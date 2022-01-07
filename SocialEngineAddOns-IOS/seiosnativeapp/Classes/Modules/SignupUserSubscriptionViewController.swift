/*
 * Copyright (c) 2016 BigStep Technologies Private Limited.
 *
 * You may not use this file except in compliance with the
 * SocialEngineAddOns License Agreement.
 * You may obtain a copy of the License at:
 * https://www.socialengineaddons.com/ios-app-license
 * The full copyright and license information is also mentioned
 * in the LICENSE file that was distributed with this
 * source code.
 */

//  SignUpUserSubscriptionViewController.swift

import UIKit
import StoreKit

var isSandboxMode = true //siteiosappMode = 1 => SandboxMode || siteiosappMode = 0 => Production Mode

class SignupUserSubscriptionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SKProductsRequestDelegate, SKPaymentTransactionObserver, UIPopoverPresentationControllerDelegate{
    
    let mainView = UIView()
    var user_id: Int!
    var tblProducts: UITableView!
    
    var productIdentifiers: Set<String> = []
    var productIDs: Array<String?> = []
    var packageIDs: Array<String?> = []
    var freePackageIDs: Array<String?> = []
    var productsArray: Array<SKProduct?> = []
    var freeProductsArray: Array<String?> = []
    
    var selectedProductIndex: Int!
    var transactionInProgress = false
    var loginOrSignup = false // true => Login, false => Signup
    var email : String!
    var pass : String!
    var bundleID: String!
    //var leftBarButtonItem : UIBarButtonItem!
    var isFromSettings = false
    var selectedPackageName = NSMutableAttributedString(string: "")
    var isFBSignUp = false
    var id = ""
    var fbAccessTokenn : String!
    //var purchaseHelper: InAppFw!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        bundleID = Bundle.main.bundleIdentifier
        
        let subViews = mainView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        setNavigationImage(controller: self)
        

