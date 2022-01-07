//
//  PlaylistProfileViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 18/06/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer
import WebKit

var playlistProfileUpdate:Bool!
var headerViewHeight = CGRect()

class PlaylistProfileViewController: UIViewController,TTTAttributedLabelDelegate,WKNavigationDelegate {

    var playlistId :String!
    var popAfterDelay:Bool!
    var subjectId:String!
    var subjectType:String!
    var videoType :Int!
    var isplaylist:Bool = true
    
    var headerView : UIView!
    var headerImageView : UIImageView!
    var headerTitle : TTTAttributedLabel!
    var topView : UIView!
    var imgUser : UIImageView!
    var ownerName : UILabel!
    var rightBarButtonItem : UIBarButtonItem!
    var playbutton : UIButton!
    
    var moviePlayer:MPMoviePlayerController!
    var videoWebView = WKWebView()
    var imageView : UIImageView!
    var gutterMenu: NSArray = []
    var shareUrl : String!
    var shareParam : NSDictionary!
    var shareTitle : String!
    var sharable: Bool = false
    var playlistName:String!
    var ownerTitle:String!
    var profileImageUrlString : String!
    var coverImageUrl : String!
    var contentDescription : String!
    var user_id : Int!
    var playlistvideos = [AnyObject]()
    var deletePlaylist: Bool = false
    var videoListObj = videoListTableViewController()
    var playlist_id : Int = 0
    var isplayerOrwebview : Bool = false
    var playlist_url : String = ""
    let player = AVPlayerViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = UIColor.black//bgColor
        videosUpdate = false
        playlistProfileUpdate = true
        popAfterDelay = false
        subjectType = "video"
        subjectId = playlistId
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlaylistProfileViewController.didselctplaylist(_:)), name: NSNotification.Name(rawValue: "didselctplaylist"), object: nil)
        navigationButtons()
        removeNavigationImage(controller: self)
        
        
        headerView = UIView(frame : CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 220))
        self.view.addSubview(headerView)
        
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 220)
        headerImageView = CoverImageViewWithGradient(frame: frame)
        headerImageView.backgroundColor = placeholderColor
        headerImageView.isUserInteractionEnabled = true
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(PlaylistProfileViewController.onImageViewTap))
        headerImageView.addGestureRecognizer(tap1)
        headerView.addSubview(headerImageView)
        headerTitle = TTTAttributedLabel(frame:CGRect(x: 10, y: 160, width: view.bounds.width - 50 , height: 60))
        headerTitle.font = UIFont(name: fontName, size: 30.0)
        //headerTitle.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        headerTitle.longPressLabel()
        headerTitle.numberOfLines = 0
        headerTitle.delegate = self
        headerImageView.addSubview(headerTitle)
        
        
        topView = createView(CGRect(x: 0, y: headerImageView.bounds.height, width: view.bounds.width, height: 60), borderColor: UIColor.clear, shadow: false)
        topView.backgroundColor = lightBgColor
        self.view.addSubview(topView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PlaylistProfileViewController.openProfile))
        topView.addGestureRecognizer(tap)
        ownerName = createLabel(CGRect(x: 65, y: 15, width: view.bounds.width, height: 30), text: "", alignment: .left, textColor: textColorDark)
        ownerName.font = UIFont(name: fontName, size: FONTSIZEMedium)
        ownerName.longPressLabel()
        topView.addSubview(ownerName)
        
        imgUser = createImageView(CGRect(x: 10, y: 10, width: 40, height: 40), border: true)
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.clear.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.image = UIImage(named: "user_profile_image.png")
        imgUser.clipsToBounds = true
        topView.addSubview(imgUser)
        
        setupPlayer()
        setupAvPlayer()
        playbutton = createButton(CGRect(x: headerImageView.frame.size.width - 70, y: headerImageView.frame.size.height - 16, width: 50, height: 50),title: playIcon, border: false, bgColor: false, textColor: textColorLight)
        playbutton.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
        playbutton.layer.masksToBounds = false
        playbutton.layer.borderColor = UIColor.clear.cgColor
        playbutton.layer.cornerRadius = playbutton.frame.height/2
        playbutton.backgroundColor = navColor
        playbutton.clipsToBounds = true
        self.view.addSubview(playbutton)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(PlaylistProfileViewController.play))
        playbutton.addGestureRecognizer(tap2)
        
        
        tableframeY = topView.frame.size.height + topView.frame.origin.y
        self.view.addSubview(videoListObj.view)
        self.addChild(videoListObj)
        videoListObj.iscomingFrom = "AdvPlaylist"
        videoListObj.isplaylist = isplaylist
        //headerViewHeight = topView.frame.origin.y + topView.frame.size.height + 10
   
        browsePlaylist()
        // Do any additional setup after loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
    
        removeNavigationImage(controller: self)
    }
    @objc func onImageViewTap(){
        if self.profileImageUrlString != nil && self.profileImageUrlString != "" {
            let presentedVC = SinglePhotoLightBoxController()
            presentedVC.imageUrl = self.coverImageUrl
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            present(nativationController, animated:false, completion: nil)
        }
    }
    @objc func openProfile(){
        if (self.user_id != nil){
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(user_id)"
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    func setupPlayer() {
        
        var playerHeight: CGFloat = 400
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            playerHeight = 220
        }
        
        videoWebView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height )
        
        
        let configuration = WKWebViewConfiguration()
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []
        }
        configuration.allowsInlineMediaPlayback = true
        videoWebView = WKWebView(frame: videoWebView.frame, configuration: configuration)
        //videoWebView.center = viewSubview.convert(viewSubview.center, from:viewSubview.superview)
        videoWebView.isOpaque = false
        //WKAudiovisualMediaTypeNone = 0
        videoWebView.backgroundColor = UIColor.black
        videoWebView.scrollView.bounces = false
        videoWebView.allowsLinkPreview = false
        videoWebView.navigationDelegate = self
        let jeremyGif = UIImage.gifWithName("progress bar")
        
        // Use the UIImage in your UIImageView
        imageView = UIImageView(image: jeremyGif)
        imageView.frame = CGRect(x: 105,y: 140 ,width: 120, height: 7)
        //view.addSubview(imageView)
        self.view.addSubview(videoWebView)
        videoWebView.addSubview(imageView)
        videoWebView.isHidden = true
        

    }
    func setupAvPlayer()
    {
        var playerHeight: CGFloat = 400
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            playerHeight = 220
        }
        player.view.frame = CGRect(x: 0, y: 64, width: view.bounds.width, height: playerHeight - 64)
        player.view.backgroundColor = UIColor.black
        player.view.sizeToFit()
        player.showsPlaybackControls = true
        self.view.addSubview(player.view)
        player.view.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(PlaylistProfileViewController.stopedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
    }
    @objc func stopedPlaying()
    {
        if playlist_id < playlistvideos.count-1
        {
          playlist_id = playlist_id + 1
        }
        else
        {
           playlist_id = 0
        }
       getVideoUrl()

    }
    @objc func play()
    {
        if self.playlistvideos.count > 0 {
            getVideoUrl()
        }
        
    }
    func getVideoUrl()
    {
        if playlistvideos.count > 0
        {
            let videosInfo = playlistvideos[playlist_id] as! NSDictionary
            let videoType  = videosInfo["type"] as! Int
            playlist_url = videosInfo["video_url"] as! String
            //print(playlist_url)
            if videoType != 3
            {
                var url = ""
                isplayerOrwebview = false
                videoWebView.isHidden = false
                headerView.isHidden = true
                player.view.isHidden = true
                if videoType == 1 || videoType == 2 || videoType == 4 || videoType == 5{
                    
                    url = "https://" + playlist_url
                }
                else
                {
                    url = playlist_url
                }
                
                if let videoURL =  URL(string:url)
                {
                    videoWebView.load(URLRequest(url: videoURL))
                    
                }
                else
                {
                    if videoType == 6
                    {
                        videoWebView.loadHTMLString(playlist_url, baseURL: nil)
                    }
                }
            }
            else
            {
                isplayerOrwebview = true
                videoWebView.isHidden = true
                headerView.isHidden = true
                player.view.isHidden = false
                let videoURL = URL(string: playlist_url)
                let avplayer = AVPlayer(url: videoURL!)
                player.player = avplayer
                player.player?.play()
                
            }
        }
    }
    
    @objc func didselctplaylist(_ notification: Foundation.Notification)
    {
        playlist_id = selectIndex
        getVideoUrl()
    }
    @objc func browsePlaylist()
    {
        
        if Reachabable.isConnectedToNetwork() {
            for ob in self.view.subviews
            {
                if ob.tag == 1000
                {
                    ob.removeFromSuperview()
                    
                }
            }
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            // Send Server Request to Explore Video Contents with Video_ID
            var url = ""
            let parameterCheck : NSDictionary = [ : ]
            url = "advancedvideo/playlist/view/\(playlistId!)"
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(parameterCheck as! Dictionary<String, String>, url: url, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        self.playlistvideos.removeAll(keepingCapacity: false)
                        if let playlist = succeeded["body"] as? NSDictionary {
                            // Update Video Gutter Menu
                            if let menu = playlist["gutterMenu"] as? NSArray{
                                self.gutterMenu = menu
                                 var isCancel = false
                                for tempMenu in self.gutterMenu{
                                    if let tempDic = tempMenu as? NSDictionary{
                                        
                                        if tempDic["name"] as! String == "share" {
                                            self.sharable = true
                                            self.shareUrl = tempDic["url"] as! String
                                            self.shareParam = tempDic["urlParams"] as! NSDictionary
                                        }
                                        else
                                        {
                                            isCancel = true
                                        }
                                    }
                                }
                                if logoutUser == false{
                                    
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    shareButton.addTarget(self, action: #selector(PlaylistProfileViewController.shareItem), for: .touchUpInside)
                                    rightNavView.addSubview(shareButton)
                                    
                                    let optionButton = createButton(CGRect(x: 44,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    optionButton.addTarget(self, action: #selector(PlaylistProfileViewController.showGutterMenu), for: .touchUpInside)
                                  //  rightNavView.addSubview(optionButton)
                                    if isCancel == false
                                    {
                                        shareButton.frame.origin.x = 44
                                    }
                                    else
                                    {
                                        rightNavView.addSubview(optionButton)
                                    }
                                    self.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
                                    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                                    
                                }
                            }
                            if let response = playlist["response"] as? NSDictionary
                            {
                                self.playlistName = response["title"] as! String
                                self.headerTitle.textColor = textColorLight
                                
                                if self.playlistName.length > 18{
                                    self.headerTitle.frame.origin.y   = 120
                                }
                                if self.playlistName.length > 45{
                                    self.headerTitle.frame.origin.y   = 80
                                }
                                
                                self.headerTitle.setText(self.playlistName, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                    
                                    // TODO: Clean this up...
                                    return mutableAttributedString
                                })
                                self.headerTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                                self.headerTitle.sizeToFit()
                                self.user_id  = response["owner_id"] as? Int
                                self.ownerName.text = response["owner_title"] as? String
                                
                                
                                self.coverImageUrl = response["image"] as! String
                                let coverImageUrl = URL(string: self.coverImageUrl)
                                if  coverImageUrl != nil {
                                    self.headerImageView.kf.indicatorType = .activity
                                    (self.headerImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    self.headerImageView.kf.setImage(with: coverImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    })
                                    
                                }
                                self.profileImageUrlString = response["owner_image_normal"] as? String
                                let ownerImageUrl = URL(string: response["owner_image_normal"] as! String)
                                if  ownerImageUrl != nil {
                                    self.imgUser.kf.indicatorType = .activity
                                     (self.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    self.imgUser.kf.setImage(with: ownerImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    })
                                    
                                }
                                self.contentDescription = response["description"] as? String
                            }
                            if let videos = playlist["videos"] as? NSArray
                            {
                                self.playlistvideos = videos as [AnyObject]
                                self.videoListObj.globalvideoList = self.playlistvideos
                                self.videoListObj.tableView.reloadData()
                            }
                            if self.playlistvideos.count == 0
                            {
                                self.emptylistingMessage(msg: "video")
                            }
                        }
                    }
                })
            }
        }
    }
    func navigationButtons()
    {
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(PlaylistProfileViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

    }
    @objc func goBack()
    {
        if conditionalProfileForm == "BrowsePage"
        {
            
            playlistProfileUpdate = true
            _ = self.navigationController?.popToRootViewController(animated: false)
        }
        else if conditionalProfileForm == "AAF"
        {
            conditionalProfileForm = ""
            self.dismiss(animated: false, completion: nil)
            
        }
        else
        {
            _ = self.navigationController?.popViewController(animated: true)
            
        }
        
    }

    // Present Feed Gutter Menus
    @objc func showGutterMenu(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                if (dic["name"] as! String != "share")
                {
                    let titleString = dic["name"] as! String
                    if titleString.range(of: "delete") != nil {
                        
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                            if  dic["name"] as! String ==  "delete"{
                                
                                // Confirmation Alert
                                displayAlertWithOtherButton(NSLocalizedString("Delete Playlist", comment: ""),message: NSLocalizedString("Are you sure you want to delete this playlist?",comment: "") , otherButton: NSLocalizedString("Delete Playlist", comment: "")) { () -> () in
                                    self.deletePlaylist = true
                                    self.updateAlbum(dic["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }))
                    }
                    else
                    {
                        
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            if  dic["name"] as! String == "edit"{
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit Playlist", comment: "")
                                presentedVC.contentType = "Playlist"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                            }
                            
                        }))
                        
                    }
                }
                
            }
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    @objc func shareItem()
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title:  String(format: NSLocalizedString("Share on %@", comment: ""),app_title), style: .default) { action -> Void in
            let pv = AdvanceShareViewController()
            pv.url = self.shareUrl
            pv.param = self.shareParam as! [AnyHashable : Any] as NSDictionary
            pv.Sharetitle = self.playlistName
            if (self.contentDescription != nil) {
                pv.ShareDescription = self.contentDescription
            }
            pv.imageString = self.profileImageUrlString
            pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: pv)
            self.present(nativationController, animated:true, completion: nil)
            
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share Outside",comment: ""), style: UIAlertAction.Style.default) { action -> Void in
            
            var sharingItems = [AnyObject]()
            
            if let text = self.playlistName {
                sharingItems.append(text as AnyObject)
            }
            
            if let url = self.coverImageUrl {
                let finalUrl = URL(string: url)!
                sharingItems.append(finalUrl as AnyObject)
            }
            
            let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                
                if(activityViewController.popoverPresentationController != nil) {
                    activityViewController.popoverPresentationController?.sourceView = self.view;
                    let frame = UIScreen.main.bounds
                    activityViewController.popoverPresentationController?.sourceRect = frame;
                }
                
            }
            else
            {
                
                let presentationController = activityViewController.popoverPresentationController
                presentationController?.sourceView = self.view
                presentationController?.sourceRect = CGRect(x: self.view.bounds.width/2 , y: self.view.bounds.width/2, width: 0, height: 0)
                presentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                
            }
            
            self.present(activityViewController, animated: true, completion: nil)
            
        })
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = self.view
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    func updateAlbum(_ url : String){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            let dic = Dictionary<String, String>()
            var method = "POST"
            
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }
            
            // Send Server Request to Explore Album Contents with Album_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Album Detail
                        // Update Album Detail
                        
                        if succeeded["message"] != nil{
                           showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if self.deletePlaylist == true{
                            albumUpdate = true
                            self.popAfterDelay = true
                            self.createTimer(self)
                            return
                        }
                        self.browsePlaylist()
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg, timer: false)
        }
        
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer:Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        
        if timer{
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true{
            _ = navigationController?.popViewController(animated: true)
            
        }
    }
    //Showing message when response count is 0
    func emptylistingMessage(msg :String)
    {
        let contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: getBottomEdgeY(inputView: headerView) + 80,width: 60 , height: 60), text: NSLocalizedString("\(videoIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
        contentIcon.font = UIFont(name: "FontAwesome", size: 50)
        contentIcon.tag = 1000
       // self.view.addSubview(contentIcon)
        
        let info = createLabel(CGRect(x: 0, y: getBottomEdgeY(inputView: contentIcon),width: self.view.bounds.width , height: 50), text: NSLocalizedString("No updates at this moment . Check again any \nother time.", comment: ""), alignment: .center, textColor: textColorMedium)
        info.numberOfLines = 2
        info.font = UIFont(name: fontName, size: FONTSIZENormal)
        info.textAlignment = .center
        info.backgroundColor = UIColor.white
        info.tag = 1000
        self.view.addSubview(info)
        
        let refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: getBottomEdgeY(inputView: info), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
        refreshButton.backgroundColor = bgColor
        refreshButton.layer.borderColor = navColor.cgColor
        refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        refreshButton.addTarget(self, action: #selector(PlaylistProfileViewController.browsePlaylist), for: UIControl.Event.touchUpInside)
        
        refreshButton.layer.cornerRadius = 5.0
        refreshButton.layer.masksToBounds = true
       // self.view.addSubview(refreshButton)
        refreshButton.tag = 1000
        refreshButton.isHidden = false
        contentIcon.isHidden = false
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation - webView.url: \(String(describing: webView.url?.description))")
        imageView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish - webView.url: \(String(describing: webView.url?.description))")
        imageView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
