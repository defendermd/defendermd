//
//  EditShippingMethodViewController.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 20/02/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import Foundation

@objcMembers class EditShippingMethodViewController : FXFormViewController
{
    var popAfterDelay:Bool!
    var shippingMethodForm = [AnyObject]()
    var shippingMethodFormValue = NSMutableDictionary()
    var countyrKey = NSString()
    var stateDIC = NSMutableDictionary()
    var index = Int()
    var backupForm = [AnyObject]()
    var logoutCartarr = NSMutableArray()
    var leftBarButtonItem: UIBarButtonItem!
    var storeId : String!
    var shippingMethodId : Int!
    var contentType : String! = ""
    var formTitle:String!
    var param : NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(EditShippingMethodViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        popAfterDelay = false
        self.title = NSLocalizedString("Edit Shipping Method", comment: "")
        conditionalForm  = "editShippingMethod"
        conditionForm = "editShippingMethod"
        isCreateOrEdit = false
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
        generateShippingMethodForm()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        Form = backupForm
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        backupForm = Form
    }
    
    @objc func goBack()
    {
        //_ = self.navigationController?.popViewController(animated: false)
        _ = self.dismiss(animated: false, completion: nil)
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
            self.shippingMethodId = param["shippingmethod_id"] as! Int
            parameter["shippingmethod_id"] = String(self.shippingMethodId)
            parameter["store_id"] = storeId
            path = "sitestore/edit-shipping-method/"+storeId
            // Send Server Request for Sign Up Form
            post(parameter, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Add Value to Form Array & Values to formValue Array
                        Form.removeAll(keepingCapacity: false)
                        tempFormArray.removeAll(keepingCapacity: false)
                        tempCategArray.removeAll(keepingCapacity: false)
                        Formbackup.removeAllObjects()
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if let dic = succeeded["body"] as? NSDictionary
                        {
                            if let formarr = dic["editForm"] as? NSArray
                            {
                                Form = formarr as [AnyObject]
                                tempFormArray = formarr as [AnyObject]
                            }
                            if let fieldDic = dic["fields"] as? NSDictionary
                            {
                                fieldsDic = fieldDic
                            }
                            if let formValues = dic["formValues"] as? NSDictionary
                            {
                                formValue = formValues as! [AnyHashable : Any] as NSDictionary
                            }
                            else
                            {
                                formValue = [:]
                            }
                        }
                        
                        //  For Enable method for all region issue
                        
                        for i in 0 ..< (Form.count) where i < Form.count
                        {
                            let enableRegionDic = Form[i] as! NSDictionary
                            let name = enableRegionDic["name"] as! String
                            if name == "all_regions"
                            {
                                Form.remove(at: i)
                            }
                        }
                        
                        var index = Int()
                        
                        if formValue["country"] as? String != nil
                        {
                            if formValue["country"] as! String == "US"
                            {
                                for i in 0 ..< (Form.count) where i < Form.count
                                {
                                    let enableRegionDic = Form[i] as! NSDictionary
                                    let name = enableRegionDic["name"] as! String
                                    if name == "country"
                                    {
                                        index = i
                                    }
                                }
                                var dic2 = [String: AnyObject]()
                                dic2["type"] = "Text" as? AnyObject
                                dic2["name"] = "region" as? AnyObject
                                dic2["label"] = "Regions / States" as? AnyObject
                                index += 1
                                Form.insert(dic2 as AnyObject, at: index)
                            }
                        }
                        
                        /*
                        if formValue["region"] as? Int != nil
                        {
                            if formValue["region"] as! Int != 0
                            {
                                for i in 0 ..< (Form.count) where i < Form.count
                                {
                                    let enableRegionDic = Form[i] as! NSDictionary
                                    let name = enableRegionDic["name"] as! String
                                    if name == "country"
                                    {
                                        index = i
                                    }
                                }
                                var dic2 = [String: AnyObject]()
                                dic2["type"] = "Text" as? AnyObject
                                dic2["name"] = "region" as? AnyObject
                                dic2["label"] = "Regions / States" as? AnyObject
                                index += 1
                                Form.insert(dic2 as AnyObject, at: index)
                            }
                        }*/
                        
                        tempFormArray = Form
                        print(Form)
                        print(tempFormArray)
                        print(formValue)
                        
                        
                        // Create FXForm Form
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
    
    
    func submitForm(_ cell: FXFormFieldCellProtocol)
    {
        //        self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
        let form = cell.field.form as! CreateNewForm
        
        // Check for errors
        
        var error = ""
        var errorTitle = "Error"
        
        if ( form.valuesByKey["title"] == nil || form.valuesByKey["title"] as! String == "")
        {
            errorTitle = NSLocalizedString("Title of Method!", comment: "")
            error = NSLocalizedString("Please enter the title of the Shipping Method", comment: "")
        }
            
        else if ( form.valuesByKey["delivery_time"] == nil || form.valuesByKey["delivery_time"] as! String == "" )
        {
            errorTitle = NSLocalizedString("Delivery Time!!", comment: "")
            error = NSLocalizedString("Please enter Delivery Time Field value", comment: "")
        }
        
        else if ( form.valuesByKey["country"] == nil )
        {
            errorTitle = NSLocalizedString("Select A country!!", comment: "")
            error = NSLocalizedString("Please select a country", comment: "")
        }
        else if ( form.valuesByKey["all_regions"] != nil && form.valuesByKey["all_regions"] as! String == "United States")
        {
            if ( form.valuesByKey["all_regions"] == nil || form.valuesByKey["all_regions"] as! String == "")
            {
                errorTitle = NSLocalizedString("Select Regions", comment: "")
                error = NSLocalizedString("Please select wether to enable for all regions or not!", comment: "")
            }
        }
            
        else if ( form.valuesByKey["dependency"] == nil )
        {
            errorTitle = NSLocalizedString("Dependency Type!!", comment: "")
            error = NSLocalizedString("Please Select a dependency type", comment: "")
        }
            
        else if ( form.valuesByKey["dependency"] != nil )
        {
            print(form.valuesByKey["dependency"]!)
            if form.valuesByKey["dependency"] as! String == "Cost & Weight"
            {
                if ( form.valuesByKey["ship_start_limit"] == nil || form.valuesByKey["ship_start_limit"] as! String == "" )
                {
                    errorTitle = NSLocalizedString("Order Cost Value!!", comment: "")
                    error = NSLocalizedString("Please enter Order Cost Start Value", comment: "")
                }
                    
                else if ( form.valuesByKey["ship_end_limit"] == nil || form.valuesByKey["ship_end_limit"] as! String == "" )
                {
                    errorTitle = NSLocalizedString("Order Cost Value!!", comment: "")
                    error = NSLocalizedString("Please enter Order Cost End Value", comment: "")
                }
                    
                else if ( form.valuesByKey["allow_weight_from"] == nil || form.valuesByKey["allow_weight_from"] as! String == "" )
                {
                    errorTitle = NSLocalizedString("Order Weight!!", comment: "")
                    error = NSLocalizedString("Please enter Total Order Weight from Value", comment: "")
                }
                    
                else if ( form.valuesByKey["allow_weight_to"] == nil || form.valuesByKey["allow_weight_to"] as! String == "" )
                {
                    errorTitle = NSLocalizedString("Order Weight!!", comment: "")
                    error = NSLocalizedString("Please enter Total Order Weight To Value", comment: "")
                }
                else if ( form.valuesByKey["handling_type"] == nil || form.valuesByKey["handling_type"] as! String == "" )
                {
                    errorTitle = NSLocalizedString("Handling Type!!", comment: "")
                    error = NSLocalizedString("Please select a handling type", comment: "")
                }
                else if ( form.valuesByKey["handling_type"] != nil )
                {
                    print(form.valuesByKey["handling_type"]!)
                    
                    
                    if ( (form.valuesByKey["handling_type"] as! String == "Fixed" ) && (form.valuesByKey["price"] == nil || form.valuesByKey["price"] as! String == "") )
                    {
                        errorTitle = NSLocalizedString("Handling Value", comment: "")
                        error = NSLocalizedString("please enter a value for Handling fee", comment: "")
                    }
                    else if ( (form.valuesByKey["handling_type"] as! String == "Percentage" ) && (form.valuesByKey["rate"] == nil || form.valuesByKey["rate"] as! String == "") )
                    {
                        errorTitle = NSLocalizedString("Handling Value", comment: "")
                        error = NSLocalizedString("please enter a value for Rate Handling fee", comment: "")
                    }
                }
                
            }
            if form.valuesByKey["dependency"] as! String == "Weight only"
            {
                if ( form.valuesByKey["ship_start_limit"] == nil || form.valuesByKey["ship_start_limit"] as! String == "" )
                {
                    errorTitle = NSLocalizedString("Order weight Value!!", comment: "")
                    error = NSLocalizedString("Please enter Order weight Start Value", comment: "")
                }
                    
                else if ( form.valuesByKey["ship_end_limit"] == nil || form.valuesByKey["ship_end_limit"] as! String == "" )
                {
                    errorTitle = NSLocalizedString("Order weight Value!!", comment: "")
                    error = NSLocalizedString("Please enter Order weight End Value", comment: "")
                }
                    
                else if ( form.valuesByKey["handling_type"] == nil || form.valuesByKey["handling_type"] as! String == "" )
                {
                    errorTitle = NSLocalizedString("Handling Type!!", comment: "")
                    error = NSLocalizedString("Please select a handling type", comment: "")
                }
                else if ( form.valuesByKey["handling_type"] != nil )
                {
                    print(form.valuesByKey["handling_type"]!)
                    
                    
                    if ( (form.valuesByKey["handling_type"] as! String == "Fixed" ) && (form.valuesByKey["price"] == nil || form.valuesByKey["price"] as! String == "") )
                    {
                        errorTitle = NSLocalizedString("Handling Value", comment: "")
                        error = NSLocalizedString("please enter a value for Handling fee", comment: "")
                    }
                    else if ( (form.valuesByKey["handling_type"] as! String == "Percentage" ) && (form.valuesByKey["rate"] == nil || form.valuesByKey["rate"] as! String == "") )
                    {
                        errorTitle = NSLocalizedString("Handling Value", comment: "")
                        error = NSLocalizedString("please enter a value for Rate Handling fee", comment: "")
                    }
                    else if ( (form.valuesByKey["handling_type"] as! String == "Per Unit Weight" ) && (form.valuesByKey["price"] == nil || form.valuesByKey["price"] as! String == "") )
                    {
                        errorTitle = NSLocalizedString("Handling Value", comment: "")
                        error = NSLocalizedString("please enter a value for Handling fee", comment: "")
                    }
                    
                }
                
                
            }
            if form.valuesByKey["dependency"] as! String == "Quantity & Weight"
            {
                if ( form.valuesByKey["ship_start_limit"] == nil || form.valuesByKey["ship_start_limit"] as! String == "" )
                {
                    errorTitle = NSLocalizedString("Product Quantity Value!!", comment: "")
                    error = NSLocalizedString("Please enter Product quantity Start Value", comment: "")
                }
                    
                else if ( form.valuesByKey["ship_end_limit"] == nil || form.valuesByKey["ship_end_limit"] as! String == "" )
                {
                    errorTitle = NSLocalizedString("Product Quantity Value!!", comment: "")
                    error = NSLocalizedString("Please enter Product quantity end Value", comment: "")
                }
                    
                else if ( form.valuesByKey["allow_weight_from"] == nil || form.valuesByKey["allow_weight_from"] as! String == "" )
                {
                    errorTitle = NSLocalizedString("Order Weight!!", comment: "")
                    error = NSLocalizedString("Please enter starting weight handling range Value", comment: "")
                }
                    
                else if ( form.valuesByKey["allow_weight_to"] == nil || form.valuesByKey["allow_weight_to"] as! String == "" )
                {
                    errorTitle = NSLocalizedString("Order Weight!!", comment: "")
                    error = NSLocalizedString("Please enter ending weight handling range Value", comment: "")
                }
                    
                else if ( form.valuesByKey["ship_type"] == nil || form.valuesByKey["ship_type"] as! String == "" )
                {
                    errorTitle = NSLocalizedString("Handling Type!!", comment: "")
                    error = NSLocalizedString("Please select a shipping type", comment: "")
                }
                else if ( form.valuesByKey["ship_type"] != nil )
                {
                    print(form.valuesByKey["ship_type"]!)
                    
                    
                    if form.valuesByKey["ship_type"] as! String == "Per Item"
                    {
                        if ( form.valuesByKey["handling_type"] == nil || form.valuesByKey["handling_type"] as! String == "" )
                        {
                            errorTitle = NSLocalizedString("Handling Type!!", comment: "")
                            error = NSLocalizedString("Please select a handling type", comment: "")
                        }
                        else if ( form.valuesByKey["handling_type"] != nil )
                        {
                            
                            if ( (form.valuesByKey["handling_type"] as! String == "Fixed" ) && (form.valuesByKey["price"] == nil || form.valuesByKey["price"] as! String == "") )
                            {
                                errorTitle = NSLocalizedString("Handling Value", comment: "")
                                error = NSLocalizedString("please enter a value for Handling fee", comment: "")
                            }
                            else if ( (form.valuesByKey["handling_type"] as! String == "Percentage" ) && (form.valuesByKey["rate"] == nil || form.valuesByKey["rate"] as! String == "") )
                            {
                                errorTitle = NSLocalizedString("Handling Value", comment: "")
                                error = NSLocalizedString("please enter a value for Rate Handling fee", comment: "")
                            }
                        }
                    }
                    if form.valuesByKey["ship_type"] as! String == "Per Order"
                    {
                        if form.valuesByKey["price"] == nil || form.valuesByKey["price"] as! String == ""
                        {
                            errorTitle = NSLocalizedString("Fee!!", comment: "")
                            error = NSLocalizedString("Please enter a handling fee for shipping type", comment: "")
                        }
                    }
                }
                
            }
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
            if Reachabable.isConnectedToNetwork()
            {
                
                view.isUserInteractionEnabled = false
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                var dic = Dictionary<String, String>()
                
                for (key, value) in form.valuesByKey
                {
                    
                    let conditionArray:[String] = ["dependency","country","handling_type","ship_type"]
                    if conditionArray.contains(key as! String)
                    {
                        if let _ = value as? NSString
                        {
                            dic["\(key)"] = findKeyForValue2(form.valuesByKey["\(key)"] as! String, keyName: key as! String)
                        }
                        if let receiver = value as? Int
                        {
                            dic["\(key)"] = String(receiver)
                        }
                    }
                    else
                    {
                        if let receiver = value as? NSString
                        {
                            dic["\(key)"] = receiver as String
                        }
                        if let receiver = value as? Int
                        {
                            dic["\(key)"] = String(receiver)
                        }
                    }
                    
                    
                }
            
            //Set Parameters (Token & Form Values) & path for Adding Shipping method
            var path = ""
            dic["store_id"] = storeId
            dic["shippingmethod_id"] = String(self.shippingMethodId)
            
            // For selecting and setting up Dependency
            /*
            if dic["dependency"] == "Cost & Weight"
            {
                dic["dependency"] = "0"
            }
            else if dic["dependency"] == "Weight only"
            {
                dic["dependency"] = "1"
            }
            else if dic["dependency"] == "Quantity & Weight"
            {
                dic["dependency"] = "2"
            }
            else
            {
                dic["dependency"] = dic["dependency"]
            }
                
            // For selecting and setting up Countries
            
            if dic["country"] == "All Countries"
            {
                dic["country"] = "ALL"
            }
            else if dic["country"] == "United States"
            {
                dic["country"] = "US"
            }
            else if dic["country"] == "US"
            {
                dic["country"] = "US"
            }
            else
            {
                dic["country"] = "ALL"
            }
                
            // For setting up Handling Type
            if dic["handling_type"] == "Fixed"
            {
                dic["handling_type"] = "fixed"
            }
            else if dic["handling_type"] == "Percentage"
            {
                dic["handling_type"] = "percentage"
            }
            else if dic["handling_type"] == "Per Unit Weight"
            {
                dic["handling_type"] = "unit_weight"
            }
            else
            {
                dic["handling_type"] = dic["handling_type"]
            }
                
            // For regions value
            if dic["all_regions"] == "No"
            {
                dic["all_regions"] = "no"
            }
            else if dic["all_regions"] == "Yes"
            {
                dic["all_regions"] = "yes"
            }
            else
            {
               dic["all_regions"] = "no"
            }
             */
            path = "sitestore/edit-shipping-method/"+storeId
            var parameter = [String:String]()
            parameter = dic
            print(parameter)
            // Send Server Request to Sign Up Form
            post(parameter,url: path , method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.view.alpha = 1.0
                    self.view.isUserInteractionEnabled = true
                    if msg
                    {
                        showToast(message:"Shipping Method successfully edited.", controller: self, onView: false, time: 5.0)
                        self.popAfterDelay = true
                        self.createTimer(self)
                    }
                    else
                    {
                        self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                        if validationMessage != ""
                        {
                            showToast(message:"\(validationMessage)", controller: self)
                        }
                        else
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
        }
        }
}
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }

// Submit form ends here

    func listingCountryValueChanged( _ cell : FXFormFieldCellProtocol)
    {
        let alert = UIAlertController(title: "Error", message: "You cannot change country. Editing is Disabled", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in

            self.formController.tableView.reloadData()
        })
        alert.addAction(action1)
        self.present(alert, animated: true, completion: nil)
    }
    
    func listingRegionValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let alert = UIAlertController(title: "Error", message: "You cannot edit this. Editing is Disabled", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
            
            self.formController.tableView.reloadData()
        })
        alert.addAction(action1)
        self.present(alert, animated: true, completion: nil)

    }

// Sub Fields Insertion in the form on the value changed
// Show list of country when value of region enabled = NO
    
    
    
    
    // Show Fields related to Type of Dependency
    
