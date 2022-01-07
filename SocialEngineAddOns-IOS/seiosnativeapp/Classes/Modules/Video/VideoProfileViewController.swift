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

//  VideoProfileViewController.swift

import UIKit
import MediaPlayer
import WebKit
var videoProfileUpdate:Bool!

class VideoProfileViewController: UIViewController, TTTAttributedLabelDelegate, UIScrollViewDelegate, WKNavigationDelegate{
    
    var videoType :Int?
    var videoUrl: String!
    var videoId :Int!
    var popAfterDelay:Bool!
    var videoTitle : TTTAttributedLabel! // Video stats
    var moviePlayer:CustomVideoPlayer!
    var videoDescription : UITextView!
    var videoWebView = WKWebView()
    var ratingView : UIView!
    var rated: Bool! = false
    var gutterMenu: NSArray = []
    var videoName : UILabel!
    var topView: UIView!
    var ownerName : UILabel!
    var imgUser : UIImageView!
    var descriptionLabel : UITextView!
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
    var like_comment : UIView!
    
    var event_id : Int!
    var videoProfileTypeCheck = ""
    
    var rightBarButtonItem : UIBarButtonItem!
    var imageView : UIImageView!
    
    var sharable: Bool = false
    var listingId : Int!
    var listingTypeId : Int!
    var leftBarButtonItem : UIBarButtonItem!
    var subjectType:String!
    fileprivate var popover: Popover!

    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        videosUpdate = false
        videoProfileUpdate = true
        popAfterDelay = false
        subjectType = "video"

        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(VideoProfileViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        removeNavigationImage(controller: self)
        
        var playerHeight: CGFloat = 400
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            playerHeight = 200
        }
        
        self.navigationItem.rightBarButtonItem = nil
        playerHeight += TOPPADING - contentPADING
        
        if videoType == 3{
            moviePlayer = CustomVideoPlayer(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: playerHeight), url: self.videoUrl, isFromVideoProfilePage: true, vc: self)
            self.view.addSubview(moviePlayer)
            
