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


//  PrivacySettingsController.swift
//  seiosnativeapp

import UIKit

@objcMembers class PrivacySettingsController: FXFormViewController {
    var popAfterDelay:Bool!
    var id:Int!
    var leftBarButtonItem : UIBarButtonItem!
    var multiDic: NSDictionary = [:]
    // Initialization of class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        blogUpdate = false
        popAfterDelay = false
        self.title = NSLocalizedString("Privacy Settings", comment: "")
        conditionalForm = "privacySettings"
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(PrivacySettingsController.goBack))
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
    @objc func stopTimer()
    {
        stop()
        if popAfterDelay == true
        {
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Server Connection For Blog Form Creation & Submission
    
    // FXFormForm Submission for Create or Edit Blog
    func submitForm(_ cell: FXFormFieldCellProtocol) {
        
        //we can lookup the form from the cell if we want, like this:
        
        let form = cell.field.form as! CreateNewForm
        let error = ""
        
        if error != ""{
            showAlertMessage(view.center , msg: error)
            return
        }
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            var dic = Dictionary<String, String>()
            var Repetvalues = "" as String
            

            // Getting Multipotion values
            if let option = multiDic["multiOptions"] as? NSDictionary
            {
                Repetvalues = getmultioptionvaluse(options: option, formdic: form)
                //print(Repetvalues)

            }
            
            var finalString = ""
            
            if Repetvalues != ""
            {                
                let arr = Repetvalues.components(separatedBy: ",")
//                dic["publishTypes"] = GetjsonObject(data:arr as AnyObject)
                
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: arr, options:  [])
                    finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                } catch _ as NSError {
                    // failure
                    //print("Fetch failed: \(error.localizedDescription)")
                }
            }
            
            for (key, value) in form.valuesByKey{
                if (key as! NSString == "comment") || (key as! NSString == "privacy") || (key as! NSString == "auth_view") || (key as! NSString == "auth_comment") || (key as! NSString == "show_alias_name")
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
            

            //Set Parameters (Token & Form Values) & path for Create/Edit Blog Form
            var parameters = [String:String]()
            var path = ""
            parameters = dic
            path = "members/settings/privacy"
            // Send Server Request to Create/Edit Blog Entries
//            post(parameter,url:path , method: "POST")
            
            postSetting(parameters, paramUrl:finalString,keyName:"publishTypes", url: path, method: "POST", postCompleted: { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        // On Sucess Update Blog
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 5.0)
                            self.popAfterDelay = true
                            self.createTimer(self)
                        }
                    }
                    else
                    {
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            self.createTimer(self)
                            
                        }
                    }
                })
            })
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg)
        }
        
        
    }
    
    // Create Request for Generation of Create/Edit Blog Form
    func generateBlogForm(){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            //Set Parameters & path for Create/Edit Blog Form
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            path = "members/settings/privacy"
            
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
                                for key in Form{
                                    // Create element Dictionary for every FXForm Element
                                    
                                    if let dic = (key as? NSDictionary)
                                    {
                                        if dic["name"] as? String == "publishTypes"
                                        {
                                            self.multiDic = dic
                                        }
                                    }
                                }

                            }
                            if let formValues = dic["formValues"] as? NSDictionary{
                                formValue = formValues
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
