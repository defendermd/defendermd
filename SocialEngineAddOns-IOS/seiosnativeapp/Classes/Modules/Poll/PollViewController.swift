//
//  PollViewController.swift
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
var pollUpdate: Bool!                           // Flag to refresh poll

class PollViewController: UIViewController , UITableViewDataSource, UITableViewDelegate ,FBNativeAdDelegate,FBNativeAdsManagerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate, UIGestureRecognizerDelegate {
    
    var editPollId:String!                   // Edit pollID
    let mainView = UIView()
    var browseOrMypoll = true                   // true for Browse poll & false for My poll
    var showSpinner = true                      // not show spinner at pull to refresh
    var pollResponse = [AnyObject]()            // For response come from Server
    var isPageRefresing = false                 // For Pagination
    var pollTableView:UITableView!              // TAbleView to show the poll Contents
    var browsepoll:UIButton!                    // poll Types
    var mypoll:UIButton!
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 70              // Dynamic Height fort for Cell
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent:Bool!
    var dict = Dictionary<String, String>()
    var noContentView : NoContentView!
    var user_id : String!
    var fromTab : Bool! = false
    var countListTitle : String!
  //  var imageCache = [String:UIImage]()
    var titleLimit : String!
    
    // AdMob Variable
//    var adLoader: GADAdLoader!
    var nativeAdArray = [AnyObject]()
    var loadrequestcount = 0
    var isnativeAd:Bool = true
    
    // Native FacebookAd Variable
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
    var adsReportView : AdsReportViewController!
    var parametersNeedToAdd = Dictionary<String, String>()
    var blackScreenForAdd : UIView!
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
  
        removeMarqueFroMNavigaTion(controller: self)
        if fromTab == false{
            setDynamicTabValue()
        }


        super.viewDidLoad()
        shared1 = VideoPlayerController()
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        setNavigationImage(controller: self)
        
