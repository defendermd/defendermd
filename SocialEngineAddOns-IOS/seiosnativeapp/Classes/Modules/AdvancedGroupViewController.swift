//
//  AdvancedGroupViewController.swift
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

var advgroupUpdate = true

class AdvancedGroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, FBNativeAdDelegate, FBNativeAdsManagerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    
    var adSocialContextLabel : UILabel!
    var adSocialSiteLabel : UILabel!
    
    
    let mainView = UIView()
    var browsePage:UIButton!
    var myPage:UIButton!
    var advGroupTableView:UITableView!
    var myAdvGroupTableView:UITableView!
    var categoryTableView:UITableView!
    var groupBrowseType : Int!
    var refresher:UIRefreshControl!
    var refresher1:UIRefreshControl!
    var refresher2:UIRefreshControl!
    var refresher3:UIRefreshControl!
    var browseOrMyPage = true                   // true for Browse advGroup & false for My advGroup
    var advGroupResponse = [AnyObject]()
    var myAdvGroupResponse = [AnyObject]()
    var categoryResponse = [AnyObject]()
    var showSpinner = true                      // not show spinner at pull to refresh
    var pageOption:UIButton!
    let scrollView = UIScrollView()
    var feedFilter : UIButton!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var mytotalItems:Int = 0
    var catTotalItems : Int = 0
    var updateScrollFlag = true
    var isPageRefresing = false                 // For Pagination
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent:Bool!
    var user_id : String!
    var fromTab : Bool! = false
    var countListTitle : String!
    var noContentView : NoContentView!
//    var imageCache = [String:UIImage]()
//    var imageCache2 = [String:UIImage]()
    var customSegmentControl : UISegmentedControl!
    var categResponse = [AnyObject]()
    var searchType = ""
    var popularSearch = ""
    var guttermenuoption = [String]()
    var guttermenuoptionname = [String]()
    var feedMenu : NSArray = []
    var currentCell : Int = 0
    var marqueeHeader : MarqueeLabel!
    
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
    
    var cdAds : ContentSlideshowScrollView!
    var shared1 = VideoPlayerController()
    var taskVideoPlayPause : DispatchWorkItem?
    var cadUrl : UILabel!
    var cadTitle : UILabel!
    var ctaButton : UIButton!
    var videoclickButton = UIButton()
    
    // AdMob Variable
