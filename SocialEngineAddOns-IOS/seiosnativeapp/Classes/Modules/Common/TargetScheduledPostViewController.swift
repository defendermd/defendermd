//
//  TargetScheduledPostViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 02/04/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
var TargetDictionary = Dictionary<String, AnyObject>()
var ScheduleDisctionary = Dictionary<String, AnyObject>()
var SellDictionary = Dictionary<String , AnyObject>()
@objcMembers class TargetScheduledPostViewController: FXFormViewController, UIPopoverPresentationControllerDelegate {

    var popAfterDelay:Bool!
    var id:Int!
    var leftBarButtonItem : UIBarButtonItem!
    var contentType = ""
    
    // Initialization of class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        sellUpdate = false
        
        let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel",  comment: ""), style:.plain , target:self , action: #selector(TargetScheduledPostViewController.goBack))
        cancel.tintColor = textColorPrime
        self.navigationItem.leftBarButtonItem = cancel
        
        if self.contentType != "Sell" {
        let remove = UIBarButtonItem(title: NSLocalizedString("Remove",  comment: ""), style:.plain , target:self , action: #selector(TargetScheduledPostViewController.goBack))
        remove.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = remove
        }
        
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
        generateTargetForm()
        popAfterDelay = false
        
    }
    
    func RemoveValue(){
        Formbackup.removeAllObjects()
        self.dismiss(animated: false, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.contentType == "" {
            self.title = NSLocalizedString("Target Your Post", comment: "")
        }
        else if self.contentType == "Sell"{
            self.title = NSLocalizedString("Sell Something", comment: "")
        }
        else{
            self.title = NSLocalizedString("Schedule Post", comment: "")
        }
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        // Initialization of Timer
       self.createTimer(self)
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer() {
        stop()
        
        if popAfterDelay == true{
            self.title = ""
            self.dismiss(animated: false, completion: nil)
            
        }
    }
    
    // MARK: - Server Connection For Blog Form Creation & Submission
    
    // FXFormForm Submission for Create or Edit Blog
    func submitForm(_ cell: FXFormFieldCellProtocol) {
        
        //we can lookup the form from the cell if we want, like this:
        
        let form = cell.field.form as! CreateNewForm
        var error = ""
        let errorTitle = "Error"
       // self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            activityIndicatorView.center = view.center
            
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            
            var dic = Dictionary<String, String>()
            for (key, value) in form.valuesByKey{
                let string = "\(key)"
                if (key as! NSString == "draft") || (key as! NSString == "category_id") || (key as! NSString == "auth_view") || (key as! NSString == "auth_comment") || (key as! NSString == "who") || (key as! NSString == "min_age") || (key as! NSString == "max_age"){
                    dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                }
                else if string.range(of: "alias_city") != nil || string.range(of: "alias_gender") != nil || string.range(of: "alias_country") != nil
                {
                    dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                }
                    
                else if string.hasSuffix("_alias_"){
                    
                    if  form.valuesByKey["\(key)"] is String {
                        if findKeyForValue(form.valuesByKey["\(key)"] as! String) != "" {
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
                    
                    if  form.valuesByKey["\(key)"] is NSNumber{
                        if let receiver = value as? NSString {
                            dic["\(key)"] = receiver as String
                        }
                        if let receiver = value as? Int {
                            dic["\(key)"] = String(receiver)
                        }
                        
                    }
                }
                else
                {
                    if let receiver = value as? Date {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        dic["\(key)"] = dateFormatter.string(from: receiver)

                    }
                    if let receiver = value as? NSString {
                        dic["\(key)"] = receiver as String
                    }
                    if let receiver = value as? Int {
                        dic["\(key)"] = String(receiver)
                    }
                }
            }
            
            if self.contentType == "" {
                TargetDictionary.update(dic as Dictionary<String, AnyObject>)
            }
            else if self.contentType == "Sell"{
                SellDictionary.update(dic as Dictionary<String, AnyObject>)
            }
            else{
                ScheduleDisctionary.update(dic as Dictionary<String, AnyObject>)
            }
            //print(TargetDictionary)
            //print(ScheduleDisctionary)
            
            if self.contentType == "Sell"{
                sellUpdate = true
            }
            else{
                sellUpdate = false
            }
            
            
            for (key, _) in form.valuesByKey{
                
                
                if (form.valuesByKey["\(key)"] != nil)
                {
                    Formbackup["\(key)"] = form.valuesByKey["\(key)"]
                }
            }
            
            
            if self.contentType == "" {
                
            if (form.valuesByKey["min_age"] != nil) && (form.valuesByKey["max_age"] != nil)
            {
                
                
                if (form.valuesByKey["max_age"] as! String != "") &&   (form.valuesByKey["min_age"] as! String != "") {
                    
                    let maxAge = Int(form.valuesByKey["max_age"] as! String) ?? 0
                    let minAge = Int(form.valuesByKey["min_age"] as! String) ?? 0
                    
                    if maxAge  < minAge
                    {
                        error = NSLocalizedString("max age is less than min age.", comment: "")
                    }
                    
                    
                }
            }
           
                
                if error != ""{
                    activityIndicatorView.stopAnimating()
                    let alertController = UIAlertController(title: "\(errorTitle)", message:
                        error, preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                else{
                    self.popAfterDelay = true
                    updateUserData()
                   self.createTimer(self)
                }
                
            }
            else{
            
            self.popAfterDelay = true
            updateUserData()
           self.createTimer(self)
            }
            
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            
        }
        
        
    }
    
    // Create Request for Generation of Create/Edit Blog Form
    func generateTargetForm(){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            
            activityIndicatorView.center = view.center
            
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            var parameter = [String:String]()
            var path = ""
            
            parameter = ["":""]
            conditionalForm =  "TargetForm"
            
            path = "advancedactivity/feelings/get-status-form"
            
            if self.contentType == "" {
                
                TargetDictionary.removeAll()
            }
            else if self.contentType == "Sell"{
                SellDictionary.removeAll()
                let defaults = UserDefaults.standard
                defaults.set("Coding", forKey: "SellSomething")
            }
            else{
                ScheduleDisctionary.removeAll()
            }
            // Send Server Request for Create/Edit Blog Form
            post(parameter, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Add Value to Form Array & Values to formValue Array
                        Form.removeAll(keepingCapacity: false)
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        if let dic = succeeded["body"] as? NSDictionary{
                            
                            if self.contentType == "" {
                                
                                if let formArray1 = dic["form"] as? NSDictionary{
                                    
                                    let  formArray = formArray1["targetForm"] as? NSArray
                                    
                                    Form = formArray! as [AnyObject]
                                }
                            }
                            else if self.contentType == "Sell"{
                                if let formArray1 = dic["form"] as? NSDictionary{
                                    
                                    let  formArray = formArray1["sellingForm"] as? NSArray
                                    
                                    Form = formArray! as [AnyObject]
                                }
                            }
                                
                            else{
                                if let formArray1 = dic["form"] as? NSDictionary{
                                    
                                    let  formArray = formArray1["scheduleForm"] as? NSArray
                                    
                                    Form = formArray! as [AnyObject]
                                }
                            }
                            
                        }
                        
                        tempFormArray = Form
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
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @objc func goBack()
    {
        self.title = ""
        self.dismiss(animated: false, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
