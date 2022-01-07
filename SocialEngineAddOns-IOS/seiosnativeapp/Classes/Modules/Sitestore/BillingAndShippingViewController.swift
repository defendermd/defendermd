//
//  BillingAndShippingViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 09/08/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

var defaultCountry : String!
var checkoutDic = [String:String]()
var bilingid:Int!
var shippingid:Int!

@objcMembers class BillingAndShippingViewController: FXFormViewController {
    
    var popAfterDelay:Bool!
    var shippingForm = [AnyObject]()
    var shippingformValue = NSMutableDictionary()
    var countyrKey = NSString()
    var stateDIC = NSMutableDictionary()
    var index = Int()
    var backupForm = [AnyObject]()
    var logoutCartarr = NSMutableArray()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        navigationSetUp()
        popAfterDelay = false
        conditionalForm  = "checkout"
        isCreateOrEdit = true
        if logoutUser == true
        {
            //Getting Record from Core data
            GetrecartData()
            
        }
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
    
        
        generateCheckoutForm()
        // Do any additional setup after loading the view.
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
        self.dismiss(animated: true, completion: nil)
        
    }
    func navigationSetUp()
    {
        navigationController?.navigationBar.isHidden = false
        self.title = NSLocalizedString("Address", comment: "")
        let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel",  comment: ""), style:.plain , target:self , action: #selector(BillingAndShippingViewController.goBack))
        cancel.tintColor = textColorPrime
        self.navigationItem.leftBarButtonItem = cancel

    }
    // MARK: Getting Checkout Form
    func generateCheckoutForm()
    {
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            //Set Parameters & path for Sign Up Form
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            parameter["store_id"] = Store_id
            path = "sitestore/checkout/address"
            // Logout user
            if logoutUser == true
            {
                if logoutCartarr.count>0
                {
                    // Convert core data array into json object
                    parameter["productsData"] = GetjsonObject(data: logoutCartarr)
                }

            }
            // Send Server Request for Sign Up Form
            post(parameter, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Add Value to Form Array & Values to formValue Array
                        Form.removeAll(keepingCapacity: false)
                        Formbackup.removeAllObjects()
                        InitialForm.removeAll()
                        self.shippingformValue.removeAllObjects()
                        formValue = self.shippingformValue
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if let dic = succeeded["body"] as? NSDictionary
                        {
                            if let formdic = dic["form"] as? NSDictionary
                            {
                                if let billingArray = formdic["billingForm"] as? NSArray
                                {
                                    Form = billingArray as [AnyObject]
                                    InitialForm = billingArray as [AnyObject]
                                }
                                
                                if let shippingArray = formdic["shippingForm"] as? NSArray
                                {
                                    self.shippingForm = shippingArray as [AnyObject]
                                   
                                }
                            }
                            
                            if let formdic = dic["formValues"] as? NSDictionary
                            {
                                if let formValues = formdic["billingAddress"] as? NSDictionary
                                {
                                    formValue = formValues

                                }
                                if let shipingformValues = formdic["shippingAddress"] as? NSDictionary
                                {
                                    self.shippingformValue = shipingformValues as! NSMutableDictionary
                                    if let  common = formValue["common"] as? Int
                                    {
                                        if common == 0
                                        {
                                            for i in 0 ..< self.shippingForm.count
                                            {
                                                let dic = Form.last
                                                var count = Form.count
                                                count = count-1
                                                Form.remove(at: count)
                                                if let shippingDic = self.shippingForm[i] as? NSDictionary
                                                {
                                                    Form.append(shippingDic)
                                                }
                                                Form.append(dic!)
                                            }
                                            
                                            for (key, value) in formValue
                                            {
                                                if self.shippingformValue["\(key)"] == nil
                                                {
                                                    self.shippingformValue["\(key)"] = "\(value)"
                                                }
 
                                            }
                                            formValue = self.shippingformValue
                                           
                                         }
                                    }
                                }
                                
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
    
    // MARK: Change Billing/Shiping Address
    func shippingValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        
        for i in 0 ..< Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        if form.valuesByKey["common"] as! Bool == false
        {
            for i in 0 ..< self.shippingForm.count
            {
                let dic = Form.last
                var count = Form.count
                count = count-1
                Form.remove(at: count)
                if let shippingDic = self.shippingForm[i] as? NSDictionary
                {
                    Form.append(shippingDic)
                }
                Form.append(dic!)
            }
            
            for (key, value) in formValue
            {
                
                if shippingformValue["\(key)"] == nil
                {

                    shippingformValue["\(key)"] = "\(value)"
                }
                
            }
            
            formValue = shippingformValue
        }
        else
        {
          
           Form = InitialForm
        }
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
       
    }
    
    // MARK: Change Billing/Shiping Country
    func CountryBillingValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        
        let form = cell.field.form as! CreateNewForm
        let country = form.valuesByKey["country_billing"] as! String
        defaultCountry = "\(country)"
        for i in 0 ..< Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "country_billing"
            {
                 if let option = dic["multiOptions"] as? NSDictionary
                 {
                    for (key, value) in option
                    {
                        if country == "\(value)"
                        {
                          countyrKey = "\(key)" as NSString
                        }
                    }

                }
                index = i+1
                stateDIC = Form[index] as! NSMutableDictionary
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
            
        }
        
        if countyrKey != ""
        {
          GetCountries()
        }
        else
        {
            let arr = NSArray()
            self.stateDIC["multiOptions"] = arr
            Form.remove(at: self.index)
            Form.insert(self.stateDIC, at: self.index)
            self.formController.form = CreateNewForm()
            self.formController.tableView.reloadData()

        }

      }
    
    func CountryShipingValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        let country = form.valuesByKey["country_shipping"] as! String
        for i in 0 ..< Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "country_shipping"
            {
                if let option = dic["multiOptions"] as? NSDictionary
                {
                    for (key, value) in option
                    {
                        if country == "\(value)"
                        {
                            countyrKey = "\(key)" as NSString
                        }
                    }
                    
                }
                index = i+1
                stateDIC = Form[index] as! NSMutableDictionary
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
            
        }
        
        if countyrKey != ""
        {
            GetCountries()
        }
 
    }
    
    // MARK: Get Contries
    func GetCountries()
    {
        if Reachabable.isConnectedToNetwork()
        {
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            //Set Parameters & path for Sign Up Form
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            parameter["store_id"] = "\(Store_id)"
            parameter["country"] = "\(countyrKey)"
            path = "sitestore/checkout/states"
            // Logout user
            if logoutUser == true
            {
                if logoutCartarr.count>0
                {
                    // Convert core data array into json object
                    parameter["productsData"] = GetjsonObject(data:logoutCartarr)
                }
                
            }
            // Send Server Request for Sign Up Form
            post(parameter, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Add Value to Form Array & Values to formValue Array
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let arr = succeeded["body"] as? NSDictionary
                        {
                            self.stateDIC["multiOptions"] = arr
                        }
                        else if let arr = succeeded["body"] as? NSArray{
                            self.stateDIC["multiOptions"] = arr
                        }
                            Form.remove(at: self.index)
                            var copyformvalue = NSMutableDictionary()
                            if formValue.count != 0
                            {
                               copyformvalue = formValue as! NSMutableDictionary
                            }
                            
                            if self.index > 6
                            {
                                Formbackup.removeObject(forKey: "state_shipping")
                                if formValue.count != 0
                                {

                                    copyformvalue["state_shipping"] = ""
                                }
                               
                            }
                            else
                            {
                                Formbackup.removeObject(forKey: "state_billing")
                                if formValue.count != 0
                                {
                                    copyformvalue["state_billing"] = ""
                                }

                            }
                            if formValue.count != 0
                            {
                                formValue = copyformvalue
                            }
                            Form.insert(self.stateDIC, at: self.index)
                        
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
    // Get record from core data into array
    func GetrecartData()
    {
        let results = GetallRecord()
        if results.count>0
        {
            for result: Any in results
            {
                let data = (result as AnyObject).value(forKey: "added_products")
                let output = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
                if let dict = output as? NSDictionary
                {
                    logoutCartarr.add(dict)
                    
                }
                
            }
            
        }
    }
    // MARK: Submit Form
    func submitForm(_ cell: FXFormFieldCellProtocol)
    {
        self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
        let form = cell.field.form as! CreateNewForm
 
            // Check Internet Connection
            if Reachabable.isConnectedToNetwork() {
                view.isUserInteractionEnabled = false
//                spinner.center = view.center
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                var dic = Dictionary<String, String>()
                print(form.valuesByKey)
                for (key, value) in form.valuesByKey{
                    
                    if (key as! NSString == "country_shipping") || (key as! NSString == "state_shipping") || (key as! NSString == "country_billing") || (key as! NSString == "state_billing"){
                        dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                    }else{
                        if let receiver = value as? NSString {
                            dic["\(key)"] = receiver as String
                        }
                        if let receiver = value as? Int {
                            dic["\(key)"] = String(receiver)
                        }
                        
                    }
                    
                }
                //Set Parameters (Token & Form Values) & path for Sign Up Form
                var path = ""
                dic["store_id"] = Store_id
                path = "sitestore/checkout/address"
                var parameter = [String:String]()
                // Logout user
                if logoutUser == true
                {
                    if logoutCartarr.count>0
                    {
                        // Convert core data array into json object
                        dic["productsData"] = GetjsonObject(data:logoutCartarr)
                    }
                    
                }
               
//                dic["state_shipping"] = "0"
//                dic["country_shipping"] = "0"
//                dic["locality_shipping"] = " "
//                dic["zip_shipping"] = " "
//                dic["country_billing"] = "0"
//                dic["state_billing"] = "0"
//                dic["locality_billing"] = " "
//                dic["zip_billing"] = " "
                parameter = dic
                

                // Send Server Request to Sign Up Form
                post(parameter,url: path , method: "POST") { (succeeded, msg) -> () in
                    
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        self.view.alpha = 1.0
                        self.view.isUserInteractionEnabled = true
                        if msg
                        {
                            if let dic = succeeded["body"] as? NSDictionary
                            {
                                if let biling_id = dic["billingAddress"] as? Int
                                {
                                   bilingid = biling_id
                                    
                                }
                                if let shipping_id = dic["shippingAddress"] as? Int
                                {
                                    shippingid = shipping_id
                                    let presentedVC = ShippingMethodViewController()
                                    self.navigationController?.pushViewController(presentedVC, animated: false)
                                }
                                else
                                {
                                    let presentedVC = PaymentMethodViewController()
                                    self.navigationController?.pushViewController(presentedVC, animated: false)
                                }

                            }

                        }
                        else
                        {
                            self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                            let a = validation
                            signupValidation.removeAll(keepingCapacity: false)
                            signupValidationKeyValue.removeAll(keepingCapacity: false)
                            for (key,value) in a  {
                                signupValidation.append(value as AnyObject)
                                signupValidationKeyValue.append(key as AnyObject)
                                
                            }
                            let count = signupValidation.count
                            if count > 0
                            {
                                showToast(message: "\(signupValidation[0] as! String).\n", controller: self)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
