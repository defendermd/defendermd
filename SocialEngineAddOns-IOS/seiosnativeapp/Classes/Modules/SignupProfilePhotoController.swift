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

//  SignupProfilePhotoController.swift

import UIKit
import CoreData
import AVFoundation
class SignupProfilePhotoController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    var chhosePhotoButton:UIButton!
    var cameraButton:UIButton!
    var skipButton:UIButton!
    var base64String: String!
    var imageView : UIImageView!
    var Subscriptionurl: String = ""
    var leftBarButtonItem : UIBarButtonItem!
    var rightBarButtonItem : UIBarButtonItem!
    var container: UIView = UIView()
    var loadingView: UIView = UIView()
    var validationValues = NSDictionary()
  //  var actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(SignupProfilePhotoController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        self.title = NSLocalizedString("Upload your photo", comment: "")
        mediaType = "image"
        multiplePhotoSelection = false
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        if(UIDevice.current.userInterfaceIdiom == .phone){
           imageView  = UIImageView(frame:CGRect(x: view.bounds.width/2.0 - 150, y: TOPPADING + 40, width: 300, height: 300));
        }
        else {
           imageView  = UIImageView(frame:CGRect(x: view.bounds.width/2.0 - 210, y: TOPPADING + 40, width: 420, height: 300));
        }
        
        
        //        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
        //        self.imageView.clipsToBounds = true;
        self.imageView.layer.borderWidth = 3.0;
        self.imageView.layer.borderColor = UIColor.white.cgColor
        self.imageView.clipsToBounds = true
        self.imageView.contentMode = .scaleAspectFill
        
        
        view.addSubview(imageView)
        
        if fbImageUrl != "" {
            let url = URL(string: fbImageUrl)
            getDataFromUrl(url!) { (data, response, error)  in
                DispatchQueue.main.async { () -> Void in
                    guard let data = data , error == nil else { return }
                    self.imageView.image = UIImage(data: data)
                    let imageArray = [self.imageView.image! as UIImage]
                    filePathArray.removeAll(keepingCapacity: false)
                    filePathArray = saveFileInDocumentDirectory(imageArray)
                    
                }
            }
            
        }else{
            self.imageView.image = UIImage(named:"user_profile_image.png")
        }
        
        cameraButton = createButton(CGRect(x: PADING, y: TOPPADING + 370 ,width: view.bounds.width/2.0 - PADING , height: ButtonHeight) , title: NSLocalizedString("Gallery",  comment: ""), border: true,bgColor: false, textColor: textColorDark)
        cameraButton.tag = 11
        cameraButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        cameraButton.addTarget(self, action: #selector(SignupProfilePhotoController.choosePhoto(_:)), for: .touchUpInside)
        view.addSubview(cameraButton)
        
        
        chhosePhotoButton = createButton(CGRect(x: view.bounds.width/2.0, y: TOPPADING + 370 ,width: view.bounds.width/2.0 - PADING , height: ButtonHeight), title: NSLocalizedString("Camera",  comment: ""), border: true,bgColor: false, textColor: textColorDark)
        chhosePhotoButton.tag = 22
        chhosePhotoButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        chhosePhotoButton.addTarget(self, action: #selector(SignupProfilePhotoController.chooseCam(_:)), for: .touchUpInside)
        view.addSubview(chhosePhotoButton)
        
        skipButton = createButton(CGRect(x: PADING, y: TOPPADING + 390 + ButtonHeight ,width: view.bounds.width - 2*PADING , height: ButtonHeight) , title: NSLocalizedString("Save Photo",  comment: ""), border: true,bgColor: false, textColor: textColorDark)
        skipButton.tag = 11
        skipButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        skipButton.addTarget(self, action: #selector(SignupProfilePhotoController.save(_:)), for: .touchUpInside)
        view.addSubview(skipButton)
        
        var hasValidator = false
        if PhotoForm.count > 0{
            if let photodic = PhotoForm[0] as? NSDictionary{
                hasValidator = (photodic["hasValidator"] as? Bool)!
            }
        }
        if hasValidator == false{
            let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
            rightNavView.backgroundColor = UIColor.clear
            let optionButton = createButton(CGRect(x: 15,y: 0,width: 50,height: 44), title: "Skip", border: false, bgColor: false, textColor: textColorPrime)
            // optionButton.setImage(UIImage(named: "option")!.maskWithColor(color: textColorPrime), for: UIControl.State())
            optionButton.addTarget(self, action: #selector(SignupProfilePhotoController.save(_:)), for: .touchUpInside)
            rightNavView.addSubview(optionButton)
            
            let barButtonItemshow = UIBarButtonItem(customView: rightNavView)
            
            self.navigationItem.rightBarButtonItem = barButtonItemshow
            
        }

        
       
        filePathArray.removeAll(keepingCapacity: false)
    }
    
    func spiner(uiView: UIView)
    {
        //print("spiner.....")
        //  var container: UIView = UIView()
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(rgbValue: 0xffffff, alpha: 0.3)
        
        activityIndicatorView.center = self.view.center
        container.addSubview(activityIndicatorView)
        uiView.addSubview(container)
        activityIndicatorView.startAnimating()
     
    }

    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    @objc func choosePhoto(_ sender: UIButton){
        DispatchQueue.main.async{
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        if UIDevice.current.userInterfaceIdiom != .pad{
            image.allowsEditing = true
        }
            DispatchQueue.main.async{
        self.present(image, animated: true, completion: nil)
            }
    }
    }
    
    func showHomePage () {
        menuRefreshConter = 0
        //fOR SHOWING WELCOME MESSAGE ON ADVANCEACTIVITYFEED
        let defaults = UserDefaults.standard
        defaults.set("LoginScreenViewController", forKey: "Comingfrom")
        createTabs()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(baseController, animated: false)
        self.view.endEditing(true)

    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func chooseCam (_ sender: UIButton){
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.notDetermined {
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (videoGranted: Bool) -> Void in
                //print("You have not determined====")
                // User clicked ok
                if (videoGranted) {
                    //print("open camera======")
                    self.chooseCamera()
                    // User clicked don't allow
                } else {
                    //print("Check not allow")
                    
                }
            })
        }
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized {
            //print("You have not denied====")
            self.chooseCamera()
        }
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.denied {
            let alert = UIAlertController(title: "Access Denied", message: "This app does not have access to your camera. You can enable access in privacy settings.", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            //print("You have denied")
        }
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.restricted {
            //print("You have not restricted====")
        }
        
    }
    
    func chooseCamera(){
        DispatchQueue.main.async {
        
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.camera
        if UIDevice.current.userInterfaceIdiom != .pad{
            image.allowsEditing = true
        }
            DispatchQueue.main.async{
        self.present(image, animated: true, completion: nil)
            }
    }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
//        for dic in info{
//            if let photoDic = dic as? NSDictionary{
//                
//                if photoDic.object(forKey: UIImagePickerController.InfoKey.mediaType) as! String == ALAssetTypePhoto {
//                    
//                    if (photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) != nil){
//                        let image = photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) as! UIImage
//                        imageView.image = image
//                        //print(image as UIImage)
//                        let imageArray = [image as UIImage]
//                        filePathArray.removeAll(keepingCapacity: false)
//                        filePathArray = saveFileInDocumentDirectory(imageArray)
//                    }
//                }
//            }
//            
//        }
        let cameraImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let image = fixOrientation(img: cameraImage)
        imageView.image = image
        //print(image as UIImage)
        let imageArray = [image as UIImage]
        filePathArray.removeAll(keepingCapacity: false)
        filePathArray = saveFileInDocumentDirectory(imageArray)
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int)
    {
        
        switch buttonIndex
        {
        case 0:
            
            
            alertView.removeFromSuperview()
            alertView.isHidden = true
            if showAppSlideShow == 1 {
                let presentedVC  = SlideShowLoginScreenViewController()
                self.navigationController?.pushViewController(presentedVC, animated: true)
                
            }
            else{
            let presentedVC = LoginViewController()
            self.navigationController?.pushViewController(presentedVC, animated: true)
            }
            break
            
        default: break
            
        }
    }
    
    @objc func save(_ sender:UIButton) {
        spiner(uiView: view)
        self.container.isHidden = false
        var error = ""
        validation = [:]
        validationMessage = ""
        var hasValidator = false
        if PhotoForm.count > 0{
            if let photodic = PhotoForm[0] as? NSDictionary{
                hasValidator = (photodic["hasValidator"] as? Bool)!
            }
        }
        if hasValidator == true{
            if filePathArray.count == 0{
                activityIndicatorView.stopAnimating()
               // self.actInd.stopAnimating()
                self.container.isHidden = true
                error = NSLocalizedString("Please upload the photo-It is required.",comment: "")
            }
        }
        if error != ""{
            let alertController = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        else{
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            view.isUserInteractionEnabled = false
//            spinner.center = view.center
 //           spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
            UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)
        //    self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
  //          spiner(uiView: view)
            _ = Dictionary<String, String>()
            
            //Set Parameters (Token & Form Values) & path for Create/Edit Blog Form
            var parameter = [String:String]()
            var path = ""
            parameter = signupDictionary
            if device_uuid != nil{
                parameter["device_uuid"] = device_uuid
            }
            if device_token_id != nil{
                parameter["device_token"] = device_token_id
            }
            
            
            parameter["ip"] = "127.0.0.1"
            parameter["subscriptionForm"] = "1"
            
            if apple_id != ""{
               parameter["apple_id"] = "\(apple_id)"
            }
            
            if(facebook_uid != nil)
            {
                path = "signup?facebook_uid=" + String(facebook_uid) + "&code=%20%20&access_token=" + String(access_token)
            }
            else
            {
                path = "signup"
            }
            postForm(parameter, url: path, filePath: filePathArray, filePathKey: "photo" , SinglePhoto: true) { (succeeded, msg) -> () in
                // Send Server Request to Create/Edit Blog Entries
                DispatchQueue.main.async(execute: {
                    
                    activityIndicatorView.stopAnimating()
                //    self.actInd.stopAnimating()
                    self.container.isHidden = true
                    self.view.alpha = 1.0
                    self.view.isUserInteractionEnabled = true
                    if msg{
                        if signUpUserSubscriptionEnabled == true {
                            PhotoForm.removeAll(keepingCapacity: false)
                            let alertController = UIAlertController(title: "Message", message:
                                NSLocalizedString("You have successfully signed up. Please choose a Subscription Plan for your account.",comment: ""), preferredStyle: UIAlertController.Style.alert)
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
                            
                            
                        }else{
                            displayAlert("Info", error: "Account created successfully :)")
                            
                            if succeeded["body"] != nil{
                                if let _ = succeeded["body"] as? NSDictionary{
                                    // Perform Login Action
                                    if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                        
                                        mergeAddToCart()
                                        //UserDefaults.standard.removeObject(forKey: "AppleEmail")
                                        isLogin = true
                                        self.showHomePage()
                                    }else{
                                        showToast(message: NSLocalizedString("Unable to Login",comment: ""), controller: self)
                                    }
                                }
                            }
                            
                        }
                    }
                    else{
                        let a = validation as NSDictionary
                        self.validationValues = validation
                        signupValidation.removeAll(keepingCapacity: false)
                        if  (UIDevice.current.userInterfaceIdiom == .phone){
                            
//                            signupValidationKeyValue.removeAll(keepingCapacity: false)
//                            for (key,value) in a  {
//                                signupValidation.append(value as AnyObject)
//                                signupValidationKeyValue.append(key as AnyObject)
//
//                            }
                            //let count = signupValidation.count
//                            for index in 0 ..< count {
//
//                                self.view.makeToast("\(signupValidation[index] as! String)\n", duration: 5, position: "bottom")
//                            }
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
                                popoverpresentationviewcontroller?.delegate = self
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
        }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        fbImageUrl = ""
    }
    
    func showRequiredAlert(){
        if validationMessage != ""{
            validationMessage = validationMessage.html2String as String
//            let alertTest = UIAlertView()
//            alertTest.message = "\(validationMessage)"
//            alertTest.addButton(withTitle: "Ok")
//            alertTest.delegate = self
//            alertTest.title = "Message"
//            alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
//            alertTest.show()
            let alertController = UIAlertController(title: "Message", message:
                "\(validationMessage)", preferredStyle: UIAlertController.Style.alert)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                if showAppSlideShow == 1 {
                    let presentedVC  = SlideShowLoginScreenViewController()
                    self.navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                else{
                let presentedVC = LoginViewController()
                self.navigationController?.pushViewController(presentedVC, animated: true)
                }
            }))
            
            self.present(alertController, animated: true, completion: nil)
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
//                let alertTest = UIAlertView()
//                alertTest.message = "\(SubscriptionMessage)"
//                alertTest.addButton(withTitle: "Ok")
//                alertTest.delegate = self
//                alertTest.title = "Message"
//                alertTest.dismiss(withClickedButtonIndex: 0, animated: true)
//                alertTest.show()
//
                let alertController = UIAlertController(title: "Message", message:
                    "\(SubscriptionMessage)", preferredStyle: UIAlertController.Style.alert)
                
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                    if showAppSlideShow == 1 {
                        let presentedVC  = SlideShowLoginScreenViewController()
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        
                    }
                    else{
                    let presentedVC = LoginViewController()
                    self.navigationController?.pushViewController(presentedVC, animated: true)
                    }
                }))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        else
        {
            
            for (key,value) in self.validationValues
            {
                let validationName = key as? String ?? ""
                if validationName == "password"
                {
                    if let message = value as? String
                    {
                        let alertController = UIAlertController(title: "Message", message:
                            message, preferredStyle: UIAlertController.Style.alert)
                        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) -> Void in
                            if showAppSlideShow == 1 {
                                let presentedVC  = SlideShowLoginScreenViewController()
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                            }
                            else{
                                let presentedVC = LoginViewController()
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                            }
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                
            }
        }
    }
}
