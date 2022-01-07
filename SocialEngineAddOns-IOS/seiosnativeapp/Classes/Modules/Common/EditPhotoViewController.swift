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


//
//  EditPhotoViewController.swift
//  seiosnativeapp
//
//

import UIKit

@objcMembers class EditPhotoViewController: FXFormViewController, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    var parameters:NSDictionary!
    var url:String!
    var popAfterDelay:Bool!
    // var groupID:Int!
    // var photoID:Int!
    var listingTypeId : Int!
    var listingPhotoId : Int!
    var contentType = ""
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = bgColor
        
        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Edit Photo", comment: "")
        popAfterDelay = false
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(EditPhotoViewController.cancel))
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
    
    @objc func cancel(){
        dismiss(animated: false, completion: nil)
    }
    
    // Generate Filter Search Form On View Appear
    override func viewDidAppear(_ animated: Bool) {
        generateForm(url)
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
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true {
            cancel()
        }
    }
    
    // MARK: - Server Connection For Form Generation
    
    // Generation of Filter Search Form
    func generateForm(_ url : String){
        let url = url
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var dic = Dictionary<String, String>()
            
            //              if let photoID = parameters["photo_id"]{
            //                url += "\(url)/\(String(photoID))"
            //            }
            
            if parameters != nil
            {
                for (key, value) in parameters{
                    
                    if let id = value as? NSNumber {
                        dic["\(key)"] = String(id as! Int)
                    }
                    
                    if let receiver = value as? NSString {
                        dic["\(key)"] = receiver as String
                    }
                }
                
            }
            else
            {
                parameters = ["" : "" ]
            }
            if self.contentType == "listings"{
                
                conditionalForm = "listings"
                isCreateOrEdit = false
                
                dic["listingtype_id"] = "\(listingTypeId)"
                dic["photo_id"] = "\(listingPhotoId)"
            }
            // Create Server Request for Filter Search Form
            post(dic,url: url , method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        Form.removeAll(keepingCapacity: false)
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            
                            if let dic = succeeded["body"] as? NSDictionary{
                                if let formArray = dic["form"] as? NSArray{
                                    Form = formArray as [AnyObject]
                                }
                                if let formValues = dic["formValue"] as? NSDictionary{
                                    formValue = formValues
                                    isCreateOrEdit = false
                                }
                                
                                // Create Edit Photo Form
                                self.formController.form = CreateNewForm()
                                self.formController.tableView.frame.origin.y = 0
                                self.formController.tableView.reloadData()
                            }
                            
                        }
                    }else{
                        // Hanle Server Side Error
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
    
    // Submission For Filter serch Form
    func submitForm(_ cell: FXFormFieldCellProtocol) {
        removeAlert()
        //we can lookup the form from the cell if we want, like this:
        let form = cell.field.form as! CreateNewForm
        
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
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            for (key, value) in parameters{
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            //            param["values"] = "\(jsonString)"
            
            
            // Send Server Request to Group Photo
            
            post(dic,url: url , method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Sucess Update Blog
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            self.dismiss(animated: false, completion: nil)
                            //  groupUpdate = true
                        }
                        
                    }else{
                        // Handle server Side Error
                        if succeeded["message"] != nil{
                            self.dismiss(animated: false, completion: nil)
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
