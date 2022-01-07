//
//  ChannelViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 15/06/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit
//import GoogleMobileAds
import FBAudienceNetwork
import AVKit
import AVFoundation
import NVActivityIndicatorView
import WebKit

var channelUpdate = false
class ChannelViewController: UIViewController ,UIScrollViewDelegate,FBNativeAdDelegate,FBNativeAdsManagerDelegate,UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate,UIActionSheetDelegate,WKNavigationDelegate,UIGestureRecognizerDelegate {
    
    
    //Navigation variables
    var navtitle : UILabel!
    var navTitle = String()
    var feedFilter: UIButton!
    var feedFilter2: UIButton!
    
    
    var showOnlyMyContent:Bool!
    let scrollView = UIScrollView()
    var fromTab : Bool! = false
    var headermenuBtn:UIButton!
    var videoTypeCheck = ""
    var pageNumber:Int = 1
    var user_id : String!
    var showSpinner = true
    var url : String!
    var updateScrollFlag = true
    var ChannelTableView:UITableView!
    var myChannelTableView:UITableView!
    var categoryTableView:UITableView!
    var categoryResponse = [AnyObject]()
    var channelResponse = [AnyObject]()
    var myChannelResponse = [AnyObject]()
    var refresher:UIRefreshControl!
    var refresher1:UIRefreshControl!
    var refresher2:UIRefreshControl!
    var isPageRefresing = false
    var responseCache = [String:AnyObject]()
    var totalItems:Int = 0
    var listingTypeId : Int!
    var viewSubview = UIView()
    // AdMob Variable
//    var adLoader: GADAdLoader!
    // var nativeAdArray = [AnyObject]()
    var loadrequestcount = 0
    var adsCount:Int = 0
    var isnativeAd:Bool = true
    // Native FacebookAd Variable
    var nativeAdArray = [AnyObject]()
    var adTitleLabel:UILabel!
    var adImageView:FBMediaView!
    var adBodyLabel:UILabel!
    var adCallToActionButton:UIButton!
    var fbView:UIView!
    var nativeAd:FBNativeAd!
    var leftBarButtonItem : UIBarButtonItem!
    // communityAds Variable
    var adImageView1 : UIImageView!
    var customAlbumView : UIView!
    var adSponserdTitleLabel:UILabel!
    var adSponserdLikeTitle : TTTAttributedLabel!
    var addLikeTitle : UIButton!
    var imageButton : UIButton!
    var communityAdsValues : NSArray = []
    var Adiconimageview : UIImageView!
    var adsReportView : AdsReportViewController!
    var parametersNeedToAdd = Dictionary<String, String>()
    var blackScreenForAdd : UIView!
    var adsImage : UIImageView!
    var adsCellheight:CGFloat = 250.0
    var videoBrowseType:Int = 3
    var gutterMenu = NSDictionary()
    var gutterMenu1 = NSDictionary()
    var filterDic = Dictionary<String, String>()
    var filterDic2 = Dictionary<String, String>()
    
    // Carausal variables
    var videoSlideshow: ContentSlideshowScrollView!
    var slideShowHeading: UILabel!
    var videoSlideShowView: UIView!
    var featuredVideosResponse = [AnyObject]()
    var dynamicHeaderHeight: CGFloat = 0.0001
    var countChannel : String!
    var selectedTab:Int!
    var timerFB = Timer()
    var noContentView = NoContentView()
    
    var cdAds : ContentSlideshowScrollView!
    var shared1 = VideoPlayerController()
    var taskVideoPlayPause : DispatchWorkItem?
    var cadUrl : UILabel!
    var cadTitle : UILabel!
    var ctaButton : UIButton!
    var videoclickButton = UIButton()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        shared1 = VideoPlayerController()
        openMenu = false
        updateAfterAlert = true
        channelUpdate = false
        self.filterDic.removeAll()
        self.filterDic2.removeAll()
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        removeNavigationViews(controller: self)
        if fromTab == false{
            setDynamicTabValue()
        }
        // UI Stuff
        designViews()
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        ChannelTableView.tableFooterView = footerView
        ChannelTableView.tableFooterView?.isHidden = true
        
        let footerView2 = UIView(frame: frameActivityIndicator)
        footerView2.backgroundColor = UIColor.clear
        let activityIndicatorView2 = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView2.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView2.addSubview(activityIndicatorView2)
        activityIndicatorView2.startAnimating()
        myChannelTableView.tableFooterView = footerView2
        myChannelTableView.tableFooterView?.isHidden = true
        
        // Get listing
        self.browseChannel()
        
