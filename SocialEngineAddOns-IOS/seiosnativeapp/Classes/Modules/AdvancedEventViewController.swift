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

//  AdvancedEventViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on FONTSIZESmall/01/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
//import GoogleMobileAds
import FBAudienceNetwork
import NVActivityIndicatorView
import Instructions

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

var evetUpdate :Bool!
class AdvancedEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, FBNativeAdDelegate, FBNativeAdsManagerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate, UIGestureRecognizerDelegate
{
    
    let mainView = UIView()
    var showOnlyMyContent:Bool! = false
    var eventOption:UIButton!
    let scrollView = UIScrollView()
    var eventBrowseType:Int!
    var feedFilter: UIButton!
    var eventTableView:UITableView!
    var myeventTableView:UITableView!
    var CategoryTableView:UITableView!
    var refresher:UIRefreshControl!
    var refresher1:UIRefreshControl!
    var refresher2:UIRefreshControl!
    var showSpinner = true
    var isPageRefresing = false
    var navtitle : UILabel!
    var contentIcon: UILabel!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var eventResponse = [AnyObject]()
    var myeventResponse = [AnyObject]()
    var categoryResponse = [AnyObject]()
    var noContentView : NoContentView!
    var updateScrollFlag = true
    var user_id : String!
    var fromTab : Bool! = false
    var imageArr:[UIImage]=[]
    var searchtype: String! = ""
    var hostCheckType : String!
    var hostCheckId : Int!
    var contentGutterMenu : NSArray = []
    var deleteContent : Bool!
    var subjectType:String!
    var popAfterDelay:Bool!
    var packagesEnabled:Int!
    var calendarView: NWCalendarView!
    var CalenderResponse = [AnyObject]()
    var arrDate = [Date]()
    
   // var imageCache = [String:UIImage]()
    var Getcalenderdate:String = ""
    var Getcalenderdate1:String = ""
    
    // AdMob Variable
//    var adLoader: GADAdLoader!
    var loadrequestcount = 0
    var adsCount:Int = 0
    var isnativeAd:Bool = true
    var nativeAdArray = [AnyObject]()
    // Native FacebookAd Variable
    var nativeAd:FBNativeAd!
    var adChoicesView: FBAdChoicesView!
    var adTitleLabel:UILabel!
    var adIconImageView:UIImageView!
    var adSocialContextLabel : UILabel!
    var adImageView:FBMediaView!
    var adBodyLabel:UILabel!
    var adSocialSiteLabel : UILabel!
    var adCallToActionButton:UIButton!
    var fbView:UIView!
    var admanager:FBNativeAdsManager!
    var Adiconview:UIImageView!
    var leftBarButtonItem : UIBarButtonItem!
    var sitegroupCheck : String = ""
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
    var isFilterapplied : Bool = false
    var adsCellheight:CGFloat = 0.0
    
    var couponView = CouponsBrowseViewController()
    
    //myticket variables

    var showSpinner5 = true                      // not show spinner at pull to refresh
    var ticketResponse = [AnyObject]()         // For response come from Server
    var isPageRefresing5 = false                 // For Pagination
    var ticketTableView:UITableView!           // TAbleView to show the blog Contents
    var refresher5:UIRefreshControl!             // Pull to refrresh
    var pageNumber5:Int = 1
    var totalItems5:Int = 0
    var updateScrollFlag5 = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 75              // Dynamic Height fort for Cell
    var showOnlyMyContent5:Bool = false
    var scrollView5: UIScrollView!
  //  var imageCache5 = [String:UIImage]()
    var responseCache = [String:AnyObject]()
    var url: String = ""
    var filterButton = UIButton()
    var filterButton1 = UIButton()
    var Button1 = UIButton()
    var Button2 = UIButton()
    var clicked : Int = 0
    var paramtype : String = "current"
    var dynamicRowHeight = [Int:CGFloat]()
    var memberLocation = UILabel()
    var pagignationtype : Int = 0
    var toggle : Int = 0 // For filter toggle
    var totalUpcomingOrderCount : Int = 100 //Check response for current order has value or not
    var totalPastOrderCount : Int = 100 //Check response for past order has value or not
    var timerFB = Timer()
    var eventCount : Int = 0
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    var targetSeeAllValue : Int = 1
    
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
  
