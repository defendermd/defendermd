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

//  SignupProfileFieldController.swift

import UIKit
var tempDictionary : NSDictionary!
var profilekeys : NSArray!
extension Dictionary {
    mutating func update(_ other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}

@objcMembers class SignupProfileFieldController: FXFormViewController, UIPopoverPresentationControllerDelegate,UIAlertViewDelegate, ReturnLocationToForm {
    
    var popAfterDelay:Bool!
    var id:Int!
    var Subscriptionurl: String = ""
    var leftBarButtonItem : UIBarButtonItem!
    var checkBoxNameKey : String!
    var validationValues = NSDictionary()
    var isReloadForm = false
    // Initialization of class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(SignupProfileFieldController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
        popAfterDelay = false
        self.title = NSLocalizedString("Sign Up", comment: "")
        conditionalForm = "signupProfileForm"
        generateSignUpProfileForm()
        
    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        
        if popAfterDelay == true{
            _ = navigationController?.popViewController(animated: true)

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if isReloadForm {
            self.formController.form = CreateNewForm()
            self.formController.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationInForm = ""
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int)
    {
        
        switch buttonIndex
        {
        case 0:
            
            alertView.removeFromSuperview()
            alertView.isHidden = true
            if showAppSlideShow == 1 {
                let presentedVC  = SlideShowLoginScreenViewController()
                self.navigationController?.pushViewController(presentedVC, animated: true)
                
            }
            else{
            let presentedVC = LoginViewController()
            self.navigationController?.pushViewController(presentedVC, animated: true)
            }
            break
            
        default: break
            
        }
    }
    
    // MARK: - Server Connection For Blog Form Creation & Submission
    
    // FXFormForm Submission for Create or Edit Blog
    func submitForm(_ cell: FXFormFieldCellProtocol) {
        validation = [:]

        //we can lookup the form from the cell if we want, like this:
        
        let form = cell.field.form as! CreateNewForm
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            view.isUserInteractionEnabled = false
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
            UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
            
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var dic = Dictionary<String, String>()
            
            for formDic in Form
            {
                if let dicform = formDic as? NSDictionary
                {
                    let keyName = dicform["name"] as? String ?? ""
                    let formValue = form.valuesByKey["\(keyName)"] as? String ?? ""
                    let type = dicform["type"] as? String ?? ""
                    if type == "Select" || type == "select" || type == "radio" || type == "Radio"
                    {
                        if let options = dicform["multiOptions"] as? NSDictionary
                        {
                            for(key,_) in options
                            {
                                
                                var valueToString = ""
                                if let value = options["\(key)"] as? String
                                {
                                    valueToString = value
                                }
                                if let value = options["\(key)"] as? Int
                                {
                                    valueToString = String(value)
                                }
                                if valueToString == formValue
                                {
                                    dic["\(keyName)"] = key as? String
                                }
                            }
                        }
                        else if let options = dicform["multiOptions"] as? NSArray
                        {
                            for value in options
                            {
                                if value as! String == formValue
                                {
                                    dic["\(keyName)"] = formValue
                                }
                            }
                        }
                    }
                    
                    else if type == "MultiCheckbox"
                    {
                        if let options = dicform["multiOptions"] as? NSDictionary
                        {
                            for(_,value) in options
                            {
                                let checkKeyName = value as? String ?? ""
                                let value = form.valuesByKey["\(checkKeyName)"]
                                if let receiver = value as? Int
                                {
                                    dic["\(checkKeyName)"] = String(receiver)
                                }
                            }
                        }
                    }
                    
                    else
                    {
                        let value = form.valuesByKey["\(keyName)"]
                        if let receiver = value as? NSString
                        {
                            dic["\(keyName)"] = receiver as String
                        }
                        if let receiver = value as? Int
                        {
                            dic["\(keyName)"] = String(receiver)
                        }
                        if let receiver = value as? Date
                        {
                            let tempString = String(describing: receiver)
                            let tempArray = tempString.components(separatedBy: "+")
                            dic["\(keyName)"] = tempArray[0] as String
                        }
                    }
                }
            }
//
//            for (key, value) in form.valuesByKey
//            {
//
//                let string = "\(key)"
//                if (key as! NSString == "draft") || (key as! NSString == "category_id") || (key as! NSString == "auth_view") || (key as! NSString == "auth_comment" || (key as! NSString == "timezone") || (key as! NSString == "language") || (key as! NSString == "profile_type")){
//                    dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
//                }
//                else if string.range(of: "alias_gender") != nil || string.range(of: "alias_country") != nil || string.range(of: "1_16_52_alias_") != nil || string.range(of: "1_1_137_alias_") != nil || string.range(of: "1_1_158_alias_gyear") != nil || string.range(of: "1_1_77_alias_") != nil || string.range(of: "1_1_80_alias_") != nil || string.range(of: "1_9_5_alias_gender") != nil || string.range(of: "1_9_137_alias_") != nil || string.range(of: "1_9_158_alias_gyear") != nil || string.range(of: "1_1_5_alias_gender") != nil
//                {
//                    dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
//                }
//                else
//                {
//                    if let receiver = value as? NSString {
//                        dic["\(key)"] = receiver as String
//                    }
//                    if let receiver = value as? Int {
//                        dic["\(key)"] = String(receiver)
//                    }
//                    if let receiver = value as? Date {
//                        let tempString = String(describing: receiver)
//
//                        let tempArray = tempString.components(separatedBy: "+")
//                        dic["\(key)"] = tempArray[0] as String
//                    }
//
//                }
//            }
//
            for i in 0 ..< (Form.count) where i < Form.count
            {
                let dic3 = Form[i] as! NSDictionary
                let type = dic3["type"] as! String
                var checkboxValue = ""
                if type == "MultiCheckbox"
                {
                    checkBoxNameKey = dic3["name"] as! String
                    
//                    if let dict = (dic3["multiOptions"] as? NSDictionary) as? [AnyHashable : Any] as NSDictionary?
//                    {
//                        multiDic = dict
                        var Repetvalues = "" as String
                        
                        // Getting Multipotion values
                        if let option = dic3["multiOptions"] as? NSDictionary
                        {
                            Repetvalues = getmultioptionvaluse(options: option, formdic: form)
                            //print(Repetvalues)
                            
                        }
                        if Repetvalues != ""
                        {
                            let arr = Repetvalues.components(separatedBy: ",")
                            dic[checkBoxNameKey] = GetjsonObject(data:arr as AnyObject)
                        }
                        
//                        for(key,value) in multiDic
//                        {
//                            for(key2,value2) in dic
//                            {
//                                if key2 == value as! String
//                                {
//                                    if value2 == "1"
//                                    {
//                                        checkboxValue += key as! String+","
//                                    }
//                                }
//                            }
//                        }
                        
//                    }
                    
                    
//                    if checkboxValue.length > 0
//                    {
//                        checkboxValue = checkboxValue.substring(to: checkboxValue.index(before: checkboxValue.endIndex))
//
//                    }
                    //print(checkboxValue)
//                    dic["\(checkBoxNameKey!)"] = checkboxValue
                }
            }
            
            dic["account_validation"] = "0"
            dic["fields_validation"] = "1"
            dic["subscriptionForm"] = "1"
            signupDictionary.update(dic)
            //            dic.update(signupDictionary)
            //            signupDictionary = dic
            //            dic["account_validation"] = "0"
            //            dic["fields_validation"] = "1"
            //Set Parameters (Token & Form Values) & path for Create/Edit Blog Form
            validationMessage = ""
            var parameter = [String:String]()
            var path = ""
            parameter = signupDictionary
            
            if signUpPhotoFlag == true {
                path = "signup/validations"
            }else{
                parameter["ip"] = "127.0.0.1"
                if apple_id != ""
                {
                   parameter["apple_id"] = "\(apple_id)"
                }
                if(facebook_uid != nil)
                {
                    path = "signup?facebook_uid=" + String(facebook_uid) + "&code=%20%20&access_token=" + String(access_token)
                }
                else
                {
                    path = "signup"
                }
                
            }
            // Send Server Request to Create/Edit Blog Entries
            post(parameter,url: path , method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.view.alpha = 1.0
                    self.view.isUserInteractionEnabled = true
                    if msg{
                        
                        if signUpPhotoFlag == true {
                            let presentedVC = SignupProfilePhotoController()
                            self.navigationController?.pushViewController(presentedVC, animated: true)
                        }else if signUpUserSubscriptionEnabled == true {
                            
                            let alertController = UIAlertController(title: "Message", message:
                                NSLocalizedString("You have successfully signed up. Please choose a Subscription Plan for your account.",comment: ""), preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                                let presentedVC = SignupUserSubscriptionViewController()
                                if succeeded["body"] != nil{
                                    if let response = succeeded["body"] as? NSDictionary{
                                        
                                        if let userId = response["user_id"] as? Int{
                                            presentedVC.user_id = userId
                                        }
                                        else if let  user = response["user"] as? NSDictionary
                                        {
                                            if let userId = user["user_id"] as? Int{
                                                presentedVC.user_id = userId
                                            }
                                        }
                                        
                                    }
                                }
                                
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                            }))
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                        }
                        else{
                            if succeeded["body"] != nil{
                                if let _ = succeeded["body"] as? NSDictionary{
                                    // Perform Login Action
                                    if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                        DispatchQueue.main.async(execute:{
                                            mergeAddToCart()
                                           // UserDefaults.standard.removeObject(forKey: "AppleEmail")
                                            self.showHomePage()
                                        })
                                    }else{
                                        showToast(message: "Unable to Login", controller: self)
                                    }
                                }
                            }
                            else {
                                if isEmailValidationEnabled {
                                    showToast(message: "Thanks for joining! An email for the account verification has been sent to registered email ID", controller: self, onView: false, time: 3.0)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                        if showAppSlideShow == 1 {
                                            self.navigationController?.pushViewController(SlideShowLoginScreenViewController(), animated: true)
                                        }
                                        else{
                                            self.navigationController?.pushViewController(LoginScreenViewController(), animated: true)
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                        
                        
                    }else{
                        
                        self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                        if  (UIDevice.current.userInterfaceIdiom == .phone){
                            let a = validation as NSDictionary
                            self.validationValues = validation
                            signupValidation.removeAll(keepingCapacity: false)
                            signupValidationKeyValue.removeAll(keepingCapacity: false)
                            for (key,value) in a  {
                                signupValidation.append(value as AnyObject)
                                signupValidationKeyValue.append(key as AnyObject)
                                
                            }
                            
                            let count = signupValidation.count
                            if count == 1 || count == 0
                            {
                               self.showRequiredAlert()
                            }
                            else
                            {
                                for index in 0 ..< count {
                                    showToast(message: "\(signupValidation[index] as! String)\n", controller: self)
                                }
                            }
//                            if count == 0{
//                                self.showRequiredAlert()
//                            }
                            
                            
                        }else{
                            let a = validation as NSDictionary
                            signupValidation.removeAll(keepingCapacity: false)
                            
                            for (_,value) in a  {
                                signupValidation.append(value as AnyObject)
                            }
                            
                            if signupValidation.count != 0{
                                let secondViewController = SignUpValidationController()
                                secondViewController.validationArray = signupValidation as NSArray?
                                secondViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                                secondViewController.preferredContentSize = CGSize(width: self.view.bounds.width*0.8,height: self.view.bounds.height*0.35)
                                
                                let popoverpresentationviewcontroller = secondViewController.popoverPresentationController
                                popoverpresentationviewcontroller?.delegate = self
                                popoverpresentationviewcontroller?.permittedArrowDirections = UIPopoverArrowDirection()
                                popoverpresentationviewcontroller?.sourceRect = CGRect( x: 0, y: self.view.bounds.height/3 , width: self.view.bounds.width , height: self.view.bounds.height/3)
                                popoverpresentationviewcontroller?.sourceView = self.view
                                self.navigationController?.present(secondViewController, animated: false, completion: nil)
                            }
                            
                        }
                        
                    }
                })
            }
        }
    }
    