        tblProducts = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), style: .plain)
        tblProducts.register(UITableViewCell.self, forCellReuseIdentifier: "idCellProduct")
        tblProducts.delegate = self
        tblProducts.dataSource = self
        tblProducts.backgroundColor = tableViewBgColor
        tblProducts.separatorColor = TVSeparatorColor
        mainView.addSubview(tblProducts)
     
        
        packageIDs.removeAll()
        freePackageIDs.removeAll()
        productIDs.removeAll()
        freeProductsArray.removeAll()
        
        //Removing all transactions from queue
        for transaction in SKPaymentQueue.default().transactions {
            SKPaymentQueue.default().finishTransaction(transaction)
        }
        
        getUserSubscriptions()
        SKPaymentQueue.default().add(self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.title = NSLocalizedString("Choose Subscription",  comment: "")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(SignupUserSubscriptionViewController.goBack))
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        AccessToken.current = nil
        SKPaymentQueue.default().remove(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableView method implementation
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isFromSettings{
            return 50.0
        }else{
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = createView(CGRect(x: PADING, y: PADING, width: view.frame.width - contentPADING, height: 40), borderColor: TVSeparatorColor, shadow: false)
        headerView.backgroundColor = tableViewBgColor
        
        let headerLabel = createLabel(CGRect(x: PADING, y: PADING, width: view.frame.width - contentPADING, height: 40), text: "", alignment: .left, textColor: textColorDark)
        headerLabel.font = UIFont(name: fontName, size: FONTSIZELarge)
        headerLabel.attributedText = selectedPackageName
        headerLabel.numberOfLines = 0
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count + freeProductsArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).row > (productsArray.count-1){
            let cell = tableView.dequeueReusableCell(withIdentifier: "idCellProduct", for: indexPath)
            
            let product = self.freeProductsArray[(indexPath as NSIndexPath).row - productsArray.count]
            cell.textLabel?.text = product
            cell.detailTextLabel?.text = product
            
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "idCellProduct", for: indexPath)
            
            let product = productsArray[(indexPath as NSIndexPath).row]
            cell.textLabel?.text = product?.localizedTitle
            cell.detailTextLabel?.text = product?.localizedDescription
            
            return cell
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProductIndex = (indexPath as NSIndexPath).row
        showActions()
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    func requestProductInfo() {
        
        if !UIDevice.isSimulator{
         
         //   productIDs.append("com.seao.seiosnativeapp.plan1")
            if SKPaymentQueue.canMakePayments() {
                
//                let productIdentifiers = NSSet(array: [productIDs as Any])
                if let obj = productIdentifiers as Set<String>?
                {
                    let productRequest = SKProductsRequest(productIdentifiers: obj)
                    productRequest.delegate = self
                    productRequest.start()
                    view.isUserInteractionEnabled = false
                    
                    self.view.addSubview(activityIndicatorView)
                    activityIndicatorView.center = self.view.center
                    activityIndicatorView.startAnimating()
                }

            }
            else {
                //print("Cannot perform In App Purchases.")
            }
            
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            activityIndicatorView.stopAnimating()
        
        
            self.view.isUserInteractionEnabled = true
        
        
        if response.products.count != 0 {
            for product in response.products {
                self.productsArray.append(product)
            }
            
            self.tblProducts.reloadData()
        }
        else {
            //print("There are no products.")
            if self.freeProductsArray.count == 0{
                let alertController = UIAlertController(title: "Message", message:
                    "You have signed up successfully, but there are no subscriptions available. \nPlease contact your site administrator to sign in to this app.", preferredStyle: UIAlertController.Style.alert)
                
                if self.loginOrSignup{
                    alertController.message = "There are no subscriptions available. \nPlease contact your site administrator to sign in to this app."
                }
                
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                    self.goBack()
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            //print(response.invalidProductIdentifiers.description)
        }
        }
    }
    
    func showActions() {
        if transactionInProgress {
            return
        }
        
        
        if selectedProductIndex > (productsArray.count-1){
            let actionSheetController = UIAlertController(title: "User Subscriptions", message: "This is a free subscription. Do you want to continue with selected subscription?", preferredStyle: UIAlertController.Style.actionSheet)
            
            let buyAction = UIAlertAction(title: "Continue", style: UIAlertAction.Style.default) { (action) -> Void in
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                var subscriptionDic = Dictionary<String, AnyObject>()
                subscriptionDic["user_id"] = self.user_id as AnyObject?
                
                if self.productsArray.count != 0{
                    if let selectedPackageId = self.freePackageIDs[(self.selectedProductIndex - self.productsArray.count)]{
                        subscriptionDic["package_id"] = "\(selectedPackageId)" as AnyObject?
                    }
                }else{
                    if let selectedPackageId = self.freePackageIDs[self.selectedProductIndex]{
                        subscriptionDic["package_id"] = "\(selectedPackageId)" as AnyObject?
                    }
                }
                
                self.setSubscription(subscriptionDic)
                
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel) { (action) -> Void in
                
            }
            
            actionSheetController.addAction(buyAction)
            actionSheetController.addAction(cancelAction)

            if let popoverController = actionSheetController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            present(actionSheetController, animated: true, completion: nil)
        }else{
            let actionSheetController = UIAlertController(title: "User Subscriptions", message: "Do you want to buy selected subscription?", preferredStyle: UIAlertController.Style.actionSheet)
            
            let buyAction = UIAlertAction(title: "Buy", style: UIAlertAction.Style.default) { (action) -> Void in
                let payment = SKPayment(product: self.productsArray[self.selectedProductIndex]! as SKProduct)
                SKPaymentQueue.default().add(payment)
                self.transactionInProgress = true
                
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel) { (action) -> Void in
                
            }            
            actionSheetController.addAction(buyAction)
            actionSheetController.addAction(cancelAction)

            if let popoverController = actionSheetController.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }

            present(actionSheetController, animated: true, completion: nil)
        }
        
        
        
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                activityIndicatorView.stopAnimating()
                view.isUserInteractionEnabled = true
                //print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                
                var subscriptionDic = Dictionary<String, AnyObject>()
                if selectedProductIndex != nil, let selectedPackageId = packageIDs[selectedProductIndex]{
                    subscriptionDic["package_id"] = "\(selectedPackageId)" as AnyObject?
                }
                subscriptionDic["transaction_id"] = transaction.transactionIdentifier as AnyObject?
                
                let transactionReceipt = getReceiptForServer(isSandboxMode)
                subscriptionDic["receipt"] = "\(transactionReceipt)" as AnyObject?
                subscriptionDic["user_id"] = user_id as AnyObject?
                
                setSubscription(subscriptionDic)
                
            case SKPaymentTransactionState.failed:
                activityIndicatorView.stopAnimating()
                view.isUserInteractionEnabled = true
                //print("Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                showToast(message: NSLocalizedString("Payment Failed. Please check your itunes detials. ", comment: ""), controller: self)
                
            default:
                activityIndicatorView.stopAnimating()
                //print(transaction.transactionState.rawValue)
            }
        }
    }
    
    func getUserSubscriptions(){
        
        //Set Parameters & path for Sign Up Form
        var parameter = [String:String]()
        var path = "signup"
        if isFromSettings{
            path = "user/upgrade-subscription"
        }
        parameter["subscriptionForm"] = "1"
        
        
//        spinner.hidesWhenStopped = true
//        spinner.style = UIstyle.gray
        view.isUserInteractionEnabled = false
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
        // Send Server Request for Sign Up Form
        post(parameter, url: path, method: "GET") { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
                if msg{
                    // On Success Add Value to Form Array & Values to formValue Array
                    Form.removeAll(keepingCapacity: false)
                    if succeeded["message"] != nil{
                        showToast(message: succeeded["message"] as! String, controller: self)
                        
                    }
                    
                    if let dic = succeeded["body"] as? NSDictionary{
                        if let subscriptionArray = dic["subscription"] as? NSArray{
                            if let plansElement = subscriptionArray[0] as? NSDictionary{
                                if let plansArray = plansElement["multiOptions"] as? NSDictionary{
                                    for (planIds, plans) in plansArray{
                                        let plansDic = plans as! NSDictionary
                                        if plansDic["label"] != nil && plansDic["price"] != nil
                                        {
                                            self.packageIDs.append("\(planIds)")
//                                            self.productIDs.append("\(self.bundleID!).plan\(planIds)")
                                            self.productIdentifiers.insert("\(self.bundleID!).plan\(planIds)")
                                            //self.purchaseHelper.addProductId("\(planIds)")
                                            
                                        }else if plansDic["label"] != nil && plansDic.object(forKey: "price") == nil{
                                            self.freePackageIDs.append("\(planIds)")
                                            self.freeProductsArray.append(plansDic["label"] as? String)
                                        }
                                    }
                                }
                            }
                        }
                        if let currentSubscriptionDic = dic["currentSubscription"] as? NSDictionary{
                            if let packageTitle = currentSubscriptionDic["title"] as? String{
                                
                                let packageLabelString = "The plan you are currently subscribed to is: "
                                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\(packageLabelString)")
                                attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                                
                                let labelString = packageTitle
                                let descString: NSMutableAttributedString = NSMutableAttributedString(string:  String("     \(labelString)"))
                                descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontBold , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                                descString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColorDark, range: NSMakeRange(0, descString.length))
                                
                                attrString.append(descString)
                                self.selectedPackageName = attrString
                            }
                        }
                        self.requestProductInfo()
                        self.tblProducts.reloadData()
                    }
                    
                    //MARK: For testing upgrade user subscription
                    //
                    //                    for (planIds, plans) in plansArray{
                    //                        let plansDic = plans as! NSDictionary
                    //                        if plansDic["label"] != nil && plansDic.object(forKey: "price") != nil
                    //                        {
                    //                            self.packageIDs.append("\(planIds)")
                    //                            self.productIDs.append("\(self.bundleID!).plan\(planIds)")
                    //
                    //                            //self.purchaseHelper.addProductId("\(planIds)")
                    //
                    //                        }else if plansDic["label"] != nil && plansDic.object(forKey: "price") == nil{
                    //                            self.freePackageIDs.append("\(planIds)")
                    //                            self.freeProductsArray.append(plansDic["label"] as? String)
                    //                        }
                    //                    }
                }
            })
        }
        
    }
    
    func setSubscription(_ parameter: Dictionary<String, AnyObject>) {
        validation = [:]
        validationMessage = ""
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            view.isUserInteractionEnabled = false
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var dic = Dictionary<String, AnyObject>()
            for (key, value) in parameter{
                
                dic["\(key)"] = value as AnyObject
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int) as AnyObject?
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String as String as AnyObject?
                }
                
            }
            
            var transactionReceiptData: AnyObject = "" as AnyObject
            
            if dic["receipt"] != nil{
                transactionReceiptData = dic["receipt"]!
                dic.removeValue(forKey: "receipt")
            }
            
            dic["isSandbox"] = "\(0)" as AnyObject
            if isSandboxMode{
                dic["isSandbox"] = "\(1)" as AnyObject
            }
            
            if device_uuid != nil{
                dic["device_uuid"] = device_uuid as AnyObject?
                if user_id != nil {
                    dic["user_id"] = "\(user_id!)" as AnyObject
                }
            }
            
            
            let path = "user/set-iosuser-subscription"
            
            receiptPost(dic, receipt:transactionReceiptData, url: path , method: "POST") { (succeeded, msg) -> () in
                // Send Server Request to Create/Edit Blog Entries
                DispatchQueue.main.async(execute: {

                    activityIndicatorView.stopAnimating()

                    if msg
                    {
                        if let body = succeeded["body"] as? NSDictionary {
                            if let isPaid = body["isPaidMember"] as? Int {
                                isPaidMember = isPaid
                            }
                        }
                    print(succeeded)
                    self.view.alpha = 1.0
                    self.view.isUserInteractionEnabled = true
                    
//                    let alertTest = UIAlertView()
//
//                    if self.isFromSettings{
//                        alertTest.message = "Subscription selected successfully."
//                    }else{
//                        if self.loginOrSignup == false{
//                            alertTest.message = "Signup Successfull. \n Logging in now.."
//                        }else{
//                            alertTest.message = "Subscription selected successfully. \n Logging in now.."
//                        }
//                    }
//
//
//                    alertTest.addButton(withTitle: "Ok")
//                    alertTest.delegate = self
//                    alertTest.title = "Message"
//                    alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
//                    alertTest.show()
                        
                        let alertController = UIAlertController(title: "Message", message:
                            "", preferredStyle: UIAlertController.Style.alert)
                        
                        if self.isFromSettings{
                            alertController.message = "Subscription selected successfully."
                        }else{
                            if self.loginOrSignup == false{
                                alertController.message = "Signup Successfull. \n Logging in now.."
                            }else{
                                alertController.message = "Subscription selected successfully. \n Logging in now.."
                            }
                        }
                        
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                            if facebook_uid != nil{
                                self.facebookLoginAfterSignup()
                            }else if self.isFromSettings{
                                self.goBack()
                            }
                            else{
                                self.signInAfterSignUp()
                            }
                        }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    
                }
                else
                {
 
            showToast(message: succeeded["message"] as! String, controller: self)
               
                }
                    
                })
            }
        }
            else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    func showHomePage () {
        menuRefreshConter = 0
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = false
            
        }
        createTabs()
        if logoutUser == true
        {
            baseController.tabBar.items![1].isEnabled = false
            baseController.tabBar.items![2].isEnabled = false
            baseController.tabBar.items![3].isEnabled = false
        }
        else
        {
            baseController.tabBar.items![1].isEnabled = true
            baseController.tabBar.items![2].isEnabled = true
            baseController.tabBar.items![3].isEnabled = true
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(baseController, animated: false)
        self.view.endEditing(true)
        
    }
    
    
    fileprivate func getReceiptForServer(_ sandbox: Bool) -> AnyObject {
        
        let url = Bundle.main.appStoreReceiptURL
        let receipt = try? Data(contentsOf: url!)
        var receiptData = ""
        if let r = receipt {
            
            receiptData = r.base64EncodedString(options: NSData.Base64EncodingOptions())
            
//            //BELOW CODE IS USERFUL IN TESTING PURPOSE
//                        let requestContent = [ "receipt-data" : receiptData ]
//
//                        do {
//                            let requestData = try JSONSerialization.data(withJSONObject: requestContent, options:[])
//
//                            let storeURL = NSURL(string: "https://buy.itunes.apple.com/verifyReceipt")
//                            let sandBoxStoreURL = NSURL(string: "https://sandbox.itunes.apple.com/verifyReceipt")
//
//                            let finalURL = sandbox ? sandBoxStoreURL : storeURL
//
//                            let storeRequest = NSMutableURLRequest(url: finalURL! as URL)
//                            storeRequest.httpMethod = "POST"
//                            storeRequest.httpBody = requestData
//
//                            let task = URLSession.shared.dataTask(with: storeRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
//                                if (error != nil) {
//                                    //print("Validation Error: \(error)")
//                                }
//                            })
//
//                            task.resume()
//
//                        } catch {
//                            //print("validateReceipt: Caught error")
//                        }
            
        }
        return receiptData as AnyObject
        
    }
    
    //MARK: - alertView
