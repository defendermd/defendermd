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

class TellAFriendViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate
{
    var url: String!
    var param: NSDictionary!
    var nameText : UITextField!
    var emailText : UITextField!
    var toText : UITextField!
    var messageTextview: UITextView!
    var myCheckbox: UIButton!
    var copylabel:UILabel!
    
    var sendMsg:UIBarButtonItem!
    var name : String!
    var email : String!
    var to : String!
    var message : String!
    var sendCopy : Bool!
    var isSelected:Bool = false
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.hidden = false
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        self.title = NSLocalizedString("Tell a friend",  comment: "")
        
        nameText = createTextField(CGRectMake(PADING, TOPPADING, CGRectGetWidth(view.bounds) - (2 * PADING ), 40), borderColor: borderColorClear , placeHolderText: "Your Name", corner: true)
        nameText.attributedPlaceholder = NSAttributedString(string: "Your Name", attributes: [NSForegroundColorAttributeName: placeholderColor])
        nameText.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        nameText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        nameText.backgroundColor = bgColor
        nameText.delegate = self
        nameText.layer.masksToBounds = true
        view.addSubview(nameText)
        
        if displayName != nil
        {
          nameText.text = "\(displayName)"
        }

        
        emailText = createTextField(CGRectMake(PADING, TOPPADING+40, CGRectGetWidth(view.bounds) - (2 * PADING ), 40), borderColor: borderColorClear , placeHolderText: "Your Email", corner: true)
        emailText.attributedPlaceholder = NSAttributedString(string: "Your Email", attributes: [NSForegroundColorAttributeName: placeholderColor])
        emailText.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        emailText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        emailText.backgroundColor = bgColor
        emailText.delegate = self
        emailText.layer.masksToBounds = true
       
        let border1 = CALayer()
        let width1 = CGFloat(1.0)
        border1.borderColor = borderColorMedium.CGColor
        border1.frame = CGRect(x: 0, y: width1 + 2, width:  emailText.frame.size.width, height: 1.0)
        border1.borderWidth = width1
        emailText.layer.addSublayer(border1)
        emailText.layer.masksToBounds = true
        view.addSubview(emailText)
        
        let lineView1 = UIView(frame: CGRectMake(0,emailText.frame.size.height+self.emailText.frame.origin.y ,self.emailText.frame.size.width,1))
        lineView1.layer.borderWidth = 1.0
        lineView1.layer.borderColor = borderColorMedium.CGColor
        self.view.addSubview(lineView1)

        toText = createTextField(CGRectMake(PADING, TOPPADING+80, CGRectGetWidth(view.bounds) - (2 * PADING ), 40), borderColor: borderColorClear , placeHolderText: "To", corner: true)
        toText.attributedPlaceholder = NSAttributedString(string: "To", attributes: [NSForegroundColorAttributeName: placeholderColor])
        toText.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        toText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        toText.backgroundColor = bgColor
        toText.delegate = self
        toText.layer.masksToBounds = true
        view.addSubview(toText)
        
        messageTextview = createTextView(CGRectMake(PADING, CGRectGetHeight(toText.bounds) + toText.frame.origin.y + 5, CGRectGetWidth(view.bounds) - (2*PADING) , 100), borderColor: borderColorClear, corner: false )
        messageTextview.delegate = self
        messageTextview.hidden = false
        messageTextview.text = NSLocalizedString("Message",  comment: "")
        messageTextview.font = UIFont(name: fontName, size: FONTSIZELarge)
        messageTextview.textColor = placeholderColor
        messageTextview.backgroundColor = bgColor
        
        messageTextview.autocorrectionType = UITextAutocorrectionType.No
        
        let border4 = CALayer()
        border4.borderColor = borderColorMedium.CGColor
        border4.frame = CGRect(x: 0, y: width1, width:  messageTextview.frame.size.width, height: 1.0)
        border4.borderWidth = width1
        messageTextview.layer.addSublayer(border4)
        view.addSubview(messageTextview)
        