        if fromTab == false{
            setDynamicTabValue()
        }
        shared1 = VideoPlayerController()
        removeMarqueFroMNavigaTion(controller: self)
        view.backgroundColor = bgColor
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        subjectType = "advancedevents"
        eventUpdate = false
        popAfterDelay = false
        
        
        globFilterValue = ""
        openMenu = false
        updateAfterAlert = true
        evetUpdate = true
        eventBrowseType = 0
        if showOnlyMyContent == false
        {
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            
            let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvancedEventViewController.openSlideMenu))
            leftNavView.addGestureRecognizer(tapView)
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

            CreateScrollHeader()
            
            if tabBarHeight > 0{
                eventTableView = UITableView(frame: CGRect(x: 0, y: ButtonHeight+10+TOPPADING, width: view.bounds.width, height: view.bounds.height-(ButtonHeight+10+TOPPADING) - tabBarHeight ), style: .grouped)
            }else{
                eventTableView = UITableView(frame: CGRect(x: 0, y: ButtonHeight+10+TOPPADING, width: view.bounds.width, height: view.bounds.height-(ButtonHeight+10+TOPPADING) - tabBarHeight ), style: .grouped)
            }
        }
        else
        {
            if tabBarHeight > 0{
                eventTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height-(TOPPADING) - tabBarHeight ), style: .grouped)
            }else{
                eventTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height-(TOPPADING) - tabBarHeight ), style: .grouped)
            }
        }
     
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        eventTableView.register(EventViewTableViewCell.self, forCellReuseIdentifier: "CellThree")
        eventTableView.rowHeight = 260
        eventTableView.dataSource = self
        eventTableView.delegate = self
        eventTableView.isOpaque = false
        eventTableView.backgroundColor = tableViewBgColor
        eventTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            eventTableView.estimatedRowHeight = 0
            eventTableView.estimatedSectionHeaderHeight = 0
            eventTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(eventTableView)
        
        
        
        myeventTableView = UITableView(frame: CGRect(x: 0,y: ButtonHeight+10+TOPPADING, width: view.bounds.width, height: view.bounds.height-(ButtonHeight+10+TOPPADING) - tabBarHeight), style: .grouped)
        myeventTableView.register(EventViewTableViewCell.self, forCellReuseIdentifier: "CellThree")
        myeventTableView.rowHeight = 260
        myeventTableView.dataSource = self
        myeventTableView.delegate = self
        myeventTableView.isHidden = true
        myeventTableView.backgroundColor = tableViewBgColor
        myeventTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            myeventTableView.estimatedRowHeight = 0
            myeventTableView.estimatedSectionHeaderHeight = 0
            myeventTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(myeventTableView)
        // Initialize Classified Table
        CategoryTableView = UITableView(frame: CGRect(x: 0,y: ButtonHeight+10+TOPPADING, width: view.bounds.width, height: view.bounds.height-(ButtonHeight+10+TOPPADING) - tabBarHeight), style: .grouped)
        CategoryTableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "Cellone")
        CategoryTableView.dataSource = self
        CategoryTableView.delegate = self
        CategoryTableView.estimatedRowHeight = 165.0
        CategoryTableView.rowHeight = UITableView.automaticDimension
        CategoryTableView.backgroundColor = UIColor.clear
        CategoryTableView.separatorColor = UIColor.clear
        CategoryTableView.isHidden = true
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            CategoryTableView.estimatedRowHeight = 0
            CategoryTableView.estimatedSectionHeaderHeight = 0
            CategoryTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(CategoryTableView)
        
        // Set pull to referseh for eventtableview
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(AdvancedEventViewController.refresh), for: UIControl.Event.valueChanged)
        eventTableView.addSubview(refresher)
        
        
        refresher1 = UIRefreshControl()
        refresher1.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher1.addTarget(self, action: #selector(AdvancedEventViewController.refresh), for: UIControl.Event.valueChanged)
        myeventTableView.addSubview(refresher1)
        
        refresher2 = UIRefreshControl()
        refresher2.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher2.addTarget(self, action: #selector(AdvancedEventViewController.refresh), for: UIControl.Event.valueChanged)
        CategoryTableView.addSubview(refresher2)
        

        scrollView.isUserInteractionEnabled = false
        
        
        if fromTab == true || showOnlyMyContent == true
        {
            if feedFilter != nil{
                feedFilter.isHidden = true
            }
            myeventTableView.frame = CGRect(x: 0,y: TOPPADING , width: view.bounds.width, height: view.bounds.height-TOPPADING - tabBarHeight)
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvancedEventViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
            
        }
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        myeventTableView.tableFooterView = footerView
        myeventTableView.tableFooterView?.isHidden = true
  
        
        let footerView2 = UIView(frame: frameActivityIndicator)
        footerView2.backgroundColor = UIColor.clear
        let activityIndicatorView2 = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView2.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView2.addSubview(activityIndicatorView2)
        activityIndicatorView2.startAnimating()
        eventTableView.tableFooterView = footerView2
        eventTableView.tableFooterView?.isHidden = true
  
        
        browseEntries()
        myticket()
        if adsType_advancedevent != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(AdvancedEventViewController.checkforAds),
                                           userInfo: nil,
                                           repeats: false)
        }
    }
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showAdvEventContent")
        {
            if  UserDefaults.standard.object(forKey: "showAdvEventContent") != nil {
                
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showAdvEventContent")
        }
        
    }
    
    //MARK: -  App Tour
    
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
                    let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50 + iphonXTopsafeArea), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                    
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
                    let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50 + iphonXTopsafeArea), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                    
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
    
    
    override func viewDidAppear(_ animated: Bool)
    {
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
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        }

        Customnavigation()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
        IsRedirctToProfile()
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
        removeNavigationViews(controller: self)
        //Customized navigation bar
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        if eventUpdate == true
        {
            eventUpdate = false
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            scrollView.isUserInteractionEnabled = false
            browseEntries()
        }
        showInFilter = ""
        showEventType = ""
        orderBy = ""
        event_time = ""
        venue_name = ""
        proximity = ""
        Siteevent_street = ""
        siteevent_city = ""
        siteevent_state = ""
        siteevent_country = ""
        category_id = ""
        location = "ab"
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
    }
    @objc func appEnteredFromBackground() {
        
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        
    }
    @objc func appMovedToBackground() {
        self.shared1.pauseVideosFor(tableView: self.eventTableView)
        self.shared1.pauseVideosFor(tableView: self.myeventTableView)
        self.taskVideoPlayPause?.cancel()
    }
    @objc func videoCompletion() {
        
        shared1.currentVideoContainer()?.playOn = true
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        
    }
    func pausePlayeVideos(){
        shared1.pausePlayeVideosFor(tableView: eventTableView)
        
    }
    func Customnavigation()
    {
        if let navigationBar = self.navigationController?.navigationBar
        {
//            if (UIDevice.current.userInterfaceIdiom == .pad){
//                let firstFrame = CGRect(x: 330, y:5, width: navigationBar.frame.width/3, height: navigationBar.frame.height - 10)
//                navtitle = UILabel(frame: firstFrame)
//                navtitle.textAlignment = .center
//                navtitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
//                navtitle.textColor = textColorPrime
//                navtitle.text = NSLocalizedString("Events", comment: "")
//                //navtitle.sizeToFit()
//                navtitle.tag = 400
//                //Filter option
//                feedFilter = createButton(CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/3))/2 ,y: 17,width: navigationBar.frame.width/3, height: 30),title:NSLocalizedString("See All", comment: "") , border: false, bgColor: false,textColor: textColorPrime)
//                feedFilter.isEnabled = true
//                feedFilter.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
//                feedFilter.addTarget(self, action: #selector(AdvancedEventViewController.showFeedFilterOptions(_:)), for: .touchUpInside)
//                feedFilter.tag = 400
//                //Filter icon
//                let filterIcon = createLabel(CGRect(x: 150, y: 0 ,width: feedFilter.bounds.height ,height: feedFilter.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorPrime)
//                filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
//                feedFilter.addSubview(filterIcon)
//
//               if((self.fromTab != nil) && (self.fromTab == true) && (self.user_id != nil) && (showOnlyMyContent == true)) {
//                navtitle.isHidden = true
//                feedFilter.isHidden = true
//                if eventCount > 0 {
//                    self.navigationItem.title = "Events : (\(eventCount))"
//                }
//                else{
//                    self.navigationItem.title = "Events"
//                }
//                }
//
//                navigationBar.addSubview(feedFilter)
//                navigationBar.addSubview(navtitle)
//            }
//            else
//            {
                let firstFrame = CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/3))/2, y:-5, width: navigationBar.frame.width/3, height: navigationBar.frame.height - 10)
                navtitle = UILabel(frame: firstFrame)
                navtitle.textAlignment = .center
                navtitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
                navtitle.textColor = textColorPrime
                navtitle.text = NSLocalizedString("Events", comment: "")
                //navtitle.sizeToFit()
                navtitle.tag = 400
                //Filter option

                feedFilter = createButton(CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/3))/2 ,y: 18,width: navigationBar.frame.width/3, height: 30),title:NSLocalizedString("See All", comment: "") , border: false, bgColor: false,textColor: textColorPrime)
                feedFilter.isEnabled = true
                feedFilter.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                feedFilter.addTarget(self, action: #selector(AdvancedEventViewController.showFeedFilterOptions(_:)), for: .touchUpInside)
                let fitertext = NSLocalizedString("See All", comment: "") + " " + searchFilterIcon
                feedFilter.setTitle(fitertext, for: .normal)
                feedFilter.tag = 400
               if((self.fromTab != nil) && (self.fromTab == true) && (self.user_id != nil) && (showOnlyMyContent == true)) {
                    navtitle.isHidden = true
                    feedFilter.isHidden = true
                    if eventCount > 0 {
                    self.navigationItem.title = "Events : (\(eventCount))"
                    }
                    else{
                        self.navigationItem.title = "Events"
                    }
                }
                
                
                navigationBar.addSubview(feedFilter)
                navigationBar.addSubview(navtitle)
            //}
        }
    }
    func IsRedirctToProfile()
    {
        if video_clicked != 1 {
            if conditionalProfileForm == "BrowsePage"
            {
                conditionalProfileForm = ""
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectId = "\(createResponse["event_id"]!)"
                presentedVC.subjectType = "advancedevents"
                navigationController?.pushViewController(presentedVC, animated: true)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        delay(0.0) {
            self.shared1.pauseVideosFor(tableView: self.eventTableView)
            self.shared1.pauseVideosFor(tableView: self.myeventTableView)
            self.taskVideoPlayPause?.cancel()
        }
        
        timerFB.invalidate()
        NotificationCenter.default.removeObserver(self)
        myeventTableView.tableFooterView?.isHidden = true
eventTableView.tableFooterView?.isHidden = true
        ticketTableView.tableFooterView?.isHidden = true
        
        self.title = ""
        removeNavigationViews(controller: self)
        filterSearchFormArray.removeAll(keepingCapacity: false)
        
    }
    
    
    @objc func checkforAds()
    {
        nativeAdArray.removeAll()
        if adsType_advancedevent == 1
        {
            if kFrequencyAdsInCells_advancedevent > 4 && placementID != ""
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
                        if eventBrowseType == 0
                        {
                            eventTableView.reloadData()
                        }
                        else
                        {
                            myeventTableView.reloadData()
                        }
                    }
                }
            }
            
        }
        else if adsType_advancedevent == 0
        {
            if kFrequencyAdsInCells_advancedevent > 4 && adUnitID != ""
            {
               // showNativeAd()
            }
            
        }
        else if adsType_advancedevent == 2{
            checkCommunityAds()
        }
        
    }
    //MARK: -  Functions that we are using for community ads and sponsered stories
    func  checkCommunityAds()
    {
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            var dic = Dictionary<String, String>()
            dic["type"] =  "\(adsType_advancedevent)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_advancedevent)"
            post(dic, url: "communityads/index/index", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if let advertismentsArray = body["advertisments"] as? NSArray
                                {
                                    self.communityAdsValues = advertismentsArray
                                    if adsType_advancedevent == 2{
                                        self.uiOfCommunityAds(count: advertismentsArray.count){
                                            (status : Bool) in
                                            if status == true{
                                                // self.eventTableView.reloadData()
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
        else
        {
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
                adCallToActionButton.addTarget(self, action: #selector(AdvancedEventViewController.actionAfterClick(_:)), for: .touchUpInside)
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
                    
                    
                    videoclickButton.addTarget(self, action: #selector(AdvancedEventViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
                    self.fbView.addSubview(videoclickButton)
                }
                else{
                    imageButton.addTarget(self, action: #selector(AdvancedEventViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
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
                        
                        ctaButton.addTarget(self, action: #selector(AdvancedEventViewController.tappedOnAds(_:)), for: .touchUpInside)
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
                let navigationController = UINavigationController(rootViewController: presentedVC)
                navigationController.modalPresentationStyle = .fullScreen
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
                let navigationController = UINavigationController(rootViewController: presentedVC)
                navigationController.modalPresentationStyle = .fullScreen
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
            let navigationController = UINavigationController(rootViewController: presentedVC)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
        
    }
    @objc func actionAfterClick(_ sender: UIButton){
        var dictionary = Dictionary<String, String>()
        dictionary["type"] =  "\(adsType_advancedevent)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_advancedevent)"
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
                if ob.tag == 1005
                {
                    (ob as! UIButton).alpha = 1.0
                    ob.isUserInteractionEnabled = true
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
            if eventBrowseType == 0
            {
                eventTableView.reloadData()
            }
            else
            {
                myeventTableView.reloadData()
            }
        }
        
        
    }
   
    func nativeAdsFailedToLoadWithError(_ error: Error)
    {
        //print(error.localizedDescription)
    }
    
    
    // MARK: - GADAdLoaderDelegate
//    func showNativeAd()
//    {
//         var adTypes = [GADAdLoaderAdType]()
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
//            if eventBrowseType == 0
//            {
//                self.eventTableView.reloadData()
//            }
//            else
//            {
//                self.myeventTableView.reloadData()
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
//            if eventBrowseType == 0
//            {
//                self.eventTableView.reloadData()
//            }
//            else
//            {
//                self.myeventTableView.reloadData()
//            }
//        }
//    }
    
    // MARK: Create AdvancedEvent Menu
    func CreateScrollHeader()
    {
        
        scrollView.frame = CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: ButtonHeight+10)
        scrollView.delegate = self
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        if logoutUser == false
        {
            var eventMenu = ["Events","Categories","My Events","Calendar","My Tickets","Coupons"]
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/3-15)
            for i in 100 ..< 106
            {
                if i == 100
                {
                    eventOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight+10), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: true)
                }else{
                    eventOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight+10), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: false)
                }
                eventOption.tag = i
                eventOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
                eventOption.addTarget(self, action: #selector(AdvancedEventViewController.eventSelectOptions(_:)), for: .touchUpInside)
                eventOption.backgroundColor =  UIColor.clear//textColorLight
                eventOption.alpha = 1.0
                if i==103
                {
                    eventOption.alpha = 0.4
                    
                }
                scrollView.addSubview(eventOption)
                origin_x += menuWidth
                
            }
            
        }
        else
        {
            var eventMenu = ["Events","Categories","Calendar"]
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/3-15)
            for i in 100 ..< 103
            {
                if i == 100
                {   eventOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight+10), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: true)
                }else{
                    eventOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight+10), title: NSLocalizedString("\(eventMenu[(i-100)])", comment: ""), border: false, selected: false)
                }
                eventOption.tag = i
                eventOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                eventOption.addTarget(self, action: #selector(AdvancedEventViewController.eventSelectOptions(_:)), for: .touchUpInside)
                eventOption.backgroundColor =  UIColor.clear//textColorLight
                eventOption.alpha = 1.0
                scrollView.addSubview(eventOption)
                origin_x += menuWidth
                
            }
            
        }
        scrollView.contentSize = CGSize(width:menuWidth * 6,height:ScrollframeY)
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
    
    // MARK: Show Slide Menu
    @objc func openSlideMenu()
    {
        let dashObj = DashboardViewController()
        dashObj.getDynamicDashboard()
        dashObj.dashboardTableView.reloadData()
        // 
        openSideMenu = true
        
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer)
    {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    func sideMenuWillOpen() {
        openSideMenu = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(AdvancedEventViewController.openSlideMenu))
        mainView.addGestureRecognizer(tapGesture)
    }
    
    func sideMenuWillClose() {
        openSideMenu = false
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    // MARK: -  Pull to Request Action
    @objc func refresh(){
        if Reachabable.isConnectedToNetwork() {
            arrGlobalFacebookAds.removeAll()
            checkforAds()
            searchDic.removeAll(keepingCapacity: false)
            
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            scrollView.isUserInteractionEnabled = false
            browseEntries()
        }
        else
        {
            // No Internet Connection Message
            refresher.endRefreshing()
            refresher1.endRefreshing()
            refresher2.endRefreshing()
            //refresher3.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    // MARK: - Event Selection Action
    @objc func eventSelectOptions(_ sender: UIButton)
    {
        showSpinner = true
        eventBrowseType = sender.tag - 100
        let subViews = mainView.subviews
//        scrollView.contentOffset.x = 0
        for ob in subViews{
            if ob.tag == 1000{
                ob.removeFromSuperview()
            }
            if(ob .isKind(of: NWCalendarView.self))
            {
                ob.removeFromSuperview()
            }
        }
        if logoutUser == false
        {
            if eventBrowseType == 0
            {
                
                couponView.view.isHidden = true
                feedFilter.isHidden = false
                
                ticketTableView.isHidden = true
                filterButton.isHidden = true
                filterButton1.isHidden = true
                
                Button1.isHidden = true
                Button2.isHidden = true
                
                if eventResponse.count == 0
                {
                    CategoryTableView.isHidden = true
                    myeventTableView.isHidden = true
                    // //DiaryTableView.isHidden = true
                    pageNumber = 1
                    showSpinner = true
                    scrollView.isUserInteractionEnabled = false
                    scrollView.contentOffset.x = 0
                    browseEntries()
                }
                else
                {
                    eventTableView.isHidden = false
                    CategoryTableView.isHidden = true
                    myeventTableView.isHidden = true
                    //DiaryTableView.isHidden = true
                    eventTableView.reloadData()
                    
                }
                
            }
            else if eventBrowseType == 1
            {
                couponView.view.isHidden = true
                feedFilter.isHidden = true
                eventTableView.isHidden = true
                
                ticketTableView.isHidden = true
                filterButton.isHidden = true
                filterButton1.isHidden = true
                
                Button1.isHidden = true
                Button2.isHidden = true
                
                // //DiaryTableView.isHidden = true
                myeventTableView.isHidden = true
                scrollView.contentOffset.x = 0
                if categoryResponse.count == 0
                {
                    showSpinner = true
                    pageNumber = 1
                    scrollView.isUserInteractionEnabled = false
                    browseEntries()
                }
                else
                {
                    
                    eventTableView.isHidden = true
                    CategoryTableView.isHidden = false
                    myeventTableView.isHidden = true
                    //DiaryTableView.isHidden = true
                }
                
                
                
            }
            else  if eventBrowseType == 2
            {
                couponView.view.isHidden = true
                feedFilter.isHidden = true

                scrollView.contentOffset.x = 0
                if showOnlyMyContent == false{
                    myeventTableView.frame = CGRect(x: 0, y: ButtonHeight+TOPPADING+10, width: view.bounds.width, height: view.bounds.height-(ButtonHeight+TOPPADING+10)-tabBarHeight)
                }
                else{
                    myeventTableView.frame = CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height - (tabBarHeight + TOPPADING))
                    
                  
                    
                }
                
                ticketTableView.isHidden = true
                filterButton.isHidden = true
                filterButton1.isHidden = true
                
                Button1.isHidden = true
                Button2.isHidden = true
                
                couponView.view.isHidden = true
                CategoryTableView.isHidden = true
                //DiaryTableView.isHidden = true
                eventTableView.isHidden = true
                
                if myeventResponse.count == 0
                {
                    showSpinner = true
                    scrollView.isUserInteractionEnabled = false
                    pageNumber = 1
                    browseEntries()
                }
                else
                {
                    myeventTableView.isHidden = false
                }
                
                
                
            }
            else if eventBrowseType == 3
            {
                couponView.view.isHidden = true
                feedFilter.isHidden = true
                eventTableView.isHidden = true
                CategoryTableView.isHidden = true
                //DiaryTableView.isHidden = true
                myeventTableView.isHidden = true
                scrollView.isUserInteractionEnabled = false
                scrollView.contentOffset.x = 52
                ticketTableView.isHidden = true
                filterButton.isHidden = true
                filterButton1.isHidden = true
                
                Button1.isHidden = true
                Button2.isHidden = true
                
                browseEntries()
                
            }//Click on My Ticket button
            else if eventBrowseType == 4
            {
                
                feedFilter.isHidden = true
                couponView.view.isHidden = true
                eventTableView.isHidden = true
                CategoryTableView.isHidden = true
                myeventTableView.isHidden = true
                
                ticketTableView.isHidden = false
                filterButton.isHidden = false
                filterButton1.isHidden = false
                
                
                pagignationtype = 1
                browseEntries1()
                
            }//Click on Coupon button
            else if eventBrowseType == 5
            {
                feedFilter.isHidden = true
                eventTableView.isHidden = true
                CategoryTableView.isHidden = true
                myeventTableView.isHidden = true
                
                ticketTableView.isHidden = true
                filterButton.isHidden = true
                filterButton1.isHidden = true
                
                Button1.isHidden = true
                Button2.isHidden = true
                
                couponView = CouponsBrowseViewController()
                couponView.view.frame = CGRect(x: 0, y: ButtonHeight+TOPPADING+10, width: self.view.bounds.width, height: view.bounds.height - (ButtonHeight+TOPPADING+10)-tabBarHeight)
                let tempUrl = "advancedeventtickets/coupons/index"
                couponView.url = tempUrl
                couponView.Events_home = 1
                mainView.addSubview(couponView.view)
            }
            
        }
        else
        {
            if eventBrowseType == 0
            {
                feedFilter.isHidden = false
                if eventResponse.count == 0
                {
                    showSpinner = true
                    CategoryTableView.isHidden = true
                    myeventTableView.isHidden = true
                    //DiaryTableView.isHidden = true
                    pageNumber = 1
                    scrollView.isUserInteractionEnabled = false
                    browseEntries()
                }
                else
                {
                    eventTableView.isHidden = false
                    CategoryTableView.isHidden = true
                    myeventTableView.isHidden = true
                    //DiaryTableView.isHidden = true
                    eventTableView.reloadData()
                    
                }
                
            }
            else if eventBrowseType == 1
            {
                feedFilter.isHidden = true
                eventTableView.isHidden = true
                //DiaryTableView.isHidden = true
                myeventTableView.isHidden = true
                if categoryResponse.count == 0
                {
                    showSpinner = true
                    pageNumber = 1
                    scrollView.isUserInteractionEnabled = false
                    browseEntries()
                }
                else
                {
                    eventTableView.isHidden = true
                    CategoryTableView.isHidden = false
                    myeventTableView.isHidden = true
                    //DiaryTableView.isHidden = true
                }
                
                
                
            }
            else  if eventBrowseType == 2
            {
                feedFilter.isHidden = true
                eventTableView.isHidden = true
                CategoryTableView.isHidden = true
                //DiaryTableView.isHidden = true
                myeventTableView.isHidden = true
                scrollView.isUserInteractionEnabled = false
                browseEntries()
                
                
            }
            
        }
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        for ob in scrollView.subviews{
            if ob .isKind(of: UIButton.self){
                if ob.tag >= 100 && ob.tag <= 105
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
    
    //My ticket filter defination
    func FilterdesignUI()
    {
        
        filterButton = createButton(CGRect(x: 0, y: TOPPADING + ButtonHeight + 10, width: view.bounds.width - 30, height: 40),title:"Current Orders" , border: false, bgColor: false,textColor: textColorDark)
        filterButton.backgroundColor = TVSeparatorColor
        filterButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZELarge)
        filterButton.isHidden = true
        self.view.addSubview(filterButton)
        
        
        filterButton1 = createButton(CGRect(x: getRightEdgeX(inputView: filterButton), y: TOPPADING + ButtonHeight + 10, width: 30, height: 40),title:"\(searchFilterIcon)" , border: false, bgColor: false,textColor: textColorDark)
        filterButton1.backgroundColor = TVSeparatorColor
        filterButton1.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        filterButton1.isHidden = true
        self.view.addSubview(filterButton1)
        
        filterButton.addTarget(self, action: #selector(filterClick), for: .touchUpInside)
        filterButton1.addTarget(self, action: #selector(filterClick), for: .touchUpInside)
        
        Button1 = createButton(CGRect(x: 0, y: getBottomEdgeY(inputView: filterButton1), width: view.bounds.width, height: 50),title:"Current Orders" , border: false, bgColor: false,textColor: textColorDark)
        
        Button1.backgroundColor = tableViewBgColor
        Button1.titleLabel?.font = UIFont(name: fontName, size: FONTSIZELarge)
        Button1.isHidden = true
        Button1.layer.borderWidth = 1
        Button1.layer.borderColor = borderColorMedium.cgColor
        Button1.contentHorizontalAlignment = .left
        Button1.tag = 1
        Button1.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        self.view.addSubview(Button1)
        
        Button2 = createButton(CGRect(x: 0, y: getBottomEdgeY(inputView: Button1), width: view.bounds.width, height: 50),title:"Past Orders" , border: false, bgColor: false,textColor: textColorDark)
        Button2.backgroundColor = tableViewBgColor
        Button2.titleLabel?.font = UIFont(name: fontName, size: FONTSIZELarge)
        Button2.isHidden = true
        Button2.layer.borderWidth = 1
        Button2.layer.borderColor = borderColorMedium.cgColor
        Button2.contentHorizontalAlignment = .left
        Button2.tag = 2
        Button2.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        self.view.addSubview(Button2)
        
    }
    // Click on Myticket filter
    @objc func filterClick()
    {
        
        if toggle == 0 {
            
            self.ticketTableView.isUserInteractionEnabled = false
            Button1.isHidden = false
            Button2.isHidden = false
            
            Button1.addTarget(self, action: #selector(Buttonclick(_ :)), for: .touchUpInside)
            Button2.addTarget(self, action: #selector(Buttonclick(_ :)), for: .touchUpInside)
            
            toggle = 1
        }
        else
        {
            toggle = 0
            
            self.ticketTableView.isUserInteractionEnabled = true
            Button1.isHidden = true
            Button2.isHidden = true
        }
        
    }
    // Choose filter option in myticket
    @objc func Buttonclick(_ sender: UIButton)
    {
        clicked = 1
        self.ticketTableView.isUserInteractionEnabled = true
        switch sender.tag
        {
        case 1:
            filterButton.setTitle("Current Orders", for: UIControl.State.normal)
            paramtype = "current"
            Button1.isHidden = true
            Button2.isHidden = true
            browseEntries1()
            break
        case 2:
            filterButton.setTitle("Past Orders", for: UIControl.State.normal)
            paramtype = "past"
            Button1.isHidden = true
            Button2.isHidden = true
            browseEntries1()
            break
        default:
            break
        }
        
    }
    
    // My ticket code defination
    func myticket()
    {
        FilterdesignUI()
        ticketTableView = UITableView(frame: CGRect(x:0, y:TOPPADING + ButtonHeight + 10 + 20 - iphonXBottomsafeArea, width:view.bounds.width, height:view.bounds.height-(tabBarHeight + ButtonHeight + TOPPADING + 20 + 10)), style:.grouped)
        ticketTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        ticketTableView.dataSource = self
        ticketTableView.delegate = self
        ticketTableView.estimatedRowHeight = 75
        ticketTableView.rowHeight = UITableView.automaticDimension
        ticketTableView.backgroundColor = tableViewBgColor
        ticketTableView.separatorColor = UIColor.gray
        ticketTableView.tag = 101
        ticketTableView.isHidden = true
        mainView.addSubview(ticketTableView)
        
        
        let footerView3 = UIView(frame: frameActivityIndicator)
        footerView3.backgroundColor = UIColor.clear
        let activityIndicatorView3 = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView3.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView3.addSubview(activityIndicatorView3)
        activityIndicatorView3.startAnimating()
        ticketTableView.tableFooterView = footerView3
        ticketTableView.tableFooterView?.isHidden = true
        
        refresher5 = UIRefreshControl()
        refresher5.addTarget(self, action: #selector(AdvancedEventViewController.refresh), for: UIControl.Event.valueChanged)
        ticketTableView.addSubview(refresher5)
    }
    
    // Get Myticket data
    @objc func browseEntries1(){
//        self.info.isHidden = true
//        self.refreshButton.isHidden = true
//        self.contentIcon.isHidden = true
      //  self.noContentView.isHidden = true
        // Check Internet Connectivity
        for ob in view.subviews {
            if ob.tag == 1000 {
                ob.removeFromSuperview()
            }
        }
        if Reachabable.isConnectedToNetwork()
        {
            let parameters = ["page":"\(pageNumber5)", "limit": "\(limit)","viewType":"\(paramtype)"]
            let path = "advancedeventtickets/tickets/index"
            
            if clicked == 1
            {
                clicked = 0
                ticketResponse.removeAll(keepingCapacity: false)
            }
            
            if (showSpinner5){
                activityIndicatorView.center = mainView.center
                if updateScrollFlag5 == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber5 == 1){
                    activityIndicatorView.center = mainView.center
                    updateScrollFlag5 = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
            //    activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
//                spinner.startAnimating()
            }
            
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner5{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher5.endRefreshing()
                    self.showSpinner5 = false
                    self.updateScrollFlag5 = true
                    
                    if msg{
                        
                        if self.pageNumber5 == 1{
                            self.ticketResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            self.totalUpcomingOrderCount = (response["totalUpcomingOrderCount"] as? Int)!
                            self.totalPastOrderCount = (response["totalPastOrderCount"] as? Int)!
                            
                            if response["response"] != nil
                            {
                                if let ticket = response["response"] as? NSMutableArray
                                {
                                    self.ticketResponse = self.ticketResponse + (ticket as [AnyObject])
                                    if (self.pageNumber5 == 1)
                                    {
                                        self.responseCache["\(path)"] = ticket
                                    }
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                        }
                        
                        self.isPageRefresing5 = false
                        self.ticketTableView.reloadData()

                    
                        if self.paramtype == "current"
                        {
                            if self.totalUpcomingOrderCount == 0 {

                                self.noContentView = NoContentView()
                                self.noContentView.tag = 1000
                                self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                                self.mainView.addSubview(self.noContentView)
                                self.noContentView.isHidden = false
                                self.noContentView.button.isHidden = true
                                self.noContentView.label.text = NSLocalizedString("No Listings available at this moment", comment: "")
                                
                            }
                        }
                        else
                        {
                            if self.totalPastOrderCount == 0 {
                                self.noContentView = NoContentView()
                                self.noContentView.tag = 1000
                                self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                                self.mainView.addSubview(self.noContentView)
                                self.noContentView.isHidden = false
                               self.noContentView.button.isHidden = true
                                self.noContentView.label.text = NSLocalizedString("No Listings available at this moment", comment: "")
                                
                            }
                        }
                        
                    }
                    else
                    {
                        // Handle Server Error
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
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        arrowView.isHidden = true
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        
        if scrollView.tag == 2
        {
            
            if scrollView.contentOffset.x>45
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
                searchDic.removeAll(keepingCapacity: false)
         
                if eventBrowseType == 2
                {
//                    if myeventTableView.contentOffset.y >= myeventTableView.contentSize.height - myeventTableView.bounds.size.height{
                        if (!isPageRefresing  && limit*pageNumber < totalItems)
                        {
                            if Reachabable.isConnectedToNetwork()
                            {
                                updateScrollFlag = false
                                pageNumber += 1
                                isPageRefresing = true
                                myeventTableView.tableFooterView?.isHidden = false
                               // if searchDic.count == 0{
                                    if adsType_advancedevent == 2 || adsType_advancedevent == 4{
                                        delay(0.8) {
                                            self.checkforAds()
                                        }
                                  }
                                    browseEntries()
                            }
                        }
                        else
                        {
                            myeventTableView.tableFooterView?.isHidden = true
                    }
                        
                  //  }
                    
                }
                else
                {
//                    if eventTableView.contentOffset.y >= eventTableView.contentSize.height - eventTableView.bounds.size.height{
                        if (!isPageRefresing  && limit*pageNumber < totalItems)
                        {
                            if Reachabable.isConnectedToNetwork()
                            {
                                updateScrollFlag = false
                                pageNumber += 1
                                isPageRefresing = true
                                eventTableView.tableFooterView?.isHidden = false
                               // if searchDic.count == 0{
                                    if adsType_advancedevent == 2 || adsType_advancedevent == 4{
                                        delay(0.1) {
                                            self.checkforAds()
                                        }
                                    }
                                    browseEntries()
                                //}
                            }
                        }
                        else
                        {
                            eventTableView.tableFooterView?.isHidden = true
                    }
                        
                 //   }
                    
                }
            }
            else
            { // Myticket table pagignation
                if pagignationtype == 1
                {
                    pagignationtype = 0
                    // Check for Page Number for Browse Blog
//                    if ticketTableView.contentOffset.y >= ticketTableView.contentSize.height - ticketTableView.bounds.size.height{
                        if (!isPageRefresing5  && limit*pageNumber5 < totalItems5){
                            if Reachabable.isConnectedToNetwork() {
                                updateScrollFlag5 = false
                                pageNumber5 += 1
                                isPageRefresing5 = true
                                ticketTableView.tableFooterView?.isHidden = false
                              //  if searchDic.count == 0{
                                    browseEntries1()
                               // }
                            }
                        }
                        else
                        {
                            ticketTableView.tableFooterView?.isHidden = true
                    }
                  //  }
                }
            }
            
        }
        
    }
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (limit*pageNumber < totalItems)
        {
            return 0
        }
        else
        {
            return 0.00001
        }
    }
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        
        return 0.00001
        
        
    }
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView.tag == 101
        {
            if dynamicRowHeight[indexPath.row] != nil
            {
                return dynamicRowHeight[indexPath.row]! - 20
            }
            else
            {
                return 75
            }
        }
        else
        {
            let row = (indexPath as NSIndexPath).row as Int
            if eventBrowseType==1
            {
                return 160.0
            }
            else if eventBrowseType == 2
            {
                if (kFrequencyAdsInCells_advancedevent > 4 &&  nativeAdArray.count > 0 && (((indexPath as NSIndexPath).row % kFrequencyAdsInCells_advancedevent) == (kFrequencyAdsInCells_advancedevent)-1))
                {
                    if adsType_advancedevent == 2{
                        guard (UIDevice.current.userInterfaceIdiom != .pad) else {
                            return adsCellheight + 5
                        }
                        return adsCellheight + 5
                    }
                    else{
                    if(UIDevice.current.userInterfaceIdiom != .pad)
                    {
                        return adsCellheight
                    }
                    else
                    {
                        return 285.0
                    }
                    }
                }
                else
                {
                    return 265.0
                }
            }
            else
            {
            if (kFrequencyAdsInCells_advancedevent > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advancedevent) == (kFrequencyAdsInCells_advancedevent)-1))
            {
                if adsType_advancedevent == 2{
                    guard (UIDevice.current.userInterfaceIdiom != .pad) else {
                        return adsCellheight + 5
                    }
                    return adsCellheight + 5
                }
                else{
                if(UIDevice.current.userInterfaceIdiom != .pad)
                {
                    return adsCellheight
                }
                }
            }
            return 265.0
        }
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if adsType_advancedevent == 2{
            
            var row = indexPath.row as Int
            if (kFrequencyAdsInCells_advancedevent > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advancedevent) == (kFrequencyAdsInCells_advancedevent)-1))
            {
                //            displyedAdsCount = (row / kFrequencyAdsInCells_feeds)
                //            row = row - displyedAdsCount
                
                if let cell1 = cell as? NativeEventCell
                {
                    var Adcount: Int = 0
                    Adcount = row/(kFrequencyAdsInCells_advancedevent-1)
                    
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
        if adsType_advancedevent == 2{
            if tableView.tag != 11
            {
                
                let row = indexPath.row as Int
                if  (kFrequencyAdsInCells_advancedevent > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advancedevent) == (kFrequencyAdsInCells_advancedevent)-1))
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
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView.tag == 101
        {
            return ticketResponse.count
        }
        else{
            // For showing facebook ads count
            var rowcount = Int()
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                rowcount = 2*(kFrequencyAdsInCells_advancedevent-1)
            }
            else
            {
                rowcount = (kFrequencyAdsInCells_advancedevent-1)
            }
            if eventBrowseType == 0
            {
                
                if nativeAdArray.count > 0
                {
                    
                    if eventResponse.count > rowcount
                    {
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            let b = Int(ceil(Float(eventResponse.count)/2))
                            adsCount = b/(kFrequencyAdsInCells_advancedevent-1)
                            if adsCount > 1 || eventResponse.count%2 != 0
                            {
                                adsCount = adsCount/2
                            }
                            let Totalrowcount = adsCount+b
                            if b%(kFrequencyAdsInCells_advancedevent-1) == 0 && eventResponse.count % 2 != 0
                            {
                                if adsCount%2 != 0
                                {
                                    return Totalrowcount - 1
                                }
                            }
                            else if eventResponse.count % 2 != 0 && adsCount % 2 == 0
                            {
                                
                                return Totalrowcount - 1
                            }
                            return Totalrowcount
                        }
                        else
                        {
                            let b = eventResponse.count
                            adsCount = b/(kFrequencyAdsInCells_advancedevent-1)
                            let Totalrowcount = adsCount+b
                            if Totalrowcount % kFrequencyAdsInCells_advancedevent == 0
                            {
                                return Totalrowcount-1
                            }
                            else
                            {
                                return Totalrowcount
                            }
                            
                        }
                    }
                    else
                    {
                        
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            return Int(ceil(Float(eventResponse.count)/2))
                        }
                        else
                        {
                            return eventResponse.count
                        }
                    }
                    
                }
                
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    return Int(ceil(Float(eventResponse.count)/2))
                }
                else
                {
                    return eventResponse.count
                }
                
            }
            else if eventBrowseType == 1
            {
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    return Int(ceil(Float(categoryResponse.count)/2))
                }
                else
                {
                    return Int(ceil(Float(categoryResponse.count)/2))
                }
                
            }
            else if eventBrowseType == 2
            {
                if nativeAdArray.count > 0
                {
                    
                    if myeventResponse.count > rowcount
                    {
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            let b = Int(ceil(Float(myeventResponse.count)/2))
                            adsCount = b/(kFrequencyAdsInCells_advancedevent-1)
                            if adsCount > 1 || myeventResponse.count%2 != 0
                            {
                                adsCount = adsCount/2
                            }
                            let Totalrowcount = adsCount+b
                            if b%(kFrequencyAdsInCells_advancedevent-1) == 0 || myeventResponse.count % 2 != 0
                            {
                                if adsCount%2 != 0
                                {
                                    return Totalrowcount - 1
                                }
                            }
                            else if myeventResponse.count % 2 != 0 && adsCount % 2 == 0
                            {
                                
                                return Totalrowcount - 1
                            }
                            return Totalrowcount
                        }
                        else
                        {
                            let b = myeventResponse.count
                            adsCount = b/(kFrequencyAdsInCells_advancedevent-1)
                            let Totalrowcount = adsCount+b
                            if Totalrowcount % kFrequencyAdsInCells_advancedevent == 0
                            {
                                return Totalrowcount-1
                            }
                            else
                            {
                                return Totalrowcount
                            }
                            
                        }
                        
                    }
                    else
                    {
                        
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            return Int(ceil(Float(myeventResponse.count)/2))
                        }
                        else
                        {
                            return myeventResponse.count
                        }
                    }
                    
                }
                
                
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    return Int(ceil(Float(myeventResponse.count)/2))
                }
                else
                {
                    return myeventResponse.count
                }
                
            }
        }
        
        return eventResponse.count
        
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView.tag == 101 // Myticket table
        {
            let row = indexPath.row as Int
            
            var ticketInfo:NSDictionary
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            for ob in cell.subviews{
                if ob.tag != 500 && ob.tag != 501 && ob.tag != 502 {
                    
                    if ob is UILabel {
                        ob.removeFromSuperview()
                    }
                }
            }
            
            ticketInfo = ticketResponse[row] as! NSDictionary
            cell.imgUser.contentMode = .scaleAspectFill
            cell.imgUser.frame = CGRect(x:5, y:7, width:60, height:60)
            // Set Blog Title
            cell.labTitle.frame = CGRect(x:cell.imgUser.bounds.width + 10, y:10,width:(UIScreen.main.bounds.width - 75) , height:100)
            cell.labTitle.text = ticketInfo["event_title"] as? String
            cell.labTitle.numberOfLines = 2
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
            cell.labTitle.sizeToFit()
            
            if let postedDate = ticketInfo["creation_date"] as? String{
                let date = dateDifferenceWithEventTime(postedDate)
                var DateC = date.components(separatedBy: ",")
                var tempInfo = ""
                
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
                
                cell.labMessage.frame = CGRect(x:cell.imgUser.bounds.width + 10, y:cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5,width:(UIScreen.main.bounds.width - 75) , height:100)
                let labMsg = String(format: NSLocalizedString("Start date: %@", comment: ""), tempInfo)
                
                
                cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                    // TODO: Clean this up..
                    return mutableAttributedString!
                })
            }
            
            cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labMessage.sizeToFit()
            cell.labMessage.font = UIFont(name: fontName, size: FONTSIZENormal)
            
            if let orderInfo = ticketInfo["order_info_ios"] as? NSArray
            {
                var height1 = getBottomEdgeY(inputView: cell.labMessage) + 2
                
                dynamicHeight = 75
                
                for i in stride(from: 0, to: orderInfo.count, by: 1){
                    if let dic = orderInfo[i] as? NSDictionary{
                        
                        for(infoHeading,v) in dic{
                            //print(infoHeading)
                            //print(v)
                            memberLocation = createLabel(CGRect(x: cell.labMessage.frame.origin.x, y: height1, width: (UIScreen.main.bounds.width - 150), height: 15), text: " ", alignment: .left, textColor: textColorMedium)
                            memberLocation.font = UIFont(name: fontName, size:FONTSIZENormal)
                            memberLocation.text = "\((infoHeading as? String)!): \((v as? Int)!)"
                            memberLocation.textColor = textColorMedium
                            memberLocation.lineBreakMode = NSLineBreakMode.byTruncatingTail
                            memberLocation.tag = i
                            memberLocation.sizeToFit()
                            dynamicHeight = dynamicHeight + 20
                            height1 += 20
                            cell.addSubview(memberLocation)
                        }
                    }
                }
                
                dynamicRowHeight[indexPath.row] = dynamicHeight
            }
            
            // Set Blog Owner Image
            if ticketInfo["image"] != nil {
            if let url = NSURL(string: ticketInfo["image"] as! String){

                cell.imgUser.kf.indicatorType = .activity
                (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url as URL?, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
            }
            }
            return cell
            
        }
        else
        {
            var row = (indexPath as NSIndexPath).row as Int
            let totalRows = eventResponse.count + adsCount
            let totalRows1 = myeventResponse.count + adsCount
            if (eventBrowseType==1 && categoryResponse.count > (indexPath.row - 1))
            {
                
                let cell = CategoryTableView.dequeueReusableCell(withIdentifier: "Cellone", for: indexPath) as! CategoryTableViewCell
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
                                    cell.classifiedImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        
                                    })
                                }
                                
                                
                            }
                        }
                        
                        // LHS
                        cell.DiaryName.text = imageInfo["category_name"] as? String
                        cell.contentSelection.tag = index//imageInfo["category_id"] as! Int
                        cell.contentSelection.addTarget(self, action: #selector(AdvancedEventViewController.showSubCategory(_:)), for: .touchUpInside)
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
            else if (eventBrowseType == 2 && totalRows1 > (indexPath.row - 1 - adsCount))
            {
                if (kFrequencyAdsInCells_advancedevent > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advancedevent) == (kFrequencyAdsInCells_advancedevent)-1))
                {  // or 9 == if you don't want the first cell to be an ad!
                    myeventTableView.register(NativeEventCell.self, forCellReuseIdentifier: "Cell1")
                    let cell = myeventTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeEventCell
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                    cell.backgroundColor = tableViewBgColor
                    var Adcount: Int = 0
                    Adcount = row/(kFrequencyAdsInCells_advancedevent-1)
                    
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
                        if adsType_advancedevent == 2{
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
                        if adsType_advancedevent == 1 {
                            cell.cellView.frame.origin.y = 5
                            adsCellheight = cell.cellView.frame.size.height + 10
                        }
                        else {
                            adsCellheight = cell.cellView.frame.size.height + 5
                        }
                        cell.cellView.frame.size.height = view.frame.size.height
                        
                    }
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        
                        
                        cell.lineView2.isHidden = false
                        cell.dateView2.backgroundColor = navColor
                        cell.btnDate1.addTarget(self, action: #selector(AdvancedEventViewController.DateAction(_:)), for: .touchUpInside)
                        var eventInfo2:NSDictionary!
                        let adcount = row/kFrequencyAdsInCells_advancedevent
                        if(myeventResponse.count > (row*2-adcount))
                        {
                            eventInfo2 = myeventResponse[(row*2-adcount)] as! NSDictionary
                            cell.dateView2.isHidden = false
                            cell.titleView2.isHidden = false
                            cell.cellView2.isHidden = false
                            cell.contentSelection2.isHidden = false
                            cell.contentSelection2.tag = (row*2-adcount)
                            cell.hostSelection2.tag = (row*2-adcount)
                            cell.menuButton2.tag = (row*2-adcount)
                            cell.btnDate1.tag = (row*2-adcount)
                            if eventBrowseType==3
                            {
                                
                                
                                cell.gutterMenu2.isHidden = false
                                cell.gutterMenu2.tag = (row*2-adcount)
                                cell.cellView2.frame.size.height = 280
                                cell.titleView2.frame.size.height = 100
                                cell.dateView2.frame.size.height = cell.titleView2.frame.size.height
                                cell.lineView2.frame.origin.y = cell.cellView2.frame.size.height
                                if((fromTab == true) && (hostCheckId != nil))
                                {
                                    cell.gutterMenu2.isHidden = true
                                }
                                else
                                {
                                    cell.gutterMenu2.isHidden = false
                                    cell.gutterMenu2.addTarget(self, action:#selector(AdvancedEventViewController.showGutterMenu(_:)) , for: .touchUpInside)
                                }
                                eventTableView.rowHeight = 280
                                cell.btnMembercount2.isHidden = false
                                cell.btnviewcount2.isHidden = false
                                cell.btnlikecount2.isHidden = false
                                cell.lblMembercount2.isHidden = false
                                cell.lblviewcount2.isHidden = false
                                cell.lbllikecount2.isHidden = false
                                
                                cell.cellView2.frame.size.height = 280
                                cell.titleView2.frame.size.height = 100
                                cell.dateView2.frame.size.height = cell.titleView2.frame.size.height
                                cell.lineView2.frame.origin.y = cell.cellView.frame.size.height
                                
                                
                            }
                            
                        }
                        else
                        {
                            cell.cellView2.isHidden = true
                            cell.dateView2.isHidden = true
                            cell.contentSelection2.isHidden = true
                            cell.titleView2.isHidden = true
                            return cell
                        }
                        
                        
                        
                        cell.hostImage2.isHidden = false
                        cell.hostSelection2.isHidden = false
                        cell.hostSelection2.isUserInteractionEnabled = true
                        
                        // Select Event Action
                        cell.contentSelection2.addTarget(self, action: #selector(AdvancedEventViewController.showEvent(_:)), for: .touchUpInside)
                        // Set MenuAction
                        cell.btnTittle2.addTarget(self, action:#selector(AdvancedEventViewController.showEvent(_:)) , for: .touchUpInside)
                        cell.menuButton2.addTarget(self, action:#selector(AdvancedEventViewController.showGutterMenu(_:)) , for: .touchUpInside)
                        //  cell.menuButton2.addTarget(self, action:Selector(("showEventMenu:")) , for: .touchUpInside)
                        cell.hostSelection2.addTarget(self, action:#selector(AdvancedEventViewController.hostProfile(_:)), for: .touchUpInside)
                        
                        
                        
                        cell.contentImage2.frame.size.height = 180
                        cell.contentSelection2.frame.size.height = 180
                        
                        
                        // Set Event Image
                        if let photoId = eventInfo2["photo_id"] as? Int{
                            
                            if photoId != 0{
                                cell.contentImage2.image = nil
                                let url = URL(string: eventInfo2["image"] as! NSString as String)
                                
                                if url != nil {
                                    cell.contentImage2.image =  UIImage(named: "nophoto_diary_thumb_profile.png")
                                      cell.contentImage2.kf.indicatorType = .activity
                                    (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                                    
                                }
                                
                            }
                            else
                            {
                                cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                            }
                        }
                        
                        //Set Profile Image
                        if let hostId2 = eventInfo2["host_id"] as? Int
                        {
                            
                            if hostId2 != 0
                            {
                                cell.hostImage2.image = nil
                                cell.hostImage2.backgroundColor = placeholderColor
                                var hostInfo2:NSDictionary!
                                if let _ = eventInfo2["hosted_by"] as? NSDictionary
                                {
                                    hostInfo2 = eventInfo2["hosted_by"] as! NSDictionary
                                    let url = URL(string: hostInfo2["image"] as! NSString as String)
                                    if url != nil {

                                        cell.hostImage2.kf.indicatorType = .activity
                                        (cell.hostImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                        cell.hostImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                            let image1 = image?.crop(to: cell.hostImage2.frame.size)
                                            cell.hostImage2.image = image1
                                        })
                                        
                                        
                                    }
                                    
                                }
                                else
                                {
                                    cell.hostImage2.isHidden = true
                                    cell.hostSelection2.isHidden = true
                                    
                                }
                            }
                            else
                            {
                                cell.hostImage2.image = nil
                                cell.hostImage2.image =  imageWithImage( UIImage(named: "")!, scaletoWidth: cell.hostImage2.bounds.width)
                                
                            }
                        }
                        else
                        {
                            cell.hostImage2.image = nil
                        }
                        
                        // Set Event Name
                        
                        let name = eventInfo2["title"] as? String
                        var tempInfo = ""
                        if let eventDate = eventInfo2["starttime"] as? String{
                            
                            let dateMonth = dateDifferenceWithTime(eventDate)
                            var dateArrayMonth = dateMonth.components(separatedBy: ", ")
                            if dateArrayMonth.count > 1{
                                cell.dateLabel3.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                                
                                cell.dateLabel3.numberOfLines = 0
                                cell.dateLabel3.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                                cell.dateLabel3.textColor = textColorPrime
                                cell.dateLabel3.font = UIFont(name: "FontAwesome", size: 22)
                            }
                            
                            let date = dateDifferenceWithEventTime(eventDate)
                            var DateC = date.components(separatedBy: ", ")
                            tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                            if DateC.count > 3{
                                tempInfo += " at \(DateC[3]) "
                            }
                            if eventInfo2["isRepeatEvent"] as? Int == 1
                            {
                                tempInfo += "(Multiple Dates Available)"
                            }
                            
                        }
                        else{
                            cell.dateView2.isHidden = true
                        }
                        
                        cell.titleLabel2.frame = CGRect(x: 10, y: 0, width: (cell.contentImage2.bounds.width-110), height: 30)
                        
                        cell.titleLabel2.text = "\(name!)"
                        cell.titleLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        
                        if let membercount2 = eventInfo2["member_count"] as? Int
                        {
                            cell.lblMembercount2.text = "\(membercount2)"
                        }
                        
                        if let viewcount2 = eventInfo2["view_count"] as? Int
                        {
                            cell.lblviewcount2.text = "\(viewcount2)"
                        }
                        
                        if let likecount2 = eventInfo2["like_count"] as? Int
                        {
                            cell.lbllikecount2.text = "\(likecount2)"
                        }
                        
                        
                        
                        let location = eventInfo2["location"] as? String
                        if location != "" && location != nil{
                            
                            cell.locLabel2.isHidden = false
                            
                            cell.locLabel2.frame = CGRect(x: 10, y: 25, width: (cell.contentImage2.bounds.width-110), height: 20)
                            cell.locLabel2.text = "\u{f041}   \(location!)"
                            // cell.locLabel.textColor = textColorLight
                            cell.locLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                            cell.locLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                            
                            
                            if eventInfo2["isRepeatEvent"] as? Int == 1
                            {
                                cell.dateLabel2.frame = CGRect(x: 10, y: 40, width: (cell.contentImage2.bounds.width-110), height: 40)
                                cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                
                                cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                
                                cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                            }
                            else
                            {
                                cell.dateLabel2.frame = CGRect(x: 10, y: 45, width: (cell.contentImage2.bounds.width-110), height: 20)
                                
                                cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                
                                cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                
                                cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                            }
                            
                            let stringValue = "\u{f073}  \(tempInfo)"
                            let attrString = NSMutableAttributedString(string: stringValue)
                            let style = NSMutableParagraphStyle()
                            style.minimumLineHeight = 14 // change line spacing between each line like 30 or 40
                            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attrString.length))
                            cell.dateLabel2.attributedText = attrString
                            cell.dateLabel2.textAlignment = NSTextAlignment.left
                            cell.dateLabel2.numberOfLines = 0
                            
                            cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                            
                            
                            cell.dateLabel3.frame = CGRect(x: 0, y: (cell.titleView2.frame.size.height-60)/2, width: 70, height: 60)
                            
                            
                            
                        }
                        
                        if location == "" || location == nil{
                            
                            cell.locLabel2.isHidden = true
                            
                            if eventInfo2["isRepeatEvent"] as? Int == 1
                            {
                                cell.dateLabel2.frame = CGRect(x: 10, y: 30, width: (cell.contentImage2.bounds.width-110), height: 40)
                                
                                cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                
                                cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                
                                cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                
                                
                            }
                            else
                            {
                                cell.dateLabel2.frame = CGRect(x: 10, y: 35, width: (cell.contentImage2.bounds.width-110), height: 20)
                                
                                cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                
                                cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                
                                cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                
                                
                            }
                            
                            let stringValue = "\u{f073}  \(tempInfo)"
                            let attrString = NSMutableAttributedString(string: stringValue)
                            let style = NSMutableParagraphStyle()
                            style.minimumLineHeight = 14 // change line spacing between each line like 30 or 40
                            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attrString.length))
                            cell.dateLabel2.attributedText = attrString
                            cell.dateLabel2.textAlignment = NSTextAlignment.left
                            cell.dateLabel2.numberOfLines = 0
                            
                            cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                            cell.dateLabel3.frame = CGRect(x: 0, y: (cell.titleView2.frame.size.height-60)/2, width: 70, height: 60)
                            
                        }
                        
                        // Set Menu
                        if eventBrowseType != 2 {
                            cell.menuButton2.isHidden = true
                            
                        }else{
                            cell.menuButton2.isHidden = true
                            
                        }
                        
                        
                        return cell
                    }
                    
                    return cell
                    
                }
                else
                {
                    if kFrequencyAdsInCells_advancedevent > 4 && nativeAdArray.count > 0
                    {
                        row = row - (row / kFrequencyAdsInCells_advancedevent)
                    }
                    let cell = myeventTableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath) as! EventViewTableViewCell
                    cell.selectionStyle = UITableViewCell.SelectionStyle.none
                    cell.lineView.isHidden = false
                    cell.dateView.backgroundColor = navColor
                    cell.btnDate.addTarget(self, action: #selector(AdvancedEventViewController.DateAction(_:)), for: .touchUpInside)
                    
                    cell.backgroundColor = tableViewBgColor
                    
                    cell.hostImage.isHidden = false
                    cell.hostSelection.isHidden = false
                    cell.hostSelection.isUserInteractionEnabled = true
                    
                    var eventInfo:NSDictionary!
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        var adcount = 0 as Int
                        if (kFrequencyAdsInCells_advancedevent > 4 && nativeAdArray.count > 0)
                        {
                            adcount = row/(kFrequencyAdsInCells_advancedevent-1)
                            if(myeventResponse.count > ((row)*2+adcount))
                            {
                                eventInfo = myeventResponse[((row)*2+adcount)] as! NSDictionary
                                cell.contentSelection.tag = ((row)*2+adcount)
                                cell.btnTittle.tag = ((row)*2+adcount)
                                cell.menu.tag = ((row)*2+adcount)
                                cell.hostSelection.tag = (row*2)+adcount
                                cell.btnDate.tag = (row*2)+adcount
                                
                            }
                        }
                        else
                        {
                            if(eventResponse.count > (row)*2)
                            {
                                eventInfo = myeventResponse[(row)*2] as! NSDictionary
                                cell.contentSelection.tag = (row)*2
                                cell.btnTittle.tag = (row)*2
                                cell.menu.tag = (row)*2
                                cell.hostSelection.tag = (row*2)
                                cell.btnDate.tag = (row*2)
                                
                            }
                        }
                        
                        if eventBrowseType==3
                        {
                            cell.gutterMenu.tag = row*2+adcount
                            cell.gutterMenu.isHidden = false
                            cell.cellView.frame.size.height = 280
                            cell.titleView.frame.size.height = 100
                            cell.dateView.frame.size.height = cell.titleView.frame.size.height
                            cell.lineView.frame.origin.y = cell.cellView.frame.size.height
                            
                            if((fromTab == true) && (hostCheckId != nil))
                            {
                                cell.gutterMenu.isHidden = true
                            }
                            else
                            {
                                cell.gutterMenu.isHidden = false
                                cell.gutterMenu.addTarget(self, action:#selector(AdvancedEventViewController.showGutterMenu(_:)) , for: .touchUpInside)
                            }
                            
                            eventTableView.rowHeight = 270
                            cell.btnMembercount.isHidden = false
                            cell.btnviewcount.isHidden = false
                            cell.btnlikecount.isHidden = false
                            cell.lblMembercount.isHidden = false
                            cell.lblviewcount.isHidden = false
                            cell.lbllikecount.isHidden = false
                            
                            
                            
                            cell.cellView2.frame.size.height = 280
                            cell.titleView2.frame.size.height = 100
                            cell.dateView2.frame.size.height = cell.titleView.frame.size.height
                            cell.lineView2.frame.origin.y = cell.cellView.frame.size.height
                        }
                    }
                    else
                    {
                        eventInfo = myeventResponse[row] as! NSDictionary
                        cell.contentSelection.tag = row
                        cell.btnTittle.tag = row
                        cell.hostSelection.tag = row
                        cell.btnDate.tag = row
                        cell.menuButton.tag = row
                        cell.gutterMenu.tag = row
                        
                        if eventBrowseType==3
                        {
                            cell.gutterMenu.isHidden = false
                            cell.cellView.frame.size.height = 280
                            cell.titleView.frame.size.height = 100
                            cell.dateView.frame.size.height = cell.titleView.frame.size.height
                            cell.lineView.frame.origin.y = cell.cellView.frame.size.height
                            if((fromTab == true) && (hostCheckId != nil))
                            {
                                cell.gutterMenu.isHidden = true
                            }
                            else
                            {
                                cell.gutterMenu.isHidden = false
                                cell.gutterMenu.addTarget(self, action:#selector(AdvancedEventViewController.showGutterMenu(_:)) , for: .touchUpInside)
                            }
                            eventTableView.rowHeight = 280
                            cell.btnMembercount.isHidden = false
                            cell.btnviewcount.isHidden = false
                            cell.btnlikecount.isHidden = false
                            cell.lblMembercount.isHidden = false
                            cell.lblviewcount.isHidden = false
                            cell.lbllikecount.isHidden = false
                            
                        }
                        else
                        {
                            cell.cellView.frame.size.height = 260
                            cell.titleView.frame.size.height = 80
                            cell.dateView.frame.size.height = cell.titleView.frame.size.height
                            cell.lineView.frame.origin.y = cell.cellView.frame.size.height
                            cell.gutterMenu.isHidden = true
                            eventTableView.rowHeight = 260
                            cell.btnMembercount.isHidden = true
                            cell.btnviewcount.isHidden = true
                            cell.btnlikecount.isHidden = true
                            cell.lblMembercount.isHidden = true
                            cell.lblviewcount.isHidden = true
                            cell.lbllikecount.isHidden = true
                            
                        }
                        
                    }
                    
                    
                    
                    //Select Event Action
                    cell.contentSelection.addTarget(self, action: #selector(AdvancedEventViewController.showEvent(_:)), for: .touchUpInside)
                    // Set MenuAction
                    cell.menuButton.addTarget(self, action:#selector(AdvancedEventViewController.showGutterMenu(_:)) , for: .touchUpInside)
                    // cell.menuButton.addTarget(self, action:Selector(("showEventMenu:")) , for: .touchUpInside)
                    cell.hostSelection.addTarget(self, action:#selector(AdvancedEventViewController.hostProfile(_:)), for: .touchUpInside)
                    cell.btnTittle.addTarget(self, action:#selector(AdvancedEventViewController.showEvent(_:)) , for: .touchUpInside)
                    cell.contentImage.frame.size.height = 180
                    cell.contentSelection.frame.origin.y = 40
                    cell.contentSelection.frame.size.height = 140
                    //  cell.contentSelection.frame.size.height = 180
                    //
                    // Set Event Image
                    
                    if let photoId = eventInfo["photo_id"] as? Int
                    {
                        
                        if photoId != 0
                        {
                            cell.contentImage.image = nil
                            cell.contentImage.backgroundColor = placeholderColor
                            let url = URL(string: eventInfo["image"] as! NSString as String)
                            if url != nil {
                                 cell.contentImage.kf.indicatorType = .activity
                                (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.contentImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
                                
                            }
                            
                        }
                        else
                        {
                            cell.contentImage.image = nil
                            cell.contentImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                            
                        }
                    }
                    else
                    {
                        cell.contentImage.image = nil
                    }
                    
                    
                    
                    //Set Profile Image
                    if let hostId = eventInfo["host_id"] as? Int
                    {
                        
                        if hostId != 0
                        {
                            cell.hostImage.image = nil
                            cell.hostImage.backgroundColor = placeholderColor
                            var hostInfo:NSDictionary!
                            if let _ = eventInfo["hosted_by"] as? NSDictionary
                            {
                                hostInfo = eventInfo["hosted_by"] as! NSDictionary
                                let url = URL(string: hostInfo["image"] as! NSString as String)
                                if url != nil
                                {
                                    cell.hostImage.kf.indicatorType = .activity
                                    (cell.hostImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    cell.hostImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        let image1 = image?.crop(to: cell.hostImage.frame.size)
                                        cell.hostImage.image = image1
                                    })
                                }
                                
                            }
                            else
                            {
                                cell.hostImage.isHidden = true
                                cell.hostSelection.isHidden = true
                                
                            }
                        }
                        else
                        {
                            cell.hostImage.image = nil
                            cell.hostImage.image =  imageWithImage( UIImage(named: "user_image")!, scaletoWidth: cell.hostImage.bounds.width)
                            
                        }
                    }
                    else
                    {
                        cell.hostImage.image = nil
                    }
                    
                    let name = eventInfo["title"] as? String
                    var tempInfo = ""
                    
                    
                    if let eventDate = eventInfo["starttime"] as? String
                    {
                        
                        let dateMonth = dateDifferenceWithTime(eventDate)
                        var dateArrayMonth = dateMonth.components(separatedBy: ", ")
                        if dateArrayMonth.count > 1{
                            cell.dateLabel1.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                            
                            cell.dateLabel1.numberOfLines = 0
                            cell.dateLabel1.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                            cell.dateLabel1.textColor = textColorPrime
                            cell.dateLabel1.font = UIFont(name: "FontAwesome", size: 22)
                        }
                        
                        let date = dateDifferenceWithEventTime(eventDate)
                        var DateC = date.components(separatedBy: ", ")
                        tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                        if DateC.count > 3{
                            tempInfo += " at \(DateC[3]) "
                        }
                        if eventInfo["isRepeatEvent"] as? Int == 1
                        {
                            tempInfo += "(Multiple Dates Available)"
                        }
                    }
                    
                    cell.titleLabel.frame = CGRect(x: 10, y: 0, width: (cell.contentImage.bounds.width-110), height: 30)
                    
                    cell.titleLabel.text = "\(name!)"
                    cell.titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    // cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
                    
                    
                    
                    if let membercount = eventInfo["member_count"] as? Int
                    {
                        cell.lblMembercount.text = "\(membercount)"
                    }
                    
                    if let viewcount = eventInfo["view_count"] as? Int
                    {
                        cell.lblviewcount.text = "\(viewcount)"
                    }
                    
                    if let likecount = eventInfo["like_count"] as? Int
                    {
                        cell.lbllikecount.text = "\(likecount)"
                    }
                    
                    
                    let location = eventInfo["location"] as? String
                    if location != "" && location != nil
                    {
                        
                        cell.locLabel.isHidden = false
                        
                        cell.locLabel.frame = CGRect(x: 10, y: 25, width: (cell.contentImage.bounds.width-110), height: 20)
                        cell.locLabel.text = "\u{f041}   \(location!)"
                        // cell.locLabel.textColor = textColorLight
                        cell.locLabel.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                        cell.locLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        
                        if eventInfo["isRepeatEvent"] as? Int == 1
                        {
                            cell.dateLabel.frame = CGRect(x: 10, y: 40, width: (cell.contentImage.bounds.width-110), height: 40)
                            
                            cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                            cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                            
                            cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                            cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                            
                            cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                            cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                        }
                        else
                        {
                            cell.dateLabel.frame = CGRect(x: 10, y: 45, width: (cell.contentImage.bounds.width-110), height: 20)
                            
                            cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                            cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                            
                            cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                            cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                            
                            cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                            cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                        }
                        
                        let stringValue = "\u{f073}  \(tempInfo)"
                        let attrString = NSMutableAttributedString(string: stringValue)
                        let style = NSMutableParagraphStyle()
                        style.minimumLineHeight = 14 // change line spacing between each line like 30 or 40
                        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attrString.length))
                        cell.dateLabel.attributedText = attrString
                        cell.dateLabel.textAlignment = NSTextAlignment.left
                        cell.dateLabel.numberOfLines = 0
                        
                        cell.dateLabel.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                        
                        cell.dateLabel1.frame = CGRect(x: 0, y: (cell.titleView.frame.size.height-60)/2, width: 70, height: 60)
                        
                        
                    }
                    
                    if location == "" || location == nil{
                        
                        cell.locLabel.isHidden = true
                        if eventInfo["isRepeatEvent"] as? Int == 1
                        {
                            cell.dateLabel.frame = CGRect(x: 10, y: 30, width: (cell.contentImage.bounds.width-110), height: 40)
                            
                            cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                            cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                            
                            
                            cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                            cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                            
                            cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                            cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                            
                        }
                        else
                        {
                            cell.dateLabel.frame = CGRect(x: 10, y: 35, width: (cell.contentImage.bounds.width-110), height: 20)
                            
                            cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                            cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                            
                            
                            cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                            cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                            
                            cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                            cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                            
                        }
                        
                        let stringValue = "\u{f073}  \(tempInfo)"
                        let attrString = NSMutableAttributedString(string: stringValue)
                        let style = NSMutableParagraphStyle()
                        style.minimumLineHeight = 14 // change line spacing between each line like 30 or 40
                        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attrString.length))
                        cell.dateLabel.attributedText = attrString
                        cell.dateLabel.textAlignment = NSTextAlignment.left
                        cell.dateLabel.numberOfLines = 0
                        cell.dateLabel.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                        cell.dateLabel1.frame = CGRect(x: 0, y: (cell.titleView.frame.size.height-60)/2, width: 70, height: 60)
                        
                    }
                    
                    
                    // Set Menu
                    if eventBrowseType != 2 {
                        cell.menuButton.isHidden = true
                        
                    }
                    else
                    {
                        cell.menuButton.isHidden = false
                        
                    }
                    
                    // RHS
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        
                        
                        cell.lineView2.isHidden = false
                        cell.dateView2.backgroundColor = navColor
                        cell.btnDate1.addTarget(self, action: #selector(AdvancedEventViewController.DateAction(_:)), for: .touchUpInside)
                        var eventInfo2:NSDictionary!
                        var adcount = Int()
                        if (kFrequencyAdsInCells_advancedevent > 4 && nativeAdArray.count > 0)
                        {
                            adcount = row/(kFrequencyAdsInCells_advancedevent-1)
                        }
                        else
                        {
                            adcount = 0
                        }
                        
                        
                        if(myeventResponse.count > (row*2+1+adcount))
                        {
                            eventInfo2 = myeventResponse[(row*2+1+adcount)] as! NSDictionary
                            cell.dateView2.isHidden = false
                            cell.titleView2.isHidden = false
                            cell.cellView2.isHidden = false
                            cell.contentSelection2.isHidden = false
                            cell.contentSelection2.tag = (row*2+1+adcount)
                            cell.hostSelection2.tag = (row*2+1+adcount)
                            cell.menuButton2.tag = (row*2+1+adcount)
                            cell.btnDate1.tag = (row*2+1+adcount)
                            if eventBrowseType==3
                            {
                                
                                
                                cell.gutterMenu2.isHidden = false
                                cell.gutterMenu2.tag = (row*2+1+adcount)
                                cell.cellView2.frame.size.height = 280
                                cell.titleView2.frame.size.height = 100
                                cell.dateView2.frame.size.height = cell.titleView2.frame.size.height
                                cell.lineView2.frame.origin.y = cell.cellView2.frame.size.height
                                if((fromTab == true) && (hostCheckId != nil))
                                {
                                    cell.gutterMenu2.isHidden = true
                                }
                                else
                                {
                                    cell.gutterMenu2.isHidden = false
                                    cell.gutterMenu2.addTarget(self, action:#selector(AdvancedEventViewController.showGutterMenu(_:)) , for: .touchUpInside)
                                }
                                eventTableView.rowHeight = 280
                                cell.btnMembercount2.isHidden = false
                                cell.btnviewcount2.isHidden = false
                                cell.btnlikecount2.isHidden = false
                                cell.lblMembercount2.isHidden = false
                                cell.lblviewcount2.isHidden = false
                                cell.lbllikecount2.isHidden = false
                                
                                cell.cellView2.frame.size.height = 280
                                cell.titleView2.frame.size.height = 100
                                cell.dateView2.frame.size.height = cell.titleView.frame.size.height
                                cell.lineView2.frame.origin.y = cell.cellView.frame.size.height
                                
                                
                            }
                            
                        }
                        else
                        {
                            cell.cellView2.isHidden = true
                            cell.dateView2.isHidden = true
                            cell.contentSelection2.isHidden = true
                            cell.titleView2.isHidden = true
                            return cell
                        }
                        
                        
                        
                        cell.hostImage2.isHidden = false
                        cell.hostSelection2.isHidden = false
                        cell.hostSelection2.isUserInteractionEnabled = true
                        
                        // Select Event Action
                        cell.contentSelection2.addTarget(self, action: #selector(AdvancedEventViewController.showEvent(_:)), for: .touchUpInside)
                        // Set MenuAction
                        cell.btnTittle2.addTarget(self, action:#selector(AdvancedEventViewController.showEvent(_:)) , for: .touchUpInside)
                        cell.menuButton2.addTarget(self, action:#selector(AdvancedEventViewController.showGutterMenu(_:)) , for: .touchUpInside)
                        //  cell.menuButton2.addTarget(self, action:Selector(("showEventMenu:")) , for: .touchUpInside)
                        cell.hostSelection2.addTarget(self, action:#selector(AdvancedEventViewController.hostProfile(_:)), for: .touchUpInside)
                        
                        
                        
                        cell.contentImage2.frame.size.height = 180
                        cell.contentSelection2.frame.origin.y = 40
                        cell.contentSelection2.frame.size.height = 180
                        // cell.contentSelection2.frame.size.height = 180
                        
                        
                        // Set Event Image
                        if let photoId = eventInfo2["photo_id"] as? Int{
                            
                            if photoId != 0{
                                cell.contentImage2.image = nil
                                let url = URL(string: eventInfo2["image"] as! NSString as String)
                                
                                if url != nil {
                                    cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                                      cell.contentImage2.kf.indicatorType = .activity
                                    (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                                    
                                }
                                
                            }
                            else
                            {
                                cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                            }
                        }
                        
                        
                        //Set Profile Image
                        if let hostId2 = eventInfo2["host_id"] as? Int
                        {
                            
                            if hostId2 != 0
                            {
                                cell.hostImage2.image = nil
                                cell.hostImage2.backgroundColor = placeholderColor
                                var hostInfo2:NSDictionary!
                                if let _ = eventInfo2["hosted_by"] as? NSDictionary
                                {
                                    hostInfo2 = eventInfo2["hosted_by"] as! NSDictionary
                                    let url = URL(string: hostInfo2["image"] as! NSString as String)
                                    if url != nil {
                                        cell.hostImage2.kf.indicatorType = .activity
                                        (cell.hostImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                        cell.hostImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                            let image1 = image?.crop(to: cell.hostImage2.frame.size)
                                            cell.hostImage2.image = image1
                                        })
                                        
                                    }
                                    
                                }
                                else
                                {
                                    cell.hostImage2.isHidden = true
                                    cell.hostSelection2.isHidden = true
                                    
                                }
                            }
                            else
                            {
                                cell.hostImage2.image = nil
                                cell.hostImage2.image =  imageWithImage( UIImage(named: "")!, scaletoWidth: cell.hostImage2.bounds.width)
                                
                            }
                        }
                        else
                        {
                            cell.hostImage2.image = nil
                        }
                        
                        // Set Event Name
                        
                        let name = eventInfo2["title"] as? String
                        var tempInfo = ""
                        if let eventDate = eventInfo2["starttime"] as? String{
                            
                            let dateMonth = dateDifferenceWithTime(eventDate)
                            var dateArrayMonth = dateMonth.components(separatedBy: ", ")
                            if dateArrayMonth.count > 1{
                                cell.dateLabel3.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                                
                                cell.dateLabel3.numberOfLines = 0
                                cell.dateLabel3.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                                cell.dateLabel3.textColor = textColorPrime
                                cell.dateLabel3.font = UIFont(name: "FontAwesome", size: 22)
                            }
                            
                            let date = dateDifferenceWithEventTime(eventDate)
                            var DateC = date.components(separatedBy: ", ")
                            tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                            if DateC.count > 3{
                                tempInfo += " at \(DateC[3]) "
                            }
                            if eventInfo2["isRepeatEvent"] as? Int == 1
                            {
                                tempInfo += "(Multiple Dates Available)"
                            }
                            
                        }
                        else{
                            cell.dateView2.isHidden = true
                        }
                        
                        cell.titleLabel2.frame = CGRect(x: 10, y: 0, width: (cell.contentImage2.bounds.width-110), height: 30)
                        
                        cell.titleLabel2.text = "\(name!)"
                        cell.titleLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        
                        if let membercount2 = eventInfo2["member_count"] as? Int
                        {
                            cell.lblMembercount2.text = "\(membercount2)"
                        }
                        
                        if let viewcount2 = eventInfo2["view_count"] as? Int
                        {
                            cell.lblviewcount2.text = "\(viewcount2)"
                        }
                        
                        if let likecount2 = eventInfo2["like_count"] as? Int
                        {
                            cell.lbllikecount2.text = "\(likecount2)"
                        }
                        
                        let location = eventInfo2["location"] as? String
                        if location != "" && location != nil{
                            
                            cell.locLabel2.isHidden = false
                            
                            cell.locLabel2.frame = CGRect(x: 10, y: 25, width: (cell.contentImage2.bounds.width-110), height: 20)
                            cell.locLabel2.text = "\u{f041}   \(location!)"
                            // cell.locLabel.textColor = textColorLight
                            cell.locLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                            cell.locLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                            
                            
                            if eventInfo2["isRepeatEvent"] as? Int == 1
                            {
                                cell.dateLabel2.frame = CGRect(x: 10, y: 40, width: (cell.contentImage2.bounds.width-110), height: 40)
                                cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                
                                cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                
                                cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                            }
                            else
                            {
                                cell.dateLabel2.frame = CGRect(x: 10, y: 45, width: (cell.contentImage2.bounds.width-110), height: 20)
                                
                                cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                
                                cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                
                                cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                            }
                            
                            let stringValue = "\u{f073}  \(tempInfo)"
                            let attrString = NSMutableAttributedString(string: stringValue)
                            let style = NSMutableParagraphStyle()
                            style.minimumLineHeight = 14 // change line spacing between each line like 30 or 40
                            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attrString.length))
                            cell.dateLabel2.attributedText = attrString
                            cell.dateLabel2.textAlignment = NSTextAlignment.left
                            cell.dateLabel2.numberOfLines = 0
                            cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                            cell.dateLabel3.frame = CGRect(x: 0, y: (cell.titleView.frame.size.height-60)/2, width: 70, height: 60)
                            
                            
                            
                        }
                        
                        if location == "" || location == nil{
                            
                            cell.locLabel2.isHidden = true
                            
                            
                            if eventInfo["isRepeatEvent"] as? Int == 1
                            {
                                cell.dateLabel.frame = CGRect(x: 10, y: 30, width: (cell.contentImage.bounds.width-110), height: 40)
                                
                                cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                
                                
                                cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                
                                cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                
                            }
                            else
                            {
                                cell.dateLabel.frame = CGRect(x: 10, y: 35, width: (cell.contentImage.bounds.width-110), height: 20)
                                
                                cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                
                                
                                cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                
                                cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                
                            }
                            
                            
                            
                            if eventInfo2["isRepeatEvent"] as? Int == 1
                            {
                                cell.dateLabel2.frame = CGRect(x: 10, y: 30, width: (cell.contentImage2.bounds.width-110), height: 40)
                                
                                cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                
                                cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                
                                cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                
                                
                            }
                            else
                            {
                                cell.dateLabel2.frame = CGRect(x: 10, y: 35, width: (cell.contentImage2.bounds.width-110), height: 20)
                                
                                cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                
                                cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                
                                cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                
                                
                            }
                            let stringValue = "\u{f073}  \(tempInfo)"
                            let attrString = NSMutableAttributedString(string: stringValue)
                            let style = NSMutableParagraphStyle()
                            style.minimumLineHeight = 14 // change line spacing between each line like 30 or 40
                            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attrString.length))
                            cell.dateLabel2.attributedText = attrString
                            cell.dateLabel2.textAlignment = NSTextAlignment.left
                            cell.dateLabel2.numberOfLines = 0
                            
                            cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                            cell.dateLabel3.frame = CGRect(x: 0, y: (cell.titleView.frame.size.height-60)/2, width: 70, height: 60)
                            
                        }
                        
                        // Set Menu
                        if eventBrowseType != 2 {
                            cell.menuButton2.isHidden = true
                            
                        }else{
                            cell.menuButton2.isHidden = true
                            
                        }
                        
                        
                        return cell
                    }
                    return cell
                }
                
            }
            else
            {
                if  (eventBrowseType == 0 && totalRows > (indexPath.row - 1 - adsCount))
                {
                    var row = (indexPath as NSIndexPath).row as Int
                    
                    if (kFrequencyAdsInCells_advancedevent > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advancedevent) == (kFrequencyAdsInCells_advancedevent)-1))
                    {  // or 9 == if you don't want the first cell to be an ad!
                        eventTableView.register(NativeEventCell.self, forCellReuseIdentifier: "Cell1")
                        let cell = eventTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeEventCell
                        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                        cell.backgroundColor = tableViewBgColor
                        var Adcount: Int = 0
                        Adcount = row/(kFrequencyAdsInCells_advancedevent-1)
                        
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
                            if adsType_advancedevent == 2{
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
                            
                            cell.cellView.frame.size.height = view.frame.size.height
                            adsCellheight = cell.cellView.frame.size.height + 5
                        }
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            
                            
                            cell.lineView2.isHidden = false
                            cell.dateView2.backgroundColor = navColor
                            cell.btnDate1.addTarget(self, action: #selector(AdvancedEventViewController.DateAction(_:)), for: .touchUpInside)
                            var eventInfo2:NSDictionary!
                            let adcount = row/kFrequencyAdsInCells_advancedevent
                            if(eventResponse.count > (row*2-adcount))
                            {
                                eventInfo2 = eventResponse[(row*2-adcount)] as! NSDictionary
                                cell.dateView2.isHidden = false
                                cell.titleView2.isHidden = false
                                cell.cellView2.isHidden = false
                                cell.contentSelection2.isHidden = false
                                cell.contentSelection2.tag = (row*2-adcount)
                                cell.hostSelection2.tag = (row*2-adcount)
                                cell.menuButton2.tag = (row*2-adcount)
                                cell.btnDate1.tag = (row*2-adcount)
                                
                                cell.cellView2.frame.size.height = 260
                                cell.titleView2.frame.size.height = 80
                                cell.dateView2.frame.size.height = cell.titleView2.frame.size.height
                                cell.lineView2.frame.origin.y = cell.cellView2.frame.size.height
                                cell.gutterMenu2.isHidden = true
                                eventTableView.rowHeight = 260
                                cell.btnMembercount2.isHidden = true
                                cell.btnviewcount2.isHidden = true
                                cell.btnlikecount2.isHidden = true
                                cell.lblMembercount2.isHidden = true
                                cell.lblviewcount2.isHidden = true
                                cell.lbllikecount2.isHidden = true
                                
                            }
                            else
                            {
                                cell.cellView2.isHidden = true
                                cell.dateView2.isHidden = true
                                cell.contentSelection2.isHidden = true
                                cell.titleView2.isHidden = true
                                return cell
                            }
                            
                            cell.hostImage2.isHidden = false
                            cell.hostSelection2.isHidden = false
                            cell.hostSelection2.isUserInteractionEnabled = true
                            
                            // Select Event Action
                            cell.contentSelection2.addTarget(self, action: #selector(AdvancedEventViewController.showEvent(_:)), for: .touchUpInside)
                            // Set MenuAction
                            cell.btnTittle2.addTarget(self, action:#selector(AdvancedEventViewController.showEvent(_:)) , for: .touchUpInside)
                            cell.menuButton2.addTarget(self, action:#selector(AdvancedEventViewController.showGutterMenu(_:)) , for: .touchUpInside)
                            // cell.menuButton2.addTarget(self, action:Selector(("showEventMenu:")) , for: .touchUpInside)
                            cell.hostSelection2.addTarget(self, action:#selector(AdvancedEventViewController.hostProfile(_:)), for: .touchUpInside)
                            
                            
                            
                            cell.contentImage2.frame.size.height = 180
                            cell.contentSelection2.frame.size.height = 180
                            
                            
                            // Set Event Image
                            if let photoId = eventInfo2["photo_id"] as? Int{
                                
                                if photoId != 0{
                                    cell.contentImage2.image = nil
                                    let url = URL(string: eventInfo2["image"] as! NSString as String)
                                    
                                    if url != nil {
                                        cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                                          cell.contentImage2.kf.indicatorType = .activity
                                        (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                                        
                                    }
                                    
                                }
                                else
                                {
                                    cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                                }
                            }
                            
                            
                            //Set Profile Image
                            if let hostId2 = eventInfo2["host_id"] as? Int
                            {
                                
                                if hostId2 != 0
                                {
                                    cell.hostImage2.image = nil
                                    cell.hostImage2.backgroundColor = placeholderColor
                                    var hostInfo2:NSDictionary!
                                    if let _ = eventInfo2["hosted_by"] as? NSDictionary
                                    {
                                        hostInfo2 = eventInfo2["hosted_by"] as! NSDictionary
                                        let url = URL(string: hostInfo2["image"] as! NSString as String)
                                        if url != nil {
                                            cell.hostImage2.kf.indicatorType = .activity
                                            (cell.hostImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                            cell.hostImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                            })
                                        }
                                        
                                    }
                                    else
                                    {
                                        cell.hostImage2.isHidden = true
                                        cell.hostSelection2.isHidden = true
                                        
                                    }
                                }
                                else
                                {
                                    cell.hostImage2.image = nil
                                    cell.hostImage2.image =  imageWithImage( UIImage(named: "")!, scaletoWidth: cell.hostImage2.bounds.width)
                                    
                                }
                            }
                            else
                            {
                                cell.hostImage2.image = nil
                            }
                            
                            // Set Event Name
                            
                            let name = eventInfo2["title"] as? String
                            var tempInfo = ""
                            if let eventDate = eventInfo2["starttime"] as? String{
                                
                                let dateMonth = dateDifferenceWithTime(eventDate)
                                var dateArrayMonth = dateMonth.components(separatedBy: ", ")
                                if dateArrayMonth.count > 1{
                                    cell.dateLabel3.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                                    
                                    cell.dateLabel3.numberOfLines = 0
                                    cell.dateLabel3.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                                    cell.dateLabel3.textColor = textColorPrime
                                    cell.dateLabel3.font = UIFont(name: "FontAwesome", size: 22)
                                }
                                
                                let date = dateDifferenceWithEventTime(eventDate)
                                var DateC = date.components(separatedBy: ", ")
                                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                                if DateC.count > 3{
                                    tempInfo += " at \(DateC[3]) "
                                }
                                if eventInfo2["isRepeatEvent"] as? Int == 1
                                {
                                    tempInfo += "(Multiple Dates Available)"
                                }
                                
                            }
                            else{
                                cell.dateView2.isHidden = true
                            }
                            
                            cell.titleLabel2.frame = CGRect(x: 10, y: 0, width: (cell.contentImage2.bounds.width-110), height: 30)
                            
                            cell.titleLabel2.text = "\(name!)"
                            cell.titleLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                            // cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
                            
                            
                            
                            
                            if let membercount2 = eventInfo2["member_count"] as? Int
                            {
                                cell.lblMembercount2.text = "\(membercount2)"
                            }
                            
                            if let viewcount2 = eventInfo2["view_count"] as? Int
                            {
                                cell.lblviewcount2.text = "\(viewcount2)"
                            }
                            
                            if let likecount2 = eventInfo2["like_count"] as? Int
                            {
                                cell.lbllikecount2.text = "\(likecount2)"
                            }
                            
                            
                            
                            let location = eventInfo2["location"] as? String
                            if location != "" && location != nil{
                                
                                cell.locLabel2.isHidden = false
                                
                                cell.locLabel2.frame = CGRect(x: 10, y: 25, width: (cell.contentImage2.bounds.width-110), height: 20)
                                cell.locLabel2.text = "\u{f041}   \(location!)"
                                // cell.locLabel.textColor = textColorLight
                                cell.locLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                                cell.locLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                                
                                
                                if eventInfo2["isRepeatEvent"] as? Int == 1
                                {
                                    cell.dateLabel2.frame = CGRect(x: 10, y: 40, width: (cell.contentImage2.bounds.width-110), height: 40)
                                    cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                    cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                    
                                    cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                    cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                    
                                    cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                    cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                }
                                else
                                {
                                    cell.dateLabel2.frame = CGRect(x: 10, y: 45, width: (cell.contentImage2.bounds.width-110), height: 20)
                                    
                                    cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    
                                    cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    
                                    cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                }
                                
                                let stringValue = "\u{f073}  \(tempInfo)"
                                let attrString = NSMutableAttributedString(string: stringValue)
                                let style = NSMutableParagraphStyle()
                                style.minimumLineHeight = 14 // change line spacing between each line like 30 or 40
                                attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attrString.length))
                                cell.dateLabel2.attributedText = attrString
                                cell.dateLabel2.textAlignment = NSTextAlignment.left
                                cell.dateLabel2.numberOfLines = 0
                                
                                cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                                
                                
                                cell.dateLabel3.frame = CGRect(x: 0, y: (cell.titleView2.frame.size.height-60)/2, width: 70, height: 60)
                                
                                
                                
                            }
                            
                            if location == "" || location == nil{
                                
                                cell.locLabel2.isHidden = true
                                
                                if eventInfo2["isRepeatEvent"] as? Int == 1
                                {
                                    cell.dateLabel2.frame = CGRect(x: 10, y: 30, width: (cell.contentImage2.bounds.width-110), height: 40)
                                    
                                    cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    
                                    cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    
                                    cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    
                                    
                                }
                                else
                                {
                                    cell.dateLabel2.frame = CGRect(x: 10, y: 35, width: (cell.contentImage2.bounds.width-110), height: 20)
                                    
                                    cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                    cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                    
                                    cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                    cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                    
                                    cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                    cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                    
                                    
                                }
                                
                                let stringValue = "\u{f073}  \(tempInfo)"
                                let attrString = NSMutableAttributedString(string: stringValue)
                                let style = NSMutableParagraphStyle()
                                style.minimumLineHeight = 14 // change line spacing between each line like 30 or 40
                                attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attrString.length))
                                cell.dateLabel2.attributedText = attrString
                                cell.dateLabel2.textAlignment = NSTextAlignment.left
                                cell.dateLabel2.numberOfLines = 0
                                
                                cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                                
                                
                                cell.dateLabel3.frame = CGRect(x: 0, y: (cell.titleView2.frame.size.height-60)/2, width: 70, height: 60)
                                
                                
                                
                                
                            }
                            
                            
                            
                            // Set Menu
                            if eventBrowseType != 2 {
                                cell.menuButton2.isHidden = true
                                //  cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 10)
                            }else{
                                cell.menuButton2.isHidden = true
                                //                cell.menuButton2.isHidden = false
                                // cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 30)
                            }
                            
                            
                            return cell
                        }
                        
                        return cell
                        
                    }
                    else
                    {
                        
                        if kFrequencyAdsInCells_advancedevent > 4 && nativeAdArray.count > 0
                        {
                            row = row - (row / kFrequencyAdsInCells_advancedevent)
                        }
                        let cell = eventTableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath) as! EventViewTableViewCell
                        cell.selectionStyle = UITableViewCell.SelectionStyle.none
                        cell.lineView.isHidden = false
                        cell.dateView.backgroundColor = navColor
                        cell.btnDate.addTarget(self, action: #selector(AdvancedEventViewController.DateAction(_:)), for: .touchUpInside)
                        
                        cell.backgroundColor = tableViewBgColor
                        
                        cell.hostImage.isHidden = false
                        cell.hostSelection.isHidden = false
                        cell.hostSelection.isUserInteractionEnabled = true
                        
                        var eventInfo:NSDictionary!
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            
                            if (kFrequencyAdsInCells_advancedevent > 4 && nativeAdArray.count > 0)
                            {
                                let adcount = row/(kFrequencyAdsInCells_advancedevent-1)
                                if(eventResponse.count > ((row)*2+adcount))
                                {
                                    eventInfo = eventResponse[((row)*2+adcount)] as! NSDictionary
                                    cell.contentSelection.tag = ((row)*2+adcount)
                                    cell.btnTittle.tag = ((row)*2+adcount)
                                    cell.menu.tag = ((row)*2+adcount)
                                    cell.hostSelection.tag = (row*2)+adcount
                                    cell.btnDate.tag = (row*2)+adcount
                                    
                                }
                            }
                            else
                            {
                                if(eventResponse.count > (row)*2)
                                {
                                    eventInfo = eventResponse[(row)*2] as! NSDictionary
                                    cell.contentSelection.tag = (row)*2
                                    cell.btnTittle.tag = (row)*2
                                    cell.menu.tag = (row)*2
                                    cell.hostSelection.tag = (row*2)
                                    cell.btnDate.tag = (row*2)
                                    
                                }
                            }
                            
                            
                            
                            cell.gutterMenu.isHidden = true
                            cell.cellView.frame.size.height = 260
                            cell.titleView.frame.size.height = 80
                            cell.dateView.frame.size.height = cell.titleView.frame.size.height
                            cell.lineView.frame.origin.y = cell.cellView.frame.size.height
                            
                            eventTableView.rowHeight = 260
                            cell.btnMembercount.isHidden = true
                            cell.btnviewcount.isHidden = true
                            cell.btnlikecount.isHidden = true
                            cell.lblMembercount.isHidden = true
                            cell.lblviewcount.isHidden = true
                            cell.lbllikecount.isHidden = true
                            
                            
                        }
                        else
                        {
                            eventInfo = eventResponse[row] as! NSDictionary
                            cell.contentSelection.tag = row
                            cell.btnTittle.tag = row
                            cell.hostSelection.tag = row
                            cell.btnDate.tag = row
                            cell.menuButton.tag = row
                            cell.gutterMenu.tag = row
                            
                            
                            if eventInfo["featured"] != nil && eventInfo["featured"] as! Int == 1{
                                
                                cell.featuredLabel.isHidden = false
                            }else{
                                cell.featuredLabel.isHidden = true
                            }
                            cell.featuredLabel.frame.origin.x = 5
                            cell.featuredLabel.frame.size.width = 85
                            
                            if eventInfo["sponsored"] != nil && eventInfo["sponsored"] as! Int == 1{
                                cell.sponsoredLabel.isHidden = false
                            }else{
                                cell.sponsoredLabel.isHidden = true
                            }
                            cell.sponsoredLabel.frame.origin.x = cell.contentImage.bounds.width - 95
                            cell.sponsoredLabel.frame.size.width = 90
                            
                            
                            cell.cellView.frame.size.height = 260
                            cell.titleView.frame.size.height = 80
                            cell.dateView.frame.size.height = cell.titleView.frame.size.height
                            cell.lineView.frame.origin.y = cell.cellView.frame.size.height
                            cell.gutterMenu.isHidden = true
                            eventTableView.rowHeight = 260
                            cell.btnMembercount.isHidden = true
                            cell.btnviewcount.isHidden = true
                            cell.btnlikecount.isHidden = true
                            cell.lblMembercount.isHidden = true
                            cell.lblviewcount.isHidden = true
                            cell.lbllikecount.isHidden = true
                            
                            
                        }
                        //Select Event Action
                        cell.contentSelection.addTarget(self, action: #selector(AdvancedEventViewController.showEvent(_:)), for: .touchUpInside)
                        // Set MenuAction
                        cell.menuButton.addTarget(self, action:#selector(AdvancedEventViewController.showGutterMenu(_:)) , for: .touchUpInside)
                        // cell.menuButton.addTarget(self, action:Selector(("showEventMenu:")) , for: .touchUpInside)
                        cell.hostSelection.addTarget(self, action:#selector(AdvancedEventViewController.hostProfile(_:)), for: .touchUpInside)
                        cell.btnTittle.addTarget(self, action:#selector(AdvancedEventViewController.showEvent(_:)) , for: .touchUpInside)
                        cell.contentImage.frame.size.height = 180
                        cell.contentSelection.frame.size.height = 180
                        //
                        // Set Event Image
                        
                        if let photoId = eventInfo["photo_id"] as? Int
                        {
                            
                            if photoId != 0
                            {
                                cell.contentImage.image = nil
                                cell.contentImage.backgroundColor = placeholderColor
                                let url = URL(string: eventInfo["image"] as! NSString as String)
                                if url != nil {
                                    cell.contentImage.image =  UIImage(named: "nophoto_group_thumb_profile.png")
                                     cell.contentImage.kf.indicatorType = .activity
                                    (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.contentImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
                                    
                                }
                                
                            }
                            else
                            {
                                cell.contentImage.image = nil
                                cell.contentImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                                
                            }
                        }
                        else
                        {
                            cell.contentImage.image = nil
                        }
                        
                        
                        
                        //Set Profile Image
                        if let hostId = eventInfo["host_id"] as? Int
                        {
                            
                            if hostId != 0
                            {
                                cell.hostImage.image = nil
                                cell.hostImage.backgroundColor = placeholderColor
                                var hostInfo:NSDictionary!
                                if let _ = eventInfo["hosted_by"] as? NSDictionary
                                {
                                    hostInfo = eventInfo["hosted_by"] as! NSDictionary
                                    let url = URL(string: hostInfo["image"] as! NSString as String)
                                    if url != nil {
                               
                                        cell.hostImage.kf.indicatorType = .activity
                                        (cell.hostImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                        cell.hostImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                            let image1 = image?.crop(to: cell.hostImage.frame.size)
                                            cell.hostImage.image = image1
                                        })
                                    }
                                    
                                }
                                else
                                {
                                    cell.hostImage.isHidden = true
                                    cell.hostSelection.isHidden = true
                                }
                            }
                            else
                            {
                                cell.hostImage.image = nil
                                cell.hostImage.image =  imageWithImage( UIImage(named: "")!, scaletoWidth: cell.hostImage.bounds.width)
                                
                            }
                        }
                        else
                        {
                            cell.hostImage.image = nil
                        }
                        
                        let name = eventInfo["title"] as? String
                        var tempInfo = ""
                        
                        
                        if let eventDate = eventInfo["starttime"] as? String
                        {
                            
                            let dateMonth = dateDifferenceWithEventTime(eventDate)
                            var dateArrayMonth = dateMonth.components(separatedBy: ", ")
                            if dateArrayMonth.count > 1{
                                cell.dateLabel1.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                                
                                cell.dateLabel1.numberOfLines = 0
                                cell.dateLabel1.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                                cell.dateLabel1.textColor = textColorPrime
                                cell.dateLabel1.font = UIFont(name: "FontAwesome", size: 22)
                            }
                            
                            let date = dateDifferenceWithEventTime(eventDate)
                            var DateC = date.components(separatedBy: ", ")
                            tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                            if DateC.count > 3{
                                tempInfo += " at \(DateC[3]) "
                            }
                            if eventInfo["isRepeatEvent"] as? Int == 1
                            {
                                tempInfo += "(Multiple Dates Available)"
                            }
                        }
                        
                        cell.titleLabel.frame = CGRect(x: 10, y: 0, width: (cell.contentImage.bounds.width-110), height: 30)
                        
                        cell.titleLabel.text = "\(name!)"
                        cell.titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                        // cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
                        
                        
                        
                        if let membercount = eventInfo["member_count"] as? Int
                        {
                            cell.lblMembercount.text = "\(membercount)"
                        }
                        
                        if let viewcount = eventInfo["view_count"] as? Int
                        {
                            cell.lblviewcount.text = "\(viewcount)"
                        }
                        
                        if let likecount = eventInfo["like_count"] as? Int
                        {
                            cell.lbllikecount.text = "\(likecount)"
                        }
                        
                        
                        let location = eventInfo["location"] as? String
                        if location != "" && location != nil
                        {
                            
                            cell.locLabel.isHidden = false
                            
                            cell.locLabel.frame = CGRect(x: 10, y: 25, width: (cell.contentImage.bounds.width-110), height: 20)
                            cell.locLabel.text = "\u{f041}   \(location!)"
                            // cell.locLabel.textColor = textColorLight
                            cell.locLabel.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                            cell.locLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                            
                            if eventInfo["isRepeatEvent"] as? Int == 1
                            {
                                cell.dateLabel.frame = CGRect(x: 10, y: 40, width: (cell.contentImage.bounds.width-110), height: 40)
                                
                                cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                                cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                                
                                cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                                cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                                
                                cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                                cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                            }
                            else
                            {
                                cell.dateLabel.frame = CGRect(x: 10, y: 45, width: (cell.contentImage.bounds.width-110), height: 20)
                                
                                cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                
                                cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                
                                cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                            }
                            
                            let stringValue = "\u{f073}  \(tempInfo)"
                            let attrString = NSMutableAttributedString(string: stringValue)
                            let style = NSMutableParagraphStyle()
                            style.minimumLineHeight = 14 // change line spacing between each line like 30 or 40
                            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attrString.length))
                            cell.dateLabel.attributedText = attrString
                            cell.dateLabel.textAlignment = NSTextAlignment.left
                            cell.dateLabel.numberOfLines = 0
                            cell.dateLabel.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                            cell.dateLabel1.frame = CGRect(x: 0, y: (cell.titleView.frame.size.height-60)/2, width: 70, height: 60)
                            
                        }
                        
                        if location == "" || location == nil{
                            
                            cell.locLabel.isHidden = true
                            if eventInfo["isRepeatEvent"] as? Int == 1
                            {
                                cell.dateLabel.frame = CGRect(x: 10, y: 30, width: (cell.contentImage.bounds.width-110), height: 40)
                                
                                cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                
                                
                                cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                
                                cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                
                            }
                            else
                            {
                                cell.dateLabel.frame = CGRect(x: 10, y: 35, width: (cell.contentImage.bounds.width-110), height: 20)
                                
                                cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                
                                
                                cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                
                                cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                
                            }
                            let stringValue = "\u{f073}  \(tempInfo)"
                            let attrString = NSMutableAttributedString(string: stringValue)
                            let style = NSMutableParagraphStyle()
                            style.minimumLineHeight = 14 // change line spacing between each line like 30 or 40
                            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attrString.length))
                            cell.dateLabel.attributedText = attrString
                            cell.dateLabel.textAlignment = NSTextAlignment.left
                            cell.dateLabel.numberOfLines = 0
                            cell.dateLabel.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                            cell.dateLabel1.frame = CGRect(x: 0, y: (cell.titleView.frame.size.height-60)/2, width: 70, height: 60)
                            
                        }
                        
                        
                        // Set Menu
                        if eventBrowseType != 2 {
                            cell.menuButton.isHidden = true
                            
                        }
                        else
                        {
                            cell.menuButton.isHidden = false
                            
                        }
                        
                        // RHS
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            
                            
                            cell.lineView2.isHidden = false
                            cell.dateView2.backgroundColor = navColor
                            cell.btnDate1.addTarget(self, action: #selector(AdvancedEventViewController.DateAction(_:)), for: .touchUpInside)
                            var eventInfo2:NSDictionary!
                            var adcount = Int()
                            if (kFrequencyAdsInCells_advancedevent > 4 && nativeAdArray.count > 0)
                            {
                                adcount = row/(kFrequencyAdsInCells_advancedevent-1)
                            }
                            else
                            {
                                adcount = 0
                            }
                            
                            if(eventResponse.count > (row*2+1+adcount))
                            {
                                eventInfo2 = eventResponse[(row*2+1+adcount)] as! NSDictionary
                                cell.dateView2.isHidden = false
                                cell.titleView2.isHidden = false
                                cell.cellView2.isHidden = false
                                cell.contentSelection2.isHidden = false
                                cell.contentSelection2.tag = (row*2+1+adcount)
                                cell.hostSelection2.tag = (row*2+1+adcount)
                                cell.menuButton2.tag = (row*2+1+adcount)
                                cell.btnDate1.tag = (row*2+1+adcount)
                                
                                cell.cellView2.frame.size.height = 260
                                cell.titleView2.frame.size.height = 80
                                cell.dateView2.frame.size.height = cell.titleView2.frame.size.height
                                cell.lineView2.frame.origin.y = cell.cellView2.frame.size.height
                                cell.gutterMenu2.isHidden = true
                                eventTableView.rowHeight = 260
                                cell.btnMembercount2.isHidden = true
                                cell.btnviewcount2.isHidden = true
                                cell.btnlikecount2.isHidden = true
                                cell.lblMembercount2.isHidden = true
                                cell.lblviewcount2.isHidden = true
                                cell.lbllikecount2.isHidden = true
                                
                                
                                
                            }
                            else
                            {
                                cell.cellView2.isHidden = true
                                cell.dateView2.isHidden = true
                                cell.contentSelection2.isHidden = true
                                cell.titleView2.isHidden = true
                                return cell
                            }
                            
                            
                            
                            cell.hostImage2.isHidden = false
                            cell.hostSelection2.isHidden = false
                            cell.hostSelection2.isUserInteractionEnabled = true
                            
                            // Select Event Action
                            cell.contentSelection2.addTarget(self, action: #selector(AdvancedEventViewController.showEvent(_:)), for: .touchUpInside)
                            // Set MenuAction
                            cell.btnTittle2.addTarget(self, action:#selector(AdvancedEventViewController.showEvent(_:)) , for: .touchUpInside)
                            cell.menuButton2.addTarget(self, action:#selector(AdvancedEventViewController.showGutterMenu(_:)) , for: .touchUpInside)
                            //cell.menuButton2.addTarget(self, action:Selector(("showEventMenu:")) , for: .touchUpInside)
                            cell.hostSelection2.addTarget(self, action:#selector(AdvancedEventViewController.hostProfile(_:)), for: .touchUpInside)
                            
                            
                            
                            cell.contentImage2.frame.size.height = 180
                            cell.contentSelection2.frame.size.height = 180
                            
                            
                            // Set Event Image
                            if let photoId = eventInfo2["photo_id"] as? Int{
                                
                                if photoId != 0{
                                    cell.contentImage2.image = nil
                                    let url = URL(string: eventInfo2["image"] as! NSString as String)
                                    
                                    if url != nil {
                                        cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                                          cell.contentImage2.kf.indicatorType = .activity
                                        (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                                        
                                    }
                                    
                                }
                                else
                                {
                                    cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                                }
                            }
                            
                            
                            //Set Profile Image
                            if let hostId2 = eventInfo2["host_id"] as? Int
                            {
                                
                                if hostId2 != 0
                                {
                                    cell.hostImage2.image = nil
                                    cell.hostImage2.backgroundColor = placeholderColor
                                    var hostInfo2:NSDictionary!
                                    if let _ = eventInfo2["hosted_by"] as? NSDictionary
                                    {
                                        hostInfo2 = eventInfo2["hosted_by"] as! NSDictionary
                                        let url = URL(string: hostInfo2["image"] as! NSString as String)
                                        if url != nil {
                                            cell.hostImage2.kf.indicatorType = .activity
                                            (cell.hostImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                            cell.hostImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                            })
                                        }
                                        
                                    }
                                    else
                                    {
                                        cell.hostImage2.isHidden = true
                                        cell.hostSelection2.isHidden = true
                                        
                                    }
                                }
                                else
                                {
                                    cell.hostImage2.image = nil
                                    cell.hostImage2.image =  imageWithImage( UIImage(named: "")!, scaletoWidth: cell.hostImage2.bounds.width)
                                    
                                }
                            }
                            else
                            {
                                cell.hostImage2.image = nil
                            }
                            
                            // Set Event Name
                            
                            let name = eventInfo2["title"] as? String
                            var tempInfo = ""
                            if let eventDate = eventInfo2["starttime"] as? String{
                                
                                let dateMonth = dateDifferenceWithTime(eventDate)
                                var dateArrayMonth = dateMonth.components(separatedBy: ", ")
                                if dateArrayMonth.count > 1{
                                    cell.dateLabel3.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                                    
                                    cell.dateLabel3.numberOfLines = 0
                                    cell.dateLabel3.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                                    cell.dateLabel3.textColor = textColorPrime
                                    cell.dateLabel3.font = UIFont(name: "FontAwesome", size: 22)
                                }
                                
                                let date = dateDifferenceWithEventTime(eventDate)
                                var DateC = date.components(separatedBy: ", ")
                                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                                if DateC.count > 3{
                                    tempInfo += " at \(DateC[3]) "
                                }
                                if eventInfo2["isRepeatEvent"] as? Int == 1
                                {
                                    tempInfo += "(Multiple Dates Available)"
                                }
                                
                            }
                            else{
                                cell.dateView2.isHidden = true
                            }
                            
                            cell.titleLabel2.frame = CGRect(x: 10, y: 0, width: (cell.contentImage2.bounds.width-110), height: 30)
                            
                            cell.titleLabel2.text = "\(name!)"
                            cell.titleLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                            // cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
                            
                            if let membercount2 = eventInfo2["member_count"] as? Int
                            {
                                cell.lblMembercount2.text = "\(membercount2)"
                            }
                            
                            if let viewcount2 = eventInfo2["view_count"] as? Int
                            {
                                cell.lblviewcount2.text = "\(viewcount2)"
                            }
                            
                            if let likecount2 = eventInfo2["like_count"] as? Int
                            {
                                cell.lbllikecount2.text = "\(likecount2)"
                            }
                            
                            
                            
                            let location = eventInfo2["location"] as? String
                            if location != "" && location != nil{
                                
                                cell.locLabel2.isHidden = false
                                
                                cell.locLabel2.frame = CGRect(x: 10, y: 25, width: (cell.contentImage2.bounds.width-110), height: 20)
                                cell.locLabel2.text = "\u{f041}   \(location!)"
                                // cell.locLabel.textColor = textColorLight
                                cell.locLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                                cell.locLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                                
                                
                                if eventInfo2["isRepeatEvent"] as? Int == 1
                                {
                                    cell.dateLabel2.frame = CGRect(x: 10, y: 40, width: (cell.contentImage2.bounds.width-110), height: 40)
                                    cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                    cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                    
                                    cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                    cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                    
                                    cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                    cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                                }
                                else
                                {
                                    cell.dateLabel2.frame = CGRect(x: 10, y: 45, width: (cell.contentImage2.bounds.width-110), height: 20)
                                    
                                    cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    
                                    cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    
                                    cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                }
                                
                                let stringValue = "\u{f073}  \(tempInfo)"
                                let attrString = NSMutableAttributedString(string: stringValue)
                                let style = NSMutableParagraphStyle()
                                style.minimumLineHeight = 14 // change line spacing between each line like 30 or 40
                                attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attrString.length))
                                cell.dateLabel2.attributedText = attrString
                                cell.dateLabel2.textAlignment = NSTextAlignment.left
                                cell.dateLabel2.numberOfLines = 0
                                
                                cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                                
                                
                                cell.dateLabel3.frame = CGRect(x: 0, y: (cell.titleView.frame.size.height-60)/2, width: 70, height: 60)
                                
                            }
                            
                            if location == "" || location == nil{
                                
                                cell.locLabel2.isHidden = true
                                
                                
                                if eventInfo["isRepeatEvent"] as? Int == 1
                                {
                                    cell.dateLabel.frame = CGRect(x: 10, y: 30, width: (cell.contentImage.bounds.width-110), height: 40)
                                    
                                    cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                    cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                    
                                    
                                    cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                    cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                    
                                    cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                    cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                                    
                                }
                                else
                                {
                                    cell.dateLabel.frame = CGRect(x: 10, y: 35, width: (cell.contentImage.bounds.width-110), height: 20)
                                    
                                    cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                    cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                    
                                    
                                    cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                    cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                    
                                    cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                    cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                                    
                                }
                                
                                
                                
                                if eventInfo2["isRepeatEvent"] as? Int == 1
                                {
                                    cell.dateLabel2.frame = CGRect(x: 10, y: 30, width: (cell.contentImage2.bounds.width-110), height: 40)
                                    
                                    cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    
                                    cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    
                                    cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                                    
                                    
                                }
                                else
                                {
                                    cell.dateLabel2.frame = CGRect(x: 10, y: 35, width: (cell.contentImage2.bounds.width-110), height: 20)
                                    
                                    cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                    cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                    
                                    cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                    cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                    
                                    cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                    cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                                    
                                    
                                }
                                
                                let stringValue = "\u{f073}  \(tempInfo)"
                                let attrString = NSMutableAttributedString(string: stringValue)
                                let style = NSMutableParagraphStyle()
                                style.minimumLineHeight = 14 // change line spacing between each line like 30 or 40
                                attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attrString.length))
                                cell.dateLabel2.attributedText = attrString
                                cell.dateLabel2.textAlignment = NSTextAlignment.left
                                cell.dateLabel2.numberOfLines = 0
                                cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                                
                                
                                cell.dateLabel3.frame = CGRect(x: 0, y: (cell.titleView.frame.size.height-60)/2, width: 70, height: 60)
                                
                            }
                            
                            
                            
                            // Set Menu
                            if eventBrowseType != 2 {
                                cell.menuButton2.isHidden = true
                                
                            }else{
                                cell.menuButton2.isHidden = true
                                
                            }
                            
                            
                            return cell
                        }
                        return cell
                        
                    }
                }
            }
        }
        let cell = CustomTableViewCellThree()
        return cell
    }
    
    //    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if tableView.tag == 101
        {
            var index = Int()
            index = indexPath.row
            
            var ticketInfo:NSDictionary
            ticketInfo = ticketResponse[index] as! NSDictionary
            
            // Check Internet Connectivity
            if Reachabable.isConnectedToNetwork()
            {
                
                let parameters = ["order_id":"\(ticketInfo["order_id"] as! Int)"]
                let path = "advancedeventtickets/order/view"
                
//                spinner.center = view.center
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                
                
                // Send Server Request to Browse Blog Entries
                post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                    
                    DispatchQueue.main.async(execute: {
                        
                        activityIndicatorView.stopAnimating()
                        if msg{
                            //                        self.view.frame = CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height)
                            let vc = OrderedTicketViewController()
                            vc.orderedid = ticketInfo["order_id"] as! Int
                            self.navigationController?.pushViewController(vc, animated: false)
//                            let nativationController = UINavigationController(rootViewController: vc)
//                            self.present(nativationController, animated:false, completion: nil)
                        }
                        else
                        {
                            // Handle Server Error
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                            }
                        }
                    })
                }
            }
            else
            {
                // No Internet Connection Message
                showToast(message: network_status_msg, controller: self)
            }

        }
        else
        {
            tableView.deselectRow(at: indexPath, animated: true)
            var row = (indexPath as NSIndexPath).row as Int
            if (kFrequencyAdsInCells_advancedevent > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_advancedevent) == (kFrequencyAdsInCells_advancedevent)-1))
            {
                
                let cell = tableView.cellForRow(at: indexPath) as! NativeEventCell
                cell.selectionStyle = .none
                
                cell.backgroundColor = .clear
                
                if muteVideo == true
                {
                    muteVideo = false
                    shared1.muteVideosFor(tableView: eventTableView)
                    cell.btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                    //sender.setTitle("\(unMuteIconIcon)", for: .normal)
                }
                else
                {
                    muteVideo = true
                    shared1.muteVideosFor(tableView: eventTableView)
                    cell.btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                    //sender.setTitle("\(muteVideoIcon)", for: .normal)
                }
            }
        }
        
    }
    
    // MARK: - Show Feed Filter Options Action
    // Show Feed Filter Options Action
    @objc func showFeedFilterOptions(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        
        let alertController = UIActionSheet(title: "Choose Option", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles:"See All","Today", "Tomorrow","This Weekend","This Week","This Month", "Featured", "Sponsored")
        alertController.show(in: self.view)
        searchDic.removeAll(keepingCapacity: false)
        
        
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        switch (buttonIndex){
        
        case 0:
            
            //print("cancel")
            isFilterapplied = false
        case 1:
            searchtype = "all"
            let fitertext = NSLocalizedString("See All", comment: "") + " " + searchFilterIcon
            feedFilter.setTitle(fitertext, for: UIControl.State())
            scrollView.isUserInteractionEnabled = false
            isFilterapplied = true
            showSpinner = true
            browseEntries()
            
        case 2:
            searchtype = "today"
            let fitertext = "Today" + " " + searchFilterIcon
            feedFilter.setTitle(fitertext, for: UIControl.State())
            scrollView.isUserInteractionEnabled = false
            isFilterapplied = true
            showSpinner = true
            browseEntries()
            
            
        case 3:
            
            searchtype = "tomorrow"
            let fitertext = "Tomorrow" + " " + searchFilterIcon
            feedFilter.setTitle(fitertext, for: UIControl.State())
            scrollView.isUserInteractionEnabled = false
            isFilterapplied = true
            showSpinner = true
            browseEntries()
            
        case 4:
            searchtype = "this_weekend"
            let fitertext = "This Weekend" + " " + searchFilterIcon
            feedFilter.setTitle(fitertext, for: UIControl.State())
            scrollView.isUserInteractionEnabled = false
            isFilterapplied = true
            showSpinner = true
            browseEntries()
            
            
        case 5:
            
            searchtype = "this_week"
            let fitertext = "This Week" + " " + searchFilterIcon
            feedFilter.setTitle(fitertext, for: UIControl.State())
            scrollView.isUserInteractionEnabled = false
            isFilterapplied = true
            showSpinner = true
            browseEntries()
            
        case 6:
            
            searchtype = "this_month"
            let fitertext = "This Month" + " " + searchFilterIcon
            feedFilter.setTitle(fitertext, for: UIControl.State())
            scrollView.isUserInteractionEnabled = false
            isFilterapplied = true
            showSpinner = true
            browseEntries()
            
        case 7:
            
            searchtype = "featured"
            let fitertext = "Featured" + " " + searchFilterIcon
            feedFilter.setTitle(fitertext, for: UIControl.State())
            scrollView.isUserInteractionEnabled = false
            isFilterapplied = true
            showSpinner = true
            browseEntries()
            
        case 8:
            
            searchtype = "sponsored"
            let fitertext = "Sponsored" + " " + searchFilterIcon
            feedFilter.setTitle(fitertext, for: UIControl.State())
            scrollView.isUserInteractionEnabled = false
            isFilterapplied = true
            showSpinner = true
            browseEntries()
            
            
        default:
            
            //print("Default")
            isFilterapplied = false
        }
    }
    
    
    // MARK: - Cover Image Selection
    @objc func showEvent(_ sender:UIButton)
    {
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        var eventInfo:NSDictionary!
        if eventBrowseType == 0
        {
            eventInfo = eventResponse[sender.tag] as! NSDictionary
        }
        else
        {
            eventInfo = myeventResponse[sender.tag] as! NSDictionary
        }
        
        
        
        if(eventInfo["allow_to_view"] as! Int == 1)
        {
            let presentedVC = ContentFeedViewController()
            presentedVC.subjectId = "\(eventInfo["event_id"]!)"
            presentedVC.subjectType = "advancedevents"
            
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        else
        {
            showToast(message: "You do not have permission to view this private page.", controller: self)
        }
    }
    
    // MARK: - Cover Image Selection
    @objc func showGutterMenu(_ sender:UIButton)
    {
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        var eventInfo:NSDictionary!
        eventInfo = myeventResponse[sender.tag] as! NSDictionary
        
        if let guttermenu = eventInfo["menu"] as? NSArray
        {
            self.contentGutterMenu = guttermenu  as NSArray
            deleteContent = false
            var confirmationTitle = ""
            
            var message = ""
            var url = ""
            var param: NSDictionary = [:]
            var confirmationAlert = true
            
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in contentGutterMenu{
                if let menuItem = menu as? NSDictionary{
                    
                    if (menuItem["name"] as! String != "share")
                    {
                        
                        let titleString = menuItem["name"] as! String
                        
                        if ((titleString.range(of: "delete") != nil) || (titleString.range(of: "leave") != nil) || (titleString.range(of: "cancel_request") != nil) || (titleString.range(of: "reject_request") != nil) || (titleString.range(of: "close") != nil))
                        {
                            
                            alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .destructive , handler:{ (UIAlertAction) -> Void in
                                let condition = menuItem["name"] as! String
                                switch(condition){
                                    
                                case "leave_group":
                                    confirmationTitle = NSLocalizedString("Leave Group", comment: "")
                                    message = NSLocalizedString("Are you sure you want to leave this group?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary // menuItem["urlParams"] as! NSDictionary
                                    
                                    
                                    
                                case "delete":
                                    self.deleteContent = true
                                    confirmationTitle = NSLocalizedString("Delete Advanced Events", comment: "")
                                    
                                    message = NSLocalizedString("Are you sure you want to delete this Advanced Events?", comment: "")
                                    
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary //menuItem["urlParams"] as! NSDictionary
                                    
                                case "leave":
                                    
                                    confirmationTitle = NSLocalizedString("Leave Event", comment: "")
                                    message = NSLocalizedString("Are you sure you want to leave this event?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    
                                    
                                case "close":
                                    
                                    if (menuItem["isClosed"] as! Int == 0)
                                    {
                                        confirmationTitle = NSLocalizedString("Cancel Event", comment: "")
                                        message = NSLocalizedString("Would you like to cancel this event?", comment: "")
                                        
                                        url = menuItem["url"] as! String
                                        param = Dictionary<String, String>() as NSDictionary // menuItem["urlParams"] as! NSDictionary
                                        
                                        
                                    }
                                    else
                                    {
                                        confirmationTitle = NSLocalizedString("Re-publish Event", comment: "")
                                        message = NSLocalizedString("Would you like to Re-publish this event?", comment: "")
                                        
                                        url = menuItem["url"] as! String
                                        param = Dictionary<String, String>() as NSDictionary // menuItem["urlParams"] as! NSDictionary
                                        
                                        
                                    }
                                    
                                    
                                    
                                default:
                                    showToast(message: unconditionalMessage, controller: self)
                                    
                                }
                                
                                if confirmationAlert == true {
                                    displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                        self.updateContentAction(param as NSDictionary,url: url)
                                    }
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }))
                            
                            
                        }
                        else
                        {
                            alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                                let condition = menuItem["name"] as! String
                                switch(condition){
                                case "edit":
                                    confirmationAlert = false
                                    isCreateOrEdit = false
                                    let presentedVC = FormGenerationViewController()
                                    presentedVC.formTitle = NSLocalizedString("Edit Event", comment: "")
                                    presentedVC.contentType = "advancedevents"
                                    presentedVC.url = menuItem["url"] as! String

                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                    nativationController.modalPresentationStyle = .fullScreen
                                    self.present(nativationController, animated:false, completion: nil)

                                    
                                case "invite":
                                    confirmationAlert = false
                                    let presentedVC = InviteMemberViewController()
                                    presentedVC.contentType = "\(self.subjectType)"
                                    presentedVC.url = menuItem["url"] as! String
                                    presentedVC.param = Dictionary<String, String>() as NSDictionary? //menuItem["urlParams"] as! NSDictionary
                                    self.navigationController?.pushViewController(presentedVC, animated: false)
                                    
                                case "join_group":
                                    confirmationTitle = NSLocalizedString("Join Group", comment: "")
                                    message = NSLocalizedString("Would you like to join this Event?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    
                                case "join":
                                    
                                    confirmationAlert = true
                                    confirmationTitle = NSLocalizedString("Join Event", comment: "")
                                    message = NSLocalizedString("Would you like to join this Event?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    
                                case "request_member":
                                    if self.subjectType == "group"
                                    {
                                        confirmationTitle = NSLocalizedString("Request Group Membership", comment: "")
                                        message = NSLocalizedString("Would you like to request membership in this group?", comment: "")
                                    }
                                    else if self.subjectType == "event"
                                    {
                                        confirmationTitle = NSLocalizedString("Request Event Membership", comment: "")
                                        message = NSLocalizedString("Would you like to request membership in this event?", comment: "")
                                    }
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary //menuItem["urlParams"] as! NSDictionary
                                    
                                    
                                case "accept_request":
                                    if self.subjectType == "group"{
                                        confirmationTitle = NSLocalizedString("Accept Group Invitation", comment: "")
                                        
                                    }else if self.subjectType == "event"{
                                        confirmationTitle = NSLocalizedString("Accept Event Invitation", comment: "")
                                        
                                    }
                                    message = NSLocalizedString("Would you like to join this \(self.subjectType)?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    
                                    
                                case "request_invite":
                                    
                                    confirmationAlert = true
                                    confirmationTitle = NSLocalizedString("Request Event Membership", comment: "")
                                    message = NSLocalizedString("Would you like to request membership in this event?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary //menuItem["urlParams"] as! NSDictionary
                                    
                                    
                                case "messageowner":
                                    
                                    confirmationAlert = false
                                    let presentedVC = MessageOwnerViewController();
                                    url = menuItem["url"] as! String
                                    presentedVC.url = url
                                    self.navigationController?.pushViewController(presentedVC, animated: true)
                                    
                                case "tellafriend":
                                    
                                    confirmationAlert = false
                                    let presentedVC = TellAFriendViewController();
                                    url = menuItem["url"] as! String
                                    presentedVC.url = url
                                    self.navigationController?.pushViewController(presentedVC, animated: true)
                                    
                                    
                                case "report":
                                    
                                    confirmationAlert = false
                                    let presentedVC = ReportContentViewController()
                                    presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    presentedVC.url = menuItem["url"] as! String
                                    self.navigationController?.pushViewController(presentedVC, animated: false)
                                    
                                case "notification_settings":
                                    
                                    confirmationAlert = false
                                    let presentedVC = NotificationsSettingsViewController();
                                    url = menuItem["url"] as! String
                                    presentedVC.url = url
                                    presentedVC.contentType = "advancedeventsview"
                                    self.navigationController?.pushViewController(presentedVC, animated: true)
                                    
                                    
                                case "accept_invite":
                                    
                                    confirmationAlert = true
                                    confirmationTitle = NSLocalizedString("Accept Event Invitation", comment: "")
                                    message = NSLocalizedString("Would you like to join this \(self.subjectType)?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    
                                case "cancel_invite":
                                    
                                    confirmationAlert = true
                                    confirmationTitle = NSLocalizedString("Cancel Event Invitation", comment: "")
                                    
                                    
                                    message = NSLocalizedString("Would you like to Cancel this \(self.subjectType)?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    
                                case "diary":
                                    
                                    isCreateOrEdit = true
                                    confirmationAlert = false
                                    globFilterValue = ""
                                    let presentedVC = FormGenerationViewController()
                                    presentedVC.formTitle = NSLocalizedString("Add to Diary", comment: "")
                                    presentedVC.contentType = "AddToDiary"
                                    presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    presentedVC.url = menuItem["url"] as! String

                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                    nativationController.modalPresentationStyle = .fullScreen
                                    self.present(nativationController, animated:false, completion: nil)

                                    
                                case "publish":
                                    
                                    confirmationTitle = NSLocalizedString("Publish Event", comment: "")
                                    message = NSLocalizedString("Would you like to Publish this event?", comment: "")
                                    
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary // menuItem["urlParams"] as! NSDictionary
                                    
                                    
                                case "package_payment":
                                    
                                    confirmationAlert = false
                                    let presentedVC = ExternalWebViewController()
                                    presentedVC.url = menuItem["url"] as! String
                                    let navigationController = UINavigationController(rootViewController: presentedVC)
                                    navigationController.modalPresentationStyle = .fullScreen
                                    self.present(navigationController, animated: true, completion: nil)
                                    
                                case "upgrade_package":
                                    let presentedVC = PackageViewController()
                                    presentedVC.url = menuItem["url"] as! String
                                    presentedVC.urlParams = menuItem["urlParams"] as! NSDictionary
                                    presentedVC.isUpgradePackageScreen = true

                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                    nativationController.modalPresentationStyle = .fullScreen
                                    self.present(nativationController, animated:false, completion: nil)

                                    
                                default:
                                    showToast(message: unconditionalMessage, controller: self)
                                }
                                
                                if confirmationAlert == true
                                {
                                    displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                        self.updateContentAction(param as NSDictionary,url: url)
                                    }
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }))
                        }
                        
                        
                        
                        
                    }}
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
        
    }
    
    // MARK: - Host Profile Selection
    @objc func hostProfile(_ sender:UIButton)
    {
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        var eventInfo:NSDictionary!
        var hostInfo:NSDictionary!
        if eventBrowseType == 0
        {
            eventInfo = eventResponse[sender.tag] as! NSDictionary
        }
        else
        {
            eventInfo = myeventResponse[sender.tag] as! NSDictionary
        }
        
        if let _ = eventInfo["hosted_by"]
        {
            hostInfo = eventInfo["hosted_by"]as! NSDictionary

            if let hostId = hostInfo["host_id"] as? Int
            {
                if hostId != 0
                {
                    let  hostType = hostInfo["host_type"] as? String
                    if hostType == "user"{
                        
                        let presentedVC = ContentActivityFeedViewController()
                        presentedVC.subjectType = "user"
                        eventUpdate = false
                        presentedVC.subjectId = "\(hostId)"
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    else{
                        
                        let presentedVC = AdvHostMemberViewController()
                        presentedVC.hostId = hostId
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    
                }
                
            }
            else
            {
                showToast(message: "You do not have permission to view this private page.", controller: self)
            }
        }
    }    // MARK: - addNewEvent Selection
    
    @objc func addNewEvent()
    {
        
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        else
        {
//            if eventBrowseType==2
//            {
//                isCreateOrEdit = true
//                globFilterValue = ""
//                let presentedVC = FormGenerationViewController()
//                presentedVC.formTitle = NSLocalizedString("Create New Diary", comment: "")
//                presentedVC.contentType = "Diary"
//                presentedVC.param = [ : ]
//                presentedVC.url = "advancedevents/diaries/create"
//                if footerDashboard == true {
//                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
//                    let nativationController = UINavigationController(rootViewController: presentedVC)
//                    self.present(nativationController, animated:false, completion: nil)
//                }else{
//                    self.navigationController?.pushViewController(presentedVC, animated: false)
//                }
//            }
//            else
//            {
                
                if packagesEnabled == 1
                {
                    isCreateOrEdit = true
                    let presentedVC = PackageViewController()
                    presentedVC.contentType = "advancedevents"
                    presentedVC.url = "advancedevents/packages"
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    nativationController.modalPresentationStyle = .fullScreen
                    self.present(nativationController, animated:false, completion: nil)

                }
                else
                {
                    isCreateOrEdit = true
                    let presentedVC = FormGenerationViewController()
                    presentedVC.formTitle = NSLocalizedString("Create New Event", comment: "")
                    presentedVC.contentType = "advancedevents"
                    presentedVC.param = [ : ]
                    presentedVC.url = "advancedevents/create"
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    nativationController.modalPresentationStyle = .fullScreen
                    self.present(nativationController, animated:false, completion: nil)

                }
                
                
            }
        
    }
    
    // MARK: - searchItem Selection
    @objc func searchItem()
    {
            let presentedVC = AdvancedEventSearchViewController()
            presentedVC.eventBrowseType = eventBrowseType
            self.navigationController?.pushViewController(presentedVC, animated: false)
            globalCatg = ""
            let url : String = "advancedevents/search-form"
            loadFilter(url)
    }
    
    //MARK:Diary section
    @objc func DateAction(_ sender:UIButton)
    {

        var eventInfo:NSDictionary!
        if eventBrowseType == 0
        {
            eventInfo = eventResponse[sender.tag] as! NSDictionary
        }
        else
        {
            eventInfo = myeventResponse[sender.tag] as! NSDictionary
        }
        
        if let eventDate = eventInfo["starttime"] as? String
        {
            let Actauldate = dateDifferenceWithEventTime(eventDate)
            var dateArrayMonth = Actauldate.components(separatedBy: ", ")
            if dateArrayMonth.count > 0
            {
                let navdate = dateArrayMonth[0] + " " + dateArrayMonth[1] + ", " + dateArrayMonth[2]
                let date: String = eventDate.substring(with: (eventDate.startIndex ..< eventDate.range(of: " ")!.lowerBound))
                let viewobj = DiaryDetailViewController()
                viewobj.CalenderDate = date
                viewobj.IScomingfrom = "Calendar"
                viewobj.Navtitle = navdate
                self.navigationController?.pushViewController(viewobj, animated: true)
                
            }
            
            
            
        }
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    //MARK: Category Selection
    @objc func showSubCategory(_ sender:UIButton)
    {
        
        var eventInfo:NSDictionary!
        eventInfo = categoryResponse[sender.tag] as! NSDictionary
        
        let presentedVC = CategoryDetailViewController()
        presentedVC.subjectId = eventInfo["category_id"] as! Int
        presentedVC.tittle = eventInfo["category_name"] as! String
        navigationController?.pushViewController(presentedVC, animated: true)
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
            
            var method = "POST"
            
            if (url.range(of: "delete") != nil){
                method = "DELETE"
            }
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                            
                        }
                        if self.deleteContent == true
                        {
                            groupUpdate = true
                            eventUpdate = true
                            //self.popAfterDelay = true
                            self.createTimer(self)
                            
                        }
                        self.scrollView.isUserInteractionEnabled = false
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
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    
    // Stop Timer for remove Alert
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Server Connection For Event Updation
    @objc func browseEntries()
    {
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            
//            self.info.isHidden = true
//            self.refreshButton.isHidden = true
//            self.contentIcon.isHidden = true
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
             //   spinner.center = view.center
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
   //             UIApplication.shared.keyWindow?.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
              //  activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            
            if((fromTab == true) && (hostCheckId != nil))
            {
                eventBrowseType = 2
            }
            if showOnlyMyContent == true{
                eventBrowseType = 0
            }
            switch(eventBrowseType)
            {
            case 0:
                
                path = "advancedevents"
                if sitegroupCheck == "sitegroup" {
                    
                    path = "advancedevents/events-integration"
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","parent_id" : "\(user_id!)","parent_type":"sitegroup_group"]
                }
                else if sitegroupCheck == "sitepage"{
                    path = "advancedevents/events-integration"
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","parent_id" : "\(user_id!)","parent_type":"sitepage_page"]
                }
                else if sitegroupCheck == "listing"{
                    path = "advancedevents/events-integration"
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","parent_id" : "\(user_id!)","parent_type":"sitereview_listing"]
                }
                else if sitegroupCheck == "sitestore"{
                    path = "advancedevents/events-integration"
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","parent_id" : "\(user_id!)","parent_type":"sitestore_store"]
                }
                    
                else
                {
                    
                    if Locationdic != nil
                    {
                        let defaults = UserDefaults.standard
                        
                        if let loc = defaults.string(forKey: "Location"), loc.length != 0
                        {
                            if searchtype != nil && searchtype != ""
                            {
                               
                                parameters = ["page":"\(pageNumber)", "limit": "\(limit)","restapilocation": loc,"event_time": searchtype]
                              
                                
                                
                            }
                            else
                            {
                                if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                                    
                                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","restapilocation": loc,"user_id" : String(user_id)]
                                }
                                else{
                                parameters = ["page":"\(pageNumber)", "limit": "\(limit)","restapilocation": loc]
                                }
                                
                                
                            }
                            if tabBarController != nil{
                                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
                            }

                        }
                        else
                        {
                            if searchtype != nil && searchtype != ""
                            {
                                parameters = ["page":"\(pageNumber)", "limit": "\(limit)","restapilocation": defaultlocation,"event_time": searchtype]
                                //self.title = NSLocalizedString("Advanced Events",  comment: "")
                                
                            }
                            else
                            {
                                if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                                    
                                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","restapilocation": defaultlocation,"user_id" : String(user_id)]
                                }
                                else{
                                parameters = ["page":"\(pageNumber)", "limit": "\(limit)","restapilocation": defaultlocation]
                                }
                                //self.title = NSLocalizedString("Advanced Events",  comment: "")
                                
                            }
                            if tabBarController != nil{
                                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
                            }

                            //DiaryTableView.isHidden = true
                            CategoryTableView.isHidden = true
                            myeventTableView.isHidden = true
                        }
                    }
                    else
                    {
                        if((fromTab == true) && (hostCheckId != nil))
                        {
                            
                            parameters = ["page":"\(pageNumber)", "limit": "\(limit)","host_id" : String(hostCheckId),"host_type":hostCheckType]
                        }
                        else
                        {
                            if searchtype != nil && searchtype != ""
                            {
                                parameters = ["page":"\(pageNumber)", "limit": "\(limit)","event_time": searchtype]
                            }
                            else
                            {
                                 if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                                    
                                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","user_id" : String(user_id)]
                                }
                                 else{
                                parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
                                }
                            }
                            
                            //DiaryTableView.isHidden = true
                            CategoryTableView.isHidden = true
                            myeventTableView.isHidden = true
                            
                        }
                        
                    }
                    
                }
            case 1:
                
                path = "advancedevents/categories"
                parameters = ["page":"\(pageNumber)","limit": "\(limit)","showEvents": "0"]
                eventTableView.isHidden = true
                //DiaryTableView.isHidden = true
                myeventTableView.isHidden = true
            case 2:
                
                if logoutUser == false
                {
                    path = "advancedevents/manage"
                    if((fromTab == true) && (hostCheckId != nil))
                    {

                        parameters = ["page":"\(pageNumber)", "limit": "\(limit)","host_id" : String(hostCheckId),"host_type":hostCheckType]
                        
                    }
                    else
                    {
                        if searchtype != nil && searchtype != ""
                        {
                            parameters = ["page":"\(pageNumber)", "limit": "\(limit)","event_time": searchtype]
                        }
                        else
                        {
                            parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
                        }
                        //DiaryTableView.isHidden = true
                        CategoryTableView.isHidden = true
                        eventTableView.isHidden = true
                        
                    }
                    
                }
                else
                {
                    path = "advancedevents/calender"
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","date_current": Getcalenderdate]
                    eventTableView.isHidden = true
                    //DiaryTableView.isHidden = true
                    CategoryTableView.isHidden = true
                    myeventTableView.isHidden = true
                    
                }
                if((fromTab == true) && (user_id != nil))
                {
                    parameters["user_id"] = "\(user_id!)"
                    
                    
                }
            case 3:
                path = "advancedevents/calender"
                parameters = ["page":"\(pageNumber)", "limit": "\(limit)","date_current": Getcalenderdate]
                eventTableView.isHidden = true
                //DiaryTableView.isHidden = true
                CategoryTableView.isHidden = true
                myeventTableView.isHidden = true
                
            default:
                print("Error")
            }
            
            
            // Send Server Request to Browse Blog Entries
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
                    self.myeventTableView.tableFooterView?.isHidden = true
                    self.eventTableView.tableFooterView?.isHidden = true
                    self.ticketTableView.tableFooterView?.isHidden = true
                    if msg
                    {
                        let subviews : NSArray = self.mainView.subviews as NSArray
                        for calendarView : Any in subviews
                        {
                            
                            if calendarView is NWCalendarView{
                                
                                self.calendarView.removeFromSuperview()
                            }

                        }
                        
                        if self.eventBrowseType==1
                        {
                            self.eventTableView.isHidden = true
                            self.CategoryTableView.isHidden = false
                            //self.DiaryTableView.isHidden = true
                            self.myeventTableView.isHidden = true
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
                                        
                                        var searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvancedEventViewController.searchItem))
                                        searchItem.imageInsets = UIEdgeInsets(top:0,left:0,bottom:0,right:-20.0)
                                        
                                        var addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(AdvancedEventViewController.addNewEvent))
                                        
                                        addBlog.imageInsets = UIEdgeInsets(top:0,left:-20.0,bottom:0,right:0)

                                        self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                        
                                        searchItem.tintColor = textColorPrime
                                        addBlog.tintColor = textColorPrime
                                        
                                    }
                                    else
                                    {
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvancedEventViewController.searchItem))
                                        
                                        self.navigationItem.setRightBarButtonItems([searchItem], animated: true)
                                        searchItem.tintColor = textColorPrime
                                        
                                        
                                    }
                                }
                            }
                            self.isPageRefresing = false
                            if self.categoryResponse.count == 0
                            {
                                
                                self.info = createLabel(CGRect(x: 0, y: self.contentIcon.bounds.height + self.contentIcon.frame.origin.y + (2 * contentPADING),width: self.view.bounds.width , height: 60), text: NSLocalizedString("You do not have any events matching this criteria.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.info.numberOfLines = 0
                                self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                                //                                    self.info.center = self.view.center
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
                                self.noContentView.button.addTarget(self, action: #selector(AdvancedEventViewController.addNewEvent), for: .touchUpInside)
                                self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
                                
                                
                            }
                          
                            self.CategoryTableView.reloadData()
                            
                        }
                        else if self.eventBrowseType == 2
                        {
//                            self.info.isHidden = true
//                            self.refreshButton.isHidden = true
//                            self.contentIcon.isHidden = true
                            if logoutUser == false
                            {
                                self.eventTableView.isHidden = true
                                self.CategoryTableView.isHidden = true
                                // self.DiaryTableView.isHidden = true
                                self.myeventTableView.isHidden = false
                                if self.pageNumber == 1
                                {
                                    self.myeventResponse.removeAll(keepingCapacity: false)
                                }
                                
                                if succeeded["message"] != nil
                                {
                                    showToast(message: succeeded["message"] as! String, controller: self)
                                }
                                
                                
                                if let response = succeeded["body"] as? NSDictionary
                                {
                                    if response["response"] != nil
                                    {
                                        if let blog = response["response"] as? NSArray
                                        {
                                            self.myeventResponse = self.myeventResponse + (blog as [AnyObject])
                                        }
                                    }
                                    
                                    if response["getTotalItemCount"] != nil
                                    {
                                        self.totalItems = response["getTotalItemCount"] as! Int
                                    }
                                    if self.showOnlyMyContent == false
                                    {
                                        if (response["canCreate"] as! Bool == true)
                                        {
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvancedEventViewController.searchItem))
                                            searchItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20.0)
                                            let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(AdvancedEventViewController.addNewEvent))
                                            self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                            addBlog.imageInsets = UIEdgeInsets(top: 0,left: -20, bottom: 0, right: 0)
                                            searchItem.tintColor = textColorPrime
                                            addBlog.tintColor = textColorPrime
                                            
                                        }
                                        else
                                        {
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvancedEventViewController.searchItem))
                                            self.navigationItem.setRightBarButtonItems([searchItem], animated: true)
                                            searchItem.tintColor = textColorPrime
                                            
                                            
                                        }
                                        
                                    }
                                }
                                
                                
                                self.isPageRefresing = false
                                if self.myeventResponse.count == 0
                                {

                                    self.noContentView = NoContentView()
                                    self.noContentView.tag = 1000
                                    self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                                    self.mainView.addSubview(self.noContentView)
                                    self.noContentView.isHidden = false
                                    self.noContentView.button.layer.borderWidth = 1
                                    self.noContentView.button.layer.borderColor = buttonColor.cgColor
                                    self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal)
                                    self.noContentView.button.addTarget(self, action: #selector(AdvancedEventViewController.addNewEvent), for: .touchUpInside)
                                    self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
                                    
                                    
                                }
                                if NotPlay != 1 {
                                    self.pausePlayeVideos()
                                }
                                self.myeventTableView.reloadData()
                            }
                            else
                            {
                                self.eventTableView.isHidden = true
                                self.CategoryTableView.isHidden = true
                                //self.DiaryTableView.isHidden = true
                                self.myeventTableView.isHidden = true
                                if self.pageNumber == 1
                                {
                                    self.arrDate.removeAll(keepingCapacity: false)
                                }
                                
                                if let response = succeeded["body"] as? NSArray
                                {
//                                    self.info.isHidden = true
//                                    self.refreshButton.isHidden = true
//                                    self.contentIcon.isHidden = true
                                    self.CalenderResponse = response as [AnyObject]
                                    if self.CalenderResponse.count > 0
                                    {
                                        for menu in self.CalenderResponse
                                        {
                                            if let menuItem = menu as? NSDictionary
                                            {
                                                
                                                let date = menuItem["starttime"] as! String
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                                let finaldate = dateFormatter.date(from: date)
                                                self.arrDate.append(finaldate!)
                                            }
                                        }
                                        
                                        
                                        self.calendarView = NWCalendarView(frame: CGRect(x: 0, y: ButtonHeight+TOPPADING+10, width: self.view.bounds.width, height: 250))
                                        self.calendarView.layer.borderWidth = 1
                                        self.calendarView.layer.borderColor = UIColor.lightGray.cgColor
                                        self.calendarView.backgroundColor = UIColor.clear
                                        let date = Date()
                                        if self.arrDate.count > 0
                                        {
                                            
                                            self.calendarView.selectedDates = self.arrDate
                                            
                                        }
                                        
                                        self.calendarView.selectionRangeLength = 1
                                        self.calendarView.maxMonths = 100
                                        self.calendarView.delegate = self
                                        self.calendarView.createCalendar()
                                        if self.Getcalenderdate != ""
                                        {
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            self.Getcalenderdate1 = self.Getcalenderdate
                                            let date1 = dateFormatter.date(from: self.Getcalenderdate)
                                            self.calendarView.scrollToDate(date1!, animated: true)
                                        }
                                        else
                                        {
                                            self.calendarView.scrollToDate(date, animated: true)
                                        }
                                        
                                        self.mainView.addSubview(self.calendarView)
                                    }
                                    else
                                    {
                                        self.calendarView = NWCalendarView(frame: CGRect(x: 0, y: ButtonHeight+TOPPADING+10, width: self.view.bounds.width, height: 250))
                                        self.calendarView.layer.borderWidth = 1
                                        self.calendarView.layer.borderColor = UIColor.lightGray.cgColor
                                        self.calendarView.backgroundColor = UIColor.clear
                                        let date = Date()
                                        self.calendarView.selectionRangeLength = 1
                                        self.calendarView.maxMonths = 100
                                        
                                        self.calendarView.delegate = self
                                        self.calendarView.createCalendar()
                                        
                                        if self.Getcalenderdate != ""
                                        {
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd"
                                            self.Getcalenderdate1 = self.Getcalenderdate
                                            let date1 = dateFormatter.date(from: self.Getcalenderdate)
                                            self.calendarView.scrollToDate(date1!, animated: true)
                                        }
                                        else
                                        {
                                            self.calendarView.scrollToDate(date, animated: true)
                                        }
                                        
                                        self.mainView.addSubview(self.calendarView)
                                    }
                                    
                                }
                            }
                            
                        }
                        else if self.eventBrowseType == 3
                        {
                            self.eventTableView.isHidden = true
                            self.CategoryTableView.isHidden = true
                            //self.DiaryTableView.isHidden = true
                            self.myeventTableView.isHidden = true
                            if self.pageNumber == 1
                            {
                                self.arrDate.removeAll(keepingCapacity: false)
                            }
                            
                            if let response = succeeded["body"] as? NSArray
                            {
//                                self.info.isHidden = true
//                                self.refreshButton.isHidden = true
//                                self.contentIcon.isHidden = true
                                self.CalenderResponse = response as [AnyObject]
                                if self.CalenderResponse.count > 0
                                {
                                    for menu in self.CalenderResponse
                                    {
                                        if let menuItem = menu as? NSDictionary
                                        {
                                            
                                            let date = menuItem["starttime"] as! String
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                            let finaldate = dateFormatter.date(from: date)
                                            self.arrDate.append(finaldate!)
                                        }
                                    }
                                    
                                    
                                    self.calendarView = NWCalendarView(frame: CGRect(x: 0, y: ButtonHeight+TOPPADING+10, width: self.view.bounds.width, height: 250))
                                    self.calendarView.layer.borderWidth = 1
                                    self.calendarView.layer.borderColor = UIColor.lightGray.cgColor
                                    self.calendarView.backgroundColor = UIColor.clear
                                    let date = Date()
                                    if self.arrDate.count > 0
                                    {
                                        
                                        self.calendarView.selectedDates = self.arrDate
                                        
                                    }
                                    
                                    self.calendarView.selectionRangeLength = 1
                                    self.calendarView.maxMonths = 100
                                    
                                    self.calendarView.delegate = self
                                    self.calendarView.createCalendar()
                                    if self.Getcalenderdate != ""
                                    {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        self.Getcalenderdate1 = self.Getcalenderdate
                                        let date1 = dateFormatter.date(from: self.Getcalenderdate)
                                        self.calendarView.scrollToDate(date1!, animated: true)
                                    }
                                    else
                                    {
                                        self.calendarView.scrollToDate(date, animated: true)
                                    }
                                    
                                    self.mainView.addSubview(self.calendarView)
                                }
                                else
                                {
                                    self.calendarView = NWCalendarView(frame: CGRect(x: 0, y: ButtonHeight+TOPPADING+10, width: self.view.bounds.width, height: 250))
                                    self.calendarView.layer.borderWidth = 1
                                    self.calendarView.layer.borderColor = UIColor.lightGray.cgColor
                                    self.calendarView.backgroundColor = UIColor.clear
                                    let date = Date()
                                    self.calendarView.selectionRangeLength = 1
                                    self.calendarView.maxMonths = 100
                                    
                                    self.calendarView.delegate = self
                                    self.calendarView.createCalendar()
                                    
                                    if self.Getcalenderdate != ""
                                    {
                                        let dateFormatter = DateFormatter()
                                        dateFormatter.dateFormat = "yyyy-MM-dd"
                                        self.Getcalenderdate1 = self.Getcalenderdate
                                        let date1 = dateFormatter.date(from: self.Getcalenderdate)
                                        self.calendarView.scrollToDate(date1!, animated: true)
                                    }
                                    else
                                    {
                                        self.calendarView.scrollToDate(date, animated: true)
                                    }
                                    
                                    self.mainView.addSubview(self.calendarView)
                                }
                                
                            }
                        }
                        else
                        {
//                            self.info.isHidden = true
//                            self.refreshButton.isHidden = true
//                            self.contentIcon.isHidden = true
                            self.eventTableView.isHidden = false
                            self.CategoryTableView.isHidden = true
                            //self.DiaryTableView.isHidden = true
                            self.myeventTableView.isHidden = true
                            self.updateScrollFlag = true
                            
                            if self.pageNumber == 1 || self.isFilterapplied == true
                            {
                                self.eventResponse.removeAll(keepingCapacity: false)
                                self.isFilterapplied = false
                                self.pageNumber = 1
                            }
                            
                            if succeeded["message"] != nil
                            {
                                showToast(message: succeeded["message"] as! String, controller: self)
                            }
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["response"] != nil
                                {
                                    if let blog = response["response"] as? NSArray
                                    {
                                        self.eventResponse = self.eventResponse + (blog as [AnyObject])
                                    }
                                }
                                
                                if response["getTotalItemCount"] != nil
                                {
                                    self.totalItems = response["getTotalItemCount"] as! Int
                                    if((self.fromTab != nil) && (self.fromTab == true) && (self.user_id != nil) && (self.showOnlyMyContent == true)) {
                                        if self.totalItems > 0 {
                                            self.navigationItem.title = "Events : (\(self.totalItems))"
                                        }
                                        else{
                                            self.navigationItem.title = "Events"
                                        }
                                    }
                                }
                               
                                if response["packagesEnabled"] != nil
                                {
                                    self.packagesEnabled = response["packagesEnabled"] as! Int
                                }
                                if self.showOnlyMyContent == false
                                {
                                    if (response["canCreate"] as! Bool == true)
                                    {
                                        
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvancedEventViewController.searchItem))
                                        searchItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20.0)
                                        let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(AdvancedEventViewController.addNewEvent))
                                        addBlog.imageInsets = UIEdgeInsets(top: 0,left: -20, bottom: 0, right: 0)
                                        self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                        
                                        searchItem.tintColor = textColorPrime
                                        addBlog.tintColor = textColorPrime
                                        
                                        self.showAppTour()
                                    }
                                    else
                                    {
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvancedEventViewController.searchItem))
                                        
                                        self.navigationItem.setRightBarButtonItems([searchItem], animated: true)
                                        searchItem.tintColor = textColorPrime
                                    }
                                    
                                    
                                    
                                }
                            }
                            
                            
                            self.isPageRefresing = false
                            if self.eventResponse.count == 0
                            {

                                self.noContentView = NoContentView()
                                self.noContentView.tag = 1000
                                self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                                self.mainView.addSubview(self.noContentView)
                                self.noContentView.isHidden = false
                                self.noContentView.button.layer.borderWidth = 1
                                self.noContentView.button.layer.borderColor = buttonColor.cgColor
                                self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal)
                                self.noContentView.button.addTarget(self, action: #selector(AdvancedEventViewController.addNewEvent), for: .touchUpInside)
                                self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
                                
                                
                            }
                            if NotPlay != 1 {
                                self.pausePlayeVideos()
                            }
                            self.eventTableView.reloadData()
                            
                        }
                        
                    }
                    else
                    {
                        self.refresher.endRefreshing()
                        if self.eventBrowseType == 3
                        {
                            self.calendarView = NWCalendarView(frame: CGRect(x: 0, y: ButtonHeight+TOPPADING+10, width: self.view.bounds.width, height: 250))
                            self.calendarView.layer.borderWidth = 1
                            self.calendarView.layer.borderColor = UIColor.lightGray.cgColor
                            self.calendarView.backgroundColor = UIColor.clear
                            let date = Date()
                            self.calendarView.selectionRangeLength = 1
                            self.calendarView.maxMonths = 100
                            
                            self.calendarView.delegate = self
                            self.calendarView.createCalendar()
                            
                            self.calendarView.scrollToDate(date, animated: true)
                            self.mainView.addSubview(self.calendarView)
                            
                        }
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
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension AdvancedEventViewController: NWCalendarViewDelegate
{
    func didChangeFromMonthToMonth(_ fromMonth: DateComponents, toMonth: DateComponents)
    {
        let day = toMonth.day
        let day1 = day!+1
        Getcalenderdate = String(toMonth.year!) + "-" + String(toMonth.month!) + "-" + String(day1)
        if Getcalenderdate1 != Getcalenderdate
        {
            browseEntries()
        }
        
    }
    
    func didSelectDate(_ fromDate: DateComponents, toDate: DateComponents)
    {
        //print("Selected date '\(String(describing: fromDate.month))/\(String(describing: fromDate.day))/\(String(describing: fromDate.year))' to date '\(String(describing: toDate.month))/\(String(describing: toDate.day))/\(String(describing: toDate.year))'")
        let date = String(toDate.year!) + "-" + String(toDate.month!) + "-" + String(toDate.day!)
        
        let Actauldate = dateDifferenceWithEventTimeCalender(date)
        var dateArrayMonth = Actauldate.components(separatedBy: ", ")
        if dateArrayMonth.count > 0
        {
            let navdate = "\(dateArrayMonth[0]) \(dateArrayMonth[1]), \(dateArrayMonth[2])"
            let viewobj = DiaryDetailViewController()
            viewobj.CalenderDate = String(date)
            viewobj.IScomingfrom = "Calendar"
            viewobj.Navtitle = "\(navdate)"
            self.navigationController?.pushViewController(viewobj, animated: true)
        }
        
    }
}