//    func alertView(_ alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
//    {
//
//        switch buttonIndex
//        {
//        case 0:
//
//            alertView.removeFromSuperview()
//            alertView.isHidden = true
//            if facebook_uid != nil{
//                self.facebookLoginAfterSignup()
//            }else if isFromSettings{
//                self.goBack()
//            }
//            else{
//                self.signInAfterSignUp()
//            }
//            break
//
//        default: break
//
//        }
//    }
    
    //FUNCTION CALLED WHEN SUCCESSFUL SUBSCRIPTION AFTER NORMAL LOGIN OR SIGNUP
    func signInAfterSignUp(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            view.isUserInteractionEnabled = false
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            // Send Server Request for Sign In
            var dic: Dictionary<String, String>
            if apple_id != ""
                       {
                            dic = ["apple_id":"\(apple_id)", "ip":"127.0.0.1","subscriptionForm": "1"]
                       }
            else{
            if loginOrSignup == false{
                if signupDictionary["email"] != nil {
                    dic = ["email":"\(signupDictionary["email"]!)", "password":"\(signupDictionary["password"]!)", "ip":"127.0.0.1","device_uuid":String(device_uuid), "device_token":String(device_token_id), "subscriptionForm": "1", "ignoreOTP":"1"]
                }
                else{
                    dic = ["emailaddress":"\(signupDictionary["emailaddress"]!)", "password":"\(signupDictionary["password"]!)", "ip":"127.0.0.1","device_uuid":String(device_uuid), "device_token":String(device_token_id), "subscriptionForm": "1","ignoreOTP":"1"]
                }
            }else{
                dic = ["email":email, "password":pass, "ip":"127.0.0.1", "device_uuid": String(device_uuid), "device_token": String(device_token_id), "subscriptionForm": "1"]
                
            }
            }
            if device_uuid != nil{
                dic.updateValue(device_uuid, forKey: "device_uuid")
            }
            if device_token_id != nil{
                dic.updateValue(device_token_id, forKey: "device_token")
            }
          
            post(dic, url: "login", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    self.view.isUserInteractionEnabled = true
                    activityIndicatorView.stopAnimating()
                    // On Success save authentication_token in Core Data
                    if(msg)
                    {
                        
                        // Get Data From Core Data
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                        }
                        if succeeded["body"] != nil{
                            // Perform Login Action
                            //UserDefaults.standard.removeObject(forKey: "AppleEmail")
                            let defaults = UserDefaults.standard
                            defaults.set("\(String(describing: signupDictionary["password"]))", forKey: "userPassword")
                            if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                DispatchQueue.main.async(execute:{
                                    mergeAddToCart()
                                    self.showHomePage()
                                })
                            }else{
                                self.view.makeToast(NSLocalizedString("Unable to Login",comment: ""), duration: 5, position: CSToastPositionCenter)
                            }
                        }
                    }
                        
                    else{
                        // Handle Server Side Error Massages
                        if succeeded["message"] != nil{
                            
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
//                            let pv = LoginViewController()
//                            self.navigationController?.pushViewController(pv, animated: true)
                            if isEmailValidationEnabled
                            {
                                self.isFBSignUp = false
                                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(SignupUserSubscriptionViewController.signInAfterEmailVerification))
                            }
                            
                        }
                        
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    
    //FUNCTION CALLED WHEN SUCCESSFUL SUBSCRIPTION AFTER FACEBOOK LOGIN OR SIGNUP
    func facebookLoginAfterSignup()
    {
        
        if((AccessToken.current) != nil){
            
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email,picture.type(large)"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    
                    let resultDic = result as! NSDictionary
                    
                    self.id = resultDic["id"]! as! String
                    
                    if resultDic["email"] != nil {
                        fbEmail = resultDic["email"]! as! String
                    }else{
                        fbEmail = ""
                    }
                    
                    if resultDic["first_name"] != nil {
                        fbFirstName = resultDic["first_name"]! as! String
                        fbFirstName = fbFirstName.lowercased()
                    }else{
                        fbFirstName = ""
                    }
                    
                    if resultDic["last_name"] != nil {
                        fbLastName = resultDic["last_name"]! as! String
                        fbLastName = fbLastName.lowercased()
                    }else{
                        fbLastName = ""
                    }
                    
                    if let picture = resultDic["picture"] as? NSDictionary{
                        if let data = picture["data"] as? NSDictionary{
                            fbImageUrl = data["url"] as! String
                        }
                    }
                    
                    self.fbAccessTokenn = AccessToken.current?.tokenString
                    // Check Internet Connection
                    if Reachabable.isConnectedToNetwork() {
//                        spinner.hidesWhenStopped = true
//                        spinner.style = UIstyle.white
//                        self.view.addSubview(spinner)
                        self.view.addSubview(activityIndicatorView)
                        activityIndicatorView.center = self.view.center
                        activityIndicatorView.startAnimating()
                        
                        userInteractionOff = true
                        var loginParams = ["facebook_uid":"\(self.id)", "code":"%2520", "access_token":"\(self.fbAccessTokenn)", "ip":"127.0.0.1"]
                        
                        if device_uuid != nil{
                            loginParams.updateValue(device_uuid, forKey: "device_uuid")
                        }
                        if device_token_id != nil{
                            loginParams.updateValue(device_token_id, forKey: "device_token")
                        }
                        
                        // Send Server Request for Sign In
                        post(loginParams, url: "login", method: "POST") { (succeeded, msg) -> () in
                            
                            DispatchQueue.main.async(execute: {
                                activityIndicatorView.stopAnimating()
                                // On Success save authentication_token in Core Data
                                if(msg)
                                {
                                    // Get Data From Core Data
                                    if succeeded["message"] != nil{
                                        self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                                    }
                                    if succeeded["body"] != nil{
                                        if let body = succeeded["body"] as? NSDictionary{
                                            if var _ = body["oauth_token"] as? String
                                            {
                                                if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                                    userInteractionOff = false
                                                    DispatchQueue.main.async(execute: {
                                                        mergeAddToCart()
                                                        self.showHomePage()
                                                    })
                                                }else{
                                                    userInteractionOff = false
                                                    self.view.makeToast(NSLocalizedString("Unable to Login",comment: ""), duration: 5, position: CSToastPositionCenter)
                                                }
                                            }
                                        }
                                        
                                    }
                                    
                                }
                                else{
                                    // Handle Server Side Error Massages
                                    if succeeded["message"] != nil{
                                        showToast(message: succeeded["message"] as! String, controller: self)
                                        
                                        if isEmailValidationEnabled
                                        {
                                            self.isFBSignUp = true
                                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(SignupUserSubscriptionViewController.signInAfterEmailVerification))
                                        }
                                    }
                                    
                                }
                            })
                        }
                    }else{
                        // No Internet Connection Message
                        showToast(message: network_status_msg, controller: self)
                    }
                }
            })
        }
        else
        {
            facebook_uid = nil
        }
    }
    //FUNCTION CALLED WHEN SUCCESSFUL SUBSCRIPTION AFTER NORMAL LOGIN OR SIGNUP
    @objc func signInAfterEmailVerification(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
           // view.isUserInteractionEnabled = false
            // Send Server Request for Sign In
            var dic : Dictionary<String, String>
            if isFBSignUp
            {
                dic = ["facebook_uid":"\(id)", "code":"%2520", "access_token":"\(fbAccessTokenn!)", "ip":"127.0.0.1"]
            }
            else
            {
                if loginOrSignup == false{
                    if signupDictionary["email"] != nil {
                        dic = ["email":"\(signupDictionary["email"]!)", "password":"\(signupDictionary["password"]!)", "ip":"127.0.0.1","device_uuid":String(device_uuid), "device_token":String(device_token_id), "subscriptionForm": "1"]
                    }
                    else{
                        dic = ["email":"\(signupDictionary["emailaddress"]!)", "password":"\(signupDictionary["password"]!)", "ip":"127.0.0.1","device_uuid":String(device_uuid), "device_token":String(device_token_id), "subscriptionForm": "1"]
                    }
                }else{
                    dic = ["email":email, "password":pass, "ip":"127.0.0.1", "device_uuid": String(device_uuid), "device_token": String(device_token_id), "subscriptionForm": "1"]
                    
                }
            }
            if apple_id != ""
            {
              dic["apple_id"] = "\(apple_id)"
            }
            if device_uuid != nil{
                dic.updateValue(device_uuid, forKey: "device_uuid")
            }
            if device_token_id != nil{
                dic.updateValue(device_token_id, forKey: "device_token")
            }
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            print("email-verification == \(dic)")
            post(dic, url: "email-verification", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                   // self.view.isUserInteractionEnabled = true
                    // On Success save authentication_token in Core Data
                    activityIndicatorView.stopAnimating()
                    if(msg)
                    {
                        
                        // Get Data From Core Data
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                        }
                        if succeeded["body"] != nil{
                            // Perform Login Action
                           // UserDefaults.standard.removeObject(forKey: "AppleEmail")
                            let defaults = UserDefaults.standard
                            defaults.set("\(String(describing: signupDictionary["password"]))", forKey: "userPassword")
                            if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                DispatchQueue.main.async(execute:{
                                    mergeAddToCart()
                                    self.showHomePage()
                                })
                            }else{
                                self.view.makeToast(NSLocalizedString("Unable to Login",comment: ""), duration: 5, position: CSToastPositionCenter)
                            }
                        }
                    }
                        
                    else{
                        // Handle Server Side Error Massages
                        if succeeded["message"] != nil{
                            
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
//                            let pv = LoginViewController()
//                            self.navigationController?.pushViewController(pv, animated: true)
                       
//
                        }
                        
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    
    @objc func goBack(){
        
        if logoutUser == true{
            self.navigationController?.navigationBar.isHidden = false
            if showAppSlideShow == 1 {
                let presentedVC  = SlideShowLoginScreenViewController()
                self.navigationController?.pushViewController(presentedVC, animated: true)
                
            }
            else{
            let pv = LoginViewController()
            navigationController?.pushViewController(pv, animated: true)
            }
        }else{
            _ = navigationController?.popViewController(animated: false)
        }
    }
   
    
}

extension UIDevice {
    static var isSimulator: Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil
    }
}
