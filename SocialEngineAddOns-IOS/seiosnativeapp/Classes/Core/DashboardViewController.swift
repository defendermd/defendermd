//
//  DashboardViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 06/06/16.
//  Copyright © 2016 bigstep. All rights reserved.
//
var mainMenu: NSArray = []
var dashboardMenu : NSArray!
var Locationdic : NSMutableDictionary!
var notificationCount = 0
var messageCount = 0
var friendRequestCount = 0
var totalNotificationCount : Int = 0
var MLTbrowseOrMyListings : Bool?
var defaultlocation : String = ""
var locationOnhome :Int = 0
var autodetectLocation :Int = 0
var isChangeManually :Int = 0
var dynamicEventPackageEnabled : Int = 1
var greetingsAllow : Int = 1
var bannerAllow : Int = 1
var enableSuggestion : Bool = true
var uploadMultiplePhoto = ""
var enableAppTour = 1
var video_quality = 0
var canSendMessage :String = ""
var storyDuration :Int = 0
var isAddFriendWidgetEnable = 0
var isPaidMember: Int = 0
import UIKit
import CoreData
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

let color1 = UIColor(hex: "f1051b") // Red Color
let color2 = UIColor(hex: "23aaff") // Light Blue
let color3 = UIColor(hex: "f5a70c") // Yellow
let color4 = UIColor(hex: "810040") // Dark Pink
let color5 = UIColor(hex: "ff7b62") // Orange
let color6 = UIColor(hex: "430fdf") // Blue
let color7 = UIColor(hex: "019a01") // Green
let color8 = UIColor(hex: "811791") // Purple
let color9 = UIColor(hex: "1446FA") // Navblue
let colorFriends = UIColor(hex: "1446FA") // Navblue
let colorPhoto = UIColor(hex: "B54399") // Navblue
let colorVideo = UIColor(hex: "0B6A96") // Navblue
let colorMore = UIColor(hex: "A15955") // Navblue
var conditionalProfileForm = ""
var context1 = CIContext(options: nil)