    // Create Request for Generation of Create/Edit Blog Form
    func generateSignUpProfileForm(){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
            UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
           // self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            //Set Parameters & path for Create/Edit Blog Form
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            path = "signup"
            // Send Server Request for Create/Edit Blog Form
            post(parameter, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Add Value to Form Array & Values to formValue Array
                        Form.removeAll(keepingCapacity: false)
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        if let dic = succeeded["body"] as? NSDictionary{
                            if( dic["fields"] is NSDictionary ){
                                let tempDictionary1 = dic["fields"] as! NSDictionary
                                if profileType != nil {
                                    if let profileFields = tempDictionary1[profileType] as? NSDictionary
                                    {
                                        tempDictionary = profileFields
                                        profilekeys = tempDictionary.allKeys as NSArray?
                                        
                                        var tempArray = [AnyObject]()
                                        var allKeys = tempDictionary.allValues
                                        
                                        for temp in stride(from: 0, to: allKeys.count, by: 1){
                                            tempArray = tempArray + ((allKeys[temp] as! NSArray) as [AnyObject])
                                        }
                                        
                                        Form = tempArray
                                    }
                                }else{
                                    tempDictionary = tempDictionary1
                                    profilekeys = tempDictionary.allKeys as NSArray?
                                    var tempArray = [AnyObject]()
                                    var allKeys = tempDictionary.allValues
                                    for temp in stride(from: allKeys.count-1, through: 0, by: -1){
                                        tempArray = tempArray + ((allKeys[temp] as! NSArray) as [AnyObject])
                                    }
                                    
                                    Form = tempArray
                                }
                            }else{
                                let accountArray = dic["fields"] as? NSArray
                                Form = accountArray! as [AnyObject]
                            }
                        }
                        // Create FXForm Form
                        self.formController.form = CreateNewForm()
                        self.formController.tableView.reloadData()
                    }else{
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
        }
    }
    
