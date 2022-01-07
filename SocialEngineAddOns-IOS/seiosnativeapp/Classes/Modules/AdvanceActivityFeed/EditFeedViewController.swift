
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

//  EditFeedViewController.swift

import UIKit


class EditFeedViewController: UIViewController,UITextViewDelegate {
    var editText : UITextView!
    var editBody : String! = ""
    var popAfterDelay:Bool!
    var editItem : UIBarButtonItem!
    var editId : Int!
    var leftBarButtonItem : UIBarButtonItem!
    var activityfeedIndex : Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        popAfterDelay = false
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        self.title = NSLocalizedString("Edit Feed", comment: "")
        
        
        
        editText = createTextView(CGRect(x: 10,y: TOPPADING + iphonXTopsafeArea  , width: view.bounds.width-20,height: 250), borderColor: borderColorClear , corner: false )
        editText.delegate = self
        editText.backgroundColor = UIColor.clear
        editText.textColor = textColorMedium
        editText.font = UIFont(name: fontName, size: FONTSIZELarge)
        editText.autocorrectionType = UITextAutocorrectionType.yes
        editText.text = NSLocalizedString(editBody,  comment: "")
        
        self.automaticallyAdjustsScrollViewInsets = false
        editText.isScrollEnabled = false
        
        if editText.frame.size.height > 250
        {
            // For fix width and variable height
            editText.frame = editText.sizeFitOnFixWidth(textView: editText)
        }


        view.addSubview(editText)
        editItem = UIBarButtonItem(title:NSLocalizedString("Post", comment: "") , style:.plain , target:self , action: #selector(EditFeedViewController.editContent))
        editItem.isEnabled = false
        self.navigationItem.rightBarButtonItem = editItem
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(EditFeedViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
    
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        editText.isEditable = true
        return true
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView){

        if textView.text.isEmpty{
            self.editItem.isEnabled = false
        }else{
            self.editItem.isEnabled = true
        }
        textView.frame.size.width = view.bounds.width-20
        //print(textView.text)
        if textView.frame.size.height <  200 {
            textView.sizeToFit()
            textView.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, animations: {
            })
        }
        else{
            editText.isScrollEnabled = true
        }
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)

    }
    
    @objc func editContent(){
        
        editText.text = editText.text.trimString(editText.text)
        if editText.text == ""{
            self.view.makeToast("Please enter status.", duration: 5, position: CSToastPositionCenter)
            editText.becomeFirstResponder()
            return
        }
        else{
            editText.resignFirstResponder()
        }
        
        if Reachabable.isConnectedToNetwork() {
            
            var path = ""
            var parameters = [String:String]()
            path = "advancedactivity/edit-feed"
            let editTextWithEmoticon = Emoticonizer.emoticonizeString(editText.text as NSString) as String
            parameters = ["action_id":String(editId),"body": editTextWithEmoticon]
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            activityIndicatorView.startAnimating()
            view.isUserInteractionEnabled = false
            post(parameters, url: path, method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.view.alpha = 1.0
                    self.view.isUserInteractionEnabled = true
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: "Content Edited Successfully.", controller: self)
                            commentsUpdate = true
                            self.createTimer(self)
                            self.popAfterDelay = true
                        }
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
                
            }
            
            
            
        }
        else{
            
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Updating comment count globally
    func updateCommentCount(feedindex:Int,key:String,updatedvalue:String)
    {
        
        let feed = feedArray[activityfeedIndex] as! NSDictionary
        var newDictionary:NSMutableDictionary = [:]
        newDictionary = feed as! NSMutableDictionary
        newDictionary["\(key)"] = updatedvalue
        feedArray[feedindex] = newDictionary
        
       // self.updateCommentCount(feedindex: self.activityfeedIndex, key: "body", updatedvalue: editTextWithEmoticon)
    }
    @objc func stopTimer() {
        stop()
        // popViewController After Delay
        if popAfterDelay == true {
            feedUpdate = true
            pageDetailUpdate = true

            _ = self.navigationController?.popViewController(animated: true)

        }
    }
    
}
