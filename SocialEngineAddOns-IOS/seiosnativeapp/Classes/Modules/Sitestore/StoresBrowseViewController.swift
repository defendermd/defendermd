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
//  StoresBrowseViewController.swift
//  seiosnativeapp
//

import UIKit
//import GoogleMobileAds
import FBAudienceNetwork
import NVActivityIndicatorView
import Instructions

var storeUpdate: Bool!
var storePackageEnabled = 0
var storeCreationEnabled = 0
class StoresBrowseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, FBNativeAdDelegate, FBNativeAdsManagerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate,UIGestureRecognizerDelegate{
    
    
    
    let mainView = UIView()
    var showOnlyMyContent:Bool!                 // This variable is used to identify what to show i.e. content respected to subject only or not.
    var noContentView : NoContentView!
    var storesTableView:UITableView!            // TableView to show the Listing Contents
    var categoryTableView:UITableView!          // TableView to show Categories
    var refresher:UIRefreshControl!             // Refresher is used for pull to refresh functionality
    var refresher2:UIRefreshControl!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var storesResponse = [AnyObject]()          // For response come from Server
    var categoryResponse = [AnyObject]()
    var browseOrMyStores = true                 // True ==> Browse Stores,  False ==> My Listings
    var updateScrollFlag = true                 // Pagination Flag
    var showSpinner = true                      // Not show spinner at pull to refresh
    var fromTab : Bool! = false
    var user_id : Int!
    var isPageRefresing = false                 // For Pagination
    var editStoreID:Int = 0
    var size:CGFloat = 0;
    let scrollView = UIScrollView()
    var storeOption:UIButton!
    var storeBrowseType:Int!
    var dynamicHeight:CGFloat = 263.0
    var viewType : Int!
    var isUserInteractionEnabled : Bool!
    var responseCache = [String:AnyObject]()
    var navigationView = UIView()
    // AdMob Variable
//    var adLoader: GADAdLoader!
    var loadrequestcount = 0
    var adsCount:Int = 0
    var isnativeAd:Bool = true
    
    
    // Packages Enables or not
    
    var packagesEnabled = 1
    
    
    
    // Floating Icon at bottom of the page
    
    
    var addItem : UIButton?
    
    

    // Native FacebookAd Variable
    var nativeAd:FBNativeAd!
    var adChoicesView: FBAdChoicesView!
    var adTitleLabel:UILabel!
    var adIconImageView:UIImageView!
    var adImageView:FBMediaView!
    var adBodyLabel:UILabel!
    var adCallToActionButton:UIButton!
    var fbView:UIView!
    var admanager:FBNativeAdsManager!
    var Adiconview:UIImageView!
    
    var storeSlideshow: ContentSlideshowScrollView!
    var slideShowHeading: UILabel!
    var storeSlideShowView: UIView!
    var dynamicHeaderHeight: CGFloat = 0.0001
    var requiredStoresResponse = [AnyObject]()
    var cartButton = UIBarButtonItem()
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
    var nativeAdArray = [AnyObject]()
    var adsImage : UIImageView!
    var adsCellheight:CGFloat = 250.0
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
        shared1 = VideoPlayerController()

        if fromTab == false{
            setDynamicTabValue()
        }
        storeUpdate = true
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        self.navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        removeMarqueFroMNavigaTion(controller: self)
        
        
        category_filterId = nil
        openMenu = false
        updateAfterAlert = true
        isUserInteractionEnabled = true
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        self.navigationItem.hidesBackButton = true
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        navigationView.frame = CGRect(x:0, y: TOPPADING, width: view.bounds.width, height: ButtonHeight)
        //self.mainView.addSubview(navigationView)
        
        if showOnlyMyContent == false
        {
            if logoutUser == false
            {
                //createNavMenu()
                createScrollableStoreMenu()
            }
            
        }
      
        // Initialize Blog Table
        if logoutUser == false
        {
            storesTableView = UITableView(frame: CGRect(x:0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight ), style:.grouped)
        }
        else
        {

            storesTableView = UITableView(frame: CGRect(x:0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height-(TOPPADING) - tabBarHeight ), style:.grouped)
        }
        