            do
            {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
                try AVAudioSession.sharedInstance().setActive(true)
            }
            catch _ as NSError
            {
                //print(error)
            }
            
        }
        else{
            var url = ""
            if videoType == 1 || videoType == 2 || videoType == 4 || videoType == 5{
                
                url = "https://" + videoUrl
            }
            else{
                url = videoUrl!
            }
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
            
            
           // self.view.addSubview(videoWebView)
            let jeremyGif = UIImage.gifWithName("progress bar")
            
            // Use the UIImage in your UIImageView
            imageView = UIImageView(image: jeremyGif)
            imageView.frame = CGRect(x: 105,y: 140 ,width: 120, height: 7)
            
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
            
            
//            if let videoURL =  URL(string:url)
//            {
//                //print("loading......")
//
//                videoWebView.loadRequest(URLRequest(url: videoURL))
//
//                do
//                {
//                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
//                    try AVAudioSession.sharedInstance().setActive(true)
//                } catch _ as NSError {
//                    //print(error)
//                }
//
//            }
//            else
//            {
//                if videoType == 6 || !videoUrl.starts(with: "http")
//                {
//                    videoWebView.loadHTMLString(videoUrl, baseURL: nil)
//                }
//            }
            
            view.addSubview(videoWebView)
            videoWebView.addSubview(imageView)
        }

        scrollView = UIScrollView(frame: CGRect(x: 0, y: playerHeight , width: view.bounds.width, height: view.bounds.height - playerHeight - tabBarHeight))
        scrollView.backgroundColor = bgColor
        scrollView.delegate = self
        scrollView.contentSize = view.bounds.size
        scrollView.sizeToFit()
        view.addSubview(scrollView)
        
        topView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 70), borderColor: UIColor.clear, shadow: false)
        topView.backgroundColor = lightBgColor
       // topView.layer.shadowOffset = CGSize(width: 0,height: 0)
        //topView.layer.shadowOpacity = 0.0
       // topView.layer.borderWidth = 0.0
        scrollView.addSubview(topView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(VideoProfileViewController.handleTap))
        topView.addGestureRecognizer(tap)
        
        ownerName = createLabel(CGRect(x: 65, y: 20, width: view.bounds.width, height: 30), text: "", alignment: .left, textColor: textColorDark)
        ownerName.font = UIFont(name: fontName, size: FONTSIZENormal)
        ownerName.longPressLabel()
        topView.addSubview(ownerName)
        
        imgUser = createImageView(CGRect(x: 10, y: 10, width: 50, height: 50), border: true)
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.clear.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.image = UIImage(named: "user_profile_image.png")
        imgUser.clipsToBounds = true
        topView.addSubview(imgUser)
        
        bottomView = createView(CGRect(x: 0,  y: 75 , width: view.bounds.width, height: 80), borderColor: UIColor.clear, shadow: false)
        bottomView.backgroundColor = lightBgColor
       // bottomView.layer.shadowOffset = CGSize(width: 0,height: 0)
       // bottomView.layer.shadowOpacity = 0.0
       // bottomView.layer.borderWidth = 0.0
        
        scrollView.addSubview(bottomView)
        videoName = createLabel(CGRect(x: PADING*2, y: 10 , width: view.bounds.width - 2*PADING, height: 30),text: "", alignment: .left, textColor: textColorDark)
        videoName.longPressLabel()
        videoName.font = UIFont(name: fontName, size: FONTSIZEMedium)
        bottomView.addSubview(videoName)
        
        // Set Video Title
        videoTitle = TTTAttributedLabel(frame: CGRect(x: PADING*2, y: 35 , width: view.bounds.width - 2*PADING - 150, height: 70))
        videoTitle.numberOfLines = 0
        videoTitle.delegate = self
        videoTitle.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
        videoTitle.textColor = textColorMedium
        videoTitle.longPressLabel()
        videoTitle.font = UIFont(name: fontName, size: FONTSIZESmall)
        bottomView.addSubview(videoTitle)
        
        ratingView = UIView(frame: CGRect(x: view.bounds.width - PADING*2 - 130, y: 50, width: 150, height: 30))
        bottomView.addSubview(ratingView)
        
        descriptionLabel = UITextView(frame: CGRect(x: 5, y: scrollView.frame.size.height , width: view.bounds.width - 5, height: 100))
        descriptionLabel.isEditable = false
        descriptionLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        descriptionLabel.textColor = textColorDark
        descriptionLabel.dataDetectorTypes = UIDataDetectorTypes.all
        descriptionLabel.linkTextAttributes = [ .foregroundColor: buttonColor]
        descriptionLabel.backgroundColor = bgColor
        
        //descriptionLabel.editable = false
        scrollView.addSubview(descriptionLabel)
        
        // Like , Comment
        likeCommentContent_id = "\(videoId!)"
        likeCommentContentType = "video"
        like_CommentStyle = 1
        like_comment = Like_CommentView()
        like_comment.layer.shadowColor = shadowColor.cgColor
        like_comment.alpha = 1
        like_comment.layer.shadowOffset = shadowOffset
        like_comment.layer.shadowRadius = shadowRadius
        like_comment.layer.shadowOpacity = shadowOpacity
        view.addSubview(like_comment)
        
        self.automaticallyAdjustsScrollViewInsets = true;
        
 
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation - webView.url: \(String(describing: webView.url?.description))")
        imageView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish - webView.url: \(String(describing: webView.url?.description))")
        imageView.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        removeNavigationImage(controller: self)
    }
    // Explore Video Detail On View Appear
    override func viewDidAppear(_ animated: Bool) {
        removeNavigationImage(controller: self)
        if videoProfileUpdate == true{
            videoProfileUpdate = false
            exploreVideo()
        }
    }
    
    // MARK: - Update Rating Function
    
    func updateRating(_ rating:Int, ratingCount:Int){
        
        for ob in ratingView.subviews{
            ob.removeFromSuperview()
        }
        
        var origin_x = 15 as CGFloat
        
        for i in stride(from: 1, through: 5, by: 1){
            let rate = createButton(CGRect(x: origin_x, y: 10, width: 20, height: 20), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clear
            rate.setImage(UIImage(named: "star.png"), for: UIControl.State() )
            
            if rated == false{
                rate.tag = i
                rate.addTarget(self, action: #selector(VideoProfileViewController.rateAction(_:)), for: .touchUpInside)
            }else{
                if i <= rating{
                    rate.setImage(UIImage(named: "yellowStar.png"), for: UIControl.State() )
                }
                rate.addTarget(self, action: #selector(VideoProfileViewController.cannotRateAction(_:)), for: .touchUpInside)
            }
            origin_x += 22
            ratingView.addSubview(rate)
        }
        
        var totalRated = ""
        totalRated = singlePluralCheck( NSLocalizedString(" rating", comment: ""),  plural: NSLocalizedString(" ratings", comment: ""), count: ratingCount)
        
        let ratedInfo = createLabel(CGRect(x: (ratingView.center.x - 50), y: 30,width: 100 , height: 20),text: totalRated, alignment: .center, textColor: textColorMedium)
        ratedInfo.font = UIFont(name: fontName, size:FONTSIZESmall)
        ratingView.addSubview(ratedInfo)
    }
    
    // Rate Action
    
    @objc func rateAction(_ sender:UIButton){

        if Reachabable.isConnectedToNetwork() {

            removeAlert()
            
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
                
                rateUrl = "videos/rate/" + String(videoId)
                
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
                                self.updateRating(sender.tag, ratingCount: (body["rating_count"] as? Int)! )
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
                if dic["name"] as! String == "share"{
                }else{
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
                    }else{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Video Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                                
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
    
    // MARK: - Server Connection For Video Updation
    
    // Explore Video Detail
    func exploreVideo(){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            // Checkin calling
//
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
                urlCheck = "advancedevents/video/" + String(event_id) + "/" + String(videoId)
            }

           else if videoProfileTypeCheck == "listings"{
                //videoType = ""
               parameterCheck = ["video_id": String(videoId), "gutter_menu": "1","listingtype_id" : String(listingTypeId)]
                if sitevideoPluginEnabled_mlt == 1
                {
                        urlCheck = "advancedvideo/view/" + String(listingId)
                }
                else
                {
                    urlCheck = "listings/video/view/" + String(listingId)
                }
                
            }
            else if videoProfileTypeCheck == "sitegroupvideo"{
                
                urlCheck = "advancedgroups/video/view/" + String(event_id) + "/" + String(videoId)
                parameterCheck = [ "menu": "1"]
            }
            else{
                urlCheck = "videos/view"
                parameterCheck = ["video_id": String(videoId) , "gutter_menu": "1"]
            }
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(parameterCheck as! Dictionary<String, String>, url: urlCheck, method: "GET") { (succeeded, msg) -> () in

                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Video Detail
                        
                        if let video = succeeded["body"] as? NSDictionary {
                            
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
                                
                                if logoutUser == false{

                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    shareButton.addTarget(self, action: #selector(VideoProfileViewController.shareItem), for: .touchUpInside)
                                    rightNavView.addSubview(shareButton)
                                    
                                    let optionButton = createButton(CGRect(x: 44,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    optionButton.addTarget(self, action: #selector(VideoProfileViewController.showGutterMenu), for: .touchUpInside)
                                    //rightNavView.addSubview(optionButton)
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
                                if self.videoType == 3{
                                    self.moviePlayer.player?.play()
                                }
                                // set Video Title
                                var videoInfo = ""
                                self.contentUrl = response["content_url"] as? String
                                self.videoTitleString = String(describing: response["title"]!)
                                self.videoName.text = String(describing: response["title"]!)
                                self.videoName.numberOfLines = 0
                                self.videoName.lineBreakMode = NSLineBreakMode.byWordWrapping
//                                self.videoName.sizeToFit()
//                                self.videoName.backgroundColor = UIColor.yellow
                                self.shareTitle = ""
                                
                                self.owner_id = response["owner_id"] as? Int
                                
                                // Owner Image
                                
                                if let url = URL(string: response["owner_image_normal"] as! String){
                                    self.imgUser.kf.indicatorType = .activity
                                    (self.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    self.imgUser.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        
                                    })
                                }
                                
                                self.videoTitle.frame.origin.y = self.videoName.bounds.height
                                self.ratingView.frame.origin.y = self.videoName.bounds.height
                                let categoryTitle = response["category"] as? String
                                if categoryTitle != nil{
                                    videoInfo += "\n in \(categoryTitle!)"
                                }
                                if let date = response["creation_date"] as? String{
                                    let postedOn = dateDifference(date)
                                    if (videoInfo == ""){
                                        videoInfo += "\n \(postedOn)"
                                    }else{
                                        videoInfo += "\n \(postedOn)"
                                    }
                                    let viewCount = response["view_count"] as? Int
                                    videoInfo += ", "
                                    videoInfo += singlePluralCheck( NSLocalizedString(" view", comment: ""),  plural: NSLocalizedString(" views", comment: ""), count: viewCount!)
                                }
                                
                                if let tags = response["tags"] as? NSDictionary{
                                    var str = ""
                                    for tag in tags{
                                        str += "#\(tag.value), "
                                    }
                                    if str != "" {
                                       // str = str.substring(to: str.index(str.startIndex, offsetBy: str.length-2))
                                        str = String(str[..<str.index(str.startIndex, offsetBy: str.length - 2)])
                                        videoInfo += "\n \(str)"
                                    }
                                }
                                
                                self.videoTitle.setText(videoInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
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
                                
                                self.videoTitle.numberOfLines = 0
                                self.videoTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                                self.videoTitle.sizeToFit()
                                //self.videoTitle.backgroundColor = UIColor.red
                                if categoryTitle != nil{
                                    let range1 = (videoInfo as NSString).range(of: categoryTitle!)
                                    self.videoTitle.addLink(toTransitInformation: ["id" : (response["category_id"] as? Int)!, "type" : "category_id"], with:range1)
                                }
                                
                                if let ownerName = response["owner_title"] as? String {
                                    self.ownerName.text = ownerName
                                }
                                if let rated = response["rated"] as? Bool{
                                    self.rated = rated
                                }
                                if let rating = response["rating"] as? Int{
                                    self.updateRating(rating, ratingCount: (response["rating"] as? Int)!)
                                }
                                self.bottomView.frame.size.height = self.videoName.bounds.height + self.videoTitle.bounds.height + 10
                                self.descriptionLabel.frame.origin.y = self.bottomView.bounds.height + self.bottomView.frame.origin.y
                                
                                let descriptionResponse = response["description"] as? String ?? ""
                                self.setDescripion(desc: descriptionResponse, label: self.descriptionLabel)
                                self.descriptionShareContent = descriptionResponse
                                self.descriptionLabel.sizeToFit()
                                self.scrollView.contentSize.height =  self.descriptionLabel.bounds.height + self.descriptionLabel.frame.origin.y + 50
                                self.scrollView.sizeToFit()
                            }
                            
                        }
                        if succeeded["message"] != nil{
                           showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                    }else{
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

    
    func setDescripion(desc: String, label: UITextView) {
        let modifiedFont = String(format:"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size: \(16)\">%@</span>", desc)
        if let htmlData = modifiedFont.data(using: String.Encoding.unicode) {
            do {
                let attributedText = try NSAttributedString(data: htmlData,
                                                            options: [.documentType:NSAttributedString.DocumentType.html],
                                                            documentAttributes: nil)
                label.attributedText = attributedText
                
            } catch _ as NSError {
                label.text = desc
            }
        }
    }
    func updateVideoMenuAction(_ url : String){
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
            // Send Server Request to Explore Video Contents with Video_ID
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        
                        videosUpdate = true
                        if self.videoProfileTypeCheck == "AdvEventProfile"{
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                        
                        showToast(message: NSLocalizedString("Video has been deleted successfully",comment: ""), controller: self)
                        
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
    @objc func goBack()
    {
        if videoType == 3
        {
            moviePlayer.player?.pause()
        }
        if conditionalProfileForm == "BrowsePage"
        {

            videosUpdate = true
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
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
        if let player = self.moviePlayer
        {
            player.stop()
        }
        return true
    }
    
    

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        arrowView.isHidden = true
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        let scrollOffset = scrollView.contentOffset.y
        if (scrollOffset > 60.0){
            self.like_comment.fadeOut()
        }else{
            self.title = ""
            if (scrollOffset < 10.0){
                self.title = ""
                self.like_comment.fadeIn()
            }
        }
    }
    
    @objc func cannotRateAction(_ sender:UIButton){
        showToast(message: NSLocalizedString("You already rated this video",comment: ""), controller: self)
    }
    
    @objc func handleTap() {
        if (self.owner_id != nil){
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(self.owner_id)"
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        if let player = self.moviePlayer
        {
            player.player?.pause()
        }
        self.navigationItem.rightBarButtonItem = nil
        setNavigationImage(controller: self)
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
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        let type = components["type"] as! String
        switch(type){
        case "category_id":
            videosUpdate = true
            searchDic.removeAll(keepingCapacity: false)
            let id = components["id"] as! Int
            searchDic["category"] = String(id)
            let presentedVC = VideoSearchViewController()
            presentedVC.searchPath = "videos/search-form"
            self.navigationController?.pushViewController(presentedVC, animated: false)
            let url : String = "videos/search-form"
            loadFilter(url)
            
        default:
            print("default")
            
        }
        
    }
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension VideoProfileViewController: UITableViewDelegate {
    
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

extension VideoProfileViewController: UITableViewDataSource {
    
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
