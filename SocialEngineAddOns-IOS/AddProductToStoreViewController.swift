//
//  AddProductToStoreViewController.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 27/02/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import Foundation

var bundledProductTypes :  NSDictionary = [:]
var weightTypeFixed : NSDictionary = [:]
var productIdReturned : Int!
var bundledGroupedProducts : String! = ""
var buildQString : String = ""
@objcMembers class AddProductToStoreViewController : FXFormViewController
{
    var popAfterDelay:Bool!
    var fieldsArray = [AnyObject]()
    var optionsArray = [AnyObject]()
    var index = Int()
    var backupForm = [AnyObject]()
    var leftBarButtonItem: UIBarButtonItem!
    var productType : String!
    var storeId : String!
    var password : String!
    var contentType : String!
    var url : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AddProductToStoreViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        mediaType = "image"
        
        //print(self.storeId!)
        //print(self.productType!)
        
        popAfterDelay = false
        if self.contentType == "addProduct"
        {
            self.title = NSLocalizedString("Add Product", comment: "")
        }
        else
        {
            self.title = NSLocalizedString("Edit Product", comment: "")
        }
        conditionalForm  = self.contentType
        conditionForm = self.contentType
        //isCreateOrEdit = true
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
        generateShippingMethodForm()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
        Form = backupForm
        if self.productType == "grouped"
        {
            
            let indexPath = IndexPath(item: 2, section: 0)
            if indexPath.section < self.formController.tableView.numberOfSections
            {
                if indexPath.row < self.formController.tableView.numberOfRows(inSection: indexPath.section)
                {
                    self.formController.form = CreateNewForm()
                    self.formController.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
            //self.formController.tableView.reloadData()
        }
        else if self.productType == "bundled"
        {
            
            let indexPath = IndexPath(item: 6, section: 0)
            if indexPath.section < self.formController.tableView.numberOfSections
            {
                if indexPath.row < self.formController.tableView.numberOfRows(inSection: indexPath.section)
                {
                    self.formController.form = CreateNewForm()
                    self.formController.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
            //self.formController.tableView.reloadData()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        backupForm = Form
    }
    
    func holdValues(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        for (key2,_) in form.valuesByKey
        {
            Formbackup["\(key2)"] = form.valuesByKey["\(key2)"]
        }
        
    }
    
    func submitForm(_ cell: FXFormFieldCellProtocol)
    {
        
        
        removeAlert()
        //let indexpath = NSIndexPath(row: 0, section: 0)
        
        self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
        //we can lookup the form from the cell if we want, like this:
        let form = cell.field.form as! CreateNewForm
        var error = ""
        var errorTitle = "Error"
        // Getting image
        
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if(form.valuesByKey["\(name)"] == nil)
            {
                form.valuesByKey["\(name)"] = Formbackup["\(name)"]
            }
        }
        
        if ( self.contentType == "addProduct")
        {
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
        }
        
        
//        for (key, value) in Formbackup
//        {
//            form.valuesByKey["\(key)"] = "\(value)"
//        }
        
        if (self.contentType == "addProduct")
        {
            if ( (form.valuesByKey["title"] == nil) || (form.valuesByKey["title"] as! String == "") )
            {
                errorTitle = NSLocalizedString("Title of Product!", comment: "")
                error = NSLocalizedString("Please enter the title of the product!", comment: "")
            }
            else if ( (form.valuesByKey["product_code"] == nil) || (form.valuesByKey["product_code"] as! String == "") )
            {
                errorTitle = NSLocalizedString("Product SKU!", comment: "")
                error = NSLocalizedString("Please enter Product SKU", comment: "")
            }

            else if ( (form.valuesByKey["category_id"] == nil) || (form.valuesByKey["category_id"] as! String == "") )
            {
                errorTitle = NSLocalizedString("Product category!", comment: "")
                error = NSLocalizedString("Please select a category of the product!", comment: "")
            }
            else if ( (form.valuesByKey["body"] == nil) || (form.valuesByKey["body"] as! String == "") )
            {
                errorTitle = NSLocalizedString("Short Description!", comment: "")
                error = NSLocalizedString("Please enter a short description of the product!", comment: "")
            }
        }
        else if (self.contentType != "editProduct")
        {
            if ( (form.valuesByKey["photo"] == nil) || (form.valuesByKey["photo"] as? UIImage == nil) )
            {
                errorTitle = NSLocalizedString("Product Photo!", comment: "")
                error = NSLocalizedString("Please select a photo of the product!", comment: "")
            }
        }
        if error != ""{
            
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
                var infoDic = Dictionary<String, String>()
                //Get MultiCheckBox Value in comma seperated way
                print(form.valuesByKey)
                
                
                
                for (key, value) in form.valuesByKey
                {
                    let conditionArray:[String] = ["category_id","auth_invite","draft","auth_view","auth_comment","type","subcategory_id","subsubcategory_id","auth_post","auth_topic","auth_photo","auth_video","spcreate","svcreate","secreate","sdicreate","sdcreate","splcreate","sncreate","smcreate","stock_unlimited","discount","end_date_enable","discount_permanant","user_type","out_of_stock","out_of_stock_action","handling_type"]
                    
                    
                    //
                    //,"repeat_week","repeat_weekday","repeat_month","repeat_interval"
                    if conditionArray.contains(key as! String)
                    {
                        if let _ = value as? NSString {
                            infoDic["\(key)"] = findKeyForValue2(form.valuesByKey["\(key)"] as! String,keyName: key as! String)
                        }
                        if let receiver = value as? Int
                        {
                            infoDic["\(key)"] = String(receiver) //findKeyForValue(form.valuesByKey["\(key)"] as! String)
                        }
                    }
                    else
                    {
                        if let receiver = value as? NSString {
                            infoDic["\(key)"] = receiver as String
                        }
                        if let receiver = value as? Int {
                            infoDic["\(key)"] = String(receiver)
                        }
                        if let receiver = value as? Date {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
                            infoDic["\(key)"] = dateFormatter.string(from: receiver)
                        }
                        if let receiver = value as? URL {
                            infoDic["\(key)"] = "\(receiver)"
                        }
                        
                    }
                    
                }
                
                var dic = Dictionary<String, String>()
                dic["store_id"] = self.storeId
                dic["product_type"] = self.productType
                
                
                var method = "POST"
                if isCreateOrEdit
                {
                    method = "POST"
                }
                else
                {
                    method = "POST"
                }
                dic.update(infoDic)
                
                

                let singlePhoto = true
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
                if self.productType == "bundled" || self.productType == "grouped"
                {
                    print(suggestedProducts)
                    print(suggestedProductsIds)
                    
                     var productIds : String = ""
                     for products in suggestedProductsIds
                     {
                     productIds += products+","
                     }
                     if productIds.length > 0
                     {
                     productIds = productIds.substring(to: productIds.index(before: productIds.endIndex))
                     }
                    
                    dic["product_ids"] = productIds
                    print(dic["product_ids"]!)
                }
                if self.productType == "bundled"
                {
                    buildQString = "bundled"
                }
                dic.removeValue(forKey: "product_search")
                print(dic)
                if self.contentType == "editProduct"
                {
                    if dic["discount"] as! String == "discount_0"
                    {
                        dic["discount_permanant"] = "discount_permanant_1"
                    }
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
                                
                                if(self.contentType == "addProduct")
                                {
                                    showToast(message: NSLocalizedString("Your Product has been created successfully.", comment: ""), controller: self, onView: false)
                                }
                                else
                                {
                                    
                                    showToast(message: String(format: NSLocalizedString("Product has been edited successfully.", comment: ""), self.contentType), controller: self, onView: false)
                                    
                                }
                                if let dic = succeeded["body"] as? NSDictionary
                                {
                                    if let responseDic = dic["response"] as? NSDictionary
                                    {
                                        if let productId = responseDic["product_id"] as? Int
                                        {
                                            productIdReturned = productId
                                        }
                                    }
                                }
                                self.createTimer(self)
                                
                                //self.popAfterDelay = true
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
                                if self.contentType == "editProduct"
                                {
                                    self.popAfterDelay = true
                                }
                                else
                                {
                                    conditionalProfileForm = "browseProduct"
                                    self.dismiss(animated: false, completion: nil)
                                    
                                    //let pv = ProductProfilePage()
                                    //pv.product_id = productIdReturned
                                    //self.navigationController?.pushViewController(pv, animated: false)
                                    
                                    //SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id:productIdReturned!)
                                }
                                
                                
                            }
                            else
                            {
                                self.view.isUserInteractionEnabled = true
                                self.view.alpha = 1.0
                                if self.contentType == "Page" || self.contentType == "Review" || self.contentType == "sitegroup" || self.contentType == "Channel"
                                {
                                    showToast(message: succeeded["message"] as! String, controller: self, onView: false)
                                }
                                else
                                {
                                    if succeeded["message"] != nil
                                    {
                                        let msg = succeeded["message"] as! String
                                        showToast(message: msg, controller: self, onView: false)
                                    }
                                    else
                                    {
                                        showToast(message: unconditionalMessage, controller: self, onView: false)
                                    }
                                }
                            }
                            
                        })
                    }
            }
            else
            {
                // No Internet Connection Message
                showToast(message: network_status_msg, controller: self, onView: false)
            }
            
        }
    }
    
    
    
    @objc func goBack()
    {
        suggestedProductsIds.removeAll(keepingCapacity: false)
        suggestedProducts.removeAll(keepingCapacity: false)
        productLabels.removeAll(keepingCapacity: false)
        labelCancelButtons.removeAll(keepingCapacity: false)
        labelHeight = 5
        labelWidth = 10
        contentSizeHeight = 0
        _ = self.dismiss(animated: false, completion: nil)
        //_ = self.navigationController?.popViewController(animated: false)
    }
    
    func generateShippingMethodForm()
    {
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            //Set Parameters & path for Adding new Shipping Method
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            if conditionalForm == "addProduct"
            {
                parameter["product_type"] = self.productType!
                parameter["store_id"] = self.storeId!
                path = "sitestore/product/create"
            }
            else if conditionalForm == "editProduct"
            {
                path = self.url
            }
            print(path)
            
            // Send Server Request for Sign Up Form
            post(parameter, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Add Value to Form Array & Values to formValue Array
                        Form.removeAll(keepingCapacity: false)
                        Formbackup.removeAllObjects()
                        suggestedProducts.removeAll(keepingCapacity: false)
                        suggestedProductsIds.removeAll(keepingCapacity: false)
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if let dic = succeeded["body"] as? NSDictionary
                        {
                            if let formarr = dic["form"] as? NSArray
                            {
                                Form = formarr as [AnyObject]
                                tempFormArray = formarr as [AnyObject]
                            }
                            if let fieldDic = dic["fields"] as? NSDictionary
                            {
                                fieldsDic = fieldDic
                            }
                            
                            if let catdic = dic["subcategories"] as? NSDictionary
                            {
                                
                                subcategoryDic = catdic
                            }
                            
                            if let formvalues = dic["formValues"] as? NSDictionary
                            {
                                formValue = formvalues
                                if let productsNames = formvalues["product_ids"] as? NSArray
                                {
                                    var j : Int = 0
                                    while j < productsNames.count
                                    {
                                        let newDic = productsNames[j] as? NSDictionary
                                        let productname = newDic!["title"] as! String
                                        bundledGroupedProducts = bundledGroupedProducts+productname+","
                                        j = j+1
                                    }
                                }
                                if let storeid = formvalues["store_id"] as? Int
                                {
                                    let stringStoreId = String(storeid)
                                    self.storeId = stringStoreId
                                }
                                
                                
                            }
                            
                            for key in Form
                            {
                                // Create element Dictionary for every FXForm Element
                                
                                if let dic = (key as? NSDictionary)
                                {
                                    if dic["name"] as? String == "category_id"
                                    {
                                        categoryDic = dic
                                    }
                                    else if dic["name"] as? String == "bundle_product_type"
                                    {
                                        bundledProductTypes = dic["multiOptions"] as! NSDictionary
                                    }
                                    else if dic["name"] as? String == "weight"
                                    {
                                        weightTypeFixed = dic
                                    }
                                    
                                }
                            }
                            for i in 0 ..< (Form.count) where i < Form.count
                            {
                                let formDic = Form[i] as! NSDictionary
                                let name = formDic["name"] as! String
                                if name == "weight"
                                {
                                    Form.remove(at: i)
                                }
                                
                            }
                            if self.contentType == "editProduct"
                            {
                                var index = Int()
                                var disIndex = Int()
                                var stockIndex = Int()
                                var endIndex = Int()
                                var disTypeIndex = Int()
                                var disEndIndex = Int()
                                
                                for i in 0 ..< (Form.count) where i < Form.count
                                {
                                    let formDic = Form[i] as! NSDictionary
                                    let name = formDic["name"] as! String
                                    if name == "category_id"
                                    {
                                        index = i
                                    }
                                    
                                }
                                
                                let catgValue = formValue["category_id"] as! Int
                                print(catgValue)
                                let catgStringValue = String(describing: catgValue)
                                print(catgStringValue)
                                
                                let subDic = subcategoryDic[catgStringValue] as! NSDictionary
                                let mainSubDic = subDic["form"] as! NSDictionary
                                index += 1
                                Form.insert(mainSubDic, at: index)
                                
                                for ( key, _ ) in fieldsDic
                                {
                                    if key as! String == catgStringValue
                                    {
                                        
                                        let ndic = fieldsDic[key] as! NSArray
                                        for i in 0 ..< ndic.count
                                        {
                                            index += 1
                                            let dic = ndic[i] as! NSDictionary
                                            Form.insert(dic as AnyObject, at: index)
                                        }
                                    }
                                }
                                
                                for i in 0 ..< (Form.count) where i < Form.count
                                {
                                    let formDic = Form[i] as! NSDictionary
                                    let name = formDic["name"] as! String
                                    if name == "discount"
                                    {
                                        disIndex = i
                                    }
                                }
                                
                                if formValue["discount"] != nil
                                {
                                    
                                    if let discount = formValue["discount"] as? String
                                    {
                                      if discount == "discount_1"
                                      {
                                        if let discountDic = fieldsDic["discount_1"] as? NSArray
                                        {
                                            for i in 0 ..< discountDic.count
                                            {
                                                disIndex += 1
                                                let dic = discountDic[i] as! NSDictionary
                                                Form.insert(dic, at: disIndex)
                                            }
                                            
                                        }
                                      }
                                    }
                                    else if let discount = formValue["discount"] as? Int
                                    {
                                       if discount == 1
                                       {
                                            if let discountDic = fieldsDic["discount_1"] as? NSArray
                                            {
                                                for i in 0 ..< discountDic.count
                                                {
                                                    disIndex += 1
                                                    let dic = discountDic[i] as! NSDictionary
                                                    Form.insert(dic, at: disIndex)
                                                }
                                                
                                            }
                                       }
                                    }
                                }
                                
                                for i in 0 ..< (Form.count) where i < Form.count
                                {
                                    let formDic = Form[i] as! NSDictionary
                                    let name = formDic["name"] as! String
                                    if name == "discount_permanant"
                                    {
                                        disEndIndex = i
                                    }
                                }
                                
                                if formValue["discount_permanant"] != nil
                                {
                                    if let discountEndDate = formValue["discount_permanant"] as? String
                                    {
                                        if discountEndDate == "discount_permanant_0"
                                        {
                                            if let disEndDate = fieldsDic["discount_permanant_0"] as? NSArray
                                            {
                                                for i in 0 ..< disEndDate.count
                                                {
                                                    disEndIndex += 1
                                                    let dic = disEndDate[i] as! NSDictionary
                                                    Form.insert(dic, at: disEndIndex)
                                                }
                                            }
                                        }
                                    }
                                    else if let discountEndDate = formValue["discount_permanant"] as? Int
                                    {
                                        if discountEndDate == 1
                                        {
                                            if let disEndDate = fieldsDic["discount_permanant_0"] as? NSArray
                                            {
                                                for i in 0 ..< disEndDate.count
                                                {
                                                    disEndIndex += 1
                                                    let dic = disEndDate[i] as! NSDictionary
                                                    Form.insert(dic, at: disEndIndex)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                
                                for i in 0 ..< (Form.count) where i < Form.count
                                {
                                    let formDic = Form[i] as! NSDictionary
                                    let name = formDic["name"] as! String
                                    if name == "stock_unlimited"
                                    {
                                        stockIndex = i
                                    }
                                }
                                
                                if formValue["stock_unlimited"] != nil
                                {
                                    if let stockUnlimited = formValue["stock_unlimited"] as? String
                                    {
                                        if stockUnlimited == "stock_unlimited_0"
                                        {
                                            if let stockDic = fieldsDic["stock_unlimited_0"] as? NSArray
                                            {
                                                for i in 0 ..< stockDic.count
                                                {
                                                    
                                                    stockIndex += 1
                                                    let dic = stockDic[i] as! NSDictionary
                                                    Form.insert(dic, at: stockIndex)
                                                }
                                            }
                                        }
                                        
                                    }
                                    else if let stockUnlimited = formValue["stock_unlimited"] as? Int
                                    {
                                        if stockUnlimited == 0
                                        {
                                            if let stockDic = fieldsDic["stock_unlimited_0"] as? NSArray
                                            {
                                                for i in 0 ..< stockDic.count
                                                {
                                                    
                                                    stockIndex += 1
                                                    let dic = stockDic[i] as! NSDictionary
                                                    Form.insert(dic, at: stockIndex)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                for i in 0 ..< (Form.count) where i < Form.count
                                {
                                    let formDic = Form[i] as! NSDictionary
                                    let name = formDic["name"] as! String
                                    if name == "end_date_enable"
                                    {
                                        endIndex = i
                                    }
                                }
                                
                                if formValue["end_date_enable"] != nil
                                {
                                    if let endDateEnable = formValue["end_date_enable"] as? String
                                    {
                                        if endDateEnable == "end_date_enable_1"
                                        {
                                            if let endDic = fieldsDic["end_date_enable_1"] as? NSArray
                                            {
                                                for i in 0 ..< endDic.count
                                                {
                                                    
                                                    endIndex += 1
                                                    let dic = endDic[i] as! NSDictionary
                                                    Form.insert(dic, at: endIndex)
                                                }
                                            }
                                        }
                                    }
                                    else if let endDateEnable = formValue["end_date_enable"] as? Int
                                    {
                                        if endDateEnable == 1
                                        {
                                            if let endDic = fieldsDic["end_date_enable_1"] as? NSArray
                                            {
                                                for i in 0 ..< endDic.count
                                                {
                                                    
                                                    endIndex += 1
                                                    let dic = endDic[i] as! NSDictionary
                                                    Form.insert(dic, at: endIndex)
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                for i in 0 ..< (Form.count) where i < Form.count
                                {
                                    let formDic = Form[i] as! NSDictionary
                                    let name = formDic["name"] as! String
                                    if name == "handling_type"
                                    {
                                        disTypeIndex = i
                                    }
                                }
                                
                                if formValue["handling_type"] != nil
                                {
                                    if let handlingType = formValue["handling_type"] as? String
                                    {
                                        if handlingType == "fixed_0"
                                        {
                                           if let disTypeDic = fieldsDic["fixed_0"] as? NSArray
                                           {
                                                for i in 0 ..< disTypeDic.count
                                                {
                                                    
                                                    disTypeIndex += 1
                                                    let dic = disTypeDic[i] as! NSDictionary
                                                    Form.insert(dic, at: disTypeIndex)
                                                }
                                            }
                                        }
                                        else if handlingType == "percent_0"
                                        {
                                            if let disTypeDic = fieldsDic["percent_0"] as? NSArray
                                            {
                                                for i in 0 ..< disTypeDic.count
                                                {
                                                    
                                                    disTypeIndex += 1
                                                    let dic = disTypeDic[i] as! NSDictionary
                                                    Form.insert(dic, at: disTypeIndex)
                                                }
                                            }
                                        }
                                    }
                                    else if let handlingType = formValue["handling_type"] as? Int
                                    {
                                        if handlingType == 0
                                        {
                                            if let disTypeDic = fieldsDic["fixed_0"] as? NSArray
                                            {
                                                for i in 0 ..< disTypeDic.count
                                                {
                                                    
                                                    disTypeIndex += 1
                                                    let dic = disTypeDic[i] as! NSDictionary
                                                    Form.insert(dic, at: disTypeIndex)
                                                }
                                            }
                                        }
                                        else if handlingType == 1
                                        {
                                            if let disTypeDic = fieldsDic["percent_0"] as? NSArray
                                            {
                                                for i in 0 ..< disTypeDic.count
                                                {
                                                    
                                                    disTypeIndex += 1
                                                    let dic = disTypeDic[i] as! NSDictionary
                                                    Form.insert(dic, at: disTypeIndex)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        tempFormArray = Form
                        // Create FXForm Form
                        //print(Form)
                        self.formController.form = CreateNewForm()
                        self.formController.tableView.reloadData()
                    }
                    else
                    {
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
            
        }
    }
    
    func listingCategoryValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        if temp7CategArray.count > 0
        {
            Form = temp7CategArray
        }
        else if temp6CategArray.count > 0
        {
            Form = temp6CategArray
        }
        else if temp5CategArray.count > 0
        {
            Form = temp5CategArray
        }
        else if temp4CategArray.count > 0
        {
            Form = temp4CategArray
        }
        else if tempTempTempCategArray.count > 0
        {
            Form = tempTempTempCategArray
        }
        else if tempTempCategArray.count > 0
        {
            Form = tempTempCategArray
        }
        else if tempCategArray.count > 0
        {
            Form = tempCategArray
        }
        else
        {
            Form = tempFormArray
        }
        //Form = tempFormArray
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
                                
                            }
                            if let feildtoaddArray = fieldsDic["\(key)"] as? NSArray
                            {
                                for dic in feildtoaddArray
                                {
                                    index += 1
                                    Form.insert(dic as AnyObject, at: index)
                                    
                                }
                                
                            }
                            tempFormArray = Form
                        }
                        //defaultCategory = "\(value)"
                        //findOptionalFormIndexforcategory("advancedevents", option: 2)
                        
                    }
                    
                    
                }
                
                
            }
        }
        FormforRepeat = Form
        
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func bundledProductWeightType(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "weight_type"
            {
                index = i;
            }
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
            if ( name == "weight")
            {
                Form.remove(at: j)
                j = j-1
            }
            else
            {
                j = j+1
            }
            
        }
        
        if (form.valuesByKey["weight_type"] != nil)
        {
            
            if form.valuesByKey["weight_type"] as! String == "Fixed Weight"
            {
                index += 1
                Form.insert(weightTypeFixed as AnyObject, at: index)
                tempFormArray = Form
            }
            
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
        
        
        
    }
    
    func productDiscountEnable(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        if temp7CategArray.count > 0
        {
            Form = temp7CategArray
        }
        else if temp6CategArray.count > 0
        {
            Form = temp6CategArray
        }
        else if temp5CategArray.count > 0
        {
            Form = temp5CategArray
        }
        else if temp4CategArray.count > 0
        {
            Form = temp4CategArray
        }
        else if tempTempTempCategArray.count > 0
        {
            Form = tempTempTempCategArray
        }
        else if tempTempCategArray.count > 0
        {
            Form = tempTempCategArray
        }
        else if tempCategArray.count > 0
        {
            Form = tempCategArray
        }
        else
        {
            Form = tempFormArray
        }
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "discount"
            {
                index = i;
            }
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
            if ( name == "handling_type" || name == "discount_start_date" || name == "discount_permanant" || name == "user_type" || name == "discount_price" || name == "discount_rate" || name == "discount_end_date" )
            {
                Form.remove(at: j)
                j = j-1
            }
            else
            {
                j = j+1
            }
            
        }

        if (form.valuesByKey["discount"] != nil)
        {
            
            if form.valuesByKey["discount"] as! String == "Yes"
            {
                let ndic = fieldsDic["discount_1"] as! NSArray
                for i in 0 ..< ndic.count
                {
                    index += 1
                    let dic = ndic[i] as! NSDictionary
                    Form.insert(dic as AnyObject, at: index)
                }
                //tempFormArray = Form
                tempTempCategArray = Form
                //tempCategArray = Form
            }
            
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
        
    }
    
    func discountTypeValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        if temp7CategArray.count > 0
        {
            Form = temp7CategArray
        }
        else if temp6CategArray.count > 0
        {
            Form = temp6CategArray
        }
        else if temp5CategArray.count > 0
        {
            Form = temp5CategArray
        }
        else if temp4CategArray.count > 0
        {
            Form = temp4CategArray
        }
        else if tempTempTempCategArray.count > 0
        {
            Form = tempTempTempCategArray
        }
        else if tempTempCategArray.count > 0
        {
            Form = tempTempCategArray
        }
        else if tempCategArray.count > 0
        {
            Form = tempCategArray
        }
        else
        {
            Form = tempFormArray
        }
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "handling_type"
            {
                index = i;
            }
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
            if ( name == "discount_price" || name == "discount_rate" )
            {
                Form.remove(at: j)
                j = j-1
            }
            else
            {
                j = j+1
            }
            
        }

        
        if (form.valuesByKey["handling_type"] != nil)
        {
            
            if form.valuesByKey["handling_type"] as! String == "Fixed"
            {
                let ndic = fieldsDic["fixed_0"] as! NSArray
                 for i in 0 ..< ndic.count
                 {
                 index += 1
                 let dic = ndic[i] as! NSDictionary
                 Form.insert(dic as AnyObject, at: index)
                 }
                //tempFormArray = Form
                 tempTempTempCategArray = Form
                 //tempTempCategArray = Form
                 //tempCategArray = Form
            }
            
            if form.valuesByKey["handling_type"] as! String == "Percent"
            {
                
                let ndic = fieldsDic["percent_0"] as! NSArray
                for i in 0 ..< ndic.count
                {
                    index += 1
                    let dic = ndic[i] as! NSDictionary
                    Form.insert(dic as AnyObject, at: index)
                }
                //tempFormArray = Form
                tempTempTempCategArray = Form
                //tempTempCategArray = Form
                //tempCategArray = Form
            }
            
        }

        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
        
    }
    
    func discountEndDateChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        if temp7CategArray.count > 0
        {
            Form = temp7CategArray
        }
        else if temp6CategArray.count > 0
        {
            Form = temp6CategArray
        }
        else if temp5CategArray.count > 0
        {
            Form = temp5CategArray
        }
        else if temp4CategArray.count > 0
        {
            Form = temp4CategArray
        }
        else if tempTempTempCategArray.count > 0
        {
            Form = tempTempTempCategArray
        }
        else if tempTempCategArray.count > 0
        {
            Form = tempTempCategArray
        }
        else if tempCategArray.count > 0
        {
            Form = tempCategArray
        }
        else
        {
            Form = tempFormArray
        }
        //Form = tempCategArray
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "discount_permanant"
            {
                index = i;
            }
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
            if ( name == "discount_end_date" )
            {
                Form.remove(at: j)
                j = j-1
            }
            else
            {
                j = j+1
            }
            
        }
        
        if (form.valuesByKey["discount_permanant"] != nil)
        {
            
            if form.valuesByKey["discount_permanant"] as! String != "No end date."
            {
                let ndic = fieldsDic["discount_permanant_0"] as! NSArray
                for i in 0 ..< ndic.count
                {
                    index += 1
                    let dic = ndic[i] as! NSDictionary
                    Form.insert(dic as AnyObject, at: index)
                }
                //tempFormArray = Form
                temp4CategArray = Form
            }
            
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func stockUnlimitedValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        if temp7CategArray.count > 0
        {
            Form = temp7CategArray
        }
        else if temp6CategArray.count > 0
        {
            Form = temp6CategArray
        }
        else if temp5CategArray.count > 0
        {
            Form = temp5CategArray
        }
        else if temp4CategArray.count > 0
        {
            Form = temp4CategArray
        }
        else if tempTempTempCategArray.count > 0
        {
            Form = tempTempTempCategArray
        }
        else if tempTempCategArray.count > 0
        {
            Form = tempTempCategArray
        }
        else if tempCategArray.count > 0
        {
            Form = tempCategArray
        }
        else
        {
            Form = tempFormArray
        }
        
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "stock_unlimited"
            {
                index = i;
            }
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
            if ( name == "in_stock" || name == "out_of_stock" || name == "out_of_stock_action" )
            {
                Form.remove(at: j)
                j = j-1
            }
            else
            {
                j = j+1
            }
            
        }

        
        if (form.valuesByKey["stock_unlimited"] != nil)
        {
            
            if form.valuesByKey["stock_unlimited"] as! String == "No"
            {
                let ndic = fieldsDic["stock_unlimited_0"] as! NSArray
                for i in 0 ..< ndic.count
                {
                    index += 1
                    let dic = ndic[i] as! NSDictionary
                    Form.insert(dic as AnyObject, at: index)
                }
                //tempFormArray = Form
                temp5CategArray = Form
                //tempCategArray = Form
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func showOutOfStockYesOrNo(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        if temp7CategArray.count > 0
        {
            Form = temp7CategArray
        }
        else if temp6CategArray.count > 0
        {
            Form = temp6CategArray
        }
        else if temp5CategArray.count > 0
        {
            Form = temp5CategArray
        }
        else if temp4CategArray.count > 0
        {
            Form = temp4CategArray
        }
        else if tempTempTempCategArray.count > 0
        {
            Form = tempTempTempCategArray
        }
        else if tempTempCategArray.count > 0
        {
            Form = tempTempCategArray
        }
        else if tempCategArray.count > 0
        {
            Form = tempCategArray
        }
        else
        {
            Form = tempFormArray
        }
        
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "out_of_stock"
            {
                index = i;
            }
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
            if ( name == "out_of_stock_action" )
            {
                Form.remove(at: j)
                j = j-1
            }
            else
            {
                j = j+1
            }
            
        }
        
        if (form.valuesByKey["out_of_stock"] != nil)
        {
            
            if form.valuesByKey["out_of_stock"] as! String == "Yes"
            {

                let ndic = fieldsDic["out_of_stock_1"] as! NSArray
                 for i in 0 ..< ndic.count
                 {
                 index += 1
                 let dic = ndic[i] as! NSDictionary
                 Form.insert(dic as AnyObject, at: index)
                 }
                //tempFormArray = Form
                temp6CategArray = Form
                //tempCategArray = Form
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func productEndDateValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        if temp7CategArray.count > 0
        {
            Form = temp7CategArray
        }
        else if temp6CategArray.count > 0
        {
            Form = temp6CategArray
        }
        else if temp5CategArray.count > 0
        {
            Form = temp5CategArray
        }
        else if temp4CategArray.count > 0
        {
            Form = temp4CategArray
        }
        else if tempTempTempCategArray.count > 0
        {
            Form = tempTempTempCategArray
        }
        else if tempTempCategArray.count > 0
        {
            Form = tempTempCategArray
        }
        else if tempCategArray.count > 0
        {
            Form = tempCategArray
        }
        else
        {
            Form = tempFormArray
        }
        
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "end_date_enable"
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
            if ( name == "end_date" )
            {
                Form.remove(at: j)
                j = j-1
            }
            else
            {
                j = j+1
            }
            
        }
        
        if (form.valuesByKey["end_date_enable"] != nil)
        {
            
            if form.valuesByKey["end_date_enable"] as! String != "No end date."
            {
                let ndic = fieldsDic["end_date_enable_1"] as! NSArray
                for i in 0 ..< ndic.count
                {
                    index += 1
                    let dic = ndic[i] as! NSDictionary
                    Form.insert(dic as AnyObject, at: index)
                }
                //tempFormArray = Form
                temp7CategArray = Form
                //tempCategArray = Form
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func productSearchValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        for (key,_) in form.valuesByKey
        {
            Formbackup["\(key)"] = form.valuesByKey["\(key)"]
        }
        var bundledProducts = ""
        if self.productType == "bundled"
        {
            for (key2,value2) in bundledProductTypes
            {
                if Formbackup["\(value2)"] != nil
                {
                    if Formbackup["\(value2)"] as! Int == 1
                    {
                        let val = key2 as! String
                        bundledProducts = bundledProducts+val+","
                    }
                }
            }
            if bundledProducts.length > 0
            {
                bundledProducts = bundledProducts.substring(to: bundledProducts.index(before: bundledProducts.endIndex))
            }
        }
        
        let presentedVC = ProductSuggestViewController()
        presentedVC.storeid = self.storeId
        if self.productType == "grouped"
        {
            presentedVC.productsType = "simple"
        }
        else if self.productType == "bundled"
        {
            presentedVC.productsType = bundledProducts
        }
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    
    func listingsubCategoryValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        print("hello")
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer()
    {
        stop()
        if popAfterDelay == true
        {
            self.dismiss(animated: true, completion: nil)
            
        }
    }
}
