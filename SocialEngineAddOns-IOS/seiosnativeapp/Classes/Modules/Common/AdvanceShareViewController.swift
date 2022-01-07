
//
//  AdvanceShareViewController.Swift
//  seiosnativeapp
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

import UIKit

class AdvanceShareViewController: UIViewController,UITextViewDelegate {
    var shareMessage : UITextView!
    var contentUrl : String!
    var photoView : UIView!
    var photoViewerFrame:CGRect!
    var titleLabel : UILabel!
    var descriptionLabel : UILabel!
    var imageView : UIImageView!
    var param: NSDictionary = [:]
    var url : String!
    var Sharetitle:String! = ""
    var ShareDescription :String! = ""
    var popAfterDelay:Bool!
    var imageString:String! = ""
    var canShareLink : Bool = false
    var linkView : UIView!
    var shareItem : UIBarButtonItem!
    var leftBarButtonItem : UIBarButtonItem!
    var delegateAdvanceVShareVideoResume : DelegateAdvanceVShareVideoResume?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        self.title = NSLocalizedString("Share", comment: "")
        
        
        
        shareMessage = createTextView(CGRect(x: 10,y: TOPPADING , width: view.bounds.width-20, height: 200), borderColor: borderColorClear , corner: false )
        shareMessage.backgroundColor = bgColor
        shareMessage.delegate = self
        shareMessage.text = NSLocalizedString("Say Something about this Link...",  comment: "")
        shareMessage.backgroundColor = UIColor.clear
        shareMessage.textColor = textColorMedium
        shareMessage.font = UIFont(name: fontName, size: FONTSIZELarge)
        shareMessage.autocorrectionType = UITextAutocorrectionType.yes
        shareMessage.sizeToFit()
        shareMessage.isScrollEnabled = false
        shareMessage.becomeFirstResponder()
        self.automaticallyAdjustsScrollViewInsets = false
        view.addSubview(shareMessage)
        
        
//        shareItem = UIBarButtonItem(title: "\(shareIcon)", style: UIBarButtonItem.Style.plain, target: self, action: #selector(AdvanceShareViewController.shareContent))
//        shareItem.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
//        self.navigationItem.rightBarButtonItem = shareItem
        
        
        let button = createButton(CGRect(x: self.view.bounds.size.width-100,y: 0,width: 30,height: 30), title: shareIcon, border: false, bgColor: false, textColor: textColorPrime)
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
        button.addTarget(self, action: #selector(AdvanceShareViewController.shareContent), for: UIControl.Event.touchUpInside)
        let locButton = UIBarButtonItem()
        locButton.customView = button
        self.navigationItem.setRightBarButtonItems([locButton], animated: true)
        
        let cancel = UIBarButtonItem(title: NSLocalizedString("Cancel",  comment: ""), style:.plain , target:self , action: #selector(AdvanceShareViewController.goBack))
        self.navigationItem.leftBarButtonItem = cancel
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZELarge)!],for: UIControl.State())
        cancel.tintColor = textColorPrime

        
        popAfterDelay = false
        
        view.addSubview(shareMessage)
        let photoViewOriginY:CGFloat = self.shareMessage.bounds.height + self.shareMessage.frame.origin.y
        photoViewerFrame = CGRect(x: 2, y: photoViewOriginY, width: view.bounds.width-4, height: 100)
        photoView = createView(photoViewerFrame!, borderColor: borderColorMedium  , shadow: false)
        photoView.backgroundColor = bgColor
        self.view.addSubview(photoView)
        photoView.layer.borderWidth = 0.0
        
        linkView = createView(CGRect(x: 0, y: 10, width: (photoViewerFrame?.width)!, height: 60), borderColor: borderColorMedium  , shadow: false)
        photoView.addSubview(linkView)
        
        let linkButton = createButton(CGRect(x: 0, y: 10, width: (photoViewerFrame?.width)!, height: 60), title: "", border: false, bgColor: false, textColor: UIColor.clear)
        photoView.addSubview(linkButton)
        imageView = createImageView(CGRect(x: 5, y: 5, width: 50, height: 50), border: true)
        imageView.clipsToBounds = true
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        imageView.contentMode = .scaleAspectFit // OR .scaleAspectFill
   

        linkView.addSubview(imageView)
        
        titleLabel = createLabel(CGRect(x: 60, y: 5 , width: (photoViewerFrame?.width)! - 60, height: 25), text: "", alignment: .left, textColor: textColorDark)
        titleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
        titleLabel.numberOfLines = 1
        linkView.addSubview(titleLabel)
        
        descriptionLabel = createLabel(CGRect(x: 60, y: titleLabel.bounds.height + titleLabel.frame.origin.y , width: (photoViewerFrame?.width)! - 60, height: 25), text: "", alignment: .left, textColor: textColorDark)
        descriptionLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
        descriptionLabel.numberOfLines = 2
        linkView.addSubview(descriptionLabel)
        //print(self.Sharetitle)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(swipeDown)
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if shareMessage.text == "" {
            self.shareMessage.textColor = textColorMedium
            shareMessage.text = NSLocalizedString("Say Something about this Link...",  comment: "")
        }
        
        // Only in case of Activity Feed
        if canShareLink == true{
            if contentUrl != nil && contentUrl != ""{
                attachLink(contentUrl)
            }
        }
            // Other Case
        else{
            
            if Sharetitle != "" || ShareDescription != ""{
                var titleLimit = 35
                var descriptionLimit = 110
                if imageString != "" && imageString != nil{
                    self.imageView.downloadedFrom(link: self.imageString, contentMode: .scaleAspectFill)

                }else{
                    titleLimit = 70
                    descriptionLimit = 150
                    
                    self.imageView.isHidden = true

                    self.titleLabel.frame.origin.x = 10
                    self.titleLabel.frame.size.width = self.view.bounds.width - 20
                    self.descriptionLabel.frame.origin.x = 10
                    self.descriptionLabel.frame.size.width = self.view.bounds.width - 20
                    
                }
                
                // Check condition for ipad and iphone
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    if self.Sharetitle.length < titleLimit + 20{
                        self.titleLabel.text = self.Sharetitle
                    }
                    else{
                        
                        var descriptionn = (self.Sharetitle as NSString).substring(to: 50-3)
                        descriptionn += NSLocalizedString("...",  comment: "")
                        self.titleLabel.text = descriptionn
                    }
                }
                else{
                    if self.Sharetitle.length < titleLimit{
                        self.titleLabel.text = self.Sharetitle
                    }
                    else{
                        
                        var descriptionn = (self.Sharetitle as NSString).substring(to: 35-3)
                        descriptionn += NSLocalizedString("...",  comment: "")
                        self.titleLabel.text = descriptionn
                    }
                }
                self.titleLabel.sizeToFit()
                
                self.descriptionLabel.frame.origin.y = self.titleLabel.bounds.height + self.titleLabel.frame.origin.y
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    if self.ShareDescription.length < descriptionLimit + 50{
                        self.descriptionLabel.text = self.ShareDescription.html2String
                    }
                    else{
                        
                        var descriptionn = (self.ShareDescription as NSString).substring(to: 150-3)
                        descriptionn += NSLocalizedString("...",  comment: "")
                        self.descriptionLabel.text = descriptionn.html2String
                    }
                }else{
                    
                    if self.ShareDescription != nil {
                        if self.ShareDescription.length < descriptionLimit{
                            self.descriptionLabel.text = self.ShareDescription.html2String
                        }
                        else{
                            
                            var descriptionn = (self.ShareDescription as NSString).substring(to: 100-3)
                            descriptionn += NSLocalizedString("...",  comment: "")
                            self.descriptionLabel.text = descriptionn.html2String
                        }

                    }
                }
                self.descriptionLabel.sizeToFit()
                
            }
            else{
                linkView.frame.size.height = 200
                imageView.frame = CGRect(x: 0, y: 0, width: (photoViewerFrame?.width)!, height: 200)
               // imageView.image = cropToBounds(img, width: (photoViewerFrame?.width)!, height: 200)
                titleLabel.isHidden = true
                descriptionLabel.isHidden = true
        
                
                let ImageUrl = URL(string: self.imageString)
                if ImageUrl != nil{
                    imageView.kf.indicatorType = .activity
                    (imageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    imageView.kf.setImage(with: ImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                else{
                    self.imageView.frame.size.height = 0.0
                    self.imageView.isHidden = true
                }
            }
            
        }
    }

    override func viewDidAppear(_ animated: Bool){
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
   func attachLink(_ contentUrl : String)

    {
        let linkUrl = contentUrl
        
        if Reachabable.isConnectedToNetwork() {
            var path = ""
            var parameters = [String:String]()
            path = "advancedactivity/feeds/attach-link"
            parameters = ["uri": linkUrl]
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            
            activityIndicatorView.startAnimating()
            view.isUserInteractionEnabled = false
            activityPost(parameters as Dictionary<String, AnyObject>, url: path, method: "POST") { (succeeded, msg) -> () in

                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    
                    if let response = succeeded["body"] as? NSDictionary{
                        //print(response)
                        if let temp_title = response["title"] as? String{
                            self.Sharetitle = temp_title
                        }
                        if let temp_description = response["description"] as? String{
                            self.ShareDescription = temp_description
                        }
                        
                        if let tempImageString = response["thumb"] as? String{
                            
                            self.imageString = tempImageString
                            if self.imageString.range(of: "http") != nil{
                                //print("exists")
                            }
                            else{
                                self.imageString = "http:\(tempImageString)"
                            }
                            
                            //print(self.imageString)
                            self.imageView.downloadedFrom(link: self.imageString, contentMode: .scaleAspectFill)
                        }
                        
                        //                        self.titleLabel.text = self.Sharetitle
                        if(UIDevice.current.userInterfaceIdiom == .pad){
                            if self.Sharetitle.length < 50{
                                self.titleLabel.text = self.Sharetitle
                            }
                            else{
                                
                                var descriptionn = (self.Sharetitle as NSString).substring(to: 50-3)
                                descriptionn += NSLocalizedString("...",  comment: "")
                                self.titleLabel.text = descriptionn
                            }
                        }
                        else{
                            if self.Sharetitle.length < 35{
                                self.titleLabel.text = self.Sharetitle
                            }
                            else{
                                
                                var descriptionn = (self.Sharetitle as NSString).substring(to: 35-3)
                                descriptionn += NSLocalizedString("...",  comment: "")
                                self.titleLabel.text = descriptionn
                            }
                        }
                        self.titleLabel.sizeToFit()
                        self.descriptionLabel.frame.origin.y = self.titleLabel.bounds.height + self.titleLabel.frame.origin.y
                        if(UIDevice.current.userInterfaceIdiom == .pad){
                            if self.ShareDescription.length < 150{
                                self.descriptionLabel.text = self.ShareDescription
                            }
                            else{
                                
                                var descriptionn = (self.ShareDescription as NSString).substring(to: 150-3)
                                descriptionn += NSLocalizedString("...",  comment: "")
                                self.descriptionLabel.text = descriptionn
                            }
                        }
                        else{
                            if self.ShareDescription.length < 100{
                                self.descriptionLabel.text = self.ShareDescription
                            }
                            else{
                                
                                var descriptionn = (self.ShareDescription as NSString).substring(to: 100-3)
                                descriptionn += NSLocalizedString("...",  comment: "")
                                self.descriptionLabel.text = descriptionn
                            }
                        }
                        self.descriptionLabel.sizeToFit()
                        
                        
                        
                    }
                })
            }
        }
    }
    
    @objc func shareContent(){
        removeAlert()
        // Share Content Validaion
        shareMessage.resignFirstResponder()
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            //self.shareItem.isEnabled = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            var dic = Dictionary<String, String>()
            for (key, value) in param{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            if shareMessage.text != "Say Something about this Link..."
            {
                dic["body"] = shareMessage.text
            }
            else
            {
                dic["body"] = ""
            }
            // Send Server Request to Share Content
            post(dic, url: url, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        //self.shareItem.isEnabled = true
                        self.navigationItem.rightBarButtonItem?.isEnabled = true
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: NSLocalizedString("Content Shared Successfully.", comment: ""), controller: self)
                            self.createTimer(self)
                            self.popAfterDelay = true
                        }
                        else
                        {
                            showToast(message: NSLocalizedString("Content Shared Successfully.", comment: ""), controller: self)
                            self.createTimer(self)
                            self.popAfterDelay = true
                        }
                        
                    }
                    else
                    {
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }

                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer() {
        stop()
        // popViewController After Delay
        if popAfterDelay == true {
            feedUpdate = true
            self.goBack()
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.textColor == textColorMedium {
            textView.text = ""
            textView.textColor = textColorDark
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView){
        textView.frame.size.width = view.bounds.width-20
        //print(textView.text)
        if textView.frame.size.height <  200 {
            textView.sizeToFit()
            textView.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, animations: {
                if self.photoView != nil{
                    self.photoView.frame.origin.y = self.shareMessage.bounds.height + self.shareMessage.frame.origin.y
                }
            })
        }
        else{
            shareMessage.isScrollEnabled = true
        }
    }
    

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        return true
    }
    
    @objc func goBack()
    {
        delegateAdvanceVShareVideoResume?.resumeVideoInTikTokTable()
        _ = self.dismiss(animated: true, completion: nil)

    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            switch swipeGesture.direction {
//            case UISwipeGestureRecognizer.Direction.right:
//                //print("Swiped right")
//            case UISwipeGestureRecognizer.Direction.down:
//                //print("Swiped down")
//                self.view.endEditing(false)
//            case UISwipeGestureRecognizer.Direction.left:
//                //print("Swiped left")
//            case UISwipeGestureRecognizer.Direction.up:
//                //print("Swiped up")
//            default:
//                break
//            }
//        }
    }
    
}