        // Do any additional setup after loading the view.
        pollUpdate = true
        globFilterValue = ""
        searchDic.removeAll(keepingCapacity: false)
        //        view.backgroundColor = bgColor
        //        navigationController?.navigationBar.isHidden = false
        openMenu = false
        updateAfterAlert = true
        let subViews = mainView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(PollViewController.handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        if showOnlyMyContent == false {
            self.title = NSLocalizedString("Polls", comment: "")
            if tabBarController != nil{
                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
            }

            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        else{
            
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(PollViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem

            
        }
        
        browsepoll = createNavigationButton(CGRect(x: 0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) ,  title: NSLocalizedString("Browse Polls",  comment: "") , border: true, selected: true)
        browsepoll.tag = 11
        browsepoll.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
        browsepoll.addTarget(self, action: #selector(PollViewController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(browsepoll)
        
        // Initialise my poll
        mypoll = createNavigationButton(CGRect(x: view.bounds.width/2.0, y: TOPPADING ,width: view.bounds.width/2.0 , height: ButtonHeight) ,  title: NSLocalizedString("My Polls",  comment: "") , border: true, selected: false)
        mypoll.tag = 22
        mypoll.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
        mypoll.addTarget(self, action: #selector(PollViewController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(mypoll)
        
        
        
        // Create Filter Search Link
        let filter = createButton(CGRect(x: PADING, y: TOPPADING + contentPADING + ButtonHeight, width: ButtonHeight - PADING , height: 0), title: fiterIcon, border: true,bgColor: false, textColor: textColorDark)
        filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        filter.addTarget(self, action: #selector(PollViewController.filterSerach), for: .touchUpInside)
        mainView.addSubview(filter)
        filter.isHidden = true
        
        
        // Initialize poll Table
        pollTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight , width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight), style: .grouped)
        pollTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        pollTableView.dataSource = self
        pollTableView.delegate = self
        pollTableView.backgroundColor = bgColor
        pollTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
           // pollTableView.contentInsetAdjustmentBehavior = .never
            pollTableView.estimatedRowHeight = 0
            pollTableView.estimatedSectionHeaderHeight = 0
            pollTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(pollTableView)
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        // refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(PollViewController.refresh), for: UIControl.Event.valueChanged)
        pollTableView.addSubview(refresher)
        
        // for logout user
        if logoutUser == true || showOnlyMyContent == true{
            browsepoll.isHidden = true
            mypoll.isHidden = true
            filter.isHidden = true
            filter.frame.origin.y = TOPPADING
            pollTableView.frame.origin.y = TOPPADING
            pollTableView.frame.size.height = view.bounds.height - (TOPPADING) - tabBarHeight
            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.plain , target:self , action: #selector(PollViewController.cancleSearch))
            self.navigationItem.rightBarButtonItem = addCancel
        }
  
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        pollTableView.tableFooterView = footerView
        pollTableView.tableFooterView?.isHidden = true
        
        if adsType_poll != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(PollViewController.checkforAds),
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
    
    
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showPollContent")
        {
            if  UserDefaults.standard.object(forKey: "showPollContent") != nil {
                
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showPollContent")
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
        self.shared1.pauseVideosFor(tableView: self.pollTableView)
        self.taskVideoPlayPause?.cancel()
    }
    @objc func videoCompletion() {
        
        shared1.currentVideoContainer()?.playOn = true
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        
    }
    func pausePlayeVideos(){
        shared1.pausePlayeVideosFor(tableView: pollTableView)
        
    }
    func IsRedirctToProfile()
    {
        if conditionalProfileForm == "BrowsePage"
        {
            conditionalProfileForm = ""
            let presentedVC = PollProfileViewController()
            presentedVC.pollId = createResponse["poll_id"] as! Int
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    // Check for poll Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        //        pollTableView.reloadData()
        if (pollUpdate == true){
             pollUpdate = false
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            browseEntries()
        }
        if fromActivityFeed == true{
            fromActivityFeed = false
            let presentedVC  = ContentFeedViewController()
            presentedVC.subjectId = "\(objectId)"
            presentedVC.subjectType = "poll"
            navigationController?.pushViewController(presentedVC, animated: true)
            //            let presentedVC  = PollProfileViewController()
            //            presentedVC.pollId = objectId
            //            presentedVC.fromActivityFeed = false
            // presentedVC.pollName = NSLocalizedString("Loading...", comment: "")
            //            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    @objc func checkforAds()
    {
        nativeAdArray.removeAll()
        if adsType_poll == 1
        {
            if kFrequencyAdsInCells_poll > 4 && placementID != ""
            {
                FacebookAds.showFacebookAd(viewController: self)
                
            }
            
        }
        else if adsType_poll == 0
        {
            if kFrequencyAdsInCells_poll > 4 && adUnitID != ""
            {
               // showNativeAd()
            }        }
        else if adsType_poll == 2 {
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
            
            dic["type"] =  "\(adsType_poll)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_poll)"
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
                                            self.pollTableView.reloadData()
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
                adCallToActionButton.addTarget(self, action: #selector(PollViewController.actionAfterClick(_:)), for: .touchUpInside)
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
                    
                    
                    videoclickButton.addTarget(self, action: #selector(PollViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
                    self.fbView.addSubview(videoclickButton)
                    
                    
                }
                else{
                    imageButton.addTarget(self, action: #selector(PollViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
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
                        
                        ctaButton.addTarget(self, action: #selector(PollViewController.tappedOnAds(_:)), for: .touchUpInside)
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
        dictionary["type"] =  "\(adsType_poll)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_poll)"
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
            pollTableView.reloadData()
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
//            self.pollTableView.reloadData()
//        }
//    }
//
//    func adLoader(_ adLoader: GADAdLoader,
//                  didReceive nativeContentAd: GADNativeContentAd) {
//
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
//            self.pollTableView.reloadData()
//        }
//    }

    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            openMenu = false
            openMenuSlideOnView(mainView)
            mainView.removeGestureRecognizer(tapGesture)
        }
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }

    
    //MARK : - Cancle Search Result for Logout User
    @objc func cancleSearch(){
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = ""
        pageNumber = 1
        showSpinner = true
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        browseEntries()
    }
    
    //MARK : - Open Filter Search Form
    @objc func filterSerach(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            searchDic.removeAll(keepingCapacity: false)
            pollUpdate = false
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "polls/search-form"
            presentedVC.serachFor = "poll"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    //MARK : - Create poll Form
    @objc func addNewPoll(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            isCreateOrEdit = true
            let presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Create Poll", comment: "")
            presentedVC.contentType = "poll"
            presentedVC.param = [ : ]
            presentedVC.url = "polls/create"
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:true, completion: nil)

        }
    }
    
    // MARK: - Handle Browse poll or My poll PreAction
    @objc func prebrowseEntries(_ sender: UIButton){
        // true for Browse poll & false for My poll
        for ob in view.subviews {
            if ob.tag == 1000 {
                ob.removeFromSuperview()
            }
        }
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        if sender.tag == 22 {
            browseOrMypoll = false
        }else if sender.tag == 11 {
            browseOrMypoll = true
        }
        self.pollResponse.removeAll(keepingCapacity: false)
        searchDic.removeAll(keepingCapacity: false)
        updateScrollFlag = false
        pageNumber = 1
        pollTableView.tableFooterView?.isHidden = true
        showSpinner = true
        browseEntries()
    }
    
    //MARK: - Pull to Request Action
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
    
    //MARK: - Generate Custom Alert Messages
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
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    
    // MARK: - Server Connection For poll Updation
    
    // MARK: - For Delete poll
    func deletePollMenuAction(_ url : String){
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
            userInteractionOff = false
            // Send Server Request to Explore pollContents with Poll_ID
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = false
                    activityIndicatorView.stopAnimating()
                    if msg{
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
    
    // MARK: - For Close and Open Poll
    func updatepollMenuAction(_ parameter: NSDictionary , url : String){
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
            // Send Server Request to Explore poll Contents with poll_ID
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
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
    
    //MARK : - Update poll
    @objc func browseEntries(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
//            if showOnlyMyContent == true{
//                browseOrMypoll = false
//            }
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            if (self.pageNumber == 1){
                
                if updateAfterAlert == true  {
                    self.pollResponse.removeAll(keepingCapacity: false)
                    removeAlert()
                    self.pollTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            if (showSpinner){
             //   spinner.center = mainView.center
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
               // activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                browseOrMypoll = true
            }
            
            // Set Parameters for Browse/Mypoll
            //            self.title = NSLocalizedString("Polls",  comment: "")
            if browseOrMypoll {
                path = "polls"
                if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                    parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "user_id" : String(user_id)]
                }else{
                    parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                }
                browsepoll.setSelectedButton()
                mypoll.setUnSelectedButton()
            }else{
                path = "polls/manage"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                mypoll.setSelectedButton()
                browsepoll.setUnSelectedButton()
            }
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            userInteractionOff = false
            // Send Server Request to Browse poll Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.pollTableView.tableFooterView?.isHidden = true
                    if msg{
                        if self.pageNumber == 1{
                            self.pollResponse.removeAll(keepingCapacity: false)
                        }
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let poll = response["response"] as? NSArray {
                                    self.pollResponse = self.pollResponse + (poll as [AnyObject])
                                }
                            }
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            if self.showOnlyMyContent == false {
                                if (response["canCreate"] as! Bool == true){
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(PollViewController.searchItem))
                                    let addGroup = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(PollViewController.addNewPoll))
                                    
                                    self.navigationItem.setRightBarButtonItems([addGroup,searchItem], animated: true)
                                    searchItem.tintColor = textColorPrime
                                    addGroup.tintColor = textColorPrime
                                    self.showAppTour()
                                }else{
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(PollViewController.searchItem))
                                    self.navigationItem.rightBarButtonItem = searchItem
                                    searchItem.tintColor = textColorPrime
                                    
                                }
                            }
                        }
                        self.isPageRefresing = false
                        //Reload poll Tabel
                        if NotPlay != 1 {
                            self.pausePlayeVideos()
                        }
                        self.pollTableView.reloadData()
                        if self.pollResponse.count == 0{
                            self.noContentView = NoContentView()
                            self.noContentView.tag = 1000
                            self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                            self.mainView.addSubview(self.noContentView)
                            self.noContentView.isHidden = false
                            self.noContentView.button.layer.borderWidth = 1
                            self.noContentView.button.layer.borderColor = buttonColor.cgColor
                            self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal) 
                            self.noContentView.button.addTarget(self, action: #selector(PollViewController.addNewPoll), for: .touchUpInside)
                            self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")
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
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set poll Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
        }else{
            return 0.00001
        }
    }
    
    // Set poll Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    // Set Height For Table Rows
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (kFrequencyAdsInCells_poll > 4 && nativeAdArray.count > 0 && (((indexPath as NSIndexPath).row % kFrequencyAdsInCells_poll) == (kFrequencyAdsInCells_poll)-1))
        {
            if adsType_poll == 2
            {
                guard (UIDevice.current.userInterfaceIdiom != .pad) else {
                    return adsCellheight + 5
                }
                
                return adsCellheight + 5

            }
            else if adsType_poll == 0
            {
                return 75
            }
            return adsCellheight + 5
            
        }
        return dynamicHeight

    }
    
    // Set poll Table Number of Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if nativeAdArray.count > 0
        {
            // For showing facebook ads count
            var rowcount = Int()
            rowcount = (kFrequencyAdsInCells_poll-1)
            if pollResponse.count > rowcount
            {
                let a = pollResponse.count/(kFrequencyAdsInCells_poll-1)
                let b = pollResponse.count
                let Totalrowcount = a+b
                if Totalrowcount % kFrequencyAdsInCells_poll == 0
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
                //print("total rows with  \(pollResponse.count)")
                return pollResponse.count
            }
            
        }
        return pollResponse.count
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if adsType_poll == 2{
            
            var row = indexPath.row as Int
            if (kFrequencyAdsInCells_poll > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_poll) == (kFrequencyAdsInCells_poll)-1))
            {
                //            displyedAdsCount = (row / kFrequencyAdsInCells_feeds)
                //            row = row - displyedAdsCount
                
                if let cell1 = cell as? NativeAdinstallFeedCell
                {
                    var Adcount: Int = 0
                    Adcount = row/(kFrequencyAdsInCells_poll-1)
                    
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
        if adsType_poll == 2{
            if tableView.tag != 11
            {
                
                let row = indexPath.row as Int
                if  (kFrequencyAdsInCells_poll > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_poll) == (kFrequencyAdsInCells_poll)-1))
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
        
        if (kFrequencyAdsInCells_poll > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_poll) == (kFrequencyAdsInCells_poll)-1))
        {  // or 9 == if you don't want the first cell to be an ad!
            pollTableView.register(NativeAdinstallFeedCell.self, forCellReuseIdentifier: "Cell1")
            let cell1 = pollTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeAdinstallFeedCell
            cell1.selectionStyle = UITableViewCell.SelectionStyle.none
            
            var Adcount: Int = 0
            Adcount = row/(kFrequencyAdsInCells_poll-1)
            
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
                for obj in cell1.cellView.subviews
                {
                    if obj.tag == 1001001 //Condition if that view belongs to any specific class
                    {
                        
                        obj.removeFromSuperview()
                        
                    }
                }
                if adsType_poll == 2{
                    let activityFeed = communityAdsValues[Adcount] as! NSMutableDictionary
                    cell1.Adimageview.isHidden = false
                    if activityFeed["cmd_ad_format"] as! String == "video"{
                        
                        print("com ads \(communityAdsValues[Adcount])")
                        //   let activityFeed = communityAdsValues[Adcount] as! NSMutableDictionary
                        var strUrl1 = ""
                        if activityFeed["videoUrl"] != nil {
                            strUrl1 = activityFeed["videoUrl"] as! String
                            
                            if muteVideo == true
                            {
                                cell1.btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                            }
                            else
                            {
                                cell1.btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                            }
                            
                            let url1 = NSURL(string: strUrl1)
                            
                            getThumbnailImageFromVideoUrl(url: url1 as! URL) { (thumbImage) in
                                cell1.Adimageview.image = thumbImage
                            }
                            
                            cell1.Adimageview.isHidden = false
                        }
                        else{
                            cell1.Adimageview.isHidden = true
                        }
                        
                        
                    }
                }
                
                
                let view = nativeAdArray[Adcount]
                cell1.cellView.addSubview(view as! UIView)
                
                cell1.cellView.frame.size.height = view.frame.size.height
                adsCellheight = cell1.cellView.frame.size.height + 5
            }
            return cell1
            
        }
        else
        {
            
            if kFrequencyAdsInCells_poll > 4 && nativeAdArray.count > 0
            {
                row = row - (row / kFrequencyAdsInCells_poll)
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            cell.tag = row
            var pollInfo:NSDictionary
            pollInfo = pollResponse[row] as! NSDictionary
            cell.imgUser.frame = CGRect(x: 5, y: 5, width: 60, height: 60)
            cell.imgUser.contentMode = .scaleAspectFill
            // Set poll Title
            cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10,width: (UIScreen.main.bounds.width - 75) , height: 100)
            
            if (pollInfo["title"] as? String) != nil
            {
              titleLimit = pollInfo["title"] as? String
//                if titleLimit.length > 25
//                {
//                    titleLimit = (titleLimit as NSString).substring(to: 25-3)
//                }
            }
            cell.labTitle.font = UIFont(name: fontName, size:FONTSIZENormal)
            cell.labTitle.text = titleLimit
             cell.labTitle.numberOfLines = 0
            cell.labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
           
            cell.labTitle.sizeToFit()
            if let ownerName = pollInfo["owner_title"] as? String {
                if let postedDate = pollInfo["creation_date"] as? String{
                    let date = dateDifferenceWithEventTime(postedDate)
                    var DateC = date.components(separatedBy: ", ")
                    var tempInfo = ""
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
                    cell.labMessage.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5,width: (UIScreen.main.bounds.width - 75) , height: 100)
                    cell.labMessage.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
                    // cell.labMessage.textColor = textColorDark
                    var labMsg = ""
                    labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), ownerName, tempInfo)
                    labMsg += "\n"
                    labMsg += "\n"
                    _ = " "
                    if let votes = pollInfo["vote_count"] as? Int{
                        labMsg += String(format: NSLocalizedString("\(votes) \(barIcon)", comment: ""), votes)
                    }
                    if let views = pollInfo["view_count"] as? Int{
                        labMsg += String(format: NSLocalizedString("  \(views) \(viewIcon)", comment: ""), views)
                    }
                    cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let boldFont = CTFontCreateWithName( (fontName as CFString?)!, FONTSIZESmall, nil)
                        let range = (labMsg as NSString).range(of: ownerName)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                        // TODO: Clean this up..
                        return mutableAttributedString
                    })
                }
            }
            cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labMessage.sizeToFit()
            if(pollInfo["closed"] as! Int == 1){
                cell.imageview.isHidden = false
                cell.imageview.text = "\(closedIcon)"
            }
            else{
                cell.imageview.isHidden = true
            }
            
            // Set poll Owner Image
            
            if let url = URL(string: pollInfo["owner_image"] as! String){
                cell.imgUser.kf.indicatorType = .activity
                 (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
            }
            if browseOrMypoll {
                cell.accessoryView = nil
            }else{
                let optionMenu = createButton(CGRect(x: view.bounds.width - 60, y: 0, width: 40, height: cell.bounds.height),title: optionIcon, border: false, bgColor: false, textColor: textColorDark)
                optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:30.0)
                optionMenu.addTarget(self, action: #selector(PollViewController.showMenu(_:)), for: .touchUpInside)
                optionMenu.tag = row
                cell.accessoryView = optionMenu
            }
            dynamicHeight = cell.labMessage.frame.origin.y + cell.labMessage.bounds.height + 5
            if dynamicHeight < (cell.imgUser.bounds.height + 10){
                dynamicHeight = (cell.imgUser.bounds.height + 10)
            }
            return cell
        }
    }
    
    // MARK : - Show MyPoll Menu
    @objc func showMenu(_ sender:UIButton){
        var pollInfo:NSDictionary
        pollInfo = pollResponse[sender.tag] as! NSDictionary
        if (pollInfo["menu"] != nil){
            let menuOption = pollInfo["menu"] as! NSArray
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in menuOption{
                if let menuItem = menu as? NSDictionary{
                    let titleString = menuItem["name"] as! String
                    if titleString.range(of: "delete_poll") != nil{
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertAction.Style.destructive , handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            switch(condition){
                            case "delete_poll":
                                let url = menuItem["url"] as! String
                                displayAlertWithOtherButton(NSLocalizedString("Delete Poll", comment: ""),message: NSLocalizedString("Are you sure that you want to delete this Poll? This action cannot be undone.",comment: "") , otherButton: NSLocalizedString("Delete Poll", comment: "")) { () -> () in
                                    self.deletePollMenuAction(url)
                                }
                                self.present(alert, animated: true, completion: nil)
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                        }))
                    } else{
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            switch(condition){
                            case "edit_privacy":
                                conditionalForm = "poll"
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit Poll Privacy", comment: "")
                                presentedVC.contentType = "poll"
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                                
                            case "close_poll", "open_poll":
                                self.updatepollMenuAction(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String)
                            default:
                                fatalError("init(coder:) has not been implemented")
                                //print("Error")
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
                popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2 , width: 1, height: 1)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
    }
    
    // Handle poll Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
            tableView.deselectRow(at: indexPath, animated: true)
            var row = (indexPath as NSIndexPath).row as Int
            if (kFrequencyAdsInCells_poll > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_poll) == (kFrequencyAdsInCells_poll)-1))
            {
                
                let cell = tableView.cellForRow(at: indexPath) as! NativeAdinstallFeedCell
                cell.selectionStyle = .none
                
                cell.backgroundColor = .clear
                
                if muteVideo == true
                {
                    muteVideo = false
                    shared1.muteVideosFor(tableView: pollTableView)
                    cell.btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                    //sender.setTitle("\(unMuteIconIcon)", for: .normal)
                }
                else
                {
                    muteVideo = true
                    shared1.muteVideosFor(tableView: pollTableView)
                    cell.btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                    //sender.setTitle("\(muteVideoIcon)", for: .normal)
                }
                print(row)
            }
            
            else{
        var pollInfo:NSDictionary
        var index = Int()
        if kFrequencyAdsInCells_poll > 4 && nativeAdArray.count > 0
        {
            let row = (indexPath as NSIndexPath).row/kFrequencyAdsInCells_poll
            index = (indexPath as NSIndexPath).row-row
        }
        else
        {
            index = (indexPath as NSIndexPath).row
        }
        
        pollInfo = pollResponse[index] as! NSDictionary
        if(pollInfo["allow_to_view"] as! Int == 1)
        {
            let presentedVC = PollProfileViewController()
            presentedVC.pollId = pollInfo["poll_id"] as! Int
            
            self.navigationController?.pushViewController(presentedVC, animated: false)
            
        }
        else
        {
            showToast(message: "You do not have permission to view this private page.", controller: self)
        }
        }
    }
    
    // MARK: - Poll Search
    @objc func searchItem(){
        let presentedVC = PollSearchViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        let url : String = "polls/search-form"
        loadFilter(url)
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
                        pollTableView.tableFooterView?.isHidden = false
                      //  if searchDic.count == 0{
                            if adsType_poll == 2{
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
                    pollTableView.tableFooterView?.isHidden = true
                }
            }
            
        }
        
    }
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delay(0.0) {
            self.shared1.pauseVideosFor(tableView: self.pollTableView)
            self.taskVideoPlayPause?.cancel()
        }
        
        timerFB.invalidate()
        NotificationCenter.default.removeObserver(self)
        pollTableView.tableFooterView?.isHidden = true
        globFilterValue = ""
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
