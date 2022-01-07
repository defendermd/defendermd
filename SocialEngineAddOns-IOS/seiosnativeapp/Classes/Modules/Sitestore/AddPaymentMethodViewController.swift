//
//  AddPaymentMethodViewController.swift
//  seiosnativeapp
//
//  Created by Vidit Paliwal on 22/02/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit

var FieldsArray = [AnyObject]()

@objcMembers class AddPaymentMethodViewController : FXFormViewController
{
    var popAfterDelay:Bool!
    //var contentType : String! = ""
    //var formTitle:String!
    var fieldsArray = [AnyObject]()
    var optionsArray = [AnyObject]()
    var index = Int()
    var fullForm = [AnyObject]()
    var backupForm = [AnyObject]()
    var leftBarButtonItem: UIBarButtonItem!
    var storeId : String!
    var password : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AddPaymentMethodViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        popAfterDelay = false
        self.title = NSLocalizedString("Configure Payment Methods", comment: "")
        conditionalForm  = "paymentMethod"
        conditionForm = "paymentMethod"
        isCreateOrEdit = true
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
            parameter["password"] = password!
            path = "sitestore/payment-info/"+storeId
            // Send Server Request for Sign Up Form
            post(parameter, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Add Value to Form Array & Values to formValue Array
                        Form.removeAll(keepingCapacity: false)
                        Formbackup.removeAllObjects()
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if let dic = succeeded["body"] as? NSDictionary
                        {
                            if let formValues = dic["formValues"] as? NSDictionary
                            {
                                formValue = formValues as! [AnyHashable : Any] as NSDictionary
                            }
                            
                            if let formarr = dic["form"] as? NSArray
                            {
                                self.fullForm = formarr as [AnyObject]
                                for i in 0 ..< (formarr.count) where i < formarr.count
                                {
                                    var arrindex = 0
                                    if let dic = formarr[i] as? NSDictionary
                                    {
                                        if let type = dic["subType"] as? String
                                        {
                                            self.optionsArray.insert(dic as AnyObject, at: arrindex)
                                            arrindex += 1
                                        }
                                        let name = dic["name"] as! String
                                        if name == "submit"
                                        {
                                            self.optionsArray.insert(dic as AnyObject, at: arrindex)
                                            arrindex += 1
                                        }
                                        
                                    }
//                                    if name == "bychequeGatewayDetail" && formValue["isByChequeChecked"] as! Int == 1
//                                    {
//                                        self.optionsArray.insert(dic as AnyObject, at: arrindex)
//                                        arrindex += 1
//                                    }
                                }
                                for j in 0 ..< (formarr.count) where j < formarr.count
                                {
                                    var fieldIndex = 0
                                    let dic = formarr[j] as? NSDictionary
                                    let name = dic?["name"] as? String
                                    if name == "isCodChecked" || name?.range(of: "paypal") != nil || name == "secret" || name == "publishable" || name == "bychequeGatewayDetail" || name == "isByChequeChecked" || name == "isPaypalChecked" || name == "isStripeChecked" || name == "first_name" || name == "last_name" || name == "email_mango" || name == "birthday" || name == "nationality" || name == "residence" || name == "isMangopay" || name == "isMoneyorderChecked"
                                    {
                                        self.fieldsArray.insert(dic as AnyObject, at: fieldIndex)
                                        fieldIndex += 1
                                    }
                                }
                                self.optionsArray = self.optionsArray.reversed()
                                self.fieldsArray = self.fieldsArray.reversed()
                                
                                Form = self.optionsArray as [AnyObject]
                                tempFormArray = self.optionsArray as [AnyObject]
                                FieldsArray = self.fieldsArray as [AnyObject]
                                
                            }
                            if let fieldDic = dic["fields"] as? NSDictionary
                            {
                                fieldsDic = fieldDic
                            }
                            
                        }
                        
                        // Create FXForm Form
                        self.formController.form = CreateNewForm()
                        self.formController.tableView.reloadData()
                    }
                    else
                    {
                        if succeeded["message"] != nil{
                            self.popAfterDelay = true
                            self.createTimer(self)
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
            
        }
    }
    
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    func submitForm(_ cell: FXFormFieldCellProtocol)
    {
        //self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
        let form = cell.field.form as! CreateNewForm
        
        // Check for errors
        
        var error = ""
        var errorTitle = "Error"
        
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
                
                if ((form.valuesByKey["email_paypal"] == nil) || !checkValidEmail(form.valuesByKey["email_paypal"] as! String))
                {
                    error = NSLocalizedString("Please enter valid paypal Email", comment: "")
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
                
                for i in 0 ..< (fullForm.count) where i < fullForm.count
                {
                    let dic = fullForm[i] as! NSDictionary
                    let name = dic["name"] as! String
                    if(form.valuesByKey["\(name)"] == nil)
                    {
                        form.valuesByKey["\(name)"] = Formbackup["\(name)"]
                    }
                }
            
                for (key, value) in form.valuesByKey
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
            
            
                self.popAfterDelay = true
            //Set Parameters (Token & Form Values) & path for Adding Shipping method
                var path = ""
                dic["store_id"] = storeId
            
                path = "sitestore/set-store-gateway-info/"+storeId
                var parameter = [String:String]()
                parameter = dic
                print(parameter)
            // Send Server Request for Form
                post(parameter,url: path , method: "POST") { (succeeded, msg) -> () in
                
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        self.view.alpha = 1.0
                        self.view.isUserInteractionEnabled = true
                    
                        if msg
                        {
                            showToast(message: String(format: NSLocalizedString("Payment Method has been added successfully.", comment: ""), "" ), controller: self, onView: false, time: 5.0)
                            self.createTimer(self)
                        }
                        else
                        {
                            self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                            if validationMessage != ""
                            {
                                showToast(message: "\(validationMessage)", controller: self)
                            }
                            else
                            {
                                showToast(message: "\(succeeded["message"]!)", controller: self)
                            }
                        }
                    })
                }
            }
        }
        
        // Check Internet Connection
        
    }
   
    // Submit form ends here
    
    func showMoneyOrderFields(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "moneyorderHeading"
            {
                index = i
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        index += 1
        
        if (form.valuesByKey["moneyorderHeading"] != nil)
        {
            if form.valuesByKey["moneyorderHeading"] as! Int == 1
            {
                for i in 0 ..< (FieldsArray.count) where i < FieldsArray.count
                {
                    let ndic = FieldsArray[i] as! NSDictionary
                    let name = ndic["name"] as! String
                    if name == "isMoneyorderChecked"
                    {
                        Form.insert(ndic, at: index)
                        index += 1
                    }
                }
                tempFormArray = Form
            }
            if form.valuesByKey["moneyorderHeading"] as! Int == 0
            {
                
                var j : Int = 0
                while j < Form.count
                {
                    let dic = Form[j] as! NSDictionary
                    let name = dic["name"] as! String
                    
                    if name == "isMoneyorderChecked"
                    {
                        Form.remove(at: j)
                        j = j-1
                    }
                    else
                    {
                        j = j+1
                    }
                    
                }
                tempFormArray = Form
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
        
    }
    
    // Sub Fields Insertion in the form on the value changed
    
    func showMangoFields(_ cell: FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "mangopayHeading"
            {
                index = i
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        index += 1
        if (form.valuesByKey["mangopayHeading"] != nil)
        {
            if form.valuesByKey["mangopayHeading"] as! Int == 1
            {
                for i in 0 ..< (FieldsArray.count) where i < FieldsArray.count
                {
                    let ndic = FieldsArray[i] as! NSDictionary
                    let name = ndic["name"] as! String
                    if name == "first_name" || name == "last_name" || name == "email_mango" || name == "birthday" || name == "nationality" || name == "residence" || name == "isMangopay"
                    {
                        Form.insert(ndic, at: index)
                        index += 1
                    }
                }
                tempFormArray = Form
            }
            if form.valuesByKey["mangopayHeading"] as! Int == 0
            {
                
                var j : Int = 0
                while j < Form.count
                {
                    let dic = Form[j] as! NSDictionary
                    let name = dic["name"] as! String
                    
                    if name == "first_name" || name == "last_name" || name == "email_mango" || name == "birthday" || name == "nationality" || name == "residence" || name == "isMangopay"
                    {
                        Form.remove(at: j)
                        j = j-1
                    }
                    else
                    {
                        j = j+1
                    }
                    
                }
                tempFormArray = Form
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
        
        
    }
    
    func showStripeFields(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "stripHeading"
            {
                index = i
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        index += 1
        if (form.valuesByKey["stripHeading"] != nil)
        {
            if form.valuesByKey["stripHeading"] as! Int == 1
            {
                for i in 0 ..< (FieldsArray.count) where i < FieldsArray.count
                {
                    let ndic = FieldsArray[i] as! NSDictionary
                    let name = ndic["name"] as! String
                    if name == "secret" || name == "publishable" || name == "isStripeChecked"
                    {
                        Form.insert(ndic as AnyObject, at: index)
                        index += 1
                    }
                }
//                var ndic = FieldsArray[0] as! NSDictionary
//                Form.insert(ndic as AnyObject, at: index)
//                index += 1
//                ndic = FieldsArray[1] as! NSDictionary
//                Form.insert(ndic as AnyObject, at: index)
                tempFormArray = Form
            }
            if form.valuesByKey["stripHeading"] as! Int == 0
            {
                var j : Int = 0
                while j < Form.count
                {
                    let dic = Form[j] as! NSDictionary
                    let name = dic["name"] as! String
                    
                    if ( name == "secret" || name == "publishable" || name == "isStripeChecked")
                    {
                        Form.remove(at: j)
                        j = j-1
                    }
                    else
                    {
                        j = j+1
                    }
                    
                }
                tempFormArray = Form
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
    }
    
    func showPaypalFields(_ cell : FXFormFieldCellProtocol)
    {

        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "PaypalHeading"
            {
                index = i
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        index += 1
        if (form.valuesByKey["PaypalHeading"] != nil)
        {
            if form.valuesByKey["PaypalHeading"] as! Int == 1
            {
                for i in 0 ..< (FieldsArray.count) where i < FieldsArray.count
                {
                    let ndic = FieldsArray[i] as! NSDictionary
                    let name = ndic["name"] as! String
                    if name.range(of: "paypal") != nil || name == "isPaypalChecked"
                    {
                        Form.insert(ndic, at: index)
                        index += 1
                    }
                }
//                var ndic = FieldsArray[2] as! NSDictionary
//                Form.insert(ndic as AnyObject, at: index)
//                index += 1
//                ndic = FieldsArray[3] as! NSDictionary
//                Form.insert(ndic as AnyObject, at: index)
//                index += 1
//                ndic = FieldsArray[4] as! NSDictionary
//                Form.insert(ndic as AnyObject, at: index)
//                index += 1
//                ndic = FieldsArray[5] as! NSDictionary
//                Form.insert(ndic as AnyObject, at: index)
                tempFormArray = Form
            }
            if form.valuesByKey["PaypalHeading"] as! Int == 0
            {
                
                var j : Int = 0
                while j < Form.count
                {
                    let dic = Form[j] as! NSDictionary
                    let name = dic["name"] as! String
                    
                    if ( name == "email_paypal" || name == "username_paypal" || name == "password_paypal" || name == "signature_paypal" || name == "isPaypalChecked")
                    {
                        Form.remove(at: j)
                        j = j-1
                    }
                    else
                    {
                        j = j+1
                    }
                    
                }
                
                
                /*for i in 0 ..< (Form.count) where i < Form.count
                {
                    let dic = Form[i] as! NSDictionary
                    let name = dic["name"] as! String
                    if name == "email_paypal"
                    {
                        Form.remove(at: i)
                        Form.remove(at: i)
                        Form.remove(at: i)
                        Form.remove(at: i)
                    }
                } */
                tempFormArray = Form
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
        
        
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
            if name == "checkHeading"
            {
                index = i
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        index += 1
        if (form.valuesByKey["checkHeading"] != nil)
        {
            if form.valuesByKey["checkHeading"] as! Int == 1
            {
                for i in 0 ..< (FieldsArray.count) where i < FieldsArray.count
                {
                    let ndic = FieldsArray[i] as! NSDictionary
                    let name = ndic["name"] as! String
                    if name == "bychequeGatewayDetail" || name == "isByChequeChecked"
                    {
                        Form.insert(ndic as AnyObject, at: index)
                        index += 1
                    }
                }
                tempFormArray = Form
            }
            
//            if formValue["isByChequeChecked"] as! Int == 1
//            {
//                print("hello")
//            }
            
            if form.valuesByKey["checkHeading"] as! Int == 0
            {
                var j : Int = 0
                while j < Form.count
                {
                    let dic = Form[j] as! NSDictionary
                    let name = dic["name"] as! String
                    
                    if name == "bychequeGatewayDetail" || name == "isByChequeChecked"
                    {
                        Form.remove(at: j)
                        j = j-1
                    }
                    else
                    {
                        j = j+1
                    }
                    
                }
                tempFormArray = Form
            }
        }
        FormforRepeat = Form
        self.formController.form = CreateNewForm()
        self.formController.tableView.reloadData()
        
        
    }
    
    func showCashOnDelivery(_ cell : FXFormFieldCellProtocol)
    {
        let form = cell.field.form as! CreateNewForm
        Form.removeAll(keepingCapacity: false)
        Form = tempFormArray
        var index = Int()
        for i in 0 ..< (Form.count) where i < Form.count
        {
            let dic = Form[i] as! NSDictionary
            let name = dic["name"] as! String
            if name == "cashHeading"
            {
                index = i
            }
            if (form.valuesByKey["\(name)"] != nil)
            {
                Formbackup["\(name)"] = form.valuesByKey["\(name)"]
            }
        }
        index += 1
        if (form.valuesByKey["cashHeading"] != nil)
        {
            if form.valuesByKey["cashHeading"] as! Int == 1
            {
                for i in 0 ..< (FieldsArray.count) where i < FieldsArray.count
                {
                    let ndic = FieldsArray[i] as! NSDictionary
                    let name = ndic["name"] as! String
                    if name == "isCodChecked"
                    {
                        Form.insert(ndic as AnyObject, at: index)
                        index += 1
                    }
                }
                tempFormArray = Form
            }
            
//            if formValue["cashHeading"] as! Int == 1
//            {
//                print("hello")
//            }
            
            if form.valuesByKey["cashHeading"] as! Int == 0
            {
                for i in 0 ..< (Form.count) where i < Form.count
                {
                    let dic = Form[i] as! NSDictionary
                    let name = dic["name"] as! String
                    if name == "isCodChecked"
                    {
                        Form.remove(at: i)
                    }
                }
                tempFormArray = Form
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