        myCheckbox = createButton(CGRectMake(PADING,CGRectGetHeight(messageTextview.bounds) + messageTextview.frame.origin.y + 5, 20 , 20), title: "", border: false,bgColor: false, textColor: textColorMedium )
        myCheckbox.setImage(UIImage(named: "unchecked.png"), forState: UIControlState.Normal)
        myCheckbox.setImage(UIImage(named: "checked.png"), forState: UIControlState.Selected)
        myCheckbox.addTarget(self, action: "myCheckboxAction:", forControlEvents: .TouchUpInside)
        view.addSubview(myCheckbox)
        
         copylabel  = createLabel(CGRectMake(CGRectGetWidth(myCheckbox.bounds)+5,CGRectGetHeight(messageTextview.bounds) + messageTextview.frame.origin.y + 5,225, 20), text: NSLocalizedString("Send a copy to my email address",  comment: "") , alignment: .Center, textColor: textColorMedium)
        copylabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        copylabel.textAlignment =  NSTextAlignment.Left;
        view.addSubview(copylabel)
        
        sendMsg = UIBarButtonItem(title: "\u{f1d8}", style: UIBarButtonItemStyle.Done , target:self , action: "send")
        sendMsg.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: FONTSIZELarge)!], forState: UIControlState.Normal)
        self.navigationItem.rightBarButtonItem = sendMsg
        
        let leftNavView = UIView(frame: CGRectMake(0, 0, 44, 44))
        leftNavView.backgroundColor = UIColor.clearColor()
        let tapView = UITapGestureRecognizer(target: self, action: Selector("cancel"))
        leftNavView.addGestureRecognizer(tapView)
        
        let backIconImageView = createImageView(CGRectMake(0,12,22,22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
 
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "resignKeyboard")
        tap.delegate = self
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap)
        
        
        
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    {
        // test if our control subview is on-screen
        if (touch.view == self.sendMsg)
        {
            return false
        }
        return true // handle the touch
    }
    func resignKeyboard()
    {
        self.view.endEditing(true)
    }
    
    // MARK: TextFeild Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        
        self.view.endEditing(true)
        return true;
        
    }
    func textFieldDidChange(textField: UITextField)
    {
        
    }
    
    // MARK: TextView Delegate
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        
        if textView.textColor == placeholderColor
        {
            textView.text = nil
            textView.textColor = textColorDark
        }
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool
    {
        
        if textView.text.isEmpty
        {
            self.messageTextview.text = NSLocalizedString("Message",  comment: "")
            self.messageTextview.textColor = placeholderColor
        }
        return true
    }
    
    // MARK: Action Events
    func myCheckboxAction(sender:UIButton!)
    {
       
        dispatch_async(dispatch_get_main_queue(),
            {
            
            if self.isSelected == false
            {
                sender.selected = true;
                self.isSelected = true
            }
            else
            {
                sender.selected = false;
                self.isSelected = false
            }
        });
    }
    func cancel()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    func send()
    {
        self.view.endEditing(true)
        var errorMsg = ""
        var parameters = [String:String]()
        if(nameText.text == "") || (emailText.text == "") || (toText.text=="") || (messageTextview.text == "" )
        {
            errorMsg =  "Content can't be empty"
            let alertController = UIAlertController(title: "Error", message:
                errorMsg, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
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
                let id = param["diary_id"] as! Int
                parameters = ["sender_name":"\(name)","sender_email":"\(email)","receiver_emails":"\(to)","message":"\(message)","send_me":"\(isSelected)","diary_id":"\(id)"]
            }
            else
            {
              parameters = ["sender_name":"\(name)","sender_email":"\(email)","receiver_emails":"\(to)","message":"\(message)","send_me":"\(isSelected)"]
            }
            
            post(parameters, url: url, method: "POST")
                {
                    (succeeded, msg) -> () in
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            spinner.stopAnimating()
                            if msg
                            {
                                if succeeded["body"] != nil
                                {
                                    
                                }
                                else
                                {
                                    self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                                    self.navigationController?.popViewControllerAnimated(true)
                                }
                            }
                            else
                            {
                                // Handle Server Side Error
                                if succeeded["message"] != nil
                                {
                                    self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                                }
                            }
                    })
                    
            }
            
            
        }
    }
    


}
