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

// VideoBrowseViewController.swift

import UIKit
//import GoogleMobileAds
import FBAudienceNetwork
import MediaPlayer
import AVKit
import AVFoundation
import NVActivityIndicatorView
import Instructions
import WebKit

var videosUpdate = true

class VideoBrowseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate, FBNativeAdDelegate, FBNativeAdsManagerDelegate, WKNavigationDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate, UIGestureRecognizerDelegate{
    
    let mainView = UIView()
    var browseVideo:UIButton!
    var myVideo:UIButton!
    var videoTableView:UITableView!
    var refresher:UIRefreshControl!
    var browseOrMyVideo = true                   // true for Browse Group & false for My Group
    var videosResponse = [AnyObject]()
    var showSpinner = true                      // not show spinner at pull to refresh
    var customSegmentControl : UISegmentedControl!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true
    var isPageRefresing = false                 // For Pagination
    var objectId:Int!
    var showOnlyMyContent:Bool!
    var user_id : String!
    var fromTab : Bool! = false
    var countListTitle : String!
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    var videoTypeCheck = ""
 //   var imageCache = [String:UIImage]()
    var url : String!
    var listingTypeId : Int!
    var contentType = ""
    var listingId : String!
    var responseCache = [String:AnyObject]()
    
    // AdMob Variable
//    var adLoader: GADAdLoader!
//    var nativeAdArray = [AnyObject]()
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
    var subject_type : String = ""
    var timerFB = Timer()
    var viewSubview = UIView()
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
      //  nativeAdArray.removeAll(keepingCapacity : false)
        updateAfterAlert = true
        globFilterValue = ""
        searchDic.removeAll(keepingCapacity: false)
        videosUpdate = true
        shared1 = VideoPlayerController()
        if fromTab == false{
            setDynamicTabValue()
        }