    func listingDependencyValueChanged(_ cell : FXFormFieldCellProtocol)
    {
        
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        print(tempFormArray)
        var index = Int()
        
        
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "dependency"
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
            
            if ( name == "ship_start_limit" || name == "ship_end_limit" || name == "allow_weight_from" || name == "allow_weight_to" || name == "handling_type" || name == "ship_type" || name == "handling_type_fixed" || name == "handling_type_percentage" || name == "handling_type_unit_weight" || name == "ship_type_per_order" || name == "ship_type_per_item" || name == "rate" || name == "price" )
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
        
        if (form.valuesByKey["dependency"] != nil)
        {
            
            if form.valuesByKey["dependency"] as! String == "Cost & Weight"
            {
                let ndic = fieldsDic["dependency_0"] as! NSArray
                for i in 0 ..< ndic.count
                {
                    index += 1
                    let dic = ndic[i] as! NSDictionary
                    Form.insert(dic as AnyObject, at: index)
                    
                }
                tempCategArray = Form
            }
            
            if form.valuesByKey["dependency"] as! String == "Weight only"
            {
                let ndic = fieldsDic["dependency_1"] as! NSArray
                for i in 0 ..< ndic.count
                {
                    index += 1
                    let dic = ndic[i] as! NSDictionary
                    Form.insert(dic as AnyObject, at: index)
                }
                tempCategArray = Form
            }
            
            if form.valuesByKey["dependency"] as! String == "Quantity & Weight"
            {
                let ndic = fieldsDic["dependency_2"] as! NSArray
                for i in 0 ..< ndic.count
                {
                    index += 1
                    let dic = ndic[i] as! NSDictionary
                    Form.insert(dic as AnyObject, at: index)
                    
                }
                tempCategArray = Form
            }
            
            FormforRepeat = Form
            self.formController.form = CreateNewForm()
            self.formController.tableView.reloadData()
        }
    }
    