        storesTableView.register(MLTGridTableViewCell.self, forCellReuseIdentifier: "CellThree")
        storesTableView.rowHeight = 253
        storesTableView.dataSource = self
        storesTableView.delegate = self
        storesTableView.isOpaque = false
        storesTableView.backgroundColor = tableViewBgColor
        storesTableView.separatorColor = TVSeparatorColorClear
        storesTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        mainView.addSubview(storesTableView)
        
        
        // Categories Table View to show categories
        categoryTableView = UITableView(frame: CGRect(x:0, y: TOPPADING + ButtonHeight + 10, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight + tabBarHeight)), style:.grouped)
        categoryTableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "Cellone")
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        categoryTableView.isOpaque = false
        categoryTableView.isHidden = true
        categoryTableView.estimatedRowHeight = 165.0
        categoryTableView.rowHeight = UITableView.automaticDimension
        categoryTableView.backgroundColor = bgColor
        categoryTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            categoryTableView.estimatedRowHeight = 0
            categoryTableView.estimatedSectionHeaderHeight = 0
            categoryTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview( categoryTableView)
        
        let footerView2 = UIView(frame: frameActivityIndicator)
        footerView2.backgroundColor = UIColor.clear
        let activityIndicatorView2 = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView2.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView2.addSubview(activityIndicatorView2)
        activityIndicatorView2.startAnimating()
        categoryTableView.tableFooterView = footerView2
        categoryTableView.tableFooterView?.isHidden = true
        
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        storesTableView.tableFooterView = footerView
        storesTableView.tableFooterView?.isHidden = true
        
        // Create featured and sponserd slider which will be added to table header later on
        createSlider()

        
        // Set pull to refresh for content table
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(StoresBrowseViewController.refresh), for: UIControl.Event.valueChanged)
        storesTableView.addSubview(refresher)
        
        
        refresher2 = UIRefreshControl()
        refresher2.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher2.addTarget(self, action: #selector(StoresBrowseViewController.refresh), for: UIControl.Event.valueChanged)
        categoryTableView.addSubview(refresher2)
        
        
        if logoutUser == true || showOnlyMyContent == true{
            
            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.plain , target:self , action: Selector(("cancelSearch")))
            self.navigationItem.rightBarButtonItem = addCancel
        }
        
        if adsType_stores != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(StoresBrowseViewController.checkforAds),
                                           userInfo: nil,
                                           repeats: false)
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
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
        case 0:
            
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 1/2", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Next ", comment: "")
            
           
            
        case 1:
            if storeCreationEnabled == 1{
                coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(createTourText)", comment: ""))"
                coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 2/2", comment: "")
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
            }
            else{
                coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(cartTourText)", comment: ""))"
                coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 2/2", comment: "")
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
            }
            
            
            
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
    
    
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showStoreContent"){
            if  UserDefaults.standard.object(forKey: "showStoreContent") != nil {
                showOnlyMyContent = name as! Bool
            }
            UserDefaults.standard.removeObject(forKey: "showStoreContent")
        }
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
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
        if conditionalProfileForm == "BrowseStoreProfile"
        {
            conditionalProfileForm = ""
            navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
            self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = textColorPrime
            
            if openMenu
            {
                openMenu = false
            }
            IsRedirectToStore()
        }
        //storeUpdate = true
        removeNavigationViews(controller: self)
        self.cartButton.customView = cartButtonView(functionOf: self)
        
        if self.showOnlyMyContent == false
        {
            // Below is search link created
            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(StoresBrowseViewController.searchItem))
            let addItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(StoresBrowseViewController.addStoreItem))
            
            addItem.imageInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            searchItem.imageInsets = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
            
           // self.navigationItem.setRightBarButtonItems([addItem, searchItem, self.cartButton], animated: true)
            if logoutUser == false
            {
                if storeCreationEnabled == 1
                {
                    self.navigationItem.setRightBarButtonItems([addItem, searchItem], animated: true)
                }
                else
                {
                    self.navigationItem.setRightBarButtonItems([self.cartButton, searchItem], animated: true)
                }
                
            }
            else
            {
                self.navigationItem.setRightBarButtonItems([self.cartButton, searchItem], animated: true)
            }
            
        }
        else
        {
            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(StoresBrowseViewController.searchItem))
            self.navigationItem.setRightBarButtonItems([self.cartButton, searchItem], animated: true)
        }
        
        
        
        if (storeUpdate == true){
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            scrollView.isUserInteractionEnabled = false
            browseStores()
        }
    }
    @objc func appEnteredFromBackground() {
        
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        
    }
    @objc func appMovedToBackground() {
        self.shared1.pauseVideosFor(tableView: self.storesTableView)
        self.taskVideoPlayPause?.cancel()
    }
    @objc func videoCompletion() {
        
        shared1.currentVideoContainer()?.playOn = true
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        
    }
    func pausePlayeVideos(){
        shared1.pausePlayeVideosFor(tableView: storesTableView)
        
    }
    func IsRedirectToStore()
    {
        let presentedVC = StoresProfileViewController()
        presentedVC.storeId = "\(createResponse["store_id"]!)"
        presentedVC.subjectType = "sitestore_store"
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.title = NSLocalizedString("Stores / Marketplace", comment: "")
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
        
        if showOnlyMyContent == false{
            self.showAppTour()
        }

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delay(0.0) {
            self.shared1.pauseVideosFor(tableView: self.storesTableView)
            self.taskVideoPlayPause?.cancel()
        }
        
        timerFB.invalidate()
        NotificationCenter.default.removeObserver(self)
        globalCatg = ""
        globFilterValue = ""
        self.title = ""
        filterSearchFormArray.removeAll(keepingCapacity: false)
         storesTableView.tableFooterView?.isHidden = true
    }
    
     // Create featured and sponserd slider which will be added to table header later on
    func createSlider(){
        storeSlideShowView = UIView(frame: CGRect(x:0, y: 5, width: view.bounds.width, height: 150))
        storeSlideShowView.backgroundColor = UIColor.white
        storeSlideShowView.isHidden = true
        
        
        slideShowHeading = createLabel(CGRect(x:10, y: 0, width: storeSlideShowView.bounds.width, height: 30), text: "Featured Stores", alignment: .center, textColor: textColorDark)
        slideShowHeading.font = UIFont(name: fontName, size: FONTSIZELarge)
        storeSlideShowView.addSubview(slideShowHeading)
        
        storeSlideshow = ContentSlideshowScrollView(frame: CGRect(x:0, y: 30, width: view.bounds.width, height: 150))
        storeSlideshow.backgroundColor = UIColor.white
        storeSlideshow.delegate = self
        storeSlideShowView.addSubview(storeSlideshow)
        
    }
    
    // Function to Check and Select Packages or to Create Store Form
    @objc func addStoreItem()
    {
        
        print("Add new Store")
        
        
        if storePackageEnabled == 1
        {
            let presentedVC = PackageViewController()
            presentedVC.contentType = "StoreCreate"
            presentedVC.url = "sitestore/package"
            let nativationController = UINavigationController(rootViewController: presentedVC)
            nativationController.modalPresentationStyle = .fullScreen
            self.present(nativationController, animated: false, completion: nil)
        }
        
        else
        {
            let presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Create New Store", comment: "")
            presentedVC.contentType = "StoreCreate"
            // presentedVC.pram = [ : ]
            presentedVC.url = "sitestore/create"
            let nativationController = UINavigationController(rootViewController: presentedVC)
            nativationController.modalPresentationStyle = .fullScreen
            self.present(nativationController, animated: false, completion: nil)
        }
        
    }
    

    @objc func checkforAds(){
        nativeAdArray.removeAll()
        if adsType_stores == 1
        {
            if kFrequencyAdsInCells_stores > 4 && placementID != ""
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
                        storesTableView.reloadData()
                    }
                }
                
            }
            
        }
        else if adsType_stores == 0
        {
            if kFrequencyAdsInCells_stores > 4 && adUnitID != ""
            {
                //showNativeAd()
            }
            
        }
        else if adsType_stores == 2 {
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
            
            dic["type"] =  "\(adsType_stores)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_stores)"
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
                                            self.storesTableView.reloadData()
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
                adCallToActionButton.addTarget(self, action: #selector(StoresBrowseViewController.actionAfterClick(_:)), for: .touchUpInside)
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
                    
                    
                    videoclickButton.addTarget(self, action: #selector(StoresBrowseViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
                    self.fbView.addSubview(videoclickButton)
                }
                else{
                    imageButton.addTarget(self, action: #selector(StoresBrowseViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
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
                        
                        ctaButton.addTarget(self, action: #selector(StoresBrowseViewController.tappedOnAds(_:)), for: .touchUpInside)
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
                    print("check \(nativeAdArray)")
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
                storeUpdate = false
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
                storeUpdate = false
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
            storeUpdate = false
            let presentedVC = ExternalWebViewController()
            presentedVC.url = dic?["cads_url"]! as! String
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated: true, completion: nil)
        }
        
    }
    @objc func actionAfterClick(_ sender: UIButton){
        var dictionary = Dictionary<String, String>()
        dictionary["type"] =  "\(adsType_stores)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_stores)"
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

//    func showNativeAd(){
//
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
    
    func nativeAdsLoaded(){
//        for _ in 0 ..< 10
//        {
//            self.nativeAd = admanager.nextNativeAd
//            fetchAds(nativeAd: self.nativeAd)
//        }
//
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
            storesTableView.reloadData()
        }
        
    }

    func nativeAdsFailedToLoadWithError(_ error: Error){
        //print(error.localizedDescription)
    }
    
    // MARK: - GADAdLoaderDelegate
    
//    func adLoader(_ adLoader: GADAdLoader, didReceive nativeContentAd: GADNativeContentAd) {
//
//    }
//
//    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError){
//        print("\(adLoader) failed with error: \(error.localizedDescription)")
//       // showNativeAd()
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
//            self.storesTableView.reloadData()
//        }
//    }

//    func adLoader(adLoader: GADAdLoader!, didReceiveNativeContentAd nativeContentAd: GADNativeContentAd!) {
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
//            contentAdView.frame = CGRect(x: 0,y:  0, width: UIScreen.main.bounds.width,height: contentAdView.frame.size.height)
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
//            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 5,y: (contentAdView.headlineView as! UILabel).bounds.height + 10 + (contentAdView.headlineView as! UILabel).frame.origin.y,width: contentAdView.bounds.width-10,height: 160)
//        }
//        else
//        {
//            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 5,y: (contentAdView.headlineView as! UILabel).bounds.height + 10 + (contentAdView.headlineView as! UILabel).frame.origin.y,width: contentAdView.bounds.width-10,height: 300)
//        }
//
//        let imgheight = Double(contentAdView.frame.size.height)
//        let imgWidth = Double((contentAdView.imageView as! UIImageView).frame.size.width)
//        (contentAdView.imageView as! UIImageView).image = cropToBounds((nativeContentAd.images?.first as! GADNativeAdImage).image!, width: imgWidth, height: imgheight)
//
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
//
//        nativeAdArray.append(contentAdView)
//        if loadrequestcount <= 10
//        {
//            self.loadrequestcount = self.loadrequestcount+1
//            self.adLoader.delegate = nil
//            self.showNativeAd()
//            self.storesTableView.reloadData()
//        }
//
//    }
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if adsType_stores == 2{
            
            var row = indexPath.row as Int
            if (kFrequencyAdsInCells_stores > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_stores) == (kFrequencyAdsInCells_stores)-1))
            {
                //            displyedAdsCount = (row / kFrequencyAdsInCells_feeds)
                //            row = row - displyedAdsCount
                
                if let cell1 = cell as? NativeMltGridCell
                {
                    
                  
                    
                    var Adcount: Int = 0
                    Adcount = row/(kFrequencyAdsInCells_stores-1)
                    
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
                    print("check5=== \(Adcount)")
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
        if adsType_stores == 2{
            if tableView.tag != 11
            {
                
                let row = indexPath.row as Int
                if  (kFrequencyAdsInCells_stores > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_stores) == (kFrequencyAdsInCells_stores)-1))
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
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
        }else{
            return 0.00001
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dynamicHeaderHeight //0.00001 // + 190
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if storeBrowseType == 2
        {
            return 160.0
        }
        else
        {
            if (kFrequencyAdsInCells_stores > 4 && nativeAdArray.count > 0 && ((indexPath.row % kFrequencyAdsInCells_stores) == (kFrequencyAdsInCells_stores)-1))
            {
                if adsType_stores == 2{
                    guard (UIDevice.current.userInterfaceIdiom != .pad) else {
                        return adsCellheight + 5
                    }
                    return adsCellheight + 5
                }
                else if adsType_stores == 0
                {
                    return 265
                }
                return adsCellheight + 5
            }
            return dynamicHeight
        }
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if storeBrowseType != 2
        {
            if nativeAdArray.count > 0
            {
                var rowcount = Int()
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    rowcount = 2*(kFrequencyAdsInCells_stores-1)
                }
                else
                {
                    rowcount = (kFrequencyAdsInCells_stores-1)
                }
                if storesResponse.count > rowcount
                {
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        let b = Int(ceil(Float(storesResponse.count)/2))
                        adsCount = b/(kFrequencyAdsInCells_stores-1)
                        if adsCount > 1 || storesResponse.count%2 != 0
                        {
                            adsCount = adsCount/2
                        }
                        let Totalrowcount = adsCount+b
                        if b%(kFrequencyAdsInCells_stores-1) == 0 && storesResponse.count % 2 != 0
                        {
                            if adsCount%2 != 0
                            {
                                
                                return Totalrowcount - 1
                            }
                        }
                        else if storesResponse.count % 2 != 0 && adsCount % 2 == 0
                        {
                            
                            return Totalrowcount - 1
                        }
                        
                        return Totalrowcount
                        
                    }
                    else
                    {
                        let b = storesResponse.count
                        adsCount = b/(kFrequencyAdsInCells_stores-1)
                        let Totalrowcount = adsCount+b
                        if Totalrowcount % kFrequencyAdsInCells_stores == 0
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
            
            if(isIpad())
            {
                return Int(ceil(Float(storesResponse.count)/2))
            }
            else
            {
                
                if self.totalItems == 0
                {
                    return 0
                }
                return storesResponse.count
            }
        }
        else
        {
            return Int(ceil(Float(categoryResponse.count)/2))
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        var row = indexPath.row as Int
        if storeBrowseType == 2
        {
            let cell = categoryTableView.dequeueReusableCell(withIdentifier: "Cellone") as! CategoryTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            cell.DiaryName.isHidden = false
            cell.DiaryName1.isHidden = false
            cell.classifiedImageView.frame.size.height = 155
            cell.backgroundColor = UIColor.clear
            var index:Int!
            index = indexPath.row * 2
            
            
            if categoryResponse.count > index
            {
                cell.contentSelection.isHidden = false
                cell.classifiedImageView.isHidden = false
                cell.DiaryName.isHidden = false
                
                if let imageInfo = categoryResponse[index] as? NSDictionary
                {
                    if imageInfo["images"] != nil
                    {

                        if let imagedic = imageInfo["images"] as? NSDictionary
                        {
                            if let url = NSURL(string: imagedic["image"] as! String)
                            {
                                if url != nil
                                {
                                    cell.classifiedImageView.kf.indicatorType = .activity
                                    (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    cell.classifiedImageView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        
                                    })
                                }
                            }
                        }
                    }
                    
                    // LHS
                    cell.DiaryName.text = imageInfo["category_name"] as? String
                    cell.contentSelection.tag = index//imageInfo["category_id"] as! Int
                    cell.contentSelection.addTarget(self, action: #selector(StoresBrowseViewController.showSubCategory(_:)), for: .touchUpInside)
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
                            
                            if let url = NSURL(string: imagedic["image"] as! String)
                            {
                                cell.classifiedImageView.kf.indicatorType = .activity
                                (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.classifiedImageView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                            }
                            
                        }
                    }
                    
                    
                    cell.DiaryName1.text = imageInfo["category_name"] as? String
                    cell.contentSelection1.tag = index+1
                    cell.contentSelection1.addTarget(self, action: #selector(StoresBrowseViewController.showSubCategory(_:)), for: .touchUpInside)
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
        else
        {
            let totalRows = storesResponse.count + adsCount
            if ( totalRows > (indexPath.row - 1 - adsCount))
            {
                var row = (indexPath as NSIndexPath).row as Int
            if (kFrequencyAdsInCells_stores > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_stores) == (kFrequencyAdsInCells_stores)-1))
            {  // or 9 == if you don't want the first cell to be an ad!
                storesTableView.register(NativeMltGridCell.self, forCellReuseIdentifier: "Cell1")
                let cell = storesTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath as IndexPath) as! NativeMltGridCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                cell.backgroundColor = tableViewBgColor
                var Adcount: Int = 0
                Adcount = row/(kFrequencyAdsInCells_stores-1)
                
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
                print("check5=== \(Adcount)")
                // videoUrl = nil
                if nativeAdArray.count > 0 && (nativeAdArray.count > (Adcount))
                {
                    
                    for obj in cell.cellView.subviews
                    {
                        if obj.tag == 1001001 //Condition if that view belongs to any specific class
                        {
                            obj.removeFromSuperview()
                        }
                    }
                    if adsType_stores == 2{
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
                
                //For IPad
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    
                    cell.dateView2.isHidden = true
                    cell.dateView2.frame.size.height = 70
                    cell.dateView2.backgroundColor = navColor
                    
                    cell.titleView2.frame.origin.x = cell.cellView.bounds.width
                    cell.titleView2.frame.size.width = cell.cellView.bounds.width
                    cell.titleView2.frame.size.height = 70
                    cell.titleView2.backgroundColor = UIColor.white
                    
                    var storeInfo2:NSDictionary!
                    let adcount = row/kFrequencyAdsInCells_stores
                    if(storesResponse.count > ((row)*2-adcount) ){
                        storeInfo2 = storesResponse[((row)*2-adcount)] as! NSDictionary
                        cell.cellView2.isHidden = false
                        cell.contentSelection2.isHidden = false
                        cell.dateView2.isHidden = false
                        cell.titleView2.isHidden = false
                        cell.contentSelection2.tag = ((row)*2-adcount)
                        cell.menuButton2.tag = ((row)*2-adcount)
                    }else{
                        cell.cellView2.isHidden = true
                        cell.contentSelection2.isHidden = true
                        cell.dateView2.isHidden = true
                        cell.titleView2.isHidden = true
                        return cell
                    }
                    
                    // Select listing Action
                    cell.contentSelection2.addTarget(self, action: #selector(StoresBrowseViewController.showStoreProfile), for: .touchUpInside)
                    
                    // Set Menu Action
                    cell.menuButton2.addTarget(self, action:#selector(StoresBrowseViewController.showMyStoreMenu) , for: .touchUpInside)
                    cell.contentImage2.frame.size.height = 250
                    cell.contentSelection2.frame = CGRect(x:0, y: 40, width: cell.cellView2.bounds.width, height: cell.cellView2.bounds.height)
                    cell.contentSelection2.frame.size.height = 180
                    
                    // Set Listing Image
                    if let defaultCover = storeInfo2["default_cover"] as? Int{
                        
                        if defaultCover == 0{
                            if defaultCover == 0
                            {
                                cell.contentImage2.backgroundColor = placeholderColor
                                cell.contentImage2.image = nil
                                if let url1 = storeInfo2["cover_image"] as? String
                                {
                                    let url = NSURL(string: url1)
                                    cell.contentImage2.kf.indicatorType = .activity
                                    (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    cell.contentImage2.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        
                                    })
                                    
                                }
                                else
                                {
                                    cell.contentImage2.backgroundColor = placeholderColor
                                    cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_store_thumb_profile_main.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                                }
                            }
                        }else{
                            cell.contentImage2.backgroundColor = placeholderColor
                            cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_store_thumb_profile_main.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                        }
                    }
                    
                    
                    // Set Listing Name
                    
                    let name = storeInfo2["title"] as? String
                    var tempInfo = ""
                    if let listingDate = storeInfo2["starttime"] as? String{
                        
                        let dateMonth = dateDifferenceWithTime(listingDate)
                        var dateArrayMonth = dateMonth.components(separatedBy: ",")
                        if dateArrayMonth.count > 1{
                            cell.dateLabel3.frame = CGRect(x:10, y: 5, width: 50, height: 60)
                            
                            cell.dateLabel3.numberOfLines = 0
                            cell.dateLabel3.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                            cell.dateLabel3.textColor = UIColor.white
                            cell.dateLabel3.font = UIFont(name: "FontAwesome", size: 18)
                        }
                        
                        let date = dateDifferenceWithEventTime(listingDate)
                        var DateC = date.components(separatedBy: ",")
                        tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                        if DateC.count > 3{
                            tempInfo += " at \(DateC[3])"
                        }
                    }
                    else{
                        cell.dateView2.isHidden = true
                    }
                    
                    cell.titleLabel2.frame = CGRect(x:10, y: 0, width: (cell.contentImage2.bounds.width-125), height: 30)
                    
                    cell.titleLabel2.text = "\(name!)"
                    cell.titleLabel2.lineBreakMode = NSLineBreakMode.byWordWrapping
                    
                    let location = storeInfo2["location"] as? String
                    
                    if location != "" && location != nil{
                        
                        cell.dateLabel2.frame = CGRect(x:10, y: 25, width: (cell.contentImage2.bounds.width-70), height: 20)
                        cell.dateLabel2.text = "\(tempInfo)"
                        cell.dateLabel2.textAlignment = NSTextAlignment.left
                        cell.dateLabel2.font = UIFont(name: "FontAwesome", size: 14)
                        
                        cell.locLabel2.isHidden = false
                        cell.locLabel2.frame = CGRect(x:10, y: 45, width: (cell.contentImage2.bounds.width-70), height: 20)
                        cell.locLabel2.text = "\(locationIcon) \(location!)"
                        cell.locLabel2.font = UIFont(name: "FontAwesome", size: 14)
                        
                    }
                    
                    if location == "" || location == nil{
                        
                        cell.locLabel2.isHidden = true
                        cell.dateLabel2.frame = CGRect(x:10, y: 35, width: (cell.contentImage2.bounds.width-70), height: 20)
                        cell.dateLabel2.text = "\(tempInfo)"
                        cell.dateLabel2.textAlignment = NSTextAlignment.left
                        cell.dateLabel2.font = UIFont(name: "FontAwesome", size: 14)
                        
                    }
                    
                    
                    cell.menuButton2.isHidden = true
                    
                    let listingOwnerTitle = storeInfo2["owner_title"] as? String
                    
                    if listingOwnerTitle != "" && listingOwnerTitle != nil{
                        var labMsg = ""
                        if let postedDate = storeInfo2["creation_date"] as? String{
                            let postedOn = dateDifference(postedDate)
                            
                            if browseOrMyStores {
                                labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), listingOwnerTitle!, postedOn)
                                cell.listingDetailsLabel2.isHidden = true
                            }else{
                                labMsg = String(format: NSLocalizedString("%@", comment: ""), postedOn)
                                
                                let view_count = storeInfo2["view_count"]
                                let review_count = storeInfo2["review_count"]
                                let comment_count = storeInfo2["comment_count"]
                                let like_count = storeInfo2["like_count"]
                                
                                cell.lineView2.frame.origin.y = 280
                                cell.titleView2.frame.size.height = 100
                                cell.listingDetailsLabel2.text = "\(viewIcon) \(view_count!) \(reviewIcon) \(review_count!) \(commentIcon) \(comment_count!) \(likeIcon) \(like_count!)"
                                
                                cell.listingDetailsLabel2.isHidden = false
                            }
                        }
                        
                        cell.dateLabel2.text = labMsg
                        
                    }
                    
                    if(storeInfo2["closed"] as! Int == 1){
                        cell.closeIconView2.frame = CGRect(x:cell.contentImage2.bounds.width/2 - cell.contentImage2.bounds.width/6 , y: cell.contentImage2.bounds.height/2 - cell.contentImage2.bounds.height/6, width: cell.contentImage2.bounds.width/3, height: cell.contentImage2.bounds.height/3)
                        cell.closeIconView2.isHidden = false
                        cell.closeIconView2.text = "\(closedIcon)"
                        cell.closeIconView2.font = UIFont(name: "FontAwesome", size: cell.contentImage2.bounds.width/6)
                    }
                    else{
                        cell.closeIconView2.isHidden = true
                    }
                    
                    return cell
                }
                
                return cell
            }
            else
            {
                if kFrequencyAdsInCells_stores > 4 && nativeAdArray.count > 0
                {
                    row = row - (row / kFrequencyAdsInCells_stores)
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath as IndexPath) as! MLTGridTableViewCell
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
                
                //SET CONTENT IMAGE BOUNDS
                //cell.contentImage.frame = CGRect(x:0, 0, cell.cellView.bounds.width, cell.cellView.bounds.height - cell.cellView.bounds.height/4)
                
                cell.ownerImage.frame = CGRect(x:cell.contentImage.bounds.width/2 - 30, y: -30, width: 60, height: 60)
                
                cell.ownerImage.layer.borderColor = UIColor.white.cgColor
                cell.ownerImage.layer.borderWidth = 2.5
                cell.ownerImage.layer.cornerRadius = cell.ownerImage.frame.size.width / 2
                cell.ownerImage.backgroundColor = placeholderColor
                cell.ownerImage.contentMode = UIView.ContentMode.scaleAspectFill
                cell.ownerImage.layer.masksToBounds = true
                cell.ownerImage.image = UIImage(named: "user_profile_image.png")
                cell.ownerImage.tag = 321
                cell.ownerImage.isUserInteractionEnabled = true
                cell.ownerImage.isHidden = false
                
                //SET TITLE VIEW BOUNDS
                
                // TITLE VIEW IS BEING USED TO SHOW THE INFO ABOUT THE CONTENT
                cell.titleView.frame = CGRect(x:0, y: cell.contentImage.bounds.height, width: cell.cellView.bounds.width, height: cell.cellView.bounds.height/4 - 5)
                cell.titleView.backgroundColor = UIColor.white
                
                // SHOWS THE LINE GAP BETWEEN TWO ITEMS
                cell.lineView.isHidden = false
                
                //Hide price tag
                cell.contentName.isHidden = true
                
                // HIDE THE DATE VIEW
                cell.dateView.isHidden = true
                cell.dateLabel.isHidden = true
                
                
                cell.backgroundColor = tableViewBgColor
                cell.layer.borderColor = UIColor.white.cgColor
                
                var storeInfo:NSDictionary!
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    if (kFrequencyAdsInCells_stores > 4 && nativeAdArray.count > 0)
                    {
                        let adcount = row/(kFrequencyAdsInCells_stores-1)
                        if(storesResponse.count > ((row)*2+adcount))
                        {
                            storeInfo = storesResponse[((row)*2+adcount)] as! NSDictionary
                            cell.contentSelection.tag = ((row)*2+adcount)
                            cell.menu.tag = ((row)*2+adcount)
                            
                        }
                    }
                    else
                    {
                        if(storesResponse.count > (row)*2 )
                        {
                            storeInfo = storesResponse[(row)*2] as! NSDictionary
                            cell.contentSelection.tag = (row)*2
                            cell.menu.tag = (row)*2
                        }
                    }
                    
                }
                else
                {
                   // if storesResponse.count > row {
                    storeInfo = storesResponse[row] as! NSDictionary
                    cell.contentSelection.tag = row
                    cell.menuButton.tag = row
                  //  }
                }
                
                cell.contentSelection.addTarget(self, action: #selector(StoresBrowseViewController.showStoreProfile), for: .touchUpInside)
                cell.menuButton.addTarget(self, action:#selector(StoresBrowseViewController.showMyStoreMenu) , for: .touchUpInside)
                cell.contentSelection.frame = CGRect(x:0, y: 40, width: cell.cellView.bounds.width, height: cell.cellView.bounds.height)
                cell.contentSelection.frame.size.height = 180
                
                if let defaultCover = storeInfo["default_cover"] as? Int{
                    
                    if defaultCover == 0
                    {
                        
                        if let url = storeInfo["cover_image"] as? String
                        {
                            let url1 = NSURL(string: url)
                            cell.contentImage.kf.indicatorType = .activity
                            (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                            cell.contentImage.backgroundColor = placeholderColor
                        }
                        else
                        {
                            //cell.contentImage.image = nil
                            cell.contentImage.image = imageWithImage(UIImage(named: "nophoto_store_thumb_profile_main.png")!, scaletoWidth: cell.contentImage.bounds.width)
                            
                        }
                    }
                    else
                    {
                        //cell.contentImage.image = nil
                        cell.contentImage.image = imageWithImage(UIImage(named: "nophoto_store_thumb_profile_main.png")!, scaletoWidth: cell.contentImage.bounds.width)
                        
                    }
                }
                
                if storeInfo["featured"] != nil && storeInfo["featured"] as! Int == 1{
                    cell.featuredLabel.frame = CGRect(x:5, y: 0, width: 66, height: 20)
                    cell.featuredLabel.isHidden = false
                }else{
                    cell.featuredLabel.isHidden = true
                }
                
                if storeInfo["sponsored"] != nil && storeInfo["sponsored"] as! Int == 1{
                    
                    cell.sponsoredLabel.frame = CGRect(x:cell.contentImage.bounds.width - 85, y: 0, width: 80, height: 20)
                    cell.sponsoredLabel.isHidden = false
                }else{
                    cell.sponsoredLabel.isHidden = true
                }
                
                // Update :  On store browse view replace owner image with store profile image and cover image
                
                if let ownerPhotoUrl = storeInfo["image"] as? String{
                    
                    if ownerPhotoUrl != ""
                    {
                        let url1 = NSURL(string: storeInfo["image"] as! NSString as String)
                        cell.ownerImage.kf.indicatorType = .activity
                        (cell.ownerImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.ownerImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                        cell.ownerImage.backgroundColor = placeholderColor
                    }
                    else
                    {
                        cell.ownerImage.image = nil
                        cell.ownerImage.image = imageWithImage( UIImage(named: "nophoto_store_thumb_profile_main.png")!, scaletoWidth: cell.ownerImage.bounds.width)
                        
                    }
                }
                
                let name = storeInfo["title"] as? String
                
                cell.titleLabel.frame = CGRect(x:0, y: 30, width: cell.titleView.bounds.width, height: 25)
                cell.titleLabel.text = "\(name!)"
                cell.titleLabel.textAlignment = .center
                cell.titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                
                var likeCount = 0
                if let tempCount = storeInfo["like_count"] as? Int{
                    likeCount = tempCount
                }
                
                
                
                let likeText = singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: likeCount)
                
                let finalText = likeText
                
                cell.statsLabel.frame = CGRect(x:0, y: cell.titleLabel.frame.origin.y + cell.titleLabel.bounds.height, width: cell.titleView.bounds.width, height: 20)
                cell.statsLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                cell.statsLabel.text = String(format: NSLocalizedString(finalText, comment: ""))
                cell.statsLabel.textAlignment = .center
                cell.statsLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                cell.statsLabel.isHidden = false
                
                //SHOWING CATEGORY
                let storeCategory = storeInfo["category_title"] as? String
                cell.locLabel.frame.origin.y = cell.statsLabel.frame.origin.y + cell.statsLabel.bounds.height
                //IF storeCategory EXISTS
                if storeCategory != "" && storeCategory != nil{
                    
                    cell.locLabel.isHidden = false
                    cell.locLabel.frame = CGRect(x:0, y: cell.statsLabel.frame.origin.y + cell.statsLabel.bounds.height, width: cell.contentImage.bounds.width, height: 25)
                    cell.locLabel.text = "in \(storeCategory!)"
                    cell.locLabel.textAlignment = .center
                    cell.locLabel.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                    
                }
                
                //IF LOCATION DOES NOT EXISTS
                if storeCategory == "" || storeCategory == nil{
                    cell.locLabel.isHidden = true
                }
                
                if(storeInfo["closed"] as! Int == 1){
                    cell.closeIconView.frame = CGRect(x:cell.contentImage.bounds.width/2 - cell.contentImage.bounds.width/6 ,y: cell.contentImage.bounds.height/2 - cell.contentImage.bounds.height/6, width: cell.contentImage.bounds.width/3, height: cell.contentImage.bounds.height/3)
                    cell.closeIconView.isHidden = false
                    cell.closeIconView.text = "\(closedIcon)"
                    cell.closeIconView.font = UIFont(name: "FontAwesome", size: cell.contentImage.bounds.width/6)
                }
                else{
                    cell.closeIconView.isHidden = true
                }
                
                
                cell.likesLabel.frame = CGRect(x:cell.contentImage.bounds.width - 55, y: cell.contentImage.bounds.height - 50, width: 50, height:20)
                cell.likesLabel.textAlignment = .right
                cell.likesLabel.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                cell.likesLabel.text = String(format: NSLocalizedString("\(likeCount) \(likeIcon) ", comment: ""))
                
                
                if browseOrMyStores {
                    cell.menuButton.isHidden = true
                }else{
                    cell.featuredLabel.isHidden = true
                    cell.sponsoredLabel.isHidden = true
                    cell.menuButton.isHidden = false
                    cell.menuButton.titleLabel?.textAlignment = .center
                }
                
                // For Ipad
                if(UIDevice.current.userInterfaceIdiom == .pad){
                    
                    // SHOWS THE LINE GAP BETWEEN TWO ITEMS
                    cell.lineView2.isHidden = false
                    
                    // Hide price tag
                    cell.contentName2.isHidden = true
                    
                    // HIDE THE DATE VIEW
                    cell.dateView2.isHidden = true
                    cell.dateLabel2.isHidden = true
                    
                    //cell.contentImage2.frame = CGRect(x:0, 0, CGRectGetWidth(cell.cellView2.bounds), CGRectGetHeight(cell.cellView2.bounds) - CGRectGetHeight(cell.cellView2.bounds)/4)
                    
                    cell.ownerImage2.frame = CGRect(x:cell.contentImage2.bounds.width/2 - 30, y: -30, width: 60, height: 60)
                    cell.ownerImage2.layer.borderColor = UIColor.white.cgColor
                    cell.ownerImage2.layer.borderWidth = 2.5
                    cell.ownerImage2.layer.cornerRadius = cell.ownerImage2.frame.size.width / 2
                    cell.ownerImage2.backgroundColor = placeholderColor
                    cell.ownerImage2.contentMode = UIView.ContentMode.scaleAspectFill
                    cell.ownerImage2.layer.masksToBounds = true
                    cell.ownerImage2.image = UIImage(named: "user_profile_image.png")
                    cell.ownerImage2.tag = 321
                    cell.ownerImage2.isUserInteractionEnabled = true
                    cell.ownerImage2.isHidden = false
                    
                    cell.titleView2.frame = CGRect(x:cell.titleView.bounds.width,y: cell.contentImage2.bounds.height, width: cell.cellView2.bounds.width, height: cell.cellView2.bounds.height/4 - 5)
                    cell.titleView2.backgroundColor = UIColor.white
                    
                    
                    var storeInfo2:NSDictionary!
                    
                    //Related to ads ??
                    var adcount = Int()
                    if (kFrequencyAdsInCells_stores > 4 && nativeAdArray.count > 0)
                    {
                        adcount = row/(kFrequencyAdsInCells_stores-1)
                    }
                    else
                    {
                        adcount = 0
                    }
                    
                    
                    if(storesResponse.count > ((row)*2+1+adcount) ){
                        storeInfo2 = storesResponse[((row)*2+1+adcount)] as! NSDictionary
                        cell.cellView2.isHidden = false
                        cell.contentSelection2.isHidden = false
                        cell.titleView2.isHidden = false
                        cell.contentSelection2.tag = ((row)*2+1+adcount)
                        cell.menuButton2.tag = ((row)*2+1+adcount)
                    }else{
                        cell.cellView2.isHidden = true
                        cell.contentSelection2.isHidden = true
                        cell.titleView2.isHidden = true
                        return cell
                    }
                    
                    // Set Menu Action
                    cell.menuButton2.addTarget(self, action:#selector(StoresBrowseViewController.showMyStoreMenu) , for: .touchUpInside)
                    
                    // Select listing Action
                    cell.contentSelection2.frame = CGRect(x:cell.cellView.bounds.width, y: 40, width: cell.cellView2.bounds.width, height: cell.cellView2.bounds.height)
                    cell.contentSelection2.addTarget(self, action: #selector(StoresBrowseViewController.showStoreProfile), for: .touchUpInside)
                    cell.contentSelection2.frame.size.height = 180
                    
                    
                    // Set Listing Image
                    if let photoId = storeInfo2["default_cover"] as? Int{
                        
                        if photoId != 0
                        {
                            let url1 = NSURL(string: storeInfo2["image"] as! NSString as String)
                            cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage2.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                            cell.contentImage2.backgroundColor = placeholderColor
                        }
                        else{
                            cell.contentImage2.image = nil
                            cell.contentImage2.image = imageWithImage( UIImage(named: "nophoto_store_thumb_profile_main.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                            
                        }
                    }
                    
                    if storeInfo2["featured"] != nil && storeInfo2["featured"] as! Int == 1{
                        cell.featuredLabel2.frame = CGRect(x:0,y: 0,width: 66, height: 20)
                        cell.featuredLabel2.isHidden = false
                    }else{
                        cell.featuredLabel2.isHidden = true
                    }
                    
                    if storeInfo2["sponsored"] != nil && storeInfo2["sponsored"] as! Int == 1{
                        
                        cell.sponsoredLabel2.frame = CGRect(x:cell.contentImage2.bounds.width - 75, y: 0, width: 75, height: 20)
                        cell.sponsoredLabel2.isHidden = false
                    }else{
                        cell.sponsoredLabel2.isHidden = true
                    }
                    
                    if let ownerPhotoUrl = storeInfo2["image"] as? String{
                        
                        if ownerPhotoUrl != ""
                        {
                            let url1 = NSURL(string: storeInfo2["owner_image"] as! NSString as String)
                            cell.ownerImage2.image = nil
                            cell.ownerImage2.kf.indicatorType = .activity
                            (cell.ownerImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.ownerImage2.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                            cell.ownerImage2.backgroundColor = placeholderColor
                            
                        }
                        else{
                            cell.ownerImage2.image = nil
                            cell.ownerImage2.image = imageWithImage( UIImage(named: "nophoto_store_thumb_profile_main.png")!, scaletoWidth: cell.ownerImage2.bounds.width)
                            
                        }
                    }
                    
                    // Set Listing Name
                    let name = storeInfo2["title"] as? String
                    cell.titleLabel2.frame = CGRect(x:0, y: 30, width: cell.titleView2.bounds.width, height: 25)
                    cell.titleLabel2.text = "\(name!)"
                    cell.titleLabel2.textAlignment = .center
                    cell.titleLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    
                    var likeCount = 0
                    if let tempCount = storeInfo2["like_count"] as? Int{
                        likeCount = tempCount
                    }
                    
                    
                    
                    let likeText = singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: likeCount)
                    
                    let finalText = likeText
                    
                    cell.statsLabel2.frame = CGRect(x:0, y: cell.titleLabel2.frame.origin.y + cell.titleLabel2.bounds.height, width: cell.titleView2.bounds.width, height: 20)
                    cell.statsLabel2.font = UIFont(name: fontName, size: FONTSIZENormal)
                    cell.statsLabel2.text = String(format: NSLocalizedString(finalText, comment: ""))
                    cell.statsLabel2.textAlignment = .center
                    cell.statsLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    cell.statsLabel2.isHidden = false
                    
                    
                    //SHOWING CATEGORY
                    let storeCategory = storeInfo2["category_title"] as? String
                    
                    //IF storeCategory EXISTS
                    if storeCategory != "" && storeCategory != nil{
                        
                        cell.locLabel2.isHidden = false
                        cell.locLabel2.frame = CGRect(x:0, y: cell.statsLabel2.frame.origin.y + cell.statsLabel2.bounds.height, width: cell.contentImage2.bounds.width, height: 25)
                        cell.locLabel2.text = "in \(storeCategory!)"
                        cell.locLabel2.textAlignment = .center
                        cell.locLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                        
                    }
                    
                    //IF LOCATION DOES NOT EXISTS
                    if storeCategory == "" || storeCategory == nil{
                        cell.locLabel2.isHidden = true
                    }
                    
                    if(storeInfo2["closed"] as! Int == 1){
                        cell.closeIconView2.frame = CGRect(x:cell.contentImage2.bounds.width/2 - cell.contentImage2.bounds.width/6 , y: cell.contentImage2.bounds.height/2 - cell.contentImage2.bounds.height/6, width: cell.contentImage2.bounds.width/3, height: cell.contentImage2.bounds.height/3)
                        cell.closeIconView2.isHidden = false
                        cell.closeIconView2.text = "\(closedIcon)"
                        cell.closeIconView2.font = UIFont(name: "FontAwesome", size: cell.contentImage2.bounds.width/6)
                    }
                    else{
                        cell.closeIconView2.isHidden = true
                    }
                    
                    
                    
                    cell.likesLabel2.frame = CGRect(x:cell.contentImage2.bounds.width - 55, y:cell.contentImage2.bounds.height - 50, width: 50, height: 20)
                    cell.likesLabel2.textAlignment = .right
                    cell.likesLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                    cell.likesLabel2.text = String(format: NSLocalizedString("\(likeCount) \(likeIcon)", comment: ""))
                    
                    
                    if browseOrMyStores {
                        cell.menuButton2.isHidden = true
                    }else{
                        cell.menuButton2.isHidden = false
                        cell.menuButton2.titleLabel?.textAlignment = .center
                    }
                    
                    cell.titleView2.frame.size.height = cell.locLabel2.frame.origin.y + cell.locLabel2.bounds.height
                    dynamicHeight = cell.titleView2.frame.origin.y + cell.titleView2.bounds.height + 5
                    cell.cellView2.frame.size.height = dynamicHeight
                    cell.cellView.frame.size.height = dynamicHeight
                    cell.lineView.frame.origin.y = dynamicHeight-5
                    cell.lineView.frame.size.width = view.bounds.width/2
                    cell.lineView2.frame.origin.y = dynamicHeight-5
                    
                    return cell
                }
                
                cell.titleView.frame.size.height = cell.locLabel.frame.origin.y + cell.locLabel.bounds.height
                dynamicHeight = cell.titleView.frame.origin.y + cell.titleView.bounds.height + 5
                cell.cellView.frame.size.height = dynamicHeight
                cell.lineView.frame.origin.y = dynamicHeight-5
                
                return cell
                
            }
            }
        }
        let cell1 = MLTGridTableViewCell()
        return cell1
        }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if (kFrequencyAdsInCells_stores > 4 && nativeAdArray.count > 0 && ((indexPath.row % kFrequencyAdsInCells_stores) == (kFrequencyAdsInCells_stores)-1))
        {
            return adsCellheight + 5
        }
        return dynamicHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        var row = (indexPath as NSIndexPath).row as Int
        // Apply condition for tableViews
        
        if (kFrequencyAdsInCells_stores > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_stores) == (kFrequencyAdsInCells_stores)-1))
        {
            
            let cell = tableView.cellForRow(at: indexPath) as! NativeMltGridCell
            cell.selectionStyle = .none
            
            cell.backgroundColor = .clear
            
            if muteVideo == true
            {
                muteVideo = false
                shared1.muteVideosFor(tableView: self.storesTableView)
                cell.btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                //sender.setTitle("\(unMuteIconIcon)", for: .normal)
            }
            else
            {
                muteVideo = true
                shared1.muteVideosFor(tableView: self.storesTableView)
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
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return storeSlideShowView
    }
    
    // MARK: Scroll Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        if scrollView.tag == 2
        {
            if scrollView.contentOffset.x>45
            {
                for ob in scrollView.subviews
                {
                    if ob .isKind(of:UIButton.self)
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
                    if ob .isKind(of:UIButton.self)
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
//                if storesTableView.contentOffset.y >= storesTableView.contentSize.height - storesTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            storesTableView.tableFooterView?.isHidden = false
                         //   if searchDic.count == 0{
//                                if adsType_stores == 2 || adsType_stores == 4{
//                                    delay(0.1) {
//                                        self.checkforAds()
//                                    }
//                                }
                                browseStores()
                           // }
                        }
                    }
                    else
                    {
                        storesTableView.tableFooterView?.isHidden = true
                }
                    
             //   }
                
            }
            
        }
        
    }

    func createNavMenu()
    {
        var menuWidth = CGFloat()
        if logoutUser == false
        {
            var listingMenu = ["Stores", "My Stores", "Categories"]
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/3)
            for i in 100 ..< 103
            {
                storeOption =  createNavigationButton(CGRect(x:origin_x, y: TOPPADING, width: menuWidth, height: ButtonHeight), title:String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: "")), border: true, selected: false)
                //                if i == 100 && browseOrMyStores
                //                {
                //                    storeOption.setSelectedButton()
                //
                //                }
                storeOption.tag = i
                storeOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                storeOption.addTarget(self, action: #selector(StoresBrowseViewController.storeSelectOptions), for: .touchUpInside)
                storeOption.backgroundColor =  UIColor.clear//textColorLight
                storeOption.alpha = 1.0
                self.navigationView.addSubview(storeOption)
                //self.mainView.addSubview(storeOption)
                //scrollView.addSubview(storeOption)
                origin_x += menuWidth
                
            }
            
        }
    }
    
    @objc func showStoreProfile(sender: UIButton){   
        var storeInfo:NSDictionary!
        storeInfo = storesResponse[sender.tag] as! NSDictionary
        
        if(storeInfo["allow_to_view"] as! Int == 1){
            let presentedVC = StoresProfileViewController()
            presentedVC.storeId = "\(storeInfo["store_id"]!)"
            presentedVC.subjectType = "sitestore_store"
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        else
        {
            showToast(message: NSLocalizedString("You do not have permission to view this private page.",  comment: ""), controller: self)
        }
    }
    
    func createScrollableStoreMenu()
    {
        openMenu = false
        scrollView.frame = CGRect(x:0, y: TOPPADING, width: view.bounds.width, height: ButtonHeight)
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.black
        scrollView.isUserInteractionEnabled = false
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        
        if logoutUser == false
        {
            var listingMenu = ["Stores", "My Stores","Categories"]
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/3)
            for i in 100 ..< 103
            {
                storeOption =  createNavigationButton(CGRect(x:origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title:String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: "")), border: true, selected: false)
                if i == 100 && browseOrMyStores
                {
                    storeOption.setSelectedButton()
                    
                }else if i == 101 && !browseOrMyStores{
                    
                    storeOption.setSelectedButton()
                    
                }
                storeOption.tag = i
                storeOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                storeOption.addTarget(self, action: #selector(StoresBrowseViewController.storeSelectOptions), for: .touchUpInside)
                storeOption.backgroundColor =  UIColor.clear//textColorLight
                storeOption.alpha = 1.0
                if i==102
                {
                    storeOption.alpha = 1.0
                    
                }
                scrollView.addSubview(storeOption)
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
                {   storeOption =  createNavigationButton(CGRect(x:origin_x,y: ScrollframeY, width: menuWidth, height: ButtonHeight), title: String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), self.title!), border: false, selected: true)
                }else{
                    storeOption =  createNavigationButton(CGRect(x:origin_x,y: ScrollframeY, width: menuWidth, height: ButtonHeight), title: String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), self.title!), border: false, selected: false)
                }
                storeOption.tag = i
                storeOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                storeOption.addTarget(self, action: #selector(StoresBrowseViewController.storeSelectOptions), for: .touchUpInside)
                storeOption.backgroundColor =  UIColor.clear//textColorLight
                storeOption.alpha = 1.0
                if i==103
                {
                    storeOption.alpha = 0.4
                    
                }
                scrollView.addSubview(storeOption)
                origin_x += menuWidth
                
            }
            
        }
        scrollView.contentSize = CGSize(width:menuWidth * 3,height:ScrollframeY)
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.isDirectionalLockEnabled = true;
        mainView.addSubview(scrollView)
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.alwaysBounceVertical = false
    
        
    }
    
    // Called when options from tabs are choosen.
    @objc func storeSelectOptions(sender: UIButton){
        for ob in view.subviews {
            if ob.tag == 1000 {
                ob.removeFromSuperview()
            }
        }
        storeBrowseType = sender.tag - 100
        //sender.setSelectedButton()
//        for ob in navigationView.subviews
//        {
//            if ob.tag != sender.tag
//            {
//                let obj = ob as! UIButton
//                obj.setUnSelectedButton()
//            }
//        }
        
        if storeBrowseType == 1 {
            browseOrMyStores = false
        }else if storeBrowseType == 0 {
            browseOrMyStores = true
        }else if storeBrowseType == 2 {
            browseOrMyStores = false
        }
        
        if browseOrMyStores == true
        {
            self.storeSlideShowView.isHidden = true
            //self.dynamicHeaderHeight = 0.0001 + 190
        }
        else
        {
            storeSlideShowView.isHidden = true
            dynamicHeaderHeight = 0.0001
        }
        
        
        if storeBrowseType == 0 || storeBrowseType == 1
        {
            if storesResponse.count == 0
            {
                categoryTableView.isHidden = true
                pageNumber = 1
                showSpinner = true
                scrollView.isUserInteractionEnabled = false
                browseStores()
            }
            else
            {
                let subViews = mainView.subviews
                for ob in subViews{
                    if ob.tag == 1000{
                        ob.removeFromSuperview()
                    }
                    if(ob .isKind(of:NWCalendarView.self))
                    {
                        ob.removeFromSuperview()
                    }
                }
                storesTableView.isHidden = false
                categoryTableView.isHidden = true
                storesTableView.reloadData()
            }
            
        }
        else if storeBrowseType == 2
        {
            if categoryResponse.count == 0
            {
                storesTableView.isHidden = true
                pageNumber = 1
                showSpinner = true
                scrollView.isUserInteractionEnabled = false
                browseStores()
            }
            else
            {

                storesTableView.isHidden = true
                categoryTableView.isHidden = false
                categoryTableView.reloadData()
            }
        }
    
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        for ob in scrollView.subviews{
            if ob .isKind(of:UIButton.self){
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
        scrollView.isUserInteractionEnabled = false
        
        
        
        browseStores()
        
    }
    
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
            browseStores()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            scrollView.isUserInteractionEnabled = true
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    @objc func searchItem(){
        
        let presentedVC = StoresSearchResultsViewController()
        presentedVC.storesSearchName = NSLocalizedString("Stores", comment: "")
        Formbackup.removeAllObjects()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
        let url : String = "sitestore/search-form"
        loadFilter(url)
    }
    
    @objc func browseStores(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {

            
            if showOnlyMyContent == true
            {
                browseOrMyStores = false
            }
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            var path = ""
            var parameters = [String:String]()
            // Set Parameters for Browse/MyListings
            
            if((fromTab != nil) && (fromTab == true) && (user_id != nil))
            {
                browseOrMyStores = true
            }
            
            if browseOrMyStores
            {
                path = "sitestore/browse"
                
                if Locationdic != nil
                {
                    let defaults = UserDefaults.standard
                    
                    if let loc = defaults.string(forKey: "Location")
                    {
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil))
                        {
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","user_id" : String(user_id), "restapilocation": loc]
                        }
                        else
                        {
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "restapilocation": loc ]
                        }
                    }
                    else
                    {
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","user_id" : String(user_id), "restapilocation":defaultlocation ]
                        }
                        else
                        {
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "restapilocation": defaultlocation]
                        }
                    }
                    
                    
                }
                else
                {
                    if((fromTab != nil) && (fromTab == true) && (user_id != nil))
                    {
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","user_id" : String(user_id)]
                    }
                    else
                    {
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                    }
                }
                if storeOption != nil && storeOption.tag  == 102 && showOnlyMyContent == false
                {
                    //scrollView.contentOffset = CGPoint(x: 0, y: 0)
                }
            }
            else
            {
                path = "sitestore/manage"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "getGutterMenu": "1"]
                if storeOption.tag == 102
                {
                    //scrollView.contentOffset = CGPoint(x: 0, y: 0)
                }
                
            }
            if storeBrowseType == 2
            {
                path = "sitestore/category"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "showCount": "1"]
                self.storesTableView.isHidden = true
                
            }
            
            if (self.pageNumber == 1)
            {
                
                if updateAfterAlert == true || searchDic.count > 0
                {
                    self.storesResponse.removeAll(keepingCapacity: false)
                    removeAlert()
                    if let responseCacheArray = self.responseCache["\(path)"]
                    {
                       // showSpinner = false
                        self.storesResponse = responseCacheArray as! [AnyObject]
                    }
                    self.storesTableView.reloadData()
                }
                else
                {
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner)
            {
                
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
              //  activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                
                if isUserInteractionEnabled == false
                {
                    self.view.isUserInteractionEnabled = false
                }
            }
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher2.endRefreshing()
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.scrollView.isUserInteractionEnabled = true
                    
                    if msg
                    {
                        
                        if self.pageNumber == 1{
                            self.storesResponse.removeAll(keepingCapacity: false)
                            self.categoryResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if self.storeBrowseType == 2
                            {
                                if let categoryResponse = response["categories"] as? NSArray
                                {
                                    self.storesTableView.isHidden = true
                                    self.categoryTableView.isHidden = false
                                    
                                    self.categoryResponse = self.categoryResponse + (categoryResponse as [AnyObject])
                                    self.categoryTableView.reloadData()
                                }
                            }
                            else
                            {
                                self.categoryTableView.isHidden = true
                                self.storesTableView.isHidden = false
                                if self.browseOrMyStores
                                {
                                    if response["response"] != nil {
                                        if let listing = response["response"] as? NSArray {
                                            self.storesResponse = self.storesResponse + (listing as [AnyObject])
                                            if (self.pageNumber == 1){
                                                self.responseCache["\(path)"] = listing
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    if response["response"] != nil {
                                        if let listing = response["response"] as? NSArray {
                                            self.storesResponse = self.storesResponse + (listing as [AnyObject])
                                            if (self.pageNumber == 1){
                                                self.responseCache["\(path)"] = listing
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                        }
                        
                        self.isPageRefresing = false
                        if NotPlay != 1 {
                            self.pausePlayeVideos()
                        }
                        if self.browseOrMyStores == true
                        {
                            if self.storesResponse.count != 0
                            {
                                self.getRequiredStores()
                            }
                        }
                        else
                        {
                            self.storeSlideShowView.isHidden = true
                            self.dynamicHeaderHeight = 0.0001
                            self.storesTableView.reloadData()
                        }
                        
                        if self.totalItems == 0
                        {
                            self.noContentView = NoContentView()
                            self.noContentView.tag = 1000
                            self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                            self.mainView.addSubview(self.noContentView)
                            self.noContentView.isHidden = false
                            self.noContentView.button.layer.borderWidth = 1
                            self.noContentView.button.layer.borderColor = buttonColor.cgColor
                            self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal) 
                            self.noContentView.button.setTitleColor(UIColor.white, for: .normal)
                            self.noContentView.button.backgroundColor = buttonColor
                            self.noContentView.button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                            self.noContentView.button.addTarget(self, action: #selector(StoresBrowseViewController.addStoreItem), for: .touchUpInside)
                            self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
                            
                        }

                        
                        if self.isUserInteractionEnabled == false{
                            self.isUserInteractionEnabled = true
                            self.view.isUserInteractionEnabled = true
                        }
                        
                    }
                    else
                    {
                        
                        // Handle Server Error
                        if succeeded["message"] != nil
                        {
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
    
    @objc func showMyStoreMenu(sender:UIButton){
        
        var storeInfo:NSDictionary
        
        storeInfo = storesResponse[sender.tag] as! NSDictionary
        editStoreID = storeInfo["store_id"] as! Int
        
        let menuOption = storeInfo["menu"] as! NSArray
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for menu in menuOption{
            
            if let menuItem = menu as? NSDictionary{
                let titleString = menuItem["name"] as! String
                
                if menuItem["name"] as! String == "addVideos"{
                    continue
                }
                
                
                if titleString.range(of: "delete") != nil{
                    
                    alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertAction.Style.destructive , handler:{ (UIAlertAction) -> Void in
                        let condition = menuItem["name"] as! String
                        
                        switch(condition){
                        case "delete":
                            
                            displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this Store?",comment: "") , otherButton: NSLocalizedString("Delete Store", comment: "")) { () -> () in
                                
                                self.performStoreMenuAction(url: menuItem["url"] as! String)
                                
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
                            
                        case "close":
                            Reload = "Not Refresh"
                            
                            self.performStoreMenuAction(url: menuItem["url"] as! String)
                            
                        case "open":
                            Reload = "Not Refresh"
                            
                            self.performStoreMenuAction(url: menuItem["url"] as! String)
                            
                        default:
                            
                            print("error")
                            
                        }
                        
                    }))
                }
            }
        }
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else if (UIDevice.current.userInterfaceIdiom == .pad){
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x:view.bounds.width/2, y: view.bounds.height/2, width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func performStoreMenuAction(url : String){
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
            
            self.view.isUserInteractionEnabled = false
            
            let dic = Dictionary<String, String>()
            
            var method:String
            
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            // Send Server Request to Explore Classified Contents with Classified_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute:  {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        updateAfterAlert = false
                        self.isUserInteractionEnabled = false
                        self.browseStores()
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
            showAlertMessage(centerPoint: view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    func showAlertMessage( centerPoint: CGPoint, msg: String, timer: Bool){
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
        // if popAfterDelay == true{
        _ = self.navigationController?.popViewController(animated: true)
        
       //  }
    }
    func goBack(){
         _ = self.navigationController?.popViewController(animated: false)
    }
    
    //Get Stores according to requirements (Liked, Featured)
    func getRequiredStores(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            var path = ""
            var parameters = [String:String]()
            
            if browseOrMyStores {
                path = "sitestore/browse"
                
                if Locationdic != nil
                {
                    let defaults = UserDefaults.standard
                    
                    if let loc = defaults.string(forKey: "Location")
                    {
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","user_id" : String(user_id), "restapilocation": loc, "show": "5"]
                        }else{
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "restapilocation": loc, "show": "5"]
                        }
                    }
                    else
                    {
                        if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","user_id" : String(user_id), "restapilocation": defaultlocation, "show": "5"]
                        }else{
                            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "restapilocation": defaultlocation, "show": "5"]
                        }
                    }
                    
                    
                }
                else
                {
                    if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)","user_id" : "\(user_id)", "show": "5"]
                    }else{
                        parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "show": "5"]
                    }
                }
                if storeOption != nil && storeOption.tag  == 102 && showOnlyMyContent == false {
                    //scrollView.contentOffset = CGPoint(x:0, y: 0)
                }
            }
            
            activityIndicatorView.startAnimating()
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.requiredStoresResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if self.browseOrMyStores{
                                if response["response"] != nil {
                                    if let listing = response["response"] as? NSArray {
                                        self.requiredStoresResponse = self.requiredStoresResponse + (listing as [AnyObject])
                                        
                                    }
                                }
                            }
                            

                        }
                        
                        self.isPageRefresing = false
                        
                        if self.browseOrMyStores == true && self.requiredStoresResponse.count > 1{
                            self.storeSlideshow.browseContent(contentItems: self.requiredStoresResponse,comingFrom : "")
                            self.storeSlideShowView.isHidden = false
                            self.dynamicHeaderHeight = 0.0001 + 190
                        }else{
                            self.storeSlideShowView.isHidden = true
                            self.dynamicHeaderHeight = 0.0001
                        }
                        
                        //Reload Listing Table
                        self.storesTableView.reloadData()
                        
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
            scrollView.isUserInteractionEnabled = true
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    
    @objc func showSubCategory( _ sender:UIButton)
    {
        var categoryInfo:NSDictionary!
        categoryInfo = categoryResponse[sender.tag] as! NSDictionary
        let presentedVC = ProductCategoriesDetailViewController()
        presentedVC.categoryType = "stores"
        presentedVC.subjectId = categoryInfo["category_id"] as! Int
        presentedVC.tittle = categoryInfo["category_name"] as! String
        navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    @objc func showCart(){
        
        let presentedVC = ManageCartViewController()
        navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the isSelected object to the new view controller.
    }
    */
    
}
