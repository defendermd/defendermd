//
//  AdvanceVideoProfileViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 13/06/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit
import MediaPlayer
import Photos
import AVKit
import WebKit
var advanceVideoProfileUpdate:Bool!
class AdvanceVideoProfileViewController: UIViewController, TTTAttributedLabelDelegate, UIScrollViewDelegate, WKNavigationDelegate, UITabBarControllerDelegate{
    var pipView: PIPViews!
    var videoType :Int?
    var videoUrl: String!
    var videoId :Int!
    var channelId :Int!
    var popAfterDelay:Bool!
    var videoDateinfo : TTTAttributedLabel! // Video stats
    var moviePlayer:CustomVideoPlayer!
    var videoDescription : UITextView!
    var videoWebView : WKWebView!
    var ratingView : UIView!
    var rated: Bool! = false
    var viewCount:Int = 0
    var gutterMenu: NSArray = []
    var actionMenu: NSArray = []  //Update Video Action Menus like,comment,add to playlist,watch etc
    var videoName : UILabel!
    var topView: UIView!
    var ownerName : UILabel!
    var imgUser : UIImageView!
    var descriptionLabel : TTTAttributedLabel!
    var owner_id : Int!
    var bottomView : UIView!
    var videoTitleString : String!
    var descriptionShareContent:String!
    var contentImage: String!
    var shareUrl : String!
    var shareParam : NSDictionary!
    var shareTitle : String!
    var contentUrl : String!
    var shareLimit : Int = 32
    var scrollView : UIScrollView!
    var delegateAdvanceVideoUI : DelegateAdvanceVideoUI?
    
    var event_id : Int!
    var group_id : Int!
    var page_id : Int!
    var store_id : Int!
    var videoProfileTypeCheck = ""
    
    var rightBarButtonItem : UIBarButtonItem!
    var imageView : UIImageView!
    
    var sharable: Bool = false
    var listingId : Int!
    var listingTypeId : Int!
    var leftBarButtonItem : UIBarButtonItem!
    var subjectType:String!
    var btnSubscribe : UIButton!
    var islike = Bool()
    var issubscribe = Bool()
    
    var btnwatchlater = UIButton()
    var lblwatchlater = UILabel()
    var btnFavourite = UIButton()
    var lblFavourite = UILabel()
    var btnPlaylist = UIButton()
    var lblPlaylist = UILabel()
    var favratevalue = Int()
    var watchvalue = Int()
    
    var likecount = Int()
    var btnlike = UIButton()
    var lbllike = UILabel()
    var lblcomment = UILabel()
    
    var videoListObj = videoListTableViewController()
    var advancevideos = [AnyObject]()
    var marqueeHeader : MarqueeLabel!
    var lastContentOffset: CGFloat = 0
    
    var lineView1: UIView?
    var lineView2: UIView?
    var lineView3: UIView?
    var videoDetailDic:NSDictionary?
    var passstr : String!
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    var isComingFromDeepLink = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        videosUpdate = false
        advanceVideoProfileUpdate = true
        popAfterDelay = false
        subjectType = "video"
        self.tabBarController?.delegate = self
        // Get notify by videoListTableViewController
        tableViewFrameType = "AdvanceVideoProfileViewController"
        //NotificationCenter.default.addObserver(self, selector: #selector(AdvanceVideoProfileViewController.ScrollingactionAdvVideo(_:)), name: NSNotification.Name(rawValue: "ScrollingactionAdvVideo"), object: nil)
        
        self.CreateNavigation()
        removeNavigationImage(controller: self)
        //Webview Implimentation
        
        
        
