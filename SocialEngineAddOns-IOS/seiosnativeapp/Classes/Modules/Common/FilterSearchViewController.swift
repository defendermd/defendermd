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
//  FilterSearchViewController.swift
//  seiosnativeapp

import UIKit

var Form = [AnyObject]()
var PhotoForm = [AnyObject]()
var addWishlistDescriptIon = ""
var createWishlistDescription = ""
var searchDic = Dictionary<String, String>()
var filterSeachDic = Dictionary<String, String>()
var isFilterSearch = false
var filterSearchFormArray = [AnyObject]()
var filterView = [AnyObject]()
var filterSearchString = ""
var globalTypeSearch = ""

var category_filterId : Int!
var showInFilter  = ""                          //show variable is a keyword
var showEventType = ""
var orderBy = ""
var event_time = ""
var venue_name = ""
var proximity = ""
var Siteevent_street = ""
var siteevent_city = ""
var siteevent_state = ""
var siteevent_country = ""
var category_id = ""
var location = "ab"
var search_diary = ""
var member = ""
var orderby = ""
var start_date:Date!
var end_date : Date!
var whatWhereWithinmile: Bool!
var profileTypeDic : NSDictionary = [:]

//MARK: Varibles for form customization
var globCoreSearchType = ""
var globSearchString = ""
var fromGlobSearch = false
var categoryDicFilter : NSMutableDictionary = [:]
var subCategoryDicFilter : NSMutableDictionary = [:]


@objcMembers class FilterSearchViewController: FXFormViewController,ReturnLocationToForm {
    
    
    
    var searchUrl:String!
    var serachFor:String! = ""
    var filterArray = [AnyObject]()
    var stringFilter = ""
    var listingTypeId : Int!
    var flag : Bool = false
    var subFlag : Bool = false
    var subsubFlag : Bool = false
    var contentType = ""
    var url = ""
    var leftBarButtonItem : UIBarButtonItem!
    var reloadForm = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conditionalForm = ""
        defaultCategory = ""
        
