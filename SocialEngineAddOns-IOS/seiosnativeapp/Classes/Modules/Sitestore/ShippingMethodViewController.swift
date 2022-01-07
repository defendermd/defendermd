//
//  ShippingMethodViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 10/08/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
var Currencycode = NSString()
@objcMembers class ShippingMethodViewController: FXFormViewController
{
    var popAfterDelay:Bool!
    var shippingForm = [AnyObject]()
    var shippingformValue = NSMutableDictionary()
    var countyrKey = NSString()
    var stateDIC = NSMutableDictionary()
    var index = Int()
    var urlPath : String?
    var contentType : String?
    var backupForm = [AnyObject]()
    var logoutCartarr = NSMutableArray()
    var leftBarButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ShippingMethodViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        popAfterDelay = false
        self.title = NSLocalizedString("Shipping Methods", comment: "")
        
        if contentType == "AddShippingMethod" {
            conditionalForm = "shippingMethod"
        } else {
            conditionalForm  = "checkout"
        }
        
        
        
        isCreateOrEdit = true
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
        if logoutUser == true
        {
            //Getting Record from Core data
            GetrecartData()
            
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
        
         _ = self.navigationController?.popViewController(animated: false)
        
    }

    // MARK: Getting Checkout Form
    func generateShippingMethodForm()
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
            
            if contentType == "AddShippingMethod" {
                path = urlPath!
                parameter["oauth_secret"] = oauth_secret
            } else
            {
                path = "sitestore/checkout/shipping"
                parameter["store_id"] = Store_id
            }
            
            
            /*
             parameter["store_id"] = Store_id
            path = "sitestore/checkout/shipping" */
            
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
                        Form.removeAll(keepingCapacity: false)
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if let dic = succeeded["body"] as? NSDictionary
                        {
                            if let formarr = dic["form"] as? NSArray
                            {
                                  Form = formarr as [AnyObject]
                            }
                            if let StrCurrency = dic["currency"] as? String
                            {
                                Currencycode = StrCurrency as NSString
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
    // Get record from core data into array
    func GetrecartData()
    {
        let results = GetallRecord()
        if results.count>0
        {
            for result in results
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
    func submitForm(_ cell: FXFormFieldCellProtocol) {
//        self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
        let form = cell.field.form as! CreateNewForm
        
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            
            view.isUserInteractionEnabled = false
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var dic = Dictionary<String, String>()
            
            for (key, value) in form.valuesByKey{
                let string = "\(key)"
                
                if (key as! NSString == "shippingmethod_id"){
                    dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                    
                }
                else if string.range(of:"shipping_method_") != nil
                {
                    dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                }
                else
                {
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
            checkoutDic = dic
            dic["store_id"] = Store_id
            if logoutUser == true
            {
                if logoutCartarr.count>0
                {
                    // Convert core data array into json object
                    dic["productsData"] = GetjsonObject(data:logoutCartarr)
                }
                
            }
            path = "sitestore/checkout/shipping"
            var parameter = [String:String]()
            parameter = dic

            // Send Server Request to Sign Up Form
            post(parameter,url: path , method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.view.alpha = 1.0
                    self.view.isUserInteractionEnabled = true
                    if msg
                    {
                        let presentedVC = PaymentMethodViewController()
                        self.navigationController?.pushViewController(presentedVC, animated: false)
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

