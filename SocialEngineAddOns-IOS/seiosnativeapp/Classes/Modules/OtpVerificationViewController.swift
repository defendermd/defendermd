//
//  OtpVerificationViewController.swift
//  seiosnativeapp
//
//  Created by Bigstep IOS on 10/9/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit
var goback : Bool = false
var country_code : String = ""
var otp  = String()
var sent_time = String()
var expairy_time : Int64 = 0
var resetpassword : Bool = false
var phone_no : Int64 = 0
var timeduration : Int = 0

class OtpVerificationViewController: UIViewController , UIGestureRecognizerDelegate{
    
    var textmsg = UILabel()
    var otplabel = UILabel()
    var notelabel = UILabel()
    var linelabel = UILabel()
    var otpTextfield = UITextField()
    var box = UIView()
    var verify = UIButton()
    var resend = UIButton()
    var tapGesture = UITapGestureRecognizer()
    var mobileno : Int64 = 0
    var countrycode : Int = 0
    var note : String = ""
    var Subscriptionurl: String = ""
    var url : String = ""
    var edit_no : Int = 0
    var useremail : String = ""
    var userpassword : String = ""
    var duration : Int = 0
    var timer1 = Timer()
    var InactiveTime : Int64 = 0
    var ActiveTime : Int64 = 0
    var userId : Int = 0
    var tempDic = NSDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sidepaading : CGFloat = 10
        timeduration = duration
        
        textmsg = UILabel(frame: CGRect(x: sidepaading, y : TOPPADING+20 ,width: UIScreen.main.bounds.width - 20, height: 30))
        