    // Show type of handling Fixed, Percentage or Per Unit Weight
    func handlingTypeValueChanged(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        if tempCategArray.count != 0
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
            
            if ( name == "rate" || name == "price" )
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
        
        if (form.valuesByKey["handling_type"] != nil)
        {
            if ( form.valuesByKey["handling_type"] as! String == "Fixed")
            {
                index += 1
                let countryDic = fieldsDic["handling_type_fixed"] as? NSArray
                let mainCountryDic = countryDic?[0] as? NSDictionary
                Form.insert(mainCountryDic!, at: index)
                //tempCategArray = Form
            }
            if ( form.valuesByKey["handling_type"] as! String == "Percentage")
            {
                index += 1
                let countryDic = fieldsDic["handling_type_percentage"] as? NSArray
                let mainCountryDic = countryDic?[0] as? NSDictionary
                Form.insert(mainCountryDic!, at: index)
                //tempCategArray = Form
            }
            if ( form.valuesByKey["handling_type"] as! String == "Per Unit Weight")
            {
                index += 1
                let countryDic = fieldsDic["handling_type_unit_weight"] as? NSArray
                let mainCountryDic = countryDic?[0] as? NSDictionary
                Form.insert(mainCountryDic!, at: index)
                //tempCategArray = Form
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    
    // Show type of Shipping Rate type Per Order or Per item in order
    func shippingTypeValueChanged(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        if tempCategArray.count != 0
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
            if name == "ship_type"
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
            
            if ( name == "rate" || name == "price" || name == "handling_type" )
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
        
        if (form.valuesByKey["ship_type"] != nil)
        {
            if ( form.valuesByKey["ship_type"] as! String == "Per Order")
            {
                index += 1
                let countryDic = fieldsDic["ship_type_per_order"] as? NSArray
                let mainCountryDic = countryDic?[0] as? NSDictionary
                Form.insert(mainCountryDic!, at: index)
                //tempCategArray = Form
            }
            if ( form.valuesByKey["ship_type"] as! String == "Per Item")
            {
                index += 1
                let countryDic = fieldsDic["ship_type_per_item"] as? NSArray
                let mainCountryDic = countryDic?[0] as? NSDictionary
                Form.insert(mainCountryDic!, at: index)
                tempCategArray = Form
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
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
