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
//  LoginScreenViewController.swift
//  seiosnativeapp
//


import UIKit
import CoreData
var sign_in : Int = 0
var loginParams = ["":""]
var name = [String]()
var namelabel = [String]()
var isEnableOtp = false //Check otp plugin is enabled ot not
var login_id : String = "email"
var forgotpass : Int = 0
var isLogin = false

class LoginScreenViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var email : UITextField!               // TextField for email
    var pass : UITextField!                // TextField for Password
    var signIn : UIButton!                 // SignIn Action
    var signInotp : UIButton!              // Singin with otp action
    var loginCustomView : UIView!
    var fromDashboard : Bool!
    var forgotPassword : UIButton!
    var emailField: UITextField!
    var bottomView : UIView!
    var Subscriptionurl: String = ""
    var leftBarButtonItem : UIBarButtonItem!
    var rememberMeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont(name: "FontAwesome", size: 13)
        button.setTitleColor(textColorPrime, for: .normal)
        button.setTitle("\u{f0c8} Remember me", for: .normal)
        return button
    }()
    var isRememberMe = false
    var emailArray: [String] = []
    var passwordArray: [String] = []
    var userNameArray: [String] = []
    var imageUrlArray: [String] = []
    var credentialsTable : UITableView!
    let credentialsCellHeight = 50
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = true
        }
        self.view.backgroundColor = bgColor
        self.navigationController?.navigationBar.isHidden = false
        // self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        // self.navigationController?.interactivePopGestureRecognizer!.isEnabled = false
        removeNavigationImage(controller: self)
        
        self.title = NSLocalizedString("Sign In",comment: "")
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.01
        //always fill the view
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let imageViewTemp = LoginImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        imageViewTemp.alpha = 0.98
        imageViewTemp.backgroundColor = navColor
        
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        switch height
        {
        case 568.0:
            // spalshName = "Splash-640x960"
            imageViewTemp.image = UIImage(named: "Welcome_SlideShow1_640x1136.png")!
            
        case 667.0:
            // spalshName = "Splash-750x1334"
            imageViewTemp.image = UIImage(named: "Welcome_SlideShow1_750x1334.png")!
        case 736.0:
            //spalshName = "Splash-1242x2208"
            imageViewTemp.image = UIImage(named: "Welcome_SlideShow1_1242x2208.png")!
        default:
            
            imageViewTemp.image = UIImage(named: "Welcome_SlideShow1_750x1334.png")!
            
        }
        self.view.addSubview(imageViewTemp)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(LoginScreenViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        loginCustomView = createView( CGRect(x: 0, y: view.bounds.height/2 - 120, width: view.bounds.width, height: 200), borderColor: UIColor.clear , shadow: true)
        
        loginCustomView.backgroundColor = UIColor.clear
        view.addSubview(loginCustomView)
        
        bottomView = createView( CGRect(x: 0, y: view.bounds.height - 50, width: view.bounds.width, height: 50), borderColor: UIColor.clear , shadow: true)
        bottomView.backgroundColor = UIColor.clear
        
        let border1 = CALayer()
        let width1 = CGFloat(1.0)
        border1.borderColor = UIColor.white.cgColor
        border1.frame = CGRect(x: 0, y: 0, width: bottomView.frame.size.width, height: 1)
        
        border1.borderWidth = width1
        bottomView.layer.addSublayer(border1)
        bottomView.layer.masksToBounds = true
        view.addSubview(bottomView)
        bottomView.isHidden = true
        
        let defaults = UserDefaults.standard
        var namelabel : String = "Email Address"
        if let namelabel1 =  defaults.object(forKey: "namelabel") as? String
        {
            namelabel = namelabel1
        }
        email = createSkyTextField(CGRect(x: (view.bounds.width/2 - 140) , y: 2 ,width: 280 , height: 50), borderColor: borderColorClear,placeHolderText: String(format: NSLocalizedString("%@ %@", comment: ""), messageIcon , namelabel)  , corner: true)
        
        email.attributedPlaceholder = NSAttributedString (string: String(format:  NSLocalizedString("%@ %@",  comment: ""), messageIcon, namelabel), attributes: [NSAttributedString.Key.foregroundColor: textColorPrime])
        email.autocapitalizationType = .none
        
        email.textColor = textColorPrime
        email.tintColor = textColorPrime
        email.font =  UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        email.delegate = self
        email.tag = 11
        email.backgroundColor = UIColor.clear
        email.autocorrectionType = UITextAutocorrectionType.no
        loginCustomView.addSubview(email)
        self.email.keyboardType = UIKeyboardType.emailAddress
        email.becomeFirstResponder()
        email.returnKeyType = UIReturnKeyType.done
        
        if #available(iOS 9.0, *) {
            let item : UITextInputAssistantItem = email.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        } else {
            // Fallback on earlier versions
        }
        
        let border = CALayer()
        let width = CGFloat(0.5)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: email.frame.size.height - width, width: email.frame.size.width, height: 1)
        
        border.borderWidth = width
        email.layer.addSublayer(border)
        email.layer.masksToBounds = true
        email.textColor = textColorPrime
        
        
        let pwdIcon = "\u{F023}"
        pass = createSkyTextField(CGRect(x: (view.bounds.width/2 - 140) , y: getBottomEdgeY(inputView: email) + 11,width: 280 , height: 50),borderColor: borderColorClear,placeHolderText: String(format: NSLocalizedString("%@ Password", comment: ""), pwdIcon) , corner: true)  //"\u{F023} Password"
        pass.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        pass.attributedPlaceholder = NSAttributedString(string: String(format:  NSLocalizedString("%@ Password",  comment: ""), pwdIcon), attributes: [NSAttributedString.Key.foregroundColor: textColorPrime])
        pass.backgroundColor = UIColor.clear
        pass.tag = 22
        pass.tintColor = textColorPrime
        pass.textColor = textColorPrime
        pass.isHidden = true//false
        pass.returnKeyType = UIReturnKeyType.done
        pass.autocapitalizationType = .none
        pass.isSecureTextEntry = true
        pass.delegate = self
 
        
        let border2 = CALayer()
        let width2 = CGFloat(0.5)
        border2.borderColor = UIColor.white.cgColor
        border2.frame = CGRect(x: 0, y: pass.frame.size.height - width2, width: pass.frame.size.width, height: 1)
        
        border2.borderWidth = width
        pass.layer.addSublayer(border2)
        pass.layer.masksToBounds = true
        loginCustomView.addSubview(pass)
        
        if #available(iOS 9.0, *) {
            let item : UITextInputAssistantItem = pass.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        } else {
            // Fallback on earlier versions
        }
        signIn = createButton(CGRect(x: (view.bounds.width/2 - 140) , y: getBottomEdgeY(inputView: pass) + 17,width: 280 , height: 40) ,title: NSLocalizedString("Sign In",comment: "") , border: true, bgColor: true, textColor: textColorPrime)
        signIn.backgroundColor = navColor.withAlphaComponent(0.5)
        //        signIn.layer.shadowColor = navColor.CGColor
        signIn.layer.borderColor = UIColor.clear.cgColor
        signIn.layer.cornerRadius = cornerRadiusSmall
        signIn.titleLabel?.font = signIn.titleLabel?.font.withSize(15)
        signIn.isHidden = false
        signIn.isEnabled = false
        loginCustomView.addSubview(signIn)
        
        signInotp = createButton(CGRect(x: (view.bounds.width/2 - 140) , y: getBottomEdgeY(inputView: email) + 17 ,width: 280 , height: 40) ,title: NSLocalizedString("OTP Sign In",comment: "") , border: true, bgColor: true, textColor: textColorPrime)
        signInotp.backgroundColor = navColor
        //        signIn.layer.shadowColor = navColor.CGColor
        signInotp.layer.borderColor = UIColor.clear.cgColor
        signInotp.layer.cornerRadius = cornerRadiusSmall
        signInotp.isHidden = true
        signInotp.titleLabel?.font = signInotp.titleLabel?.font.withSize(15)
        loginCustomView.addSubview(signInotp)
        
        // Forgot Password Button
        let buttonWidth = (view.bounds.width - 80)/2
        forgotPassword = createButton(CGRect(x: view.bounds.width - buttonWidth - 10, y: getBottomEdgeY(inputView: signIn) + 5, width: (view.bounds.width - 80)/2 , height: 30) ,title: NSLocalizedString("Forgot your password?",comment: "") , border: false, bgColor: true, textColor: textColorPrime)
        
        rememberMeButton.frame = CGRect(x: 10, y: getBottomEdgeY(inputView: signIn) + 5, width: buttonWidth , height: 30)
        rememberMeButton.addTarget(self, action: #selector(LoginScreenViewController.setRememberMe(sender:)), for: .touchUpInside)
        loginCustomView.addSubview(rememberMeButton)
        self.setRememberMeTable()
        
        let formmode =  defaults.string(forKey: "formmode")
        
        if formmode ==  "default" || isEnableOtp == false
        {
            signInotp.isHidden = true
            signIn.isEnabled = true
            signIn.isHidden = false
            signIn.backgroundColor = navColor.withAlphaComponent(1.0)
            pass.isHidden = false
            signIn.addTarget(self, action: #selector(LoginScreenViewController.login), for: .touchUpInside)
        }
        else if formmode == "both"
        {
            signIn.addTarget(self, action: #selector(LoginScreenViewController.login), for: .touchUpInside)
            signInotp.addTarget(self, action: #selector(LoginScreenViewController.signInAction), for: .touchUpInside)
        }
        else
        {
            signInotp.isHidden = true
            signIn.isEnabled = true
            signIn.isHidden = false
            signIn.backgroundColor = navColor.withAlphaComponent(1.0)
            pass.isHidden = false
            signIn.addTarget(self, action: #selector(LoginScreenViewController.signInAction), for: .touchUpInside)
        }
        
        forgotPassword.layer.cornerRadius = cornerRadiusSmall
        forgotPassword.backgroundColor = UIColor.clear
        forgotPassword.addTarget(self, action: #selector(LoginScreenViewController.forgotPasswords), for: .touchUpInside)
        forgotPassword.isHidden = true//false
        self.rememberMeButton.isHidden = true
        forgotPassword.titleLabel?.font = forgotPassword.titleLabel?.font.withSize(13)
        
        loginCustomView.addSubview(forgotPassword)
        
        if sign_in == 1
        {
            sign_in = 0
            self.login()
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeNavigationImage(controller: self)
        let defaults = UserDefaults.standard
        let formmode =  defaults.string(forKey: "formmode")
        if !((formmode !=  "default" && formmode != "otp") && isEnableOtp != false)
        {
            self.forgotPassword.isHidden = false
            self.rememberMeButton.isHidden = false
        }
    }
    
    /// shows table view with saved id and passwords
    func setRememberMeTable() {
          let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCredentials")
              //request.predicate = NSPredicate(format: "age = %@", "12")
              request.returnsObjectsAsFaults = false
              do {
                  let result = try context.fetch(request)
                  for data in result as! [NSManagedObject] {
                      if let str = data.value(forKey: "email") as? String {
                          self.emailArray.append(str)
                      }
                      if let pass = data.value(forKey: "password") as? String {
                          self.passwordArray.append(pass)
                      }
                      if let userName = data.value(forKey: "displayName") as? String {
                          self.userNameArray.append(userName)
                      }
                      if let imageUrl = data.value(forKey: "profileImage") as? String {
                          self.imageUrlArray.append(imageUrl)
                      }
                      
                  }
                  
              } catch {
                  
                  print("Failed")
              }
              self.credentialsTable = UITableView(frame: CGRect.zero, style: .plain)
              let tapView = UITapGestureRecognizer(target: self, action: #selector(LoginScreenViewController.removeRememberMeTable))
              self.view.addGestureRecognizer(tapView)
              credentialsTable.frame = CGRect(x: 0, y: 0, width: 280, height: 0)
              credentialsTable.separatorColor = .clear
              credentialsTable.register(CredentialCell.self, forCellReuseIdentifier: "cell")
              credentialsTable.center.x = self.view.center.x
              credentialsTable.rowHeight = 70
              credentialsTable.frame.origin.y = self.loginCustomView.frame.origin.y - 20
              keywindow!.addSubview(self.credentialsTable)
              
              credentialsTable.delegate = self
              credentialsTable.tag = 99
              credentialsTable.dataSource = self
              credentialsTable.style
              credentialsTable.backgroundColor = .white
              credentialsTable.layer.shadowColor = UIColor(red: 190/255, green: 190/255, blue: 190/255, alpha: 1.0).cgColor
              credentialsTable.layer.shadowOpacity = 5
              credentialsTable.layer.shadowOffset = CGSize.zero
              credentialsTable.layer.shadowRadius = 5
              self.credentialsTable.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
              UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
                  self.credentialsTable.alpha = 1
                  self.credentialsTable.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
              }, completion: { _ in
              })
              if emailArray.count > 0 {
                  if !isLogin {
                      self.view.alpha = 0.5
                      credentialsTable.isHidden = false
                  }
                  else {
                      credentialsTable.isHidden = true
                  }
                  if emailArray.count > 4 {
                      credentialsTable.frame.size.height = CGFloat(4 * credentialsCellHeight)
                  }
                  else {
                      credentialsTable.frame.size.height = CGFloat((emailArray.count + 1) * credentialsCellHeight)
                  }
                  credentialsTable.reloadData()
              }
              else {
                  credentialsTable.isHidden = true
              }
    }
    
    @objc func removeRememberMeTable() {
        if let table = self.credentialsTable {
            UIView.animate(withDuration: 0.65, animations: {
                table.frame.origin.x = 500
            }) { (_) in
                self.view.alpha = 1
                table.removeFromSuperview()
            }
        }
    }
    
    @objc func setRememberMe(sender: UIButton) {
        if self.isRememberMe {
            self.isRememberMe = false
            self.rememberMeButton.setTitle("\u{f0c8} Remember me", for: .normal)
        }
        else {
            self.isRememberMe = true
            self.rememberMeButton.setTitle("\u{f14a} Remember me", for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setNavigationImage(controller: self)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:  UITextViewDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.loginCustomView.frame.origin.y -= 10
            self.bottomView.frame.origin.y -= keyBoardHeight
            
        })
    }
    
    func showPassword()
    {
        self.pass.isSecureTextEntry = false
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        pass.isHidden = true
        signIn.isHidden = true
        forgotPassword.isHidden = true
        self.rememberMeButton.isHidden = true
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        //
        if(textField.text == UIPasteboard.general.string)
        {
            if signIn.isHidden == false {
                signIn.isEnabled = true
                signIn.backgroundColor = navColor.withAlphaComponent(1.0)
            }
            else if signInotp.isHidden == false {
                signInotp.isEnabled = true
                signInotp.backgroundColor = navColor.withAlphaComponent(1.0)
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nums: Set<Character> = ["0" , "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let defaults = UserDefaults.standard
        let formmode =  defaults.string(forKey: "formmode")
        
        var emailText : NSString = ""
        if let text = textField.text as NSString?
        {
            emailText = text.replacingCharacters(in: range, with: string) as NSString
        }
        
        if (formmode !=  "default" && formmode != "otp") && isEnableOtp != false && textField.tag == 11 {
            if !string.contains(" ")
            {
                if range.location <= 0 && string == ""
                {
                    pass.isHidden = true
                    signInotp.isHidden = true
                    forgotPassword.isHidden = true
                    self.rememberMeButton.isHidden = true
                    signIn.isHidden = false
                    signIn.isEnabled = false
                    signIn.backgroundColor = navColor.withAlphaComponent(0.5)
                }
                else if Set(string).isSubset(of: nums) && string != ""
                {
                    
                    pass.isHidden = true
                    signIn.isHidden = true
                    forgotPassword.isHidden = true
                    self.rememberMeButton.isHidden = true
                    if range.location > 5
                    {
                        UIView.animate(withDuration: 2, animations: {
                            if Set(self.email.text!).isSubset(of: nums)
                            {
                                self.signInotp.isHidden = false
                                self.signInotp.isEnabled = true
                                self.signInotp.backgroundColor = navColor.withAlphaComponent(1.0)
                                self.signInotp.frame.origin.y = getBottomEdgeY(inputView: self.email) + 17
                            }
                            else
                            {
                                self.pass.isHidden = false
                                self.signIn.isHidden = false
                                self.forgotPassword.isHidden = false
                                self.rememberMeButton.isHidden = false
                            }
                        })
                    }
                    else
                    {
                        if  range.location == 1 && (Int(textField.text!) != nil){
                            signInotp.isHidden = false
                            signInotp.isEnabled = false
                            signInotp.backgroundColor = navColor.withAlphaComponent(0.5)//UIColor.clear
                        }
                        else if Set(email.text!).isSubset(of: nums)
                        {
                            signInotp.isHidden = false
                            signInotp.isEnabled = false
                            signInotp.backgroundColor = navColor.withAlphaComponent(0.5)//UIColor.clear
                        }
                        else
                        {
                            pass.isHidden = false
                            signInotp.isHidden = true
                            signIn.isHidden = false
                            forgotPassword.isHidden = false
                            self.rememberMeButton.isHidden = false
                        }
                        
                    }
                    
                }
                else if string != ""
                {
                    signInotp.isHidden = true
                    signInotp.isEnabled = false
                    
                    self.pass.isHidden = false
                    self.signIn.isHidden = false
                    self.forgotPassword.isHidden = false
                    self.rememberMeButton.isHidden = false
                    signIn.isEnabled = false
                    signIn.backgroundColor = navColor.withAlphaComponent(0.5)//UIColor.clear
                    
                    self.pass.frame.origin.y = getBottomEdgeY(inputView: self.email)
                    self.signIn.frame.origin.y = getBottomEdgeY(inputView: self.pass) + 17
                    self.forgotPassword.frame.origin.y = getBottomEdgeY(inputView: self.signIn) + 5
                    self.rememberMeButton.frame.origin.y = getBottomEdgeY(inputView: self.signIn) + 5
                }
                
                
                
                if self.email.text!.contains("@")
                {
                    UIView.animate(withDuration: 1, animations: {
                        if !checkValidEmail(emailText as String) || string == ""{
                            self.signIn.isEnabled = false
                            self.signIn.backgroundColor = navColor.withAlphaComponent(0.5)//UIColor.clear
                        }
                        else{
                            self.pass.isHidden = false
                            self.signIn.isHidden = false
                            self.forgotPassword.isHidden = false
                            self.rememberMeButton.isHidden = false
                            self.signInotp.isHidden = true
                            self.signIn.isEnabled = true
                            self.signIn.backgroundColor = navColor.withAlphaComponent(1.0)
                            self.pass.frame.origin.y = getBottomEdgeY(inputView: self.email)
                            self.signIn.frame.origin.y = getBottomEdgeY(inputView: self.pass) + 17
                            self.forgotPassword.frame.origin.y = getBottomEdgeY(inputView: self.signIn) + 5
                            self.rememberMeButton.frame.origin.y = getBottomEdgeY(inputView: self.signIn) + 5
                        }
                    })
                }
                else if Set(self.email.text!).isSubset(of: nums) && range.location > 0
                {
                    pass.isHidden = true
                    signIn.isHidden = true
                    forgotPassword.isHidden = true
                    self.rememberMeButton.isHidden = true
                    if range.location > 5{
                        UIView.animate(withDuration: 1, animations: {
                            self.signInotp.isHidden = false
                            self.signInotp.isEnabled = true
                            self.signInotp.backgroundColor = navColor.withAlphaComponent(1.0)
                            self.signInotp.frame.origin.y = getBottomEdgeY(inputView: self.email) + 17
                        })
                    }
                    else
                    {
                        signInotp.isHidden = false
                        signInotp.isEnabled = false
                        signInotp.backgroundColor = navColor.withAlphaComponent(0.5)//UIColor.clear
                    }
                }
            }
            else
            {
                pass.isHidden = true
                forgotPassword.isHidden = true
                self.rememberMeButton.isHidden = true
                signInotp.isHidden = true
                
                signIn.isHidden = false
                signIn.isEnabled = false
                signIn.backgroundColor = navColor.withAlphaComponent(0.5)
                
            }
        }
        else
        {
            signIn.isEnabled = true
            signIn.isHidden = false
            signInotp.isHidden = true
            signIn.backgroundColor = navColor.withAlphaComponent(1.0)
            pass.isHidden = false
            forgotPassword.isHidden = false
            self.rememberMeButton.isHidden = false
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {  //delegate method
        // Animation On TextView End Editing
        UIView.animate(withDuration: 0.5, animations: {
            self.loginCustomView.frame.origin.y += 10
            self.bottomView.frame.origin.y += keyBoardHeight
        })
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        if textField.tag == 22 || textField.tag == 11
        {
            if signIn.isHidden == false && signIn.isEnabled == true{
                login()
            }
            else if signInotp.isHidden == false && signInotp.isEnabled == true
            {
                signInAction()
            }
            return true;
        }
        else
        {
            self.pass.becomeFirstResponder()
            return true
        }
    }
    
    
    @objc func goBack()
    {
        //if user click on logout and than back
        if let _ = self.tabBarController?.tabBar
        {
            oauth_token = ""
            logoutUser = true
            refreshMenu = true
            let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
            userDefaults!.set(oauth_token, forKey: "oauth_token")
            userDefaults!.set(oauth_secret, forKey: "oauth_secret")
            menuRefreshConter = 0
            if let tabBarObject = self.tabBarController?.tabBar {
                tabBarObject.isHidden = true
            }

            self.navigationController?.pushViewController(LoginViewController(), animated: false)
            
        }
        else   // already logout user or guest user
        {
            if goback == true
            {
                goback = false
                _ = self.navigationController?.popViewController(animated: false)
            }
            else
            {
                if let tabBarObject = self.tabBarController?.tabBar {
                    tabBarObject.isHidden = true
                }
                self.navigationController?.pushViewController(LoginViewController(), animated: false)
            }
        }
    }
    
    
    @objc func signInAction(){
        var error = ""
        let defaults = UserDefaults.standard
        let formmode =  defaults.string(forKey: "formmode")
        
        if formmode != "both" {
            if email.text == "" && pass.text == "" {
                error = NSLocalizedString("Please enter the Email Address and Password.",comment: "")
                email.becomeFirstResponder()
            }
            
            if error == "" {
                if email.text == "" && pass.text != "" {
                    error = NSLocalizedString("Please enter the Email Address.",comment: "")
                    email.becomeFirstResponder()
                }else if email.text != "" {
                }
            }
            
            if error == "" && pass.text == ""{
                error = NSLocalizedString("Please enter the Password.",comment: "")
                pass.becomeFirstResponder()
            }
        }
        else
        {
            if error == "" {
                if email.text == "" {
                    error = NSLocalizedString("Please enter the Email Address.",comment: "")
                    email.becomeFirstResponder()
                }
            }
        }
        
        if error != ""{
            let alertController = UIAlertController(title: NSLocalizedString("Error",comment: ""), message:
                error, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss",comment: ""), style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            
            // Check Internet Connection
            if Reachabable.isConnectedToNetwork() {
                
                
                self.view.isUserInteractionEnabled = false
                self.loginCustomView.alpha = 0.7
                if formmode != "both" {
                    self.signIn.setTitle("Signing...", for: UIControl.State())
                }
                else
                {
                    self.signInotp.setTitle("OTP Signing...", for: UIControl.State())
                }
                // Send Server Request for Sign In
                
                var param = ["":""]
                loginParams = [login_id:"\(self.email.text!)","password":"\(self.pass.text!)","ip":"127.0.0.1" , "subscriptionForm": "1"]
                param = [login_id:"\(self.email.text!)","password":"\(self.pass.text!)","ip":"127.0.0.1"]
                OTPvalue = self.email.text!
                
                if device_uuid != nil{
                    loginParams.updateValue(device_uuid, forKey: "device_uuid")
                    param.updateValue(device_uuid, forKey: "device_uuid")
                }
                if device_token_id != nil{
                    loginParams.updateValue(device_token_id, forKey: "device_token")
                    param.updateValue(device_token_id, forKey: "device_token")
                }
                post(param, url: "otpverifier/send", method: "POST") { (succeeded, msg) -> () in
                    
                    DispatchQueue.main.async(execute: {
                        self.signIn.setTitle("Sign In", for: UIControl.State())
                        self.signInotp.setTitle("OTP Sign In", for: UIControl.State())
                        self.view.isUserInteractionEnabled = true
                        self.loginCustomView.alpha = 1.0
                        // On Success save authentication_token in Core Data
                        if(msg)
                        {
                            // Get Data From Core Data
                            if succeeded["message"] != nil{
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                            }
                            if succeeded["body"] != nil{
                                // Perform Login Action
                                
                                if let subsResponse = succeeded["body"] as? NSDictionary{
                                    if subsResponse["status"] as? Bool == true
                                    {
                                        //print(subsResponse)
                                        sign_in = 1
                                        
                                        let presentedVC = OtpVerificationViewController()
                                        
                                        if let mobno = subsResponse["phoneno"] as? Int64
                                        {
                                            presentedVC.mobileno = mobno
                                        }
                                        
                                        if let country_code = subsResponse["country_code"] as? Int
                                        {
                                            presentedVC.countrycode = country_code
                                        }
                                        
                                        if let duration = subsResponse["duration"] as? Int
                                        {
                                            presentedVC.duration  = duration
                                        }
                                        presentedVC.useremail = self.email.text!
                                        presentedVC.userpassword = self.pass.text!
                                        self.navigationController?.pushViewController(presentedVC, animated: true)
                                    }
                                    else{
                                        self.gohomepage(subsResponse : subsResponse)//  self.login()
                                    }
                                    
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
            presentedVC.email = self.email.text!
            presentedVC.pass = self.pass.text!
            self.navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        else
        {
            let defaults = UserDefaults.standard
            defaults.set("\(self.pass.text!)", forKey: "userPassword")
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
    
    @objc func login()
    {
        var error = ""
        if email.text == "" && pass.text == "" {
            error = NSLocalizedString("Please enter the Email Address and Password.",comment: "")
            email.becomeFirstResponder()
        }
        
        if error == "" {
            if email.text == "" && pass.text != "" {
                error = NSLocalizedString("Please enter the Email Address.",comment: "")
                email.becomeFirstResponder()
            }else if email.text != "" {
            }
        }
        if error == "" && pass.text == ""{
            error = NSLocalizedString("Please enter the Password.",comment: "")
            pass.becomeFirstResponder()
        }
        
        if error != ""{
            let alertController = UIAlertController(title: NSLocalizedString("Error",comment: ""), message:
                error, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss",comment: ""), style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            // Check Internet Connection
            if Reachabable.isConnectedToNetwork() {
                
                view.isUserInteractionEnabled = false
                loginCustomView.alpha = 0.7
                signIn.setTitle(NSLocalizedString("Signing...",comment: ""), for: UIControl.State())
                // Send Server Request for Sign In
                loginParams = [login_id:"\(self.email.text!)","password":"\(self.pass.text!)","ip":"127.0.0.1" , "subscriptionForm": "1"]
                
                if device_uuid != nil{
                    loginParams.updateValue(device_uuid, forKey: "device_uuid")
                }
                if device_token_id != nil{
                    loginParams.updateValue(device_token_id, forKey: "device_token")
                }
                
                post(loginParams, url: "login", method: "POST") { (succeeded, msg) -> () in
                    
                    DispatchQueue.main.async(execute: {
                        self.signIn.setTitle("Sign In", for: UIControl.State())
                        self.view.isUserInteractionEnabled = true
                        self.loginCustomView.alpha = 1.0
                        // On Success save authentication_token in Core Data
                        if(msg)
                        {
                            
                            sign_in = 0
                            // Get Data From Core Data
                            if succeeded["message"] != nil{
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                            }
                            if succeeded["body"] != nil{
                                // Perform Login Action
                                
                                if let subsResponse = succeeded["body"] as? NSDictionary{
                                    isLogin = true
                                    if self.isRememberMe && !self.rememberMeButton.isHidden {
                                        var userName = ""
                                        var imageUrl = ""
                                        if let user = subsResponse["user"] as? NSDictionary {
                                            if let name = user["displayname"] as? String {
                                                userName = name
                                            }
                                            else {
                                                userName = "No Name"
                                            }
                                            if let image = user["image_profile"] as? String {
                                                imageUrl = image
                                            }
                                        }
                                        let entity = NSEntityDescription.entity(forEntityName: "UserCredentials", in: context)
                                        let newUser = NSManagedObject(entity: entity!, insertInto: context)
                                        if !self.isExist(email: self.email.text!) {
                                            newUser.setValue(self.email.text!, forKey: "email")
                                            newUser.setValue(self.pass.text!, forKey: "password")
                                            newUser.setValue(userName, forKey: "displayName")
                                            newUser.setValue(imageUrl, forKey: "profileImage")
                                        }
                                        else {
                                            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCredentials")
                                            fetchRequest.predicate = NSPredicate(format: "email = %@",argumentArray: [self.email.text])
                                            do {
                                                let results = try context.fetch(fetchRequest) as? [NSManagedObject]
                                                if results?.count != 0 { // Atleast one was returned
                                                    results![0].setValue(self.pass.text, forKey: "password")
                                                    results![0].setValue(userName, forKey: "displayName")
                                                    results![0].setValue(imageUrl, forKey: "profileImage")
                                                }
                                            } catch {
                                                print("Fetch Failed: \(error)")
                                            }
                                        }
                                        
                                        do {
                                            try context.save()
                                        } catch {
                                            print("Failed saving")
                                        }
                                    }
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
                self.view.makeToast(network_status_msg, duration: 5, position: CSToastPositionCenter)
                
            }
            
        }
        
    }
    
    // to check whether particular credential exist in core data or not
       func isExist(email: String) -> Bool {
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserCredentials")
           fetchRequest.predicate = NSPredicate(format: "email = %d", argumentArray: [email])
           let res = try! context.fetch(fetchRequest)
           return res.count > 0 ? true : false
       }
    
    @objc func forgotPasswords(){
        if isOTPEnableplugin != 1 {
            let alert = UIAlertController(title: NSLocalizedString("Forgot Password",comment: ""), message: NSLocalizedString("Enter your email address",comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Done",comment: ""), style: UIAlertAction.Style.default, handler: forgotPasswordHandler))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.default, handler: nil))
            alert.addTextField(configurationHandler: {(textField: UITextField) in
                textField.placeholder = NSLocalizedString("Enter Email",comment: "")
                textField.isSecureTextEntry = false
                self.emailField = textField
            })
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: NSLocalizedString("Forgot Password",comment: ""), message: NSLocalizedString("Please enter your email address or mobile number whose password you want to reset.",comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Continue",comment: ""), style: UIAlertAction.Style.default, handler: forgotPasswordHandler))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.default, handler: nil))
            alert.addTextField(configurationHandler: {(textField: UITextField) in
                textField.placeholder = NSLocalizedString("Enter Email or Mobile No",comment: "")
                textField.isSecureTextEntry = false
                self.emailField = textField
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func forgotPasswordHandler(_ alertView: UIAlertAction!)
    {
        var error = ""
        if error == "" {
            if isOTPEnableplugin != 1 {
                if self.emailField.text! == "" {
                    error = NSLocalizedString("Please enter the Email Address.",comment: "")
                    //                email.becomeFirstResponder()
                }else if self.emailField.text! != "" {
                    if !checkValidEmail(self.emailField.text!){
                        error = NSLocalizedString("Please enter the valid Email Address.",comment: "")
                        email.becomeFirstResponder()
                    }
                }
            }
            else
            {
                let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
                
                if self.emailField.text! == "" {
                    error = NSLocalizedString("Please enter the Email Address or Mobile no.",comment: "")
                    //                email.becomeFirstResponder()
                }else if self.emailField.text! != "" {
                    if Set(self.emailField.text!).isSubset(of: nums){
                        if self.emailField.text!.contains("@")
                        {
                            if !checkValidEmail(self.emailField.text!){
                                error = NSLocalizedString("Please enter the valid Email Address.",comment: "")
                                email.becomeFirstResponder()
                            }
                        }
                        else if self.emailField.text!.length < 6
                        {
                            error = NSLocalizedString("Please enter the valid Mobile Number.",comment: "")
                            email.becomeFirstResponder()
                        }
                    }
                    else if !checkValidEmail(self.emailField.text!){
                        error = NSLocalizedString("Please enter the valid Email Address.",comment: "")
                        email.becomeFirstResponder()
                    }
                }
            }
        }
        if error != ""{
            let alertController = UIAlertController(title: "Error", message:
                error, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }else{
            self.proceed()
        }
    }
    
    //Send forgot password request
    func proceed()
    {
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
        self.emailField.resignFirstResponder()
        self.email.resignFirstResponder()
        self.pass.resignFirstResponder()
        var param  = [String:String]()
        param = ["email":"\(self.emailField.text!)"]
        
        var forgotPasswordUrl = ""
        if isEnableOtp
        {
            forgotPasswordUrl = "otpverifier/forgot-password"
        }
        else
        {
            forgotPasswordUrl = "forgot-password"
        }
        
        post( param,url: forgotPasswordUrl, method: "POST") { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if(msg)
                {
                    if let body = succeeded["body"] as? NSDictionary
                    {
                        //print(body)
                        if let response = body["response"] as? NSDictionary{
                            if let isEmail = response["isEmail"] as? Int
                            {
                                if isEmail != 1 {
                                    let presentedVC = OtpVerificationViewController()
                                    forgotpass = 1
                                    if let mobno = response["phoneno"] as? Int64
                                    {
                                        phone_no = mobno
                                        OTPvalue = "\(mobno)"
                                    }
                                    if let countrycode = response["country_code"] as? Int
                                    {
                                        country_code = String(countrycode)
                                    }
                                    if let duration = response["duration"] as? Int
                                    {
                                        presentedVC.duration  = duration
                                    }
                                    self.navigationController?.pushViewController(presentedVC, animated: true)
                                }
                                else
                                {
                                    self.view.makeToast(NSLocalizedString("An email has been sent to your email address",comment: ""), duration: 5, position: CSToastPositionCenter)
                                }
                            }
                        }
                    }
                    else
                    {
                        if succeeded["message"] != nil
                        {
                            let messageStatus = succeeded["message"]
                            let mesage = String(describing: messageStatus!)
                            
                            if mesage == "Your action has been performed successfully."
                            {
                                self.view.makeToast(NSLocalizedString("An email has been sent to your email address",comment: ""), duration: 5, position: CSToastPositionCenter)
                            }
                            else
                            {
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                            }
                            
                        }
                    }
                }else{
                    // Handle Server Side Error Massages
                    if succeeded["message"] != nil{
                        self.view.makeToast(succeeded["message"] as! String, duration: 5, position: CSToastPositionCenter)
                    }
                }
            })
        }
    }
    
    
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
}

// tableview delegates for remember me work
extension LoginScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if emailArray.count > 0 {
            return emailArray.count + 1
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        var cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CredentialCell
        cell = CredentialCell(style: .subtitle, reuseIdentifier: "cell")
        cell.userImage?.image = UIImage(named: "user_profile_image.png")
        //cell.imageView?.frame = CGRect(x: 5, y: 5, width: 50, height: 50)
        if indexPath.row < emailArray.count  {
            cell.emailLabel!.text = emailArray[(indexPath as NSIndexPath).row]
            cell.emailLabel?.textColor = .gray
            cell.nameLabel!.text = userNameArray[(indexPath as NSIndexPath).row]
            cell.nameLabel?.textColor = .black
            cell.userImage?.isHidden = false
//            cell.imageView?.layer.cornerRadius = 25
//            cell.imageView?.layer.masksToBounds = false
//            cell.imageView?.clipsToBounds = true
            cell.userImage?.contentMode = .scaleAspectFill
            let url = imageUrlArray[(indexPath as NSIndexPath).row]
            cell.userImage?.kf.setImage(with: URL(string: url), placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
            })
        }
        else if indexPath.row == emailArray.count {
            cell.nameLabel!.text = "None of the above"
            cell.userImage?.isHidden = true
            cell.nameLabel?.textColor = .blue
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.view.alpha = 1
        if indexPath.row < emailArray.count {
            pass.text = passwordArray[(indexPath as NSIndexPath).row]
            email.text = emailArray[(indexPath as NSIndexPath).row]
            pass.isHidden = false
            signIn.isEnabled = true
            signIn.alpha = 1
        }
        credentialsTable.isHidden = true
        
    }
  
   
    
}
