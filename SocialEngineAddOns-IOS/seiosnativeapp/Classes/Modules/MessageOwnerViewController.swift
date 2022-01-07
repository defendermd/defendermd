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

//  MessageOwnerViewController.swift
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
    var param: NSDictionary = [:]
    var leftBarButtonItem : UIBarButtonItem!
    var popAfterDelay:Bool = false
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        //        self.navigationController.
        
        self.title = NSLocalizedString("Message owner",  comment: "")
        
        subjectText = createTextField(CGRect(x: PADING, y: TOPPADING, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: "Subject", corner: true)
        subjectText.attributedPlaceholder = NSAttributedString(string: "Subject", attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])

        subjectText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        subjectText.backgroundColor = bgColor
        subjectText.delegate = self
        subjectText.layer.masksToBounds = true
        view.addSubview(subjectText)
        
        bodyTextview = createTextView(CGRect(x: PADING, y: subjectText.bounds.height + subjectText.frame.origin.y + 5, width: view.bounds.width - (2*PADING) , height: 100), borderColor: borderColorClear, corner: false )
        bodyTextview.delegate = self
        bodyTextview.isHidden = false
        bodyTextview.text = NSLocalizedString("Message",  comment: "")
        bodyTextview.font = UIFont(name: fontName, size: FONTSIZELarge)
        bodyTextview.textColor = placeholderColor
        bodyTextview.backgroundColor = bgColor
        
        bodyTextview.autocorrectionType = UITextAutocorrectionType.no
        
        
        
        let width1 = CGFloat(1.0)
        let border4 = CALayer()
        border4.borderColor = borderColorMedium.cgColor
        border4.frame = CGRect(x: 0, y: width1 + 2, width:  bodyTextview.frame.size.width, height: 1.0)
        border4.borderWidth = width1
        bodyTextview.layer.addSublayer(border4)
        view.addSubview(bodyTextview)
        
        sendMsg = UIBarButtonItem(title: "\u{f1d8}", style: UIBarButtonItem.Style.done , target:self , action: #selector(MessageOwnerViewController.send))
        
        
        sendMsg.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZELarge)!], for: UIControl.State())
        sendMsg.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = sendMsg
        
        let cancel = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain , target:self , action: #selector(MessageOwnerViewController.cancel))
        cancel.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZELarge)!], for: UIControl.State())
        cancel.tintColor = textColorPrime
        self.navigationItem.leftBarButtonItem = cancel
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessageOwnerViewController.resignKeyboard))
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
        
        if textView.textColor == placeholderColor
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
            self.bodyTextview.text = NSLocalizedString("Message",  comment: "")
            self.bodyTextview.textColor = placeholderColor
        }
        return true
    }
    
    // MARK: Action Events
    @objc func cancel()
    {
        _ = self.navigationController?.popViewController(animated: true)

    }
    
    @objc func send()
    {
        self.view.endEditing(true)
        var errorMsg = ""
        var parameters = [String:String]()
        if(subjectText.text == "") || (bodyTextview.text == "")
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
            
            subject = subjectText.text
            body = bodyTextview.text

            
            let keyExists = param["diary_id"] != nil
            let keyExists1 = param["subject_id"] != nil
            let keyExists2 = param["wishlist_id"] != nil
            if keyExists == true
            {
                let id = param["diary_id"] as! Int
                parameters = ["title": subject,"body": body, "diary_id": String(id)]
            }
            else if keyExists1 == true
            {
                let id = param["subject_id"] as! Int
                parameters = ["title": subject,"body": body,"subject_id": String(id)]
            }
            else if keyExists2 == true
            {
                let id = param["wishlist_id"] as! Int
                parameters = ["title": subject,"body": body,"wishlist_id": String(id)]
            }
            else
            {

                parameters = ["title": subject,"body": body]
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
                            //_ = self.navigationController?.popViewController(animated: true)
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
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    
}
