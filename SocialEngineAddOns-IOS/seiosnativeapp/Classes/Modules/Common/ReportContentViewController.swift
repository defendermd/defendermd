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
//  ReportContentViewController.swift
//  seiosnativeapp

import UIKit

class ReportContentViewController: UIViewController {
    // Variable for Report Contents
    var param : NSDictionary = [:]
    var url : String!
    // var content_id :Int!
    // var contentType : String!
    var type:UILabel!
    var reportType:UIButton!
    var descriptionLabel :UILabel!
    var reportDescription : UITextView!
    var submit:UIButton!
    var reportTypeDictionary : NSDictionary = [:]
    var popAfterDelay:Bool!
    var rightButton : UIBarButtonItem!
    var leftBarButtonItem : UIBarButtonItem!
    
    
    // Initialize Report Class Objects
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = false
        view.backgroundColor = bgColor
        self.title = NSLocalizedString("Report", comment: "")
        popAfterDelay = false
        
        
        setNavigationImage(controller: self)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ReportContentViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        rightButton = UIBarButtonItem(title: NSLocalizedString("Report", comment: ""), style: UIBarButtonItem.Style.plain, target: self, action: #selector(ReportContentViewController.report))
        self.navigationItem.rightBarButtonItem = rightButton
        rightButton.isEnabled = false
        
        
        let title = createLabel(CGRect(x: 10, y: TOPPADING + 10, width: 300, height: 30), text: NSLocalizedString("Report", comment: ""), alignment: .left, textColor: textColorDark)
        title.font = UIFont(name: fontBold, size: FONTSIZELarge)
        view.addSubview(title)
        
        let subTitle = createLabel(CGRect(x: 10, y: getBottomEdgeY(inputView: title), width: view.bounds.width-20, height: 30), text: NSLocalizedString("Do you want to Report this?", comment: ""), alignment: .left, textColor: textColorDark)
        subTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
        view.addSubview(subTitle)
        
        
        type = createLabel(CGRect(x: 10, y: getBottomEdgeY(inputView: subTitle), width: view.bounds.width-20, height: 30), text: " ", alignment: .left, textColor: textColorDark)
        type.isHidden = true
        type.font = UIFont(name: fontBold, size: FONTSIZENormal)
        view.addSubview(type)
        
        reportType = createButton(CGRect(x: 10, y: getBottomEdgeY(inputView: type), width: view.bounds.width-20, height: 30),title: "", border: true,bgColor: false, textColor: textColorDark)
        reportType.addTarget(self, action: #selector(ReportContentViewController.reportTypeAction), for: .touchUpInside)
        reportType.isHidden = true
        reportType.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
        view.addSubview(reportType)
        
        
        descriptionLabel = createLabel(CGRect(x: 10, y: getBottomEdgeY(inputView: reportType), width: view.bounds.width-20, height: 30), text: "", alignment: .left, textColor: textColorDark)
        descriptionLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
        descriptionLabel.isHidden = true
        view.addSubview(descriptionLabel)
        
        
        reportDescription = createTextView(CGRect(x: 10,y: getBottomEdgeY(inputView: descriptionLabel), width: view.bounds.width-20, height: 150), borderColor: borderColorDark, corner: false)
        reportDescription.font = UIFont(name: fontName, size: FONTSIZENormal)
        reportDescription.isHidden = true
        view.addSubview(reportDescription)
        
        
        submit = createButton(CGRect(x: 10,y: getBottomEdgeY(inputView: reportDescription) + 10 , width: 200, height: 40), title: "", border: true, bgColor: true,textColor: textColorDark)
        //  submit.backgroundColor = navColor
        submit.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
        submit.isHidden = true
        submit.addTarget(self, action: #selector(ReportContentViewController.report), for: .touchUpInside)
        
        view.addSubview(submit)
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ReportContentViewController.resignKeyboard))
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap)
 

    }
    
    @objc func resignKeyboard(){
        reportDescription.resignFirstResponder()
    }
    
    //Generate Share Form On View Appear
    override func viewDidAppear(_ animated: Bool) {
        reportForm(param as NSDictionary,url: url)
        
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
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
        // popViewController After Delay
        if popAfterDelay == true {
            _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // Create Popup For Report Types
    @objc func reportTypeAction(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        for (_,value) in reportTypeDictionary{
            //print(key)
            alertController.addAction(UIAlertAction(title: (value as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                self.reportType.setTitle((value as! String), for: UIControl.State())
            }))
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else if  (UIDevice.current.userInterfaceIdiom == .pad){
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2 , width: 1, height: 1)
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    // MARK: - Server Connection For Blog Updation
    func reportForm(_ parameter: NSDictionary , url : String){
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
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            // Send Server Request to Report Form with content Type & content ID
            post(dic, url: url, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update Report Form
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            if let response = succeeded["body"] as? NSArray{
                                
                                for dic in (response as? [[String:Any]])! {
                                    
                                    let form = dic
                                    for (key, value) in form {
                                        
                                        if key == "type"
                                        {
                                            if value as! String == "Textarea"{
                                                self.descriptionLabel.isHidden = false
                                                
                                                self.descriptionLabel.text = dic["label"] as? String
                                                self.reportDescription.isHidden = false
                                            }
                                            if value as! String == "Submit"{
                                                
                                                self.rightButton.isEnabled = true
                                                self.submit.setTitle(dic["label"] as? String, for: UIControl.State())
                                            }
                                            if value as! String == "Select"{
                                                
                                                if let menu = dic["multiOptions"] as? NSDictionary{
                                                    self.reportTypeDictionary = menu
                                                    self.type.isHidden = false
                                                    self.type.text = dic["label"] as? String
                                                    self.reportType.setTitle(menu[""] as? String, for: UIControl.State())
                                                    self.reportType.isHidden = false
                                                }
                                                
                                            }
                                            
                                        }
                                    }
                                    
                                }
                            }
                            
                        }
                        
                        
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            self.popAfterDelay = true
                            
                        }
                        
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    
    @objc func report(){
        self.reportContent(param as NSDictionary, url: url)
    }
    
    // Submit Report Contents
    func reportContent(_ parameter: NSDictionary , url : String){
        removeAlert()
        // Report Form Validation
        reportDescription.resignFirstResponder()
        var error = ""
        if reportDescription.text == ""{
            error = NSLocalizedString("Please Enter Your Message.", comment: "")
            reportDescription.becomeFirstResponder()
        }
        
        // Find Category Id of Selected Report Type
        var category_id = ""
        for (key,_) in reportTypeDictionary{
            //print(value)
            if reportTypeDictionary["\(key)"] as? String == reportType.titleLabel?.text{
                category_id = key as! String
            }
        }
        
        if category_id == "" && error == ""{
            error = NSLocalizedString("Please Select Report Type.", comment: "")
        }
        
        if error != ""{
            self.view.makeToast(error, duration: 5, position: CSToastPositionCenter)
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
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            dic["description"] = "\(reportDescription.text)"
            dic["category"] = "\(category_id)"
            
            // Send Server Request to Report Contents
            post(dic, url: url, method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update
                        showToast(message: NSLocalizedString("Your action has been performed successfully.", comment: ""), controller: self)
                        self.popAfterDelay = true
                        self.createTimer(self)
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)
        
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