        if adsType_channel != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(ChannelViewController.checkforAds),
                                           userInfo: nil,
                                           repeats: false)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        IsRedirctToProfile()
        setNavigationImage(controller: self)
        Customnavigation()
        delay(0.0) {
            if NotPlay != 1 {
                self.pausePlayeVideos()
            }
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appEnteredFromBackground),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoCompletion), name: Notification.Name("NotificationVideoCompletion"), object: nil)
        createNavigationbuttons()
        if channelProfileUpdate == true
        {
            channelProfileUpdate = false
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            self.browseChannel()
        }
    }
    @objc func appEnteredFromBackground() {
        
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        
    }
    @objc func appMovedToBackground() {
        self.shared1.pauseVideosFor(tableView: self.ChannelTableView)
        self.shared1.pauseVideosFor(tableView: self.myChannelTableView)
        self.taskVideoPlayPause?.cancel()
    }
    @objc func videoCompletion() {
        
        shared1.currentVideoContainer()?.playOn = true
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        
    }
    func pausePlayeVideos(){
        shared1.pausePlayeVideosFor(tableView: ChannelTableView)
        shared1.pausePlayeVideosFor(tableView: myChannelTableView)
        
    }
    
    
    // Check for Group Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        taskVideoPlayPause = DispatchWorkItem {
             if NotPlay != 1 {
            self.pausePlayeVideos()
             }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: taskVideoPlayPause!)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: taskVideoPlayPause!)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: taskVideoPlayPause!)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.5, execute: taskVideoPlayPause!)
        if channelUpdate {
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            self.browseChannel()
            
        }
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        delay(0.0) {
            self.shared1.pauseVideosFor(tableView: self.ChannelTableView)
            self.shared1.pauseVideosFor(tableView: self.myChannelTableView)
            self.taskVideoPlayPause?.cancel()
        }
        
        timerFB.invalidate()
        NotificationCenter.default.removeObserver(self)
        ChannelTableView.tableFooterView?.isHidden = true
        myChannelTableView.tableFooterView?.isHidden = true
        self.title = ""
        removeNavigationViews(controller: self)
        filterSearchFormArray.removeAll(keepingCapacity: false)
        
    }
    func IsRedirctToProfile()
    {
        if conditionalProfileForm == "BrowsePage"
        {
            conditionalProfileForm = ""
            
            let presentedVC = ChannelProfileViewController()
            presentedVC.subjectId =  "\(createResponse["channel_id"]!)"
            presentedVC.subjectType = "sitevideo_channel"
            navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        
        
    }
    
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showAdvVideoContent")
        {
            if  UserDefaults.standard.object(forKey: "showAdvVideoContent") != nil {
                
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showAdvVideoContent")
        }
        
    }
    func createNavigationbuttons()
    {
        
        if showOnlyMyContent == false
        {
            if tabBarController != nil{
                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
            }
            
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        else
        {
            if(countChannel != nil)
            {
                navtitle.text = ""
                self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countChannel)
                feedFilter.isHidden = true
            }
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(ChannelViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
            
        }
    }
    
    func Customnavigation()
    {
        if let navigationBar = self.navigationController?.navigationBar
        {
            let firstFrame = CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/3))/2, y:5, width: navigationBar.frame.width/3, height: navigationBar.frame.height - 10)
            navtitle = UILabel(frame: firstFrame)
            navtitle.textAlignment = .center
            navtitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
            navtitle.textColor = textColorPrime
            navtitle.text = NSLocalizedString("Video Channels", comment: "")
            navtitle.textAlignment = .center
            navtitle.sizeToFit()
            navtitle.tag = 400
            //Filter option
            feedFilter = createButton(CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/2))/2 ,y: 15,width: navigationBar.frame.width/2, height: 30),title:"" , border: false, bgColor: false,textColor: textColorLight)
            feedFilter.isEnabled = true
            feedFilter.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
            feedFilter.addTarget(self, action: #selector(ChannelViewController.showFeedFilterOptions(_:)), for: .touchUpInside)
            feedFilter.tag = 400
            let fitertext = NSLocalizedString("See All", comment: "") + " " + searchFilterIcon
            feedFilter.setTitle(fitertext, for: .normal)
            //Filter icon
            
            
            feedFilter2 = createButton(CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/2))/2 ,y: 15,width: navigationBar.frame.width/2, height: 30),title:"" , border: false, bgColor: false,textColor: textColorLight)
            feedFilter2.isEnabled = true
            feedFilter2.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
            feedFilter2.addTarget(self, action: #selector(ChannelViewController.showFeedFilterOptions2(_:)), for: .touchUpInside)
            feedFilter2.tag = 400
            feedFilter2.setTitle(fitertext, for: .normal)
            feedFilter2.isHidden = true
            
            
            navigationBar.addSubview(feedFilter)
            navigationBar.addSubview(feedFilter2)
            navigationBar.addSubview(navtitle)
            
        }
    }
    // MARK: Create AdvancedEvent Menu
    func CreateScrollHeadermenu()
    {
        
        scrollView.frame = CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: ButtonHeight)
        //  scrollView.delegate = self
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        if logoutUser == false
        {
            if selectedTab == nil{
                selectedTab = 103
            }
            var eventMenu = [String]()
            if isChannelEnable == true
            {
                eventMenu = ["Videos","My Videos","Categories","Channels","My Channels","Ch Categories"]
                if isPlaylistEnable == true{
                    eventMenu = ["Videos","My Videos","Categories","Channels","My Channels","Ch Categories","Playlists","My Playlists"]
                }
            }
            else if isPlaylistEnable == true{
                
                eventMenu =  ["Videos","My Videos","Categories","Playlists","My Playlists"]
                
            }
            else{
                eventMenu =  ["Videos","My Videos","Categories"]
            }
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/3)
            let menucount = eventMenu.count + 100
            for i in 100 ..< menucount
            {
                if i == selectedTab
                {
                    headermenuBtn =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: true)
                    headermenuBtn.setSelectedButton()
                }
                else
                {
                    headermenuBtn =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: false)
                }
                headermenuBtn.tag = i
                headermenuBtn.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
                headermenuBtn.addTarget(self, action: #selector(ChannelViewController.menuSelectOptions(_:)), for: .touchUpInside)
                headermenuBtn.backgroundColor =  UIColor.clear//textColorLight
                headermenuBtn.alpha = 1.0
                scrollView.addSubview(headermenuBtn)
                origin_x += menuWidth
                
            }
            let index = selectedTab - 100
            scrollView.contentOffset.x = CGFloat(index) * menuWidth
            let scrollWidth = menuWidth * CGFloat(eventMenu.count)
            scrollView.contentSize = CGSize(width:scrollWidth,height:ScrollframeY)
            
        }
        else
        {
            if selectedTab == nil{
                selectedTab = 102
            }
            var eventMenu = [String]()
            if isChannelEnable == true
            {
                
                eventMenu = ["Videos","Categories","Channels","Ch Categories"]
                if isPlaylistEnable == true{
                    eventMenu = ["Videos","Categories","Channels","Ch Categories","Playlists"]
                }
            }
            else if isPlaylistEnable == true{
                
                eventMenu =  ["Videos","Categories","Playlists"]
                
            }
            else{
                eventMenu =  ["Videos","Categories"]
            }
            
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/2)
            let menucount = eventMenu.count + 100
            for i in 100 ..< menucount
            {
                if i == selectedTab
                {   headermenuBtn =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: true)
                }else{
                    headermenuBtn =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: false)
                }
                headermenuBtn.tag = i
                headermenuBtn.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                headermenuBtn.addTarget(self, action: #selector(ChannelViewController.menuSelectOptions(_:)), for: .touchUpInside)
                headermenuBtn.backgroundColor =  UIColor.clear//textColorLight
                headermenuBtn.alpha = 1.0
                scrollView.addSubview(headermenuBtn)
                origin_x += menuWidth
                
            }
            let index = selectedTab - 100
            scrollView.contentOffset.x = CGFloat(index) * menuWidth
            let scrollWidth = menuWidth * CGFloat(eventMenu.count)
            scrollView.contentSize = CGSize(width:scrollWidth,height:ScrollframeY)
            
        }
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true;
        scrollView.backgroundColor = UIColor.clear
        self.view.addSubview(scrollView)
    }
    // MARK: Back Implementation
    @objc func goBack(){
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        _ = self.navigationController?.popViewController(animated: false)
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        return true
    }
    
    // MARK: UI Implementation
    func designViews()
    {
        //MARK: Create AdvancedEvent Menu
        if showOnlyMyContent == false{
            
            CreateScrollHeadermenu()
        }
        ChannelTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight , width: view.bounds.width, height: view.bounds.height - (TOPPADING + ButtonHeight) - tabBarHeight), style: .grouped)
        ChannelTableView.register(CustomTableViewCellThree.self, forCellReuseIdentifier: "Cell")
        ChannelTableView.rowHeight = 235.0
        ChannelTableView.dataSource = self
        ChannelTableView.delegate = self
        ChannelTableView.isOpaque = false
        ChannelTableView.backgroundColor = UIColor.clear//tableViewBgColor
        ChannelTableView.separatorColor = TVSeparatorColorClear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            ChannelTableView.estimatedRowHeight = 0
            ChannelTableView.estimatedSectionHeaderHeight = 0
            ChannelTableView.estimatedSectionFooterHeight = 0
        }
        self.view.addSubview(ChannelTableView)
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ChannelViewController.refresh), for: UIControl.Event.valueChanged)
        ChannelTableView.addSubview(refresher)
        
        // Featured carausal
        videoSlideShowView = UIView(frame: CGRect(x:0, y: 0, width: view.bounds.width, height: 180))
        videoSlideShowView.backgroundColor = textColorclear
        videoSlideShowView.isHidden = true
        
        slideShowHeading = createLabel(CGRect(x:0, y: 5, width: videoSlideShowView.bounds.width, height: 25), text: "Featured Channels", alignment: .center, textColor: textColorDark)
        slideShowHeading.font = UIFont(name: fontName, size: FONTSIZELarge)
        slideShowHeading.backgroundColor = textColorLight
        videoSlideShowView.addSubview(slideShowHeading)
        
        videoSlideshow = ContentSlideshowScrollView(frame: CGRect(x:0, y: 30, width: view.bounds.width, height: 150))
        videoSlideshow.backgroundColor = UIColor.white
        videoSlideshow.delegate = self
        videoSlideShowView.addSubview(videoSlideshow)
        ChannelTableView.addSubview(videoSlideShowView)
        
        if showOnlyMyContent == true{
            ChannelTableView.frame.origin.y = TOPPADING - 4
            ChannelTableView.frame.size.height = view.bounds.height - (TOPPADING - 4) - tabBarHeight
        }
        
        // My video view
        myChannelTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height - (TOPPADING + ButtonHeight) - tabBarHeight), style: .grouped)
        myChannelTableView.register(CustomTableViewCellThree.self, forCellReuseIdentifier: "Cell")
        myChannelTableView.rowHeight = 253.0
        myChannelTableView.dataSource = self
        myChannelTableView.delegate = self
        myChannelTableView.isOpaque = false
        myChannelTableView.isHidden = true
        myChannelTableView.backgroundColor = bgColor
        myChannelTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            myChannelTableView.estimatedRowHeight = 0
            myChannelTableView.estimatedSectionHeaderHeight = 0
            myChannelTableView.estimatedSectionFooterHeight = 0
        }
        self.view.addSubview(myChannelTableView)
        refresher1 = UIRefreshControl()
        refresher1.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher1.addTarget(self, action: #selector(ChannelViewController.refresh), for: UIControl.Event.valueChanged)
        myChannelTableView.addSubview(refresher1)
        
        // Category view
        categoryTableView = UITableView(frame: CGRect(x: 0, y:  TOPPADING + ButtonHeight + 3, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight + tabBarHeight + 3)), style: .grouped)
        
        categoryTableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "CategoryCell2")
        categoryTableView.rowHeight = 110.0
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.isOpaque = false
        categoryTableView.isHidden = true
        categoryTableView.backgroundColor = bgColor
        categoryTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            categoryTableView.estimatedRowHeight = 0
            categoryTableView.estimatedSectionHeaderHeight = 0
            categoryTableView.estimatedSectionFooterHeight = 0
        }
        self.view.addSubview( categoryTableView)
        
        refresher2 = UIRefreshControl()
        refresher2.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher2.addTarget(self, action: #selector(ChannelViewController.refresh), for: UIControl.Event.valueChanged)
        categoryTableView.addSubview(refresher2)
        
        
        if showOnlyMyContent == true{
            videoBrowseType = 4
            self.videoSlideShowView.isHidden = true
            
            myChannelTableView.frame = CGRect(x: 0, y: TOPPADING+3, width: view.bounds.width, height: view.bounds.height - (tabBarHeight + TOPPADING + 3))
            
            ChannelTableView.isHidden = true
            myChannelTableView.isHidden = false
            categoryTableView.isHidden = true
        }
        
    }
 
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            arrGlobalFacebookAds.removeAll()
            checkforAds()
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            filterDic.removeAll(keepingCapacity: false)
            filterDic2.removeAll(keepingCapacity: false)
            browseChannel()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    // MARK: - Menu Selection Action
    @objc func menuSelectOptions(_ sender: UIButton)
    {
        print("featuredVideosResponse\(featuredVideosResponse.count)")
        noContentView.isHidden = true
        for ob in self.view.subviews
        {
            if ob.tag == 1000
            {
                ob.removeFromSuperview()
                
            }
        }
        
        videoBrowseType = sender.tag - 100
        if logoutUser == false
        {
            switch videoBrowseType {
            case 0:
                let videoObj = AdvanceVideoViewController()
                videoObj.showOnlyMyContent = false
                videoObj.selectedTab = 100
                videoObj.videoBrowseType = 0
                self.navigationController?.pushViewController(videoObj, animated: false)
                break
            case 1:
                
                let videoObj = AdvanceVideoViewController()
                videoObj.showOnlyMyContent = false
                videoObj.selectedTab = 101
                videoObj.videoBrowseType = 1
                self.navigationController?.pushViewController(videoObj, animated: false)
                break
            case 2:
                let videoObj = AdvanceVideoViewController()
                videoObj.showOnlyMyContent = false
                videoObj.selectedTab = 102
                videoObj.videoBrowseType = 2
                self.navigationController?.pushViewController(videoObj, animated: false)
                
                break
                
                
            case 3:
                feedFilter.isHidden = false
                feedFilter2.isHidden = true
                self.videoSlideShowView.isHidden = false
                //                if channelResponse.count == 0
                //                {
                ChannelTableView.isHidden = false
                myChannelTableView.isHidden = true
                categoryTableView.isHidden = true
                pageNumber = 1
                showSpinner = true
                scrollView.isUserInteractionEnabled = false
                self.filterDic.removeAll()
                browseChannel()
                //                }
                //                else
                //                {
                //                    ChannelTableView.isHidden = false
                //                    myChannelTableView.isHidden = true
                //                    categoryTableView.isHidden = true
                //                    ChannelTableView.reloadData()
                //
                //
                //                }
                break
            case 4:
                feedFilter.isHidden = true
                feedFilter2.isHidden = false
                self.videoSlideShowView.isHidden = true
                if showOnlyMyContent == false{
                    myChannelTableView.frame = CGRect(x: 0, y: ButtonHeight + TOPPADING + 3, width: view.bounds.width, height: view.bounds.height-(ButtonHeight + TOPPADING + 3)-tabBarHeight)
                }
                else{
                    myChannelTableView.frame = CGRect(x: 0, y: TOPPADING+3, width: view.bounds.width, height: view.bounds.height - (tabBarHeight + TOPPADING + 3))
                }
                //                if myChannelResponse.count == 0
                //                {
                
                ChannelTableView.isHidden = true
                myChannelTableView.isHidden = true
                categoryTableView.isHidden = true
                scrollView.isUserInteractionEnabled = false
                pageNumber = 1
                showSpinner = true
                self.filterDic2.removeAll()
                browseChannel()
                //                }
                //                else
                //                {
                //
                //                    ChannelTableView.isHidden = true
                //                    myChannelTableView.isHidden = false
                //                    categoryTableView.isHidden = true
                //
                //                }
                break
            case 5:
                
                feedFilter.isHidden = true
                feedFilter2.isHidden = true
                self.videoSlideShowView.isHidden = true
                ChannelTableView.isHidden = true
                myChannelTableView.isHidden = true
                
                if categoryResponse.count == 0
                {
                    categoryTableView.isHidden = true
                    pageNumber = 1
                    showSpinner = true
                    self.filterDic.removeAll()
                    self.filterDic2.removeAll()
                    scrollView.isUserInteractionEnabled = false
                    browseChannel()
                }
                else
                {
                    ChannelTableView.isHidden = true
                    myChannelTableView.isHidden = true
                    categoryTableView.isHidden = false
                    
                }
                break
            case 6:
                
                let playlistObj = PlaylistBrowseViewController()
                playlistObj.showOnlyMyContent = false
                playlistObj.browseOrmyListing = true
                playlistObj.isPlaylist = true
                playlistObj.isMyPlaylist = false
                playlistObj.selectedTab = 106
                playlistObj.videoBrowseType = 6
                self.navigationController?.pushViewController(playlistObj, animated: false)
                break
                
            case 7:
                let playlistObj = PlaylistBrowseViewController()
                playlistObj.showOnlyMyContent = false
                playlistObj.browseOrmyListing = false
                playlistObj.isPlaylist = false
                playlistObj.isMyPlaylist = true
                playlistObj.selectedTab = 107
                playlistObj.videoBrowseType = 7
                self.navigationController?.pushViewController(playlistObj, animated: false)
                
                break
                
                
            default:
                break
            }
            
        }
        else
        {
            switch videoBrowseType {
            case 0:
                let videoObj = AdvanceVideoViewController()
                videoObj.showOnlyMyContent = false
                videoObj.selectedTab = 100
                videoObj.videoBrowseType = 0
                self.navigationController?.pushViewController(videoObj, animated: false)
                break
            case 1:
                
                let videoObj = AdvanceVideoViewController()
                videoObj.showOnlyMyContent = false
                videoObj.selectedTab = 101
                videoObj.videoBrowseType = 1
                self.navigationController?.pushViewController(videoObj, animated: false)
                break
                
            case 2:
                if isChannelEnable == true
                {
                    feedFilter.isHidden = false
                    feedFilter2.isHidden = true
                    self.videoSlideShowView.isHidden = false
                    if channelResponse.count == 0
                    {
                        ChannelTableView.isHidden = true
                        myChannelTableView.isHidden = true
                        categoryTableView.isHidden = true
                        pageNumber = 1
                        showSpinner = true
                        scrollView.isUserInteractionEnabled = false
                        self.filterDic.removeAll()
                        browseChannel()
                    }
                    else
                    {
                        ChannelTableView.isHidden = false
                        myChannelTableView.isHidden = true
                        categoryTableView.isHidden = true
                        ChannelTableView.reloadData()
                        
                        
                    }
                }
                else {
                    let playlistObj = PlaylistBrowseViewController()
                    playlistObj.showOnlyMyContent = false
                    playlistObj.browseOrmyListing = true
                    playlistObj.isPlaylist = true
                    playlistObj.isMyPlaylist = false
                    playlistObj.selectedTab = 102
                    playlistObj.videoBrowseType = 2
                    self.navigationController?.pushViewController(playlistObj, animated: false)
                }
                break
            case 3:
                if isChannelEnable == true {
                    feedFilter.isHidden = true
                    feedFilter2.isHidden = true
                    self.videoSlideShowView.isHidden = true
                    ChannelTableView.isHidden = true
                    myChannelTableView.isHidden = true
                    
                    if categoryResponse.count == 0
                    {
                        categoryTableView.isHidden = true
                        pageNumber = 1
                        showSpinner = true
                        self.filterDic.removeAll()
                        self.filterDic2.removeAll()
                        scrollView.isUserInteractionEnabled = false
                        browseChannel()
                    }
                    else
                    {
                        ChannelTableView.isHidden = true
                        myChannelTableView.isHidden = true
                        categoryTableView.isHidden = false
                        
                    }
                }
                else {
                    
                }
                break
            case 4:
                let playlistObj = PlaylistBrowseViewController()
                playlistObj.showOnlyMyContent = false
                playlistObj.browseOrmyListing = true
                playlistObj.isPlaylist = true
                playlistObj.isMyPlaylist = false
                playlistObj.selectedTab = 104
                playlistObj.videoBrowseType = 4
                self.navigationController?.pushViewController(playlistObj, animated: false)
                break
            default:
                break
            }
            
        }
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(self.view)
            return
        }
        for ob in scrollView.subviews{
            if ob .isKind(of: UIButton.self){
                if ob.tag >= 100 && ob.tag <= 107
                {
                    (ob as! UIButton).setUnSelectedButton()
                    if ob.tag == sender.tag
                    {
                        (ob as! UIButton).setSelectedButton()
                        
                    }
                }
                
            }
        }
        filterDic.removeAll(keepingCapacity: false)
        filterDic2.removeAll(keepingCapacity: false)
        
        
    }
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
        }else{
            return 0.00001
        }
        
    }
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if  ((self.videoBrowseType == 3 && logoutUser == false) || (self.videoBrowseType == 2 && logoutUser == true))
        {
            return dynamicHeaderHeight
        }
        else
        {
            return 0.00001
        }
        
    }
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if logoutUser == false
        {
            
            switch videoBrowseType {
            case 3:
                if nativeAdArray.count > 0
                {
                    // For showing facebook ads count
                    var rowcount = Int()
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        rowcount = 2*(kFrequencyAdsInCells_channel - 1)
                    }
                    else
                    {
                        rowcount = (kFrequencyAdsInCells_channel - 1)
                    }
                    if channelResponse.count > rowcount
                    {
                        
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            let b = Int(ceil(Float(channelResponse.count)/2))
                            adsCount = b/(kFrequencyAdsInCells_channel - 1)
                            
                            if adsCount > 1 || channelResponse.count%2 != 0
                            {
                                adsCount = adsCount/2
                            }
                            let Totalrowcount = adsCount+b
                            if b%(kFrequencyAdsInCells_channel - 1) == 0 && channelResponse.count % 2 != 0
                            {
                                if adsCount%2 != 0
                                {
                                    
                                    return Totalrowcount - 1
                                }
                            }
                            else if channelResponse.count % 2 != 0 && adsCount % 2 == 0
                            {
                                
                                return Totalrowcount - 1
                            }
                            
                            return Totalrowcount
                        }
                        else
                        {
                            let b = channelResponse.count
                            adsCount = b/(kFrequencyAdsInCells_channel - 1)
                            let Totalrowcount = adsCount+b
                            if Totalrowcount %  kFrequencyAdsInCells_channel  == 0
                            {
                                return Totalrowcount-1
                            }
                            else
                            {
                                return Totalrowcount
                            }
                        }
                        
                    }
                }
                
                if(isIpad()){
                    return Int(ceil(Float(channelResponse.count)/2))
                }else{
                    return channelResponse.count
                }
            case 4:
                if nativeAdArray.count > 0
                {
                    // For showing facebook ads count
                    var rowcount = Int()
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        rowcount = 2*(kFrequencyAdsInCells_channel - 1)
                    }
                    else
                    {
                        rowcount = (kFrequencyAdsInCells_channel - 1)
                    }
                    if myChannelResponse.count > rowcount
                    {
                        
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            let b = Int(ceil(Float(myChannelResponse.count)/2))
                            adsCount = b/(kFrequencyAdsInCells_channel - 1)
                            
                            if adsCount > 1 || myChannelResponse.count%2 != 0
                            {
                                adsCount = adsCount/2
                            }
                            let Totalrowcount = adsCount+b
                            if b%(kFrequencyAdsInCells_channel - 1) == 0 && myChannelResponse.count % 2 != 0
                            {
                                if adsCount%2 != 0
                                {
                                    
                                    return Totalrowcount - 1
                                }
                            }
                            else if myChannelResponse.count % 2 != 0 && adsCount % 2 == 0
                            {
                                
                                return Totalrowcount - 1
                            }
                            
                            return Totalrowcount
                        }
                        else
                        {
                            let b = myChannelResponse.count
                            adsCount = b/(kFrequencyAdsInCells_channel - 1)
                            let Totalrowcount = adsCount+b
                            if Totalrowcount %  kFrequencyAdsInCells_channel  == 0
                            {
                                return Totalrowcount-1
                            }
                            else
                            {
                                return Totalrowcount
                            }
                        }
                        
                    }
                }
                if(isIpad()){
                    return Int(ceil(Float(myChannelResponse.count)/2))
                }else{
                    return myChannelResponse.count
                }
            default:
                
                return Int(ceil(Float(categoryResponse.count)/2))
                
                
            }
        }
        else{
            switch videoBrowseType {
            case 2:
                if nativeAdArray.count > 0
                {
                    // For showing facebook ads count
                    var rowcount = Int()
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        rowcount = 2*(kFrequencyAdsInCells_channel - 1)
                    }
                    else
                    {
                        rowcount = (kFrequencyAdsInCells_channel - 1)
                    }
                    if channelResponse.count > rowcount
                    {
                        
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            let b = Int(ceil(Float(channelResponse.count)/2))
                            adsCount = b/(kFrequencyAdsInCells_channel - 1)
                            
                            if adsCount > 1 || channelResponse.count%2 != 0
                            {
                                adsCount = adsCount/2
                            }
                            let Totalrowcount = adsCount+b
                            if b%(kFrequencyAdsInCells_channel - 1) == 0 && channelResponse.count % 2 != 0
                            {
                                if adsCount%2 != 0
                                {
                                    
                                    return Totalrowcount - 1
                                }
                            }
                            else if channelResponse.count % 2 != 0 && adsCount % 2 == 0
                            {
                                
                                return Totalrowcount - 1
                            }
                            
                            return Totalrowcount
                        }
                        else
                        {
                            let b = channelResponse.count
                            adsCount = b/(kFrequencyAdsInCells_channel - 1)
                            let Totalrowcount = adsCount+b
                            if Totalrowcount %  kFrequencyAdsInCells_channel  == 0
                            {
                                return Totalrowcount-1
                            }
                            else
                            {
                                return Totalrowcount
                            }
                        }
                        
                    }
                }
                
                if(isIpad()){
                    return Int(ceil(Float(channelResponse.count)/2))
                }else{
                    return channelResponse.count
                }
                
            default:
                
                return Int(ceil(Float(categoryResponse.count)/2))
                
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        if ((self.videoBrowseType == 5 && logoutUser == false) || (self.videoBrowseType == 3 && logoutUser == true))
        {
            return 160.0
        }
        if ( kFrequencyAdsInCells_channel  > 4 && (((indexPath as NSIndexPath).row %  kFrequencyAdsInCells_channel ) == ( kFrequencyAdsInCells_channel )-1))
        {
            if adsType_channel == 2
            {
                guard (UIDevice.current.userInterfaceIdiom != .pad) else {
                    return adsCellheight+5
                }
                return adsCellheight+5
            }
            return adsCellheight+5
        }
        return 238
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if adsType_channel == 2{
            //        let height = NSNumber(value: Float(cell.frame.size.height))
            //        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
            // cell.contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            var row = indexPath.row as Int
            if (kFrequencyAdsInCells_channel > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_channel) == (kFrequencyAdsInCells_channel)-1))
            {
                //            displyedAdsCount = (row / kFrequencyAdsInCells_feeds)
                //            row = row - displyedAdsCount
                
                if let cell1 = cell as? NativeVideoCellTableViewCell
                {
                    var Adcount: Int = 0
                    Adcount = row/(kFrequencyAdsInCells_channel-1)
                    
                    //
                    while Adcount > 10
                    {
                        Adcount = Adcount%10
                    }
                    
                    if Adcount > 0
                    {
                        Adcount = Adcount-1
                    }
                    
                    if Adcount > nativeAdArray.count {
                        Adcount = Adcount % nativeAdArray.count
                        if Adcount > 0 {
                            Adcount = Adcount-1
                        }
                        else{
                            Adcount = nativeAdArray.count - 1
                        }
                    }
                    // videoUrl = nil
                    if nativeAdArray.count > 0 && (nativeAdArray.count > (Adcount))
                    {
                        
                        
                        
                        print("com ads \(communityAdsValues[Adcount])")
                        let activityFeed = communityAdsValues[Adcount] as! NSMutableDictionary
                        var strUrl1 = ""
                        if activityFeed["videoUrl"] != nil {
                            strUrl1 = activityFeed["videoUrl"] as! String
                            
                            cell1.playerController = shared1
                            cell1.Adimageview.isHidden = false
                            cell1.playVideo(strURL: strUrl1)
                        }
                        else{
                            cell1.playVideo(strURL: nil)
                            cell1.Adimageview.isHidden = true
                        }
                        
                        //  }
                        //                cell1.cellView.addSubview(view as! UIView)
                        //
                        //                otherFeedCount = Adcount
                    }
                    
                }
                
            }
        }
        
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if adsType_channel == 2{
            if tableView.tag != 11
            {
                
                let row = indexPath.row as Int
                if  (kFrequencyAdsInCells_channel > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_channel) == (kFrequencyAdsInCells_channel)-1))
                {
                    if let cell1 = cell as? AutoPlayVideoLayerContainer
                    {
                        shared1.removeLayerFor(cell: cell1 )
                    }
                    // videoUrl = nil
                }
                
            }
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return videoSlideShowView
        
        
    }
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let totalRows = channelResponse.count + adsCount
        let totalRows1 = myChannelResponse.count + adsCount
        
        
        if (((self.videoBrowseType == 3 && logoutUser == false) || (self.videoBrowseType == 2 && logoutUser == true)) && totalRows > (indexPath.row - 1 - adsCount))
        {
            var row = (indexPath as NSIndexPath).row as Int
            if ( kFrequencyAdsInCells_channel  > 4 && nativeAdArray.count > 0 && ((row %  kFrequencyAdsInCells_channel ) == ( kFrequencyAdsInCells_channel )-1))
            {  // or 9 == if you don't want the first cell to be an ad!
                ChannelTableView.register(NativeVideoCellTableViewCell.self, forCellReuseIdentifier: "Cell1")
                let cell = ChannelTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeVideoCellTableViewCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = tableViewBgColor
                var Adcount: Int = 0
                Adcount = row/(kFrequencyAdsInCells_channel - 1)
                
                while Adcount > 10 {
                    
                    Adcount = Adcount%10
                }
                if Adcount > 0
                {
                    Adcount = Adcount-1
                }
                if Adcount > nativeAdArray.count {
                    Adcount = Adcount % nativeAdArray.count
                    if Adcount > 0 {
                        Adcount = Adcount-1
                    }
                    else{
                        Adcount = nativeAdArray.count - 1
                    }
                }
                
                if nativeAdArray.count > 0 && (nativeAdArray.count > (Adcount))
                {
                    for obj in cell.cellView.subviews
                    {
                        if obj.tag == 1001001 //Condition if that view belongs to any specific class
                        {
                            obj.removeFromSuperview()
                        }
                    }
                    if adsType_channel == 2{
                        let activityFeed = communityAdsValues[Adcount] as! NSMutableDictionary
                        cell.Adimageview.isHidden = false
                        if activityFeed["cmd_ad_format"] as! String == "video"{
                            
                            
                            
                            var strUrl1 = ""
                            if activityFeed["videoUrl"] != nil {
                                strUrl1 = activityFeed["videoUrl"] as! String
                                
                                if muteVideo == true
                                {
                                    cell.btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                                }
                                else
                                {
                                    cell.btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                                }
                                
                                let url1 = NSURL(string: strUrl1)
                                
                                getThumbnailImageFromVideoUrl(url: url1 as! URL) { (thumbImage) in
                                    cell.Adimageview.image = thumbImage
                                }
                                
                                cell.Adimageview.isHidden = false
                            }
                            else{
                                cell.Adimageview.isHidden = true
                            }
                        }
                        //  cell1.Adimageview.image = activityFeed["image"]
                    }
                    
                    
                    let view = nativeAdArray[Adcount]
                    cell.cellView.addSubview(view as! UIView)
                    //                    if(UIDevice.current.userInterfaceIdiom != .pad)
                    //                    {
                    cell.cellView.frame.size.height = view.frame.size.height
                    adsCellheight = cell.cellView.frame.size.height + 5
                    //  }
                }
                if(isIpad())
                {
                    var videosInfo2:NSDictionary!
                    let adcount = row/kFrequencyAdsInCells_channel
                    if(channelResponse.count > ((row)*2-adcount) ){
                        videosInfo2 = channelResponse[((row)*2-adcount)] as! NSDictionary
                        cell.cellView2.isHidden = false
                        cell.contentSelection2.isHidden = false
                        cell.contentSelection2.tag = ((row)*2-adcount)
                        cell.menu2.tag = ((row)*2-adcount)
                    }else{
                        cell.cellView2.isHidden = true
                        cell.contentSelection2.isHidden = true
                        return cell
                    }
                    
                    // Select Video Action
                    cell.contentSelection2.addTarget(self, action: #selector(ChannelViewController.showVideo(_:)), for: .touchUpInside)
                    //   cell.imgVideo2.addTarget(self, action: #selector(ChannelViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                    //   cell.imgVideo2.tag = cell.contentSelection2.tag
                    cell.imgVideo2.isHidden = true
                    // Set MenuAction
                    cell.menu2.addTarget(self, action:#selector(ChannelViewController.showVideoMenu(_:)) , for: .touchUpInside)
                    cell.contentImage2.frame.size.height = 180
                    
                    
                    // Set Video Image
                    cell.contentImage2.image = nil
                    let url = URL(string: videosInfo2["image"] as! NSString as String)
                    if url != nil
                    {
                        cell.contentImage2.kf.indicatorType = .activity
                        (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        })
                        
                    }
                    
                    
                    // Set Video Duration
                    let duration = videosInfo2["duration"] as? Int
                    let durationString = timeFormatted(duration!) as String
                    cell.videoDuration2.isHidden = false
                    cell.videoDuration2.text = "\(durationString)"
                    cell.contentName2.frame = CGRect(x: (cell.contentImage2.bounds.width - 50), y: 110, width: (cell.contentImage2.bounds.width-100), height: 10)
                    cell.contentName2.font = UIFont(name: fontName, size: FONTSIZESmall)
                    cell.contentName2.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.contentName2.sizeToFit()
                    cell.contentName2.frame.origin.y = (cell.contentImage2.bounds.height - (cell.contentName2.bounds.height+10))
                    // Set Video Info
                    cell.createdBy2.frame = CGRect(x: contentPADING , y: cell.contentImage2.bounds.height, width: cell.cellView2.bounds.width - (cell.cellView2.bounds.height - cell.contentImage2.bounds.height), height: cell.cellView2.bounds.height - cell.contentImage2.bounds.height)
                    var value2 = ""
                    
                    if let videoTitle2 = videosInfo2["title"] as? NSString {
                        if videoTitle2.length > 25{
                            value2 = videoTitle2.substring(to: 25 - 3)
                            value2 += NSLocalizedString("...",  comment: "")
                        }else{
                            value2 = "\(videoTitle2)"
                        }
                    }else if videosInfo2["title"] is NSNumber{
                        
                        let videoTitle2 = String(describing: videosInfo2["title"]!) as NSString
                        if videoTitle2.length > 25{
                            value2 = videoTitle2.substring(to: 25 - 3)
                            value2 += NSLocalizedString("...",  comment: "")
                        }else{
                            value2 = "\(videoTitle2)"
                        }
                        
                    }
                    
                    
                    var tempInfo = ""
                    
                    tempInfo = "\(value2)\n"
                    tempInfo = "\(tempInfo)"
                    let postedDate2 = videosInfo2["creation_date"] as? String
                    
                    let date = dateDifferenceWithEventTime(postedDate2!)
                    var DateC = date.components(separatedBy: ", ")
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
                    cell.createdBy2.delegate = self
                    cell.createdBy2.textAlignment = .left
                    cell.createdBy2.textColor = textColorMedium
                    cell.createdBy2.numberOfLines = 0
                    
                    cell.createdBy2.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                        
                        let range = (tempInfo as NSString).range(of: value2)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                        
                        
                        return mutableAttributedString
                    })
                    
                    var totalView = ""
                    
                    if let ratingCount = videosInfo2["rating_count"] as? Int{
                        totalView = "\(ratingCount) \(starIcon)"
                    }
                    if let likes = videosInfo2["like_count"] as? Int{
                        totalView += " \(likes) \(likeIcon)"
                    }
                    if let comment = videosInfo2["comment_count"] as? Int{
                        totalView += " \(comment) \(commentIcon)"
                    }
                    cell.totalMembers2.text = "\(totalView)"
                    cell.totalMembers2.textColor = textColorMedium
                    cell.totalMembers2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                    cell.totalMembers2.sizeToFit()
                    //   Set Menu
                    cell.menu2.isHidden = true
                    cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                    cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)
                }
                
                return cell
                
            }
            else
            {
                if  kFrequencyAdsInCells_channel  > 4 && nativeAdArray.count > 0
                {
                    row = row - (row /  kFrequencyAdsInCells_channel )
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCellThree
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = tableViewBgColor
                var videosInfo:NSDictionary!
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    if ( kFrequencyAdsInCells_channel  > 4 && nativeAdArray.count > 0)
                    {
                        let adcount = row/(kFrequencyAdsInCells_channel - 1)
                        if(channelResponse.count > ((row)*2+adcount))
                        {
                            videosInfo = channelResponse[((row)*2+adcount)] as! NSDictionary
                            cell.contentSelection.tag = ((row)*2+adcount)
                            cell.menu.tag = ((row)*2+adcount)
                            
                        }
                    }
                    else
                    {
                        if(channelResponse.count > (row)*2)
                        {
                            videosInfo = channelResponse[(row)*2] as! NSDictionary
                            cell.contentSelection.tag = (row)*2
                            cell.menu.tag = (row)*2
                            
                        }
                    }
                }
                else
                {
                    videosInfo = channelResponse[row] as! NSDictionary
                    cell.contentSelection.tag = row
                    cell.menu.tag = row
                }
                
                //Select Video Action
                cell.contentSelection.addTarget(self, action: #selector(ChannelViewController.showVideo(_:)), for: .touchUpInside)
                //  cell.imgVideo.addTarget(self, action: #selector(ChannelViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                //   cell.imgVideo.tag = cell.contentSelection.tag
                cell.imgVideo.isHidden = true
                
                // Set MenuAction
                cell.menu.addTarget(self, action:#selector(ChannelViewController.showVideoMenu(_:)) , for: .touchUpInside)
                cell.contentImage.frame.size.height = 180
                
                // Set Video Image
                if let imgeMain = videosInfo["video_overlay_image"] as? [String : AnyObject], let url = URL(string: imgeMain["url"] as? String ?? "")
                {
                    cell.imgViewOverLay.kf.indicatorType = .activity
                    (cell.imgViewOverLay.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgViewOverLay.kf.setImage(with: url, placeholder: UIImage(named : ""), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
                else
                {
                    cell.imgViewOverLay.image = UIImage(named: "")
                }
                if (videosInfo["image"] as? String) != nil
                {
                    let url  = URL(string: videosInfo["image"] as! NSString as String)
                    cell.contentImage.kf.indicatorType = .activity
                    (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImage.kf.setImage(with: url, placeholder: UIImage(named: "nophoto_video_thumb_icon.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                    
                }
                else
                {
                    cell.contentImage.image = UIImage(named: "nophoto_video_thumb_icon.png")!
                }

                // Set Video Name
                let videoscount = videosInfo["videos_count"] as? Int
                cell.videoDuration.isHidden = false
                if videoscount == 1
                {
                    cell.videoDuration.text = "\(videoscount!) Video"
                }
                else{
                    cell.videoDuration.text = "\(videoscount!) Videos"
                }
                cell.videoDuration.frame.origin.x = cell.contentImage.bounds.width - 70
                cell.videoDuration.frame.size.width = 65
                
                cell.contentName.frame = CGRect(x: (cell.contentImage.bounds.width - 50), y: 110, width: (cell.contentImage.bounds.width-100), height: 10)
                cell.contentName.font = UIFont(name: fontName, size: FONTSIZESmall)
                cell.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.contentName.sizeToFit()
                cell.contentName.frame.origin.y = (cell.contentImage.bounds.height - (cell.contentName.bounds.height+10))
                
                // Set Video Info
                cell.createdBy.frame = CGRect(x: contentPADING , y: cell.contentImage.bounds.height, width: cell.cellView.bounds.width - (cell.cellView.bounds.height - cell.contentImage.bounds.height), height: cell.cellView.bounds.height - cell.contentImage.bounds.height)
                var tempInfo = ""
                var value = ""
                
                if let videoTitle = videosInfo["title"] as? NSString {
                    if videoTitle.length > 32{
                        value = videoTitle.substring(to: 32-3)
                        value += NSLocalizedString("...",  comment: "")
                    }else{
                        value = "\(videoTitle)"
                    }
                }else if videosInfo["title"] is NSNumber{
                    let videoTitle = String(describing: videosInfo["title"]!) as NSString
                    
                    if videoTitle.length > 32{
                        value = videoTitle.substring(to: 32-3)
                        value += NSLocalizedString("...",  comment: "")
                    }else{
                        value = "\(videoTitle)"
                    }
                    
                }
                
                tempInfo = "\(value)\n"
                tempInfo = "\(tempInfo)"
                let postedDate = videosInfo["creation_date"] as? String
                
                let date = dateDifferenceWithEventTime(postedDate!)
                var DateC = date.components(separatedBy: ", ")
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
                cell.createdBy.delegate = self
                cell.createdBy.textAlignment = .left
                cell.createdBy.textColor = textColorMedium
                cell.createdBy.numberOfLines = 0
                
                cell.createdBy.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                    let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                    let range = (tempInfo as NSString).range(of: value)
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                    
                    
                    return mutableAttributedString
                })
                // Set Like , Comment & ViewCount
                
                var totalView = ""
                if let ratingCount = videosInfo["rating_count"] as? Int{
                    totalView = "\(ratingCount) \(starIcon)"
                }
                if videoTypeCheck == "sitegroup"{
                    if let ratingCount = videosInfo["rating"] as? Int{
                        totalView = "\(ratingCount) \(starIcon)"
                    }
                    
                }
                
                if let likes = videosInfo["like_count"] as? Int{
                    totalView += " \(likes) \(likeIcon)"
                }
                if let comment = videosInfo["comment_count"] as? Int{
                    totalView += " \(comment) \(viewIcon)"
                }
                cell.totalMembers.textColor = textColorMedium
                cell.totalMembers.text = "\(totalView)"
                cell.totalMembers.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                
                // Set Menu
                if(isIpad()){
                    
                    cell.menu.isHidden = true
                    cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 95)
                    //
                    cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage.bounds.height, width: 95
                        , height: 40)
                    
                }
                else{
                    cell.menu.isHidden = true
                    cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 90)
                    cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 90,y: cell.contentImage.bounds.height, width: 90
                        , height: 40)
                    
                    
                }
                // RHS
                if(isIpad()){
                    var videosInfo2:NSDictionary!
                    var adcount = Int()
                    if ( kFrequencyAdsInCells_channel  > 4 && nativeAdArray.count > 0)
                    {
                        adcount = row/(kFrequencyAdsInCells_channel - 1)
                    }
                    else
                    {
                        adcount = 0
                    }
                    if(channelResponse.count > ((row)*2+1+adcount))
                    {
                        
                        videosInfo2 = channelResponse[((row)*2+1+adcount)] as! NSDictionary
                        cell.cellView2.isHidden = false
                        cell.contentSelection2.isHidden = false
                        cell.contentSelection2.tag = ((row)*2+1+adcount)
                        cell.menu2.tag = ((row)*2+1+adcount)
                    }
                    else
                    {
                        cell.cellView2.isHidden = true
                        cell.contentSelection2.isHidden = true
                        return cell
                    }
                    
                    // Select Video Action
                    cell.contentSelection2.addTarget(self, action: #selector(ChannelViewController.showVideo(_:)), for: .touchUpInside)
                    //  cell.imgVideo2.addTarget(self, action: #selector(ChannelViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                    //  cell.imgVideo2.tag = cell.contentSelection2.tag
                    cell.imgVideo2.isHidden = true
                    // Set MenuAction
                    cell.menu2.addTarget(self, action:#selector(ChannelViewController.showVideoMenu(_:)) , for: .touchUpInside)
                    cell.contentImage2.frame.size.height = 180
                    cell.contentImage2.image = nil
                    if (videosInfo2["image"] as? String) != nil
                    {
                        let url  = URL(string: videosInfo2["image"] as! NSString as String)
                        cell.contentImage2.kf.indicatorType = .activity
                        (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage2.kf.setImage(with: url, placeholder: UIImage(named: "nophoto_video_thumb_icon.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        })
                        
                    }
                    else
                    {
                        
                        cell.contentImage2.image = UIImage(named: "nophoto_group_thumb_profile.png")!
                    }
                    
                    // Set Video Duration
                    let videos_count = videosInfo2["videos_count"] as? Int
                    
                    cell.videoDuration2.isHidden = false
                    
                    if videoscount == 1
                    {
                        cell.videoDuration2.text = "\(videos_count!) Video"
                    }
                    else{
                        cell.videoDuration2.text = "\(videos_count!) Videos"
                    }
                    cell.contentName2.frame = CGRect(x: (cell.contentImage2.bounds.width - 50), y: 110, width: (cell.contentImage2.bounds.width-100), height: 10)
                    cell.contentName2.font = UIFont(name: fontName, size: FONTSIZESmall)
                    //            cell.contentName2.text = timeFormatted(duration!)
                    cell.contentName2.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.contentName2.sizeToFit()
                    cell.contentName2.frame.origin.y = (cell.contentImage2.bounds.height - (cell.contentName2.bounds.height+10))
                    // Set Video Info
                    cell.createdBy2.frame = CGRect(x: contentPADING , y: cell.contentImage2.bounds.height, width: cell.cellView2.bounds.width - (cell.cellView2.bounds.height - cell.contentImage2.bounds.height), height: cell.cellView2.bounds.height - cell.contentImage2.bounds.height)
                    
                    var value2 = ""
                    
                    if let videoTitle2 = videosInfo2["title"] as? NSString {
                        if videoTitle2.length > 25{
                            value2 = videoTitle2.substring(to: 25 - 3)
                            value2 += NSLocalizedString("...",  comment: "")
                        }else{
                            value2 = "\(videoTitle2)"
                        }
                    }else if videosInfo2["title"] is NSNumber{
                        let videoTitle2 = String(describing: videosInfo2["title"]!) as NSString
                        
                        if videoTitle2.length > 25{
                            value2 = videoTitle2.substring(to: 25 - 3)
                            value2 += NSLocalizedString("...",  comment: "")
                        }else{
                            value2 = "\(videoTitle2)"
                        }
                        
                        
                    }
                    
                    tempInfo = "\(value2)\n"
                    tempInfo = "\(tempInfo)\n"
                    let postedDate2 = videosInfo2["creation_date"] as? String
                    
                    let date = dateDifferenceWithEventTime(postedDate2!)
                    var DateC = date.components(separatedBy: ", ")
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
           
                    cell.createdBy2.delegate = self
                    cell.createdBy2.textAlignment = .left
                    cell.createdBy2.textColor = textColorMedium
                    cell.createdBy2.numberOfLines = 0
                    
                    cell.createdBy2.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                        
                        let range = (tempInfo as NSString).range(of: value2)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                        
                        
                        return mutableAttributedString
                    })
                    
                    var totalView = ""
                    
                    if let ratingCount = videosInfo2["rating_count"] as? Int{
                        totalView = "\(ratingCount) \(starIcon)"
                    }
                    if let likes = videosInfo2["like_count"] as? Int{
                        totalView += " \(likes) \(likeIcon)"
                    }
                    if let comment = videosInfo2["comment_count"] as? Int{
                        totalView += " \(comment) \(commentIcon)"
                    }
                    cell.totalMembers2.text = "\(totalView)"
                    cell.totalMembers2.textColor = textColorMedium
                    cell.totalMembers2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                    cell.totalMembers2.sizeToFit()
                    //   Set Menu
                    cell.menu2.isHidden = true
                    cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                    cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)
                    
                }
                return cell
            }
            
        }
        else if ((videoBrowseType == 4 && logoutUser == false) && totalRows1 > (indexPath.row - 1 - adsCount))
        {
            var row = (indexPath as NSIndexPath).row as Int
            if ( kFrequencyAdsInCells_channel  > 4 && nativeAdArray.count > 0 && ((row %  kFrequencyAdsInCells_channel ) == ( kFrequencyAdsInCells_channel )-1))
            {  // or 9 == if you don't want the first cell to be an ad!
                myChannelTableView.register(NativeVideoCellTableViewCell.self, forCellReuseIdentifier: "Cell1")
                let cell = myChannelTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeVideoCellTableViewCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = tableViewBgColor
                var Adcount: Int = 0
                Adcount = row/(kFrequencyAdsInCells_channel - 1)
                
                while Adcount > 10 {
                    
                    Adcount = Adcount%10
                }
                if Adcount > 0
                {
                    Adcount = Adcount-1
                }
                
                if nativeAdArray.count > 0 && (nativeAdArray.count > (Adcount))
                {
                    for obj in cell.contentView.subviews
                    {
                        if obj.tag == 1001001 //Condition if that view belongs to any specific class
                        {
                            obj.removeFromSuperview()
                        }
                    }
                    let view = nativeAdArray[Adcount]
                    cell.contentView.addSubview(view as! UIView)
                    if(UIDevice.current.userInterfaceIdiom != .pad)
                    {
                        cell.contentView.frame.size.height = view.frame.size.height
                        adsCellheight = cell.contentView.frame.size.height + 5
                    }
                }
                if(isIpad())
                {
                    var videosInfo2:NSDictionary!
                    let adcount = row/kFrequencyAdsInCells_channel
                    if(myChannelResponse.count > ((row)*2-adcount) ){
                        videosInfo2 = channelResponse[((row)*2-adcount)] as! NSDictionary
                        cell.cellView2.isHidden = false
                        cell.contentSelection2.isHidden = false
                        cell.contentSelection2.tag = ((row)*2-adcount)
                        cell.menu2.tag = ((row)*2-adcount)
                    }else{
                        cell.cellView2.isHidden = true
                        cell.contentSelection2.isHidden = true
                        return cell
                    }
                    
                    // Select Video Action
                    cell.contentSelection2.addTarget(self, action: #selector(ChannelViewController.showVideo(_:)), for: .touchUpInside)
                    // cell.imgVideo2.addTarget(self, action: #selector(ChannelViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                    //  cell.imgVideo2.tag = cell.contentSelection2.tag
                    cell.imgVideo2.isHidden = true
                    // Set MenuAction
                    cell.menu2.addTarget(self, action:#selector(ChannelViewController.showVideoMenu(_:)) , for: .touchUpInside)
                    cell.contentImage2.frame.size.height = 180
                    
                    
                    // Set Video Image
                    if let photoId = videosInfo2["photo_id"] as? Int{
                        if photoId != 0{
                            cell.contentImage2.image = nil
                            let url = URL(string: videosInfo2["image"] as! NSString as String)
                            
                            if  url != nil {
                                cell.contentImage2.kf.indicatorType = .activity
                                (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.contentImage2.kf.setImage(with: url, placeholder: UIImage(named: "nophoto_video_thumb_icon.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    cell.contentImage2.backgroundColor = UIColor.clear
                                })
                            }
                        }else{
                            
                            cell.contentImage2.image = UIImage(named: "nophoto_group_thumb_profile.png")!
                        }
                    }
                    
                    // Set Video Duration
                    let duration = videosInfo2["duration"] as? Int
                    let durationString = timeFormatted(duration!) as String
                    cell.videoDuration2.isHidden = false
                    cell.videoDuration2.text = "\(durationString)"
                    cell.contentName2.frame = CGRect(x: (cell.contentImage2.bounds.width - 50), y: 110, width: (cell.contentImage2.bounds.width-100), height: 10)
                    cell.contentName2.font = UIFont(name: fontName, size: FONTSIZESmall)
                    cell.contentName2.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.contentName2.sizeToFit()
                    cell.contentName2.frame.origin.y = (cell.contentImage2.bounds.height - (cell.contentName2.bounds.height+10))
                    // Set Video Info
                    cell.createdBy2.frame = CGRect(x: contentPADING , y: cell.contentImage2.bounds.height, width: cell.cellView2.bounds.width - (cell.cellView2.bounds.height - cell.contentImage2.bounds.height), height: cell.cellView2.bounds.height - cell.contentImage2.bounds.height)
                    var value2 = ""
                    
                    if let videoTitle2 = videosInfo2["title"] as? NSString {
                        if videoTitle2.length > 25{
                            value2 = videoTitle2.substring(to: 25 - 3)
                            value2 += NSLocalizedString("...",  comment: "")
                        }else{
                            value2 = "\(videoTitle2)"
                        }
                    }else if videosInfo2["title"] is NSNumber{
                        
                        let videoTitle2 = String(describing: videosInfo2["title"]!) as NSString
                        if videoTitle2.length > 25{
                            value2 = videoTitle2.substring(to: 25 - 3)
                            value2 += NSLocalizedString("...",  comment: "")
                        }else{
                            value2 = "\(videoTitle2)"
                        }
                        
                    }
                    
                    
                    var tempInfo = ""
                    
                    tempInfo = "\(value2)\n"
                    tempInfo = "\(tempInfo)"
                    let postedDate2 = videosInfo2["creation_date"] as? String
                    
                    let date = dateDifferenceWithEventTime(postedDate2!)
                    var DateC = date.components(separatedBy: ", ")
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
                    
                    cell.createdBy2.delegate = self
                    cell.createdBy2.textAlignment = .left
                    cell.createdBy2.textColor = textColorMedium
                    cell.createdBy2.numberOfLines = 0
                    
                    cell.createdBy2.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                        let range = (tempInfo as NSString).range(of: value2)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                        
                        
                        return mutableAttributedString
                    })
                    
                    var totalView = ""
                    
                    if let ratingCount = videosInfo2["rating_count"] as? Int{
                        totalView = "\(ratingCount) \(starIcon)"
                    }
                    if let likes = videosInfo2["like_count"] as? Int{
                        totalView += " \(likes) \(likeIcon)"
                    }
                    if let comment = videosInfo2["comment_count"] as? Int{
                        totalView += " \(comment) \(commentIcon)"
                    }
                    cell.totalMembers2.text = "\(totalView)"
                    cell.totalMembers2.textColor = textColorMedium
                    cell.totalMembers2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                    cell.totalMembers2.sizeToFit()
                    //   Set Menu
                    if videoBrowseType == 5 {
                        cell.menu2.isHidden = true
                        cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                        cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)
                    }else{
                        cell.menu2.isHidden = false
                        
                        cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                        cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)
                    }
                }
                return cell
                
            }
            else
            {
                if  kFrequencyAdsInCells_channel  > 4 && nativeAdArray.count > 0
                {
                    row = row - (row /  kFrequencyAdsInCells_channel )
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCellThree
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = tableViewBgColor
                var videosInfo:NSDictionary!
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    if ( kFrequencyAdsInCells_channel  > 4 && nativeAdArray.count > 0)
                    {
                        let adcount = row/(kFrequencyAdsInCells_channel - 1)
                        if(myChannelResponse.count > ((row)*2+adcount))
                        {
                            videosInfo = myChannelResponse[((row)*2+adcount)] as! NSDictionary
                            cell.contentSelection.tag = ((row)*2+adcount)
                            cell.menu.tag = ((row)*2+adcount)
                            
                        }
                    }
                    else
                    {
                        if(myChannelResponse.count > (row)*2)
                        {
                            videosInfo = myChannelResponse[(row)*2] as! NSDictionary
                            cell.contentSelection.tag = (row)*2
                            cell.menu.tag = (row)*2
                            
                        }
                    }
                    
                }
                else
                {
                    videosInfo = myChannelResponse[row] as! NSDictionary
                    cell.contentSelection.tag = row
                    cell.menu.tag = row
                }
                
                //Select Video Action
                cell.contentSelection.addTarget(self, action: #selector(ChannelViewController.showVideo(_:)), for: .touchUpInside)
                //  cell.imgVideo.addTarget(self, action: #selector(ChannelViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                //  cell.imgVideo.tag = cell.contentSelection.tag
                cell.imgVideo.isHidden = true
                
                // Set MenuAction
                cell.menu.addTarget(self, action:#selector(ChannelViewController.showVideoMenu(_:)) , for: .touchUpInside)
                cell.contentImage.frame.size.height = 180
                //        cell.contentSelection.frame.size.height = 180
                // Set Video Image
                if let imgeMain = videosInfo["video_overlay_image"] as? [String : AnyObject], let url = URL(string: imgeMain["url"] as? String ?? "")
                {
                    cell.imgViewOverLay.kf.indicatorType = .activity
                    (cell.imgViewOverLay.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgViewOverLay.kf.setImage(with: url, placeholder: UIImage(named : ""), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
                else
                {
                    cell.imgViewOverLay.image = UIImage(named: "")
                }
                if (videosInfo["image"] as? String) != nil
                {
                    let url  = URL(string: videosInfo["image"] as! NSString as String)
                    
                    cell.contentImage.kf.indicatorType = .activity
                    (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImage.kf.setImage(with: url, placeholder: UIImage(named: "nophoto_video_thumb_icon.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        cell.contentImage.backgroundColor = UIColor.clear
                    })
                }
                else
                {
                    cell.contentImage.image = UIImage(named: "nophoto_video_thumb_icon.png")!
                }
                
         
                
                // Set Video Name
                let duration = videosInfo["videos_count"] as? Int
                cell.videoDuration.isHidden = false
                
                
                if duration == 1
                {
                    cell.videoDuration.text = "\(duration!) Video"
                }
                else{
                    cell.videoDuration.text = "\(duration!) Videos"
                }
                cell.videoDuration.frame.origin.x = cell.contentImage.bounds.width - 70
                cell.videoDuration.frame.size.width = 65
                cell.contentName.frame = CGRect(x: (cell.contentImage.bounds.width - 50), y: 110, width: (cell.contentImage.bounds.width-100), height: 10)
                cell.contentName.font = UIFont(name: fontName, size: FONTSIZESmall)
                cell.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.contentName.sizeToFit()
                cell.contentName.frame.origin.y = (cell.contentImage.bounds.height - (cell.contentName.bounds.height+10))
                
                // Set Video Info
                
                cell.createdBy.frame = CGRect(x: contentPADING , y: cell.contentImage.bounds.height, width: cell.cellView.bounds.width - (cell.cellView.bounds.height - cell.contentImage.bounds.height), height: cell.cellView.bounds.height - cell.contentImage.bounds.height)
                var tempInfo = ""
                var value = ""
                
                if let videoTitle = videosInfo["title"] as? NSString {
                    if videoTitle.length > 32{
                        value = videoTitle.substring(to: 32-3)
                        value += NSLocalizedString("...",  comment: "")
                    }else{
                        value = "\(videoTitle)"
                    }
                }else if videosInfo["title"] is NSNumber{
                    let videoTitle = String(describing: videosInfo["title"]!) as NSString
                    
                    if videoTitle.length > 32{
                        value = videoTitle.substring(to: 32-3)
                        value += NSLocalizedString("...",  comment: "")
                    }else{
                        value = "\(videoTitle)"
                    }
                    
                }
                
                
                tempInfo = "\(value)\n"
                tempInfo = "\(tempInfo)"
                let postedDate = videosInfo["creation_date"] as? String
                
                let date = dateDifferenceWithEventTime(postedDate!)
                var DateC = date.components(separatedBy: ", ")
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
                
                cell.createdBy.delegate = self
                cell.createdBy.textAlignment = .left
                cell.createdBy.textColor = textColorMedium
                cell.createdBy.numberOfLines = 0
                
                cell.createdBy.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                    let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                    let range = (tempInfo as NSString).range(of: value)
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                    
                    
                    return mutableAttributedString
                })
                // Set Like , Comment & ViewCount
                
                var totalView = ""
                if let ratingCount = videosInfo["rating_count"] as? Int{
                    totalView = "\(ratingCount) \(starIcon)"
                }
                if videoTypeCheck == "sitegroup"{
                    if let ratingCount = videosInfo["rating"] as? Int{
                        totalView = "\(ratingCount) \(starIcon)"
                    }
                    
                }
                
                if let likes = videosInfo["like_count"] as? Int{
                    totalView += " \(likes) \(likeIcon)"
                }
                if let comment = videosInfo["comment_count"] as? Int{
                    totalView += " \(comment) \(viewIcon)"
                }
                cell.totalMembers.textColor = textColorMedium
                cell.totalMembers.text = "\(totalView)"
                cell.totalMembers.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                
                // Set Menu
                if(isIpad()){
                    
                    if videoBrowseType == 5 {
                        cell.menu.isHidden = true
                        cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 95)
                        //
                        cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage.bounds.height, width: 95
                            , height: 40)
                        
                    }else{
                        cell.menu.isHidden = false
                        cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 95)
                        cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage.bounds.height, width: 95
                            , height: 40)
                        
                    }
                    
                }
                else{
                    if videoBrowseType == 5 {
                        cell.menu.isHidden = true
                        cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 90)
                        cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 90,y: cell.contentImage.bounds.height, width: 90
                            , height: 40)
                        
                    }else{
                        cell.menu.isHidden = false
                        cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 90)
                        cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 90,y: cell.contentImage.bounds.height, width: 90
                            , height: 40)
                        
                    }
                    
                }
                
                // RHS
                if(isIpad()){
                    var videosInfo2:NSDictionary!
                    var adcount = Int()
                    if (kFrequencyAdsInCells_channel  > 4 && nativeAdArray.count > 0)
                    {
                        adcount = row/(kFrequencyAdsInCells_channel - 1)
                    }
                    else
                    {
                        adcount = 0
                    }
                    if(channelResponse.count > ((row)*2+1+adcount))
                    {
                        
                        videosInfo2 = channelResponse[((row)*2+1+adcount)] as! NSDictionary
                        cell.cellView2.isHidden = false
                        cell.contentSelection2.isHidden = false
                        cell.contentSelection2.tag = ((row)*2+1+adcount)
                        cell.menu2.tag = ((row)*2+1+adcount)
                    }
                    else
                    {
                        cell.cellView2.isHidden = true
                        cell.contentSelection2.isHidden = true
                        return cell
                    }
                    
                    // Select Video Action
                    cell.contentSelection2.addTarget(self, action: #selector(ChannelViewController.showVideo(_:)), for: .touchUpInside)
                    //  cell.imgVideo2.addTarget(self, action: #selector(ChannelViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                    //  cell.imgVideo2.tag = cell.contentSelection2.tag
                    cell.imgVideo2.isHidden = true
                    // Set MenuAction
                    cell.menu2.addTarget(self, action:#selector(ChannelViewController.showVideoMenu(_:)) , for: .touchUpInside)
                    cell.contentImage2.frame.size.height = 180
                    
                    if (videosInfo2["image"] as? String) != nil
                    {
                        let url  = URL(string: videosInfo2["image"] as! NSString as String)
                        cell.contentImage2.kf.indicatorType = .activity
                        (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage2.kf.setImage(with: url, placeholder: UIImage(named: "nophoto_video_thumb_icon.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            cell.contentImage2.backgroundColor = UIColor.clear
                        })
                        
                    }
                    else
                    {
                        cell.contentImage2.image = UIImage(named: "nophoto_group_thumb_profile.png")!
                    }
                    
                    // Set Video Duration
                    let videoscount = videosInfo2["videos_count"] as? Int
                    cell.videoDuration2.isHidden = false
                    cell.videoDuration2.text = "\(videoscount!) Video"
                    cell.contentName2.frame = CGRect(x: (cell.contentImage2.bounds.width - 50), y: 110, width: (cell.contentImage2.bounds.width-100), height: 10)
                    cell.contentName2.font = UIFont(name: fontName, size: FONTSIZESmall)
                    //            cell.contentName2.text = timeFormatted(duration!)
                    cell.contentName2.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.contentName2.sizeToFit()
                    cell.contentName2.frame.origin.y = (cell.contentImage2.bounds.height - (cell.contentName2.bounds.height+10))
                    // Set Video Info
                    cell.createdBy2.frame = CGRect(x: contentPADING , y: cell.contentImage2.bounds.height, width: cell.cellView2.bounds.width - (cell.cellView2.bounds.height - cell.contentImage2.bounds.height), height: cell.cellView2.bounds.height - cell.contentImage2.bounds.height)
                    
                    var value2 = ""
                    
                    if let videoTitle2 = videosInfo2["title"] as? NSString {
                        if videoTitle2.length > 25{
                            value2 = videoTitle2.substring(to: 25 - 3)
                            value2 += NSLocalizedString("...",  comment: "")
                        }else{
                            value2 = "\(videoTitle2)"
                        }
                    }else if videosInfo2["title"] is NSNumber{
                        let videoTitle2 = String(describing: videosInfo2["title"]!) as NSString
                        
                        if videoTitle2.length > 25{
                            value2 = videoTitle2.substring(to: 25 - 3)
                            value2 += NSLocalizedString("...",  comment: "")
                        }else{
                            value2 = "\(videoTitle2)"
                        }
                        
                        
                    }
                    
                    tempInfo = "\(value2)\n"
                    tempInfo = "\(tempInfo)\n"
                    let postedDate2 = videosInfo2["creation_date"] as? String
                    
                    let date = dateDifferenceWithEventTime(postedDate2!)
                    var DateC = date.components(separatedBy: ", ")
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
                    
                    
                    cell.createdBy2.delegate = self
                    cell.createdBy2.textAlignment = .left
                    cell.createdBy2.textColor = textColorMedium
                    cell.createdBy2.numberOfLines = 0
                    
                    cell.createdBy2.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                        let range = (tempInfo as NSString).range(of: value2)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                        
                        
                        return mutableAttributedString
                    })
                    
                    var totalView = ""
                    if let ratingCount = videosInfo2["rating_count"] as? Int{
                        totalView = "\(ratingCount) \(starIcon)"
                    }
                    if let likes = videosInfo2["like_count"] as? Int{
                        totalView += " \(likes) \(likeIcon)"
                    }
                    if let comment = videosInfo2["comment_count"] as? Int{
                        totalView += " \(comment) \(commentIcon)"
                    }
                    cell.totalMembers2.text = "\(totalView)"
                    cell.totalMembers2.textColor = textColorMedium
                    cell.totalMembers2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                    cell.totalMembers2.sizeToFit()
                    //Set Menu
                    if videoBrowseType == 5 {
                        cell.menu2.isHidden = true
                        cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                        cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)
                    }else{
                        cell.menu2.isHidden = false
                        cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                        cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)
                    }
                }
                return cell
            }
            
        }
        else if ((videoBrowseType == 5 || videoBrowseType == 3) && categoryResponse.count > (indexPath.row - 1))
        {
            
            let cell = categoryTableView.dequeueReusableCell(withIdentifier: "CategoryCell2") as! CategoryTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            cell.DiaryName.isHidden = false
            cell.DiaryName1.isHidden = false
            cell.classifiedImageView.frame.size.height = 155
            cell.backgroundColor = UIColor.clear
            var index:Int!
            index = (indexPath as NSIndexPath).row * 2
            if categoryResponse.count > index
            {
                cell.contentSelection.isHidden = false
                cell.classifiedImageView.isHidden = false
                cell.DiaryName.isHidden = false
                //cell.classifiedImageView.image = nil
                
                if let imageInfo = categoryResponse[index] as? NSDictionary
                {
                    if imageInfo["images"] != nil
                    {
                        
                        if let imagedic = imageInfo["images"] as? NSDictionary
                        {
                            if let url = URL(string: imagedic["image"] as! String)
                            {
                                cell.classifiedImageView.kf.indicatorType = .activity
                                (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.classifiedImageView.kf.setImage(with: url, placeholder: UIImage(named: "nophoto_video_thumb_icon.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                })
                                
                            }
                        }
                    }
                    
                    // LHS
                    cell.DiaryName.text = imageInfo["category_name"] as? String
                    cell.contentSelection.tag = index//imageInfo["category_id"] as! Int
                    cell.contentSelection.addTarget(self, action: #selector(ChannelViewController.showSubCategory(_:)), for: .touchUpInside)
                    
                }
                
                
            }
            else
            {
                cell.contentSelection.isHidden = true
                cell.classifiedImageView.isHidden = true
                cell.DiaryName.isHidden = true
                
                
                
                cell.contentSelection1.isHidden = true
                cell.classifiedImageView1.isHidden = true
                cell.DiaryName1.isHidden = true
                
                
            }
            if categoryResponse.count > (index + 1)
            {
                cell.contentSelection1.isHidden = false
                cell.classifiedImageView1.isHidden = false
                cell.DiaryName1.isHidden = false
                
                
                //cell.classifiedImageView1.image = nil
                if let imageInfo = categoryResponse[index + 1] as? NSDictionary
                {
                    if imageInfo["images"] != nil
                    {
                        
                        if let imagedic = imageInfo["images"] as? NSDictionary
                        {
                            
                            if let url = URL(string: imagedic["image"] as! String)
                            {
                                cell.classifiedImageView1.image = nil
                                cell.classifiedImageView1.kf.indicatorType = .activity
                                (cell.classifiedImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.classifiedImageView1.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                })
                            }
                            
                        }
                    }
                    cell.DiaryName1.text = imageInfo["category_name"] as? String
                    cell.contentSelection1.tag = index+1//imageInfo["category_id"] as! Int
                    cell.contentSelection1.addTarget(self, action: #selector(AdvancedEventViewController.showSubCategory(_:)), for: .touchUpInside)
                }
                
            }
            else
            {
                cell.contentSelection1.isHidden = true
                cell.classifiedImageView1.isHidden = true
                cell.DiaryName1.isHidden = true
                
            }
            
            return cell
        }
        
        let cell = CustomTableViewCellThree()
        return cell
    }
    
    
    // MARK:  UIScrollViewDelegate
    // Handle Scroll For Pagination
    //    func scrollViewDidScroll(_ scrollView: UIScrollView)
    //    {
    //        if scrollView.tag != 2
    //        {
    //            if updateScrollFlag
    //            {
    //
    //                filterDic.removeAll(keepingCapacity: false)
    //                filterDic2.removeAll(keepingCapacity: false)
    //                // Check for Page Number for Browse Video
    //                if videoBrowseType == 5
    //                {
    //                    if ChannelTableView.contentOffset.y >= ChannelTableView.contentSize.height - ChannelTableView.bounds.size.height{
    //                        if (!isPageRefresing  && limit*pageNumber < totalItems){
    //                            if Reachabable.isConnectedToNetwork() {
    //                                updateScrollFlag = false
    //                                pageNumber += 1
    //                                isPageRefresing = true
    //                                if filterDic.count == 0{
    //                                    browseChannel()
    //                                }
    //                            }
    //                        }
    //
    //                    }
    //                }
    //                else if videoBrowseType == 6
    //                {
    //                    if myChannelTableView.contentOffset.y >= myChannelTableView.contentSize.height - myChannelTableView.bounds.size.height{
    //                        if (!isPageRefresing  && limit*pageNumber < totalItems)
    //                        {
    //                            if Reachabable.isConnectedToNetwork()
    //                            {
    //                                updateScrollFlag = false
    //                                pageNumber += 1
    //                                isPageRefresing = true
    //                                if filterDic2.count == 0{
    //                                    browseChannel()
    //                                }
    //                            }
    //                        }
    //
    //                    }
    //
    //                }
    //
    //            }
    //        }
    //
    //    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var row = (indexPath as NSIndexPath).row as Int
        // Apply condition for tableViews
        
         if (kFrequencyAdsInCells_channel > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_channel) == (kFrequencyAdsInCells_channel)-1))
        {
            
            let cell = tableView.cellForRow(at: indexPath) as! NativeVideoCellTableViewCell
            cell.selectionStyle = .none
            
            cell.backgroundColor = .clear
            
            if muteVideo == true
            {
                muteVideo = false
                shared1.muteVideosFor(tableView: self.ChannelTableView)
                cell.btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                //sender.setTitle("\(unMuteIconIcon)", for: .normal)
            }
            else
            {
                muteVideo = true
                shared1.muteVideosFor(tableView: self.ChannelTableView)
                cell.btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                //sender.setTitle("\(muteVideoIcon)", for: .normal)
            }
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            
            if NotPlay != 1 {
                self.pausePlayeVideos()
            }
            
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        if maximumOffset - currentOffset <= 10
        {
            if scrollView.tag != 2
            {
                
                if updateScrollFlag{
                    
                    filterDic.removeAll(keepingCapacity: false)
                    filterDic2.removeAll(keepingCapacity: false)
                    // Check for Page Number for Browse Video
                    if videoBrowseType == 3
                    {
                        //                    if ChannelTableView.contentOffset.y >= ChannelTableView.contentSize.height - ChannelTableView.bounds.size.height{
                        if (!isPageRefresing  && limit*pageNumber < totalItems){
                            if Reachabable.isConnectedToNetwork() {
                                updateScrollFlag = false
                                pageNumber += 1
                                isPageRefresing = true
                                myChannelTableView.tableFooterView?.isHidden = false
                                // if filterDic.count == 0{
                                browseChannel()
                                // }
                            }
                        }
                        else
                        {
                            myChannelTableView.tableFooterView?.isHidden = true
                        }
                        
                        //  }
                    }
                    else if videoBrowseType == 4
                    {
                        //                    if myChannelTableView.contentOffset.y >= myChannelTableView.contentSize.height - myChannelTableView.bounds.size.height{
                        if (!isPageRefresing  && limit*pageNumber < totalItems)
                        {
                            if Reachabable.isConnectedToNetwork()
                            {
                                updateScrollFlag = false
                                pageNumber += 1
                                isPageRefresing = true
                                myChannelTableView.tableFooterView?.isHidden = false
                                //  if filterDic2.count == 0{
                                browseChannel()
                                // }
                            }
                        }
                        else
                        {
                            myChannelTableView.tableFooterView?.isHidden = true
                        }
                        
                        //  }
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @objc func checkforAds()
    {
        nativeAdArray.removeAll()
        if adsType_channel == 1
        {
            if  kFrequencyAdsInCells_channel  > 4 && placementID != ""
            {
                if arrGlobalFacebookAds.count == 0
                {
                    FacebookAds.showFacebookAd(viewController: self)
                }
                else
                {
                    for nativeAd in arrGlobalFacebookAds {
                        FacebookAds.createAdView(nativeAd: nativeAd, viewController: self, adArray: &nativeAdArray, frame: fbAdFrame)
                    }
                    if nativeAdArray.count == 10
                    {
                        ChannelTableView.reloadData()
                    }
                }
                
            }
        }
        else if adsType_channel == 0
        {
            if  kFrequencyAdsInCells_channel  > 4 && adUnitID != ""
            {
                //showNativeAd()
                
            }
        }
        else if adsType_channel == 2 {
            checkCommunityAds()
        }
        
    }
    //MARK: -  Functions that we are using for community ads and sponsered stories
    func  checkCommunityAds()
    {
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            var dic = Dictionary<String, String>()
            dic["type"] =  "\(adsType_channel)"
            dic["placementCount"] = "\( kFrequencyAdsInCells_channel )"
            post(dic, url: "communityads/index/index", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if let advertismentsArray = body["advertisments"] as? NSArray
                                {
                                    self.communityAdsValues = advertismentsArray
                                    self.uiOfCommunityAds(count: advertismentsArray.count){
                                        (status : Bool) in
                                        if status == true{
                                            self.ChannelTableView.reloadData()
                                        }
                                    }
                                    
                                }
                            }
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
    func uiOfCommunityAds(count : Int,completion: @escaping (_ status: Bool) -> Void)
    {
        var status  = false
        for i in 0  ..< communityAdsValues.count{
            
            if  let dic = communityAdsValues[i]  as? NSDictionary {
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    self.fbView = UIView(frame: CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: 320))
                }
                else
                {
                    self.fbView = UIView(frame: CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: 320))
                }
                self.fbView.backgroundColor = textColorclear
                self.fbView.tag = 1001001
                
                adsImage = createImageView(CGRect(x: 5, y: 5, width: 40, height: 40), border: false)
                if dic["image_icon"] != nil{
                    let icon = dic["image_icon"]
                    let url = URL(string:icon as! String)
                    
                    
                    adsImage.kf.setImage(with: url! as URL, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                adsImage.layer.cornerRadius = 20
                adsImage.layer.masksToBounds = true
                self.fbView.addSubview(adsImage)
                
                adTitleLabel = UILabel(frame: CGRect(x: 50,y: 15,width: self.fbView.bounds.width-(40),height: 30))
                adTitleLabel.numberOfLines = 0
                adTitleLabel.textColor = textColorDark
                adTitleLabel.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                let title = String(describing: dic["web_name"] ?? "")
                adTitleLabel.text = title
                adTitleLabel.sizeToFit()
                self.fbView.addSubview(adTitleLabel)
                
                adTitleLabel.isUserInteractionEnabled = true // Remember to do this
                let tap: UITapGestureRecognizer = UITapGestureRecognizer(
                    target: self, action: #selector(didTapLabelDemo))
                adTitleLabel.addGestureRecognizer(tap)
                tap.delegate = self
                adTitleLabel.tag = i
                
                
                adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-(30), y: 10,width: 26,height: 26))
                let adsimg = UIImage(named: "crossimg.png")!.maskWithColor(color: textColorMedium)
                self.adCallToActionButton.setImage(adsimg , for: UIControl.State.normal)
                adCallToActionButton.backgroundColor = textColorclear
                adCallToActionButton.layer.cornerRadius = 13;
                
                
                if logoutUser == true {
                    adCallToActionButton.isHidden = true
                }
                
                adCallToActionButton.tag = i
                if logoutUser == true {
                    adCallToActionButton.isHidden = true
                }
                adCallToActionButton.addTarget(self, action: #selector(ChannelViewController.actionAfterClick(_:)), for: .touchUpInside)
                self.fbView.addSubview(adCallToActionButton)
                if  (UIDevice.current.userInterfaceIdiom == .phone)
                {
                    imageButton = createButton(CGRect(x: 5,y: self.adsImage.bounds.height + 15 + self.adsImage.frame.origin.y,width: self.fbView.bounds.width-10,height: self.fbView.bounds.height/2 + 5),title: "", border: false, bgColor: false, textColor: textColorLight)
                    adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.imageButton.bounds.width,height: self.fbView.bounds.height/2 + 5), border: false)
                }
                else
                {
                    imageButton = createButton(CGRect(x: 5,y: self.adsImage.bounds.height + 10 + self.adsImage.frame.origin.y,width: self.fbView.bounds.width-10,height: self.fbView.bounds.height/2 + 5),title: "", border: false, bgColor: false, textColor: textColorLight)
                    adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.fbView.bounds.width-10,height: self.fbView.bounds.height/2 + 5), border: false)
                }
                
                adImageView1.contentMode = .scaleAspectFill
                adImageView1.layer.masksToBounds = true
                if dic["image"] != nil{
                    let icon = dic["image"]
                    let url = URL(string:icon as! String)
                    
                    adImageView1.kf.setImage(with: url! as URL, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                imageButton.tag = i
                
                
                if dic["cmd_ad_format"] as! String == "carousel"{
                    
                    cdAds = ContentSlideshowScrollView(frame: CGRect(x: 12,y: self.adsImage.bounds.height + 15 + self.adsImage.frame.origin.y,width: self.fbView.bounds.width-24,height: self.fbView.bounds.height - 60))
                    cdAds.backgroundColor = UIColor.white
                    cdAds.delegate = self
                    if dic["carousel"] != nil {
                        cdAds.browseAdsSellContent(contentItems: dic["carousel"] as! [AnyObject] , comingFrom: "")
                    }
                    self.fbView.addSubview(self.cdAds)
                }
                else if dic["cmd_ad_format"] as! String == "video"{
                    
                    
                    videoclickButton = createButton(CGRect(x: 5,y: self.adsImage.bounds.height + 10 + self.adsImage.frame.origin.y,width: self.fbView.bounds.width-55,height: self.fbView.bounds.height - (self.adsImage.bounds.height + 10 + self.adsImage.frame.origin.y)),title: "", border: false, bgColor: false, textColor: textColorLight)
                    
                    
                    videoclickButton.addTarget(self, action: #selector(ChannelViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
                    self.fbView.addSubview(videoclickButton)
                }
                else{
                    imageButton.addTarget(self, action: #selector(ChannelViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
                    self.fbView.addSubview(imageButton)
                    imageButton.addSubview(adImageView1)
                }
                
                if dic["cmd_ad_format"] as! String != "carousel"{
                    cadUrl = UILabel(frame: CGRect(x: 5,y: imageButton.bounds.height + 10 + imageButton.frame.origin.y,width: self.fbView.bounds.width-10,height: 40))
                    cadUrl.numberOfLines = 1
                    cadUrl.lineBreakMode = .byTruncatingTail
                    cadUrl.textColor = textColorDark
                    cadUrl.font = UIFont(name: fontBold, size: 14.0)
                    self.fbView.addSubview(cadUrl)
                    let description1 = String(describing: dic["cads_url"] ?? "")
                    if dic["cmd_ad_format"] as! String == "image"{
                        cadUrl.text = ""
                    }
                    else{
                        cadUrl.text = ""//description1
                    }
                    cadUrl.sizeToFit()
                    cadUrl.frame.size.width = self.fbView.bounds.width-10
                    
                    cadUrl.isUserInteractionEnabled = true // Remember to do this
                    let tap1: UITapGestureRecognizer = UITapGestureRecognizer(
                        target: self, action: #selector(didTapLabelDemo1))
                    cadUrl.addGestureRecognizer(tap1)
                    tap1.delegate = self
                    
                    cadUrl.tag = i
                    
                    if dic["cta_button"] != nil {
                        ctaButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-(82), y: cadUrl.bounds.height +  cadUrl.frame.origin.y + 7,width: 80,height: 30))
                        ctaButton.setTitle(" \(dic["cta_button"] ?? "") ", for: .normal)
                        ctaButton.titleLabel?.font = UIFont(name: fontNormal, size: FONTSIZENormal)
                        ctaButton.backgroundColor = buttonColor
                        ctaButton.layer.cornerRadius = 4;
                        ctaButton.setTitleColor(textColorPrime, for: .normal)
                        ctaButton.frame.size.width = findWidthByTextFont(" \(dic["cta_button"] ?? "") ", fontNormal, FONTSIZENormal)
                        ctaButton.frame.origin.x = self.fbView.bounds.width-((ctaButton.frame.size.width) + 12)
                        ctaButton.frame.size.height = 30
                        ctaButton.isHidden = false
                        if ctaButton.titleLabel?.text == "  "{
                            ctaButton.isHidden = true
                        }
                        ctaButton.tag = i
                        
                        ctaButton.addTarget(self, action: #selector(ChannelViewController.tappedOnAds(_:)), for: .touchUpInside)
                        self.fbView.addSubview(ctaButton)
                    }
                    else{
                        ctaButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-(82), y: cadUrl.bounds.height +  cadUrl.frame.origin.y + 7,width: 0,height: 30))
                        ctaButton.isHidden = true
                        self.fbView.addSubview(ctaButton)
                    }
                    cadTitle = UILabel(frame: CGRect(x: 5,y: cadUrl.bounds.height + 5 + cadUrl.frame.origin.y,width: self.fbView.bounds.width-(ctaButton.frame.size.width + 10),height: 40))
                    cadTitle.numberOfLines = 1
                    cadTitle.lineBreakMode = .byTruncatingTail
                    cadTitle.textColor = textColorDark
                    cadTitle.font = UIFont(name: fontBold, size: 13.0)
                    self.fbView.addSubview(cadTitle)
                    var description2 = String(describing: dic["cads_title"] ?? "")
                    cadTitle.text = description2
                    cadTitle.sizeToFit()
                    cadTitle.frame.size.width = self.fbView.bounds.width-(ctaButton.frame.size.width + 10)
                    
                    
                    
                    
                    adBodyLabel = UILabel(frame: CGRect(x: 5,y: cadTitle.bounds.height + 5 + cadTitle.frame.origin.y,width: self.fbView.bounds.width-(ctaButton.frame.size.width + 10),height: 40))
                    adBodyLabel.numberOfLines = 2
                    adBodyLabel.lineBreakMode = .byTruncatingTail
                    adBodyLabel.textColor = textColorDark
                    adBodyLabel.textAlignment = .left
                    adBodyLabel.font = UIFont(name: fontName, size: 12.0)
                    self.fbView.addSubview(adBodyLabel)
                    var description = String(describing: dic["cads_body"] ?? "")
                    description = description.replacingOccurrences(of: "<br />", with: "\n")
                    description = description.replacingOccurrences(of: "\r\n", with: "")
                    adBodyLabel.text = description
                    adBodyLabel.sizeToFit()
                    adBodyLabel.frame.size.width = self.fbView.bounds.width-(ctaButton.frame.size.width + 10)
                    
                    
                }
                nativeAdArray.append(self.fbView)
                
                if i == count - 1{
                    status = true
                    completion(status)
                    
                }
                
            }
        }
        
    }
    
    
    @objc func didTapLabelDemo(gesture: UITapGestureRecognizer) {
        let text = (adTitleLabel.text)!
        
        let termsRange = (text as NSString).range(of: "\(text as NSString)")
        
        if gesture.didTapAttributedTextInLabel(label: adTitleLabel, inRange: termsRange) {
            print("Tapped terms")
            let tagvalue = gesture.view?.tag
            let dic = communityAdsValues[tagvalue!] as? NSDictionary
            if dic?["web_url"] != nil
            {
                
                fromExternalWebView = true
                let presentedVC = ExternalWebViewController()
                presentedVC.url = dic?["web_url"] as? String ?? ""
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let navigationController = UINavigationController(rootViewController: presentedVC)
                self.present(navigationController, animated: true, completion: nil)
            }
        } else {
            print("Tapped none")
        }
    }
    
    @objc func didTapLabelDemo1(gesture: UITapGestureRecognizer) {
        let text = (cadUrl.text)!
        let termsRange = (text as NSString).range(of: "\(text as NSString)")
        
        if gesture.didTapAttributedTextInLabel(label: cadUrl, inRange: termsRange) {
            print("Tapped terms url")
            let tagvalue = gesture.view?.tag
            let dic = communityAdsValues[tagvalue!] as? NSDictionary
            if dic?["cads_url"] != nil
            {
                
                fromExternalWebView = true
                let presentedVC = ExternalWebViewController()
                presentedVC.url = dic?["cads_url"] as? String ?? ""
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let navigationController = UINavigationController(rootViewController: presentedVC)
                self.present(navigationController, animated: true, completion: nil)
            }
        } else {
            print("Tapped none")
        }
    }
    @objc func tappedOnAds(_ sender: UIButton){
        let dic = communityAdsValues[sender.tag] as? NSDictionary
        if dic?["cads_url"] != nil{
            let presentedVC = ExternalWebViewController()
            presentedVC.url = dic?["cads_url"]! as! String
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated: true, completion: nil)
        }
        
    }
    @objc func actionAfterClick(_ sender: UIButton){
        var dictionary = Dictionary<String, String>()
        dictionary["type"] =  "\(adsType_channel)"
        dictionary["placementCount"] = "\( kFrequencyAdsInCells_channel )"
        let dic = communityAdsValues[sender.tag] as? NSDictionary
        if dic!["userad_id"] != nil{
            dictionary["adsId"] =  String(dic!["userad_id"] as! Int)
        }
        else if dic?["ad_id"] != nil{
            dictionary["adsId"] =  String(describing: dic?["ad_id"]!)
        }
        parametersNeedToAdd = dictionary
        if reportDic.count == 0{
            if Reachabable.isConnectedToNetwork() {
                self.parent?.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                // Send Server Request for Comments
                post(dictionary, url: "communityads/index/remove-ad", method: "GET") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg
                        {
                            if succeeded["body"] != nil{
                                if let body = succeeded["body"] as? NSDictionary{
                                    if let form = body["form"] as? NSArray
                                    {
                                        let  key = form as! [NSDictionary]
                                        
                                        for dic in key
                                        {
                                            for(k,v) in dic{
                                                if k as! String == "multiOptions"{
                                                    self.blackScreenForAdd = UIView(frame: (self.parent?.view.frame)!)
                                                    self.blackScreenForAdd.backgroundColor = UIColor.black
                                                    self.blackScreenForAdd.alpha = 0.0
                                                    self.parent?.view.addSubview(self.blackScreenForAdd)
                                                    self.adsReportView = AdsReportViewController(frame:CGRect(x:  10,y: (self.parent?.view.bounds.height)!/2  ,width: self.view.bounds.width - (20),height: 100))
                                                    self.adsReportView.showMenu(dic: v as! NSDictionary,parameters : dictionary,view : self)
                                                    reportDic = v as! NSDictionary
                                                    self.parent?.view.addSubview(self.adsReportView)
                                                    
                                                    
                                                    UIView.animate(withDuration: 0.2) { () -> Void in
                                                        self.adsReportView.frame.origin.y = (self.parent?.view.bounds.height)!/2 - self.adsReportView.frame.height/2 - 50
                                                        self.blackScreenForAdd.alpha = 0.5
                                                        
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
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
        else {
            self.blackScreenForAdd = UIView(frame: (self.parent?.view.frame)!)
            self.blackScreenForAdd.backgroundColor = UIColor.black
            self.blackScreenForAdd.alpha = 0.0
            self.parent?.view.addSubview(self.blackScreenForAdd)
            self.adsReportView = AdsReportViewController(frame:CGRect(x:  10,y: (self.parent?.view.bounds.height)!/2  ,width: self.view.bounds.width - (20),height: 100))
            self.adsReportView.showMenu(dic: reportDic as NSDictionary,parameters : dictionary,view : self)
            self.parent?.view.addSubview(self.adsReportView)
            
            
            UIView.animate(withDuration: 0.2) { () -> Void in
                self.adsReportView.frame.origin.y = (self.parent?.view.bounds.height)!/2 - self.adsReportView.frame.height/2 - 50
                self.blackScreenForAdd.alpha = 0.5
                
            }
            
        }
        
    }
   @objc func doneAfterReportSelect(){
        for ob in adsReportView.subviews{
            if ob is UITextField{
                ob.resignFirstResponder()
            }
            
        }
        UIView.animate(withDuration:0.5) { () -> Void in
            self.blackScreenForAdd.isHidden = true
            self.adsReportView.isHidden = true
            self.blackScreenForAdd.alpha = 0.0
        }
        
    }
   @objc func pressedAd(_ sender: UIButton){
        
      //  parametersNeedToAdd = [:]
        for ob in adsReportView.subviews{
            if ob .isKind(of: UIButton.self){
                if ob.tag == 0 || ob.tag == 1 || ob.tag == 2 || ob.tag == 3 || ob.tag == 4{
                    (ob as! UIButton).setTitle("\u{f10c}", for: UIControl.State.normal)
                }
            }
        }
        
        parametersNeedToAdd["adCancelReason"] =  configArray["\(sender.tag)"]!
        sender.setTitle("\u{f111}", for: UIControl.State.normal)
        if parametersNeedToAdd["adCancelReason"] != "Other"{
            
            for ob in adsReportView.subviews{
                if ob is UITextField{
                    ob.isHidden = true
                }
                if ob.tag == 1000{
                    ob.isHidden = true
                }
                if ob.tag == 1005{
                    ob.isHidden = false
                }
            }
            // removeAd()
        }
        else{
            for ob in adsReportView.subviews{
                if ob is UITextField{
                    ob.isHidden = false
                }
                if ob.tag == 1000{
                    ob.isHidden = false
                }
                if ob.tag == 1005{
                    ob.isHidden = true
                }
            }
        }
    }
    @objc func submitReasonPressed()
    {
        removeAd()
    }
    func removeAd(){
        self.doneAfterReportSelect()
        showToast(message: NSLocalizedString("Thanks for your feedback. Your report has been submitted.", comment: ""), controller: self)
        activityIndicatorView.startAnimating()
        if Reachabable.isConnectedToNetwork() {
            post(parametersNeedToAdd, url: "communityads/index/remove-ad", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        
                        if succeeded["body"] != nil{
                            if (succeeded["body"] as? NSDictionary) != nil{
                                self.nativeAdArray.removeAll(keepingCapacity: false)
                                self.checkCommunityAds()
                            }
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
    @objc func removeOtherReason(){
        for ob in adsReportView.subviews{
            if ob is UITextField{
                let view = ob as? UITextField
                parametersNeedToAdd["adDescription"] = view?.text
            }
        }
        removeAd()
        
    }
    
    // MARK: - FacebookAd Delegate
    func nativeAdsLoaded()
    {
        arrGlobalFacebookAds.removeAll()
        for _ in 0 ..< 10
        {
            if let fb = FacebookAds.admanager?.nextNativeAd
            {
                fb.unregisterView()
                arrGlobalFacebookAds.append(fb)
            }
        }
        for nativeAd in arrGlobalFacebookAds {
            FacebookAds.createAdView(nativeAd: nativeAd, viewController: self, adArray: &nativeAdArray, frame: fbAdFrame)
        }
        
        if self.nativeAdArray.count == 10
        {
            self.ChannelTableView.reloadData()
            self.myChannelTableView.reloadData()
        }
        //      }
        
    }
  
    
    public func nativeAdsFailedToLoadWithError(_ error: Error)
    {
        print(error.localizedDescription)
    }
    
    
    // MARK: - GADAdLoaderDelegate
//    func showNativeAd()
//    {
//        var adTypes = [GADAdLoaderAdType]()
//        if iscontentAd == true
//        {
//            if isnativeAd
//            {
//                adTypes.append(GADAdLoaderAdType.nativeAppInstall)
//                isnativeAd = false
//            }
//            else
//            {
//                adTypes.append(GADAdLoaderAdType.nativeContent)
//                isnativeAd = true
//            }
//        }
//        else
//        {
//            adTypes.append(GADAdLoaderAdType.nativeAppInstall)
//        }
//        delay(0, closure: {
//            self.adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: self,
//                                        adTypes: adTypes, options: nil)
//            self.adLoader.delegate = self
//            let request = GADRequest()
//            //            request.testDevices = [kGADSimulatorID,"bc29f25fa57e135618e267a757a5fa35"]
//            self.adLoader.load(request)
//        })
//    }
//
//    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
//        print("\(adLoader) failed with error: \(error.localizedDescription)")
//    }
//
//    // Mark: - GADNativeAppInstallAdLoaderDelegate
//    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAppInstallAd: GADNativeAppInstallAd)
//    {
//        let appInstallAdView = Bundle.main.loadNibNamed("NativeAdAdvancedevent", owner: nil,
//                                                        options: nil)?.first as! GADNativeAppInstallAdView
//
//        if(UIDevice.current.userInterfaceIdiom == .pad)
//        {
//            appInstallAdView.frame = CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: appInstallAdView.frame.size.height+150)
//        }
//        else
//        {
//            appInstallAdView.frame = CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: appInstallAdView.frame.size.height)
//        }
//
//        // Associate the app install ad view with the app install ad object. This is required to make
//        // the ad clickable.
//        appInstallAdView.nativeAppInstallAd = nativeAppInstallAd
//        appInstallAdView.tag = 1001001
//
//        (appInstallAdView.iconView as! UIImageView).frame = CGRect(x:5,y: 5,width: 40,height: 40)
//        (appInstallAdView.iconView as! UIImageView).image = nativeAppInstallAd.icon?.image
//
//        (appInstallAdView.headlineView as! UILabel).frame = CGRect(x: (appInstallAdView.iconView as! UIImageView).bounds.width + 10 ,y: 5,width: appInstallAdView.bounds.width-((appInstallAdView.iconView as! UIImageView).bounds.width + 55),height: 30)
//        (appInstallAdView.headlineView as! UILabel).numberOfLines = 0
//        (appInstallAdView.headlineView as! UILabel).textColor = textColorDark
//        (appInstallAdView.headlineView as! UILabel).font = UIFont(name: fontBold, size: FONTSIZENormal)
//        (appInstallAdView.headlineView as! UILabel).text = nativeAppInstallAd.headline
//
//        if  (UIDevice.current.userInterfaceIdiom == .phone)
//        {
//            (appInstallAdView.imageView as! UIImageView).frame = CGRect(x:0,y: (appInstallAdView.iconView as! UIImageView).bounds.height + 10 + (appInstallAdView.iconView as! UIImageView).frame.origin.y,width: appInstallAdView.bounds.width,height: 150)
//        }
//        else
//        {
//            (appInstallAdView.imageView as! UIImageView).frame = CGRect(x: 0,y: (appInstallAdView.iconView as! UIImageView).bounds.height+10+(appInstallAdView.iconView as! UIImageView).frame.origin.y,width: appInstallAdView.bounds.width,height: 300)
//        }
//
//        let imgheight = Double(appInstallAdView.frame.size.height)
//        let imgWidth = Double((appInstallAdView.imageView as! UIImageView).frame.size.width)
//        (appInstallAdView.imageView as! UIImageView).image = cropToBounds((nativeAppInstallAd.images?.first as! GADNativeAdImage).image!, width: imgWidth, height: imgheight)
//        //(appInstallAdView.imageView as! UIImageView).contentMode = .ScaleAspectFit
//
//        (appInstallAdView.bodyView as! UILabel).frame = CGRect(x: 10,y: (appInstallAdView.imageView as! UIImageView).bounds.height + 10 + (appInstallAdView.imageView as! UIImageView).frame.origin.y,width: appInstallAdView.bounds.width-100,height: 40)
//
//        (appInstallAdView.bodyView as! UILabel).text = nativeAppInstallAd.body
//        (appInstallAdView.bodyView as! UILabel).numberOfLines = 0
//        (appInstallAdView.bodyView as! UILabel).textColor = textColorDark
//        (appInstallAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZENormal)
//        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
//
//        (appInstallAdView.callToActionView as! UIButton).frame = CGRect(x: appInstallAdView.bounds.width-75, y:(appInstallAdView.imageView as! UIImageView).bounds.height + 15 + (appInstallAdView.imageView as! UIImageView).frame.origin.y,width: 70,height: 30)
//
//        (appInstallAdView.callToActionView as! UIButton).setTitle(
//            nativeAppInstallAd.callToAction, for: UIControl.State.normal)
//        (appInstallAdView.callToActionView as! UIButton).isUserInteractionEnabled = false
//        (appInstallAdView.callToActionView as! UIButton).titleLabel?.font = UIFont(name: fontName , size: verySmallFontSize)
//        (appInstallAdView.callToActionView as! UIButton).titleLabel?.textColor = buttonColor
//        (appInstallAdView.callToActionView as! UIButton).backgroundColor = bgColor
//        (appInstallAdView.callToActionView as! UIButton).layer.borderWidth = 0.5
//        (appInstallAdView.callToActionView as! UIButton).layer.borderColor = UIColor.lightGray.cgColor
//        (appInstallAdView.callToActionView as! UIButton).layer.cornerRadius = cornerRadiusSmall
//        (appInstallAdView.callToActionView as! UIButton).contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
//        nativeAdArray.append(appInstallAdView)
//
//        if loadrequestcount <= 10
//        {
//            self.loadrequestcount = self.loadrequestcount+1
//            self.adLoader.delegate = nil
//            self.showNativeAd()
//            self.ChannelTableView.reloadData()
//        }
//    }
//
//    func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd) {
//
//        let contentAdView = Bundle.main.loadNibNamed("ContentAdsFeedview", owner: nil,
//                                                     options: nil)?.first as! GADNativeContentAdView
//
//        if(UIDevice.current.userInterfaceIdiom == .pad)
//        {
//            contentAdView.frame = CGRect(x: 0,y: 0, width: UIScreen.main.bounds.width,height: contentAdView.frame.size.height+150)
//        }
//        else
//        {
//            contentAdView.frame = CGRect(x: 0,y: 0, width: UIScreen.main.bounds.width,height: contentAdView.frame.size.height)
//        }
//
//        // Associate the app install ad view with the app install ad object. This is required to make
//        // the ad clickable.
//        contentAdView.nativeContentAd = nativeContentAd
//        contentAdView.tag = 1001001
//
//        // Populate the app install ad view with the app install ad assets.
//        // Some assets are guaranteed to be present in every app install ad.
//        (contentAdView.headlineView as! UILabel).frame = CGRect(x: 10 ,y: 5,width: contentAdView.bounds.width-55, height: 30)
//        (contentAdView.headlineView as! UILabel).numberOfLines = 0
//        (contentAdView.headlineView as! UILabel).textColor = textColorDark
//        (contentAdView.headlineView as! UILabel).font = UIFont(name: fontBold, size: FONTSIZENormal)
//        (contentAdView.headlineView as! UILabel).text = nativeContentAd.headline
//
//        if  (UIDevice.current.userInterfaceIdiom == .phone)
//        {
//            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 0,y: (contentAdView.headlineView as! UILabel).bounds.height + 10 + (contentAdView.headlineView as! UILabel).frame.origin.y,width: contentAdView.bounds.width,height: 160)
//        }
//        else
//        {
//            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 0,y: (contentAdView.headlineView as! UILabel).bounds.height + 10 + (contentAdView.headlineView as! UILabel).frame.origin.y,width: contentAdView.bounds.width,height: 300)
//        }
//
//        let imgheight = Double(contentAdView.frame.size.height)
//        let imgWidth = Double((contentAdView.imageView as! UIImageView).frame.size.width)
//        (contentAdView.imageView as! UIImageView).image = cropToBounds((nativeContentAd.images?.first as! GADNativeAdImage).image!, width: imgWidth, height: imgheight)
//
//        (contentAdView.bodyView as! UILabel).frame = CGRect(x:10 ,y: (contentAdView.imageView as! UIImageView).bounds.height + 10 + (contentAdView.imageView as! UIImageView).frame.origin.y,width: contentAdView.bounds.width-100,height: 40)
//
//        (contentAdView.bodyView as! UILabel).text = nativeContentAd.body
//        (contentAdView.bodyView as! UILabel).numberOfLines = 0
//        (contentAdView.bodyView as! UILabel).textColor = textColorDark
//        (contentAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZENormal)
//        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
//
//
//        (contentAdView.callToActionView as! UIButton).frame = CGRect(x: contentAdView.bounds.width-75, y: (contentAdView.imageView as! UIImageView).bounds.height + 15 + (contentAdView.imageView as! UIImageView).frame.origin.y,width: 70,height: 30)
//
//        (contentAdView.callToActionView as! UIButton).setTitle(
//            nativeContentAd.callToAction, for: UIControl.State.normal)
//        (contentAdView.callToActionView as! UIButton).isUserInteractionEnabled = false
//        (contentAdView.callToActionView as! UIButton).titleLabel?.font = UIFont(name: fontName , size: verySmallFontSize)
//        (contentAdView.callToActionView as! UIButton).titleLabel?.textColor = buttonColor
//        (contentAdView.callToActionView as! UIButton).backgroundColor = bgColor
//        (contentAdView.callToActionView as! UIButton).layer.borderWidth = 0.5
//        (contentAdView.callToActionView as! UIButton).layer.borderColor = UIColor.lightGray.cgColor
//        (contentAdView.callToActionView as! UIButton).layer.cornerRadius = cornerRadiusSmall
//        (contentAdView.callToActionView as! UIButton).contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
//        nativeAdArray.append(contentAdView)
//
//        if loadrequestcount <= 10
//        {
//            self.loadrequestcount = self.loadrequestcount+1
//            self.adLoader.delegate = nil
//            self.showNativeAd()
//            self.ChannelTableView.reloadData()
//        }
//    }
    
    //MARK: Action method
    @objc func searchItem()
    {
        
        let presentedVC = ChannelSearchViewController()
        presentedVC.searchPath = "advancedvideos/channel/browse"
        self.navigationController?.pushViewController(presentedVC, animated: true)
        globalCatg = ""
        let url : String = "advancedvideos/channel/search-form"
        loadFilter(url)
        
    }
    @objc func addNewChannel(){
        
        isCreateOrEdit = true
        let presentedVC = FormGenerationViewController()
        presentedVC.formTitle = NSLocalizedString("Add New Channel", comment: "")
        presentedVC.contentType = "Channel"
        presentedVC.param = [ : ]
        presentedVC.url = "advancedvideos/channel/create"
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:true, completion: nil)
        
    }
    @objc func showVideo(_ sender:UIButton)
    {
        var videoInfo:NSDictionary!
        if videoBrowseType == 4{
            videoInfo = myChannelResponse[sender.tag] as! NSDictionary
        }
        else{
            videoInfo = channelResponse[sender.tag] as! NSDictionary
        }
        if(videoInfo["allow_to_view"] as! Int == 1)
        {
            let presentedVC = ChannelProfileViewController()
            presentedVC.subjectId = "\(videoInfo["channel_id"]!)"
            presentedVC.subjectType = "sitevideo_channel"
            navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        else
        {
            showToast(message: NSLocalizedString("You do not have permission to view this private page.", comment: ""), controller: self)
        }
        
    }
    @objc func showVideoMenu(_ sender:UIButton){
        
        var videoInfo:NSDictionary
        videoInfo = myChannelResponse[sender.tag] as! NSDictionary
        if (videoInfo["menu"] != nil){
            let menuOption = videoInfo["menu"] as! NSArray
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in menuOption{
                if let menuItem = menu as? NSDictionary{
                    
                    let titleString = menuItem["name"] as! String
                    
                    if titleString.range(of: "delete") != nil{
                        
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            
                            switch(condition){
                            case "delete":
                                displayAlertWithOtherButton(NSLocalizedString("Delete Channel", comment: ""),message: NSLocalizedString("Are you sure you want to delete this channel?", comment: "") , otherButton: NSLocalizedString("Delete Channel", comment: "")) { () -> () in
                                    self.updateMyVideoMenuAction(menuItem["url"] as! String)
                                    
                                }
                                self.present(alert, animated: true, completion: nil)
                                
                            default:
                                showToast(message:unconditionalMessage, controller: self)
                                
                            }
                        }))
                        
                    }else{
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            switch(condition){
                            case "edit":
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit Video", comment: "")
                                presentedVC.contentType = "video"
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            default:
                                showToast(message:unconditionalMessage, controller: self)
                            }
                        }))
                    }
                }
            }
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }else if  (UIDevice.current.userInterfaceIdiom == .pad){
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2, width: 0, height: 0)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
    }
    func updateMyVideoMenuAction(_ url : String){
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
                        // On Success Update Video Detail
                        // Update Group Detail
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        updateAfterAlert = false
                        self.browseChannel()
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
    //MARK: Category Selection
    @objc func showSubCategory(_ sender:UIButton)
    {
        var categInfo:NSDictionary!
        categInfo = categoryResponse[sender.tag] as! NSDictionary
        var category_title = categInfo["category_name"] as! String
        if let totalItem = categInfo["count"] as? Int{
            if totalItem > 0{
                category_title = category_title + ": " + "\(totalItem)"
            }
        }
        let presentedVC = ChannelCategoryDetailViewController()
        presentedVC .subjectId = categInfo["category_id"] as! Int
        presentedVC .title = category_title
        presentedVC .contentType = "AdvVideo"
        self.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    //MARK: Show Feed Filter Options Action
    @objc func showFeedFilterOptions(_ sender: UIButton){
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        self.ChannelTableView.setContentOffset(CGPoint.zero, animated: true)
        for ob in self.view.subviews
        {
            if ob.tag == 1000
            {
                ob.removeFromSuperview()
                
            }
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        filterDic.removeAll(keepingCapacity: false)
        for (key,menu) in  gutterMenu
        {
            if menu as! String != ""
            {
                alertController.addAction(UIAlertAction(title: "\(menu)", style: .default, handler:{ (UIAlertAction) -> Void in
                    
                    self.filterDic.removeAll(keepingCapacity: false)
                    // Set Feed Filter Option Title
                    let fitertext = "\(menu)" + " " + searchFilterIcon
                    self.feedFilter.setTitle(fitertext, for: .normal)
                    // Make Hard Refresh request for selected Feed Filter & Reset all VAriable
                    self.filterDic["orderby"] = "\(key)"
                    self.showSpinner = true
                    self.browseChannel()
                    
                    
                }))
            }
            
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }
        else
        {
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height - (self.feedFilter.frame.origin.y+self.feedFilter.frame.size.height + TOPPADING),y: view.bounds.width/2, width: 0,height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    @objc func showFeedFilterOptions2(_ sender: UIButton){
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        self.myChannelTableView.setContentOffset(CGPoint.zero, animated: true)
        for ob in self.view.subviews
        {
            if ob.tag == 1000
            {
                ob.removeFromSuperview()
                
            }
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        filterDic2.removeAll(keepingCapacity: false)
        for (key,menu) in  gutterMenu1
        {
            if menu as! String != ""
            {
                alertController.addAction(UIAlertAction(title: "\(menu)", style: .default, handler:{ (UIAlertAction) -> Void in
                    
                    self.filterDic2.removeAll(keepingCapacity: false)
                    // Set Feed Filter Option Title
                    let fitertext = "\(menu)" + " " + searchFilterIcon
                    self.feedFilter2.setTitle(fitertext, for: .normal)
                    // Make Hard Refresh request for selected Feed Filter & Reset all VAriable
                    self.filterDic2["orderby"] = "\(key)"
                    self.showSpinner = true
                    self.browseChannel()
                    
                    
                }))
            }
            
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }
        else
        {
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height - (self.feedFilter.frame.origin.y+self.feedFilter.frame.size.height + TOPPADING),y: view.bounds.width/2, width: 0,height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    //MARK: Server call
    @objc func browseChannel(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            var path = ""
            var parameters = [String:String]()
            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                
                
                videoBrowseType = 3
                
                
                parameters = ["page":"\(pageNumber)", "limit": "\(limit)","user_id" : String(user_id)]
            }
            
            if self.videoTypeCheck == "listings"{
                path = url
                parameters = ["page":"\(pageNumber)", "limit": "\(limit)","listingtype_id" : String(listingTypeId)]
                
            }
            else if self.videoTypeCheck == "sitegroup" {
                path = url
                parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
            }
            else
            {
                // Set Parameters for Browse/Myvideo
                let tag = videoBrowseType
                if logoutUser == false{
                    switch tag
                    {
                    case 3:
                        if self.videoTypeCheck == "dff"{
                            //videoType = ""
                            path = "" + String(user_id)
                        }
                        else
                        {
                            if self.featuredVideosResponse.count == 0
                            {
                                if self.videoTypeCheck != "feeds" {
                                    getFeaturedVideos()
                                }
                                else {
                                    self.videoSlideShowView.frame.size.height = 0.000001
                                    self.dynamicHeaderHeight = self.videoSlideShowView.frame.size.height
                                    self.videoSlideShowView.isHidden = true
                                }
                            }
                            path = "advancedvideos/channel/browse"
                        }
                        
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            parameters = ["page":"\(pageNumber)", "limit": "\(limit)","user_id" : String(user_id)]
                        }else{
                            parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
                        }
                        if self.filterDic.count > 0
                        {
                            // Set Parameters for Search
                            parameters.merge(self.filterDic)
                        }
                        break
                    case 4:
                        if logoutUser == true
                        {
                            path = "advancedvideos/channel/categories"
                            parameters = ["showCount": "1"]
                        }
                        else
                        {
                            path = "advancedvideos/channel/manage"
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                            if self.filterDic2.count > 0
                            {
                                // Set Parameters for Search
                                parameters.merge(self.filterDic2)
                            }
                        }
                        break
                        
                    case 5:
                        path = "advancedvideos/channel/categories"
                        parameters = ["showCount": "1"]
                        break
                        
                        
                    default:
                        break
                        
                    }
                }
                else {
                    switch tag
                    {
                    case 2:
                        if self.videoTypeCheck == "dff"{
                            //videoType = ""
                            path = "" + String(user_id)
                        }
                        else
                        {
                            if self.featuredVideosResponse.count == 0
                            {
                                if self.videoTypeCheck != "feeds" {
                                    getFeaturedVideos()
                                }
                                else {
                                    self.videoSlideShowView.frame.size.height = 0.000001
                                    self.dynamicHeaderHeight = self.videoSlideShowView.frame.size.height
                                    self.videoSlideShowView.isHidden = true
                                }
                            }
                            path = "advancedvideos/channel/browse"
                        }
                        
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            parameters = ["page":"\(pageNumber)", "limit": "\(limit)","user_id" : String(user_id)]
                        }else{
                            parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
                        }
                        if self.filterDic.count > 0
                        {
                            // Set Parameters for Search
                            parameters.merge(self.filterDic)
                        }
                        break
                        
                    case 3:
                        path = "advancedvideos/channel/categories"
                        parameters = ["showCount": "1"]
                        break
                        
                        
                    default:
                        break
                        
                    }
                }
                
                
                
            }
            
            
            if (showSpinner){
                // spinner.center = self.view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = self.view.center
                    updateScrollFlag = false
                }
                //                spinner.hidesWhenStopped = true
                //                spinner.style = UIstyle.gray
                //                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                //       activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            self.scrollView.isUserInteractionEnabled = false
            // Send Server Request to Browse video Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.refresher1.endRefreshing()
                    self.refresher2.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.scrollView.isUserInteractionEnabled = true
                    if msg
                    {
                        self.isPageRefresing = false
                        if succeeded["body"] != nil
                        {
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["totalItemCount"] != nil
                                {
                                    self.totalItems = response["totalItemCount"] as! Int
                                    self.countChannel = "Channels " + "(" + "\(self.totalItems)" + ")"
                                    self.createNavigationbuttons()
                                }
                                if ((self.videoBrowseType == 3 && logoutUser == false) || (self.videoBrowseType == 2 && logoutUser == true))
                                {
                                    self.ChannelTableView.isHidden = false
                                    self.myChannelTableView.isHidden = true
                                    self.categoryTableView.isHidden = true
                                    if self.pageNumber == 1 || self.filterDic.count > 0
                                    {
                                        self.channelResponse.removeAll(keepingCapacity: false)
                                    }
                                    
                                    if let responsearr = response["response"] as? NSArray{
                                        
                                        self.channelResponse = self.channelResponse + (responsearr as [AnyObject])
                                        
                                        
                                    }
                                    if let menu = response["filter"] as? NSDictionary
                                    {
                                        if let guttermenu = menu["multiOptions"] as? NSDictionary
                                        {
                                            self.gutterMenu = guttermenu
                                        }
                                    }
                                    var videotitle : String!
                                    for tempMenu in self.channelResponse
                                    {
                                        if let tempDic = tempMenu as? NSDictionary
                                        {
                                            if tempDic["title"] is NSString
                                            {
                                                videotitle = tempDic["title"] as! String
                                            }
                                            else if tempDic["title"] is NSNumber
                                            {
                                                videotitle = String(describing: tempDic["title"])
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                    if self.videoTypeCheck == "AdvEventVideo"{
                                        
                                        if (response["canCreate"] as! Int == 1)
                                        {
                                            var searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(ChannelViewController.searchItem))
                                            
                                            searchItem.imageInsets = UIEdgeInsets(top:0,left:0,bottom:0,right:-20.0)
                                            
                                            var addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ChannelViewController.addNewChannel))
                                            
                                            addBlog.imageInsets = UIEdgeInsets(top:0,left:-20.0,bottom:0,right:0)
                                            self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                            
                                            searchItem.tintColor = textColorPrime
                                            addBlog.tintColor = textColorPrime
                                            self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                            
                                            
                                        }
                                        if response["totalItemCount"] != nil
                                        {
                                            self.totalItems = response["totalItemCount"] as! Int
                                            self.title = "Video (" + String(self.totalItems)+"): " + videotitle
                                            
                                        }
                                        
                                    }
                                    if self.videoTypeCheck == "listings"{
                                        if (response["canCreate"] as! Bool == true){
                                            
                                            let addVideo = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ChannelViewController.addNewChannel))
                                            self.navigationItem.rightBarButtonItem = addVideo
                                            
                                        }
                                    }
                                    else
                                    {
                                        
                                        if self.showOnlyMyContent == false
                                        {
                                            
                                            if (response["canCreate"] as! Bool == true)
                                            {
                                                
                                                let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(ChannelViewController.searchItem))
                                                let addVideo = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ChannelViewController.addNewChannel))
                                                self.navigationItem.setRightBarButtonItems([addVideo,searchItem], animated: true)
                                                searchItem.tintColor = textColorPrime
                                                addVideo.tintColor = textColorPrime
                                                
                                            }
                                            else
                                            {
                                                let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(ChannelViewController.searchItem))
                                                
                                                self.navigationItem.rightBarButtonItem = searchItem
                                                searchItem.tintColor = textColorPrime
                                            }
                                        }
                                        
                                    }
                                    //Reload Video Tabel
                                    if NotPlay != 1 {
                                        self.pausePlayeVideos()
                                    }
                                    self.ChannelTableView.reloadData()
                                    if self.channelResponse.count == 0{
                                        self.emptylistingMessage()
                                        
                                    }
                                }
                                else if self.videoBrowseType == 4
                                {
                                    self.ChannelTableView.isHidden = true
                                    self.myChannelTableView.isHidden = false
                                    self.categoryTableView.isHidden = true
                                    if self.pageNumber == 1 || self.filterDic2.count > 0
                                    {
                                        self.myChannelResponse.removeAll(keepingCapacity: false)
                                    }
                                    if let responsearr = response["response"] as? NSArray{
                                        
                                        self.myChannelResponse = self.myChannelResponse + (responsearr as [AnyObject])
                                        
                                    }
                                    if let menu = response["filter"] as? NSDictionary
                                    {
                                        if let guttermenu = menu["multiOptions"] as? NSDictionary
                                        {
                                            self.gutterMenu1 = guttermenu
                                        }
                                    }
                                    if self.videoTypeCheck == "listings"{
                                        if (response["canCreate"] as! Bool == true){
                                            
                                            let addVideo = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ChannelViewController.addNewChannel))
                                            self.navigationItem.rightBarButtonItem = addVideo
                                            
                                        }
                                    }
                                    self.myChannelTableView.reloadData()
                                    if self.myChannelResponse.count == 0{
                                        self.emptylistingMessage()
                                        
                                    }
                                }
                                else if ((self.videoBrowseType == 5 && logoutUser == false) || (self.videoBrowseType == 3 && logoutUser == true))
                                {
                                    self.ChannelTableView.isHidden = true
                                    self.myChannelTableView.isHidden = true
                                    self.categoryTableView.isHidden = false
                                    if self.pageNumber == 1
                                    {
                                        self.categoryResponse.removeAll(keepingCapacity: false)
                                    }
                                    if let response = succeeded["body"] as? NSDictionary
                                    {
                                        if response["categories"] != nil
                                        {
                                            if let blog = response["categories"] as? NSArray
                                            {
                                                self.categoryResponse = self.categoryResponse + (blog as [AnyObject])
                                            }
                                        }
                                        
                                        if response["totalItemCount"] != nil
                                        {
                                            self.totalItems = response["totalItemCount"] as! Int
                                        }
                                        
                                    }
                                    self.isPageRefresing = false
                                    if self.categoryResponse.count == 0{
                                        self.emptylistingMessage()
                                        
                                    }
                                    self.categoryTableView.reloadData()
                                    
                                }
                            }
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
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
            scrollView.isUserInteractionEnabled = true
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    //Get Stores according to requirements (Liked, Featured)
    func getFeaturedVideos(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            var path = ""
            var parameters = [String:String]()
            path = "advancedvideos/channel/browse"
            parameters["orderby"] = "featured"
            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                
                
                videoBrowseType = 3
                
                
                parameters = ["orderby":"featured", "user_id" : String(user_id)]
            }
            activityIndicatorView.startAnimating()
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.featuredVideosResponse.removeAll(keepingCapacity: false)
                        }
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil {
                                if let listing = response["response"] as? NSArray {
                                    self.featuredVideosResponse = self.featuredVideosResponse + (listing as [AnyObject])
                                    
                                }
                            }
                        }
                        print("featuredVideosResponse.count\(self.featuredVideosResponse.count)")
                        if (self.featuredVideosResponse.count > 0){
                            self.videoSlideshow.browseContent(contentItems: self.featuredVideosResponse,comingFrom : "Channel")
                            self.dynamicHeaderHeight = 175
                            self.videoSlideShowView.isHidden = false
                            self.ChannelTableView.reloadData()
                        }
                        else{
                            
                            self.videoSlideShowView.frame.size.height = 0.000001
                            self.dynamicHeaderHeight = self.videoSlideShowView.frame.size.height
                            self.videoSlideShowView.isHidden = true
                            
                        }
                        
                    }else{
                        
                        // Handle Server Error
                        if succeeded["message"] != nil{
                           showToast(message: succeeded["message"] as! String, controller: self)
                            self.videoSlideShowView.isHidden = false
                            self.videoSlideShowView.frame.size.height = ButtonHeight + 5
                            self.dynamicHeaderHeight = self.videoSlideShowView.frame.size.height
                            
                        }
                        
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            scrollView.isUserInteractionEnabled = true
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    // Showing message when response count is 0
    func emptylistingMessage()
    {
        noContentView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        noContentView.center = self.view.center
        noContentView.isHidden = false
        noContentView.button.addTarget(self, action: #selector(ChannelViewController.addNewChannel), for: .touchUpInside)
        noContentView.button.layer.borderWidth = 1
        noContentView.button.layer.borderColor = buttonColor.cgColor
        noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal) 
        noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
        self.view.addSubview(noContentView)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: Video Icon Action
    @objc func btnVideoIconClicked(_ sender: UIButton)
    {
        var videoInfo:NSDictionary!
        if videoBrowseType == 4{
            videoInfo = myChannelResponse[sender.tag] as! NSDictionary
        }
        else{
            videoInfo = channelResponse[sender.tag] as! NSDictionary
        }
        
        let attachment_video_type = videoInfo["type"] as? Int ?? 0
        let attachment_video_url = videoInfo["video_url"] as? String ?? ""
        let attachment_video_code = videoInfo["code"] as? String ?? ""
        
        if(videoInfo["allow_to_view"] as! Int == 1){
            
            implemnetPlayer(videoType: attachment_video_type, videoURL: attachment_video_url, videoCode: attachment_video_code, sender : sender)
        }else{
            showToast(message:NSLocalizedString("You do not have permission to view this private page.", comment: ""), controller: self)
        }
        
        
    }
    @objc func btnVideoIconClosedAction()
    {
        let window = UIApplication.shared.keyWindow!
        if let view = window.viewWithTag(200123)
        {
            view.alpha = 0.0
            window.viewWithTag(200123)?.removeFromSuperview()
            //            UIView.animate(withDuration: 0.5, animations: {
            //                view.alpha = 0.0
            //            }) { (isComplete) in
            //                window.viewWithTag(200123)?.removeFromSuperview()
            //            }
        }
        player?.pause()
        player?.replaceCurrentItem(with: nil)
    }
    var originalPosition = CGPoint(x: 0, y: 0)
    var player : AVPlayer?
    // MARK: - Player & Webview Implimentation
    func implemnetPlayer(videoType : Int, videoURL : String, videoCode : String, sender : UIButton)
    {
        if videoType == 3
        {
            if let url = URL(string:videoURL)
            {
                player = AVPlayer(url: url)
                let vc = AVPlayerViewController()
                vc.player = player
                
                present(vc, animated: true) {
                    vc.player?.play()
                }
            }
            
        }
        else
        {
            let window = UIApplication.shared.keyWindow!
            viewSubview = UIView(frame:CGRect(x: 0 , y: 0, width: self.view.bounds.width, height: self.view.bounds.height + tabBarHeight + TOPPADING))
            viewSubview.backgroundColor = .black
            viewSubview.tag = 200123
            viewSubview.alpha = 0
            let imageButton = createButton(CGRect(x: -10,y: 10 ,width: 100 , height:100) , title: "Close", border: false, bgColor: false, textColor: textColorLight)
            imageButton.addTarget(self, action: #selector(self.btnVideoIconClosedAction), for: .touchUpInside)
            //  viewSubview.addSubview(imageButton)
            
            var playerHeight: CGFloat = 800
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                playerHeight = 500
            }
            self.navigationItem.rightBarButtonItem = nil
            playerHeight += TOPPADING - contentPADING
            var videoWebView = WKWebView()
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
            let imageView = UIImageView(image: jeremyGif)
            imageView.tag = 2002134
            imageView.frame = CGRect(x: view.bounds.width/2 - 60,y: self.view.bounds.height/2 ,width: 120, height: 7)
            
            var url = ""
            if videoURL.length != 0
            {
                let videoUrl1 : String = videoURL
                let find = videoUrl1.contains("http")
                if videoType == 1 || videoType == 2 || videoType == 4 || videoType == 5 && find == false{
                    
                    url = "https://" + videoURL
                }
                else
                {
                    url = videoURL
                }
            }
            
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
                    if videoUrl != nil {
                        videoWebView.loadHTMLString(videoUrl, baseURL: nil)
                    }
                }
            }
            
//            if let videoURL =  URL(string:url)
//            {
//                var request = URLRequest(url: videoURL)
//                if videoType == 1 {
//                    request.setValue("http://www.youtube.com", forHTTPHeaderField: "Referer")
//                    let embededHTML = "<html><body style='margin:0px;padding:0px;'><script type='text/javascript' src='http://www.youtube.com/iframe_api'></script><script type='text/javascript'>function onYouTubeIframeAPIReady(){ytplayer=new YT.Player('playerId',{events:{onReady:onPlayerReady}})}function onPlayerReady(a){a.target.playVideo();}</script><iframe id='playerId' type='text/html' width='\(view.frame.size.width)' height='\(view.frame.size.height - TOPPADING - 30)' src='http://www.youtube.com/embed/\(videoCode)?enablejsapi=1&rel=0&playsinline=1&autoplay=1' frameborder='0'></body></html>"
//                    let videoURLYouTube =  URL(string:"http://www.youtube.com")
//                    videoWebView.loadHTMLString(embededHTML, baseURL: videoURLYouTube)
//                }
//                else
//                {
//                    // videoWebView.frame.origin.y = viewSubview.bounds.height/8
//                    // videoWebView.center = window.convert(window.center, from:window.superview)
//                    // videoWebView.center = CGPoint(x: viewSubview.bounds.midX,                                                  y: viewSubview.bounds.midY - (playerHeight/6))
//                    videoWebView.center = view.convert(view.center, from:view.superview)
//                    videoWebView.loadRequest(request)
//                }
//
//                do {
//                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
//                    try AVAudioSession.sharedInstance().setActive(true)
//                } catch _ as NSError {
//                    //print(error)
//                }
//
//            }
//            else
//            {
//                if videoType == 6
//                {
//                    videoWebView.loadHTMLString(videoURL, baseURL: nil)
//                }
//            }
            viewSubview.addSubview(videoWebView)
            videoWebView.addSubview(imageView)
            
            
            window.addSubview(viewSubview)
            originalPosition = self.viewSubview.center
            
            viewSubview.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrage(_:))))
            
            UIView.animate(withDuration: 0.5, animations: {
                self.viewSubview.alpha = 1.0
            }, completion: nil)
            
        }
        
        
    }
    
    @objc func onDrage(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: viewSubview)
        
        if panGesture.state == .changed {
            viewSubview.frame.origin = CGPoint(
                x:  viewSubview.frame.origin.x,
                y:  viewSubview.frame.origin.y + translation.y
            )
            panGesture.setTranslation(CGPoint.zero, in: self.viewSubview)
        } else if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: viewSubview)
            if velocity.y >= 150 {
                UIView.animate(withDuration: 0.2
                    , animations: {
                        self.viewSubview.frame.origin = CGPoint(
                            x: self.viewSubview.frame.origin.x,
                            y: self.viewSubview.frame.size.height
                        )
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.btnVideoIconClosedAction()
                        // self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewSubview.center = self.originalPosition
                })
            }
        }
    }
    
    // MARK: - WebView delegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation - webView.url: \(String(describing: webView.url?.description))")
        if let imgView = webView.viewWithTag(2002134)
        {
            imgView.isHidden = false
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish - webView.url: \(String(describing: webView.url?.description))")
        if let imgView = webView.viewWithTag(2002134)
        {
            imgView.isHidden = true
        }
    }
}

