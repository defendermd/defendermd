
//
//  BillingAndShippingViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 09/08/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

//var defaultCountry : String!
//var checkoutDic = [String:String]()
//var bilingid:Int!
//var shippingid:Int!

var placeandorder : Int = 0

@objcMembers class BuyersTicketViewController: FXFormViewController {
    
    var popAfterDelay:Bool!
    var shippingForm = [AnyObject]()
    var shippingformValue = NSMutableDictionary()
    var countyrKey = NSString()
    var stateDIC = NSMutableDictionary()
    var index = Int()
    var backupForm = [AnyObject]()
    var logoutCartarr = NSMutableArray()
    
    var param : NSDictionary = [:]
    var url : String!
    var contentType : String! = ""
    var formTitle:String!
    var info : UILabel!
    var info1 : String = ""
    var eventid : Int = 0
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        navigationSetUp()
        popAfterDelay = false
        conditionalForm  = "checkout"
        isCreateOrEdit = true
    
        generateCheckoutForm()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        Form = backupForm
        
        if placeandorder == 1
        {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        backupForm = Form
    }
    
    @objc func goBack()
    {
        placeandorder = 0
        self.dismiss(animated: true, completion: nil)
    }
    func navigationSetUp()
    {
        navigationController?.navigationBar.isHidden = false
        self.title = NSLocalizedString("Buyer's Info", comment: "")
        let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel",  comment: ""), style:.plain , target:self , action: #selector(BuyersTicketViewController.goBack))
        cancel.tintColor = textColorPrime
        self.navigationItem.leftBarButtonItem = cancel
    }
    // MARK: Getting Checkout Form
    func generateCheckoutForm()
    {
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
       
            activityIndicatorView.startAnimating()
            
            let path = url
            
            post(param as! Dictionary<String, String>, url: path!, method: "GET") { (succeeded, msg) -> () in
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
                                if let billingArray = formdic["buyerForm"] as? NSArray
                                {
                                    Form = billingArray as [AnyObject]
                                    InitialForm = billingArray as [AnyObject]
                                }
                                
                                if let shippingArray = formdic["tickerHolderForm"] as? NSArray
                                {
                                    self.shippingForm = shippingArray as [AnyObject]
                                    
                                }
                            }
                            
                            if let formdic = dic["formValues"] as? NSDictionary
                            {
                                if let formValues = formdic["buyerFormValues"] as? NSDictionary
                                {
                                    formValue = formValues
                                    
                                }
                                if let shipingformValues = formdic["tickerHolderFormvalues"] as? NSDictionary
                                {
                                    self.shippingformValue = shipingformValues as! NSMutableDictionary
                                    
                                    if let common = formValue["isCopiedDetails"] as? Int
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
        
        if form.valuesByKey["isCopiedDetails"] as! Bool == false
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
    
    
    // MARK: Submit Form
    func submitForm(_ cell: FXFormFieldCellProtocol)
    {
        self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
        let form = cell.field.form as! CreateNewForm
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            view.isUserInteractionEnabled = false
   
            activityIndicatorView.startAnimating()
            var dic = Dictionary<String, String>()
            for (key, value) in form.valuesByKey
            {
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
            
            dic["event_id"] = "\(eventid)"
            dic["order_info"] = "\(info1)"
            
            post(dic,url: url , method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.view.alpha = 1.0
                    self.view.isUserInteractionEnabled = true
                    if msg
                    {
                        if let body = succeeded["body"] as? String
                        {
                            let presentedVC = FormGenerationViewController()
                            presentedVC.formTitle = NSLocalizedString("Payment Method", comment: "")
                            presentedVC.contentType = ""
                            presentedVC.url = "advancedeventtickets/order/checkout"
                            placeandorder  = 1
                            
                            presentedVC.param = ["event_id":"\(self.eventid)","order_info":"\(self.info1)","buyer_info":"\(body)"]
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:false, completion: nil)
                        }
                    }
                    else
                    {
                        showToast(message: NSLocalizedString("Oops something went wrong !!", comment: ""), controller: self)
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

