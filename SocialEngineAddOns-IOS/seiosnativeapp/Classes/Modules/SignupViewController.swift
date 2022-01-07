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

//  SignupViewController.swift

import UIKit
var signupDictionary = Dictionary<String, String>()
var signupValidation = [AnyObject]()
var signupValidationKeyValue = [AnyObject]()
var validation = NSDictionary()
var validationMessage : String = ""
var profileType : String!
var InitialForm = [AnyObject]()
var signUpPhotoFlag = false
var signUpUserSubscriptionEnabled = false
var isEmailValidationEnabled = false
var OTP = Bool()
var OTPvalue : String = ""
var sign_up : Int = 0
var photoView = UIView()

@objcMembers class SignupViewController: FXFormViewController, UIPopoverPresentationControllerDelegate, TTTAttributedLabelDelegate {
    var popAfterDelay:Bool!
    var id:Int!
    var tempDic : NSDictionary!
    var leftBarButtonItem : UIBarButtonItem!
    var phoneno : String = ""
    var isOtpSend : Bool = false
    var checkBoxNameKey : String!
    // Initialization of class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.backgroundColor = bgColor
        
        self.navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(SignupViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = true
        }
        
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
        
        popAfterDelay = false
        self.title = NSLocalizedString("Sign Up", comment: "")
        conditionalForm = "signupAccountForm"
        generateSignUpForm()
    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true{
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func findValidator(key: String) -> Bool
    {
        for elements in Form
        {
            if let dic = elements as? NSDictionary
            {
                if let name = dic["name"] as? String
                {
                    if name == key
                    {
                        if let validator = dic["hasValidator"] as? String
                        {
                            if validator == "true" || validator == "True" || validator == "TRUE"
                            {
                                return true
                            }
                        }
                        else if let validator = dic["hasValidator"] as? Bool
                        {
                            if validator == true
                            {
                                return true
                            }
                        }
                    }
                }
                
            }
        }
        return false
    }
    
    // MARK: - Server Connection For Sign Up Form Creation & Submission
    
    // FXFormForm Submission for Sign Up Form
    func submitForm(_ cell: FXFormFieldCellProtocol) {
        // Form = InitialForm
        //we can lookup the form from the cell if we want, like this:
        
        let form = cell.field.form as! CreateNewForm
        var error = ""
        if (form.valuesByKey["email"] != nil){
            OTPvalue = form.valuesByKey["email"] as! String
            OTP = OTPvalue.contains("@")
            if ((form.valuesByKey["email"] as! String) == "") &&  error == ""{
                error = NSLocalizedString("Please enter email.", comment: "")
            }
        }
        
        if (form.valuesByKey["emailaddress"] != nil){
            OTPvalue = form.valuesByKey["emailaddress"] as! String
            
            OTP = OTPvalue.contains("@")
            if ((form.valuesByKey["emailaddress"] as! String) == "") &&  error == ""{
                error = NSLocalizedString("Please enter email.", comment: "")
            }
        }
        
        if ((form.valuesByKey["profile_type"] == nil)  || (form.valuesByKey["profile_type"] as! String) == "") && error == ""
        {
            let hasValidator = findValidator(key: "profile_type")
            if hasValidator
            {
                error = NSLocalizedString("Please enter profile type.", comment: "")
            }
        }
        
        if (form.valuesByKey["country_code"] != nil){
            if form.valuesByKey["country_code"] is NSNumber{
                country_code = (form.valuesByKey["country_code"] as! NSNumber).stringValue
            }
            else{
                country_code = form.valuesByKey["country_code"] as! String
            }
        }
        
        if ((form.valuesByKey["phoneno"] == nil) || (form.valuesByKey["phoneno"] as! String) == "") &&  error == ""
        {
            let hasValidator = findValidator(key: "phoneno")
            if hasValidator
            {
                error = NSLocalizedString("Please enter phone number.", comment: "")
            }
        }
        
        if ((form.valuesByKey["password"] == nil) || (form.valuesByKey["password"] as! String) == "") &&  error == ""
        {
            let hasValidator = findValidator(key: "password")
            if hasValidator
            {
                error = NSLocalizedString("Please enter password.", comment: "")
            }
        }
        
        if (form.valuesByKey["photo"] == nil)  &&  error == ""
        {
            let hasValidator = findValidator(key: "photo")
            if hasValidator
            {
                error = NSLocalizedString("Please upload the photo-It is required.",comment: "")
            }
        }
        
        if(facebook_uid != nil)
        {
            if(form.valuesByKey["password"] != nil){
                if ((form.valuesByKey["password"] as! String) == "") &&  error == ""{
                    error = NSLocalizedString("Please enter the password.", comment: "")
                }
            }
            if(form.valuesByKey["passconf"] != nil){
                if ((form.valuesByKey["passconf"] as! String) == "") &&  error == ""{
                    error = NSLocalizedString("Please enter the confirm password.", comment: "")
                }
            }
        }
        
        if(form.valuesByKey["username"] != nil){
            if ((form.valuesByKey["username"] as! String) == "") &&  error == ""{
                error = NSLocalizedString("Please enter username.", comment: "")
            }
        }
        
        for (key, _) in form.valuesByKey{
            if (key as! NSString == "profile_type"){
                profileType = findKeyForValue(form.valuesByKey["\(key)"] as! String)
            }
        }
        
        if error != ""{
            let alertController = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            if (form.valuesByKey["photo"]) != nil
            {
                let imageArray = [form.valuesByKey["photo"] as! UIImage]
                filePathArray.removeAll(keepingCapacity: false)
                filePathArray = saveFileInDocumentDirectory(imageArray)
            }
            else
            {
                filePathArray.removeAll(keepingCapacity: false)
            }
            
            if isEnableOtp != false {
                if (form.valuesByKey["phoneno"] != nil){
                    
                    phoneno = form.valuesByKey["phoneno"] as! String
                    OTPvalue = form.valuesByKey["phoneno"] as! String
                }
                // Check Internet Connection
                if Reachabable.isConnectedToNetwork() {
                    view.isUserInteractionEnabled = false
                    UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
                    activityIndicatorView.center = self.view.center
                    activityIndicatorView.startAnimating()
                    var dic = Dictionary<String, String>()
                    for (key, value) in form.valuesByKey{
                        
                        if (key as! NSString == "draft") || (key as! NSString == "category_id") || (key as! NSString == "auth_view") || (key as! NSString == "auth_comment" || (key as! NSString == "timezone") || (key as! NSString == "language") || (key as! NSString == "profile_type")){
                            dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                        }
                        else{
                            if let receiver = value as? NSString {
                                dic["\(key)"] = receiver as String
                            }
                            if let receiver = value as? Int {
                                dic["\(key)"] = String(receiver)
                            }
                            if let receiver = value as? Date {
                                //let tempString = String(describing: receiver)
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                dic["\(key)"] = dateFormatter.string(from: receiver)
                                //dic["\(key)"] = String(describing: receiver)
                            }
                            if signUplayoutType == true && facebook_uid == nil{
                                dic["fields_validation"] = "1"
                                
                            }
                            else{
                                dic["fields_validation"] = "0"
                            }
                        }
                        
                    }
                    //Set Parameters (Token & Form Values) & path for Sign Up Form
                    //  var path = ""
                    if(facebook_uid != nil)
                    {
                        // path = "signup/validations"
                        dic["account_validation"] = "1"
                        dic["facebook_uid"] = String(facebook_uid)
                        dic["code"] = "%2520"
                        dic["access_token"] = String(access_token)
                    }
                    else
                    {
                        dic["account_validation"] = "1"
                        if apple_id != ""{
                            dic["apple_id"] = "\(apple_id)"
                        }
                        //   path = "signup/validations"
                    }
                    
                    var parameter = [String:String]()
                    if signUplayoutType && facebook_uid == nil{
                        country_code = "+" + country_code
                    }
                    parameter = ["emailaddress":OTPvalue,"country_code":country_code]
                    // Send Server Request to Sign Up Form
                    post(parameter,url: "otpverifier/verify-mobileno" , method: "POST") { (succeeded, msg) -> () in
                        
                        DispatchQueue.main.async(execute: {
                            activityIndicatorView.stopAnimating()
                            UIApplication.shared.keyWindow?.willRemoveSubview(activityIndicatorView)
                            self.view.alpha = 1.0
                            self.view.isUserInteractionEnabled = true
                            if msg{
                                
                                var otpDuration :Int = 0
                                if let body = succeeded["body"] as? NSDictionary
                                {
                                    if let subsResponse = succeeded["body"] as? NSDictionary{
                                        if let Response = subsResponse["response"] as? NSDictionary{
                                            if let duration = Response["duration"] as? Int
                                            {
                                                otpDuration  = duration
                                            }
                                        }
                                    }
                                    if let response = body["response"] as? NSDictionary
                                    {   otp = ""
                                        self.isOtpSend = response["isOtpSend"] as! Bool
                                        if self.isOtpSend == true {
                                            if let code = response["code"]
                                            {
                                                otp = "\(code)"
                                            }
                                            
                                            if let senttime = response["sent_time"] as? String
                                            {
                                                sent_time = senttime
                                            }
                                            
                                            if let expairyTime = response["expairyTime"] as? Int64
                                            {
                                                expairy_time = expairyTime
                                            }
                                        }
                                    }
                                }
                                if Reachabable.isConnectedToNetwork() {
                                    
                                    self.view.isUserInteractionEnabled = false
                                    UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
                                    activityIndicatorView.center = self.view.center
                                    activityIndicatorView.startAnimating()
                                    var dic = Dictionary<String, String>()
                                    for (key, value) in form.valuesByKey{
                                        
                                        if (key as! NSString == "draft") || (key as! NSString == "category_id") || (key as! NSString == "auth_view") || (key as! NSString == "auth_comment" || (key as! NSString == "timezone") || (key as! NSString == "language") || (key as! NSString == "profile_type")){
                                            dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                                        }else{
                                            if let receiver = value as? NSString {
                                                dic["\(key)"] = receiver as String
                                            }
                                            if let receiver = value as? Int {
                                                dic["\(key)"] = String(receiver)
                                            }
                                            if let receiver = value as? Date {
                                                //let tempString = String(describing: receiver)
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                                dic["\(key)"] = dateFormatter.string(from: receiver)
                                                //dic["\(key)"] = String(describing: receiver)
                                            }
                                            if signUplayoutType == true && facebook_uid == nil{
                                                dic["fields_validation"] = "1"
                                                
                                            }
                                            else{
                                                dic["fields_validation"] = "0"
                                            }
                                        }
                                        
                                    }
                                    //Set Parameters (Token & Form Values) & path for Sign Up Form
                                    var path = ""
                                    
                                    
                                    if signUplayoutType == true && facebook_uid == nil{
                                        path = "sitequicks"
                                        self.tempDic = nil
                                        dic["account_validation"] = "1"
                                        dic["ip"] = "127.0.0.1"
                                        if(facebook_uid != nil)
                                        {
                                            path = "signup?facebook_uid=" + String(facebook_uid) + "&code=%20%20&access_token=" + String(access_token)
                                        }
                                    }
                                    else{
                                        if(facebook_uid != nil)
                                        {
                                            path = "signup/validations"
                                            dic["account_validation"] = "1"
                                            dic["facebook_uid"] = String(facebook_uid)
                                            dic["code"] = "%2520"
                                            dic["access_token"] = String(access_token)
                                        }
                                        else
                                        {
                                            dic["account_validation"] = "1"
                                            path = "signup/validations"
                                            if apple_id != ""
                                            {
                                                dic["apple_id"] = "\(apple_id)"
                                            }
                                        }
                                    }
                                    
                                    var checkBoxvalues = "" as String
                                    var checkKeys = String()
                                    var infoDic = Dictionary<String, String>()
                                    
                                    for i in 0 ..< (Form.count) where i < Form.count
                                    {
                                        let dic = Form[i] as! NSDictionary
                                        
                                        let type = dic["type"] as! String
                                        if type == "Multi_checkbox" || type == "MultiCheckbox" || type == "Multiselect"
                                        {
                                            checkBoxvalues = ""
                                            checkKeys = ""
                                            self.checkBoxNameKey = dic["name"] as! String
                                            multiDic = (dic["multiOptions"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                            
                                            if isCreateOrEdit{
                                                for (key, value) in multiDic
                                                {
                                                    let keys =  form.valuesByKey["\(value)"] as? Int
                                                    
                                                    if keys != nil
                                                    {
                                                        
                                                        if keys != 0
                                                        {
                                                            checkKeys = "\(key)"
                                                            if checkBoxvalues != ""
                                                            {
                                                                checkBoxvalues = "\(checkBoxvalues),\(checkKeys)"
                                                            }
                                                            else
                                                            {
                                                                checkBoxvalues = "\(checkKeys)"
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                
                                                for (key, value) in multiDic
                                                {
                                                    let keys =  form.valuesByKey["\(value)"] as? Int
                                                    
                                                    if keys != nil
                                                    {
                                                        
                                                        if keys != 0
                                                        {
                                                            checkKeys = "\(key)"
                                                            // form.valuesByKey.removeObject(forKey:value)
                                                            if checkBoxvalues != ""
                                                            {
                                                                checkBoxvalues = "\(checkBoxvalues),\(checkKeys)"
                                                            }
                                                            else
                                                            {
                                                                checkBoxvalues = "\(checkKeys)"
                                                            }
                                                            
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            if checkBoxvalues != ""
                                            {
                                                infoDic["\(self.checkBoxNameKey!)"] = "\(checkBoxvalues)"
                                                
                                            }
                                        }
                                    }
                                    
                                    var parameter = [String:String]()
                                    dic.update(infoDic)
                                    parameter = dic
                                    
                                    signupDictionary = dic
                                    
                                    fbEmail = ""
                                    
                                    
                                    if signUplayoutType == true && filePathArray.count > 0  && facebook_uid == nil {
                                        postForm(parameter, url: path, filePath: filePathArray, filePathKey: "photo" , SinglePhoto: true) { (succeeded, msg) -> () in
                                            
                                            
                                            DispatchQueue.main.async(execute: {
                                                activityIndicatorView.stopAnimating()
                                                self.view.alpha = 1.0
                                                self.view.isUserInteractionEnabled = true
                                                if msg{
                                                    
                                                    if signUplayoutType == true && facebook_uid == nil{
                                                        
                                                        if (OTP == false || self.phoneno != "") && self.isOtpSend == true
                                                        {
                                                            showToast(message: "Signed up successfully. You can edit your information anytime from your profile", controller: self)
                                                            sign_up = 1
                                                            facebook_uid = nil
                                                            let presentedVC = OtpVerificationViewController()
                                                            if succeeded["body"] != nil{
                                                                if let response = succeeded["body"] as? NSDictionary{
                                                                    presentedVC.tempDic = response
                                                                    if let userId = response["user_id"] as? Int{
                                                                        presentedVC.userId = userId
                                                                    }
                                                                    else if let  user = response["user"] as? NSDictionary
                                                                    {
                                                                        if let userId = user["user_id"] as? Int{
                                                                            presentedVC.userId = userId
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                            }
                                                            
                                                            presentedVC.duration  = otpDuration
                                                            self.navigationController?.pushViewController(presentedVC, animated: true)
                                                        }
                                                        else if signUpUserSubscriptionEnabled == true {
                                                            facebook_uid = nil
                                                            let alertController = UIAlertController(title: "Message", message:
                                                                NSLocalizedString("Signed up successfully. You can edit your information anytime from your profile. Please choose a Subscription Plan for your account.",comment: ""), preferredStyle: UIAlertController.Style.alert)
                                                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                                                                let presentedVC = SignupUserSubscriptionViewController()
                                                                if succeeded["body"] != nil{
                                                                    if let response = succeeded["body"] as? NSDictionary{
                                                                        
                                                                        if let userId = response["user_id"] as? Int{
                                                                            presentedVC.user_id = userId
                                                                        }
                                                                        else if let  user = response["user"] as? NSDictionary
                                                                        {
                                                                            if let userId = user["user_id"] as? Int{
                                                                                presentedVC.user_id = userId
                                                                            }
                                                                        }
                                                                        
                                                                    }
                                                                }
                                                                
                                                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                                            }))
                                                            
                                                            self.present(alertController, animated: true, completion: nil)
                                                            
                                                        }
                                                        else{
                                                            showToast(message: "Signed up successfully. You can edit your information anytime from your profile", controller: self)
                                                            if succeeded["body"] != nil{
                                                                if let _ = succeeded["body"] as? NSDictionary{
                                                                    // Perform Login Action
                                                                    if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                                                        DispatchQueue.main.async(execute:{
                                                                            mergeAddToCart()
                                                                            //UserDefaults.standard.removeObject(forKey: "AppleEmail")
                                                                            self.showHomePage()
                                                                        })
                                                                    }else{
                                                                        showToast(message: "Unable to Login", controller: self)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    else{
                                                        if (OTP == false || self.phoneno != "") && self.isOtpSend == true
                                                        {
                                                            sign_up = 1
                                                            let presentedVC = OtpVerificationViewController()
                                                            presentedVC.duration  = otpDuration
                                                            self.navigationController?.pushViewController(presentedVC, animated: true)
                                                        }
                                                        else
                                                        {
                                                            let presentedVC = SignupProfileFieldController()
                                                            self.navigationController?.pushViewController(presentedVC, animated: false)
                                                        }
                                                    }
                                                }
                                                else{
                                                    self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                                                    if succeeded["message"] != nil{
                                                        showToast(message: succeeded["message"] as! String, controller: self)
                                                        
                                                    }
                                                    else{
                                                        // self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                                                        if  (UIDevice.current.userInterfaceIdiom == .phone){
                                                            let a = validation
                                                            signupValidation.removeAll(keepingCapacity: false)
                                                            signupValidationKeyValue.removeAll(keepingCapacity: false)
                                                            for (key,value) in a  {
                                                                signupValidation.append(value as AnyObject)
                                                                signupValidationKeyValue.append(key as AnyObject)
                                                                
                                                            }
                                                            let count = signupValidation.count
                                                            for index in 0 ..< count {
                                                                if signupValidationKeyValue[index] as! NSString == "passconf"
                                                                {
                                                                    showToast(message: "Password - \(signupValidation[index] as! String)\n", controller: self)
                                                                }
                                                                else if signupValidationKeyValue[index] as! NSString == "password"
                                                                {
                                                                    showToast(message: "Password - \(signupValidation[index] as! String)\n", controller: self)
                                                                }
                                                                else if signupValidationKeyValue[index] as! NSString == "username"
                                                                {
                                                                    showToast(message: "Username - \(signupValidation[index] as! String)\n", controller: self)
                                                                }
                                                                else  if signupValidationKeyValue[index] as! NSString == "terms"
                                                                {
                                                                    showToast(message: "Terms - \(signupValidation[index] as! String)\n", controller: self)
                                                                }
                                                                else{
                                                                    showToast(message: "\(signupValidation[index] as! String)\n", controller: self)
                                                                }
                                                            }
                                                        }else{
                                                            let a = validation
                                                            signupValidation.removeAll(keepingCapacity: false)
                                                            for (_,value) in a  {
                                                                signupValidation.append(value as AnyObject)
                                                            }
                                                            let secondViewController = SignUpValidationController()
                                                            secondViewController.validationArray = signupValidation as NSArray?
                                                            secondViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                                                            secondViewController.preferredContentSize = CGSize(width: self.view.bounds.width*0.8,height: self.view.bounds.height*0.35)
                                                            let popoverpresentationviewcontroller = secondViewController.popoverPresentationController
                                                            popoverpresentationviewcontroller?.delegate = self
                                                            popoverpresentationviewcontroller?.permittedArrowDirections = UIPopoverArrowDirection()
                                                            popoverpresentationviewcontroller?.sourceRect = CGRect( x: 0, y: self.view.bounds.height/3 , width: self.view.bounds.width , height: self.view.bounds.height/3)
                                                            popoverpresentationviewcontroller?.sourceView = self.view
                                                            self.navigationController?.present(secondViewController, animated: false, completion: nil)
                                                        }
                                                    }
                                                }
                                            })
                                        }
                                        
                                    }
                                    else{
                                        // Send Server Request to Sign Up Form
                                        post(parameter,url: path , method: "POST") { (succeeded, msg) -> () in
                                            
                                            DispatchQueue.main.async(execute: {
                                                activityIndicatorView.stopAnimating()
                                                self.view.alpha = 1.0
                                                self.view.isUserInteractionEnabled = true
                                                if msg{
                                                    
                                                    if signUplayoutType == true && facebook_uid == nil{
                                                        
                                                        if (OTP == false || self.phoneno != "") && self.isOtpSend == true
                                                        {
                                                            showToast(message: "Signed up successfully. You can edit your information anytime from your profile", controller: self)
                                                            sign_up = 1
                                                            facebook_uid = nil
                                                            let presentedVC = OtpVerificationViewController()
                                                            if succeeded["body"] != nil{
                                                                if let response = succeeded["body"] as? NSDictionary{
                                                                    presentedVC.tempDic = response
                                                                    if let userId = response["user_id"] as? Int{
                                                                        presentedVC.userId = userId
                                                                    }
                                                                    else if let  user = response["user"] as? NSDictionary
                                                                    {
                                                                        if let userId = user["user_id"] as? Int{
                                                                            presentedVC.userId = userId
                                                                        }
                                                                    }
                                                                    
                                                                }
                                                            }
                                                            
                                                            presentedVC.duration  = otpDuration
                                                            self.navigationController?.pushViewController(presentedVC, animated: true)
                                                        }
                                                        else if signUpUserSubscriptionEnabled == true {
                                                            facebook_uid = nil
                                                            let alertController = UIAlertController(title: "Message", message:
                                                                NSLocalizedString("Signed up successfully. You can edit your information anytime from your profile. Please choose a Subscription Plan for your account.",comment: ""), preferredStyle: UIAlertController.Style.alert)
                                                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                                                                let presentedVC = SignupUserSubscriptionViewController()
                                                                if succeeded["body"] != nil{
                                                                    if let response = succeeded["body"] as? NSDictionary{
                                                                        
                                                                        if let userId = response["user_id"] as? Int{
                                                                            presentedVC.user_id = userId
                                                                        }
                                                                        else if let  user = response["user"] as? NSDictionary
                                                                        {
                                                                            if let userId = user["user_id"] as? Int{
                                                                                presentedVC.user_id = userId
                                                                            }
                                                                        }
                                                                        
                                                                    }
                                                                }
                                                                
                                                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                                            }))
                                                            
                                                            self.present(alertController, animated: true, completion: nil)
                                                            
                                                        }
                                                        else{
                                                            showToast(message: "Signed up successfully. You can edit your information anytime from your profile", controller: self)
                                                            if succeeded["body"] != nil{
                                                                if let _ = succeeded["body"] as? NSDictionary{
                                                                    // Perform Login Action
                                                                    if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                                                        DispatchQueue.main.async(execute:{
                                                                            mergeAddToCart()
                                                                            //UserDefaults.standard.removeObject(forKey: "AppleEmail")
                                                                            self.showHomePage()
                                                                        })
                                                                    }else{
                                                                        showToast(message: NSLocalizedString("Unable to Login",comment: ""), controller: self)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                    else{
                                                        if (OTP == false || self.phoneno != "") && self.isOtpSend == true
                                                        {
                                                            sign_up = 1
                                                            let presentedVC = OtpVerificationViewController()
                                                            presentedVC.duration  = otpDuration
                                                            self.navigationController?.pushViewController(presentedVC, animated: true)
                                                        }
                                                        else
                                                        {
                                                            let presentedVC = SignupProfileFieldController()
                                                            self.navigationController?.pushViewController(presentedVC, animated: false)
                                                        }
                                                    }
                                                }
                                                else{
                                                    self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                                                    if succeeded["message"] != nil{
                                                        showToast(message: succeeded["message"] as! String, controller: self)
                                                        
                                                    }
                                                    else{
                                                        
                                                        if  (UIDevice.current.userInterfaceIdiom == .phone){
                                                            let a = validation
                                                            signupValidation.removeAll(keepingCapacity: false)
                                                            signupValidationKeyValue.removeAll(keepingCapacity: false)
                                                            for (key,value) in a  {
                                                                signupValidation.append(value as AnyObject)
                                                                signupValidationKeyValue.append(key as AnyObject)
                                                                
                                                            }
                                                            let count = signupValidation.count
                                                            for index in 0 ..< count {
                                                                if signupValidationKeyValue[index] as! NSString == "passconf"
                                                                {
                                                                    showToast(message: "Password - \(signupValidation[index] as! String)\n", controller: self)
                                                                }
                                                                else if signupValidationKeyValue[index] as! NSString == "password"
                                                                {
                                                                    showToast(message: "Password - \(signupValidation[index] as! String)\n", controller: self)
                                                                }
                                                                else if signupValidationKeyValue[index] as! NSString == "username"
                                                                {
                                                                    showToast(message: "Username - \(signupValidation[index] as! String)\n", controller: self)
                                                                }
                                                                else  if signupValidationKeyValue[index] as! NSString == "terms"
                                                                {
                                                                    showToast(message: "Terms - \(signupValidation[index] as! String)\n", controller: self)
                                                                }
                                                                else{
                                                                    showToast(message: "\(signupValidation[index] as! String)\n", controller: self)
                                                                }
                                                            }
                                                        }else{
                                                            let a = validation
                                                            signupValidation.removeAll(keepingCapacity: false)
                                                            for (_,value) in a  {
                                                                signupValidation.append(value as AnyObject)
                                                            }
                                                            let secondViewController = SignUpValidationController()
                                                            secondViewController.validationArray = signupValidation as NSArray?
                                                            secondViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                                                            secondViewController.preferredContentSize = CGSize(width: self.view.bounds.width*0.8,height: self.view.bounds.height*0.35)
                                                            let popoverpresentationviewcontroller = secondViewController.popoverPresentationController
                                                            popoverpresentationviewcontroller?.delegate = self
                                                            popoverpresentationviewcontroller?.permittedArrowDirections = UIPopoverArrowDirection()
                                                            popoverpresentationviewcontroller?.sourceRect = CGRect( x: 0, y: self.view.bounds.height/3 , width: self.view.bounds.width , height: self.view.bounds.height/3)
                                                            popoverpresentationviewcontroller?.sourceView = self.view
                                                            self.navigationController?.present(secondViewController, animated: false, completion: nil)
                                                        }
                                                    }
                                                }
                                            })
                                        }
                                    }
                                }
                            }
                            else
                            {
                                if succeeded["message"] != nil{
                                    showToast(message: succeeded["message"] as! String, controller: self)
                                    
                                }
                            }
                        })
                    }
                }
                else
                {
                    // No Internet Connection Message
                    showToast(message: network_status_msg, controller: self)
                }
            }
            else
            {
                if Reachabable.isConnectedToNetwork() {
                    
                    self.view.isUserInteractionEnabled = false
                    UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
                    activityIndicatorView.center = self.view.center
                    activityIndicatorView.startAnimating()
                    var dic = Dictionary<String, String>()
                    
                    for (key, value) in form.valuesByKey{
                        
                        if (key as! NSString == "draft") || (key as! NSString == "category_id") || (key as! NSString == "auth_view") || (key as! NSString == "auth_comment" || (key as! NSString == "timezone") || (key as! NSString == "language") || (key as! NSString == "profile_type")){
                            dic["\(key)"] = findKeyForValue(form.valuesByKey["\(key)"] as! String)
                        }else{
                            if let receiver = value as? NSString {
                                dic["\(key)"] = receiver as String
                            }
                            if let receiver = value as? Int {
                                dic["\(key)"] = String(receiver)
                            }
                            if let receiver = value as? Date {
                                //let tempString = String(describing: receiver)
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                dic["\(key)"] = dateFormatter.string(from: receiver)
                                //dic["\(key)"] = String(describing: receiver)
                            }
                            if signUplayoutType == true && facebook_uid == nil{
                                dic["fields_validation"] = "1"
                                
                            }
                            else{
                                dic["fields_validation"] = "0"
                            }
                        }
                    }
                    var checkBoxvalues = "" as String
                    var checkKeys = String()
                    var infoDic = Dictionary<String, String>()
                    
                    for i in 0 ..< (Form.count) where i < Form.count
                    {
                        let dic = Form[i] as! NSDictionary
                        
                        let type = dic["type"] as! String
                        if type == "Multi_checkbox" || type == "MultiCheckbox" || type == "Multiselect"
                        {
                            checkBoxvalues = ""
                            checkKeys = ""
                            checkBoxNameKey = dic["name"] as! String
                            multiDic = (dic["multiOptions"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            
                            if isCreateOrEdit{
                                for (key, value) in multiDic
                                {
                                    let keys =  form.valuesByKey["\(value)"] as? Int
                                    
                                    if keys != nil
                                    {
                                        
                                        if keys != 0
                                        {
                                            checkKeys = "\(key)"
                                            if checkBoxvalues != ""
                                            {
                                                checkBoxvalues = "\(checkBoxvalues),\(checkKeys)"
                                            }
                                            else
                                            {
                                                checkBoxvalues = "\(checkKeys)"
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                                
                                for (key, value) in multiDic
                                {
                                    let keys =  form.valuesByKey["\(value)"] as? Int
                                    
                                    if keys != nil
                                    {
                                        
                                        if keys != 0
                                        {
                                            checkKeys = "\(key)"
                                            if checkBoxvalues != ""
                                            {
                                                checkBoxvalues = "\(checkBoxvalues),\(checkKeys)"
                                            }
                                            else
                                            {
                                                checkBoxvalues = "\(checkKeys)"
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if checkBoxvalues != ""
                            {
                                infoDic["\(checkBoxNameKey!)"] = "\(checkBoxvalues)"
                                
                            }
                        }
                        
                    }
                    
                    //Set Parameters (Token & Form Values) & path for Sign Up Form
                    var path = ""
                    
                    
                    if signUplayoutType == true && facebook_uid == nil{
                        path = "sitequicks"
                        dic["account_validation"] = "1"
                        dic["ip"] = "127.0.0.1"
                        tempDic = nil
                        if(facebook_uid != nil)
                        {
                            path = "signup?facebook_uid=" + String(facebook_uid) + "&code=%20%20&access_token=" + String(access_token)
                        }
                    }
                    else{
                        if(facebook_uid != nil)
                        {
                            path = "signup/validations"
                            dic["account_validation"] = "1"
                            dic["facebook_uid"] = String(facebook_uid)
                            dic["code"] = "%2520"
                            dic["access_token"] = String(access_token)
                        }
                        else
                        {
                            dic["account_validation"] = "1"
                            path = "signup/validations"
                        }
                    }
                    if apple_id != ""{
                        dic["apple_id"] = "\(apple_id)"
                    }
                    dic.update(infoDic)
                    var parameter = [String:String]()
                    parameter = dic
                    
                    signupDictionary = dic
                    
                    fbEmail = ""
                    
                    if signUplayoutType == true && filePathArray.count > 0  && facebook_uid == nil {
                        postForm(parameter, url: path, filePath: filePathArray, filePathKey: "photo" , SinglePhoto: true) { (succeeded, msg) -> () in
                            DispatchQueue.main.async(execute: {
                                activityIndicatorView.stopAnimating()
                                self.view.alpha = 1.0
                                self.view.isUserInteractionEnabled = true
                                
                                if msg{
                                    if signUplayoutType == true && facebook_uid == nil{
                                        
                                        if signUpUserSubscriptionEnabled == true {
                                            
                                            let alertController = UIAlertController(title: "Message", message:
                                                NSLocalizedString("Signed up successfully. You can edit your information anytime from your profile. Please choose a Subscription Plan for your account.",comment: ""), preferredStyle: UIAlertController.Style.alert)
                                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                                                let presentedVC = SignupUserSubscriptionViewController()
                                                if succeeded["body"] != nil{
                                                    if let response = succeeded["body"] as? NSDictionary{
                                                        
                                                        if let userId = response["user_id"] as? Int{
                                                            presentedVC.user_id = userId
                                                        }
                                                        else if let  user = response["user"] as? NSDictionary
                                                        {
                                                            if let userId = user["user_id"] as? Int{
                                                                presentedVC.user_id = userId
                                                            }
                                                        }
                                                        
                                                    }
                                                }
                                                
                                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                            }))
                                            
                                            self.present(alertController, animated: true, completion: nil)
                                            
                                        }
                                        else{
                                            showToast(message: "Signed up successfully. You can edit your information anytime from your profile", controller: self)
                                            if succeeded["body"] != nil{
                                                if let _ = succeeded["body"] as? NSDictionary{
                                                    // Perform Login Action
                                                    if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                                        DispatchQueue.main.async(execute:{
                                                            mergeAddToCart()
                                                           // UserDefaults.standard.removeObject(forKey: "AppleEmail")
                                                            self.showHomePage()
                                                        })
                                                    }else{
                                                        showToast(message: "Unable to Login", controller: self)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        let presentedVC = SignupProfileFieldController()
                                        self.navigationController?.pushViewController(presentedVC, animated: false)
                                    }
                                }
                                else{
                                    self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                                    if succeeded["message"] != nil{
                                        showToast(message: succeeded["message"] as! String, controller: self)
                                    }
                                    else{
                                        let a = validation
                                        signupValidation.removeAll(keepingCapacity: false)
                                        signupValidationKeyValue.removeAll(keepingCapacity: false)
                                        for (key,value) in a  {
                                            signupValidation.append(value as AnyObject)
                                            signupValidationKeyValue.append(key as AnyObject)
                                            
                                        }
                                        let count = signupValidation.count
                                        for index in 0 ..< count {
                                            if signupValidationKeyValue[index] as! NSString == "passconf"
                                            {
                                                showToast(message: "Password - \(signupValidation[index] as! String)\n", controller: self)
                                            }
                                            else if signupValidationKeyValue[index] as! NSString == "password"
                                            {
                                                showToast(message: "Password - \(signupValidation[index] as! String)\n", controller: self)
                                            }
                                            else if signupValidationKeyValue[index] as! NSString == "username"
                                            {
                                                showToast(message: "Username - \(signupValidation[index] as! String)\n", controller: self)
                                            }
                                            else  if signupValidationKeyValue[index] as! NSString == "terms"
                                            {
                                                showToast(message: "Terms - \(signupValidation[index] as! String)\n", controller: self)
                                            }
                                            else{
                                                showToast(message: "\(signupValidation[index] as! String)\n", controller: self)
                                            }
                                        }
                                    }
                                }
                                
                            })
                        }
                    }
                    else{
                        // Send Server Request to Sign Up Form
                        post(parameter,url: path , method: "POST") { (succeeded, msg) -> () in
                            
                            DispatchQueue.main.async(execute: {
                                activityIndicatorView.stopAnimating()
                                self.view.alpha = 1.0
                                self.view.isUserInteractionEnabled = true
                                
                                if msg{
                                    if signUplayoutType == true && facebook_uid == nil{
                                        
                                        if signUpUserSubscriptionEnabled == true {
                                            
                                            let alertController = UIAlertController(title: "Message", message:
                                                NSLocalizedString("Signed up successfully. You can edit your information anytime from your profile. Please choose a Subscription Plan for your account.",comment: ""), preferredStyle: UIAlertController.Style.alert)
                                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                                                let presentedVC = SignupUserSubscriptionViewController()
                                                if succeeded["body"] != nil{
                                                    if let response = succeeded["body"] as? NSDictionary{
                                                        
                                                        if let userId = response["user_id"] as? Int{
                                                            presentedVC.user_id = userId
                                                        }
                                                        else if let  user = response["user"] as? NSDictionary
                                                        {
                                                            if let userId = user["user_id"] as? Int{
                                                                presentedVC.user_id = userId
                                                            }
                                                        }
                                                        
                                                    }
                                                }
                                                
                                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                            }))
                                            
                                            self.present(alertController, animated: true, completion: nil)
                                            
                                        }
                                        else{
                                            showToast(message: NSLocalizedString("Signed up successfully. You can edit your information anytime from your profile",comment: ""), controller: self)
                                            if succeeded["body"] != nil{
                                                if let _ = succeeded["body"] as? NSDictionary{
                                                    // Perform Login Action
                                                    if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                                        DispatchQueue.main.async(execute:{
                                                            mergeAddToCart()
                                                            //UserDefaults.standard.removeObject(forKey: "AppleEmail")
                                                            self.showHomePage()
                                                        })
                                                    }else{
                                                        showToast(message: "Unable to Login", controller: self)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        let presentedVC = SignupProfileFieldController()
                                        self.navigationController?.pushViewController(presentedVC, animated: false)
                                    }
                                }
                                else{
                                    self.formController.tableView.setContentOffset(CGPoint.zero, animated:true)
                                    if succeeded["message"] != nil{
                                        showToast(message: succeeded["message"] as! String, controller: self)
                                    }
                                    else{
                                        let a = validation
                                        signupValidation.removeAll(keepingCapacity: false)
                                        signupValidationKeyValue.removeAll(keepingCapacity: false)
                                        for (key,value) in a  {
                                            signupValidation.append(value as AnyObject)
                                            signupValidationKeyValue.append(key as AnyObject)
                                            
                                        }
                                        let count = signupValidation.count
                                        for index in 0 ..< count {
                                            if signupValidationKeyValue[index] as! NSString == "passconf"
                                            {
                                                showToast(message: "Password - \(signupValidation[index] as! String)\n", controller: self)
                                            }
                                            else if signupValidationKeyValue[index] as! NSString == "password"
                                            {
                                                showToast(message: "Password - \(signupValidation[index] as! String)\n", controller: self)
                                            }
                                            else if signupValidationKeyValue[index] as! NSString == "username"
                                            {
                                                showToast(message: "Username - \(signupValidation[index] as! String)\n", controller: self)
                                            }
                                            else  if signupValidationKeyValue[index] as! NSString == "terms"
                                            {
                                                showToast(message: "Terms - \(signupValidation[index] as! String)\n", controller: self)
                                            }
                                            else{
                                                showToast(message: "\(signupValidation[index] as! String)\n", controller: self)
                                            }
                                        }
                                    }
                                }
                                
                            })
                        }
                    }
                }
                else
                {
                    // No Internet Connection Message
                    showToast(message: network_status_msg, controller: self)
                }
            }
        }
    }
    
    func showHomePage () {
        menuRefreshConter = 0
        //fOR SHOWING WELCOME MESSAGE ON ADVANCEACTIVITYFEED
        let defaults = UserDefaults.standard
        defaults.set("LoginScreenViewController", forKey: "Comingfrom")
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = false
            
        }
        createTabs()
        if logoutUser == true
        {
            baseController.tabBar.items![1].isEnabled = false
            baseController.tabBar.items![2].isEnabled = false
            baseController.tabBar.items![3].isEnabled = false
        }
        else
        {
            baseController.tabBar.items![1].isEnabled = true
            baseController.tabBar.items![2].isEnabled = true
            baseController.tabBar.items![3].isEnabled = true
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(baseController, animated: false)
        self.view.endEditing(true)
        
    }
    
    // Create Request for Generation of Sign Up Form
    func generateSignUpForm(){
        signupDictionary = ["":""]
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            // self.formController.tableView.frame.origin.y = 150
            UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            UserDefaults.standard.removeObject(forKey: "preferenceName")
            UserDefaults.standard.removeObject(forKey: "SellSomething")
            textstoreValue = ""
            isCreateOrEdit = true
            defaultCategory = ""
            MultiCheckFormValue = [:]
            Formbackup.removeAllObjects()
            if(tempDic != nil)
            {
                mediaType = "image"
                multiplePhotoSelection = false
                activityIndicatorView.stopAnimating()
                DispatchQueue.main.async(execute: {
                    if let accountArray = self.tempDic["account"] as? NSArray{
                        
                        if let _ = self.tempDic["photo"] as? NSArray{
                            signUpPhotoFlag = true
                        }else{
                            signUpPhotoFlag = false
                        }
                        
                        if let _ = self.tempDic["subscription"] as? NSArray{
                            signUpUserSubscriptionEnabled = true
                        }else{
                            signUpUserSubscriptionEnabled = false
                        }
                        if let isEnable_otp = self.tempDic["isEnableotp"] as? String
                              {
                                                           if isEnable_otp == "1"
                                                           {
                                                               isEnableOtp = true
                                                           }
                                                           else
                                                           {
                                                               isEnableOtp = false
                                                           }
                                                       }
                          else if let isEnable_otp = self.tempDic["isEnableotp"] as? Int
                              {
                                                           if isEnable_otp == 1
                                                           {
                                                               isEnableOtp = true
                                                           }
                                                           else
                                                           {
                                                               isEnableOtp = false
                                                           }
                                                       }
                        if let EnablisEmailVerification = self.tempDic["isEmailVerificationEnable"] as? Int{
                            if EnablisEmailVerification == 1
                            {
                                isEmailValidationEnabled = true
                            }
                            else
                            {
                                isEmailValidationEnabled = false
                            }
                        }
                        if signUplayoutType == true {
                            if let isEnable_otp = self.tempDic["isOTPEnabled"] as? Int
                               {
                                                               if isEnable_otp == 1
                                                               {
                                                                   isEnableOtp = true
                                                               }
                                                           }
                            else{
                                                               isEnableOtp = false
                                                           }
                         }
                        Form = accountArray as [AnyObject]
                        InitialForm = accountArray as [AnyObject]
                        if let accountArray = self.tempDic["account"] as? NSArray
                        {
                            for key in Form{
                                // Create element Dictionary for every FXForm Element
                                
                                if let dic = (key as? NSDictionary)
                                {
                                    if dic["name"] as? String == "profile_type"
                                    {
                                        categoryDic = dic
                                    }
                                }
                            }
                            
                            
                        }
                        if let fieldDic = self.tempDic["fields"] as? NSDictionary
                        {
                            fieldsDic = fieldDic
                        }
                    }
                    
                    if let accountArray = self.tempDic["form"] as? NSArray{
                                           
                                           if let _ = self.tempDic["photo"] as? NSArray{
                                               signUpPhotoFlag = true
                                           }else{
                                               signUpPhotoFlag = false
                                           }
                                           
                                           if let _ = self.tempDic["subscription"] as? NSArray{
                                               signUpUserSubscriptionEnabled = true
                                           }else{
                                               signUpUserSubscriptionEnabled = false
                                           }
                                           if let isEnable_otp = self.tempDic["isEnableotp"] as? String
                                                 {
                                                                              if isEnable_otp == "1"
                                                                              {
                                                                                  isEnableOtp = true
                                                                              }
                                                                              else
                                                                              {
                                                                                  isEnableOtp = false
                                                                              }
                                                                          }
                                             else if let isEnable_otp = self.tempDic["isEnableotp"] as? Int
                                                 {
                                                                              if isEnable_otp == 1
                                                                              {
                                                                                  isEnableOtp = true
                                                                              }
                                                                              else
                                                                              {
                                                                                  isEnableOtp = false
                                                                              }
                                                                          }
                                           if let EnablisEmailVerification = self.tempDic["isEmailVerificationEnable"] as? Int{
                                               if EnablisEmailVerification == 1
                                               {
                                                   isEmailValidationEnabled = true
                                               }
                                               else
                                               {
                                                   isEmailValidationEnabled = false
                                               }
                                           }
                                           if signUplayoutType == true {
                                               if let isEnable_otp = self.tempDic["isOTPEnabled"] as? Int
                                                  {
                                                                                  if isEnable_otp == 1
                                                                                  {
                                                                                      isEnableOtp = true
                                                                                  }
                                                                              }
                                               else{
                                                                                  isEnableOtp = false
                                                                              }
                                            }
                                           Form = accountArray as [AnyObject]
                                           InitialForm = accountArray as [AnyObject]
                                           if let accountArray = self.tempDic["form"] as? NSArray
                                           {
                                               for key in Form{
                                                   // Create element Dictionary for every FXForm Element
                                                   
                                                   if let dic = (key as? NSDictionary)
                                                   {
                                                       if dic["name"] as? String == "profile_type"
                                                       {
                                                           categoryDic = dic
                                                       }
                                                   }
                                               }
                                               
                                               
                                           }
                                           if let fieldDic = self.tempDic["fields"] as? NSDictionary
                                           {
                                               fieldsDic = fieldDic
                                           }
                                       }
                    self.formController.form = CreateNewForm()
                    self.formController.tableView.reloadData()
                })
            }
            else
            {
                //Set Parameters & path for Sign Up Form
                var parameter = [String:String]()
                var path = ""
                parameter = ["":""]
                parameter["subscriptionForm"] = "1"
                if signUplayoutType == true && facebook_uid == nil{
                    path = "sitequicks"
                    mediaType = "image"
                    multiplePhotoSelection = false
                }
                else{
                    path = "signup"
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
                            if let dic = succeeded["body"] as? NSDictionary{
                                
                                if let EnablisEmailVerification = dic["isEmailVerificationEnable"] as? Int{
                                    if EnablisEmailVerification == 1
                                    {
                                        isEmailValidationEnabled = true
                                    }
                                    else
                                    {
                                        isEmailValidationEnabled = false
                                    }
                                }
                                if let _ = dic["photo"] as? NSArray{
                                    signUpPhotoFlag = true
                                }else{
                                    signUpPhotoFlag = false
                                }
                                
                                if let _ = dic["subscription"] as? NSArray{
                                    signUpUserSubscriptionEnabled = true
                                }else{
                                    signUpUserSubscriptionEnabled = false
                                }
                                if signUplayoutType == true && facebook_uid == nil{
                                    if let accountArray = dic["form"] as? NSArray
                                    {
                                        Form = accountArray as [AnyObject]
                                        for key in Form{
                                            // Create element Dictionary for every FXForm Element
                                            
                                            if let dic = (key as? NSDictionary)
                                            {
                                                if dic["name"] as? String == "profile_type"
                                                {
                                                    categoryDic = dic
                                                }
                                            }
                                        }
                                        
                                        
                                        InitialForm = accountArray as [AnyObject]
                                    }
                                    if let fieldDic = dic["fields"] as? NSDictionary
                                    {
                                        fieldsDic = fieldDic
                                    }
                                }
                                else{
                                    if let accountArray = dic["account"] as? NSArray
                                    {
                                        Form = accountArray as [AnyObject]
                                        InitialForm = accountArray as [AnyObject]
                                    }
                                }
                                
                                if let photoArray = dic["photo"] as? NSArray
                                {
                                    PhotoForm = photoArray as [AnyObject]
                                }
                                if let isEnable_otp = dic["isEnableotp"] as? String
                                {
                                    if isEnable_otp == "1"
                                    {
                                        isEnableOtp = true
                                    }
                                    else
                                    {
                                        isEnableOtp = false
                                    }
                                }
                                else if let isEnable_otp = dic["isEnableotp"] as? Int
                                {
                                    if isEnable_otp == 1
                                    {
                                        isEnableOtp = true
                                    }
                                    else
                                    {
                                        isEnableOtp = false
                                    }
                                }
                                
                                if signUplayoutType == true {
                                    if let isEnable_otp = dic["isOTPEnabled"] as? Int
                                    {
                                        if isEnable_otp == 1
                                        {
                                            isEnableOtp = true
                                        }
                                    }
                                    else{
                                        isEnableOtp = false
                                    }
                                }
                                
                            }
                            // Create FXForm Form
                            self.formController.form = CreateNewForm()
                            self.formController.tableView.reloadData()
                        }
                        else
                        {
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                            }
                        }
                    })
                }
            }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    func profileValueChanged(_ cell: FXFormFieldCellProtocol)
    {
        if fieldsDic.count > 0 && facebook_uid == nil{
            let form = cell.field.form as! CreateNewForm
            Form.removeAll(keepingCapacity: false)
            Form = InitialForm
            var index = Int()
            
            for i in 0 ..< (Form.count) where i < Form.count
            {
                let dic = Form[i] as! NSDictionary
                if let dicName = dic["name"] as? String {
                    
                    if dicName == "profile_type"
                    {
                        index = i;
                    }
                    if (form.valuesByKey["\(dicName)"] != nil)
                    {
                        Formbackup["\(dicName)"] = form.valuesByKey["\(dicName)"]
                    }
                    
                }
                
            }
            
            if (form.valuesByKey["profile_type"] != nil)
            {
                if let option = categoryDic["multiOptions"] as? NSDictionary
                {
                    
                    let categoryvalue = form.valuesByKey["profile_type"] as! String
                    for (key, value) in option
                    {
                        
                        if categoryvalue == value as! String
                        {
                            if let feildtoaddArray = fieldsDic["profile_type_\(key)"] as? NSArray
                            {
                                for dic in feildtoaddArray
                                {
                                    index += 1
                                    Form.insert(dic as AnyObject, at: index)
                                    
                                }
                                
                            }
                            
                            defaultCategory = "\(value)"
                            
                        }
                    }
                }
            }
            self.formController.form = CreateNewForm()
            self.formController.tableView.reloadData()
        }
    }
    
    func readTerms(_ cell: FXFormFieldCellProtocol)
    {
        
        if termPrivacyUrl != nil && termPrivacyUrl != ""{
            let presentedVC = ExternalWebViewController()
            presentedVC.url = termPrivacyUrl
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated: true, completion: nil)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func goBack()
    {
        let alertController = UIAlertController(title: "Go Back?", message:"Are you sure that you want to go back?", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Go Back", style: UIAlertAction.Style.default,handler: { action -> Void in
            AccessToken.current = nil
            if let tabBarObject = self.tabBarController?.tabBar
            {
                tabBarObject.isHidden = false
                
            }
            _ = self.navigationController?.popViewController(animated: false)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel,handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
