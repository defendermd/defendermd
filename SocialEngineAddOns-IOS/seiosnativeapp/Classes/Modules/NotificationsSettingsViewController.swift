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

////
////  NotificationsSettingsViewController.swift
////  seiosnativeapp

import UIKit
@objcMembers class NotificationsSettingsViewController: FXFormViewController {
    var popAfterDelay:Bool!
    var id:Int!
    var url:String!
    var contentType:String!
    var multiDic: NSDictionary = [:]
    var leftBarButtonItem : UIBarButtonItem!
    // Initialization of class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        blogUpdate = false
        popAfterDelay = false
        if contentType != "advancedeventsview"
        {
            conditionalForm = "notificationSetting"
        }
        else
        {
            conditionalForm = "advancedeventsview"
        }
        
        self.title = NSLocalizedString("Notification Settings", comment: "")
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(NotificationsSettingsViewController.goBack))
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
      
    }
    
    
    // Generate Form On View Appear
    override func viewDidAppear(_ animated: Bool) {
        generateBlogForm()
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
            _ = navigationController?.popViewController(animated: true)

        }
    }
    
    
    // MARK: - Server Connection For Blog Form Creation & Submission
    
    // FXFormForm Submission for Create or Edit Blog
    func submitForm(_ cell: FXFormFieldCellProtocol) {
        
        //we can lookup the form from the cell if we want, like this:
        
        let form = cell.field.form as! CreateNewForm
        
        self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
        
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var dic = Dictionary<String, String>()
            var Repetvalues = "" as String
            if let option = multiDic["multiOptions"] as? NSDictionary
            {
                Repetvalues = getmultioptionvaluse(options: option, formdic: form)
                //print(Repetvalues)
//                for (key, value) in option
//                {
//                    let keys =  form.valuesByKey["\(value)"] as? Int
//                    if keys != nil
//                    {
//                        if keys != 0
//                        {
//                            days = "\(key)"
//                            form.valuesByKey.removeObject(forKey: value)
//                            if Repetvalues != ""
//                            {
//                                Repetvalues = "\(Repetvalues),\(days)"
//                            }
//                            else
//                            {
//                                Repetvalues = "\(days)"
//                            }
//
//                        }
//                        else
//                        {
//                            form.valuesByKey.removeObject(forKey: value)
//                        }
//                    }
//
//                }

            }
            
            for (key, value) in form.valuesByKey
            {
                
                if (key as! NSString == "draft") || (key as! NSString == "category_id") || (key as! NSString == "auth_view") || (key as! NSString == "auth_comment")
                {
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
            if Repetvalues != ""
            {
                dic["action_notification"] = "\(Repetvalues)"
            }
            // Conversion of Form Data in Json
            
            //Set Parameters (Token & Form Values) & path for Create/Edit Blog Form
            var parameter = [String:String]()
            parameter = dic
            if url == nil
            {
                url = "members/settings/notifications"
            }
            
            // Send Server Request to Create/Edit Blog Entries
            post(parameter,url: url , method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Sucess Update Blog
                        
                        
                        if succeeded["message"] != nil
                        {


                            showToast(message: succeeded["message"] as! String, controller: self)
                            self.popAfterDelay = true
                        }
                        
                        blogUpdate = true
                        blogDetailUpdate = true
                        self.createTimer(self)
                        
                        
                    }
                    else
                    {
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg)
        }
        
        
    }


    // Create Request for Generation of Create/Edit Blog Form
    func generateBlogForm(){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
//
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            //Set Parameters & path for Create/Edit Blog Form
            var parameter = [String:String]()
            parameter = ["":""]
            if url == nil
            {
                url = "members/settings/notifications"
            }
            // Send Server Request for Create/Edit Blog Form
            post(parameter, url: url, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Add Value to Form Array & Values to formValue Array
                        Form.removeAll(keepingCapacity: false)
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if let dic = succeeded["body"] as? NSDictionary{
                            // if let response = dic["response"] as? NSDictionary{
                            if let formArray = dic["form"] as? NSArray{
                                Form = formArray as [AnyObject]
                                for key in Form{
                                    // Create element Dictionary for every FXForm Element
                                    
                                    if let dic = (key as? NSDictionary)
                                    {
                                        if dic["name"] as? String == "action_notification"
                                        {
                                            self.multiDic = dic
                                        }
                                    }
                                }
                                
                            }
                            if let formValues = dic["formValue"] as? NSDictionary{
                                formValue = formValues
                            }
                            else if let formValues = dic["formValues"] as? NSDictionary{
                                formValue = formValues
                            }
                            else if let formValues = dic["formValues"] as? NSArray{
                                formValuearr = formValues
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
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg)
        }
        
    }
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