    // MARK: - Member Homepage redirection
    func showHomePage () {
        menuRefreshConter = 0
        //fOR SHOWING WELCOME MESSAGE ON ADVANCEACTIVITYFEED
        let defaults = UserDefaults.standard
        defaults.set("LoginScreenViewController", forKey: "Comingfrom")
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func goBack()
    {
        let alertController = UIAlertController(title: NSLocalizedString("Go Back?", comment: ""), message:NSLocalizedString("Are you sure that you want to go back?", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Go Back", comment: ""), style: UIAlertAction.Style.default,handler: { action -> Void in
            _ = self.navigationController?.popViewController(animated: true)

        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    @objc func formLocation(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        for (key2,_) in form.valuesByKey
        {
            Formbackup["\(key2)"] = form.valuesByKey["\(key2)"]
        }
        print(Formbackup)
        let presentedVC = BrowseLocationViewController()
        presentedVC.delegate = self as ReturnLocationToForm
        presentedVC.fromFormGeneration = true
        presentedVC.fromMainForm = true
        self.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    func sendLocation(location: String)
    {
        locationInForm = location
    }
    
    func isReloadForm(reload: Bool)
    {
       self.isReloadForm = reload
    }
    
    func sendLocationParam(locationParam: [String : Any])
    {
        //Not required for Now
    }
    
    func showRequiredAlert(){
        if validationMessage != ""{
            validationMessage = validationMessage.html2String as String
            let alertTest = UIAlertView()
            alertTest.message = "\(validationMessage)"
            alertTest.addButton(withTitle: "Ok")
            alertTest.delegate = self
            alertTest.title = "Message"
            alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
            alertTest.show()
        }
        else if SubscriptionMessage != ""{
            if signUpUserSubscriptionEnabled == true {
                let presentedVC = SignupUserSubscriptionViewController()
                self.navigationController?.pushViewController(presentedVC, animated: true)
            }else{
                let myString: String = "<a href="
                
                var myStringArr = SubscriptionMessage.components(separatedBy: myString)
                let tempAnotherString = myStringArr[1]
                let temp1: String = ">"
                
                var myStringArr1 = tempAnotherString.components(separatedBy: temp1 )
                self.Subscriptionurl = myStringArr1[0]
                
                self.Subscriptionurl = self.Subscriptionurl.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                SubscriptionMessage = SubscriptionMessage.html2String as String
                let alertTest = UIAlertView()
                alertTest.message = "\(SubscriptionMessage)"
                alertTest.addButton(withTitle: "Ok")
                alertTest.delegate = self
                alertTest.title = "Message"
                alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
                alertTest.show()
            }
        }
        else
        {
            for (key,value) in self.validationValues
            {
                let validationName = key as? String ?? ""
                if validationName == "password"
                {
                    if let message = value as? String
                    {
                        let alertController = UIAlertController(title: "Message", message:
                            message, preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                            if showAppSlideShow == 1 {
                                let presentedVC  = SlideShowLoginScreenViewController()
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                            }
                            else{
                                let presentedVC = LoginViewController()
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                            }
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                
            }
        }
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
