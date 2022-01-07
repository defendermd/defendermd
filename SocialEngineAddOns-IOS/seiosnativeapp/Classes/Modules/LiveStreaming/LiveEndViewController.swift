//
//  LiveEndViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 03/12/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
var storyPrivacyCheck : Bool = false
var postPrivacyCheck : Bool = false
class LiveEndViewController: UIViewController {
    
    var postLabel = UILabel()
    var viewerLabel = UILabel()
    var viewerCount : Int = 0
    var storyButton = UIButton()
    var storyDesc = UILabel()
    var switch1 = UISwitch()
    var switch2 = UISwitch()
    var postButton = UIButton()
    var postDesc = UILabel()
    var shareDiscardButton = UIButton()
    var streamName = ""
    var story_authView = "everyone"
    var post_authView = "friends"
    var dismissDelegateCheck : dismissDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeNavigationImage(controller: self)
        view.backgroundColor = UIColor(red: 40/255 , green: 40/255 , blue: 40/255, alpha: 1.0)
        storyPrivacyCheck = false
        postPrivacyCheck = false
        postLabel = createLabel(CGRect(x: 20, y: view.bounds.height/2 - 130 , width: view.bounds.width - 40, height: 25), text: NSLocalizedString("Post your live video",  comment: ""), alignment: .center, textColor: textColorLight)
        postLabel.font = UIFont(name: fontBold, size: 18.0)
        view.addSubview(postLabel)
        
        viewerLabel = createLabel(CGRect(x: 20, y: getBottomEdgeY(inputView: postLabel)   , width: view.bounds.width - 40, height: 25), text: "", alignment: .center, textColor: textColorLight)
        viewerLabel.font = UIFont(name: fontNormal, size: FONTSIZEMedium)
        view.addSubview(viewerLabel)
        
        if viewerCount == 1 {
            viewerLabel.text = String(format: "%@ Viewer", "\(viewerCount)")
        }
        else{
            viewerLabel.text = String(format: "%@ Viewers", "\(viewerCount)")
        }
        
        if show_story == 1 {
        storyButton = ImageTextButton(imageFrame: CGRect(x: findWidthByText("Your Story") + 10, y: 7  , width:  15, height: 15), titleFrame: CGRect(x: 5, y: 0  , width: findWidthByText("Your Story") + 5, height: 25), frame: CGRect(x: 5, y: getBottomEdgeY(inputView: viewerLabel) + 25  , width: view.bounds.width - 20, height: 25))
        storyButton.contentHorizontalAlignment = .left
        storyButton.setTitle(NSLocalizedString("Your Story",  comment: ""), for: .normal)
        storyButton.setImage(UIImage(named: "gearicon")?.maskWithColor(color: textColorLight), for: .normal)
        storyButton.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZELarge)
        view.addSubview(storyButton)
        
