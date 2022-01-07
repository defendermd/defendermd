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


//
//  FormGenerationViewController.swift
//  seiosnativeapp

import UIKit

var filePathArray = [String]()
var videoDurationInSeconds : Double = 0.0
var hostImageArray = [String]()
var conditionalForm:String!
var forumRenameTitle : String!
var fieldsDic : NSDictionary = [:] // for advanced event create form
var tempFormArray = [AnyObject]()
var tempCategArray = [AnyObject]()
var tempTempCategArray = [AnyObject]() // For Form generation in store creation for Dependency Quantity and weight
var tempTempTempCategArray = [AnyObject]() //  For product creation as 4th level temperory form
var temp4CategArray = [AnyObject]() // Product creation 5 level
var temp5CategArray = [AnyObject]() // product creation 6 Level
var temp6CategArray = [AnyObject]() // Product creation 7 Level
var temp7CategArray = [AnyObject]() // Product creation 8 level
var subcategoryDic : NSDictionary = [:]
var subsubcategoryDic : NSDictionary = [:]
var subsubDic : NSDictionary = [:]
var clicksubsubDic : NSDictionary = [:]
var repeatDic : NSDictionary = [:]
var categoryDic : NSDictionary = [:]
var eventRepeatDic : NSDictionary = [:]
var endDateDic : NSDictionary = [:]
var Formbackup = NSMutableDictionary()
var checkFieldId : Int!
var catFieldCheck = ""
var multiDic : NSDictionary = [:]
var tagbackupdic = NSMutableDictionary()
var profileCurrencySymbol = ""
var createResponse = NSDictionary()
var infoGlobalDic = Dictionary<String, String>()
var videoAttachFromAAF = ""
var filename = "" // For saving uidocumentpicker file name
var hostSelectionFormArr = [AnyObject]()
var tempFormArr = [AnyObject]()
var hostCreateArr = [AnyObject]()
var hostCreateFormSocialArr = [AnyObject]()
var canEditCategory : Int!
var locationInForm = ""

var hostDictionary = Dictionary<String, String>()
@objcMembers class FormGenerationViewController: FXFormViewController,UIDocumentPickerDelegate,ReturnLocationToForm
{
    var popAfterDelay:Bool!
    var param : NSDictionary = [:]
    var url : String!
    var contentType : String! = ""
    var formTitle:String!
    var flag : Bool = false
    var subFlag : Bool = false
    var subsubFlag : Bool = false
    var listingTypeId : Int!
    var checkBoxNameKey : String!
    var bodyfetchhtml = ""
    var leftBarButtonItem : UIBarButtonItem!
    var info : UILabel!
    var eventExtensionCheck : Bool = false
    var packageId : Int = 0
    var paymentPassword : String!  // Password for payment. User will enter it
    var storeId : String! // Get store ID if content type of payment method
    var productType : String!
    var productHelpUrl : String!
    var reloadForm = false
    var locParams = ""
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // self.alwaysShowToolbar = true
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        blogUpdate = false
        groupUpdate = false
        eventUpdate = false
        classifiedUpdate = false
        contentFeedUpdate = false
        albumUpdate = false
        videosUpdate = false
        videoProfileUpdate = false
        forumViewUpdate = false
        forumtopicViewUpdate = false
        pollUpdate = false
        listingUpdate = false
        conditionalForm = ""
        
