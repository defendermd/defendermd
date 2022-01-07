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


//
//  MLTBrowseListViewController.swift
//  seiosnativeapp
//

import UIKit
//import GoogleMobileAds
import FBAudienceNetwork
import NVActivityIndicatorView
import Instructions

var listingUpdate: Bool!

class MLTBrowseListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,FBNativeAdDelegate,FBNativeAdsManagerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate,UIGestureRecognizerDelegate{
    
    let mainView = UIView()
    var showOnlyMyContent:Bool!
    var noContentView : NoContentView!
    var countListTitle : String!
    var listingsTableView:UITableView!          // TableView to show the Listing Contents
    var refresher:UIRefreshControl!             // Pull to refresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var dynamicHeight:CGFloat = 75              // Dynamic Height fort for Cell
    var listingsResponse = [AnyObject]()        // For response come from Server
    var browseOrMyListings = true               // True for Browse Listings & False for My Listings
  //  var imageCache = [String:UIImage]()
    var updateScrollFlag = true                 // Pagination Flag
    var showSpinner = true                      // Not show spinner at pull to refresh
    var fromTab : Bool! = false
    var info:UILabel!
    var user_id : String!
    var isPageRefresing = false                 // For Pagination
    var editListingID:Int = 0
  //  var imageCache1 = [String:UIImage]()
    var ownerLabel : UILabel!
    var size:CGFloat = 0;
    var listingTypeId:Int!
    var scrollView = UIScrollView()
    var listingOption:UIButton!
    var listingBrowseType:Int!
    var fromSearch: Bool!
    var viewType : Int!
    var listingName : String!
    var isUserInteractionEnabled : Bool!
    var profileCurrencySymbol : String!
    var listingSeeAllFilter: UIButton!
    var showListingType: String! = ""
    var responseCache = [String:AnyObject]()
    
    // AdMob Variable
//    var adLoader: GADAdLoader!
    var loadrequestcount = 0
    var isnativeAd:Bool = true
    var nativeAdArray = [AnyObject]()
    // Native FacebookAd Variable
    var adTitleLabel:UILabel!
    var adImageView:FBMediaView!
    var adBodyLabel:UILabel!
    var adCallToActionButton:UIButton!
    var fbView:UIView!
    var nativeAd:FBNativeAd!
    var leftBarButtonItem : UIBarButtonItem!
    var path = ""
    // communityAds Variable
    var adImageView1 : UIImageView!
    var customAlbumView : UIView!
    var adSponserdTitleLabel:UILabel!
    var adSponserdLikeTitle : TTTAttributedLabel!
    var addLikeTitle : UIButton!
    var imageButton : UIButton!
    var communityAdsValues : NSArray = []
    var navtitle : UILabel!
    var Adiconimageview : UIImageView!
    var adsReportView : AdsReportViewController!
    var parametersNeedToAdd = Dictionary<String, String>()
    var blackScreenForAdd : UIView!
    var adsImage : UIImageView!
    var adsCellheight:CGFloat = 0.0
    