        removeMarqueFroMNavigaTion(controller: self)
        setNavigationImage(controller: self)
        // Navigation title and button stuff
        createNavigation()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        // Initialize Video Types
        browseVideo = createNavigationButton(CGRect(x: 0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) , title: NSLocalizedString("Browse Videos",  comment: ""), border: true, selected: true)
        browseVideo.tag = 11
        browseVideo.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
        browseVideo.addTarget(self, action: #selector(VideoBrowseViewController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(browseVideo)
        browseVideo.isHidden = false
        
        myVideo = createNavigationButton(CGRect(x: view.bounds.width/2.0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) , title: NSLocalizedString("My Videos",  comment: ""), border: true, selected: false)
        myVideo.tag = 22
        myVideo.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
        myVideo.addTarget(self, action: #selector(VideoBrowseViewController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(myVideo)
        myVideo.isHidden = false
        
        let filter = createButton(CGRect(x: PADING, y: TOPPADING + contentPADING + ButtonHeight, width: ButtonHeight - PADING , height: 0), title: fiterIcon, border: true,bgColor: false, textColor: textColorDark)
        filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)

        filter.addTarget(self, action: #selector(VideoBrowseViewController.filterSerach), for: .touchUpInside)
        mainView.addSubview(filter)
        filter.isHidden = true
        
        videoTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING +  ButtonHeight  , width: view.bounds.width, height: view.bounds.height - (TOPPADING +  ButtonHeight) - tabBarHeight), style: .grouped)
        videoTableView.register(CustomTableViewCellThree.self, forCellReuseIdentifier: "CellThree")
        videoTableView.rowHeight = 235.0
        videoTableView.dataSource = self
        videoTableView.delegate = self
        videoTableView.isOpaque = false
        videoTableView.backgroundColor = tableViewBgColor
        videoTableView.separatorColor = TVSeparatorColorClear
        if #available(iOS 11.0, *) {
            videoTableView.estimatedRowHeight = 0
            videoTableView.estimatedSectionHeaderHeight = 0
            videoTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(videoTableView)
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(VideoBrowseViewController.refresh), for: UIControl.Event.valueChanged)
        videoTableView.addSubview(refresher)
        if logoutUser == true || showOnlyMyContent == true{
            browseVideo.isHidden = true
            myVideo.isHidden = true
            filter.frame.origin.y = TOPPADING
            videoTableView.frame.origin.y = TOPPADING - 4
            videoTableView.frame.size.height = view.bounds.height - (TOPPADING - 4) - tabBarHeight
        }
  
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        videoTableView.tableFooterView = footerView
        videoTableView.tableFooterView?.isHidden = true
        
        if adsType_video != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(VideoBrowseViewController.checkforAds),
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
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 1/2", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Next ", comment: "")
            
        case 1:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(createTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 2/2", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
            
            
            
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
    
    
    
    // Navigation title and button stuff
    func createNavigation()
    {
        if showOnlyMyContent == false
        {
            self.title = NSLocalizedString("Videos", comment: "")
            if tabBarController != nil{
                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
            }
            navigationController?.navigationBar.isHidden = false
            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        else
        {
            if(countListTitle != nil)
            {
                self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
            }
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(VideoBrowseViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem

        }
    }
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showVideoContent")
        {
            if  UserDefaults.standard.object(forKey: "showVideoContent") != nil {
                
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showVideoContent")
        }
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
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
        IsRedirctToProfile()
    }
    @objc func appEnteredFromBackground() {
        
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        
    }
    @objc func appMovedToBackground() {
        self.shared1.pauseVideosFor(tableView: self.videoTableView)
        self.taskVideoPlayPause?.cancel()
    }
    @objc func videoCompletion() {
        
        shared1.currentVideoContainer()?.playOn = true
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        
    }
    func pausePlayeVideos(){
        shared1.pausePlayeVideosFor(tableView: videoTableView)
        
    }
    
    func IsRedirctToProfile()
    {

            if conditionalProfileForm == "BrowsePage"
            {
                conditionalProfileForm = ""
                if self.videoTypeCheck == "listings"{
                    let presentedVC = VideoProfileViewController()
                    presentedVC.listingTypeId = listingTypeId
                    presentedVC.videoProfileTypeCheck = "listings"
                    presentedVC.videoId = createResponse["video_id"] as! Int
                    presentedVC.videoType = createResponse["type"] as? Int
                    presentedVC.videoUrl = createResponse["video_url"] as! String
                    if sitevideoPluginEnabled_mlt == 1
                    {
                        presentedVC.listingId = createResponse["parent_id"] as! Int
                    }
                    else
                    {
                        presentedVC.listingId = createResponse["listing_id"] as! Int
                    }
                    
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                else{

                    let presentedVC = VideoProfileViewController()//GroupDetailViewController()
                    if self.videoTypeCheck == "AdvEventVideo"{
                        presentedVC.videoProfileTypeCheck = "AdvEventProfile"
                    }
                    else if self.videoTypeCheck == "sitegroupvideo"{
                        presentedVC.videoProfileTypeCheck = "sitegroupvideo"
                    }
                    else if self.videoTypeCheck == "stores"{
                        presentedVC.videoProfileTypeCheck = "stores"
                    }
                    else{
                        presentedVC.videoProfileTypeCheck = ""
                    }
                    presentedVC.videoId = createResponse["video_id"] as! Int
                    presentedVC.videoType = createResponse["type"] as? Int
                    presentedVC.videoUrl = createResponse["video_url"] as! String
                    if self.videoTypeCheck == "AdvEventVideo"{
                        presentedVC.event_id = createResponse["event_id"] as! Int
                    }
                    if self.videoTypeCheck == "sitegroupvideo"{
                        presentedVC.event_id = createResponse["group_id"] as! Int
                    }
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                
            }

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
        if videosUpdate {
            pageNumber = 1
            updateScrollFlag = false
            browseEntries()
        }
    }
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    @objc func checkforAds()
    {
        nativeAdArray.removeAll()
        if adsType_video == 1
        {
            if kFrequencyAdsInCells_video > 4 && placementID != ""
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
                        videoTableView.reloadData()
                    }
                }
            }
            
        }
        else if adsType_video == 0
        {
            if kFrequencyAdsInCells_video > 4 && adUnitID != ""
            {
                //showNativeAd()
                
            }
            
        }
        else if adsType_video == 2 {
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
            
            dic["type"] =  "\(adsType_video)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_video)"
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
                                            self.videoTableView.reloadData()
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
                adCallToActionButton.addTarget(self, action: #selector(VideoBrowseViewController.actionAfterClick(_:)), for: .touchUpInside)
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
                    
                    
                    videoclickButton.addTarget(self, action: #selector(VideoBrowseViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
                    self.fbView.addSubview(videoclickButton)
                }
                else{
                    imageButton.addTarget(self, action: #selector(VideoBrowseViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
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
                        
                        ctaButton.addTarget(self, action: #selector(VideoBrowseViewController.tappedOnAds(_:)), for: .touchUpInside)
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
        dictionary["type"] =  "\(adsType_video)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_video)"
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
            videoTableView.reloadData()
        }
        
    }

    public func nativeAdsFailedToLoadWithError(_ error: Error)
    {
        
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
//            self.videoTableView.reloadData()
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
//            self.videoTableView.reloadData()
//        }
//    }
    
    func indexChanged(_ sender: UISegmentedControl) {

        switch sender.selectedSegmentIndex {
        case 0:
            browseOrMyVideo = true
            self.browseEntries()
        case 1:
            browseOrMyVideo = false
            self.browseEntries()
        default:
            break;
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delay(0.0) {
            self.shared1.pauseVideosFor(tableView: self.videoTableView)
            self.taskVideoPlayPause?.cancel()
        }
        
        timerFB.invalidate()
        NotificationCenter.default.removeObserver(self)
        videoTableView.tableFooterView?.isHidden = true
        globFilterValue = ""
        globalCatg = ""
    }
    
   
    
    // Open Filter Search Form
    @objc func filterSerach(){

        searchDic.removeAll(keepingCapacity: false)
        videosUpdate = false
        let presentedVC = FilterSearchViewController()
        presentedVC.searchUrl = "videos/browse-search-form"
        presentedVC.serachFor = "video"
        isCreateOrEdit = true
        navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    // Handle Browse Video or My Video PreAction
    @objc func prebrowseEntries(_ sender: UIButton){
        
        if sender.tag == 22 {
            browseOrMyVideo = false
        }else if sender.tag == 11 {
            browseOrMyVideo = true
        }
        videoTableView.tableFooterView?.isHidden = true
        searchDic.removeAll(keepingCapacity: false)
        updateScrollFlag = false
        pageNumber = 1
        showSpinner = true
        // Update for Video
        browseEntries()
    }
    
    // Create Video Form
    @objc func addNewVideo(){
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            isCreateOrEdit = true
            let presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Add New Video", comment: "")
            presentedVC.contentType = "video"
            presentedVC.param = [ : ]
            if self.videoTypeCheck == "AdvEventVideo"{
                presentedVC.url = "advancedevents/video/create/\(user_id)"
            }
            else if self.videoTypeCheck == "sitegroupvideo"{
                presentedVC.url = "group/video/create/\(listingId)"
            }
            else if self.videoTypeCheck == "listings"{
                presentedVC.url = "listings/video/create/\(listingId)"
            }
            else
            {
                presentedVC.url = "videos/create"
            }
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:false, completion: nil)

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
    
    @objc func showVideo(_ sender:UIButton){
        var videoInfo:NSDictionary!
        videoInfo = videosResponse[sender.tag] as! NSDictionary
        if self.videoTypeCheck == "listings"{
            let presentedVC = VideoProfileViewController()
            presentedVC.listingTypeId = listingTypeId
            presentedVC.videoProfileTypeCheck = "listings"
            presentedVC.videoId = videoInfo["video_id"] as! Int
            if sitevideoPluginEnabled_mlt == 1
            {
                presentedVC.listingId = videoInfo["parent_id"] as! Int
            }
            else
            {
                presentedVC.listingId = videoInfo["listing_id"] as! Int
            }
            presentedVC.videoType = videoInfo["type"] as? Int
            presentedVC.videoUrl = videoInfo["video_url"] as! String
            
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        else{
           
            if(videoInfo["allow_to_view"] as! Int == 1){
                let presentedVC = VideoProfileViewController()//GroupDetailViewController()
                
                if self.videoTypeCheck == "AdvEventVideo"{
                    presentedVC.videoProfileTypeCheck = "AdvEventProfile"
                }
                else if self.videoTypeCheck == "sitegroupvideo"{
                    presentedVC.videoProfileTypeCheck = "sitegroupvideo"
                    presentedVC.event_id = videoInfo["group_id"] as! Int
                }
   
                else{
                    presentedVC.videoProfileTypeCheck = ""
                }
                presentedVC.videoId = videoInfo["video_id"] as! Int
                presentedVC.videoType = videoInfo["type"] as? Int
                if  videoInfo["type"] as! Int == 1 || videoInfo["type"] as! Int == 2 || videoInfo["type"] as! Int == 3 || videoInfo["type"] as! Int == 4 || videoInfo["type"] as! Int == 5 || videoInfo["type"] as! Int == 6
                {
                    presentedVC.videoUrl = videoInfo["video_url"] as! String
                }
                else
                {
                    presentedVC.videoUrl = videoInfo["content_url"] as! String
                }
                
                if self.videoTypeCheck == "AdvEventVideo"{
                    presentedVC.event_id = videoInfo["event_id"] as! Int
                }
                navigationController?.pushViewController(presentedVC, animated: true)
            }else{
                showToast(message: NSLocalizedString("You do not have permission to view this private page.", comment: ""), controller: self)
            }
        }
    }
    
    @objc func showVideoMenu(_ sender:UIButton)
    {
        
        var videoInfo:NSDictionary
        videoInfo = videosResponse[sender.tag] as! NSDictionary
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
                                displayAlertWithOtherButton(NSLocalizedString("Delete Video", comment: ""),message: NSLocalizedString("Are you sure you want to delete this video?", comment: "") , otherButton: NSLocalizedString("Delete Video", comment: "")) { () -> () in
                                    self.updateMyVideoMenuAction(menuItem["url"] as! String)
                                    
                                }
                                self.present(alert, animated: true, completion: nil)
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
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
                                showToast(message: unconditionalMessage, controller: self)
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
    
    // Update video
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
//            if showOnlyMyContent == true{
//                browseOrMyVideo = false
//            }
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            contentIcon.isHidden = true
            refreshButton.isHidden = true
            
            var path = ""
            var parameters = [String:String]()
            
            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                browseOrMyVideo = true
            }
            
            
            if self.videoTypeCheck == "listings" || self.videoTypeCheck == "sitegroupvideo" || self.videoTypeCheck == "stores" || self.videoTypeCheck == "sitegroup" || self.videoTypeCheck == "AdvEventVideo" || self.videoTypeCheck == "Pages"
            {
                path = url
                parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
            }
            else{
                // Set Parameters for Browse/Myvideo
                if browseOrMyVideo {
                    
                    path = "videos/browse"
                    
                    if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                        parameters = ["page":"\(pageNumber)", "limit": "\(limit)","user_id" : String(user_id)]
                    }else{
                        parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
                    }
                    browseVideo.setSelectedButton()
                    myVideo.setUnSelectedButton()
                }else{
                    path = "videos/manage"
                    parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                    browseVideo.setUnSelectedButton()
                    myVideo.setSelectedButton()
                }
            }
            
            
            if (self.pageNumber == 1){
                
                if updateAfterAlert == true {
//                    self.videosResponse.removeAll(keepingCapacity: false)
                    removeAlert()
                    if let responseCacheArray = self.responseCache["\(path)"]{
                        videosResponse = responseCacheArray as! [AnyObject]
                      //  showSpinner = false
                    }
                    
                    self.videoTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
               // spinner.center = mainView.center
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
        //        activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            // Send Server Request to Browse video Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.videoTableView.tableFooterView?.isHidden = true
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    if msg{
                        if self.pageNumber == 1{
                            self.videosResponse.removeAll(keepingCapacity: false)
                        }
                        self.isPageRefresing = false
                        if succeeded["body"] != nil{
                            if let response = succeeded["body"] as? NSDictionary{
                                
                                
                                if let group = response["response"] as? NSArray {
                                    
                                    self.videosResponse = self.videosResponse + (group as [AnyObject])
                                    
                                    if (self.pageNumber == 1){
                                        self.responseCache["\(path)"] = group
                                    }
                                }
                                
                                
                                var videotitle : String!
                                for tempMenu in self.videosResponse{
                                    if let tempDic = tempMenu as? NSDictionary{
                                        if tempDic["title"] is NSString{
                                            videotitle = tempDic["title"] as! String
                                        }else if tempDic["title"] is NSNumber{
                                            videotitle = String(describing: tempDic["title"])
                                        }

                                    }
                                    
                                }
                                
                                
                                
                                if self.videoTypeCheck == "AdvEventVideo"{
                                    
                                    if (response["canCreate"] as! Int == 1)
                                    {
                                        
                                        //                                        let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.Add, target: self, action: "addNewVideo")
                                        //                                        self.navigationItem.setRightBarButtonItems([addBlog], animated: true)
                                        
                                    }
                                
                                    if response["totalItemCount"] != nil
                                    {
                                        self.totalItems = response["totalItemCount"] as! Int
                                        self.title = "Video (" + String(self.totalItems)+"): " + videotitle
                                        
                                    }
                                    
                                    
                                }
                                if self.videoTypeCheck == "sitegroupvideo"{
                                    self.totalItems = response["totalItemCount"] as! Int
                                    if videotitle == nil
                                    {
                                        videotitle = ""
                                    }
                                    self.title = "Video (" + String(self.totalItems)+"): " + videotitle
                                }
                                if self.videoTypeCheck == "listings"{
                                    // if (response["canCreate"] as! Bool == true){
                                    //
                                    //                                    let addVideo = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.Add, target: self, action: "addNewVideo")
                                    //                                    self.navigationItem.rightBarButtonItem = addVideo
                                    
                                    // }
                                }
                                else{
                                    if self.showOnlyMyContent == false{
                                        
                                        if (response["canCreate"] as! Bool == true){

                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(VideoBrowseViewController.searchItem))
                                            let addVideo = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(VideoBrowseViewController.addNewVideo))
                                            self.navigationItem.setRightBarButtonItems([addVideo,searchItem], animated: true)
                                            searchItem.tintColor = textColorPrime
                                            addVideo.tintColor = textColorPrime
                                            
                                            self.showAppTour()
                                        }else{
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(VideoBrowseViewController.searchItem))

                                            self.navigationItem.rightBarButtonItem = searchItem
                                            searchItem.tintColor = textColorPrime
                                        }
                                    }
                                    
                                }
                                if response["totalItemCount"] != nil{
                                    self.totalItems = response["totalItemCount"] as! Int
                                    
                                }
                                
                            }
                        }
                        if NotPlay != 1 {
                            self.pausePlayeVideos()
                        }
                        //Reload Video Tabel
                        self.videoTableView.reloadData()
                        
                        if self.videosResponse.count == 0{
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(videoIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.mainView.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any Video entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.sizeToFit()
                            self.info.numberOfLines = 0
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.mainView.addSubview(self.info)
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(VideoBrowseViewController.browseEntries), for: UIControl.Event.touchUpInside)

                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.mainView.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        
                    }else{
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
        return 0.00001
    }
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if nativeAdArray.count > 0
        {
            // For showing facebook ads count
            var rowcount = Int()
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                rowcount = 2*(kFrequencyAdsInCells_video-1)
            }
            else
            {
                rowcount = (kFrequencyAdsInCells_video-1)
            }
            if videosResponse.count > rowcount
            {

                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    let b = Int(ceil(Float(videosResponse.count)/2))
                    adsCount = b/(kFrequencyAdsInCells_video-1)
                    
                    if adsCount > 1 || videosResponse.count%2 != 0
                    {
                        adsCount = adsCount/2
                    }
                    let Totalrowcount = adsCount+b
                    if b%(kFrequencyAdsInCells_video-1) == 0 && videosResponse.count % 2 != 0
                    {
                        if adsCount%2 != 0
                        {
                            
                            return Totalrowcount - 1
                        }
                    }
                    else if videosResponse.count % 2 != 0 && adsCount % 2 == 0
                    {
                        
                        return Totalrowcount - 1
                    }
                    
                    return Totalrowcount
                }
                else
                {
                    let b = videosResponse.count
                    adsCount = b/(kFrequencyAdsInCells_video-1)
                    let Totalrowcount = adsCount+b
                    if Totalrowcount % kFrequencyAdsInCells_video == 0
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
            return Int(ceil(Float(videosResponse.count)/2))
        }else{
            return videosResponse.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (kFrequencyAdsInCells_video > 4 && (((indexPath as NSIndexPath).row % kFrequencyAdsInCells_video) == (kFrequencyAdsInCells_video)-1))
        {
            if adsType_video == 2
            {
                guard (UIDevice.current.userInterfaceIdiom != .pad) else {
                     return adsCellheight + 5
                }
                return adsCellheight + 5
            }
            else if adsType_video == 0
            {
                return 265
            }
            return adsCellheight + 5
        }
        return 230
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if adsType_video == 2{
            
            var row = indexPath.row as Int
            if (kFrequencyAdsInCells_video > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_video) == (kFrequencyAdsInCells_video)-1))
            {
                //            displyedAdsCount = (row / kFrequencyAdsInCells_feeds)
                //            row = row - displyedAdsCount
                
                if let cell1 = cell as? NativeVideoCellTableViewCell
                {
                    var Adcount: Int = 0
                    Adcount = row/(kFrequencyAdsInCells_video-1)
                    
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
        if adsType_video == 2{
            if tableView.tag != 11
            {
                
                let row = indexPath.row as Int
                if  (kFrequencyAdsInCells_video > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_video) == (kFrequencyAdsInCells_video)-1))
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
        
        var row = (indexPath as NSIndexPath).row as Int
        if (kFrequencyAdsInCells_video > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_video) == (kFrequencyAdsInCells_video)-1))
        {  // or 9 == if you don't want the first cell to be an ad!
            videoTableView.register(NativeVideoCellTableViewCell.self, forCellReuseIdentifier: "Cell1")
            let cell = videoTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeVideoCellTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            var Adcount: Int = 0
            Adcount = row/(kFrequencyAdsInCells_video-1)
            
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
                if adsType_video == 2{
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
            if(isIpad())
            {
                var videosInfo2:NSDictionary!
                let adcount = row/kFrequencyAdsInCells_video
                if(videosResponse.count > ((row)*2-adcount) ){
                    videosInfo2 = videosResponse[((row)*2-adcount)] as! NSDictionary
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
                cell.contentSelection2.addTarget(self, action: #selector(VideoBrowseViewController.showVideo(_:)), for: .touchUpInside)
                cell.imgVideo2.addTarget(self, action: #selector(VideoBrowseViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                cell.imgVideo2.tag = cell.contentSelection2.tag
                // Set MenuAction
                cell.menu2.addTarget(self, action:#selector(VideoBrowseViewController.showVideoMenu(_:)) , for: .touchUpInside)
                cell.contentImage2.frame.size.height = 180
                //            cell.contentSelection2.frame.size.height = 180
                
                // Set Video Image
                if let photoId = videosInfo2["photo_id"] as? Int{
                    if photoId != 0{
                        cell.contentImage2.image = nil
                        let url = URL(string: videosInfo2["image"] as! NSString as String)

                        if  url != nil {
                            cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                    }else{
                        //                    cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: CGRectGetWidth(cell.contentImage.bounds))
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
                    let boldFont = CTFontCreateWithName( (fontName as CFString?)!, FONTSIZENormal, nil)
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
                if browseOrMyVideo {
                    cell.menu2.isHidden = true
                    cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                    cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)
                }else{
                    cell.menu2.isHidden = false
                    //                cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                    //                cell.totalMembers2.frame = CGRect(x:cell.cellView.bounds.width - 95,CGRectGetHeight(cell.contentImage2.bounds) , 95, 40)
                    
                    cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                    cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)
                }
            }
            
            return cell
            
        }
        else
        {
            if kFrequencyAdsInCells_video > 4 && nativeAdArray.count > 0
            {
                row = row - (row / kFrequencyAdsInCells_video)
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath) as! CustomTableViewCellThree
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            
            var videosInfo:NSDictionary!
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                if (kFrequencyAdsInCells_video > 4 && nativeAdArray.count > 0)
                {
                    let adcount = row/(kFrequencyAdsInCells_video-1)
                    if(videosResponse.count > ((row)*2+adcount))
                    {
                        videosInfo = videosResponse[((row)*2+adcount)] as! NSDictionary
                        cell.contentSelection.tag = ((row)*2+adcount)
                        cell.menu.tag = ((row)*2+adcount)
                        
                    }
                }
                else
                {
                    if(videosResponse.count > (row)*2)
                    {
                        videosInfo = videosResponse[(row)*2] as! NSDictionary
                        cell.contentSelection.tag = (row)*2
                        cell.menu.tag = (row)*2
                        
                    }
                }
                
                
            }
            else
            {
                videosInfo = videosResponse[row] as! NSDictionary
                cell.contentSelection.tag = row
                cell.menu.tag = row
            }
            
            //Select Video Action
            cell.contentSelection.addTarget(self, action: #selector(VideoBrowseViewController.showVideo(_:)), for: .touchUpInside)
            cell.imgVideo.addTarget(self, action: #selector(VideoBrowseViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
            cell.imgVideo.tag = cell.contentSelection.tag
            // Set MenuAction
            cell.menu.addTarget(self, action:#selector(VideoBrowseViewController.showVideoMenu(_:)) , for: .touchUpInside)
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
            if let photoId = videosInfo["photo_id"] as? Int{
                
                if photoId != 0{
                    cell.contentImage.image = nil
                    cell.contentImage.backgroundColor = placeholderColor
                    let url = URL(string: videosInfo["image"] as! NSString as String)
                    
                    if  url != nil {
                        cell.contentImage.kf.indicatorType = .activity
                        (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        })
                    }
                    
                    
                    
                }else{
                    cell.contentImage.image = nil
                    //                cell.contentImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: CGRectGetWidth(cell.contentImage.bounds))
                    cell.contentImage.image = UIImage(named: "nophoto_group_thumb_profile.png")!
                    
                }
            }

            
            // Set Video Name
            let duration = videosInfo["duration"] as? Int
            let durationString = timeFormatted(duration!) as String
            cell.videoDuration.isHidden = false
            cell.videoDuration.text = "\(durationString)"
            cell.contentName.frame = CGRect(x: (cell.contentImage.bounds.width - 50), y: 110, width: (cell.contentImage.bounds.width-100), height: 10)
            cell.contentName.font = UIFont(name: fontName, size: FONTSIZESmall)
            cell.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.contentName.sizeToFit()
            cell.contentName.frame.origin.y = (cell.contentImage.bounds.height - (cell.contentName.bounds.height+10))
            
            // Set Video Info
            
            cell.createdBy.frame = CGRect(x: contentPADING , y: cell.contentImage.bounds.height, width: cell.cellView.bounds.width - (cell.cellView.bounds.height - cell.contentImage.bounds.height), height: cell.cellView.bounds.height - cell.contentImage.bounds.height)
            var tempInfo = ""
            var value = ""
            //        if browseOrMyVideo {
            
            
            
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
            
            //        }
            //        else{
            //            if let videoTitle = videosInfo["title"] as? NSString {
            //                if videoTitle.length > 25{
            //                    value = videoTitle.substringToIndex(25-3)
            //                    value += NSLocalizedString("...",  comment: "")
            //                }else{
            //                    value = "\(videoTitle)"
            //                }
            //            }
            //        }
            tempInfo = "\(value)\n"
            tempInfo = "\(tempInfo)"
            let postedDate = videosInfo["creation_date"] as? String
            
            let date = dateDifferenceWithEventTime(postedDate!)
            var DateC = date.components(separatedBy: ", ")
            tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
            if DateC.count > 3{
                tempInfo += " at \(DateC[3])"
            }
            
            
            //        let postedOn = dateDifference(postedDate!)
            //        tempInfo += String(format: NSLocalizedString("%@", comment:""),postedOn)
            cell.createdBy.delegate = self
            cell.createdBy.textAlignment = .left
            cell.createdBy.textColor = textColorMedium
            cell.createdBy.numberOfLines = 0

            cell.createdBy.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                let boldFont = CTFontCreateWithName( (fontName as CFString?)!, FONTSIZENormal, nil)
                
                let range = (tempInfo as NSString).range(of: value)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)

                // TODO: Clean this up...
                
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
                totalView += " \(comment) \(commentIcon)"
            }
            cell.totalMembers.textColor = textColorMedium
            cell.totalMembers.text = "\(totalView)"
            cell.totalMembers.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
            
            // Set Menu
            if(isIpad()){
                
                if browseOrMyVideo {
                    cell.menu.isHidden = true
                    cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 95)
                    //            cell.totalMembers.frame = CGRect(x:(CGRectGetWidth(cell.createdBy.bounds) + cell.createdBy.frame.origin.x + 5 - 10), CGRectGetHeight(cell.contentImage.bounds) + 5 , 110, 40)
                    //
                    cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage.bounds.height, width: 95
                        , height: 40)
                    
                }else{
                    cell.menu.isHidden = false
                    //                cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 120)
                    cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 95)
                    //            cell.totalMembers.frame = CGRect(x:(CGRectGetWidth(cell.createdBy.bounds) + cell.createdBy.frame.origin.x + 5 - 10), CGRectGetHeight(cell.contentImage.bounds) + 5 , 110, 40)
                    //                cell.totalMembers.frame = CGRect(x:cell.cellView.bounds.width - 120,CGRectGetHeight(cell.contentImage.bounds) , 95, 30)
                    cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage.bounds.height, width: 95
                        , height: 40)
                    
                }
                
            }
            else{
                if browseOrMyVideo {
                    cell.menu.isHidden = true
                    cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 90)
                    //            cell.totalMembers.frame = CGRect(x:(CGRectGetWidth(cell.createdBy.bounds) + cell.createdBy.frame.origin.x + 5 - 10), CGRectGetHeight(cell.contentImage.bounds) + 5 , 110, 40)
                    //
                    cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 90,y: cell.contentImage.bounds.height, width: 90
                        , height: 40)
                    
                }else{
                    cell.menu.isHidden = false
                    cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 90)
                    //            cell.totalMembers.frame = CGRect(x:(CGRectGetWidth(cell.createdBy.bounds) + cell.createdBy.frame.origin.x + 5 - 10), CGRectGetHeight(cell.contentImage.bounds) + 5 , 110, 40)
                    //
                    cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 90,y: cell.contentImage.bounds.height, width: 90
                        , height: 40)
                    
                }
                
            }
            
            // RHS
            if(isIpad()){
                var videosInfo2:NSDictionary!
                var adcount = Int()
                if (kFrequencyAdsInCells_video > 4 && nativeAdArray.count > 0)
                {
                    adcount = row/(kFrequencyAdsInCells_video-1)
                }
                else
                {
                    adcount = 0
                }
                if(videosResponse.count > ((row)*2+1+adcount))
                {
                    
                    videosInfo2 = videosResponse[((row)*2+1+adcount)] as! NSDictionary
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
                cell.contentSelection2.addTarget(self, action: #selector(VideoBrowseViewController.showVideo(_:)), for: .touchUpInside)
                cell.imgVideo2.addTarget(self, action: #selector(VideoBrowseViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                cell.imgVideo2.tag = cell.contentSelection2.tag
                // Set MenuAction
                cell.menu2.addTarget(self, action:#selector(VideoBrowseViewController.showVideoMenu(_:)) , for: .touchUpInside)
                cell.contentImage2.frame.size.height = 180
                //            cell.contentSelection2.frame.size.height = 180
                // Set Video Image
                if let photoId = videosInfo2["photo_id"] as? Int{
                    if photoId != 0{
                        cell.contentImage2.image = nil
                        let url = URL(string: videosInfo2["image"] as! NSString as String)

                        if  url != nil {
                            cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                    }else{
                        //                    cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: CGRectGetWidth(cell.contentImage.bounds))
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
                    let boldFont = CTFontCreateWithName( (fontName as CFString?)!, FONTSIZENormal, nil)
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
                if browseOrMyVideo {
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
    
    
    // Handle Video Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
         var row = (indexPath as NSIndexPath).row as Int
        if (kFrequencyAdsInCells_video > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_video) == (kFrequencyAdsInCells_video)-1))
        {
            
            let cell = tableView.cellForRow(at: indexPath) as! NativeVideoCellTableViewCell
            cell.selectionStyle = .none
            
            cell.backgroundColor = .clear
            
            if muteVideo == true
            {
                muteVideo = false
                shared1.muteVideosFor(tableView: videoTableView)
                cell.btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                //sender.setTitle("\(unMuteIconIcon)", for: .normal)
            }
            else
            {
                muteVideo = true
                shared1.muteVideosFor(tableView: videoTableView)
                cell.btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                //sender.setTitle("\(muteVideoIcon)", for: .normal)
            }
        }
    }
    
    // MARK:  UIScrollViewDelegate
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
                if (!isPageRefresing  && limit*pageNumber < totalItems){
                    if Reachabable.isConnectedToNetwork() {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        videoTableView.tableFooterView?.isHidden = false
                        //  if searchDic.count == 0{
                        if adsType_video == 2{
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
                    videoTableView.tableFooterView?.isHidden = true
                }
            }
            
        }
        
    }
    
    @objc func searchItem(){
        let presentedVC = VideoSearchViewController()
        if self.videoTypeCheck == "AdvEventVideo"{

            presentedVC.searchPath = "advancedevents/videos/" + String(user_id)
        }
        else{
            presentedVC.searchPath = "videos/browse"
        }
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
        let url : String = "videos/search-form"
        loadFilter(url)
    }
    
    
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Video Icon Action
    @objc func btnVideoIconClicked(_ sender: UIButton)
    {
        var videoInfo:NSDictionary!
        videoInfo = videosResponse[sender.tag] as! NSDictionary
        
        let attachment_video_type = videoInfo["type"] as? Int ?? 0
        var attachment_video_url = videoInfo["video_url"] as? String ?? ""
        let attachment_video_code = videoInfo["code"] as? String ?? ""

   
        if self.videoTypeCheck == "listings"{
            
            implemnetPlayer(videoType: attachment_video_type, videoURL: attachment_video_url, videoCode: attachment_video_code, sender : sender)
        }
        else{
            if(videoInfo["allow_to_view"] as! Int == 1){
                if  videoInfo["type"] as! Int == 1 || videoInfo["type"] as! Int == 2 || videoInfo["type"] as! Int == 3 || videoInfo["type"] as! Int == 4 || videoInfo["type"] as! Int == 5 || videoInfo["type"] as! Int == 6
                {
                    attachment_video_url = videoInfo["video_url"] as! String
                }
                else
                {
                    attachment_video_url = videoInfo["content_url"] as! String
                }
                implemnetPlayer(videoType: attachment_video_type, videoURL: attachment_video_url, videoCode: attachment_video_code, sender : sender)
                
            }else{
                showToast(message: NSLocalizedString("You do not have permission to view this private page.", comment: ""), controller: self)
            }
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
            //            videoWebView.mediaPlaybackRequiresUserAction = false
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
                    //if videoUrl != nil {
                    videoWebView.loadHTMLString(videoURL, baseURL: nil)
                    // }
                }
            }
            
            
//            let videoWebView = UIWebView()
//            videoWebView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height )
//            videoWebView.center = viewSubview.convert(viewSubview.center, from:viewSubview.superview)
//            videoWebView.isOpaque = false
//            videoWebView.backgroundColor = UIColor.black
//            videoWebView.scrollView.bounces = false
//            videoWebView.navigationDelegate = self
//            videoWebView.allowsInlineMediaPlayback = true
//            videoWebView.mediaPlaybackRequiresUserAction = false
//            let jeremyGif = UIImage.gifWithName("progress bar")
//            // Use the UIImage in your UIImageView
//            let imageView = UIImageView(image: jeremyGif)
//            imageView.tag = 2002134
//            imageView.frame = CGRect(x: view.bounds.width/2 - 60,y: self.view.bounds.height/2 ,width: 120, height: 7)
//
//            var url = ""
//            if videoURL.length != 0
//            {
//                let videoUrl1 : String = videoURL
//                let find = videoUrl1.contains("http")
//                if videoType == 1 || videoType == 2 || videoType == 4 || videoType == 5 && find == false{
//
//                    url = "https://" + videoURL
//                }
//                else
//                {
//                    url = videoURL
//                }
//            }
//
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
//
//              videoWebView.loadHTMLString(videoURL, baseURL: nil)
//
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