        wishlistUpdate = false
        pageUpdate = false
        reviewUpdate = false
        advgroupUpdate = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(FormGenerationViewController.ScrollingactionPage1(_:)), name: NSNotification.Name(rawValue: "ScrollingactionPage1"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FormGenerationViewController.ScrollingactionBlog(_:)), name: NSNotification.Name(rawValue: "ScrollingactionBlog"), object: nil)
        

        
        setNavigationImage(controller: self)
        //self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel",  comment: ""), style:.plain , target:self , action: #selector(FormGenerationViewController.goBack))
        let addstore = UIBarButtonItem(title: NSLocalizedString("Add", comment: ""), style: .plain, target: self, action: #selector(FormGenerationViewController.addStore))
        
        self.navigationItem.leftBarButtonItem = cancel
        if contentType == "shippingMethod" {
            self.navigationItem.rightBarButtonItem = addstore
            addstore.tintColor = textColorPrime
        }
        
        cancel.tintColor = textColorPrime

        
        let defaults = UserDefaults.standard
        defaults.set("", forKey: "overviewcheck")
        //Host change user
        defaults.removeObject(forKey: "userName")
        defaults.removeObject(forKey: "useId")
        
        if contentType == "album"
        {
            multiplePhotoSelection = true
        }
        else
        {
            multiplePhotoSelection = false
        }
        
        if contentType == "video" || contentType == "Advanced Video" || contentType == "Video"
        {
            mediaType = "video"
        }
        else
        {
            mediaType = "image"
        }
        
        if contentType == "listings"
        {
            mediaType = "image"
        }
        
        if contentType == "Page"
        {
            mediaType = "image"
        }
        
        if contentType == "StoreCreate"
        {
            mediaType = "image"
        }
        
        if contentType == "sitegroup"
        {
            mediaType = "image"
        }

        if ((contentType == "video") || (contentType == "album") || (contentType == "poll") || (contentType == "Album") || contentType == "Video")
        {
            hideIndexFormArray.removeAll(keepingCapacity: false)
        }
        
        conditionalForm = contentType
        popAfterDelay = false
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }

        
        generateForm()

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let topOffset = CGPoint(x: 0, y: -(self.formController.tableView.contentInset.top))
        self.formController.tableView.contentOffset = topOffset
        if self.reloadForm == true
        {
            self.reloadForm = false
            self.formController.form = CreateNewForm()
        }
        self.formController.tableView.reloadData()
        
        if conditionalProfileForm == "BrowseStoreProfile"
        {
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {

        let defaults = UserDefaults.standard
        
        if let name = defaults.value(forKey: "spinner")
        {
            if  name as! String != "" {
//                spinner.center = view.center
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                view.isUserInteractionEnabled = false
                
            }
        }
        
        if conditionalProfileForm == "browseProduct"
        {
            self.dismiss(animated: false, completion: nil)
        }
        else if conditionalProfileForm == "BrowseStoreProfile"
        {
            self.dismiss(animated: false, completion: nil)
        }
        
        
        self.title = String(format: NSLocalizedString(" %@ ", comment: ""), formTitle)
        setNavigationImage(controller: self)
        
        if (conditionForm != nil) && ((conditionForm == "topicCreation") || (conditionForm == "forumEditing") || (conditionForm == "postReply" ) || (conditionForm == "forumQuoting") || (conditionForm == "forum")){
            
            let defaults = UserDefaults.standard
            
            if let name = defaults.value(forKey: "preferenceName")
            {
                if  name as! String != "" {
                    
                    self.formController.form = CreateNewForm()
                    self.formController.tableView.reloadData()
                }
            }
        }
        
        if (conditionForm != nil) && ((conditionForm == "HostChange") && conditionalForm == "HostChange")
        {
            Form = tempFormArr
            self.formController.form = CreateNewForm()
            self.formController.tableView.reloadData()
            //self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
        }
        
        conditionalForm = contentType
        conditionForm = contentType
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Remove view from Window
        viewRemoveFromWindow()        
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool)
    {
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer
        {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
     func ScrollingactionPage1(_ notification: Foundation.Notification)
    {
        
        let instanceOfCustomObject: ZSSDemoViewController = ZSSDemoViewController()
        instanceOfCustomObject.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: instanceOfCustomObject)
        nativationController.modalPresentationStyle = .fullScreen
        self.present(nativationController, animated:true, completion: nil)
    }
    
    func getresponse()
    {
        let defaults = UserDefaults.standard
        var infoDicLocal = Dictionary<String, String>()
        if let name = defaults.value(forKey: "preferenceName")
        {
            let replaced = (name as AnyObject).replacingOccurrences(of: "&nbsp;", with: " ")
            if self.contentType == "listings" || self.contentType == "advancedevents"{
                infoDicLocal["overview"] = ("\(replaced)")
            }
            if self.contentType == "blog" || self.contentType == "classified"{
                infoDicLocal["body"] = ("\(replaced)")
            }
            
        }
        var method = "POST"
        //if isCreateOrEdit {
            method = "POST"
//        }else{
//            method = "PUT"
//        }
        
        var infoDic = Dictionary<String, String>()
        infoDic = infoGlobalDic
        infoDic.update(infoDicLocal)
        
        if eventExtensionCheck == true && packageId != 0{
            infoDic["package_id"] = "\(packageId)"
        }
        
        if self.contentType == "listings" || self.contentType == "advancedevents" || self.contentType == "classified"{
            let singlePhoto = true
            var mediaDataType = ""
            for key in Form{
                if let dic = (key as? NSDictionary){
                    for (key,value) in dic{
                        // Check for Type
                        if key as! NSString == "type" && value as! NSString == "File"{
                            mediaDataType = dic["name"] as! String
                        }
                    }
                }
            }
            
            postForm(infoDic, url: url, filePath: filePathArray, filePathKey: mediaDataType , SinglePhoto: singlePhoto) { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute:
                    {
                        activityIndicatorView.stopAnimating()
                        
                        self.view.isUserInteractionEnabled = true
                        for path in filePathArray
                        {
                            removeFileFromDocumentDirectoryAtPath(path)
                        }
                        filePathArray.removeAll(keepingCapacity: false)
                        if msg
                        {
                            if isCreateOrEdit
                            {
                                
                                if(self.contentType == "advancedevents")
                                {
                                    
                                    showToast(message: "Your event has been created successfully.", controller: self, onView: false, time: 5)
                                    
                                }
                                else if self.contentType == "listings" {
                                    showToast(message: String(format: NSLocalizedString("%@ has been created successfully.", comment: ""), listingNameToShow), controller: self, onView: false, time: 5)
                                }
                                else if (self.contentType == "classified"){
                                    showToast(message: NSLocalizedString("classified has been created successfully.", comment: ""), controller: self, onView: false, time: 5)
                                }
                                else
                                {
                                    
                                    showToast(message: String(format: NSLocalizedString("%@ has been created successfully.", comment: ""), self.contentType), controller: self, onView: false, time: 5)
                                    
                                }
                                
                                if(self.contentType == "advancedevents")
                                {
                                    
                                    if succeeded["body"] != nil
                                    {
                                        
                                        if let response = succeeded["body"] as? NSDictionary
                                        {
                                            if response["response"] != nil
                                            {
                                                if let response = response["response"] as? NSDictionary{
                                                    
                                                    let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                        conditionalProfileForm = "BrowsePage"
                                                        if self.eventExtensionCheck == true{
                                                            conditionalProfileForm = ""
                                                            packageCheck = false
                                                            advGroupDetailUpdate = true
                                                            pageDetailUpdate = true
                                                            listingDetailUpdate = true
                                                            storeDetailUpdate = true
                                                        }
                                                        createResponse = response
                                                        self.dismiss(animated: true, completion: nil)
                                                        
                                                    })
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                
                                if(self.contentType == "classified")
                                {
                                    if succeeded["body"] != nil
                                    {
                                        
                                        if let response = succeeded["body"] as? NSDictionary
                                        {
                                            
                                            if response["response"] != nil
                                            {
                                                if let response = response["response"] as? NSDictionary
                                                {
                                                    
                                                    let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                        conditionalProfileForm = "BrowsePage"
                                                        createResponse = response
                                                        self.dismiss(animated: true, completion: nil)

                                                    })

                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                
                                if(self.contentType == "listings")
                                {
                                    if succeeded["body"] != nil
                                    {
                                        
                                        if let response = succeeded["body"] as? NSDictionary
                                        {
                                            
                                            let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                
                                                conditionalProfileForm = "BrowsePage"
//                                                let viewType = sitereviewMenuDictionary["viewProfileType"] as! Int
                                                
                                                
                                                if response.object(forKey: "price") != nil && (response["price"] as! Int > 0 ){
                                                    
                                                    if response["currency"] != nil{
                                                        
                                                        let currencySymbol = getCurrencySymbol(response["currency"] as! String)
                                                        profileCurrencySymbol = currencySymbol
                                                    }
                                                }
                                                
                                                createResponse = response
                                                self.dismiss(animated: true, completion: nil)

                                                
                                            })
                                            
                                        }

                                    }
                                    
                                }
                                
                            }
                            else{
                                
                                if(self.contentType == "advancedevents")
                                {
                                    showToast(message: NSLocalizedString("Your event has been edited successfully.", comment: ""), controller: self, onView: false, time: 5)
                                }
                                else
                                {
                                    showToast(message: String(format: NSLocalizedString("%@ has been edited successfully.", comment: ""),self.contentType), controller: self, onView: false, time: 5)
                                }
                                
                                self.createTimer(self)
                                self.dismiss(animated: true, completion: nil)
                                self.popAfterDelay = true
                            }
                            
                            listingDetailUpdate = true
                            listingUpdate = true
                            classifiedUpdate = true
                            classifiedDetailUpdate = true
                            eventUpdate = true
                            contentFeedUpdate = true
                            
                        }
                        else
                        {
                            self.view.isUserInteractionEnabled = true
                            self.view.alpha = 1.0
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                            }
                           // UIApplication.shared.keyWindow?.makeToast(unconditionalMessage, duration: 5, position: "bottom")
                        }
                        
                })
            }
            
        }
        
        if self.contentType == "blog" {
            
            post(infoDic,url: url , method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    activityIndicatorView.stopAnimating()
                    self.view.alpha = 1.0
                    self.view.isUserInteractionEnabled = true
                    if msg
                    {
                        
                        if isCreateOrEdit
                        {
                            showToast(message: String(format: NSLocalizedString("%@ has been created successfully.", comment: ""),self.contentType), controller: self, onView: false, time: 5)
                            
                            
                            self.createTimer(self)
                        }
                        else
                        {
                            
                            showToast(message: String(format: NSLocalizedString("%@ has been edited successfully.", comment: ""),self.contentType), controller: self, onView: false, time: 5)
                            
                            
                           self.createTimer(self)
                        }
                        
                        if isCreateOrEdit == true
                        {
                            if self.contentType == "blog"
                            {
                                if succeeded["body"] != nil
                                {
                                    if let response = succeeded["body"] as? NSDictionary
                                    {
                                        if response["response"] != nil
                                        {
                                            if let response = response["response"] as? NSDictionary
                                            {
                                                
                                                let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                    conditionalProfileForm = "BrowsePage"
                                                    createResponse = response
                                                    self.dismiss(animated: true, completion: nil)
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                            
                            
                           self.createTimer(self)
                        }
                        else
                        {
                            self.dismiss(animated: true, completion: nil)
                            self.popAfterDelay = true
                           self.createTimer(self)
                        }
                        blogUpdate = true
                        blogDetailUpdate = true
                    }
                    else
                    {
                        // Handle server Side Error
                        if succeeded["message"] != nil
                        {
                            showToast(message: unconditionalMessage, controller: self, onView: false, time: 5)
                        }
                    }
                })
            }
        }
        
    }
    
     func ScrollingactionBlog(_ notification: Foundation.Notification)
    {
        getresponse()
        
    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true
        {
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    // MARK: - Server Connection For Blog Form Creation & Submission
    
    // Create Request for Generation of Create/Edit Blog Form
    func generateForm()
    {
        // Check Internet Connection
        filename = ""
        if Reachabable.isConnectedToNetwork() {
        locationInForm = ""
            removeAlert()
            activityIndicatorView.center =  CGPoint(x: view.center.x, y: (view.bounds.height/2) - 50)
            view.addSubview(activityIndicatorView)
            
            activityIndicatorView.startAnimating()
            Formbackup.removeAllObjects()
            tagbackupdic.removeAllObjects()
            hostDictionary.removeAll()
            defaultCategory = ""
            defaultrepeatid = ""
            defaultsubCategory = ""
            defaultsubsubCategory = ""
            formValue = [:]
            MultiCheckFormValue = [:]
            Form.removeAll(keepingCapacity: false)
            formValue = [:]
            // NSUserDefaults.standardUserDefaults().removeObject(forKey:"overviewcheck")
            UserDefaults.standard.removeObject(forKey: "SellSomething")
            UserDefaults.standard.removeObject(forKey: "blogandclassified")
            UserDefaults.standard.removeObject(forKey: "spinner")
            UserDefaults.standard.removeObject(forKey: "EditorTitle")
            UserDefaults.standard.removeObject(forKey: "EditValue")
            UserDefaults.standard.removeObject(forKey: "userName")
            
            
            if (conditionForm != nil) && ((conditionForm != "topicCreation") && (conditionForm != "forumEditing") && (conditionForm != "postReply" ) && ( conditionForm != "forumQuoting")){
                
                textstoreValue = ""
                UserDefaults.standard.removeObject(forKey: "forumcheckkey")
                UserDefaults.standard.removeObject(forKey: "preferenceName")
                
            }
            
            let defaults = UserDefaults.standard
            defaults.setValue("", forKey: "rating")
            defaults.setValue("", forKey: "key")
            hideIndexFormArray.removeAll(keepingCapacity: false)
            isheader = true
            istitleheader = true
            
            var dic = Dictionary<String, String>()
            
            for (key, value) in param{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            if isCreateOrEdit == false{
                if contentType == "classified" {
                    dic["profile_feilds_value_merge"] = "1"
                }
            }
            
            if self.contentType == "listings" || self.contentType == "Listings claim"{
                dic["listingtype_id"] = String(listingTypeId!)
            }
            

            if eventExtensionCheck == true && packageId != 0{
                dic["package_id"] = "\(packageId)"
            }
            

            if self.contentType == "paymentMethod" {
                dic["password"] = paymentPassword!
            }
            if self.contentType == "productType"
            {
                dic["store_id"] = storeId!
            }
            
            if self.contentType == "mainFile"
            {
                dic["type"] = "main"
            }
            else if self.contentType == "sampleFile"
            {
                dic["type"] = "sample"
            }
            
            
            
            /*if self.contentType == "StoreCreate"
            {
                let packageId = param["package_id"] as! Int
                dic["package_id"] = String(packageId)
            } */

            
            // Send Server Request for Create/Edit Blog Form
            post(dic, url: url, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        // On Success Add Value to Form Array & Values to formValue Array
                        Form.removeAll(keepingCapacity: false)
                        tempFormArray.removeAll(keepingCapacity: false)
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 5.0)
                           self.createTimer(self)
                            
                        }
                        
                        if isCreateOrEdit
                        {
                            if let dic = succeeded["body"] as? NSArray
                            {
                                
                                Form = dic as [AnyObject]
                                
                            }
                            else
                            {
                                if let dic = succeeded["body"] as? NSDictionary
                                {
                                    if let formArray = dic["form"] as? NSArray
                                    {
                                        Form = formArray as [AnyObject]
                                        tempFormArr = Form
                                        for key in Form{
                                            // Create element Dictionary for every FXForm Element
                                            
                                            if let dic = (key as? NSDictionary)
                                            {
                                                if dic["name"] as? String == "category_id"
                                                {
                                                    categoryDic = dic
                                                }
                                                
                                                if self.contentType == "ads"{
                                                    if dic["name"] as? String == "adCancelReason"
                                                    {
                                                        categoryDic = dic
                                                    }
                                                }
                                                
                                                if dic["name"] as? String == "eventrepeat_id"
                                                {
                                                    eventRepeatDic = dic
                                                }
                                                
                                                if dic["name"] as? String == "end_date_enable"
                                                {
                                                    endDateDic = dic
                                                }
                                                
                                                
                                            }
                                        }
                                        
                                    }
                                    
                                    // Advance Event Host selection dic
                                    if let hostArr = dic["hostSelectionForm"] as? NSArray
                                    {
                                       hostSelectionFormArr = hostArr as [AnyObject]
                                        
                                    }
                                    
                                    // Advance Event Host create arr
                                    if let hostCreateFormArr = dic["hostCreateForm"] as? NSArray
                                    {
                                        hostCreateArr = hostCreateFormArr as [AnyObject]
                                        
                                    }
                                    
                                    // Advance Event Host create for social
                                    if let hostCreateFormSocial = dic["hostCreateFormSocial"] as? NSArray
                                    {
                                        hostCreateFormSocialArr = hostCreateFormSocial as [AnyObject]
                                        
                                    }
                                    
                                    if let ratingArray = dic["ratingParams"] as? NSArray
                                    {
                                        var arr = ratingArray as [AnyObject]
                                        let dic = Form.last
                                        Form.removeLast()
                                        arr.append(dic!)
                                        Form += arr
                                        
                                    }
                                    
                                    if let formValues = dic["formValues"] as? NSDictionary
                                    {
                                        formValue = formValues as! [AnyHashable : Any] as NSDictionary
                                    }
                                    else
                                    {
                                        formValue = [:]
                                    }
                                    if let wishlistDescription = dic["add_wishlist_description"] as? String{
                                        addWishlistDescriptIon = wishlistDescription
                                        
                                    }
                                    
                                    if let wishlistDescription = dic["create_wishlist_descriptions"] as? String{
                                        createWishlistDescription = wishlistDescription
                                    }
                                    
                                }
                                
                            }
                        }
                        else
                        {
                            if let dic = succeeded["body"] as? NSDictionary
                            {
                                if let formArray = dic["form"] as? NSArray
                                {
                                    Form = formArray as [AnyObject]
                                    tempFormArr = Form
                                    for key in Form{
                                        // Create element Dictionary for every FXForm Element
                                        
                                        if let dic = (key as? NSDictionary)
                                        {
                                            if dic["name"] as? String == "category_id"
                                            {
                                                categoryDic = dic
                                            }
                                            if dic["name"] as? String == "eventrepeat_id"
                                            {
                                                eventRepeatDic = dic
                                            }
                                            
                                        }
                                    }
                                }
                                
                                if let formValues = dic["formValues"] as? NSDictionary
                                {
                                    formValue = formValues as! [AnyHashable : Any] as NSDictionary
                                    for (key,value) in formValue {
                                        if key as! String == "body"{
                                            if self.contentType == "blog" || self.contentType == "classified" {
                                                
                                                let defaults = UserDefaults.standard
                                                defaults.set("\(value)", forKey: "preferenceName")
                                            }
                                        }
                                    }
                                    
                                }
                                
                                if let canEditCategories = dic["canEditCategory"] as? Int
                                {
                                    canEditCategory = canEditCategories
                                }
                                
                                // Advance Event Host selection dic
                                if let hostArr = dic["hostSelectionForm"] as? NSArray
                                {
                                    hostSelectionFormArr = hostArr as [AnyObject]
                                    
                                }
                                
                                // Advance Event Host create arr
                                if let hostCreateFormArr = dic["hostCreateForm"] as? NSArray
                                {
                                    hostCreateArr = hostCreateFormArr as [AnyObject]
                                    
                                }
                                
                                // Advance Event Host create for social
                                if let hostCreateFormSocial = dic["hostCreateFormSocial"] as? NSArray
                                {
                                    hostCreateFormSocialArr = hostCreateFormSocial as [AnyObject]
                                    
                                }
                                
                                if let ratingArray = dic["ratingParams"] as? NSArray
                                {
                                    var arr = ratingArray as [AnyObject]
                                    let dic = Form.last
                                    Form.removeLast()
                                    arr.append(dic!)
                                    Form += arr
                                    
                                }
                                
                                if let wishlistDescription = dic["create_wishlist_descriptions"] as? String{
                                    createWishlistDescription = wishlistDescription
                                }
                            }
                        }
                        
                        if self.contentType == "listings" || self.contentType == "Page" || self.contentType == "ads" || self.contentType == "sitegroup" || self.contentType == "Advanced Video" || self.contentType == "Channel" || self.contentType == "StoreCreate" || self.contentType == "shippingMethod" || self.contentType == "paymentMethod" || self.contentType == "editStore" || self.contentType == "addShippingMethod" || self.contentType == "editFile"
                        {
                            
                            if let dic = succeeded["body"] as? NSDictionary
                            {
                                if self.url == "listings/create" || self.url == "sitepages/create" || self.url == "communityads/index/remove-ad" || self.url == "advancedgroups/create" || self.url == "sitestore/create"
                                {
                                    if let formArray = dic["form"] as? NSArray
                                    {
                                        tempFormArray = formArray as [AnyObject]
                                        Form = formArray as [AnyObject]
                                        
                                    }
                                    
                                    if let catdic = dic["subcategories"] as? NSDictionary
                                    {
                                        
                                        subcategoryDic = catdic
                                    }
                                    
                                    if let catdic = dic["subCategories"] as? NSDictionary
                                    {
                                        
                                        subcategoryDic = catdic
                                    }
                                    
                                    if let fieldDic = dic["fields"] as? NSDictionary
                                    {
                                        fieldsDic = fieldDic
                                    }
                                    
                                    if let formValues = dic["formValues"] as? NSDictionary
                                    {
                                        formValue = formValues as! [AnyHashable : Any] as NSDictionary
                                    }else{
                                        formValue = [:]
                                    }
                                    
                                }
                                else
                                {
                                    if let formArray = dic["form"] as? NSArray
                                    {
                                        tempFormArray = formArray as [AnyObject]
                                        
                                        Form = formArray as [AnyObject]
                                    }
                                    
                                    
                                    if let catdic = dic["subcategories"] as? NSDictionary
                                    {
                                        subcategoryDic = catdic
                                    }
                                    
                                    if let catdic = dic["subCategories"] as? NSDictionary
                                    {
                                        
                                        subcategoryDic = catdic
                                    }
                                    
                                    if let formValues = dic["formValues"] as? NSDictionary
                                    {
                                        tempformValue = formValues.mutableCopy() as! NSMutableDictionary
                                        formValue = formValues as! [AnyHashable : Any] as NSDictionary
                                        if self.contentType == "listings"{
                                            catFieldCheck = formValue["fieldCategoryLevel"] as! String
                                        }
                                    }
                                    
                                    if let fieldDic = dic["fields"] as? NSDictionary
                                    {
                                        fieldsDic = fieldDic
                                    }
                                }
                            }
                        }
                        
                        if self.contentType == "productType"
                        {
                            if let dic = succeeded["body"] as? NSDictionary
                            {
                                if let formArray = dic["form"] as? NSArray
                                {
                                    tempFormArray = formArray as [AnyObject]
                                    Form = formArray as [AnyObject]
                                }
                                for i in 0 ..< (Form.count) where i < Form.count
                                {
                                    let dic = Form[i] as! NSDictionary
                                    let name = dic["name"] as! String
                                    if name == "product_help"
                                    {
                                        if let url = dic["url"] as? String
                                        {
                                            self.productHelpUrl = url
                                        }
                                        
                                    }
                                }
                                var helpDic = Dictionary<String, AnyObject>()
                                helpDic["name"] = "product_help" as AnyObject
                                helpDic["type"] = "help" as AnyObject
                                helpDic["label"] = "Need help with Product Types" as AnyObject
                                helpDic["value"] = "click here" as AnyObject
                                Form.append(helpDic as AnyObject)
                                tempFormArray.append(helpDic as AnyObject)
                                
//                                var helpDic2 = Dictionary<String, AnyObject>()
//                                helpDic2["name"] = "remember" as AnyObject
//                                helpDic2["type"] = "switch" as AnyObject
//                                helpDic2["label"] = "Remember me" as AnyObject
//                                helpDic2["value"] = "click here" as AnyObject
//
//                                Form.append(helpDic2 as AnyObject)
//                                tempFormArray.append(helpDic2 as AnyObject)
                            }
                        }
                        
                        if self.contentType == "advancedevents"                        {
                            
                            if let dic = succeeded["body"] as? NSDictionary
                            {
                                if self.url == "advancedevents/create"
                                {
                                    if let formArray = dic["form"] as? NSArray
                                    {
                                        tempFormArray = formArray as [AnyObject]
                                        Form = formArray as [AnyObject]
                                        
                                    }
                                    if let catdic = dic["subcategories"] as? NSDictionary
                                    {
                                        subcategoryDic = catdic
                                    }
                                    if let fieldDic = dic["fields"] as? NSDictionary
                                    {
                                        fieldsDic = fieldDic
                                    }
                                    if let formValues = dic["formValues"] as? NSDictionary
                                    {
                                        formValue = formValues as! [AnyHashable : Any] as NSDictionary
                                        
                                    }
                                    if let repeatOccurences = dic["repeatOccurences"] as? NSDictionary
                                    {
                                        repeatDic = repeatOccurences
                                    }
                                    
                                }
                                else
                                {
                                    if let formArray = dic["form"] as? NSArray
                                    {
                                        tempFormArray = formArray as [AnyObject]
                                        Form = formArray as [AnyObject]
                                    }
                                    if let catdic = dic["subcategories"] as? NSDictionary
                                    {
                                        subcategoryDic = catdic
                                    }
                                    if let fieldDic = dic["fields"] as? NSDictionary
                                    {
                                        fieldsDic = fieldDic
                                    }
                                    
                                    if let formValues = dic["formValues"] as? NSDictionary
                                    {
                                        tempformValue = formValues.mutableCopy() as! NSMutableDictionary
                                        formValue = formValues as! [AnyHashable : Any] as NSDictionary
                                    }
                                    if let repeatOccurences = dic["repeatOccurences"] as? NSDictionary
                                    {
                                        repeatDic = repeatOccurences
                                    }
                                    
                                }
                            }
                        }
                        
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        // Create FXForm Form
                        self.formController.form = CreateNewForm()
                        self.formController.tableView.reloadData()
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 5.0)
                            self.popAfterDelay = true
                           self.createTimer(self)
                            
                            
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self, onView: false, time: 5.0)
        }
        
    }
    
    func showStripeFields(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        if (form.valuesByKey["isStripeChecked"] != nil)
        {
            let val = form.valuesByKey["isStripeChecked"] as! Int
            print(val)
        }
    }
    
    func showPaypalFields(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        if (form.valuesByKey["isPaypalChecked"] != nil)
        {
            let val = form.valuesByKey["isPaypalChecked"] as! Int
            print(val)
        }
    }
    
    func showChequeField(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "isByChequeChecked"
            {
                index = i
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        index += 1
        if (form.valuesByKey["isByChequeChecked"] != nil)
        {
            if form.valuesByKey["isByChequeChecked"] as! Int == 1
            {
                let ndic = Form[index] as! NSDictionary
                Form.insert(ndic as AnyObject, at: index)
                tempFormArray = Form
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()

        
    }
    
    // Product category value changed function
    
    
    func handlingTypeValueChange(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        print(tempCategArray)
        Form = tempCategArray
        contentType = "shippingMethod"
        var index =  Int()
        print(Form.count)
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "handling_type"
            {
                index = i
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        
        index += 1
        print(index)
        //print(form.valuesByKey["handling_type"])
        
        if (form.valuesByKey["handling_type"] != nil)
        {
            if form.valuesByKey["handling_type"] as! String == "Fixed"
            {
                let ndic = fieldsDic["handling_type_fixed"] as! NSArray
                print(ndic.count)
                for i in 0 ..< ndic.count
                {
                    let dic = ndic[i] as! NSDictionary
                    Form.insert(dic as AnyObject, at: index)
                    index += 1
                }
            }
            else if form.valuesByKey["handling_type"] as! String == "Percentage"
            {
                let ndic = fieldsDic["handling_type_percentage"] as! NSArray
                print(ndic.count)
                for i in 0 ..< ndic.count
                {
                    let dic = ndic[i] as! NSDictionary
                    Form.insert(dic as AnyObject, at: index)
                    index += 1
                }
            }
            else if form.valuesByKey["handling_type"] as! String == "Per Unit Weight"
            {
                let ndic = fieldsDic["handling_type_unit_weight"] as! NSArray
                print(ndic.count)
                for i in 0 ..< ndic.count
                {
                    let dic = ndic[i] as! NSDictionary
                    Form.insert(dic as AnyObject, at: index)
                    index += 1
                }
            }
            
        }
        
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
        
    }
    
    func shippingTypeValueChanged(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        print(tempCategArray)
        Form = tempCategArray
        contentType = "shippingMethod"
        var index =  Int()
        print(Form.count)
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "ship_type"
            {
                index = i
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        
        index += 1
        print(index)
        //print(form.valuesByKey["handling_type"])
        
        if (form.valuesByKey["ship_type"] != nil)
        {
            if form.valuesByKey["ship_type"] as! String == "Per Order"
            {
                let ndic = fieldsDic["ship_type_per_order"] as! NSArray
                print(ndic.count)
                for i in 0 ..< ndic.count
                {
                    let dic = ndic[i] as! NSDictionary
                    Form.insert(dic as AnyObject, at: index)
                    index += 1
                }
            }
            else if form.valuesByKey["ship_type"] as! String == "Per Item"
            {
                let ndic = fieldsDic["ship_type_per_item"] as! NSArray
                print(ndic.count)
                for i in 0 ..< ndic.count
                {
                    let dic = ndic[i] as! NSDictionary
                    Form.insert(dic as AnyObject, at: index)
                    index += 1
                }
            }

        }
        
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func listingDependencyChanged(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        contentType = "shippingMethod"
        var index = Int()
        
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "dependency"
            {
                index = i
            }
            
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
            
        }
        index += 1
        
            if (form.valuesByKey["dependency"] != nil)
            {
                if form.valuesByKey["dependency"] as! String == "Cost & Weight"
                {
                    let ndic = fieldsDic["dependency_0"] as! NSArray
                    for i in 0 ..< ndic.count
                    {
                        let dic = ndic[i] as! NSDictionary
                        Form.insert(dic as AnyObject, at: index)
                        index += 1
                    }
                    tempCategArray = Form
                }
                    
                if form.valuesByKey["dependency"] as! String == "Weight only"
                {
                    let ndic = fieldsDic["dependency_1"] as! NSArray
                    for i in 0 ..< ndic.count
                    {
                        let dic = ndic[i] as! NSDictionary
                        Form.insert(dic as AnyObject, at: index)
                        index += 1
                    }
                    tempCategArray = Form
                }
                
                if form.valuesByKey["dependency"] as! String == "Quantity & Weight"
                {
                    let ndic = fieldsDic["dependency_2"] as! NSArray
                    for i in 0 ..< ndic.count
                    {
                        let dic = ndic[i] as! NSDictionary
                        Form.insert(dic as AnyObject, at: index)
                        index += 1
                    }
                    tempCategArray = Form
                }
            }
        print(Form)
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
        
    }
    
    
    func listingRegionChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
    
        
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "all_regions"
            {
                index = i
            }
            
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
            
        }
        index += 1
        
        if (form.valuesByKey["all_regions"] != nil)
        {
            if form.valuesByKey["all_regions"] as! String == "No"
            {
                let ndic = fieldsDic["country_US"] as! NSArray
                let countryDic = ndic[0] as! NSDictionary
                Form.insert(countryDic as AnyObject, at: index)
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    
    // Edit Store configuration
    
    func storeMainCategoryChanged(_ cell:  FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
        
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "category_id"
            {
                index = i;
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        var j : Int = 0
        while j < Form.count
        {
            let dic = Form[j] as! NSDictionary
            let name = dic["name"] as! String
            
            if ( name == "subcategory_id" || name == "subsubcategory_id" )
            {
                Form.remove(at: j)
                j = j-1
                print(j)
            }
            else
            {
                j = j+1
            }
            
        }
        
        if (form.valuesByKey["category_id"] != nil)
        {
            if let option = categoryDic["multiOptions"] as? NSDictionary
            {
                let categoryvalue = form.valuesByKey["category_id"] as! String
                for (key, value) in option
                {
                    
                    if categoryvalue == value as! String
                    {
                        
                        if let subDic = subcategoryDic["\(key)"] as? NSDictionary
                        {
                            if let formDic = subDic["form"] as? NSDictionary
                            {
                                index += 1
                                Form.insert(formDic, at: index)
                                tempCategArray = Form
                                
                            }
                        }
                    }
                }

            }
        }

        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
        
    }
    
    func storeSubCategoryChanged(_ cell: FXFormFieldCellProtocol)
    {
        
    }
    
    func storeSubSubCategoryChanged(_ cell: FXFormFieldCellProtocol)
    {
        
    }
    
    
    func adsCategoryValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        flag = false
        subFlag = false
        subsubFlag = false
        
        let form = cell.field.form as! CreateNewForm
        
        Form.removeAll(keepingCapacity: false)
        
        Form = tempFormArray
        var index = Int()
        defaultsubCategory = ""
        
        for i in 0 ..< Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "subcategory_id" || name == "subsubcategory_id"
            {
                
                Form.remove(at: i)
                
            }
            if name == "adCancelReason"
            {
                index = i;
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        
        if (form.valuesByKey["adCancelReason"] != nil)
        {
            
            
            if let option = categoryDic["multiOptions"] as? NSDictionary
            {
                
                let categoryvalue = form.valuesByKey["adCancelReason"] as! String
                for (key, value) in option
                {
                    
                    if categoryvalue == value as! String
                    {
                        
                        if flag == false{
                            if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                            {
                                flag = true
                                //subFlag = true
                                for dic in feildtoaddArray
                                {
                                    index += 1
                                    Form.insert(dic as AnyObject, at: index)
                                }
                            }
                        }
                        defaultCategory = "\(value)"
                        // findOptionalFormIndexforcategory("advancedevents", option: 2)
                        
                    }
                }
            }
        }
        FormforRepeat = Form
        
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func addMoreOption(_ cell: FXFormFieldCellProtocol)
    {
        if contentType == "poll"
        {
            if hideIndexFormArray.count > 0
            {
                hideIndexFormArray.remove(at: 0)
            }
            if hideIndexFormArray.count == 0
            {
                hideIndexFormArray.append(17)
            }
        }
        self.formController.tableView.reloadData()
    }
    
    
    
    func fieldValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        
        if contentType == "video" || contentType == "Advanced Video" || contentType == "Video"  || contentType == "Channel"
        {
            if (form.valuesByKey["type"] != nil)
            {
                if form.valuesByKey["type"] as! String == "YouTube" || form.valuesByKey["type"] as! String == "Vimeo" || form.valuesByKey["type"] as! String == "Dailymotion"
                {
                    findOptionalFormIndex(contentType, option: 1)
                }
                if form.valuesByKey["type"] as! String == "My Device"
                {
                    findOptionalFormIndex(contentType, option: 2)
                }
            }
        }
        else if contentType == "album"
        {
            if (form.valuesByKey["album"] != nil)
            {
                if form.valuesByKey["album"] as! String == "Create A New Album"
                {
                    findOptionalFormIndex("album", option: 1)
                }
                else
                {
                    findOptionalFormIndex("album", option: 2)
                }
            }
        }
        else if contentType == "listings"{
            
            if form.valuesByKey["end_date_enable"] as! String == "No end date."{
                findOptionalFormIndex("listings", option: 1)
            }else{
                findOptionalFormIndex("listings", option: 2)
            }
            
        }
        else if contentType == "advancedevents"
        {
            
            if form.valuesByKey["is_online"] as! Bool == false
            {
                findOptionalFormIndex("advancedevents", option: 1)
            }
            else
            {
                findOptionalFormIndex("advancedevents", option: 2)
            }
            
        }
        self.formController.tableView.reloadData()
        // self.formController.tableView.beginUpdates()
    }
    
    func fieldValueChanged1(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        if contentType == "advancedevents"
        {
            
            if form.valuesByKey["monthlyType"] as! Bool == false
            {
                findOptionalFormIndex1("advancedevents", option: 1)
            }
            else
            {
                findOptionalFormIndex1("advancedevents", option: 2)
            }
            
        }
        self.formController.tableView.reloadData()
    }
    
    // On click of category---Listing condition
    var fieldLabelCheck : String!
    
    func editStoreListingCategoryValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        if canEditCategory != nil
        {
            if canEditCategory! == 0 && conditionalForm == "editStore"
            {
                let keyValue = String(describing: formValue["category_id"])
                print(keyValue)
                
                if let option = categoryDic["multiOptions"] as? NSDictionary
                {
                    for ( key , value ) in option
                    {
                        if (key as? NSString)! as String == keyValue
                        {
                            print(value)
                        }
                    }
                }
                
                let alert = UIAlertController(title: "Error", message: "You cannot change category. Category editing is Disabled", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                    
                    //self.formController.tableView.reloadData()
                })
                alert.addAction(action1)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    func listingCategoryValueCantChanged(_ cell: FXFormFieldCellProtocol){
        print("cant change")
        let alert = UIAlertController(title: "Alert", message: "You dont have a permission to edit the category", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func listingsubCategoryValueCantChanged(_ cell: FXFormFieldCellProtocol){
        print("cant change")
        let alert = UIAlertController(title: "Alert", message: "You dont have a permission to edit the sub category", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func listingCategoryValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        flag = false
        subFlag = false
        subsubFlag = false
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "subcategory_id" || name == "subsubcategory_id"
            {
                Form.remove(at: i)
                
            }
            if name == "category_id"
            {
                index = i;
            }
            /*if (form.valuesByKey["\(name)"] != nil)
             {
             Formbackup["\(name)"] = form.valuesByKey["\(name)"]
             } */
        }
        for (key2,_) in form.valuesByKey
        {
            Formbackup["\(key2)"] = form.valuesByKey["\(key2)"]
        }
        var j : Int = 0
        while j < Form.count
        {
            let dic = Form[j] as! NSDictionary
            let name = dic["name"] as! String
            
            if name.range(of: "_field_") != nil
            {
                Form.remove(at: j)
                j = j-1
            }
                
            else
            {
                j = j+1
            }
            
        }
        
            if (form.valuesByKey["category_id"] != nil)
            {
                
                if let option = categoryDic["multiOptions"] as? NSDictionary
                {
                    
                    let categoryvalue = form.valuesByKey["category_id"] as! String
                    
                    print(categoryvalue)
                    
                    for (key, value) in option
                    {
                        
                        if categoryvalue == value as! String
                        {
                            
                            if let subDic = subcategoryDic["\(key)"] as? NSDictionary
                            {
                                subsubDic = subDic as! [AnyHashable : Any] as NSDictionary
                                if !isCreateOrEdit
                                {
                                    tempformValue["category_id"] = "\(key)"
                                    tempformValue.removeObject(forKey: "subcategory_id")
                                    tempformValue.removeObject(forKey: "subsubcategory_id")
                                    //formValue = tempformValue
                                }
                                
                                if let formDic = subDic["form"] as? NSDictionary
                                {
                                    index += 1
                                    Form.insert(formDic, at: index)
                                    tempCategArray = Form
                                    print(Form)
                                    
                                }
                            }
                            catFieldCheck = ""
                            if flag == false
                            {
                                if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                                {
                                    if feildtoaddArray.count > 0
                                    {
                                        catFieldCheck = "category_id"
                                        
                                    }
                                    else
                                    {
                                        catFieldCheck = ""
                                    }
                                    
                                    flag = true
                                    for dic in feildtoaddArray
                                    {
                                        index += 1
                                        
                                        Form.insert(dic as AnyObject, at: index)
                                        
                                    }
                                    
                                }
                            }
                                
                            
                            //defaultCategory = "\(value)"
                            
                        }
                        
                        
                    }
                    
                    
                }
            }

            FormforRepeat = Form
            
            self.formController.form = CreateNewForm()
            self.formController.tableView.reloadData()
    }
    
    func listingsubCategoryValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        subsubFlag = false
        let form = cell.field.form as! CreateNewForm
        if  subFlag == true{
            subFlag = false
            flag = false
            if !isCreateOrEdit{
                //Form = tempCategArray
            }
            else{
                Form = tempCategArray
            }
        }
        defaultsubsubCategory = ""
        
        var index1 = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "subsubcategory_id"
            {
                Form.remove(at: i)
            }
            
            if name == "subcategory_id"
            {
                index1 = i;
                
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
            
        }
        
        if !isCreateOrEdit{
            if catFieldCheck == "subcategory_id" || catFieldCheck == "subsubcategory_id"{
                
                for var j in 0 ..< (Form.count) where j < Form.count{
                    let dic = Form[j] as! NSDictionary
                    let name = dic["name"] as! String
                    if (name.range(of: "_field_") != nil) {
                        
                        Form.remove(at: j)
                        j = j - 1
                    }
                }
            }
        }
        
        
        
        if (form.valuesByKey["subcategory_id"] != nil)
        {
            if let formsubDic = subsubDic["form"] as? NSDictionary
            {
                if let option = formsubDic["multiOptions"] as? NSDictionary
                {
                    let subcategoryvalue = form.valuesByKey["subcategory_id"] as! String
                    for (key, value) in option
                    {
                        
                        if subcategoryvalue == value as! String
                        {
                            
                            if !isCreateOrEdit
                            {
                                tempformValue["subcategory_id"] = "\(key)"
                                tempformValue.removeObject(forKey: "subsubcategory_id")
                                formValue = tempformValue
                            }
                            
                            if let formsubsubDic = subsubDic["subsubcategories"] as? NSDictionary
                            {
                                if let formsubDic = formsubsubDic["\(key)"] as? NSDictionary
                                {
                                    clicksubsubDic = formsubDic as! [AnyHashable : Any] as NSDictionary
                                    
                                    index1 += 1
                                    Form.insert(formsubDic, at: index1)
                                    
                                }
                                
                            }
                            
                            if !isCreateOrEdit{
                                
                                if catFieldCheck == "subcategory_id" || catFieldCheck == "subsubcategory_id" || catFieldCheck == ""{
                                    
                                    if flag == false{
                                        if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                                        {
                                            if feildtoaddArray.count > 0{
                                                catFieldCheck = "subcategory_id"
                                            }
                                            // Form.remove(at:index1)
                                            flag = true
                                            subFlag = true
                                            for dic in feildtoaddArray
                                            {
                                                index1 += 1
                                                
                                                Form.insert(dic as AnyObject, at: index1)
                                                
                                            }
                                            
                                        }
                                    }
                                    
                                }
                            }
                                
                            else{
                                
                                if flag == false{
                                    if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                                    {
                                        flag = true
                                        subFlag = true
                                        for dic in feildtoaddArray
                                        {
                                            let dic = dic as! NSDictionary
                                            if let option = dic["multiOptions"] as? NSDictionary {
                                                checkBoxNameKey = dic["name"] as! String
                                                multiDic = option
                                            }
                                            
                                            index1 += 1
                                            
                                            Form.insert(dic as AnyObject, at: index1)
                                            
                                        }
                                        
                                    }
                                }
                                
                                
                            }
                            
                            defaultsubCategory = "\(value)"
                            
                        }
                    }
                    
                }
            }
                
            else
            {
                
                if (form.valuesByKey["category_id"] != nil)
                {
                    if let option = categoryDic["multiOptions"] as? NSDictionary
                    {
                        
                        let categoryvalue = form.valuesByKey["category_id"] as! String
                        for (key, value) in option
                        {
                            
                            if categoryvalue == value as! String
                            {
                                
                                if let subDic = subcategoryDic["\(key)"] as? NSDictionary
                                {
                                    subsubDic = subDic as! [AnyHashable : Any] as NSDictionary
                                    if let formsubDic = subsubDic["form"] as? NSDictionary
                                    {
                                        if let option = formsubDic["multiOptions"] as? NSDictionary
                                        {
                                            
                                            let subcategoryvalue = form.valuesByKey["subcategory_id"] as! String
                                            for (key, value) in option
                                            {
                                                
                                                if subcategoryvalue == value as! String
                                                {
                                                    
                                                    if let formsubsubDic = subsubDic["subsubcategories"] as? NSDictionary
                                                    {
                                                        if let formsubDic = formsubsubDic["\(key)"] as? NSDictionary
                                                        {
                                                            
                                                            index1 += 1
                                                            Form.insert(formsubDic, at: index1)
                                                            
                                                        }
                                                        
                                                        
                                                    }
                                                    
                                                    
                                                    if catFieldCheck == "subcategory_id" || catFieldCheck == "subsubcategory_id" || catFieldCheck == ""{
                                                        if flag == false{
                                                            if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                                                            {
                                                                if feildtoaddArray.count > 0{
                                                                    catFieldCheck = "subcategory_id"
                                                                }
                                                                
                                                                flag = true
                                                                subFlag = true
                                                                for dic in feildtoaddArray
                                                                {
                                                                    index1 += 1
                                                                    
                                                                    Form.insert(dic as AnyObject, at: index1)
                                                                    
                                                                }
                                                                
                                                            }
                                                        }
                                                    }
                                                    
                                                    defaultsubCategory = "\(value)"
                                                    
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        FormforRepeat = Form
        
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func listingsubsubCategoryValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        
        let form = cell.field.form as! CreateNewForm
        if  subsubFlag == true{
            subsubFlag = false
            flag = false
            if isCreateOrEdit{
                Form = tempCategArray
            }
        }
        
        var index2 = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            
            if name == "subsubcategory_id"
            {
                index2 = i;
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
            
        }
        if !isCreateOrEdit{
            if catFieldCheck == "subsubcategory_id"{
                
                for var j in 0 ..< (Form.count) where j < Form.count{
                    
                    let dic = Form[j] as! NSDictionary
                    let name = dic["name"] as! String
                    if (name.range(of: "_field_") != nil) {
                        
                        Form.remove(at: j)
                        j = j - 1
                    }
                    
                }
                
            }
        }
        
        
        if (form.valuesByKey["subsubcategory_id"] != nil)
        {
            if let option = clicksubsubDic["multiOptions"] as? NSDictionary
            {
                
                
                let subsubcategoryvalue = form.valuesByKey["subsubcategory_id"] as! String
                for (key, value) in option
                {
                    
                    if subsubcategoryvalue == value as! String
                    {
                        if !isCreateOrEdit
                        {
                            tempformValue["subsubcategory_id"] = "\(key)"
                            formValue = tempformValue
                        }
                        
                        if !isCreateOrEdit{
                            if catFieldCheck == "subsubcategory_id" || catFieldCheck == ""{
                                if flag == false{
                                    if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                                    {
                                        flag = true
                                        subFlag = true
                                        subsubFlag = true
                                        for dic in feildtoaddArray
                                        {
                                            index2 += 1
                                            Form.insert(dic as AnyObject, at: index2)
                                            
                                        }
                                        
                                    }
                                }
                            }
                        }
                        else{
                            if flag == false{
                                if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                                {
                                    flag = true
                                    subFlag = true
                                    subsubFlag = true
                                    for dic in feildtoaddArray
                                    {
                                        index2 += 1
                                        
                                        Form.insert(dic as AnyObject, at: index2)
                                        
                                    }
                                    
                                }
                            }
                            
                        }
                        
                        
                        defaultsubsubCategory = "\(value)"
                        
                    }
                }
                
            }
                
            else
            {
                
                if (form.valuesByKey["category_id"] != nil)
                {
                    if let option = categoryDic["multiOptions"] as? NSDictionary
                    {
                        
                        let categoryvalue = form.valuesByKey["category_id"] as! String
                        for (key, value) in option
                        {
                            
                            if categoryvalue == value as! String
                            {
                                
                                if let subDic = subcategoryDic["\(key)"] as? NSDictionary
                                {
                                    subsubDic = subDic as! [AnyHashable : Any] as NSDictionary
                                    if let formsubDic = subsubDic["form"] as? NSDictionary
                                    {
                                        if let option = formsubDic["multiOptions"] as? NSDictionary
                                        {
                                            
                                            let subcategoryvalue = form.valuesByKey["subcategory_id"] as! String
                                            for (key, value) in option
                                            {
                                                
                                                if subcategoryvalue == value as! String
                                                {
                                                    
                                                    if !isCreateOrEdit
                                                    {
                                                        tempformValue["subcategory_id"] = "\(key)"
                                                        
                                                        formValue = tempformValue
                                                    }
                                                    
                                                    
                                                    if let formsubsubDic = subsubDic["subsubcategories"] as? NSDictionary
                                                    {
                                                        if let formsubDic = formsubsubDic["\(key)"] as? NSDictionary
                                                        {
                                                            clicksubsubDic = formsubDic as! [AnyHashable : Any] as NSDictionary
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    if let option = clicksubsubDic["multiOptions"] as? NSDictionary
                                                    {
                                                        
                                                        let subsubcategoryvalue = form.valuesByKey["subsubcategory_id"] as! String
                                                        for (key, value) in option
                                                        {
                                                            
                                                            if subsubcategoryvalue == value as! String
                                                            {
                                                                
                                                                if !isCreateOrEdit
                                                                {
                                                                    tempformValue["subsubcategory_id"] = "\(key)"
                                                                    
                                                                    formValue = tempformValue
                                                                }
                                                                
                                                                if catFieldCheck == "subsubcategory_id" || catFieldCheck == ""{
                                                                    if flag == false{
                                                                        if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                                                                        {
                                                                            flag = true
                                                                            subFlag = true
                                                                            subsubFlag = true
                                                                            for dic in feildtoaddArray
                                                                            {
                                                                                index2 += 1
                                                                                
                                                                                Form.insert(dic as AnyObject, at: index2)
                                                                                
                                                                            }
                                                                            
                                                                        }
                                                                    }
                                                                }
                                                                
                                                                defaultsubsubCategory = "\(value)"
                                                                
                                                            }
                                                        }
                                                        
                                                    }
                                                    defaultsubCategory = "\(value)"
                                                    
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func categoryValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        
        Form.removeAll(keepingCapacity: false)
        
        Form = tempFormArray
        var index = Int()
        defaultsubCategory = ""
        
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            if let dicName = dic["name"] as? String {
                if dicName == "subcategory_id" || dicName == "subsubcategory_id"
                {
                    Form.remove(at: i)
                    
                }
                if dicName == "category_id"
                {
                    index = i;
                }
                if (form.valuesByKey["\(dicName)"] != nil)
                {
                    Formbackup["\(dicName)"] = form.valuesByKey["\(dicName)"]
                }

            }
           
        }
        
        for var j in 0 ..< (Form.count) where j < Form.count{
            
            let dic = Form[j] as! NSDictionary
            if let dicName = dic["name"] as? String {
                if dicName.range(of: "_field_") != nil
                {
                    Form.remove(at: j)
                    j = j-1
                }
            }
        }
        
        if (form.valuesByKey["category_id"] != nil)
        {
            if let option = categoryDic["multiOptions"] as? NSDictionary
            {
                
                let categoryvalue = form.valuesByKey["category_id"] as! String
                for (key, value) in option
                {
                    
                    if categoryvalue == value as! String
                    {
                        
                        if let subDic = subcategoryDic["\(key)"] as? NSDictionary
                        {
                            subsubDic = subDic as! [AnyHashable : Any] as NSDictionary
                            if !isCreateOrEdit
                            {
                                tempformValue["category_id"] = "\(key)"
                                tempformValue.removeObject(forKey: "subcategory_id")
                                tempformValue.removeObject(forKey: "subsubcategory_id")
                                formValue = tempformValue
                            }
                            
                            if let formDic = subDic["form"] as? NSDictionary
                            {
                                index += 1
                                Form.insert(formDic, at: index)
                                
                            }
                        }
                        if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                        {
                            for dic in feildtoaddArray
                            {
                                index += 1
                                Form.insert(dic as AnyObject, at: index)
                                
                            }
                            
                        }

                        defaultCategory = "\(value)"
                        //findOptionalFormIndexforcategory("advancedevents", option: 2)
                        
                    }

                }
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func subCategoryValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        
        var index1 = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "subsubcategory_id"
            {
                Form.remove(at: i)
            }
            if name == "subcategory_id"
            {
                index1 = i;
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
            
        }
        
        if (form.valuesByKey["subcategory_id"] != nil)
        {
            if let formsubDic = subsubDic["form"] as? NSDictionary
            {
                if let option = formsubDic["multiOptions"] as? NSDictionary
                {
                    
                    let subcategoryvalue = form.valuesByKey["subcategory_id"] as! String
                    for (key, value) in option
                    {
                        
                        if subcategoryvalue == value as! String
                        {
                            
                            if let formsubsubDic = subsubDic["subsubcategories"] as? NSDictionary
                            {
                                if let formsubDic = formsubsubDic["\(key)"] as? NSDictionary
                                {
                                    
                                    index1 += 1
                                    Form.insert(formsubDic, at: index1)
                                    
                                }
                                
                                
                            }
                            defaultsubCategory = "\(value)"
                            //findOptionalFormIndexforcategory("advancedevents", option: 11)
                            
                        }
                    }
                    
                }
            }
            else
            {
                
                if (form.valuesByKey["category_id"] != nil)
                {
                    if let option = categoryDic["multiOptions"] as? NSDictionary
                    {
                        
                        let categoryvalue = form.valuesByKey["category_id"] as! String
                        for (key, value) in option
                        {
                            
                            if categoryvalue == value as! String
                            {
                                
                                if let subDic = subcategoryDic["\(key)"] as? NSDictionary
                                {
                                    subsubDic = subDic as! [AnyHashable : Any] as NSDictionary
                                    if let formsubDic = subsubDic["form"] as? NSDictionary
                                    {
                                        if let option = formsubDic["multiOptions"] as? NSDictionary
                                        {
                                            
                                            let subcategoryvalue = form.valuesByKey["subcategory_id"] as! String
                                            for (key, value) in option
                                            {
                                                
                                                if subcategoryvalue == value as! String
                                                {
                                                    
                                                    if let formsubsubDic = subsubDic["subsubcategories"] as? NSDictionary
                                                    {
                                                        if let formsubDic = formsubsubDic["\(key)"] as? NSDictionary
                                                        {
                                                            
                                                            index1 += 1
                                                            Form.insert(formsubDic, at: index1)
                                                            
                                                        }
                                                        
                                                        
                                                    }
                                                    defaultsubCategory = "\(value)"
                                                    //findOptionalFormIndexforcategory("advancedevents", option: 11)
                                                    
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func EventRepeatValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        var index = Int()
        
        for var i in (0..<Form.count).reversed()
        {
            
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            
            if name == "eventrepeat_id"
            {
                index = i;
            }
            if name == "start_date" || name == "end_date" || name == "add_date" || name == "repeat_interval" || name == "date" || name == "repeat_week" || name == "repeat_weekday" || name == "repeat_month" || name == "repeat_interval" || name == "monthlyType" || name == "repeat_day"
            {
                Form.remove(at: i)
                i = i - 1
                
                continue
                
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        
        
        if (form.valuesByKey["eventrepeat_id"] != nil)
        {
            if let option = eventRepeatDic["multiOptions"] as? NSDictionary
            {
                
                let eventRepeatvalue = form.valuesByKey["eventrepeat_id"] as! String
                for (key, value) in option
                {
                    
                    if eventRepeatvalue == value as! String
                    {
                        
                        if let repeatarr = repeatDic["\(key)"] as? NSArray
                        {
                            
                            for dic in repeatarr
                            {
                                index += 1
                                Form.insert(dic as AnyObject, at: index)
                                
                            }
                        }
                        defaultrepeatid = "\(value)"
                        findOptionalFormIndex1("advancedevents", option: 1)
                        
                    }
                }
            }
        }
        
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
        findOptionalFormIndex1("advancedevents", option: 1)
    }
    
    func productHelpOpener(_ cell: FXFormFieldCellProtocol)
    {
        let presentedVC = ExternalWebViewController()
        presentedVC.url = self.productHelpUrl
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navigationController = UINavigationController(rootViewController: presentedVC)
        self.present(navigationController, animated: true, completion: nil)
        print("entered!")
    }
    

    // MARK: - Picking document from DocumentP[icker
    func pickDocument(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.composite-content","public.item"], in: UIDocumentPickerMode.import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    // After picking document relaod data ans save path
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL)
    {
        do
        {
            filePathArray.removeAll()
            filename = ""
            let filearr = url.path.components(separatedBy: "/")
            if filearr.count>0
            {
                filename = filearr[filearr.count - 1] as String
            }
            filePathArray.append(url.path)
            self.formController.form = CreateNewForm()
            self.formController.tableView.reloadData()
        }
        
        
    }
    
    func getRating(_ cell: FXFormFieldCellProtocol)
    {
        let defaults = UserDefaults.standard
        let rate = defaults.string(forKey: "rating")
        let keyname = defaults.string(forKey: "key")
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i]
            let Type = dic["type"] as! String
            if Type == "Rating"
            {
                let name = dic["name"] as! String
                if keyname == name
                {
                    let name = dic["name"] as! String
                    if rate != nil
                    {
                        tagbackupdic["\(name)"] = "\(rate!)"
                    }
                    else
                    {
                        tagbackupdic["\(name)"] = "0.0"
                    }
                    
                }
                
            }
            
        }
        
    }
    func changeHostAction(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        
        for (key , value) in form.valuesByKey{
            Formbackup[key] = value
        }
        
//        for i in 0 ..< (Form.count) where i < Form.count
//        {
//            let dic = Form[i] as! NSDictionary
//            let name = dic["name"] as! String
//            if (form.valuesByKey["\(name)"] != nil)
//            {
//                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
//            }
//        }
        tempFormArr = Form
        let presentedVC = HostChangeViewControlle()
        presentedVC.hostSelectionFormArr = hostSelectionFormArr
        self.navigationController?.pushViewController(presentedVC, animated: false)

    }

    func submitForm(_ cell: FXFormFieldCellProtocol)
    {
        removeAlert()
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "imagePicked") != nil {
            defaults.removeObject(forKey: "imagePicked")
        }
        self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
        //we can lookup the form from the cell if we want, like this:
        let form = cell.field.form as! CreateNewForm
        var error = ""
        var errorTitle = "Error"
        
        for (key,_) in Formbackup
        {
            let name = key as? String ?? ""
            if(form.valuesByKey["\(name)"] == nil)
            {
                form.valuesByKey["\(name)"] = Formbackup["\(name)"]
            }
        }
        
        //        for i in 0 ..< (Form.count) where i < Form.count
        //        {
        //            let dic = Form[i] as! NSDictionary
        //            let name = dic["name"] as! String
        //            if(form.valuesByKey["\(name)"] == nil)
        //            {
        //                form.valuesByKey["\(name)"] = Formbackup["\(name)"]
        //            }
        //        }
        
        if contentType == "Review"
        {
            
            for (key, value) in tagbackupdic
            {
                
                if let _ = form.valuesByKey["\(key)"]
                {
                    
                }
                else
                {
                    form.valuesByKey["\(key)"] = "\(value)"
                }
            }
            
        }
        
        if contentType == "advancedevents"
        {
            for (key, value) in Formbackup
            {
                
                if let _ = form.valuesByKey["\(key)"]
                {
                    
                }
                else
                {
                    form.valuesByKey["\(key)"] = "\(value)"
                }
            }
            
        }
        if contentType == "productType"
        {
            
            
            var value = form.valuesByKey["product_type"] as! String
            value = value.lowercased()
            let presentedVC = AddProductToStoreViewController()
            //let presentedVC = FormGenerationViewController()
            isCreateOrEdit = true
            //var params = [String:String]()
            //params["product_type"] = "simple"
            //params["store_id"] = "161"
            //presentedVC.formTitle = "Add Product"
            presentedVC.storeId = self.storeId
            presentedVC.url = "sitestore/product/create"
            presentedVC.contentType = "addProduct"
            presentedVC.productType = value
            //presentedVC.param = params as NSDictionary
            tempFormArray.removeAll(keepingCapacity: false)
            tempCategArray.removeAll(keepingCapacity: false)
            tempTempCategArray.removeAll(keepingCapacity: false)
            tempTempTempCategArray.removeAll(keepingCapacity: false)
            temp4CategArray.removeAll(keepingCapacity: false)
            temp5CategArray.removeAll(keepingCapacity: false)
            temp6CategArray.removeAll(keepingCapacity: false)
            temp7CategArray.removeAll(keepingCapacity: false)
            
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated: false, completion: nil)
            return
            //print(value)
            //print(form.valuesByKey["product_type"] as! String)
        }
        if conditionalForm != nil && conditionalForm == "applynow"
        {
            if(form.valuesByKey["contact"] != nil)
            {
                let value = form.valuesByKey["contact"] as! String
                if value.count > 0
                {
                    let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
                    if Set(value).isSubset(of: nums)
                    {
                        //print("ok")
                    }
                    else
                    {
                        error = NSLocalizedString("Please enter valid contact number!", comment: "")
                    }
                }
            }
        }
        if contentType == "wishlist"
        {
            //print(form.valuesByKey)
            var boolCheck = false
            for (key, value) in form.valuesByKey
            {
                if let k = key as? String, k == "title" ||  k == "body", let v = value as? String, v.length != 0
                {
                    boolCheck = true
                }
                else  if let v = value as? Int, v != 0
                {
                    boolCheck = true
                }
                
            }
            if boolCheck == false
            {
                error = NSLocalizedString("Please select the wishlist in which you want to add this listing.", comment: "")
            }
        }
        
        if(conditionForm != nil && conditionForm != "postReply" && conditionForm != "formMove" && conditionForm != "forumEditing" && conditionForm != "formRename" && conditionForm != "forumQuoting" && conditionForm == "topicCreation")
        {
            if(!isCreateOrEdit) && conditionalForm == "poll"
            {
                
                
            }
            else
            {
                if ((form.valuesByKey["title"] == nil) || (form.valuesByKey["title"] as! String) == "")
                {
                    error = NSLocalizedString("Please enter \(contentType!) name.", comment: "")
                }
                
                
                if ((form.valuesByKey["body"] == nil) || (form.valuesByKey["body"] as! String) == "") &&  error == ""
                {
                    let hasValidator = findValidator(key: "body")
                    if hasValidator
                    {
                        error = NSLocalizedString("Please enter \(contentType!) description.", comment: "")
                    }
                }
                
                
            }
            //            if contentType == "event" || contentType == "advancedevents"
            //            {
            //                if let startTime = form.valuesByKey["starttime"] as? Date{
            //                    if let endTime = form.valuesByKey["endtime"] as? Date{
            //                        if startTime.compare(endTime) ==  ComparisonResult.orderedDescending {
            //                            print("date1 is earlier than date2");
            //                            error = NSLocalizedString("Please enter \(contentType!) description.", comment: "")
            //                            return
            //                        }
            //                    }
            //                }
            //
            //            }
            
        }
        
        // Getting image 
        if contentType == "group" || contentType == "event" || contentType == "classified" || contentType == "album" || contentType == "video" || contentType == "forum" || contentType == "advancedevents" || (conditionalForm != nil && conditionalForm == "signupPhotoForm" || contentType == "Album" || contentType == "listings" || contentType == "Page" || contentType == "sitegroup" || contentType == "Advanced Video" || self.contentType == "Channel" || contentType == "Video" || contentType == "StoreCreate" || contentType == "playlist")
        {
            if contentType == "Album" || contentType == "album" {
                updateFromAlbum = true
            }
            if mediaType == "image"
            {
                if filePathArray.count > 0
                {
                    if (form.valuesByKey["photo"]) != nil
                    {
                        let imageArray = [form.valuesByKey["photo"] as! UIImage]
                        var path = [String]()
                        path = saveFileInDocumentDirectory(imageArray)
                        filePathArray.append(path[0] + " photo")
                        uploadMultiplePhoto = "advancedevent"
                        
                    }
                }
                else
                {
                    if (form.valuesByKey["photo"]) != nil
                    {
                        let imageArray = [form.valuesByKey["photo"] as! UIImage]
                        filePathArray.removeAll(keepingCapacity: false)
                        filePathArray = saveFileInDocumentDirectory(imageArray)
                    }
                    else
                    {
                        filePathArray.removeAll(keepingCapacity: false)
                    }
                }
            }
            else
            {
                var arryVideo = [AnyObject]()
                
                if (form.valuesByKey["filedata"]) != nil
                {
                    let videoUrl = form.valuesByKey["filedata"] as! URL
                    let thumbImage = getThumbnailFrom(path: videoUrl)
                    let imageNormal = fixOrientation(img: thumbImage!)
                    arryVideo.append(videoUrl as AnyObject)
                    arryVideo.append(imageNormal as AnyObject)
                    filePathArray.removeAll(keepingCapacity: false)
                    filePathArray = saveFileInDocumentDirectory(arryVideo)
                }
                else
                {
                    filePathArray.removeAll(keepingCapacity: false)
                }
            }
        }
        if contentType != nil && contentType == "Listings claim"{
            
            if ((form.valuesByKey["nickname"] == nil) || (form.valuesByKey["nickname"] as! String) == ""){
                errorTitle = NSLocalizedString("Name!!", comment: "")
                error = NSLocalizedString("Please enter your name.", comment: "")
            }
            if ((form.valuesByKey["email"] == nil) || (form.valuesByKey["email"] as! String) == "" || !checkValidEmail(form.valuesByKey["email"] as! String)) &&  error == ""{
                errorTitle = NSLocalizedString("Email!!", comment: "")
                
                if !checkValidEmail(form.valuesByKey["email"] as! String){
                    error = NSLocalizedString("Invalid email!! Please enter correct email address.", comment: "")
                }else{
                    error = NSLocalizedString("Please enter your email. This field cannot be empty.", comment: "")
                }
                
                
            }
            if ((form.valuesByKey["terms"] == nil) || (form.valuesByKey["terms"] as! Int) == 0) &&  error == ""{
                errorTitle = NSLocalizedString("Terms & Conditions!!", comment: "")
                error = NSLocalizedString("Please accept terms & conditions to continue.", comment: "")
            }
            if ((form.valuesByKey["about"] == nil) || (form.valuesByKey["about"] as! String) == "") &&  error == ""{
                error = NSLocalizedString("This field cannot be empty. Please enter some detail.", comment: "")
                errorTitle = NSLocalizedString("About you and listing!!.", comment: "")
            }
        }
        
        if (self.contentType != nil && self.contentType == "listings") || (self.contentType != nil && self.contentType == "advancedevents"){
            
            if ((form.valuesByKey["title"] == nil) || (form.valuesByKey["title"] as! String) == ""){
                if self.contentType != nil && contentType == "advancedevents"
                {
                    print("=====name1======")
                    error = NSLocalizedString("Please enter event's name.", comment: "")
                }
                else{
                    error = NSLocalizedString("Please enter \(contentType!) name.", comment: "")
                }
                
                
            }
            
            if ((form.valuesByKey["body"] == nil) || (form.valuesByKey["body"] as! String) == "") &&  error == ""{
                if self.contentType != nil && contentType == "advancedevents"
                {
                    print("=====name2======")
                    error = NSLocalizedString("Please enter event's description.", comment: "")
                }
                else
                {
                    let hasValidator = findValidator(key: "body")
                    if hasValidator
                    {
                        error = NSLocalizedString("Please enter \(contentType!) description.", comment: "")
                    }
                    //error = NSLocalizedString("Please enter \(contentType!) description.", comment: "")
                }
                
            }
            
            if ((form.valuesByKey["category_id"] == nil) || (form.valuesByKey["category_id"] as! String) == "") &&  error == ""{
                if self.contentType != nil && contentType == "advancedevents"
                {
                    print("=====name3======")
                    error = NSLocalizedString("Please enter event's category.", comment: "")
                }
                else{
                    error = NSLocalizedString("Please enter \(contentType!) category.", comment: "")
                }
                
                
            }
            
            
            //            if (self.contentType != nil && self.contentType == "advancedevents"){
            //                print("=====name4======")
            //                if ((form.valuesByKey["starttime"] == nil) || (form.valuesByKey["starttime"] as? Date) == nil) &&  error == ""{
            //                    print("=====name5======")
            //                    error = NSLocalizedString("Please enter event's start time.", comment: "")
            //                }
            //                if ((form.valuesByKey["endtime"] == nil) || (form.valuesByKey["endtime"] as? Date) == nil) &&  error == ""{
            //                    print("=====name6======")
            //                    error = NSLocalizedString("Please enter event's end time.", comment: "")
            //                }
            //
            //
            //            }
        }
        
        if contentType != nil && contentType == "sitegroup"
        {
            
            if ((form.valuesByKey["title"] == nil) || (form.valuesByKey["title"] as! String) == ""){
                error = NSLocalizedString("Please enter Advanced Group name.", comment: "")
            }
            
            
            if ((form.valuesByKey["body"] == nil) || (form.valuesByKey["body"] as! String) == "") &&  error == ""{
                error = NSLocalizedString("Please enter Advanced Group description.", comment: "")
                
            }
            
            if ((form.valuesByKey["category_id"] == nil) || (form.valuesByKey["category_id"] as! String) == "") &&  error == ""{
                error = NSLocalizedString("Please enter Advanced Group category.", comment: "")
                
            }
            
            
        }
        
        if contentType == ""
        {
            if ((form.valuesByKey["method"] == nil) || (form.valuesByKey["method"] as! String) == "")
            {
                error = NSLocalizedString("Please choose payment method.", comment: "")
            }
        }
        
        // Payment Configuration validation
        
        // Payment method error check code
        
        if contentType != nil && contentType == "paymentMethod"
        {
            
            if( (form.valuesByKey["isStripeChecked"] != nil) && (form.valuesByKey["isStripeChecked"] as! Int) == 1)
            {
                
                if( (form.valuesByKey["secret"] == nil) || (form.valuesByKey["secret"] as! String) == "") {
                    error = NSLocalizedString("Please enter Stripe secret Key", comment: "")
                }
                
                if( (form.valuesByKey["publishable"] == nil) || (form.valuesByKey["publishable"] as! String) == "") {
                    error = NSLocalizedString("Please enter Stripe Publishable Key", comment: "")
                }
            }
            
            if( (form.valuesByKey["isPaypalChecked"] != nil) && (form.valuesByKey["isPaypalChecked"] as! Int) == 1)
            {
                
                if( (form.valuesByKey["email_paypal"] == nil) || (form.valuesByKey["email_paypal"] as! String) == "") {
                    error = NSLocalizedString("Please enter paypal Email", comment: "")
                }
                
                if( (form.valuesByKey["username_paypal"] == nil) || (form.valuesByKey["username_paypal"] as! String) == "") {
                    error = NSLocalizedString("Please enter paypal username", comment: "")
                }
                
                if( (form.valuesByKey["password_paypal"] == nil) || (form.valuesByKey["password_paypal"] as! String) == "") {
                    error = NSLocalizedString("Please enter paypal password", comment: "")
                }
                
                if( (form.valuesByKey["signature_paypal"] == nil) || (form.valuesByKey["signature_paypal"] as! String) == "") {
                    error = NSLocalizedString("Please enter paypal API Signature", comment: "")
                }
                
            }
            
            if( (form.valuesByKey["isByChequeChecked"] != nil) && (form.valuesByKey["isByChequeChecked"] as! Int) == 1)
            {
                if( (form.valuesByKey["bychequeGatewayDetail"] == nil) || (form.valuesByKey["bychequeGatewayDetail"] as! String) == "") {
                    error = NSLocalizedString("Please enter Cheque Details", comment: "")
                }
            }
            
        }
        
        if contentType != nil && contentType == "editStore"
        {
            if( (form.valuesByKey["title"] == nil) || (form.valuesByKey["title"] as! String) == "")
            {
                error = NSLocalizedString("Please enter Title of the store", comment: "")
            }
            else if( (form.valuesByKey["tags"] == nil) || (form.valuesByKey["tags"] as! String) == "")
            {
                error = NSLocalizedString("Please enter tags of the store", comment: "")
            }
            else if( (form.valuesByKey["body"] == nil) || (form.valuesByKey["body"] as! String) == "")
            {
                error = NSLocalizedString("Please enter description of the Store", comment: "")
            }
        }
        
        if contentType != nil && contentType == "StoreCreate"
        {
            if( (form.valuesByKey["title"] == nil) || (form.valuesByKey["title"] as! String) == "")
            {
                error = NSLocalizedString("Please enter Title of the store", comment: "")
            }
            else if ((form.valuesByKey["store_uri"] == nil) || (form.valuesByKey["store_uri"] as! String == ""))
            {
                error = NSLocalizedString("PLease enter url of the Store", comment: "")
            }
            else if( (form.valuesByKey["tags"] == nil) || (form.valuesByKey["tags"] as! String) == "")
            {
                error = NSLocalizedString("Please enter tags of the store", comment: "")
            }
            else if( (form.valuesByKey["category_id"] == nil) || (form.valuesByKey["category_id"] as! String) == "")
            {
                error = NSLocalizedString("Please select a category for the store", comment: "")
            }
            else if( (form.valuesByKey["body"] == nil) || (form.valuesByKey["body"] as! String) == "")
            {
                error = NSLocalizedString("Please enter description of the Store", comment: "")
            }
        }
        
        if contentType == "Password reset"{
            if ((form.valuesByKey["password"] == nil) || (form.valuesByKey["password_confirm"] as! String) == ""){
                error = NSLocalizedString("Please enter your password. This field cannot be empty.", comment: "")
            }
        }
        
        
        
        // Payment Configuration validation check ends
        
        
        if error != ""
        {
            
            let alertController = UIAlertController(title: "\(errorTitle)", message:
                error, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        else
        {
            
            if Reachabable.isConnectedToNetwork()
            {
                self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                view.isUserInteractionEnabled = false
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                var checkBoxvalues = "" as String
                var checkKeys = String()
                
                var infoDic = Dictionary<String, String>()
                //Get MultiCheckBox Value in comma seperated way
                if self.contentType == "Advanced Video"
                {
                    if let value = UserDefaults.standard.string(forKey:"videoDurationKey"){
                        infoDic["duration"] = String(describing: value)
                    }
                }
                
                if self.contentType == "listings"
                {
                    
                    for i in 0 ..< (Form.count) where i < Form.count
                    {
                        let dic = Form[i] as! NSDictionary
                        
                        let type = dic["type"] as! String
                        
                        if type == "Multi_checkbox" || type == "MultiCheckbox" || type == "Multiselect"
                        {
                            checkBoxvalues = ""
                            checkKeys = ""
                            checkBoxNameKey = dic["name"] as! String
                            multiDic = (dic["multiOptions"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            
                            
                            if isCreateOrEdit{
                                for (key, value) in multiDic
                                {
                                    let keys =  form.valuesByKey["\(value)"] as? Int
                                    
                                    if keys != nil
                                    {
                                        
                                        if keys != 0
                                        {
                                            checkKeys = "\(key)"
                                            // form.valuesByKey.removeObject(forKey:value)
                                            if checkBoxvalues != ""
                                            {
                                                checkBoxvalues = "\(checkBoxvalues),\(checkKeys)"
                                            }
                                            else
                                            {
                                                checkBoxvalues = "\(checkKeys)"
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                                
                                for (key, value) in multiDic
                                {
                                    let keys =  form.valuesByKey["\(value)"] as? Int
                                    
                                    if keys != nil
                                    {
                                        
                                        if keys != 0
                                        {
                                            checkKeys = "\(key)"
                                            // form.valuesByKey.removeObject(forKey:value)
                                            if checkBoxvalues != ""
                                            {
                                                checkBoxvalues = "\(checkBoxvalues),\(checkKeys)"
                                            }
                                            else
                                            {
                                                checkBoxvalues = "\(checkKeys)"
                                            }
                                            
                                            
                                        }
                                    }
                                }
                            }
                            
                            if checkBoxvalues != ""
                            {
                                infoDic["\(checkBoxNameKey!)"] = "\(checkBoxvalues)"
                                
                            }
                        }
                        
                    }
                }
                
                var Repetdays = "" as String
                
                for (key, value) in form.valuesByKey
                {
                    
                    if (key as! NSString == "filedata") || (key as! NSString == "filename")
                    {
                        continue
                    }
                    
                    let RepetdaysArray:[String] = ["monday", "tuesday","wednesday","thursday","friday", "saturday","sunday"]
                    if RepetdaysArray.contains(key as! String)
                    {
                        
                        if let receiver = value as? Int
                        {
                            var days = String()
                            form.valuesByKey.removeObject(forKey: key)
                            if key as! String == "monday"
                            {
                                if receiver != 0
                                {
                                    days = String(1)
                                }
                                
                            }
                            
                            if key as! String == "tuesday"
                            {
                                if receiver != 0
                                {
                                    days = String(2)
                                }
                                
                            }
                            
                            if key as! String == "wednesday"
                            {
                                if receiver != 0
                                {
                                    days = String(3)
                                }
                                
                            }
                            
                            if key as! String == "thursday"
                            {
                                if receiver != 0
                                {
                                    days = String(4)
                                }
                                
                            }
                            
                            if key as! String == "friday"
                            {
                                if receiver != 0
                                {
                                    days = String(5)
                                }
                                
                            }
                            
                            if key as! String == "saturday"
                            {
                                if receiver != 0
                                {
                                    days = String(6)
                                }
                                
                            }
                            
                            if key as! String == "sunday"
                            {
                                if receiver != 0
                                {
                                    days = String(7)
                                }
                                
                            }
                            if Repetdays != ""
                            {
                                Repetdays = "\(Repetdays),\(days)"
                            }
                            else
                            {
                                Repetdays = "\(days)"
                            }
                            
                        }
                        
                    }
                    
                    if (key as! NSString == "change_description")
                    {
                        if let receiver = value as? String
                        {
                            infoDic["description"] = receiver as String
                        }
                    }
                    
                    //
                    //                    let conditionArray:[String] = ["forum_id","category_id","auth_invite","approval", "draft","auth_view","auth_comment","album","type","subcategory_id","subsubcategory_id","rotation","timezone","locale","eventrepeat_id","auth_post","auth_topic","auth_photo","auth_video","repeat_week","repeat_mon  th","repeat_interval","recommend","spcreate","svcreate","secreate","sdicreate","sdcreate","splcreate","sncreate","smcreate","main_channel_id","all_post","method"]
                    //
                    //
                    //                    //,"repeat_week","repeat_weekday","repeat_month","repeat_interval"
                    //                    if conditionArray.contains(key as! String)
                    //                    {
                    //                        if let _ = value as? NSString
                    //                        {
                    //                            //print(value)
                    //                            infoDic["\(key)"] = findKeyForValue2(form.valuesByKey["\(key)"] as! String,keyName: key as! String)
                    //                        }
                    //                        if let receiver = value as? Int
                    //                        {
                    //                            infoDic["\(key)"] = String(receiver)
                    //                        }
                    //                    }
                    //                    else
                    //                    {
                    //                        if self.contentType != "Review"
                    //                        {
                    //
                    //                            if (key as! NSString == "body")
                    //                            {
                    //                                for key in Form
                    //                                {
                    //                                    if let dic = (key as? NSDictionary)
                    //                                    {
                    //                                        for (key,value1) in dic
                    //                                        {
                    //                                            // Check for Type
                    //                                            if key as! NSString == "type" && value1 as! NSString == "Textarea"{
                    //                                                let newkey = dic["name"] as! String
                    //                                                infoDic["\(newkey)"] = value as? String
                    //                                                break
                    //                                            }
                    //                                            if key as! NSString == "name" && value1 as! NSString == "body"{
                    //                                                let newkey = dic["name"] as! String
                    //                                                infoDic["\(newkey)"] = value as? String
                    //                                                break
                    //                                            }
                    //
                    //
                    //                                        }
                    //                                    }
                    //                                }
                    //                                continue
                    //                            }
                    //                        }
                    //
                    //                        if (key as! NSString == "change_description")
                    //                        {
                    //                            //form.valuesByKey.removeObject(forKey: key)
                    //                            if let receiver = value as? String {
                    //                                infoDic["description"] = receiver as String
                    //                            }
                    //                        }
                    //
                    //                        if let receiver = value as? NSString {
                    //                            infoDic["\(key)"] = receiver as String
                    //                        }
                    //                        if let receiver = value as? Int {
                    //                            infoDic["\(key)"] = String(receiver)
                    //                        }
                    //                        if let receiver = value as? Date {
                    //                            let dateFormatter = DateFormatter()
                    //                            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                    //                            infoDic["\(key)"] = dateFormatter.string(from: receiver)
                    //                        }
                    //                        if let receiver = value as? URL {
                    //                            infoDic["\(key)"] = "\(receiver)"
                    //                        }
                    //
                    //                    }
                    //
                }
                
                
                for formDic in Form
                {
                    if let dicform = formDic as? NSDictionary
                    {
                        let keyName = dicform["name"] as? String ?? ""
                        let formValue = form.valuesByKey["\(keyName)"] as? String ?? ""
                        //                        if (keyName as NSString == "filedata") || (keyName as NSString == "filename")
                        //                        {
                        //                            continue
                        //                        }
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
                                        infoDic["\(keyName)"] = key as? String
                                    }
                                }
                            }
                            else if let options = dicform["multiOptions"] as? NSArray
                            {
                                for value in options
                                {
                                    if value as! String == formValue
                                    {
                                        infoDic["\(keyName)"] = formValue
                                    }
                                }
                            }
                        }
                            
                        else if type == "MultiCheckbox" || type == "Multi_checkbox" || type == "Multiselect"
                        {
                            //                            if let options = dicform["multiOptions"] as? NSDictionary
                            //                            {
                            //                                for(_,value) in options
                            //                                {
                            //                                    let checkKeyName = value as? String ?? ""
                            //                                    let value = form.valuesByKey["\(checkKeyName)"]
                            //                                    if let receiver = value as? Int
                            //                                    {
                            //                                        infoDic["\(checkKeyName)"] = String(receiver)
                            //                                    }
                            //                                }
                            //                            }
                        }
                            
                        else
                        {
                            let value = form.valuesByKey["\(keyName)"]
                            
                            if (keyName as NSString == "change_description")
                            {
                                if let receiver = value as? String
                                {
                                    infoDic["description"] = receiver as String
                                }
                            }
                            
                            if let receiver = value as? NSString
                            {
                                infoDic["\(keyName)"] = receiver as String
                            }
                            if let receiver = value as? Int
                            {
                                infoDic["\(keyName)"] = String(receiver)
                            }
                            if let receiver = value as? Date
                            {
                                let tempString = String(describing: receiver)
                                let tempArray = tempString.components(separatedBy: "+")
                                infoDic["\(keyName)"] = tempArray[0] as String
                            }
                            if let receiver = value as? URL
                            {
                                infoDic["\(keyName)"] = "\(receiver)"
                            }
                        }
                    }
                }
                
                for (key, value) in infoDic
                {
                    if (key == "type")
                    {
                        if value == "3"
                        {
                            //                            infoDic["url"] = ""
                            infoDic.removeValue(forKey: "url")
                        }
                        else
                        {
                            //                            infoDic["filedata"] = ""
                            infoDic.removeValue(forKey: "filedata")
                            filePathArray.removeAll(keepingCapacity: false)
                        }
                    }
                }
                
                
                //                if checkBoxvalues != ""
                //                {
                //                    infoDic["\(checkBoxNameKey!)"] = "\(checkBoxvalues)"
                //
                //                }
                
                if Repetdays != ""
                {
                    infoDic["repeat_weekday"] = "\(Repetdays)"
                }
                
                
                var dic = Dictionary<String, String>()
                for (key, value) in param
                {
                    
                    if let id = value as? NSNumber {
                        dic["\(key)"] = String(id as! Int)
                    }
                    
                    if let receiver = value as? NSString {
                        dic["\(key)"] = receiver as String
                    }
                }
                
                var method = "POST"
                
                if (conditionForm != nil && conditionForm == "formMove"){
                    //print("formMoveCheck")
                    isCreateOrEdit = true
                }
                
                if (conditionForm != nil && conditionForm == "forumEditing"){
                    //print("forumEditing")
                    isCreateOrEdit = false
                }
                
                if (conditionForm != nil && conditionForm == "formRename"){
                    //print("forumRename")
                    isCreateOrEdit = false
                }
                
                if (conditionForm != nil && conditionForm == "forumQuoting"){
                    //print("forumQuoting")
                    isCreateOrEdit = true
                }
                
                if isCreateOrEdit
                {
                    method = "POST"
                }
                else
                {
                    method = "POST"
                }
                
                if self.contentType == "Listings claim"
                {
                    dic["listingtype_id"] = String(listingTypeId!)
                }
                
                if eventExtensionCheck == true && packageId != 0{
                    dic["package_id"] = "\(packageId)"
                }
                
                dic.update(infoDic)
                dic.update(hostDictionary)
                
                if self.contentType == "listings" || self.contentType == "Page"
                {
                    if self.locParams != ""
                    {
                        dic["locationParams"] = self.locParams
                    }
                }
                
                // Send Server Request to Create/Edit Group Entries
                
                if self.contentType == "blog" || (self.contentType == "video1") || (self.contentType == "forum1")  || (self.contentType == "poll")||(self.contentType == "advancedeventsDetail" || self.contentType == "Listings claim") || self.contentType == "ads" || self.contentType == "paymentMethod" || self.contentType == "editStore"
                {
                    if self.contentType != nil && self.contentType == "blog"
                    {
                        
                        
                        infoGlobalDic = dic
                        activityIndicatorView.stopAnimating()
                        self.view.alpha = 1.0
                        self.view.isUserInteractionEnabled = true
                        
                        if self.contentType != nil && self.contentType == "blog"
                        {
                            if !isCreateOrEdit
                            {
                                let defaults = UserDefaults.standard
                                defaults.set("Edit", forKey: "EditValue")
                            }
                        }
                        
                        
                        if ((form.valuesByKey["title"] == nil) || (form.valuesByKey["title"] as! String) == "")
                        {
                            error = NSLocalizedString("Please enter \(contentType) name.", comment: "")
                            
                        }
                        
                        if error != ""
                        {
                            
                            let alertController = UIAlertController(title: "\(errorTitle)", message:
                                error, preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                        }
                        else
                        {
                            
                            let defaults = UserDefaults.standard
                            defaults.set("Check", forKey: "blogandclassified")
                            let instanceOfCustomObject: ZSSDemoViewController = ZSSDemoViewController()
                            //let presentedVC = EditorViewController()
                            instanceOfCustomObject.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: instanceOfCustomObject)
                            self.present(nativationController, animated:true, completion: nil)
                            
                        }
                        
                        
                    }
                    else
                    {
                        if self.contentType == "paymentMethod" {
                            url = "sitestore/set-store-gateway-info/"+storeId!
                        }
                        if self.contentType == "shippingMethod" {
                            url = "sitestore/add-shipping-method/"+storeId!
                        }
                        
                        print(dic)
                        print(method)
                        print(url)
                        post(dic,url: url , method: method) { (succeeded, msg) -> () in
                            DispatchQueue.main.async(execute:
                                {
                                    activityIndicatorView.stopAnimating()
                                    self.view.alpha = 1.0
                                    self.view.isUserInteractionEnabled = true
                                    if msg
                                    {
                                        if isCreateOrEdit {
                                            
                                            if self.contentType == "Listings claim"{
                                                
                                                showToast(message: String(format: NSLocalizedString("%@ has been submitted successfully.", comment: ""), self.contentType ), controller: self, onView: false, time: 5.0)
                                                
                                                self.createTimer(self)
                                            }
                                            if self.contentType == "ads"{
                                                showToast(message: NSLocalizedString("Thanks for your feedback. Your report has been submitted.", comment: ""), controller: self, onView: false, time: 5.0)
                                            }
                                            if self.contentType == "paymentMethod"
                                            {
                                                showToast(message: NSLocalizedString("Payment Method has been created successfully", comment: ""), controller: self, onView: false, time: 5.0)
                                            }
                                            else{
                                                showToast(message: String(format: NSLocalizedString("%@ has been created successfully.", comment: ""), self.contentType), controller: self, onView: false, time: 5.0)
                                                
                                                self.createTimer(self)
                                            }
                                            
                                            
                                        }
                                        else
                                        {
                                            if self.contentType == "Listings claim"{
                                                showToast(message: String(format: NSLocalizedString("%@ has been submitted successfully.", comment: ""), self.contentType), controller: self, onView: false, time: 5.0)
                                                
                                                self.createTimer(self)
                                            }else{
                                                if self.contentType == "editStore" {
                                                    showToast(message: String(format: NSLocalizedString("Store has been edited successfully.", comment: ""), self.contentType), controller: self, onView: false, time: 5.0)
                                                }
                                                else
                                                {
                                                    showToast(message: String(format: NSLocalizedString("%@ has been edited successfully.", comment: ""), self.contentType), controller: self, onView: false, time: 5.0)
                                                }
                                                
                                                self.createTimer(self)
                                            }
                                            
                                            
                                        }
                                        
                                        if(self.contentType == "forum1" && conditionForm == "formRename")
                                        {
                                            forumRenameTitle = dic["title"]! as String
                                            _ = self.navigationController?.popViewController(animated: true)
                                        }
                                        else
                                        {
                                            self.popAfterDelay = true
                                            
                                        }
                                        
                                        if isCreateOrEdit == true
                                        {
                                            if self.contentType == "blog"
                                            {
                                                if succeeded["body"] != nil
                                                {
                                                    
                                                    if let response = succeeded["body"] as? NSDictionary
                                                    {
                                                        if response["response"] != nil
                                                        {
                                                            
                                                            if let response = response["response"] as? NSDictionary
                                                            {
                                                                
                                                                let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                                    conditionalProfileForm = "BrowsePage"
                                                                    createResponse = response
                                                                    self.dismiss(animated: true, completion: nil)
                                                                    
                                                                    
                                                                })
                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            
                                            if(self.contentType == "poll")
                                            {
                                                if succeeded["body"] != nil
                                                {
                                                    
                                                    if let response = succeeded["body"] as? NSDictionary
                                                    {
                                                        
                                                        if response["response"] != nil
                                                        {
                                                            if let response = response["response"] as? NSDictionary
                                                            {
                                                                let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute:{ () -> Void in
                                                                    conditionalProfileForm = "BrowsePage"
                                                                    createResponse = response
                                                                    self.dismiss(animated: true, completion: nil)
                                                                    
                                                                })
                                                                
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                            }
                                            
                                            
                                            if(self.contentType == "blog") || (self.contentType == "poll")
                                            {
                                                self.popAfterDelay = false
                                            }
                                            else
                                            {
                                                self.popAfterDelay = true
                                            }
                                            
                                            self.createTimer(self)
                                        }
                                        else
                                        {
                                            self.popAfterDelay = true
                                            self.createTimer(self)
                                        }
                                        feedUpdate = true
                                        blogUpdate = true
                                        videosUpdate = true
                                        videoProfileUpdate = true
                                        contentFeedUpdate = true
                                        forumViewUpdate = true
                                        forumUpdate = true
                                        forumtopicViewUpdate = true
                                        pollUpdate = true
                                        forumtopicViewUpdate = true
                                        listingDetailUpdate = true
                                        pageDetailUpdate = true
                                        advGroupDetailUpdate = true
                                        reviewUpdate = true
                                        eventUpdate = true
                                        musicUpdate = true
                                        groupUpdate = true
                                        productUpdate = true
                                        storeUpdate = true
                                        storeDetailUpdate = true
                                        pageUpdate = true
                                        listingUpdate = true
                                        albumUpdate = true
                                        classifiedUpdate = true
                                        advanceVideoProfileUpdate = true
                                        channelUpdate = true
                                        
                                        channelProfileUpdate = true
                                        playlistProfileUpdate = true
                                        
                                    }
                                    else
                                    {
                                        // Handle server Side Error
                                        if succeeded["message"] != nil
                                        {
                                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 5.0)
                                        }
                                        else
                                        {
                                            showToast(message: "Please complete this field - it is required.", controller: self, onView: false, time: 5.0)
                                        }
                                    }
                            })
                        }
                    }
                    
                }
                else
                {
                    var singlePhoto = true
                    if self.contentType == "album" || contentType == "Album"{
                        singlePhoto = false
                    }
                    var mediaDataType = ""
                    for key in Form
                    {
                        if let dic = (key as? NSDictionary)
                        {
                            for (key,value) in dic
                            {
                                // Check for Type
                                if key as! NSString == "type" && value as! NSString == "File"{
                                    mediaDataType = dic["name"] as! String
                                }
                            }
                        }
                    }
                    
                    dic["album"] = "0"
                    
                    if self.contentType == "listings"
                    {
                        dic["listingtype_id"] = String(listingTypeId!)
                    }
                    
                    if self.contentType == "StoreCreate"
                    {
                        if let packageId = param["package_id"] as? Int
                        {
                            dic["package_id"] = String(packageId)
                        }
                    }
                    
                    if self.contentType == "mainFile"
                    {
                        dic["type"] = "main"
                    }
                    else if self.contentType == "sampleFile"
                    {
                        dic["type"] = "sample"
                    }
                    
                    let defaults = UserDefaults.standard
                    
                    if let name = defaults.value(forKey: "overviewcheck")
                    {
                        if  name as! String != "" {
                            
                            
                            if (self.contentType != nil && self.contentType == "classified") || (self.contentType != nil && self.contentType == "listings") || (self.contentType != nil && self.contentType == "advancedevents") {
                                
                                infoGlobalDic = dic
                                
                                activityIndicatorView.stopAnimating()
                                self.view.alpha = 1.0
                                self.view.isUserInteractionEnabled = true
                                
                                if self.contentType != nil && self.contentType == "classified"{
                                    
                                    if ((form.valuesByKey["title"] == nil) || (form.valuesByKey["title"] as! String) == ""){
                                        error = NSLocalizedString("Please enter \(contentType) name.", comment: "")
                                        
                                    }
                                    
                                    
                                    if !isCreateOrEdit{
                                        
                                        let defaults = UserDefaults.standard
                                        defaults.set("Edit", forKey: "EditValue")
                                        
                                    }
                                }
                                
                                if self.contentType != nil && self.contentType != "classified"{
                                    
                                    
                                    let defaults = UserDefaults.standard
                                    defaults.set("Overview", forKey: "EditorTitle")
                                    
                                }
                                if error != ""{
                                    
                                    let alertController = UIAlertController(title: "\(errorTitle)", message:
                                        error, preferredStyle: UIAlertController.Style.alert)
                                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                                    
                                    self.present(alertController, animated: true, completion: nil)
                                    
                                }
                                else
                                {
                                    if self.contentType != nil && self.contentType == "classified" {
                                        let defaults = UserDefaults.standard
                                        defaults.set("Check", forKey: "blogandclassified")
                                    }
                                    
                                    let instanceOfCustomObject: ZSSDemoViewController = ZSSDemoViewController()
                                    
                                    instanceOfCustomObject.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                    
                                    let nativationController = UINavigationController(rootViewController: instanceOfCustomObject)
                                    self.present(nativationController, animated:true, completion: nil)
                                }
                                
                            }
                            
                            
                        }
                        else
                        {
                            if placeandorder == 1
                            {
                                url = "advancedeventtickets/order/place-order"
                            }
                            postForm(dic, url: url, filePath: filePathArray, filePathKey: mediaDataType , SinglePhoto: singlePhoto) { (succeeded, msg) -> () in
                                DispatchQueue.main.async(execute: {
                                    activityIndicatorView.stopAnimating()
                                    self.view.isUserInteractionEnabled = true
                                    self.view.alpha = 1.0
                                    for path in filePathArray
                                    {
                                        removeFileFromDocumentDirectoryAtPath(path)
                                    }
                                    filePathArray.removeAll(keepingCapacity: false)
                                    if msg
                                    {
                                        if placeandorder == 1
                                        {
                                            if let body = succeeded["body"] as? NSDictionary
                                            {
                                                if let weburl = body["webviewUrl"] as? String
                                                {
                                                    let presentedVC = ExternalWebViewController()
                                                    presentedVC.url = weburl
                                                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                                    let navigationController = UINavigationController(rootViewController: presentedVC)
                                                    self.present(navigationController, animated: true, completion: nil)
                                                }
                                                else
                                                {
                                                    showToast(message: NSLocalizedString("Thanks for your's purchase !, your order id is \(body["order_id"]!) .", comment: ""), controller: self)
                                                    
                                                    self.dismiss(animated: false, completion: nil)
                                                    
                                                    
                                                }
                                            }
                                        }
                                        else
                                        {
                                            if isCreateOrEdit
                                            {
                                                
                                                if self.contentType == "AddToDiary"
                                                {
                                                    showToast(message: NSLocalizedString("Your event has been successfully added.", comment: ""), controller: self, onView: false, time: 5.0)
                                                    
                                                }
                                                else if self.contentType == "shippingMethod" {
                                                    showToast(message: NSLocalizedString("Shipping Method Added Successfully", comment: ""), controller: self, onView: false, time: 5.0)
                                                }
                                                else
                                                {
                                                    
                                                    if(self.contentType == "advancedevents")
                                                    {
                                                        showToast(message: NSLocalizedString("Your event has been created successfully.", comment: ""), controller: self, onView: false, time: 5.0)
                                                    }
                                                    else if self.contentType == "Review"
                                                    {
                                                        storeDetailUpdate = true
                                                        showToast(message: String(format: NSLocalizedString("%@ has been submitted successfully.", comment: ""),self.contentType), controller: self, onView: false, time: 5.0)
                                                    }
                                                    else if self.contentType == "listings"
                                                    {
                                                        showToast(message: String(format: NSLocalizedString("%@ has been created successfully.", comment: ""), listingNameToShow ), controller: self, onView: false, time: 5.0)
                                                    }
                                                    else if self.contentType == "applynow"
                                                    {
                                                        showToast(message: String(format: NSLocalizedString("Applied for job Successfully", comment: "")), controller: self, onView: false, time: 5.0)
                                                    }
                                                    else if self.contentType == "sitegroup"
                                                    {
                                                        showToast(message: String(format: NSLocalizedString("Advanced Group has been created successfully.", comment: "")), controller: self, onView: false, time: 5.0)
                                                    }
                                                    else if self.contentType == "group"
                                                    {
                                                        showToast(message: String(format: NSLocalizedString("Group has been created successfully.", comment: "")), controller: self, onView: false, time: 5.0)
                                                    }
                                                    else if self.contentType == "Advanced Video"
                                                    {
                                                        showToast(message: String(format: NSLocalizedString("Video has been uploaded successfully.", comment: "")), controller: self, onView: false, time: 5.0)
                                                    }
                                                        
                                                    else if self.contentType == "Advanced Channel"
                                                    {
                                                        isCreateOrEdit = true
                                                        let presentedVC = FormGenerationViewController()
                                                        presentedVC.formTitle = NSLocalizedString("Add New Video", comment: "")
                                                        presentedVC.contentType = "Advanced Video"
                                                        presentedVC.param = [ : ]
                                                        presentedVC.url = "advancedvideos/create"
                                                        self.navigationController?.pushViewController(presentedVC, animated: false)
                                                        
                                                    }
                                                    else if self.contentType == "groupJoin"
                                                    {
                                                        showToast(message: String(format: NSLocalizedString("Your action performed Successfully.", comment: "")), controller: self, onView: false, time: 5.0)
                                                    }
                                                    else if self.contentType == "addtoplaylist"
                                                    {
                                                        showToast(message: String(format: NSLocalizedString("Video has been added to playlist.", comment: "")), controller: self, onView: false, time: 5.0)
                                                    }
                                                    else if self.contentType == "StoreCreate"
                                                    {
                                                        showToast(message: String(format: NSLocalizedString("Store has been created successfully", comment: "")), controller: self, onView: false, time: 5.0)
                                                        if succeeded["body"] != nil
                                                        {
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                createResponse = response
                                                            }
                                                        }
                                                        conditionalProfileForm = "BrowseStore"
                                                        self.dismiss(animated: true, completion: nil)
                                                        
                                                    }
                                                    else if self.contentType == "Channel"
                                                    {
                                                        showToast(message: String(format: NSLocalizedString("Channel has been created successfully.", comment: "")), controller: self, onView: false, time: 5.0)
                                                    }
                                                        
                                                    else if self.contentType == "product wishlist"{
                                                        showToast(message: String(format: NSLocalizedString("Wishlist has been updated successfully.", comment: "")), controller: self, onView: false, time: 5.0)
                                                        
                                                    }
                                                    else if self.contentType == "playlist"{
                                                        showToast(message: NSLocalizedString("Playlist has been created successfully.", comment: ""), controller: self, onView: false, time: 5.0)
                                                        
                                                    }
                                                    else if self.contentType == "Password reset"
                                                    {
                                                        showToast(message: NSLocalizedString("Password has been reset successfully", comment: ""), controller: self, onView: false, time: 5.0)
                                                    }
                                                    else
                                                    {
                                                        if videoAttachFromAAF == "AAF"
                                                        {
                                                            
                                                            showToast(message: NSLocalizedString("Your video is in queue to be processed - you will be notified when it is ready to be viewed.", comment: ""), controller: self, onView: false, time: 5.0)
                                                            feedUpdate = true
                                                            
                                                            
                                                        }
                                                        else
                                                        {
                                                            
                                                            let contenname = self.contentType.capitalizingFirstLetter()
                                                            if contenname == "capacitywaitlist"
                                                            {
                                                                showToast(message: String(format: NSLocalizedString("Capacity has been updated successfully.", comment: "")), controller: self, onView: false, time: 5.0)
                                                            }
                                                                
                                                            else
                                                            {
                                                                showToast(message: String(format: NSLocalizedString("%@ created successfully.", comment: ""), contenname), controller: self, onView: false, time: 5.0)
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    if(self.contentType == "advancedevents")
                                                    {
                                                        
                                                        if succeeded["body"] != nil
                                                        {
                                                            
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                if response["response"] != nil{
                                                                    if let response = response["response"] as? NSDictionary{
                                                                        
                                                                        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                                            conditionalProfileForm = "BrowsePage"
                                                                            if self.eventExtensionCheck == true{
                                                                                conditionalProfileForm = ""
                                                                                packageCheck = false
                                                                                advGroupDetailUpdate = true
                                                                                pageDetailUpdate = true
                                                                                listingDetailUpdate = true
                                                                                storeDetailUpdate = true
                                                                                
                                                                            }
                                                                            
                                                                            createResponse = response
                                                                            self.dismiss(animated: true, completion: nil)
                                                                            
                                                                        })
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                    if(self.contentType == "Album")
                                                    {
                                                        if succeeded["body"] != nil
                                                        {
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                if response["album"] != nil
                                                                {
                                                                    if let response = response["album"] as? NSDictionary
                                                                    {
                                                                        
                                                                        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                                            conditionalProfileForm = "BrowsePage"
                                                                            createResponse = response
                                                                            self.dismiss(animated: true, completion: nil)
                                                                            
                                                                        })
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                    if(self.contentType == "classified")
                                                    {
                                                        if succeeded["body"] != nil
                                                        {
                                                            
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                
                                                                if response["response"] != nil
                                                                {
                                                                    if let response = response["response"] as? NSDictionary
                                                                    {
                                                                        
                                                                        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                                            conditionalProfileForm = "BrowsePage"
                                                                            createResponse = response
                                                                            self.dismiss(animated: true, completion: nil)
                                                                            
                                                                            
                                                                        })
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                    if(self.contentType == "group")
                                                    {
                                                        if succeeded["body"] != nil
                                                        {
                                                            
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                
                                                                if response["response"] != nil
                                                                {
                                                                    if let response = response["response"] as? NSDictionary
                                                                    {
                                                                        
                                                                        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                                            conditionalProfileForm = "BrowsePage"
                                                                            createResponse = response
                                                                            self.dismiss(animated: true, completion: nil)
                                                                            
                                                                        })
                                                                        
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                    if(self.contentType == "event")
                                                    {
                                                        if succeeded["body"] != nil
                                                        {
                                                            
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                
                                                                if response["response"] != nil
                                                                {
                                                                    if let response = response["response"] as? NSDictionary
                                                                    {
                                                                        
                                                                        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                                            conditionalProfileForm = "BrowsePage"
                                                                            createResponse = response
                                                                            self.dismiss(animated: true, completion: nil)
                                                                            
                                                                        })
                                                                        
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                    if(self.contentType == "video")
                                                    {
                                                        
                                                        if succeeded["body"] != nil
                                                        {
                                                            
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                
                                                                if response["response"] != nil
                                                                {
                                                                    if let response = response["response"] as? NSDictionary
                                                                    {
                                                                        
                                                                        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                                            conditionalProfileForm = "BrowsePage"
                                                                            let VC = VideoBrowseViewController()
                                                                            if VC.videoTypeCheck == "listings"
                                                                            {
                                                                                createResponse = response
                                                                                self.dismiss(animated: true, completion: nil)
                                                                                
                                                                            }
                                                                            else
                                                                            {
                                                                                if videoAttachFromAAF == "AAF"
                                                                                {
                                                                                    conditionalProfileForm = "AAF"
                                                                                    createResponse = response
                                                                                    self.dismiss(animated: false, completion: nil)
                                                                                    
                                                                                    
                                                                                }
                                                                                createResponse = response
                                                                                self.dismiss(animated: true, completion: nil)
                                                                                
                                                                            }
                                                                            
                                                                        })
                                                                        
                                                                    }
                                                                }
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                    if(self.contentType == "Diary")
                                                    {
                                                        
                                                        if succeeded["body"] != nil
                                                        {
                                                            
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                if response["response"] != nil
                                                                {
                                                                    if let response = response["response"] as? NSDictionary
                                                                    {
                                                                        
                                                                        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                                            conditionalProfileForm = "BrowsePage"
                                                                            createResponse = response
                                                                            self.dismiss(animated: true, completion: nil)
                                                                            
                                                                        })
                                                                        
                                                                        
                                                                    }
                                                                }
                                                            }
                                                            
                                                            
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    if(self.contentType == "listings")
                                                    {
                                                        if succeeded["body"] != nil
                                                        {
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                                    
                                                                    conditionalProfileForm = "BrowsePage"
                                                                    
                                                                    let viewType = sitereviewMenuDictionary["viewProfileType"] as! Int                                                 
                                                                    
                                                                    if response.object(forKey: "price") != nil && (response["price"] as! Int > 0 ){
                                                                        
                                                                        if response["currency"] != nil{
                                                                            
                                                                            let currencySymbol = getCurrencySymbol(response["currency"] as! String)
                                                                            profileCurrencySymbol = currencySymbol
                                                                        }
                                                                    }
                                                                    createResponse = response
                                                                    self.dismiss(animated: true, completion: nil)
                                                                    
                                                                })
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    if(self.contentType == "Page")
                                                    {
                                                        if succeeded["body"] != nil
                                                        {
                                                            
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                
                                                                let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                                    conditionalProfileForm = "BrowsePage"
                                                                    
                                                                    createResponse = response
                                                                    self.dismiss(animated: true, completion: nil)
                                                                    
                                                                })
                                                                
                                                            }
                                                        }
                                                    }
                                                    if(self.contentType == "sitegroup")
                                                    {
                                                        if succeeded["body"] != nil
                                                        {
                                                            
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                
                                                                if response["response"] != nil
                                                                {
                                                                    if let response = response["response"] as? NSDictionary
                                                                    {
                                                                        
                                                                        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                                            conditionalProfileForm = "BrowsePage"
                                                                            createResponse = response
                                                                            advgroupUpdate = true
                                                                            self.dismiss(animated: true, completion: nil)
                                                                            
                                                                        })
                                                                        
                                                                    }
                                                                }
                                                                
                                                                
                                                            }
                                                        }
                                                        
                                                    }
                                                    
                                                    if(self.contentType ==  "product wishlist")
                                                    {
                                                        if succeeded["body"] != nil
                                                        {
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                
                                                                if let _ = response["wishlistPresent"] as? Int{
                                                                    AddToWishlistIcon = true
                                                                }
                                                                
                                                            }
                                                        }
                                                        
                                                        
                                                    }
                                                    if(self.contentType == "Channel")
                                                    {
                                                        if succeeded["body"] != nil
                                                        {
                                                            
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                
                                                                if response["response"] != nil
                                                                {
                                                                    if let response = response["response"] as? NSDictionary
                                                                    {
                                                                        
                                                                        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                                            conditionalProfileForm = "BrowsePage"
                                                                            createResponse = response
                                                                            channelUpdate = true
                                                                            channelProfileUpdate = true
                                                                            self.dismiss(animated: true, completion: nil)
                                                                            
                                                                        })
                                                                        
                                                                    }
                                                                }
                                                                
                                                                
                                                            }
                                                        }
                                                        
                                                    }
                                                    if(self.contentType == "Advanced Video")
                                                    {
                                                        if succeeded["body"] != nil
                                                        {
                                                            
                                                            if let response = succeeded["body"] as? NSDictionary
                                                            {
                                                                
                                                                if response["response"] != nil
                                                                {
                                                                    if let response = response["response"] as? NSDictionary
                                                                    {
                                                                        
                                                                        let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                                                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                                                            conditionalProfileForm = "BrowsePage"
                                                                            createResponse = response
                                                                            advVideosUpdate = true
                                                                            self.dismiss(animated: true, completion: nil)
                                                                            
                                                                        })
                                                                        
                                                                    }
                                                                }
                                                                
                                                                
                                                            }
                                                        }
                                                        
                                                    }
                                                }
                                                
                                                if(self.contentType == "Diary") || (self.contentType == "advancedevents") || (self.contentType == "Album") || (self.contentType == "classified") || (self.contentType == "group") || (self.contentType == "event") || (self.contentType == "video") || (self.contentType == "listings") || (self.contentType == "Page" || (self.contentType == "sitegroup") || (self.contentType == "Advanced Video") || (self.contentType == "Channel") || (self.contentType == "Advanced Channel"))
                                                {
                                                    if videoAttachFromAAF != "AAF"
                                                    {
                                                        self.popAfterDelay = false
                                                        
                                                    }
                                                    
                                                }
                                                else
                                                {
                                                    
                                                    self.dismiss(animated: true, completion: nil)
                                                    self.popAfterDelay = true
                                                }
                                                if self.contentType != "Advanced Channel"
                                                {
                                                    self.createTimer(self)
                                                }
                                                
                                            }
                                            else
                                            {
                                                
                                                if(self.contentType == "advancedevents")
                                                {
                                                    showToast(message: NSLocalizedString("Your event has been edited successfully.", comment: ""), controller: self)
                                                }
                                                else if self.contentType == "listings"{
                                                    showToast(message: String(format: NSLocalizedString("%@ has been edited successfully.", comment: ""), listingNameToShow), controller: self)
                                                }
                                                else if self.contentType == "Review"
                                                {
                                                    
                                                    showToast(message: String(format: NSLocalizedString("%@ has been updated successfully.", comment: ""), self.contentType), controller: self)
                                                    
                                                }
                                                else if self.contentType == "sitegroup"
                                                {
                                                    showToast(message: String(format: NSLocalizedString("Advanced Group has been edited successfully.", comment: "")), controller: self)
                                                }
                                                else if self.contentType == "Contact"{
                                                    
                                                    if succeeded["body"] != nil{
                                                        if let response = succeeded["body"] as? NSDictionary{
                                                            isContactUpdate = true
                                                            profileField = response
                                                            
                                                        }
                                                        
                                                    }
                                                    showToast(message: NSLocalizedString("Details are saved successfully", comment: ""), controller: self)
                                                }
                                                else
                                                {
                                                    
                                                    showToast(message: String(format: NSLocalizedString("%@ updated successfully.", comment: ""), self.contentType), controller: self)
                                                    
                                                }
                                                self.createTimer(self)
                                                
                                                self.popAfterDelay = true
                                                if self.contentType != "Page" && self.contentType != "Review"
                                                {
                                                    
                                                    self.dismiss(animated: true, completion: nil)
                                                    self.popAfterDelay = true
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                        
                                        storeDetailUpdate = true
                                        pageUpdate = true
                                        listingDetailUpdate = true
                                        listingUpdate = true
                                        groupUpdate = true
                                        eventUpdate = true
                                        classifiedUpdate = true
                                        albumUpdate = true
                                        contentFeedUpdate = true
                                        videosUpdate = true
                                        forumViewUpdate = true
                                        forumUpdate = true
                                        forumtopicViewUpdate = true
                                        forumtopicViewUpdate = true
                                        classifiedDetailUpdate = true
                                        videoProfileUpdate = true
                                        wishlistUpdate = true
                                        reviewUpdate = true
                                        pageDetailUpdate = true
                                        productUpdate = true
                                        productDetailUpdate = true
                                        advGroupDetailUpdate = true
                                        advgroupUpdate = true
                                        advVideosUpdate = true
                                        channelUpdate = true
                                        channelProfileUpdate = true
                                        advanceVideoProfileUpdate = true
                                        storeDetailUpdate = true
                                        storeUpdate = true
                                        
                                        
                                    }
                                    else
                                    {
                                        self.view.isUserInteractionEnabled = true
                                        self.view.alpha = 1.0
                                        if self.contentType == "Page" || self.contentType == "Review" || self.contentType == "sitegroup" || self.contentType == "Channel"
                                        {
                                            if let error_code = succeeded["error_code"] as? String
                                            {
                                                if error_code == "validation_fail"
                                                {
                                                    var message = "Please complete these fields - "
                                                    let fields = self.showValidationToast()
                                                    for field in fields
                                                    {
                                                        message = message + "\(field),"
                                                    }
                                                    if message.length > 0
                                                    {
                                                        message = message.substring(to: message.index(before: message.endIndex))
                                                    }
                                                    showToast(message: message, controller: self)
                                                    print(fields)
                                                }
                                                else
                                                {
                                                    showToast(message: succeeded["message"] as! String, controller: self)
                                                }
                                                
                                            }
                                            else
                                            {
                                                showToast(message: succeeded["message"] as! String, controller: self)
                                            }
                                        }
                                        else
                                        {
                                            if succeeded["message"] != nil
                                            {
                                                let msg = succeeded["message"] as! String
                                                showToast(message: msg, controller: self)
                                            }
                                            else
                                            {
                                                showToast(message: unconditionalMessage, controller: self)
                                            }
                                        }
                                    }
                                    
                                })
                            }
                        }
                        
                    }
                }
            }
            else
            {
                // No Internet Connection Message
                showToast(message: network_status_msg, controller: self)
            }
            
        }
    }
    
    func showValidationToast() -> [String]
    {
        var fieldNames = [String]()
        for(key,values) in validation
        {
            for elements in Form
            {
                if let dic = elements as? NSDictionary
                {
                    let keyName = dic["name"] as? String ?? ""
                    if key as! String == keyName
                    {
                        let fieldName = dic["label"] as? String ?? ""
                        fieldNames.append(fieldName)
                    }
                }
            }
        }
        return fieldNames
    }
    
    func findValidator(key: String) -> Bool
    {
        for elements in Form
        {
            if let dic = elements as? NSDictionary
            {
                if let name = dic["name"] as? String
                {
                    if name == key
                    {
                        if let validator = dic["hasValidator"] as? String
                        {
                            if validator == "true" || validator == "True" || validator == "TRUE"
                            {
                                return true
                            }
                        }
                        else if let validator = dic["hasValidator"] as? Bool
                        {
                            if validator == true
                            {
                                return true
                            }
                        }
                    }
                }
                
            }
        }
        return false
    }

     func goBack()
    {
        placeandorder = 0
        let defaults = UserDefaults.standard
        defaults.set("", forKey: "EventLocation")
        if defaults.value(forKey: "imagePicked") != nil {
            defaults.removeObject(forKey: "imagePicked")
        }
        videoAttachFromAAF = ""
        self.dismiss(animated: true, completion: nil)
    }
    
    func enterPaymentPassword ()
    {
        let alert = UIAlertController(title: "Password", message: "Enter Your Login Password", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your Password"
        }
        alert.addAction(action)
        present(alert, animated:false, completion: nil)
    }
    
    func addStore()
    {
        let presentedVC = FormGenerationViewController()
        presentedVC.formTitle = NSLocalizedString("Add new Method", comment: "")
        presentedVC.contentType = "shippingMethod"
        let nativationController = UINavigationController(rootViewController : presentedVC)
        self.present(nativationController, animated : false, completion : nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func formLocation(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        for (key2,_) in form.valuesByKey
        {
            Formbackup["\(key2)"] = form.valuesByKey["\(key2)"]
        }
        let presentedVC = BrowseLocationViewController()
        presentedVC.delegate = self as ReturnLocationToForm
        presentedVC.fromFormGeneration = true
        presentedVC.fromMainForm = true
        self.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    func sendLocation(location: String)
    {
        locationInForm = location
        print("location is : \(location)")
    }
    
    func isReloadForm(reload : Bool)
    {
        self.reloadForm = reload
    }
    
    func sendLocationParam(locationParam: [String : Any])
    {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: locationParam, options:  [])
            let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            self.locParams = finalString
            
        }
        catch _ {
        }
    }
    
    
}