    var packagesEnabled:Int! = 0
    var username : String = ""
    var timerFB =  Timer()
    var dashboardMenuDic = NSDictionary()
    var btnFloaty = UIButton()
    var filterTitle = ""
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    var targetToggleValue : Int = 1
    var targetSeeAllValue : Int = 1
    var cdAds : ContentSlideshowScrollView!
    var shared1 = VideoPlayerController()
    var taskVideoPlayPause : DispatchWorkItem?
    var cadUrl : UILabel!
    var cadTitle : UILabel!
    var ctaButton : UIButton!
    var videoclickButton = UIButton()
    override func viewDidLoad() {
        
        super.viewDidLoad()
        shared1 = VideoPlayerController()
        if fromTab == false {
            if (self.tabBarController?.selectedIndex == 1 ) ||  (self.tabBarController?.selectedIndex == 2) || ( self.tabBarController?.selectedIndex == 3 ) {
                setDynamicTabValue()
            }
            self.navigationItem.hidesBackButton = true
            
        }
        
        
        
        listingUpdate = true
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        setNavigationImage(controller: self)
        
        openMenu = false
        updateAfterAlert = true
        isUserInteractionEnabled = true
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        if showOnlyMyContent == false {
            self.navigationItem.hidesBackButton = true
            createScrollableListingMenu()
            
        }
        
        listingSeeAllFilter = createButton(CGRect(x: 10 ,y: 15,width: 20, height: 30),title:NSLocalizedString("See All", comment: "") , border: false, bgColor: false,textColor: textColorPrime)
        listingSeeAllFilter.isHidden = true

        // Initialize Blog Like View
        
        if tabBarHeight > 0{
            listingsTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight ), style: .grouped)
        }else{
            listingsTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight ), style: .grouped)
        }
        listingsTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        listingsTableView.dataSource = self
        listingsTableView.delegate = self
        listingsTableView.backgroundColor = tableViewBgColor
        listingsTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            listingsTableView.estimatedRowHeight = 0
            listingsTableView.estimatedSectionHeaderHeight = 0
            listingsTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(listingsTableView)
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(MLTBrowseListViewController.refresh), for: UIControl.Event.valueChanged)
        listingsTableView.addSubview(refresher)
        
    
        scrollView.isUserInteractionEnabled = false
        
        if logoutUser == true || showOnlyMyContent == true{
            if showOnlyMyContent == true{
                listingSeeAllFilter.isHidden = true
                listingsTableView.frame.origin.y = TOPPADING
                listingsTableView.frame.size.height = view.bounds.height - (TOPPADING + contentPADING + ButtonHeight)
                
            }
            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.plain , target:self , action: Selector(("cancelSearch")))
            self.navigationItem.rightBarButtonItem = addCancel
            
        }
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        listingsTableView.tableFooterView = footerView
        listingsTableView.tableFooterView?.isHidden = true
        
        self.Updatetitle()
        
        if adsType_mltlist != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(MLTBrowseListViewController.checkforAds),
                                           userInfo: nil,
                                           repeats: false)
        }
        self.btnFloaty = UIButton(frame:CGRect(x:self.view.bounds.width-70, y:self.view.bounds.height-(tabBarHeight + 70), width:50, height:50))
        self.btnFloaty.layer.masksToBounds = false
        self.btnFloaty.shadowColors = UIColor.gray
        self.btnFloaty.shadowOffsets = CGSize(width:0.1,height:0.1)
        self.btnFloaty.shadowOpacitys = 1.0
        self.btnFloaty.layer.borderWidth = 1
        self.btnFloaty.layer.borderColor = buttonColor.cgColor
        self.btnFloaty.layer.cornerRadius = self.btnFloaty.frame.height/2
        self.btnFloaty.setTitle("\u{f0ca}", for: UIControl.State.normal)
        if sitereviewMenuDictionary != nil{
            let anotherViewBrowseType = sitereviewMenuDictionary["anotherViewBrowseType"] as? Int ?? 0
            if anotherViewBrowseType != 0 {
                var browseType = sitereviewMenuDictionary["viewBrowseType"] as? Int ?? 0
                
                if browseType == 1
                {
                    browseType = anotherViewBrowseType
                }
                
                if browseType == 1
                {
                    self.btnFloaty.setTitle("\u{f0ca}", for: UIControl.State.normal)
                }
                else if browseType == 2
                {
                    self.btnFloaty.setTitle("\u{f00a}", for: UIControl.State.normal)
                }
                else if browseType == 3
                {
                    self.btnFloaty.setTitle("\u{f0db}", for: UIControl.State.normal)
                }
                else
                {
                    self.btnFloaty.setTitle("\u{f279}", for: UIControl.State.normal)
                }
            }
        }
        self.btnFloaty.titleLabel?.font = UIFont(name: "FontAwesome", size:FONTSIZELarge)
        self.btnFloaty.backgroundColor = buttonColor
        self.btnFloaty.clipsToBounds = true
        self.btnFloaty.addTarget(self, action: #selector(MLTBrowseListViewController.toggleView), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.btnFloaty)
        if browseOrMyListings == false || showOnlyMyContent == true
        {
            self.btnFloaty.isHidden = true
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        if self.targetCheckValue == 1 && self.targetToggleValue == 1 && self.targetSeeAllValue == 1{
            return 4
        }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1 && self.targetToggleValue == 1{
            return 2
        }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 2 && self.targetToggleValue == 1{
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
        if self.targetCheckValue == 1 && self.targetToggleValue == 1 && self.targetSeeAllValue == 1{
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
                
            case 3:
                // skipView.isHidden = true
                var  coachMark2 : CoachMark
                let showView = UIView()
                let origin_x : CGFloat = self.view.bounds.width - 45.0
                let radious : Int = 40
                
                
                coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                    // This will create a circular cutoutPath, perfect for the circular avatar!
                    let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: self.view.bounds.height-(tabBarHeight + 43)), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                    
                    return circlePath
                    
                }
                coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
                return coachMark2
                
            default:
                coachMark = coachMarksController.helper.makeCoachMark()
                coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
            }
            
        }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1 && self.targetToggleValue == 1{
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
                
            case 1:
                // skipView.isHidden = true
                var  coachMark2 : CoachMark
                let showView = UIView()
                let origin_x : CGFloat = self.view.bounds.width - 45.0
                let radious : Int = 40
                
                
                coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                    // This will create a circular cutoutPath, perfect for the circular avatar!
                    let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: self.view.bounds.height-(tabBarHeight + 43)), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                    
                    return circlePath
                    
                }
                coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
                return coachMark2
                
                
            default:
                coachMark = coachMarksController.helper.makeCoachMark()
                coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
            }
            
        }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 2 && self.targetToggleValue == 1{
            switch(index) {
                
            case 0:
                // skipView.isHidden = true
                var  coachMark2 : CoachMark
                let showView = UIView()
                let origin_x : CGFloat = self.view.bounds.width - 45.0
                let radious : Int = 40
                
                
                coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                    // This will create a circular cutoutPath, perfect for the circular avatar!
                    let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: self.view.bounds.height-(tabBarHeight + 43)), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                    
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
        
        if self.targetCheckValue == 1 && self.targetToggleValue == 1 && self.targetSeeAllValue == 1{
            switch(index) {
            case 0:
                coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
                coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 1/4", comment: "")
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Next ", comment: "")
                
            case 1:
                coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(createTourText)", comment: ""))"
                coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 2/4", comment: "")
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Next ", comment: "")
            case 2:
                coachViews.bodyView.hintLabel.text = NSLocalizedString("Use Filters to search specific results.", comment: "")
                coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 3/4", comment: "")
                coachViews.bodyView.nextLabel.text = "Next "
            case 3:
                coachViews.bodyView.hintLabel.text = NSLocalizedString("Click here to Switch Listings Views.", comment: "")
                coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 4/4", comment: "")
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
                
                
            default: break
            }
            
            return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 2 && self.targetToggleValue == 1{
            switch(index) {
                
                
            case 0:
                coachViews.bodyView.hintLabel.text = NSLocalizedString("Click here to Switch Listings Views.", comment: "")
                coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 1/1", comment: "")
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
                
                
                
            default: break
            }
            return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        }
        
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1 && self.targetToggleValue == 1{
            switch(index) {
            case 0:
                coachViews.bodyView.hintLabel.text = NSLocalizedString("Use Filters to search specific results.", comment: "")
                coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 1/2", comment: "")
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Next ", comment: "")
                
            case 1:
                coachViews.bodyView.hintLabel.text = NSLocalizedString("Click here to Switch Listings Views.", comment: "")
                coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 2/2", comment: "")
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
                
                
                
            default: break
            }
            
            return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
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
        
        if let name = defaults.object(forKey: "showTogglePluginAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showTogglePluginAppTour") != nil {
                
                self.targetToggleValue = name as! Int
                
                
            }
            
        }
        
        if let name = defaults.object(forKey: "showSeeAllPluginAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showSeeAllPluginAppTour") != nil {
                
                self.targetSeeAllValue = name as! Int
                
                
            }
            
        }
        
        
        
        if self.targetCheckValue == 1 && self.targetToggleValue == 1 && self.targetSeeAllValue == 1{
            
            UserDefaults.standard.set(2, forKey: "showPluginAppTour")
            UserDefaults.standard.set(2, forKey: "showTogglePluginAppTour")
            UserDefaults.standard.set(2, forKey: "showSeeAllPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
        
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 1 && self.targetToggleValue == 1{
            
            
            UserDefaults.standard.set(2, forKey: "showTogglePluginAppTour")
            UserDefaults.standard.set(2, forKey: "showSeeAllPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
        if self.targetCheckValue == 2 && self.targetSeeAllValue == 2 && self.targetToggleValue == 1{
            
            
            UserDefaults.standard.set(2, forKey: "showTogglePluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationImage(controller: self)
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
        if let button = self.scrollView.viewWithTag(100) as? UIButton
        {
            if browseOrMyListings == true {
                listingSeeAllFilter.isHidden = false
                button.setSelectedButton()
            }
        }
        if let button = self.scrollView.viewWithTag(100) as? UIButton
        {
            button.setUnSelectedButton()
        }
        
    }
    @objc func appEnteredFromBackground() {
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
    }
    @objc func appMovedToBackground() {
        self.shared1.pauseVideosFor(tableView: self.listingsTableView)
        self.taskVideoPlayPause?.cancel()
    }
    @objc func videoCompletion() {
        
        shared1.currentVideoContainer()?.playOn = true
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        
    }
    func pausePlayeVideos(){
        shared1.pausePlayeVideosFor(tableView: listingsTableView)
        
    }
    
    
    func IsRedirctToProfile()
    {
        if conditionalProfileForm == "BrowsePage"
        {
            conditionalProfileForm = ""
            
            if sitevideoPluginEnabled_mlt != 1 && addvideo_click != 1
            {
                SiteMltObject().redirectToMltProfilePage(self ,subjectType : "sitereview_listing" , listingTypeIdValue : createResponse["listingtype_id"] as! Int , listingIdValue : "\(createResponse["listing_id"]!)", viewTypeValue : viewType)
            }
            else
            {
                addvideo_click = 0
            }
            
        }
        
    }
    
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
        
        if self.tabBarController?.selectedIndex == 1 || self.tabBarController?.selectedIndex == 2 || self.tabBarController?.selectedIndex == 3 {
            if self.tabBarController?.selectedIndex == 1 {
                listingTypeId = globalListingTypeId
                listingName = globalListingName
            }
            if self.tabBarController?.selectedIndex == 2 {
                listingTypeId = globalListingTypeId1
                listingName = globalListingName1
                
            }
            if self.tabBarController?.selectedIndex == 3 {
                listingTypeId = globalListingTypeId2
                listingName = globalListingName2
                
            }
        }
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        }

        if showOnlyMyContent == true{
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
        }
        else{
            Customnavigation()
        }
        if (listingUpdate == true){
            listingUpdate = false
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            scrollView.isUserInteractionEnabled = false
            browseEntries()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delay(0.0) {
            self.shared1.pauseVideosFor(tableView: self.listingsTableView)
            self.taskVideoPlayPause?.cancel()
        }
        
        timerFB.invalidate()
        NotificationCenter.default.removeObserver(self)
        listingsTableView.tableFooterView?.isHidden = true
        globalCatg = ""
        globFilterValue = ""
        filterSearchFormArray.removeAll(keepingCapacity: false)
        self.title = ""
        removeNavigationViews(controller: self)
    }
    
    func Customnavigation()
    {
        removeNavigationViews(controller: self)
        if let navigationBar = self.navigationController?.navigationBar
        {
            self.title = ""
            let firstFrame = CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/2))/2, y:-5, width: navigationBar.frame.width/2, height: navigationBar.frame.height - 10)
            navtitle = UILabel(frame: firstFrame)
            navtitle.textAlignment = .center
            navtitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
            navtitle.textColor = textColorPrime
            if showOnlyMyContent == false {
                navtitle.text = NSLocalizedString(listingName,  comment: "")
            }
            else{
                navtitle.text = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
            }
            navtitle.tag = 400
            //navtitle.sizeToFit()
            

            listingSeeAllFilter = createButton(CGRect(x: (navigationBar.frame.width - (navigationBar.frame.width/3))/2 ,y: 18,width: navigationBar.frame.width/3, height: 30),title:"" , border: false, bgColor: false,textColor: textColorLight)
            listingSeeAllFilter.isEnabled = true
            listingSeeAllFilter.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
            listingSeeAllFilter.addTarget(self, action: #selector(MLTBrowseListViewController.showListingFilterOptions(_:)), for: .touchUpInside)
            listingSeeAllFilter.tag = 400
            let fitertext = NSLocalizedString("See All", comment: "") + " " + searchFilterIcon
            if  filterTitle == "" {
                listingSeeAllFilter.setTitle(fitertext, for: .normal)
            }
            else{
                listingSeeAllFilter.setTitle(filterTitle, for: .normal)
            }
            
            navigationBar.addSubview(listingSeeAllFilter)
            navigationBar.addSubview(navtitle)
            
        }
    }
    
    func Updatetitle()
    {
        if showOnlyMyContent == true {
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(MLTBrowseListViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            self.navigationItem.title = countListTitle
        }
    }
    
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "showMyListingContent") != nil {
            if let name = defaults.object(forKey: "showMyListingContent")
            {
                if  UserDefaults.standard.object(forKey: "showMyListingContent") != nil {
                    
                    showOnlyMyContent = name as! Bool
                    
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingName")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingName") != nil {
                        
                        listingName = name as! String
                        
                    }
                }
                if let name = UserDefaults.standard.object(forKey: "showlistingId")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingId") != nil {
                        
                        listingTypeId = name as! Int
                        
                    }
                }
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }
                
            }
        }
        if defaults.object(forKey: "showMyListingContent1") != nil {
            if let name = defaults.object(forKey: "showMyListingContent1")
            {
                if  UserDefaults.standard.object(forKey: "showMyListingContent1") != nil {
                    
                    showOnlyMyContent = name as! Bool
                    
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingName1")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingName1") != nil {
                        
                        listingName = name as! String
                        
                    }
                }
                if let name = UserDefaults.standard.object(forKey: "showlistingId1")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingId1") != nil {
                        
                        listingTypeId = name as! Int
                        
                    }
                }
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType1")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType1") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }
            }
        }
        if defaults.object(forKey: "showMyListingContent2") != nil {
            if let name = defaults.object(forKey: "showMyListingContent2")
            {
                if  UserDefaults.standard.object(forKey: "showMyListingContent2") != nil {
                    
                    showOnlyMyContent = name as! Bool
                    
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingName2")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingName2") != nil {
                        
                        listingName = name as! String
                        
                    }
                }
                if let name = UserDefaults.standard.object(forKey: "showlistingId2")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingId2") != nil {
                        
                        listingTypeId = name as! Int
                        
                    }
                }
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType2")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType2") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }
                
                
            }
        }
        
    }
    
    @objc func checkforAds()
    {
        nativeAdArray.removeAll()
        if adsType_mltlist == 1
        {
            if kFrequencyAdsInCells_mltlist > 4 && placementID != ""
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
                        listingsTableView.reloadData()
                    }
                }
            }
            
        }
        else if adsType_mltlist == 0
        {
            if kFrequencyAdsInCells_mltlist > 4 && adUnitID != ""
            {
                //showNativeAd()
            }
            
        }
        else if adsType_mltlist == 2
        {
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
            
            dic["type"] =  "\(adsType_mltlist)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_mltlist)"
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
                                            self.listingsTableView.reloadData()
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
                adCallToActionButton.addTarget(self, action: #selector(MLTBrowseListViewController.actionAfterClick(_:)), for: .touchUpInside)
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
                    
                    
                    videoclickButton.addTarget(self, action: #selector(MLTBrowseListViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
                    self.fbView.addSubview(videoclickButton)
                    
                    
                }
                else{
                    imageButton.addTarget(self, action: #selector(MLTBrowseListViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
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
                        
                        ctaButton.addTarget(self, action: #selector(MLTBrowseListViewController.tappedOnAds(_:)), for: .touchUpInside)
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
        dictionary["type"] =  "\(adsType_mltlist)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_mltlist)"
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
    
    // MARK: - FacebookAd Delegate
   
    func nativeAdsLoaded()
    {
//        for _ in 0 ..< 10
//        {
//
//            self.nativeAd = admanager.nextNativeAd
//            self.fetchAds(self.nativeAd)
//        }
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
            listingsTableView.reloadData()
        }
        
    }
    
    /*!
     @method
     
     @abstract When the FBNativeAdsManager has reached a failure while attempting to load a batch of ads this message will be sent to the application.
     @param error An NSError object with information about the failure.
     */
    public func nativeAdsFailedToLoadWithError(_ error: Error) {
        //print(error.localizedDescription)
    }
    
 //   func nativeAdDidLoad(_ nativeAd: FBNativeAd)
//    {
////        if ((self.nativeAd) != nil) {
////            self.nativeAd.unregisterView()
////        }
//        if loadrequestcount <= 10
//        {
//            loadrequestcount = loadrequestcount+1
//            if arrGlobalFacebookAds.count == 0
//            {
//                self.showFacebookAd()
//            }
//            else
//            {
//                for nativeAd in arrGlobalFacebookAds {
//                    self.fetchAds(nativeAd)
//                }
//                if nativeAdArray.count == 10
//                {
//                    listingsTableView.reloadData()
//                }
//            }
//            // nativeAd1.delegate = self
//        }
//
//        self.fbView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 75))
//        self.fbView.backgroundColor = tableViewBgColor
//        self.fbView.tag = 1001001
//        self.fbView.backgroundColor = UIColor.white
//
//        adImageView = FBMediaView(frame: CGRect(x: 5, y: 7, width: 60, height: 60))
//        self.adImageView.nativeAd = nativeAd
//        self.adImageView.clipsToBounds = true
//        //self.adImageView.layer.masksToBounds = true
//        self.adImageView.backgroundColor = UIColor.clear
//        self.fbView.addSubview(adImageView)
//
//        adTitleLabel = UILabel(frame: CGRect(x: adImageView.bounds.width + 10,y: 5,width: (self.fbView.bounds.width - (adImageView.bounds.width + 80)) , height: 20))
//        adTitleLabel.textColor = textColorDark
//        adTitleLabel.numberOfLines = 1
//        adTitleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
//        adTitleLabel.font = UIFont(name: fontName, size: FONTSIZELarge)
//        adTitleLabel.text = nativeAd.title
//        self.fbView.addSubview(adTitleLabel)
//
//
//        adBodyLabel = UILabel(frame: CGRect(x: adImageView.bounds.width + 10, y: adTitleLabel.bounds.height + adTitleLabel.frame.origin.y,width: (self.fbView.bounds.width - (adImageView.bounds.width + 100)) , height: 40))
//        if let _ = nativeAd.body {
//            adBodyLabel.text = nativeAd.body
//        }
//        adBodyLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
//        adBodyLabel.numberOfLines = 2
//        adBodyLabel.textColor = textColorMedium
//        adBodyLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
//        adBodyLabel.sizeToFit()
//        self.fbView.addSubview(adBodyLabel)
//
//
//
//
//        adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-75,y: adImageView.bounds.height/2 + adImageView.frame.origin.y/2-10, width: 70, height: 30))
//        adCallToActionButton.setTitle(
//            nativeAd.callToAction, for: UIControl.State())
//
//        adCallToActionButton.titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
//        adCallToActionButton.titleLabel?.textColor = navColor
//        adCallToActionButton.backgroundColor = navColor
//        adCallToActionButton.layer.cornerRadius = 2; // this value vary as per your desire
//        adCallToActionButton.clipsToBounds = true
//        self.fbView.addSubview(adCallToActionButton)
//
//        nativeAd.registerView(forInteraction: self.fbView, with: self)
//        nativeAdArray.append(self.fbView)
//        //print(nativeAdArray.count)
//        if nativeAdArray.count == 10
//        {
//            listingsTableView.reloadData()
//        }
//    }
    
    //    func nativeAd(nativeAd: FBNativeAd, didFailWithError error: NSError){
    //        showFacebookAd()
    //    }
    
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
//    func adLoader(_ adLoader: GADAdLoader,
//                  didReceive nativeAppInstallAd: GADNativeAppInstallAd)
//    {
//        let appInstallAdView = Bundle.main.loadNibNamed("NativeadsBlogtype", owner: nil,
//                                                        options: nil)?.first as! GADNativeAppInstallAdView
//
//
//        appInstallAdView.frame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds).width, height: appInstallAdView.frame.size.height)
//
//
//
//        appInstallAdView.nativeAppInstallAd = nativeAppInstallAd
//        appInstallAdView.tag = 1001001
//        (appInstallAdView.imageView as! UIImageView).image =
//            (nativeAppInstallAd.images?.first as! GADNativeAdImage).image
//        if  (UIDevice.current.userInterfaceIdiom == .phone)
//        {
//            (appInstallAdView.imageView as! UIImageView).frame = CGRect(x: 5, y: 7, width: 60, height: 60)
//        }
//        else
//        {
//            (appInstallAdView.imageView as! UIImageView).frame = CGRect(x: 5, y: 7, width: 60, height: 60)
//        }
//        (appInstallAdView.imageView as! UIImageView).layer.masksToBounds = true
//
//
//        (appInstallAdView.headlineView as! UILabel).frame = CGRect(x: ((appInstallAdView.imageView as! UIImageView).bounds).width + 10,y: 5,width: ((appInstallAdView.bounds).width - (((appInstallAdView.imageView as! UIImageView).bounds).width + 70)) , height: 20)
//
//        (appInstallAdView.headlineView as! UILabel).textColor = textColorDark
//        (appInstallAdView.headlineView as! UILabel).text = nativeAppInstallAd.headline
//        (appInstallAdView.headlineView as! UILabel).numberOfLines = 1
//        (appInstallAdView.headlineView as! UILabel).lineBreakMode = NSLineBreakMode.byTruncatingTail
//        (appInstallAdView.headlineView as! UILabel).font = UIFont(name: fontName, size: FONTSIZELarge)
//        //(appInstallAdView.headlineView as! UILabel).sizeToFit()
//
//        (appInstallAdView.bodyView as! UILabel).frame = CGRect(x: ((appInstallAdView.imageView as! UIImageView).bounds).width + 10, y: ((appInstallAdView.headlineView as! UILabel).bounds).height + (appInstallAdView.headlineView as! UILabel).frame.origin.y,width: ((appInstallAdView.bounds).width - (((appInstallAdView.imageView as! UIImageView).bounds).width + 100)) , height: 40)
//
//        (appInstallAdView.bodyView as! UILabel).text = nativeAppInstallAd.body
//        (appInstallAdView.bodyView as! UILabel).lineBreakMode = NSLineBreakMode.byWordWrapping
//        (appInstallAdView.bodyView as! UILabel).numberOfLines = 2
//        (appInstallAdView.bodyView as! UILabel).textColor = textColorMedium
//        (appInstallAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZESmall)
//        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
//
//
//        (appInstallAdView.callToActionView as! UIButton).frame = CGRect(x: (appInstallAdView.bounds).width-75,y: ((appInstallAdView.imageView as! UIImageView).bounds).height/2 + (appInstallAdView.imageView as! UIImageView).frame.origin.y/2-10, width: 65, height: 30)
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
//
//        nativeAdArray.append(appInstallAdView)
//        if loadrequestcount <= 10
//        {
//            self.loadrequestcount = self.loadrequestcount+1
//            self.adLoader.delegate = nil
//            self.showNativeAd()
//            self.listingsTableView.reloadData()
//        }
//    }
//
//    func adLoader(_ adLoader: GADAdLoader,
//                  didReceive nativeContentAd: GADNativeContentAd) {
//        let contentAdView = Bundle.main.loadNibNamed("ContentAdListType", owner: nil,
//                                                     options: nil)?.first as! GADNativeContentAdView
//        // Associate the app install ad view with the app install ad object. This is required to make
//        // the ad clickable.
//        contentAdView.nativeContentAd = nativeContentAd
//        contentAdView.tag = 1001001
//
//        contentAdView.frame = CGRect(x: 0, y: 0, width: (UIScreen.main.bounds).width, height: contentAdView.frame.size.height)
//
//
//
//        (contentAdView.imageView as! UIImageView).image =
//            (nativeContentAd.images?.first as! GADNativeAdImage).image
//        if  (UIDevice.current.userInterfaceIdiom == .phone)
//        {
//            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 5, y: 7, width: 60, height: 60)
//        }
//        else
//        {
//            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 5, y: 7, width: 60, height: 60)
//        }
//        (contentAdView.imageView as! UIImageView).layer.masksToBounds = true
//
//
//        (contentAdView.headlineView as! UILabel).frame = CGRect(x: ((contentAdView.imageView as! UIImageView).bounds).width + 10,y: 5,width: ((contentAdView.bounds).width - (((contentAdView.imageView as! UIImageView).bounds).width + 70)) , height: 20)
//
//        (contentAdView.headlineView as! UILabel).textColor = textColorDark
//        (contentAdView.headlineView as! UILabel).text = nativeContentAd.headline
//        (contentAdView.headlineView as! UILabel).numberOfLines = 1
//        (contentAdView.headlineView as! UILabel).lineBreakMode = NSLineBreakMode.byTruncatingTail
//        (contentAdView.headlineView as! UILabel).font = UIFont(name: fontName, size: FONTSIZELarge)
//        //(appInstallAdView.headlineView as! UILabel).sizeToFit()
//
//        (contentAdView.bodyView as! UILabel).frame = CGRect(x: ((contentAdView.imageView as! UIImageView).bounds).width + 10, y: ((contentAdView.headlineView as! UILabel).bounds).height + (contentAdView.headlineView as! UILabel).frame.origin.y,width: ((contentAdView.bounds).width - (((contentAdView.imageView as! UIImageView).bounds).width + 100)) , height: 40)
//
//        (contentAdView.bodyView as! UILabel).text = nativeContentAd.body
//        (contentAdView.bodyView as! UILabel).lineBreakMode = NSLineBreakMode.byWordWrapping
//        (contentAdView.bodyView as! UILabel).numberOfLines = 2
//        (contentAdView.bodyView as! UILabel).textColor = textColorMedium
//        (contentAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZESmall)
//        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
//
//
//        (contentAdView.callToActionView as! UIButton).frame = CGRect(x: (contentAdView.bounds).width-75,y: ((contentAdView.imageView as! UIImageView).bounds).height/2 + (contentAdView.imageView as! UIImageView).frame.origin.y/2-10, width: 65, height: 30)
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
//
//        nativeAdArray.append(contentAdView)
//        if loadrequestcount <= 10
//        {
//            self.loadrequestcount = self.loadrequestcount+1
//            self.adLoader.delegate = nil
//            self.showNativeAd()
//            self.listingsTableView.reloadData()
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Listing Table Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Listing Table Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.00001
    }
    
    // Set Listing Table Row Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (kFrequencyAdsInCells_mltlist > 4 && (((indexPath as NSIndexPath).row % kFrequencyAdsInCells_mltlist) == (kFrequencyAdsInCells_mltlist)-1))
        {
            if adsType_mltlist == 2
            {
                if(UIDevice.current.userInterfaceIdiom != .pad)
                {
                    return adsCellheight + 5
                }
                else
                {
                    return adsCellheight + 5
                }
            }
            else if adsType_mltlist == 0
            {
                return 75
            }
            else if adsType_mltlist == 1 {
                return adsCellheight + 5
            }
            if browseOrMyListings
            {
                return 80
            }
            else
            {
                return 90
            }
            
        }
        if browseOrMyListings
        {
            return 80
        }
        else
        {
            return 90
        }
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if adsType_mltlist == 2{
            
            var row = indexPath.row as Int
            if (kFrequencyAdsInCells_mltlist > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_mltlist) == (kFrequencyAdsInCells_mltlist)-1))
            {
                //            displyedAdsCount = (row / kFrequencyAdsInCells_feeds)
                //            row = row - displyedAdsCount
                
                if let cell1 = cell as? NativeAdinstallFeedCell
                {
                    var Adcount: Int = 0
                    Adcount = row/(kFrequencyAdsInCells_mltlist-1)
                    
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
        if adsType_mltlist == 2{
            if tableView.tag != 11
            {
                
                let row = indexPath.row as Int
                if (kFrequencyAdsInCells_mltlist > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_mltlist) == (kFrequencyAdsInCells_mltlist)-1))
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
    // Set Blog Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if nativeAdArray.count > 0
        {
            // For showing facebook ads count
            var rowcount = Int()
            rowcount = (kFrequencyAdsInCells_mltlist-1)
            if listingsResponse.count > rowcount
            {
                let a = listingsResponse.count/(kFrequencyAdsInCells_mltlist-1)
                let b = listingsResponse.count
                let Totalrowcount = a+b
                if Totalrowcount % kFrequencyAdsInCells_mltlist == 0
                {
                    return Totalrowcount-1
                }
                else
                {
                    return Totalrowcount
                }
                
            }
            else
            {
                //print("total rows with  \(listingsResponse.count)")
                return listingsResponse.count
            }
            
        }
        return listingsResponse.count
    }
    
    // Set Cell of TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var row = (indexPath as NSIndexPath).row as Int
        
        if (kFrequencyAdsInCells_mltlist > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_mltlist) == (kFrequencyAdsInCells_mltlist)-1))
        {  // or 9 == if you don't want the first cell to be an ad!
            let cellIdentifier = String((indexPath as NSIndexPath).section) + "-" + String((indexPath as NSIndexPath).row)
            listingsTableView.register(NativeAdinstallFeedCell.self, forCellReuseIdentifier: cellIdentifier)
            let cell = listingsTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NativeAdinstallFeedCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            var Adcount: Int = 0
            Adcount = row/(kFrequencyAdsInCells_mltlist-1)
            
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
                if adsType_mltlist == 2{
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
            
            return cell
            
        }
        else
        {
            
            if kFrequencyAdsInCells_mltlist > 4 && nativeAdArray.count > 0
            {
                row = row - (row / kFrequencyAdsInCells_mltlist)
            }
            //LAYOUT LIKE BLOG VIEW
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            
            var listingInfo:NSDictionary
            listingInfo = listingsResponse[row] as! NSDictionary
            
            cell.featuredLabel.isHidden = true
            cell.sponsoredLabel.isHidden = true
            // Set Blog Title
            
            if browseOrMyListings
            {
                cell.imgUser.frame = CGRect(x: 5, y: 7, width: 60, height: 60)
            }
            else
            {
                cell.imgUser.frame = CGRect(x: 5, y: 12, width: 60, height: 60)
            }
            
             cell.labTitle.frame = CGRect(x:  cell.imgUser.frame.origin.x + cell.imgUser.frame.size.width + 5, y: 10, width: cell.frame.size.width - 2 * (cell.imgUser.frame.origin.x + cell.imgUser.frame.size.width + 5), height: 20)
            cell.labTitle.text = listingInfo["title"] as? String
            cell.labTitle.numberOfLines = 1
            
            cell.labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
            
            cell.labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
            cell.labTitle.sizeToFit()
            cell.labTitle.frame.size.width = view.bounds.width - (cell.imgUser.frame.origin.x + cell.imgUser.frame.size.width + 15)
            
            if let ownerName = listingInfo["owner_title"] as? String {
                if let postedDate = listingInfo["creation_date"] as? String{
                    let date = dateDifferenceWithEventTime(postedDate)
                    var DateC = date.components(separatedBy: ", ")
                    var tempInfo = ""
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    
                    
                    
                    cell.labMessage.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5,width: (UIScreen.main.bounds.width - 75) , height: 25)
                    cell.labMessage.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                    
                    var labMsg = ""
                    
                    if browseOrMyListings {
//                        labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), ownerName, tempInfo)
                        let location = listingInfo["location"] as? String
                        if location != "" && location != nil
                        {
                            labMsg = String(format: NSLocalizedString("\(locationIcon) %@ - %@", comment: ""), location!, tempInfo)
                        }
                        else
                        {
                            labMsg = String(format: NSLocalizedString(" %@", comment: ""), tempInfo)
                        }
                        cell.postCount.isHidden = true
                    }else{
                        
                        labMsg = String(format: NSLocalizedString("%@", comment: ""), tempInfo)
                        
                        var listingStats = ""
                        let view_count = listingInfo["view_count"]
                        let review_count = listingInfo["review_count"]
                        let comment_count = listingInfo["comment_count"]
                        let like_count = listingInfo["like_count"]
                        
                        listingStats = String(format: NSLocalizedString("\(viewIcon) \(view_count!)  \(starIcon) \(review_count!)  \(commentIcon) \(comment_count!)  \(likeIcon) \(like_count!)", comment: ""))
                        
                        // postCount is being used to show the listing stats
                        cell.postCount.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labMessage.frame.origin.y + cell.labMessage.bounds.height, width: (UIScreen.main.bounds.width - 75), height: 20)
                        cell.postCount.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                        cell.postCount.textColor = UIColor.gray
                        
                        cell.postCount.text = listingStats
                        cell.postCount.sizeToFit()
                        cell.postCount.isHidden = false
                        
                    }
                    
                    cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        return mutableAttributedString
                    })
                    
                    
                }
            }
            
            cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labMessage.numberOfLines = 1
            cell.labMessage.sizeToFit()
            cell.labMessage.frame.size.width = view.bounds.width - (cell.imgUser.frame.origin.x + cell.imgUser.frame.size.width + 15)
            cell.labMessage.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            
            if(listingInfo["closed"] as! Int == 1){
                cell.imageview.isHidden = false
                cell.imageview.text = "\(closedIcon)"
            }
            else{
                cell.imageview.isHidden = true
            }
            
            if listingInfo.object(forKey: "price") != nil && (listingInfo["price"] as! Double > 0 ){
                
                if listingInfo["currency"] != nil{
                    
                    let currencySymbol = getCurrencySymbol(listingInfo["currency"] as! String)
                    profileCurrencySymbol = currencySymbol
                }
            }
            
            // Set featured and Sponsered Labels
            
            if browseOrMyListings {
                cell.imgUser.frame = CGRect(x: 5, y: 7, width: 60, height: 60)
                //   cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10, width: cell.bounds.width - (cell.imgUser.bounds.width + 60 + 20), height: 20)
                
                if listingInfo["sponsored"] != nil && listingInfo["sponsored"] as! Int == 1
                {
                    if listingInfo["featured"] != nil && listingInfo["featured"] as! Int == 1
                    {
                        cell.featuredLabel.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labMessage.frame.origin.y + cell.labMessage.frame.size.height + 5, width: 60, height: 20)
                        cell.featuredLabel.isHidden = false
                        
                        cell.sponsoredLabel.frame = CGRect(x: cell.featuredLabel.frame.origin.x + cell.featuredLabel.bounds.width + 10, y: cell.labMessage.frame.origin.y + cell.labMessage.frame.size.height + 5, width: 70, height: 20)
                        cell.sponsoredLabel.isHidden = false
                        
                        
                    }
                    else
                    {
                        cell.sponsoredLabel.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labMessage.frame.origin.y + cell.labMessage.frame.size.height + 5, width: 70, height: 20)
                        cell.sponsoredLabel.isHidden = false
                        cell.featuredLabel.isHidden = true
                    }
                    
                }
                else if listingInfo["featured"] != nil && listingInfo["featured"] as! Int == 1
                {
                    
                    cell.featuredLabel.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labMessage.frame.origin.y + cell.labMessage.frame.size.height + 5, width: 60, height: 20)
                    cell.featuredLabel.isHidden = false
                    cell.sponsoredLabel.isHidden = true
                }
                
                
            }
            else
            {
                cell.imgUser.frame = CGRect(x: 5, y: 12, width: 60, height: 60)
                // cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10, width: cell.bounds.width - (cell.imgUser.bounds.width + 60 + 20), height: 20)
                cell.featuredLabel.isHidden = true
                cell.sponsoredLabel.isHidden = true
                
            }
            
            
            // Set Listing Owner Image
            
            if let url = URL(string: listingInfo["image"] as! String){

                cell.imgUser.kf.indicatorType = .activity
                (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
                })
            }
            
            cell.optionMenu.frame = CGRect(x: view.bounds.width - 40, y: cell.labTitle.frame.origin.y + cell.labTitle.frame.height, width: 40, height: cell.labMessage.frame.height + cell.postCount.frame.height)
            
            cell.optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
            cell.optionMenu.addTarget(self, action: #selector(MLTBrowseListViewController.showListingMenu(_:)), for: .touchUpInside)
            cell.optionMenu.tag = row
            if browseOrMyListings {
                cell.accessoryView = nil
                cell.optionMenu.isHidden = true
                
            }else{
                cell.accessoryView = nil
                cell.optionMenu.isHidden = false
                
            }
            
            cell.lineView.frame = CGRect(x: 0, y: cell.bounds.height, width: (UIScreen.main.bounds).width, height: 1)
            cell.lineView.isHidden = false
            
            return cell
            
        }
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         var row = (indexPath as NSIndexPath).row as Int
         if (kFrequencyAdsInCells_mltlist > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_mltlist) == (kFrequencyAdsInCells_mltlist)-1))
        {
            
            let cell = tableView.cellForRow(at: indexPath) as! NativeAdinstallFeedCell
            cell.selectionStyle = .none
            
            cell.backgroundColor = .clear
            
            if muteVideo == true
            {
                muteVideo = false
                shared1.muteVideosFor(tableView: self.listingsTableView)
                cell.btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                //sender.setTitle("\(unMuteIconIcon)", for: .normal)
            }
            else
            {
                muteVideo = true
                shared1.muteVideosFor(tableView: self.listingsTableView)
                cell.btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                //sender.setTitle("\(muteVideoIcon)", for: .normal)
            }
            print(row)
        }
         else{
        tableView.deselectRow(at: indexPath, animated: true)
        var listingInfo:NSDictionary
        var index = Int()
        if kFrequencyAdsInCells_mltlist > 4 && nativeAdArray.count > 0
        {
            let row = (indexPath as NSIndexPath).row/kFrequencyAdsInCells_mltlist
            index = (indexPath as NSIndexPath).row-row
        }
        else
        {
            index = (indexPath as NSIndexPath).row
        }
        listingInfo = listingsResponse[index] as! NSDictionary
        
        if(listingInfo["allow_to_view"] as! Int == 1){
            
            SiteMltObject().redirectToMltProfilePage(self ,subjectType : "sitereview_listing" , listingTypeIdValue : listingInfo["listingtype_id"] as! Int , listingIdValue : "\(listingInfo["listing_id"]!)" , viewTypeValue : viewType)
        }
        else
        {
            showToast(message:  NSLocalizedString("You do not have permission to view this private page.",  comment: ""), controller: self)
        }
        }
    }
    
    // MARK: - Actions
    
    // Refersh table content
    @objc func refresh(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            arrGlobalFacebookAds.removeAll()
            checkforAds()
            searchDic.removeAll(keepingCapacity: false)
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            scrollView.isUserInteractionEnabled = false
            browseEntries()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            scrollView.isUserInteractionEnabled = true
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    // SET THE BROWSE LISTING CONTENT
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
//            self.refreshButton.isHidden = true
//            self.contentIcon.isHidden = true

            var path = ""
            var parameters = [String:String]()
            if self.tabBarController?.selectedIndex == 1 {
                listingTypeId = globalListingTypeId
                listingName = globalListingName
                viewType = globalViewType
            }
            if self.tabBarController?.selectedIndex == 2 {
                listingTypeId = globalListingTypeId1
                listingName = globalListingName1
                viewType = globalViewType1
            }
            if self.tabBarController?.selectedIndex == 3 {
                listingTypeId = globalListingTypeId2
                listingName = globalListingName2
                viewType = globalViewType2
            }
            
            // Set Parameters for Browse/MyListings
            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                browseOrMyListings = true
            }
            
            if browseOrMyListings {
                path = "listings"
                if listingOption != nil && listingOption.tag  == 100 {
                    
                    listingSeeAllFilter.isHidden = false
                    listingOption.setSelectedButton()
                }
                if Locationdic != nil
                {
                    let defaults = UserDefaults.standard
                    
                    if let loc = defaults.string(forKey: "Location")
                    {
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id), "listingtype_id": String(listingTypeId), "restapilocation": loc, "listing_filter": showListingType]
                        }else{
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "listingtype_id": String(listingTypeId), "restapilocation": loc, "listing_filter": showListingType]
                            
                        }
                    }
                    else
                    {
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id), "listingtype_id": String(listingTypeId), "restapilocation": defaultlocation, "listing_filter": showListingType]
                        }else{
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "listingtype_id": String(listingTypeId), "restapilocation": defaultlocation, "listing_filter": showListingType]
                            
                        }
                        //listingsTableView.isHidden = true
                    }
                    
                    
                }else{
                    if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                        
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id), "listingtype_id": String(listingTypeId), "listing_filter": showListingType]
                        
                    }else{
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "listingtype_id": String(listingTypeId), "listing_filter": showListingType]
                    }
                }

                
                if listingOption != nil && listingOption.tag  == 102 && showOnlyMyContent == false {
                    
                    scrollView.contentOffset = CGPoint(x: 0, y: -64)
                    
                }
                

            }
            else{
                path = "listings/manage"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "listingtype_id": String(listingTypeId), "getGutterMenu": "1"]


            }
            
            
            if (self.pageNumber == 1){
                
                if updateAfterAlert == true || searchDic.count > 0 {
                    self.listingsResponse.removeAll(keepingCapacity: false)
                    removeAlert()
                    if let responseCacheArray = self.responseCache["\(path)"]{
                      //  showSpinner = false
                        self.listingsResponse = responseCacheArray as! [AnyObject]
                    }
                  //  self.listingsTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
                
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = mainView.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
             //   activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                
                if isUserInteractionEnabled == false{
                    self.view.isUserInteractionEnabled = false
                }
            }
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.scrollView.isUserInteractionEnabled = true
                    self.listingsTableView.tableFooterView?.isHidden = true
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.listingsResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if self.browseOrMyListings
                            {
                                if response["response"] != nil {
                                    if let listing = response["response"] as? NSArray {
                                        self.listingsResponse = self.listingsResponse + (listing as [AnyObject])
                                        
                                        if self.showOnlyMyContent == false {
                                            self.navtitle.text = NSLocalizedString(self.listingName,  comment: "")
                                        }
                                        else{
//                                            let count = response["totalItemCount"] as? Int
//                                            let title = "Products " + "(" + "\(count!)" + ")" + " : " + self.username
//                                            self.countListTitle = title
//                                            self.Updatetitle()
                                        }

                                        
                                        if (self.pageNumber == 1){
                                            self.responseCache["\(path)"] = listing
                                        }
                                    }
                                }
                            }
                            else{
                                if response["listings"] != nil {
                                    if let listing = response["listings"] as? NSArray {
                                        self.listingsResponse = self.listingsResponse + (listing as [AnyObject])
                                        
                                        if (self.pageNumber == 1){
                                            self.responseCache["\(path)"] = listing
                                        }
                                    }
                                }
                            }
                            
                            if response["packagesEnabled"] != nil
                            {
                                self.packagesEnabled = response["packagesEnabled"] as! Int
                            }
                            
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                            if self.showOnlyMyContent == false {
                                
                                if(response["canCreate"] != nil && response["canCreate"] as! Bool == true){
                                    
                                    
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(MLTBrowseListViewController.searchItem))
                                    searchItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20.0)
                                    let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(MLTBrowseListViewController.addNewListing))
                                    self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                    addBlog.imageInsets = UIEdgeInsets(top: 0,left: -20, bottom: 0, right: 0)
                                    searchItem.tintColor = textColorPrime
                                    addBlog.tintColor = textColorPrime
                                    self.showAppTour()
                                    
                                }else{
                                    
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(MLTBrowseListViewController.searchItem))
                                    self.navigationItem.rightBarButtonItem = searchItem
                                    searchItem.tintColor = textColorPrime
                                    
                                }
                            }
                        }
                        
                        self.isPageRefresing = false
                        
                        //Reload Listing Table
                        if NotPlay != 1 {
                            self.pausePlayeVideos()
                        }
                        self.listingsTableView.reloadData()
                        
                        if self.listingsResponse.count == 0{
                            
//                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(listingDefaultIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
//                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
//                            self.mainView.addSubview(self.contentIcon)
//                            
//                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any listings entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
//                            self.info.sizeToFit()
//                            self.info.tag = 1000
//                            self.info.numberOfLines = 0
//                            self.info.center = self.view.center
//                            self.info.backgroundColor = bgColor
//                            self.mainView.addSubview(self.info)
//                            
//                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
//                            self.refreshButton.backgroundColor = bgColor
//                            self.refreshButton.layer.borderColor = navColor.cgColor
//                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
//                            self.refreshButton.addTarget(self, action: #selector(MLTBrowseListViewController.browseEntries), for: UIControl.Event.touchUpInside)
//                            self.refreshButton.layer.cornerRadius = 5.0
//                            self.refreshButton.layer.masksToBounds = true
//                            self.mainView.addSubview(self.refreshButton)
//                            self.refreshButton.isHidden = false
//                            self.contentIcon.isHidden = false
//                            self.info.isHidden = false
                            self.noContentView = NoContentView()
                            self.noContentView.tag = 1000
                            self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                            self.mainView.addSubview(self.noContentView)
                            self.noContentView.isHidden = false
                            self.noContentView.button.layer.borderWidth = 1
                            self.noContentView.button.layer.borderColor = buttonColor.cgColor
                            self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal) 
                            self.noContentView.button.addTarget(self, action: #selector(MLTBrowseListViewController.addNewListing), for: .touchUpInside)
                            self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
                            
                            
                        }
                        if self.isUserInteractionEnabled == false{
                            self.isUserInteractionEnabled = true
                            self.view.isUserInteractionEnabled = true
                        }
                        
                    }else{
                        
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                    }
                    
                })
            }
        }else{
            // No Internet Connection Message
            self.scrollView.isUserInteractionEnabled = true
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    // MARK: Create Scrollable Menu
    func createScrollableListingMenu()
    {
        openMenu = false
        scrollView.frame = CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: ButtonHeight)
        scrollView.delegate = self
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        if self.tabBarController?.selectedIndex == 1 {
            listingTypeId = globalListingTypeId
            listingName = globalListingName
            viewType = globalViewType
        }
        if self.tabBarController?.selectedIndex == 2 {
            listingTypeId = globalListingTypeId1
            listingName = globalListingName1
            viewType = globalViewType1
        }
        if self.tabBarController?.selectedIndex == 3 {
            listingTypeId = globalListingTypeId2
            listingName = globalListingName2
            viewType = globalViewType2
        }
        
        if logoutUser == false
        {
            var listingMenu = ["Categories","%@"]
            var origin_x:CGFloat = 0.0

            menuWidth = CGFloat((view.bounds.width)/2)
            for i in 100 ..< 102
            {
                listingOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title:String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), listingName!), border: true, selected: false)
                
                if i == 101 && browseOrMyListings
                {
                    listingOption.setSelectedButton()
                    
                }
                listingOption.tag = i
                listingOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                listingOption.addTarget(self, action: #selector(MLTBrowseListViewController.listingSelectOptions(_:)), for: .touchUpInside)
                listingOption.backgroundColor =  UIColor.clear//textColorLight
                listingOption.alpha = 1.0
                scrollView.addSubview(listingOption)
                origin_x += menuWidth
                
            }
            
        }
        else
        {
            var listingMenu = ["Browse %@", "Categories"]
            var origin_x:CGFloat = 0.0
            
            menuWidth = CGFloat((view.bounds.width)/2)
            
            for i in 100 ..< 102
            {
                if i == 100
                {   listingOption =  createNavigationButton(CGRect(x: origin_x, y:ScrollframeY, width: menuWidth, height: ButtonHeight), title: String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), listingName), border: false, selected: true)
                }else{
                    listingOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title: String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), listingName), border: false, selected: false)
                    
                }
                listingOption.tag = i
                listingOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                listingOption.addTarget(self, action: #selector(MLTBrowseListViewController.listingSelectOptions(_:)), for: .touchUpInside)
                listingOption.backgroundColor =  UIColor.clear//textColorLight
                listingOption.alpha = 1.0
                scrollView.addSubview(listingOption)
                origin_x += menuWidth
                
            }
            
        }
        scrollView.contentSize = CGSize(width:menuWidth * 2,height:ScrollframeY)

        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.isDirectionalLockEnabled = true;
        mainView.addSubview(scrollView)
        
    }
    
    // MARK: - Listing Selection Action
    @objc func listingSelectOptions(_ sender: UIButton)
    {
        for ob in view.subviews {
            if ob.tag == 1000 {
                ob.removeFromSuperview()
            }
        }
        listingBrowseType = sender.tag - 100
        if listingBrowseType == 0
        {
            browseOrMyListings = false
            listingSeeAllFilter.isHidden = true
        }
        else if listingBrowseType == 1
        {

//        let _ = CGFloat((view.bounds.width)/3)
//        if listingBrowseType == 1 {
//            self.btnFloaty.isHidden = true
//            browseOrMyListings = false
//            listingSeeAllFilter.isHidden = true
//            scrollView.contentOffset.x = 0
//        }else if listingBrowseType == 0 {
//            self.btnFloaty.isHidden = false

            browseOrMyListings = true
            listingSeeAllFilter.isHidden = false
            if showGoogleMapView == true
            {
                showGoogleMapView = false
                let presentedVC = GoogleMapViewController()
                presentedVC.title = listingName
                presentedVC.showOnlyMyContent = false
                presentedVC.listingTypeId = self.listingTypeId
                presentedVC.viewType = viewType
                presentedVC.listingName = listingName
                presentedVC.browseOrMyListings = browseOrMyListings
                presentedVC.dashboardMenuDic = dashboardMenuDic
                navigationController?.pushViewController(presentedVC, animated: false)
            }
        }
        else if listingBrowseType == 2
        {
            self.btnFloaty.isHidden = true
            browseOrMyListings = false
            listingSeeAllFilter.isHidden = false
            scrollView.contentOffset.x = 0
        }
        
        
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
        
        //self.eventResponse.removeAll(keepingCapacity: false)
        searchDic.removeAll(keepingCapacity: false)
        pageNumber = 1
        showSpinner = true

        if listingBrowseType == 0
        {
            browseOrMyListings = false
            showOnlyMyContent = false
            let presentedVC = CategoryBrowseViewController()
            presentedVC.listingName = listingName
            presentedVC.listingTypeId = self.listingTypeId
            presentedVC.browseType = 1
            presentedVC.dashboardMenuDic = dashboardMenuDic
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else
        {
            self.listingsTableView.tableFooterView?.isHidden = true
            scrollView.isUserInteractionEnabled = false
            browseEntries()
        }
        
        
    }
    
    // Create Listing Form
    @objc func addNewListing(){
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            
            if packagesEnabled == 1
            {
                isCreateOrEdit = true
                let presentedVC = PackageViewController()
                presentedVC.contentType = "listings"
                presentedVC.url = "listings/packages"
                presentedVC.listingTypeId = listingTypeId
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)
                
            }else{
                
                isCreateOrEdit = true
                let presentedVC = FormGenerationViewController()
                presentedVC.formTitle = NSLocalizedString("Post A New Listing", comment: "")
                presentedVC.contentType = "listings"
                presentedVC.param = [ : ]
                presentedVC.url = "listings/create"
                presentedVC.listingTypeId = listingTypeId
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)
                
            }
        }
    }
    
    // Open Filter Search Form
    func filterSearch(){
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            searchDic.removeAll(keepingCapacity: false)
            listingUpdate = false
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "listings/search-form"
            presentedVC.serachFor = "listings"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    // Toggle view

    @objc func toggleView()

    {
        listingNameToShow = sitereviewMenuDictionary["headerLabel"] as! String
        sitereviewMenuDictionary = dashboardMenuDic
        
        let anotherViewBrowseType = sitereviewMenuDictionary["anotherViewBrowseType"] as? Int ?? 0
        if anotherViewBrowseType != 0 {
            var browseType = sitereviewMenuDictionary["viewBrowseType"] as? Int ?? 0
            let viewType = sitereviewMenuDictionary["viewProfileType"] as? Int ?? 0
            
            if browseType == 0 || viewType == 0 {
                return
            }
            
            if browseType == 1
            {
                mltToggleView = true
                browseType = anotherViewBrowseType
            }
            else
            {
                mltToggleView = false
            }
            
            if MLTbrowseOrMyListings == nil{
                MLTbrowseOrMyListings = true
            }
            SiteMltObject().redirectToMltBrowsePage(self, showOnlyMyContent: false, listingTypeIdValue : sitereviewMenuDictionary["listingtype_id"] as! Int , listingNameValue : sitereviewMenuDictionary["headerLabel"] as! String , MLTbrowseorMyListingsValue : MLTbrowseOrMyListings! , browseTypeValue : browseType , viewTypeValue : viewType,dashboardMenuDic:dashboardMenuDic)
        }
        else
        {
            return
        }
    }

    // Redirect to Search controller
    @objc func searchItem(){
        let presentedVC = MLTSearchListViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
        listingGlobalTypeId = listingTypeId
        presentedVC.listingTypeId  = listingTypeId
        presentedVC.viewSearchType = viewType
        presentedVC.listingSearchName = listingName
        Formbackup.removeAllObjects()
        listingGlobalTypeId = listingTypeId
        let url : String = "listings/search-form"
        loadFilter(url)
        
    }
    
    // SHOW GUTTER MENUS ON MY LISTINGS PAGE
    @objc func showListingMenu(_ sender:UIButton){
        
        var listingInfo:NSDictionary
        var url = ""
        
        listingInfo = listingsResponse[sender.tag] as! NSDictionary
        editListingID = listingInfo["listing_id"] as! Int
        
        let menuOption = listingInfo["gutterMenus"] as! NSArray
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        
        for menu in menuOption{
            
            if let menuItem = menu as? NSDictionary{
                let titleString = menuItem["name"] as! String
                
//                if menuItem["name"] as! String == "addVideos"{
//                    continue
//                }
                
                
                if titleString.range(of: "delete") != nil{
                    
                    alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertAction.Style.destructive , handler:{ (UIAlertAction) -> Void in
                        let condition = menuItem["name"] as! String
                        
                        switch(condition){
                        case "delete":
                            
                            displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this listing entry?",comment: "") , otherButton: NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                                
                                self.performListingMenuAction(menuItem["url"] as! String)
                                
                            }
                            self.present(alert, animated: true, completion: nil)
                            
                            
                        default:
                            showToast(message: unconditionalMessage, controller: self)
                            
                        }
                    }))
                    
                    
                }
                else
                {
                    alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                        let condition = menuItem["name"] as! String
                        
                        switch(condition){
                            
                        case "videoCreate" :
                            addvideo_click = 1
                            manage_advvideoshow = true
                            isCreateOrEdit = true
                            let presentedVC = FormGenerationViewController()
                            presentedVC.formTitle = NSLocalizedString("Add New Video", comment: "")
                            presentedVC.contentType = "Advanced Video"
                            if sitevideoPluginEnabled_mlt == 1
                            {
                                let subject_type = menuItem["subject_type"] as! String
                                let subject_id =   menuItem["subject_id"] as! Int
                                presentedVC.param = ["subject_id":"\(subject_id)","subject_type" :"\(subject_type)" ]
                            }
                            let url = menuItem["url"] as! String
                            presentedVC.url = url
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:true, completion: nil)
                            
                            
                        case "edit":
                            isCreateOrEdit = false
                            let presentedVC = FormGenerationViewController()
                            presentedVC.contentType = "listings"
                            var editFormTitle = "Edit Listing"
                            if menuItem["label"] != nil{
                                editFormTitle = menuItem["label"] as! String
                            }
                            presentedVC.formTitle = NSLocalizedString(editFormTitle, comment: "")
                            presentedVC.listingTypeId = self.listingTypeId
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:false, completion: nil)
                            
                        case "addPhotos":
                            
                            let presentedVC = UploadPhotosViewController()
                            presentedVC.contentType = "sitereview_photo"
                            presentedVC.directUpload = false
                            presentedVC.url = "listings/photo/\(self.editListingID)"
                            presentedVC.param = ["listing_id":"\(self.editListingID)", "listingtype_id": String(self.listingTypeId)]
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                            self.navigationController?.pushViewController(presentedVC, animated: true)
                            
                        case "tellafriend":
                            
                            let presentedVC = TellAFriendViewController();
                            url = menuItem["url"] as! String
                            presentedVC.url = url
                            self.navigationController?.pushViewController(presentedVC, animated: true)
                            
                        case "close":
                            Reload = "Not Refresh"
                            
                            self.performListingMenuAction(menuItem["url"] as! String)
                            
                        case "open":
                            Reload = "Not Refresh"
                            
                            self.performListingMenuAction(menuItem["url"] as! String)
                            
                        case "makePayment":
                            
                            let presentedVC = ExternalWebViewController()
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let navigationController = UINavigationController(rootViewController: presentedVC)
                            self.present(navigationController, animated: true, completion: nil)
                            
                        case "upgrade_package":
                            let presentedVC = PackageViewController()
                            presentedVC.contentType = "listings"
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.urlParams = menuItem["urlParams"] as! NSDictionary
                            presentedVC.listingTypeId = self.listingTypeId
                            presentedVC.isUpgradePackageScreen = true
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:false, completion: nil)

                        default:
                            
                            print("error")
                            
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
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
        
    }
    
    // Perform action when selected from gutter menus
    func performListingMenuAction(_ url : String){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
         //   activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            let dic = Dictionary<String, String>()
            
            var method:String
            
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            // Send Server Request to Explore Classified Contents with Classified_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update Classified Detail
                        // Update Classified Detail
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        updateAfterAlert = false
                        self.browseEntries()
                        self.isUserInteractionEnabled = false
                        self.listingsTableView.reloadData()
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
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer() {
        stop()
      //  if popAfterDelay == true{
            _ = self.navigationController?.popViewController(animated: true)
            
       // }
    }
    // Handle Scroll For Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.tag == 2
        {
            
            if scrollView.contentOffset.x>45
            {
                for ob in scrollView.subviews
                {
                    if ob .isKind(of: UIButton.self)
                    {
                        if ob.tag == 102
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
                        if ob.tag == 102
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
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                // Check for Page Number for Browse Blog
//                if listingsTableView.contentOffset.y >= listingsTableView.contentSize.height - listingsTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            listingsTableView.tableFooterView?.isHidden = false
                            //if searchDic.count == 0{
                                if adsType_mltlist == 2 || adsType_mltlist == 4{
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
                        listingsTableView.tableFooterView?.isHidden = true
                }
                    
               // }
                
            }
            
        }
        
    }
    
    @objc func goBack(){
        sitevideoPluginEnabled_mlt = 0
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    // MARK: - Show Feed Filter Options Action
    // Show Feed Filter Options Action

   @objc func showListingFilterOptions(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        
        let alertController = UIActionSheet(title: "Choose Option", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles:"See All", "Featured", "Sponsored")
        
        alertController.show(in: self.view)
        searchDic.removeAll(keepingCapacity: false)
        
        
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        switch (buttonIndex){
            
        case 0:
            
            print("cancel")
            
        case 1:
            showListingType = ""
            let fitertext = NSLocalizedString("See All", comment: "") + " " + searchFilterIcon
            filterTitle = fitertext
            listingSeeAllFilter.setTitle(fitertext, for: .normal)
            scrollView.isUserInteractionEnabled = false
            pageNumber=1
            self.showSpinner = true
            browseEntries()
            
        case 2:
            
            showListingType = "featured"
            let fitertext = "Featured" + " " + searchFilterIcon
            filterTitle = fitertext
            listingSeeAllFilter.setTitle(fitertext, for: .normal)
            scrollView.isUserInteractionEnabled = false
            pageNumber=1
            self.showSpinner = true
            browseEntries()
            
        case 3:
            
            showListingType = "sponsored"
            let fitertext = "Sponsored" + " " + searchFilterIcon
            filterTitle = fitertext
            listingSeeAllFilter.setTitle(fitertext, for: .normal)
            scrollView.isUserInteractionEnabled = false
            pageNumber=1
            self.showSpinner = true
            browseEntries()
            
            
        default:
            
            print("Default")
            
        }
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
