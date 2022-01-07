//
//  PageViewController.swift
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
//import GoogleMobileAds
import FBAudienceNetwork
import NVActivityIndicatorView
import Instructions
var pageUpdate = true

class PageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, FBNativeAdDelegate, FBNativeAdsManagerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    
    
    let mainView = UIView()
    var browsePage:UIButton!
    var myPage:UIButton!
    var pageTableView:UITableView!
    var myPageTableView:UITableView!
    var popularPageTableView:UITableView!
    var categoryTableView:UITableView!
    var pageBrowseType : Int!
    var refresher:UIRefreshControl!
    var refresher1:UIRefreshControl!
    var refresher2:UIRefreshControl!
    var refresher3:UIRefreshControl!
    var contentIcon: UILabel!
    var browseOrMyPage = true                   // true for Browse Page & false for My Page
    var pageResponse = [AnyObject]()
    var myPageResponse = [AnyObject]()
    var popularPageResponse = [AnyObject]()
    var categoryResponse = [AnyObject]()
    var showSpinner = true                      // not show spinner at pull to refresh
    var pageOption:UIButton!
    let scrollView = UIScrollView()
    var feedFilter : UIButton!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info = UILabel()
    var updateScrollFlag = true
    var isPageRefresing = false                 // For Pagination
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent:Bool!
    var user_id : Int!
    var fromTab : Bool! = false
    var countListTitle : String!
    var noContentView : NoContentView!
    //   var imageCache = [String:UIImage]()
    //  var imageCache2 = [String:UIImage]()
    var customSegmentControl : UISegmentedControl!
    var categResponse = [AnyObject]()
    var searchType = "view_count"
    var popularSearch = ""
    var guttermenuoption = [String]()
    var guttermenuoptionname = [String]()
    var feedMenu : NSArray = []
    var currentCell : Int = 0
    var nativeAdArray = [AnyObject]()
    // AdMob Variable
