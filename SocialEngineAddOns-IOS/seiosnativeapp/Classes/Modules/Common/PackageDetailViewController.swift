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
//  PackageDetailViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 18/05/16.
//  Copyright © 2016 bigstep. All rights reserved.


import UIKit

class PackageDetailViewController: UIViewController
{
    var contentType : String!
    var url : String!
    var Formtittle : String =  ""
    var param: NSDictionary = [:]
    var responsedic:NSDictionary!
    var label1 : UILabel!
    var label2 : TTTAttributedLabel!
    var scrollView: UIScrollView!
    var leftBarButtonItem : UIBarButtonItem!
    var listingTypeId:Int!
    var isUpgradePackageScreen = false
    var popAfterDelay = false
    var redirect : Int = 0
    
    var eventExtensionCheck = false
    var extParam : NSDictionary!
    var extUrl : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = bgColor
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = bgColor
        scrollView.contentSize = view.bounds.size
        scrollView.sizeToFit()
        view.addSubview(scrollView)
        
        
        label1 = UILabel(frame: CGRect(x: 10, y: 5, width: 100, height: 30))
        label1.numberOfLines = 0
        label1.textColor = textColorDark
        label1.font = UIFont(name: fontName, size: 13)
        
        label2 = TTTAttributedLabel(frame: CGRect(x: 120, y: 12,width: self.view.frame.size.width-120 , height: 30))
        label2.numberOfLines = 0
        label2.textColor = textColorMedium
        label2.font = UIFont(name: fontName, size: 13)
        
        self.scrollView.addSubview(label1)
        self.scrollView.addSubview(label2)
        
        var dic : NSDictionary!
        
        if self.contentType == "shippingMethod"
        {
           dic = responsedic["method"] as! NSDictionary
        }
        else
        {
            dic = responsedic["package"] as! NSDictionary
        }
        for (_,value) in dic
        {
            if value is NSDictionary{
                
                let dic = value as! NSDictionary
                let title = dic["label"] as? String
                if title != nil
                {
                    print(title!)
                    label1.text = "\(title!)"
                }
                
                label2.numberOfLines = 0
                label2.lineBreakMode = NSLineBreakMode.byWordWrapping
                let titlevalue = dic["value"]
                if titlevalue != nil
                {
                    if title == "Status"
                    {
                        if let titValue = dic["value"] as? Int
                        {
                            if titValue == 1
                            {
                                label2?.text = "Active"
                            }
                            else
                            {
                                label2?.text = "Inactive"
                            }
                        }
                        else
                        {
                            label2?.text = "\(titlevalue!)"
                        }
                        
                    }
                    else if title == "Price"{
                        
                        if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                            let defaults = UserDefaults.standard
                            if let name = defaults.object(forKey: "Currency")
                            {
                                if let changePrice = defaults.object(forKey: "PriceRate") as? Float {
                                    if let title = (titlevalue as? NSString)?.floatValue {
                                        let changePric = changePrice * title
                                        let showPrice = (String(format:"%.2f", changePric))
                                        
                                        label2?.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                    }
                                   
                                }
                            
                            }
                        }
                        else{
                            
                            label2?.text = "\(titlevalue!)"
                        }
                        
                       // label2?.text = "\(titlevalue!)"
                    }
                    else
                    {
                        label2?.text = "\(titlevalue!)"
                    }
                    
                }
                
                label2.sizeToFit()
                
                label1 = UILabel(frame: CGRect(x: 10, y: label2.frame.origin.y+label2.frame.size.height+10, width: 100, height: 30))
                label1.numberOfLines = 0
                label1.textColor = textColorDark
                label1.font = UIFont(name: fontName, size: 13)
                
                label2 = TTTAttributedLabel(frame: CGRect(x: 120, y: label1.frame.origin.y+5,width: self.view.frame.size.width-120 , height: 30))
                label2.numberOfLines = 0
                label2.textColor = textColorMedium
                label2.font = UIFont(name: fontName, size: 13)
                
                self.scrollView.addSubview(label1)
                self.scrollView.addSubview(label2)
            }
            else
            {
                //print("no")
            }
        }
   
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool)
    {
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
//        navigationController?.navigationBar.barTintColor = UIColor.white
        self.title = NSLocalizedString(Formtittle,  comment: "")
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(PackageDetailViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        let button   = UIButton(type: UIButton.ButtonType.system) as UIButton
        button.frame = CGRect(x: self.view.bounds.size.width-100, y: 0, width: 20, height: 20)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "Checkmark.png")!.maskWithColor(color: textColorPrime), for: UIControl.State())
        
        if isUpgradePackageScreen{
            button.addTarget(self, action: #selector(PackageDetailViewController.updatePackage), for: UIControl.Event.touchUpInside)
        }else{
            button.addTarget(self, action: #selector(PackageDetailViewController.send), for: UIControl.Event.touchUpInside)
        }
        if self.contentType == "shippingMethod"
        {
            print("")
        }
        else
        {
            let sendButton = UIBarButtonItem()
            sendButton.customView = button
            self.navigationItem.setRightBarButtonItems([sendButton], animated: true)
            sendButton.tintColor = textColorPrime
        }
        
        
        if redirect == 1
        {
            redirect = 0
            _ = self.navigationController?.popViewController(animated: false)
        }
        
    }
    
    @objc func cancel()
    {
        _ = self.navigationController?.popViewController(animated: true)

    }
    
    @objc func send()
    {
        redirect = 1
        isCreateOrEdit = true
        let presentedVC = FormGenerationViewController()
        print(contentType)
        switch contentType {
            
        case "StoreCreate":
            presentedVC.formTitle = NSLocalizedString("Create New Store", comment: "")
            presentedVC.contentType = self.contentType
            presentedVC.param = param
            presentedVC.url = "sitestore/create"
            break
            
        case "Page":
            presentedVC.formTitle = NSLocalizedString("Create New Page", comment: "")
            presentedVC.contentType = self.contentType
            presentedVC.param = param
            presentedVC.url = "sitepages/create"
            break
        case "listings":
            presentedVC.formTitle = NSLocalizedString("Post A New Listing", comment: "")
            presentedVC.contentType = "listings"
            presentedVC.param = param
            presentedVC.url = "listings/create"
            presentedVC.listingTypeId = listingTypeId
            break
        case "sitegroup":
            presentedVC.formTitle = NSLocalizedString("Create New Group", comment: "")
            presentedVC.contentType = self.contentType
            presentedVC.param = param
            presentedVC.url = "advancedgroups/create"
            
            
        default:
            presentedVC.formTitle = NSLocalizedString("Create New Event", comment: "")
            presentedVC.contentType = self.contentType
            if self.eventExtensionCheck == true {
                presentedVC.eventExtensionCheck = true
                presentedVC.param = self.extParam//self.extensionParam
                presentedVC.url = self.extUrl//self.extensionUrl
                let dict = param//(menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                let packageId = dict["package_id"] as! Int
                presentedVC.packageId = packageId
            }
            else{
            presentedVC.param = param
            presentedVC.url = "advancedevents/create"
            }
        }
        
        let nativationController = UINavigationController(rootViewController: presentedVC)
        nativationController.modalPresentationStyle = .fullScreen
        self.present(nativationController, animated:false, completion: nil)
    }
    
    @objc func updatePackage() {
        
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
            
            for (key, value) in param{
                
                if let id = value as? NSNumber {
                    parameters["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    parameters["\(key)"] = receiver as String
                }
                
            }
            //print(parameters)
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
                    
                    storeDetailUpdate = true
                    storeUpdate = true
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
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
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
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true {
            cancel()
        }
    }
    
}
