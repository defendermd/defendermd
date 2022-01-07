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
//  LoginViewController.swift
//  SocailEngineDemoForSwift
//
var loginVieww:Bool = true
import AVFoundation
import UIKit
import Foundation
import CoreData
import QuartzCore
#if compiler(>=5.1)
import AuthenticationServices
#endif
var facebook_uid:String!
var code:String!
var access_token:String!
var fbEmail : String!
var fbFirstName :String!
var fbLastName : String!
var fbGender : String!
var updateDashboardContent = false
var moveforward = true
//var checkBrowseAsGuest:Bool = false
var fbImageUrl = ""
var SubscriptionMessage : String = ""
var images : NSMutableArray = []
var tempString1 : NSMutableArray = []
var tempString2 : NSMutableArray = []

var apple_id = ""
var appleEmail = ""
var appleFirstName = ""
var appleLastName = ""


class LoginViewController: UIViewController , UIScrollViewDelegate, UITextFieldDelegate, LoginButtonDelegate , UIGestureRecognizerDelegate{
    

    var imgUser:UIImageView!
   // var button1:UIButton!
    var email : UITextField!               // TextField for email
    var pass : UITextField!                // TextField for Password
    var signIn : UIButton!                 // SignIn Action
    var signUp : UIButton!                 // SignUp Action
    let scrollView = UIScrollView()         // ScrollView for background Image
    var forgotPassword : UIButton!
    var emailField: UITextField!
    var homePage : UIButton!
    var info1 : UILabel!
    var info2 : UILabel!
    let loginView  = FBLoginButton()
    var welcomeTimer : Timer!
    var terms : UIButton!
    var privacyPolicy : UIButton!
    var index = 0
    let animationDuration: TimeInterval = 0.25
    let switchingInterval: TimeInterval = 4
    
