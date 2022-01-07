//
//  AdvancedEventMessageownerViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 22/01/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class MessageOwnerViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate,UIGestureRecognizerDelegate
{
    var url: String!
    var subjectText : UITextField!
    var bodyTextview: UITextView!
    var sendMsg:UIBarButtonItem!
    var subject : String!
    var body : String!
    var param = [:]
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        print(url)
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.hidden = false
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        self.title = NSLocalizedString("Message owner",  comment: "")
        
        
        subjectText = createTextField(CGRectMake(PADING, TOPPADING, CGRectGetWidth(view.bounds) - (2 * PADING ), 40), borderColor: borderColorClear , placeHolderText: "Subject", corner: true)
        subjectText.attributedPlaceholder = NSAttributedString(string: "Subject", attributes: [NSForegroundColorAttributeName: placeholderColor])
        subjectText.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        subjectText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        subjectText.backgroundColor = bgColor
        subjectText.delegate = self
        subjectText.layer.masksToBounds = true
        view.addSubview(subjectText)
        
        bodyTextview = createTextView(CGRectMake(PADING, CGRectGetHeight(subjectText.bounds) + subjectText.frame.origin.y + 5, CGRectGetWidth(view.bounds) - (2*PADING) , 100), borderColor: borderColorClear, corner: false )
        bodyTextview.delegate = self
        bodyTextview.hidden = false
        bodyTextview.text = NSLocalizedString("Message",  comment: "")
        bodyTextview.font = UIFont(name: fontName, size: FONTSIZELarge)
        bodyTextview.textColor = placeholderColor
        bodyTextview.backgroundColor = bgColor
        
        bodyTextview.autocorrectionType = UITextAutocorrectionType.No
        
        
        
        let width1 = CGFloat(1.0)
        let border4 = CALayer()
        border4.borderColor = borderColorMedium.CGColor
        border4.frame = CGRect(x: 0, y: width1 + 2, width:  bodyTextview.frame.size.width, height: 1.0)
        border4.borderWidth = width1
        bodyTextview.layer.addSublayer(border4)
        view.addSubview(bodyTextview)
        
        sendMsg = UIBarButtonItem(title: "\u{f1d8}", style: UIBarButtonItemStyle.Done , target:self , action: "send")
        
        
        sendMsg.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: FONTSIZELarge)!], forState: UIControlState.Normal)
        self.navigationItem.rightBarButtonItem = sendMsg
        
        let cancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain , target:self , action: "cancel")
        cancel.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: FONTSIZELarge)!], forState: UIControlState.Normal)
        self.navigationItem.leftBarButtonItem = cancel
        
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
            self.bodyTextview.text = NSLocalizedString("Message",  comment: "")
            self.bodyTextview.textColor = placeholderColor
        }
        return true
    }
    
    // MARK: Action Events
    func cancel()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func send()
    {
        self.view.endEditing(true)
        var errorMsg = ""
        var parameters = [String:String]()
        if(subjectText.text == "") || (bodyTextview.text == "")
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
            
            
            
            subject = subjectText.text
            body = bodyTextview.text
            
            parameters = ["title":"\(subject)","body":"\(body)"]
            
            if param.objectForKey("diary_id") != nil {
                let id = param["diary_id"] as! Int
                parameters = ["title":"\(subject)","body":"\(body)","diary_id":"\(id)"]
            }
            
            if param.objectForKey("listing_id") != nil {
                let id = param["listing_id"] as! Int
                parameters = ["title":"\(subject)","body":"\(body)","listing_id":"\(id)"]
            }
            
            if param.objectForKey("wishlist_id") != nil {
                let id = param["wishlist_id"] as! Int
                parameters = ["title":"\(subject)","body":"\(body)","wishlist_id":"\(id)"]
            }
                
            
            post(parameters, url: url, method: "POST")
                {
                    (succeeded, msg) -> () in
                    dispatch_async(dispatch_get_main_queue(),
                        {
                            spinner.stopAnimating()
                            if msg
                            {
                                print(succeeded)
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
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    
}