        hideIndexFormArray.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(FilterSearchViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
        self.title = NSLocalizedString("Filter Search", comment: "")
        if contentType == "listings" || contentType == "members" || contentType == "Page" || contentType == "Stores" || contentType == "products" || contentType == "sitegroup"
        {
            
            conditionalForm = contentType
            
        }
        if contentType == "SearchHome"{
            conditionalForm = "coreSearch"
        }

        //MARK: Work for Reset Form to Global Search
        if fromGlobSearch && conditionalForm != "coreSearch"{
            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(FilterSearchViewController.toGlobalSearch))
            self.navigationItem.setRightBarButtonItems([searchItem], animated: true)
        }
    }
    
    // Generate Filter Search Form On View Appear
    override func viewWillAppear(_ animated: Bool)
    {
        if conditionalForm == "coreSearch"{
            self.navigationItem.rightBarButtonItem = nil
            
        }
        
        if filterSearchFormArray.count > 0
        {
            
            isCreateOrEdit = false
            Form = filterArray
            
            var tempDic = [String:String]()
            if (serachFor == "group" || serachFor == "event"){
                
                if category_filterId != nil{
                    tempDic["category_id"] = "\(category_filterId)"
                }
                tempDic["search_text"] = stringFilter
            }
            else if (serachFor == "listing")
            {
                if self.reloadForm == true
                {
                    self.reloadForm = false
                    self.formController.form = CreateNewForm()
                }
                else
                {
                    locationInForm = ""
                }
//                isCreateOrEdit = true
//
//                if Formbackup["show"] != nil {
//                    if  Formbackup["show"] as! String != ""
//                    {
//                        tempDic["show"] = Formbackup["show"] as? String
//                    }
//                }
//
//                if  Formbackup["orderby"] != nil {
//                    if  Formbackup["orderby"] as! String != ""
//                    {
//                        tempDic["orderby"] = Formbackup["orderby"] as? String
//                    }
//                }
//
//                if Formbackup["category_id"] != nil {
//                    if  Formbackup["category_id"] as! String != ""
//                    {
//                        tempDic["category_id"] = Formbackup["category_id"] as? String
//                    }
//                }
//
//                if Formbackup["review"] != nil{
//                    if  Formbackup["review"] as! String != ""
//                    {
//                        tempDic["review"] = Formbackup["review"] as? String
//                    }
//                }
//
//                if Formbackup["closed"] != nil{
//                    if  Formbackup["closed"] as! String != ""
//                    {
//                        tempDic["closed"] = Formbackup["closed"] as? String
//                    }
//                }
//
//                if Formbackup["has_photo"] != nil {
//                    if  Formbackup["has_photo"] as! Int != 0
//                    {
//                        tempDic["has_photo"] = String(Formbackup["has_photo"] as! Int)
//                    }
//                }
//
//                if Formbackup["max_price"] != nil{
//                    if  Formbackup["max_price"] as! String != ""
//                    {
//                        tempDic["max_price"] = Formbackup["max_price"] as? String
//                    }
//                }
//
//                if Formbackup["min_price"] != nil{
//                    if  Formbackup["min_price"] as! String != ""
//                    {
//                        tempDic["min_price"] = Formbackup["min_price"] as? String
//                    }
//                }
//
//
//                if Formbackup["location"] != nil{
//                    if  Formbackup["location"] as! String != ""
//                    {
//                        tempDic["location"] = Formbackup["location"] as? String
//
//                    }
//                }
//
//                if Formbackup["search"] != nil{
//                    if  Formbackup["search"] as! String != ""
//                    {
//                        tempDic["search"] = Formbackup["search"] as? String
//
//                    }
//                }
//
//                tempDic["search"] = stringFilter
//                globFilterValue = stringFilter
            }
            else if (serachFor == "products"){
                isCreateOrEdit = true
                
                if  Formbackup["orderby"] != nil {
                    if  Formbackup["orderby"] as! String != ""
                    {
                        tempDic["orderby"] = Formbackup["orderby"] as? String
                    }
                }
                
                if  Formbackup["discount"] != nil {
                    if  Formbackup["discount"] as! String != ""
                    {
                        tempDic["discount"] = Formbackup["discount"] as? String
                    }
                }
                
                if Formbackup["category_id"] != nil {
                    if  Formbackup["category_id"] as! String != ""
                    {
                        tempDic["category_id"] = Formbackup["category_id"] as? String
                    }
                }
                
                if Formbackup["price"] != nil{
                    if  Formbackup["price"] as! String != ""
                    {
                        tempDic["price"] = Formbackup["price"] as? String

                    }
                }
                
                
                if Formbackup["search"] != nil{
                    if  Formbackup["search"] as! String != ""
                    {
                        tempDic["search"] = Formbackup["search"] as? String
                    }
                }
                if Formbackup["minPrice"] != nil{
                    if  Formbackup["minPrice"] as! String != ""
                    {
                        tempDic["minPrice"] = Formbackup["minPrice"] as? String
                    }
                }
                if Formbackup["maxPrice"] != nil{
                    if  Formbackup["maxPrice"] as! String != ""
                    {
                        tempDic["maxPrice"] = Formbackup["maxPrice"] as? String
                    }
                }
                if Formbackup["in_stock"] != nil{
                    if  Formbackup["in_stock"] as! String != ""
                    {
                        tempDic["in_stock"] = Formbackup["in_stock"] as? String

                    }
                }

                tempDic["search"] = stringFilter
                globFilterValue = stringFilter
            }
            else if(serachFor == "advancedevents"){
                isCreateOrEdit = true
                iscomingFromAdvEvents = true
                
                if category_filterId != nil{
                    tempDic["category_id"] = "\(category_filterId)"
                }
                
                if showInFilter != ""{
                    tempDic["show"] = "\(show)"
                }
                
                if showEventType != ""{
                    tempDic["showEventType"] = "\(showEventType)"
                }
                
                if orderBy != ""{
                    tempDic["orderBy"] = "\(orderBy)"
                }
                
                if event_time != ""{
                    tempDic["event_time"] = "\(event_time)"
                }
                
                if venue_name != ""{
                    tempDic["venue_name"] = "\(venue_name)"
                }
                
                if location != "ab"{
                    tempDic["location"] = "\(location)"
                }
                
                if proximity != ""{
                    tempDic["proximity"] = "\(proximity)"
                }
                
                if Siteevent_street != ""{
                    tempDic["Siteevent_street"] = "\(Siteevent_street)"
                }
                
                if siteevent_city != ""{
                    tempDic["siteevent_city"] = "\(siteevent_city)"
                }
                
                if siteevent_state != ""{
                    tempDic["siteevent_state"] = "\(siteevent_state)"
                }
                
                if siteevent_country != ""{
                    tempDic["siteevent_country"] = "\(siteevent_country)"
                }
                
                if category_id != ""{
                    tempDic["category_id"] = "\(category_id)"
                }
                
                if search_diary != ""{
                    tempDic["search_diary"] = "\(search_diary)"
                }
                
                if member != ""{
                    tempDic["member"] = "\(member)"
                }
                
                if orderby != ""{
                    tempDic["orderby"] = "\(orderby)"
                }
                
                tempDic["search"] = stringFilter
                globFilterValue = stringFilter
                
            }
            else if (serachFor == "Pages") || (serachFor == "sitegroup")
            {
                if self.reloadForm == true
                {
                    self.reloadForm = false
                    self.formController.form = CreateNewForm()
                }
                else
                {
                    locationInForm = ""
                }
                
//                isCreateOrEdit = true
//                if Formbackup["show"] != nil {
//                    if  Formbackup["show"] as! String != ""
//                    {
//                        tempDic["show"] = Formbackup["show"] as? String
//                    }
//                }
//
//                if  Formbackup["orderby"] != nil {
//                    if  Formbackup["orderby"] as! String != ""
//                    {
//                        tempDic["orderby"] = Formbackup["orderby"] as? String
//                    }
//                }
//
//                if Formbackup["category"] != nil {
//                    if  Formbackup["category"] as! String != ""
//                    {
//                        tempDic["category"] = Formbackup["category"] as? String
//                    }
//                }
//
//                if Formbackup["sitepage_street"] != nil {
//                    if  Formbackup["sitepage_street"] as! String != ""
//                    {
//                        tempDic["sitepage_street"] = Formbackup["sitepage_street"] as? String
//                    }
//                }
//
//                if Formbackup["sitepage_country"] != nil {
//                    if  Formbackup["sitepage_country"] as! String != ""
//                    {
//                        tempDic["sitepage_country"] = Formbackup["sitepage_country"] as? String
//                    }
//                }
//
//                if Formbackup["sitepage_state"] != nil {
//                    if  Formbackup["sitepage_state"] as! String != ""
//                    {
//                        tempDic["sitepage_state"] = Formbackup["sitepage_state"] as? String
//                    }
//                }
//
//                if Formbackup["sitepage_city"] != nil {
//                    if  Formbackup["sitepage_city"] as! String != ""
//                    {
//                        tempDic["sitepage_city"] = Formbackup["sitepage_city"] as? String
//                    }
//                }
//
//                if Formbackup["sitepage_location"] != nil {
//                    if  Formbackup["sitepage_location"] as! String != ""
//                    {
//                        tempDic["sitepage_location"] = Formbackup["sitepage_location"] as? String
//                    }
//                }
//                if Formbackup["sitegroup_location"] != nil {
//                    if  Formbackup["sitegroup_location"] as! String != ""
//                    {
//                        tempDic["sitegroup_location"] = Formbackup["sitegroup_location"] as? String
//                    }
//                }
//
//
//                if Formbackup["locationmiles"] != nil {
//                    if  Formbackup["locationmiles"] as! String != ""
//                    {
//                        tempDic["locationmiles"] = Formbackup["locationmiles"] as? String
//                    }
//                }
//
//
//
//                tempDic["search"] = stringFilter
//                globFilterValue = stringFilter
                
            }
            else if(serachFor == "coreSearch"){
                isCreateOrEdit = false
                //conditionalForm = ""
                if globCoreSearchType != ""{
                    
                    tempDic["type"] = globCoreSearchType
                }else if globalTypeSearch != ""{
                    tempDic["type"] = globalTypeSearch
                }else{
                    tempDic["type"] = "0"
                }
                
                tempDic["query"] = stringFilter
                if globSearchString != ""{
                    tempDic["query"] = globSearchString
                }
            }
            else if (serachFor == "members"){
                isCreateOrEdit = true
                
                if  Formbackup["locationmiles"] != nil {
                    if  Formbackup["locationmiles"] as! String != ""
                    {
                        tempDic["locationmiles"] = Formbackup["locationmiles"] as? String
                    }
                }
                
                if Formbackup["show"] != nil {
                    if Formbackup["show"] as! String != ""
                    {
                        tempDic["show"] = Formbackup["show"] as? String
                    }
                }
                
                if  Formbackup["network_id"] != nil {
                    if let network_id = Formbackup["network_id"] as? Int{
                        if  network_id != 0
                        {
                            tempDic["network_id"] = String(network_id)
                        }
                    }else if let network_id = Formbackup["network_id"] as? String{
                        tempDic["network_id"] = String(network_id)
                    }
                    
                }
                
                if  Formbackup["orderby"] != nil {
                    if  Formbackup["orderby"] as! String != ""
                    {
                        tempDic["orderby"] = Formbackup["orderby"] as? String
                    }
                }
                
                if Formbackup["is_online"] != nil {
                    if let isonline = Formbackup["has_photo"] as? Int
                    {
                        if  isonline != 0
                        {
                            tempDic["is_online"] = String(Formbackup["is_online"] as! Int)
                        }
                    }

                }
                
                if Formbackup["has_photo"] != nil {
                    if let isphoto = Formbackup["has_photo"] as? Int
                    {
                        if  isphoto != 0
                        {
                            tempDic["has_photo"] = String(Formbackup["has_photo"] as! Int)
                        }
                    }
                }
                
                if Formbackup["location"] != nil{
                    if  Formbackup["location"] as! String != ""
                    {
                        tempDic["location"] = Formbackup["location"] as? String
                    }
                }
                
                if Formbackup["search"] != nil{
                    if  Formbackup["search"] as! String != ""
                    {
                        tempDic["search"] = Formbackup["search"] as? String
                    }
                }
                
                tempDic["search"] = stringFilter
                globFilterValue = stringFilter
            }
            else
            {
                if category_filterId != nil
                {
                    tempDic["category"] = "\(category_filterId)"
                }

                tempDic["search"] = stringFilter
                
            }
            
            formValue = tempDic as NSDictionary
            self.formController.form = CreateNewForm()
            self.formController.tableView.reloadData()
            
        }
        else
        {
            var tempDic = [String:String]()
            tempDic["search"] = stringFilter
            globFilterValue = stringFilter
            generateSearchForm()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        iscomingFromAdvEvents = false
        // Remove view from Window
           viewRemoveFromWindow()
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
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    
    // MARK: - Server Connection For Form Generation
    
    // Generation of Filter Search Form
    func generateSearchForm(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {

            filterSearchFormArray.removeAll(keepingCapacity: false)
            UserDefaults.standard.removeObject(forKey: "SellSomething")
            categoryDicFilter.removeAllObjects()
            subCategoryDicFilter.removeAllObjects()
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            var parameters = [String:String]()
            
            if self.contentType == "listings"{
                
                parameters = ["listingtype_id" : String(listingTypeId)]
            }
            
            // Create Server Request for Filter Search Form
            
            post(parameters, url: searchUrl ?? "search", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        // On Success Add Values to Form Array
                        Form.removeAll(keepingCapacity: false)
                        Formbackup.removeAllObjects()
                        filterSearchFormArray.removeAll(keepingCapacity: false)
                        if let form = succeeded["body"] as? NSArray{
                            Form = form as [AnyObject]
                            filterSearchFormArray = form as [AnyObject]
                            // Crete Filter Search Form
                        }
                        if let dic = succeeded["body"] as? NSDictionary{
                            if let formArray = dic["form"] as? NSArray{
                                Form = formArray as [AnyObject]
                                
                                filterSearchFormArray = formArray as [AnyObject]
                                
                                
                                if self.contentType == "listings" || self.contentType == "Page" || self.contentType == "Stores" || self.contentType == "products" || self.contentType == "sitegroup"{
                                    
                                    
                                    for key in Form{
                                        
                                        // Create element Dictionary for every FXForm Element
                                        
                                        if let dic = (key as? NSDictionary)
                                        {
                                            if dic["name"] as? String == "category_id"
                                            {
                                                categoryDicFilter = dic as! NSMutableDictionary
                                            }
                                            if dic["name"] as? String == "category"
                                            {
                                                categoryDicFilter = dic as! NSMutableDictionary
                                            }
                                            
                                        }
                                    }
                                    
                                    
                                }
                                
                                if self.contentType == "members"{
                                    
                                    for key in Form{
                                        // Create element Dictionary for every FXForm Element
                                        
                                        if let dic = (key as? NSDictionary)
                                        {
                                            if dic["name"] as? String == "profile_type"
                                            {
                                                profileTypeDic = dic
                                            }
                                            
                                        }
                                    }
                                    
                                    
                                }
                                
                                if self.serachFor == "coreSearch"{
                                    isCreateOrEdit = false
                                    tempformValue = formValue.mutableCopy() as! NSMutableDictionary
                                    tempformValue.setValue("\(self.stringFilter)", forKey: "query")
                                    if globSearchString != ""{
                                        tempformValue.setValue("\(globSearchString)", forKey: "query")
                                    }
                                    formValue = tempformValue
                                    if globCoreSearchType == "" || globCoreSearchType == "0"{
                                        tempformValue = formValue.mutableCopy() as! NSMutableDictionary
                                        tempformValue.setValue("0", forKey: "type")
                                        formValue = tempformValue
                                    }else{
                                        tempformValue = formValue.mutableCopy() as! NSMutableDictionary
                                        tempformValue.setValue("\(globCoreSearchType)", forKey: "type")
                                        formValue = tempformValue
                                    }
                                    
                                }
                                
                            }
                            
                            if self.contentType == "listings" || self.contentType == "members" || self.contentType == "products"{
                                if let formValues = dic["formValues"] as? NSDictionary
                                {
                                    formValue = formValues as! [AnyHashable : Any] as NSDictionary
                                }
                            }
                            
                        }
                        
                        if self.contentType == "listings" || self.contentType == "Page" || self.contentType == "Stores" || self.contentType == "products" || self.contentType == "sitegroup"
                            
                        {
                            
                            if let dic = succeeded["body"] as? NSDictionary
                            {
                                if self.url == "listings/search-form" ||  self.url == "sitestore/product/product-search-form"
                                {
                                    if let formArray = dic["form"] as? NSArray
                                    {
                                        tempFormArray = formArray as [AnyObject]
                                        Form = formArray as [AnyObject]
                                        
                                        
                                    }
                                    if let catdic = dic["categoriesForm"] as? NSDictionary
                                    {
                                        
                                        subCategoryDicFilter = catdic as! NSMutableDictionary
                                    }
                                    
                                    if let fieldDic = dic["fields"] as? NSDictionary
                                    {
                                        fieldsDic = fieldDic
                                    }
                                    if let formValues = dic["formValues"] as? NSDictionary
                                    {
                                        formValue = formValues
                                    }
                                    
                                }
                                else
                                {
                                    if let formArray = dic["form"] as? NSArray
                                    {
                                        tempFormArray = formArray as [AnyObject]
                                        Form = formArray as [AnyObject]
                                    }
                                    if let catdic = dic["categoriesForm"] as? NSDictionary
                                    {
                                        subCategoryDicFilter = catdic as! NSMutableDictionary
                                    }
                                    
                                    
                                    if let fieldDic = dic["fields"] as? NSDictionary
                                    {
                                        fieldsDic = fieldDic
                                    }
                                    
                                    if let formValues = dic["formValues"] as? NSDictionary
                                    {
                                        tempformValue = formValues.mutableCopy() as! NSMutableDictionary
                                        formValue = formValues
                                    }
                                    
                                }
                            }
                        }
                        
                        if self.contentType == "members"
                        {
                            if let dic = succeeded["body"] as? NSDictionary
                            {
                                if let formArray = dic["form"] as? NSArray
                                {
                                    tempFormArray = formArray as [AnyObject]
                                    Form = formArray as [AnyObject]
                                }
                                
                                if let fieldDic = dic["fields"] as? NSDictionary
                                {
                                    
                                    fieldsDic = fieldDic
                                }
                                
                                if self.url == "members/search-form"
                                {
                                    if let formValues = dic["formValues"] as? NSDictionary
                                    {
                                        formValue = formValues
                                    }
                                }
                                else
                                {
                                    if let formValues = dic["formValues"] as? NSDictionary
                                    {
                                        tempformValue = formValues.mutableCopy() as! NSMutableDictionary
                                        formValue = formValues
                                    }
                                }
                            }
                        }
                        
                        if self.contentType == "SearchHome"
                        {
                            if let dic = succeeded["body"] as? NSDictionary
                            {
                                if let formArray = dic["form"] as? NSArray
                                {
                                    tempFormArray = formArray as [AnyObject]
                                    Form = formArray as [AnyObject]
                                }
                                
                                if self.url == "search"
                                {
                                    if let formValues = dic["formValues"] as? NSDictionary
                                    {
                                        formValue = formValues
                                    }
                                }
                                else
                                {
                                    if let formValues = dic["formValues"] as? NSDictionary
                                    {
                                        tempformValue = formValues.mutableCopy() as! NSMutableDictionary
                                        formValue = formValues
                                    }
                                }
                            }
                        }
                        
                        
                        self.formController.form = CreateNewForm()
                        self.formController.tableView.reloadData()
                        
                    }
                    else
                    {
                        // Hanle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
        }else{
            showToast(message: network_status_msg, controller: self)
            
        }
        
    }
    
    
    
    // Listing Category called
    
    func listingCategoryValueChanged(_ cell: FXFormFieldCellProtocol)
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
            if name == "category_id"
            {
                index = i;
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        
        if (form.valuesByKey["category_id"] != nil)
        {
            
            
            if let option = categoryDicFilter["multiOptions"] as? NSDictionary
            {
                
                let categoryvalue = form.valuesByKey["category_id"] as! String
                for (key, value) in option
                {
                    
                    if categoryvalue == value as! String
                    {
                        
                        if let subDic = subCategoryDicFilter["\(key)"] as? NSDictionary
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
                                tempCategArray = Form
                                
                            }
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
    
    func listingsubCategoryValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        subsubFlag = false
        //flag = false
        // subFlag = true
        let form = cell.field.form as! CreateNewForm
        
        if  subFlag == true{
            subFlag = false
            flag = false
            
            Form = tempCategArray
        }
        defaultsubsubCategory = ""

        var index1 = Int()
        for i in 0 ..< Form.count
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
                                    clicksubsubDic = formsubDic as! [AnyHashable : Any] as NSDictionary
                                    
                                    index1 += 1
                                    Form.insert(formsubDic, at: index1)
                                    
                                }
                                
                                
                            }

                            if flag == false{
                                if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                                {
                                    flag = true
                                    subFlag = true
                                    for dic in feildtoaddArray
                                    {
                                        index1 += 1
   
                                        Form.insert(dic as AnyObject, at: index1)
                                    }

                                }
                                
                            }
                            
                            defaultsubCategory = "\(value)"
                            // findOptionalFormIndexforcategory("advancedevents", option: 11)
                            
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
            
            Form = tempCategArray
        }
        
        var index2 = Int()
        for i in 0 ..< Form.count
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
        
        if (form.valuesByKey["subsubcategory_id"] != nil)
        {
            if let option = clicksubsubDic["multiOptions"] as? NSDictionary
            {
                
                let subsubcategoryvalue = form.valuesByKey["subsubcategory_id"] as! String
                for (key, value) in option
                {
                    
                    if subsubcategoryvalue == value as! String
                    {
                        
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
                        
                        defaultsubsubCategory = "\(value)"
                        // findOptionalFormIndexforcategory("advancedevents", option: 11)
                        
                    }
                }
                
            }
        }
        
        FormforRepeat = Form
        
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func memberProfileTypeValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        flag = false
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
        
        for i in 0 ..< Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "profile_type"
            {
                index = i;
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
                if name == "network_id"{
                    Formbackup["\(name)"] = findKeyForValue(form.valuesByKey["\(name)"] as! String)
                }
            }
        }
        
        if (form.valuesByKey["profile_type"] != nil)
        {
            if let option = profileTypeDic["multiOptions"] as? NSDictionary
            {
                let profileTypeValue = form.valuesByKey["profile_type"] as! String
                for (key, value) in option
                {
                    if profileTypeValue == value as! String
                    {
                        if !isCreateOrEdit
                        {
                            tempformValue["profile_type"] = "\(key)"
                            formValue = tempformValue
                        }
                        
                        if flag == false{
                            
                            if let fieldToAddArray = fieldsDic["\(key)"] as? NSArray
                            {
                                flag = true
                                //subFlag = true
                                for dic in fieldToAddArray
                                {
                                    index += 1
                                    Form.insert(dic as AnyObject, at: index)
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
    
    
  // Submission For Filter serch Form
   func submitForm(_ cell: FXFormFieldCellProtocol)
   {
       
       isFilterSearch = true
       //we can lookup the form from the cell if we want, like this:
       let form = cell.field.form as! CreateNewForm
       
       var error = ""
       var minimumPrice : Int! = 0
       var maximumPrice : Int! = 0
       switch(serachFor){
           
       case "blog":
           blogUpdate = true
       case "group":
           groupUpdate = true
       case "event":
           eventUpdate = true
       case "members":
           membersUpdate = true
       case "classified":
           classifiedUpdate = true
       case "album":
           albumUpdate = true
       case "video":
           videosUpdate = true
       case "poll":
           pollUpdate = true
       case "listing":
           listingUpdate = true
       case "Pages":
           pageUpdate = true
       case "products":
           productUpdate = true
       case "sitegroup":
           advgroupUpdate = true
       default:
           print("error no such class")
       }
       
       
       for (key, value) in form.valuesByKey
       {
           if (key as! NSString == "draft") || (key as! NSString == "category_id") || (key as! NSString == "subcategory_id") || (key as! NSString == "subsubcategory_id") || (key as! NSString == "order") || (key as! NSString == "view") || (key as! NSString == "show") || (key as! NSString == "category") || (key as! NSString == "showEventType") || (key as! NSString == "orderBy") || (key as! NSString == "discount") || (key as! NSString == "closed") || (key as! NSString == "sort") || (key as! NSString == "type") || (key as! NSString == "orderby") || (key as! NSString == "max_price") || (key as! NSString == "min_price") || (key as! NSString == "minPrice") || (key as! NSString == "maxPrice") || (key as! NSString == "review") || (key as! NSString == "closed")  || (key as! NSString == "sitepage_state") || (key as! NSString == "sitepage_city") || (key as! NSString == "sitepage_street") || (key as! NSString == "sitepage_location") || (key as! NSString == "network_id") || (key as! NSString  == "type" && serachFor == "coreSearch") || (key as! NSString == "in_stock") || (key as! NSString == "locationmiles") || (key as! NSString == "sitegroup_location") || (key as! NSString == "profile_type")

           {
            
               if form.valuesByKey["\(key)"] is String{
                   if findKeyForValue(form.valuesByKey["\(key)"] as! String) != "" {
                       searchDic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                   }
                   else
                   {
                       if let receiver = value as? NSString {
                           searchDic["\(key)"] = receiver as String
                       }
                       if let receiver = value as? Int {
                           searchDic["\(key)"] = String(receiver)
                       }
                       
                   }
               }
               
               if (key as! NSString  == "type" && serachFor == "coreSearch"){
                   globCoreSearchType = findKeyForValue(form.valuesByKey["\(key)"] as! String)
               }
               }
           else
           {
               
               if let receiver = value as? NSString
               {
                   
                   if key as! String=="showEventType"
                   {
                       let lowercasevalue = (value as AnyObject).lowercased
                       searchDic["\(key)"] = lowercasevalue! as String
                       
                   }
                   else
                   {
                       searchDic["\(key)"] = receiver as String
                       
                       
                       
                   }
                   if (serachFor == "coreSearch" && key as! String == "query") || key as! String == "search"{
                       globSearchString = receiver as String
                   }
               }
               
               if let id = value as? NSNumber
               {
                   searchDic["\(key)"] =  String(describing: id)
               }
           }
       }
       
       
       for (key, value) in form.valuesByKey
       {
           
           if (key as! NSString == "locationmiles")
           {
               Formbackup["locationmiles"] = (searchDic["\(key)"]!)
           }
           
           if (key as! NSString == "search"){
               globFilterValue = searchDic["\(key)"]!
               Formbackup["search"] = searchDic["\(key)"]!
           }
           
           if (key as! NSString == "search_text"){
               globFilterValue = searchDic["\(key)"]!
           }
           
           if (key as! NSString == "query"){
               globFilterValue = searchDic["\(key)"]!
           }
           
           if (key as! NSString == "category_id") || (key as! NSString == "category") {
               category_filterId = Int(searchDic["\(key)"]!)
               // Formbackup["category"] = category_filterId as! String
           }
           
           if (key as! NSString == "type"){
               globalTypeSearch = "\(value)"//searchDic["\(key)"]!
           }
           
           if (key as! NSString == "show")
           {
               Formbackup["show"] = "\(value)"
               showInFilter = "\(value)"
           }
           
           if (key as! NSString == "showEventType")
           {
               showEventType = "\(value)"
           }
           
           if (key as! NSString == "orderBy")
           {

               orderBy = "\(value)"
           }
           
           if (key as! NSString == "orderby")
           {
               Formbackup["orderby"] = "\(value)"
               
           }
           
           if (key as! NSString == "orderby")
           {
               orderby = "\(value)"
           }
           if (key as! NSString == "discount")
           {
               Formbackup["discount"] = "\(value)"
               
           }
           if (key as! NSString == "network_id")
           {
               Formbackup["network_id"] = Int(searchDic["\(key)"]!)
               
           }
           
           if (key as! NSString == "is_online")
           {
               Formbackup["is_online"] = Int(searchDic["\(key)"]!)
               
           }

           if (key as! NSString == "in_stock")
           {
               Formbackup["in_stock"] = "\(value)"
               
           }

           
           if (key as! NSString == "has_photo")
           {
               Formbackup["has_photo"] = Int(searchDic["\(key)"]!)
               
           }
           
           if (key as! NSString == "review")
           {
               Formbackup["review"] = "\(value)"
               
           }
           
           if (key as! NSString == "closed")
           {
               Formbackup["closed"] = "\(value)"
               
           }

           if (key as! NSString == "price")
           {
               Formbackup["price"] = "\(value)"
               
           }

           if (key as! NSString == "min_price")
           {
               Formbackup["min_price"] = "\(value)"
               
           }
           
           if (key as! NSString == "max_price")
           {
               Formbackup["max_price"] = "\(value)"
               
           }

           if (key as! NSString == "minPrice")
           {
               Formbackup["minPrice"] = "\(value)"
               
           }
           if (key as! NSString == "maxPrice")
           {
               Formbackup["maxPrice"] = "\(value)"
               
           }

           
           if (key as! NSString == "event_time")
           {
               event_time = "\(value)"
           }
           
           if (key as! NSString == "venue_name")
           {
               venue_name = "\(value)"
           }
           
           if (key as! NSString == "location")
           {
               location = "\(value)"
               Formbackup["location"] = "\(value)"
           }
           
           if (key as! NSString == "proximity")
           {
               proximity = "\(value)"
           }
           
           if (key as! NSString == "Siteevent_street"){
               Siteevent_street = "\(value)"//searchDic["\(key)"]!
           }
           
           if (key as! NSString == "siteevent_city")
           {
               siteevent_city = "\(value)"
           }
           
           if (key as! NSString == "siteevent_state")
           {
               siteevent_state = "\(value)"
           }
           
           if (key as! NSString == "siteevent_country")
           {
               siteevent_country = "\(value)"
           }
           
           if (key as! NSString == "category_id")
           {
               category_id = "\(value)"
           }
           
           if (key as! NSString == "start_date")
           {
               
               start_date = value as! Date
           }
           
           if (key as! NSString == "end_date")
           {
               
               end_date = value as! Date
           }
           
           if (key as! NSString == "search_diary")
           {
               search_diary = "\(value)"
           }
           
           if (key as! NSString == "member")
           {
               member = "\(value)"
           }
           
           if (key as! NSString == "orderby")
           {
               orderby = "\(value)"
           }
           
           if (key as! NSString == "sitepage_location"){
               Formbackup["sitepage_location"] = "\(value)"
           }
           if (key as! NSString == "sitegroup_location"){
               Formbackup["sitegroup_location"] = "\(value)"
           }

           
           if (key as! NSString == "sitepage_street"){
               Formbackup["sitepage_street"] = "\(value)"
           }
           
           if (key as! NSString == "sitepage_city"){
               Formbackup["sitepage_city"] = "\(value)"
           }
           
           if (key as! NSString == "sitepage_state"){
               Formbackup["sitepage_state"] = "\(value)"
           }
           
           if (key as! NSString == "sitepage_country"){
               Formbackup["sitepage_country"] = searchDic["\(key)"]
           }

       }
    
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
                            searchDic["\(keyName)"] = key as? String
                        }
                    }
                }
                else if let options = dicform["multiOptions"] as? NSArray
                {
                    for value in options
                    {
                        if value as! String == formValue
                        {
                            searchDic["\(keyName)"] = formValue
                        }
                    }
                }
            }
          
        }
    }
      
       if (form.valuesByKey["minPrice"] != nil){
           minimumPrice =  (form.valuesByKey["minPrice"]  as! NSString).integerValue
       }
       if (form.valuesByKey["maxPrice"] != nil){
           maximumPrice =  (form.valuesByKey["maxPrice"] as! NSString).integerValue
       }
       if minimumPrice != 0 && maximumPrice != 0{
       if minimumPrice > maximumPrice{
           error = NSLocalizedString("Maximum Price should be greater than Minimum Price.", comment: "")

           
       }
   }
       if serachFor != nil && serachFor == "coreSearch"{
           redirectToContentSearch()
       }else{

           if error != ""{
               let alertController = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
               alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
               self.present(alertController, animated: true, completion: nil)
           }
           else{
           _ = navigationController?.popViewController(animated: true)
           }

       }
       
   }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    //function called when some action is defined in element creation
    func fieldValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        
        if contentType == "members"{
            
            if form.valuesByKey["advanced_search"] as! Bool == false
            {
                findOptionalFormIndex("members", option: 2)
            }
            else
            {
                findOptionalFormIndex("members", option: 1)
            }
        }
        
        
        self.formController.tableView.reloadData()
    }
    
    
    func storeCategoryValueChanged(_ cell: FXFormFieldCellProtocol)
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
            
            if name == "category_id"
            {
                index = i;
            }
            
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        
        if (form.valuesByKey["category_id"] != nil)
        {
            
            if let option = categoryDicFilter["multiOptions"] as? NSDictionary
            {
                
                let categoryvalue = form.valuesByKey["category_id"] as! String
                for (key, value) in option
                {
                    
                    if categoryvalue == value as! String
                    {
                        if let subDic = subCategoryDicFilter["\(key)"] as? NSDictionary
                        {
                            subsubDic = subDic
                            if !isCreateOrEdit
                            {
                                tempformValue["category_id"] = "\(key)"
                                tempformValue.removeObject(forKey: "subcategory_id")
                                tempformValue.removeObject(forKey:"subsubcategory_id")
                                formValue = tempformValue
                            }
                            
                            if let formDic = subDic["form"] as? NSDictionary
                            {
                                index += 1
                                Form.insert(formDic, at: index)
                                tempCategArray = Form
                                
                            }
                            if flag == false{
                                if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                                {
                                    flag = true
                                    for dic in feildtoaddArray
                                    {
                                        index += 1
                                        Form.insert(dic as Any as AnyObject, at: index)
                                    }
                                }
                            }
                            
                        }
                        defaultCategory = "\(value)"
                        // findOptionalFormIndexforcategory("advancedevents", option: 2)
                        
                    }
                }
            }
            else if let option = categoryDicFilter["multiOptions"] as? NSArray
            {
                
                let categoryvalue = form.valuesByKey["category_id"] as! String
                for (key, value) in option.enumerated()
                {
                    
                    if categoryvalue == value as! String
                    {
                        if let subDic = subCategoryDicFilter["\(key)"] as? NSDictionary
                        {
                            subsubDic = subDic
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
                                tempCategArray = Form
                                
                            }
                            if flag == false{
                                if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                                {
                                    flag = true
                                    for dic in feildtoaddArray
                                    {
                                        index += 1
                                        Form.insert(dic as AnyObject, at: index)
                                    }
                                }
                            }
                            
                        }
                        defaultCategory = "\(value)"
                    }
                }
            }
        }
        
        FormforRepeat = Form
        
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func storeSubCategoryValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        subsubFlag = false
        let form = cell.field.form as! CreateNewForm
        if  subFlag == true{
            subFlag = false
            flag = false
            Form = tempCategArray
        }
        
        defaultsubsubCategory = ""
        
        var index1 = Int()
        for i in 0 ..< Form.count
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
                                    clicksubsubDic = formsubDic
                                    
                                    index1 += 1
                                    Form.insert(formsubDic, at: index1)
                                    
                                }
                            }
                            
                            if flag == false{
                                if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                                {
                                    flag = true
                                    subFlag = true
                                    for dic in feildtoaddArray
                                    {
                                        index1 += 1
                                        Form.insert(dic as Any as AnyObject, at: index1)
                                        
                                    }
                                }
                            }
                            defaultsubCategory = "\(value)"
                            
                        }
                    }
                }
            }
        }
        
        FormforRepeat = Form
        
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func storeSubSubCategoryValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        
        if  subsubFlag == true{
            subsubFlag = false
            flag = false
            Form = tempCategArray
        }
        
        var index2 = Int()
        for i in 0 ..< Form.count
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
        
        if (form.valuesByKey["subsubcategory_id"] != nil)
        {
            
            if let option = clicksubsubDic["multiOptions"] as? NSDictionary
            {
                let subsubcategoryvalue = form.valuesByKey["subsubcategory_id"] as! String
                for (key, value) in option
                {
                    
                    if subsubcategoryvalue == value as! String
                    {
                        if flag == false{
                            if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                            {
                                flag = true
                                subFlag = true
                                subsubFlag = true
                                for dic in feildtoaddArray
                                {
                                    index2 += 1
                                    Form.insert(dic as Any as AnyObject, at: index2)
                                }
                            }
                        }
                        
                        defaultsubsubCategory = "\(value)"
                        // findOptionalFormIndexforcategory("advancedevents", option: 11)
                        
                    }
                }
                
            }
        }
        
        FormforRepeat = Form
        
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    func redirectToContentSearch(){
        
        if let moduleContentType = searchDic["type"]{
            var module = moduleContentType
            if module == "0"{
                module = ""
            }
            var shouldRedirect = true
            var presentedVC:UIViewController!
            
            if let searchText = searchDic["query"]{
                globFilterValue = searchText
                
                if searchDic["search"] == nil{
                    searchDic.updateValue("\(searchText)", forKey: "search")
                }
            }
            
            var listingBrowseType = "0"
            var listingViewType = "0"
            var tempListingTypeId = 0
            let tempModuleContentType = moduleContentType.components(separatedBy: "_")
            if tempModuleContentType.count > 1 && tempModuleContentType[0] == "sitereview"{
                tempListingTypeId = Int(tempModuleContentType[1])!
                if tempListingTypeId != 0{
                    if let listingViewArr = listingBrowseViewTypeArr[tempListingTypeId]{
                        listingBrowseType = String(listingViewArr["browseType"]!)
                        listingViewType = String(listingViewArr["viewType"]!)
                        module = listingBrowseType
                    }
                }
            }
            
            
            
            switch(module){

            case "blog":
                presentedVC = BlogSearchViewController()
                globalCatg = ""
                loadFilter("blogs/search-form")
                break
            case "classified":
                presentedVC = ClassifiedSearchViewController()
                globalCatg = ""
                loadFilter("classifieds/search-form")
                break
            case "event":
                presentedVC = EventSearchViewController()
                globalCatg = ""
                loadFilter("events/search-form")
                break
            case "group":
                presentedVC = GroupSearchViewController()
                globalCatg = ""
                loadFilter("groups/search-form")
                break
            case "poll":
                presentedVC = PollSearchViewController()
                globalCatg = ""
                loadFilter("polls/search-form")
                break
            case "siteevent":
                presentedVC = AdvancedEventSearchViewController()
                (presentedVC as! AdvancedEventSearchViewController).eventBrowseType = 0
                globalCatg = ""
                loadFilter("advancedevents/search-form")
                break
            case "sitepage":
                presentedVC = PageSearchViewController()
                globalCatg = ""
                Formbackup.removeAllObjects()
                loadFilter("sitepages/search-form")
                break
            case "user":
                presentedVC = MemberSearchViewController()
                (presentedVC as! MemberSearchViewController).contentType = "members"
                break
            case "video":
                presentedVC = VideoSearchViewController()
                (presentedVC as! VideoSearchViewController).searchPath = "videos/browse"
                globalCatg = ""
                loadFilter("videos/browse-search-form")
                break
            case "siteevent_video":
                presentedVC = VideoSearchViewController()
                globalCatg = ""
                loadFilter("videos/search-form")
                break
            case "album":
                presentedVC = AlbumSearchViewController()
                loadFilter("albums/search-form")
                break

                case "sitestore":
                presentedVC = StoresSearchResultsViewController()
                (presentedVC as! StoresSearchResultsViewController).storesSearchName = NSLocalizedString("Stores", comment: "")
                globalCatg = ""
                loadFilter("sitestore/search-form")
                break
            case "sitegroup":
                presentedVC = AdvancedGroupSearchViewController()
                globalCatg = ""
                Formbackup.removeAllObjects()
                loadFilter("advancedgroups/search-form")
                break
    

            case "0":
                presentedVC = MLTSearchListViewController()
                globalCatg = ""
                (presentedVC as! MLTSearchListViewController).listingTypeId  = tempListingTypeId
                (presentedVC as! MLTSearchListViewController).viewSearchType = Int(listingViewType)

                Formbackup.removeAllObjects()
                globalCatg = ""
                listingGlobalTypeId = tempListingTypeId
                loadFilter("listings/search-form")

                break
            case "1":
                
                presentedVC = MLTSearchGridViewController()
                (presentedVC as! MLTSearchGridViewController).listingTypeId = tempListingTypeId
                (presentedVC as! MLTSearchGridViewController).viewSearchType = Int(listingViewType)
                //presentedVC.listingSearchName = listingName
                Formbackup.removeAllObjects()
                globalCatg = ""
                listingGlobalTypeId = tempListingTypeId
                loadFilter("listings/search-form")
                break
            case "2":
                presentedVC = MLTSearchMatrixViewController()
                (presentedVC as! MLTSearchMatrixViewController).listingTypeId = tempListingTypeId
                (presentedVC as! MLTSearchMatrixViewController).viewSearchType = Int(listingViewType)
                //presentedVC.listingSearchName = listingName
                globalCatg = ""
                listingGlobalTypeId = tempListingTypeId
                Formbackup.removeAllObjects()
                loadFilter("listings/search-form")
                break
                
            case "sitevideo_video":
                presentedVC = AdvancedVideoSearchViewController()
                (presentedVC as! AdvancedVideoSearchViewController).searchPath = "advancedvideos/browse"
                globalCatg = ""
                loadFilter("advancedvideos/search-form")
                break
                
            case "sitevideo_channel":
                presentedVC = ChannelSearchViewController()
                (presentedVC as! ChannelSearchViewController).searchPath = "advancedvideos/channel/browse"
                globalCatg = ""
                loadFilter("advancedvideos/channel/search-form")
                break
                
            case "sitevideo_playlist":
                presentedVC = PlaylistSearchViewController()
                (presentedVC as! PlaylistSearchViewController).searchPath = "advancedvideos/playlist/browse"
                globalCatg = ""
                loadFilter("advancedvideo/playlist/search-form")
                break
                
            default:
                shouldRedirect = false

                break
            }
            
            if shouldRedirect{
                globalTypeSearch = ""
                updateAfterAlert = true
                fromGlobSearch = true
                navigationController?.pushViewController(presentedVC, animated: false)
            }else{
                fromGlobSearch = false
                _ = navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    @objc func toGlobalSearch(){
        let navArray = self.navigationController?.viewControllers
        for tempViewController in navArray!{
            if tempViewController is FilterSearchViewController{
                conditionalForm = "coreSearch"
                (tempViewController as! FilterSearchViewController).contentType = "SearchHome"
                globCoreSearchType = "0"
                fromGlobSearch = false
                filterSearchFormArray.removeAll()
                (tempViewController as! FilterSearchViewController).searchUrl = "search"
                _ = self.navigationController?.popToViewController(tempViewController, animated: true)
            }
        }
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
    }
    
    func isReloadForm(reload: Bool)
    {
        self.reloadForm = reload
    }
    
    func sendLocationParam(locationParam: [String : Any])
    {
        //Not required for Now
    }

    
}