        navigationItem.title = "\(NSLocalizedString("OTP Verification",  comment: ""))"
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(OtpVerificationViewController.applicationDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(OtpVerificationViewController.applicationWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        view.backgroundColor = bgColor
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(OtpVerificationViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        if mobileno == 0
        {
            textmsg.text = "\(NSLocalizedString("Enter the verification code you have received on \(country_code) \(OTPvalue)",  comment: ""))"
        }
        else
        {
            textmsg.text = "\(NSLocalizedString("Enter the verification code you have received on +\(countrycode) \(mobileno)",  comment: ""))"
        }
        textmsg.font = UIFont(name: fontName, size: FONTSIZENormal)
        textmsg.numberOfLines = 0
        textmsg.lineBreakMode = NSLineBreakMode.byWordWrapping
        textmsg.sizeToFit()
        view.addSubview(textmsg)
        
        otplabel = UILabel(frame: CGRect(x: sidepaading, y : getBottomEdgeY(inputView: textmsg) + 20 ,width: 80, height: 20))
        otplabel.text = "\(NSLocalizedString("Enter OTP",  comment: ""))"
        otplabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        otplabel.textColor = buttonColor
        view.addSubview(otplabel)
        
        otpTextfield = UITextField(frame: CGRect(x: sidepaading, y : getBottomEdgeY(inputView: otplabel) - 5 ,width: UIScreen.main.bounds.width - (150), height: 45))
        let paddingView : UIView = UIView(frame: CGRect(x :0, y :0, width: 5, height : 20))
        otpTextfield.leftView = paddingView
        otpTextfield.leftViewMode = UITextField.ViewMode.always
        otpTextfield.isSecureTextEntry = true
        if #available(iOS 12.0, *) {
            otpTextfield.textContentType = .oneTimeCode
        } else {
            // Fallback on earlier versions
        }
        view.addSubview(otpTextfield)
        
        linelabel = UILabel(frame: CGRect(x: sidepaading, y : getBottomEdgeY(inputView: otpTextfield),width: UIScreen.main.bounds.width - (2*sidepaading), height: 1))
        linelabel.backgroundColor = buttonColor
        linelabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        view.addSubview(linelabel)
        
        verify = createButton(CGRect(x: sidepaading, y: getBottomEdgeY(inputView: otpTextfield) + 30, width: UIScreen.main.bounds.width - (2*sidepaading) , height: 50), title: "\(NSLocalizedString("Verify",  comment: ""))", border: false,bgColor: false, textColor: textColorLight)
        verify.layer.borderColor = buttonBgColor.cgColor
        verify.layer.cornerRadius = verify.frame.size.width / 2;
        verify.layer.borderWidth = 2.5
        verify.layer.cornerRadius = 5.0
        verify.contentHorizontalAlignment = .center
        verify.titleLabel?.font = UIFont(name: fontName, size: FONTSIZELarge)
        verify.layer.borderWidth = borderWidth
        verify.backgroundColor = buttonBgColor
        verify.backgroundColor = buttonBgColor
        view.addSubview(verify)
        
        resend.backgroundColor = buttonBgColor
        resend = createButton(CGRect(x: getRightEdgeX(inputView: otpTextfield)+5, y: getBottomEdgeY(inputView: otplabel)+10, width: view.bounds.width-(getRightEdgeX(inputView: otpTextfield) + (2*sidepaading)) , height: 20), title: "\(NSLocalizedString("Resend OTP",  comment: ""))", border: false,bgColor: false, textColor: buttonColor)
        resend.contentHorizontalAlignment = .right
        resend.titleLabel?.font = UIFont(name: fontNormal, size: FONTSIZENormal)
//        resend.sizeToFit()
        resend.addTarget(self, action: #selector(resend_OTP), for: .touchUpInside)
        view.addSubview(resend)
        
        notelabel = UILabel(frame: CGRect(x: sidepaading, y : getBottomEdgeY(inputView: verify) + 30 ,width: UIScreen.main.bounds.width - (2*sidepaading), height: 30))
//        notelabel.text = "\(NSLocalizedString(note,  comment: ""))"
        notelabel.font = UIFont(name: fontName, size: FONTSIZEExtraLarge)
        notelabel.textAlignment = .center
        view.addSubview(notelabel)
        
        if sign_in == 1
        {
            verify.addTarget(self, action: #selector(self.login), for: .touchUpInside)
        }
        else if edit_no == 1{
            verify.addTarget(self, action: #selector(self.fetch_otp_signin), for: .touchUpInside)
        }
        else if sign_up == 1 {
           verify.addTarget(self, action: #selector(self.nextPage), for: .touchUpInside)
        }
        else if forgotpass == 1
        {
            verify.addTarget(self, action: #selector(self.forgotpassword), for: .touchUpInside)
        }
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(OtpVerificationViewController.resignKeyboard))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false;
        view.addGestureRecognizer(tapGesture)
        createTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if resetpassword == true
        {
            resetpassword = false
            goBack()
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer() {
        stop()
      //  if popAfterDelay == true{
            _ = self.navigationController?.popViewController(animated: true)
            
        //}
    }
    override func viewWillDisappear(_ animated: Bool) {
        notelabel.text = ""
        timer1.invalidate()
    }
    
    @objc func resignKeyboard(){
        self.otpTextfield.resignFirstResponder()
    }
    
    @objc func fetch_otp_signin()
    {
        if otpTextfield.text == ""
        {
            self.view.makeToast(NSLocalizedString("Please complete this field - it is required.",  comment: ""), duration: 5, position: CSToastPositionCenter)
        }
        else {
            verify.setTitle(NSLocalizedString("Verifying...",comment: ""), for: UIControl.State())
            view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var parameter = [String:String]()
            parameter = ["code":self.otpTextfield.text!,"mobileno":OTPvalue,"tostep_verification":"1","country_code":country_code,"type":addedittype]
            // Send Server Request to Sign Up Form
            post(parameter,url: "otpverifier/code-verification" , method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    self.verify.setTitle(NSLocalizedString("Verify",comment: ""), for: UIControl.State())
                    activityIndicatorView.stopAnimating()
                    if msg{
                        self.view.makeToast(NSLocalizedString("Verification is successfull.",  comment: ""), duration: 5, position: CSToastPositionCenter)
                        self.edit_no = 0
                        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
                        for aViewController in viewControllers {
                            if aViewController is two_step_verificationViewController {

                                // Post notification
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "editNo"), object: nil)
                                self.navigationController!.popToViewController(aViewController, animated: true)
                            }
                        }
                    }
                    else{
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                            
                        }
                    }
                })
            }
        }
    }

    @objc func nextPage()
    {
        if otpTextfield.text == ""
        {
            self.view.makeToast(NSLocalizedString("Please enter OTP to verify.",  comment: ""), duration: 5, position: CSToastPositionCenter)
        }
        else {
            verify.setTitle(NSLocalizedString("Verifying...",comment: ""), for: UIControl.State())
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            let someDate = Date()
            let timeInterval = someDate.timeIntervalSince1970
            // convert to Integer
            let myInt = Int64(timeInterval)

            if (myInt + Int64(timeduration)) > myInt
            {
                activityIndicatorView.stopAnimating()
                sign_up = 1
                self.verify.setTitle(NSLocalizedString("Verify",comment: ""), for: UIControl.State())
                if otp == self.otpTextfield.text!{
                    if sign_up == 1 {
                        otp = ""
                        self.view.makeToast(NSLocalizedString("Verification is successfull.",  comment: ""), duration: 3, position: CSToastPositionCenter)
                        sign_up = 0
                        if signUplayoutType == true && facebook_uid == nil {
                            delay(2.0) {
                            
                        if signUpUserSubscriptionEnabled == true {
                            
                            let alertController = UIAlertController(title: "Message", message:
                                NSLocalizedString("You have successfully signed up. Please choose a Subscription Plan for your account.",comment: ""), preferredStyle: UIAlertController.Style.alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                                let presentedVC = SignupUserSubscriptionViewController()
                                presentedVC.user_id = self.userId
                              
                                
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                            }))
                            
                            self.present(alertController, animated: true, completion: nil)
                            
                        }
                        else{
                            print("temp \(self.tempDic)")
                            if self.tempDic != nil{
                                    // Perform Login Action
                                if performLoginActionSuccessfully(self.tempDic){
                                        DispatchQueue.main.async(execute:{
                                            mergeAddToCart()
                                            self.showHomePage()
                                        })
                                    }else{
                                        self.view.makeToast(NSLocalizedString("Unable to Login",comment: ""), duration: 5, position: "bottom")
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
                }
                else{
                    self.view.makeToast(NSLocalizedString("OTP entered is not valid.",  comment: ""), duration: 5, position: CSToastPositionCenter)
                }
            }
            else{
                activityIndicatorView.stopAnimating()
                self.verify.setTitle(NSLocalizedString("Verify",comment: ""), for: UIControl.State())
                self.view.makeToast(NSLocalizedString("OTP has been expired. Please resend OTP.",  comment: ""), duration: 5, position: CSToastPositionCenter)
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
    
    @objc func resend_OTP()
    {
        timeduration = duration
        timer1.invalidate()
        createTimer()
        resend.setTitle(NSLocalizedString("Sending...",comment: ""), for: UIControl.State())
        otpTextfield.text = ""
        view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
        if sign_in == 1
        {
                sign_up = 0
                var parameter = [String:String]()
                parameter = [login_id:"\(useremail)","password":"\(userpassword)","ip":"127.0.0.1"]
            
            if device_uuid != nil{
                loginParams.updateValue(device_uuid, forKey: "device_uuid")
                parameter.updateValue(device_uuid, forKey: "device_uuid")
            }
            if device_token_id != nil{
                loginParams.updateValue(device_token_id, forKey: "device_token")
                parameter.updateValue(device_token_id, forKey: "device_token")
            }
            
                // Send Server Request to Sign Up Form
                post(parameter,url: "otpverifier/send" , method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        self.resend.setTitle(NSLocalizedString("Resend OTP",comment: ""), for: UIControl.State())
                        activityIndicatorView.stopAnimating()
                        if msg{
                            self.view.makeToast(NSLocalizedString("OTP has been resent successfully.",comment: ""), duration: 5, position: CSToastPositionCenter)
                        }
                        else
                        {
                            if succeeded["message"] != nil{
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                                
                            }
                        }
                        
                    })
                }
        }
        else if edit_no == 1
        {
            var parameter = [String:String]()
            parameter = ["mobileno":useremail,"country_code":country_code]
            // Send Server Request to Sign Up Form
            post(parameter,url: url , method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    self.resend.setTitle(NSLocalizedString("Resend OTP",comment: ""), for: UIControl.State())
                    activityIndicatorView.stopAnimating()
            
                    if msg{
                        //print(succeeded)
                    }
                    else
                    {
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                            
                        }
                    }
                    
                })
            }
        }
        else if forgotpass == 1
        {
            var param  = [String:String]()
            param = ["email":"\(phone_no)","country_code":country_code]
            post( param,url: "otpverifier/forgot-password", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    self.resend.setTitle(NSLocalizedString("Resend OTP",comment: ""), for: UIControl.State())
                    activityIndicatorView.stopAnimating()
                    if(msg){
                        self.view.makeToast(NSLocalizedString("OTP has been resent successfully.",comment: ""), duration: 5, position: CSToastPositionCenter)
                    }else{
                        // Handle Server Side Error Massages
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                        }
                    }
                })
                
            }
        }
        else if sign_up == 1
        {
          sign_in = 0
          self.fetch_otp()  
        }
    }
    
    func fetch_otp()
    {
        var parameter = [String:String]()
        parameter = ["emailaddress":OTPvalue,"country_code":country_code]
        // Send Server Request to Sign Up Form
        post(parameter,url: "otpverifier/verify-mobileno" , method: "POST") { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                self.resend.setTitle(NSLocalizedString("Resend OTP",comment: ""), for: UIControl.State())
                activityIndicatorView.stopAnimating()
                if msg{
                    if let body = succeeded["body"] as? NSDictionary
                    {
                        if let response = body["response"] as? NSDictionary
                        {   otp = ""
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
                            
                            self.view.makeToast(NSLocalizedString("OTP has been resent successfully.",comment: ""), duration: 5, position: CSToastPositionCenter)
                        }
                    }
                }
                else
                {
                    if succeeded["message"] != nil{
                        self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                        
                    }
                }
            })
        }
    }

    @objc func forgotpassword()
    {
        if otpTextfield.text == ""
        {
            self.view.makeToast(NSLocalizedString("Please complete this field - it is required.",  comment: ""), duration: 5, position: CSToastPositionCenter)
        }
        else {
            verify.setTitle(NSLocalizedString("Verifying...",comment: ""), for: UIControl.State())
            view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            forgotpass = 0
            var parameter = [String:String]()
            useremail = "\(phone_no)"
            parameter = ["email":useremail,"country_code":country_code,"code":self.otpTextfield.text!]
            // Send Server Request to Sign Up Form
            post(parameter,url: "otpverifier/verify" , method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    self.verify.setTitle(NSLocalizedString("Verify",comment: ""), for: UIControl.State())
                    activityIndicatorView.stopAnimating()
                    if msg{
                        //print(succeeded)
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if let response = body["response"] as? NSDictionary{
                                    let mobile = response["email"] as? Int64
                                    resetpassword = true
                                    let presentedVC = FormGenerationViewController()
                                    presentedVC.formTitle = NSLocalizedString("Reset Password", comment: "")
                                    presentedVC.contentType = "Password reset"
                                    presentedVC.param = ["email" :"\(String(describing: mobile!))","code":self.otpTextfield.text!,"option":"0" ]
                                    presentedVC.url = "otpverifier/reset"
                                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                    self.present(nativationController, animated:true, completion: nil)
                                }
                            }
                        }
                    }
                    else
                    {
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                            
                        }
                    }
                })
            }
        }
    }
    
    @objc func login()
    {
        if otpTextfield.text == ""
        {
            self.view.makeToast(NSLocalizedString("Please enter OTP to verify",  comment: ""), duration: 5, position: CSToastPositionCenter)
        }
        else
        {
            // Check Internet Connection
            if Reachabable.isConnectedToNetwork() {
                
                view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                
                
               
                
                verify.setTitle(NSLocalizedString("Verifying...",comment: ""), for: UIControl.State())
                // Send Server Request for Sign In
                loginParams = [login_id:"\(useremail)","ip":"127.0.0.1" , "subscriptionForm": "1","loginWithOtp":"1","code":self.otpTextfield.text!]
                logoutUser = true
                if device_uuid != nil{
                    loginParams.updateValue(device_uuid, forKey: "device_uuid")
                }
                if device_token_id != nil{
                    loginParams.updateValue(device_token_id, forKey: "device_token")
                }
                
                post(loginParams, url: "login", method: "POST") { (succeeded, msg) -> () in
                    
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        self.verify.setTitle("Verify", for: UIControl.State())
                        sign_in = 0
                        // On Success save authentication_token in Core Data
                        if(msg)
                        {
                            //loginParams = ["":""]
                            // Get Data From Core Data
                            if succeeded["message"] != nil{
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                            }
                            if succeeded["body"] != nil{
                                // Perform Login Action
                                
                                if let subsResponse = succeeded["body"] as? NSDictionary{
                                    self.gohomepage(subsResponse : subsResponse)
                                }
                            }
                        }
                        else
                        {
                            // Handle Server Side Error Massages
                            if succeeded["message"] != nil
                            {
                                
                                if validationMessage != ""
                                {
                                    validationMessage = validationMessage.html2String as String
//                                    let alertTest = UIAlertView()
//                                    alertTest.message = "\(validationMessage)"
//                                    alertTest.addButton(withTitle: "Ok")
//                                    alertTest.delegate = self
//                                    alertTest.title = "Message"
//                                    alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
//                                    alertTest.show()
                                    
                                    let alertController = UIAlertController(title: "Message", message:
                                        "\(validationMessage)", preferredStyle: UIAlertController.Style.alert)
                                    
                                    alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                                        if let url = URL(string: self.Subscriptionurl)
                                        {
                                            
                                            UIApplication.shared.openURL(url)
                                        }
                                    }))
                                    
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                else if SubscriptionMessage != ""
                                {
                                    if signUpUserSubscriptionEnabled == true
                                    {
                                        let presentedVC = SignupUserSubscriptionViewController()
                                        self.navigationController?.pushViewController(presentedVC, animated: true)
                                    }
                                    else
                                    {
                                        let myString: String = "<a href="
                                        
                                        var myStringArr = SubscriptionMessage.components(separatedBy: myString)
                                        let tempAnotherString = myStringArr[1]
                                        let temp1: String = ">"
                                        
                                        var myStringArr1 = tempAnotherString.components(separatedBy: temp1 )
                                        self.Subscriptionurl = myStringArr1[0]
                                        
                                        self.Subscriptionurl = self.Subscriptionurl.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
                                        
                                        SubscriptionMessage = SubscriptionMessage.html2String as String
//                                        let alertTest = UIAlertView()
//                                        alertTest.message = "\(SubscriptionMessage)"
//                                        alertTest.addButton(withTitle: "Ok")
//                                        alertTest.delegate = self
//                                        alertTest.title = "Message"
//                                        alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
//                                        alertTest.show()
                                        
                                        let alertController = UIAlertController(title: "Message", message:
                                            "\(SubscriptionMessage)", preferredStyle: UIAlertController.Style.alert)
                                        
                                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                                            if let url = URL(string: self.Subscriptionurl)
                                            {
                                                
                                                UIApplication.shared.openURL(url)
                                            }
                                        }))
                                        
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                }else
                                {
                                    self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                                }
                            }
                            
                        }
                    })
                }
            }
            else
            {
                // No Internet Connection Message
                self.view.endEditing(true)
                self.view.makeToast(network_status_msg, duration: 5, position: "top")
                
            }
        }
    }
    // Go to home page
    func gohomepage(subsResponse : NSDictionary)
    {
        
        if subsResponse["subscription"] != nil && subsResponse["subscription"] as! Int == 1{
            let presentedVC = SignupUserSubscriptionViewController()
            if let userId = subsResponse["user_id"] as? Int{
                presentedVC.user_id = userId
            }
            presentedVC.loginOrSignup = true
            presentedVC.email = useremail
            presentedVC.pass = userpassword
            self.navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        else
        {
            let defaults = UserDefaults.standard
            defaults.set("\(userpassword)", forKey: "userPassword")
            if performLoginActionSuccessfully(subsResponse){
                mergeAddToCart()
                self.showHomePage()
            }
            else
            {
                self.view.makeToast(NSLocalizedString("Unable to Login",comment: ""), duration: 5, position: CSToastPositionCenter)
            }
        }
    }
    
//    func showHomePage ()
//    {
//        menuRefreshConter = 0
//        //fOR SHOWING WELCOME MESSAGE ON ADVANCEACTIVITYFEED
//        let defaults = UserDefaults.standard
//        defaults.set("LoginScreenViewController", forKey: "Comingfrom")
//        createTabs()
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        self.navigationController?.pushViewController(baseController, animated: false)
//        self.view.endEditing(true)
//
//    }
    
//    func alertView(_ alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int)
//    {
//
//        switch buttonIndex
//        {
//        case 0:
//
//            alertView.removeFromSuperview()
//            alertView.isHidden = true
//            if let url = URL(string: self.Subscriptionurl)
//            {
//
//                UIApplication.shared.openURL(url)
//            }
//            break
//
//        default: break
//
//        }
//    }

    // MARK: Back Implimentation
    @objc func goBack(){
        timer.invalidate()
        sign_in = 0
        edit_no = 0
        forgotpass = 0
        sign_up = 0
        _ = self.navigationController?.popViewController(animated: false)
        goback = true
    }
    
    @objc func applicationDidEnterBackground(_ application: UIApplication) {
        timer1.invalidate()
        notelabel.text = ""
        let someDate = Date()
        let timeInterval = someDate.timeIntervalSince1970
        // convert to Integer
        InactiveTime = Int64(timeInterval)
    }
    
    @objc func applicationWillEnterForeground(_ application: UIApplication) {
        let someDate = Date()
        let timeInterval = someDate.timeIntervalSince1970
        // convert to Integer
        ActiveTime = Int64(timeInterval)
        
        let time : Int = Int(ActiveTime - InactiveTime)
        timeduration -= time
        createTimer()
    }
    
    
    // Create Timer
    func createTimer(){
        timer1 = Timer.scheduledTimer(timeInterval: 1, target: self, selector:  #selector(OtpVerificationViewController.updateTimer), userInfo: nil, repeats: true)
    }
    
    // Stop Timer
    @objc func updateTimer()
    {
        timeduration -= 1
        
        let minutes = timeduration / 60 % 60
        let seconds = timeduration % 60
        
        if timeduration > 0
        {
            if minutes >= 10
            {
                notelabel.text = "\(minutes) : \(seconds)"
            }
            else
            {
                notelabel.text = "0\(minutes) : \(seconds)"
            }
        }
        else
        {
            timer1.invalidate()
            notelabel.text = " Time Out! "
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