//    var adLoader: GADAdLoader!
    var nativeAdArray = [AnyObject]()
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
    var feedfilterHeight:CGFloat = 0.00001
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    fileprivate var popoverOptionsUp: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    var popoverTableView:UITableView!
    
    var packagesEnabled:Int! = 0
    var timerFB = Timer()
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    var targetSeeAllValue : Int = 1
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
        advgroupUpdate = true
        groupBrowseType = 0
        
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(AdvancedGroupViewController.handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        if showOnlyMyContent == false
        {
            self.navigationItem.setHidesBackButton(true, animated: false)
            self.title = NSLocalizedString("Groups / Communities", comment: "")
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
            createScrollGroupMenu()
            
        }
        
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        advGroupTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight , width: view.bounds.width, height: view.bounds.height-(TOPPADING + tabBarHeight + ButtonHeight)), style: .grouped)
        advGroupTableView.register(GroupTableViewCell.self, forCellReuseIdentifier: "CellThree1")
        advGroupTableView.rowHeight = 255.0
        advGroupTableView.dataSource = self
        advGroupTableView.delegate = self
        advGroupTableView.isOpaque = false
        advGroupTableView.backgroundColor = bgColor
        advGroupTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            advGroupTableView.estimatedRowHeight = 0
            advGroupTableView.estimatedSectionHeaderHeight = 0
            advGroupTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(advGroupTableView)
        
        if showOnlyMyContent == false{
            feedFilter = createButton(CGRect(x: 0,y: 0,width: view.bounds.width, height: ButtonHeight+10),title: NSLocalizedString("See All",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
            feedFilter.isEnabled = true
            feedFilter.backgroundColor = lightBgColor
            feedFilter.titleLabel?.font = UIFont(name: fontName, size: FONTSIZELarge)
            feedFilter.addTarget(self, action: #selector(AdvancedGroupViewController.showFeedFilterOptions(_:)), for: .touchUpInside)
            feedFilter.titleLabel!.numberOfLines = 1;
            feedFilter.titleLabel!.adjustsFontSizeToFitWidth = true;
            advGroupTableView.addSubview(feedFilter)
            let filterIcon = createLabel(CGRect(x: feedFilter.bounds.width - feedFilter.bounds.height, y: 0 ,width: feedFilter.bounds.height ,height: feedFilter.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorMedium)
            filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
            feedFilter.addSubview(filterIcon)
            feedfilterHeight = CGFloat(ButtonHeight + 10.0)
            
        }
        if showOnlyMyContent == true{
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
            advGroupTableView.frame.origin.y = TOPPADING
            advGroupTableView.frame.size.height = view.bounds.height-(TOPPADING + tabBarHeight - 10)
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvancedGroupViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        if logoutUser == true {
            self.title = NSLocalizedString("Groups / Communities", comment: "")
//            advGroupTableView.frame.origin.y = TOPPADING
//            advGroupTableView.frame.size.height = view.bounds.height-(TOPPADING + tabBarHeight - 10)
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvancedGroupViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
        }
        
        myAdvGroupTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight - 4 + tabBarHeight)), style: .grouped)
        myAdvGroupTableView.register(GroupTableViewCell.self, forCellReuseIdentifier: "CellThree1")
        myAdvGroupTableView.rowHeight = 255.0
        myAdvGroupTableView.dataSource = self
        myAdvGroupTableView.delegate = self
        myAdvGroupTableView.isOpaque = false
        myAdvGroupTableView.isHidden = true
        myAdvGroupTableView.backgroundColor = bgColor
        myAdvGroupTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            myAdvGroupTableView.estimatedRowHeight = 0
            myAdvGroupTableView.estimatedSectionHeaderHeight = 0
            myAdvGroupTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(myAdvGroupTableView)
        
        
        categoryTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + feedfilterHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + feedfilterHeight + tabBarHeight)), style: .grouped)
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
        refresher.addTarget(self, action: #selector(AdvancedGroupViewController.refresh), for: UIControl.Event.valueChanged)
        advGroupTableView.addSubview(refresher)
        
        refresher1 = UIRefreshControl()
        refresher1.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher1.addTarget(self, action: #selector(AdvancedGroupViewController.refresh), for: UIControl.Event.valueChanged)
        myAdvGroupTableView.addSubview(refresher1)
        
        refresher2 = UIRefreshControl()
        refresher2.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher2.addTarget(self, action: #selector(AdvancedGroupViewController.refresh), for: UIControl.Event.valueChanged)
        categoryTableView.addSubview(refresher2)
        scrollView.isUserInteractionEnabled = false
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        advGroupTableView.tableFooterView = footerView
        advGroupTableView.tableFooterView?.isHidden = true
        
        let footerView2 = UIView(frame: frameActivityIndicator)
        footerView2.backgroundColor = UIColor.clear
        let activityIndicatorView2 = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView2.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView2.addSubview(activityIndicatorView2)
        activityIndicatorView2.startAnimating()
        myAdvGroupTableView.tableFooterView = footerView2
        myAdvGroupTableView.tableFooterView?.isHidden = true
        
        
        let footerView3 = UIView(frame: frameActivityIndicator)
        footerView3.backgroundColor = UIColor.clear
        let activityIndicatorView3 = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView3.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView3.addSubview(activityIndicatorView3)
        activityIndicatorView3.startAnimating()
        categoryTableView.tableFooterView = footerView3
        categoryTableView.tableFooterView?.isHidden = true
        
        if adsType_advGroup != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(AdvancedGroupViewController.checkforAds),
                                           userInfo: nil,
                                           repeats: false)
        }
        
        
    }
    
    func updateTitle()
    {
        if showOnlyMyContent == true  {
            
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
        }
    }
    
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showAdvGroupContent")
        {
            if  UserDefaults.standard.object(forKey: "showAdvGroupContent") != nil {
                
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showAdvGroupContent")
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
        
        if conditionalProfileForm == ""
        {
            navigationController?.navigationBar.isHidden = false
            setNavigationImage(controller: self)
        }
    }
    
    @objc func appEnteredFromBackground() {
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
    }
    @objc func appMovedToBackground() {
        self.shared1.pauseVideosFor(tableView: self.advGroupTableView)
        self.taskVideoPlayPause?.cancel()
    }
    @objc func videoCompletion() {
        
        shared1.currentVideoContainer()?.playOn = true
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        
    }
    func pausePlayeVideos(){
        shared1.pausePlayeVideosFor(tableView: advGroupTableView)
        
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        if self.targetCheckValue == 1 && self.targetSeeAllValue == 1{
            return 3
            
        }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1{
            return 1
        }
        
        return 0
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        let flatCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(rect: frame)
        }
        //  self.blackScreen.alpha = 0.5
        var coachMark : CoachMark
        coachMark = coachMarksController.helper.makeCoachMark()
        coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        if self.targetCheckValue == 1 && self.targetSeeAllValue == 1{
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
                
                
                
            case 2:
                // skipView.isHidden = true
                var  coachMark2 : CoachMark
                let showView = UIView()
                let origin_x : CGFloat = self.view.bounds.width/2
                let radious : Int = 35
                
                
                coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                    // This will create a circular cutoutPath, perfect for the circular avatar!
                    let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 120 + iphonXTopsafeArea), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                    
                    return circlePath
                    
                }
                coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
                return coachMark2
                
                
                
            default:
                coachMark = coachMarksController.helper.makeCoachMark()
                coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
            }
            
        }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1{
            switch(index) {
                
            case 0:
                // skipView.isHidden = true
                var  coachMark2 : CoachMark
                let showView = UIView()
                let origin_x : CGFloat = self.view.bounds.width/2
                let radious : Int = 35
                
                
                coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                    // This will create a circular cutoutPath, perfect for the circular avatar!
                    let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 120 + iphonXTopsafeArea), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                    
                    return circlePath
                    
                }
                coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
                return coachMark2
                
            default:
                coachMark = coachMarksController.helper.makeCoachMark()
                coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
            }
            
            
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
        if self.targetCheckValue == 1 && self.targetSeeAllValue == 1{
            switch(index) {
            case 0:
                coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Next ", comment: "")
                coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 1/3", comment: "")
                
            case 1:
                coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(createTourText)", comment: ""))"
                coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 2/3", comment: "")
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Next ", comment: "")
                
            case 2:
                coachViews.bodyView.hintLabel.text = NSLocalizedString("Use Filters to search specific results.", comment: "")
                coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 3/3", comment: "")
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
                
            default: break
            }
        }
        
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1{
            switch(index) {
            case 0:
                coachViews.bodyView.hintLabel.text = NSLocalizedString("Use Filters to search specific results.", comment: "")
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
                coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 1/1", comment: "")
            default: break
            }
            
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
        
        if let name = defaults.object(forKey: "showSeeAllPluginAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showSeeAllPluginAppTour") != nil {
                
                self.targetSeeAllValue = name as! Int
                
                
            }
            
        }
        
        if self.targetCheckValue == 1 && self.targetSeeAllValue == 1{
            
            UserDefaults.standard.set(2, forKey: "showPluginAppTour")
            UserDefaults.standard.set(2, forKey: "showSeeAllPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
        
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1{
            
            UserDefaults.standard.set(2, forKey: "showSeeAllPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
    }
    
    
    
    
    // Check for Page Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool)
    {
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
            setNavigationImage(controller: self)
        }
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        if advgroupUpdate {
            pageNumber = 1
            updateScrollFlag = false
            browseEntries()
        }
        
        IsRedirectToProfile()
        
     
    }

    @objc func checkforAds()
    {
        nativeAdArray.removeAll()
        if adsType_advGroup == 1
        {
            if kFrequencyAdsInCells_advgroup > 4 && placementID != ""
            {
                if arrGlobalFacebookAds.count == 0
                {
                    //self.showFacebookAd()
                    FacebookAds.showFacebookAd(viewController: self)
                }
                else
                {
                    for nativeAd in arrGlobalFacebookAds {
                        FacebookAds.createAdView(nativeAd: nativeAd, viewController: self, adArray: &nativeAdArray, frame:fbAdFrame )
                    }
                    if nativeAdArray.count == 10
                    {
                        if groupBrowseType == 0
                        {
                            advGroupTableView.reloadData()
                        }
                        else if groupBrowseType == 2
                        {
                            myAdvGroupTableView.reloadData()
                        }
                    }
                }
                
            }
            
        }
        else if adsType_advGroup == 0
        {
            if kFrequencyAdsInCells_advgroup > 4 && adUnitID != ""
            {
               // showNativeAd()
            }
            
        }
        
        else if adsType_advGroup == 2 {
            checkCommunityAds()
        }
        
    }
    
    func checkCommunityAds()
    {
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            //            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
            
            dic["type"] =  "\(adsType_advGroup)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_advgroup)"
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
                                            self.advGroupTableView.reloadData()
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
                adCallToActionButton.addTarget(self, action: #selector(AdvancedGroupViewController.actionAfterClick(_:)), for: .touchUpInside)
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
                    
                    
                    videoclickButton.addTarget(self, action: #selector(AdvancedGroupViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
                    self.fbView.addSubview(videoclickButton)
                    
                    
                }
                else{
                    imageButton.addTarget(self, action: #selector(AdvancedGroupViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
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
            let presentedVC = ExternalWebViewController()
            presentedVC.url = dic?["cads_url"]! as! String
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated: true, completion: nil)
        }
        
    }
    
    @objc func actionAfterClick(_ sender: UIButton){
        var dictionary = Dictionary<String, String>()
        dictionary["type"] =  "\(adsType_advGroup)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_advgroup)"
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
            if groupBrowseType == 0
            {
                advGroupTableView.reloadData()
            }
            else if groupBrowseType == 2
            {
                myAdvGroupTableView.reloadData()
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
//            if groupBrowseType == 0
//            {
//                self.advGroupTableView.reloadData()
//            }
//            else if groupBrowseType == 2
//            {
//                self.myAdvGroupTableView.reloadData()
//            }
//        }
//    }
//
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
//            if groupBrowseType == 0
//            {
//                self.advGroupTableView.reloadData()
//            }
//            else if groupBrowseType == 2
//            {
//                self.myAdvGroupTableView.reloadData()
//            }
//        }
//    }
    
    func createScrollGroupMenu()
    {
        scrollView.frame = CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: ButtonHeight)
        scrollView.delegate = self
        scrollView.tag = 2;
        
        var menuWidth = CGFloat()
        var origin_x:CGFloat = 0.0
        if logoutUser == false
        {
            var eventMenu = [NSLocalizedString("Groups", comment: ""),NSLocalizedString("Categories", comment: ""),NSLocalizedString("My Groups", comment: "")]

            for i in 100 ..< 103
            {

                menuWidth = CGFloat((view.bounds.width)/3)
                if i == 100
                {
                    pageOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth + 5, height: ButtonHeight), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: true)
                }else{
                    pageOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth + 5, height: ButtonHeight), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: false)
                }
                pageOption.tag = i
                pageOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
                pageOption.addTarget(self, action: #selector(AdvancedGroupViewController.pageSelectOptions(_:)), for: .touchUpInside)
                pageOption.backgroundColor =  UIColor.clear//textColorLight
                
                pageOption.alpha = 1.0
                scrollView.addSubview(pageOption)
                origin_x += menuWidth
                
            }
            
        }
        else
        {
            var eventMenu = ["Groups","Categories"]
            
            for i in 100 ..< 102
            {
                
                if  (UIDevice.current.userInterfaceIdiom == .pad){
                    menuWidth = CGFloat((view.bounds.width)/2-15)
                }else{
                    menuWidth = CGFloat((view.bounds.width)/2-15)//findWidthByText("\(eventMenu[(i-100)])") + 5
                }
                
                if i == 100
                {   pageOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth + 5, height: ButtonHeight), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: true)
                }else{
                    pageOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth + 5, height: ButtonHeight), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: false)
                }
                pageOption.tag = i
                pageOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                pageOption.addTarget(self, action: #selector(AdvancedGroupViewController.pageSelectOptions(_:)), for: .touchUpInside)
                pageOption.backgroundColor =  UIColor.clear//textColorLight
                
                pageOption.alpha = 1.0
                
//                if i==101
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
            showToast(message: network_status_msg, controller: self)
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
        for ob in view.subviews {
            if ob.tag == 1000 {
                ob.removeFromSuperview()
            }
        }
        groupBrowseType = sender.tag - 100
        
//        if logoutUser == false
//        {
            if groupBrowseType == 0
            {
                feedFilter.isHidden = false
                if advGroupResponse.count == 0
                {
                    categoryTableView.isHidden = true
                    myAdvGroupTableView.isHidden = true
                    showSpinner = true
                    pageNumber = 1
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

                    advGroupTableView.isHidden = false
                    categoryTableView.isHidden = true
                    myAdvGroupTableView.isHidden = true
                    advGroupTableView.reloadData()
                    
                }
                
            }
            else if groupBrowseType == 1
            {
                feedFilter.isHidden = true
                if categoryResponse.count == 0
                {
                    advGroupTableView.isHidden = true
                    myAdvGroupTableView.isHidden = true
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
                    advGroupTableView.isHidden = true
                    categoryTableView.isHidden = false
                    myAdvGroupTableView.isHidden = true
                    categoryTableView.reloadData()
                }
                
            }
            else  if groupBrowseType == 2
            {
                feedFilter.isHidden = true
                myAdvGroupTableView.frame = CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(ButtonHeight+TOPPADING+tabBarHeight))
                
                if myAdvGroupResponse.count == 0
                {
                    categoryTableView.isHidden = true
                    advGroupTableView.isHidden = true
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
                    advGroupTableView.isHidden = true
                    myAdvGroupTableView.isHidden = false
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
                if ob.tag >= 100 && ob.tag <= 103
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
                presentedVC.contentType = "sitegroup"
                presentedVC.url = "advancedgroups/packages"
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)

            }
            else
            {
                
                isCreateOrEdit = true
                let presentedVC = FormGenerationViewController()
                presentedVC.formTitle = NSLocalizedString("Create New Group", comment: "")
                presentedVC.contentType = "sitegroup"
                presentedVC.param = [ : ]
                presentedVC.url = "advancedgroups/create"
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)

            }
            
        }
    }
    
    func IsRedirectToProfile()
    {
        if sitevideoPluginEnabled_group != 1 && addvideo_click != 1 {
            if conditionalProfileForm == "BrowsePage"
            {
                conditionalProfileForm = ""
                let presentedVC = AdvancedGroupDetailViewController()
                presentedVC.subjectId = "\(createResponse["group_id"]!)"
                presentedVC.subjectType = "sitegroup_group"
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
        if groupBrowseType == 0{
            pageInfo = advGroupResponse[sender.tag] as! NSDictionary
        }
        else{
            pageInfo = myAdvGroupResponse[sender.tag] as! NSDictionary
        }
        
        if(pageInfo["allow_to_view"] as! Int == 1){
            let presentedVC = AdvancedGroupDetailViewController()
            presentedVC.subjectId = "\(pageInfo["group_id"]!)"
            presentedVC.subjectType = "sitegroup_group"
            navigationController?.pushViewController(presentedVC, animated: true)
        }else{
            showToast(message:NSLocalizedString("You do not have permission to view this private group.", comment: ""), controller: self)
            
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
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        updateAfterAlert = false
                        self.advGroupResponse.removeAll(keepingCapacity: false)
                        self.myAdvGroupResponse.removeAll(keepingCapacity: false)
                        self.browseEntries()
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
                }
                else
                {
                    updateAfterAlert = true
                }
            }
            if (showSpinner)
            {
            //    spinner.center = view.center
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
          //      activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            
            switch(groupBrowseType)
            {
            case 0:
                
                path = "advancedgroups"
                if Locationdic != nil
                {
                    let defaults = UserDefaults.standard
                    
                    if let loc = defaults.string(forKey: "Location")
                    {
                        
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id),"restapilocation" : loc,"type" : "userPages" , "orderby": "\(searchType)"]
                        }else{
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","restapilocation": loc , "orderby": "\(searchType)"]
                        }
                    }
                    else
                    {
                        
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id),"restapilocation": defaultlocation,"type" : "userPages" , "orderby": "\(searchType)"]
                        }else{
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","restapilocation": defaultlocation , "orderby": "\(searchType)"]
                        }
                        
                        categoryTableView.isHidden = true
                        myAdvGroupTableView.isHidden = true
                    }
                }
                else
                {
                    if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id),"type" : "userPages" , "orderby": "\(searchType)"]
                    }else{
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)" , "orderby": "\(searchType)"]
                    }
                    categoryTableView.isHidden = true
                    myAdvGroupTableView.isHidden = true
                    
                }
                
            case 1:
                
                path = "advancedgroups/category"
                parameters = ["page":"\(pageNumber)","limit": "\(limit)","showCount": "1"]
                advGroupTableView.isHidden = true
                myAdvGroupTableView.isHidden = true
                
            case 2:
                
                if logoutUser == false
                {
                    path = "advancedgroups/manage"
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
                    // popularPageTableView.isHidden = true
                    categoryTableView.isHidden = true
                    advGroupTableView.isHidden = true
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
                    
                    self.updateScrollFlag = true
                    self.scrollView.isUserInteractionEnabled = true
                    if self.showSpinner
                    {
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false

                    if msg
                    {
                        
                        if self.groupBrowseType==1
                        {
                            self.advGroupTableView.isHidden = true
                            self.categoryTableView.isHidden = false
                            self.myAdvGroupTableView.isHidden = true
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
                                
                                if response["totalItemCount"] != nil
                                {
                                    self.catTotalItems = response["totalItemCount"] as! Int
                                }
                                if self.showOnlyMyContent == false
                                {
                                    if (response["canCreate"] as! Bool == true)
                                    {
                                        
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvancedGroupViewController.searchItem))
                                        let addPage = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(AdvancedGroupViewController.addNewPage))
                                        self.navigationItem.setRightBarButtonItems([addPage,searchItem], animated: true)
                                        searchItem.tintColor = textColorPrime
                                        addPage.tintColor = textColorPrime
                                        
                                    }
                                }
                            }
                            self.isPageRefresing = false
                            if self.categoryResponse.count == 0
                            {
                                self.noContentView = NoContentView()
                                self.noContentView.tag = 1000
                                self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                                self.mainView.addSubview(self.noContentView)
                                self.noContentView.isHidden = false
                                self.noContentView.button.layer.borderWidth = 1
                                self.noContentView.button.layer.borderColor = buttonColor.cgColor
                                self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal)
                                self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
                                self.noContentView.button.addTarget(self, action: #selector(AdvancedGroupViewController.addNewPage), for: .touchUpInside)
                                
                            }
                            self.categoryTableView.reloadData()
                            
                        }
                        else if self.groupBrowseType == 2
                        {
                            if logoutUser == false
                            {
                                self.advGroupTableView.isHidden = true
                                self.categoryTableView.isHidden = true
                                self.myAdvGroupTableView.isHidden = false
                                if self.pageNumber == 1
                                {
                                    self.myAdvGroupResponse.removeAll(keepingCapacity: false)
                                }
                                
                                if succeeded["message"] != nil
                                {
                                    showToast(message: succeeded["message"] as! String, controller: self)
                                }
                                
                                
                                if let response = succeeded["body"] as? NSDictionary
                                {
                                    if response["response"] != nil
                                    {
                                        if let myPageArr = response["response"] as? NSArray
                                        {
                                            self.myAdvGroupResponse = self.myAdvGroupResponse + (myPageArr as [AnyObject])
                                        }
                                    }
                                    
                                    if response["packagesEnabled"] != nil
                                    {
                                        self.packagesEnabled = response["packagesEnabled"] as! Int
                                    }
                                    
                                    if response["getTotalItemCount"] != nil
                                    {
                                        self.mytotalItems = response["getTotalItemCount"] as! Int
                                    }
                                    if self.showOnlyMyContent == false
                                    {
                                        if (response["canCreate"] as! Bool == true)
                                        {
                                            
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvancedGroupViewController.searchItem))
                                            let addPage = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(AdvancedGroupViewController.addNewPage))
                                            self.navigationItem.setRightBarButtonItems([addPage,searchItem], animated: true)
                                            searchItem.tintColor = textColorPrime
                                            addPage.tintColor = textColorPrime
                                            
                                            
                                        }
                                        else
                                        {
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvancedGroupViewController.searchItem))
                                            self.navigationItem.rightBarButtonItem = searchItem
                                            searchItem.tintColor = textColorPrime
                                            
                                            
                                        }
                                    }
                                }
                                
                                self.isPageRefresing = false
                                if self.myAdvGroupResponse.count == 0
                                {
                                    self.noContentView = NoContentView()
                                    self.noContentView.tag = 1000
                                    self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                                    self.mainView.addSubview(self.noContentView)
                                    self.noContentView.isHidden = false
                                    self.noContentView.button.layer.borderWidth = 1
                                    self.noContentView.button.layer.borderColor = buttonColor.cgColor
                                    self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal)
                                    self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
                                    self.noContentView.button.addTarget(self, action: #selector(AdvancedGroupViewController.addNewPage), for: .touchUpInside)
                                    
                                }
                                self.myAdvGroupTableView.reloadData()
                            }
                            
                        }
                        else
                        {
                            self.advGroupTableView.isHidden = false
                            self.categoryTableView.isHidden = true
                            self.myAdvGroupTableView.isHidden = true
                            if self.pageNumber == 1
                            {
                                self.advGroupResponse.removeAll(keepingCapacity: false)
                            }
                            
                            if succeeded["message"] != nil
                            {
                                showToast(message: succeeded["message"] as! String, controller: self)
                            }
                            
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["response"] != nil
                                {
                                    if let page = response["response"] as? NSArray
                                    {
                                        self.advGroupResponse = self.advGroupResponse + (page as [AnyObject])
                                    }
                                }
                                
                                if response["packagesEnabled"] != nil
                                {
                                    self.packagesEnabled = response["packagesEnabled"] as! Int
                                }
                                
                                if response["totalItemCount"] != nil
                                {
                                    self.totalItems = response["totalItemCount"] as! Int
                                    self.countListTitle = "Pages " + "(" + "\(self.totalItems)" + ")" + " : " + self.username
                                    self.updateTitle()
                                }
                                if self.showOnlyMyContent == false
                                {
                                    if (response["canCreate"] as! Bool == true)
                                    {
                                        
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvancedGroupViewController.searchItem))
                                        let addPage = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(AdvancedGroupViewController.addNewPage))
                                        self.navigationItem.setRightBarButtonItems([addPage,searchItem], animated: true)
                                        searchItem.tintColor = textColorPrime
                                        addPage.tintColor = textColorPrime
                                        
                                       self.showAppTour()
                                        
                                        
                                        
                                    }
                                    else
                                    {
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvancedGroupViewController.searchItem))
                                        self.navigationItem.rightBarButtonItem = searchItem
                                        searchItem.tintColor = textColorPrime
                                        
                                    }
                                    
                                    
                                    
                                }
                            }
                            
                            self.isPageRefresing = false
                            if self.advGroupResponse.count == 0
                            {
                                self.noContentView = NoContentView()
                                self.noContentView.tag = 1000
                                self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                                self.mainView.addSubview(self.noContentView)
                                self.noContentView.isHidden = false
                                self.noContentView.button.layer.borderWidth = 1
                                self.noContentView.button.layer.borderColor = buttonColor.cgColor
                                self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal)
                                self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
                                self.noContentView.button.addTarget(self, action: #selector(AdvancedGroupViewController.addNewPage), for: .touchUpInside)
                                
                            }
                            if NotPlay != 1 {
                                self.pausePlayeVideos()
                            }
                            self.advGroupTableView.reloadData()
                            
                        }
                        
                    }
                    else
                    {
                        self.refresher.endRefreshing()
                        if succeeded["message"] != nil
                        {
                            self.scrollView.isUserInteractionEnabled = true
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                    }
                    
                })
            }
        }
        else
        {
            // No Internet Connection Message
            self.scrollView.isUserInteractionEnabled = true
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if tableView.tag == 11{
            return 0.00001
        }
        else{
            return 0
        }
    }
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if groupBrowseType == 0 {
            return feedfilterHeight
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
        
        var rowcount = Int()
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            rowcount = 2*(kFrequencyAdsInCells_advgroup-1)
        }
        else
        {
            rowcount = (kFrequencyAdsInCells_advgroup-1)
        }
        
        if groupBrowseType == 0
        {
            if nativeAdArray.count > 9
            {
                if advGroupResponse.count > rowcount
                {
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        let b = Int(ceil(Float(advGroupResponse.count)/2))
                        adsCount = b/(kFrequencyAdsInCells_advgroup-1)
                        if adsCount > 1 || advGroupResponse.count%2 != 0
                        {
                            adsCount = adsCount/2
                        }
                        let Totalrowcount = adsCount+b
                        if b%(kFrequencyAdsInCells_advgroup-1) == 0 && advGroupResponse.count % 2 != 0
                        {
                            if adsCount%2 != 0
                            {
                                return Totalrowcount - 1
                            }
                        }
                        else if advGroupResponse.count % 2 != 0 && adsCount % 2 == 0
                        {
                            
                            return Totalrowcount - 1
                        }
                        return Totalrowcount
                    }
                    else
                    {
                        let b = advGroupResponse.count
                        adsCount = b/(kFrequencyAdsInCells_advgroup-1)
                        let Totalrowcount = adsCount+b
                        if Totalrowcount % kFrequencyAdsInCells_advgroup == 0
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
                return Int(ceil(Float(advGroupResponse.count)/2))
            }
            
            return advGroupResponse.count
            
            
        }
        else if groupBrowseType == 1
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return Int(ceil(Float(categoryResponse.count)/4))
            }
            return Int(ceil(Float(categoryResponse.count)/3))
            
            
            
        }
        else if groupBrowseType == 2
        {
            if tableView.tag == 11
            {
                //print("check1")
                //print(guttermenuoption.count)
                return guttermenuoption.count
            }
            else
            {
                
                if nativeAdArray.count > 9
                {
                    if myAdvGroupResponse.count > 0
                    {
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            let b = Int(ceil(Float(myAdvGroupResponse.count)/2))
                            adsCount = b/(kFrequencyAdsInCells_advgroup-1)
                            if adsCount > 1 || myAdvGroupResponse.count%2 != 0
                            {
                                adsCount = adsCount/2
                            }
                            let Totalrowcount = adsCount+b
                            if b%(kFrequencyAdsInCells_advgroup-1) == 0 && myAdvGroupResponse.count % 2 != 0
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
                            let b = myAdvGroupResponse.count
                            adsCount = b/(kFrequencyAdsInCells_advgroup-1)
                            let c = adsCount+b
                            return c
                        }
                    }
                    
                    
                }
                
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    return Int(ceil(Float(myAdvGroupResponse.count)/2))
                }
                return myAdvGroupResponse.count
                
            }
        }
        else{
        return myAdvGroupResponse.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = (indexPath as NSIndexPath).row as Int
        if tableView.tag == 11
        {
            return 40
        }
        
        if groupBrowseType == 1 {
            return 100
        }
        else{

            if (kFrequencyAdsInCells_advgroup > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advgroup) == (kFrequencyAdsInCells_advgroup)-1)) && groupBrowseType == 0
            {
                if adsType_advGroup == 2
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

    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if adsType_advGroup == 2{
            if tableView.tag != 11
            {
                
                let row = indexPath.row as Int
                
                if  (kFrequencyAdsInCells_advgroup > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advgroup) == (kFrequencyAdsInCells_advgroup)-1))
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
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if adsType_advGroup == 2{
            //        let height = NSNumber(value: Float(cell.frame.size.height))
            //        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
            // cell.contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
            var row = indexPath.row as Int
            if (kFrequencyAdsInCells_advgroup > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advgroup) == (kFrequencyAdsInCells_advgroup)-1))
            {
                //            displyedAdsCount = (row / kFrequencyAdsInCells_feeds)
                //            row = row - displyedAdsCount
                
                if let cell1 = cell as? NativeGroupCell
                {
                    var Adcount: Int = 0
                    Adcount = row/(kFrequencyAdsInCells_advgroup-1)
                    
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
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var row = (indexPath as NSIndexPath).row as Int
        if tableView.tag == 11
        {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            cell.textLabel?.text = guttermenuoption[(indexPath as NSIndexPath).row]
            return cell
            
        }

        let totalRows = advGroupResponse.count + adsCount
        let totalRows1 = myAdvGroupResponse.count + adsCount
        if (groupBrowseType == 0 && totalRows > (indexPath.row - 1 - adsCount))  {
            
            if (kFrequencyAdsInCells_advgroup > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advgroup) == (kFrequencyAdsInCells_advgroup)-1))
            {
                advGroupTableView.register(NativeGroupCell.self, forCellReuseIdentifier: "Cell1")
                let cell = advGroupTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeGroupCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = tableViewBgColor
                var Adcount: Int = 0
                Adcount = row/(kFrequencyAdsInCells_advgroup-1)
                
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
                    if adsType_advGroup == 2{
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
                    
                    
//                    let view = nativeAdArray[Adcount]
//
//                    cell.cellView.addSubview(view as! UIView)
//                    if adsType_advGroup == 1 {
//                        cell.cellView.frame.origin.y = 5
//                        adsCellheight = cell.cellView.frame.size.height + 10
//                    }
//                    else {
//                         adsCellheight = cell.cellView.frame.size.height + 5
//                    }
//                    cell.cellView.frame.size.height = view.frame.size.height
                    
                    
                    let view = nativeAdArray[Adcount]
                    cell.cellView.addSubview(view as! UIView)
                    
                    cell.cellView.frame.size.height = view.frame.size.height
                    adsCellheight = cell.cellView.frame.size.height + 5
                   
                }
                
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    
                    var pageInfo2:NSDictionary!
                    let adcount = row/kFrequencyAdsInCells_advgroup
                    if(advGroupResponse.count > (row*2-adcount) ){
                        pageInfo2 = advGroupResponse[(row*2-adcount)] as! NSDictionary
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
                    cell.contentSelection2.addTarget(self, action: #selector(AdvancedGroupViewController.showPage(_:)), for: .touchUpInside)
                    
                    let recognizer = UITapGestureRecognizer(target: self, action:#selector(AdvancedGroupViewController.handleTapped(_:)))
                    recognizer.delegate = self
                    
                    cell.menu2.addGestureRecognizer(recognizer)
                    
                    // Set Page Image
                    
                    if let photoId = pageInfo2["photo_id"] as? Int{
                        
                        if photoId != 0{
                            
                            let url1 = NSURL(string: pageInfo2["image"] as! NSString as String)
                            cell.contentImage2.backgroundColor = placeholderColor
                            cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage2.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                           
                            
                        } else {
                            cell.contentImage2.image = nil
                            cell.contentImage2.image = imageWithImage(UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                            
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
                    
                    var ownerName : String = ""// = (pageInfo2["owner_title"] as? String)!
                    
                    if let location = pageInfo2["location"] as? String
                    {
                        ownerName = location
                    }
                    
                    var OwnerTitle : String
                    let tempStringOwner = ownerName as NSString
                    if tempStringOwner.length > 30{
                        OwnerTitle = tempStringOwner.substring(to: 27)
                        OwnerTitle += NSLocalizedString("...",  comment: "")
                    }else{
                        OwnerTitle = "\(tempStringOwner)"
                    }
                    
                    if pageInfo2["featured"] != nil && pageInfo2["featured"] as! Int == 1{
                        cell.featuredLabel2.frame = CGRect(x:0, y:0, width:66, height:20)
                        cell.featuredLabel2.isHidden = false
                    }else{
                        cell.featuredLabel2.isHidden = true
                    }
                    
                    if pageInfo2["sponsored"] != nil && pageInfo2["sponsored"] as! Int == 1{
                        
                        cell.sponsoredLabel2.frame = CGRect(x:cell.contentImage2.bounds.width - 70, y:0, width:70, height:20)
                        cell.sponsoredLabel2.isHidden = false
                    }else{
                        cell.sponsoredLabel2.isHidden = true
                    }
                    
                    
                    cell.contentName2.frame = CGRect(x: 8, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 27)
                    cell.contentName2.text = " \(value2)"
                    cell.contentName2.font = UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)//UIFont(name: fontName, size: FONTSIZENormal)
                    
                    cell.ownerLabel2.frame =  CGRect(x: 11, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage2.bounds.width-140), height: 22)
                    if ownerName != ""{
                         cell.ownerLabel2.text = "\(locationIcon) \(OwnerTitle)"
                    }
                    cell.ownerLabel2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZENormal)
                    
                    let member = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                    
                    
                    let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                    cell.totalMembers2.frame = CGRect(x: (cell.contentImage2.bounds.width-130), y: cell.contentImage2.bounds.height - 30, width: 120, height: 20)
                    cell.totalMembers2.text = "\(likeCount)  \(member)"
                    cell.totalMembers2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZESmall)
                    cell.totalMembers2.textAlignment = NSTextAlignment.right
                    
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
            else
            {
                
                if kFrequencyAdsInCells_advgroup > 4 && nativeAdArray.count > 0
                {
                    row = row - (row / kFrequencyAdsInCells_advgroup)
                }
                let cell = advGroupTableView.dequeueReusableCell(withIdentifier: "CellThree1") as! GroupTableViewCell
                
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = bgColor
                
                var pageInfo:NSDictionary!
                if groupBrowseType == 0{
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        if (kFrequencyAdsInCells_advgroup > 4 && nativeAdArray.count > 0)
                        {
                            let adcount = row/(kFrequencyAdsInCells_advgroup-1)
                            if(advGroupResponse.count > row*2+adcount)
                            {
                                pageInfo = advGroupResponse[row*2+adcount] as! NSDictionary
                                cell.contentSelection.tag = row*2+adcount
                                cell.menu.tag = row*2+adcount
                            }
                        }
                        else
                        {
                            if(advGroupResponse.count > row*2 )
                            {
                                pageInfo = advGroupResponse[row*2] as! NSDictionary
                                cell.contentSelection.tag = row*2
                                cell.menu.tag = row*2
                            }
                        }
                    }
                    else
                    {
                        pageInfo = advGroupResponse[row] as! NSDictionary
                        cell.contentSelection.tag = row
                        cell.menu.tag = row
                    }
                }
                
                //Select Page Action
                cell.contentSelection.addTarget(self, action: #selector(AdvancedGroupViewController.showPage(_:)), for: .touchUpInside)
                // Set MenuAction
                // Set Page Image
                
                if let photoId = pageInfo["photo_id"] as? Int{
                    
                    if photoId != 0{
                        
                        let url1 = NSURL(string: pageInfo["image"] as! NSString as String)
                        cell.contentImage.backgroundColor = placeholderColor
                         cell.contentImage.kf.indicatorType = .activity
                        (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                        
                    } else {
                        cell.contentImage.image = nil
                        cell.contentImage.image = imageWithImage(UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                        
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
                if tempString.length > 60{
                    value = tempString.substring(to: 57)
                    value += NSLocalizedString("...",  comment: "")
                }else{
                    value = "\(tempString)"
                }
                let owner = pageInfo["like_count"] as? Int
                
                let members = pageInfo["follow_count"] as? Int
                
                
                var ownerName : String = ""//(pageInfo["owner_title"] as? String)!
                if let location = pageInfo["location"] as? String
                {
                    ownerName = location
                }
                
                var OwnerTitle : String
                let tempStringOwner = ownerName as NSString
                if tempStringOwner.length > 30{
                    OwnerTitle = tempStringOwner.substring(to: 27)
                    OwnerTitle += NSLocalizedString("...",  comment: "")
                }else{
                    OwnerTitle = "\(tempStringOwner)"
                }
                if pageInfo["featured"] != nil && pageInfo["featured"] as! Int == 1{
                    cell.featuredLabel.frame = CGRect(x:0, y:0, width:66, height:20)
                    cell.featuredLabel.isHidden = false
                }else{
                    cell.featuredLabel.isHidden = true
                }
                
                if pageInfo["sponsored"] != nil && pageInfo["sponsored"] as! Int == 1{
                    
                    cell.sponsoredLabel.frame = CGRect(x:cell.contentImage.bounds.width - 70, y:0, width:70, height:20)
                    cell.sponsoredLabel.isHidden = false
                }else{
                    cell.sponsoredLabel.isHidden = true
                }
                
                
                let follower = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                cell.contentName.frame = CGRect(x: 8, y: cell.contentImage.bounds.height - 60, width: (cell.contentImage.bounds.width-20), height: 27)
                cell.contentName.text = " \(value)"
                cell.contentName.font = UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)//UIFont(name: fontName, size: FONTSIZENormal)
                
                
                cell.ownerLabel.frame =  CGRect(x: 11, y: cell.contentImage.bounds.height - 30, width: (cell.contentImage.bounds.width-155), height: 20)
                if ownerName != ""{
                    cell.ownerLabel.text = "\(locationIcon) \(OwnerTitle)"
                }
                cell.ownerLabel.layer.shadowOpacity = 0.0
                cell.ownerLabel.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZENormal)
                
                
                let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                cell.totalMembers.frame = CGRect(x: (cell.contentImage.bounds.width-140), y: cell.contentImage.bounds.height - 30, width: 130, height: 20)
                cell.totalMembers.text = "\(likeCount)  \(follower)"
                cell.totalMembers.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZESmall)
                cell.totalMembers.textAlignment = NSTextAlignment.right
                cell.totalMembers.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.totalMembers.layer.shadowOpacity = 0.0
                
                
                // Set Menu
                if groupBrowseType != 3 {
                    cell.menu.isHidden = true
                    // cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 10)
                }else{
                    cell.menu.isHidden = false
                    
                    let recognizer = UITapGestureRecognizer(target: self, action:#selector(AdvancedGroupViewController.handleTapped(_:)))
                    recognizer.delegate = self
                    
                    cell.menu.addGestureRecognizer(recognizer)
                    
                }
                
                // RHS
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    
                    var pageInfo2:NSDictionary!
                    var adcount = Int()
                    if (kFrequencyAdsInCells_advgroup > 4 && nativeAdArray.count > 0)
                    {
                        adcount = row/(kFrequencyAdsInCells_advgroup-1)
                    }
                    else
                    {
                        adcount = 0
                    }
                    
                    if(advGroupResponse.count > (row*2+1+adcount) ){
                        pageInfo2 = advGroupResponse[(row*2+1+adcount)] as! NSDictionary
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
                    cell.contentSelection2.addTarget(self, action: #selector(AdvancedGroupViewController.showPage(_:)), for: .touchUpInside)
                    // Set MenuAction
                    
                    let recognizer = UITapGestureRecognizer(target: self, action:#selector(AdvancedGroupViewController.handleTapped(_:)))
                    recognizer.delegate = self
                    
                    cell.menu2.addGestureRecognizer(recognizer)
                    
                    // Set Page Image
                    
                    if let photoId = pageInfo2["photo_id"] as? Int{
                        
                        if photoId != 0{
                            
                            let url1 = NSURL(string: pageInfo2["image"] as! NSString as String)
                            cell.contentImage2.backgroundColor = placeholderColor
                             cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage2.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                            
                        } else {
                            cell.contentImage2.image = nil
                            cell.contentImage2.image = imageWithImage(UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                            
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
                    
                    var ownerName : String = ""//(pageInfo2["owner_title"] as? String)!
                    if let location = pageInfo2["location"] as? String
                    {
                        ownerName = location
                    }
                    var OwnerTitle : String
                    let tempStringOwner = ownerName as NSString
                    if tempStringOwner.length > 30{
                        OwnerTitle = tempStringOwner.substring(to: 27)
                        OwnerTitle += NSLocalizedString("...",  comment: "")
                    }else{
                        OwnerTitle = "\(tempStringOwner)"
                    }
                    
                    
                    let owner = pageInfo2["like_count"] as? Int
                    
                    let members = pageInfo2["follow_count"] as? Int
                    
                    if pageInfo2["featured"] != nil && pageInfo2["featured"] as! Int == 1{
                        cell.featuredLabel2.frame = CGRect(x:0, y:0, width:66, height:20)
                        cell.featuredLabel2.isHidden = false
                    }else{
                        cell.featuredLabel2.isHidden = true
                    }
                    
                    if pageInfo2["sponsored"] != nil && pageInfo2["sponsored"] as! Int == 1{
                        
                        cell.sponsoredLabel2.frame = CGRect(x:cell.contentImage.bounds.width - 70, y:0, width:70, height:20)
                        cell.sponsoredLabel2.isHidden = false
                    }else{
                        cell.sponsoredLabel2.isHidden = true
                    }
                    
                    
                    
                    cell.contentName2.frame = CGRect(x: 8, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 22)
                    cell.contentName2.text = " \(value2)"
                    cell.contentName2.font = UIFont(name: fontName, size: FONTSIZEExtraLarge)
                    
                    cell.ownerLabel2.frame =  CGRect(x: 11, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage2.bounds.width-140), height: 22)
                    if ownerName != "" {
                        cell.ownerLabel2.text = "\(locationIcon) \(OwnerTitle)"
                    }
                    cell.ownerLabel2.layer.shadowOpacity = 0.0
                    cell.ownerLabel2.font = UIFont(name: fontName, size: FONTSIZENormal)
                    
                    let member = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                    
                    
                    let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                    cell.totalMembers2.frame = CGRect(x: (cell.contentImage2.bounds.width-130), y: cell.contentImage2.bounds.height - 30, width: 120, height: 20)
                    cell.totalMembers2.text = "\(likeCount)  \(member)"
                    cell.totalMembers2.font = UIFont(name: fontName, size: FONTSIZESmall)
                    cell.totalMembers2.textAlignment = NSTextAlignment.right
                    
                    
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
        else if (groupBrowseType == 2 && totalRows1 > (indexPath.row - 1 - adsCount)){
            
            
            if (kFrequencyAdsInCells_advgroup > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advgroup) == (kFrequencyAdsInCells_advgroup)-1))
            {  // or 9 == if you don't want the first cell to be an ad!
                myAdvGroupTableView.register(NativeGroupCell.self, forCellReuseIdentifier: "Cell1")
                let cell = myAdvGroupTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeGroupCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = tableViewBgColor
                var Adcount: Int = 0
                Adcount = row/(kFrequencyAdsInCells_advgroup-1)
                
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
                    let adcount = row/kFrequencyAdsInCells_advgroup
                    if(myAdvGroupResponse.count > (row*2-adcount) ){
                        pageInfo2 = myAdvGroupResponse[(row*2-adcount)] as! NSDictionary
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
                    cell.contentSelection2.addTarget(self, action: #selector(AdvancedGroupViewController.showPage(_:)), for: .touchUpInside)
                    // Set Page Image
                    
                    if let photoId = pageInfo2["photo_id"] as? Int{
                        
                        if photoId != 0{
                            
                            let url1 = NSURL(string: pageInfo2["image"] as! NSString as String)
                            cell.contentImage2.backgroundColor = placeholderColor
                             cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage2.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                            
                        } else {
                            cell.contentImage2.image = nil
                            cell.contentImage2.image = imageWithImage(UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                            
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
                    
                    var ownerName : String = ""//(pageInfo2["owner_title"] as? String)!
                    if let location = pageInfo2["location"] as? String
                    {
                        ownerName = location
                    }
                    
                    var OwnerTitle : String
                    let tempStringOwner = ownerName as NSString
                    if tempStringOwner.length > 30{
                        OwnerTitle = tempStringOwner.substring(to: 27)
                        OwnerTitle += NSLocalizedString("...",  comment: "")
                    }else{
                        OwnerTitle = "\(tempStringOwner)"
                    }
                    
                    
                    cell.contentName2.frame = CGRect(x: 8, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 22)
                    cell.contentName2.text = " \(value2)"
                    cell.contentName2.font = UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)//UIFont(name: fontName, size: FONTSIZENormal)
                    
                    cell.ownerLabel2.frame =  CGRect(x: 11, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage2.bounds.width-140), height: 22)
                    if ownerName != "" {
                        cell.ownerLabel2.text = "\(locationIcon) \(OwnerTitle)"
                    }
                    cell.ownerLabel2.layer.shadowOpacity = 0.0
                    cell.ownerLabel2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZENormal)
                    
                    let member = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                    
                    
                    let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                    cell.totalMembers2.frame = CGRect(x: (cell.contentImage2.bounds.width-130), y: cell.contentImage2.bounds.height - 30, width: 120, height: 20)
                    cell.totalMembers2.text = "\(likeCount)  \(member)"
                    cell.totalMembers2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZESmall)
                    cell.totalMembers2.textAlignment = NSTextAlignment.right
                    
                    
                    
                    cell.menu2.isHidden = false
                    let recognizer = UITapGestureRecognizer(target: self, action:#selector(AdvancedGroupViewController.handleTapped(_:)))
                    recognizer.delegate = self
                    
                    cell.menu2.addGestureRecognizer(recognizer)
                    
                    cell.createdBy2.frame.size.width = cell.cellView2.bounds.width -  (cell.createdBy2.frame.origin.x + 30)
                    
                    
                }
                return cell
                
            }
            else
            {
                
                if kFrequencyAdsInCells_advgroup > 4 && nativeAdArray.count > 9
                {
                    row = row - (row / kFrequencyAdsInCells_advgroup)
                }
                
                let cell = myAdvGroupTableView.dequeueReusableCell(withIdentifier: "CellThree1") as! GroupTableViewCell
                
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = bgColor
                
                var pageInfo:NSDictionary!
                
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    if (kFrequencyAdsInCells_advgroup > 4 && nativeAdArray.count > 9)
                    {
                        let adcount = row/(kFrequencyAdsInCells_advgroup-1)
                        if(myAdvGroupResponse.count > row*2+adcount)
                        {
                            pageInfo = myAdvGroupResponse[row*2+adcount] as! NSDictionary
                            cell.contentSelection.tag = row*2+adcount
                            cell.menu.tag = row*2+adcount
                        }
                    }
                    else
                    {
                        if(myAdvGroupResponse.count > row*2 )
                        {
                            pageInfo = myAdvGroupResponse[row*2] as! NSDictionary
                            cell.contentSelection.tag = row*2
                            cell.menu.tag = row*2
                        }
                    }
                    
                }
                else{
                    pageInfo = myAdvGroupResponse[row] as! NSDictionary
                    cell.contentSelection.tag = row
                    cell.menu.tag = row
                }
                
                
                //Select Page Action
                cell.contentSelection.addTarget(self, action: #selector(AdvancedGroupViewController.showPage(_:)), for: .touchUpInside)
                
                // Set Page Image
                if let photoId = pageInfo["photo_id"] as? Int{
                    
                    if photoId != 0{
                        
                        let url1 = NSURL(string: pageInfo["image"] as! NSString as String)
                        cell.contentImage.backgroundColor = placeholderColor
                         cell.contentImage.kf.indicatorType = .activity
                        (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                        
                    } else {
                        cell.contentImage.image = nil
                        cell.contentImage.image = imageWithImage(UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                        
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
                
                var ownerName : String = ""//(pageInfo["owner_title"] as? String)!
                if let location = pageInfo["location"] as? String
                {
                    ownerName = location
                }
                
                var OwnerTitle : String
                let tempStringOwner = ownerName as NSString
                if tempStringOwner.length > 30{
                    OwnerTitle = tempStringOwner.substring(to: 27)
                    OwnerTitle += NSLocalizedString("...",  comment: "")
                }else{
                    OwnerTitle = "\(tempStringOwner)"
                }
                
                
                
                let follower = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                cell.contentName.frame = CGRect(x: 8, y: cell.contentImage.bounds.height - 60, width: (cell.contentImage.bounds.width-20), height: 27)
                cell.contentName.text = " \(value)"
                cell.contentName.font = UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)//UIFont(name: fontName, size: FONTSIZENormal)
                
                cell.ownerLabel.frame =  CGRect(x: 11, y: cell.contentImage.bounds.height - 30, width: (cell.contentImage.bounds.width-155), height: 20)
                if ownerName != "" {
                    cell.ownerLabel.text = "\(locationIcon) \(OwnerTitle)"
                }
                cell.ownerLabel.layer.shadowOpacity = 0.0
                cell.ownerLabel.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZENormal)
                
                
                let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                cell.totalMembers.frame = CGRect(x: (cell.contentImage.bounds.width-140), y: cell.contentImage.bounds.height - 30, width: 130, height: 20)
                cell.totalMembers.text = "\(likeCount)  \(follower)"
                cell.totalMembers.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZESmall)
                cell.totalMembers.textAlignment = NSTextAlignment.right
                cell.totalMembers.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.totalMembers.layer.shadowOpacity = 0.0
                
                
                // Set Menu
                cell.menu.isHidden = false
                
                let recognizer = UITapGestureRecognizer(target: self, action:#selector(AdvancedGroupViewController.handleTapped(_:)))
                recognizer.delegate = self
                
                cell.menu.addGestureRecognizer(recognizer)
                
                
                // RHS
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    
                    var pageInfo2:NSDictionary!
                    var adcount = Int()
                    if (kFrequencyAdsInCells_advgroup > 4 && nativeAdArray.count > 9)
                    {
                        adcount = row/(kFrequencyAdsInCells_advgroup-1)
                    }
                    else
                    {
                        adcount = 0
                    }
                    if(myAdvGroupResponse.count > (row*2+1+adcount) ){
                        pageInfo2 = myAdvGroupResponse[(row*2+1+adcount)] as! NSDictionary
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
                    cell.contentSelection2.addTarget(self, action: #selector(AdvancedGroupViewController.showPage(_:)), for: .touchUpInside)
                    
                    // Set Page Image
                    
                    
                    if let photoId = pageInfo2["photo_id"] as? Int{
                        
                        if photoId != 0{
                            
                            let url1 = NSURL(string: pageInfo2["image"] as! NSString as String)
                            cell.contentImage2.backgroundColor = placeholderColor
                             cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage2.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                            
                        } else {
                            cell.contentImage2.image = nil
                            cell.contentImage2.image = imageWithImage(UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                            
                        }
                    }
                    
                    
                    // Set Page Name
                    let name = pageInfo2["title"] as? String
                    
                    let tempString2 = "\(name!)" as NSString
                    
                    var ownerName : String = ""//(pageInfo2["owner_title"] as? String)!
                    if let location = pageInfo2["location"] as? String
                    {
                        ownerName = location
                    }
                    
                    var OwnerTitle : String
                    let tempStringOwner = ownerName as NSString
                    if tempStringOwner.length > 30{
                        OwnerTitle = tempStringOwner.substring(to: 27)
                        OwnerTitle += NSLocalizedString("...",  comment: "")
                    }else{
                        OwnerTitle = "\(tempStringOwner)"
                    }
                    
                    
                    var value2 : String
                    
                    if tempString2.length > 30{
                        value2 = tempString2.substring(to: 27)
                        value2 += NSLocalizedString("...",  comment: "")
                    }else{
                        value2 = "\(tempString2)"
                    }
                    
                    let owner = pageInfo2["like_count"] as? Int
                    
                    let members = pageInfo2["follow_count"] as? Int
                    
                    
                    cell.contentName2.frame = CGRect(x: 8, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 27)
                    cell.contentName2.text = " \(value2)"
                    cell.contentName2.font = UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)//UIFont(name: fontName, size: FONTSIZENormal)
                    
                    cell.ownerLabel2.frame =  CGRect(x: 11, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage2.bounds.width-140), height: 20)
                    if ownerName != "" {
                        cell.ownerLabel2.text = "\(locationIcon) \(OwnerTitle)"
                    }
                    cell.ownerLabel2.layer.shadowOpacity = 0.0
                    cell.ownerLabel2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZENormal)
                    
                    let member = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                    
                    
                    let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                    cell.totalMembers2.frame = CGRect(x: (cell.contentImage2.bounds.width-130), y: cell.contentImage2.bounds.height - 30, width: 120, height: 20)
                    cell.totalMembers2.text = "\(likeCount)  \(member)"
                    cell.totalMembers2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZESmall)
                    cell.totalMembers2.textAlignment = NSTextAlignment.right
                    
                    
                    
                    cell.menu2.isHidden = false
                    let recognizer = UITapGestureRecognizer(target: self, action:#selector(AdvancedGroupViewController.handleTapped(_:)))
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
                    if imageInfo["image_icon"]  != nil , let url = URL(string: imageInfo["image_icon"] as! String)
                    {
                        cell.categoryImageView.kf.indicatorType = .activity
                        (cell.categoryImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.categoryImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                        
                    }
                    // LHS
                    cell.categoryName.text = imageInfo["category_name"] as? String
                    cell.contentSelection.tag = index//imageInfo["category_id"] as! Int
                    cell.contentSelection.addTarget(self, action: #selector(AdvancedGroupViewController.showSubCategory(_:)), for: .touchUpInside)
                    
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
                
                if let imageInfo = categoryResponse[index + 1] as? NSDictionary
                {
                    if imageInfo["image_icon"]  != nil , let url = URL(string: imageInfo["image_icon"] as! String)
                    {
                        cell.categoryImageView1.kf.indicatorType = .activity
                        (cell.categoryImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.categoryImageView1.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                        
                        
                    }
                    cell.categoryName1.text = imageInfo["category_name"] as? String
                    cell.contentSelection1.tag = index+1 //imageInfo["category_id"] as! Int
                    cell.contentSelection1.addTarget(self, action: #selector(AdvancedGroupViewController.showSubCategory(_:)), for: .touchUpInside)
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
                    if imageInfo["image_icon"]  != nil , let url = URL(string: imageInfo["image_icon"] as! String)
                    {
                        cell.categoryImageView2.kf.indicatorType = .activity
                        (cell.categoryImageView2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.categoryImageView2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                        
                    }
                    cell.categoryName2.text = imageInfo["category_name"] as? String
                    cell.contentSelection2.tag = index+2 //imageInfo["category_id"] as! Int
                    cell.contentSelection2.addTarget(self, action: #selector(AdvancedGroupViewController.showSubCategory(_:)), for: .touchUpInside)
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
        if tableView.tag == 11 {
            popover.dismiss()
            let feed = myAdvGroupResponse[currentCell] as! NSDictionary
            if let feed_menu = feed["menu"] as? NSArray{
                let  menuItem = feed_menu[(indexPath as NSIndexPath).row]
                if let dic = menuItem as? NSDictionary {
                    let menuItem = menuItem as! NSDictionary
                    if dic["name"] as! String == "delete"{
                        
                        // Confirmation Alert for Delete Feed
                        displayAlertWithOtherButton(NSLocalizedString("Delete this Group?", comment: "") ,message: NSLocalizedString("Are you sure that you want to delete this Group? This action cannot be undone.", comment: "") ,otherButton: NSLocalizedString("Delete", comment: ""), otherButtonAction: { () -> () in
                            // Update Feed Gutter Menu
                            self.updatePageMenuAction(menuItem["url"] as! String,feedIndex: self.currentCell)
                            
                        })
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    if dic["name"] as! String == "edit"{
                        
                        isCreateOrEdit = false
                        let presentedVC = FormGenerationViewController()
                        presentedVC.formTitle = NSLocalizedString("Edit Group", comment: "")
                        presentedVC.contentType = "sitegroup"
                        presentedVC.url = menuItem["url"] as! String
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let nativationController = UINavigationController(rootViewController: presentedVC)
                        self.present(nativationController, animated:false, completion: nil)

                    }
                    
                    if dic["name"] as! String == "invite"{
                        isCreateOrEdit = true
                        let presentedVC = MessageCreateController()
                        presentedVC.iscoming = "sitegroup"
                        presentedVC.url = menuItem["url"] as! String
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        
                    }
                    
                    if dic["name"] as! String == "publish"{
                        self.updatePageMenuAction(menuItem["url"] as! String,feedIndex: self.currentCell)
                        
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
                        presentedVC.contentType = "sitegroup"
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
        else  if (kFrequencyAdsInCells_advgroup > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advgroup) == (kFrequencyAdsInCells_advgroup)-1))
        {
            
            let cell = tableView.cellForRow(at: indexPath) as! NativeGroupCell
            cell.selectionStyle = .none
            
            cell.backgroundColor = .clear
            
            if muteVideo == true
            {
                muteVideo = false
                shared1.muteVideosFor(tableView: advGroupTableView)
                cell.btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                //sender.setTitle("\(unMuteIconIcon)", for: .normal)
            }
            else
            {
                muteVideo = true
                shared1.muteVideosFor(tableView: advGroupTableView)
                cell.btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                //sender.setTitle("\(muteVideoIcon)", for: .normal)
            }
            print(row)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        arrowView.isHidden = true
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        if scrollView.tag == 2
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
            else
            {
                for ob in scrollView.subviews
                {
                    if ob .isKind(of: UIButton.self)
                    {
                        if ob.tag == 103
                        {
                            
                            (ob as! UIButton).alpha = 0.4
                            
                        }
                        
                    }
                }
                
            }
        }
        
//        if updateScrollFlag{
//            // Check for Page Number for Browse Page
//            if groupBrowseType == 0{
//                if advGroupTableView.contentOffset.y >= advGroupTableView.contentSize.height - advGroupTableView.bounds.size.height{
//                    if (!isPageRefresing  && limit*pageNumber < totalItems){
//                        if Reachabable.isConnectedToNetwork() {
//                            updateScrollFlag = false
//                            pageNumber += 1
//                            isPageRefresing = true
//                            if searchDic.count == 0{
//                                browseEntries()
//                            }
//                        }
//                    }
//
//                }
//            }
//            else if groupBrowseType == 1
//            {
//                if categoryTableView.contentOffset.y >= categoryTableView.contentSize.height - categoryTableView.bounds.size.height{
//                    if (!isPageRefresing  && limit*pageNumber < catTotalItems)
//                    {
//                        if Reachabable.isConnectedToNetwork()
//                        {
//                            updateScrollFlag = false
//                            pageNumber += 1
//                            isPageRefresing = true
//                            if searchDic.count == 0{
//                                browseEntries()
//                            }
//                        }
//                    }
//                }
//            }
//            else{
//                if myAdvGroupTableView.contentOffset.y >= myAdvGroupTableView.contentSize.height - myAdvGroupTableView.bounds.size.height{
//                    if (!isPageRefresing  && limit*pageNumber < mytotalItems)
//                    {
//                        if Reachabable.isConnectedToNetwork()
//                        {
//                            updateScrollFlag = false
//                            pageNumber += 1
//                            isPageRefresing = true
//                            if searchDic.count == 0{
//                                browseEntries()
//                            }
//                        }
//                    }
//                }
//            }
//        }
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
            if updateScrollFlag{
                // Check for Page Number for Browse Page
                if groupBrowseType == 0{
//                    if advGroupTableView.contentOffset.y >= advGroupTableView.contentSize.height - advGroupTableView.bounds.size.height{
                        if (!isPageRefresing  && limit*pageNumber < totalItems){
                            if Reachabable.isConnectedToNetwork() {
                                updateScrollFlag = false
                                pageNumber += 1
                                isPageRefresing = true
                                advGroupTableView.tableFooterView?.isHidden = false
                              //  if searchDic.count == 0{
                                if adsType_advGroup == 2 || adsType_advGroup == 4{
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
                            advGroupTableView.tableFooterView?.isHidden = true
                    }
                        
                   // }
                }
                else if groupBrowseType == 1
                {
//                    if categoryTableView.contentOffset.y >= categoryTableView.contentSize.height - categoryTableView.bounds.size.height{
                        if (!isPageRefresing  && limit*pageNumber < catTotalItems)
                        {
                            if Reachabable.isConnectedToNetwork()
                            {
                                updateScrollFlag = false
                                pageNumber += 1
                                isPageRefresing = true
                                categoryTableView.tableFooterView?.isHidden = false
                              //  if searchDic.count == 0{
                                    browseEntries()
                               // }
                            }
                        }
                        else
                        {
                            categoryTableView.tableFooterView?.isHidden = true
                    }
                  //  }
                }
                else{
//                    if myAdvGroupTableView.contentOffset.y >= myAdvGroupTableView.contentSize.height - myAdvGroupTableView.bounds.size.height{
                        if (!isPageRefresing  && limit*pageNumber < mytotalItems)
                        {
                            if Reachabable.isConnectedToNetwork()
                            {
                                updateScrollFlag = false
                                pageNumber += 1
                                isPageRefresing = true
                                myAdvGroupTableView.tableFooterView?.isHidden = false
                               // if searchDic.count == 0{
                                    browseEntries()
                               // }
                            }
                        }
                        else
                        {
                            myAdvGroupTableView.tableFooterView?.isHidden = true
                    }
                 //   }
                }
            }
            
        }
        
    }
    
    @objc func searchItem(){
        let presentedVC = AdvancedGroupSearchViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
        Formbackup.removeAllObjects()
        let url : String = "advancedgroups/search-form"
        loadFilter(url)
    }
    
    @objc func showFeedFilterOptions(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        let alertController = UIActionSheet(title: "Choose Option", delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), destructiveButtonTitle: nil, otherButtonTitles:"See All","Most Recent","Most Viewed","Most Commented", "Most Liked","Alphabetical","Most Reviewed","Most Rated")
        
        alertController.show(in: self.view)
        searchDic.removeAll(keepingCapacity: false)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        switch (buttonIndex){
//        case 0:
//            print("ok")
        case 1:
            searchType = ""
            feedFilter.setTitle(NSLocalizedString("See All", comment: ""), for: UIControl.State())
            self.showSpinner = true
            browseEntries()
        case 2:
            searchType = "creation_date"
            feedFilter.setTitle(NSLocalizedString("Most Recent", comment: ""), for: UIControl.State())
            self.showSpinner = true
            browseEntries()
        case 3:
            searchType = "view_count"
            feedFilter.setTitle(NSLocalizedString("Most Viewed", comment: ""), for: UIControl.State())
            self.showSpinner = true
            browseEntries()
        case 4:
            searchType = "comment_count"
            feedFilter.setTitle(NSLocalizedString("Most Commented", comment: ""), for: UIControl.State())
            self.showSpinner = true
            browseEntries()
        case 5:
            searchType = "like_count"
            feedFilter.setTitle(NSLocalizedString("Most Liked", comment: ""), for: UIControl.State())
            self.showSpinner = true
            browseEntries()
        case 6:
            searchType = "title"
            feedFilter.setTitle(NSLocalizedString("Alphabetical", comment: ""), for: UIControl.State())
            self.showSpinner = true
            browseEntries()
        case 7:
            searchType = "review_count"
            feedFilter.setTitle(NSLocalizedString("Most Reviewed", comment: ""), for: UIControl.State())
            self.showSpinner = true
            browseEntries()
        case 8:
            searchType = "rating"
            feedFilter.setTitle(NSLocalizedString("Most Rated", comment: ""), for: UIControl.State())
            self.showSpinner = true
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
        presentedVC .contentType = "sitegroup"
        
        
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
        let feed = myAdvGroupResponse[currentCell] as! NSDictionary
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
            popoverTableView.tag = 11
            popover.show(popoverTableView, point: startPoint)
            popoverTableView.reloadData()
        }
    }
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delay(0.0) {
            self.shared1.pauseVideosFor(tableView: self.advGroupTableView)
            self.taskVideoPlayPause?.cancel()
        }
        
        timerFB.invalidate()
        NotificationCenter.default.removeObserver(self)
        globFilterValue = ""
        globalCatg = ""
        tableViewFrameType = ""
        advGroupTableView.tableFooterView?.isHidden = true
        myAdvGroupTableView.tableFooterView?.isHidden = true
 categoryTableView.tableFooterView?.isHidden = true
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