    var Subscriptionurl: String = ""
    
//    func setupSOAppleSignIn() {
//
//        if #available(iOS 13.0, *) {
//            let btnAuthorization = ASAuthorizationAppleIDButton()
//            btnAuthorization.frame = CGRect(x: 0, y: 100, width: 200, height: 40)
//
//                   btnAuthorization.center = self.view.center
//
//                   btnAuthorization.addTarget(self, action: #selector(actionHandleAppleSignin), for: .touchUpInside)
//
//                   self.view.addSubview(btnAuthorization)
//        } else {
//            // Fallback on earlier versions
//        }
//
//
//
//    }
    #if compiler(>=5.1)
    @available(iOS 13.0, *)
    @objc private func actionHandleApple() {

        let appleIDProvider = ASAuthorizationAppleIDProvider()

        let request = appleIDProvider.createRequest()

        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])

        authorizationController.delegate = self

        authorizationController.presentationContextProvider = self

        authorizationController.performRequests()
        

    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {

        print(error.localizedDescription)

    }

       // ASAuthorizationControllerDelegate function for successful authorization

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if #available(iOS 13.0, *) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                
                // Create an account as per your requirement
                print("appleIDCredential")
                print(appleIDCredential)
                let appleId = appleIDCredential.user
                print(appleId)
                apple_id = appleId
                
                
                if let appleUserFirstName = appleIDCredential.fullName?.givenName{
                    appleFirstName = appleUserFirstName
                    UserDefaults.standard.set(appleFirstName, forKey: "AppleFirstName")
                    print(appleUserFirstName)
                }
                else{
                    appleFirstName = ""
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "AppleFirstName")
                    {
                        if  UserDefaults.standard.object(forKey: "AppleFirstName") != nil {
                            
                            appleFirstName = name as? String ?? ""
                            print("AppleFirstName \(appleFirstName)")
                            
                        }
                        
                    }
                }
                if let appleUserLastName = appleIDCredential.fullName?.familyName{
                    appleLastName = appleUserLastName
                    UserDefaults.standard.set(appleLastName, forKey: "AppleLastName")
                    print(appleUserLastName)
                }
                else{
                    appleLastName = ""
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "AppleLastName")
                    {
                        if  UserDefaults.standard.object(forKey: "AppleLastName") != nil {
                            
                            appleLastName = name as? String ?? ""
                            print("appleLastName \(appleLastName)")
                            
                        }
                        
                    }
                }
                if let appleUserEmail = appleIDCredential.email{
                    appleEmail = appleUserEmail
                    UserDefaults.standard.set(appleUserEmail, forKey: "AppleEmail")
                    print(appleUserEmail)
                }
                else{
                    appleEmail = ""
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "AppleEmail")
                    {
                        if  UserDefaults.standard.object(forKey: "AppleEmail") != nil {
                            
                            appleEmail = name as? String ?? ""
                            print("appleEmail \(appleEmail)")
                            
                        }
                        
                    }
                    
                }
               
                
                if Reachabable.isConnectedToNetwork() {
                    self.view.addSubview(activityIndicatorView)
                    activityIndicatorView.center = self.view.center
                    
                    activityIndicatorView.startAnimating()
                    
                    
                    userInteractionOff = true
                    
                    var loginParams = ["apple_id":apple_id,"ip":"127.0.0.1", "subscriptionForm": "1"]
                    if device_uuid != nil{
                        loginParams.updateValue(device_uuid, forKey: "device_uuid")
                    }
                    if device_token_id != nil{
                        loginParams.updateValue(device_token_id, forKey: "device_token")
                    }
                    
                    // Send Server Request for Sign In
                    post(loginParams as! Dictionary<String, String>, url: "login", method: "POST") { (succeeded, msg) -> () in
                        DispatchQueue.main.async(execute: {
                            self.signIn.setTitle("Sign In", for: UIControl.State())
                            activityIndicatorView.stopAnimating()
                        //    self.loginView.isUserInteractionEnabled = true
                            // On Success save authentication_token in Core Data
                            if(msg)
                            {
                                // Get Data From Core Data
                                if succeeded["message"] != nil{
                                    self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                                }
                                if succeeded["body"] != nil{
                                    if let body = succeeded["body"] as? NSDictionary{
                                        if var _ = body["oauth_token"] as? String
                                        {
                                            if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                                userInteractionOff = false
                                                mergeAddToCart()
                                               // UserDefaults.standard.removeObject(forKey: "AppleEmail")
                                                self.showHomePage()
                                            }else{
                                                userInteractionOff = false
                                                self.view.makeToast(NSLocalizedString("Unable to Login",comment: ""), duration: 5, position: CSToastPositionCenter)
                                            }
                                        }
                                        else
                                        {
                                            self.signUp.isEnabled = true
                                            self.signIn.isEnabled = true
                                            self.privacyPolicy.isEnabled = true
                                            facebook_uid = nil
                                            let pv = SignupViewController()
                                            pv.tempDic = body
                                         
                                            self.navigationController?.pushViewController(pv, animated: true)
                                        }
                                    }
                                    
                                }
                                
                            }
                            else{
                                let a = validation as NSDictionary
                                signupValidation.removeAll(keepingCapacity: false)
                                if  (UIDevice.current.userInterfaceIdiom == .phone){
                                    
                                    signupValidationKeyValue.removeAll(keepingCapacity: false)
                                    for (key,value) in a  {
                                        signupValidation.append(value as AnyObject)
                                        signupValidationKeyValue.append(key as AnyObject)
                                        
                                    }
                                    
                                    let count = signupValidation.count
                                    
                                    for index in (0..<count) {
                                        showToast(message: "\(signupValidationKeyValue[index]) - \(signupValidation[index] as! String).\n", controller: self)
                                    }
                                    
                                }else{
                                    
                                    for (_,value) in a  {
                                        signupValidation.append(value as AnyObject)
                                    }
                                    if signupValidation.count != 0{
                                        let secondViewController = SignUpValidationController()

                                        secondViewController.validationArray = signupValidation as NSArray?


                                        secondViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                                        
                                        secondViewController.preferredContentSize = CGSize(width: self.view.bounds.width*0.8,height: self.view.bounds.height*0.35)
                                        
                                        let popoverpresentationviewcontroller = secondViewController.popoverPresentationController
                                        //popoverpresentationviewcontroller?.delegate = self
                                        popoverpresentationviewcontroller?.permittedArrowDirections = UIPopoverArrowDirection()
                                        popoverpresentationviewcontroller?.sourceRect = CGRect( x: 0, y: self.view.bounds.height/3 , width: self.view.bounds.width , height: self.view.bounds.height/3)
                                        popoverpresentationviewcontroller?.sourceView = self.view
                                        self.navigationController?.present(secondViewController, animated: false, completion: nil)
                                    }
                                    
                                }
                                self.showRequiredAlert()
                            }
                        })
                    }
                }else{
                    // No Internet Connection Message
                    showToast(message: network_status_msg, controller: self)
                   // self.loginView.isUserInteractionEnabled = true
                }
                
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                appleIDProvider.getCredentialState(forUserID: appleId) {  (credentialState, error) in
                     switch credentialState {
                        case .authorized:
                            print("autho=== \(appleId)")
                            // The Apple ID credential is valid.
                            break
                        case .revoked:
                            print("revo=== \(appleId)")
                            // The Apple ID credential is revoked.
                            break
                        case .notFound:
                        print("not=== \(appleId)")
                            // No credential was found, so show the sign-in UI.
                        default:
                            break
                     }
                }
                //Write your code
                
            } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
                
                let appleUsername = passwordCredential.user
                print("pwd===\(appleUsername)")
                let applePassword = passwordCredential.password
                print(applePassword)
                //Write your code
                
            }
        } else {
            // Fallback on earlier versions
        }

    }
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {

        return self.view.window!

    }
    #endif
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //call sign in form
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.mixWithOthers)
            try audioSession.setActive(true)
        }catch{
            // handle error
        } 
        
        imgUser = LoginPageImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        view.addSubview(imgUser)
        
        if let tabBarObject = self.tabBarController?.tabBar {
            tabBarObject.isHidden = true
        }
        logoutUser = true
        if (auth_user == true  && oauth_token != nil)
        {
            
            auth_user = false
            logoutUser = false
            refreshMenu = true
            let imageViewTemp = createImageView(CGRect(x: 0, y: 0, width: view.bounds.width , height: view.bounds.height), border: false)
            imageViewTemp.backgroundColor = navColor
            imageViewTemp.image = UIImage(named: "Splash")
            view.addSubview(imageViewTemp)
            showHomePage()
            return
        }
      // setupSOAppleSignIn()
        
        AccessToken.current = nil
        loginVieww =  true
        view.backgroundColor = bgColor
        isPresented = false
       
       
        // Create signUp Button
        if DeviceType.IS_IPHONE_X
        {
            signUp = createButton(CGRect(x: 15 , y: view.bounds.height - 90, width: view.bounds.width/2 - 20, height: 40) ,title: NSLocalizedString("Sign Up",comment: "") , border: true, bgColor: true, textColor: textColorPrime)
        }
        else
        {
             signUp = createButton(CGRect(x: 15 , y: view.bounds.height - 80, width: view.bounds.width/2 - 20, height: 40) ,title: NSLocalizedString("Sign Up",comment: "") , border: true, bgColor: true, textColor: textColorPrime)
        }
        signUp.backgroundColor = navColor
        signUp.layer.shadowColor = navColor.cgColor
        signUp.layer.borderColor = navColor.cgColor
        signUp.layer.cornerRadius = cornerRadiusSmall
        signUp.addTarget(self, action: #selector(LoginViewController.signUpAction), for: .touchUpInside)
        view.addSubview(signUp)
        
        if DeviceType.IS_IPHONE_X
        {
              signIn = createButton(CGRect(x: view.bounds.width/2.0 + 5,  y: view.bounds.height - 90, width: view.bounds.width/2 - 20, height: 40) ,title: NSLocalizedString("Sign In",comment: "") , border: true, bgColor: true, textColor: textColorPrime)
        }
        else
        {
              signIn = createButton(CGRect(x: view.bounds.width/2.0 + 5,  y: view.bounds.height - 80, width: view.bounds.width/2 - 20, height: 40) ,title: NSLocalizedString("Sign In",comment: "") , border: true, bgColor: true, textColor: textColorPrime)
        }
      
        signIn.backgroundColor = navColor
        signIn.layer.shadowColor = navColor.cgColor
        signIn.layer.borderColor = navColor.cgColor
        signIn.layer.cornerRadius = cornerRadiusSmall
        signIn.addTarget(self, action: #selector(LoginViewController.signInAction), for: .touchUpInside)
        view.addSubview(signIn)
        
        // Browse as a Guest Button
        if DeviceType.IS_IPHONE_X
        {
              homePage = createButton(CGRect(x: (view.bounds.width/2)-150, y: view.bounds.height - 55, width: 80, height: 20), title: NSLocalizedString("Browse as a guest",comment: ""),border: false,bgColor: true , textColor: textColorLight)
        }
        else
        {
              homePage = createButton(CGRect(x: (view.bounds.width/2)-150, y: view.bounds.height - 45, width: 80, height: 20), title: NSLocalizedString("Browse as a guest",comment: ""),border: false,bgColor: true , textColor: textColorLight)
        }
      
        homePage.backgroundColor = UIColor.clear
        homePage.addTarget(self, action: #selector(LoginViewController.logoutSite), for: .touchUpInside)
        homePage.sizeToFit()
        homePage.isHidden = true
        view.addSubview(homePage)
        
        // Terms and Privacy Buttons
        if DeviceType.IS_IPHONE_X
        {
              terms = createButton(CGRect(x: (view.bounds.width/2)-100, y: view.bounds.height - 55, width: 60, height: 20), title: NSLocalizedString("Terms",comment: ""),border: false,bgColor: true , textColor: textColorLight)
        }
        else
        {
              terms = createButton(CGRect(x: (view.bounds.width/2)-100, y: view.bounds.height - 45, width: 60, height: 20), title: NSLocalizedString("Terms",comment: ""),border: false,bgColor: true , textColor: textColorLight)
        }
      
        terms.backgroundColor = UIColor.clear
        terms.addTarget(self, action: #selector(LoginViewController.termsConditions), for: .touchUpInside)
        terms.sizeToFit()
        view.addSubview(terms)
        
        if DeviceType.IS_IPHONE_X
        {
            privacyPolicy = createButton(CGRect(x: (view.bounds.width/2), y: view.bounds.height - 55, width: 80, height: 20), title: NSLocalizedString("Privacy Policy",comment: ""),border: false,bgColor: true , textColor: textColorLight)
        }
        else
        {
            privacyPolicy = createButton(CGRect(x: (view.bounds.width/2), y: view.bounds.height - 45, width: 80, height: 20), title: NSLocalizedString("Privacy Policy",comment: ""),border: false,bgColor: true , textColor: textColorLight)
        }

        privacyPolicy.backgroundColor = UIColor.clear
        privacyPolicy.addTarget(self, action: #selector(LoginViewController.privacy), for: .touchUpInside)
        privacyPolicy.sizeToFit()
        view.addSubview(privacyPolicy)
                        

        homePage.titleLabel?.font = homePage.titleLabel?.font.withSize(12)
        privacyPolicy.titleLabel?.font = homePage.titleLabel?.font.withSize(12)
        terms.titleLabel?.font = homePage.titleLabel?.font.withSize(12)
        
       

        
        self.title = NSLocalizedString("Sign In",comment: "")
        self.edgesForExtendedLayout = UIRectEdge.all;
        self.automaticallyAdjustsScrollViewInsets = false;
        if logoutUser == false{
            signIn.isHidden = true
            signUp.isHidden = true
        }

         NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.browseAsGuestUser(_:)), name: NSNotification.Name(rawValue: "BrowseAsGuest"), object: nil)

        if (AccessToken.current != nil)
        {
            // User is already logged in, do work such as! go to next view controller.
            self.view.alpha = 0.6
        }
        else
        {
            if let facebookSdk = Bundle.main.infoDictionary?["FacebookAppID"] as? String {
                if facebookSdk != "" && (logoutUser == true) {

                    if DeviceType.IS_IPHONE_X
                    {
                        loginView.frame = CGRect(x: 15 ,  y: view.bounds.height - 150, width: view.bounds.width - 30, height: 50)
                    }
                    else
                    {
                        loginView.frame = CGRect(x: 15 ,  y: view.bounds.height - 140, width: view.bounds.width - 30, height: 50)
                    }
                    
                    view.addSubview(loginView)
                    loginView.permissions = ["public_profile", "email"]
                    
                    loginView.delegate = self
                }
            }
            
        }
         

        // Description and Title of Slideshow
        if DeviceType.IS_IPHONE_X
        {
            info1 = createLabel(CGRect(x: 10, y: view.bounds.height - 370 ,width: self.view.bounds.width - 10 , height: 60), text:"" , alignment: .center, textColor: textColorLight )

        }
        else
        {
            info1 = createLabel(CGRect(x: 10, y: view.bounds.height - 350 ,width: self.view.bounds.width - 10 , height: 60), text: "", alignment: .center, textColor: textColorLight )
        }
        
        info1.layer.borderColor = UIColor.red.cgColor
        info1.font = UIFont(name: fontBold, size: FONTSIZELarge)
        info1.textColor = textColorLight
        info1.textAlignment = NSTextAlignment.center
        info1.lineBreakMode = NSLineBreakMode.byWordWrapping
        info1.numberOfLines = 0
        
        if DeviceType.IS_IPHONE_X
        {
            info2 = createLabel(CGRect(x: 5, y: view.bounds.height - 280,width: self.view.bounds.width - 10 , height: 80), text: "", alignment: .center, textColor: textColorLight )
        }
        else
        {
            info2 = createLabel(CGRect(x: 5, y: view.bounds.height - 270,width: self.view.bounds.width - 10 , height: 80), text: "", alignment: .center, textColor: textColorLight )
        }
        
        info2.font = UIFont(name: fontName, size: FONTSIZEMedium)
        info2.textColor = textColorLight
        info2.textAlignment = NSTextAlignment.center
        info2.lineBreakMode = NSLineBreakMode.byWordWrapping
        info2.numberOfLines = 0
        view.addSubview(info1)
        view.addSubview(info2)
        
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            let btnAuthorization = ASAuthorizationAppleIDButton()
            btnAuthorization.frame = CGRect(x: 15, y: view.bounds.height - 200, width: view.bounds.width - 30, height: 50)
            btnAuthorization.layer.cornerRadius = 5
           

                 //  btnAuthorization.center = self.view.center

            btnAuthorization.addTarget(self, action: #selector(LoginViewController.actionHandleApple), for: .touchUpInside)

                   self.view.addSubview(btnAuthorization)
        } else {
            // Fallback on earlier versions
        }
        #endif
 
    }
    func animateImageView() {
//        CATransaction.begin()
//        view.layer.removeAllAnimations()
//        CATransaction.flush()
//        CATransaction.setAnimationDuration(animationDuration)
//        CATransaction.setCompletionBlock {
//            let delay = DispatchTime.now() + Double(Int64(self.switchingInterval * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//            DispatchQueue.main.asyncAfter(deadline: delay) {
//                self.info1.text = nil
//                self.info2.text = nil
//                self.animateImageView()
//            }
//        }
//
//        let transition = CATransition()
//        transition.type = kCATransitionFade
//        /*
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromRight
//        */
//        imgUser.layer.add(transition, forKey: kCATransition)
//        self.info1.text = (tempString1[index] as! String)
//        self.info2.text = (tempString2[index] as! String)
//        imgUser.image = (images[index] as! UIImage)
//
//        CATransaction.commit()
//        index = index < images.count - 1 ? index + 1 : 0


        view.layer.removeAllAnimations()
        UIView.transition(with: self.imgUser, duration: animationDuration, options: .transitionCrossDissolve, animations: {

            self.info1.text = (tempString1[self.index] as! String)
            let labelText = tempString2[self.index] as! String
            let labelHeight = self.heightForView(text: labelText)
            
            if DeviceType.IS_IPHONE_X
            {
                self.info2.frame = CGRect(x: 5, y: self.view.bounds.height - (labelHeight+220),width: self.view.bounds.width - 10 , height: labelHeight)
            }
            else
            {
                self.info2.frame = CGRect(x: 5, y: self.view.bounds.height - (labelHeight+210),width: self.view.bounds.width - 10 , height: labelHeight)
            }
            self.info1.frame.origin.y = self.info2.frame.origin.y - 70
            self.info2.text = (tempString2[self.index] as! String)
            self.imgUser.image = (images[self.index] as! UIImage)


        }) { (complete) in

            let delay = DispatchTime.now() + Double(Int64(self.switchingInterval * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delay) {
                  self.info1.text = nil
                  self.info2.text = nil
                self.index = self.index < images.count - 1 ? self.index + 1 : 0
                self.animateImageView()
            }
        }
 
       
    }
    
    func heightForView(text:String) -> CGFloat
    {
        let label = UILabel(frame: CGRect(x:0,y:0,width:self.view.bounds.width-10,height:CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.font = UIFont(name: fontName, size: FONTSIZEMedium)
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.text = text
        label.sizeToFit()
        let labHeight = label.frame.size.height
        label.removeFromSuperview()
        return labHeight
    }
    
        
    override func viewWillAppear(_ animated: Bool) {

        
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if let tabBarObject = self.tabBarController?.tabBar {
            tabBarObject.isHidden = true
        }
        switch(slideShowCount){
        case 1:
            
            let bounds = UIScreen.main.bounds
            let height = bounds.size.height
//            if(UIDevice.current.userInterfaceIdiom == .phone){
            switch height
            {
            case 568.0:
                // spalshName = "Splash-640x960"
                images = [UIImage(named: "Welcome_SlideShow1_640x1136.png")!]                
            case 667.0:
                // spalshName = "Splash-750x1334"
                images = [UIImage(named: "Welcome_SlideShow1_750x1334.png")!]
            case 736.0:
                //spalshName = "Splash-1242x2208"
                images = [UIImage(named: "Welcome_SlideShow1_1242x2208.png")!]
            default:
                
                images = [UIImage(named: "Welcome_SlideShow1_750x1334.png")!]
                
            }
//            }
//            else {
//                images = [UIImage(named: "Welcome_SlideShow1_1536x2208.png")!]
//            }
            // images = [UIImage(named: "Welcome_SlideShow1.png")!]
            tempString1 = [ Welcome_SlideShow1_title.html2String as NSString]
            tempString2 = [ Welcome_SlideShow1_description.html2String as NSString]
            
            
        case 2:
            
            let bounds = UIScreen.main.bounds
            let height = bounds.size.height
//            if(UIDevice.current.userInterfaceIdiom == .phone){
            switch height
            {
            case 568.0:
                // spalshName = "Splash-640x960"
                images = [UIImage(named: "Welcome_SlideShow1_640x1136.png")!,UIImage(named: "Welcome_SlideShow2_640x1136.png")!]
                
            case 667.0:
                // spalshName = "Splash-750x1334"
                images = [UIImage(named: "Welcome_SlideShow1_750x1334.png")!,UIImage(named: "Welcome_SlideShow2_750x1334.png")!]
            case 736.0:
                //spalshName = "Splash-1242x2208"
                images = [UIImage(named: "Welcome_SlideShow1_1242x2208.png")!,UIImage(named: "Welcome_SlideShow2_1242x2208.png")!]
            default:
                
                images = [
                    UIImage(named: "Welcome_SlideShow1_750x1334.png")!,
                    UIImage(named: "Welcome_SlideShow2_750x1334.png")!]
            }
//            }
//            else {
//                images = [UIImage(named: "Welcome_SlideShow1_1536x2208.png")!,UIImage(named: "Welcome_SlideShow2_1536x2208.png")!]
//            }
            tempString1 = [ Welcome_SlideShow1_title.html2String as NSString, Welcome_SlideShow2_title.html2String as NSString]
            tempString2 = [ Welcome_SlideShow1_description.html2String as NSString,Welcome_SlideShow2_description.html2String as NSString]
            
        case 3:
            
            let bounds = UIScreen.main.bounds
            let height = bounds.size.height
//            if(UIDevice.current.userInterfaceIdiom == .phone){
            switch height
            {
            case 568.0:
                // spalshName = "Splash-640x960"
                images = [UIImage(named: "Welcome_SlideShow1_640x1136.png")!,UIImage(named: "Welcome_SlideShow2_640x1136.png")!,UIImage(named: "Welcome_SlideShow3_640x1136.png")!]
                
            case 667.0:
                // spalshName = "Splash-750x1334"
                images = [UIImage(named: "Welcome_SlideShow1_750x1334.png")!,UIImage(named: "Welcome_SlideShow2_750x1334.png")!,UIImage(named: "Welcome_SlideShow3_750x1334.png")!]
            case 736.0:
                //spalshName = "Splash-1242x2208"
                images = [UIImage(named: "Welcome_SlideShow1_1242x2208.png")!,UIImage(named: "Welcome_SlideShow2_1242x2208.png")!,UIImage(named: "Welcome_SlideShow3_1242x2208.png")!]
            default:
                
                images = [
                    UIImage(named: "Welcome_SlideShow1_750x1334.png")!,
                    UIImage(named: "Welcome_SlideShow2_750x1334.png")!,
                    UIImage(named: "Welcome_SlideShow3_750x1334.png")!]
            }
//            }
//            else {
//                  images = [UIImage(named: "Welcome_SlideShow1_1536x2208.png")!,UIImage(named: "Welcome_SlideShow2_1536x2208.png")!,UIImage(named: "Welcome_SlideShow3_1536x2208.png")!]
//            }
            tempString1 = [ Welcome_SlideShow1_title.html2String as NSString, Welcome_SlideShow2_title.html2String as NSString, Welcome_SlideShow3_title.html2String as NSString]
            tempString2 = [ Welcome_SlideShow1_description.html2String as NSString,Welcome_SlideShow2_description.html2String as NSString,Welcome_SlideShow3_description.html2String as NSString]
            
        default:
            print("default")
        }
        
        self.info1.text = (tempString1[index] as! String)
        
        let labelText = tempString2[self.index] as! String
        let labelHeight = self.heightForView(text: labelText)
        if DeviceType.IS_IPHONE_X
        {
            self.info2.frame = CGRect(x: 5, y: self.view.bounds.height - (labelHeight+170),width: self.view.bounds.width - 10 , height: labelHeight)
        }
        else
        {
            self.info2.frame = CGRect(x: 5, y: self.view.bounds.height - (labelHeight+160),width: self.view.bounds.width - 10 , height: labelHeight)
        }
        
        self.info1.frame.origin.y = self.info2.frame.origin.y - 70
        self.info2.text = (tempString2[index] as! String)
        imgUser.image = (images[index] as! UIImage)
        
        animateImageView()
        
        if iscomingfrom != "store"
        {
            navigationController?.navigationBar.isHidden = true
        }
        else
        {

            removeNavigationImage(controller: self)
            self.title = NSLocalizedString("", comment: "")
            let leftNavView = UIView(frame: CGRect(x:0, y:0, width:44, height:44))
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")
            leftNavView.addSubview(backIconImageView)
            
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem

        
        }

        if logoutUser == true{
            signUp.isHidden = false
            signIn.isHidden = false
            if browseAsGuest == true{
                self.homePage.frame.origin.x = (self.view.bounds.width/2)-150
                self.terms.frame.origin.x = self.view.bounds.width/2
                self.privacyPolicy.frame.origin.x = (self.view.bounds.width/2)+40
                 homePage.isHidden = false
            }
            else{
                self.terms.frame.size.width = view.bounds.width/2 - 20
                self.terms.frame.origin.x = 15
                self.privacyPolicy.frame.size.width = view.bounds.width/2 - 20
                self.privacyPolicy.frame.origin.x = (self.view.bounds.width/2)+5
                
            }
        }

    }

    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)
        
    }

    @objc func browseAsGuestUser(_ notification: Foundation.Notification)
    {
        DispatchQueue.main.async {
            if browseAsGuest == true {
                self.homePage.frame.origin.x = (self.view.bounds.width/2)-150
                self.terms.frame.size.width = 60
                self.terms.frame.origin.x = self.view.bounds.width/2
                self.terms.frame.size.width = 80
                self.privacyPolicy.frame.origin.x = (self.view.bounds.width/2)+40
                self.homePage.isHidden = false
            }
        }
       
    }
    
    @objc func logoutSite(){
        oauth_token = ""
        logoutUser = true
        refreshMenu = true
        let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
        userDefaults!.set(oauth_token, forKey: "oauth_token")
        userDefaults!.set(oauth_secret, forKey: "oauth_secret")
        showHomePage()
    }
    

    // MARK: - Member Homepage redirection
    
    
   func showHomePage () {
        menuRefreshConter = 0
        //fOR SHOWING WELCOME MESSAGE ON ADVANCEACTIVITYFEED
        let defaults = UserDefaults.standard
        defaults.set("LoginScreenViewController", forKey: "Comingfrom")

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
    
    
    // MARK: - Signup redirection
    @objc func signUpAction() {
        fbFirstName = ""
        fbLastName = ""
        fbEmail = ""
        appleFirstName = ""
        appleLastName = ""
        appleEmail = ""
        apple_id = ""
        validationMessage = ""
        let presentedVC = SignupViewController()
        navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    // MARK: - Server Connection For SignIn

    @objc func signInAction()
    {
        let presentedVC = LoginScreenViewController()
        presentedVC.fromDashboard = false
        self.navigationController?.pushViewController(presentedVC, animated: true)
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
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        
        setNavigationImage(controller: self)
        self.navigationController?.navigationBar.alpha = 1
        //FBSDKAccessToken.setCurrentAccessToken(nil)
        
    }
    
    /*!
     @abstract Sent to the delegate when the button was used to login.
     @param loginButton the sender
     @param result The results of the login
     @param error The error (if any) from the login
     */
    public func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {
        if(error == nil)
        {
            // loginView.isUserInteractionEnabled = false
            self.returnUserData()
            
        }
        else
        {
           //  loginView.isUserInteractionEnabled = true
            //print(error.localizedDescription)
        }
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton!) {
    }
    
    // Get User Information From Successful Facebook Login
    func returnUserData()
    {
        var fbAccessTokenn : String!
        if AccessToken.current != nil{
            
            self.signUp.isEnabled = false
            self.signIn.isEnabled = false
            self.privacyPolicy.isEnabled = false
            self.terms.isEnabled = false
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, gender,email,picture.type(large)"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    
                    
                    
                    let tempResult = result as! NSDictionary
                    
                    let id = tempResult["id"]! as! String

                    if tempResult["email"] != nil
                    {
                        fbEmail = tempResult["email"]! as! String
                    }else
                    {
                        fbEmail = ""
                    }
                    if tempResult["gender"] != nil
                    {
                        
                        fbGender = tempResult["gender"]! as! String
                    }
                    else
                    {
                        fbGender = ""
                    }
                    if tempResult["first_name"] != nil {

                        fbFirstName = tempResult["first_name"]! as! String
                        fbFirstName = fbFirstName.lowercased()
                    }else{
                        fbFirstName = ""
                    }

                    if tempResult["last_name"] != nil {

                        fbLastName = tempResult["last_name"]! as! String
                        fbLastName = fbLastName.lowercased()
                    }else{
                        fbLastName = ""
                    }
                    
                    if let picture = tempResult["picture"] as? NSDictionary{
                        if let data = picture["data"] as? NSDictionary{
                            fbImageUrl = data["url"] as! String
                        }
                    }
                    
                    fbAccessTokenn = AccessToken.current?.tokenString
                    // Check Internet Connection
                    if Reachabable.isConnectedToNetwork() {
                        self.view.addSubview(activityIndicatorView)
                        activityIndicatorView.center = self.view.center
                        
                        activityIndicatorView.startAnimating()
                        
                        
                        userInteractionOff = true
                        
                        var loginParams = ["facebook_uid":id, "code":"%2520", "access_token":fbAccessTokenn, "ip":"127.0.0.1", "subscriptionForm": "1"]
                        if device_uuid != nil{
                            loginParams.updateValue(device_uuid, forKey: "device_uuid")
                        }
                        if device_token_id != nil{
                            loginParams.updateValue(device_token_id, forKey: "device_token")
                        }
                        
                        // Send Server Request for Sign In
                        post(loginParams as! Dictionary<String, String>, url: "login", method: "POST") { (succeeded, msg) -> () in
                            DispatchQueue.main.async(execute: {
                                self.signIn.setTitle("Sign In", for: UIControl.State())
                                activityIndicatorView.stopAnimating()
                            //    self.loginView.isUserInteractionEnabled = true
                                // On Success save authentication_token in Core Data
                                if(msg)
                                {
                                    // Get Data From Core Data
                                    if succeeded["message"] != nil{
                                        self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                                    }
                                    if succeeded["body"] != nil{
                                        if let body = succeeded["body"] as? NSDictionary{
                                            if var _ = body["oauth_token"] as? String
                                            {
                                                if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                                    userInteractionOff = false
                                                    mergeAddToCart()
                                                    self.showHomePage()
                                                }else{
                                                    userInteractionOff = false
                                                    self.view.makeToast(NSLocalizedString("Unable to Login",comment: ""), duration: 5, position: CSToastPositionCenter)
                                                }
                                            }
                                            else
                                            {
                                                self.signUp.isEnabled = true
                                                self.signIn.isEnabled = true
                                                self.privacyPolicy.isEnabled = true
                                                
                                                let pv = SignupViewController()
                                                pv.tempDic = body
                                                facebook_uid = id
                                                code = "%2520"
                                                access_token = fbAccessTokenn
                                                self.navigationController?.pushViewController(pv, animated: true)
                                            }
                                        }
                                        
                                    }
                                    
                                }
                                else{
                                    let a = validation as NSDictionary
                                    signupValidation.removeAll(keepingCapacity: false)
                                    if  (UIDevice.current.userInterfaceIdiom == .phone){
                                        
                                        signupValidationKeyValue.removeAll(keepingCapacity: false)
                                        for (key,value) in a  {
                                            signupValidation.append(value as AnyObject)
                                            signupValidationKeyValue.append(key as AnyObject)
                                            
                                        }
                                        
                                        let count = signupValidation.count
                                        
                                        for index in (0..<count) {
                                            showToast(message: "\(signupValidationKeyValue[index]) - \(signupValidation[index] as! String).\n", controller: self)
                                        }
                                        
                                    }else{
                                        
                                        for (_,value) in a  {
                                            signupValidation.append(value as AnyObject)
                                        }
                                        if signupValidation.count != 0{
                                            let secondViewController = SignUpValidationController()

                                            secondViewController.validationArray = signupValidation as NSArray?


                                            secondViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                                            
                                            secondViewController.preferredContentSize = CGSize(width: self.view.bounds.width*0.8,height: self.view.bounds.height*0.35)
                                            
                                            let popoverpresentationviewcontroller = secondViewController.popoverPresentationController
                                            //popoverpresentationviewcontroller?.delegate = self
                                            popoverpresentationviewcontroller?.permittedArrowDirections = UIPopoverArrowDirection()
                                            popoverpresentationviewcontroller?.sourceRect = CGRect( x: 0, y: self.view.bounds.height/3 , width: self.view.bounds.width , height: self.view.bounds.height/3)
                                            popoverpresentationviewcontroller?.sourceView = self.view
                                            self.navigationController?.present(secondViewController, animated: false, completion: nil)
                                        }
                                        
                                    }
                                    self.showRequiredAlert()
                                }
                            })
                        }
                    }else{
                        // No Internet Connection Message
                        showToast(message: network_status_msg, controller: self)
                       // self.loginView.isUserInteractionEnabled = true
                    }
                }
            })
        }
    }
    
    @objc func termsConditions(){
        let pv = TermsViewController()
        pv.fromLoginPage = true
        navigationController?.pushViewController(pv, animated: true)
    }
    
    @objc func privacy(){
        let pv = PrivacyViewController()
        pv.fromLoginPage = true
        navigationController?.pushViewController(pv, animated: true)
    }
    
    func getAppId()
    {
        let bundleID = Bundle.main.bundleIdentifier
        let bundleResponse = URL(string:"https://itunes.apple.com/lookup?bundleId=\(bundleID!)")
        let task = URLSession.shared.dataTask(with: bundleResponse!, completionHandler: { (data, response, error) -> Void in
            
            if let urlContent = data
            {
                do
                {
                    let jsonResult =  try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    if let jsonResults = jsonResult as? NSDictionary
                    {
                        //print(jsonResults)
                        if jsonResults["resultCount"] as! Int != 0 {
                            if jsonResults["results"] != nil{
                                
                                if let results = jsonResults["results"] as? NSArray
                                {
                                    if let result = results[0] as? NSDictionary
                                    {
                                        let appId = result["trackId"]
                                        UserDefaults.standard.set(appId, forKey: "appItunesId")
                                        
                                    }
                                }
                            }
                        }
                    }
                }catch{
                    //print("JSON serialization failed")
                }
        }
        })
        task.resume()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showRequiredAlert(){
        if validationMessage != ""{
            validationMessage = validationMessage.html2String as String
            let alertTest = UIAlertView()
            alertTest.message = "\(validationMessage)"
            alertTest.addButton(withTitle: "Ok")
            alertTest.delegate = self
            alertTest.title = "Message"
            alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
            alertTest.show()
        }
        else if SubscriptionMessage != ""{
            if signUpUserSubscriptionEnabled == true {
                let presentedVC = SignupUserSubscriptionViewController()
                self.navigationController?.pushViewController(presentedVC, animated: true)
            }else{
                let myString: String = "<a href="
                
                var myStringArr = SubscriptionMessage.components(separatedBy: myString)
                let tempAnotherString = myStringArr[1]
                let temp1: String = ">"
                
                var myStringArr1 = tempAnotherString.components(separatedBy: temp1 )
                self.Subscriptionurl = myStringArr1[0]
                
                self.Subscriptionurl = self.Subscriptionurl.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
                
                SubscriptionMessage = SubscriptionMessage.html2String as String
                let alertTest = UIAlertView()
                alertTest.message = "\(SubscriptionMessage)"
                alertTest.addButton(withTitle: "Ok")
                alertTest.delegate = self
                alertTest.title = "Message"
                alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
                alertTest.show()
            }
        }
    }
    
}
#if compiler(>=5.1)
extension LoginViewController: ASAuthorizationControllerDelegate,ASAuthorizationControllerPresentationContextProviding {

}
#endif
