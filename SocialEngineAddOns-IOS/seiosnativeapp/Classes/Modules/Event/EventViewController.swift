//
//  EventViewController.swift
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
var eventUpdate = true

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate, FBNativeAdDelegate, FBNativeAdsManagerDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate, UIGestureRecognizerDelegate{
    
    
    let mainView = UIView()
    var showSpinner = true                      // not show spinner at pull to refresh
    var eventResponse = [AnyObject]()           // To Show Event Response in Table View
    var eventTableView:UITableView!
    var refresher:UIRefreshControl!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true
    var isPageRefresing = false                 // For Pagination
    var eventBrowseType:Int!
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent:Bool!
    var fromTab : Bool! = false
    var user_id : String!
    var eventOption:UIButton!
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    var dateView : UIView!
    var titleView : UIView!
    var countListTitle : String!
//    var imageCache = [String:UIImage]()
    var responseCache = [String:AnyObject]()
    
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
    override func viewDidLoad()
    {
        super.viewDidLoad()
        shared1 = VideoPlayerController()
        removeMarqueFroMNavigaTion(controller: self)
        
        if fromTab == false{
            setDynamicTabValue()
        }


        // Do any additional setup after loading the view.
        if showOnlyMyContent == false {
            self.title = NSLocalizedString("Events", comment: "")
            if tabBarController != nil{
                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
            }

            self.navigationItem.setHidesBackButton(true, animated: false)
        }
        else{
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(EventViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem

            
        }
        
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        globFilterValue = ""
        category_filterId = nil
        openMenu = false
        updateAfterAlert = true
        eventUpdate = true
        eventBrowseType = 0
        
        let subViews = mainView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        
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
        
        leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(EventViewController.handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        if showOnlyMyContent == false {
            // Set event options
            var eventMenu = ["Upcoming","Past","My Events"]
            var origin_x:CGFloat = 0.0
            let menuWidth = CGFloat((view.bounds.width)/3)
            for i in 100 ..< 103 {
                
                if i == 100{
                    eventOption = createNavigationButton(CGRect(x: origin_x, y: TOPPADING , width: menuWidth, height: ButtonHeight) , title: NSLocalizedString("\(eventMenu[(i-100)])", comment: "") , border: true, selected: true)
                }else{
                    eventOption = createNavigationButton(CGRect(x: origin_x, y: TOPPADING , width: menuWidth, height: ButtonHeight) , title: NSLocalizedString("\(eventMenu[(i-100)])", comment: "") , border: true, selected: false)
                }
                eventOption.tag = i
                eventOption.layer.borderColor = navColor.cgColor
                eventOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
                eventOption.addTarget(self, action: #selector(EventViewController.eventSelectOptions(_:)), for: .touchUpInside)
                mainView.addSubview(eventOption)
                origin_x += menuWidth
            }
        }
        
        let filter = createButton(CGRect(x: PADING, y: TOPPADING + contentPADING + ButtonHeight, width: ButtonHeight - PADING , height: 0), title: fiterIcon, border: true,bgColor: false, textColor: textColorDark)
        filter.addTarget(self, action: #selector(EventViewController.filterSerach), for: .touchUpInside)

        filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        mainView.addSubview(filter)
        filter.isHidden = true

        
        
        // Set tableview to show events
        
        if tabBarHeight > 0{
            eventTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight ), style: .grouped)
        }else{
            eventTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING + ButtonHeight, width: view.bounds.width, height: view.bounds.height-(TOPPADING + ButtonHeight) - tabBarHeight ), style: .grouped)
        }
        
        eventTableView.register(EventViewTableViewCell.self, forCellReuseIdentifier: "CellThree")
        eventTableView.rowHeight = 253
        eventTableView.dataSource = self
        eventTableView.delegate = self
        eventTableView.isOpaque = false
        // eventTableView.bounces = false
        eventTableView.backgroundColor = tableViewBgColor
        eventTableView.separatorColor = TVSeparatorColorClear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            eventTableView.estimatedSectionHeaderHeight = 0
        }
        mainView.addSubview(eventTableView)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        eventTableView.tableFooterView = footerView
        eventTableView.tableFooterView?.isHidden = true
        
        // Set pull to referseh for eventtableview
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(EventViewController.refresh), for: UIControl.Event.valueChanged)
        eventTableView.addSubview(refresher)

        
        if logoutUser == true || showOnlyMyContent == true{
            filter.frame.origin.y = TOPPADING
            eventTableView.frame.origin.y = TOPPADING
            eventTableView.frame.size.height = view.bounds.height - (TOPPADING)  - tabBarHeight // (CGRectGetHeight(filter.bounds) + 2 * contentPADING + filter.frame.origin.y)
            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.plain , target:self , action: Selector(("cancleSearch")))
            self.navigationItem.rightBarButtonItem = addCancel
        }
        if adsType_event != 1
        {
            checkforAds()
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(EventViewController.checkforAds),
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
        if let name = defaults.object(forKey: "showEventContent")
        {
            if  UserDefaults.standard.object(forKey: "showEventContent") != nil {
                
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showEventContent")
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
        self.shared1.pauseVideosFor(tableView: self.eventTableView)
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
    func IsRedirctToProfile()
    {
        if conditionalProfileForm == "BrowsePage"
        {
            conditionalProfileForm = ""
            let presentedVC = ContentFeedViewController()
            presentedVC.subjectId = "\(createResponse["event_id"]!)"
            presentedVC.subjectType = "event"
            self.navigationController?.pushViewController(presentedVC, animated: true)
            
        }
    }
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        //  if eventResponse.count != 0{
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
        //   }
    }
    
    @objc func checkforAds()
    {
        nativeAdArray.removeAll()
        if adsType_event == 1
        {
            if kFrequencyAdsInCells_event > 4 && placementID != ""
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
                        eventTableView.reloadData()
                    }
                }
            }
            
        }
        else if adsType_event == 0
        {
            if kFrequencyAdsInCells_event > 4 && adUnitID != ""
            {
                //showNativeAd()
            }
        }
        else if adsType_event == 2 {
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
            
            dic["type"] =  "\(adsType_event)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_event)"
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
                                            self.eventTableView.reloadData()
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
                adCallToActionButton.addTarget(self, action: #selector(EventViewController.actionAfterClick(_:)), for: .touchUpInside)
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
                    
                    
                    videoclickButton.addTarget(self, action: #selector(EventViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
                    self.fbView.addSubview(videoclickButton)
                }
                else{
                    imageButton.addTarget(self, action: #selector(EventViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
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
                        
                        ctaButton.addTarget(self, action: #selector(EventViewController.tappedOnAds(_:)), for: .touchUpInside)
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
        dictionary["type"] =  "\(adsType_event)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_event)"
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
            eventTableView.reloadData()
        }
        
    }

    public func nativeAdsFailedToLoadWithError(_ error: Error)
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
//        if loadrequestcount <= 10
//        {
//            self.loadrequestcount = self.loadrequestcount+1
//            self.adLoader.delegate = nil
//            self.showNativeAd()
//            self.eventTableView.reloadData()
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
//            self.eventTableView.reloadData()
//        }
//    }

    @objc func eventSelectOptions(_ sender: UIButton){
        eventBrowseType = sender.tag - 100
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        for ob in mainView.subviews{
            if ob .isKind(of: UIButton.self){
                if ob.tag >= 100 && ob.tag <= 102{
                    if ob.tag == sender.tag{
                        (ob as! UIButton).setSelectedButton()
                    }else{
                        (ob as! UIButton).setUnSelectedButton()
                    }
                }
                
            }
        }
        self.eventResponse.removeAll(keepingCapacity: false)
        searchDic.removeAll(keepingCapacity: false)
        pageNumber = 1
        showSpinner = true
        browseEntries()
        // sender.backgroundColor = buttonSelectColor
        
    }
    
    @objc func filterSerach(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            searchDic.removeAll(keepingCapacity: false)
            eventUpdate = false
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "events/browse-search-form"
            presentedVC.serachFor = "event"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delay(0.0) {
            self.shared1.pauseVideosFor(tableView: self.eventTableView)
            self.taskVideoPlayPause?.cancel()
        }
        
        timerFB.invalidate()
        NotificationCenter.default.removeObserver(self)
        eventTableView.tableFooterView?.isHidden = true
        mainView.removeGestureRecognizer(tapGesture)
        fromTab = false
        globFilterValue = ""
        globalCatg = ""
        filterSearchFormArray.removeAll(keepingCapacity: false)
        //  searchDic.removeAll(keepingCapacity: false)
    }
    
    
    // Check for Blog Update Every Time when View Appears
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
        
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            
        }
        
        if eventUpdate {

            showSpinner = true
            pageNumber = 1
            updateScrollFlag = false
            browseEntries()
        }
        
        if fromActivityFeed == true{
            fromActivityFeed = false
            let presentedVC  = ContentFeedViewController() //EventDetailViewController()
            presentedVC.subjectId = "\(objectId!)"
            presentedVC.subjectType = "event"
            //      presentedVC.eventId = objectId
            //presentedVC.eventName = NSLocalizedString("Loading...", comment: "")
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
 
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    

    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            openMenu = false
            openMenuSlideOnView(mainView)
            mainView.removeGestureRecognizer(tapGesture)
            
        }
        
    }
    

    
    @objc func addNewEvent(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            isCreateOrEdit = true
            let presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Create New Event", comment: "")
            presentedVC.contentType = "event"
            presentedVC.param = [ : ]
            presentedVC.url = "events/create"
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
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    
    
    @objc func showEvent(_ sender:UIButton){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        var eventInfo:NSDictionary!
        eventInfo = eventResponse[sender.tag] as! NSDictionary
        
        if(eventInfo["allow_to_view"] as! Int == 1){
            let presentedVC = ContentFeedViewController()
            presentedVC.subjectId = "\(eventInfo["event_id"]!)"
            presentedVC.subjectType = "event"
            //EventDetailViewController()
            //  presentedVC.eventId = eventInfo["event_id"] as! Int
            // presentedVC.eventName = eventInfo["title"] as! String
            navigationController?.pushViewController(presentedVC, animated: true)
        }else{
            showToast(message: "You do not have permission to view this private page.", controller: self)
        }
    }
    
    
    @objc func showEventMenu(_ sender:UIButton){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        var eventInfo:NSDictionary
        eventInfo = eventResponse[sender.tag] as! NSDictionary
        
        var confirmationTitle = ""
        var message = ""
        var url = ""
        let param: NSDictionary = [:]
        var confirmationAlert = true
        if (eventInfo["menu"] != nil){
            let menuOption = eventInfo["menu"] as! NSArray
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in menuOption{
                if let menuItem = menu as? NSDictionary{
                    alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                        let condition = menuItem["name"] as! String
                        
                        switch(condition){
                            
                        case "edit":
                            confirmationAlert = false
                            isCreateOrEdit = false
                            let presentedVC = FormGenerationViewController()
                            presentedVC.formTitle = NSLocalizedString("Edit Event", comment: "")
                            presentedVC.contentType = "event"
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:false, completion: nil)

                            
                        case "delete_event":
                            //    self.deleteEvent = true
                            confirmationTitle = NSLocalizedString("Delete Event", comment: "")
                            
                            message = NSLocalizedString("Are you sure you want to delete this event?", comment: "")
                            url = menuItem["url"] as! String
                            //                        param = menuItem["urlParams"] as! NSDictionary
                            
                        case "leave_event":
                            confirmationTitle = NSLocalizedString("Leave Event", comment: "")
                            message = NSLocalizedString("Are you sure you want to leave this event?", comment: "")
                            url = menuItem["url"] as! String
                            
                        default:
                            
                            print("error")
                            //                        fatalError("init(coder:) has not been implemented")
                        }
                        
                        
                        if confirmationAlert == true {
                            displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                self.updateEventMenuAction(param as NSDictionary,url: url)
                            }
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }))
                }
            }
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }else if  (UIDevice.current.userInterfaceIdiom == .pad){
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2, width: 1, height: 1)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
    }
    
    func updateEventMenuAction(_ parameter: NSDictionary , url : String){
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
            
            var method:String
            
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update Blog Detail
                        // Update Event Detail
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
    
    
    // MARK: - Server Connection For Event Updation
    // Update Events
    @objc func browseEntries(){
        
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
//            if showOnlyMyContent == true {
//                eventBrowseType = 2
//            }
            
            // info.removeFromSuperview()
            let subViews = mainView.subviews
            for ob in subViews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            //
            
            var path = ""
            var parameters = [String:String]()
            
            if((fromTab == true) && (user_id != nil)) {
                eventBrowseType = 0
            }
            
            
            switch(eventBrowseType){
            case 0:
                
                path = "events"
                if((fromTab == true) && (user_id != nil)) {
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","user_id" : String(user_id)] // ,"filter":"future"
                }else{
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
                    self.title = NSLocalizedString("Events",  comment: "")
                }
                
            case 1:
                path = "events"
                parameters = ["page":"\(pageNumber)","limit": "\(limit)","filter":"past"]
                self.title = NSLocalizedString("Events",  comment: "")
            case 2:
                path = "events/manage"
                parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
                self.title = NSLocalizedString("Events",  comment: "")
            default:
                print("Error")
            }
            
            
            if (self.pageNumber == 1){
                //self.eventResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true {
                    removeAlert()
                    if let responseCacheArray = self.responseCache["\(path)"]{
                        self.eventResponse = responseCacheArray as! [AnyObject]
                     //   showSpinner = false
                    }
                    self.eventTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            refreshButton.isHidden = true
            contentIcon.isHidden = true
            
            if (showSpinner){
          //      spinner.center = view.center
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
            
            //           // Set Parameters for Search
            //            if searchDic.count > 0 {
            //                parameters.merge(searchDic)
            //            }
            //          //  path = "events/manage"
            
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    
                    if msg{
                        
                        ////print(succeeded)
                        
                        if self.pageNumber == 1{
                            self.eventResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let blog = response["response"] as? NSArray {
                                    self.eventResponse = self.eventResponse + (blog as [AnyObject])
                                    if (self.pageNumber == 1){
                                        self.responseCache["\(path)"] = blog
                                    }
                                }
                            }
                            
                            if response["getTotalItemCount"] != nil{
                                self.totalItems = response["getTotalItemCount"] as! Int
                            }
                            if self.showOnlyMyContent == false {
                                
                                if (response["canCreate"] as! Bool == true){

                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(EventViewController.searchItem))
                                    let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(EventViewController.addNewEvent))

                                    self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                    
                                    searchItem.tintColor = textColorPrime
                                    addBlog.tintColor = textColorPrime
                                    self.showAppTour()
                                }else{
                                    let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(EventViewController.searchItem))

                                    self.navigationItem.rightBarButtonItem = searchItem
                                    searchItem.tintColor = textColorPrime
                                }
                                
                            }
                        }
                        
                        
                        self.isPageRefresing = false
                        if NotPlay != 1 {
                            self.pausePlayeVideos()
                        }
                        //                        //Reload Event Tabel
                        self.eventTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.eventResponse.count == 0{
                            
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(eventIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.mainView.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any Event entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
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
                            self.refreshButton.addTarget(self, action: #selector(EventViewController.refresh), for: UIControl.Event.touchUpInside)

                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.mainView.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (kFrequencyAdsInCells_event > 4 && (((indexPath as NSIndexPath).row % kFrequencyAdsInCells_event) == (kFrequencyAdsInCells_event)-1))
        {
        
        if adsType_event == 2{
            guard (UIDevice.current.userInterfaceIdiom != .pad) else {
                return adsCellheight + 5
            }
            return adsCellheight + 5
        }
        else if adsType_event == 0
        {
            return 265
        }
        return adsCellheight + 5
        }
        return 253.0
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if adsType_event == 2{
            
            var row = indexPath.row as Int
            if (kFrequencyAdsInCells_event > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_event) == (kFrequencyAdsInCells_event)-1))
            {
                //            displyedAdsCount = (row / kFrequencyAdsInCells_feeds)
                //            row = row - displyedAdsCount
                
                if let cell1 = cell as? NativeEventCell
                {
                    var Adcount: Int = 0
                    Adcount = row/(kFrequencyAdsInCells_event-1)
                    
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
        if adsType_event == 2{
            if tableView.tag != 11
            {
                
                let row = indexPath.row as Int
                if  (kFrequencyAdsInCells_event > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_event) == (kFrequencyAdsInCells_event)-1))
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
        if nativeAdArray.count > 0
        {
            // For showing facebook ads count
            var rowcount = Int()
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {

                rowcount = 2*(kFrequencyAdsInCells_event-1)
            }
            else
            {
                rowcount = (kFrequencyAdsInCells_event-1)
            }
            if eventResponse.count > rowcount
            {

                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    let b = Int(ceil(Float(eventResponse.count)/2))
                    adsCount = b/(kFrequencyAdsInCells_event-1)
                    if adsCount > 1 || eventResponse.count%2 != 0
                    {
                        adsCount = adsCount/2
                    }
                    let Totalrowcount = adsCount+b
                    if b%(kFrequencyAdsInCells_event-1) == 0 && eventResponse.count % 2 != 0
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
                    adsCount = b/(kFrequencyAdsInCells_event-1)
                    let Totalrowcount = adsCount+b
                    if Totalrowcount % kFrequencyAdsInCells_event == 0
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
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return Int(ceil(Float(eventResponse.count)/2))
        }else{
            return eventResponse.count
        }
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        var row = (indexPath as NSIndexPath).row as Int
        if (kFrequencyAdsInCells_event > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_event) == (kFrequencyAdsInCells_event)-1))
        {  // or 9 == if you don't want the first cell to be an ad!
            eventTableView.register(NativeEventCell.self, forCellReuseIdentifier: "Cell1")
            let cell = eventTableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! NativeEventCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = tableViewBgColor
            var Adcount: Int = 0
            Adcount = row/(kFrequencyAdsInCells_event-1)
            
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
                if adsType_event == 2{
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
                
                cell.dateView2.isHidden = false
                cell.dateView2.frame.size.height = 70
                cell.dateView2.backgroundColor = navColor
                cell.titleView2.frame.size.height = 70
                cell.titleView2.backgroundColor = tableViewBgColor
                var eventInfo2:NSDictionary!
                let adcount = row/kFrequencyAdsInCells_event
                if(eventResponse.count > ((row)*2-adcount) ){
                    eventInfo2 = eventResponse[((row)*2-adcount)] as! NSDictionary
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
                
                // Select Event Action
                cell.contentSelection2.addTarget(self, action: #selector(EventViewController.showEvent(_:)), for: .touchUpInside)
                // Set MenuAction
                cell.menuButton2.addTarget(self, action:#selector(EventViewController.showEventMenu(_:)) , for: .touchUpInside)
                
                
                cell.contentImage2.frame.size.height = 250
                cell.contentSelection2.frame = CGRect(x: (UIScreen.main.bounds.width/2), y: 40, width: cell.cellView2.bounds.width, height: cell.cellView2.bounds.height)
                cell.contentSelection2.frame.size.height = 180
                
                
                // Set Event Image
                if let photoId = eventInfo2["photo_id"] as? Int{
                    
                    if photoId != 0{
                        cell.contentImage2.backgroundColor = placeholderColor
                        cell.contentImage2.image = nil
                        let url = URL(string: eventInfo2["image"] as! NSString as String)
                        
                        if url != nil {
                            cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage2.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })

                        }
                        
                    }else{
                        cell.contentImage2.backgroundColor = placeholderColor
                        cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                    }
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
                        cell.dateLabel3.textColor = UIColor.white
                        cell.dateLabel3.font = UIFont(name: "FontAwesome", size: 18)
                    }
                    
                    let date = dateDifferenceWithEventTime(eventDate)
                    var DateC = date.components(separatedBy: ", ")
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
                }
                else{
                    cell.dateView2.isHidden = true
                }
                
                cell.titleLabel2.frame = CGRect(x: 10, y: 0, width: (cell.contentImage2.bounds.width-125), height: 30)
                
                cell.titleLabel2.text = "\(name!)"
                cell.titleLabel2.numberOfLines = 0
                cell.titleLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                // cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
                // cell.titleLabel2.sizeToFit()
                
                let location = eventInfo2["location"] as? String
                if location != "" && location != nil{
                    
                    cell.locLabel2.isHidden = false
                    
                    cell.locLabel2.frame = CGRect(x: 10, y: 25, width: (cell.contentImage2.bounds.width-70), height: 20)
                    cell.locLabel2.text = "\u{f041}   \(location!)"
                    // cell.locLabel.textColor = textColorLight
                    cell.locLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                    
                    cell.dateLabel2.frame = CGRect(x: 10, y: 45, width: (cell.contentImage2.bounds.width-70), height: 20)
                    cell.dateLabel2.text = "\u{f073}  \(tempInfo)"
                    cell.dateLabel2.textAlignment = NSTextAlignment.left
                    // cell.dateLabel.textColor = textColorLight
                    cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                    
                }
                
                if location == "" || location == nil{
                    
                    cell.locLabel2.isHidden = true
                    
                    cell.dateLabel2.frame = CGRect(x: 10, y: 35, width: (cell.contentImage2.bounds.width-70), height: 20)
                    cell.dateLabel2.text = "\u{f073}  \(tempInfo)"
                    cell.dateLabel2.textAlignment = NSTextAlignment.left
                    //cell.dateLabel.textColor = textColorLight
                    cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                    
                }
                
                
                
                // Set Menu
                if eventBrowseType != 2 {
                    cell.menuButton2.isHidden = true
                }else{
                    cell.menuButton2.isHidden = false
                }
                
                return cell
            }
            
            return cell
            
        }
        else
        {
            
            if kFrequencyAdsInCells_event > 4 && nativeAdArray.count > 0
            {
                row = row - (row / kFrequencyAdsInCells_event)
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath) as! EventViewTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.lineView.isHidden = false
            cell.dateView.frame.size.height = 70
            cell.dateView.backgroundColor = navColor
            cell.titleView.frame.size.height = 70
            cell.titleView.backgroundColor = UIColor.white
            cell.backgroundColor = tableViewBgColor
            cell.layer.borderColor = UIColor.white.cgColor
            
            var eventInfo:NSDictionary!
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                if (kFrequencyAdsInCells_event > 4 && nativeAdArray.count > 0)
                {
                    let adcount = row/(kFrequencyAdsInCells_event-1)
                    if(eventResponse.count > ((row)*2+adcount))
                    {
                        eventInfo = eventResponse[((row)*2+adcount)] as! NSDictionary
                        cell.contentSelection.tag = ((row)*2+adcount)
                        cell.menu.tag = ((row)*2+adcount)
                        
                    }
                }
                else
                {
                    if(eventResponse.count > (row)*2)
                    {
                        eventInfo = eventResponse[(row)*2] as! NSDictionary
                        cell.contentSelection.tag = (row)*2
                        cell.menu.tag = (row)*2
                        
                    }
                }
                
                
            }
            else
            {
                eventInfo = eventResponse[row] as! NSDictionary
                cell.contentSelection.tag = row
                cell.menuButton.tag = row
            }
            
            //Select Event Action
            cell.contentSelection.addTarget(self, action: #selector(EventViewController.showEvent(_:)), for: .touchUpInside)
            // Set MenuAction
            cell.menuButton.addTarget(self, action:#selector(EventViewController.showEventMenu(_:)) , for: .touchUpInside)
            
            
            cell.contentImage.frame.size.height = 250
            cell.contentSelection.frame = CGRect(x: 0, y: 40, width: cell.cellView.bounds.width, height: cell.cellView.bounds.height)
            cell.contentSelection.frame.size.height = 180
            
            // Set Event Image
            
            if let photoId = eventInfo["photo_id"] as? Int{
                
                if photoId != 0{
                    
                    cell.contentImage.backgroundColor = placeholderColor
                    let url1 = URL(string: eventInfo["image"] as! NSString as String)
                    cell.contentImage.kf.indicatorType = .activity
                    (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImage.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
                else{
                    cell.contentImage.image = nil
                    cell.contentImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                    
                }
            }
            
            let name = eventInfo["title"] as? String
            var tempInfo = ""
            if let eventDate = eventInfo["starttime"] as? String{
                
                let dateMonth = dateDifferenceWithTime(eventDate)
                var dateArrayMonth = dateMonth.components(separatedBy: ", ")
                if dateArrayMonth.count > 1{
                    cell.dateLabel1.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                    
                    cell.dateLabel1.numberOfLines = 0
                    cell.dateLabel1.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                    cell.dateLabel1.textColor = UIColor.white
                    cell.dateLabel1.font = UIFont(name: "FontAwesome", size: 18)
                }
                
                let date = dateDifferenceWithEventTime(eventDate)
                var DateC = date.components(separatedBy: ", ")
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
            }
            
            cell.titleLabel.frame = CGRect(x: 10, y: 0, width: (cell.contentImage.bounds.width-125), height: 30)
            cell.titleLabel.numberOfLines = 0
            cell.titleLabel.text = "\(name!)"
            cell.titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
            // cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
            // cell.titleLabel.sizeToFit()
            
            let location = eventInfo["location"] as? String
            if location != "" && location != nil{
                
                cell.locLabel.isHidden = false
                
                cell.locLabel.frame = CGRect(x: 10, y: 25, width: (cell.contentImage.bounds.width-70), height: 20)
                cell.locLabel.text = "\u{f041}   \(location!)"
                // cell.locLabel.textColor = textColorLight
                cell.locLabel.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                
                cell.dateLabel.frame = CGRect(x: 10, y: 45, width: (cell.contentImage.bounds.width-70), height: 20)
                cell.dateLabel.text = "\u{f073}  \(tempInfo)"
                cell.dateLabel.textAlignment = NSTextAlignment.left
                // cell.dateLabel.textColor = textColorLight
                cell.dateLabel.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                
            }
            
            if location == "" || location == nil{
                
                cell.locLabel.isHidden = true
                
                cell.dateLabel.frame = CGRect(x: 10, y: 35, width: (cell.contentImage.bounds.width-70), height: 20)
                cell.dateLabel.text = "\u{f073}  \(tempInfo)"
                cell.dateLabel.textAlignment = NSTextAlignment.left
                //cell.dateLabel.textColor = textColorLight
                cell.dateLabel.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                
            }
            
            // Set Menu
            if eventBrowseType != 2 {
                cell.menuButton.isHidden = true
                //  cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 10)
            }else{
                cell.menuButton.isHidden = false
                // cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 30)
            }
            
            // RHS
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                
                cell.dateView2.isHidden = false
                cell.dateView2.frame.size.height = 70
                cell.dateView2.backgroundColor = navColor
                cell.titleView2.frame.size.height = 70
                cell.titleView2.backgroundColor = tableViewBgColor
                
                var eventInfo2:NSDictionary!
                var adcount = Int()
                if (kFrequencyAdsInCells_event > 4 && nativeAdArray.count > 0)
                {
                    adcount = row/(kFrequencyAdsInCells_event-1)
                }
                else
                {
                    adcount = 0
                }
                if(eventResponse.count > ((row)*2+1+adcount) ){
                    eventInfo2 = eventResponse[((row)*2+1+adcount)] as! NSDictionary
                    cell.cellView2.isHidden = false
                    cell.contentSelection2.isHidden = false
                    cell.dateView2.isHidden = false
                    cell.titleView2.isHidden = false
                    cell.contentSelection2.tag = ((row)*2+1+adcount)
                    cell.menuButton2.tag = ((row)*2+1+adcount)
                }else{
                    cell.cellView2.isHidden = true
                    cell.contentSelection2.isHidden = true
                    cell.dateView2.isHidden = true
                    cell.titleView2.isHidden = true
                    return cell
                }
                
                // Select Event Action
                cell.contentSelection2.addTarget(self, action: #selector(EventViewController.showEvent(_:)), for: .touchUpInside)
                // Set MenuAction
                cell.menuButton2.addTarget(self, action:#selector(EventViewController.showEventMenu(_:)) , for: .touchUpInside)
                
                
                cell.contentImage2.frame.size.height = 250
                cell.contentSelection2.frame = CGRect(x: (UIScreen.main.bounds.width/2), y: 40, width: cell.cellView2.bounds.width, height: cell.cellView2.bounds.height)
                cell.contentSelection2.frame.size.height = 180
                
                
                // Set Event Image
                if let photoId = eventInfo2["photo_id"] as? Int{
                    
                    if photoId != 0{
                        cell.contentImage2.backgroundColor = placeholderColor
                        cell.contentImage2.image = nil
                        let url = URL(string: eventInfo2["image"] as! NSString as String)
                        
                        if url != nil {
                            cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage2.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })

                        }
                        
                    }else{
                        cell.contentImage2.backgroundColor = placeholderColor
                        cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                    }
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
                        cell.dateLabel3.textColor = UIColor.white
                        cell.dateLabel3.font = UIFont(name: "FontAwesome", size: 18)
                    }
                    
                    let date = dateDifferenceWithEventTime(eventDate)
                    var DateC = date.components(separatedBy: ", ")
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
                }
                else{
                    cell.dateView2.isHidden = true
                }
                
                cell.titleLabel2.frame = CGRect(x: 10, y: 0, width: (cell.contentImage2.bounds.width-125), height: 30)
                
                cell.titleLabel2.text = "\(name!)"
                cell.titleLabel2.numberOfLines = 0
                cell.titleLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                // cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
                // cell.titleLabel2.sizeToFit()
                
                let location = eventInfo2["location"] as? String
                if location != "" && location != nil{
                    
                    cell.locLabel2.isHidden = false
                    
                    cell.locLabel2.frame = CGRect(x: 10, y: 25, width: (cell.contentImage2.bounds.width-70), height: 20)
                    cell.locLabel2.text = "\u{f041}   \(location!)"
                    // cell.locLabel.textColor = textColorLight
                    cell.locLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                    
                    cell.dateLabel2.frame = CGRect(x: 10, y: 45, width: (cell.contentImage2.bounds.width-70), height: 20)
                    cell.dateLabel2.text = "\u{f073}  \(tempInfo)"
                    cell.dateLabel2.textAlignment = NSTextAlignment.left
                    // cell.dateLabel.textColor = textColorLight
                    cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                    
                }
                
                if location == "" || location == nil{
                    
                    cell.locLabel2.isHidden = true
                    
                    cell.dateLabel2.frame = CGRect(x: 10, y: 35, width: (cell.contentImage2.bounds.width-70), height: 20)
                    cell.dateLabel2.text = "\u{f073}  \(tempInfo)"
                    cell.dateLabel2.textAlignment = NSTextAlignment.left
                    //cell.dateLabel.textColor = textColorLight
                    cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                    
                }
                
                
                
                // Set Menu
                if eventBrowseType != 2 {
                    cell.menuButton2.isHidden = true
                }else{
                    cell.menuButton2.isHidden = false
                }
                
                return cell
            }
            return cell
        }
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        var row = (indexPath as NSIndexPath).row as Int
        if (kFrequencyAdsInCells_event > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_event) == (kFrequencyAdsInCells_event)-1))
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
    
    
    // MARK:  TTTAttributedLabelDelegate
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        //UIApplication.shared.openURL(url!)
        let presentedVC = ExternalWebViewController()
        presentedVC.url = url.absoluteString
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navigationController = UINavigationController(rootViewController: presentedVC)
        self.present(navigationController, animated: true, completion: nil)

    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        let type = components["type"] as! String
        
        switch(type){
        case "category_id":
            blogUpdate = true
            searchDic.removeAll(keepingCapacity: false)
            let id = components["id"] as! Int
            searchDic["category"] = "\(id)"
            //print(searchDic, terminator: "")
            _ = self.navigationController?.popViewController(animated: true)

            
        default:
            print("default")
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
                        eventTableView.tableFooterView?.isHidden = false
                     //   if searchDic.count == 0{
                            if adsType_event == 2 || adsType_event == 4{
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
                    eventTableView.tableFooterView?.isHidden = true
                }
                
            }
            
        }
        
    }
    
    @objc func searchItem(){
        let presentedVC = EventSearchViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
        let url : String = "events/search-form"
        loadFilter(url)
    }
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)

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