var sitereviewMenuDictionary : NSDictionary!
var listingBrowseViewTypeArr = Dictionary<Int, Dictionary<String, Int>>()
var imageProfile : UIImage? = nil
var imageDashboardCover : UIImage? = nil
var processedImage : UIImage? = nil
class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, LoginButtonDelegate, UISearchBarDelegate , CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    
    var dashboardTableView : UITableView!
    var bottomTableView : UIView!
    var signInButton : UIButton!
    var signUpButton : UIButton!
    var topTableVIew : UIView!
    var profilePic : UIImageView!
    var displayNameLabel : UILabel!
    var profileImageView : UIImageView!
    var profileView = UIView()
    var blurImageView = UIImageView()
    let searchBar = UISearchBar()
    var coachMarksController = CoachMarksController()
    var dashboardTargetCheckValue = 1
    
    override func viewDidLoad()
    {
        
        // self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        if iscomingfrom == "store"
        {
            SiteStoreObject().redirectToManageCart(viewController: self)
        }
        
        uploadMultiplePhoto = ""
        _ = SearchBarContainerView(self, customSearchBar:searchBar, isKeyboardAppear:false)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search",  comment: ""))
        searchBar.delegate = self
        //        searchBar.resignFirstResponder()
        
        
        let topView = createView(CGRect(x: 0, y: 0 , width: view.bounds.width,height: 190), borderColor: UIColor.clear, shadow: false)
        topView.backgroundColor = aafBgColor
        
        
        profileView = createView(CGRect(x: 0, y: 0 , width: view.bounds.width,height: 190), borderColor: UIColor.clear, shadow: false)
        profileView.layer.borderWidth = 0.0
        
        displayNameLabel = createLabel(CGRect(x: 10, y: profileView.bounds.height/2 + 50 , width: view.bounds.width - 20,height: 40), text: "Alen J", alignment: .center, textColor: textColorLight)
        displayNameLabel.font = UIFont(name: fontName, size: FONTSIZELarge + 3.0)
        
        
        if logoutUser == false {
            if displayName != nil {
                displayNameLabel.text = displayName
            }
        }else{
            displayNameLabel.text = NSLocalizedString("Guest",comment: "")
            displayNameLabel.textColor = UIColor(red: 51/255 , green: 51/255 , blue: 51/255, alpha: 1.0)
        }
        
        // blurImageView = createImageView(CGRect(x: 0, y: 0 , width: view.bounds.width,height: 190), border: false)
        blurImageView = CoverImageViewWithGradient(frame: CGRect(x: 0, y: 0 , width: view.bounds.width,height: 190))
        blurImageView.backgroundColor = textColorLight
        blurImageView.layer.masksToBounds = true
        blurImageView.clipsToBounds = true
        blurImageView.contentMode = .scaleAspectFill
        profileView.addSubview(blurImageView)
        if imageDashboardCover != nil
        {
            blurImageView.image = imageDashboardCover
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.updateCoverImageView(userInfo:)), name: NSNotification.Name(rawValue: "CoverImageUpdated"), object: nil)
        
        
        profileView.addSubview(displayNameLabel)
        
        profileImageView = createImageView(CGRect(x: view.bounds.width/2 - 60, y: profileView.bounds.height/2 - 63 , width: 120,height: 120), border: false)
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2;
        profileImageView.layer.masksToBounds = true
        profileImageView.image = UIImage(named: "Splash")
        profileView.addSubview(profileImageView)
        topView.addSubview(profileView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(DashboardViewController.openProfile))
        profileView.addGestureRecognizer(tap)
        
        bottomTableView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 170), borderColor: textColorLight , shadow: false)
        signInButton = createButton(CGRect(x: 15, y: 70, width: (view.bounds.width / 2) - 25, height: 40), title: NSLocalizedString("Sign Up", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        signInButton.addTarget(self, action: #selector(DashboardViewController.signup), for: UIControl.Event.touchUpInside)
        signInButton.layer.cornerRadius = 5
        bottomTableView.addSubview(signInButton)
        
        signUpButton = createButton(CGRect(x: (view.bounds.width / 2) + 10, y: 70, width: (view.bounds.width / 2) - 25, height: 40), title: NSLocalizedString("Sign In", comment: ""), border: false, bgColor: true, textColor: textColorPrime)
        signUpButton.layer.cornerRadius = 5
        signUpButton.addTarget(self, action: #selector(DashboardViewController.signin), for: UIControl.Event.touchUpInside)
        bottomTableView.backgroundColor = textColorLight
        bottomTableView.addSubview(signUpButton)
        if let facebookSdk = Bundle.main.infoDictionary?["FacebookAppID"] as? String {
            if facebookSdk != "" && (logoutUser == true) {
                let loginView  = FBLoginButton()
                loginView.frame = CGRect(x: 15, y: 10, width: view.bounds.width - 30, height: 50)
                loginView.permissions = ["public_profile", "email"]
                loginView.delegate = self
                bottomTableView.addSubview(loginView)
            }
        }
        // Initialize Blog Table
        dashboardTableView = UITableView(frame: CGRect(x: 0, y: 0 , width: view.bounds.width, height: view.bounds.height - tabBarHeight + 1), style: .grouped)
        dashboardTableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        dashboardTableView.dataSource = self
        dashboardTableView.delegate = self
        dashboardTableView.estimatedRowHeight = 40.0
        dashboardTableView.rowHeight = UITableView.automaticDimension
        dashboardTableView.backgroundColor = tableViewBgColor
        dashboardTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.dashboardTableView.estimatedRowHeight = 0
            self.dashboardTableView.estimatedSectionHeaderHeight = 0
            self.dashboardTableView.estimatedSectionFooterHeight = 0
        }
        //        if #available(iOS 9.0, *) {
        //            dashboardTableView.cellLayoutMarginsFollowReadableWidth = false
        //        } else {
        //            // Fallback on earlier versions
        //        }
        view.addSubview(dashboardTableView)
        dashboardTableView.tableHeaderView = topView
        print(self.dashboardTableView.contentOffset.y)
        print("ok")
        if logoutUser == true {
            dashboardTableView.tableFooterView = bottomTableView
        }else{
            dashboardTableView.tableFooterView = nil
        }
        
    }
    
    // MARK: - Server Connection For Dynamic Dashboard
    func getDynamicDashboard(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            parameters = ["browse_as_guest" : "1","limit": "\(limit)","type":"ios","version":"1.5"]
            
            // Send Server Request for Ac as! NSArraytivity Feed
            post(parameters, url: "get-dashboard-menus", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    // Reset Object after Response from server
                    userInteractionOff = true
                    if msg{
                        //defaults.setObject(dict, forKey:  “SaveDict”)
                        if let response = succeeded["body"] as? NSDictionary{
                            // Check for Feed Filter Options
                            //  print(response)
                            
                            if response["video_quality"] as? Int == 1
                            {
                                video_quality = 1
                            }
                            else
                            {
                                video_quality = 0
                            }
                            if let isPaid = response["isPaidMember"] as? Int {
                                isPaidMember = isPaid
                            }
                            if let isAddfriendWidget = response["isAddFriendWidgetEnable"] as? Int {
                                isAddFriendWidgetEnable = isAddfriendWidget
                            }
                            
                            if let restapilocation = response["restapilocation"] as? NSDictionary{
                                if restapilocation["autodetectLocation"] as? Int == 1
                                {
                                    autodetectLocation = 1
                                }
                                else
                                {
                                    autodetectLocation = 0
                                }
                                
                                if restapilocation["isChangeManually"] as? Int == 1
                                {
                                    isChangeManually = 1
                                }
                                else
                                {
                                    isChangeManually = 0
                                }
                            }
                            
                            if let default_location = response["defaultlocation"] as? String
                            {
                                defaultlocation = default_location
                                let defaults = UserDefaults.standard
                                defaults.set(defaultlocation, forKey: "Location")
                            }
                            
                            if response["location"] as? Int == 1
                            {
                                locationOnhome = 1
                            }
                            else
                            {
                                locationOnhome = 0
                            }
                            
                            if response["app_tour"] as? Int == 0 {
                                enableAppTour = 0
                                print("first called")
                                UserDefaults.standard.set(0, forKey: "showHomePageAppTour")
                                UserDefaults.standard.set(0, forKey: "showDashboardAppTour")
                                UserDefaults.standard.set(0, forKey: "showPluginAppTour")
                                UserDefaults.standard.set(0, forKey: "showUserProfilePageAppTour")
                                UserDefaults.standard.set(0, forKey: "showOtherUserProfilePageAppTour")
                                UserDefaults.standard.set(0, forKey: "showMessageAppTour")
                                UserDefaults.standard.set(0, forKey: "showAlbumAppTour")
                                UserDefaults.standard.set(0, forKey: "showSearchPluginAppTour")
                                UserDefaults.standard.set(0, forKey: "showMemberSearchPluginAppTour")
                                UserDefaults.standard.set(0, forKey: "showTogglePluginAppTour")
                                UserDefaults.standard.set(0, forKey: "showSeeAllPluginAppTour")
                                
                            }
                            else{
                                print("first called condition check")
                                enableAppTour = 1
                                
                                if let name = UserDefaults.standard.object(forKey: "showHomePageAppTour")
                                {
                                    if  UserDefaults.standard.object(forKey: "showHomePageAppTour") != nil {
                                        let nameVlaue = name as! Int
                                        if nameVlaue == 0 {
                                            UserDefaults.standard.set(1, forKey: "showHomePageAppTour")
                                            UserDefaults.standard.set(1, forKey: "showDashboardAppTour")
                                            UserDefaults.standard.set(1, forKey: "showPluginAppTour")
                                            UserDefaults.standard.set(1, forKey: "showUserProfilePageAppTour")
                                            UserDefaults.standard.set(1, forKey: "showOtherUserProfilePageAppTour")
                                            UserDefaults.standard.set(1, forKey: "showMessageAppTour")
                                            UserDefaults.standard.set(1, forKey: "showAlbumAppTour")
                                            UserDefaults.standard.set(1, forKey: "showSearchPluginAppTour")
                                            UserDefaults.standard.set(1, forKey: "showMemberSearchPluginAppTour")
                                            UserDefaults.standard.set(1, forKey: "showTogglePluginAppTour")
                                            UserDefaults.standard.set(1, forKey: "showSeeAllPluginAppTour")
                                            
                                        }
                                        
                                        
                                    }
                                    
                                }
                                
                                
                            }
                            
                            let nc = NotificationCenter.default
                            nc.post(name: Foundation.Notification.Name(rawValue: "checkService"), object: nil)
                            if let loginopt = response["loginoption"] as? String{
                                let defaults = UserDefaults.standard
                                defaults.set(loginopt, forKey: "formmode") // change when need to show otp with loginopt
                            }
                            if let isSitestoriesEnable = response["isSitestoriesEnable"] as? Int{
                                let defaults = UserDefaults.standard
                                defaults.set(isSitestoriesEnable, forKey: "isSitestoriesEnable")
                            }
                            
                            if let sd = response["storyDuration"] as? Int{
                                storyDuration = sd
                            }
                            
                            if let EnableOtp = response["isOTPEnable"] as? Int{
                                if EnableOtp == 1
                                {
                                    let defaults = UserDefaults.standard
                                    defaults.set(NSLocalizedString("Email Address or Mobile Number", comment: ""), forKey: "namelabel")
                                    isEnableOtp = true
                                }
                                else
                                {
                                    isEnableOtp = false
                                }
                                isOTPEnableplugin = EnableOtp
                            }
                            
                            if let showFilterType = response["showFilterType"] as? Int
                            {
                                isfeedfilter = showFilterType
                            }
                            
                            if let package = response["packagesEnabled"] as? Int
                            {
                                dynamicEventPackageEnabled = package
                            }
                            
                            if let location = response["menus"] as? NSArray
                            {
                                for dic in location
                                {
                                    if let tempLocationDic = dic as? NSDictionary{
                                        if let name = tempLocationDic["name"] as? String
                                        {
                                            if name == "seaocore_location"
                                            {
                                                if  let locationdic = tempLocationDic["data"] as? NSDictionary
                                                {
                                                    Locationdic = locationdic.mutableCopy() as! NSMutableDictionary
                                                    if Locationdic != nil
                                                    {
                                                        let keyExists = Locationdic["default"] != nil
                                                        if keyExists
                                                        {
                                                            defaultlocation = Locationdic["default"] as! String
                                                            
                                                            let defaults = UserDefaults.standard
                                                            defaults.set(defaultlocation, forKey: "Location")
                                                        }
                                                        //                                                        else
                                                        //                                                        {
                                                        //                                                            defaultlocation = ""
                                                        //
                                                        //                                                        }
                                                    }
                                                    let nc = NotificationCenter.default
                                                    nc.post(name: Foundation.Notification.Name(rawValue: "UserLoggedIn"), object: nil)
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                
                            }
                            
                            if let menu = response["menus"] as! NSArray?
                            {
                                let  defaults = UserDefaults.standard
                                dashboardMenu = menu as NSArray
                                let dataarray:Data = NSKeyedArchiver.archivedData(withRootObject: menu)
                                defaults.set(dataarray , forKey: "SaveMenu")
                                refreshMenu = false
                                
                            }
                            
                            if response["browse_as_guest"] as? Int == 1 {
                                browseAsGuest = true
                                let nc = NotificationCenter.default
                                nc.post(name: Foundation.Notification.Name(rawValue: "BrowseAsGuest"), object: nil)
                            }
                            else{
                                browseAsGuest = false
                            }
                            
                            //Containing Modules enabled
                            if let enabled_modules = response["enable_modules"] as? NSArray{
                                enabledModules = enabled_modules
                            }
                            
                            // Check if channel enable or not
                            if let ischannel = response["isChannelEnable"] as? Bool{
                                isChannelEnable = ischannel
                                
                            }
                            
                            // Check if playlist enable or not
                            if let isplaylist = response["isPlaylistEnable"] as? Bool{
                                isPlaylistEnable = isplaylist
                                
                            }
                            
                            // feed Permission variable
                            if let isGreetings = response["allowGreeting"] as? Int{
                                greetingsAllow = isGreetings
                                
                            }
                            if let isBanner = response["allowBanner"] as? Int{
                                bannerAllow = isBanner
                                
                            }
                            if let isTarget = response["allowTargetPost"] as? Int{
                                targetAllow = isTarget
                                
                            }
                            if let isSchedule = response["allowSchedulePost"] as? Int{
                                scheduleAllow = isSchedule
                                
                            }
                            // Check if otp plugin enable or not
                            if let canSendMsg = response["canSendMessage"] as? String{
                                canSendMessage = canSendMsg
                                if canSendMessage == "none" || canSendMessage == "None" {
                                    if let tabBarControllerItems = self.tabBarController?.tabBar.items as AnyObject as? NSArray {
                                        let tabBarItem = tabBarControllerItems[messageIndex] as? UITabBarItem
                                        tabBarItem?.isEnabled = false
                                        
                                    }
                                }
                            }
                            
                            if enabledModules.contains("suggestion") && logoutUser == false && enableSuggestion == true{
                                let nc = NotificationCenter.default
                                nc.post(name: Foundation.Notification.Name(rawValue: "Suggestion"), object: nil)
                                
                            }
                            
                            updateUserData()
                            if self.dashboardTableView != nil{
                                self.dashboardTableView.reloadData()
                            }
                            
                            self.updateListingBrowseViewTypeArr()
                        }
                    }
                    
                    if let successBody = succeeded["body"] as? NSDictionary{
                        if let siteiosappMode = successBody["siteiosappMode"] as? Bool{
                            isSandboxMode = siteiosappMode
                        }
                    }
                })
            }
            if bannerAllow == 1 {
                getBannerImage()
            }
            
            getFeedDecorationSeting()
            getCartCount()
            
        }else{
            // No Internet Connection Message
            //            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        updateListingBrowseViewTypeArr()
    }
    
//    func setTimer() {
//        self.checkMiniMenuTimers = Timer.scheduledTimer(timeInterval: 10, target:self, selector:  #selector(DashboardViewController.checkMiniMenu), userInfo: nil, repeats: true)
//    }
    func getFeedDecorationSeting(){
        if Reachabable.isConnectedToNetwork()
        {
            let parameters = [String:String]()
            post(parameters, url: "advancedactivity/feeds/feed-decoration", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg {
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["feed_docoration_setting"] != nil {
                                decorationDictionary =  response["feed_docoration_setting"] as! NSDictionary
                                feedCharLength = decorationDictionary["char_length"] as! Int
                                feedFontStyle = decorationDictionary["font_style"] as! String
                                feedFontSize = decorationDictionary["font_size"] as! Int
                                feedTextColor = decorationDictionary["font_color"] as! String
                                bannerFeedLength = decorationDictionary["banner_feed_length"] as! Int
                            }
                            // spinner.stopAnimating()
                        }
                    }
                    
                })
                
            }
        }
    }
    
    
    func getBannerImage(){
        if Reachabable.isConnectedToNetwork()
        {
            let parameters = [String:String]()
            post(parameters, url: "advancedactivity/feelings/banner", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg {
                        
                        if let response = succeeded["body"] as? NSArray{
                            bannerArray =  (response as [AnyObject])
                            //  spinner.stopAnimating()
                        }
                    }
                    
                })
                
            }
        }
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    
    
    //    func coachMarksController(_ coachMarksController: CoachMarksController,
    //                              coachMarkAt index: Int) -> CoachMark {
    //        var coachMark : CoachMark
    //        dashboardTargetCheckValue = 2
    //        coachMark = coachMarksController.helper.makeCoachMark(for: profileImageView)
    //        coachMark.disableOverlayTap = true
    //        return coachMark
    //    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        let flatCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(rect: frame)
        }
        
        var coachMark : CoachMark
        var origin_y = 0.0
        
        if !(DeviceType.IS_IPHONE_X) {
            
            let bounds = UIScreen.main.bounds
            let height = bounds.size.height
            
            
            switch height
            {
            case 568.0:
                origin_y = 128
            default:
                origin_y = 156
            }
        }
        else{
            origin_y = 180
        }
        
        
        switch(index) {
        case 0:
            //  self.postView.layer.cornerRadius = self.postView.frame.width / 2
            //   skipView.isHidden = false
            
            var   coachMark1 : CoachMark
            coachMark1 = coachMarksController.helper.makeCoachMark(for: profileImageView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.view.bounds.width/2 ,y: CGFloat(origin_y)), radius: CGFloat(65), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                
                
                return circlePath//UIBezierPath(ovalIn: frame.insetBy(dx: -5, dy: -5))
                
            }
            coachMark1.disableOverlayTap = true
            coachMark1.gapBetweenCoachMarkAndCutoutPath = 8.0
            // We'll also enable the ability to touch what's inside
            // the cutoutPath.
            //  coachMark1.allowTouchInsideCutoutPath = true
            return coachMark1
            
            
            
            
            
        default:
            coachMark = coachMarksController.helper.makeCoachMark()
            coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        }
        
        
        
        return coachMark
    }
    
    
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        // let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, arrowOrientation: coachMark.arrowOrientation)
        
        var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        //  var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        // For the coach mark at index 2, we disable the ability to tap on the
        // coach mark to get to the next one, forcing the user to perform
        // the appropriate action.
        switch(index) {
        case 1:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        // coachViews.bodyView.isUserInteractionEnabled = false
        default:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = NSLocalizedString(" Tap to access your Profile Page.", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Got it", comment: "")
            
            
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        
        
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        removeNavigationViews(controller: self)
        
        if logoutUser == false {
            if dashboardTargetCheckValue == 1 {
                UserDefaults.standard.set(2, forKey: "showDashboardAppTour")
                coachMarksController.dataSource = self
                coachMarksController.delegate = self
                
                //        skipView.setTitle("Skip", for: .normal)
                //        coachMarksController.skipView = skipView
                
                coachMarksController.overlay.allowTap = true
                coachMarksController.overlay.fadeAnimationDuration = 0.5
                coachMarksController.start(on: self)
            }
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool{
        DispatchQueue.main.async {
            let pv = CoreAdvancedSearchViewController()
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(pv, animated: false)
        }
        return true
        
    }
    
    //UPDATE LISTING BROWSE VIEW TYPE ARRAY FUNCTION
    func updateListingBrowseViewTypeArr(){
        
        if dashboardMenu != nil
        {
            for menuObj in dashboardMenu
            {
                if ((menuObj as AnyObject).object(forKey: "listingtype_id") != nil){
                    
                    var tempDictionary = Dictionary<String, Int>()
                    if let tempMenuObj = menuObj as? NSDictionary{
                        tempDictionary["viewType"] = tempMenuObj["viewProfileType"] as? Int
                        tempDictionary["browseType"] = tempMenuObj["viewBrowseType"] as? Int
                        tempDictionary["anotherViewBrowseType"] = tempMenuObj["anotherViewBrowseType"] as? Int
                        listingBrowseViewTypeArr[tempMenuObj["listingtype_id"] as! Int] = tempDictionary
                        
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showDashboardAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showDashboardAppTour") != nil {
                
                dashboardTargetCheckValue = name as! Int
                
                
            }
            
        }
        if dashboardTargetCheckValue == 1 {
            self.dashboardTableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
        }
        
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search",  comment: ""))
        //  searchBar.resignFirstResponder()
        sitevideoPluginEnabled_group = 0
        sitevideoPluginEnabled_event = 0
        sitevideoPluginEnabled_page = 0
        sitevideoPluginEnabled_store = 0
        sitevideoPluginEnabled_mlt = 0
        uploadMultiplePhoto = ""
        likeCommentContentType = ""
        likeCommentContent_id = ""
        Messag_Owner = false
        Messag_Url = ""
        Messag_OwnerId = -10
        self.navigationController?.setNavigationBarHidden(false, animated:false)
        self.tabBarController?.tabBar.isHidden = false
        setNavigationImage(controller: self)
        // let  defaults = UserDefaults.standard
        if let menu1 = defaults.object(forKey: "SaveMenu") {
            if let savedArray = NSKeyedUnarchiver.unarchiveObject(with: menu1 as! Data) {
                dashboardMenu = savedArray as! NSArray
                self.dashboardTableView.reloadData()
            }
        }
        
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        }
        
        
        if logoutUser == false{
            if displayName != nil {
                self.displayNameLabel.text = displayName
            }
            if coverImage != nil
            {
                if let url = URL(string: coverImage as String)
                {
                    
                    self.profileImageView.kf.indicatorType = .activity
                    (self.profileImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    self.profileImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        if let imageUser = image
                        {
                            coverPhotoImage = imageUser
                            let tempWidth = Double(self.profileImageView.bounds.width)
                            let ttheight = Double(self.profileImageView.bounds.height)
                            
                            let currentFilter = CIFilter(name: "CIGaussianBlur")
                            let beginImage = CIImage(image: imageUser)
                            currentFilter!.setValue(beginImage, forKey: kCIInputImageKey)
                            currentFilter!.setValue(10, forKey: kCIInputRadiusKey)
                            
                            let cropFilter = CIFilter(name: "CICrop")
                            cropFilter!.setValue(currentFilter!.outputImage, forKey: kCIInputImageKey)
                            cropFilter!.setValue(CIVector(cgRect: beginImage!.extent), forKey: "inputRectangle")
                            
                            let output = cropFilter!.outputImage
                            let cgimg = context1.createCGImage(output!, from: output!.extent)
                            processedImage = UIImage(cgImage: cgimg!)
                            if imageDashboardCover == nil
                            {
                                self.blurImageView.image = processedImage
                            }
                            self.profileImageView.image = cropToBounds(imageUser, width: tempWidth, height: ttheight)
                            imageProfile = self.profileImageView.image
                        }
                    })
                    
                }
            }
            if coverImageBackgorund != nil
            {
                if let url = URL(string: coverImageBackgorund as String)
                {
                    self.blurImageView.kf.indicatorType = .activity
                    (self.blurImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    self.blurImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
            }
        }
        else
        {
            let tempWidth = Double(self.profileImageView.bounds.width)
            let ttheight = Double(self.profileImageView.bounds.height)
            
            let img = UIImage(named: "logoutprofileIcon.png")
            self.profileImageView.image = cropToBounds(img!, width: tempWidth, height: ttheight)
            imageProfile = self.profileImageView.image
        }
        getDynamicDashboard()
        
        if logoutUser == true {
            dashboardTableView.tableFooterView = bottomTableView
        }else{
            dashboardTableView.tableFooterView = nil
        }
        
        
        
    }
    @objc func updateCoverImageView(userInfo: NSNotification)
    {
        if let contentInfo = userInfo.userInfo {
            if let coverImageDashboard = contentInfo["imageCover"] as? UIImage
            {
                imageDashboardCover = coverImageDashboard
                self.blurImageView.image = coverImageDashboard
            }
        }
        else
        {
            self.blurImageView.image = processedImage
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //  searchBar.resignFirstResponder()
        //  self.navigationController?.navigationBar.isTranslucent = true
    }
    
    // MARK: - Table Delegates
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    // Set Table Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if dashboardMenu != nil {
            return dashboardMenu.count
        }else{
            return 0
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        var dashboardInfo:NSDictionary
        dashboardInfo = dashboardMenu[(indexPath as NSIndexPath).row] as! NSDictionary
        
        for ob in cell.subviews{
            if ob.tag == 100 || ob.tag == 101 || ob.tag == 102 || ob.tag == 103 || ob.tag == 104 || ob.tag == 201 || ob.tag == 202{
                ob.removeFromSuperview()
            }
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        var FontIconLabelString = ""
        if (dashboardInfo["type"] as! String == "menu" ){
            cell.textLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
            if logoutUser == true
            {
                if (dashboardInfo["name"] as? NSString !=  nil)
                {
                    if dashboardInfo["name"] as! String != "signout"
                    {
                        if let name = dashboardInfo["name"] as? String
                        {
                            if name == "home"
                            {
                                FontIconLabelString = "\u{f015}"
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color1
                                }
                                buttonBackView.tag = 201
                                cell.addSubview(buttonBackView)
                                
                            }
                           else if name == "core_main_multicurrency"
                            {
                                FontIconLabelString = "\u{f0d6}"
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color1
                                }
                                buttonBackView.tag = 201
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_blog"{
                                FontIconLabelString = "\(blogIcon)"
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color1
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_group"{
                                FontIconLabelString = "\(groupIcon)"
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color2
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_sitegroup"{
                                FontIconLabelString = "\(groupIcon)"
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color2
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_music"{
                                FontIconLabelString = "\(musicIcon)"
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color6
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_classified"{
                                FontIconLabelString = "\(classifiedIcon)"
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color4
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_album"{
                                FontIconLabelString = "\(albumIcon)"
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color7
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_event"{
                                FontIconLabelString = "\(eventIcon)"
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color3
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_siteevent"{
                                FontIconLabelString = "\(eventIcon)"
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color3
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_user"{
                                FontIconLabelString = "\u{f007}"
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color6
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_video"{
                                FontIconLabelString = "\(videoIcon)"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color5
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_sitevideo"{
                                FontIconLabelString = "\(videoIcon)"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color5
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_sitevideochannel"{
                                FontIconLabelString = "\(channelIcon)"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color6
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_sitevideoplaylist"{
                                FontIconLabelString = "\(playlistIcon)"
                                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color7
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_forum"{
                                FontIconLabelString = "\u{f086}"
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.tag = 202
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color7
                                }
                                
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_poll"{
                                FontIconLabelString = "\u{f080}"
                                
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color1
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                                
                            else if name == "core_mini_messages"{
                                FontIconLabelString = "\u{f0e0}"
                                if (messageCount > 0){
                                    let messageCountString = String(messageCount)
                                    let optionMenu = createLabel(CGRect(x: cell.bounds.width - 50, y: 5, width: 20, height: cell.bounds.height - 10), text: messageCountString, alignment: .left, textColor: UIColor.red)
                                    optionMenu.tag = 101
                                    cell.addSubview(optionMenu)
                                }
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color3
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_mini_notification"
                            {
                                FontIconLabelString = "\u{f0f3}"
                                
                                var countTotal = 0
                                if (notificationCount > 0){
                                    countTotal = notificationCount
                                }
                                else{
                                    countTotal = 0
                                }
                                if (notificationCount > 0){
                                    let notificationCountString = String(countTotal)
                                    let optionMenu = createLabel(CGRect(x: cell.bounds.width - 50, y: 5, width: 20, height: cell.bounds.height - 10), text: notificationCountString, alignment: .left, textColor: UIColor.red)
                                    optionMenu.tag = 102
                                    cell.addSubview(optionMenu)
                                }
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color4
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_friends"{
                                FontIconLabelString = friendIcon
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.tag = 202
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color7
                                }
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "signup"{
                                FontIconLabelString = "\u{f015}"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color1
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "\(cometChatPackageName)"{
                                FontIconLabelString = "\u{f1d7}"
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color4
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "user_settings"{
                                FontIconLabelString = "\u{f013}"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color2
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "contact_us"{
                                FontIconLabelString = "\u{f095}"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color3
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_diaries"
                            {
                                FontIconLabelString = "\(diaryIcon)"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color5
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "user_settings_network"{
                                FontIconLabelString = "\u{f015}"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color5
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "user_settings_password"{
                                FontIconLabelString = "\u{f015}"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color5
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "terms_of_service"{
                                FontIconLabelString = "\u{f15c}"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color5
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "privacy_policy"{
                                FontIconLabelString = "\u{f023}"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color4
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "seaocore_location"{
                                FontIconLabelString = "\u{f041}"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color7
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_global_search"{
                                FontIconLabelString = "\u{f002}"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = UIColor(hex: "23aaff")
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "seaocore_location"{
                                FontIconLabelString = "\u{f041}"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color7
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "Setting"{
                                FontIconLabelString = "\u{f013}"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color5
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                                
                            else if name == "spread_the_word"{
                                FontIconLabelString = "\(spreadTheWordIcon)"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color2
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "signout"{
                                FontIconLabelString = "\u{f011}"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color4
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "sitereview_listing" {
                                FontIconLabelString = "\(listingDefaultIcon)"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color5
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                                
                            }
                            else if name == "core_main_wishlist"{
                                FontIconLabelString = "\(wishlistIcon)"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color1
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                                
                            }
                            else if name == "core_main_sitestoreproduct_orders"
                            {
                                FontIconLabelString = "\(myorderIcon)"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color2
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                            else if name == "core_main_sitepage"{
                                FontIconLabelString = "\(pageIcon)"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color5
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                                
                                
                            }else if name == "core_main_sitestore"{
                                FontIconLabelString = "\(storeCartIcon)"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color6
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }else if name  == "core_main_sitestoreoffer"{
                                FontIconLabelString = "\(creditCardIcon)"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color1
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }else if name == "core_main_sitestoreproduct"{
                                FontIconLabelString = "\(productIcon)"
                                cell.accessoryView?.isHidden = true
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color7
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                                
                            else if name == "core_main_rate"{
                                FontIconLabelString = "\(ratingIcon)"
                                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color3
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                                
                            else if name == "core_main_sitestoreproduct_cart"{
                                FontIconLabelString = "\(storeCartIcon)"
                                if (cartCount > 0){
                                    let cartCountString = String(cartCount)
                                    let optionMenu = createLabel(CGRect(x:cell.bounds.width - 50, y:5, width:20, height:cell.bounds.height - 10), text: cartCountString, alignment: .left, textColor: UIColor.red)
                                    optionMenu.tag = 104
                                    cell.addSubview(optionMenu)
                                }
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = color3
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                            }
                                
                                
                            else{
                                FontIconLabelString = "\(signOutIcon)"
                            }
                            
                            let labelString:String!
                            
                            if name == "seaocore_location"
                            {
                                let defaults = UserDefaults.standard
                                if let loc = defaults.string(forKey: "Location")
                                {
                                    if loc != ""
                                    {
                                        labelString =  loc
                                    }
                                    else
                                    {
                                        labelString =  dashboardInfo["label"] as? String
                                    }
                                    
                                }
                                else
                                {
                                    
                                    if defaultlocation != "" && defaultlocation != nil
                                    {
                                        labelString =  defaultlocation
                                    }
                                    else
                                    {
                                        labelString =  dashboardInfo["label"] as? String
                                    }
                                    
                                }
                            }
                            else
                            {
                                
                                labelString =  dashboardInfo["label"] as? String
                                
                            }
                            
                            if dashboardInfo["icon"] as! String != "" {
                                var linkIcon = dashboardInfo["icon"] as! String
                                linkIcon = linkIcon.trimString(linkIcon)
                                if linkIcon != ""{
                                    let unicodeIcon = Character(UnicodeScalar(UInt32(hexString: "\(linkIcon)")!)!)
                                    FontIconLabelString = "\(unicodeIcon)"
                                    let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                    buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                    buttonBackView.textAlignment = .center
                                    buttonBackView.layer.cornerRadius = 7.0
                                    buttonBackView.layer.masksToBounds = true
                                    buttonBackView.layer.borderWidth = 0.0
                                    if dashboardInfo["color"] as! String != "" {
                                        var check = dashboardInfo["color"] as! String
                                        let _ = check.remove(at: (check.startIndex))
                                        buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                    }
                                    else{
                                        buttonBackView.backgroundColor = UIColor.green
                                    }
                                    
                                    buttonBackView.tag = 201
                                    
                                    cell.addSubview(buttonBackView)
                                    
                                    
                                }
                                
                            }
                            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "")
                            attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome" , size: FONTSIZELarge + 2.0)!, range: NSMakeRange(0, attrString.length))
                            
                            let descString: NSMutableAttributedString = NSMutableAttributedString(string:  String("       \(labelString!)"))
                            descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                            
                            attrString.append(descString);
                            cell.textLabel?.attributedText = attrString
                            
                            cell.backgroundColor = tabbedDashboardBgColor
                            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                            
                        }
                        else
                        {
                            FontIconLabelString = "\u{f08b}"
                            
                            let labelString =  dashboardInfo["label"] as? String
                            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "")
                            attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge + 2.0)!, range: NSMakeRange(0, attrString.length))
                            
                            let descString: NSMutableAttributedString = NSMutableAttributedString(string:  String("       \(labelString!)"))
                            descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                            
                            attrString.append(descString);
                            cell.textLabel?.attributedText = attrString
                            cell.backgroundColor = textColorLight
                            
                        }
                        
                    }
                    cell.accessoryView?.isHidden = false
                    cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                    
                }
                else{
                    if dashboardInfo["icon"] as! String != "" {
                        let linkIcon = dashboardInfo["icon"] as! String
                        if linkIcon != ""{
                            if let intValue = UInt32(hexString: "\(linkIcon)") {
                                let unicodeIcon = Character(UnicodeScalar(intValue)!)
                                FontIconLabelString = "\(unicodeIcon)"
                            }
                            else {
                                FontIconLabelString = "\u{f15c}"
                            }
                           
                        }else{
                            FontIconLabelString = "\u{f15c}"
                        }
                        let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                        buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                        buttonBackView.textAlignment = .center
                        buttonBackView.layer.borderWidth = 0.0
                        buttonBackView.layer.cornerRadius = 7.0
                        buttonBackView.layer.masksToBounds = true
                        if dashboardInfo["color"] as! String != "" {
                            var check = dashboardInfo["color"] as! String
                            let _ = check.remove(at: (check.startIndex))
                            buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                        }
                        else{
                            buttonBackView.backgroundColor = color5
                        }
                        
                        buttonBackView.tag = 201
                        
                        cell.addSubview(buttonBackView)
                        
                        let labelString =  dashboardInfo["label"] as? String
                        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "")
                        attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome" , size: FONTSIZELarge + 2.0)!, range: NSMakeRange(0, attrString.length))
                        
                        let descString: NSMutableAttributedString = NSMutableAttributedString(string:  String("       \(labelString!)"))
                        descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                        
                        attrString.append(descString);
                        cell.textLabel?.attributedText = attrString
                        cell.backgroundColor = textColorLight
                        
                    }
                }
                
                
            }
            else
            {
                if (dashboardInfo["name"] as? NSString !=  nil)
                {
                    if let name = dashboardInfo["name"] as? String
                    {
                        if name == "home"
                        {
                            FontIconLabelString = "\u{f015}"
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color1
                            }
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                       else if name == "core_main_multicurrency"
                        {
                            FontIconLabelString = "\u{f0d6}"
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color1
                            }
                            buttonBackView.tag = 201
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_blog"{
                            FontIconLabelString = "\(blogIcon)"
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color1
                            }
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_group"{
                            FontIconLabelString = "\(groupIcon)"
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color2
                            }
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_sitegroup"{
                            FontIconLabelString = "\(groupIcon)"
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color2
                            }
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_music"{
                            FontIconLabelString = "\(musicIcon)"
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color6
                            }
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_classified"{
                            FontIconLabelString = "\(classifiedIcon)"
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color4
                            }
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "\(cometChatPackageName)"{
                            FontIconLabelString = "\u{f1d7}"
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color4
                            }
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_album"{
                            FontIconLabelString = "\(albumIcon)"
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color7
                            }
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_event"{
                            FontIconLabelString = "\(eventIcon)"
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color3
                            }
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_siteevent"{
                            FontIconLabelString = "\(eventIcon)"
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color3
                            }
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_user"{
                            FontIconLabelString = "\u{f007}"
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color6
                            }
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_video"{
                            FontIconLabelString = "\(videoIcon)"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color5
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_sitevideo"{
                            FontIconLabelString = "\(videoIcon)"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color5
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_sitevideochannel"{
                            FontIconLabelString = "\(channelIcon)"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color6
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_sitevideoplaylist"{
                            FontIconLabelString = "\(playlistIcon)"
                            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color7
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_forum"{
                            FontIconLabelString = "\u{f086}"
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.tag = 202
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color7
                            }
                            
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_poll"{
                            FontIconLabelString = "\u{f080}"
                            
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color1
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_mini_messages"{
                            FontIconLabelString = "\u{f0e0}"
                            if (messageCount > 0){
                                let messageCountString = String(messageCount)
                                let optionMenu = createLabel(CGRect(x: cell.bounds.width - 50, y: 5, width: 20, height: cell.bounds.height - 10), text: messageCountString, alignment: .left, textColor: UIColor.red)
                                optionMenu.tag = 101
                                cell.addSubview(optionMenu)
                            }
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color3
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_mini_notification"
                        {
                            FontIconLabelString = "\u{f0f3}"
                            
                            var countTotal = 0
                            if (notificationCount > 0){
                                countTotal = notificationCount
                            }
                            else{
                                countTotal = 0
                            }
                            if (notificationCount > 0){
                                let notificationCountString = String(countTotal)
                                let optionMenu = createLabel(CGRect(x: cell.bounds.width - 50, y: 5, width: 20, height: cell.bounds.height - 10), text: notificationCountString, alignment: .left, textColor: UIColor.red)
                                optionMenu.tag = 102
                                cell.addSubview(optionMenu)
                            }
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color4
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_friends"{
                            FontIconLabelString = friendIcon
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.tag = 202
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color7
                            }
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_mini_friend_request"{
                            FontIconLabelString = "\u{f1d8}"
                            if(friendRequestCount > 0){
                                let friendRequestCountString = String(friendRequestCount)
                                let optionMenu = createLabel(CGRect(x: cell.bounds.width - 50, y: 5, width: 25, height: cell.bounds.height - 10), text: friendRequestCountString, alignment: .left, textColor: UIColor.red)
                                optionMenu.tag = 103
                                cell.addSubview(optionMenu)
                            }
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color5
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "signup"{
                            FontIconLabelString = "\u{f015}"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color1
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "user_settings"{
                            FontIconLabelString = "\u{f013}"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color2
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "contact_us"{
                            FontIconLabelString = "\u{f095}"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color3
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_diaries"
                        {
                            FontIconLabelString = "\(diaryIcon)"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color5
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "user_settings_network"{
                            FontIconLabelString = "\u{f015}"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color5
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "user_settings_password"{
                            FontIconLabelString = "\u{f015}"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color5
                            }
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "terms_of_service"{
                            FontIconLabelString = "\u{f15c}"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color5
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "privacy_policy"{
                            FontIconLabelString = "\u{f023}"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color4
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "seaocore_location"{
                            FontIconLabelString = "\u{f041}"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color7
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "core_main_global_search"{
                            FontIconLabelString = "\u{f002}"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = UIColor(hex: "23aaff")
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "seaocore_location"{
                            FontIconLabelString = "\u{f041}"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color7
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "Setting"{
                            FontIconLabelString = "\u{f013}"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color5
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "spread_the_word"{
                            FontIconLabelString = "\(spreadTheWordIcon)"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color2
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "signout"{
                            FontIconLabelString = "\u{f011}"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color4
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        else if name == "sitereview_listing" {
                            FontIconLabelString = "\(listingDefaultIcon)"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color5
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                            
                        }
                        else if name == "core_main_wishlist"{
                            FontIconLabelString = "\(wishlistIcon)"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color1
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                            
                        }
                        else if name == "core_main_sitestoreproduct_orders"
                        {
                            FontIconLabelString = "\(myorderIcon)"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color2
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                            
                        else if name == "core_main_sitepage"{
                            FontIconLabelString = "\(pageIcon)"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color5
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                            
                            
                        }else if name == "core_main_sitestore"{
                            FontIconLabelString = "\(storeCartIcon)"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color6
                            }
                            if let action = dashboardInfo["canCreate"] as? NSDictionary
                            {
                                if let package = action["packagesEnabled"] as? Int
                                {
                                    storePackageEnabled = package
                                }
                                if let creation = action["default"] as? Int
                                {
                                    storeCreationEnabled = creation
                                }
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }else if name  == "core_main_sitestoreoffer"{
                            FontIconLabelString = "\(creditCardIcon)"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color1
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }else if name == "core_main_sitestoreproduct"{
                            FontIconLabelString = "\(productIcon)"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color7
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                            
                        else if name == "core_main_rate"{
                            FontIconLabelString = "\(ratingIcon)"
                            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color3
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                            
                        else if name == "core_main_sitestoreproduct_cart"{
                            FontIconLabelString = "\(storeCartIcon)"
                            if (cartCount > 0){
                                let cartCountString = String(cartCount)
                                let optionMenu = createLabel(CGRect(x:cell.bounds.width - 50, y:5, width:20, height:cell.bounds.height - 10), text: cartCountString, alignment: .left, textColor: UIColor.red)
                                optionMenu.tag = 104
                                cell.addSubview(optionMenu)
                            }
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color3
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                            
                            
                        else{
                            FontIconLabelString = "\u{f08b}"
                            cell.accessoryView?.isHidden = true
                            let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                            buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                            buttonBackView.textAlignment = .center
                            buttonBackView.layer.cornerRadius = 7.0
                            buttonBackView.layer.masksToBounds = true
                            
                            buttonBackView.layer.borderWidth = 0.0
                            if dashboardInfo["color"] as! String != "" {
                                var check = dashboardInfo["color"] as! String
                                let _ = check.remove(at: (check.startIndex))
                                buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                            }
                            else{
                                buttonBackView.backgroundColor = color7
                            }
                            
                            buttonBackView.tag = 201
                            
                            cell.addSubview(buttonBackView)
                            
                        }
                        
                        let labelString:String!
                        
                        if name == "seaocore_location"
                        {
                            let defaults = UserDefaults.standard
                            if let loc = defaults.string(forKey: "Location")
                            {
                                if loc != ""
                                {
                                    labelString =  loc
                                }
                                else
                                {
                                    labelString =  dashboardInfo["label"] as? String
                                }
                                
                            }
                            else
                            {
                                
                                if defaultlocation != "" && defaultlocation != nil
                                {
                                    labelString =  defaultlocation
                                }
                                else
                                {
                                    labelString =  dashboardInfo["label"] as? String
                                }
                                
                                
                            }
                        }
                        else if name == "core_main_multicurrency"
                        {
                            
                            
                            
                            let defaults = UserDefaults.standard
                            if let name = defaults.object(forKey: "Currency")
                            {
                                print("=== \(name)===")
                                if flagCheck == true {
                                    if  UserDefaults.standard.object(forKey: "CurrencyFlagCheck") != nil {
                                        let flagVar = defaults.object(forKey: "CurrencyFlagCheck")
                                        labelString = flagVar as? String
                                        
                                    }
                                    else{
                                        labelString =  dashboardInfo["label"] as? String
                                        
                                    }
                                }
                                else{
                                    if  UserDefaults.standard.object(forKey: "Currency") != nil {
                                        
                                        labelString = name as? String
                                        
                                    }
                                    else{
                                        let curr = dashboardInfo["currencyDetails"] as? NSDictionary
                                        labelString =  curr!["default"] as? String
                                        
                                    }
                                }
                                
                            }
                                
                                
                            else
                            {
                                
                                let curr = dashboardInfo["currencyDetails"] as? NSDictionary
                                labelString =  curr!["default"] as? String
                                
                                
                                
                            }
                        }
                        else
                        {
                            
                            labelString =  dashboardInfo["label"] as? String
                            
                        }
                        
                        if dashboardInfo["icon"] as! String != "" {
                            var linkIcon = dashboardInfo["icon"] as! String
                            linkIcon = linkIcon.trimString(linkIcon)
                            if linkIcon != ""{
                                let unicodeIcon = Character(UnicodeScalar(UInt32(hexString: "\(linkIcon)")!)!)
                                FontIconLabelString = "\(unicodeIcon)"
                                
                                let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                                buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                                buttonBackView.textAlignment = .center
                                buttonBackView.layer.cornerRadius = 7.0
                                buttonBackView.layer.masksToBounds = true
                                
                                buttonBackView.layer.borderWidth = 0.0
                                if dashboardInfo["color"] as! String != "" {
                                    var check = dashboardInfo["color"] as! String
                                    let _ = check.remove(at: (check.startIndex))
                                    buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                                }
                                else{
                                    buttonBackView.backgroundColor = UIColor.green
                                }
                                
                                buttonBackView.tag = 201
                                
                                cell.addSubview(buttonBackView)
                                
                                
                            }
                            
                        }
                        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "")
                        attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome" , size: FONTSIZELarge + 2.0)!, range: NSMakeRange(0, attrString.length))
                        
                        var descString : NSMutableAttributedString!
                        if let label = labelString{
                            descString = NSMutableAttributedString(string:  String("       \(label)"))
                        } else{
                            descString = NSMutableAttributedString(string:  String("       label"))
                        }
                        
                        descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                        attrString.append(descString);
                        cell.textLabel?.attributedText = attrString
                        cell.textLabel?.textColor = UIColor(red: 51/255 , green: 51/255 , blue: 51/255, alpha: 1.0)//UIColor.black
                        cell.backgroundColor = tabbedDashboardBgColor
                    }
                    
                    cell.accessoryView?.isHidden = false
                    cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                    
                    
                    
                }
                else{
                    if dashboardInfo["icon"] as! String != "" {
                        let linkIcon = dashboardInfo["icon"] as! String
                        if linkIcon != ""{
                            if let hex = UInt32(hexString: "\(linkIcon)") {
                               let unicodeIcon = Character(UnicodeScalar(hex)!)
                                FontIconLabelString = "\(unicodeIcon)"
                            }
                            else {
                                FontIconLabelString = "\u{f15c}"
                            }

                        }else{
                            FontIconLabelString = "\u{f15c}"
                        }
                        
                        let buttonBackView = createLabel(CGRect(x: 10, y: 10 , width: 25,height: 25), text: "\(FontIconLabelString)", alignment: .left, textColor: textColorLight)
                        buttonBackView.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium + 3.0)
                        buttonBackView.textAlignment = .center
                        buttonBackView.layer.cornerRadius = 7.0
                        buttonBackView.layer.masksToBounds = true
                        
                        buttonBackView.layer.borderWidth = 0.0
                        if dashboardInfo["color"] as! String != "" {
                            var check = dashboardInfo["color"] as! String
                            let _ = check.remove(at: (check.startIndex))
                            buttonBackView.backgroundColor = UIColor(hex: "\(check)")
                        }
                        else{
                            buttonBackView.backgroundColor = color5
                        }
                        
                        buttonBackView.tag = 201
                        
                        cell.addSubview(buttonBackView)
                        
                        
                        
                        cell.accessoryView?.isHidden = true
                        
                    }
                    
                    let labelString =  dashboardInfo["label"] as? String
                    let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "")
                    attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome" , size: FONTSIZELarge + 2.0)!, range: NSMakeRange(0, attrString.length))
                    
                    var descString : NSMutableAttributedString!
                    if let label = labelString{
                        descString = NSMutableAttributedString(string:  String("       \(label)"))
                    } else{
                        descString = NSMutableAttributedString(string:  String("       label"))
                    }
                    
                    descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                    
                    attrString.append(descString);
                    cell.textLabel?.attributedText = attrString
                    cell.textLabel?.textColor = UIColor(red: 51/255 , green: 51/255 , blue: 51/255, alpha: 1.0)//UIColor.black
                    cell.backgroundColor = tabbedDashboardBgColor
                }
                
                
                
            }
            
            cell.accessoryView?.isHidden = false
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            
        }else{
            cell.textLabel?.text = dashboardInfo["label"] as? String
            cell.textLabel?.textColor = UIColor(red: 51/255 , green: 51/255 , blue: 51/255, alpha: 1.0)//UIColor.black
            cell.backgroundColor = UIColor(red: 235/255 , green: 235/255 , blue: 235/255, alpha: 1.0)//UIColor.red//aafBgColor
            cell.textLabel?.font = UIFont(name: fontBold, size: 14 )
            cell.accessoryView?.isHidden = true
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: cell.bounds.size.width);
            
            cell.accessoryView?.isHidden = true
            cell.accessoryType = UITableViewCell.AccessoryType.none
            
        }
        
        return cell
        
    }
    
    // Section of Row in TableView
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect Selected Row
        tableView.deselectRow(at: indexPath, animated: true)
        var dashboardInfo:NSDictionary
        dashboardInfo = dashboardMenu[(indexPath as NSIndexPath).row] as! NSDictionary
        sitereviewMenuDictionary = dashboardInfo
        if ((dashboardInfo["url"] as? String != nil) && (dashboardInfo["url"] as? String != "")){
            let presentedVC = ExternalWebViewController()
            presentedVC.url = dashboardInfo["url"] as! String
            presentedVC.siteTitle = dashboardInfo["headerLabel"] as! String
            presentedVC.fromDashboard = true
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
        else
        {
            if let name = dashboardInfo["name"] as? String {
                self.redirectNavigation(name, id : (indexPath as NSIndexPath).row)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)){
            cell.separatorInset = UIEdgeInsets.zero
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)){
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    // Redirect From Dashboard
    func redirectNavigation(_ name:String,id: Int)
    {
        print("name--\(name)")
        //dashboardTableView.reloadData()
        var presentedVC : UIViewController!
        if name == "home"
        {
            tabBarController?.selectedIndex = 0
            //            presentedVC = AdvanceActivityFeedViewController()
            //            if logoutUser == true
            //            {
            //              feedArray.removeAll()
            //            }
        }
        else {
            if name == "core_main_multicurrency"{
                
                presentedVC = CurrencyViewController()
            }
            
            if name == "core_main_blog"{
                
                BlogObject().redirectToBlogBrowsePage(self, showOnlyMyContent: false)
                return
            }
            if name == "core_main_group"{
                GroupObject().redirectToBrowsePage(self, showOnlyMyContent: false)
                return
            }
            if name == "core_main_sitegroup"{
                SiteAdvGroupObject().redirectToAdvGroupBrowsePage(self, showOnlyMyContent: false)
                return
                
            }
            if name == "core_main_music"{
                MusicObject().redirectToMusicBrowsePage(self, showOnlyMyContent: false )
                return
            }
            if name == "core_main_classified"{
                listingNameToShow = sitereviewMenuDictionary["headerLabel"] as! String
                ClassifiedObject().redirectToClassifiedBrowsePage(self,showOnlyMyContent: false)
                return
            }
            if name == "core_main_album"{
                presentedVC = AlbumViewController()
                catKey = ""
                sortKey = ""
                (presentedVC as! AlbumViewController).showOnlyMyContent = false
            }
            if name == "core_main_event"{
                EventObject().redirectToEventBrowsePage(self, showOnlyMyContent: false)
                return
            }
            //hardcode value redirect to advancedevent
            if name == "core_main_user"
            {
                presentedVC = MemberViewController()
                (presentedVC as! MemberViewController).contentType = "members"
                var dashboardInfo:NSDictionary
                dashboardInfo = dashboardMenu[id] as! NSDictionary
                
                if let id : Int = dashboardInfo["memberViewType"] as? Int{
                    
                    (presentedVC as! MemberViewController).mapormember = id
                }
            }
            if name == "core_main_video"{
                VideoObject().redirectToVideoBrowsePage(self, showOnlyMyContent: false)
                return
                
            }
            else if name == "core_main_sitevideo"{
                SitevideoObject().redirectToAdvVideoBrowsePage(self, showOnlyMyContent: false)
                return
                
            }
            else if name == "core_main_sitevideochannel"{
                SitevideoObject().redirectToChannelBrowsePage(self, showOnlyMyContent: false)
                return
                //presentedVC = ChannelProfileViewController()
            }
            else if name == "core_main_sitevideoplaylist"{
                SitevideoObject().redirectToPlaylistBrowsePage(self, showOnlyMyContent: false)
                return
            }
            if name == "core_main_forum"{
                presentedVC = ForumHomePageController()
            }
            if name == "core_main_siteevent"
            {
                AdvanceEventObject().redirectToAdvanceEventBrowsePage(self, showOnlyMyContent: false)
                return
            }
            
            if name == "core_main_poll"{
                
                PollObject().redirectToPollBrowsePage(self, showOnlyMyContent: false)
                return
                
            }
            if name == "core_mini_messages"{
                if isChannelizeAvailable {
                    if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                        let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                        if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                            channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: nil)
                        }
                    }
                    return
                } else{
                    presentedVC = MessageViewController()
                    (presentedVC as! MessageViewController).showOnlyMyContent = false
                }
            }
            if name == "core_mini_notification"{
                notificationCount = 0
                presentedVC = NotificationViewController()
                (presentedVC as! NotificationViewController).showOnlyMyContent = false
            }
            if name == "core_mini_friend_request"{
                presentedVC = FriendRequestViewController()
                (presentedVC as! FriendRequestViewController).contentType = "friendmembers"
            }
            if name == "core_main_friends"{
                presentedVC = SuggestionsBrowseViewController()
                (presentedVC as! SuggestionsBrowseViewController).activeTableView = 5
            }
            if name == "core_main_cometchat"{
                openCometChat()
                return;
            }
            if name == "signup"{
                fbFirstName = ""
                fbLastName = ""
                fbEmail = ""
                appleFirstName = ""
                appleLastName = ""
                appleEmail = ""
                apple_id = ""
                presentedVC = SignupViewController()
            }
            if name == "user_settings"{
                presentedVC = SettingsViewController()
            }
//            if name == "core_main_app_tour"{
//                UserDefaults.standard.set(1, forKey: "showHomePageAppTour")
//                UserDefaults.standard.set(1, forKey: "showDashboardAppTour")
//                UserDefaults.standard.set(1, forKey: "showPluginAppTour")
//                UserDefaults.standard.set(1, forKey: "showUserProfilePageAppTour")
//                UserDefaults.standard.set(1, forKey: "showOtherUserProfilePageAppTour")
//                UserDefaults.standard.set(1, forKey: "showMessageAppTour")
//                UserDefaults.standard.set(1, forKey: "showAlbumAppTour")
//                UserDefaults.standard.set(1, forKey: "showSearchPluginAppTour")
//                UserDefaults.standard.set(1, forKey: "showMemberSearchPluginAppTour")
//                UserDefaults.standard.set(1, forKey: "showTogglePluginAppTour")
//                UserDefaults.standard.set(1, forKey: "showSeeAllPluginAppTour")
//
//
//                presentedVC = AdvanceActivityFeedViewController()
//
//            }
            
            if name == "contact_us"{
                presentedVC = ContactViewController()
            }
            if name == "user_settings_network"{
                presentedVC = EditProfileViewController()
            }
            if name == "user_settings_password"{
                presentedVC = EditProfilePhotoViewController()
            }
            if name == "terms_of_service"{
                presentedVC = TermsViewController()
            }
            if name == "privacy_policy"{
                presentedVC = PrivacyViewController()
            }
            if name == "core_main_global_search"{
                presentedVC = CoreAdvancedSearchViewController()
                searchDic.removeAll(keepingCapacity: false)
                
                // Increase MenuRefresh Counter
                menuRefreshConter += 1
                if(menuRefreshConter > Int(menuRefreshConterLimit)){
                    menuRefreshConter = 0
                    
                }
                
                dashboardTableView.reloadData()
                self.navigationController?.pushViewController(presentedVC, animated: false)
                return
            }
            else if name == "seaocore_location"{
                
                if Locationdic != nil
                {
                    if let locType = Locationdic["locationType"] as? String
                    {
                        if locType == "notspecific"
                        {
                            presentedVC = BrowseLocationViewController()
                        }
                        else
                        {
                            presentedVC = BrowseSpecificLocationViewController()
                            
                        }
                    }
                }
                
            }
            if name == "Setting"{
                presentedVC = SettingsViewController()
            }
            if name == "core_main_app_tour"{
                UserDefaults.standard.set(1, forKey: "showHomePageAppTour")
                UserDefaults.standard.set(1, forKey: "showDashboardAppTour")
                UserDefaults.standard.set(1, forKey: "showPluginAppTour")
                UserDefaults.standard.set(1, forKey: "showUserProfilePageAppTour")
                UserDefaults.standard.set(1, forKey: "showOtherUserProfilePageAppTour")
                UserDefaults.standard.set(1, forKey: "showMessageAppTour")
                UserDefaults.standard.set(1, forKey: "showAlbumAppTour")
                UserDefaults.standard.set(1, forKey: "showSearchPluginAppTour")
                UserDefaults.standard.set(1, forKey: "showMemberSearchPluginAppTour")
                UserDefaults.standard.set(1, forKey: "showTogglePluginAppTour")
                UserDefaults.standard.set(1, forKey: "showSeeAllPluginAppTour")
                
                
                
                presentedVC = AdvanceActivityFeedViewController()
                
            }
            if name == "signout"{
                if Reachabable.isConnectedToNetwork() {
                    let alertController = UIAlertController(title: nil, message: NSLocalizedString("Are you sure you want to logout?", comment: "") , preferredStyle: UIAlertController.Style.actionSheet)
                    
                    var dashboardInfo:NSDictionary
                    dashboardInfo = dashboardMenu[id] as! NSDictionary
                    
                    var headingTitle = "Logout"
                    if let headingLabelTitle = dashboardInfo["label"]as? String {
                        headingTitle = headingLabelTitle
                    }
                    
                    alertController.addAction(UIAlertAction(title: "\(headingTitle)", style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                        let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                        if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                            channelizeClass.performChannelizeLogout()
                            channelizeClass.perfromRealmObjectsDeletion()
                        }
                        if((AccessToken.current) != nil){
                            let loginManager = LoginManager()
                            loginManager.logOut()
                        }
                        auth_user = false
                        post(["device_uuid":device_uuid,"device_token":device_token_id,"oauth_consumer_secret":"\(oauth_consumer_secret)"], url: "logout", method: "POST") {
                            (succeeded, msg) -> () in
                            //                        DispatchQueue.main.async(execute: {
                            //                            activityIndicatorView.stopAnimating()
                            //                        })
                        }
                        deleteAAFEntries()
                        self.checkLiveTimeSetting1()
                        menuRefreshConter = 0
                        let defaults = UserDefaults.standard
                        defaults.set("", forKey: "Location")
                        defaults.setValue("", forKey: "rating")
                        defaults.setValue("", forKey: "key")
                        defaults.setValue("", forKey: "userEmail")
                        defaults.setValue("", forKey: "userPassword")
                        
                        
                        let userDefaults = UserDefaults(suiteName: "\(shareGroupname)")
                        userDefaults!.set("", forKey: "oauth_token")
                        userDefaults!.set("", forKey: "oauth_secret")
                        userDefaults!.set("", forKey: "ios_version")
                        userDefaults!.set("", forKey: "baseUrl")
                        userDefaults!.set("", forKey: "oauth_consumer_secret")
                        userDefaults!.set("", forKey: "oauth_consumer_key")
                        
                        
                        
                        greetingsArray.removeAll()
                        usersBirthday.removeAll()
                        UserDefaults.standard.removeObject(forKey: "SellSomething")
                        
                        removeGreetingsId.removeAll()
                        removeBirthdayId.removeAll()
                        
                        //                    userImageCaches.removeAll()
                        
                        if showAppSlideShow == 1 {
                            UserDefaults.standard.removeObject(forKey: "SaveMenu")
                        }
                        
                        UserDefaults.standard.removeObject(forKey: "Currency")
                        UserDefaults.standard.removeObject(forKey: "PriceRate")
                        UserDefaults.standard.removeObject(forKey: "CurrencyFlagCheck")
                        UserDefaults.standard.removeObject(forKey: "isAppRated")
                        UserDefaults.standard.removeObject(forKey: "showBlogContent")
                        UserDefaults.standard.removeObject(forKey: "showGroupContent")
                        UserDefaults.standard.removeObject(forKey: "showEventContent")
                        UserDefaults.standard.removeObject(forKey: "showClassifiedContent")
                        UserDefaults.standard.removeObject(forKey: "showVideoContent")
                        UserDefaults.standard.removeObject(forKey: "showPollContent")
                        UserDefaults.standard.removeObject(forKey: "showPageContent")
                        UserDefaults.standard.removeObject(forKey: "showMusicContent")
                        UserDefaults.standard.removeObject(forKey: "showMemberContent")
                        UserDefaults.standard.removeObject(forKey: "showAlbumContent")
                        UserDefaults.standard.removeObject(forKey: "showFriendContent")
                        UserDefaults.standard.removeObject(forKey: "showAdvGroupContent")
                        UserDefaults.standard.removeObject(forKey: "showAdvEventContent")
                        UserDefaults.standard.removeObject(forKey: "showOfferContent")
                        UserDefaults.standard.removeObject(forKey: "showProductContent")
                        UserDefaults.standard.removeObject(forKey: "showStoreContent")
                        
                        UserDefaults.standard.removeObject(forKey: "showMyListingContent")
                        UserDefaults.standard.removeObject(forKey: "showlistingName")
                        UserDefaults.standard.removeObject(forKey: "showlistingId")
                        UserDefaults.standard.removeObject(forKey: "showlistingviewType")
                        UserDefaults.standard.removeObject(forKey: "showlistingBrowseType")
                        
                        UserDefaults.standard.removeObject(forKey: "showMyListingContent1")
                        UserDefaults.standard.removeObject(forKey: "showlistingName1")
                        UserDefaults.standard.removeObject(forKey: "showlistingId1")
                        UserDefaults.standard.removeObject(forKey: "showlistingviewType1")
                        UserDefaults.standard.removeObject(forKey: "showlistingBrowseType1")
                        
                        UserDefaults.standard.removeObject(forKey: "showMyListingContent2")
                        UserDefaults.standard.removeObject(forKey: "showlistingName2")
                        UserDefaults.standard.removeObject(forKey: "showlistingId2")
                        UserDefaults.standard.removeObject(forKey: "showlistingviewType2")
                        UserDefaults.standard.removeObject(forKey: "showlistingBrowseType2")
                        UserDefaults.standard.removeObject(forKey: "eventids")
                        
                        UserDefaults.standard.removeObject(forKey: "SavedbirthdayArray")
                        UserDefaults.standard.removeObject(forKey: "SavedGreetingsArray")
                        
                        
                        
                        defaultlocation = ""
                        defaults.set(defaultlocation, forKey: "Location")
                        logoutUser = true
                        refreshMenu = true
                        enableSuggestion = true
                        
                        UserDefaults.standard.removeObject(forKey: "storiesBrowseData")
                        imageProfile = nil
                        imageDashboardCover = nil
                        processedImage = nil
                        coverPhotoImage = nil
                        
                        let request: NSFetchRequest<UserInfo>
                        
                        if #available(iOS 10.0, *){
                            request = UserInfo.fetchRequest() as! NSFetchRequest<UserInfo>
                        }else{
                            request = NSFetchRequest(entityName: "UserInfo")
                        }
                        
                        
                        request.returnsObjectsAsFaults = false
                        let results = try? context.fetch(request)
                        if(results?.count>0){
                            for result: AnyObject in results! {
                                if let _ = result.value(forKey: "oauth_token") as? String{
                                    context.delete(result as! NSManagedObject)
                                }
                            }
                            do {
                                try context.save()
                            } catch _ {
                            }
                        }
                        
                        let request1: NSFetchRequest<ActivityFeedData>
                        
                        if #available(iOS 10.0, *){
                            request1 = ActivityFeedData.fetchRequest() as! NSFetchRequest<UserInfo> as! NSFetchRequest<ActivityFeedData>
                        }else{
                            request1 = NSFetchRequest(entityName: "ActivityFeedData")
                        }
                        
                        request1.returnsObjectsAsFaults = false
                        let results1 = try? context.fetch(request1)
                        if(results1?.count>0){
                            // If exist than Delete all entries
                            for result: AnyObject in results1! {
                                context.delete(result as! NSManagedObject)
                            }
                            do {
                                try context.save()
                            } catch _ {
                            }
                        }
                        //  self.dashboardTableView.setContentOffset(CGPoint.zero, animated:true)
                        
                        
                        let  defaults1 = UserDefaults.standard
                        let menu = defaults1.object(forKey: "SaveMenu")
                        if menu != nil && refreshMenu == false{
                            
                            let  defaults = UserDefaults.standard
                            let menu = defaults.object(forKey: "SaveMenu")
                            let savedArray = NSKeyedUnarchiver.unarchiveObject(with: menu as! Data)
                            dashboardMenu = savedArray as! NSArray
                            updateUserData()
                            self.dashboardTableView.reloadData()
                            
                        }
                        else
                        {
                            self.dashboardTableView.tableFooterView = self.bottomTableView
                            self.getDynamicDashboard()
                        }
                        
                        //self.parent?.navigationController?.popToRootViewController(animated: true)
                        isLogin = false
                         apple_id = ""
                        if showAppSlideShow == 1 {
                            self.navigationController?.pushViewController(SlideShowLoginScreenViewController(), animated: false)
                        }
                        else{
                            self.navigationController?.pushViewController(LoginScreenViewController(), animated: false)
                        }
                        
                        
                    }))
                    
                    if  (!isIpad()){
                        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
                    }else if  (UIDevice.current.userInterfaceIdiom == .pad){
                        // Present Alert as! Popover for iPad
                        alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                        alertController.popoverPresentationController?.sourceView = view
                        alertController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width/2 , y: view.bounds.height/2, width: 0, height: 0)
                        alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection()
                    }
                    self.present(alertController, animated:true, completion: nil)
                    
                    return
                }
                else{
                    showToast(message: network_status_msg, controller: self)
                    return
                }
            }
            if name == "signin"{
                if showAppSlideShow == 1 {
                    presentedVC = SlideShowLoginScreenViewController()
                    (presentedVC as! SlideShowLoginScreenViewController).fromDashboard = true
                    
                }
                else{
                    presentedVC = LoginScreenViewController()
                    (presentedVC as! LoginScreenViewController).fromDashboard = true
                }
            }
            
            if name == "facebook"{
            }
            
            //For multiple listings
            
            if name == "sitereview_listing" {
                showGoogleMapView = false
                mltToggleView = false
                listingNameToShow = sitereviewMenuDictionary["headerLabel"] as! String
                sitereviewMenuDictionary = dashboardMenu[id] as! NSDictionary
                
                let browseType = sitereviewMenuDictionary["viewBrowseType"] as! Int
                let viewType = sitereviewMenuDictionary["viewProfileType"] as! Int
                
                if MLTbrowseOrMyListings == nil{
                    MLTbrowseOrMyListings = true
                }
                SiteMltObject().redirectToMltBrowsePage(self, showOnlyMyContent: false, listingTypeIdValue : sitereviewMenuDictionary["listingtype_id"] as! Int , listingNameValue : sitereviewMenuDictionary["headerLabel"] as! String , MLTbrowseorMyListingsValue : MLTbrowseOrMyListings! , browseTypeValue : browseType , viewTypeValue : viewType,dashboardMenuDic : sitereviewMenuDictionary)
                return
                

            }
            
            if name == "core_main_wishlist"
            {
                presentedVC = WishlistBrowseViewController()
                iscomingfrom = "\(name)"
                (presentedVC as! WishlistBrowseViewController).wishlistType = "other"
                if let dic = sitereviewMenuDictionary["canCreate"] as? NSDictionary
                {
                    let sitestore = dic["sitestore"] as! Int
                    let sitereview = dic["sitereview"] as! Int
                    if sitestore == 1 && sitereview==1
                    {
                        (presentedVC as! WishlistBrowseViewController).wishlistType = "both"
                    }
                    else if sitestore == 1 && sitereview == 0
                    {
                        (presentedVC as! WishlistBrowseViewController).wishlistType = "product"
                    }
                    
                }
                
                (presentedVC as! WishlistBrowseViewController).showOnlyMyContent = false
            }
            if name == "core_main_diaries"
            {
                
                presentedVC = WishlistBrowseViewController()
                iscomingfrom = "\(name)"
                (presentedVC as! WishlistBrowseViewController).wishlistType = "diary"
                (presentedVC as! WishlistBrowseViewController).showOnlyMyContent = false
            }
            if name == "core_main_sitestoreproduct_orders"
            {
                SiteStoreObject().redirectToMyStore(viewController: self)
                iscomingfrom = "sidemenu"
                return
            }
            
            //CONDITION FOR SPREAD THE WORD FEATURE
            if(name == "spread_the_word"){
                var dashboardInfo:NSDictionary
                dashboardInfo = dashboardMenu[id] as! NSDictionary
                presentedVC = SpreadTheWordViewController()
                var headingTitle = ""
                if let headingLabelTitle = dashboardInfo["headerLabel"]as? String {
                    headingTitle = headingLabelTitle
                }
                
                (presentedVC as! SpreadTheWordViewController).viewTitle = headingTitle
                
            }
            
            if name == "core_main_sitepage"{
                SitePageObject().redirectToPageBrowsePage(self, showOnlyMyContent: false)
                return
            }
            
            if name == "core_main_sitestore"{
                SiteStoreObject().redirectToStoresBrowse(viewController: self, showOnlyMyContent: false)
                return
            }
            
            if name == "core_main_sitestoreoffer"{
                SiteStoreObject().redirectToCouponsBrowse(viewController: self, showOnlyMyContent: false, fromStore: false, storeId: 0)
                return
            }
            
            if name == "core_main_sitestoreproduct"{
                SiteStoreObject().redirectToProductsViewPage(viewController: self, showOnlyMyContent: false)
                return
            }
            
            if name == "core_main_rate"
            {
                requestReview()
                return
            }
            
            if name == "core_main_sitestoreproduct_cart"
            {
                SiteStoreObject().redirectToManageCart(viewController: self)
                return
            }
            
            searchDic.removeAll(keepingCapacity: false)
            
            // Increase MenuRefresh Counter
            menuRefreshConter += 1
            if(menuRefreshConter > Int(menuRefreshConterLimit)){
                menuRefreshConter = 0
                
            }
            
            dashboardTableView.reloadData()
            //  //print(self.navigationController?.viewControllers)
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
        
    }
    func checkLiveTimeSetting1(){
        let url1 = "get-settings"
        
        let dic = [String : String]()
        
        let method1 = "GET"
        
        post(dic , url: "\(url1)", method: method1) { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                
                if msg{
                    
                    if let body = succeeded["body"] as? NSDictionary{
                       
                        if let setting = body["sitequicksignup"] as? NSDictionary{
                            signUplayoutType = (setting["isQuickSignUp"] as! Bool)
                        }
                    }
                    
                    
                }
                    
                else{
                    // Handle Server Side Error
                    if succeeded["message"] != nil{
                         print("error =====")
                       // self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                    }
                }
            })
        }
    }
    
    func requestReview ()
    {
        var appId: Int {
            get {
                return UserDefaults.standard.integer(forKey: "appItunesId")
            }
        }
        
        if appId != 0
        {
            let mainId = String(appId)
            let appURLString: String
            appURLString = "itms-apps://itunes.apple.com/app/id\(mainId)?mt=8&action=write-review"
            UIApplication.shared.openURL(URL(string: appURLString)!)
        }
        //AdvanceActivityFeedViewController().rateApp()
        //ConfigurationFormViewController().rateApp()
    }
    
    // MARK: - Signin and Signup action
    
    @objc func signin(){
        if showAppSlideShow == 1 {
            let presentedVC  = SlideShowLoginScreenViewController()
            presentedVC.fromDashboard = true
            self.navigationController?.pushViewController(presentedVC, animated: false)
            
        }
        else{
            
            let presentedVC = LoginScreenViewController()
            presentedVC.fromDashboard = true
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    @objc func signup(){
        let presentedVC = SignupViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    // MARK: - Webview operations
    
    func openExternalLinks(_ url : String){
        let presentedVC = ExternalWebViewController()
        presentedVC.url = url as String
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navigationController = UINavigationController(rootViewController: presentedVC)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - Facebook Delegates
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton!) {
    }
    
    func returnUserData(){
        var fbAccessTokenn : String!
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    
                    let tempResultData:[String:AnyObject] = result as! [String : AnyObject]
                    
                    let id = tempResultData["id"] as! String
                    if tempResultData["email"] != nil {
                        fbEmail = tempResultData["email"] as! String
                    }else{
                        fbEmail = ""
                    }
                    
                    fbAccessTokenn = AccessToken.current?.tokenString
                    
                    // Check Internet Connection
                    if Reachabable.isConnectedToNetwork() {
                        //                        spinner.hidesWhenStopped = true
                        //                        spinner.style = UIstyle.white
                        //                        self.view.addSubview(spinner)
                        //                        activityIndicatorView.startAnimating()
                        
                        // Send Server Request for Sign In
                        
                        var loginParams = ["facebook_uid":"\(id)", "code":"%2520", "access_token":"\(fbAccessTokenn)", "ip":"127.0.0.1"]
                        if device_uuid != nil{
                            loginParams.updateValue(device_uuid, forKey: "device_uuid")
                        }
                        if device_token_id != nil{
                            loginParams.updateValue(device_token_id, forKey: "device_token")
                        }
                        post(loginParams, url: "login", method: "POST") { (succeeded, msg) -> () in
                            
                            DispatchQueue.main.async(execute: {
                                //                               activityIndicatorView.stopAnimating()
                                // On Success save authentication_token in Core Data
                                if(msg)
                                {
                                    // Get Data From Core Data
                                    if succeeded["message"] != nil{
                                        showToast(message: succeeded["message"] as! String, controller: self)
                                    }
                                    if succeeded["body"] != nil{
                                        if let body = succeeded["body"] as? NSDictionary{
                                            if var _ = body["oauth_token"] as? String
                                            {
                                                // Perform Login Action
                                                if performLoginActionSuccessfully(succeeded["body"] as! NSDictionary){
                                                    DispatchQueue.main.async(execute: {
                                                        mergeAddToCart()
                                                        self.showHomePage()
                                                    })
                                                }else{
                                                    showToast(message: NSLocalizedString("Unable to Login",comment: ""), controller: self)
                                                }
                                            }
                                            else
                                            {
                                                // Signup Condition
                                                let pv = SignupViewController()
                                                pv.tempDic = body
                                                facebook_uid = id
                                                code = "null"
                                                access_token = fbAccessTokenn
                                                self.navigationController?.pushViewController(pv, animated: false)
                                                
                                            }
                                        }
                                    }
                                }
                                else{
                                    // Handle Server Side Error Massages
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
                
            })
            
        }
        
    }
    
    /*!
     @abstract Sent to the delegate when the button was used to login.
     @param loginButton the sender
     @param result The results of the login
     @param error The error (if any) from the login
     */
    public func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {
        if(error == nil)
        {
            self.returnUserData()
        }
        else
        {
            //print(error.localizedDescription)
        }
    }
    
    @objc func openProfile(){
        
        if (logoutUser == false && currentUserId != 0){
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.strProfileImageUrl = coverImage
            presentedVC.strUserName = displayName
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(currentUserId)"
            presentedVC.fromDashboard =  true
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    func showHomePage () {
        menuRefreshConter = 0
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = true
            
        }
        createTabs()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.pushViewController(baseController, animated: false)
        self.view.endEditing(true)
        
    }

}

