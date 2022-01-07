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
////  GeneralSettingsController.swift
////  seiosnativeapp

import UIKit



@objcMembers class GeneralSettingsController: FXFormViewController {
    var popAfterDelay:Bool!
    var id:Int!
    var leftBarButtonItem : UIBarButtonItem!
    // Initialization of class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        conditionalForm = "generalSettings"
        isCreateOrEdit = false
        blogUpdate = false
        popAfterDelay = false
        self.title = NSLocalizedString("General Settings", comment: "")
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(GeneralSettingsController.goBack))
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
    // FXFormForm Submission for Create or Edit Blog
    func submitForm(_ cell: FXFormFieldCellProtocol) {
        
        //we can lookup the form from the cell if we want, like this:
        
        self.formController.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        let form = cell.field.form as! CreateNewForm
        let error = ""
        if error != ""{
            showAlertMessage(view.center , msg: error)
            return
        }
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
            for (key, value) in form.valuesByKey{
                
                if (key as! NSString == "draft") || (key as! NSString == "category_id") || (key as! NSString == "auth_view") || (key as! NSString == "auth_comment") || (key as! NSString == "timezone") || (key as! NSString == "locale"){
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
            
            // Conversion of Form Data in Json
            
            //Set Parameters (Token & Form Values) & path for Create/Edit Blog Form
            var parameter = [String:String]()
            var path = ""
            parameter = dic
            path = "members/settings/general"
            
            // Send Server Request to Create/Edit Blog Entries
            post(parameter,url: path , method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Sucess Update Blog
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            self.popAfterDelay = true
                            self.createTimer(self)
                        }
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
    
    
    // Create Request for Generation of Create/Edit Blog Form
    func generateBlogForm(){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            //Set Parameters & path for Create/Edit Blog Form
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            path = "members/settings/general"
            
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
                            // if let response = dic["response"] as? NSDictionary{
                            if let formArray = dic["form"] as? NSArray{
                                Form = formArray as [AnyObject]
                                //print(Form.count)
                                //print("form count")
                            }
                            if let formValues = dic["formValues"] as? NSDictionary{
                                formValue = formValues
                                
                            }
                        }
                        
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        // Create FXForm Form
                        self.formController.form = CreateNewForm()
                        self.formController.tableView.reloadData()
                        // })
                        
                        
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
    
    @objc func goBack(){
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
