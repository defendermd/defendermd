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

// ContactViewController.swift

import UIKit

@objcMembers class ContactViewController: FXFormViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate{
    var popAfterDelay:Bool!
    var id:Int!
    var contentLabelText : UITextView!
    var nameLabel : UITextField!
    var emailLabel : UITextField!
    var sendButton : UIBarButtonItem!
    var leftBarButtonItem : UIBarButtonItem!
    
    // Initialization of class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        popAfterDelay = false
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        popAfterDelay = false
        self.title = NSLocalizedString("Contact Us", comment: "")
        baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = ""
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        sendButton = UIBarButtonItem(title: NSLocalizedString("Send", comment: ""), style: UIBarButtonItem.Style.plain, target: self, action: #selector(ContactViewController.send))
        self.navigationItem.rightBarButtonItem = sendButton
        sendButton.tintColor = textColorPrime
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: fontName, size: FONTSIZELarge)!],for: UIControl.State())
        
        
        let contactUsText = createLabel(CGRect(x: 10, y: 15, width: view.bounds.width - 20, height: 20), text: NSLocalizedString("Have a question? Need help?", comment: ""), alignment: NSTextAlignment.center, textColor: textColorDark)
        contactUsText.font = UIFont(name: fontBold, size: FONTSIZELarge)
        view.addSubview(contactUsText)
        
        let contactUsMessageIcon = createLabel(CGRect(x: 20, y: contactUsText.bounds.height + 15, width: view.bounds.width - 40, height: 75), text: "\(envelopeIcon)", alignment: NSTextAlignment.center, textColor: navColor)

        contactUsMessageIcon.font = UIFont(name: "FontAwesome", size: 65 )
        view.addSubview(contactUsMessageIcon)

        
        let dropMessage = createLabel(CGRect(x: 10, y: contactUsMessageIcon.bounds.height + 30, width: view.bounds.width - 20, height: 20), text: NSLocalizedString("Drop us a message and we'll get back soon.", comment: ""), alignment: NSTextAlignment.center, textColor: textColorMedium)
        dropMessage.font = UIFont(name: fontName, size: FONTSIZENormal)
        view.addSubview(dropMessage)

        nameLabel = createTextField(CGRect(x: PADING, y: contactUsText.bounds.height + 110 , width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: NSLocalizedString("Name",  comment: ""), corner: true)
        nameLabel.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Name",  comment: ""), attributes: [NSAttributedString.Key.foregroundColor: textColorMedium])
        nameLabel.font =  UIFont(name: fontName, size: FONTSIZELarge)
        nameLabel.backgroundColor = bgColor
        
        nameLabel.layer.masksToBounds = true
        view.addSubview(nameLabel)
        
        emailLabel = createTextField(CGRect(x: PADING, y: contactUsText.bounds.height + 150, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText:  NSLocalizedString("Email Address",  comment: ""), corner: true)
        emailLabel.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Email Address",  comment: ""), attributes: [NSAttributedString.Key.foregroundColor: textColorMedium])
        emailLabel.font =  UIFont(name: fontName, size: FONTSIZELarge)
        emailLabel.backgroundColor = bgColor
        view.addSubview(emailLabel)
        
        let border1 = CALayer()
        let width1 = CGFloat(1.0)
        border1.borderColor = borderColorMedium.cgColor
        border1.frame = CGRect(x: 0, y: width1 + 2, width:  emailLabel.frame.size.width, height: 1.0)
        
        border1.borderWidth = width1
        emailLabel.layer.addSublayer(border1)
        emailLabel.layer.masksToBounds = true
        view.addSubview(emailLabel)
        
        contentLabelText = createTextView(CGRect(x: PADING, y: emailLabel.bounds.height + emailLabel.frame.origin.y + 5, width: view.bounds.width - (2*PADING) , height: 100), borderColor: borderColorClear, corner: false )
        contentLabelText.isHidden = false
        contentLabelText.text = NSLocalizedString("Message",  comment: "")
        contentLabelText.font = UIFont(name: fontName, size: FONTSIZELarge)
        contentLabelText.textColor = textColorMedium
        contentLabelText.backgroundColor = bgColor
        contentLabelText.delegate = self
        contentLabelText.autocorrectionType = UITextAutocorrectionType.no
        
        let border4 = CALayer()
        border4.borderColor = borderColorMedium.cgColor
        border4.frame = CGRect(x: 0, y: width1 + 2, width:  contentLabelText.frame.size.width, height: 1.0)
        border4.borderWidth = width1
        contentLabelText.layer.addSublayer(border4)
        view.addSubview(contentLabelText)
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.formController.tableView.estimatedSectionHeaderHeight = 0
        }
   
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeNavigationViews(controller: self)
    }
    
    // Generate Form On View Appear
    override func viewDidAppear(_ animated: Bool) {

    }
    
    // MARK:  Send Message
    
    @objc func send(){
        
        if Reachabable.isConnectedToNetwork() {
            var errorMsg = ""
            var parameters = [String:String]()
            if(nameLabel.text == ""){
                errorMsg = NSLocalizedString("Please enter name",  comment: "")
            }
            
            if errorMsg == "" {
                if self.emailLabel.text! == "" {
                    errorMsg = NSLocalizedString("Please enter the Email Address.",comment: "")
                    //                email.becomeFirstResponder()
                }else if self.emailLabel.text! != "" {
                    if !checkValidEmail(self.emailLabel.text!){
                        errorMsg = NSLocalizedString("Please enter the valid Email Address.",comment: "")
                        
                    }
                }
            }
            

            if(errorMsg == ""){
                removeAlert()
                activityIndicatorView.center = CGPoint(x: view.center.x, y: view.center.y/3)
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
            //    activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                parameters = ["name":"\(nameLabel.text!)","email":"\(emailLabel.text!)","body":"\(contentLabelText.text!)"]
                post(parameters, url: "help/contact", method: "POST") {
                    (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            
                            self.view.makeToast("Message sent successfully.", duration: 5, position: CSToastPositionCenter)
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
                self.view.makeToast(errorMsg , duration: 5, position: CSToastPositionTop)
            }
        }else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: CSToastPositionTop)
            
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if textView.textColor == textColorMedium {
            textView.text = nil
            textView.textColor = textColorDark
        }
        return true
    }
    
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        if textView.text.isEmpty{
            self.contentLabelText.text = NSLocalizedString("Message",  comment: "")
            self.contentLabelText.textColor = textColorMedium
        }
        return true
    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true{
            // cancel()
            
            self.goBack()
            //            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func goBack(){
        let presentedVC = AdvanceActivityFeedViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
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
