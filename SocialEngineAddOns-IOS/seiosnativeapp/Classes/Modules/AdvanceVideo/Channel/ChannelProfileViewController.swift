//
//  ChannelProfileViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 16/06/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
var channelProfileUpdate =  false
var issubscribe : Int = 0
class ChannelProfileViewController: UIViewController,TTTAttributedLabelDelegate,UIScrollViewDelegate,UITabBarControllerDelegate{

    var subjectId:String = ""
    var subjectType:String = ""
    var contentTitle : String!
    var gutterMenu: NSArray = []
    var actionMenu: NSArray = [] // Array for Gutter Menu
    var imgUser : UIImageView!
    var ownerName : UILabel!
    var user_id : Int!
    var headerView : UIView!
    var headerImageView : UIImageView!
    var headerTitle : TTTAttributedLabel!
    var channelViewTile : UILabel!
    var channelCreatedOn : UILabel!
    var tabsContainerMenu:UIScrollView!
    var topView : UIView!
    var profileImageUrlString : String!
    var headerImage1 : UIImageView!
    var channelName:String!
    var popAfterDelay:Bool!
    var channelInfo : TTTAttributedLabel!
    var allPhotos = [AnyObject]()
    var channelTableView:UITableView!
    var dynamicHeight:CGFloat = 100
    var photos:[PhotoViewer] = []
    var descriptionResult: String!
    var pageNumber:Int = 1
    var videoPageNumber: Int = 1
    var totalItems:Int = 0
    var isPageRefresing = false
    var updateScrollFlag = true
    var refresher:UIRefreshControl!
    var showSpinner = true
    var deletechannel: Bool!
    var descView : TTTAttributedLabel!
    var like_comment : UIView!
    var height : CGFloat = 0
//    var imageCache = [String:UIImage]()
//    var imageCache1 = [String:UIImage]()
    var lastContentOffset: CGFloat = 0
    var showNavColor = false
    var photoId : Int!
    var contentType = ""
    var urlPath = ""
    var pageId : Int!
    var marqueeHeader : MarqueeLabel!
    var contentId: Int!
    var leftBarButtonItem : UIBarButtonItem!
    var groupId : Int!
    var contentDescription : String!
    var coverImageUrl : String!
    var rightBarButtonItem : UIBarButtonItem!

    var channelTitleString : String!
    var descriptionShareContent:String!
    var contentImage: String!
    var shareUrl : String!
    var shareParam : NSDictionary!
    var shareTitle : String!
    var sharable: Bool = false
    var contentUrl : String!
    var shareLimit : Int = 32
    var owner_id : Int!
    var videoProfileTypeCheck = ""
    var channelvideos = [AnyObject]()
    var channelVideosPerPage = [AnyObject]()
    var videoListObj = videoListTableViewController()
    var channelVideoCount = 0
    var feedObj = FeedTableViewController()
    var maxid:Int!                              // MaxID for Pagination
    var minid:Int!                              // MinID for New Feeds
    var deleteFeed = false                      // Flag for Delete Feed Updation
    var feedFilter: UIButton!                   // Feed Filter Option
    var activityFeeds:[ActivityFeed] = []       // To save Activity Feeds from Response (subclass of ActivityFeed)
    var tempcontentFeedArray = [Int:AnyObject]()       // Hold TemproraryFeedMenu for Hide Row (Undo, HideAll)
    var feed_filter = 1                         // Set Value for Feed Filter options in browse
    var feedFilterFlag = false
    var menuOptionSelected:String!
    var dynamicRowHeight = [Int:CGFloat]()
    var filterGutterMenu: NSArray = []
    var toastView : UIView!
    var checkInvite : Int = 0
    var info : UILabel!
    var selectedTabmenu : String = ""
    var selectedTab:Int!
    private var dismissEmojiView: UITapGestureRecognizer?
    override func viewDidLoad() {
        
        channelProfileUpdate = false
        subject_unique_id = subjectId
        subject_unique_type = subjectType
        self.tabBarController?.delegate = self
        maxid = 0
        maxidTikTok = 0
        removeNavigationImage(controller: self)
        navigationButtons()
        self.view.backgroundColor = textColorLight
        self.automaticallyAdjustsScrollViewInsets = false
        // Add header on view
        createHeaderview()
        tableframeY = 0
        videoListObj.tableView.addSubview(headerView)
        videoListObj.headerheight = headerView.frame.size.height + headerView.frame.origin.y
        self.view.addSubview(videoListObj.view)
        self.addChild(videoListObj)
        
        tableViewFrameType = "ChannelProfileViewController"
        NotificationCenter.default.addObserver(self, selector: #selector(ChannelProfileViewController.ScrollingactionAdvVideoChannel(_:)), name: NSNotification.Name(rawValue: "ScrollingactionAdvVideoChannel"), object: nil)
    
        explorechannel()


        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        feedObj.tableView.tableFooterView = footerView
        feedObj.tableView.tableFooterView?.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(moreVideos(notification:)), name: NSNotification.Name(rawValue: "checkMoreVideos"), object: nil)
        dismissEmojiView = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        
        if let tap = dismissEmojiView {
            
            view.addGestureRecognizer(tap)
            
        }
    }
    
    @objc private func dismissView() {
       
            scrollViewEmoji.isHidden = true
            arrowView.isHidden = true
       
    }

    
    override func viewDidAppear(_ animated: Bool)
    {
        like_CommentStyle = 1
        if (showNavColor == true)
        {
            setNavigationImage(controller: self)
        }
        else
        {
            removeNavigationImage(controller: self)
        }
    }
    override func viewWillAppear(_ animated: Bool){
        
        tableViewFrameType = "ChannelProfileViewController"
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.alpha = 1
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 40, y: 0, width: navigationBar.frame.width - 80, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
            
        }
        if (showNavColor == true)
        {
            setNavigationImage(controller: self)
        }
        else{
            removeNavigationImage(controller: self)
        }
        if channelProfileUpdate == true
        {
            conditionalProfileForm = ""
            channelProfileUpdate = false
            feedUpdate = false
            maxid = 0
            maxidTikTok = 0
            showSpinner = true
            feed_filter = 1
            searchDic.removeAll(keepingCapacity: false)
            updateAfterAlert = false
            
            if selectedTabmenu != "update"{
            self.explorechannel()
            }
            else
            {
                self.browseFeed()
            }
            
        }
        else
        {
            // Update Feed for showing instant like comment
            if selectedTabmenu == "update"
            {
                
                if logoutUser == false
                {
                    globalFeedHeight = getBottomEdgeY(inputView: self.feedFilter) + 12
                }
                else
                {
                    globalFeedHeight =  getBottomEdgeY(inputView: self.tabsContainerMenu)
                }
                self.feedObj.globalArrayFeed = contentFeedArray
                if !fromExternalWebView{
                    self.feedObj.refreshLikeUnLike = true
                    feedObj.tableView.reloadData()
                }else{
                    fromExternalWebView = false
                }
            }
        }

