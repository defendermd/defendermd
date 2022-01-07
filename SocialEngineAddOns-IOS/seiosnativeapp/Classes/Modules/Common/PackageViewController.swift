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

//  PackageViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 18/05/16.
//  Copyright © 2016 bigstep. All rights reserved.


import UIKit
var packageCheck = true
class PackageViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    
    var contentType : String!
    var url : String!
    var PackageTableview : UITableView!
    var responseArr:NSArray!
    var dynamicHeight : CGFloat = 60
    var contentGutterMenu: NSArray = []
    var packagetitle :String!
    var leftBarButtonItem : UIBarButtonItem!
    var listingTypeId:Int!
    var contentId: Int!
    var storeID : String!
    var storeId : Int!
    var deleteShippingEntry:Bool!
    var noSearchResultsIcon : UILabel!
    var noSearchResultsMessage : UILabel!
    var urlParams:NSDictionary!
    
    var popAfterDelay:Bool!
    var isUpgradePackageScreen = false
    var isPackageUpdate = false
    var selectedPackageName = NSMutableAttributedString(string: "")
    var eventExtensionCheck = false
    
    var extensionUrl = ""
    var extensionParam : NSDictionary!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.view.backgroundColor = bgColor
        
        popAfterDelay = false
        
        PackageTableview = UITableView(frame: CGRect(x: 0,y: 0, width: view.bounds.width, height: view.bounds.height), style: .grouped)
        PackageTableview.register(PackageTableViewCell.self, forCellReuseIdentifier: "Cell")
        PackageTableview.estimatedRowHeight = 60.0
        PackageTableview.separatorStyle = UITableViewCell.SeparatorStyle.none
        PackageTableview.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        PackageTableview.backgroundColor = tableViewBgColor
        self.PackageTableview.isOpaque = false
        self.view.addSubview(PackageTableview)
        
        
        noSearchResultsIcon = createLabel(CGRect(x: self.PackageTableview.bounds.width/2 - 30, y: self.PackageTableview.bounds.height/2-100, width: 60, height: 50), text: NSLocalizedString("\u{f0d1}",  comment: "") , alignment: .center, textColor: buttonColor)
        noSearchResultsIcon.font = UIFont(name: "FontAwesome", size: 50)
        noSearchResultsIcon.isHidden = true
        PackageTableview.addSubview(noSearchResultsIcon)
        
        noSearchResultsMessage = createLabel(CGRect(x: 0, y: getBottomEdgeY(inputView: noSearchResultsIcon) + (2 * PADING), width: self.PackageTableview.bounds.width , height: 30), text: NSLocalizedString("No Shipping Method Available. Please Add!",  comment: "") , alignment: .center, textColor: buttonColor)
        noSearchResultsMessage.numberOfLines = 0
        noSearchResultsMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        noSearchResultsMessage.backgroundColor = bgColor
        noSearchResultsMessage.tag = 1000
        noSearchResultsMessage.isHidden = true
        PackageTableview.addSubview(noSearchResultsMessage)
        
        
    
    }

    override func viewWillAppear(_ animated: Bool)
    {
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = navColor
        noSearchResultsMessage.isHidden = true
        noSearchResultsIcon.isHidden = true
        if contentType == "shippingMethod"
        {
            self.title = NSLocalizedString("Shipping Methods", comment: "")
        } else {
            self.title = NSLocalizedString("Select Package",  comment: "")
        }
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(PackageViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        if contentType == "shippingMethod" {
            let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(PackageViewController.addStore))
            self.navigationItem.rightBarButtonItem = addButton
        }
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        if conditionalProfileForm == "BrowsePage"
        {
            self.dismiss(animated: true, completion: nil)
            
        }
        else if conditionalProfileForm == "BrowseStore"
        {
            let presentedVC = StoreInitialConfiguration()
            presentedVC.storeid = createResponse["store_id"] as! Int
            presentedVC.storeID = String(describing: createResponse["store_id"] as! Int)
            let nativationController = UINavigationController(rootViewController: presentedVC)
            nativationController.modalPresentationStyle = .fullScreen
            self.present(nativationController, animated:false, completion: nil)
            //self.present(presentedVC, animated: false, completion: nil)
        }
        

        if conditionalProfileForm == "" && packageCheck == false {
            packageCheck = true
            self.dismiss(animated: true, completion: nil)
        }
        

        else if conditionalProfileForm == "BrowseMyStore"
        {
            
            conditionalProfileForm = "BrowseStoreProfile"
            self.dismiss(animated: true, completion: nil)
        }

        exploreContent()
    }
    @objc func addStore()
    {
        let presentedVC = AddShippingMethodViewController()
        presentedVC.contentType = "addNewShippingMethod"
        presentedVC.storeId = storeID
        tempCategArray.removeAll(keepingCapacity: false)
        tempFormArray.removeAll(keepingCapacity: false)
        tempTempCategArray.removeAll(keepingCapacity: false)
        let nativationController = UINavigationController(rootViewController : presentedVC)
        self.present(nativationController, animated : false, completion : nil)
    }
    
    @objc func cancel()
    {
            self.dismiss(animated: true, completion: nil)

    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        
        return 0.00001
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isUpgradePackageScreen{
            return 50.0
        }else{
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = createView(CGRect(x: PADING, y: PADING, width: view.frame.width - contentPADING, height: 40), borderColor: TVSeparatorColor, shadow: false)
        headerView.backgroundColor = UIColor.white
        
        let headerLabel = createLabel(CGRect(x: PADING, y: PADING, width: view.frame.width - contentPADING, height: 40), text: "", alignment: .left, textColor: textColorDark)
        headerLabel.font = UIFont(name: fontName, size: FONTSIZELarge)
        headerLabel.attributedText = selectedPackageName
        headerLabel.numberOfLines = 0
        headerLabel.sizeToFit()
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return responseArr.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var packageInfo:NSDictionary!
        packageInfo = responseArr[indexPath.row] as! NSDictionary
        var packagedic = packageInfo["package"] as? NSDictionary
        if contentType == "shippingMethod" {
            packagedic = packageInfo["method"] as? NSDictionary
        }
        let tittledic = packagedic!["title"] as? NSDictionary
        if tittledic != nil
        {
            let tittle = tittledic!["value"] as? String
            packagetitle = "\(tittle!)"
        }
        
        if contentType == "shippingMethod"
        {
            //print("hello")
            let presentedVC = PackageDetailViewController()
            presentedVC.Formtittle = self.packagetitle
            presentedVC.contentType = self.contentType
            presentedVC.responsedic = self.responseArr[indexPath.row] as! NSDictionary
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
        
        if let guttermenu = packageInfo["menu"] as? NSArray
        {
            if let menuItem = guttermenu[1] as? NSDictionary
            {                
                let presentedVC = PackageDetailViewController()
                if self.eventExtensionCheck == true {
                    presentedVC.eventExtensionCheck = true
                    presentedVC.extParam = self.extensionParam
                    presentedVC.extUrl = self.extensionUrl
                }
                presentedVC.contentType = self.contentType
                presentedVC.Formtittle = self.packagetitle
                presentedVC.responsedic = self.responseArr[indexPath.row] as! NSDictionary
                presentedVC.url = menuItem["url"] as! String
                presentedVC.param = menuItem["urlParams"] as! NSDictionary
                presentedVC.listingTypeId = self.listingTypeId
                presentedVC.isUpgradePackageScreen = self.isUpgradePackageScreen
                self.navigationController?.pushViewController(presentedVC, animated: true)
            }
            
        }
        
    }
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PackageTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = UIColor.clear
        let dic = responseArr.object(at: (indexPath as NSIndexPath).row)
        let packageResponseDic = dic as! NSDictionary
        var packagedic = packageResponseDic["package"] as? NSDictionary
        
        if contentType == "shippingMethod" {
            packagedic = packageResponseDic["method"] as? NSDictionary
        }
        
        let tittledic = packagedic!["title"] as? NSDictionary
        if tittledic != nil
        {
            let tittle = tittledic!["value"] as? String
            if tittle != nil
            {
                cell.lbltitle.text = tittle
            }
        }
        
        cell.btnmenu.tag = (indexPath as NSIndexPath).row
        cell.btnmenu.addTarget(self, action: #selector(PackageViewController.showGutterMenuOptions(_:)), for: .touchUpInside)

        cell.lineView.frame = CGRect(x: 0, y: cell.lbltitle.frame.origin.y + cell.lbltitle.bounds.height+20, width: cell.cellView.frame.size.width, height: 1)
        
        dynamicHeight = 60
        
        if dynamicHeight < (cell.lineView.frame.origin.y + cell.lineView.bounds.height)
        {
            dynamicHeight = (cell.lineView.frame.origin.y + cell.lineView.bounds.height+1)
            cell.cellView.frame.size.height = dynamicHeight
        }
        cell.btnmenu.frame = CGRect(x: cell.cellView.frame.size.width-50, y: cell.cellView.frame.size.height/2-12, width: 25, height: 25)
        return cell
    }
    
    // MARK: Guttermenu implimentation
    @objc func showGutterMenuOptions(_ sender: UIButton)
    {
        var packageInfo:NSDictionary!
        packageInfo = responseArr[sender.tag] as! NSDictionary
        var packagedic = packageInfo["package"] as? NSDictionary
        
        if contentType == "shippingMethod" {
            packagedic = packageInfo["method"] as? NSDictionary
        }

        let tittledic = packagedic!["title"] as? NSDictionary
        if tittledic != nil
        {
            let tittle = tittledic!["value"] as? String
            packagetitle = "\(tittle!)"
        }
        
        if let guttermenu2 = packagedic?["menu"] as? NSArray
        {
            self.contentGutterMenu = guttermenu2 as NSArray
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in contentGutterMenu
            {
                if let menuItem = menu as? NSDictionary
                {
                    let actionUrl = menuItem["url"] as! String
                    let params = menuItem["urlParams"] as! NSDictionary
                    let titleString = menuItem["name"] as! String
                    if titleString.range(of: "delete") != nil
                     {
                        
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                     
                            let condition = menuItem["name"] as! String
                            switch(condition){
                     
                            case "delete_method":
                     
                            displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this Method?",comment: "") , otherButton: NSLocalizedString("Delete Method", comment: "")) { () -> () in
                                self.deleteShippingEntry = true
                                //StoresProfileViewController.performStoreMenuAction(params: params as NSDictionary, url: actionUrl as! String)
                                self.performShippingAction(params : params as NSDictionary, url: actionUrl )
                                
                                }
                     
                            self.present(alert, animated: true, completion: nil)
                     
                            default:
                     
                                showToast(message: unconditionalMessage, controller: self)
                     
                            }
                        }))
                     
                     }
                     else
                     {
                     alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                        let condition = menuItem["name"] as! String
                     
                        switch(condition)
                        {
                            case "edit_method":
                                let presentedVC = EditShippingMethodViewController()
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.contentType = "addShippingMethod"
                                presentedVC.formTitle = "Edit Method"
                                presentedVC.storeId = self.storeID
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                nativationController.modalPresentationStyle = .fullScreen
                                self.present(nativationController, animated:false, completion: nil)
                            case "disable_method":
                                self.performShippingAction(params: params as NSDictionary, url: actionUrl)
                                self.deleteShippingEntry = false
                            case "enable_method":
                                self.performShippingAction(params: params as NSDictionary, url: actionUrl)
                                self.deleteShippingEntry = false
                        
                            default:
                            showToast(message: unconditionalMessage, controller: self)
                        }
                     
                     
                     }))
                    }
                }
            }
            
            if  (UIDevice.current.userInterfaceIdiom == .phone)
            {
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }
            else
            {
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
        
        if let guttermenu = packageInfo["menu"] as? NSArray
        {
            self.contentGutterMenu = guttermenu as NSArray

            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in contentGutterMenu
            {
                if let menuItem = menu as? NSDictionary
                {
                    alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                        let condition = menuItem["name"] as! String
                        
                        switch(condition)
                        {
                        case "create":
                            
                            
                            isCreateOrEdit = true
                            let presentedVC = FormGenerationViewController()
                            switch(self.contentType){
                                
                            case "StoreCreate":
                                presentedVC.formTitle = NSLocalizedString("Create New Store", comment : "")
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                break
                            case "Page":
                                presentedVC.formTitle = NSLocalizedString("Create New Page", comment: "")
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = menuItem["url"] as! String
                                break
                            case "sitegroup":
                                presentedVC.formTitle = NSLocalizedString("Create New Group", comment: "")
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = menuItem["url"] as! String
                                break
                            case "listings":
                                presentedVC.formTitle = NSLocalizedString("Post a new listing", comment: "")
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = menuItem["url"] as! String
                                break
                            default:
                                presentedVC.formTitle = NSLocalizedString("Create New Event", comment: "")
                                if self.eventExtensionCheck == true {
                                    presentedVC.eventExtensionCheck = true
                                    let dict = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                   let packageId = dict["package_id"] as! Int
                                    presentedVC.param = self.extensionParam//(menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    presentedVC.url = self.extensionUrl //menuItem["url"] as! String
                                    presentedVC.packageId = packageId
                                }
                                else{
                                    presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    presentedVC.url = menuItem["url"] as! String
                                }
                                break
                            }
                            
                           // presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            presentedVC.contentType = self.contentType
                            
                            // Only for testing purpose to be updated later
                            
                            if self.contentType == "StoreCreate" {
                                presentedVC.url = "sitestore/create"
                            } else
                            {
                                presentedVC.url = menuItem["url"] as! String
                            }
                            
                            // Updation limit ends here

                            
                            if self.listingTypeId != nil{
                                presentedVC.listingTypeId = self.listingTypeId
                            }
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            nativationController.modalPresentationStyle = .fullScreen
                            self.present(nativationController, animated:false, completion: nil)
                            
                        case "package_info":
                            
                            let presentedVC = PackageDetailViewController()
                            if self.eventExtensionCheck == true {
                                presentedVC.eventExtensionCheck = true
                                presentedVC.extParam = self.extensionParam
                                presentedVC.extUrl = self.extensionUrl
                            }
                            presentedVC.contentType = self.contentType
                            presentedVC.Formtittle = self.packagetitle
                            presentedVC.responsedic = self.responseArr[sender.tag] as! NSDictionary
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.param = menuItem["urlParams"] as! NSDictionary
                            presentedVC.listingTypeId = self.listingTypeId
                            presentedVC.isUpgradePackageScreen = self.isUpgradePackageScreen
                            self.navigationController?.pushViewController(presentedVC, animated: true)
                            
                        case "upgrade_package":
                            self.updatePackage(params: menuItem["urlParams"] as! NSDictionary)
                            break
                            
                        case "edit_method":
                            let presentedVC = FormGenerationViewController()
                            presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            presentedVC.contentType = self.contentType
                            presentedVC.url = menuItem["url"] as! String
                            
                        default:
                            showToast(message: unconditionalMessage, controller: self)
                        }
                        
                        
                    }))
                }
            }
            
            if  (UIDevice.current.userInterfaceIdiom == .phone)
            {
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }
            else
            {
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
    }
    
    func performShippingAction(params: NSDictionary, url: String)
    {
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var dic = Dictionary<String, String>()
            
            for (key, value) in params{
                
                if let id = value as? Int {
                    dic["\(key)"] = String(id as Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            var method:String
            
            if url.range(of:"delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute:  {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if self.deleteShippingEntry == true {
                            storeUpdate = true
                            storeDetailUpdate = true
                            //_ = self.dismiss(animated: false, completion: nil)
                            //_ = self.navigationController?.popViewController(animated: false)
                            //return
                            self.PackageTableview.reloadData()
                            self.exploreContent()
                        }
                        else
                        {
                            storeUpdate = true
                            storeDetailUpdate = true
                            self.PackageTableview.reloadData()
                            self.exploreContent()

                        }
                        
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }

    }
    
    // MARK: Server call
    func exploreContent()
    {
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            self.view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var parameters = Dictionary<String, String>()
            
            if listingTypeId != nil{
                parameters = ["listingtype_id": String(listingTypeId)]
            }
            
            if urlParams != nil{
                for (key, value) in urlParams{
                    
                    if let id = value as? NSNumber {
                        parameters["\(key)"] = String(id as! Int)
                    }
                    
                    if let receiver = value as? NSString {
                        parameters["\(key)"] = receiver as String
                    }
                    
                }
            }
            
            post(parameters, url: url, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg
                    {
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if succeeded["body"] != nil
                        {
                            
                            if let body = succeeded["body"] as? NSDictionary
                            {
                                if let currentSubscriptionDic = body["currentPackage"] as? NSDictionary{
                                    if let packageTitle = currentSubscriptionDic["title"] as? String{
                                        
                                        let packageLabelString = "The plan you are currently subscribed to is: \n"
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
                                
                                if let response = body["response"] as? NSArray
                                {
                                    self.responseArr = response
                                    self.PackageTableview.dataSource = self
                                    self.PackageTableview.delegate = self
                                    self.PackageTableview.isOpaque = false
                                    self.PackageTableview.isHidden = false
                                    self.PackageTableview.reloadData()
                                }
                                
                                if self.contentType == "shippingMethod"
                                {
                                    if let totalCheck = body["totalItemCount"] as? Int{
                                        if totalCheck == 0{
                                            self.responseArr = []
                                            self.noSearchResultsIcon.isHidden = false
                                            self.noSearchResultsMessage.isHidden = false
                                            //self.view.makeToast("No Shipping Method is available.Please add", duration: 5, position: "bottom")
                                            self.PackageTableview.reloadData()
                                        }
                                    }
                                }
                                
                                
                                if let totalCheck = body["getTotalItemCount"] as? Int{
                                    if totalCheck == 0{
                                        showToast(message: "No Package listing available.", controller: self)
                                    let triggerTime = (Int64(NSEC_PER_SEC) * 3)
                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                            self.dismiss(animated: true, completion: nil)
                                        })
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                            showToast(message: succeeded["message"] as! String, controller: self)
                    }
                })
            }
        }
        else
        {
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    func updatePackage(params: NSDictionary) {
        
        if Reachabable.isConnectedToNetwork()
        {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            self.view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var parameters = Dictionary<String, String>()
            
            if listingTypeId != nil{
                parameters = ["listingtype_id": String(listingTypeId)]
            }
            
            for (key, value) in params{
                
                if let id = value as? NSNumber {
                    parameters["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    parameters["\(key)"] = receiver as String
                }
                
            }
            
            post(parameters, url: url, method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        } else {
                            showToast(message: "Package Selected Successfully!!", controller: self)
                        }

                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                    }
                    
                    storeUpdate = true
                    storeDetailUpdate = true
                    self.popAfterDelay = true
                    self.createTimer(self)
                })
            }
        }
        else
        {
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true {
            cancel()
        }
    }
    
    
}
