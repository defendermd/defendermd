//
//  PreviewViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 20/11/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit
import AgoraSigKit

class PreviewViewController: UIViewController , LiveRoomVCDelegate , UITextFieldDelegate , TTTAttributedLabelDelegate , UITextViewDelegate{
    var rtcEngine: AgoraRtcEngineKit!
    var isBroadcaster: Bool = true//false
    var remoteContainerView =  UIView()
    var liveButton = UIButton()
    var crossButton = UIButton()
    var cameraButton = UIButton()
    var email = UITextView()//UITextField()
    var videoPrivacybutton = UIButton()
    var video_authView = "everyone"
    var rightBottomButton = UIButton()
    var liveDesc = UILabel()
    var checkBroadcast = ""
    var privacyButton = UIButton()
    var checkBoxValue = ""
    var locLabel : TTTAttributedLabel! //UILabel()
    var frndTagLabel = UILabel()
    var withLabel = UILabel()
    var cancelLabel = UIButton()
    var lineView = UIView()
    var taggedFriendsString = ""
    var locationInfoString = ""
    
    fileprivate var videoSessions = [VideoSession]() {
        didSet {
            guard remoteContainerView != nil else {
                return
            }
            updateInterface(withAnimation: true)
        }
    }
    
    fileprivate var fullSession: VideoSession? {
        didSet {
            if fullSession != oldValue && remoteContainerView != nil {
                updateInterface(withAnimation: true)
            }
        }
    }
    
    fileprivate let viewLayouter = VideoViewLayouter()
    
    var clientRole = AgoraClientRole.broadcaster {
        didSet {
            // updateButtonsVisiablity()
        }
    }
    
    func updateInterface(withAnimation animation: Bool) {
        if animation {
            
            UIView.animate(withDuration: 0.3) {
                self.updateInterface()
                self.view.layoutIfNeeded()
            }
            
        }
        else {
            updateInterface()
        }
    }
    