        maxidTikTok = 0
        API_getAAFList()
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        scrollviewEmojiLikeView.isHidden = true
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        feedObj.tableView.tableFooterView?.isHidden = true
        self.marqueeHeader.text = ""
        setNavigationImage(controller: self)
        removeMarqueFroMNavigaTion(controller: self)
        tableViewFrameType = ""
        
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }
    func createHeaderview()
    {
        headerView = UIView(frame : CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 270 + ButtonHeight))
        headerView.backgroundColor = UIColor.red
        headerView.isUserInteractionEnabled = true
        self.view.addSubview(headerView)
        
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 270)
        headerImageView = CoverImageViewWithGradient(frame: frame)
        headerImageView.backgroundColor = placeholderColor
        headerImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChannelProfileViewController.onImageViewTap))
        headerImageView.addGestureRecognizer(tap)
        headerView.addSubview(headerImageView)
        
        headerTitle = TTTAttributedLabel(frame:CGRect(x: 90, y: 210, width: view.bounds.width - 100 , height: 60))
        headerTitle.font = UIFont(name: fontName, size: 30.0)
        headerTitle.linkAttributes = [kCTForegroundColorAttributeName:textColorLight]
        headerTitle.textColor = textColorLight
        headerTitle.longPressLabel()
        headerTitle.numberOfLines = 0
        headerTitle.delegate = self
        headerImageView.addSubview(headerTitle)
        
        
        imgUser = createImageView(CGRect(x: 10, y: headerImageView.frame.size.height - 80, width: 70, height: 70), border: true)
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.clear.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.image = UIImage(named: "user_profile_image.png")
        imgUser.clipsToBounds = true
        headerImageView.addSubview(imgUser)
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(ChannelProfileViewController.openProfile))
        imgUser.addGestureRecognizer(tap1)
        
        tabsContainerMenu = UIScrollView(frame: CGRect(x: 0, y: headerImageView.frame.size.height,width: view.bounds.width ,height: ButtonHeight))
        tabsContainerMenu.delegate = self
        tabsContainerMenu.backgroundColor = tableViewBgColor
        tabsContainerMenu.showsHorizontalScrollIndicator = false
        tabsContainerMenu.showsVerticalScrollIndicator = false
        tabsContainerMenu.tag = 222
        headerView.addSubview(tabsContainerMenu)
    }
    func addfilterview()
    {
        feedFilter = createButton(CGRect(x: PADING, y: 2*contentPADING , width: view.bounds.width - 2 * PADING, height: ButtonHeight),title: NSLocalizedString("Everyone",  comment: "") , border: false, bgColor: false,textColor: textColorMedium)
        feedFilter.isEnabled = false
        feedFilter.backgroundColor = lightBgColor
        feedFilter.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        feedFilter.isHidden = true
        feedFilter.addTarget(self, action: #selector(ChannelProfileViewController.showFeedFilterOption(_:)), for: .touchUpInside)
        self.feedObj.tableView.addSubview(feedFilter)
        
        // Filter Icon on Left site
        let filterIcon = createLabel(CGRect(x: feedFilter.bounds.width - feedFilter.bounds.height, y: 0 ,width: feedFilter.bounds.height ,height: feedFilter.bounds.height), text: "\(searchFilterIcon)", alignment: .center, textColor: textColorMedium)
        filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        feedFilter.addSubview(filterIcon)
        
        
        // Initialize Pull to Refresh to ActivityFeed Table
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(ChannelProfileViewController.refresh), for: UIControl.Event.valueChanged)
        self.feedObj.tableView.addSubview(refresher)
        self.automaticallyAdjustsScrollViewInsets = false;

    }
    func navigationButtons()
    {
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ChannelProfileViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

    }

    @objc func goBack(){
        
        NotificationCenter.default.removeObserver(self)
        if conditionalProfileForm == "BrowsePage"
        {
            channelProfileUpdate = true
             _ = self.navigationController?.popViewController(animated: false)
//            _ = self.navigationController?.popToRootViewController(animated: true)
            
        }
        else
        {
            _ = self.navigationController?.popViewController(animated: false)
            
        }
        
    }
    @objc func onImageViewTap(){
        if self.profileImageUrlString != nil && self.profileImageUrlString != "" {
            let presentedVC = SinglePhotoLightBoxController()
            presentedVC.imageUrl = self.profileImageUrlString
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            present(nativationController, animated:false, completion: nil)
        }
    }
    @objc func openProfile(){
        if (self.user_id != nil){
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(user_id!)"
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {

    }
    // Explore Video Detail
    func explorechannel(){
        // Check Internet Connection
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
            self.view.isUserInteractionEnabled = false
             // Send Server Request to Explore Video Contents with Video_ID
            var urlCheck = ""
            var parameterCheck : NSDictionary = [ : ]
            urlCheck = "advancedvideo/channel/view/" + String(subjectId)
            parameterCheck = ["gutter_menu": "1","menu" : "1"]
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(parameterCheck as! Dictionary<String, String>, url: urlCheck, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    if msg{
                        // On Success Update Video Detail
                        if let video = succeeded["body"] as? NSDictionary
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
                                if logoutUser == false{
                                    
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    shareButton.addTarget(self, action: #selector(ChannelProfileViewController.shareItem), for: .touchUpInside)
                                    rightNavView.addSubview(shareButton)
                                    
                                    let optionButton = createButton(CGRect(x: 44,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    optionButton.addTarget(self, action: #selector(ChannelProfileViewController.showGutterMenu), for: .touchUpInside)
                                //    rightNavView.addSubview(optionButton)
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

                                // set Video Title
                                self.contentUrl = response["content_url"] as? String
                                self.channelTitleString = String(describing: response["title"]!)
                                self.contentTitle = self.channelTitleString
                                self.headerTitle.text = String(describing: response["title"]!)
                                self.headerTitle.numberOfLines = 0
                                self.headerTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                                self.headerTitle.sizeToFit()
                                if self.channelTitleString.length > 20{
                                    self.headerTitle.frame.origin.y = self.headerTitle.frame.origin.y - 30
                                }
                                if self.channelTitleString.length > 42
                                {
                                   self.headerTitle.frame.origin.y = self.headerTitle.frame.origin.y - 50
                                }
                                self.shareTitle = ""
                                self.owner_id = response["owner_id"] as? Int
                                if let menu = video["profile_tabs"] as? NSArray{
                                    if self.actionMenu.count == 0{
                                        self.actionMenu = menu
                                        self.showtabMenu()
                                    }
                                }
                                
                                if let ownerimageprofile = response["owner_image_profile"] as? String
                                {
                                    if ownerimageprofile != ""
                                    {
                                       let url = URL(string: ownerimageprofile)
                                        self.imgUser.kf.indicatorType = .activity
                                        (self.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                        self.imgUser.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                            
                                        })
                                    }
                                }
                                
                                if let image = response["image"] as? String
                                {
                                    if image != ""
                                    {
                                        let url = URL(string: image)
                                        self.headerImageView.kf.indicatorType = .activity
                                        (self.headerImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                        self.headerImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                            
                                        })
                                    }
                                    
                                }
                                if let subscribe = response["is_subscribe"] as? Int{
                                    if self.selectedTab == 0{
                                        issubscribe = subscribe
                                        likeCommentContent_id = self.self.subjectId
                                        likeCommentContentType = "sitevideo_channel"
                                        like_CommentStyle = 1
                                        self.like_comment = Like_CommentView()
                                        self.like_comment.layer.shadowColor = shadowColor.cgColor
                                        self.like_comment.layer.shadowOffset = shadowOffset
                                        self.like_comment.layer.shadowRadius = shadowRadius
                                        self.like_comment.layer.shadowOpacity = shadowOpacity
                                        self.view.addSubview(self.like_comment)
                                    }
                                }

                            }
                            
                        }
                        if self.selectedTab == 0{
                            self.browseVideos()
                        }
                        
                    }
                    else{
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
    @objc func browseVideos()
    {
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var url = ""
            
            var parameters = [String:String]()
            parameters["page"] = "\(self.videoPageNumber)"
            url = "advancedvideo/channel/videos/" + String(subjectId)
            post(parameters, url: url, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        // If Message in Response show the Message
                        if let videoresponse = succeeded["body"] as? NSDictionary
                        {
                            if let totalVideoCount = videoresponse["totalItemCount"] as? Int
                            {
                                self.channelVideoCount = totalVideoCount
                            }
                            if let videos = videoresponse["response"] as? NSArray
                            {
                                self.channelVideosPerPage.removeAll(keepingCapacity: false)
                                self.channelVideosPerPage = videos as [AnyObject]
                                self.channelvideos = self.channelvideos + self.channelVideosPerPage
                                self.videoListObj.globalvideoList = self.channelvideos
                                DispatchQueue.main.async
                                    {
                                        self.videoListObj.tableView.reloadData()
                                }
                                
                            }
                            else
                            {
                                self.emptylistingMessage(msg: "video")
                                
                            }
                            
                        }
                        
                    }
                })

            }
        }
        
        
    }
    //Showing message when response count is 0
    func emptylistingMessage(msg :String)
    {
        let contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: getBottomEdgeY(inputView: headerView) + 20,width: 60 , height: 60), text: NSLocalizedString("\(videoIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
        contentIcon.font = UIFont(name: "FontAwesome", size: 50)
        contentIcon.tag = 1000
       // self.view.addSubview(contentIcon)
        
        let info = createLabel(CGRect(x: 0, y: getBottomEdgeY(inputView: contentIcon),width: self.view.bounds.width   , height: 50), text: String(format: NSLocalizedString("No updates at this moment . Check again any \nother time.", comment: ""),msg), alignment: .center, textColor: textColorMedium)
        info.numberOfLines = 2
        info.font = UIFont(name: fontName, size: FONTSIZENormal)
        info.textAlignment = .center
        info.backgroundColor = .white
        info.tag = 1000
        self.feedObj.tableView.addSubview(info)
        
        let refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: getBottomEdgeY(inputView: info), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
        refreshButton.backgroundColor = bgColor
        refreshButton.layer.borderColor = navColor.cgColor
        refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        refreshButton.addTarget(self, action: #selector(ChannelProfileViewController.browseVideos), for: UIControl.Event.touchUpInside)
        
        refreshButton.layer.cornerRadius = 5.0
        refreshButton.layer.masksToBounds = true
       // self.view.addSubview(refreshButton)
        refreshButton.tag = 1000
        refreshButton.isHidden = false
        contentIcon.isHidden = false
    }

    func showtabMenu(){
        
        for ob in tabsContainerMenu.subviews{
            ob.removeFromSuperview()
        }
        var origin_x:CGFloat = 0
        var i : Int = 100
        for menu in actionMenu{
            if let menuItem = menu as? NSDictionary{
                
                var button_title = menuItem["label"] as! String
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                let width = findWidthByText(button_title) + 10
                let menu = createNavigationButton(CGRect(x: origin_x,y: 0 - contentPADING ,width: width , height: tabsContainerMenu.bounds.height + contentPADING) , title: button_title, border: true, selected: false)
                
                if menuItem["name"] as! String == "video"{
                    menu.setSelectedButton()
                    selectedTab = 0
                }
                else{
                    menu.setUnSelectedButton()
                }
                menu.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
                menu.tag = i
                menu.addTarget(self, action: #selector(ChannelProfileViewController.tabMenuAction(_:)), for: .touchUpInside)
                tabsContainerMenu.addSubview(menu)
                origin_x += width
                
            }
            i = i+1
        }
        tabsContainerMenu.contentSize = CGSize(width: origin_x, height: tabsContainerMenu.bounds.height)
        
    }
    
    @objc func tabMenuAction(_ sender:UIButton){
        selectedTabmenu = ""
        selectedTab = sender.tag
        for ob in self.view.subviews
        {
            if ob.tag == 1000
            {
                ob.removeFromSuperview()
                
            }
        }

        for menu in actionMenu{
            if let menuItem = menu as? NSDictionary{
                var button_title = menuItem["label"] as! String
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                if sender.titleLabel?.text == button_title{
                    if menuItem["name"] as! String == "update"{
                        sender.setSelectedButton()
                        feedObj.tableView.addSubview(headerView)
                        self.addfilterview()
                        selectedTabmenu = menuItem["name"] as! String
                        self.view.addSubview(feedObj.view)
                        self.addChild(feedObj)
                        if self.activityFeeds.count > 0
                        {
                            self.feedObj.refreshLikeUnLike = true
                            feedObj.tableView.reloadData()
                        }
                        else
                        {
                            browseFeed()
                            self.feedObj.refreshLikeUnLike = true
                            self.feedObj.tableView.reloadData()
                        }
                        
                    }
                    if menuItem["name"] as! String == "video"{
                        videoListObj.tableView.addSubview(headerView)
                        self.view.addSubview(videoListObj.view)
                        self.addChild(videoListObj)
                        self.likecommentView()
                        if self.channelvideos.count == 0 {
                            self.emptylistingMessage(msg: "video")
                        }
 
                    }
                    if menuItem["name"] as! String == "description"
                    {
                        let presentedVC = DescriptionViewController()
                        presentedVC.mytitle = "\((self.contentTitle)!)"
                        presentedVC.subjectId = subjectId
                        presentedVC.headertitle = "Description"
                        presentedVC.url = menuItem["url"] as! String
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    if menuItem["name"] as! String == "overview"
                    {
                        let presentedVC = DescriptionViewController()
                        presentedVC.mytitle = "\((self.contentTitle)!)"
                        presentedVC.subjectId = subjectId
                        presentedVC.url = "\((menuItem["url"])!)"
                        presentedVC.headertitle = "Overview"
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    if menuItem["name"] as! String == "information"
                    {
                        let presentedVC = UserInfoViewController()
                        presentedVC.contentId = subjectId
                        presentedVC.user_id = "45"
                        presentedVC.contentUrl = menuItem["url"] as! String
                        navigationController?.pushViewController(presentedVC,animated:true)
                    }
                    if menuItem["name"] as! String == "Subscriber"
                    {
                        let presentedVC = FriendListViewController()
                        presentedVC.contentType = "AdvVideo"
                        presentedVC.urlString = menuItem["url"] as! String
                        presentedVC.param = Dictionary<String, String>() as NSDictionary?
                        navigationController?.pushViewController(presentedVC, animated: true)

                    }
                    if menuItem["name"] as! String == "reviews"
                    {
                        let presentedVC = UserReviewViewController()
                        presentedVC.mytitle = "\((self.contentTitle)!)"
                        presentedVC.subjectId = "\(subjectId)"
                        presentedVC.contentType = "video"
                        if let totalItem = menuItem["totalItemCount"] as? Int
                        {
                            if totalItem > 0
                            {
                                presentedVC.count = totalItem
                                
                            }
                            
                        }
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    if menuItem["name"] as! String == "announcement"
                    {
                        let presentedVC = AnnouncementViewController()
                        presentedVC.mytitle = "\((self.contentTitle)!)"
                        presentedVC.subjectId = "\(subjectId)"
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    if menuItem["name"] as! String == "photos"{
                        
                            let presentedVC = PhotoListViewController()
                            presentedVC.mytitle = "\((self.contentTitle)!)"
                            presentedVC.url = menuItem["url"] as! String // "albums/view-content-album"
                            presentedVC.param = ["subject_type" : "sitevideo_album","subject_id":subjectId]
                            presentedVC.contentType = "sitevideo_photo"
                            self.navigationController?.pushViewController(presentedVC, animated: false)

                    }
                    if menuItem["name"] as! String == "coupons"
                    {
                        let presentedVC = CouponsBrowseViewController()
                        //presentedVC.contentType = "siteevent_photo"
                        let tempUrl = menuItem["url"] as! String
                        presentedVC.content_id = "\(subjectId)"
                        presentedVC.url = tempUrl
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                    }
                    
                }
            }
        }
        for ob in tabsContainerMenu.subviews
        {
            if ob .isKind(of: UIButton.self)
            {
                if sender.tag == 100 || sender.tag == 101
                {
                    (ob as! UIButton).setUnSelectedButton()
                    if ob.tag == sender.tag
                    {
                        (ob as! UIButton).setSelectedButton()
                        
                    }
                }
                
            }
        }

    }
    
    @objc func moreVideos(notification : NSNotification)
    {
       if self.channelvideos.count != self.channelVideoCount
       {
            self.videoPageNumber += 1
            browseVideos()
       }
    }
    
    func likecommentView()
    {
        likeCommentContent_id = "\(self.self.subjectId)"
        likeCommentContentType = "sitevideo_channel"
        like_CommentStyle = 1
        self.like_comment = Like_CommentView()
        self.like_comment.layer.shadowColor = shadowColor.cgColor
        self.like_comment.layer.shadowOffset = shadowOffset
        self.like_comment.layer.shadowRadius = shadowRadius
        self.like_comment.layer.shadowOpacity = shadowOpacity
        self.view.addSubview(self.like_comment)
    }
    
    //MARK:- TikTok API
    func API_getAAFList()
    {
        if Reachabable.isConnectedToNetwork()
        {
            var parameters = [String:String]()
            parameters = ["limit": "\(limit)","maxid": String(maxidTikTok),"feed_filter": "1","post_elements": "1","post_menus":"1","object_info":"1","getAttachedImageDimention":"0","filter_type":"video","onlyMyDeviceVideo":"1"]
            if subjectId != ""{
                parameters["subject_id"] = String(subjectId)
                subjectIdTikTok = "\(subjectId)"
            }
            else{
                subjectIdTikTok = ""
            }
            if subjectType != ""{
                parameters["subject_type"] = subjectType
                subjectTypeTikTok = subjectType
            }
            else{
                subjectTypeTikTok = ""
            }
            
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg {
                        
                        if succeeded["message"] != nil{
                           showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2)
                            
                        }
                        //print(succeeded)
                        // Set MaxId for Feeds Result
                        if maxidTikTok == 0
                        {
                            feedArrayTikTok.removeAll()
                        }
                        if let dicTemp = succeeded["body"] as? [String : AnyObject], let activity_feed = dicTemp["data"] as? NSArray
                        {
                            
                            if let maxid = dicTemp["maxid"] as? Int{
                                maxidTikTok = maxid
                            }
                            let activityFeeds:[ActivityFeed] = ActivityFeed.loadActivityFeedInfo(activity_feed)
                            self.updateFeedsArrayTikTok(feeds: activityFeeds)
                        }
                        else
                        {
                            // Handle Server Error
                            if succeeded["message"] != nil && enabledModules.contains("suggestion")
                            {
                                showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2)
                                
                            }
                        }
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2)
                        }
                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self, onView: false, time: 2)
        }
    }
    
    func updateFeedsArrayTikTok(feeds:[ActivityFeed]){
        var existingFeedIntegerArray = [Int]()
        for tempFeedArrays in feedArrayTikTok {
            existingFeedIntegerArray.append(tempFeedArrays["action_id"] as? Int ?? 0)
        }
        for feed in feeds{
            let newDictionary:NSMutableDictionary = [:]
            if feed.action_id != nil{
                newDictionary["action_id"] = feed.action_id
            }
            if feed.feed_privacy != nil{
                newDictionary["privacy"] = feed.feed_privacy
            }
            if feed.feed_privacyIcon != nil{
                newDictionary["privacy_icon"] = feed.feed_privacyIcon
            }
            
            if feed.subject_id != nil{
                newDictionary["subject_id"] = feed.subject_id
            }
            if feed.share_params_type != nil{
                newDictionary["share_params_type"] = feed.share_params_type
            }
            if feed.share_params_id != nil{
                newDictionary["share_params_id"] = feed.share_params_id
            }
            if feed.attachment != nil{
                newDictionary["attachment"] = feed.attachment
            }
            if feed.attactment_Count != nil{
                newDictionary["attactment_Count"] = feed.attactment_Count
            }
            if feed.comment != nil{
                newDictionary["comment"] = feed.comment
            }
            if feed.delete != nil{
                newDictionary["delete"] = feed.delete
            }
            if feed.share != nil{
                newDictionary["share"] = feed.share
            }
            if feed.comment_count != nil{
                newDictionary["comment_count"] = feed.comment_count
            }
            if feed.feed_createdAt != nil{
                newDictionary["feed_createdAt"] = feed.feed_createdAt
            }
            if feed.feed_menus != nil{
                newDictionary["feed_menus"] = feed.feed_menus
            }
            if feed.feed_footer_menus != nil{
                newDictionary["feed_footer_menus"] = feed.feed_footer_menus
            }
            if feed.feed_reactions != nil{
                newDictionary["feed_reactions"] = feed.feed_reactions
            }
            if feed.my_feed_reaction != nil{
                newDictionary["my_feed_reaction"] = feed.my_feed_reaction
            }
            if feed.feed_title != nil{
                newDictionary["feed_title"] = feed.feed_title
            }
            if feed.feed_Type != nil{
                newDictionary["feed_Type"] = feed.feed_Type
            }
            if feed.is_like != nil{
                newDictionary["is_like"] = feed.is_like
            }
            if feed.likes_count != nil{
                newDictionary["likes_count"] = feed.likes_count
            }
            if feed.subject_image != nil{
                newDictionary["subject_image"] = feed.subject_image
            }
            if feed.photo_attachment_count != nil{
                newDictionary["photo_attachment_count"] = feed.photo_attachment_count
            }
            if feed.object_id != nil{
                newDictionary["object_id"] = feed.object_id
            }
            if feed.object_type != nil{
                newDictionary["object_type"] = feed.object_type
            }
            if feed.params != nil{
                newDictionary["params"] = feed.params
            }
            if feed.tags != nil{
                newDictionary["tags"] = feed.tags
            }
            if feed.action_type_body_params != nil{
                newDictionary["action_type_body_params"] = feed.action_type_body_params
            }
            if feed.action_type_body != nil{
                newDictionary["action_type_body"] = feed.action_type_body
            }
            if feed.object != nil{
                newDictionary["object"] = feed.object
            }
            if feed.hashtags != nil{
                newDictionary["hashtags"] = feed.hashtags
            }
            if feed.userTag != nil{
                newDictionary["userTag"] = feed.userTag
            }
            if feed.decoration != nil{
                newDictionary["decoration"] = feed.decoration
            }
            if feed.wordStyle != nil{
                newDictionary["wordStyle"] = feed.wordStyle
            }
            if feed.publish_date != nil{
                newDictionary["publish_date"] = feed.publish_date
            }
            if feed.isNotificationTurnedOn != nil{
                newDictionary["isNotificationTurnedOn"] = feed.isNotificationTurnedOn
            }
            if feed.attachment_content_type != nil{
                newDictionary["attachment_content_type"] = feed.attachment_content_type
            }
            if feed.pin_post_duration != nil{
                newDictionary["pin_post_duration"] = feed.pin_post_duration
            }
            if feed.isPinned != nil{
                newDictionary["isPinned"] = feed.isPinned
            }
            let actionId  = newDictionary["action_id"] as! Int
            if !existingFeedIntegerArray.contains(actionId){
                feedArrayTikTok.append(newDictionary)
            }
        }
        existingFeedIntegerArray.removeAll(keepingCapacity: true)
    }
    
    //MARK:Feed calling
    func browseFeed(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            API_getAAFList()
            removeAlert()
            // Remove new Activity Feed InfoLabel, NO Stories
            for ob1 in self.feedObj.tableView.subviews
            {
                if  ob1.tag == 1000{
                    ob1.removeFromSuperview()
                }
            }
            for ob in view.subviews{
                if ob.tag == 2020{
                    ob.removeFromSuperview()
                }
            }
            
            
            // Reset Objects for Hard Refresh Request
            if maxid == 0{
                
                if contentFeedArray.count == 0{
                    self.feedObj.tableView.reloadData()
                }
                
            }
            // Check for Show Spinner Position for Request
            if (showSpinner){
                activityIndicatorView.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-50 - (tabBarHeight))
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                self.view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
               // activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
                parameters = ["maxid":String(maxid!), "limit": "\(limit)","subject_id": String(subjectId) , "subject_type": subjectType , "post_menus":"1", "feed_filter": "1","getAttachedImageDimention":"0" ]

            // Set userinteractionflag for request
            userInteractionOff = false
            // Check for FeedFilter Option in Request
            if feedFilterFlag == true{
                parameters.merge(searchDic)
            }
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    // Reset Object after Response from server
                    userInteractionOff = true
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }else{
                        self.refresher.endRefreshing()

                    }
                     self.showSpinner = false
                    
                    self.feedObj.tableView.tableFooterView?.isHidden = true

                    
                    // On Success Update Feeds
                    if msg{
                        // If Message in Response show the Message
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        // Reset contentFeedArray for Sink with Feed Results
                        if self.maxid == 0{
                            self.feedObj.globalArrayFeed.removeAll(keepingCapacity: false)
                            contentFeedArray.removeAll(keepingCapacity: false)
                            self.dynamicRowHeight.removeAll(keepingCapacity: false)
                        }
                        self.activityFeeds.removeAll(keepingCapacity: false)
                    
                        // Check response of Activity Feeds
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            // Set MinId for Feeds Result
                            if let minID = response["minid"] as? Int{
                                self.minid = minID
                            }
                            // Check that whether Reaction Plugin is enable or not
                            if let reactionsEnable = response["reactionsEnabled"] as? Bool{
                                if reactionsEnable == true{
                                    if let reactions = response["reactions"] as? NSDictionary
                                    {
                                        reactionsDictionary = reactions
                                        ReactionPlugin = true
                                        self.browseEmoji(contentItems: reactions)
                                    }
                                }
                            }
                            else{
                                ReactionPlugin = false
                            }
                            
                            // Check for Feed Filter Options
                            if let menu = response["filterTabs"] as? NSArray{
                                self.feedFilter.isEnabled = true
                                self.filterGutterMenu = menu //as! [Any] as NSArray
                            }
                            
                            // Check for Feeds
                            if response["data"] != nil{
                                if let activity_feed = response["data"] as? NSArray{
                                    // Extract FeedInfo from response by ActivityFeed class
                                    self.activityFeeds = ActivityFeed.loadActivityFeedInfo(activity_feed)
                                    // Update contentFeedArray
                                    self.updateFeedsArray(self.activityFeeds)
                                }
                            }
                            
                            if self.feedFilter.isHidden == true{
                                self.feedFilter.isHidden = false
                            }
                            
                            
                            // Set MaxId for Feeds Result
                            
                            if let maxid = response["maxid"] as? Int{
                                self.maxid = maxid
                            }
                            
                            // Check for Post Feed Options
                            if response["feed_post_menu"] != nil{
                                if logoutUser == false{
                                    self.feedFilter.frame.origin.y = self.tabsContainerMenu.frame.origin.y + self.tabsContainerMenu.bounds.height + ButtonHeight + 38
                                }
                                else{
                                    self.feedFilter.frame.origin.y = self.tabsContainerMenu.frame.origin.y + self.tabsContainerMenu.bounds.height + 10
                                    self.feedFilter.isHidden = true
                                }
                                globalFeedHeight =  getBottomEdgeY(inputView: self.feedFilter) + 12
                                postPermission = response["feed_post_menu"] as! NSDictionary
                                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: postPermission), forKey: "postMenu")
                                if (logoutUser == false){
                                    self.postFeedOption()
                                }
                            }
                            
                            if logoutUser == true{
                                globalFeedHeight =  getBottomEdgeY(inputView: self.tabsContainerMenu)
                                self.feedFilter.isHidden = true
                            }
                            
                            if contentFeedArray.count == 0 {
                                
                                self.info  = createLabel(CGRect(x: 0,y: 270 + 10 + ButtonHeight,width: self.view.bounds.width , height: 60), text: NSLocalizedString("No updates at this moment . Check again any \nother time.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.info.backgroundColor = .white
                                self.info.numberOfLines = 0
                                self.info.textAlignment = .center
                                self.info.font = UIFont(name: fontName, size: FONTSIZENormal)
                                self.info.tag = 1000
                                self.feedObj.tableView.frame.size.height = self.view.bounds.height - 30
                                self.feedObj.tableView.addSubview(self.info)
                                self.info.isHidden = false

                            }
                            
                            // Reload Tabel After Updation
                            self.feedObj.globalArrayFeed = contentFeedArray
                            self.feedObj.refreshLikeUnLike = true
                            self.feedObj.tableView.reloadData()
                            if afterPost == true{
                                afterPost = false
                                
                                DispatchQueue.main.async(execute: {
                                    soundEffect("post")
                                })
                                
                            }
                            self.updateScrollFlag = true
                            self.activityFeeds.removeAll(keepingCapacity: false)
                        }
                        
                    }else{
                        // Show Message on Failour
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                            
                        }
                        self.updateScrollFlag = true
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            
        }
    }

    func browseEmoji(contentItems: NSDictionary)
    {
        scrollViewEmoji.backgroundColor = .clear
        arrowView.backgroundColor = .clear
        for ob in scrollViewEmoji.subviews{
            ob.removeFromSuperview()
            arrowView.removeFromSuperview()
        }
        // var allReactionsValueDic = Dictionary<String, AnyObject>() // sorted Reaction Dictionary
        if let allReactionsValueDic = sortedReactionDictionary(dic: contentItems) as? Dictionary<String, AnyObject>
        {
            
            let space:CGFloat = 15
            let vSpace:CGFloat = 9
            let viewWidth = self.view.frame.width - 12
            let iconHeight = (viewWidth/6) - (space*7)/6
            let viewHeight = iconHeight + (2*vSpace)
            
            scrollViewEmoji.frame = CGRect(x:0,y: 0,width: viewWidth,height: viewHeight)
            arrowView.frame = CGRect(x: 0, y: 0, width: 14, height: 10)
            scrollViewEmoji.backgroundColor = UIColor.black.withAlphaComponent(0.85)//UIColor.clear
            arrowView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
            //                scrollViewEmoji.layer.borderWidth = 2.0
            //                scrollViewEmoji.layer.borderColor = aafBgColor.cgColor  //UIColor.red.cgColor //tableViewBgColor.cgColor
            scrollViewEmoji.layer.cornerRadius = CGFloat(viewHeight/2)
            var menuWidth = CGFloat()
            var origin_x:CGFloat = 15
            var i : Int = 0
            for key in allReactionsValueDic.keys.sorted(by: <) {
                if let   v = allReactionsValueDic[key]
                {
                    
                    if let icon = v["icon"] as? NSDictionary{
                        
                        menuWidth = iconHeight
                        let   emoji = createButton(CGRect(x: origin_x,y: vSpace,width: iconHeight,height: iconHeight), title: "", border: false, bgColor: false, textColor: textColorLight)
                        emoji.addTarget(self, action: #selector(ChannelProfileViewController.feedMenuReactionLike(sender:)), for: .touchUpInside)
                        emoji.tag = v["reactionicon_id"] as? Int ?? 0
                        if let imageUrl = icon["reaction_image_large_icon"] as? String
                        {
                            let url = NSURL(string:imageUrl)
                            if url != nil
                            {
                                emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                })
                            }
                        }
                        scrollViewEmoji.addSubview(emoji)
                        origin_x = origin_x + menuWidth + CGFloat(space)
                        i = i + 1
                    }
                    
                }
                
                
            }
            
            scrollViewEmoji.contentSize = CGSize(width: origin_x, height: CGFloat(viewHeight))
            scrollViewEmoji.bounces = false
            scrollViewEmoji.isUserInteractionEnabled = true
            scrollViewEmoji.showsVerticalScrollIndicator = false
            scrollViewEmoji.showsHorizontalScrollIndicator = true
            scrollViewEmoji.alwaysBounceHorizontal = true
            scrollViewEmoji.alwaysBounceVertical = false
            scrollViewEmoji.isDirectionalLockEnabled = true;
            scrollViewEmoji.isHidden = true
            arrowView.isHidden = true
        }
    }
    
    func newfeedsUpdate(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            
            if subjectId == "" && subjectType == ""{
                parameters = ["limit": "\(limit)" ,"minid":String(minid),"feed_count_only":"1","getAttachedImageDimention":"0"]
            }else{
                parameters = ["limit": "\(limit)","minid":String(minid),"feed_count_only":"1","getAttachedImageDimention":"0" ,"subject_id": String(subjectId), "subject_type": subjectType]
            }
            
            if feedFilterFlag == true{
                parameters.merge(searchDic)
            }
            
            // Set userinteractionflag for request
            userInteractionOff = false
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    // Reset Object after Response from server
                    userInteractionOff = true
                    
                    // On Success Update Feeds
                    if msg{
                        
                        // Check response of Activity Feeds
                        if let response = succeeded["body"] as? NSDictionary{
                            if let newFeedCount = response["response"] as? Int{
                                for ob in self.view.subviews{
                                    if ob.tag == 2020{
                                        ob.removeFromSuperview()
                                    }
                                }
                                
                                if newFeedCount > 0{
                                    
                                    //Show New Feed Option for new Stories
                                    let newFeedCount =  String(format: NSLocalizedString("%d new stories", comment:""),newFeedCount)
                                    
                                    let newFeeds = createButton(CGRect( x: 0, y: self.feedFilter.bounds.height + self.feedFilter.frame.origin.y + TOPPADING + ButtonHeight , width: findWidthByText(newFeedCount) + 40 , height: ButtonHeight - PADING),title: newFeedCount, border: false,bgColor: true, textColor: textColorLight)
                                    newFeeds.tag = 2020
                                    newFeeds.center = CGPoint(x: self.view.center.x, y: newFeeds.frame.origin.y)
                                    newFeeds.layer.cornerRadius = newFeeds.bounds.height/2
                                    newFeeds.addTarget(self, action: #selector(ChannelProfileViewController.updateNewFeed), for: .touchUpInside)
                                    self.view.addSubview(newFeeds)
                                    
                                }
                            }
                            
                        }
                        
                    }else{
                        // Show Message on Failour
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
    // Request to Show New Stories Feed
    @objc func updateNewFeed(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            // Reset Variables
            maxid = 0
            maxidTikTok = 0
            feed_filter = 0
            browseFeed()
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    func animateReaction() {
        arrowView.isHidden = true
        let frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        let image = reactionButtonImage.imageView?.image
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.center = (self.view.parentViewController()?.view.center)!
        imageView.isHidden = false
        view.addSubview(imageView)
        view.bringSubviewToFront(imageView)
        imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            imageView.transform = .identity
        }, completion: { (_) in
            imageView.isHidden = true
            imageView.removeFromSuperview()
        }
        )
    }
    
    
    @objc func feedMenuReactionLike(sender:UIButton){
        arrowView.isHidden = true
        reactionButtonImage = sender
        let feed = contentFeedArray[scrollViewEmoji.tag] as! NSDictionary
        let action_id = feed["action_id"] as! Int
        if openSideMenu{
            openSideMenu = false
             
            return
        }
        
        animateReaction()
        var reaction = ""
        
        for (_,v) in reactionsDictionary
        {
            var updatedDictionary = Dictionary<String, AnyObject>()
            let v = v as! NSDictionary
            if  let reactionId = v["reactionicon_id"] as? Int
            {
                if reactionId == sender.tag
                {
                    
                    reaction = (v["reaction"] as? String)!
                    updatedDictionary["reactionicon_id"] = v["reactionicon_id"]  as AnyObject?
                    updatedDictionary["caption" ] = v["caption"]  as AnyObject?
                    if let icon  = v["icon"] as? NSDictionary{
                        
                        updatedDictionary["reaction_image_icon"] = icon["reaction_image_icon"]  as AnyObject?
                        
                    }
                    
                    var url = ""
                    
                    url = "advancedactivity/like"
                    
                    DispatchQueue.main.async(execute: {
                        soundEffect("Like")
                    })
                    
                    feedObj.updateReaction(url: url,reaction : reaction,action_id  : action_id, updateMyReaction : updatedDictionary as NSDictionary,feedIndex: scrollViewEmoji.tag)
                    
                }
            }
        }
        
        
        
    }
    
    func postFeedOption(){
        /// Read Post Permission saved in NSUserDefaults
        if let data = UserDefaults.standard.object(forKey: "postMenu") as? Data{
            if data.count != 0{
                for ob in view.subviews{
                    if ob.tag == 1 || ob.tag == 2 || ob.tag == 3{
                        ob.removeFromSuperview()
                    }
                }
                
                postPermission = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
                
                var postMenu = [String]()
                if postPermission.count > 0{
                    if let status = postPermission["status"] as? Bool{
                        if status{
                            postMenu.append(NSLocalizedString("\(statusIcon) Status", comment: ""))
                        }
                    }
                    if let photo = postPermission["photo"] as? Bool{
                        if photo{
                            postMenu.append(NSLocalizedString("\(cameraIcon) Photo", comment: ""))
                        }
                    }
                    if let checkIn = postPermission["checkin"] as? Bool{
                        if checkIn{
                            postMenu.append(NSLocalizedString("\(locationIcon) Check In", comment: ""))
                        }
                    }
                }
                
                
                for ob in self.feedObj.tableView.subviews{
                    if ob.tag >= 1991 && ob.tag <= 1993{
                        ob.removeFromSuperview()
                    }
                }
                
                
                //Add Post Feed Option
                for i in 0 ..< postMenu.count {
                    let origin_x = PADING + (CGFloat(i) * ((view.bounds.width - (2 * PADING))/CGFloat(postMenu.count)))
                    let postFeed = createButton(CGRect(x: origin_x, y: tabsContainerMenu.frame.origin.y + tabsContainerMenu.bounds.height + contentPADING + 15, width: view.bounds.width/CGFloat(postMenu.count), height: ButtonHeight - PADING), title: postMenu[i] , border: false ,bgColor: false, textColor: textColorMedium)
                    postFeed.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZENormal)
                    postFeed.backgroundColor = lightBgColor
                    postFeed.tag = i+1 + 1990
                    postFeed.addTarget(self, action: #selector(ChannelProfileViewController.openPostFeed(_:)), for: .touchUpInside)
                    self.feedObj.tableView.addSubview(postFeed)
                }
                
                postMenu.removeAll(keepingCapacity: false)
            }
        }
    }
    
    @objc func openPostFeed(_ sender:UIButton){
        
        if openSideMenu{
            openSideMenu = false
             
            return
        }
        let presentedVC = AdvancePostFeedViewController()
        if (sender.tag - 1990) == 1 {
            presentedVC.openfeedStyle = 0//(sender.tag - 1990)
        }
        else{
            presentedVC.openfeedStyle = (sender.tag - 1990)
        }
        if presentedVC.openfeedStyle == 3 {
            presentedVC.isCheckIn = true
        }
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:false, completion: nil)
    }
    
    func updateFeedsArray(_ feeds:[ActivityFeed]){
        for feed in feeds{
            let newDictionary:NSMutableDictionary = [:]
            
            if feed.action_id != nil{
                newDictionary["action_id"] = feed.action_id
            }
            if feed.subject_id != nil{
                newDictionary["subject_id"] = feed.subject_id
            }
            if feed.share_params_type != nil{
                newDictionary["share_params_type"] = feed.share_params_type
            }
            if feed.share_params_id != nil{
                newDictionary["share_params_id"] = feed.share_params_id
            }
            if feed.attachment != nil{
                newDictionary["attachment"] = feed.attachment
            }
            if feed.attactment_Count != nil{
                newDictionary["attactment_Count"] = feed.attactment_Count
            }
            if feed.comment != nil{
                newDictionary["comment"] = feed.comment
            }
            if feed.delete != nil{
                newDictionary["delete"] = feed.delete
            }
            if feed.share != nil{
                newDictionary["share"] = feed.share
            }
            if feed.comment_count != nil{
                newDictionary["comment_count"] = feed.comment_count
            }
            if feed.feed_createdAt != nil{
                newDictionary["feed_createdAt"] = feed.feed_createdAt
            }
            if feed.feed_menus != nil{
                newDictionary["feed_menus"] = feed.feed_menus
            }
            if feed.feed_footer_menus != nil{
                newDictionary["feed_footer_menus"] = feed.feed_footer_menus
            }
            if feed.feed_title != nil{
                newDictionary["feed_title"] = feed.feed_title
            }
            if feed.feed_Type != nil{
                newDictionary["feed_Type"] = feed.feed_Type
            }
            if feed.is_like != nil{
                newDictionary["is_like"] = feed.is_like
            }
            if feed.likes_count != nil{
                newDictionary["likes_count"] = feed.likes_count
            }
            if feed.subject_image != nil{
                newDictionary["subject_image"] = feed.subject_image
            }
            if feed.photo_attachment_count != nil{
                newDictionary["photo_attachment_count"] = feed.photo_attachment_count
            }
            if feed.object_id != nil{
                newDictionary["object_id"] = feed.object_id
            }
            if feed.object_type != nil{
                newDictionary["object_type"] = feed.object_type
            }
            
            if feed.params != nil{
                newDictionary["params"] = feed.params
            }
            if feed.tags != nil{
                newDictionary["tags"] = feed.tags
            }
            if feed.action_type_body_params != nil{
                newDictionary["action_type_body_params"] = feed.action_type_body_params
            }
            if feed.action_type_body != nil{
                newDictionary["action_type_body"] = feed.action_type_body
            }
            if feed.object != nil{
                newDictionary["object"] = feed.object
            }
            if feed.hashtags != nil{
                newDictionary["hashtags"] = feed.hashtags
            }
            if feed.feed_reactions != nil{
                newDictionary["feed_reactions"] = feed.feed_reactions
            }
            if feed.my_feed_reaction != nil{
                newDictionary["my_feed_reaction"] = feed.my_feed_reaction
            }
            contentFeedArray.append(newDictionary)
            self.feedObj.globalArrayFeed = contentFeedArray
            
            if logoutUser == false
            {
                globalFeedHeight = getBottomEdgeY(inputView: self.feedFilter) + 12
            }
            else
            {
                globalFeedHeight =  getBottomEdgeY(inputView: self.tabsContainerMenu)
            }
            self.feedObj.refreshLikeUnLike = true
            self.feedObj.tableView.reloadData()
            
            
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
                                displayAlertWithOtherButton(NSLocalizedString("Delete Channel", comment: ""),message: NSLocalizedString("Are you sure you want to delete this channel?",comment: "") , otherButton: NSLocalizedString("Delete Channel", comment: "")) { () -> () in
                                
                                    self.updateVideoMenuAction(dic["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                                
                            default:
                                showToast(message:unconditionalMessage, controller: self)
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
                                presentedVC.formTitle = NSLocalizedString("Edit Channel", comment: "")
                                presentedVC.contentType = "Channel"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                                
                            case "create" :
                                isCreateOrEdit = true
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Add new video", comment: "")
                                presentedVC.contentType = "Advanced Video"//"Video"
                                presentedVC.param = [ : ]
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                            case "suggest":
                                
                                isCreateOrEdit = true
                                let presentedVC = MessageCreateController()
                                presentedVC.iscoming = "sitevideo"
                                presentedVC.url = dic["url"] as! String
                                print(dic["url"] as! String)
                                presentedVC.param = dic["urlParams"]  as! NSDictionary
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                            case "favourite":
                               let param = dic["urlParams"]  as! NSDictionary
                               let url = dic["url"] as! String
                               self.updateContentAction(param, url: url)
                               

                            case "report":
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            default:
                                showToast(message:unconditionalMessage, controller: self)
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
    func updateContentAction(_ parameter: NSDictionary , url : String){
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
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        self.explorechannel()
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
                        
                        if self.videoProfileTypeCheck == "AdvEventProfile"{
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                        showToast(message:NSLocalizedString("Channel has been deleted successfully", comment: ""), controller: self)
                        feedUpdate = true
                        channelProfileUpdate = true
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
    // Stop Timer for remove Alert
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    @objc func ScrollingactionAdvVideoChannel(_ notification: Foundation.Notification)
    {
        
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        if updateScrollFlag{
            
            // Check for PAGINATION
            if self.feedObj.tableView.contentSize.height > self.feedObj.tableView.bounds.size.height{
                if self.feedObj.tableView.contentOffset.y >= (self.feedObj.tableView.contentSize.height - self.feedObj.tableView.bounds.size.height){
                    if Reachabable.isConnectedToNetwork() {
                        if contentFeedArray.count > 0{
                            if maxid == 0{
                                feedObj.tableView.tableFooterView?.isHidden = true
                                toastView = createView(CGRect(x: 0,y: (self.feedObj.tableView.bounds.size.height) , width: view.bounds.width, height: 20), borderColor: UIColor.clear, shadow: false)
                                toastView.backgroundColor = UIColor.clear
                                showToast(message:NSLocalizedString("There are no more posts to show.", comment: ""), controller: self)
                                view.addSubview(toastView)
                                self.toastView.hideToastActivity()
                                
                            }else{
                                 feedObj.tableView.tableFooterView?.isHidden = false
                                // Request for Pagination
                                updateScrollFlag = false
                                feed_filter = 0
                              //  showSpinner = true
                                browseFeed()
                            }
                        }
                    }
                }
            }
        }
        
        let scrollOffset = scrollopoint.y
        if (scrollOffset > 60)
        {
            
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            setNavigationImage(controller: self)
            self.marqueeHeader.text = self.contentTitle
            self.marqueeHeader.textColor = textColorPrime
            self.navigationController?.navigationBar.alpha = barAlpha
            self.marqueeHeader.alpha = barAlpha
            self.headerTitle.alpha = 1-barAlpha
            
            if (self.lastContentOffset > scrollOffset) {
                // move up
                if self.like_comment != nil
                {
                    self.like_comment.fadeIn()
                }
            }
            else if (self.lastContentOffset < scrollOffset){
                // move down
                if self.like_comment != nil
                {
                    self.like_comment.fadeOut()
                }
                
            }
            // update the new position acquired
            self.lastContentOffset = scrollOffset
        }else{
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            self.marqueeHeader.text = ""
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            removeNavigationImage(controller: self)
            self.marqueeHeader.alpha = 1
            self.headerTitle.alpha = 1-barAlpha
            //self.like_comment.alpha = 1
            if (scrollOffset < 10.0){
              //  self.like_comment.alpha = 1
            }
        }
        
    }
    
    // Show Feed Filter Options Action
    @objc func showFeedFilterOption(_ sender: UIButton){
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        //      if logoutUser != true {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        
        for menu in filterGutterMenu{
            if let dic = menu as? NSDictionary{
                alertController.addAction(UIAlertAction(title: (dic["tab_title"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                    // Set Feed Filter Option Title
                    self.feedFilter.setTitle((dic["tab_title"] as! String), for: UIControl.State())
                    self.feedFilterFlag = true
                    
                    // Set Parameters for Feed Filter
                    if let params = dic["urlParams"] as? NSDictionary{
                        for (key, value) in params{
                            if let id = value as? NSNumber {
                                searchDic["\(key)"] = String(id as! Int)
                            }
                            
                            if let receiver = value as? NSString {
                                searchDic["\(key)"] = receiver as String
                            }
                        }
                    }
                    // Make Hard Refresh request for selected Feed Filter & Reset all VAriable
                    contentFeedArray.removeAll(keepingCapacity: false)
                    self.dynamicRowHeight.removeAll(keepingCapacity: false)
                    self.maxid = 0
                    maxidTikTok = 0
                    self.feed_filter = 1
                     self.showSpinner = true
                    self.browseFeed()
                    
                }))
            }
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width/2 , y: view.bounds.height/2, width: 0, height: 0)
            alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection()
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
            pv.Sharetitle = self.channelTitleString
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
            
            if let text = self.contentUrl {
                sharingItems.append(self.contentUrl as AnyObject)
            }
          
            
            let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            
            if (UIDevice.current.userInterfaceIdiom == .phone){
                
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
    @objc func refresh(){
        DispatchQueue.main.async(execute: {
            soundEffect("Activity")
        })
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            searchDic.removeAll(keepingCapacity: false)
            showSpinner = false
            updateAfterAlert = false
            browseFeed()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
