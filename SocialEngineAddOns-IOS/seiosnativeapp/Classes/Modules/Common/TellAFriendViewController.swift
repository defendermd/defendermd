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

//  TellafriendViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 22/01/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class TellAFriendViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate
{
    var url: String!
    var param: NSDictionary!
    var nameText : UITextField!
    var emailText : UITextField!
    var toText : UITextField!
    var messageTextview: UITextView!
    var myCheckbox: UIButton!
    var copylabel:UILabel!
    var opinion : Bool = false
    var sendMsg:UIBarButtonItem!
    var name : String!
    var email : String!
    var to : String!
    var message : String!
    var sendCopy : Bool!
    var isSelected:Bool = false
    var leftBarButtonItem : UIBarButtonItem!
    var popAfterDelay:Bool = false
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = bgColor

        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        if opinion == true{
            self.title = NSLocalizedString("Ask a Opinion",  comment: "")
            opinion = false
        }
        else{
            self.title = NSLocalizedString("Tell a friend",  comment: "")
        }
        nameText = createTextField(CGRect(x: PADING, y: TOPPADING, width: view.bounds.width - (2 * PADING), height: 40), borderColor: borderColorClear , placeHolderText: "Your Name", corner: true)

        nameText.attributedPlaceholder = NSAttributedString(string: "Your Name", attributes: [NSAttributedString.Key.foregroundColor: textColorMedium])
        

        nameText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        nameText.backgroundColor = bgColor
        nameText.delegate = self
        nameText.layer.masksToBounds = true
        if displayName != nil
        {
            nameText.text = displayName

        }
        
        view.addSubview(nameText)
        
        
        emailText = createTextField(CGRect(x: PADING, y: TOPPADING+40, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: "Your Email", corner: true)
        emailText.attributedPlaceholder = NSAttributedString(string: "Your Email", attributes: [NSAttributedString.Key.foregroundColor: textColorMedium])
        //emailText.addTarget(self, action: #selector(TellAFriendViewController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        emailText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        emailText.backgroundColor = bgColor
        emailText.delegate = self
        
        let defaults = UserDefaults.standard
        if let userEmail = defaults.string(forKey: "userEmail")
        {
            
            emailText.text = "\(userEmail)"
            
        }
        
        emailText.layer.masksToBounds = true
        
        let border1 = CALayer()
        let width1 = CGFloat(1.0)
        border1.borderColor = borderColorMedium.cgColor
        border1.frame = CGRect(x: 0, y: width1 + 2, width:  emailText.frame.size.width, height: 1.0)
        border1.borderWidth = width1
        emailText.layer.addSublayer(border1)
        emailText.layer.masksToBounds = true
        view.addSubview(emailText)
        
        let lineView1 = UIView(frame: CGRect(x: 0, y: emailText.frame.size.height + self.emailText.frame.origin.y, width: self.emailText.frame.size.width, height: 1))
        lineView1.layer.borderWidth = 1.0
        lineView1.layer.borderColor = borderColorMedium.cgColor
        self.view.addSubview(lineView1)

        toText = createTextField(CGRect(x: PADING, y: TOPPADING+80, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: "Email", corner: true)
        toText.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: textColorMedium]) //placeholderColor
//        toText.addTarget(self, action: Selector("textFieldDidChange:"), for: UIControl.Event.editingChanged)
        toText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        toText.backgroundColor = bgColor
        toText.delegate = self
        toText.layer.masksToBounds = true
        
        let border3 = CALayer()
        border3.borderColor = borderColorMedium.cgColor
        border3.frame = CGRect(x: 0, y: width1, width:  toText.frame.size.width, height: 1.0)
        border3.borderWidth = width1
        toText.layer.addSublayer(border3)
        
        view.addSubview(toText)
        
        messageTextview = createTextView(CGRect(x: PADING, y: toText.bounds.height + toText.frame.origin.y + 5, width: view.bounds.width - (2*PADING) , height: 100), borderColor: borderColorClear, corner: false )
        messageTextview.delegate = self
        messageTextview.isHidden = false
        messageTextview.text = NSLocalizedString("Message",  comment: "")
        messageTextview.font = UIFont(name: fontName, size: FONTSIZELarge)
        messageTextview.textColor = textColorMedium//placeholderColor
        messageTextview.backgroundColor = bgColor
        
        messageTextview.autocorrectionType = UITextAutocorrectionType.no
        
        let border4 = CALayer()
        border4.borderColor = borderColorMedium.cgColor
        border4.frame = CGRect(x: 0, y: width1, width:  messageTextview.frame.size.width, height: 1.0)
        border4.borderWidth = width1
        messageTextview.layer.addSublayer(border4)
        view.addSubview(messageTextview)
        
        let lineView2 = UIView(frame: CGRect(x: 0, y: messageTextview.frame.size.height + self.messageTextview.frame.origin.y, width: self.messageTextview.frame.size.width, height: 1))
        lineView2.layer.borderWidth = 1.0
        lineView2.layer.borderColor = borderColorMedium.cgColor
        self.view.addSubview(lineView2)
        
        myCheckbox = createButton(CGRect(x: PADING,y: messageTextview.bounds.height + messageTextview.frame.origin.y + 5, width: 20 , height: 20), title: "", border: false, bgColor: false, textColor: textColorMedium )
        myCheckbox.setImage(UIImage(named: "uncheckedGrey_new.png"), for: UIControl.State())
        myCheckbox.setImage(UIImage(named: "checked.png"), for: UIControl.State.selected)
        myCheckbox.addTarget(self, action: #selector(TellAFriendViewController.myCheckboxAction(_:)), for: .touchUpInside)
        view.addSubview(myCheckbox)
        
        copylabel  = createLabel(CGRect(x: myCheckbox.bounds.width+5, y: messageTextview.bounds.height + messageTextview.frame.origin.y + 5, width: 225, height: 20), text: NSLocalizedString("Send a copy to my email address",  comment: "") , alignment: .center, textColor: textColorMedium)
        copylabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        copylabel.textAlignment =  NSTextAlignment.left;

        view.addSubview(copylabel)

        sendMsg = UIBarButtonItem(title: "\u{f1d8}", style: UIBarButtonItem.Style.done , target:self , action: #selector(TellAFriendViewController.send))
        sendMsg.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZELarge)!], for: UIControl.State())
        self.navigationItem.rightBarButtonItem = sendMsg
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(TellAFriendViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TellAFriendViewController.resignKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        // test if our control subview is on-screen
        if (touch.view == self.sendMsg)
        {
            return false
        }
        return true // handle the touch
    }
    
    @objc func resignKeyboard()
    {
        self.view.endEditing(true)
    }
    
    // MARK: TextFeild Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        
        self.view.endEditing(true)
        return true;
        
    }
    
    // MARK: TextView Delegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        
        if textView.textColor == textColorMedium//placeholderColor
        {
            textView.text = nil
            textView.textColor = textColorDark
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool
    {
        
        if textView.text.isEmpty
        {
            self.messageTextview.text = NSLocalizedString("Message",  comment: "")
            self.messageTextview.textColor = textColorMedium//placeholderColor
        }
        return true
    }
    
    
    // MARK: Action Events
    @objc func myCheckboxAction(_ sender:UIButton!)
    {
        
        DispatchQueue.main.async(execute: {
            
            if self.isSelected == false
            {
                sender.isSelected = true;
                self.isSelected = true
            }
            else
            {
                sender.isSelected = false;
                self.isSelected = false
            }
        });
    }
    
    @objc func cancel()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @objc func send()
    {
        self.view.endEditing(true)
        var errorMsg = ""
        var parameters = [String:String]()
        if(nameText.text == "") || (emailText.text == "") || (toText.text=="") || (messageTextview.text == "" )
        {
            errorMsg =  NSLocalizedString("Content can't be empty",  comment: "")
            let alertController = UIAlertController(title: NSLocalizedString("Error",  comment: ""), message:
                errorMsg, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Dismiss",  comment: ""), style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        }
        else
        {
            
            
            let finalString = "\(loadingIcon)"
            sendMsg.title = finalString
            var myDynamicArray:[Int] = []
            
            for (key, _) in frndTag{
                myDynamicArray.append(key)
            }
            
            var str : String = ""
            for (key, _) in frndTag {
                str += "\(key)"
                if key < frndTag.count-1 {
                    str += ","
                }
            }
            name = nameText.text
            email = emailText.text
            to = toText.text
            message = messageTextview.text
            
            
            if param != nil
            {

                if let id = param["diary_id"] as? Int
                {
                    parameters = ["sender_name": name ,"sender_email": email ,"receiver_emails": to ,"message": message ,"send_me":"\(isSelected)","diary_id": String(id) ]
                }else if let id = param["wishlist_id"] as? Int
                {
                    parameters = ["sender_name": name ,"sender_email": email ,"receiver_emails": to ,"message": message ,"send_me":"\(isSelected)","wishlist_id": String(id) ]
                }
                else if let id = param["subject_id"] as? Int
                {
                    parameters = ["sender_name": name ,"sender_email": email ,"receiver_emails": to ,"message": message , "send_me":"\(isSelected)", "subject_id": String(id) ]
                }
                
            }
            else
            {

                parameters = ["sender_name": name,"sender_email": email,"receiver_emails": to, "message":message,"send_me":"\(isSelected)"]

            }
            
            post(parameters, url: url, method: "POST")
            {
                (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        if succeeded["body"] != nil
                        {
                            
                        }
                        else
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            self.createTimer(self)
                            self.popAfterDelay = true
                           // _ = self.navigationController?.popViewController(animated: true)
                        }
                    }
                    else
                    {
                        // Handle Server Side Error
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)


                        }
                    }
                })
                
            }
            
            
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true
        {

            _ = self.navigationController?.popViewController(animated: false)
            
        }
    }
    
}