    func updateInterface() {
        var displaySessions = videoSessions
        if !isBroadcaster && !displaySessions.isEmpty {
            displaySessions.removeFirst()
        }
        viewLayouter.layout(sessions: displaySessions, fullSession: fullSession, inContainer: remoteContainerView)
        setStreamType(forSessions: displaySessions, fullSession: fullSession)
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func setStreamType(forSessions sessions: [VideoSession], fullSession: VideoSession?) {
        if let fullSession = fullSession {
            for session in sessions {
                rtcEngine.setRemoteVideoStream(UInt(session.uid), type: (session == fullSession ? .high : .low))
            }
        } else {
            for session in sessions {
                rtcEngine.setRemoteVideoStream(UInt(session.uid), type: .high)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeNavigationImage(controller: self)
        self.hideKeyboardWhenTappedAround()
        checkBroadcast = ""
        locLabel = TTTAttributedLabel(frame:CGRect(x: 10, y:  50, width: view.bounds.width - 90, height: 50))
        UserDefaults.standard.setValue("friends", forKey: "privacy")
        rtcEngine = AgoraRtcEngineKit.sharedEngine(withAppId: "\(AgoraId)", delegate: self as? AgoraRtcEngineDelegate)
        rtcEngine.setChannelProfile(.liveBroadcasting)
        rtcEngine.enableDualStreamMode(true)
        rtcEngine.enableVideo()
        rtcEngine.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension840x480,
                                                                              frameRate: .fps15,
                                                                              bitrate: AgoraVideoBitrateStandard,
                                                                              orientationMode: .fixedPortrait))
        rtcEngine.setClientRole(clientRole)
        
        if isBroadcaster {
            rtcEngine.startPreview()
        }
        
        addLocalSession()
        frndTag.removeAll(keepingCapacity: false)
        locationTag.removeAll(keepingCapacity: false)
        arrayPrivacy.removeAll()
        
        view.backgroundColor = UIColor.black//UIColor(patternImage: UIImage(named: "Welcome_SlideShow3_640x1136")!)
        view.addSubview(remoteContainerView)
        remoteContainerView.frame = view.frame
        liveButton = createButton(CGRect(x: view.bounds.width/2 - 100 , y: view.bounds.height -  (10 + tabBarHeight) , width : 200 , height : 40), title: NSLocalizedString(" Go Live",  comment: ""), border: false, bgColor: true, textColor: UIColor.white)
        view.addSubview(liveButton)
        liveButton.layer.cornerRadius = 18
        liveButton.layer.masksToBounds = true
        liveButton.addTarget(self, action: #selector(PreviewViewController.showLive), for: .touchUpInside)
        
        crossButton = createButton(CGRect(x: view.bounds.width - 40 , y: 21 + iphonXTopsafeArea, width : 40 , height : 40), title: "", border: false, bgColor: false, textColor: UIColor.red)
        crossButton.setImage(UIImage(named: "cross_icon"), for: .normal)
        crossButton.titleLabel?.font = UIFont(name: fontNormal, size: FONTSIZELarge)
        view.addSubview(crossButton)
        crossButton.addTarget(self, action: #selector(PreviewViewController.goBack), for: .touchUpInside)
        
        cameraButton = createButton(CGRect(x: 10 , y: view.bounds.height -  ( 10 + tabBarHeight) , width : 40 , height : 40), title: "", border: false, bgColor: true, textColor: buttonColor)
        cameraButton.layer.cornerRadius = 20
        cameraButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        cameraButton.setImage(UIImage(named: "flipCamera"), for: .normal)
        cameraButton.contentMode = .scaleAspectFit
        cameraButton.clipsToBounds = true
        cameraButton.layer.masksToBounds = true
        cameraButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        view.addSubview(cameraButton)
        cameraButton.addTarget(self, action: #selector(PreviewViewController.doSwitchCameraPressed), for: .touchUpInside)
        
        rightBottomButton = createButton(CGRect(x: view.bounds.width - 50 , y: view.bounds.height -  (10 + tabBarHeight) , width : 40 , height : 40), title: "", border: false, bgColor: true, textColor: UIColor.red)
        rightBottomButton.setImage(UIImage(named: "MoreIcon"), for: .normal)
        rightBottomButton.contentMode = .scaleAspectFit
        rightBottomButton.clipsToBounds = true
        rightBottomButton.layer.masksToBounds = true
        rightBottomButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        rightBottomButton.layer.cornerRadius = 20
        rightBottomButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(rightBottomButton)
        rightBottomButton.addTarget(self, action: #selector(PreviewViewController.doMore), for: .touchUpInside)
        
        
        email = createTextView(CGRect(x:10 , y:view.bounds.height/2 - 50 ,width:UIScreen.main.bounds.width-20  , height:90), borderColor: UIColor.clear, corner: false)
        email.text = NSLocalizedString(NSLocalizedString("Add a description",  comment: ""), comment: "")
        email.delegate = self
        email.autocapitalizationType = .none
        email.textColor = textColorLight
        email.font =  UIFont(name: fontNormal, size: 17.0)
        email.tag = 11
        email.backgroundColor = UIColor.clear
        email.autocorrectionType = UITextAutocorrectionType.no
        view.addSubview(email)
        
        if #available(iOS 9.0, *) {
            let item : UITextInputAssistantItem = email.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        } else {
            // Fallback on earlier versions
        }
        
        email.layer.masksToBounds = true
        email.tintColor = UIColor.lightGray
        email.textColor = textColorLight
        
        lineView = UIView()
        lineView.frame = CGRect(x: 10, y: getBottomEdgeY(inputView: email) - 55, width: view.bounds.width - 20, height: 1)
        view.addSubview(lineView)
        lineView.backgroundColor = buttonColor
        
        if let privacy = UserDefaults.standard.string(forKey: "privacy")
        {
            video_authView = privacy
        }
        else
        {
            video_authView = "everyone"
        }
        
        
        videoPrivacybutton = createButton(CGRect(x: 10 , y: view.bounds.height/2 - 110 ,width: view.bounds.width - 20 , height: 25), title: "", border: false,bgColor: false, textColor: textColorLight)
        videoPrivacybutton.titleLabel?.font = UIFont(name: fontName, size: 17)
        
        view.addSubview(videoPrivacybutton)
        
        privacyButton = createButton(CGRect(x: view.bounds.width - 30 , y: view.bounds.height/2 - 106 ,width: 19 , height: 19), title: "", border: false,bgColor: false, textColor: textColorLight)
        privacyButton.setImage(UIImage(named:"gearicon")?.maskWithColor(color: textColorLight), for: .normal)
        privacyButton.addTarget(self, action: #selector(PreviewViewController.showVideoPrivacy(_:)), for: .touchUpInside)
        view.addSubview(privacyButton)
        
        
        // Do any additional setup after loading the view.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == NSLocalizedString("Add a description",  comment: ""){
            textView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text.isEmpty {
            DispatchQueue.main.async {
                textView.text = NSLocalizedString("Add a description",  comment: "")
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        lineView.frame.origin.y = email.frame.origin.y + textView.contentSize.height//getBottomEdgeY(inputView: email)
        if lineView.frame.origin.y > getBottomEdgeY(inputView: email){
            lineView.frame.origin.y = getBottomEdgeY(inputView: email)
        }
    }
    
    @objc func doMore(){
        checkBroadcast = "false"
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Location",  comment: ""), style: .default) { (action) in
            self.openLocation()
        })
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Tag People",  comment: ""), style: .default) { (action) in
            self.openTag()
        })
        
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel",  comment: ""), style: .cancel))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func openTag(){
        let presentedVC = TaggingViewController()
        presentedVC.showType = "Preview"
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:false, completion: nil)
        CFRunLoopWakeUp(CFRunLoopGetCurrent())
    }
    
    func openLocation(){
        let presentedVC = CheckInViewController()
        presentedVC.fromActivityFeed = false
        let nativationController = UINavigationController(rootViewController: presentedVC)
        nativationController.modalPresentationStyle = .fullScreen
        self.present(nativationController, animated:false, completion: nil)
        CFRunLoopWakeUp(CFRunLoopGetCurrent())
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @objc func showVideoPrivacy(_ sender:UIButton){
        
        
        let pv = SetPrivacyViewController()
        
        pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: pv)
        
        present(nativationController, animated:true, completion: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if discardView == true{
            discardView = false
            dismiss(animated: true, completion: nil)
            
        }
        
        removeNavigationImage(controller: self)
        checkBroadcast = ""
        if let privacy = UserDefaults.standard.string(forKey: "privacy")
        {
            video_authView = privacy
        }
        else
        {
            video_authView = "everyone"
        }
        
        if let privacyDictionary = postPermission["userprivacy"] as? NSDictionary{
            var privacyStringContent = ""
            if video_authView != nil && video_authView != ""{
                
                if let privacy = privacyDictionary[video_authView] as? String {
                    
                    privacyStringContent = privacy
                    
                }
                else {
                    privacyStringContent = "Everyone"
                }
            }
            else{
                privacyStringContent = "Everyone"
            }
            videoPrivacybutton.titleLabel?.numberOfLines = 1
            videoPrivacybutton.titleLabel?.lineBreakMode = .byTruncatingTail
            videoPrivacybutton.setTitle(String(format: NSLocalizedString("You are going live with %@", comment: ""), privacyStringContent), for: .normal)
            videoPrivacybutton.contentHorizontalAlignment = .center
            let height = videoPrivacybutton.frame.size.height
            videoPrivacybutton.sizeToFit()
            videoPrivacybutton.frame.size.height = height
            let totWidth = (findWidthByTextLive("You are going live with \(privacyStringContent)") + 20 + 10)
            videoPrivacybutton.frame.origin.x = (self.view.bounds.width - totWidth)/2
            privacyButton.frame.origin.x = videoPrivacybutton.frame.origin.x + findWidthByTextLive("You are going live with \(privacyStringContent)") + 8
        }
        
        if locationTag["location"] != nil {
            var location = locationTag["location"] as! NSDictionary
            if location["label"] != nil {
                let city = location["label"] as? String
            }
        }
        
        if arrayPrivacy.count == 0 {
            if let privacy = UserDefaults.standard.string(forKey: "privacy"){
                arrayPrivacy.append(privacy)
            }
        }
        
        var checkKey = ""
        checkBoxValue = ""
        
        for a in arrayPrivacy{
            
            checkKey = a
            
            if checkBoxValue  != "" {
                checkBoxValue = "\(checkBoxValue),\(checkKey)"
            }
            else{
                checkBoxValue = "\(checkKey)"
            }
        }
        
        
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
            } catch _ {
                // failure
            }
        }
        
        updateTagLabel()
        
        // addFrnd()
    }
    
    func updateTagLabel(){
        if frndTag.count > 0  {
            for (key, _) in frndTag{
                for ob in view.subviews {
                    if ob.tag == key{
                        ob.removeFromSuperview()
                    }
                }
            }
            var tempString = ""
            if frndTag.count == 1 {
                for (_, value) in frndTag{
                    tempString += "\(value)"
                }
            }else if frndTag.count == 2{
                
                var i = 0
                
                for (_, value) in frndTag{
                    if i == 0{
                        tempString += "\(value)"
                    }else{
                        tempString += " and \(value)"
                    }
                    i += 1
                }
                
            }else if frndTag.count > 2{
                let tempCount = frndTag.count - 1
                var i = 0
                for (_, value) in frndTag{
                    if i == 0{
                        tempString += "\(value) and \(tempCount) others"
                    }
                    i += 1
                    
                }
            }
            
            taggedFriendsString = tempString
            
        }else{
            taggedFriendsString = ""
        }
        
        if locationTag.count > 0{
            for (_, value) in locationTag{
                let location = value["label"] as! String
                locationInfoString = location
            }
        }else{
            locationInfoString = ""
        }
        updateUserText()
    }
    
    func updateUserText(){
        locLabel.removeFromSuperview()
        let origin_x:CGFloat = 10
        let origin_y:CGFloat = getBottomEdgeY(inputView: email) + 10
        var completeUserDetailString = "" as NSString
        if locationInfoString != "" && taggedFriendsString == ""{
            completeUserDetailString =  "- at \(locationInfoString)" as NSString
        }else if taggedFriendsString != "" && locationInfoString == "" {
            completeUserDetailString = "with - \(taggedFriendsString)" as NSString
        }else if taggedFriendsString != "" && locationInfoString != "" {
            completeUserDetailString =  "with - \(taggedFriendsString) at \(locationInfoString)" as NSString
        }
        
        locLabel = TTTAttributedLabel(frame:CGRect(x: origin_x , y: origin_y  , width: view.bounds.width - 20, height: 50))
        locLabel.numberOfLines = 0
        locLabel.delegate = self
        locLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        locLabel.textColor = textColorLight
        
        self.locLabel.setText(completeUserDetailString, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
            let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZEMedium, nil)
            let normalFont = CTFontCreateWithName( (fontName as CFString?)!, FONTSIZEMedium, nil)
            
            //            let range1 = (completeUserDetailString as NSString).range(of: userName!)
            //            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range1)
            //            mutableAttributedString?.addAttribute(NSAttributedStringKey(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)
            
            if self.locationInfoString != "" {
                let range2 = (completeUserDetailString as NSString).range(of: self.locationInfoString)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range2)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorLight , range: range2)
            }
            
