//
//  LiveViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 16/11/18.
//  Copyright © 2018 bigstep. All rights reserved.
//

import UIKit
import AgoraRtcEngineKit
import AgoraSigKit
var videoProfile = AgoraVideoDimension640x360
protocol LiveRoomVCDelegate {
    func liveVCNeedClose(_ liveVC: LiveViewController)
}
protocol dismissDelegate{
    func didSwitch()
    
}
var discardView : Bool = false


fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class LiveViewController: UIViewController , UITextViewDelegate , UITableViewDelegate , UITableViewDataSource , TTTAttributedLabelDelegate , UIGestureRecognizerDelegate , dismissDelegate{
    
    
    var rtcEngine: AgoraRtcEngineKit!
    var isBroadcaster: Bool = true//false
    var remoteContainerView =  UIView()
    var dismissButton = UIButton()
    var delegate: LiveRoomVCDelegate?
    var cameraButton = UIButton()
    var userNum : Int = 0
    var chName = ""
    var liveButton = UIButton()
    var viewButton = UIButton()
    var commentButton = UIButton()
    var scrollemoji = UIScrollView()
    var scrollUperemoji = UIImageView()
    var lineView = UIView()
    var updateTimer:Timer!
    var startTime = TimeInterval()
    var timerLabel = ""
    var updateTimer1:Timer!
    var showTimer : Bool = false
    var commentTextView = UITextView()
    var commentPost = UIButton()
    var keyBoardHeight1 : CGFloat = 0.0
    var responseDictonary:NSDictionary?
    var commentResponse = [AnyObject]()
    var viewersResponse = [AnyObject]()
    var tempViewersResponse = [AnyObject]()
    var liveComentTableView = UITableView()
    var dynamicHeight = [Int:CGFloat]()
    var userIdList = [Int]()
    var tempUserIdList = [Int]()
    var liveUserTableView = UITableView()
    
    var videoId : Int = 0
    var videoType : String = ""
    var pageNumber : Int = 1
    var privacyAuthView = ""
    var descriptionText = ""
    
    
    fileprivate var isMuted = false {
        didSet {
            rtcEngine?.muteLocalAudioStream(isMuted)
            // audioMuteButton?.setImage(UIImage(named: isMuted ? "btn_mute_cancel" : "btn_mute"), for: .normal)
        }
    }
    
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
    
    var clientRole = AgoraClientRole.audience//AgoraClientRole.broadcaster
    
    override func viewDidLoad() {
        super.viewDidLoad()
        discardView = false
        sidValue = ""
        removeNavigationImage(controller: self)
        remoteContainerView.frame = view.frame
        // if isBroadcaster == true {
        self.hideViewWhenTappedAround()
        //  }
        view.addSubview(remoteContainerView)
        self.remoteContainerView.isUserInteractionEnabled = false
        if isBroadcaster == true{
            clientRole = AgoraClientRole.broadcaster
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LiveViewController.keyboardWasShown),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LiveViewController.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        remoteContainerView.backgroundColor = UIColor.black//textColorLight
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(LiveViewController.applicationWillTerminate),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
        
        
        
        
        loadAgoraKit()
        AgoraSignal.Kit.login2(AgoraId, account: "\(currentUserId)", token: "_no_need_token", uid: 0, deviceID: nil, retry_time_in_s: 2, retry_count: 5)
        AgoraSignal.Kit.channelJoin("\(chName)")
        AgoraSignal.Kit.channelQueryUserNum("\(chName)")
        addAgoraSignalBlock()
        
        if emojiReactionDictionary != nil {
            browseEmojiSub(contentItems: emojiReactionDictionary)
        }
        
        
        scrollemoji.frame = CGRect(x:0, y:(self.view.bounds.height) - (60 + iphonXBottomsafeArea), width:(self.view.bounds.width), height:60)
        scrollemoji.backgroundColor = UIColor.clear//UIColor.black.withAlphaComponent(0.8)
        self.view.addSubview(scrollemoji)
        
        scrollUperemoji = UIImageView(frame: CGRect(x:0, y: iphonXBottomsafeArea, width:(self.view.bounds.width), height:60))
        scrollUperemoji.backgroundColor = UIColor.clear
        self.view.addSubview(scrollUperemoji)
        
        cameraButton = createButton(CGRect(x: 10 , y: 12 , width : 40 , height : 40), title: "", border: false, bgColor: false, textColor: textColorLight)
        cameraButton.layer.cornerRadius = 20
        cameraButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        cameraButton.setImage(UIImage(named: "flipCamera"), for: .normal)
        cameraButton.contentMode = .scaleAspectFit
        cameraButton.clipsToBounds = true
        cameraButton.layer.masksToBounds = true
        cameraButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        cameraButton.titleLabel?.font = UIFont(name: "fontAwesome", size: FONTSIZEExtraLarge)
        self.scrollemoji.addSubview(cameraButton)
        cameraButton.addTarget(self, action: #selector(LiveViewController.doSwitchCameraPressed), for: .touchUpInside)
        
        liveButton = createButton(CGRect(x: 10 , y: 21 + iphonXTopsafeArea, width : 40 , height : 27), title: "", border: false, bgColor: false, textColor: textColorLight)
        liveButton.layer.cornerRadius = 5
        liveButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        view.addSubview(liveButton)
        liveButton.addTarget(self, action: #selector(LiveViewController.switchToTime), for: .touchUpInside)
        
        if (DeviceType.IS_IPHONE_X) {
            viewButton = ImageTextButton(imageFrame: CGRect(x: 5 , y: 24  , width : 20 , height : 20), titleFrame: CGRect(x: 30 , y: 24  , width : 20 , height : 20), frame: CGRect(x: 60 , y: 24 , width : 40 , height : 40))
        }
        else{
            viewButton = ImageTextButton(imageFrame: CGRect(x: 5 , y: 13   , width : 20 , height : 20), titleFrame: CGRect(x: 30 , y: 13   , width : 20 , height : 20), frame: CGRect(x: 60 , y: 13  , width : 40 , height : 20))
        }
        
        viewButton.contentHorizontalAlignment = .left
        //  viewButton = createButton(CGRect(x: 60 , y: 15 + iphonXTopsafeArea , width : 40 , height : 40), title: "", border: false, bgColor: false, textColor: textColorLight)
        viewButton.titleLabel?.font = UIFont(name: "fontAwesome", size: 18.0)
        view.addSubview(viewButton)
        viewButton.addTarget(self, action: #selector(LiveViewController.showViewers), for: .touchUpInside)
        
        viewButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        viewButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        viewButton.layer.shadowOpacity = 1.0
        viewButton.layer.shadowRadius = 0
        viewButton.layer.masksToBounds = false
        
        dismissButton = createButton(CGRect(x: remoteContainerView.frame.size.width - 60 , y: 21 + iphonXTopsafeArea , width: 60 , height: 25), title: "", border: false, bgColor: false, textColor: textColorLight)
        dismissButton.layer.cornerRadius = 8
        view.addSubview(dismissButton)
        
        if isBroadcaster == false{
            dismissButton.setTitle(NSLocalizedString("Close",  comment: ""), for: .normal)
            dismissButton.addTarget(self, action: #selector(LiveViewController.cross), for: .touchUpInside)
        }
        else{
            // dismissButton.setTitle(NSLocalizedString("End",  comment: ""), for: .normal)
            // dismissButton.addTarget(self, action: #selector(LiveViewController.showAlertDialog), for: .touchUpInside)
            
        }
        
        dismissButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        dismissButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        dismissButton.layer.shadowOpacity = 1.0
        dismissButton.layer.shadowRadius = 0
        dismissButton.layer.masksToBounds = false
        
        
        commentButton = createButton(CGRect(x:60,y:10 , width:160, height:45), title: NSLocalizedString("Write a comment",  comment: ""), border: true,bgColor: true, textColor: textColorLight )
        commentButton.layer.cornerRadius = 20
        commentButton.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZELarge)
        commentButton.layer.borderColor = textColorDark.cgColor
        commentButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        commentButton.layer.borderWidth = 0
        commentButton.contentHorizontalAlignment = .center
        commentButton.titleLabel?.font = UIFont(name: fontNormal , size: FONTSIZEMedium )
        commentButton.addTarget(self, action: #selector(LiveViewController.clickComment), for: .touchUpInside)
        self.scrollemoji.addSubview(commentButton)
        
        if isBroadcaster == false{
            viewButton.isHidden = true
            cameraButton.isHidden = true
            commentButton.frame.origin.x = 10
            commentButton.frame.size.width = 200
        }
        else{
            viewButton.isHidden = false
            cameraButton.isHidden = false
        }
        
        
        liveComentTableView = UITableView(frame: CGRect(x: 0, y: (UIScreen.main.bounds.height) - (scrollemoji.frame.size.height), width: view.bounds.width, height:  1), style: UITableView.Style.plain)
        liveComentTableView.register(LiveCommentTableViewCell.self, forCellReuseIdentifier: "liveCommentCell")
        liveComentTableView.dataSource = self
        liveComentTableView.delegate = self
        liveComentTableView.bounces = false
        liveComentTableView.rowHeight = UITableView.automaticDimension
        liveComentTableView.backgroundColor = UIColor.clear
        liveComentTableView.separatorColor = UIColor.clear
        liveComentTableView.separatorInset = .zero
        liveComentTableView.layoutMargins = .zero
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            liveComentTableView.estimatedRowHeight = 0
            liveComentTableView.estimatedSectionHeaderHeight = 0
            liveComentTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(liveComentTableView)
        
        
        liveUserTableView = UITableView(frame: CGRect(x: 20, y: 55 + iphonXTopsafeArea, width: view.bounds.width - 40, height:  view.bounds.height - (60 + iphonXTopsafeArea + 70 + iphonXBottomsafeArea)), style: UITableView.Style.plain)
        liveUserTableView.register(LiveUserTableViewCell.self, forCellReuseIdentifier: "liveUserCell")
        liveUserTableView.dataSource = self
        liveUserTableView.delegate = self
        liveUserTableView.bounces = false
        liveUserTableView.tag = 101
        liveUserTableView.rowHeight = UITableView.automaticDimension
        liveComentTableView.estimatedRowHeight = 55
        liveUserTableView.backgroundColor = UIColor.clear
        liveUserTableView.separatorColor = UIColor.clear//UIColor(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 1.0)//textColorMedium
        liveUserTableView.separatorInset = .zero
        liveUserTableView.layoutMargins = .zero
        liveUserTableView.isHidden = true
        liveUserTableView.showsVerticalScrollIndicator = false
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            liveUserTableView.estimatedRowHeight = 0
            liveUserTableView.estimatedSectionHeaderHeight = 0
            liveUserTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(liveUserTableView)
        delegate?.liveVCNeedClose(self)
        
        
        // Do any additional setup after loading the view.
    }
    
    func didSwitch(){
        self.dismiss(animated: false, completion: nil)
        self.delegate?.liveVCNeedClose(self)
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == "" {
            commentPost.isEnabled = false
        }
        else{
            commentPost.isEnabled = true
        }
    }
    
    func findAllComments(){
        
        
        // fetchReactionResponse()
        
        // Check Internet Connection
        if reachability.connection != .none {
            removeAlert()
            
            //   var url = "like-comments"
            var parameters = [ "subject_type": videoType,"viewAllComments":"1","limit":"\(limit)", "page":"\(pageNumber)"]
            
            parameters ["subject_id"] = String(videoId)
            
            var url:String!
            url = "advancedcomments/likes-comments"//"likes-comments"
            // Send Server Request for Comments
            post(parameters , url: url, method: "GET") { (succeeded, msg) -> () in
                // Stop Spinner
                DispatchQueue.main.async(execute: {
                    // spinner.stopAnimating()
                    
                    
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                total_Comments = body["getTotalComments"] as! Int
                                if let comments = body["viewAllComments"] as? NSArray{
                                    if comments.count > 0{
                                        
                                        self.commentResponse = (comments as [AnyObject])
                                        self.liveComentTableView.isHidden = false
                                        
                                        let indexPath = IndexPath(row: (self.commentResponse.count) - 1, section: 0)
                                        self.liveComentTableView.reloadData()
                                        
                                        if (self.liveComentTableView.contentSize.height) > CGFloat(200) {
                                            self.liveComentTableView.frame.size.height = 200
                                            self.liveComentTableView.frame.origin.y = (UIScreen.main.bounds.height) - ((self.scrollemoji.frame.size.height) + iphonXBottomsafeArea + 200)
                                        }
                                        else{
                                            self.liveComentTableView.frame.size.height = (self.liveComentTableView.contentSize.height)
                                            self.liveComentTableView.frame.origin.y = (UIScreen.main.bounds.height) - ((self.liveComentTableView.contentSize.height) + (self.scrollemoji.frame.size.height) + iphonXBottomsafeArea)
                                            if indexPath.row == 0 {
                                                self.dynamicHeight[indexPath.row] = (self.liveComentTableView.contentSize.height)
                                                
                                                self.liveComentTableView.reloadData()
                                            }
                                        }
                                        
                                        
                                        
                                        self.liveComentTableView.reloadData()
                                        DispatchQueue.main.async {
                                            self.liveComentTableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
                                        }
                                        
                                        
                                    }
                                }
                                
                            }
                        }
                        
                    }else{
                        // Handle Server Side Error
                        //                        if succeeded["message"] != nil{
                        //                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        //                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
        
    }
    
    @objc func applicationWillTerminate(_ application: UIApplication) {
        if isBroadcaster {
            self.liveAppClose()
            self.stopServerCalling()
            self.stopApiCalling()
            
            var dismissObject = [String:AnyObject]()
            dismissObject.updateValue("Live Video Ended" as AnyObject, forKey: "endmessage")
            dismissObject.updateValue(true as AnyObject, forKey: "is_live_stream_dismiss")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dismissObject, options:  [])
                let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                
                let diceRoll = arc4random()
                AgoraSignal.Kit.messageChannelSend("\(self.chName)", msg: "\(finalString)", msgID: String(diceRoll))
            }
            catch _ {
                // failure
            }
            
        }
        
        
    }
    
    func hideViewWhenTappedAround() {
        let tap: UITapGestureRecognizer =  UITapGestureRecognizer(target: self, action: #selector(LiveViewController.dismissView))
        tap.delegate = self
        // tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchPoint = touch.location(in: self.view)
        let buttonFrame = self.scrollemoji.frame
        let secondFrame = CGRect(x: 0, y: 0 , width: view.bounds.width, height: 50 + iphonXTopsafeArea)
        if (self.liveUserTableView.contentSize.height) > CGFloat(view.bounds.height - (60 + iphonXTopsafeArea + 70 + iphonXBottomsafeArea)) {
            self.liveUserTableView.frame.size.height = view.bounds.height - (60 + iphonXTopsafeArea + 70 + iphonXBottomsafeArea)
            
        }
        else{
            self.liveUserTableView.frame.size.height = (self.liveUserTableView.contentSize.height)
        }
        let thirdFrame = self.liveUserTableView.frame
        if buttonFrame.contains(touchPoint) || secondFrame.contains(touchPoint) || thirdFrame.contains(touchPoint)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    @objc func dismissView() {
        view.endEditing(true)
        if dismissButton.isHidden == true {
            dismissButton.isHidden = false
        }
        else{
            dismissButton.isHidden = true
        }
        if isBroadcaster == true {
            if viewButton.isHidden == true {
                viewButton.isHidden = false
            }
            else{
                viewButton.isHidden = true
            }
            
            liveUserTableView.isHidden = true
            
        }
        
        if liveButton.isHidden == true {
            liveButton.isHidden = false
        }
        else{
            liveButton.isHidden = true
        }
        
        if scrollemoji.isHidden == true {
            scrollemoji.isHidden = false
        }
        else{
            scrollemoji.isHidden = true
        }
        
        if liveComentTableView.isHidden == true{
            liveComentTableView.isHidden = false
        }
        else{
            liveComentTableView.isHidden = true
        }
        if scrollUperemoji.isHidden == true {
            scrollUperemoji.isHidden = false
        }
        else{
            scrollUperemoji.isHidden = true
        }
        
    }
    
    func browseEmojiSub(contentItems: NSDictionary)
    {
        var allReactionsValueDic = Dictionary<String, AnyObject>() // sorted Reaction Dictionary
        allReactionsValueDic = sortedReactionDictionary(dic: contentItems) as! Dictionary<String, AnyObject>
        var width   = contentItems.count
        width =   (30 * width)
        let  width1 = CGFloat(width)
        scrollemoji.frame = CGRect(x:0,y: (self.view.bounds.height) - 50,width: width1 + 170,height: 50)
        scrollemoji.backgroundColor = UIColor.gray.withAlphaComponent(0.6)
        scrollemoji.layer.borderWidth = 0.0
        scrollemoji.layer.borderColor = aafBgColor.cgColor  //UIColor.red.cgColor //tableViewBgColor.cgColor
        var menuWidth = CGFloat()
        var origin_x:CGFloat = 220 + 10
        var i : Int = 0
        
        for key in allReactionsValueDic.keys.sorted(by: <) {
            let   v = allReactionsValueDic[key]!
            
            if let icon = v["icon"] as? NSDictionary{
                
                menuWidth = 30
                let   emoji = createButton(CGRect(x: origin_x,y: 14,width: menuWidth,height: 30), title: "", border: false, bgColor: false, textColor: textColorLight)
                emoji.addTarget(self, action: #selector(LiveViewController.feedMenuReactionLike(sender:)), for: .touchUpInside)
                emoji.tag = v["reactionicon_id"] as! Int
                let imageUrl = icon["reaction_image_icon"] as? String
                
                let url = NSURL(string:imageUrl!)
                if url != nil
                {
                    emoji.kf.setImage(with: url! as URL, for: .normal)
                }
                scrollemoji.addSubview(emoji)
                origin_x = origin_x + menuWidth  + 5
                i = i + 1
            }
            
        }
        scrollemoji.contentSize = CGSize(width: width1 + CGFloat((contentItems.count) * 5) + 240, height: 30)
        scrollemoji.bounces = false
        scrollemoji.isUserInteractionEnabled = true
        scrollemoji.showsVerticalScrollIndicator = false
        scrollemoji.showsHorizontalScrollIndicator = false
        scrollemoji.alwaysBounceHorizontal = true
        scrollemoji.alwaysBounceVertical = false
        scrollemoji.isDirectionalLockEnabled = true;
        
    }
    
    @objc func feedMenuReactionLike(sender:UIButton){
        
        sender.shake()
        
        var reaction = ""
        for (_,v) in emojiReactionDictionary
        {
            
            let v = v as! NSDictionary
            if  let reactionId = v["reactionicon_id"] as? Int
            {
                if reactionId == sender.tag
                {
                    
                    reaction = (v["reaction"] as? String)!
                    var url = ""
                    url = "advancedcomments/like"
                    let icon = v["icon"] as! NSDictionary
                    let imageUrl = icon["reaction_image_icon"] as! String
                    var reactionObject = [String:AnyObject]()
                    reactionObject.updateValue("\(displayName!)" as AnyObject, forKey: "displayname")
                    reactionObject.updateValue("\(coverImage!)" as AnyObject, forKey: "user_image")
                    reactionObject.updateValue(currentUserId as AnyObject, forKey: "user_id")
                    reactionObject.updateValue(true as AnyObject, forKey: "is_live_stream_reaction")
                    reactionObject.updateValue(imageUrl as AnyObject, forKey: "reaction_icon")
                    
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: reactionObject, options:  [])
                        let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                        
                        let diceRoll = arc4random()
                        AgoraSignal.Kit.messageChannelSend("\(chName)", msg: "\(finalString)", msgID: String(diceRoll))
                        
                    }
                    catch _ {
                        // failure
                    }
                    updateReaction(url: url,reaction : reaction)
                    
                }
            }
        }
        
    }
    
    func updateReaction(url : String,reaction : String){
        if reachability.connection != .none {
            removeAlert()
            var dic = Dictionary<String, String>()
            dic["reaction"] = "\(reaction)"
            dic["subject_id"] = String(videoId)
            dic["subject_type"] = "\(videoType)"
            
            
            // Send Server Request to Update Feed Gutter Menu
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    if msg{
                        
                    }
                    
                })
                
            }
            
        }
        else
        {
            
            showToast(message: network_status_msg, controller: self, onView: false, time: 5.0)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if liveComentTableView.contentOffset.y >= liveComentTableView.contentSize.height - liveComentTableView.bounds.size.height{
            if ( limit*pageNumber < total_Comments){
                if reachability.connection != .none {
                    pageNumber += 1
                    findAllComments()
                }
            }
        }
    }
    
    func getLikeReaction(urlValue : String){
        let imageReactView = UIImageView()
        let urlVal = NSURL(string: urlValue)
        
        imageReactView.kf.setImage(with: urlVal! as URL)
        let dimension = 20 + drand48() * 10
        imageReactView.frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        
        let animation = CAKeyframeAnimation(keyPath: "position")
        if  (UIDevice.current.userInterfaceIdiom == .pad){
            animation.duration = 5 + drand48() * 3
        }
        else{
            animation.duration = 4 + drand48() * 3
        }
        animation.path = customPathLike().cgPath
        
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        imageReactView.layer.add(animation, forKey: nil)
        self.view.addSubview(imageReactView)
        
    }
    
    @objc func switchToTime(){
        showTimer = true
        if liveButton.titleLabel?.text == "Live"{
            liveButton.setTitle("\(timerLabel)", for: .normal)
            liveButton.frame.size.width = findWidthByText("\(timerLabel)") + 3
        }
        else{
            liveButton.setTitle(NSLocalizedString("Live",  comment: ""), for: .normal)
            liveButton.frame.size.width = findWidthByText("Live") + 7
        }
        
        delay(2) {
            self.showTimer = false
        }
        
    }
    
    @objc func showViewers(){
        commentTextView.resignFirstResponder()
        if  liveUserTableView.isHidden == true {
            liveUserTableView.isHidden = false
        }
        else{
            liveUserTableView.isHidden = true
        }
        liveUserTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if discardView == true{
            //discardView = false
            dismiss(animated: false, completion: nil)
            delegate?.liveVCNeedClose(self)
        }
        
        msgCheck()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        msgCheck()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        AgoraSignal.Kit.channelLeave("\(chName)")
    }
    
    func startTimer(){
        self.updateTimer = Timer.scheduledTimer(timeInterval: 0.01, target:self, selector:  #selector(LiveViewController.updateTime), userInfo: nil, repeats: true)
        startTime = NSDate.timeIntervalSinceReferenceDate
    }
    
    @objc func updateTime() {
        
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        
        //Find the difference between current time and start time.
        
        var elapsedTime: TimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        
        let minutes = UInt8(elapsedTime / 60.0)
        
        elapsedTime -= (TimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        
        let seconds = UInt8(elapsedTime)
        
        elapsedTime -= TimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        
        //  let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        
        let strMinutes = String(format: "%02d", minutes)
        let strSeconds = String(format: "%02d", seconds)
        //let strFraction = String(format: "%02d", fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        timerLabel =  "\(strMinutes):\(strSeconds)"//:\(strFraction)"
        
        
        if liveButton.titleLabel?.text != "Live" && showTimer == true{
            liveButton.setTitle("\(timerLabel)", for: .normal)
            liveButton.isUserInteractionEnabled = false
            liveButton.frame.size.width = findWidthByText("\(timerLabel)") + 3
        }
        else{
            liveButton.isUserInteractionEnabled = true
            showTimer = false
            liveButton.setTitle(NSLocalizedString("Live",  comment: ""), for: .normal)
            liveButton.frame.size.width = findWidthByText("Live") + 7
        }
        
        if Int(minutes) == (timeLimit) {
            self.redirectToEndPage()
            
        }
        
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    func msgCheck(){
        AgoraSignal.Kit.onMessageSendError = { [weak self] (messageID, ecode) -> () in
            // self?.alert(string: "Message send failed with error: \(ecode.rawValue)")
        }
        
        
        
        AgoraSignal.Kit.onMessageChannelReceive = { [weak self] (channelID, account, uid, msg) -> () in
            DispatchQueue.main.async(execute: {
                
                let jsonText = "\(msg!)"
                
                
                if let data = jsonText.data(using: String.Encoding.utf8) {
                    
                    do {
                        self?.responseDictonary = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                        
                        if self?.isBroadcaster == false{
                            if self?.responseDictonary!["is_live_stream_dismiss"] != nil && self?.responseDictonary!["is_live_stream_dismiss"] as! Bool == true {
                                self?.view.makeToast("\(self?.responseDictonary!["endmessage"] as! String)", duration: 10, position: "center")
                                self?.liveComentTableView.isHidden = true
                                self?.liveButton.isHidden = true
                                self?.scrollemoji.isHidden = true
                                delay(10, closure: {
                                    self?.dismiss(animated: false, completion: nil)
                                })
                            }
                        }
                        
                        if self?.responseDictonary!["is_live_stream_comment"] != nil && self?.responseDictonary!["is_live_stream_comment"] as! Bool == true {
                            
                            self?.commentResponse.append((self?.responseDictonary)!)
                            
                            
                            let indexPath = IndexPath(row: (self?.commentResponse.count)! - 1, section: 0)
                            self?.liveComentTableView.reloadData()
                            
                            if (self?.liveComentTableView.contentSize.height)! > CGFloat(200) {
                                self?.liveComentTableView.frame.size.height = 200
                                self?.liveComentTableView.frame.origin.y = (UIScreen.main.bounds.height) - ((self?.scrollemoji.frame.size.height)! + iphonXBottomsafeArea + 200)
                            }
                            else{
                                self?.liveComentTableView.frame.size.height = (self?.liveComentTableView.contentSize.height)!
                                self?.liveComentTableView.frame.origin.y = (UIScreen.main.bounds.height) - ((self?.liveComentTableView.contentSize.height)! + (self?.scrollemoji.frame.size.height)! + iphonXBottomsafeArea)
                                if indexPath.row == 0 {
                                    self?.dynamicHeight[indexPath.row] = (self?.liveComentTableView.contentSize.height)!
                                    
                                    self?.liveComentTableView.reloadData()
                                }
                            }
                            
                            
                            
                            self?.liveComentTableView.reloadData()
                            DispatchQueue.main.async {
                                self?.liveComentTableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
                            }
                        }
                        
                        
                        
                        if self?.responseDictonary!["is_live_stream_viewer"] != nil && self?.responseDictonary!["is_live_stream_viewer"] as! Bool == true {
                            
                            if (!((self?.userIdList.contains(self?.responseDictonary!["user_id"] as! Int))!)) && (self?.responseDictonary!["is_viewer"] != nil && self?.responseDictonary!["is_viewer"] as! Bool == true){
                                if !((self?.tempUserIdList.contains(self?.responseDictonary!["user_id"] as! Int))!){
                                    self?.viewersResponse.append((self?.responseDictonary)!)
                                }
                                self?.userIdList.append(self?.responseDictonary!["user_id"] as! Int)
                                self?.tempUserIdList.append(self?.responseDictonary!["user_id"] as! Int)
                                
                                self?.tempViewersResponse.append((self?.responseDictonary)!)
                                self?.viewButton.setTitle(NSLocalizedString("\((self?.tempViewersResponse.count)!)",  comment: ""), for: .normal)
                                self?.viewButton.setImage(UIImage(named: "eyeliveIcon")?.maskWithColor(color: textColorLight), for: .normal)
                                //  self?.viewButton.setTitle("\(eyeIcon) \((self?.tempViewersResponse.count)!)", for: .normal)
                                self?.liveUserTableView.reloadData()
                            }
                            
                            
                            if self?.responseDictonary!["is_viewer"] != nil && self?.responseDictonary!["is_viewer"] as! Bool == false {
                                outerLoop:    for (b , a) in ((self?.tempViewersResponse)?.enumerated())!
                                {
                                    
                                    for (key, value) in (a as! NSDictionary)
                                    {
                                        if key as! String == "user_id" && value as! Int == (self?.responseDictonary!["user_id"] as! Int)
                                        {
                                            self?.userIdList.remove(at: b)
                                            self?.tempViewersResponse.remove(at: b)
                                            self?.viewButton.setTitle(NSLocalizedString("\((self?.tempViewersResponse.count)!)",  comment: ""), for: .normal)
                                            self?.viewButton.setImage(UIImage(named: "eyeliveIcon")?.maskWithColor(color: textColorLight), for: .normal)
                                            //  self?.viewButton.setTitle("\(eyeIcon) \((self?.tempViewersResponse.count)!)", for: .normal)
                                            self?.liveUserTableView.reloadData()
                                            if self?.tempViewersResponse.count == 1 {
                                                break outerLoop
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                            
                            
                        }
                        
                        
                        
                        if self?.responseDictonary!["is_live_stream_reaction"] != nil && self?.responseDictonary!["is_live_stream_reaction"] as! Bool == true {
                            if let myDictionary = self?.responseDictonary
                            {
                                if myDictionary["reaction_icon"] != nil {
                                    self?.getLikeReaction(urlValue: "\(String(describing: myDictionary["reaction_icon"]!))")
                                }
                            }
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
                
                
            })
            
        }
        
        AgoraSignal.Kit.onChannelQueryUserNumResult = { [weak self] (channelID, ecode, num) -> () in
            // self?.userNum = Int(num)
            let userChannel : Int = Int(num)//(self?.userNum)!
        }
        
        AgoraSignal.Kit.onChannelUserJoined = { [weak self] (account, uid) -> () in
            DispatchQueue.main.async(execute: {
                self?.userNum += 1
                DispatchQueue.main.async {
                    if (self?.isBroadcaster)!{
                        print("Nice 1")
                    }
                    else{
                        //                    let userSession = self?.videoSession(ofUid: Int64(uid))
                        //                    self?.rtcEngine.setupRemoteVideo((userSession?.canvas)!)
                    }
                    
                }
                
                self?.liveUserTableView.reloadData()
                
            })
        }
        
        AgoraSignal.Kit.onChannelUserLeaved = { [weak self] (account, uid) -> () in
            DispatchQueue.main.async(execute: {
                // self?.userNum -= 1
                
                
            })
        }
    }
    
    func addAgoraSignalBlock() {
        
        AgoraSignal.Kit.onChannelJoined = { (channelID) -> () in
            // DispatchQueue.main.async(execute: {
            self.msgCheck()
            if self.isBroadcaster == false {
                var viewerObject = [String:AnyObject]()
                viewerObject.updateValue("\(displayName!)" as AnyObject, forKey: "displayname")
                viewerObject.updateValue("\(coverImage!)" as AnyObject, forKey: "image_profile")
                viewerObject.updateValue(currentUserId as AnyObject, forKey: "user_id")
                viewerObject.updateValue(true as AnyObject, forKey: "is_viewer")
                viewerObject.updateValue(true as AnyObject, forKey: "is_live_stream_viewer")
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: viewerObject, options:  [])
                    let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                    
                    
                    let diceRoll = arc4random()
                    AgoraSignal.Kit.messageChannelSend("\(self.chName)", msg: "\(finalString)", msgID: String(diceRoll))
                }
                catch _ {
                    // failure
                }
                
                
            }
            
            
        }
        
        AgoraSignal.Kit.onChannelJoinFailed = { (channelID, ecode) -> () in
            // self.alert(string: "Join channel failed with error: \(ecode.rawValue)")
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
    
    func liveAppClose(){
        setIdleTimerActive(true)
        
        rtcEngine.setupLocalVideo(nil)
        rtcEngine.leaveChannel(nil)
        if isBroadcaster {
            rtcEngine.stopPreview()
            
        }
        
        for session in videoSessions {
            session.hostingView.removeFromSuperview()
        }
        videoSessions.removeAll()
        dismiss(animated: false, completion: nil)
        delegate?.liveVCNeedClose(self)
        
    }
    
    func redirectToEndPage(){
        setIdleTimerActive(true)
        self.updateTimer.invalidate()
        rtcEngine.setupLocalVideo(nil)
        rtcEngine.leaveChannel(nil)
        if isBroadcaster {
            rtcEngine.stopPreview()
        }
        self.stopServerCalling()
        self.stopApiCalling()
        
        var dismissObject = [String:AnyObject]()
        dismissObject.updateValue(NSLocalizedString("Live Streaming has Ended",  comment: "") as AnyObject, forKey: "endmessage")
        dismissObject.updateValue(true as AnyObject, forKey: "is_live_stream_dismiss")
        
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dismissObject, options:  [])
            let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            
            
            let diceRoll = arc4random()
            AgoraSignal.Kit.messageChannelSend("\(self.chName)", msg: "\(finalString)", msgID: String(diceRoll))
        }
        catch _ {
            // failure
        }
        
        for session in videoSessions {
            session.hostingView.removeFromSuperview()
        }
        videoSessions.removeAll()
        
        let pv = LiveEndViewController()
        pv.viewerCount = self.viewersResponse.count
        pv.streamName = chName
        pv.modalPresentationStyle = .fullScreen
        self.present(pv, animated: false, completion: nil)
        // delegate?.liveVCNeedClose(self)
    }
    
    func stopServerCalling(){
        
        
        var dic = [String : String]()
        let url1 = "stop"
        
        let method1 = "POST"
        dic["sid"] = "\(sidValue)"
        
        AgoraPost(dic , url: "\(url1)", method: method1) { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if msg{
                    
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
    
    func stopApiCalling(){
        
        
        var dic = [String : String]()
        let url1 = "livestreamingvideo/stop-video-streaming"
        
        
        let method1 = "POST"
        dic["stream_name"] = "\(chName)"
        dic["endType"] = "normal"
        
        post(dic , url: "\(url1)", method: method1) { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if msg{
                    
                    
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
    
    @objc func cross(){
        setIdleTimerActive(true)
        
        rtcEngine.setupLocalVideo(nil)
        rtcEngine.leaveChannel(nil)
        if isBroadcaster {
            rtcEngine.stopPreview()
        }
        
        for session in videoSessions {
            session.hostingView.removeFromSuperview()
        }
        
        if self.isBroadcaster == false {
            var viewerObject = [String:AnyObject]()
            viewerObject.updateValue("\(displayName!)" as AnyObject, forKey: "displayname")
            viewerObject.updateValue("\(coverImage!)" as AnyObject, forKey: "image_profile")
            viewerObject.updateValue(currentUserId as AnyObject, forKey: "user_id")
            viewerObject.updateValue(false as AnyObject, forKey: "is_viewer")
            viewerObject.updateValue(true as AnyObject, forKey: "is_live_stream_viewer")
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: viewerObject, options:  [])
                let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                
                let diceRoll = arc4random()
                AgoraSignal.Kit.messageChannelSend("\(self.chName)", msg: "\(finalString)", msgID: String(diceRoll))
            }
            catch _ {
                // failure
            }
            
            
        }
        
        videoSessions.removeAll()
        dismiss(animated: true, completion: nil)
        delegate?.liveVCNeedClose(self)
        // updateTimer.invalidate()
    }
    
    @objc func doSwitchCameraPressed() {
        rtcEngine?.switchCamera()
        
    }
    
    func loadAgoraKit(){
        rtcEngine = AgoraRtcEngineKit.sharedEngine(withAppId: "\(AgoraId)", delegate: self as? AgoraRtcEngineDelegate)
        rtcEngine.setChannelProfile(.liveBroadcasting)
        rtcEngine.enableDualStreamMode(true)
        rtcEngine.enableVideo()
        rtcEngine.setVideoEncoderConfiguration(AgoraVideoEncoderConfiguration(size: AgoraVideoDimension640x360,
                                                                              frameRate: .fps15,
                                                                              bitrate: AgoraVideoBitrateStandard,
                                                                              orientationMode: .adaptative))
        rtcEngine.setClientRole(clientRole)
        //updateInterface(withAnimation :true)
        
        if isBroadcaster {
            rtcEngine.startPreview()
        }
        
        addLocalSession()
        
        if  (UIDevice.current.userInterfaceIdiom == .pad){
            commentTextView = createTextView(CGRect(x:5,y:view.bounds.height-360 , width:view.bounds.width-50, height:40), borderColor: borderColorMedium, corner: false )
        }
        else{
            commentTextView = createTextView(CGRect(x:5,y:view.bounds.height-260 , width:view.bounds.width-50, height:40), borderColor: borderColorMedium, corner: false )
        }
        self.view.addSubview(commentTextView)
        commentTextView.isHidden = true
        
        if  (UIDevice.current.userInterfaceIdiom == .pad){
            commentPost = createButton(CGRect(x:view.bounds.width-45,y:view.bounds.height-365 , width:40, height:40), title: NSLocalizedString("",  comment: ""), border: false,bgColor: true, textColor: buttonColor )
        }
        else{
            commentPost = createButton(CGRect(x:view.bounds.width-45,y:view.bounds.height-260 , width:50, height:40), title: NSLocalizedString("",  comment: ""), border: false,bgColor: true, textColor: UIColor.clear)
        }
        commentPost.setImage(UIImage(named : "sendIcon")?.maskWithColor(color: buttonColor), for: .normal)
        commentPost.contentMode = .scaleAspectFit
        commentPost.layer.masksToBounds = true
        commentPost.titleLabel?.font = UIFont(name: fontNormal, size: FONTSIZELarge)
        self.view.addSubview(commentPost)
        commentPost.isEnabled = false
        commentPost.isHidden = true
        
        let code = rtcEngine.joinChannel(byToken: nil, channelId: "\(chName)", info: nil, uid: UInt(currentUserId), joinSuccess: nil)
        print("channel join id=== \(currentUserId)")
        if code == 0 {
            setIdleTimerActive(false)
            rtcEngine.setEnableSpeakerphone(true)
            
            if isBroadcaster == true {
                showToast(message: NSLocalizedString("Checking Connection...",  comment: ""), controller: self)
                startBroadCast()
            }
            else{
                showToast(message: NSLocalizedString(NSLocalizedString("Connecting...",  comment: ""),  comment: ""), controller: self)
                DispatchQueue.main.async {
                    self.liveButton.backgroundColor = buttonColor
                    self.liveButton.setTitle(NSLocalizedString("Live",  comment: ""), for: .normal)
                    self.liveButton.frame.size.width = findWidthByText("Live") + 7
                    self.liveButton.isUserInteractionEnabled = false
                    
                    self.findAllComments()
                }
            }
            
            
        } else {
             showToast(message: NSLocalizedString("Join channel failed",  comment: ""), controller: self)
            // self.alert(string: "Join channel failed: \(code)")
        }
        
    }
    
    func startBroadCast(){
        
        let url1 = "livestreamingvideo/start-video-streaming/"
        activityIndicatorView.center = view.center
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        var dic = [String : String]()
        
        let method1 = "POST"
        dic["stream_name"] = "\(chName)"
        dic["description"] = "\(descriptionText)"
        scrollemoji.isUserInteractionEnabled = false
        
        dic["auth_view"] = "\(privacyAuthView)"
        
        post(dic , url: "\(url1)", method: method1) { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                // spinner.stopAnimating()
                
                if msg{
                    activityIndicatorView.stopAnimating()
                    showToast(message: NSLocalizedString("You are now live!",  comment: ""), controller: self)
                    
                    self.liveButton.backgroundColor = buttonColor
                    self.liveButton.setTitle(NSLocalizedString("Live",  comment: ""), for: .normal)
                    self.liveButton.frame.size.width = findWidthByText("Live") + 7
                    self.viewButton.setTitle(NSLocalizedString("0",  comment: ""), for: .normal)
                    self.dismissButton.setTitle(NSLocalizedString("End",  comment: ""), for: .normal)
                    self.dismissButton.addTarget(self, action: #selector(LiveViewController.showAlertDialog), for: .touchUpInside)
                    self.viewButton.setImage(UIImage(named: "eyeliveIcon")?.maskWithColor(color: textColorLight), for: .normal)
                    // self.viewButton.setTitle("\(eyeIcon) 0", for: .normal)
                    self.startTimer()
                    self.startServerApiCalling()
                    self.NotifyCalling()
                    
                    
                    if let body = succeeded["body"] as? NSDictionary{
                        self.videoId = body["video_id"] as! Int
                        self.videoType = body["subject_type"] as! String
                        self.scrollemoji.isUserInteractionEnabled = true
                        
                    }
                }
                    
                else{
                    // Handle Server Side Error
                    if succeeded["message"] != nil{
                        self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom", title: "", image: nil, style: nil, completion: { (_) in
                            self.dismiss(animated: true, completion: nil)
                        })
                        
                    }
                }
            })
        }
        
    }
    
    func startServerApiCalling(){
        
        var dic = [String : String]()
        let url1 = "start"
        
        let method1 = "POST"
        dic["appid"] = "\(AgoraId)"
        dic["channel"] = "\(chName)"
        
        //       var dic1 = [String : String]()
        
        //        if(logoutUser == false){
        //            dic1["oauth_token"] = oauth_token
        //            dic1["oauth_secret"] = oauth_secret
        //        }
        //        dic1["oauth_consumer_secret"] = "\(oauth_consumer_secret)"
        //        dic1["oauth_consumer_key"] = "\(oauth_consumer_key)"
        //
        //        if ios_version != nil && ios_version != "" {
        //            dic1["_IOS_VERSION"] = ios_version
        //        }
        //
        //        let url2 = "livestreamingvideo/stop-video-streaming"
        //
        //
        //
        //        dic1["stream_name"] = "\(chName)"
        //        dic1["endType"] = "normal"
        //        let abc : String =  baseUrl+url2+buildQueryString(fromDictionary:dic1)
        //        print("nice caliing === \(abc)")
        //        dic["actionUrl"] = "\(abc)"
        
        AgoraPost(dic , url: "\(url1)", method: method1) { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                self.remoteContainerView.isUserInteractionEnabled = true
                
                
                if msg{
                    //                    activityIndicatorView.stopAnimating()
                    //                    self.view.makeToast(NSLocalizedString("You are now live!",  comment: ""), duration: 3, position: "bottom")
                    //                    self.startTimer()
                    //                    self.liveButton.backgroundColor = buttonColor
                    //                    self.liveButton.setTitle(NSLocalizedString("Live",  comment: ""), for: .normal)
                    //                    self.liveButton.frame.size.width = findWidthByText("Live") + 7
                    //                    self.viewButton.setTitle(NSLocalizedString("0",  comment: ""), for: .normal)
                    //                    self.dismissButton.setTitle(NSLocalizedString("End",  comment: ""), for: .normal)
                    //                    self.dismissButton.addTarget(self, action: #selector(LiveViewController.showAlertDialog), for: .touchUpInside)
                    //                    self.viewButton.setImage(UIImage(named: "eyeliveIcon")?.maskWithColor(color: textColorLight), for: .normal)
                    //                    // self.viewButton.setTitle("\(eyeIcon) 0", for: .normal)
                    //                    self.NotifyCalling()
                    delay(3, closure: {
                        
                        showToast(message: String(format: NSLocalizedString("You can Go Live for %@ minutes", comment: ""),"\(timeLimit)"), controller: self)
                        
                    })
                    //  self.checkLiveTimeSetting()
                }
                    
                else{
                    activityIndicatorView.stopAnimating()
                    // Handle Server Side Error
                    if succeeded["message"] != nil{
                        showToast(message: succeeded["message"] as! String, controller: self)
                    }
                }
            })
        }
        
        
    }
    
    func NotifyCalling(){
        let url1 = "livestreamingvideo/process-notification/"
        
        let dic = [String : String]()
        
        let method1 = "POST"
        
        post(dic , url: "\(url1)", method: method1) { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                
                if msg{
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
    
    @objc func showAlertDialog() {
        // Declare Alert
        let dialogMessage = UIAlertController(title: NSLocalizedString("End Live Stream",  comment: ""), message: NSLocalizedString("Are you sure that you want to end the live streaming?",  comment: ""), preferredStyle: .alert)
        
        // Create OK button with action handler
        let ok = UIAlertAction(title: NSLocalizedString("End Live Streaming",  comment: ""), style: .default, handler: { (action) -> Void in
            self.redirectToEndPage()
        })
        
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel",  comment: ""), style: .cancel) { (action) -> Void in
        }
        
        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    @objc func clickComment(){
        if isBroadcaster == true {
            liveUserTableView.isHidden = true
        }
        commentTextView.isHidden = false
        commentTextView.layer.cornerRadius = 5.0
        commentTextView.delegate = self
        commentTextView.font = UIFont(name: fontName, size: FONTSIZELarge )
        commentTextView.textColor = textColorDark
        commentTextView.autocorrectionType = UITextAutocorrectionType.no
        // commentTextView.returnKeyType = UIReturnKeyType.done
        commentTextView.becomeFirstResponder()
        
        view.addSubview(commentTextView)
        
        if #available(iOS 9.0, *) {
            let item : UITextInputAssistantItem = commentTextView.inputAssistantItem
            item.leadingBarButtonGroups = []
            item.trailingBarButtonGroups = []
        } else {
            // Fallback on earlier versions
        }
        
        commentPost.isHidden = false
        commentPost.backgroundColor = UIColor.clear
        commentPost.isEnabled = false
        commentPost.addTarget(self, action: #selector(LiveViewController.postComment), for: .touchUpInside)
        view.addSubview(commentPost)
        
    }
    
    
    
    @objc func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyBoardHeight1 = keyboardFrame.size.height
        dismissButton.isHidden = false
        scrollUperemoji.isHidden = false
        if isBroadcaster == true {
            viewButton.isHidden = false
        }
        liveButton.isHidden = false
        scrollemoji.isHidden = false
        liveComentTableView.isHidden = false
        commentTextView.isHidden = false
        commentPost.isHidden = false
        DispatchQueue.main.async {
            if self.commentTextView.text == "" {
                self.commentPost.isEnabled = false
            }
            else{
                self.commentPost.isEnabled = true
            }
        }
        commentPost.frame.origin.y = view.bounds.height - (keyBoardHeight1 + iphonXBottomsafeArea + ButtonHeight + 7)
        commentTextView.frame.origin.y = view.bounds.height - (keyBoardHeight1 + iphonXBottomsafeArea + ButtonHeight + 5)
        
    }
    
    @objc func keyboardWillHide(sender: NSNotification)
    {
        dismissButton.isHidden = true
        commentTextView.isHidden = true
        commentPost.isHidden = true
        viewButton.isHidden = true
        liveButton.isHidden = true
        scrollemoji.isHidden = true
        liveComentTableView.isHidden = true
        scrollUperemoji.isHidden = true
        
        
    }
    
    @objc func postComment(){
        
        commentTextView.resignFirstResponder()
        let tempComment = commentTextView.text
        self.commentTextView.text = ""
        dismissButton.isHidden = false
        scrollUperemoji.isHidden = false
        if isBroadcaster == true {
            viewButton.isHidden = false
        }
        liveButton.isHidden = false
        scrollemoji.isHidden = false
        liveComentTableView.isHidden = false
        var commentObject = [String:AnyObject]()
        commentObject.updateValue("\(displayName!)" as AnyObject, forKey: "displayname")
        commentObject.updateValue("\(coverImage!)" as AnyObject, forKey: "image_profile")
        commentObject.updateValue(tempComment as AnyObject, forKey: "comment_body")
        commentObject.updateValue(currentUserId as AnyObject, forKey: "user_id")
        commentObject.updateValue(true as AnyObject, forKey: "is_live_stream_comment")
        
        do {
            
            
            let jsonData = try JSONSerialization.data(withJSONObject: commentObject, options:  [])
            let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
            
            let diceRoll = arc4random()
            AgoraSignal.Kit.messageChannelSend("\(chName)", msg: "\(finalString)", msgID: String(diceRoll))
        }
        catch _ {
            // failure
        }
        
        if reachability.connection != .none {
            var url:String!
            if enabledModules.contains("nestedcomment")
            {
                url = "advancedcomments/comment"//"comment-create"
            }
            else
            {
                url = "comment-create"
            }
            let parameters = ["subject_id":String(videoId), "subject_type": videoType,"body":tempComment,"send_notification":"0"] as [String : Any]
            // Send Server Request for Post Comment
            post(parameters as! Dictionary<String, String>, url: url, method: "POST") { (succeeded, msg) -> () in
                
                // Stop Spinner
                DispatchQueue.main.async(execute: {
                    
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            
                            self.commentTextView.text = ""
                            
                        }
                        
                    }else{
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
    
    func setIdleTimerActive(_ active: Bool) {
        UIApplication.shared.isIdleTimerDisabled = !active
    }
    
    // TableView Implementation
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView.tag == 101 {
            return 55
        }
        
        if dynamicHeight[indexPath.row] != nil{
            return dynamicHeight[indexPath.row]!
        }
        return 60.0
        
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        if tableView.tag == 101 {
            return 55
        }
        if dynamicHeight[indexPath.row] != nil{
            return dynamicHeight[indexPath.row]!
        }
        
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView.tag == 101 && tempViewersResponse.count > 0 {
            
            let frame = tableView.frame
            
            let button = UIButton(frame: CGRect(x: frame.size.width/2 - 15, y: 10, width: 30, height: 30))  // create button
            button.setImage(UIImage(named: "crossBlack"), for: UIControl.State.normal)
            button.addTarget(self, action: #selector(LiveViewController.showViewers), for: .touchUpInside)  // add selector called by clicking on the button
            
            let headerView = UIView(frame: CGRect(x:0, y:0, width:frame.size.width, height:50))  // create custom view
            headerView.addSubview(button)   // add the button to the view
            
            return headerView
        }
        let headerView1 = UIView(frame: CGRect(x:0, y:0, width:0, height:0))  // create custom view
        // add the button to the view
        return headerView1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 101 {
            return tempViewersResponse.count
        }
        return commentResponse.count
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 101 {
            return 55
        }
        return 0.001
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 101{
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        
        if tableView.tag == 101
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "liveUserCell", for: indexPath) as! LiveUserTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = textColorLight
            cell.lineView.isHidden = false
            let viewers = tempViewersResponse[(indexPath as NSIndexPath).row] as! NSDictionary
            if viewers["displayname"] != nil {
                cell.viewerTitle.text = (viewers["displayname"] as! String)
            }
            let url = URL(string: "\(viewers["image_profile"] as! String)")
            if url != nil{
                cell.viewerImage.kf.setImage(with: url as URL?, placeholder: UIImage(named: "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                    
                })
            }
            cell.viewerImage.layer.cornerRadius = 20
            cell.viewerImage.layer.masksToBounds = true
            return cell
            
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "liveCommentCell", for: indexPath) as! LiveCommentTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = UIColor.clear
        
        let comment = commentResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        cell.liveBody.delegate = self
        if comment["displayname"] != nil {
            cell.liveUserTitle.text = (comment["displayname"] as! String)
        }
        else{
            cell.liveUserTitle.text = (comment["author_title"] as! String)
        }
        let strValue = comment["comment_body"] as! String
        // Set Feed Tittle & Description Link
        cell.liveBody.setText("\(strValue) ", afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
            
            // TODO: Clean this up..
            return mutableAttributedString
        })
        
        cell.liveBody.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.liveBody.numberOfLines = 0
        cell.liveBody.sizeToFit()
        cell.liveBody.frame.size.width = view.bounds.width-(cell.liveUserImage.bounds.width+15)
        if comment["image_profile"] != nil {
            let url = URL(string: "\(comment["image_profile"] as! String)")
            if url != nil{
                cell.liveUserImage.kf.setImage(with: url as URL?, placeholder: UIImage(named: "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                    
                })
            }
        }
        else{
            let url = URL(string: "\(comment["author_image_icon"] as! String)")
            if url != nil{
                cell.liveUserImage.kf.setImage(with: url as URL?, placeholder: UIImage(named: "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                    
                })
            }
        }
        
        cell.liveUserImage.layer.cornerRadius = 20
        cell.liveUserImage.layer.masksToBounds = true
        dynamicHeight[indexPath.row] = cell.liveBody.frame.origin.y + cell.liveBody.bounds.height + 10
        
        if cell.liveBody.frame.origin.y + cell.liveBody.bounds.height + 10 < 60 {
            dynamicHeight[indexPath.row] = 60.0
        }
        
        
        return cell
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



extension LiveViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
//        let userSession = videoSession(ofUid: Int64(uid))
//        rtcEngine.setupRemoteVideo(userSession.canvas)
        print("check audiance streaming=====")
        let userSession = videoSession(ofUid: Int64(uid))
        rtcEngine.setupRemoteVideo(userSession.canvas)
        msgCheck()
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoDecodedOfUid uid: UInt, size: CGSize, elapsed: Int) {
//        let userSession = videoSession(ofUid: Int64(uid))
//        rtcEngine.setupRemoteVideo(userSession.canvas)
        print("check audiance streaming2=====")
        msgCheck()
    }
//
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("check2")
    }
//
//    func rtcEngine(_ engine: AgoraRtcEngineKit, firstRemoteVideoFrameOfUid uid: UInt, size: CGSize, elapsed: Int) {
//        let userSession = videoSession(ofUid: Int64(uid))
//        rtcEngine.setupRemoteVideo(userSession.canvas)
//        print("check audiance streaming1=====")
//       // msgCheck()
//    }
//
    func rtcEngine(_ engine: AgoraRtcEngineKit, firstLocalVideoFrameWith size: CGSize, elapsed: Int) {
        if let _ = videoSessions.first {
            updateInterface(withAnimation: false)
        }
    }
    
    
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        var indexToDelete: Int?
        for (index, session) in videoSessions.enumerated() {
            if session.uid == Int64(uid) {
                indexToDelete = index
            }
        }
        
        if let indexToDelete = indexToDelete {
            let deletedSession = videoSessions.remove(at: indexToDelete)
            deletedSession.hostingView.removeFromSuperview()
            
            if deletedSession == fullSession {
                fullSession = nil
            }
        }
    }
}

extension UIButton {
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 1.0
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
}

func customPathLike() -> UIBezierPath{
    let path = UIBezierPath()
    if  (UIDevice.current.userInterfaceIdiom == .pad){
        path.move(to: CGPoint(x: UIScreen.main.bounds.width , y: 500))
        let endPoint = CGPoint(x: -20, y: 450)
        let rshift = 100 + drand48() * 150
        let cp1 = CGPoint(x: 500, y: 500 - rshift)
        let cp2 = CGPoint(x: 250, y: 400 + rshift)
        path.addCurve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
        
    }
    else{
        path.move(to: CGPoint(x: UIScreen.main.bounds.width , y: 300))
        
        let endPoint = CGPoint(x: -50, y: 250)
        let rshift = 100 + drand48() * 150
        let cp1 = CGPoint(x: 75, y: 300 - rshift)
        let cp2 = CGPoint(x: 150, y: 200 + rshift)
        path.addCurve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
        path.addClip()
    }
    return path
    
}

func customPathWow() -> UIBezierPath{
    let path = UIBezierPath()
    if  (UIDevice.current.userInterfaceIdiom == .pad){
        path.move(to: CGPoint(x: UIScreen.main.bounds.width , y: 500))
        let endPoint = CGPoint(x: -20, y: 450)
        let rshift = 100 + drand48() * 150
        let cp1 = CGPoint(x: 500, y: 500 - rshift)
        let cp2 = CGPoint(x: 300, y: 400 + rshift)
        path.addCurve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
        
    }
    else{
        path.move(to: CGPoint(x: UIScreen.main.bounds.width , y: 300))
        
        let endPoint = CGPoint(x: -50, y: 250)
        let rshift = 100 + drand48() * 150
        let cp1 = CGPoint(x: 75, y: 300 - rshift)
        let cp2 = CGPoint(x: 150, y: 200 + rshift)
        path.addCurve(to: endPoint, controlPoint1: cp1, controlPoint2: cp2)
    }
    return path
    
}

class CurvedView : UIView{
    
    override func draw(_ rect: CGRect) {
        let path = customPathLike()
        let path1 = customPathWow()
        path.stroke()
        path1.stroke()
        
        
    }
}


