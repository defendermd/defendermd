////
////  BrowseProductsViewController.swift
////  seiosnativeapp
///*
//* Copyright (c) 2016 BigStep Technologies Private Limited.
//*
//* You may not use this file except in compliance with the
//* SocialEngineAddOns License Agreement.
//* You may obtain a copy of the License at:
//* https://www.socialengineaddons.com/ios-app-license
//* The full copyright and license information is also mentioned
//* in the LICENSE file that was distributed with this
//* source code.
//*/
//
//
//import UIKit
//import GoogleMobileAds
////var musicUpdate = true
////var browseOrMyMusic = true
//// Flag to refresh Blog
//class BrowseProductsViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate,GADNativeAppInstallAdLoaderDelegate,GADNativeContentAdLoaderDelegate{
//    var editPlaylistID:Int = 0                          // Edit ClassifiedID
//    let mainView = UIView()
//    // true for Browse Classified & false for My Classified
//    var showSpinner = true                      // not show spinner at pull to refresh
//    var musicResponse = [AnyObject]()            // For response come from Server
//    var isPageRefresing = false                 // For Pagination
//    var musicTableView:UITableView!              // TAbleView to show the Classified Contents
//    var browseMusic:UIButton!                    // Classified Types
//    var myMusic:UIButton!
//    var searchBar = UISearchBar()               // searchBar
//    var refresher:UIRefreshControl!             // Pull to refrresh
//    var pageNumber:Int = 1
//    var totalItems:Int = 0
//    var currency : String = ""
//    var info:UILabel!
//    var updateScrollFlag = true                 // Paginatjion Flag
//    var dynamicHeight:CGFloat = 200              // Dynamic Height fort for Cell
//    var fromActivityFeed = false
//    var objectId:Int!
//    var showOnlyMyContent:Bool!
//    var contentIcon : UILabel!
//    var refreshButton : UIButton!
//    var customSegmentControl:UISegmentedControl!
//    var countListTitle : String!
//    var user_id : Int!
//    var fromTab : Bool!
//    var imageCache = [String:UIImage]()
//    var imageCache1 = [String:UIImage]()
//    var responseCache = [String:AnyObject]()
//    
//    // AdMob Variable
//    var adLoader: GADAdLoader!
//    var nativeAdArray = [AnyObject]()
//    var loadrequestcount = 0
//    var adsCount:Int = 0
//    var isnativeAd:Bool = true
//    // Initialization of class Object
//    override func viewDidLoad() {
//        
//        if kFrequencyAdsInCells_music > 4 && adUnitID != ""
//        {
//            showNativeAd()
//        }
//        
//        super.viewDidLoad()
//        searchDic.removeAll(keepCapacity: false)
//        view.backgroundColor = UIColor.whiteColor()
//        navigationController?.navigationBar.hidden = false
//        openMenu = false
//        updateAfterAlert = true
//        musicUpdate = true
//        
//        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), forBarMetrics: .Default)
//        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
//        self.navigationController?.navigationBar.translucent = true
//        self.navigationController?.navigationBar.tintColor = textColorLight
//        
//        
//        let subViews = mainView.subviews
//        for subview in subViews{
//            subview.removeFromSuperview()
//        }
//        
//        if footerDashboard == false {
//            if showOnlyMyContent == false {
//                let leftNavView = UIView(frame: CGRectMake(0, 0, 44, 44))
//                leftNavView.backgroundColor = UIColor.clearColor()
//                
//                let tapView = UITapGestureRecognizer(target: self, action: Selector("openSlideMenu"))
//                leftNavView.addGestureRecognizer(tapView)
//                
//                let menuImageView = createImageView(CGRectMake(0,12,22,22), border: false)
//                menuImageView.image = UIImage(named: "dashboard_icon")
//                leftNavView.addSubview(menuImageView)
//                if (logoutUser == false && (totalNotificationCount !=  nil) && (totalNotificationCount > 0)) {
//                    let countLabel = createLabel(CGRectMake(17,3,17,17), text: "\(totalNotificationCount)", alignment: .Center, textColor: textColorLight)
//                    countLabel.backgroundColor = UIColor.redColor()
//                    countLabel.layer.cornerRadius = countLabel.frame.size.width / 2;
//                    countLabel.layer.masksToBounds = true
//                    countLabel.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
//                    leftNavView.addSubview(countLabel)
//                }
//                
//                let barButtonItem = UIBarButtonItem(customView: leftNavView)
//                self.navigationItem.leftBarButtonItem = barButtonItem
//            }
//        }
//        
//        mainView.frame = view.frame
//        mainView.backgroundColor = UIColor.clearColor()
//        view.addSubview(mainView)
//        mainView.removeGestureRecognizer(tapGesture)
//        
//        contentIcon = createLabel(CGRectMake(0,0,0,0), text: "", alignment: .Center, textColor: textColorMedium )
//        mainView.addSubview(contentIcon)
//        contentIcon.hidden = true
//        
//        refreshButton = createButton(CGRectMake(0,0,0,0), title: "", border: true, bgColor: true, textColor: navColor)
//        mainView.addSubview(refreshButton)
//        refreshButton.hidden = true
//        
//        
//        
//        leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
//        leftSwipe.direction = .Left
//        view.addGestureRecognizer(leftSwipe)
//        
//        
//        
//        if showOnlyMyContent == false {
//            self.title = NSLocalizedString("Music", comment: "")
//        }
//        else{
//            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
//            let leftNavView = UIView(frame: CGRectMake(0, 0, 44, 44))
//            leftNavView.backgroundColor = UIColor.clearColor()
//            let tapView = UITapGestureRecognizer(target: self, action: Selector("goBack"))
//            leftNavView.addGestureRecognizer(tapView)
//            
//            let backIconImageView = createImageView(CGRectMake(0,12,22,22), border: false)
//            backIconImageView.image = UIImage(named: "back_icon")
//            leftNavView.addSubview(backIconImageView)
//            
//            if footerDashboard == false {
//                let barButtonItem = UIBarButtonItem(customView: leftNavView)
//                self.navigationItem.leftBarButtonItem = barButtonItem
//            }
//            
//        }
//        
//        
//        
//        // Initialize Blog Types
//        browseMusic = createNavigationButton(CGRectMake(0, 64 ,CGRectGetWidth(view.bounds)/2.0  , ButtonHeight) ,  title: NSLocalizedString("Browse Music",  comment: "") , border: true, selected: true)
//        browseMusic.tag = 11
//        browseMusic.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
//        browseMusic.addTarget(self, action: "prebrowseEntries:", forControlEvents: .TouchUpInside)
//        mainView.addSubview(browseMusic)
//        
//        browseMusic.hidden = false
//        
//        myMusic = createNavigationButton(CGRectMake(CGRectGetWidth(view.bounds)/2.0, 64 ,CGRectGetWidth(view.bounds)/2.0  , ButtonHeight) ,  title: NSLocalizedString("My Music",  comment: "") , border: true, selected: false)
//        myMusic.tag = 22
//        myMusic.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
//        myMusic.addTarget(self, action: "prebrowseEntries:", forControlEvents: .TouchUpInside)
//        mainView.addSubview(myMusic)
//        
//        myMusic.hidden = false
//        
//        
//        
//        
//        // Create Filter Search Link
//        let filter = createButton(CGRectMake(PADING, TOPPADING + contentPADING + ButtonHeight, 0,0), title: fiterIcon , border: true,bgColor: false, textColor: textColorDark)
//        filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
//        filter.addTarget(self, action: "filterSerach", forControlEvents: .TouchUpInside)
//        mainView.addSubview(filter)
//        
//        filter.hidden = true
//        
//        
//        // Initialze Searcgh Bar
//        searchBar.frame = CGRectMake( CGRectGetWidth(filter.bounds) + 2*PADING, TOPPADING + contentPADING + ButtonHeight , 0, 0)
//        searchBar.delegate = self
//        searchBar.placeholder = NSLocalizedString("Search",  comment: "")
//        mainView.addSubview(searchBar)
//        
//        searchBar.hidden = true
//        
//        for subView in searchBar.subviews  {
//            for subsubView in subView.subviews  {
//                if let textField = subsubView as? UITextField {
//                    textField.textColor = textColorDark
//                    textField.font = UIFont(name: fontBold, size: FONTSIZENormal)
//                }
//            }
//        }
//        
//        // Initialize Classified Table
//        if tabBarHeight > 0{
//            musicTableView = UITableView(frame: CGRectMake(0, TOPPADING - 6 + ButtonHeight, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)-(TOPPADING - 18 + ButtonHeight) - tabBarHeight ), style: .Grouped)
//        }else{
//            musicTableView = UITableView(frame: CGRectMake(0, TOPPADING - 6 + ButtonHeight, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)-(TOPPADING - 6 + ButtonHeight) - tabBarHeight ), style: .Grouped)
//        }
//        musicTableView.registerClass(ProductTableViewCell.self, forCellReuseIdentifier: "Cell")
//        musicTableView.dataSource = self
//        musicTableView.delegate = self
//        musicTableView.estimatedRowHeight = 200.0
//        musicTableView.rowHeight = UITableViewAutomaticDimension
//        musicTableView.backgroundColor = UIColor.clearColor()
//        //musicTableView.separatorColor = TVSeparatorColor
//        musicTableView.separatorColor = UIColor.clearColor()
//        
//        mainView.addSubview(musicTableView)
//        
//        //    musicTableView.tableHeaderView = customSegmentControl
//        
//        // Initialize Reresher for Table (Pull to Refresh)
//        refresher = UIRefreshControl()
//        //    refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
//        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
//        musicTableView.addSubview(refresher)
//        
//        //    self.shyNavBarManager.scrollView = musicTableView
//        
//        
//        if logoutUser == true || showOnlyMyContent == true{
//            browseMusic.hidden = true
//            myMusic.hidden = true
//            filter.frame.origin.y = TOPPADING
//            searchBar.frame.origin.y = TOPPADING
//            musicTableView.frame.origin.y = TOPPADING - 6
//            musicTableView.frame.size.height = CGRectGetHeight(view.bounds) - (TOPPADING - 6) - tabBarHeight
//            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.Plain , target:self , action: "cancleSearch")
//            self.navigationItem.rightBarButtonItem = addCancel
//            
//            
//        }
//        
//        
//        
//        //   self.edgesForExtendedLayout = UIRectEdge.None;
//        //   self.automaticallyAdjustsScrollViewInsets = true;
//        
//    }
//    
//    
//    
//    // Check for Classified Update Every Time when View Appears
//    override func viewDidAppear(animated: Bool) {
//        
//        if openMenu{
//            openMenu = false
//            openMenuSlideOnView(mainView)
//        }
//        
//        
//        playlistResponse.removeAll()
//        
//        if (musicUpdate == true){
//            pageNumber = 1
//            searchBar.text = ""
//            browseEntries()
//        }else{
//            musicTableView.reloadData()
//        }
//        
//        //    if fromActivityFeed == true{
//        //        fromActivityFeed = false
//        //        let presentedVC  = ClassifiedDetailViewController()
//        //        presentedVC.ClassifiedId = objectId
//        //        presentedVC.ClassifiedName = NSLocalizedString("Loading...", comment: "")
//        //        navigationController?.pushViewController(presentedVC, animated: true)
//        //    }
//        
//    }
//    
//    
//    // MARK: - GADAdLoaderDelegate
//    func showNativeAd()
//    {
//        
//        var adTypes = [String]()
//        if iscontentAd == true
//        {
//            if isnativeAd
//            {
//                adTypes.append(kGADAdLoaderAdTypeNativeAppInstall)
//                isnativeAd = false
//            }
//            else
//            {
//                adTypes.append(kGADAdLoaderAdTypeNativeContent)
//                isnativeAd = true
//            }
//        }
//        else
//        {
//            adTypes.append(kGADAdLoaderAdTypeNativeAppInstall)
//        }
//        //adTypes.append(kGADAdLoaderAdTypeNativeContent)
//        adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: self,
//            adTypes: adTypes, options: nil)
//        adLoader.delegate = self
//        
//        let request = GADRequest()
//        
//        request.testDevices = [kGADSimulatorID,"5431f9841e382a606b19b38a7846df81","c6adea630f210d80ef5673aa4a78b500","40cd3e71cf06e1754ada161ff60ab41e"]
//        
//        adLoader.loadRequest(request)
//        
//        
//    }
//    
//    
//    func adLoader(adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
//        print("\(adLoader) failed with error: \(error.localizedDescription)")
//        
//    }
//    
//    // Mark: - GADNativeAppInstallAdLoaderDelegate
//    
//    func adLoader(adLoader: GADAdLoader!,
//        didReceiveNativeAppInstallAd nativeAppInstallAd: GADNativeAppInstallAd!)
//    {
//        print("Received native app install ad: \(nativeAppInstallAd)")
//        if loadrequestcount <= 10
//        {
//            loadrequestcount = loadrequestcount+1
//            showNativeAd()
//        }
//        
//        
//        let appInstallAdView = NSBundle.mainBundle().loadNibNamed("NativeAdAdvancedevent", owner: nil,
//            options: nil).first as! GADNativeAppInstallAdView
//        
//        if(UIDevice.currentDevice().userInterfaceIdiom == .Pad)
//        {
//            appInstallAdView.frame = CGRectMake(PADING, 2*PADING ,(CGRectGetWidth(UIScreen.mainScreen().bounds)/2 - 2*PADING) , 160)
//        }
//        else
//        {
//            appInstallAdView.frame = CGRectMake(2*PADING, 2*PADING,(CGRectGetWidth(UIScreen.mainScreen().bounds) - 4*PADING) , 160)
//            
//        }
//        
//        appInstallAdView.nativeAppInstallAd = nativeAppInstallAd
//        
//        appInstallAdView.tag = 1001001
//        
//        
//        
//        (appInstallAdView.imageView as! UIImageView).frame = CGRectMake(0, 0, CGRectGetWidth(appInstallAdView.bounds), 155)
//        (appInstallAdView.imageView as! UIImageView).image = cropToBounds((nativeAppInstallAd.images?.first as! GADNativeAdImage).image, width: (Double)((appInstallAdView.imageView as! UIImageView).frame.size.width), height: 155)
//        
//        let gradient: CAGradientLayer = CAGradientLayer()
//        gradient.frame = (appInstallAdView.imageView as! UIImageView).frame
//        gradient.colors = [UIColor.clearColor().CGColor,UIColor.grayColor().CGColor]
//        gradient.locations = [0.7, 1.0]
//        (appInstallAdView.imageView as! UIImageView).layer.insertSublayer(gradient, atIndex: 0)
//        
//        
//        
//        
//        
//        (appInstallAdView.headlineView as! UILabel).frame = CGRectMake(5 , CGRectGetHeight((appInstallAdView.imageView as! UIImageView).bounds) + (appInstallAdView.imageView as! UIImageView).frame.origin.y - 40, CGRectGetWidth(appInstallAdView.bounds)-80, 30)
//        (appInstallAdView.headlineView as! UILabel).numberOfLines = 0
//        (appInstallAdView.headlineView as! UILabel).textColor = textColorLight
//        (appInstallAdView.headlineView as! UILabel).font = UIFont(name: fontBold, size: FONTSIZENormal)
//        (appInstallAdView.headlineView as! UILabel).text = nativeAppInstallAd.headline
//        //(appInstallAdView.headlineView as! UILabel).sizeToFit()
//        
//        
//        
//        
//        (appInstallAdView.bodyView as! UILabel).frame = CGRectMake(5 , CGRectGetHeight((appInstallAdView.headlineView as! UILabel).bounds) + 10 + (appInstallAdView.headlineView as! UILabel).frame.origin.y, CGRectGetWidth(appInstallAdView.bounds)-80, 40)
//        
//        (appInstallAdView.bodyView as! UILabel).text = nativeAppInstallAd.body
//        (appInstallAdView.bodyView as! UILabel).numberOfLines = 0
//        (appInstallAdView.bodyView as! UILabel).textColor = textColorMedium
//        (appInstallAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZESmall)
//        (appInstallAdView.bodyView as! UILabel).hidden = true
//        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
//        
//        
//        
//        
//        
//        (appInstallAdView.callToActionView as! UIButton).frame = CGRectMake(CGRectGetWidth(appInstallAdView.bounds)-60,CGRectGetHeight((appInstallAdView.imageView as! UIImageView).bounds) + 5 + (appInstallAdView.imageView as! UIImageView).frame.origin.y, 60, 30)
//        
//        (appInstallAdView.callToActionView as! UIButton).setTitle(
//            nativeAppInstallAd.callToAction, forState: UIControlState.Normal)
//        (appInstallAdView.callToActionView as! UIButton).userInteractionEnabled = false
//        (appInstallAdView.callToActionView as! UIButton).titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
//        (appInstallAdView.callToActionView as! UIButton).titleLabel?.textColor = navColor
//        (appInstallAdView.callToActionView as! UIButton).backgroundColor = bgColor
//        (appInstallAdView.callToActionView as! UIButton).hidden = true
//        
//        
//        
//        nativeAdArray.append(appInstallAdView)
//        if nativeAdArray.count == 10
//        {
//            musicTableView.reloadData()
//        }
//    }
//    func adLoader(adLoader: GADAdLoader!,
//        didReceiveNativeContentAd nativeContentAd: GADNativeContentAd!) {
//            
//            print("Received native content ad: \(nativeContentAd)")
//            if loadrequestcount <= 10
//            {
//                loadrequestcount = loadrequestcount+1
//                showNativeAd()
//            }
//            
//            
//            let contentAdView = NSBundle.mainBundle().loadNibNamed("ContentAdsFeedview", owner: nil,
//                options: nil).first as! GADNativeContentAdView
//            // Associate the app install ad view with the app install ad object. This is required to make
//            // the ad clickable.
//            contentAdView.nativeContentAd = nativeContentAd
//            contentAdView.tag = 1001001
//            
//            if(UIDevice.currentDevice().userInterfaceIdiom == .Pad)
//            {
//                contentAdView.frame = CGRectMake(PADING, 2*PADING ,(CGRectGetWidth(UIScreen.mainScreen().bounds)/2 - 2*PADING) , 160)
//            }
//            else
//            {
//                contentAdView.frame = CGRectMake(2*PADING, 2*PADING,(CGRectGetWidth(UIScreen.mainScreen().bounds) - 4*PADING) , 160)
//                
//            }
//            
//            
//            (contentAdView.imageView as! UIImageView).frame = CGRectMake(0, 0, CGRectGetWidth(contentAdView.bounds), 155)
//            (contentAdView.imageView as! UIImageView).image = cropToBounds((nativeContentAd.images?.first as! GADNativeAdImage).image, width: (Double)((contentAdView.imageView as! UIImageView).frame.size.width), height: 155)
//            
//            let gradient: CAGradientLayer = CAGradientLayer()
//            gradient.frame = (contentAdView.imageView as! UIImageView).frame
//            gradient.colors = [UIColor.clearColor().CGColor,UIColor.grayColor().CGColor]
//            gradient.locations = [0.7, 1.0]
//            (contentAdView.imageView as! UIImageView).layer.insertSublayer(gradient, atIndex: 0)
//            
//            
//            
//            
//            
//            (contentAdView.headlineView as! UILabel).frame = CGRectMake(5 , CGRectGetHeight((contentAdView.imageView as! UIImageView).bounds) + (contentAdView.imageView as! UIImageView).frame.origin.y - 40, CGRectGetWidth(contentAdView.bounds)-80, 30)
//            (contentAdView.headlineView as! UILabel).numberOfLines = 0
//            (contentAdView.headlineView as! UILabel).textColor = textColorLight
//            (contentAdView.headlineView as! UILabel).font = UIFont(name: fontBold, size: FONTSIZENormal)
//            (contentAdView.headlineView as! UILabel).text = nativeContentAd.headline
//            //(appInstallAdView.headlineView as! UILabel).sizeToFit()
//            
//            
//            
//            
//            (contentAdView.bodyView as! UILabel).frame = CGRectMake(5 , CGRectGetHeight((contentAdView.headlineView as! UILabel).bounds) + 10 + (contentAdView.headlineView as! UILabel).frame.origin.y, CGRectGetWidth(contentAdView.bounds)-100, 40)
//            
//            (contentAdView.bodyView as! UILabel).text = nativeContentAd.body
//            (contentAdView.bodyView as! UILabel).numberOfLines = 0
//            (contentAdView.bodyView as! UILabel).textColor = textColorMedium
//            (contentAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZESmall)
//            (contentAdView.bodyView as! UILabel).hidden = true
//            //(appInstallAdView.bodyView as! UILabel).sizeToFit()
//            
//            
//            
//            
//            
//            (contentAdView.callToActionView as! UIButton).frame = CGRectMake(CGRectGetWidth(contentAdView.bounds)-75,CGRectGetHeight((contentAdView.imageView as! UIImageView).bounds) + 5 + (contentAdView.imageView as! UIImageView).frame.origin.y, 60, 30)
//            
//            (contentAdView.callToActionView as! UIButton).setTitle(
//                nativeContentAd.callToAction, forState: UIControlState.Normal)
//            (contentAdView.callToActionView as! UIButton).userInteractionEnabled = false
//            (contentAdView.callToActionView as! UIButton).titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
//            (contentAdView.callToActionView as! UIButton).titleLabel?.textColor = navColor
//            (contentAdView.callToActionView as! UIButton).backgroundColor = bgColor
//            (contentAdView.callToActionView as! UIButton).hidden = true
//            
//            
//            
//            nativeAdArray.append(contentAdView)
//            if nativeAdArray.count == 10
//            {
//                musicTableView.reloadData()
//            }
//            
//    }
//    
//    // Show Slide Menu
//    func openSlideMenu(){
//        //    // Add TapGesture On Open Slide Menu
//        //    if openMenu{
//        //        openMenu = false
//        //    }else{
//        //        openMenu = true
//        //        tapGesture = tapGestureCreation(self)
//        //    }
//        //    // openMenuSlideOnView(mainView)
//        //    openMenuSlideOnView(mainView)
//        
//        toggleSideMenuView()
//        
//    }
//    
//    
//    
//    func handleSwipes(sender:UISwipeGestureRecognizer) {
//        if (sender.direction == .Left) {
//            print("Swipe Left")
//            
//            openMenu = false
//            openMenuSlideOnView(mainView)
//            mainView.removeGestureRecognizer(tapGesture)
//            
//        }
//        
//    }
//    
//    // Handle TapGesture On Open Slide Menu
//    func handleTap(recognizer: UITapGestureRecognizer) {
//        openMenu = false
//        openMenuSlideOnView(mainView)
//        mainView.removeGestureRecognizer(tapGesture)
//    }
//    
//    // Check Condition when Search is Enable
//    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
//        if openMenu{
//            openMenu = false
//            openMenuSlideOnView(mainView)
//            return false
//        }else{
//            return true
//        }
//    }
//    
//    
//    // Handle Simple Search on Search Click
//    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
//        
//        // Add search text to searchDic
//        searchDic.removeAll(keepCapacity: false)
//        searchDic["search"] = searchBar.text
//        pageNumber = 1
//        musicResponse.removeAll(keepCapacity: false)
//        searchBar.resignFirstResponder()
//        // Update Classified for Search Text
//        
//        if searchBar.text != "" && logoutUser == true{
//            self.navigationItem.rightBarButtonItem?.title = "Cancle"
//            self.navigationItem.rightBarButtonItem?.enabled = true
//        }
//        
//        browseEntries()
//    }
//    
//    
//    // Cancle Search Result for Logout User
//    func cancleSearch(){
//        searchDic.removeAll(keepCapacity: false)
//        searchDic["search"] = ""
//        pageNumber = 1
//        
//        self.navigationItem.rightBarButtonItem?.title = ""
//        self.navigationItem.rightBarButtonItem?.enabled = false
//        browseEntries()
//    }
//    
//    
//    // Open Filter Search Form
//    func filterSerach(){
//        if openMenu{
//            openMenu = false
//            openMenuSlideOnView(mainView)
//        }else{
//            searchBar.text = ""
//            searchBar.resignFirstResponder()
//            searchDic.removeAll(keepCapacity: false)
//            musicUpdate = false
//            let presentedVC = FilterSearchViewController()
//            presentedVC.searchUrl = "music/browse-search-form"
//            presentedVC.serachFor = "music"
//            isCreateOrEdit = true
//            navigationController?.pushViewController(presentedVC, animated: true)
//        }
//    }
//    
//    
//    // Create Classified Form
//    
//    //// Open Create/Edit Classified Form
//    //func openClassifiedForm(){
//    //    if openMenu{
//    //        openMenu = false
//    //        openMenuSlideOnView(mainView)
//    //    }else{
//    ////        var presentedVC = CreateNewClassified()
//    ////        presentedVC.id = editPlaylistID
//    ////        navigationController?.pushViewController(presentedVC, animated: true)
//    //    }
//    //}
//    
//    
//    // Handle Browse Classified or My Classified PreAction
//    func prebrowseEntries(sender: UIButton){
//        var currentTask: NSURLSessionTask?
//        currentTask?.cancel()
//        // true for Browse Classified & false for My Classified
//        if openMenu{
//            openMenu = false
//            openMenuSlideOnView(mainView)
//            return
//        }
//        
//        if sender.tag == 22 {
//            browseOrMyMusic = false
//        }else if sender.tag == 11 {
//            browseOrMyMusic = true
//        }
//        self.musicResponse.removeAll(keepCapacity: false)
//        searchBar.text = ""
//        searchBar.resignFirstResponder()
//        searchDic.removeAll(keepCapacity: false)
//        updateScrollFlag = false
//        pageNumber = 1
//        // Update for Classified
//        browseEntries()
//    }
//    
//    
//    // Pull to Request Action
//    func refresh(){
//        // Check Internet Connectivity
//        //  if musicResponse.count != 0{
//        if reachability.isReachable() {
//            searchBar.text = ""
//            searchBar.resignFirstResponder()
//            searchDic.removeAll(keepCapacity: false)
//            
//            showSpinner = false
//            pageNumber = 1
//            updateAfterAlert = false
//            browseEntries()
//        }else{
//            // No Internet Connection Message
//            refresher.endRefreshing()
//            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
//            
//        }
//        //   }
//    }
//    
//    
//    // Generate Custom Alert Messages
//    func showAlertMessage( centerPoint: CGPoint, msg: String, timer: Bool){
//        self.view .addSubview(validationMsg)
//        showCustomAlert(centerPoint, msg: msg)
//        if timer {
//            // Initialization of Timer
//            createTimer(self)
//        }
//    }
//    
//    
//    // Stop Timer
//    func stopTimer() {
//        stop()
//    }
//    
//    
//    
//    
//    
//    // MARK: - Server Connection For Classified Updation
//    
//    // For delete  a Classified
//    func updateMusicMenuAction(url : String){
//        // Check Internet Connection
//        if reachability.isReachable() {
//            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
//            view.addSubview(spinner)
//            spinner.startAnimating()
//            
//            
//            let dic = Dictionary<String, String>()
//            //        for (key, value) in parameter{
//            //
//            //            if let id = value as? NSNumber {
//            //                dic["\(key)"] = String(id as! Int)
//            //            }
//            //
//            //            if let receiver = value as? NSString {
//            //                dic["\(key)"] = receiver
//            //            }
//            //        }
//            
//            // Send Server Request to Explore Classified Contents with Classified_ID
//            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
//                dispatch_async(dispatch_get_main_queue(), {
//                    spinner.stopAnimating()
//                    
//                    if msg{
//                        // On Success Update Classified Detail
//                        // Update Classified Detail
//                        if succeeded["message"] != nil{
//                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
//                            
//                        }
//                        updateAfterAlert = false
//                        self.browseEntries()
//                    }
//                        
//                    else{
//                        // Handle Server Side Error
//                        if succeeded["message"] != nil{
//                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
//                            
//                        }
//                    }
//                })
//            }
//            
//        }else{
//            // No Internet Connection Message
//            showAlertMessage(view.center , msg: network_status_msg , timer: false)
//        }
//        
//    }
//    func indexChanged(sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//        case 0:
//            browseOrMyMusic = true
//            self.browseEntries()
//        case 1:
//            
//            browseOrMyMusic = false
//            self.browseEntries()
//        default:
//            break;
//        }
//    }
//    
//    
//    
//    // Update Classified
//    func browseEntries(){
//        
//        // Check Internet Connectivity
//        if reachability.isReachable() {
//            
//            if showOnlyMyContent == true{
//                browseOrMyMusic = false
//            }
//            
//            // Reset Objects
//            for ob in mainView.subviews{
//                if ob.tag == 1000{
//                    ob.removeFromSuperview()
//                }
//            }
//            
//            var path = ""
//            var parameters = [String:String]()
//            
//            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
//                browseOrMyMusic = true
//            }
//            
//            
//            // Set Parameters for Browse/myMusic
//            if browseOrMyMusic {
//                path = "sitestore/product/browse"
//                
//                
//                if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
//                    parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : "\(user_id)"]
//                }else{
//                    parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
//                }
//                
//                myMusic.setUnSelectedButton()
//                browseMusic.setSelectedButton()
//                
//                
//            }else{
//                path = "music/manage"
//                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
//                myMusic.setSelectedButton()
//                browseMusic.setUnSelectedButton()
//                
//            }
//            
//            if (self.pageNumber == 1){
//                self.musicResponse.removeAll(keepCapacity: false)
//                
//                if updateAfterAlert == true {
//                    removeAlert()
//                    if let responseCacheArray = self.responseCache["\(path)"]{
//                        self.musicResponse = responseCacheArray as! [AnyObject]
//                    }
//                    self.musicTableView.reloadData()
//                }else{
//                    updateAfterAlert = true
//                }
//            }
//            
//            contentIcon.hidden = true
//            refreshButton.hidden = true
//            
//            if (showSpinner){
//                spinner.center = mainView.center
//                if updateScrollFlag == false {
//                    spinner.center = CGPoint(x: view.center.x, y: view.bounds.height-50 - (tabBarHeight / 4))
//                }
//                if (self.pageNumber == 1){
//                    spinner.center = mainView.center
//                    updateScrollFlag = false
//                }
//                spinner.hidesWhenStopped = true
//                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
//                view.addSubview(spinner)
//                spinner.startAnimating()
//            }
//            
//            // Set Parameters for Search
//            if searchDic.count > 0 {
//                parameters.merge(searchDic)
//            }
//            
//            // Send Server Request to Browse Classified Entries
//            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
//                
//                dispatch_async(dispatch_get_main_queue(),{
//                    var currentTask: NSURLSessionTask?
//                    currentTask?.cancel()
//                    
//                    if self.showSpinner{
//                        spinner.stopAnimating()
//                    }
//                    self.refresher.endRefreshing()
//                    self.showSpinner = true
//                    self.updateScrollFlag = true
//                    //})
//                    
//                    if msg{
//                        
//                        if self.pageNumber == 1{
//                            self.musicResponse.removeAll(keepCapacity: false)
//                        }
//                        
//                        if succeeded["message"] != nil{
//                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
//                        }
//                        
//                        
//                        if let response = succeeded["body"] as? NSDictionary{
//                            if response["response"] != nil{
//                                if let Classified = response["response"] as? NSArray {
//                                    self.musicResponse += Classified
//                                    if (self.pageNumber == 1){
//                                        self.responseCache["\(path)"] = Classified
//                                    }
//                                }
//                            }
//                            
//                            if response["totalItemCount"] != nil{
//                                self.totalItems = response["totalItemCount"] as! Int
//                            }
//                            if response["currency"] != nil{
//                                self.currency = response["currency"] as! String
//                            }
//                            if self.showOnlyMyContent == false {
//                                
////                                if (response["canCreate"] as! Bool == true){
////                                    
////                                    
////                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "searchItem")
////                                    self.navigationItem.rightBarButtonItem = searchItem
////                                    
////                                    
////                                    //                                    var addMusic = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addNewMusic")
////                                    
////                                    //self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
////                                    
////                                    
////                                }else{
////                                    
////                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "searchItem")
////                                    self.navigationItem.rightBarButtonItem = searchItem
////                                    
////                                    
////                                }
//                                
//                            }
//                        }
//                        //  dispatch_async(dispatch_get_main_queue(),{
//                        
//                        self.isPageRefresing = false
//                        //Reload Classified Tabel
//                        self.musicTableView.reloadData()
//                        //    if succeeded["message"] != nil{
//                        if self.musicResponse.count == 0{
//                            
//                            self.contentIcon = createLabel(CGRectMake(CGRectGetWidth(self.view.bounds)/2 - 30,CGRectGetHeight(self.view.bounds)/2-80,60 , 60), text: NSLocalizedString("\(classifiedIcon)",  comment: "") , alignment: .Center, textColor: textColorMedium)
//                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
//                            self.mainView.addSubview(self.contentIcon)
//                            
//                            self.info = createLabel(CGRectMake(0, 0,CGRectGetWidth(self.view.bounds) * 0.8 , 50), text: NSLocalizedString("You do not have any Music entries.",  comment: "") , alignment: .Center, textColor: textColorMedium)
//                            self.info.sizeToFit()
//                            self.info.numberOfLines = 0
//                            self.info.center = self.view.center
//                            self.info.backgroundColor = bgColor
//                            self.info.tag = 1000
//                            self.mainView.addSubview(self.info)
//                            
//                            self.refreshButton = createButton(CGRectMake(CGRectGetWidth(self.view.bounds)/2-40, CGRectGetHeight(self.info.bounds) + self.info.frame.origin.y + (2 * contentPADING), 80, 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
//                            self.refreshButton.backgroundColor = bgColor
//                            self.refreshButton.layer.borderColor = navColor.CGColor
//                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
//                            self.refreshButton.addTarget(self, action: "browseEntries", forControlEvents: UIControlEvents.TouchUpInside)
//                            self.refreshButton.layer.cornerRadius = 5.0
//                            self.refreshButton.layer.masksToBounds = true
//                            self.mainView.addSubview(self.refreshButton)
//                            self.refreshButton.hidden = false
//                            self.contentIcon.hidden = false
//                            
//                            
//                        }
//                        //   }
//                        // })
//                        
//                    }else{
//                        if succeeded["message"] != nil{
//                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
//                            
//                            
//                        }
//                        
//                    }
//                    
//                })
//            }
//        }else{
//            // No Internet Connection Message
//            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
//            
//            
//        }
//        
//    }
//    
//    
//    // MARK:  UITableViewDelegate & UITableViewDataSource
//    
//    // Set Classified Tabel Footer Height
//    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if (limit*pageNumber < totalItems){
//            
//            return 80
//            
//        }else{
//            return 0.00001
//        }
//    }
//    
//    // Set Classified Tabel Header Height
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 0.00001
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
//    {
//        if (kFrequencyAdsInCells_music > 4 && nativeAdArray.count > 9 && ((indexPath.row % kFrequencyAdsInCells_music) == (kFrequencyAdsInCells_music)-1))
//        {
//            return 200
//        }
//        return dynamicHeight
//    }
//    
//    // Set Classified Section
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    // Set No. of Rows in Section
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
//    {
//        if nativeAdArray.count > 9
//        {
//            if musicResponse.count > 0
//            {
//                let b = Int(ceil(Float(musicResponse.count)/2))
//                adsCount = b/(kFrequencyAdsInCells_music-1)
//                let Totalrowcount = adsCount+b
//                if b%(kFrequencyAdsInCells_music-1) == 0 && musicResponse.count % 2 != 0
//                {
//                    if adsCount%2 != 0
//                    {
//                        
//                        return Totalrowcount - 1
//                    }
//                }
//                else if musicResponse.count % 2 != 0 && adsCount % 2 == 0
//                {
//                    
//                    return Totalrowcount - 1
//                }
//                
//                return Totalrowcount
//                
//            }
//            else
//            {
//                
//                return Int(ceil(Float(musicResponse.count)/2))
//            }
//            
//        }
//        
//        return Int(ceil(Float(musicResponse.count)/2))
//    }
//    
//    // Set Cell of TabelView
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
//    {
//        var row = indexPath.row as Int
//        if (kFrequencyAdsInCells_music > 4 && nativeAdArray.count > 9 && ((row % kFrequencyAdsInCells_music) == (kFrequencyAdsInCells_music)-1))
//        {  // or 9 == if you don't want the first cell to be an ad!
//            musicTableView.registerClass(NativeProductsCell.self, forCellReuseIdentifier: "Cell1")
//            let cell = musicTableView.dequeueReusableCellWithIdentifier("Cell1", forIndexPath: indexPath) as! NativeProductsCell
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            cell.backgroundColor = tableViewBgColor
//            var Adcount: Int = 0
//            Adcount = row/(kFrequencyAdsInCells_music-1)
//            for var i=0;  Adcount > 10; i++
//            {
//                Adcount = Adcount/10
//            }
//            
//            if nativeAdArray.count > 0 && (nativeAdArray.count > (Adcount-1))
//            {
//                for obj in cell.contentView.subviews
//                {
//                    if obj.tag == 1001001 //Condition if that view belongs to any specific class
//                    {
//                        
//                        
//                        obj.removeFromSuperview()
//                        
//                    }
//                }
//                let view = nativeAdArray[Adcount-1]
//                cell.contentView.addSubview(view as! UIView)
//            }
//            if(UIDevice.currentDevice().userInterfaceIdiom == .Pad)
//            {
//                let adcount = row/kFrequencyAdsInCells_music
//                var index:Int!
//                index = (row * 2) - adcount
//                
//                if musicResponse.count > (index)
//                {
//                    cell.contentSelection1.hidden = false
//                    cell.classifiedImageView1.hidden = false
//                    cell.classifiedName1.hidden = false
//                    cell.MusicPlays1.hidden = false
//                    cell.descriptionView1.hidden = true
//                    cell.classifiedImageView1.image = nil
//                    if let musicInfo = musicResponse[index] as? NSDictionary {
//                        
//                        if let url = NSURL(string: musicInfo["image"] as! String){
//                            
//                            if let img = imageCache1[musicInfo["image"] as! NSString as String] {
//                                cell.classifiedImageView1?.image = img
//                            }
//                            else {
//                                // The image isn't cached, download the img data
//                                // We should perform this in a background thread
//                                let request: NSURLRequest = NSURLRequest(URL: url)
//                                let mainQueue = NSOperationQueue.mainQueue()
//                                NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
//                                    if error == nil {
//                                        // Convert the downloaded data in to a UIImage object
//                                        let image = UIImage(data: data!)
//                                        // Store the image in to our cache
//                                        self.imageCache1[musicInfo["image"] as! NSString as String] = image
//                                        // Update the cell
//                                        dispatch_async(dispatch_get_main_queue(), {
//                                            if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? NativeProductsCell {
//                                                
//                                                cellToUpdate.classifiedImageView1?.image = image
//                                                //                                        let imageview = createImageView(CGRectMake(CGRectGetWidth(cellToUpdate.classifiedImageView1.bounds)/2 - 10, CGRectGetHeight(cellToUpdate.classifiedImageView1.bounds)/2 - 7, 20, 20), border: false)
//                                                //
//                                                //                                        let lockedImage = UIImage(named:"CircularPlay1.png")
//                                                //
//                                                //                                        imageview.image = lockedImage
//                                                //
//                                                //                                        cellToUpdate.classifiedImageView1.addSubview(imageview)
//                                                
//                                                let imageLabelView = createLabel(CGRectMake(CGRectGetWidth(cellToUpdate.classifiedImageView1.bounds)/2 - 12, CGRectGetHeight(cellToUpdate.classifiedImageView1.bounds)/2 - 8, 22, 22), text: "\u{f01d}", alignment: .Center, textColor: textColorLight)
//                                                imageLabelView.font = UIFont(name: "FontAwesome", size: 24)
//                                                imageLabelView.layer.shadowColor = UIColor.blackColor().CGColor
//                                                imageLabelView.opaque = true
//                                                imageLabelView.backgroundColor = UIColor.clearColor()
//                                                imageLabelView.shadowOffset = CGSizeMake(10, 10);
//                                                imageLabelView.layer.shadowOpacity = shadowOpacity
//                                                imageLabelView.layer.shadowRadius = shadowRadius
//                                                imageLabelView.layer.shadowOffset = shadowOffset
//                                                imageLabelView.layer.masksToBounds = false
//                                                cellToUpdate.classifiedImageView1.addSubview(imageLabelView)
//                                                
//                                                
//                                                
//                                            }
//                                        })
//                                    }
//                                    else {
//                                        print("Error: \(error!.localizedDescription)")
//                                    }
//                                })
//                            }
//                            
//                        }
//                        
//                        cell.classifiedName1.text = musicInfo["title"] as? String
//                        cell.contentSelection1.tag = musicInfo["playlist_id"] as! Int
//                        cell.contentSelection1.addTarget(self, action: "showMusic:", forControlEvents: .TouchUpInside)
//                        //                if(musicInfo["menu"] as? NSArray != nil){
//                        if browseOrMyMusic {
//                            
//                            cell.menu1.hidden = true
//                        }else{
//                            // Set MenuAction
//                            cell.menu1.addTarget(self, action:"showMenu:" , forControlEvents: .TouchUpInside)
//                            cell.menu1.hidden = false
//                        }
//                        
//                        var totalView = ""
//                        if let views = musicInfo["play_count"] as? Int{
//                            let a = singlePluralCheck( NSLocalizedString(" play", comment: ""),  plural: NSLocalizedString(" plays", comment: ""), count: views)
//                            
//                            totalView += " \(a)  "
//                            
//                        }
//                        
//                        
//                        
//                        cell.MusicPlays1.text = "\(totalView)  "
//                        
//                        
//                        
//                        
//                    }
//                    
//                }
//                else{
//                    cell.contentSelection1.hidden = true
//                    cell.classifiedImageView1.hidden = true
//                    cell.classifiedName1.hidden = true
//                    cell.MusicPlays1.hidden = true
//                    cell.descriptionView1.hidden = true
//                }
//            }
//            else{
//                cell.contentSelection1.hidden = true
//                cell.classifiedImageView1.hidden = true
//                cell.classifiedName1.hidden = true
//                cell.MusicPlays1.hidden = true
//                cell.descriptionView1.hidden = true
//                
//            }
//            
//            return cell
//            
//        }
//        else
//        {
//            
//            
//            if kFrequencyAdsInCells_music > 4 && nativeAdArray.count > 9
//            {
//                row = row - (row / kFrequencyAdsInCells_music)
//            }
//            
//            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ProductTableViewCell
//            cell.selectionStyle = UITableViewCellSelectionStyle.None
//            
//            
//            var index:Int!
//            if(UIDevice.currentDevice().userInterfaceIdiom == .Pad)
//            {
//                if (kFrequencyAdsInCells_music > 4 && nativeAdArray.count > 9)
//                {
//                    var adcount = row/(kFrequencyAdsInCells_music-1)
//                    index = (row * 2) + adcount
//                    
//                }
//                else
//                {
//                    index = row * 2
//                    
//                }
//                
//                
//            }
//            else
//            {
//                index = row * 2
//            }
//            
//            
//            
//            
//            if musicResponse.count > index {
//                cell.contentSelection.hidden = false
//                cell.classifiedImageView.hidden = false
//                cell.classifiedName.hidden = false
////
////                cell.MusicPlays.hidden = false
//                cell.classifiedImageView.image = nil
//                
//                
//                
//                if let musicInfo = musicResponse[index] as? NSDictionary {
//                    // LHS
//                    if let url = NSURL(string: musicInfo["image"] as! String){
//                        
//                        if let img = imageCache[musicInfo["image"] as! NSString as String] {
//                            cell.classifiedImageView?.image = img
//                        }
//                        else {
//                            // The image isn't cached, download the img data
//                            // We should perform this in a background thread
//                            let request: NSURLRequest = NSURLRequest(URL: url)
//                            let mainQueue = NSOperationQueue.mainQueue()
//                            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
//                                if error == nil {
//                                    // Convert the downloaded data in to a UIImage object
//                                    let image = UIImage(data: data!)
//                                    // Store the image in to our cache
//                                    self.imageCache[musicInfo["image"] as! NSString as String] = image
//                                    // Update the cell
//                                    dispatch_async(dispatch_get_main_queue(), {
//                                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? ProductTableViewCell {
//                                            
//                                            cellToUpdate.classifiedImageView?.image = image
//                                            
//                                        }
//                                    })
//                                }
//                                else {
//                                    print("Error: \(error!.localizedDescription)")
//                                }
//                            })
//                        }
//                        
//                        
//                    }
//                    cell.classifiedName.text = musicInfo["title"] as? String
////                    cell.contentSelection.tag = musicInfo["playlist_id"] as! Int
////                    cell.contentSelection.addTarget(self, action: "showMusic:", forControlEvents: .TouchUpInside)
////                    
////                    if browseOrMyMusic {
////                        
////                        cell.menu.hidden = true
////                        cell.menu1.hidden = true
////                        
////                    }else{
////                        // Set MenuAction
////                        //                        if(musicInfo["menu"] as? NSArray != nil){
////                        cell.menu.addTarget(self, action:"showMenu:" , forControlEvents: .TouchUpInside)
////                        cell.menu.hidden = false
////                        cell.menu1.addTarget(self, action:"showMenu:" , forControlEvents: .TouchUpInside)
////                        cell.menu1.hidden = false
////                        //                        }
////                    }
////                    
////                    
//                    var totalView = ""
//                    if var views = musicInfo["price"] as? Int{
//                        let formatter = NSNumberFormatter()
//                        formatter.numberStyle = .CurrencyStyle
//                         formatter.locale = NSLocale.currentLocale() // This is the default
////                        formatter.stringFromNumber(price) // "$123.44"
//                        formatter.currencyCode = "\(currency)"
////                        formatter.locale = NSLocale(localeIdentifier: "\(currency)")
//                       totalView += formatter.stringFromNumber(views)! // $123"
//////                        let a = singlePluralCheck( NSLocalizedString(" play", comment: ""),  plural: NSLocalizedString(" plays", comment: ""), count: views)
//////                        
////                        totalView += " \(views)"
//////
//                    }
////
//                    
//                    //                  cell.MusicPlays.frame = CGRectMake(3 * PADING  , cell.classifiedName.frame.origin.y + CGRectGetWidth(cell.classifiedName.bounds), (CGRectGetWidth(UIScreen.mainScreen().bounds) - (3 * PADING)), 13)
//                    cell.classifiedPrice.text = "\(totalView)"
//                    
//                    
//                    
//                    
//                }
//                
//                
//            }
//            else{
//                cell.contentSelection.hidden = true
//                cell.classifiedImageView.hidden = true
//                cell.classifiedName.hidden = true
//                cell.MusicPlays.hidden = true
//                cell.descriptionView.hidden = true
//                
//                cell.contentSelection1.hidden = true
//                cell.classifiedImageView1.hidden = true
//                cell.classifiedName1.hidden = true
//                cell.MusicPlays1.hidden = true
//                cell.descriptionView1.hidden = true
//            }
//            
//            
//            if musicResponse.count > (index + 1){
//                cell.contentSelection1.hidden = false
//                cell.classifiedImageView1.hidden = false
//                cell.classifiedName1.hidden = false
//                cell.MusicPlays1.hidden = false
//                cell.descriptionView1.hidden = false
//                cell.classifiedImageView1.image = nil
//                if let musicInfo = musicResponse[index + 1] as? NSDictionary {
//                    
//                    if let url = NSURL(string: musicInfo["image"] as! String){
//                        
//                        if let img = imageCache1[musicInfo["image"] as! NSString as String] {
//                            cell.classifiedImageView1?.image = img
//                        }
//                        else {
//                            // The image isn't cached, download the img data
//                            // We should perform this in a background thread
//                            let request: NSURLRequest = NSURLRequest(URL: url)
//                            let mainQueue = NSOperationQueue.mainQueue()
//                            NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
//                                if error == nil {
//                                    // Convert the downloaded data in to a UIImage object
//                                    let image = UIImage(data: data!)
//                                    // Store the image in to our cache
//                                    self.imageCache1[musicInfo["image"] as! NSString as String] = image
//                                    // Update the cell
//                                    dispatch_async(dispatch_get_main_queue(), {
//                                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? ProductTableViewCell {
//                                            
//                                            cellToUpdate.classifiedImageView1?.image = image
//                                            
//                                        }
//                                    })
//                                }
//                                else {
//                                    print("Error: \(error!.localizedDescription)")
//                                }
//                            })
//                        }
//                        
//                    }
//                    
//                    cell.classifiedName1.text = musicInfo["title"] as? String
//                    
//                    if let rating = musicInfo["rating_avg"] as? Int
//                    {
//                        cell.updateRating(rating, ratingCount: rating)
//                    }
//                    else
//                    {
//                        cell.updateRating(0, ratingCount: 0)
//                    }
//
//                    
//                    
//                    
////                    cell.contentSelection1.tag = musicInfo["playlist_id"] as! Int
////                    cell.contentSelection1.addTarget(self, action: "showMusic:", forControlEvents: .TouchUpInside)
////                    //                if(musicInfo["menu"] as? NSArray != nil){
////                    if browseOrMyMusic {
////                        cell.menu.hidden = true
////                        cell.menu1.hidden = true
////                    }else{
////                        // Set MenuAction
////                        //                          if(musicInfo["menu"] as? NSArray != nil){
////                        cell.menu.addTarget(self, action:"showMenu:" , forControlEvents: .TouchUpInside)
////                        cell.menu.hidden = false
////                        cell.menu1.addTarget(self, action:"showMenu:" , forControlEvents: .TouchUpInside)
////                        cell.menu1.hidden = false
////                    }
//                    //                    }
//                    
//                    //                }
//                    var totalView = ""
//                    if var views = musicInfo["price"] as? Int{
//                        let formatter = NSNumberFormatter()
//                        formatter.numberStyle = .CurrencyStyle
//                        formatter.locale = NSLocale.currentLocale() // This is the default
//                        //                        formatter.stringFromNumber(price) // "$123.44"
//                        formatter.currencyCode = "\(currency)"
//                        //                        formatter.locale = NSLocale(localeIdentifier: "\(currency)")
//                        totalView += formatter.stringFromNumber(views)! // $123"
//                        ////                        let a = singlePluralCheck( NSLocalizedString(" play", comment: ""),  plural: NSLocalizedString(" plays", comment: ""), count: views)
//                        ////
//                        //                        totalView += " \(views)"
//                        ////
//                    }
//                    cell.classifiedPrice1.text = "\(totalView)"
//                }
//                
//            }
//            else{
//                cell.contentSelection1.hidden = true
//                cell.classifiedImageView1.hidden = true
//                cell.classifiedName1.hidden = true
//                cell.MusicPlays1.hidden = true
//                cell.descriptionView1.hidden = true
//            }
//            
//            return cell
//        }
//    }
//    
//    
//    
//    // Handle Classified Table Cell Selection
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        //            tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        //            var classifiedInfo:NSDictionary
//        //            classifiedInfo = musicResponse[indexPath.row] as! NSDictionary
//        //
//        //
//        //            println(classifiedInfo)
//        //
//        //
//        //
//        //            let presentedVC = MusicPlayListViewController()
//        //            presentedVC.playListId = classifiedInfo["playlist_id"] as! Int
//        //            //presentedVC.classifiedName = classifiedInfo["title"] as! String
//        //            //  presentedVC.url = blogInfo["url"] as! String
//        //            navigationController?.pushViewController(presentedVC, animated: true)
//        //            //        else{
//        //            //            showAlertMessage(mainView.center, msg: NSLocalizedString("You do not have permission to view this private page.", comment: ""), timer: true)
//        //            //        }
//        //            //
//    }
//    
//    
//    
//    
//    
//    // MARK:  UIScrollViewDelegate
//    
//    // Handle Scroll For Pagination
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        
//        if updateScrollFlag{
//            // Check for Page Number for Browse Classified
//            if musicTableView.contentOffset.y >= musicTableView.contentSize.height - musicTableView.bounds.size.height{
//                if (!isPageRefresing  && limit*pageNumber < totalItems){
//                    if reachability.isReachable() {
//                        updateScrollFlag = false
//                        pageNumber += 1
//                        isPageRefresing = true
//                        if searchDic.count == 0{
//                            browseEntries()
//                        }
//                    }
//                }
//                
//            }
//            
//        }
//        
//    }
//    
//    func searchItem(){
//        let presentedVC = MusicSearchViewController()
//        self.navigationController?.pushViewController(presentedVC, animated: false)
//        
//    }
//    
//    func showMenu(sender:UIButton){
//        var musicInfo:NSDictionary
//        musicInfo = musicResponse[sender.tag] as! NSDictionary
//        editPlaylistID = musicInfo["playlist_id"] as! Int
//        if (musicInfo["menu"] != nil){
//            let menuOption = musicInfo["menu"] as! NSArray
//            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
//            for menu in menuOption{
//                if let menuItem = menu as? NSDictionary{
//                    let titleString = menuItem["name"] as! String
//                    
//                    if titleString.rangeOfString("delete") != nil{
//                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertActionStyle.Destructive, handler:{ (UIAlertAction) -> Void in
//                            let condition = menuItem["name"] as! String
//                            switch(condition){
//                                
//                            case "delete":
//                                displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this playlist ?",comment: "") , otherButton: NSLocalizedString("Delete Playlist", comment: "")) { () -> () in
//                                    self.updateMusicMenuAction(menuItem["url"] as! String)
//                                    
//                                }
//                                self.presentViewController(alert, animated: true, completion: nil)
//                                
//                                
//                            default:
//                                self.view.makeToast(unconditionalMessage, duration: 5, position: "bottom")
//                                
//                                
//                            }
//                            
//                            
//                        }))
//                    }
//                    else{
//                        //                    alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .Default, handler:{ (UIAlertAction) -> Void in
//                        //                        let condition = menuItem["name"] as! String
//                        //                        switch(condition){
//                        //
//                        //                        case "play_on_profile":
//                        //
//                        //                            println("not working")
//                        //                        default:
//                        //                            self.view.makeToast(unconditionalMessage, duration: 5, position: "bottom")
//                        //
//                        //                        }
//                        //
//                        //
//                        //                    }))
//                    }
//                }
//            }
//            if  (UIDevice.currentDevice().userInterfaceIdiom == .Phone){
//                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .Cancel, handler:nil))
//            }else if  (UIDevice.currentDevice().userInterfaceIdiom == .Pad){
//                // Present Alert as! Popover for iPad
//                alertController.modalPresentationStyle = UIModalPresentationStyle.Popover
//                let popover = alertController.popoverPresentationController
//                popover?.sourceView = UIButton()
//                popover?.sourceRect = CGRectMake(view.bounds.height/2, view.bounds.width/2 , 1, 1)
//                popover?.permittedArrowDirections = UIPopoverArrowDirection()
//            }
//            self.presentViewController(alertController, animated:true, completion: nil)
//        }
//        
//    }
//    
//    
//    func showMusic(sender:UIButton){
//        
//        //        var musicInfo:NSDictionary
//        //        musicInfo = musicResponse[sender.tag] as! NSDictionary
//        let presentedVC = MusicPlayListViewController() //MusicPlayerViewController()
//        presentedVC.playListId = sender.tag
//        navigationController?.pushViewController(presentedVC, animated: true)
//        
//    }
//    
//    
//    
//    
//    func goBack(){
//        self.navigationController?.popViewControllerAnimated(false)
//    }
//    
//    
//    
//    //override func viewWillDisappear(animated: Bool) {
//    //    mainView.removeGestureRecognizer(tapGesture)
//    //  //  searchDic.removeAll(keepCapacity: false)
//    //}
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    
//    /*
//    // MARK: - Navigation
//    
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    // Get the new view controller using segue.destinationViewController.
//    // Pass the selected object to the new view controller.
//    }
//    */
//    
//}