        let configuration = WKWebViewConfiguration()
        if #available(iOS 10.0, *) {
            configuration.mediaTypesRequiringUserActionForPlayback = []
        }
        configuration.allowsInlineMediaPlayback = true
        videoWebView = WKWebView(frame: .zero, configuration: configuration)
        //videoWebView.center = viewSubview.convert(viewSubview.center, from:viewSubview.superview)
        videoWebView.isOpaque = false
        //WKAudiovisualMediaTypeNone = 0
        videoWebView.backgroundColor = UIColor.black
        videoWebView.scrollView.bounces = false
        videoWebView.allowsLinkPreview = false
        videoWebView.navigationDelegate = self
        

        self.view.addSubview(videoWebView)
        
        let jeremyGif = UIImage.gifWithName("progress bar")
        // Use the UIImage in your UIImageView
        imageView = UIImageView(image: jeremyGif)
        imageView.frame = CGRect(x: view.bounds.width/2 - 60,y: 140 ,width: 120, height: 7)
        videoWebView.addSubview(imageView)
        
        // Player & Webview Implimentation
        implemnetPlayer()
        
        //UI Added on VideolistTableviewController
        designUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableViewFrameType = "AdvanceVideoProfileViewController"
        removeNavigationImage(controller: self)
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
        }
        
    }
    
    // Explore Video Detail On View Appear
    override func viewDidAppear(_ animated: Bool) {
        removeNavigationImage(controller: self)
        if advanceVideoProfileUpdate == true{
            advanceVideoProfileUpdate = false
            exploreVideo()
        }
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        if videoType == 3 {
        if let player = self.moviePlayer.player
        {
            //player.pause()
        }
        }
        tableViewFrameType = ""
        self.marqueeHeader.text = ""
        //        self.navigationItem.rightBarButtonItem = nil
        removeMarqueFroMNavigaTion(controller: self)
        setNavigationImage(controller: self)
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
        if videoType == 3 {
        if let player = self.moviePlayer.player
        {
            player.pause()
        }
        }
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }
    
    // MARK: - Create navigation
    func CreateNavigation()
    {
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvanceVideoProfileViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
    }
    // MARK: - Player & Webview Implimentation
    func implemnetPlayer()
    {
        for view in (keywindows?.subviews)! {
            if view.tag == 9999 {
                view.removeFromSuperview()
            }
        }
        var playerHeight: CGFloat = 400
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            playerHeight = 200
        }
        self.navigationItem.rightBarButtonItem = nil
        playerHeight += TOPPADING - contentPADING
        tableframeY = playerHeight
        if videoType == 3
        {
            moviePlayer = CustomVideoPlayer(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: playerHeight), url: self.videoUrl, isFromVideoProfilePage: true, vc: self)
            self.view.addSubview(moviePlayer)
            videoWebView.isHidden = true
            do
            {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
                try AVAudioSession.sharedInstance().setActive(true)
            }
            catch _ as NSError {
                //print(error)
            }
            
        }
        else
        {
            videoWebView.isHidden = false
            var url = ""
            if videoUrl != nil
            {
                let videoUrl1 : String = videoUrl
                let find = videoUrl1.contains("http")
                if videoType == 1 || videoType == 2 || videoType == 4 || videoType == 5 && find == false{
                    
                    url = "https://" + videoUrl
                }
                else
                {
                    url = videoUrl
                }
            }
            videoWebView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: playerHeight)
            if let videoURL =  URL(string:url){
                var request = URLRequest(url: videoURL)
                if videoType == 1 {
                    request.setValue("http://www.youtube.com", forHTTPHeaderField: "Referer")
                }
                videoWebView.load(request)
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch _ as NSError {
                    //print(error)
                }
                
            }
            else
            {
                if videoType == 6
                {
                    videoWebView.loadHTMLString(videoUrl, baseURL: nil)
                }
            }
        }
    }
    
    // MARK: - UI Added on VideolistTableviewController
    func designUI()
    {
        bottomView = createView(CGRect(x: 0,  y: 0 , width: view.bounds.width, height: 140), borderColor: UIColor.clear, shadow: false)
        bottomView.backgroundColor = lightBgColor
        videoListObj.tableView.addSubview(bottomView)
        
        videoName = createLabel(CGRect(x: PADING*2, y: 0 , width: view.bounds.width - 2*PADING, height: 40),text: "", alignment: .left, textColor: textColorDark)
        videoName.longPressLabel()
        videoName.font = UIFont(name: fontBold, size: FONTSIZELarge)
        //videoName.backgroundColor = UIColor.green
        videoName.numberOfLines = 0
        videoName.lineBreakMode = .byWordWrapping
        bottomView.addSubview(videoName)
        
        // Set Video Title
        videoDateinfo = TTTAttributedLabel(frame: CGRect(x: PADING*2, y: 40, width: view.bounds.width - 2*PADING - 120, height: 70))
        videoDateinfo.numberOfLines = 0
        videoDateinfo.delegate = self
        videoDateinfo.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
        videoDateinfo.textColor = textColorMedium
        videoDateinfo.longPressLabel()
        videoDateinfo.font = UIFont(name: fontName, size: FONTSIZESmall)
        // videoDateinfo.backgroundColor = UIColor.red//textColorclear
        bottomView.addSubview(videoDateinfo)
        
        ratingView = UIView(frame: CGRect(x: view.bounds.width - PADING*2 - 80, y: 40, width: 100, height: 30))
        // ratingView.backgroundColor = UIColor.yellow
        bottomView.addSubview(ratingView)
        
        
        
        topView = createView(CGRect(x: 0, y: getBottomEdgeY(inputView: bottomView) + 5, width: view.bounds.width, height: 60), borderColor: textColorclear, shadow: false)
        topView.backgroundColor = lightBgColor
        videoListObj.tableView.addSubview(topView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AdvanceVideoProfileViewController.handleTap))
        topView.addGestureRecognizer(tap)
        imgUser = createImageView(CGRect(x: 10, y: 2, width: 50, height: 50), border: true)
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.clear.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.image = UIImage(named: "user_profile_image.png")
        imgUser.isHidden = true
        imgUser.clipsToBounds = true
        topView.addSubview(imgUser)
        
        ownerName = createLabel(CGRect(x: getRightEdgeX(inputView: imgUser) + 5, y: 12, width: view.bounds.width - (110 + getRightEdgeX(inputView: imgUser) + 5), height: 30), text: "", alignment: .left, textColor: textColorDark)
        ownerName.font = UIFont(name: fontName, size: FONTSIZENormal)
        ownerName.longPressLabel()
        topView.addSubview(ownerName)
        
        btnSubscribe = createButton(CGRect(x: topView.frame.size.width - 105, y:10, width: 100, height: ButtonHeight), title: "SUBSCRIBE", border: false, bgColor: false, textColor: textColorLight)
        btnSubscribe.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
        btnSubscribe.backgroundColor = navColor
        btnSubscribe.isHidden = true
        btnSubscribe.layer.cornerRadius = cornerRadiusSmall
        btnSubscribe.addTarget(self, action: #selector(AdvanceVideoProfileViewController.subscribeAction(_:)), for: .touchUpInside)
        topView.addSubview(btnSubscribe)
        
        
        descriptionLabel = TTTAttributedLabel(frame: CGRect(x: 5, y:getBottomEdgeY(inputView: topView) , width: view.bounds.width - 5, height: 20))
        descriptionLabel.numberOfLines = 0
        descriptionLabel.delegate = self
        descriptionLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        descriptionLabel.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        descriptionLabel.textColor = textColorDark
        descriptionLabel.backgroundColor = textColorclear
        //descriptionLabel.backgroundColor = UIColor.red
        videoListObj.tableView.addSubview(descriptionLabel)
        
        lineView1 = createView(CGRect(x: 0,  y: bottomView.frame.size.height - 1 , width: view.bounds.width, height: 1), borderColor: UIColor.clear, shadow: false)
        lineView1?.backgroundColor =  UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1.0)
        lineView1?.isHidden = true
        bottomView.addSubview(lineView1!)
        
        lineView2 = createView(CGRect(x: 0,  y: topView.frame.size.height - 1 , width: view.bounds.width, height: 1), borderColor: UIColor.clear, shadow: false)
        lineView2?.backgroundColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1.0)
        lineView2?.isHidden = true
        topView.addSubview(lineView2!)
        
        lineView3 = createView(CGRect(x: 0,  y: getBottomEdgeY(inputView: descriptionLabel) , width: view.bounds.width, height: 1), borderColor: UIColor.clear, shadow: false)
        lineView3?.backgroundColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1.0)
        lineView3?.isHidden = true
        videoListObj.tableView.addSubview(lineView3!)
        
        videoListObj.headerheight = descriptionLabel.frame.size.height + descriptionLabel.frame.origin.y + 1
        comingFromPlaylist = false
        videoListObj.delegateVideoChange = self
        videoListObj.isAdvanceVideoProfileParent = true
        self.view.addSubview(videoListObj.view)
        self.addChild(videoListObj)
        
    }
    // MARK: - Back action
    @objc func goBack()
    {
        if videoType == 3
        {
            isVideoPlayingInPIP = true
            for view in (keywindows?.subviews)! {
                if view.tag == 9999 {
                    view.removeFromSuperview()
                }
            }
            if showPipOption() == "yes" {
            self.moviePlayer.player?.pause()
            let videoPlayer = AVPlayer(url: URL(string: self.videoUrl)!)
            self.pipView = PIPViews(frame: CGRect(x: UIScreen.main.bounds.width - pipModeSize.width - 10, y: UIScreen.main.bounds.height - pipModeSize.height - 10, width: pipModeSize.width, height: pipModeSize.height), videoPlayer: videoPlayer, parentViewController: self, currentTimeStamp: (self.moviePlayer.player?.currentTime())!)
                self.pipView.player?.play()
            keywindows?.addSubview(self.pipView)
            self.pipView.openPIPWithAnimation()
            }

        }
        if conditionalProfileForm == "BrowsePage"
        {
            
            videosUpdate = true
            self.dismiss(animated: true, completion: nil)
        }
        else if conditionalProfileForm == "AAF"
        {
            conditionalProfileForm = ""
            self.dismiss(animated: false, completion: nil)
            
        }
        else
        {
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true{
            _ = navigationController?.popViewController(animated: true)
            
        }
    }
    
    
    
    @objc func showGutterMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                
                if dic["name"] as! String == "create"{
                    continue
                }
                
                if dic["name"] as! String == "share"{
                }
                else
                {
                    let titleString = dic["name"] as! String
                    if titleString.range(of: "delete") != nil{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Video Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                                
                            case "delete":
                                displayAlertWithOtherButton(NSLocalizedString("Delete Video", comment: ""),message: NSLocalizedString("Are you sure you want to delete this video?",comment: "") , otherButton: NSLocalizedString("Delete Video", comment: "")) { () -> () in
                                    self.updateVideoMenuAction(dic["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                            }
                            
                            
                        }))
                    }
                    else{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Video Entry
                            let condition = dic["name"] as! String
                            switch(condition)
                            {
                                
                            case "edit" :
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit Video", comment: "")
                                presentedVC.contentType = "video"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            case "create" :
                                addvideo_click = 1
                                isCreateOrEdit = true
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Add New Video", comment: "")
                                presentedVC.contentType = "video"
                                presentedVC.param = [ : ]
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                                
                            case "report":
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "download":
                                let url = dic["url"] as! String//"https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
                                let id = self.videoId
                                self.createUrl(url: url,id: id!)
                                break
                                
                            case "suggest":
                                
                                isCreateOrEdit = true
                                let presentedVC = MessageCreateController()
                                presentedVC.iscoming = "sitevideoAvoid"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.param = dic["urlParams"]  as! NSDictionary
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                            }
                        }))
                        
                    }
                    
                }
                
            }
        }
        if  (!isIpad()){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height-50, y: view.bounds.width, width: 0, height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    // MARK: - Download video
    func createUrl(url : String,id : Int)
    {
        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: url),
                let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/\(url.lastPathComponent)"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            
                            DispatchQueue.main.sync {
                                print("Video is saved!")
                                showToast(message: NSLocalizedString("Video Downloaded Sucessfully.",comment: ""), controller: self)
                            }
                            
                        }
                    }
                }
            }
        }
        
        showToast(message: NSLocalizedString("Video Downloading...Your video will be saved in gallery.",comment: ""), controller: self, onView: false, time: 2)
        
        /*
         let filename = "downloadedFile" + String(id) + ".mp4"
         if let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
         {
         let destinationFileUrl = documentsUrl.appendingPathComponent(filename)
         let downloadurl = URL(string: url)
         self.videoListObj.tableView.makeToast(NSLocalizedString("Downloading...", comment: ""), duration: 5, position: "top")
         
         // Download video file
         Downloader.load(url: downloadurl!, to: destinationFileUrl) { (status) in
         if status == true
         {
         //AdvanceVideoProfileViewController().videoListObj.tableView.makeToast(NSLocalizedString("Download sucessfully", comment: ""), duration: 5, position: "top")
         self.videoListObj.tableView.makeToast(NSLocalizedString("Download sucessfully", comment: ""), duration: 5, position: "top")
         }
         else
         {
         self.videoListObj.tableView.makeToast(NSLocalizedString("Download fail", comment: ""), duration: 5, position: "top")
         }
         
         }
         }
         */
    }
    
    // MARK: - Password Alert
    func passwordAlert(pass : String)
    {
        let alertController = UIAlertController(title: NSLocalizedString("Enter Password",  comment: ""), message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = NSLocalizedString("Enter Password",  comment: "")
            textField.isSecureTextEntry = true
            
        })
        
        
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            let enterpass = alertController.textFields?[0].text
            if enterpass == String(pass)
            {
                self.bindData(video: self.videoDetailDic!)
            }
            else
            {
                showToast(message: "Password invalid", controller: self)
                self.passwordAlert(pass : self.passstr)
            }
            
            
        })
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            self.goBack()
        })
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: {  })
    }
    func updateVideoMenuAction(_ url : String){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            let dic = Dictionary<String, String>()
            // Send Server Request to Explore Video Contents with Video_ID
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        self.feedRemoveInTikTokArray()
                        videosUpdate = true
                        if self.videoProfileTypeCheck == "AdvEventProfile"{
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                        
                        showToast(message: NSLocalizedString("Video has been deleted successfully",comment: ""), controller: self)
                        channelProfileUpdate = true
                        channelUpdate = true
                        feedUpdate = true
                        advVideosUpdate = true
                        
                        if sitevideoPluginEnabled_event == 1
                        {
                            contentFeedUpdate = true
                        }
                        else if sitevideoPluginEnabled_group == 1
                        {
                            advGroupDetailUpdate = true
                        }
                        else if sitevideoPluginEnabled_mlt == 1
                        {
                            listingDetailUpdate = true
                        }
                        else if sitevideoPluginEnabled_page == 1
                        {
                            pageDetailUpdate = true
                        }
                        else if sitevideoPluginEnabled_store == 1
                        {
                            storeDetailUpdate = true
                        }
                        
                        self.popAfterDelay = true
                        self.createTimer(self)
                        return
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
            showToast(message: network_status_msg, controller: self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation - webView.url: \(String(describing: webView.url?.description))")
        imageView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish - webView.url: \(String(describing: webView.url?.description))")
       imageView.isHidden = true
    }

  
    
    @objc func ScrollingactionAdvVideo(_ notification: Foundation.Notification)
    {
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        let scrollOffset = scrollopoint.y
        if (scrollOffset < 60.0)
        {
            
            self.title = ""
        }
        if (scrollOffset > 60)
        {
            
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            setNavigationImage(controller: self)
            self.marqueeHeader.text = self.videoTitleString
            self.marqueeHeader.textColor = textColorPrime
            self.navigationController?.navigationBar.alpha = barAlpha
            self.marqueeHeader.alpha = barAlpha
            self.videoName.alpha = 1-barAlpha
            // update the new position acquired
            self.lastContentOffset = scrollOffset
        }
        else
        {
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            self.marqueeHeader.text = ""
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            removeNavigationImage(controller: self)
            self.marqueeHeader.alpha = 1
            self.videoName.alpha = 1-barAlpha
        }
    }
    
    @objc func cannotRateAction(_ sender:UIButton){
        showToast(message: NSLocalizedString("You already rated this video",comment: ""), controller: self)
    }
    
    @objc func handleTap() {
        if (self.owner_id != nil){
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(self.owner_id!)"
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    //MARK: - For share
    @objc func shareItem(){
        let startPoint = CGPoint(x: self.view.frame.width - 72, y: 50)
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
        let ShareOptionHeightCount:CGFloat = CGFloat(44*ShareOption.count)
        let tableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: self.view.frame.width, height: ShareOptionHeightCount))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.tag = 11
        tableView.estimatedRowHeight = 34.0
        popover.show(tableView, point: startPoint)
    }
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        //UIApplication.shared.openURL(url!)
        let presentedVC = ExternalWebViewController()
        presentedVC.url = url.absoluteString
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navigationController = UINavigationController(rootViewController: presentedVC)
        self.present(navigationController, animated: true, completion: nil)
        
    }
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!)
    {
        let type = components["type"] as! String
        switch(type){
            
        case "like":
            
            break
        case "comment":
            let presentedVC = CommentsViewController()
            likeCommentContent_id = "\(videoId!)"
            presentedVC.openCommentTextView = 1
            presentedVC.activityFeedComment = false
            presentedVC.commentPermission = 1
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:true, completion: nil)
            
            break
        case "category_id":
            videosUpdate = true
            searchDic.removeAll(keepingCapacity: false)
            let id = components["id"] as! Int
            searchDic["category"] = String(id)
            
            if let response = videoDetailDic?["response"] as? NSDictionary
            {
                for(key,value) in (response["tags"] as? NSDictionary)!{
                    searchDic["tag"] = "\(value)"
                    searchDic["tag_id"] = "\(key)"
                }
                
            }
            
            let presentedVC = AdvancedVideoSearchViewController()
            
            presentedVC.searchPath = "advancedvideos/browse"
            
            self.navigationController?.pushViewController(presentedVC, animated: false)
            globalCatg = ""
            let url : String = "advancedvideos/search-form"
            loadFilter(url)
            
        default:
            print("default")
            
        }
        
    }
    
    //MARK: - Create menus
    func createactionMenus()
    {
        let btnwidth =   bottomView.frame.size.width/5
        var widthI : CGFloat = 0
        let subviews = bottomView.subviews
        for obj in subviews
        {
            if obj.tag == 20
            {
                obj.removeFromSuperview()
            }
        }
        self.bottomView.frame.size.height = self.bottomView.frame.size.height + 70
        for menu in actionMenu
        {
            
            if let menuItem = menu as? NSDictionary
            {
                let nameString = menuItem["name"] as! String
                if nameString == "like"
                {
                    
                    btnlike  = createButton(CGRect(x: widthI, y: getBottomEdgeY(inputView: videoDateinfo) + 28, width: btnwidth, height: 20), title: "\(likeIcon)", border: false, bgColor: false, textColor: textColorMedium)
                    btnlike.titleLabel?.font = UIFont(name: "FontAwesome", size:16)
                    btnlike.backgroundColor = textColorclear
                    btnlike.tag = 20
                    likecount = menuItem ["like_count"] as! Int
                    
                    btnlike.addTarget(self, action: #selector(AdvanceVideoProfileViewController.likeAction(_:)), for: .touchUpInside)
                    bottomView.addSubview(btnlike)
                    
                    lbllike = createLabel(CGRect(x:widthI, y: getBottomEdgeY(inputView: videoDateinfo) + 48 , width: btnwidth, height: 10),text: String(likecount), alignment: .center, textColor: textColorMedium)
                    lbllike.font = UIFont(name: fontName, size: FONTSIZESmall)
                    lbllike.tag = 20
                    bottomView.addSubview(lbllike)
                    if menuItem["is_like"] as! Int == 0
                    {
                        
                        btnlike.setTitleColor(textColorMedium, for: .normal)
                        lbllike.textColor = textColorMedium
                        islike = false
                    }
                    else
                    {
                        btnlike.setTitleColor(navColor, for: .normal)
                        lbllike.textColor = navColor
                        islike = true
                    }
                    
                    
                }
                else if nameString == "comment"
                {
                    let btncomment  = createButton(CGRect(x: widthI, y: getBottomEdgeY(inputView: videoDateinfo) + 28, width: btnwidth, height: 20), title: "\(commentIcon)", border: false, bgColor: false, textColor: textColorMedium)
                    btncomment.titleLabel?.font = UIFont(name: "FontAwesome", size:16)
                    btncomment.backgroundColor = textColorclear
                    let commentcount = menuItem ["comment_count"] as! Int
                    btncomment.titleLabel?.tintColor = textColorMedium
                    btncomment.addTarget(self, action: #selector(AdvanceVideoProfileViewController.comentAction(_:)), for: .touchUpInside)
                    bottomView.addSubview(btncomment)
                    btncomment.tag = 20
                    
                    lblcomment = createLabel(CGRect(x:widthI, y: getBottomEdgeY(inputView: videoDateinfo) + 48 , width: btnwidth, height: 10),text: String(commentcount), alignment: .center, textColor: textColorMedium)
                    lblcomment.font = UIFont(name: fontName, size: FONTSIZESmall)
                    bottomView.addSubview(lblcomment)
                    lblcomment.tag = 20
                    
                    
                }
                else if nameString == "watch_later"
                {
                    
                    btnwatchlater  = createButton(CGRect(x: widthI - 5, y: getBottomEdgeY(inputView: videoDateinfo) + 28, width: btnwidth + 5, height: 20), title: "\(watchIcon)", border: false, bgColor: false, textColor: textColorMedium)
                    btnwatchlater.titleLabel?.font = UIFont(name: "FontAwesome", size:16)
                    btnwatchlater.backgroundColor = textColorclear
                    btnwatchlater.addTarget(self, action: #selector(AdvanceVideoProfileViewController.watchAction(_:)), for: .touchUpInside)
                    bottomView.addSubview(btnwatchlater)
                    btnwatchlater.tag = 20
                    
                    lblwatchlater = createLabel(CGRect(x:widthI - 5, y: getBottomEdgeY(inputView: videoDateinfo) + 48 , width: btnwidth + 5, height: 10),text: NSLocalizedString("Watch Later", comment: ""), alignment: .center, textColor: textColorMedium)
                    lblwatchlater.font = UIFont(name: fontName, size: FONTSIZESmall)
                    lblwatchlater.tag = 20
                    bottomView.addSubview(lblwatchlater)
                    if let dic  = menuItem["urlParams"] as? NSDictionary
                    {
                        if dic["value"] as! Int == 0
                        {
                            watchvalue = dic["value"] as! Int
                            btnwatchlater.setTitleColor(navColor, for: .normal)
                            lblwatchlater.textColor = navColor
                            
                        }
                        else
                        {
                            watchvalue = dic["value"] as! Int
                            btnwatchlater.setTitleColor(textColorMedium, for: .normal)
                            lblwatchlater.textColor = textColorMedium
                        }
                    }
                    
                }
                else if nameString == "favourite"
                {
                    // For Like
                    btnFavourite = createButton(CGRect(x: widthI, y: getBottomEdgeY(inputView: videoDateinfo) + 30, width: btnwidth, height: 15), title: "", border: false, bgColor: false, textColor: textColorMedium)
                    btnFavourite.backgroundColor = textColorclear
                    btnFavourite.setImage(UIImage(named :"favourite.png"), for: .normal)
                    btnFavourite.imageView?.contentMode = .scaleAspectFit
                    btnFavourite.addTarget(self, action: #selector(AdvanceVideoProfileViewController.favouriteAction(_:)), for: .touchUpInside)
                    bottomView.addSubview(btnFavourite)
                    btnFavourite.tag = 20
                    lblFavourite = createLabel(CGRect(x:widthI, y: getBottomEdgeY(inputView: videoDateinfo) + 48 , width: btnwidth, height: 10),text: NSLocalizedString("Favourite", comment: ""), alignment: .center, textColor: textColorMedium)
                    lblFavourite.font = UIFont(name: fontName, size: FONTSIZESmall)
                    bottomView.addSubview(lblFavourite)
                    lblFavourite.tag = 20
                    if let dic  = menuItem["urlParams"] as? NSDictionary
                    {
                        
                        if dic["value"] as! Int == 1
                        {
                            favratevalue = dic["value"] as! Int
                            btnFavourite.setImage(UIImage(named :"favourite.png"), for: .normal)
                            lblFavourite.textColor = textColorMedium
                            
                        }
                        else
                        {
                            favratevalue = dic["value"] as! Int
                            btnFavourite.setImage(UIImage(named: "favourite.png")!.maskWithColor(color: navColor), for: .normal)
                            lblFavourite.textColor = navColor
                        }
                        
                    }
                    
                    
                }
                else if nameString == "playlist"
                {
                    btnPlaylist = createButton(CGRect(x: widthI, y: getBottomEdgeY(inputView: videoDateinfo) + 28, width: btnwidth, height: 20), title: "", border: false, bgColor: false, textColor: textColorMedium)
                    btnPlaylist.backgroundColor = textColorclear
                    btnPlaylist.setImage(UIImage(named :"playlistaddgrey.png"), for: .normal)
                    btnPlaylist.imageView?.contentMode = .scaleAspectFit
                    btnPlaylist.addTarget(self, action: #selector(AdvanceVideoProfileViewController.playlistAction(_:)), for: .touchUpInside)
                    bottomView.addSubview(btnPlaylist)
                    btnPlaylist.tag = 20
                    lblPlaylist = createLabel(CGRect(x:widthI, y: getBottomEdgeY(inputView: videoDateinfo) + 48 , width: btnwidth, height: 10),text: NSLocalizedString("Add to", comment: ""), alignment: .center, textColor: textColorMedium)
                    lblPlaylist.font = UIFont(name: fontName, size: FONTSIZESmall)
                    bottomView.addSubview(lblPlaylist)
                    lblPlaylist.tag = 20
                    
                }
                widthI = widthI+btnwidth
                
            }
        }
        
        self.topView.frame.origin.y = getBottomEdgeY(inputView: self.bottomView) + 5
        lineView1?.frame.origin.y = bottomView.frame.size.height - 1
        lineView2?.frame.origin.y  = topView.frame.size.height - 1
    }
    
    //MARK: - Action methods
    @objc func likeAction(_ sender:UIButton)
    {
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            var path = ""
            // Set path for Like & UnLike
            if self.islike == true{
                path = "unlike"
                self.btnlike.setTitleColor(textColorMedium, for: .normal)
                self.lbllike.textColor = textColorMedium
                islike = false
                likecount = likecount - 1
                self.lbllike.text = String(likecount)
            }else{
                path = "like"
                self.btnlike.setTitleColor(navColor, for: .normal)
                self.lbllike.textColor = navColor
                likecount = likecount + 1
                self.lbllike.text = String(likecount)
                islike = true
            }
            // Send Server Request to Like/Unlike Content
            post(["subject_id":String(videoId), "subject_type": "sitevideo_video"], url: path, method: "POST") {
                (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    if msg
                    {
                        //print("Success")
                    }
                    else
                    {
                        if self.islike == true{
                            
                            self.btnlike.setTitleColor(textColorMedium, for: .normal)
                            self.lbllike.textColor = textColorMedium
                            self.islike = false
                            self.likecount = self.likecount - 1
                            self.lbllike.text = String(self.likecount)
                        }
                        else
                        {
                            
                            self.btnlike.setTitleColor(navColor, for: .normal)
                            self.lbllike.textColor = navColor
                            self.likecount = self.likecount + 1
                            self.lbllike.text = String(self.likecount)
                            self.islike = true
                        }
                        
                    }
                })
            }
        }
        else{
            
            
        }
    }
    @objc func comentAction(_ sender:UIButton)
    {
        let presentedVC = CommentsViewController()
        likeCommentContent_id = "\(videoId!)"
        presentedVC.openCommentTextView = 1
        presentedVC.activityFeedComment = false
        presentedVC.commentPermission = 1
        likeCommentContentType = "sitevideo_video"
        
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:true, completion: nil)
        
    }
    @objc func watchAction(_ sender:UIButton)
    {
        
        for menu in actionMenu
        {
            if let menuItem = menu as? NSDictionary
            {
                let nameString = menuItem["name"] as! String
                if nameString == "watch_later"
                {
                    
                    if watchvalue != 0
                    {
                        btnwatchlater.setTitleColor(navColor, for: .normal)
                        lblwatchlater.textColor = navColor
                        
                        
                    }
                    else
                    {
                        
                        btnwatchlater.setTitleColor(textColorMedium, for: .normal)
                        lblwatchlater.textColor = textColorMedium
                    }
                    
                    let param = menuItem["urlParams"] as! NSDictionary //Dictionary<String, String>() as NSDictionary
                    let url = menuItem["url"] as! String
                    updateContentAction(param, url: url, oncompletion: { (value) in
                        if value == 1
                        {
                            if self.watchvalue == 1
                            {
                                self.watchvalue = 0
                            }
                            else
                            {
                                self.watchvalue = 1
                            }
                        }
                    })
                    
                }
            }
            
        }
    }
    @objc func playlistAction(_ sender:UIButton)
    {
        for menu in actionMenu
        {
            if let menuItem = menu as? NSDictionary
            {
                
                let nameString = menuItem["name"] as! String
                if nameString == "playlist"
                {
                    
                    let url = menuItem["url"] as! String
                    isCreateOrEdit = true
                    let presentedVC = FormGenerationViewController()
                    presentedVC.formTitle = NSLocalizedString("Add To Playlist", comment: "")
                    presentedVC.contentType = "addtoplaylist"
                    presentedVC.param = [ : ]
                    presentedVC.url = url
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    self.present(nativationController, animated:true, completion: nil)
                    
                    
                }
            }
        }
    }
    @objc func favouriteAction(_ sender:UIButton)
    {
        for menu in actionMenu
        {
            if let menuItem = menu as? NSDictionary
            {
                
                let nameString = menuItem["name"] as! String
                if nameString == "favourite"
                {
                    if favratevalue == 1
                    {
                        btnFavourite.setImage(UIImage(named: "favourite.png")!.maskWithColor(color: navColor), for: .normal)
                        lblFavourite.textColor = navColor
                        
                    }
                    else
                    {
                        btnFavourite.setImage(UIImage(named :"favourite.png"), for: .normal)
                        lblFavourite.textColor = textColorMedium
                    }
                    let param = menuItem["urlParams"] as! NSDictionary //Dictionary<String, String>() as NSDictionary
                    let url = menuItem["url"] as! String
                    updateContentAction(param, url: url, oncompletion: { (value) in
                        if value == 1
                        {
                            if self.favratevalue == 1
                            {
                                self.favratevalue = 0
                            }
                            else
                            {
                                self.favratevalue = 1
                            }
                        }
                    })
                }
            }
        }
    }
    func updateContentAction(_ parameter: NSDictionary , url : String,oncompletion :@escaping (_ value : Int) -> ()){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            let method = "POST"
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg
                    {
                        
                        oncompletion(1)
                    }
                    else
                    {
                        oncompletion(0)
                    }
                })
            }
            
        }else{
            
        }
        
    }
    @objc func subscribeAction(_ sender:UIButton){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            let path = "advancedvideo/channel/channel-subscribe/" + String(channelId)
            var parameters : NSDictionary = [ : ]
            // Set path for Like & UnLike
            if self.issubscribe == true{
                self.issubscribe = false
                parameters = ["value":"0"]
                self.btnSubscribe.setTitle(NSLocalizedString("SUBSCRIBE", comment: ""), for: .normal)
                
            }
            else{
                
                self.issubscribe = true
                self.btnSubscribe.setTitle(NSLocalizedString("SUBSCRIBED", comment: ""), for: .normal)
                parameters = ["value":"1","channel_id":String(channelId)]
            }
            // Send Server Request to Like/Unlike Content
            post(parameters as! Dictionary<String, String>, url: path, method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    if msg
                    {
                        //print("Success")
                    }
                    else
                    {
                        
                        
                    }
                })
            }
        }
        else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    // MARK: - Update Rating Function
    func updateRating(_ rating:Int, ratingCount:Int)
    {
        
        for ob in ratingView.subviews{
            ob.removeFromSuperview()
        }
        var origin_x = 10 as CGFloat
        for i in stride(from: 1, through: 5, by: 1){
            let rate = createButton(CGRect(x: origin_x, y: 0, width: 12, height: 12), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clear
            rate.setImage(UIImage(named: "star.png"), for: UIControl.State() )
            
            if rated == false{
                rate.tag = i
                rate.addTarget(self, action: #selector(AdvanceVideoProfileViewController.rateAction(_:)), for: .touchUpInside)
            }
            else
            {
                if i <= rating{
                    rate.setImage(UIImage(named: "yellowStar.png"), for: UIControl.State() )
                }
                rate.addTarget(self, action: #selector(AdvanceVideoProfileViewController.cannotRateAction(_:)), for: .touchUpInside)
            }
            origin_x += 14
            ratingView.addSubview(rate)
        }
        
        var totalRated = ""
        totalRated = singlePluralCheck( NSLocalizedString(" view", comment: ""),  plural: NSLocalizedString(" views", comment: ""), count: self.viewCount)
        let ratedInfo = createLabel(CGRect(x: 0, y: 15,width: 75 , height: 10),text: totalRated, alignment: .center, textColor: textColorMedium)
        ratedInfo.font = UIFont(name: fontName, size:FONTSIZESmall)
        ratedInfo.textAlignment = .right
        ratingView.addSubview(ratedInfo)
    }
    
    // Rate Action
    @objc func rateAction(_ sender:UIButton){
        
        if Reachabable.isConnectedToNetwork() {
            
            removeAlert()
            //
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            var rateUrl = ""
            if videoProfileTypeCheck == "AdvEventProfile"{
                //videoType = ""
                
                rateUrl = "advancedevents/video/rate"
            }
            else if videoProfileTypeCheck == "sitegroupvideo"{
                
                rateUrl = "advancedgroups/video/rating/" + String(event_id) + "/" + String(videoId)
                
            }
            else{
                
                rateUrl = "advancedvideo/rate/" + String(videoId)
                
            }
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["video_id" : String(videoId), "rating":"\(sender.tag)"], url: rateUrl, method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Video Detail
                        // Update Video Detail
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                self.rated = true
                                self.updateRating(sender.tag, ratingCount: (body["rating_count"] as? Int)!)
                            }
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
            
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    // MARK: - Server calling
    func exploreVideo(){
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
            // Send Server Request to Explore Video Contents with Video_ID
            
            var urlCheck = ""
            var parameterCheck : NSDictionary = [ : ]
            if videoProfileTypeCheck == "AdvEventProfile"{
                //videoType = ""
                parameterCheck = ["user_id": String(event_id), "gutter_menu": "1"]
                if sitevideoPluginEnabled_event == 1
                {
                    urlCheck = "advancedvideo/view/" + String(videoId)
                }
                else
                {
                    urlCheck = "advancedevents/video/" + String(event_id) + "/" + String(videoId)
                }
                
            }
                
            else if videoProfileTypeCheck == "listings"{
                //videoType = ""
                parameterCheck = ["video_id": String(videoId), "gutter_menu": "1","listingtype_id" : String(listingTypeId)]
                if sitevideoPluginEnabled_mlt == 1
                {
                    urlCheck = "advancedvideo/view/" + String(videoId)
                }
                else
                {
                    urlCheck = "listings/video/view/" + String(listingId)
                }
            }
            else if videoProfileTypeCheck == "Pages"{
                
                if sitevideoPluginEnabled_page == 1
                {
                    urlCheck = "advancedvideo/view/" + String(videoId)
                }
                else
                {
                    urlCheck = "pages/video/view/" + String(group_id) + "/" + String(videoId)
                }
                
                parameterCheck = [ "menu": "1"]
            }
            else if videoProfileTypeCheck == "stores"{
                
                if sitevideoPluginEnabled_store == 1
                {
                    urlCheck = "advancedvideo/view/" + String(videoId)
                }
                else
                {
                    urlCheck = "store/video/view/" + String(group_id) + "/" + String(videoId)
                }
                
                parameterCheck = [ "menu": "1"]
            }
            else if videoProfileTypeCheck == "sitegroupvideo"{
                
                if sitevideoPluginEnabled_group == 1
                {
                    urlCheck = "advancedvideo/view/" + String(videoId)
                }
                else
                {
                    urlCheck = "advancedgroups/video/view/" + String(group_id) + "/" + String(videoId)
                }
                
                parameterCheck = [ "menu": "1"]
            }
            else{
                urlCheck = "advancedvideo/view/" + String(videoId)
                parameterCheck = ["gutter_menu": "1","menu" : "1"]
            }
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(parameterCheck as! Dictionary<String, String>, url: urlCheck, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Video Detail
                        if let video = succeeded["body"] as? NSDictionary {
                            self.videoDetailDic = video
                            if video["is_password"] as! Int == 1
                            {
                                if let response = video["response"] as? NSDictionary
                                {
                                    if let pass = response["password"]
                                    {
                                        
                                        self.passstr = String(describing: pass)
                                        self.passwordAlert(pass : self.passstr)
                                    }
                                    
                                }
                                
                            }
                            else
                            {
                                self.bindData(video: self.videoDetailDic!)
                            }
                            
                        }
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                    }
                    else
                    {
                        //Handle Server Side Error
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
    // MARK: -Bind Server Data
    func bindData(video:NSDictionary)
    {
        // Update Video Gutter Menu
        if let menu = video["gutterMenu"] as? NSArray{
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
            
            if logoutUser == false
            {
                
                let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                rightNavView.backgroundColor = UIColor.clear
                
                let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                shareButton.setImage(UIImage(named: "upload")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                shareButton.addTarget(self, action: #selector(AdvanceVideoProfileViewController.shareItem), for: .touchUpInside)
                rightNavView.addSubview(shareButton)
                
                let optionButton = createButton(CGRect(x: 44,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                optionButton.setImage(UIImage(named: "option")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                optionButton.addTarget(self, action: #selector(AdvanceVideoProfileViewController.showGutterMenu), for: .touchUpInside)
                // rightNavView.addSubview(optionButton)
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
        
        if let response = video["response"] as? NSDictionary {
            
            self.lineView1?.isHidden = false
            self.lineView2?.isHidden = false
            self.lineView3?.isHidden = false
            self.videoUrl = response["video_url"] as? String ?? ""
            if self.isComingFromDeepLink {
                if self.videoType == 3{
                    if self.isComingFromDeepLink{
                        moviePlayer.videoUrl = self.videoUrl
                        moviePlayer.setupPlayerView()
                        if let player = moviePlayer.player {
                            player.play()
                        }
                    }
                    else {
                        showToast(message: "Invalid Video url", controller: self, onView: true, time: 5.0)
                    }
                }
                else {
                    implemnetPlayer()
                }
            }
            else {
                if self.videoType == 3 {
                    //self.moviePlayer.player.prepareToPlay()
                    if let player = moviePlayer.player {
                        player.play()
                    }
                }
            }
            
            // set Video Title
            var videoInfo = ""
            self.contentUrl = response["content_url"] as? String
            self.videoTitleString = String(describing: response["title"]!)
            self.videoName.text = String(describing: response["title"]!)
            self.videoName.numberOfLines = 0
            self.videoName.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.shareTitle = ""
            self.owner_id = response["owner_id"] as? Int
            
            self.videoDateinfo.frame.origin.y = self.videoName.bounds.height
            self.ratingView.frame.origin.y = self.videoName.bounds.height
            let categoryTitle = response["category"] as? String
            if categoryTitle != nil{
                videoInfo += "in \(categoryTitle!)"
            }
            if let date = response["creation_date"] as? String{
                let postedOn = dateDifference(date)
                if (videoInfo == ""){
                    videoInfo += "\(postedOn)"
                }else{
                    videoInfo += " - \(postedOn)"
                }
                
            }
            
            if let tags = response["tags"] as? NSDictionary{
                var str = ""
                for tag in tags{
                    str += "#\(tag.value), "
                }
                if str != "" {
                    //str = str.substring(to: str.index(str.startIndex, offsetBy: str.length-2))
                    str = String(str[..<str.index(str.startIndex, offsetBy: str.length - 2)])
                    videoInfo += "\n \(str)"
                }
            }
            
            self.videoDateinfo.setText(videoInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                var boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZENormal, nil)
                let largeBoldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                
                if categoryTitle != nil{
                    let range = (videoInfo as NSString).range(of: categoryTitle!)
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                }
                boldFont =  CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZENormal, nil)
                
                let range2 = (videoInfo as NSString).range(of: self.videoTitleString)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: largeBoldFont, range: range2)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range2)
                
                // TODO: Clean this up...
                
                return mutableAttributedString
            })
            self.videoDateinfo.numberOfLines = 0
            self.videoDateinfo.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.videoDateinfo.sizeToFit()
            self.bottomView.frame.size.height = self.videoDateinfo.frame.size.height + 35
            // Update Video Action Menus like,comment,add to playlist,watch etc
            if let menu = video["menus"] as? NSArray{
                self.actionMenu = menu
                self.createactionMenus()
            }
            
            if categoryTitle != nil{
                let range1 = (videoInfo as NSString).range(of: categoryTitle!)
                self.videoDateinfo.addLink(toTransitInformation: ["id" : (response["category_id"] as? Int)!, "type" : "category_id"], with:range1)
            }
            
            self.imgUser.isHidden = false
            if ((response["main_channel_id"] as? Int) != nil) && ((response["main_channel_id"] as? Int) != 0)
            {
                self.channelId = response["main_channel_id"] as! Int
                // Owner Image
                if response["channel_image"] is String {
                    if let url = URL(string: (response["channel_image"] as? String)!){
                        self.imgUser.kf.indicatorType = .activity
                        (self.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        self.imgUser.kf.setImage(with: url as URL?, placeholder: UIImage(named: "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                    }
                }
                if response["channel_title"] is String {
                    if let ownerName = response["channel_title"] as? String {
                        self.ownerName.text = ownerName
                    }
                }
                if let is_subscribe = response["is_subscribe"] as? Int {
                    if is_subscribe == 0
                    {
                        self.btnSubscribe.setTitle(NSLocalizedString("SUBSCRIBE", comment: ""), for: .normal)
                        self.issubscribe = false
                    }
                    else
                    {
                        self.btnSubscribe.setTitle(NSLocalizedString("SUBSCRIBED", comment: ""), for: .normal)
                        self.issubscribe = true
                    }
                }
                self.btnSubscribe.isHidden = false
            }
            else
            {
                // Owner Image
                if let url = URL(string: response["owner_image_normal"] as! String){
                    self.imgUser.kf.indicatorType = .activity
                    (self.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    self.imgUser.kf.setImage(with: url as URL?, placeholder: UIImage(named: "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                if let ownerName = response["owner_title"] as? String {
                    self.ownerName.text = ownerName
                }
                self.btnSubscribe.isHidden = true
            }
            
            if let rated = response["rated"] as? Bool{
                self.rated = rated
            }
            if let rating = response["rating"] as? Int{
                self.viewCount = (response["view_count"] as? Int)!
                self.updateRating(rating, ratingCount: (response["rating"] as? Int)!)
            }
            
            descriptionLabel.frame =  CGRect(x: 5, y:self.topView.bounds.height + self.topView.frame.origin.y , width: view.bounds.width - 5, height: 20)
            //self.descriptionLabel.frame.origin.y = self.topView.bounds.height + self.topView.frame.origin.y
            let descriptionResponse = response["description"] as? String
            let description = descriptionResponse?.html2String
            let linkColor = UIColor.blue
            let linkActiveColor = UIColor.blue
            self.descriptionLabel.linkAttributes = [kCTForegroundColorAttributeName as AnyHashable : linkColor.cgColor,kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: true as Bool)]
            self.descriptionLabel.activeLinkAttributes = [NSAttributedString.Key.foregroundColor : linkActiveColor]
            self.descriptionLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
            self.descriptionLabel.enabledTextCheckingTypes = NSTextCheckingAllTypes
            self.descriptionLabel.isUserInteractionEnabled = true
            if description != nil
            {
                self.descriptionLabel.text = "\n " + String(description!)
                self.descriptionShareContent = descriptionResponse!
            }
            self.descriptionLabel.lineBreakMode = NSLineBreakMode.byCharWrapping
            self.descriptionLabel.sizeToFit()
            descriptionLabel.delegate = self
            
            if description == ""
            {
                self.lineView3?.isHidden = true
                self.descriptionLabel.frame.size.height = 0
                self.videoListObj.headerheight =  self.descriptionLabel.frame.origin.y + 5
            }
            else
            {
                self.lineView3?.isHidden = false
                self.lineView3?.frame.origin.y = self.descriptionLabel.frame.size.height + self.descriptionLabel.frame.origin.y + 13
                self.videoListObj.headerheight = self.descriptionLabel.frame.size.height + self.descriptionLabel.frame.origin.y + 20
            }
        }
        
        if let videos = video["relatedVideo"] as? NSArray
        {
            self.advancevideos = videos as [AnyObject]
            self.videoListObj.globalvideoList = self.advancevideos
            DispatchQueue.main.async {
                self.videoListObj.tableView.reloadData()
            }
            
        }
        else
        {
            self.videoListObj.tableView.reloadData()
            //  self.emptylistingMessage(msg: "video")
            
        }
    }
    
    func feedRemoveInTikTokArray()
    {
        for (index,feed) in feedArrayTikTok.enumerated()
        {
            if let activityFeed = feed as? NSDictionary
            {
                if let attachment = activityFeed["attachment"] as? NSArray
                {
                    if attachment.count != 0
                    {
                        let attechmentDic = attachment[0] as! NSDictionary
                        if let attachment_id = attechmentDic["attachment_id"] as? Int
                        {
                            if attachment_id == videoId
                            {
                                feedArrayTikTok.remove(at: index)
                            }
                        }
                    }
                }
            }
        }
        
        delegateAdvanceVideoUI?.updateTikTokTable(videoId : videoId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension AdvanceVideoProfileViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.popover.dismiss()
        if (indexPath as NSIndexPath).row == 0{
            var sharingItems = [AnyObject]()
            if let url = self.contentUrl {
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
            
            
        }else if (indexPath as NSIndexPath).row == 1{
            let pv = AdvanceShareViewController()
            pv.url = self.shareUrl
            pv.param = self.shareParam as! [AnyHashable : Any] as NSDictionary
            pv.Sharetitle = self.videoTitleString
            pv.imageString = coverImage
            if (self.descriptionShareContent != nil) {
                pv.ShareDescription = self.descriptionShareContent!
            }
            pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: pv)
            self.present(nativationController, animated:true, completion: nil)
            
            
        }else if (indexPath as NSIndexPath).row == 2{
            UIPasteboard.general.url = URL(string: self.contentUrl)
            showToast(message: NSLocalizedString("Link copied.",comment: ""), controller: self)
        }
        
    }
    
}

extension AdvanceVideoProfileViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return ShareOption.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.font = UIFont(name: "FontAwesome", size: 16.0)
        cell.textLabel?.textColor = UIColor.darkGray
        cell.textLabel?.text = ShareOption[(indexPath as NSIndexPath).row]
        return cell
        
    }
}
// Download video file
class Downloader {
    class func load(url: URL, to localUrl: URL, completion: @escaping (_ status:Bool) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if ((response as? HTTPURLResponse)?.statusCode) != nil {
                    //print("Success: \(statusCode)")
                }
                do
                {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion(true)
                }
                catch ( _)
                {
                    //print("error writing file \(localUrl) : \(writeError)")
                    completion(true)
                    
                }
                
            }
            else
            {
                //print("Failure: %@", error?.localizedDescription as Any);
                completion(false)
            }
        }
        task.resume()
    }
}

extension AdvanceVideoProfileViewController : VideoChangeDelegate
{
    func didNewVideoClicked(dict: [String : Any]) {
        videoProfileTypeCheck = ""
        videoId = dict["video_id"] as! Int
        videoType = dict["type"] as? Int
        videoUrl = dict["video_url"] as! String
        if moviePlayer != nil
        {
            moviePlayer.player!.pause()
        }
        imageView.alpha = 0
        implemnetPlayer()
        self.exploreVideo()
        
    }
    
    
}

extension AdvanceVideoProfileViewController: AVPlayerViewControllerDelegate {
    
}