//    var adLoader: GADAdLoader!
    var loadrequestcount = 0
    var adsCount:Int = 0
    var isnativeAd:Bool = true
    
    // Native FacebookAd Variable
    var nativeAd:FBNativeAd!
    var adTitleLabel:UILabel!
    var adImageView:FBMediaView!
    var adBodyLabel:UILabel!
    var adCallToActionButton:UIButton!
    var fbView:UIView!
    var leftBarButtonItem : UIBarButtonItem!
    var username : String = ""
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    fileprivate var popoverOptionsUp: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    var popoverTableView:UITableView!
    
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
    var adsCellheight:CGFloat = 0
    
    var packagesEnabled:Int! = 0
    var timerFB = Timer()
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    
    var cdAds : ContentSlideshowScrollView!
    var shared1 = VideoPlayerController()
    var taskVideoPlayPause : DispatchWorkItem?
    var cadUrl : UILabel!
    var cadTitle : UILabel!
    var ctaButton : UIButton!
    var videoclickButton = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if fromTab == false{
            setDynamicTabValue()
        }
        shared1 = VideoPlayerController()
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        category_filterId = nil
        globFilterValue = ""
        updateAfterAlert = true
        searchDic.removeAll(keepingCapacity: false)
        openMenu = false
        pageUpdate = true
        pageBrowseType = 0
        
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PageViewController.handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        if showOnlyMyContent == false
        {
            
            self.navigationItem.setHidesBackButton(true, animated: false)
            self.title = NSLocalizedString("Pages", comment: "")
            if tabBarController != nil{
                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
            }
            
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            
            let menuImageView = createImageView(CGRect(x: 0,y: 12,width: 22,height: 22), border: false)
            menuImageView.image = UIImage(named: "dashboard_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(menuImageView)
            
            
            if (logoutUser == false && (totalNotificationCount !=  nil) && (totalNotificationCount > 0)) {
                
                let countLabel = createLabel(CGRect(x: 17,y: 3,width: 17,height: 17), text: String(totalNotificationCount), alignment: .center, textColor: textColorLight)
                
                countLabel.backgroundColor = UIColor.red
                countLabel.layer.cornerRadius = countLabel.frame.size.width / 2;
                countLabel.layer.masksToBounds = true
                countLabel.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
                leftNavView.addSubview(countLabel)
            }
            
            createScrollPageMenu()
            
        }
        
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        pageTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight + 10, width: view.bounds.width, height: view.bounds.height-(TOPPADING  + ButtonHeight - 4 + tabBarHeight)), style: .grouped)
        pageTableView.register(GroupTableViewCell.self, forCellReuseIdentifier: "CellThree1")
        pageTableView.rowHeight = 255.0
        pageTableView.dataSource = self
        pageTableView.delegate = self
        pageTableView.isOpaque = false
        pageTableView.backgroundColor = bgColor
        pageTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            pageTableView.estimatedRowHeight = 0
            pageTableView.estimatedSectionHeaderHeight = 0
            pageTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(pageTableView)
        
        if showOnlyMyContent == true  {
            
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
            pageTableView.frame.origin.y = TOPPADING
            pageTableView.frame.size.height = view.bounds.height-(TOPPADING + tabBarHeight - 10)
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(PageViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        
        if logoutUser == true {
            self.title = NSLocalizedString("Pages", comment: "")
            pageTableView.frame.origin.y = TOPPADING
            pageTableView.frame.size.height = view.bounds.height-(TOPPADING + tabBarHeight - 10)
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(PageViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
        }
        
        myPageTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight + 10, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight - 4 + tabBarHeight)), style: .grouped)
        myPageTableView.register(GroupTableViewCell.self, forCellReuseIdentifier: "CellThree1")
        myPageTableView.rowHeight = 253.0
        myPageTableView.dataSource = self
        myPageTableView.delegate = self
        myPageTableView.isOpaque = false
        myPageTableView.isHidden = true
        myPageTableView.backgroundColor = bgColor
        myPageTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            myPageTableView.estimatedRowHeight = 0
            myPageTableView.estimatedSectionHeaderHeight = 0
            myPageTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview( myPageTableView)
        
        
        popularPageTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight + 10, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight - 4 + tabBarHeight)), style: .grouped)
        popularPageTableView.register(GroupTableViewCell.self, forCellReuseIdentifier: "CellThree1")
        popularPageTableView.rowHeight = 253.0
        popularPageTableView.dataSource = self
        popularPageTableView.delegate = self
        popularPageTableView.isOpaque = false
        popularPageTableView.isHidden = true
        popularPageTableView.backgroundColor = bgColor
        popularPageTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            popularPageTableView.estimatedRowHeight = 0
            popularPageTableView.estimatedSectionHeaderHeight = 0
            popularPageTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview( popularPageTableView)
        
        feedFilter = createButton(CGRect(x: 0,y: 0,width: view.bounds.width, height: ButtonHeight+10),title: NSLocalizedString("Most Viewed",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
        feedFilter.isEnabled = true
        feedFilter.backgroundColor = lightBgColor
        feedFilter.titleLabel?.font = UIFont(name: fontName, size: FONTSIZELarge)
        feedFilter.addTarget(self, action: #selector(PageViewController.showFeedFilterOptions(_:)), for: .touchUpInside)
        feedFilter.titleLabel!.numberOfLines = 1;
        feedFilter.titleLabel!.adjustsFontSizeToFitWidth = true;
        feedFilter.isHidden = true
        popularPageTableView.addSubview(feedFilter)
        
        let filterIcon = createLabel(CGRect(x: feedFilter.bounds.width - feedFilter.bounds.height, y: 0 ,width: feedFilter.bounds.height ,height: feedFilter.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorMedium)
        filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        feedFilter.addSubview(filterIcon)
        
        categoryTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight + 10, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight + tabBarHeight)), style: .grouped)
        
        categoryTableView.register(CategoryBrowseTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
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
        mainView.addSubview( categoryTableView)
        
        
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(PageViewController.refresh), for: UIControl.Event.valueChanged)
        pageTableView.addSubview(refresher)
        
        refresher1 = UIRefreshControl()
        refresher1.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher1.addTarget(self, action: #selector(PageViewController.refresh), for: UIControl.Event.valueChanged)
        myPageTableView.addSubview(refresher1)
        
        refresher2 = UIRefreshControl()
        refresher2.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher2.addTarget(self, action: #selector(PageViewController.refresh), for: UIControl.Event.valueChanged)
        categoryTableView.addSubview(refresher2)
        
        refresher3 = UIRefreshControl()
        refresher3.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher3.addTarget(self, action: #selector(PageViewController.refresh), for: UIControl.Event.valueChanged)
        popularPageTableView.addSubview(refresher3)
        
        scrollView.isUserInteractionEnabled = false
        
        let footerView3 = UIView(frame: frameActivityIndicator)
        footerView3.backgroundColor = UIColor.clear
        let activityIndicatorView3 = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView3.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView3.addSubview(activityIndicatorView3)
        activityIndicatorView3.startAnimating()
        popularPageTableView.tableFooterView = footerView3
        popularPageTableView.tableFooterView?.isHidden = true
        
        let footerView4 = UIView(frame: frameActivityIndicator)
        footerView4.backgroundColor = UIColor.clear
        let activityIndicatorView4 = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView4.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView4.addSubview(activityIndicatorView4)
        activityIndicatorView4.startAnimating()
        categoryTableView.tableFooterView = footerView4
        categoryTableView.tableFooterView?.isHidden = true
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        pageTableView.tableFooterView = footerView
        pageTableView.tableFooterView?.isHidden = true
        
        let footerView2 = UIView(frame: frameActivityIndicator)
        footerView2.backgroundColor = UIColor.clear
        let activityIndicatorView2 = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView2.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView2.addSubview(activityIndicatorView2)
        activityIndicatorView2.startAnimating()
        myPageTableView.tableFooterView = footerView2
        myPageTableView.tableFooterView?.isHidden = true
        
        if adsType_page != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(PageViewController.checkforAds),
                                           userInfo: nil,
                                           repeats: false)
        }
        
    }
    
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showPageContent")
        {
            if  UserDefaults.standard.object(forKey: "showPageContent") != nil {
                
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showPageContent")
        }
        
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        let flatCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(rect: frame)
        }
        //  self.blackScreen.alpha = 0.5
        var coachMark : CoachMark
        switch(index) {
            
        case 0:
            
            var  coachMark1 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 75.0
            let radious : Int = 40
            
            coachMark1 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                return circlePath
                
            }
            
            coachMark1.gapBetweenCoachMarkAndCutoutPath = 6.0
            
            return coachMark1
            
            
        case 1:
            // skipView.isHidden = true
            var  coachMark2 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 15.0
            let radious : Int = 40
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
            
        default:
            coachMark = coachMarksController.helper.makeCoachMark()
            coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        }
        
        
        return coachMark
    }
    
    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController, at index: Int) -> Bool{
        
        coachMarksController.stop(immediately: true)
        return false
        
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        //  var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        // For the coach mark at index 2, we disable the ability to tap on the
        // coach mark to get to the next one, forcing the user to perform
        // the appropriate action.
        switch(index) {
        case 1:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        // coachViews.bodyView.isUserInteractionEnabled = false
        default:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = " 1/2"
            coachViews.bodyView.nextLabel.text = "Next "
            
        case 1:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(createTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = " 2/2"
            coachViews.bodyView.nextLabel.text = "Finish "
            
            
            
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        
        
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool)
    {
        print("End Skip")
        //  self.blackScreen.alpha = 0.0
        
    }
    
    func showAppTour(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showPluginAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showPluginAppTour") != nil {
                
                self.targetCheckValue = name as! Int
                
                
            }
            
        }
        
        if self.targetCheckValue == 1 {
            
            UserDefaults.standard.set(2, forKey: "showPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
    }
    
    
    func updatetitle()
    {
        if showOnlyMyContent == true  {
            
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        removeNavigationViews(controller: self)
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
        
        if conditionalProfileForm == ""{
            navigationController?.navigationBar.isHidden = false
            
            self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
            self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = textColorPrime
            
        }
        
    }
    @objc func appEnteredFromBackground() {
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
    }
    @objc func appMovedToBackground() {
        self.shared1.pauseVideosFor(tableView: self.pageTableView)
        self.taskVideoPlayPause?.cancel()
    }
    @objc func videoCompletion() {
        
        shared1.currentVideoContainer()?.playOn = true
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        
    }
    func pausePlayeVideos(){
        shared1.pausePlayeVideosFor(tableView: pageTableView)
       
    }
   
    // Check for Page Update Every Time when View Appears
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
        
        
        if conditionalProfileForm == "BrowsePage"{
            navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
            self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = textColorPrime
            
        }
        
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        if pageUpdate {
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            browseEntries()
        }
        IsRedirectToProfile()
        
    }
    
    @objc func checkforAds()
    {
        nativeAdArray.removeAll()
        if adsType_page == 1
        {
            if kFrequencyAdsInCells_page > 4 && placementID != ""
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
                        if pageBrowseType == 2
                        {
                            pageTableView.reloadData()
                        }
                        else if pageBrowseType == 3
                        {
                            myPageTableView.reloadData()
                        }
                    }
                }
                
            }
            
        }
        else if adsType_page == 0
        {
            if kFrequencyAdsInCells_page > 4 && adUnitID != ""
            {
                //showNativeAd()
            }
            
        }
        else if adsType_page == 2{
            checkCommunityAds()
        }
        
    }
    
    //MARK: -  Functions that we are using for community ads and sponsered stories
    func  checkCommunityAds()
    {
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            //            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
            
            dic["type"] =  "\(adsType_page)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_page)"
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
                                            self.pageTableView.reloadData()
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
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
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
                adCallToActionButton.addTarget(self, action: #selector(PageViewController.actionAfterClick(_:)), for: .touchUpInside)
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
                    
                    
                    videoclickButton.addTarget(self, action: #selector(PageViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
                    self.fbView.addSubview(videoclickButton)
                    

                }
                else{
                    imageButton.addTarget(self, action: #selector(PageViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
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
                        
                        ctaButton.addTarget(self, action: #selector(PageViewController.tappedOnAds(_:)), for: .touchUpInside)
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
            pageUpdate = false
            let presentedVC = ExternalWebViewController()
            presentedVC.url = dic?["cads_url"]! as! String
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated: true, completion: nil)
        }
        
    }
    
    @objc func actionAfterClick(_ sender: UIButton){
      //  activityIndicatorView.startAnimating()
        var dictionary = Dictionary<String, String>()
        dictionary["type"] =  "\(adsType_page)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_page)"
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
                        self.view.isUserInteractionEnabled = true
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
                self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
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
       // parametersNeedToAdd = [:]
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
       
        if Reachabable.isConnectedToNetwork() {
             activityIndicatorView.startAnimating()
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
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
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
    
    // MARK: - FacebookAd
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
        
        if nativeAdArray.count == 10
        {
            if pageBrowseType == 2
            {
                pageTableView.reloadData()
            }
            else if pageBrowseType == 3
            {
                myPageTableView.reloadData()
            }
            
        }
        
        
    }
    public func nativeAdsFailedToLoadWithError(_ error: Error)
    {
        //print(error.localizedDescription)
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
////            request.testDevices = [kGADSimulatorID,"bc29f25fa57e135618e267a757a5fa35"]
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
//            if pageBrowseType == 0
//            {
//                self.pageTableView.reloadData()
//            }
//            else if pageBrowseType == 3
//            {
//                self.myPageTableView.reloadData()
//            }
//        }
//    }
//
//
//    func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd) {
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
//            if pageBrowseType == 0
//            {
//                self.pageTableView.reloadData()
//            }
//            else if pageBrowseType == 3
//
//            {
//                self.myPageTableView.reloadData()
//            }
//        }
//    }
    
    func createScrollPageMenu()
    {
        
        scrollView.frame = CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: ButtonHeight+10)
        scrollView.delegate = self
        scrollView.tag = 2;
        
        var menuWidth = CGFloat()
        var origin_x:CGFloat = 5.0
        if logoutUser == false
        {
            var eventMenu = ["Categories","Popular Pages","Pages","My Pages"]
            
            // menuWidth = CGFloat((view.bounds.width)/3-15)
            for i in 100 ..< 104
            {
                if  (UIDevice.current.userInterfaceIdiom == .pad){
                    menuWidth = CGFloat((view.bounds.width)/4-15)
                }else{
                    menuWidth = 100 + 5
                }
                if i == 100
                {
                    pageOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth + 5, height: ButtonHeight+10), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: true)
                }else{
                    pageOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth + 5, height: ButtonHeight+10), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: false)
                }
                pageOption.tag = i
                pageOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
                pageOption.addTarget(self, action: #selector(PageViewController.pageSelectOptions(_:)), for: .touchUpInside)
                pageOption.backgroundColor =  UIColor.clear//textColorLight
                pageOption.alpha = 1.0
                scrollView.addSubview(pageOption)
                origin_x += menuWidth
            }
            
        }
        else
        {
            var eventMenu = ["Categories","PopularPages","Pages"]
            
            //menuWidth = CGFloat((view.bounds.width)/3-15)
            for i in 100 ..< 103
            {
                
                if  (UIDevice.current.userInterfaceIdiom == .pad){
                    menuWidth = CGFloat((view.bounds.width)/3-15)
                }else{
                    menuWidth = CGFloat((view.bounds.width)/3-15)//findWidthByText("\(eventMenu[(i-100)])") + 5
                }
                
                if i == 100
                {   pageOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth + 5, height: ButtonHeight+10), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: true)
                }else{
                    pageOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth + 5, height: ButtonHeight+10), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: false)
                }
                pageOption.tag = i
                pageOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                pageOption.addTarget(self, action: #selector(PageViewController.pageSelectOptions(_:)), for: .touchUpInside)
                pageOption.backgroundColor =  UIColor.clear//textColorLight
                pageOption.alpha = 1.0
                
                //                if i==102
                //                {
                //                    pageOption.alpha = 0.4
                //
                //                }
                scrollView.addSubview(pageOption)
                origin_x += menuWidth + 10
                
            }
            
        }
        scrollView.contentSize = CGSize(width:origin_x + 10,height:ScrollframeY)
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true;
        scrollView.backgroundColor = UIColor.clear
        mainView.addSubview(scrollView)
        
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            openMenu = false
            openMenuSlideOnView(mainView)
            mainView.removeGestureRecognizer(tapGesture)
        }
    }
    
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        
        if Reachabable.isConnectedToNetwork() {
            arrGlobalFacebookAds.removeAll()
            checkforAds()
            searchDic.removeAll(keepingCapacity: false)
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            browseEntries()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }
    
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    
    @objc func pageSelectOptions(_ sender: UIButton)
    {
        pageBrowseType = sender.tag - 100
        //        scrollView.contentOffset.x = 52
        
        for ob in view.subviews {
            if ob.tag == 1000 {
                ob.removeFromSuperview()
            }
        }
        
        //        if logoutUser == false
        //        {
        if pageBrowseType == 2
        {
            feedFilter.isHidden = true
            if pageResponse.count == 0
            {
                pageTableView.isHidden = false
                categoryTableView.isHidden = true
                myPageTableView.isHidden = true
                popularPageTableView.isHidden = true
                pageNumber = 1
                showSpinner = true
                scrollView.isUserInteractionEnabled = false
                pageTableView.setContentOffset(pageTableView.contentOffset, animated: false)
                browseEntries()
            }
            else
            {
                let subViews = mainView.subviews
                for ob in subViews{
                    if ob.tag == 1000{
                        ob.removeFromSuperview()
                    }
                    if(ob .isKind(of: NWCalendarView.self))
                    {
                        ob.removeFromSuperview()
                    }
                }
                
                pageTableView.isHidden = false
                categoryTableView.isHidden = true
                myPageTableView.isHidden = true
                popularPageTableView.isHidden = true
                pageTableView.reloadData()
                
            }
            
        }
        else if pageBrowseType == 0
        {
            feedFilter.isHidden = true
            
            if categoryResponse.count == 0
            {
                pageTableView.isHidden = true
                popularPageTableView.isHidden = true
                myPageTableView.isHidden = true
                pageNumber = 1
                showSpinner = true
                scrollView.isUserInteractionEnabled = false
                browseEntries()
            }
            else
            {
                let subViews = mainView.subviews
                for ob in subViews{
                    if ob.tag == 1000{
                        ob.removeFromSuperview()
                    }
                    if(ob .isKind(of: NWCalendarView.self))
                    {
                        ob.removeFromSuperview()
                    }
                }
                
                pageTableView.isHidden = true
                categoryTableView.isHidden = false
                myPageTableView.isHidden = true
                popularPageTableView.isHidden = true
                categoryTableView.reloadData()
            }
            
            
            
        }
        else if pageBrowseType == 1
        {
            feedFilter.isHidden = false
            
            if popularPageResponse.count == 0
            {
                pageTableView.isHidden = true
                categoryTableView.isHidden = true
                myPageTableView.isHidden = true
                pageNumber = 1
                showSpinner = true
                scrollView.isUserInteractionEnabled = false
                browseEntries()
            }
            else
            {
                let subViews = mainView.subviews
                for ob in subViews{
                    if ob.tag == 1000{
                        ob.removeFromSuperview()
                    }
                    if(ob .isKind(of: NWCalendarView.self))
                    {
                        ob.removeFromSuperview()
                    }
                }
                
                pageTableView.isHidden = true
                categoryTableView.isHidden = true
                myPageTableView.isHidden = true
                popularPageTableView.isHidden = false
                popularPageTableView.reloadData()
            }
            
            
            
        }
        else  if pageBrowseType == 3
        {
            feedFilter.isHidden = true
            myPageTableView.frame = CGRect(x: 0, y: TOPPADING + ButtonHeight + 10, width: view.bounds.width, height: view.bounds.height-(ButtonHeight+TOPPADING-4+tabBarHeight ))
            scrollView.contentOffset.x = 52
            if myPageResponse.count == 0
            {
                categoryTableView.isHidden = true
                popularPageTableView.isHidden = true
                pageTableView.isHidden = true
                scrollView.isUserInteractionEnabled = false
                pageNumber = 1
                showSpinner = true
                browseEntries()
            }
            else
            {
                let subViews = mainView.subviews
                for ob in subViews{
                    if ob.tag == 1000{
                        ob.removeFromSuperview()
                    }
                    if(ob .isKind(of: NWCalendarView.self))
                    {
                        ob.removeFromSuperview()
                    }
                }
                
                categoryTableView.isHidden = true
                popularPageTableView.isHidden = true
                pageTableView.isHidden = true
                myPageTableView.isHidden = false
            }
            
            
        }
        
        //        }
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        for ob in scrollView.subviews{
            if ob .isKind(of: UIButton.self){
                if ob.tag >= 100 && ob.tag <= 104
                {
                    
                    (ob as! UIButton).setUnSelectedButton()
                    if ob.tag == sender.tag
                    {
                        
                        (ob as! UIButton).setSelectedButton()
                        
                    }
                }
                
            }
        }
        searchDic.removeAll(keepingCapacity: false)
        
    }
    
    // Create Page Form
    @objc func addNewPage(){
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            
            if packagesEnabled == 1
            {
                isCreateOrEdit = true
                let presentedVC = PackageViewController()
                presentedVC.contentType = "Page"
                presentedVC.url = "sitepages/packages"
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)
                
            }
            else
            {
                isCreateOrEdit = true
                let presentedVC = FormGenerationViewController()
                presentedVC.formTitle = NSLocalizedString("Create New Page", comment: "")
                presentedVC.contentType = "Page"
                presentedVC.param = [ : ]
                presentedVC.url = "sitepages/create"
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)
                
            }
        }
    }
    
    func IsRedirectToProfile()
    {
        if sitevideoPluginEnabled_page != 1 && addvideo_click != 1 {
            if conditionalProfileForm == "BrowsePage"
            {
                conditionalProfileForm = ""
                let presentedVC = PageDetailViewController()
                presentedVC.subjectId = "\(createResponse["page_id"] as! Int)"
                presentedVC.subjectType = "sitepage_page"
                presentedVC.checkUpdate = true
                self.navigationController?.pushViewController(presentedVC, animated: false)
            }
        }
    }
    
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        // Initialization of Timer
        self.createTimer(self)
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    
    @objc func showPage(_ sender:UIButton){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        var pageInfo:NSDictionary!
        if pageBrowseType == 2{
            pageInfo = pageResponse[sender.tag] as! NSDictionary
        }
        else if pageBrowseType == 1{
            pageInfo = popularPageResponse[sender.tag] as! NSDictionary
        }
        else if pageBrowseType == 3{
            pageInfo = myPageResponse[sender.tag] as! NSDictionary
        }
        
        if(pageInfo["allow_to_view"] as! Int == 1){
            let presentedVC = PageDetailViewController()
            presentedVC.subjectId = "\(pageInfo["page_id"] as! Int)"
            presentedVC.subjectType = "sitepage_page"
            navigationController?.pushViewController(presentedVC, animated: true)
        }else{
            self.view.makeToast(NSLocalizedString("You do not have permission to view this private page.", comment: ""), duration: 5, position: "bottom")
            
        }
    }
    
    
    @objc func pageMenu(_ sender:UIButton){
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        var pageInfo:NSDictionary
        pageInfo = myPageResponse[sender.tag] as! NSDictionary
        if(pageInfo["menu"] != nil){
            let menuOption = pageInfo["menu"] as! NSArray
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in menuOption{
                if let menuItem = menu as? NSDictionary{
                    let titleString = menuItem["name"] as! String
                    
                    if titleString.range(of: "delete") != nil{
                        
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertAction.Style.destructive , handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            
                            switch(condition){
                                
                            case "delete":
                                displayAlertWithOtherButton(NSLocalizedString("Delete Page", comment: ""),message: NSLocalizedString("Are you sure you want to delete this page?", comment: "") , otherButton: NSLocalizedString("Delete Page", comment: "")) { () -> () in
                                    // self.updatePageMenuAction(menuItem["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                            default:
                                self.view.makeToast(unconditionalMessage, duration: 5, position: "bottom")
                                
                            }
                            
                            
                        }))
                    }else{
                        
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            
                            switch(condition){
                                
                            case "edit":
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit Page", comment: "")
                                presentedVC.contentType = "Page"
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                                
                            default:
                                self.view.makeToast(unconditionalMessage, duration: 5, position: "bottom")
                                
                            }
                            
                        }))
                    }
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
    }
    
    func updatePageMenuAction(_ url : String,feedIndex: Int){
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
            
            
            if (url.range(of: "delete") != nil){
                method = "DELETE"
            }
            
            
            // Send Server Request to Explore Page Contents with Page_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update Page Detail
                        // Update Page Detail
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        updateAfterAlert = false
                        self.pageResponse.removeAll(keepingCapacity: false)
                        self.popularPageResponse.removeAll(keepingCapacity: false)
                        self.myPageResponse.removeAll(keepingCapacity: false)
                        self.browseEntries()
                    }
                        
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    @objc func openDialPad(sender: UIButton) {
        if let pageInfo = pageResponse[sender.tag] as? NSDictionary {
            if let phoneNumber = pageInfo["phone"] as? String {
                phoneNumber.makeACall()
            }
            else {
                showToast(message: "Invalid Phone Number", controller: self, onView: true, time: 5.0)
            }
        }
        
    }
    
    @objc func browseEntries()
    {
        
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            let subViews = mainView.subviews
            for ob in subViews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
                if(ob .isKind(of: NWCalendarView.self))
                {
                    ob.removeFromSuperview()
                }
            }
            
            if (self.pageNumber == 1)
            {
                
                if updateAfterAlert == true
                {
                    removeAlert()
                    //                    self.eventTableView.reloadData()
                }
                else
                {
                    updateAfterAlert = true
                }
            }
            if (showSpinner)
            {
                //           spinner.center = view.center
                if updateScrollFlag == false
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1)
                {
                    activityIndicatorView.center = mainView.center
                    updateScrollFlag = false
                }
                //                spinner.hidesWhenStopped = true
                //                spinner.style = UIstyle.gray
                //                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                //    activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            
            switch(pageBrowseType)
            {
            case 2:
                
                path = "sitepages/browse"
                if Locationdic != nil
                {
                    let defaults = UserDefaults.standard
                    
                    if let loc = defaults.string(forKey: "Location")
                    {
                        
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id),"restapilocation" : loc,"type" : "userPages"]
                        }else{
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","restapilocation": loc]
                        }
                        
                        
                        
                    }
                    else
                    {
                        
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id),"restapilocation": defaultlocation,"type" : "userPages"]
                        }else{
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","restapilocation": defaultlocation]
                        }
                        
                        popularPageTableView.isHidden = true
                        categoryTableView.isHidden = true
                        myPageTableView.isHidden = true
                        pageTableView.isHidden = false
                    }
                    
                    
                    
                }
                else
                    
                {
                    if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id),"type" : "userPages"]
                    }else{
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                        
                    }
                    
                    
                    //self.title = NSLocalizedString("Pages",  comment: "")
                    popularPageTableView.isHidden = true
                    categoryTableView.isHidden = true
                    myPageTableView.isHidden = true
                    pageTableView.isHidden = false
                    
                }
                
                
                
                
            case 0:
                
                path = "sitepages/category"
                parameters = ["page":"\(pageNumber)","limit": "\(limit)","showCount": "1"] //,"showCategory": "1"
                pageTableView.isHidden = true
                popularPageTableView.isHidden = true
                myPageTableView.isHidden = true
                categoryTableView.isHidden = false
                
                
            case 1:
                path = "sitepages/browse"
                parameters = ["page":"\(pageNumber)", "limit": "\(limit)", "orderby": "\(searchType)"]
                pageTableView.isHidden = true
                categoryTableView.isHidden = true
                myPageTableView.isHidden = true
                popularPageTableView.isHidden = false
                
            case 3:
                
                if logoutUser == false
                {
                    path = "sitepages/manage"
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
                    popularPageTableView.isHidden = true
                    categoryTableView.isHidden = true
                    pageTableView.isHidden = true
                    myPageTableView.isHidden = false
                    
                    
                }
                
            default:
                print("Error")
            }
            
            
            // Send Server Request to Browse Page Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    self.refresher.endRefreshing()
                    self.refresher1.endRefreshing()
                    self.refresher2.endRefreshing()
                    self.refresher3.endRefreshing()
                    
                    
                    self.updateScrollFlag = true
                    self.scrollView.isUserInteractionEnabled = true
                    if self.showSpinner
                    {
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    self.pageTableView.tableFooterView?.isHidden = true
                    if msg
                    {
                        
                        if self.pageBrowseType==0
                        {
                            self.pageTableView.isHidden = true
                            self.categoryTableView.isHidden = false
                            self.popularPageTableView.isHidden = true
                            self.myPageTableView.isHidden = true
                            if self.pageNumber == 1
                            {
                                self.categoryResponse.removeAll(keepingCapacity: false)
                            }
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["categories"] != nil
                                {
                                    if let page = response["categories"] as? NSArray
                                    {
                                        
                                        self.categoryResponse = self.categoryResponse + (page as [AnyObject])
                                        
                                    }
                                }
                                
                                if response["packagesEnabled"] != nil
                                {
                                    self.packagesEnabled = response["packagesEnabled"] as! Int
                                }
                                
                                if response["totalItemCount"] != nil
                                {
                                    
                                    self.totalItems = response["totalItemCount"] as! Int
                                }
                                if self.showOnlyMyContent == false
                                {
                                    
                                    if (response["canCreate"] as! Bool == true)
                                    {
                                        
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(PageViewController.searchItem))
                                        let addPage = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(PageViewController.addNewPage))
                                        self.navigationItem.setRightBarButtonItems([addPage,searchItem], animated: true)
                                        searchItem.tintColor = textColorPrime
                                        addPage.tintColor = textColorPrime
                                        
                                        
                                    }
                                }
                            }
                            self.isPageRefresing = false
                            if self.categoryResponse.count == 0
                            {
                                
                                self.info = createLabel(CGRect(x: 0, y: self.contentIcon.bounds.height + self.contentIcon.frame.origin.y + (2 * contentPADING),width: self.view.bounds.width , height: 60), text: NSLocalizedString("You do not have any pages matching this criteria.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.info.numberOfLines = 0
                                self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                                self.info.backgroundColor = bgColor
                                self.info.tag = 1000
                                self.info.isHidden = false
                                self.mainView.addSubview(self.info)
                                self.noContentView = NoContentView()
                                self.noContentView.tag = 1000
                                self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                                self.mainView.addSubview(self.noContentView)
                                self.noContentView.isHidden = false
                                self.noContentView.button.layer.borderWidth = 1
                                self.noContentView.button.layer.borderColor = buttonColor.cgColor
                                self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal)
                                self.noContentView.button.addTarget(self, action: #selector(PageViewController.addNewPage), for: .touchUpInside)
                                self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
                                
                                
                            }
                            self.categoryTableView.reloadData()
                            
                        }
                        else if self.pageBrowseType == 1
                        {
                            
                            self.pageTableView.isHidden = true
                            self.categoryTableView.isHidden = true
                            self.popularPageTableView.isHidden = false
                            self.myPageTableView.isHidden = true
                            if self.pageNumber == 1
                            {
                                self.popularPageResponse.removeAll(keepingCapacity: false)
                            }
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["response"] != nil
                                {
                                    if let popularPage = response["response"] as? NSArray
                                    {
                                        self.popularPageResponse = self.popularPageResponse + (popularPage as [AnyObject])
                                    }
                                }
                            }
                            if self.popularPageResponse.count == 2
                            {
                                self.noContentView = NoContentView()
                                self.noContentView.tag = 1000
                                self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                                self.mainView.addSubview(self.noContentView)
                                self.noContentView.isHidden = false
                                self.noContentView.button.layer.borderWidth = 1
                                self.noContentView.button.layer.borderColor = buttonColor.cgColor
                                self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal)
                                self.noContentView.button.addTarget(self, action: #selector(PageViewController.addNewPage), for: .touchUpInside)
                                self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
                                
                            }
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                
                                if response["totalItemCount"] != nil
                                {
                                    self.totalItems = response["totalItemCount"] as! Int
                                }
                                if response["canCreate"] != nil
                                {
                                    if (response["canCreate"] as! Bool == true)
                                    {
                                        
                                        
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(PageViewController.searchItem))
                                        let addPage = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(PageViewController.addNewPage))
                                        self.navigationItem.setRightBarButtonItems([addPage,searchItem], animated: true)
                                        searchItem.tintColor = textColorPrime
                                        addPage.tintColor = textColorPrime
                                        
                                    }
                                    else
                                    {
                                        
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(PageViewController.searchItem))
                                        self.navigationItem.rightBarButtonItem = searchItem
                                        searchItem.tintColor = textColorPrime
                                        
                                    }
                                }
                                
                                
                                
                            }
                            
                            self.popularPageTableView.reloadData()
                        }
                        else if self.pageBrowseType == 3
                        {
                            if logoutUser == false
                            {
                                
                                self.pageTableView.isHidden = true
                                self.categoryTableView.isHidden = true
                                self.popularPageTableView.isHidden = true
                                self.myPageTableView.isHidden = false
                                self.myPageResponse.removeAll(keepingCapacity: false)
                                if self.pageNumber == 1
                                {
                                    self.myPageResponse.removeAll(keepingCapacity: false)
                                    
                                }
                                
                                if succeeded["message"] != nil
                                {
                                    self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                                }
                                
                                
                                if let response = succeeded["body"] as? NSDictionary
                                {
                                    if response["response"] != nil
                                    {
                                        if let myPageArr = response["response"] as? NSArray
                                        {
                                            self.myPageResponse = self.myPageResponse + (myPageArr as [AnyObject])
                                            
                                        }
                                    }
                                    
                                    if response["packagesEnabled"] != nil
                                    {
                                        self.packagesEnabled = response["packagesEnabled"] as! Int
                                    }
                                    
                                    if response["getTotalItemCount"] != nil
                                    {
                                        self.totalItems = response["getTotalItemCount"] as! Int
                                    }
                                    if self.showOnlyMyContent == false
                                    {
                                        if (response["canCreate"] as! Bool == true)
                                        {
                                            
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(PageViewController.searchItem))
                                            let addPage = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(PageViewController.addNewPage))
                                            
                                            self.navigationItem.setRightBarButtonItems([addPage,searchItem], animated: true)
                                            searchItem.tintColor = textColorPrime
                                            addPage.tintColor = textColorPrime
                                            
                                        }
                                        else
                                        {
                                            
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(PageViewController.searchItem))
                                            
                                            self.navigationItem.rightBarButtonItem = searchItem
                                            searchItem.tintColor = textColorPrime
                                            
                                        }
                                        
                                        
                                        
                                    }
                                }
                                
                                self.isPageRefresing = false
                                if self.myPageResponse.count == 0
                                {
                                    self.noContentView = NoContentView()
                                    self.noContentView.tag = 1000
                                    self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                                    self.mainView.addSubview(self.noContentView)
                                    self.noContentView.isHidden = false
                                    self.noContentView.button.layer.borderWidth = 1
                                    self.noContentView.button.layer.borderColor = buttonColor.cgColor
                                    self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal)
                                    self.noContentView.button.addTarget(self, action: #selector(PageViewController.addNewPage), for: .touchUpInside)
                                    self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
                                }
                                self.myPageTableView.reloadData()
                            }
                            
                        }
                        else
                        {
                            self.pageTableView.isHidden = false
                            self.categoryTableView.isHidden = true
                            self.popularPageTableView.isHidden = true
                            self.myPageTableView.isHidden = true
                            if self.pageNumber == 1
                            {
                                self.pageResponse.removeAll(keepingCapacity: false)
                            }
                            
                            if succeeded["message"] != nil
                            {
                                self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            }
                            
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["response"] != nil
                                {
                                    if let page = response["response"] as? NSArray
                                    {
                                        self.pageResponse = self.pageResponse + (page as [AnyObject])
                                    }
                                }
                                
                                if response["packagesEnabled"] != nil
                                {
                                    self.packagesEnabled = response["packagesEnabled"] as! Int
                                }
                                
                                if response["totalItemCount"] != nil
                                {
                                    self.totalItems = response["totalItemCount"] as! Int
                                    self.countListTitle = "Pages " + "(" + "\(self.totalItems)" + ")"  + " : " + self.username
                                    self.updatetitle()
                                }
                                if self.showOnlyMyContent == false
                                {
                                    if (response["canCreate"] as! Bool == true)
                                    {
                                        
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(PageViewController.searchItem))
                                        let addPage = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(PageViewController.addNewPage))
                                        self.navigationItem.setRightBarButtonItems([addPage,searchItem], animated: true)
                                        searchItem.tintColor = textColorPrime
                                        addPage.tintColor = textColorPrime
                                        
                                        self.showAppTour()
                                        
                                        
                                        
                                    }
                                    else
                                    {
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(PageViewController.searchItem))
                                        self.navigationItem.rightBarButtonItem = searchItem
                                        searchItem.tintColor = textColorPrime
                                        
                                    }
                                }
                            }
                            
                            
                            self.isPageRefresing = false
                            if self.pageResponse.count == 0
                            {
                                
                                self.noContentView = NoContentView()
                                self.noContentView.tag = 1000
                                self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                                self.mainView.addSubview(self.noContentView)
                                self.noContentView.isHidden = false
                                self.noContentView.button.layer.borderWidth = 1
                                self.noContentView.button.layer.borderColor = buttonColor.cgColor
                                self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal)
                                self.noContentView.button.addTarget(self, action: #selector(PageViewController.addNewPage), for: .touchUpInside)
                                self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
                            }
                            if NotPlay != 1 {
                                self.pausePlayeVideos()
                            }
                            self.pageTableView.reloadData()
                            
                            
                        }
                        
                    }
                    else
                    {
                        self.refresher.endRefreshing()
                        if succeeded["message"] != nil
                        {
                            self.scrollView.isUserInteractionEnabled = true
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        
                    }
                    
                    
                })
            }
        }
        else
        {
            // No Internet Connection Message
            self.scrollView.isUserInteractionEnabled = true
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if tableView.tag == 11{
            return 0.00001
        }
        else{
            
            if (limit*pageNumber < totalItems){
                return 0
            }else{
                return 0.00001
            }
        }
    }
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if pageBrowseType == 1 {
            return ButtonHeight + 10
        }
        else{
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
        
        // For showing facebook ads count
        var rowcount = Int()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            rowcount = 2*(kFrequencyAdsInCells_page-1)
        }
        else
        {
            rowcount = (kFrequencyAdsInCells_page-1)
        }
        
        if pageBrowseType == 2
        {
            if nativeAdArray.count > 9
            {
                if pageResponse.count > rowcount
                {
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        let b = Int(ceil(Float(pageResponse.count)/2))
                        adsCount = b/(kFrequencyAdsInCells_page-1)
                        if adsCount > 1 || pageResponse.count%2 != 0
                        {
                            adsCount = adsCount/2
                        }
                        let Totalrowcount = adsCount+b
                        if b%(kFrequencyAdsInCells_page-1) == 0 && pageResponse.count % 2 != 0
                        {
                            if adsCount%2 != 0
                            {
                                return Totalrowcount - 1
                            }
                        }
                        else if pageResponse.count % 2 != 0 && adsCount % 2 == 0
                        {
                            
                            return Totalrowcount - 1
                        }
                        return Totalrowcount
                    }
                    else
                    {
                        let b = pageResponse.count
                        adsCount = b/(kFrequencyAdsInCells_page-1)
                        let Totalrowcount = adsCount+b
                        if Totalrowcount % kFrequencyAdsInCells_page == 0
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
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return Int(ceil(Float(pageResponse.count)/2))
            }
            
            return pageResponse.count
            
            
        }
        else if pageBrowseType == 0
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return Int(ceil(Float(categoryResponse.count)/4))
            }
            return Int(ceil(Float(categoryResponse.count)/3))
            
            
            
        }
        else if pageBrowseType == 1
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return Int(ceil(Float(popularPageResponse.count)/2))
            }
            
            return popularPageResponse.count
            
            
        }
        else if pageBrowseType == 3
        {
            if tableView.tag == 11
            {
                return guttermenuoption.count
            }
            else
            {
                
                if nativeAdArray.count > 0
                {
                    if myPageResponse.count > rowcount
                    {
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            let b = Int(ceil(Float(myPageResponse.count)/2))
                            adsCount = b/(kFrequencyAdsInCells_page-1)
                            if adsCount > 1 || myPageResponse.count%2 != 0
                            {
                                adsCount = adsCount/2
                            }
                            let Totalrowcount = adsCount+b
                            if b%(kFrequencyAdsInCells_page-1) == 0 && myPageResponse.count % 2 != 0
                            {
                                if adsCount%2 != 0
                                {
                                    return Totalrowcount - 1
                                }
                            }
                            return Totalrowcount
                        }
                        else
                        {
                            let b = myPageResponse.count
                            adsCount = b/(kFrequencyAdsInCells_page-1)
                            let c = adsCount+b
                            return c
                        }
                    }
                    
                    
                }
                
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    return Int(ceil(Float(myPageResponse.count)/2))
                }
                return myPageResponse.count
                
            }
        }
        return myPageResponse.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = (indexPath as NSIndexPath).row as Int
        if tableView.tag == 11
        {
            return 40
        }
        guard pageBrowseType == 0 else
        {
            if (kFrequencyAdsInCells_page > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_page) == (kFrequencyAdsInCells_page)-1)) && pageBrowseType == 2
            {
            if adsType_page == 2
            {
                guard (UIDevice.current.userInterfaceIdiom != .pad) else {
                    return adsCellheight
                }
                return adsCellheight
            }
           
            return adsCellheight + 5
            }
            return 255
        }
        return 105
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
     
        cell.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        cell.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cell.layer.shadowOpacity = 1.0
        cell.layer.shadowRadius = 0.0
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 4.0
        if adsType_page == 2{

        var row = indexPath.row as Int
        if (kFrequencyAdsInCells_page > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_page) == (kFrequencyAdsInCells_page)-1))
        {
            //            displyedAdsCount = (row / kFrequencyAdsInCells_feeds)
            //            row = row - displyedAdsCount
            
            if let cell1 = cell as? NativeAdinstallFeedCell
            {
                var Adcount: Int = 0
                Adcount = row/(kFrequencyAdsInCells_page-1)
                
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
        if adsType_page == 2{
        if tableView.tag != 11
        {
            
            let row = indexPath.row as Int
            if pageBrowseType == 0 && (kFrequencyAdsInCells_page > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_page) == (kFrequencyAdsInCells_page)-1))
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
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView.tag == 11
        {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            cell.textLabel?.text = guttermenuoption[(indexPath as NSIndexPath).row]
            return cell
            
        }
        
        var row = (indexPath as NSIndexPath).row as Int
        let totalRows = pageResponse.count + adsCount
        let totalRows1 = myPageResponse.count + adsCount
        if (pageBrowseType == 2 && totalRows > (indexPath.row - 1 - adsCount))
        {
            
            if (kFrequencyAdsInCells_page > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_page) == (kFrequencyAdsInCells_page)-1))
            {  // or 9 == if you don't want the first cell to be an ad!
                pageTableView.register(NativeAdinstallFeedCell.self, forCellReuseIdentifier: "Cell1")
                let cell = pageTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeAdinstallFeedCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = tableViewBgColor
                var Adcount: Int = 0
                Adcount = row/(kFrequencyAdsInCells_page-1)
                
                while Adcount > 10{
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
                    if adsType_page == 2{
                    let activityFeed = communityAdsValues[Adcount] as! NSMutableDictionary
                    cell.Adimageview.isHidden = false
                    if activityFeed["cmd_ad_format"] as! String == "video"{
                        
                        print("com ads \(communityAdsValues[Adcount])")
                     //   let activityFeed = communityAdsValues[Adcount] as! NSMutableDictionary
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
                    }

                    
                    let view = nativeAdArray[Adcount]
                    cell.cellView.addSubview(view as! UIView)

                    cell.cellView.frame.size.height = view.frame.size.height
                    adsCellheight = cell.cellView.frame.size.height + 5
                }

//                if(UIDevice.current.userInterfaceIdiom == .pad){
//
//                    var pageInfo2:NSDictionary!
//                    let adcount = row/kFrequencyAdsInCells_advancedevent
//                    if(pageResponse.count > (row*2-adcount) ){
//                        pageInfo2 = pageResponse[(row*2-adcount)] as! NSDictionary
//                        cell.cellView2.isHidden = false
//                        cell.contentSelection2.isHidden = false
//                        cell.contentSelection2.tag = (row*2-adcount)
//                        cell.menu2.tag = (row*2-adcount)
//                    }else{
//                        cell.cellView2.isHidden = true
//                        cell.contentSelection2.isHidden = true
//                        return cell
//                    }
//
//
//                    // Select Page Action
//                    cell.contentSelection2.addTarget(self, action: #selector(PageViewController.showPage(_:)), for: .touchUpInside)
//                    // Set MenuAction
//                    cell.menu2.addTarget(self, action:#selector(PageViewController.pageMenu(_:)) , for: .touchUpInside)
//
//                    // Set Page Image
//
//
//                    if let photoId = pageInfo2["photo_id"] as? Int{
//
//                        if photoId != 0{
//                            //   cell.contentImage2.image = nil
//                            cell.contentImage2.backgroundColor = placeholderColor
//
//                            if let url = URL(string: pageInfo2["image"] as! NSString as String){
//                                cell.contentImage2.kf.indicatorType = .activity
//                                (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
//                                cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
//
//                                })
//                            }
//
//
//                        }else{
//                            cell.contentImage2.image =  imageWithImage( UIImage(named: "showPageImage.png")!, scaletoWidth: cell.contentImage2.bounds.width)
//
//                        }
//                    }
//
//                    // Set Page Name
//                    let name = pageInfo2["title"] as? String
//
//                    let tempString2 = "\(name!)" as NSString
//
//                    var value2 : String
//
//                    if tempString2.length > 30{
//                        value2 = tempString2.substring(to: 27)
//                        value2 += NSLocalizedString("...",  comment: "")
//                    }else{
//                        value2 = "\(tempString2)"
//                    }
//
//                    let owner = pageInfo2["like_count"] as? Int
//
//                    let members = pageInfo2["follow_count"] as? Int
//
//
//                    cell.contentName2.frame = CGRect(x: 0, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 27)
//                    cell.contentName2.text = " \(value2)"
//                    cell.contentName2.font = UIFont(name: fontName, size: FONTSIZELarge)
//
//                    let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
//                    cell.totalMembers2.frame = CGRect(x: 4, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage2.bounds.width-20), height: 20)
//                    cell.totalMembers2.text = " \(likeCount)"
//                    cell.totalMembers2.font = UIFont(name: fontName, size: FONTSIZESmall)
//
//
//                    let member = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
//                    // CGRect(x:CGRectGetWidth(cell.contentImage.bounds) - 100, CGRectGetHeight(cell.contentImage.bounds) - 40, 100, 20)
//                    cell.eventTime2.frame = CGRect(x: cell.contentImage2.bounds.width - 105, y: cell.contentImage2.bounds.height - 30, width: 100, height: 20)
//                    cell.eventTime2.text = "\(member)"
//                    cell.eventTime2.textAlignment = NSTextAlignment.right
//                    cell.eventTime2.textColor = textColorLight
//                    cell.eventTime2.font = UIFont(name: fontName, size: FONTSIZESmall)
//
//                    if browseOrMyPage {
//                        cell.menu2.isHidden = true
//                        cell.createdBy2.frame.size.width = cell.cellView2.bounds.width -  (cell.createdBy2.frame.origin.x + 10)
//                    }else{
//                        cell.menu2.isHidden = false
//                        cell.createdBy2.frame.size.width = cell.cellView2.bounds.width -  (cell.createdBy2.frame.origin.x + 30)
//                    }
//
//                }

                return cell
                
            }
            else
            {
                
                if kFrequencyAdsInCells_page > 4 && nativeAdArray.count > 0
                {
                    row = row - (row / kFrequencyAdsInCells_page)
                }
                let cell = pageTableView.dequeueReusableCell(withIdentifier: "CellThree1") as! GroupTableViewCell
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = bgColor
                
                
                // cell.contentSelection.frame.height = CGRectGetHeight(cell.contentImage.bounds) - 75
                
                var pageInfo:NSDictionary!
                if pageBrowseType == 2{
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        if (kFrequencyAdsInCells_page > 4 && nativeAdArray.count > 0)
                        {
                            let adcount = row/(kFrequencyAdsInCells_page-1)
                            if(pageResponse.count > row*2+adcount)
                            {
                                pageInfo = pageResponse[row*2+adcount] as! NSDictionary
                                cell.contentSelection.tag = row*2+adcount
                                cell.menu.tag = row*2+adcount
                            }
                        }
                        else
                        {
                            if(pageResponse.count > row*2 )
                            {
                                pageInfo = pageResponse[row*2] as! NSDictionary
                                cell.contentSelection.tag = row*2
                                cell.menu.tag = row*2
                            }
                        }
                        
                        
                    }
                    else
                    {
                        pageInfo = pageResponse[row] as! NSDictionary
                        cell.contentSelection.tag = row
                        cell.menu.tag = row
                    }
                }
                
                //Select Page Action
                cell.contentSelection.addTarget(self, action: #selector(PageViewController.showPage(_:)), for: .touchUpInside)
                // Set MenuAction
                
                
                // Set Page Image
                if pageInfo["photo_id"] != nil ,let photoId = pageInfo["photo_id"] as? Int{
                    if photoId != 0{
                        cell.contentImage.image = nil
                        cell.contentImage.image =  imageWithImage( UIImage(named: "showPageImage.png")!, scaletoWidth: cell.contentImage.bounds.width)
                        //  cell.contentImage.backgroundColor = placeholderColor
                        if let url1 = URL(string: pageInfo["image"] as! NSString as String){
                            cell.contentImage.kf.indicatorType = .activity
                            (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            })
                        }
                        
                    }
                    else{
                        cell.contentImage.image = nil
                        cell.contentImage.image =  imageWithImage( UIImage(named: "showPageImage.png")!, scaletoWidth: cell.contentImage.bounds.width)
                    }
                }
                if(pageInfo["closed"] as! Int == 1){
                    cell.closeIconView.frame = CGRect(x: cell.contentImage.bounds.width/2 - cell.contentImage.bounds.width/6 , y: cell.contentImage.bounds.height/2 - cell.contentImage.bounds.height/6, width: cell.contentImage.bounds.width/3, height: cell.contentImage.bounds.height/3)
                    cell.closeIconView.isHidden = false
                    cell.closeIconView.text = "\(closedIcon)"
                    cell.closeIconView.font = UIFont(name: "FontAwesome", size: cell.contentImage.bounds.width/6)
                }
                else{
                    cell.closeIconView.isHidden = true
                }
               
                
                // Set Page Name
                let name = pageInfo["title"] as? String
                let tempString = name! as NSString
                var value : String
                if tempString.length > 30{
                    value = tempString.substring(to: 27)
                    value += NSLocalizedString("...",  comment: "")
                }else{
                    value = "\(tempString)"
                }
                let owner = pageInfo["like_count"] as? Int
                
                let members = pageInfo["follow_count"] as? Int
                
                let follower = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                cell.contentName.frame = CGRect(x: 0, y: cell.contentImage.bounds.height - 55, width: (cell.contentImage.bounds.width-20), height: 27)
                cell.contentName.text = " \(value)"
                cell.contentName.font = UIFont(name: fontName, size: FONTSIZELarge)
                
                let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                cell.totalMembers.frame = CGRect(x: 4, y: cell.contentImage.bounds.height - 30, width: (cell.contentImage.bounds.width-100), height: 20)
                cell.totalMembers.text = "\(likeCount) "
                cell.totalMembers.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.totalMembers.layer.shadowOpacity = 0.0
                
                cell.eventTime.frame = CGRect(x: cell.contentImage.bounds.width - 105, y: cell.contentImage.bounds.height - 30, width: 100, height: 20)
                cell.eventTime.text = "\(follower)"
                cell.eventTime.textAlignment = NSTextAlignment.right
                cell.eventTime.textColor = textColorLight
                
                
                // Set Menu
                if pageBrowseType != 3 {
                    cell.menu.isHidden = true
                    //cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 10)
                }else{
                    cell.menu.isHidden = false
                    cell.menu.addTarget(self, action:#selector(PageViewController.pageMenu(_:)) , for: .touchUpInside)
                    
                    //cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 30)
                }
                
                // RHS
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    
                    var pageInfo2:NSDictionary!
                    var adcount = Int()
                    if (kFrequencyAdsInCells_page > 4 && nativeAdArray.count > 0)
                    {
                        adcount = row/(kFrequencyAdsInCells_page-1)
                    }
                    else
                    {
                        adcount = 0
                    }
                    
                    if(pageResponse.count > (row*2+1+adcount) ){
                        pageInfo2 = pageResponse[(row*2+1+adcount)] as! NSDictionary
                        cell.cellView2.isHidden = false
                        cell.contentSelection2.isHidden = false
                        cell.contentSelection2.tag = (row*2+1+adcount)
                        cell.menu2.tag = (row*2+1+adcount)
                        
                    }else{
                        cell.cellView2.isHidden = true
                        cell.contentSelection2.isHidden = true
                        return cell
                    }
                    
                    
                    // Select Page Action
                    cell.contentSelection2.addTarget(self, action: #selector(PageViewController.showPage(_:)), for: .touchUpInside)
                    // Set MenuAction
                    cell.menu2.addTarget(self, action:#selector(PageViewController.pageMenu(_:)) , for: .touchUpInside)
                    
                    // Set Page Image
                    
                    
                    if let photoId = pageInfo2["photo_id"] as? Int{
                        
                        if photoId != 0{
                            cell.contentImage2.image = nil
                            cell.contentImage2.backgroundColor = placeholderColor
                            
                            if let url = URL(string: pageInfo2["image"] as! NSString as String){
                                cell.contentImage2.kf.indicatorType = .activity
                                (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                            }
                            
                            
                        }else{
                            cell.contentImage2.image =  imageWithImage( UIImage(named: "showPageImage.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                            
                        }
                    }
                    
                    // Set Page Name
                    let name = pageInfo2["title"] as? String
                    
                    let tempString2 = "\(name!)" as NSString
                    
                    var value2 : String
                    
                    if tempString2.length > 30{
                        value2 = tempString2.substring(to: 27)
                        value2 += NSLocalizedString("...",  comment: "")
                    }else{
                        value2 = "\(tempString2)"
                    }
                    
                    let owner = pageInfo2["like_count"] as? Int
                    
                    let members = pageInfo2["follow_count"] as? Int
                    
                    
                    cell.contentName2.frame = CGRect(x: 0, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 27)
                    cell.contentName2.text = " \(value2)"
                    cell.contentName2.font = UIFont(name: fontName, size: FONTSIZELarge)
                    
                    let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                    
                    cell.totalMembers2.frame = CGRect(x: 4, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage.bounds.width-20), height: 20)
                    
                    cell.totalMembers2.text = " \(likeCount)"
                    
                    
                    
                    let member = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                    // CGRect(x:CGRectGetWidth(cell.contentImage.bounds) - 100, CGRectGetHeight(cell.contentImage.bounds) - 40, 100, 20)
                    cell.eventTime2.frame = CGRect(x: cell.contentImage2.bounds.width - 102, y: cell.contentImage2.bounds.height - 30, width: 100, height: 20)
                    cell.eventTime2.text = "\(member)"
                    cell.eventTime2.textAlignment = NSTextAlignment.right
                    cell.eventTime2.textColor = textColorLight
                    
                    
                    if browseOrMyPage {
                        cell.menu2.isHidden = true
                        cell.createdBy2.frame.size.width = cell.cellView2.bounds.width -  (cell.createdBy2.frame.origin.x + 10)
                    }else{
                        cell.menu2.isHidden = false
                        cell.createdBy2.frame.size.width = cell.cellView2.bounds.width -  (cell.createdBy2.frame.origin.x + 30)
                    }
                    
                }
                
                return cell
            }
        }
        else if (pageBrowseType == 1 && popularPageResponse.count > (indexPath.row - 1))
        {
            let cell = popularPageTableView.dequeueReusableCell(withIdentifier: "CellThree1") as! GroupTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = bgColor
            
            
            // cell.contentSelection.frame.height = CGRectGetHeight(cell.contentImage.bounds) - 75
            
            var pageInfo:NSDictionary!
            if pageBrowseType == 1{
                
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    if(popularPageResponse.count > ((indexPath as NSIndexPath).row)*2 ){
                        pageInfo = popularPageResponse[((indexPath as NSIndexPath).row)*2] as! NSDictionary
                        cell.contentSelection.tag = ((indexPath as NSIndexPath).row)*2
                        cell.menu.tag = ((indexPath as NSIndexPath).row)*2
                    }
                }else{
                    pageInfo = popularPageResponse[(indexPath as NSIndexPath).row] as! NSDictionary
                    cell.contentSelection.tag = (indexPath as NSIndexPath).row
                    cell.menu.tag = (indexPath as NSIndexPath).row
                }
            }
            
            
            //Select Page Action
            cell.contentSelection.addTarget(self, action: #selector(PageViewController.showPage(_:)), for: .touchUpInside)
            // Set MenuAction
            
            
            // Set Page Image
            if pageInfo["photo_id"] != nil ,let photoId = pageInfo["photo_id"] as? Int{
                if photoId != 0{
                    
                    if let url1 = URL(string: pageInfo["image"] as! NSString as String){
                        cell.contentImage.kf.indicatorType = .activity
                        (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        })
                    }
                    
                }
                else{
                    cell.contentImage.image = nil
                    cell.contentImage.image =  imageWithImage( UIImage(named: "showPageImage.png")!, scaletoWidth: cell.contentImage.bounds.width)
                }
            }
            
            if(pageInfo["closed"] as! Int == 1){
                cell.closeIconView.frame = CGRect(x: cell.contentImage.bounds.width/2 - cell.contentImage.bounds.width/6 , y: cell.contentImage.bounds.height/2 - cell.contentImage.bounds.height/6, width: cell.contentImage.bounds.width/3, height: cell.contentImage.bounds.height/3)
                cell.closeIconView.isHidden = false
                cell.closeIconView.text = "\(closedIcon)"
                cell.closeIconView.font = UIFont(name: "FontAwesome", size: cell.contentImage.bounds.width/6)
            }
            else {
                cell.closeIconView.isHidden = true
            }
            
            if let featured = pageInfo["featured"] as? Int, featured == 1 {
                //                    cell.featuredLabel.isHidden = false
                if let sponsored = pageInfo["sponsored"] as? Int, sponsored == 1 {
                    cell.featuredLabel.isHidden = false
                    cell.sponsoredLabel.isHidden = false
                    cell.featuredLabel.frame.origin.x = UIScreen.main.bounds.size.width - 140
                }
                else {
                    cell.sponsoredLabel.isHidden = true
                    cell.featuredLabel.isHidden = false
                    cell.featuredLabel.frame.origin.x = cell.sponsoredLabel.frame.origin.x
                }
            }
            else{
                cell.closeIconView.isHidden = true
            }
            
            
            // Set Page Name
            let name = pageInfo["title"] as? String
            let tempString = name! as NSString
            var value : String
            if tempString.length > 30{
                value = tempString.substring(to: 27)
                value += NSLocalizedString("...",  comment: "")
            }else{
                value = "\(tempString)"
            }
            let owner = pageInfo["like_count"] as? Int
            
            let members = pageInfo["follow_count"] as? Int
            
            let a = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
            cell.contentName.frame = CGRect(x: 0, y: cell.contentImage.bounds.height - 55, width: (cell.contentImage.bounds.width-20), height: 27)
            cell.contentName.text = " \(value)"
            cell.contentName.font = UIFont(name: fontName, size: FONTSIZELarge)
            
            let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
            cell.totalMembers.frame = CGRect(x: 4, y: cell.contentImage.bounds.height - 30, width: (cell.contentImage.bounds.width-100), height: 20)
            cell.totalMembers.text = "\(likeCount) "
            cell.totalMembers.font = UIFont(name: fontName, size: FONTSIZESmall)
            cell.totalMembers.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.totalMembers.layer.shadowOpacity = 0.0
            
            cell.eventTime.frame = CGRect(x: cell.contentImage.bounds.width - 105, y: cell.contentImage.bounds.height - 30, width: 100, height: 20)
            cell.eventTime.text = "\(a)"
            cell.eventTime.textAlignment = NSTextAlignment.right
            cell.eventTime.textColor = textColorLight
            cell.eventTime.font = UIFont(name: fontName, size: FONTSIZESmall)
            
            // Set Menu
            if pageBrowseType != 3 {
                cell.menu.isHidden = true
                cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 10)
            }else{
                cell.menu.isHidden = false
                cell.menu.addTarget(self, action:#selector(PageViewController.pageMenu(_:)) , for: .touchUpInside)
                cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 30)
            }
            
            // RHS
            if(UIDevice.current.userInterfaceIdiom == .pad){
                
                var pageInfo2:NSDictionary!
                if(pageResponse.count > (((indexPath as NSIndexPath).row)*2+1) ){
                    pageInfo2 = pageResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
                    cell.cellView2.isHidden = false
                    cell.contentSelection2.isHidden = false
                    cell.contentSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
                    cell.menu2.tag = (((indexPath as NSIndexPath).row)*2+1)
                }else{
                    cell.cellView2.isHidden = true
                    cell.contentSelection2.isHidden = true
                    return cell
                }
                
                
                // Select Page Action
                cell.contentSelection2.addTarget(self, action: #selector(PageViewController.showPage(_:)), for: .touchUpInside)
                // Set MenuAction
                cell.menu2.addTarget(self, action:#selector(PageViewController.pageMenu(_:)) , for: .touchUpInside)
                
                // Set Page Image
                
                
                if let photoId = pageInfo2["photo_id"] as? Int{
                    
                    if photoId != 0{
                        cell.contentImage2.image = nil
                        cell.contentImage2.backgroundColor = placeholderColor
                        
                        if let url = URL(string: pageInfo2["image"] as! NSString as String){
                            cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                        
                        
                    }else{
                        cell.contentImage2.image =  imageWithImage( UIImage(named: "showPageImage.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                        
                    }
                }
                
                // Set Page Name
                let name = pageInfo2["title"] as? String
                
                let tempString2 = "\(name!)" as NSString
                
                var value2 : String
                
                if tempString2.length > 30{
                    value2 = tempString2.substring(to: 27)
                    value2 += NSLocalizedString("...",  comment: "")
                }else{
                    value2 = "\(tempString2)"
                }
                
                let owner = pageInfo2["like_count"] as? Int
                
                let members = pageInfo2["follow_count"] as? Int
                
                
                cell.contentName2.frame = CGRect(x: 0, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 27)
                cell.contentName2.text = " \(value2)"
                cell.contentName2.font = UIFont(name: fontName, size: FONTSIZELarge)
                
                let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                cell.totalMembers2.frame = CGRect(x: 4, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage.bounds.width-20), height: 20)
                cell.totalMembers2.text = " \(likeCount)"
                cell.totalMembers2.font = UIFont(name: fontName, size: FONTSIZESmall)
                
                
                let member = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                // CGRect(x:CGRectGetWidth(cell.contentImage.bounds) - 100, CGRectGetHeight(cell.contentImage.bounds) - 40, 100, 20)
                cell.eventTime2.frame = CGRect(x: cell.contentImage2.bounds.width - 102, y: cell.contentImage2.bounds.height - 30, width: 100, height: 20)
                cell.eventTime2.text = "\(member)"
                cell.eventTime2.textAlignment = NSTextAlignment.right
                cell.eventTime2.textColor = textColorLight
                cell.eventTime2.font = UIFont(name: fontName, size: FONTSIZESmall)
                
                
            }
            
            return cell
            
        }
        else if (pageBrowseType == 3 && totalRows1 > (indexPath.row - 1 - adsCount))
        {
            
            if (kFrequencyAdsInCells_page > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_page) == (kFrequencyAdsInCells_page)-1))
            {  // or 9 == if you don't want the first cell to be an ad!
                myPageTableView.register(NativeGroupCell.self, forCellReuseIdentifier: "Cell1")
                let cell = myPageTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeGroupCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = tableViewBgColor
                var Adcount: Int = 0
                Adcount = row/(kFrequencyAdsInCells_page-1)
                
                while Adcount > 10{
                    
                    Adcount = Adcount/10
                }
                
                
                if nativeAdArray.count > 0 && (nativeAdArray.count > (Adcount-1))
                {
                    for obj in cell.contentView.subviews
                    {
                        if obj.tag == 1001001 //Condition if that view belongs to any specific class
                        {
                            
                            
                            obj.removeFromSuperview()
                            
                        }
                    }
                    let view = nativeAdArray[Adcount-1]
                    cell.contentView.addSubview(view as! UIView)
                }
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    
                    var pageInfo2:NSDictionary!
                    let adcount = row/kFrequencyAdsInCells_page
                    if(myPageResponse.count > (row*2-adcount) ){
                        pageInfo2 = myPageResponse[(row*2-adcount)] as! NSDictionary
                        cell.cellView2.isHidden = false
                        cell.contentSelection2.isHidden = false
                        cell.contentSelection2.tag = (row*2-adcount)
                        cell.menu2.tag = (row*2-adcount)
                    }else{
                        cell.cellView2.isHidden = true
                        cell.contentSelection2.isHidden = true
                        return cell
                    }
                    
                    
                    // Select Page Action
                    cell.contentSelection2.addTarget(self, action: #selector(PageViewController.showPage(_:)), for: .touchUpInside)
                    // Set MenuAction
                    // cell.menu2.addTarget(self, action:"pageMenu:" , forControlEvents: .touchUpInside)
                    
                    // Set Page Image
                    
                    
                    if let photoId = pageInfo2["photo_id"] as? Int{
                        
                        if photoId != 0{
                            cell.contentImage2.image = nil
                            cell.contentImage2.backgroundColor = placeholderColor
                            
                            if let url = URL(string: pageInfo2["image"] as! NSString as String){
                                cell.contentImage2.kf.indicatorType = .activity
                                (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                            }
                            
                            
                        }else{
                            cell.contentImage2.image =  imageWithImage( UIImage(named: "showPageImage.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                            
                        }
                    }
                    
                    // Set Page Name
                    let name = pageInfo2["title"] as? String
                    
                    let tempString2 = "\(name!)" as NSString
                    
                    var value2 : String
                    
                    if tempString2.length > 30{
                        value2 = tempString2.substring(to: 27)
                        value2 += NSLocalizedString("...",  comment: "")
                    }else{
                        value2 = "\(tempString2)"
                    }
                    
                    let owner = pageInfo2["like_count"] as? Int
                    
                    let members = pageInfo2["follow_count"] as? Int
                    
                    
                    cell.contentName2.frame = CGRect(x: 0, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 27)
                    cell.contentName2.text = " \(value2)"
                    cell.contentName2.font = UIFont(name: fontName, size: FONTSIZELarge)
                    
                    let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                    cell.totalMembers2.frame = CGRect(x: 4, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage2.bounds.width-20), height: 20)
                    cell.totalMembers2.text = " \(likeCount)"
                    cell.totalMembers2.font = UIFont(name: fontName, size: FONTSIZESmall)
                    
                    
                    let member = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                    // CGRect(x:CGRectGetWidth(cell.contentImage.bounds) - 100, CGRectGetHeight(cell.contentImage.bounds) - 40, 100, 20)
                    cell.eventTime2.frame = CGRect(x: cell.contentImage2.bounds.width - 102, y: cell.contentImage2.bounds.height - 30, width: 100, height: 20)
                    cell.eventTime2.text = "\(member)"
                    cell.eventTime2.textAlignment = NSTextAlignment.right
                    cell.eventTime2.textColor = textColorLight
                    cell.eventTime2.font = UIFont(name: fontName, size: FONTSIZESmall)
                    
                    cell.menu2.isHidden = false
                    // cell.menu2.addTarget(self, action:"pageMenu:" , forControlEvents: .touchUpInside)
                    let recognizer = UITapGestureRecognizer(target: self, action:#selector(PageViewController.handleTapped(_:)))
                    recognizer.delegate = self
                    
                    cell.menu2.addGestureRecognizer(recognizer)
                    
                    cell.createdBy2.frame.size.width = cell.cellView2.bounds.width -  (cell.createdBy2.frame.origin.x + 30)
                    
                    
                }
                
                
                return cell
                
            }
            else
            {
                
                if kFrequencyAdsInCells_page > 4 && nativeAdArray.count > 0
                {
                    row = row - (row / kFrequencyAdsInCells_page)
                }
                
                
                let cell = myPageTableView.dequeueReusableCell(withIdentifier: "CellThree1") as! GroupTableViewCell
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = bgColor
                
                
                // cell.contentSelection.frame.height = CGRectGetHeight(cell.contentImage.bounds) - 75
                
                var pageInfo:NSDictionary!
                
                if pageBrowseType == 3{
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        if (kFrequencyAdsInCells_page > 4 && nativeAdArray.count > 0)
                        {
                            let adcount = row/(kFrequencyAdsInCells_page-1)
                            if(myPageResponse.count > row*2+adcount)
                            {
                                pageInfo = myPageResponse[row*2+adcount] as! NSDictionary
                                cell.contentSelection.tag = row*2+adcount
                                cell.menu.tag = row*2+adcount
                            }
                        }
                        else
                        {
                            if(myPageResponse.count > row*2 )
                            {
                                pageInfo = myPageResponse[row*2] as! NSDictionary
                                cell.contentSelection.tag = row*2
                                cell.menu.tag = row*2
                            }
                        }
                        
                    }else{
                        pageInfo = myPageResponse[row] as! NSDictionary
                        cell.contentSelection.tag = row
                        cell.menu.tag = row
                    }
                }
                
                
                
                //Select Page Action
                cell.contentSelection.addTarget(self, action: #selector(PageViewController.showPage(_:)), for: .touchUpInside)
                // Set MenuAction
                
                
                // Set Page Image
                if let photoId = pageInfo["photo_id"] as? Int{
                    if photoId != 0{
                        cell.contentImage.image = nil
                        //cell.contentImage.backgroundColor = placeholderColor
                        if let url1 = URL(string: pageInfo["image"] as! NSString as String){
                            cell.contentImage.kf.indicatorType = .activity
                            (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            })
                        }
                        
                    }
                    else{
                        cell.contentImage.image = nil
                        cell.contentImage.image =  imageWithImage( UIImage(named: "showPageImage.png")!, scaletoWidth: cell.contentImage.bounds.width)
                    }
                }
                
                
                // Set Page Name
                let name = pageInfo["title"] as? String
                let tempString = name! as NSString
                var value : String
                if tempString.length > 30{
                    value = tempString.substring(to: 27)
                    value += NSLocalizedString("...",  comment: "")
                }else{
                    value = "\(tempString)"
                }
                let owner = pageInfo["like_count"] as? Int
                
                let members = pageInfo["follow_count"] as? Int
                
                let follower = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                cell.contentName.frame = CGRect(x: 0, y: cell.contentImage.bounds.height - 55, width: (cell.contentImage.bounds.width-20), height: 27)
                cell.contentName.text = " \(value)"
                cell.contentName.font = UIFont(name: fontName, size: FONTSIZELarge)
                
                let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                cell.totalMembers.frame = CGRect(x: 4, y: cell.contentImage.bounds.height - 30, width: (cell.contentImage.bounds.width-100), height: 20)
                cell.totalMembers.text = "\(likeCount) "
                
                cell.totalMembers.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.totalMembers.layer.shadowOpacity = 0.0
                
                cell.eventTime.frame = CGRect(x: cell.contentImage.bounds.width - 105, y: cell.contentImage.bounds.height - 30, width: 100, height: 20)
                cell.eventTime.text = "\(follower)"
                cell.eventTime.textAlignment = NSTextAlignment.right
                cell.eventTime.textColor = textColorLight
                
                
                // Set Menu
                cell.menu.isHidden = false
                //cell.menu.addTarget(self, action:"pageMenu:" , forControlEvents: .touchUpInside)
                
                let recognizer = UITapGestureRecognizer(target: self, action:#selector(PageViewController.handleTapped(_:)))
                recognizer.delegate = self
                
                cell.menu.addGestureRecognizer(recognizer)
                
                cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 30)
                
                
                // RHS
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    
                    var pageInfo2:NSDictionary!
                    var adcount = Int()
                    if (kFrequencyAdsInCells_page > 4 && nativeAdArray.count > 0)
                    {
                        adcount = row/(kFrequencyAdsInCells_page-1)
                    }
                    else
                    {
                        adcount = 0
                    }
                    if(myPageResponse.count > (row*2+1+adcount) ){
                        pageInfo2 = myPageResponse[(row*2+1+adcount)] as! NSDictionary
                        cell.cellView2.isHidden = false
                        cell.contentSelection2.isHidden = false
                        cell.contentSelection2.tag = (row*2+1+adcount)
                        cell.menu2.tag = (row*2+1+adcount)
                    }else{
                        cell.cellView2.isHidden = true
                        cell.contentSelection2.isHidden = true
                        return cell
                    }
                    
                    
                    // Select Page Action
                    cell.contentSelection2.addTarget(self, action: #selector(PageViewController.showPage(_:)), for: .touchUpInside)
                    // Set MenuAction
                    // cell.menu2.addTarget(self, action:"pageMenu:" , forControlEvents: .touchUpInside)
                    
                    // Set Page Image
                    
                    
                    if let photoId = pageInfo2["photo_id"] as? Int{
                        
                        if photoId != 0{
                            cell.contentImage2.image = nil
                            cell.contentImage2.backgroundColor = placeholderColor
                            
                            if let url = URL(string: pageInfo2["image"] as! NSString as String){
                                cell.contentImage2.kf.indicatorType = .activity
                                (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                            }
                            
                            
                        }else{
                            cell.contentImage2.image =  imageWithImage( UIImage(named: "showPageImage.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                            
                        }
                    }
                    
                    // Set Page Name
                    let name = pageInfo2["title"] as? String
                    
                    let tempString2 = "\(name!)" as NSString
                    
                    var value2 : String
                    
                    if tempString2.length > 30{
                        value2 = tempString2.substring(to: 27)
                        value2 += NSLocalizedString("...",  comment: "")
                    }else{
                        value2 = "\(tempString2)"
                    }
                    
                    let owner = pageInfo2["like_count"] as? Int
                    
                    let members = pageInfo2["follow_count"] as? Int
                    
                    
                    cell.contentName2.frame = CGRect(x: 0, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 27)
                    cell.contentName2.text = " \(value2)"
                    cell.contentName2.font = UIFont(name: fontName, size: FONTSIZELarge)
                    
                    let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                    cell.totalMembers2.frame = CGRect(x: 4, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage.bounds.width-20), height: 20)
                    cell.totalMembers2.text = " \(likeCount)"
                    
                    
                    
                    let member = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                    // CGRect(x:CGRectGetWidth(cell.contentImage.bounds) - 100, CGRectGetHeight(cell.contentImage.bounds) - 40, 100, 20)
                    cell.eventTime2.frame = CGRect(x: cell.contentImage2.bounds.width - 102, y: cell.contentImage2.bounds.height - 30, width: 100, height: 20)
                    cell.eventTime2.text = "\(member)"
                    cell.eventTime2.textAlignment = NSTextAlignment.right
                    cell.eventTime2.textColor = textColorLight
                    
                    
                    cell.menu2.isHidden = false
                    // cell.menu2.addTarget(self, action:"pageMenu:" , forControlEvents: .touchUpInside)
                    let recognizer = UITapGestureRecognizer(target: self, action:#selector(PageViewController.handleTapped(_:)))
                    recognizer.delegate = self
                    
                    cell.menu2.addGestureRecognizer(recognizer)
                    
                    cell.createdBy2.frame.size.width = cell.cellView2.bounds.width -  (cell.createdBy2.frame.origin.x + 30)
                    
                    
                }
                
                return cell
                
            }
        }
        else if (categoryResponse.count > (indexPath.row - 1)) {
            
            let cell = categoryTableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryBrowseTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            cell.categoryName.isHidden = false
            cell.categoryName1.isHidden = false
            cell.categoryName2.isHidden = false
            cell.cellView.frame.size.height = 100
            cell.cellView1.frame.size.height = 100
            cell.cellView2.frame.size.height = 100
            var index:Int!
            index = (indexPath as NSIndexPath).row * 3
            
            
            if categoryResponse.count > index
            {
                cell.cellView.isHidden = false
                cell.contentSelection.isHidden = false
                cell.categoryImageView.isHidden = false
                cell.categoryName.isHidden = false
                //cell.classifiedImageView.image = nil
                
                if let imageInfo = categoryResponse[index] as? NSDictionary
                {
                    if let imgDic = imageInfo["images"] as? NSDictionary{
                        if imgDic["image_icon"] != nil
                            
                        {
                            if let url = URL(string: imgDic["image_icon"] as! String)
                            {
                                cell.categoryImageView.kf.indicatorType = .activity
                                (cell.categoryImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.categoryImageView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                                
                            }
                        }
                    }
                    // LHS
                    cell.categoryName.text = imageInfo["category_name"] as? String
                    cell.contentSelection.tag = index//imageInfo["category_id"] as! Int
                    cell.contentSelection.addTarget(self, action: #selector(PageViewController.showSubCategory(_:)), for: .touchUpInside)
                    
                }
                
            }
            else
            {
                cell.cellView.isHidden = true
                cell.contentSelection.isHidden = true
                cell.categoryImageView.isHidden = true
                cell.categoryName.isHidden = true
                
                cell.cellView1.isHidden = true
                cell.contentSelection1.isHidden = true
                cell.categoryImageView1.isHidden = true
                cell.categoryName1.isHidden = true
                
                cell.cellView2.isHidden = true
                cell.contentSelection2.isHidden = true
                cell.categoryImageView2.isHidden = true
                cell.categoryName2.isHidden = true
                
            }
            
            if categoryResponse.count > (index + 1)
            {
                cell.cellView1.isHidden = false
                cell.contentSelection1.isHidden = false
                cell.categoryImageView1.isHidden = false
                cell.categoryName1.isHidden = false
                
                //cell.classifiedImageView1.image = nil
                if let imageInfo = categoryResponse[index + 1] as? NSDictionary
                {
                    if let imgDic = imageInfo["images"] as? NSDictionary{
                        if imgDic["image_icon"] != nil
                        {
                            
                            if let url = URL(string: imgDic["image_icon"] as! String)
                            {
                                cell.categoryImageView1.kf.indicatorType = .activity
                                (cell.categoryImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.categoryImageView1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                                
                            }
                        }
                    }
                    
                    cell.categoryName1.text = imageInfo["category_name"] as? String
                    cell.contentSelection1.tag = index+1 //imageInfo["category_id"] as! Int
                    cell.contentSelection1.addTarget(self, action: #selector(PageViewController.showSubCategory(_:)), for: .touchUpInside)
                }
                
            }
            else
            {
                cell.contentSelection1.isHidden = true
                cell.categoryImageView1.isHidden = true
                cell.categoryName1.isHidden = true
                
                cell.contentSelection2.isHidden = true
                cell.categoryImageView2.isHidden = true
                cell.categoryName2.isHidden = true
                
            }
            
            if categoryResponse.count > (index + 2)
            {
                
                cell.cellView2.isHidden = false
                cell.contentSelection2.isHidden = false
                cell.categoryImageView2.isHidden = false
                cell.categoryName2.isHidden = false
                
                //cell.classifiedImageView1.image = nil
                if let imageInfo = categoryResponse[index + 2] as? NSDictionary
                {
                    if let imgDic = imageInfo["images"] as? NSDictionary{
                        
                        if imgDic["image_icon"] != nil
                            
                        {
                            if let url = URL(string: imgDic["image_icon"] as! String)
                            {
                                cell.categoryImageView2.kf.indicatorType = .activity
                                (cell.categoryImageView2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.categoryImageView2.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                                
                            }
                        }
                    }
                    cell.categoryName2.text = imageInfo["category_name"] as? String
                    cell.contentSelection2.tag = index+2 //imageInfo["category_id"] as! Int
                    cell.contentSelection2.addTarget(self, action: #selector(PageViewController.showSubCategory(_:)), for: .touchUpInside)
                }
                
            }
            else
            {
                cell.contentSelection2.isHidden = true
                cell.categoryImageView2.isHidden = true
                cell.categoryName2.isHidden = true
                
            }
            
            return cell
        }
        let cell1 = CustomTableViewCell()
        return cell1
        
    }
   
    // Handle Page Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var row = (indexPath as NSIndexPath).row as Int
        if tableView.tag == 11
        {
            popover.dismiss()
            let feed = myPageResponse[currentCell] as! NSDictionary
            if let feed_menu = feed["menu"] as? NSArray{
                let  menuItem = feed_menu[(indexPath as NSIndexPath).row]
                if let dic = menuItem as? NSDictionary {
                    let menuItem = menuItem as! NSDictionary
                    
                    if dic["name"] as! String == "delete"{
                        
                        // Confirmation Alert for Delete Feed
                        displayAlertWithOtherButton(NSLocalizedString("Delete this Page?", comment: "") ,message: NSLocalizedString("Are you sure that you want to delete this Page? This action cannot be undone.", comment: "") ,otherButton: NSLocalizedString("Delete", comment: ""), otherButtonAction: { () -> () in
                            // Update Feed Gutter Menu
                            self.updatePageMenuAction(menuItem["url"] as! String,feedIndex: self.currentCell)
                            
                            // self.updateFeedMenu(dic["urlParams"] as! NSDictionary, url:dic["url"] as! String,feedIndex: self.currentCell  )
                        })
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    if dic["name"] as! String == "edit"{
                        
                        isCreateOrEdit = false
                        let presentedVC = FormGenerationViewController()
                        presentedVC.formTitle = NSLocalizedString("Edit Page", comment: "")
                        presentedVC.contentType = "Page"
                        presentedVC.url = menuItem["url"] as! String
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let nativationController = UINavigationController(rootViewController: presentedVC)
                        self.present(nativationController, animated:false, completion: nil)
                        
                    }
                    
                    if dic["name"] as! String == "package_payment"{
                        let presentedVC = ExternalWebViewController()
                        presentedVC.url = dic["url"] as! String
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let navigationController = UINavigationController(rootViewController: presentedVC)
                        self.present(navigationController, animated: true, completion: nil)
                    }
                    
                    if dic["name"] as! String == "upgrade_package"{
                        let presentedVC = PackageViewController()
                        presentedVC.contentType = "Page"
                        presentedVC.url = dic["url"] as! String
                        presentedVC.urlParams = dic["urlParams"] as! NSDictionary
                        presentedVC.isUpgradePackageScreen = true
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let nativationController = UINavigationController(rootViewController: presentedVC)
                        self.present(nativationController, animated:false, completion: nil)
                        
                    }
                    
                }
            }
        }
        else  if (kFrequencyAdsInCells_page > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_page) == (kFrequencyAdsInCells_page)-1))
        {
            
            let cell = tableView.cellForRow(at: indexPath) as! NativeAdinstallFeedCell
            cell.selectionStyle = .none
            
            cell.backgroundColor = .clear
            
            if muteVideo == true
            {
                muteVideo = false
                shared1.muteVideosFor(tableView: pageTableView)
                cell.btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                //sender.setTitle("\(unMuteIconIcon)", for: .normal)
            }
            else
            {
                muteVideo = true
                shared1.muteVideosFor(tableView: pageTableView)
                cell.btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                //sender.setTitle("\(muteVideoIcon)", for: .normal)
            }
            print(row)
        }
        else {
            if openMenu{
                openMenu = false
                openMenuSlideOnView(mainView)
                return
            }
            var pageInfo:NSDictionary!
            if pageBrowseType == 0{
                pageInfo = pageResponse[indexPath.row] as! NSDictionary
            }
            else if pageBrowseType == 2{
                pageInfo = popularPageResponse[indexPath.row] as! NSDictionary
            }
            else{
                pageInfo = myPageResponse[indexPath.row] as! NSDictionary
            }
            
            if(pageInfo["allow_to_view"] as! Int == 1){
                let presentedVC = PageDetailViewController()
                presentedVC.subjectId = "\(pageInfo["page_id"]!)"
                presentedVC.subjectType = "sitepage_page"
                presentedVC.isComingFromPage = true
                if let title = pageInfo["title"] as? String {
                    presentedVC.pageTitle = title
                    presentedVC.contentTitle = title
                }
                if let owner = pageInfo["owner_title"] as? String {
                    presentedVC.ownerTitle = owner
                }
                if let categ = pageInfo["category_title"] as? String {
                    presentedVC.categoryTitle = categ
                }
                if let like = pageInfo["like_count"] as? Int {
                    presentedVC.likes = like
                }
                if let desc = pageInfo["body"] as? String {
                    presentedVC.descriptionString = desc
                }
                if let location = pageInfo["location"] as? String {
                    presentedVC.locationInfo = location
                }
                if let url = pageInfo["cover_image"] as? String {
                    presentedVC.coverImageUrl1 = url
                }
                if let url = pageInfo["image_profile"] as? String {
                    presentedVC.pageProfileUrl = url
                }
                navigationController?.pushViewController(presentedVC, animated: true)
            }else{
                showToast(message: NSLocalizedString("You do not have permission to view this private page.", comment: ""), controller: self)
                
            }
        }
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.tag != 2
        {
            
            if scrollView.contentOffset.x>30
            {
                for ob in scrollView.subviews
                {
                    if ob .isKind(of: UIButton.self)
                    {
                        if ob.tag == 103
                        {
                            
                            (ob as! UIButton).alpha = 1.0
                            
                        }
                        
                    }
                }
                
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
        if scrollView.tag != 2
        {
            if NotPlay != 1 {
                self.pausePlayeVideos()
            }
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                // Check for Page Number for Browse Page
                
                if pageBrowseType == 0{
                    
                    if pageBrowseType == 2{
                        
                        //                    if pageTableView.contentOffset.y >= pageTableView.contentSize.height - pageTableView.bounds.size.height{
                        if (!isPageRefresing  && limit*pageNumber < totalItems){
                            if Reachabable.isConnectedToNetwork() {
                                updateScrollFlag = false
                                pageNumber += 1
                                isPageRefresing = true
                                pageTableView.tableFooterView?.isHidden = false
                                //   if searchDic.count == 0{
                                if adsType_page == 2 || adsType_page == 4{
                                    delay(0.1) {
                                        self.checkforAds()
                                    }
                                }
                                browseEntries()
                                // }
                                
                            }
                        }
                        else
                        {
                            pageTableView.tableFooterView?.isHidden = true
                        }
                        
                        //   }
                        
                    }
                    else if pageBrowseType == 0
                    {
                        //                    if categoryTableView.contentOffset.y >= categoryTableView.contentSize.height - categoryTableView.bounds.size.height{
                        if (!isPageRefresing  && limit*pageNumber < totalItems)
                        {
                            if Reachabable.isConnectedToNetwork()
                            {
                                updateScrollFlag = false
                                pageNumber += 1
                                isPageRefresing = true
                                categoryTableView.tableFooterView?.isHidden = false
                                //  if searchDic.count == 0{
                                browseEntries()
                                //  }
                            }
                        }
                        else
                        {
                            categoryTableView.tableFooterView?.isHidden = true
                        }
                        
                        //  }
                        
                    }
                    else if pageBrowseType == 1
                    {
                        //                    if popularPageTableView.contentOffset.y >= popularPageTableView.contentSize.height - popularPageTableView.bounds.size.height{
                        if (!isPageRefresing  && limit*pageNumber < totalItems)
                        {
                            if Reachabable.isConnectedToNetwork()
                            {
                                updateScrollFlag = false
                                pageNumber += 1
                                isPageRefresing = true
                                popularPageTableView.tableFooterView?.isHidden = false
                                //    if searchDic.count == 0{
                                browseEntries()
                                //  }
                            }
                        }
                        else
                        {
                            popularPageTableView.tableFooterView?.isHidden = true
                        }
                        
                        //     }
                        
                    }
                    else{
                        
                        //                    if myPageTableView.contentOffset.y >= myPageTableView.contentSize.height - myPageTableView.bounds.size.height{
                        if (!isPageRefresing  && limit*pageNumber < totalItems)
                        {
                            if Reachabable.isConnectedToNetwork()
                            {
                                updateScrollFlag = false
                                pageNumber += 1
                                isPageRefresing = true
                                myPageTableView.tableFooterView?.isHidden = false
                                //   if searchDic.count == 0{
                                browseEntries()
                                // }
                            }
                        }
                        else
                        {
                            myPageTableView.tableFooterView?.isHidden = true
                        }
                        
                        //    }
                        
                        
                    }
                    
                    
                }
                
            }
        }
        }
        
        
    }
    
    @objc func searchItem(){
        let presentedVC = PageSearchViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
        Formbackup.removeAllObjects()
        let url : String = "sitepages/search-form"
        loadFilter(url)
        
    }
    
    @objc func showFeedFilterOptions(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        
        let alertController = UIActionSheet(title: NSLocalizedString("Choose Option", comment: ""), delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), destructiveButtonTitle: nil, otherButtonTitles:NSLocalizedString("Most Viewed", comment: ""),NSLocalizedString("Most Commented", comment: ""), NSLocalizedString("Most Liked", comment: ""),NSLocalizedString("Alphabetical", comment: ""),NSLocalizedString("Most Reviewed", comment: ""),NSLocalizedString("Most Rated", comment: ""))
        
        alertController.show(in: self.view)
        searchDic.removeAll(keepingCapacity: false)
        
        
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        switch (buttonIndex){
            
            
            
        case 1:
            searchType = "view_count"
            self.showSpinner = true
            feedFilter.setTitle(NSLocalizedString("Most Viewed", comment: ""), for: UIControl.State())
            browseEntries()
            
        case 2:
            searchType = "comment_count"
            feedFilter.setTitle(NSLocalizedString("Most Commented", comment: ""), for: UIControl.State())
            self.showSpinner = true
            browseEntries()
            
            
        case 3:
            
            searchType = "like_count"
            self.showSpinner = true
            feedFilter.setTitle(NSLocalizedString("Most Liked", comment: ""), for: UIControl.State())
            browseEntries()
            
        case 4:
            searchType = "title"
            self.showSpinner = true
            feedFilter.setTitle(NSLocalizedString("Alphabetical", comment: ""), for: UIControl.State())
            browseEntries()
            
            
        case 5:
            
            searchType = "review_count"
            self.showSpinner = true
            feedFilter.setTitle(NSLocalizedString("Most Reviewed", comment: ""), for: UIControl.State())
            browseEntries()
            
        case 6:
            
            searchType = "rating"
            self.showSpinner = true
            feedFilter.setTitle(NSLocalizedString("Most Rated", comment: ""), for: UIControl.State())
            browseEntries()
            
            
            
        default:
            
            print("Default")
            
        }
    }
    
    @objc func showSubCategory(_ sender:UIButton)
    {
        
        var categInfo:NSDictionary!
        
        categInfo = categoryResponse[sender.tag] as! NSDictionary
        var category_title = categInfo["category_name"] as! String
        if let totalItem = categInfo["count"] as? Int{
            if totalItem > 0{
                category_title += " (\(totalItem))"
            }
        }
        let presentedVC = CategoryDetailGridViewController()
        presentedVC .subjectId = categInfo["category_id"] as! Int
        presentedVC .title = category_title
        presentedVC .contentType = "Pages"
        
        
        navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    @objc func handleTapped(_ recognizer: UITapGestureRecognizer) {
        currentCell = (recognizer.view?.tag)!
        let tapPositionOneFingerTap = recognizer.location(in: self.view)
        var count  = 0
        guttermenuoption.removeAll(keepingCapacity: false)
        if openSideMenu{
            openSideMenu = false
            
            return
        }
        let feed = myPageResponse[currentCell] as! NSDictionary
        if let feed_menu = feed["menu"] as? NSArray{
            for menuItem in feed_menu{
                if let dic = menuItem as? NSDictionary {
                    let titleString = dic["label"] as! String
                    count += 1
                    guttermenuoption.append(titleString)
                    let titleStringName = dic["name"] as! String
                    guttermenuoptionname.append(titleStringName)
                }
            }
        }
        let heightOfPopoverTableView : CGFloat = CGFloat(count) * 40.0
        if((view.bounds.height - tapPositionOneFingerTap.y) > heightOfPopoverTableView) {
            let startPoint = CGPoint(x: self.view.frame.width - 20, y: tapPositionOneFingerTap.y )
            self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
            popoverTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: self.view.frame.width, height: heightOfPopoverTableView))
            popoverTableView.delegate = self
            popoverTableView.dataSource = self
            popoverTableView.isScrollEnabled = false
            popoverTableView.tag = 11
            popover.show(popoverTableView, point: startPoint)
            popoverTableView.reloadData()
            
        }
        else{
            let heightt : CGFloat = CGFloat(count) * 40.0
            let startPoint = CGPoint(x: self.view.frame.width - 20, y: tapPositionOneFingerTap.y )
            self.popover = Popover(options: self.popoverOptionsUp, showHandler: nil, dismissHandler: nil)
            popoverTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: self.view.frame.width, height: heightt))
            popoverTableView.delegate = self
            popoverTableView.dataSource = self
            popoverTableView.isScrollEnabled = false
            popoverTableView.tag = 11
            popover.show(popoverTableView, point: startPoint)
            popoverTableView.reloadData()
        }
    }
    
    @objc func goBack(){
        sitevideoPluginEnabled_page = 0
        _ = self.navigationController?.popViewController(animated: false)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delay(0.0) {
            self.shared1.pauseVideosFor(tableView: self.pageTableView)
            self.taskVideoPlayPause?.cancel()
        }
        
        timerFB.invalidate()
        NotificationCenter.default.removeObserver(self)
        globFilterValue = ""
        globalCatg = ""
        tableViewFrameType = ""
        popularPageTableView.tableFooterView?.isHidden = true
        categoryTableView.tableFooterView?.isHidden = true
        pageTableView.tableFooterView?.isHidden = true
        myPageTableView.tableFooterView?.isHidden = true
        filterSearchFormArray.removeAll(keepingCapacity: false)
        
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

extension String {
    
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\+?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        let filtredUnicodeScalars = unicodeScalars.filter{CharacterSet.decimalDigits.contains($0)}
        return String(String.UnicodeScalarView(filtredUnicodeScalars))
    }
    
    func makeACall() {
        if isValid(regex: .phone) {
            if let url = URL(string: "tel://\(self.onlyDigits())"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}
func getThumbnailImageFromVideoUrl(url: URL, completion: @escaping ((_ image: UIImage?)->Void)) {
    DispatchQueue.global().async { //1
        let asset = AVAsset(url: url) //2
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
        avAssetImageGenerator.appliesPreferredTrackTransform = true //4
        let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
        do {
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
            let thumbImage = UIImage(cgImage: cgThumbImage) //7
            DispatchQueue.main.async { //8
                completion(thumbImage) //9
            }
        } catch {
            print(error.localizedDescription) //10
            DispatchQueue.main.async {
                completion(nil) //11
            }
        }
    }
}