        storyButton.sizeToFit()
        storyButton.frame.size.height = 25
        storyButton.addTarget(self, action: #selector(LiveEndViewController.storyPrivacy(_:)), for: .touchUpInside)
        
        storyDesc = createLabel(CGRect(x: 10, y: getBottomEdgeY(inputView: storyButton) , width: view.bounds.width - 40, height: 25), text: NSLocalizedString("Visible to EveryOne",  comment: ""), alignment: .left, textColor: textColorLight)
        storyDesc.font = UIFont(name: fontNormal, size: FONTSIZEMedium)
        view.addSubview(storyDesc)
        
        switch1 = UISwitch(frame: CGRect(x: view.bounds.width - 55, y: getBottomEdgeY(inputView: viewerLabel) + 30  , width:  50, height: 30))
        view.addSubview(switch1)
        switch1.addTarget(self, action: #selector(LiveEndViewController.switchAction), for: .valueChanged)
        switch1.setOn(true, animated: true)
        
        
        postButton = ImageTextButton(imageFrame: CGRect(x: findWidthByText("Post") + 10, y: 5  , width:  15, height: 15), titleFrame: CGRect(x: 5, y: 0  , width: findWidthByText("Post") + 5, height: 25), frame: CGRect(x: 5, y: getBottomEdgeY(inputView: storyDesc) + 15  , width: view.bounds.width - 20, height: 25))
        postButton.contentHorizontalAlignment = .left
        postButton.setTitle(NSLocalizedString("Post",  comment: ""), for: .normal)
        postButton.setImage(UIImage(named: "gearicon")?.maskWithColor(color: textColorLight), for: .normal)
        postButton.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZELarge)
        view.addSubview(postButton)
        postButton.sizeToFit()
        postButton.frame.size.height = 25
        postButton.addTarget(self, action: #selector(LiveEndViewController.postPrivacy(_:)), for: .touchUpInside)
        
        postDesc = createLabel(CGRect(x: 10, y: getBottomEdgeY(inputView: postButton)  , width: view.bounds.width - 40, height: 25), text: NSLocalizedString("Share with Friends Only",  comment: ""), alignment: .left, textColor: textColorLight)
        postDesc.font = UIFont(name: fontNormal, size: FONTSIZEMedium)
        view.addSubview(postDesc)
        
        switch2 = UISwitch(frame: CGRect(x: view.bounds.width - 55, y: getBottomEdgeY(inputView: storyDesc) + 20  , width:  50, height: 30))
        view.addSubview(switch2)
        switch2.addTarget(self, action: #selector(LiveEndViewController.switchAction2), for: .valueChanged)
        switch2.setOn(true, animated: true)
        }
        else {
            postButton = ImageTextButton(imageFrame: CGRect(x: findWidthByText("Post") + 10, y: 7  , width:  15, height: 15), titleFrame: CGRect(x: 5, y: 0  , width: findWidthByText("Post") + 5, height: 25), frame: CGRect(x: 5, y: getBottomEdgeY(inputView: viewerLabel) + 25  , width: view.bounds.width - 20, height: 25))
            postButton.contentHorizontalAlignment = .left
            postButton.setTitle(NSLocalizedString("Post",  comment: ""), for: .normal)
            postButton.setImage(UIImage(named: "gearicon")?.maskWithColor(color: textColorLight), for: .normal)
            postButton.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZELarge)
            view.addSubview(postButton)
            postButton.sizeToFit()
            postButton.frame.size.height = 25
            postButton.addTarget(self, action: #selector(LiveEndViewController.postPrivacy(_:)), for: .touchUpInside)
            
            postDesc = createLabel(CGRect(x: 10, y: getBottomEdgeY(inputView: postButton) , width: view.bounds.width - 40, height: 25), text: NSLocalizedString("Share with Friends Only",  comment: ""), alignment: .left, textColor: textColorLight)
            postDesc.font = UIFont(name: fontNormal, size: FONTSIZEMedium)
            view.addSubview(postDesc)
            
            switch2 = UISwitch(frame: CGRect(x: view.bounds.width - 55, y: getBottomEdgeY(inputView: viewerLabel) + 30  , width:  50, height: 30))
            view.addSubview(switch2)
            switch2.addTarget(self, action: #selector(LiveEndViewController.switchAction2), for: .valueChanged)
            switch2.setOn(true, animated: true)
        }
        
        shareDiscardButton = createButton(CGRect(x: 40, y: view.bounds.height - (70 + iphonXBottomsafeArea) , width: view.bounds.width - 80, height: 45), title: NSLocalizedString("Share",  comment: ""), border: true, bgColor: true, textColor: textColorDark)
        shareDiscardButton.titleLabel?.font = UIFont.systemFont(ofSize: 21)
        shareDiscardButton.backgroundColor = textColorLight
        shareDiscardButton.layer.cornerRadius = 20
        shareDiscardButton.layer.masksToBounds = true
        shareDiscardButton.addTarget(self, action: #selector(LiveEndViewController.discardVideo), for: .touchUpInside)
        view.addSubview(shareDiscardButton)
        
        dismissDelegateCheck?.didSwitch()
        
        // Do any additional setup after loading the view.
    }
    
    @objc func switchAction(){
        shareDiscardButton.addTarget(self, action: #selector(LiveEndViewController.discardVideo), for: .touchUpInside)
        shareDiscardButton.setTitle(NSLocalizedString("Share",  comment: ""), for: .normal)
        if switch1.isOn == false && switch2.isOn == false{
            shareDiscardButton.setTitle(NSLocalizedString("Discard",  comment: ""), for: .normal)
            shareDiscardButton.addTarget(self, action: #selector(LiveEndViewController.discardVideo), for: .touchUpInside)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if storyPrivacyCheck == true {
            storyPrivacyCheck = false
            if let privacy = UserDefaults.standard.string(forKey: "privacy")
            {
                story_authView = privacy
            }
            else
            {
                story_authView = "everyone"
            }
            
            if let privacyDictionary = postPermission["userprivacy"] as? NSDictionary{
                
                var privacyStringContent = ""
                
                if story_authView != nil && story_authView != ""{
                    privacyStringContent = privacyDictionary[story_authView]! as! String
                }
                else{
                    privacyStringContent = "Everyone"
                }
                storyDesc.text = "Visible to \(privacyStringContent)"
                
            }
        }
        
        
        if postPrivacyCheck == true {
            postPrivacyCheck = false
            if let privacy = UserDefaults.standard.string(forKey: "privacy")
            {
                post_authView = privacy
            }
            else
            {
                post_authView = "friends"
            }
            
            if let privacyDictionary = postPermission["userprivacy"] as? NSDictionary{
                
                var privacyStringContent = ""
                
                if post_authView != nil && post_authView != ""{
                    privacyStringContent = privacyDictionary[post_authView]! as! String
                }
                else{
                    privacyStringContent = "Friends Only"
                }
                postDesc.text = "Share with \(privacyStringContent)"
                
            }
        }
        
        
    }
    
    @objc func storyPrivacy(_ sender:UIButton){
        
        let pv = SetPrivacyViewController()
        storyPrivacyCheck = true
        UserDefaults.standard.setValue("everyone", forKey: "privacy")
        pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: pv)
        present(nativationController, animated:true, completion: nil)
        
    }
    
    @objc func postPrivacy(_ sender:UIButton){
        
        let pv = SetPrivacyViewController()
        postPrivacyCheck = true
        UserDefaults.standard.setValue("friends", forKey: "privacy")
        pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: pv)
        present(nativationController, animated:true, completion: nil)
        
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    @objc func switchAction2(){
        shareDiscardButton.addTarget(self, action: #selector(LiveEndViewController.discardVideo), for: .touchUpInside)
        shareDiscardButton.setTitle("Share", for: .normal)
        if switch1.isOn == false && switch2.isOn == false{
            shareDiscardButton.setTitle(NSLocalizedString("Discard", comment: ""), for: .normal)
            shareDiscardButton.addTarget(self, action: #selector(LiveEndViewController.discardVideo), for: .touchUpInside)
        }
        
    }
    
    @objc func discardVideo(){
        discardView = true
        endVideoCalling()
        
    }
    
    func endVideoCalling(){
        
        var dic = [String : String]()
        
        if frndTag.count > 0{
            var tagString = ""
            for (key, _) in frndTag{
                tagString += (String(key) + ",")
            }
            tagString = String(tagString[..<tagString.index(tagString.startIndex, offsetBy: tagString.length-1)])
            dic["toValues"] = tagString
            
        }
        
        if locationTag.count > 0{
            let dic1 = (locationTag["location"])!
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dic1, options:  [])
                let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                
                
                var tempDic = [String:AnyObject]()
                tempDic.updateValue(finalString as AnyObject, forKey: "checkin")
                let templocationString = "{\"checkin\":"
                let locationString = templocationString + finalString + "}"
                
                dic["composer"] = locationString
                // success ...
            } catch _ {
                // failure
            }
        }
        
        
        let url1 = "livestreamingvideo/share-video/"
        activityIndicatorView.center = view.center
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        dic["auth_view"] = post_authView
        dic["privacy"] = story_authView
        
        var endType = "normal"
        if switch1.isOn == true && switch2.isOn == true{
            endType = "both"
        }
        else if switch1.isOn == true && switch2.isOn == false{
            endType = "story"
        }
        else if switch1.isOn == false && switch2.isOn == true{
            endType = "feed"
        }
        let method1 = "POST"
        dic["stream_name"] = "\(streamName)"
        dic["endType"] = "\(endType)"
        dic["view_count"] = "\(viewerCount)"
        dic["sid"] = "\(sidValue)"
        
        post(dic , url: "\(url1)", method: method1) { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                // spinner.stopAnimating()
                
                if msg{
                    
                    feedUpdate = true
                    frndTag.removeAll()
                    locationTag.removeAll()
                    
                    discardView = true
                    if endType == "normal"{
                        self.discardApiCalling()
                        showToast(message: NSLocalizedString("Video Discarded",  comment: ""), controller: self)
                    }
                    else if endType == "feed"{
                        activityIndicatorView.stopAnimating()
                        isViewWillAppearCall = 0
                        showToast(message: NSLocalizedString("Video will be Added to your Feed",  comment: ""), controller: self)
                        delay(2) {
                            
                            self.dismiss(animated: false, completion: nil)
                        }
                    }
                    else if endType == "story"{
                        activityIndicatorView.stopAnimating()
                        isViewWillAppearCall = 3
                        showToast(message: NSLocalizedString("Video will be Added to your Story",  comment: ""), controller: self)
                        delay(2) {
                            
                            self.dismiss(animated: false, completion: nil)
                        }
                    }
                    else{
                        isViewWillAppearCall = 0
                        activityIndicatorView.stopAnimating()
                        showToast(message: NSLocalizedString("Video will be Added to Story and Feed Shortly",  comment: ""), controller: self)
                        delay(2) {
                            
                            self.dismiss(animated: false, completion: nil)
                        }
                    }
                    
                    
                    
                }
                    
                else{
                    activityIndicatorView.stopAnimating()
                    // Handle Server Side Error
                    if succeeded["message"] != nil{
                        if succeeded["message"] as! String == "stream_not_exist"{
                            showToast(message: NSLocalizedString("Something went wrong, Video can't be shared",  comment: ""), controller: self)
                        }
                        else{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                    delay(2) {
                        self.dismiss(animated: false, completion: nil)
                    }
                }
            })
        }
        
        
    }
    
    func discardApiCalling(){
        var dic = [String : String]()
        let url1 = "discard"
        
        let method1 = "DELETE"
        dic["sid"] = "\(sidValue)"
        
        
        AgoraPost(dic , url: "\(url1)", method: method1) { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
               
                activityIndicatorView.stopAnimating()
                
                if msg{
                    delay(2) {
                        self.dismiss(animated: false, completion: nil)
                    }
                    
                    
                }
                    
                else{
                    // Handle Server Side Error
                    if succeeded["message"] != nil{
                        showToast(message: succeeded["message"] as! String, controller: self)
                    }
                }
            })
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