            if self.taggedFriendsString != "" {
                let range3 = (completeUserDetailString as NSString).range(of: self.taggedFriendsString)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range3)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorLight , range: range3)
            }
            if self.taggedFriendsString != "" {
                let range4 = (completeUserDetailString as NSString).range(of: "and")
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: normalFont, range: range4)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorLight , range: range4)
            }
            
            return mutableAttributedString
        })
        self.locLabel.sizeToFit()
        view.addSubview(locLabel)
        
    }
    
    @objc func removeFriend(_ sender: UIButton){
        frndTag.removeValue(forKey: sender.tag)
        
        for ob in view.subviews{
            if ob.tag == sender.tag{
                ob.removeFromSuperview()
            }
        }
        
    }
    
    @objc func doSwitchCameraPressed() {
        rtcEngine?.switchCamera()
    }
    
    func addLocalSession() {
        let localSession = VideoSession.localSession()
        videoSessions.append(localSession)
        rtcEngine.setupLocalVideo(localSession.canvas)
    }
    
    func fetchSession(ofUid uid: Int64) -> VideoSession? {
        for session in videoSessions {
            if session.uid == uid {
                return session
            }
        }
        
        return nil
    }
    
    func videoSession(ofUid uid: Int64) -> VideoSession {
        if let fetchedSession = fetchSession(ofUid: uid) {
            return fetchedSession
        } else {
            let newSession = VideoSession(uid: uid)
            videoSessions.append(newSession)
            return newSession
        }
    }
    
    @objc func showLive(){
        let pv = LiveViewController()
        pv.delegate = self
        if checkBroadcast == "false"{
            pv.isBroadcaster = false
        }
        else{
            pv.isBroadcaster = true
        }
        
        let uuid = NSUUID().uuidString.lowercased()
        
        if email.text == NSLocalizedString("Add a description",  comment: ""){
            email.text = ""
        }
        
        let channelPlay = email.text!
        pv.chName = uuid
        pv.privacyAuthView = checkBoxValue
        pv.descriptionText = channelPlay
        pv.modalPresentationStyle = .fullScreen
        self.present(pv, animated: false, completion: nil)
    }
    
    func liveVCNeedClose(_ liveVC: LiveViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func goBack(){
        frndTag.removeAll()
        locationTag.removeAll()
        dismiss(animated: true, completion: nil)
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
