
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

//  AdvanceActivityFeedViewController.swift
protocol scrollDelegate{
    func didScroll()
    
}

public protocol LiveStreamingObjectDelegates {
    static func redirectToLivePage(_ viewController : UIViewController, isBroadcaster : Bool , chName : String)
    static func redirectToPreview(_ viewController : UIViewController)
    static func redirectToLivePageFromNotification(_ viewController : UIViewController, isBroadcaster : Bool , chName : String , videoId : Int , videoType : String)
}

import CoreLocation
//import GoogleMobileAds
import FBAudienceNetwork
import UIKit
import CoreData
import AVFoundation
import NVActivityIndicatorView
import Kingfisher
import Instructions

var fromEditProfilePage : Bool = false
import WebKit
var timeLimit  = 0
var enableLiveStreaming : Bool = false
var comingFromPlaylist : Bool = false
var sidValue = ""
var feedFilterAsGuest : NSArray = []
// Advance video common tableview Y frmae
var tableframeY : CGFloat = 0.0
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
var feedPostMenu:Bool = true
var feedUpdate:Bool!
var contentfeedArrUpdate:Bool = false // For assigning updated userfeedarray to table in case of comments and activityphotoviewcontroller
var feedArrayTikTok = [AnyObject]()
var subjectIdTikTok = ""
var subjectTypeTikTok = ""
var feedArray = [AnyObject]()
var feedArrayTemp = [AnyObject]()
var contentFeedArray = [AnyObject]()
var userFeedArray = [AnyObject]()
var postPermission = NSDictionary()
// Timer for Update feed after particular time repeation
var checkMiniMenuTimer:Timer!
var coverPhotoImage : UIImage!
var addSeeMore:Bool  = false
//var globalImageCache = [String:UIImage]()
var afterPost :Bool = false
var ReactionPlugin : Bool  = true
var StickerPlugin : Bool = false
var emojiEnabled : Bool = false       // Check that whether Image Attachment for comments is enable or not
var reactionsDictionary : NSDictionary! = [:]
var emojiReactionDictionary : NSDictionary! = [:]
let scrollViewEmoji = UIScrollView()
let arrowView = Triangle()
let scrollviewEmojiLikeView = UIScrollView() // All Reaction View in case of Content Like
var videoattachmentType = NSDictionary()
var isshimmer = false
var fromExternalWebView = false
var isfeedfilter = 1
var userSuggestions = [Any]() // Containing Suggetions
var bannerArray = [AnyObject]()
var decorationDictionary = NSDictionary()
var greetingsArray = [AnyObject]()
var usersBirthday = [AnyObject]()
var feedCharLength : Int = 0
var feedFontStyle = ""
var feedFontSize : Int = 0
var feedTextColor  = ""
var bannerFeedLength : Int = 0
var removeGreetingsId = [Int]()
var removeBirthdayId = [Int]()
var isViewWillAppearCall = 0
var reactionButtonImage = UIButton()
var likeIconImage = UIImage()
var quickContentIncrementIndex = 0
var isQuickContentInProcess = 0
var targetCheckValueAAF : Int = 0
var show_storySetting : Int = 0

class AdvanceActivityFeedViewController: UIViewController, UIPopoverPresentationControllerDelegate, TTTAttributedLabelDelegate, UIGestureRecognizerDelegate,UISearchBarDelegate,UITabBarControllerDelegate,scrollDelegate,CLLocationManagerDelegate, WKNavigationDelegate , CoachMarksControllerDataSource, CoachMarksControllerDelegate, StoryNotUploadedCell, QuickContentProtocol{
    
    var locationManager = CLLocationManager()
    /// Called when native content is received.
    
    let mainView = UIView()
    var audioPlayer = AVAudioPlayer()
    var checkMiniMenuTimers : Timer!
    var showSpinner = true                      // show spinner flag for pull to refresh
    var refresher:UIRefreshControl!             // Refresher for Pull to Refresh
    var maxid:Int!                              // MaxID for Pagination
    var minid:Int! = 0                           // MinID for New Feeds
    var titleInfo: UILabel!
    var menuLike : UIButton!
    //    var activityFeedTableView:UITableView!      // activityFeedTable to display Activity Feeds
    var feedObj = FeedTableViewController()
    var dynamicHeight:CGFloat = 44              // Defalut Dynamic Height for each Row
    var updateScrollFlag = true                 // Flag for Pagination by ScrollView Delegate
    var deleteFeed = false                      // Flag for Delete Feed Updation
    var activityFeeds:[ActivityFeed] = []       // To save Activity Feeds from Response (subclass of ActivityFeed)
    var menuOptionSelected:String!              // Set Option Selected for Feed Gutter Menu
    var tempFeedArray = [Int:AnyObject]()       // Hold TemproraryFeedMenu for Hide Row (Undo, HideAll)
    var feed_filter = 1                         // Set Value for Feed Filter options in browse Feed Request to get feed_filter in response
    var feedFilterFlag = false                  // Flag to merge Feed Filter Params in browse Feed Request
    var fullDescriptionCell = [Int]()           // Contain Array of all cell to show full description
    var dynamicRowHeight = [Int:CGFloat]()      // Save table Dynamic RowHeight
    var rightAddBarButtonItem:UIBarButtonItem!
    var rightAddBarButtonItem2:UIBarButtonItem!
    var rightAddBarButtonItem3:UIBarButtonItem!
    var userImage : UIImageView!
    var UserId:Int!
    var notLabel:UILabel!
    var msgLabel:UILabel!
    var reqLabel:UILabel!
    // var imageCache = [String:UIImage]()
    //  var userImageCache = [String:UIImage]()
    var noContentView : NoPostView!
    var titleshow :Bool  = false
    var titleHeight:CGFloat = 0
    var temptitleInfo : String = ""
    var gutterMenu1: NSArray = []
    var noPost : Bool = true
    var action_id:Int!
    var postView = UIView()
    var storiesView : StoriesView? //stories
    var storiesViewHeight : CGFloat = 0.0
    var storyNotUploaded : StoryNotUploaded!
    var shareTitle:String!
    var actionIdArray = [Int]()
    var updateDashboard:Timer!
    var noCommentMenu:Bool = false
    var updateNewFeed = false
    var newFeedUpdateCounter = 0
    var footerView = UIView()
    var defaultFeedCount : Int = 0
    var hidingNavBarManager: HidingNavigationBarManager?
    let subscriptionNoticeLinkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.gray,
        // NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    let subscriptionNoticeActiveLinkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.80),
        //NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    var guttermenuoption = [String]()
    var guttermenuoptionname = [String]()
    var feedMenu : NSArray = []
    var currentCell : Int = 0
    var noContentLabel = UILabel()
    private var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    fileprivate var popoverOptionsUp: [PopoverOption] = [
        .type(.up),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    var popoverTableView:UITableView!
    var tableHeaderHight: CGFloat = 0
    var scrollableCategory = UIScrollView()
    var openAppRating = false
    var currentButton : UIButton?
    // Initialize Class
    var myTimer:Timer!
    var greetingsWebView = WKWebView()
    var crossView = UIButton()
    var birthdayView = UIView()
    var birthdayImage = UIImageView()
    var birthdayTitle = UILabel()
    var bdayMsgButton = UIButton()
    var bdayPostbutton = UIButton()
    var birthdayUserimage = UIImageView()
    var birthdayUserName = UILabel()
    var birthdaybuttonsFrame = UIView()
    var frndsbirthdayPost = UIButton()
    var frndsBirthdayMsg = UIButton()
    
    var dictCheckValue  = [Int:String]()
    var dictBirthdayValue = [Int:String]()
    var userBirthdayName = [Int:String]()
    var userBirthdayImage = [Int:String]()
    var crossBdayView = UIButton()
    var webframe = UIView()
    private var dismissEmojiView: UITapGestureRecognizer?
    var day : Int = 0
    var month : Int = 0
    var year : Int = 0
    
    var greetingsId = [Int]()
    var firstGreetings = false
    var didFindLocation = false
    
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    var errorMessage : String = ""
    var checkProfileforldis : Bool = false
    var strURLTextBanner = ""
    var background_color = ""
    var strURLcolor = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var imageGetAttachementLink = ""
    var titleGetAttachementLink = ""
    var descriptionGetAttachementLink = ""
    var tourCount : Int = 4
    var appDesc = String()
    var appVersion : String = ""
    var noPostViewSet = false
    var friendWidgetRemoved = false
    
    override func viewDidLoad()
    {
        let defaults = UserDefaults.standard
        show_storySetting = defaults.integer(forKey: "isSitestoriesEnable")
        super.viewDidLoad()
    NotificationCenter.default.addObserver(self,selector:#selector(AdvanceActivityFeedViewController.applicationWillEnterForeground),name: UIApplication.willEnterForegroundNotification,object: nil)
        
        show_storySetting = defaults.integer(forKey: "isSitestoriesEnable")
        let date = Date()
        let calendar = Calendar.current
        year = calendar.component(.year, from: date)
        month = calendar.component(.month, from: date)
        day = calendar.component(.day, from: date)
        checkLiveTimeSetting()
        // checkapp()
        tableViewFrameType = "AdvanceActivityFeedViewController"
        if UserDefaults.standard.string(forKey: "isAppRated") != nil
        {
            openAppRating = false
        }
        else
        {
            openAppRating = true
        }
        
        self.checkRequiredFields()
        removeQuickContentPost()
        
        globalTypeSearch = ""
        firstGreetings = true
        subject_unique_type = nil
        subject_unique_id = nil
        openSideMenu = false
        feedUpdate = false
        isshimmer = true

        self.view.isUserInteractionEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isUserInteractionEnabled = false
        }
        
        if  defaults.bool(forKey: "AppInstalled") == false
        {
            self.view.isUserInteractionEnabled = false
            if let tabBarObject = self.tabBarController?.tabBar
            {
                tabBarObject.isUserInteractionEnabled = false
            }
            navigationController?.navigationBar.isUserInteractionEnabled = false
            defaults.set(true, forKey: "AppInstalled")
        }
        searchDic.removeAll(keepingCapacity: false)
        maxid = 0
        maxidTikTok = 0
        frndTagValue.removeAll()
        
        // self.coachMarksController.dataSource = self
        setNavigationcontroller()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AdvanceActivityFeedViewController.checkService), name: NSNotification.Name(rawValue: "checkService"), object: nil)
        
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        }
        
        // Create container view
        mainView.frame = view.frame
        mainView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)//aafBgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        // For getting Location response
        NotificationCenter.default.addObserver(self, selector: #selector(AdvanceActivityFeedViewController.userLoggedIn(_:)), name: NSNotification.Name(rawValue: "UserLoggedIn"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AdvanceActivityFeedViewController.showContent(userInfo:)), name: NSNotification.Name(rawValue: "appNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AdvanceActivityFeedViewController.showMassNotification(userInfo:)), name: NSNotification.Name(rawValue: "massNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AdvanceActivityFeedViewController.universalLinkRedirection), name: NSNotification.Name(rawValue: "UniversalLink"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AdvanceActivityFeedViewController.viewProfileClicked), name: NSNotification.Name(rawValue: "ChannelizeBroadcast"), object: nil)
        
        // Set navigation right item on basis of location
        getLocationdata()
        
        // For customize header having searchbar in center
        getheaderSetting()
        noContentView = NoPostView(frame: CGRect(x: 0, y: 75, width: self.view.bounds.width, height: 120))
        noContentView.crossButton.isHidden = true
        noContentView.button.addTarget(self, action: #selector(self.goToMember), for: .touchUpInside)
        noContentView.isHidden = true
        mainView.addSubview(noContentView)
        self.noContentView.crossButton.addTarget(self, action: #selector(AdvanceActivityFeedViewController.removeFriendWidget), for: .touchUpInside)
        
        
        // For hiding navigation bar while scrolling
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: feedObj.tableView)
        
        mainView.addSubview(feedObj.view)
        self.addChild(feedObj)
        
        //        let offset = CGPoint.init(x: 0, y: -(TOPPADING))
        //        feedObj.tableView.setContentOffset(offset, animated: true)
        DispatchQueue.main.async {
            let offset = CGPoint.init(x: 0, y: -(TOPPADING))
            self.feedObj.tableView.setContentOffset(offset, animated: false)
            self.viewMethodCalled()
        }
        
        dismissEmojiView = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        dismissEmojiView?.cancelsTouchesInView = false
        if let tap = dismissEmojiView {
            
            view.addGestureRecognizer(tap)
            
        }
        self.feedObj.feedDelegate = self
        self.feedObj.quickUploadFailedDelegate = self
         self.checkMiniMenuTimers = Timer.scheduledTimer(timeInterval: 10, target:self, selector:  #selector(AdvanceActivityFeedViewController.checkMiniMenuCount), userInfo: nil, repeats: true)
    }
    
    @objc private func dismissView() {
        
        guard let _ = dismissEmojiView else {
            
            return
            
        } // guard
        
        guard scrollViewEmoji.isHidden == false else {
            
            return
            
        } // guard
        
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        
        //view.removeGestureRecognizer(tap)
        
    }
    
    
    /// calls in every 10 sec to check notification count
    @objc func checkMiniMenuCount(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork(){
            // Set Parameters & Path for Notifications Update Requests
            if logoutUser == false {
                var parameters = [String:String]()
                parameters = ["limit": "\(limit)" ]
                // Send Server Request for Activity Feed
                post(parameters, url: "notifications/new-updates", method: "GET") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        // Reset Object after Response from server
                        // On Success Update Feeds
                        if msg{
                            // Check response of Activity Feeds
                            if let response = succeeded["body"] as? NSDictionary{
                                let n = response["notifications"] as! Int
                                let m = response["messages"] as! Int
                                let r = response["friend_requests"] as! Int
                                var cartCount:Int = 0
                                if response["cartProductsCount"] != nil{
                                    cartCount  = response["cartProductsCount"] as! Int
                                }
                                friendRequestCount = r
                                notificationCount = n
                                if !isChannelizeAvailable {
                                     messageCount = m
                                }
                                totalNotificationCount = r + messageCount + n
                                if logoutUser == false {
                                    
                                    if cartCount > 0 {
                                        if cartIndex > 0 {
                                            baseController?.tabBar.items?[cartIndex].badgeValue = "\(cartCount)"
                                        }
                                        
                                    }
                                    else{
                                        if cartIndex > 0{
                                            baseController?.tabBar.items?[cartIndex].badgeValue = nil
                                        }
                                    }
                                    
                                    if friendRequestCount > 0 {
                                        if friendReqIndex > 0 {
                                            baseController?.tabBar.items?[friendReqIndex].badgeValue = "\(friendRequestCount)"
                                        }
                                        
                                    }
                                    else{
                                        if friendReqIndex > 0{
                                            baseController?.tabBar.items?[friendReqIndex].badgeValue = nil
                                        }
                                    }
                                    if messageCount > 0 {
                                        if messageIndex > 0 {
                                            baseController?.tabBar.items?[messageIndex].badgeValue = "\(messageCount)"
                                        }
                                        
                                        
                                    }
                                    else{
                                        if messageIndex > 0{
                                            baseController?.tabBar.items?[messageIndex].badgeValue = nil
                                        }
                                    }
                                    if notificationCount > 0 {
                                        if notificationIndex > 0 {
                                            baseController?.tabBar.items?[notificationIndex].badgeValue = "\(notificationCount)"
                                        }
                                        
                                        
                                    }else{
                                        if notificationIndex > 0{
                                            baseController?.tabBar.items?[notificationIndex].badgeValue = nil
                                        }
                                    }
                                }
                            }
                            // self.dashboardTableView.reloadData()
                        }
                        
                    })
                    
                }
            }
            
        }
        
    }
    
    func getLikeIconImage(contentItems: NSDictionary) {
        for (k,v) in contentItems
        {
            let v = v as! NSDictionary
            if  (v["reactionicon_id"] as? Int) != nil
            {
                if k as! String == "like"
                {
                    if let icon  = v["icon"] as? NSDictionary{
                        if let url = icon["reaction_image_large_icon"] as? String{
                            KingfisherManager.shared.retrieveImage(with: URL(string: url)!, options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) -> () in
                                if image != nil {
                                    likeIconImage = image!
                                    print("url--\(url)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func viewMethodCalled()
    {
        feedObj.feedShowingFrom = "ActivityFeed"
        feedObj.delegateScroll = self
        if logoutUser == false
        {
            //Stories View
            if show_story == 1
            {
                storiesViewHeight = 115.0
                storiesView =  StoriesView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: storiesViewHeight), vc: self)
                storiesView?.objAAF = self
                storiesView?.delegateStoryNotUploaded = self
                storiesView?.layer.borderWidth = 0.0
                storiesView?.layer.borderColor = cellBackgroundColor.cgColor
                self.feedObj.tableView.addSubview(storiesView!)
            }
            else
            {
                storiesViewHeight = 0.0
            }
            storyNotUploaded = StoryNotUploaded(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height), vc: self)
            storyNotUploaded.isHidden = true
            storyNotUploaded.objAAF = self
            self.view.addSubview(storyNotUploaded)
            
            
            postView =  createView(CGRect(x: 0,y: storiesViewHeight + 5,width: view.bounds.width,height: 110), borderColor: cellBackgroundColor , shadow: true)
            postView.layer.borderWidth = 0.0
            postView.layer.borderColor = cellBackgroundColor.cgColor
            self.feedObj.tableView.addSubview(postView)
            
            userImage = createImageView(CGRect(x:PADING,y:9,width: 50,height: 50), border: true)
            userImage.image = UIImage(named: "user_profile_image.png")
            imageProfile = userImage.image
            self.storiesView?.collectionViewStories?.reloadData()
            userImage.tag = 108
            userImage.layer.cornerRadius = userImage.frame.size.width/2
            userImage.clipsToBounds = true
            userImage.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
            userImage.contentMode = .scaleAspectFill
            postView.addSubview(userImage)
            
            
            let profile = createButton(CGRect(x: PADING,y: 9,width: 60,height: 60), title: "", border: false, bgColor: false, textColor: textColorLight)
            profile.addTarget(self, action: #selector(AdvanceActivityFeedViewController.showProfile), for: .touchUpInside)
            postView.addSubview(profile)
            profile.tag = 108
            
            // postFeedOption()
            
            
            birthdayView = UIView(frame: CGRect(x: PADING , y: postView.frame.size.height + 5 + storiesViewHeight ,width : view.bounds.width , height : 215 ))
            birthdayView.isHidden = true
            birthdayView.backgroundColor = textColorLight
            self.feedObj.tableView.addSubview(birthdayView)
            
            birthdayImage = createImageView(CGRect(x: PADING , y:  5 ,width : view.bounds.width , height : 100 ), border: false)
            birthdayImage.layer.masksToBounds = true
            birthdayView.addSubview(birthdayImage)
            
            birthdayUserimage = createImageView(CGRect(x: view.bounds.width/2 - 35 , y:  birthdayImage.frame.size.height - 40 ,width : 70 , height : 70 ), border: false)
            birthdayUserimage.layer.cornerRadius = birthdayUserimage.frame.size.width / 2;
            birthdayUserimage.layer.masksToBounds = true
            birthdayView.addSubview(birthdayUserimage)
            
            birthdayUserName = createLabel(CGRect(x: PADING , y:  148 ,width : view.bounds.width - 2*PADING , height : 20 ), text: "", alignment: .center, textColor: textColorDark)
            birthdayUserName.font = UIFont(name: fontBold, size: 15.0)
            birthdayView.addSubview(birthdayUserName)
            
            birthdayTitle = createLabel(CGRect(x: PADING , y: 180 ,width : view.bounds.width - 2*PADING , height : 20 ), text: "", alignment: .center, textColor: textColorDark)
            
            birthdayTitle.font = UIFont(name: fontNormal, size: FONTSIZENormal)
            birthdayView.addSubview(birthdayTitle)
            
            crossBdayView = createButton(CGRect(x: view.bounds.width - 30 , y :  5 , width : 30 , height : 30), title: "X", border: false, bgColor: false, textColor: textColorDark)
            crossBdayView.isHidden = true
            birthdayView.addSubview(crossBdayView)
            
            birthdaybuttonsFrame = UIView(frame: CGRect(x: PADING , y: 215 + postView.frame.size.height + 5 + storiesViewHeight,width : view.bounds.width , height : 40 ))
            birthdaybuttonsFrame.isHidden = true
            birthdaybuttonsFrame.backgroundColor = textColorLight
            self.feedObj.tableView.addSubview(birthdaybuttonsFrame)
            
            frndsbirthdayPost = createButton(CGRect(x: 5 , y :  5 , width : view.bounds.width/2 - 10 , height : 30), title: "\(editFeedIcon)"+NSLocalizedString(" Write a post",comment: ""), border: true, bgColor: false, textColor: navColor)
            frndsbirthdayPost.layer.borderColor = navColor.cgColor
            frndsbirthdayPost.titleLabel?.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
            birthdaybuttonsFrame.addSubview(frndsbirthdayPost)
            
            frndsBirthdayMsg = createButton(CGRect(x: view.bounds.width/2  , y :  5 , width : view.bounds.width/2 - 15 , height : 30), title: "", border: true, bgColor: false, textColor: navColor)
            //    let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
            let iconFont = CTFontCreateWithName(("fontAwesome" as CFString?)!, FONTSIZENormal, nil)
            let textFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
            let iconPart = NSMutableAttributedString(string: "\(messagebda)", attributes: [NSAttributedString.Key.font:iconFont ,  NSAttributedString.Key.foregroundColor : navColor])
            
            let
            textPart = NSMutableAttributedString(string: NSLocalizedString(" Message",comment: ""), attributes: [NSAttributedString.Key.font:textFont , NSAttributedString.Key.foregroundColor : navColor])
            iconPart.append(textPart)
            
            frndsBirthdayMsg.setAttributedTitle(iconPart, for: .normal)
            birthdaybuttonsFrame.addSubview(frndsBirthdayMsg)
            
            webframe = UIView(frame: CGRect(x: PADING , y: postView.frame.size.height + 7 + storiesViewHeight ,width : view.bounds.width , height : 1 ))
            
            webframe.isHidden = true
            webframe.backgroundColor = textColorLight
            webframe.backgroundColor = textColorLight
            self.feedObj.tableView.addSubview(webframe)
            
            greetingsWebView = WKWebView(frame: CGRect(x: 0 , y : 0 , width : view.bounds.width , height : 1))
            greetingsWebView.clipsToBounds = true
            greetingsWebView.backgroundColor = textColorLight
            greetingsWebView.isHidden = true
            greetingsWebView.navigationDelegate = self
            greetingsWebView.scrollView.bounces = false
            greetingsWebView.scrollView.isScrollEnabled = false
            webframe.addSubview(greetingsWebView)
            crossView = createButton(CGRect(x: view.bounds.width - 30 , y :  0 , width : 30 , height : 70), title: "", border: false, bgColor: false, textColor: textColorDark)
            crossView.setTitle(solidCross, for: .normal)
            crossView.titleLabel?.font = UIFont(name: "fontAwesome", size: 17.0)
            crossView.contentVerticalAlignment = .center
            crossView.contentHorizontalAlignment = .center
            crossView.isHidden = true
            greetingsWebView.addSubview(crossView)
            if isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved {
                self.feedObj.tableView.addSubview(self.noContentView)
                
                self.noContentView.frame.origin.y = getBottomEdgeY(inputView: postView)
            }
            tableHeaderHight = postView.frame.size.height + 8 + storiesViewHeight
            // Download userprofile
            if coverImage != nil {
                let coverImageUrl = NSURL(string: coverImage)
                if coverImageUrl != nil {
                    self.userImage.kf.indicatorType = .activity
                    (self.userImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    self.userImage.kf.setImage(with: coverImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        coverPhotoImage = image
                        imageProfile = image
                        self.storiesView?.collectionViewStories?.reloadData()
                    })
                    
                }
                
            }
            // Show Feed Option only to LoginUser
            
            
        }
        else
        {
            self.title = ""
        }
        
        // Initialize Pull to Refresh to ActivityFeed Table
        refresher = UIRefreshControl()
        let attr = [NSAttributedString.Key.foregroundColor:textColorMedium]
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""),attributes: attr)
        refresher.addTarget(self, action: #selector(AdvanceActivityFeedViewController.refresh), for: UIControl.Event.valueChanged)
        feedObj.tableView.addSubview(refresher)
        
        if isAddFriendWidgetEnable == 0 {
            // Stuff when there is no feed Start
            self.noContentView.button.layer.cornerRadius = self.noContentView.button.frame.height/2
            self.noContentView.button.addTarget(self, action: #selector(self.goToMember), for: .touchUpInside)
            self.noContentView.tag = 1000
            self.noContentView.frame.origin.y = getBottomEdgeY(inputView: scrollableCategory) + 5
            self.feedObj.tableView.addSubview(self.noContentView)
        }
        
        // Stuff when there is no feed End
        
        if logoutUser == false
        {
            if coverImage != nil
            {
                if coverPhotoImage != nil
                {
                    self.userImage.image = coverPhotoImage
                    imageProfile = coverPhotoImage
                    self.storiesView?.collectionViewStories?.reloadData()
                }
                else
                {
                    if let coverImageUrl = NSURL(string: coverImage)
                    {
                        self.userImage.kf.indicatorType = .activity
                        (self.userImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        self.userImage.kf.setImage(with: coverImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            coverPhotoImage = image
                            imageProfile = image
                            self.storiesView?.collectionViewStories?.reloadData()
                        })
                    }
                }
            }
            //getSuggestions()
            
        }
        // Get stored feed and show
        
        getchacheFeed()
        showSpinner = false
        browseFeed()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(AdvanceActivityFeedViewController.getSuggestions), name: NSNotification.Name(rawValue: "Suggestion"), object: nil)
        
        CreateFooter()
        
        
        API_CheckVideoSize()
    }
    
    func checkRequiredFields()
    {
        // Check Internet Connectivity
        if reachability.connection != .none {
            // Reset Objects
            
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = mainView.center
            activityIndicatorView.startAnimating()
            
            var path = ""
            var parameters = [String:String]()
            
            path = "user/check-required-fields/\(currentUserId)"
            parameters = ["restapilocation":"\(defaultlocation)"]
            
            // Send Server Request to Browse Notifications Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        if let body = succeeded["body"] as? NSDictionary
                        {
                            self.checkProfileforldis = true
                            if let isEmptyRequiredField = body["isEmptyRequiredField"] as? Int
                            {
                                if isEmptyRequiredField == 1
                                {
                                    if let errorMsg = body["errorMessage"] as? String
                                    {
                                        self.errorMessage = errorMsg
                                    }
                                    
                                    self.fieldRequiredPopUp()
                                }
                                else
                                {
                                    self.view.isUserInteractionEnabled = true
                                    if let tabBarObject = self.tabBarController?.tabBar
                                    {
                                        tabBarObject.isUserInteractionEnabled = true
                                    }
                                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                                }
                            }
                        }
                        
                    }else{
                        // Handle Server Error
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
    
    //Redirect to edit profile page
    func fieldRequiredPopUp()
    {
        let alertController = UIAlertController(title: "Fill Profile Required Fields", message:
            "\nClick on continue to fill profile required fields.\n \(self.errorMessage)", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default,handler: { action in
            let presentedVC = EditProfileViewController()
            presentedVC.errorMessage = self.errorMessage
            presentedVC.fromMainFeed = true
            fromEditProfilePage = true
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func removeFriendWidget() {
        if feedArray.count == 0 {
            self.noContentLabel.isHidden = true
        }
        self.friendWidgetRemoved = true
        if birthdayView.isHidden == false {
            self.scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: birthdaybuttonsFrame) + 5
        }
        else if birthdayView.isHidden == true && greetingsWebView.isHidden == true {
            self.scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.postView) + 5
        }
        else if birthdayView.isHidden == true && greetingsArray.count > 0  {
            self.scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.postView) + 5 + webframe.frame.size.height
        }
        else {
            self.scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.postView) + 5
        }
        self.noContentView.frame.size.height = 0
        tableHeaderHight = getBottomEdgeY(inputView: self.scrollableCategory) + 5
        globalFeedHeight = tableHeaderHight
        self.noContentView.removeFromSuperview()
        self.noContentView.isHidden = true
        self.feedObj.tableView.reloadData()
        
    }
    
    // MARK: - Check App Updates
    
    func checkapp(){
        var checkBoolUpgrade : Bool = false
        appUpdateAvailable(completion: { (check) in
            
            
            if check == true{
                
                
                let defaults = UserDefaults.standard
                if let name = defaults.object(forKey: "forceUpgrade")
                {
                    if  UserDefaults.standard.object(forKey: "forceUpgrade") != nil {
                        
                        checkBoolUpgrade = name as! Bool
                        
                    }
                }
                
                if checkBoolUpgrade == false {
                    
                    
                    if UserDefaults.standard.value(forKey: "ignore") != nil {
                        return
                    }
                    else if UserDefaults.standard.value(forKey: "Remind") != nil {
                        
                        let date = Date()
                        let calendar = Calendar.current
                        let  currentYear = calendar.component(.year, from: date)
                        let currentmonth = calendar.component(.month, from: date)
                        let currentday = calendar.component(.day, from: date)
                        
                        print("currentday")
                        print(currentday)
                        print(UserDefaults.standard.value(forKey: "day") as! Int)
                        
                        if currentday == UserDefaults.standard.value(forKey: "day") as! Int && currentmonth == UserDefaults.standard.value(forKey: "month") as! Int && currentYear == UserDefaults.standard.value(forKey: "year") as! Int
                        {
                            print("same day====will call later")
                        }
                        else{
                            
                            self.appUpdateAvailable(completion: { (check) in
                                if check == true{
                                    self.updateValue()
                                }
                            })
                            
                            
                        }
                        
                    }
                    else{
                        
                        self.appUpdateAvailable(completion: { (check) in
                            
                            
                            if check == true{
                                
                                
                                self.updateValue()
                                
                            }
                        })
                        
                    }
                    
                }
                else{
                    self.showForceUpgrade()
                }
                
                
            }
        })
        
        
    }
    
    func showForceUpgrade() {
        
        // create the alert
        let alert = UIAlertController(title: "New version available \((self.appVersion)) ", message: "\(self.appDesc)", preferredStyle: UIAlertController.Style.alert)
        let paragraphStyle = NSMutableParagraphStyle()
        let textFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
        paragraphStyle.alignment = NSTextAlignment.left
        let messageText = NSMutableAttributedString(
            string: "\(self.appDesc)",
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font:textFont,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        
        alert.setValue(messageText, forKey: "attributedMessage")
        
        
        alert.addAction(UIAlertAction(title: "Upgrade App", style: UIAlertAction.Style.destructive, handler: { action in
            
            self.getAppFromItunes()
            self.view.isUserInteractionEnabled = false
            
            if let items =  self.tabBarController?.tabBar.items {
                
                for i in 0 ..< items.count {
                    
                    let itemToDisable = items[i]
                    itemToDisable.isEnabled = false
                    
                }
            }
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func getAppFromItunes(){
        let bundleID = Bundle.main.bundleIdentifier
        print(bundleID!)
        getiTunesObject(bundleID!) { (succeeded, msg) -> () in
            if let results = succeeded["results"] as? NSArray{
                if msg{
                    if let result = results[0] as? NSDictionary  {
                        if let trackViewUrl = result["trackViewUrl"] as? String {
                            print("opening=====")
                            // UITabBarController.tabBar.userInteractionEnabled = Yes
                            UIApplication.shared.open(URL(string: trackViewUrl)!, options: [UIApplication.OpenExternalURLOptionsKey(rawValue: ""):""], completionHandler: nil)
                            // UIApplication.shared.openURL(URL(string: trackViewUrl)!)
                        }
                    }
                }
            }
        }
    }
    
    func updateValue(){
        
        let alert = UIAlertController(title: "New version available \((self.appVersion)) ", message: "\(self.appDesc)", preferredStyle: UIAlertController.Style.alert)
        
        let paragraphStyle = NSMutableParagraphStyle()
        let textFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
        paragraphStyle.alignment = NSTextAlignment.left
        let messageText = NSMutableAttributedString(
            string: "\(self.appDesc)",
            attributes: [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font:textFont,
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        
        alert.setValue(messageText, forKey: "attributedMessage")
        
        // add the actions (buttons)
        
        alert.addAction(UIAlertAction(title: "Upgrade", style: UIAlertAction.Style.default, handler: { action in
            
            self.getAppFromItunes()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Remind later", style: UIAlertAction.Style.default, handler: { action in
            
            
            UserDefaults.standard.setValue(true, forKey: "Remind")
            UserDefaults.standard.setValue(self.day, forKey: "day")
            UserDefaults.standard.setValue(self.year, forKey: "year")
            UserDefaults.standard.setValue(self.month, forKey: "month")
            
            
        }))
        alert.addAction(UIAlertAction(title: "Ignore", style: UIAlertAction.Style.cancel, handler: { action in
            
            
            UserDefaults.standard.setValue(false, forKey: "ignore")
            
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func appUpdateAvailable(completion:@escaping (Bool) -> ()){
        
        var currentVersion = ""
        if reachability.connection != .none {
            removeAlert()
            activityIndicatorView.center = view.center
            if quickContentIncrementIndex == 0
            {
                self.view.addSubview(activityIndicatorView)
                // activityIndicatorView.startAnimating()
            }
            //self.view.addSubview(activityIndicatorView)
            // activityIndicatorView.startAnimating()
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                currentVersion = version
            }
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["type":"ios"], url: "get-new-version", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    // activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            print("response version \(response)")
                            
                            let popup = response["isPopUpEnabled"] as! Int
                            
                            
                            
                            if popup == 0{
                                completion(false)
                            }
                            else{
                                self.appVersion = (response["latestVersion"] as! String)
                                self.appDesc = response["description"] as! String
                                
                                if response["isForceUpgrade"] != nil {
                                    if response["isForceUpgrade"] as! Int == 1 {
                                        UserDefaults.standard.set(true, forKey: "forceUpgrade")
                                    }
                                    else{
                                        UserDefaults.standard.set(false, forKey: "forceUpgrade")
                                    }
                                }
                                
                                if self.appVersion > (currentVersion as String){
                                    completion(true)
                                }
                                else{
                                    UserDefaults.standard.set(false, forKey: "forceUpgrade")
                                    completion(false)
                                    
                                    if UserDefaults.standard.bool(forKey: "fcmTockenUpdate") == false {
                                        if reachability.connection != .none {
                                            // Reset Objects
                                            // Send Server Request to Browse Notifications Entries
                                            post(["device_token":"\(device_token_id!)","device_uuid":"\(String(describing: device_uuid!))"], url: "user/update-fcm-token", method: "POST") { (succeeded, msg) -> () in
                                                DispatchQueue.main.async(execute: {
                                                    if msg{
                                                        print("Refreshed Token")
                                                        UserDefaults.standard.set(true, forKey: "fcmTockenUpdate")
                                                    }
                                                    else{
                                                        print("Error")
                                                    }
                                                })
                                            }
                                        }else{
                                            // No Internet Connection Message
                                            print("Network Error")
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                    }
                    
                })
                
            }
        }
    }

    @objc func openSheet()
    {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Create Post", comment: ""), style: .default , handler:{ (UIAlertAction)in
            self.stopMyTimer()
            
            likeCommentContentType = ""
            likeCommentContent_id = ""
            
            let presentedVC = AdvancePostFeedViewController()
            presentedVC.postFeedDelegate = self
            
            let navigationController = UINavigationController(rootViewController: presentedVC)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated:false, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        self.present(alert, animated: true, completion: {
            //print("completion block")
        })
    }
    
    @objc func checkService()
    {
        if (CLLocationManager.locationServicesEnabled())
        {
            let defaults = UserDefaults.standard
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                //    //print("No access")
                if AppLauchForLocation == true && locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1{
                    AppLauchForLocation = false
                    // At the time of app installation , user also login at time ios default pop up show , so first time we don't show our custom pop-up
                    if defaults.bool(forKey: "showMsg")
                    {
                        currentLocation(controller: self)
                    }
                    defaults.set(true, forKey: "showMsg")
                }
            case .authorizedAlways, .authorizedWhenInUse:
                // //print("Access")
                if updateLocation == false
                {
                    setLocation = true
                }
            }
            
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        else
        {
            if AppLauch == true && locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1 {
                setLocation = true
                AppLauch = false
                gpsLocation(controller: self)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let defaults = UserDefaults.standard
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            //  //print("No access")
            if defaults.bool(forKey: "appTour")
            {
                self.showAppTour()
            }
            defaults.set(true, forKey: "appTour")
        case .authorizedAlways, .authorizedWhenInUse:
            //   //print("Access")
            defaults.set(true, forKey: "appTour")
            self.showAppTour()
        }
        
    }
    
    func getGreetings(){
        if Reachabable.isConnectedToNetwork()
        {
            let parameters = [String:String]()
            post(parameters, url: "advancedactivity/feelings/greeting-manage", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg {
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["greetings"] != nil {
                                greetingsArray =  ((response["greetings"] as! NSArray) as [AnyObject])
                            }
                            if response["usersBirthday"] != nil {
                                usersBirthday = ((response["usersBirthday"] as! NSArray) as [AnyObject])
                            }
                            
                            
                            let date = Date()
                            let calendar = Calendar.current
                            let currentday = calendar.component(.day, from: date)
                            if UserDefaults.standard.value(forKey: "Gday") != nil {
                                if currentday == UserDefaults.standard.value(forKey: "Gday") as! Int
                                {
                                    ////print(currentday)
                                    let defaults = UserDefaults.standard
                                    let array = defaults.array(forKey: "SavedGreetingsArray")  as? [Int] ?? [Int]()
                                    removeGreetingsId = array
                                    if removeGreetingsId.count != greetingsArray.count {
                                        if array.count > 0 {
                                            for i  in 0 ..< greetingsArray.count {
                                                // if greetingsArray[i] != nil {
                                                
                                                if let dic = greetingsArray[i] as? NSDictionary{
                                                    let id  = dic["greeting_id"] as! Int
                                                    if array.contains(id){
                                                        // greetingsArray.remove(at: i )
                                                        ////print("count")
                                                        ////print(greetingsArray.count)
                                                        
                                                    }
                                                }
                                                //}
                                            }
                                        }
                                    }
                                    
                                }
                                else{
                                    
                                    removeGreetingsId.removeAll()
                                    
                                    UserDefaults.standard.removeObject(forKey: "SavedGreetingsArray")
                                }
                            }
                            
                            if UserDefaults.standard.value(forKey: "Bday") != nil {
                                if currentday == UserDefaults.standard.value(forKey: "Bday") as! Int
                                {
                                    
                                    let defaults = UserDefaults.standard
                                    var array = defaults.array(forKey: "SavedbirthdayArray")  as? [Int] ?? [Int]()
                                    removeBirthdayId = array
                                    if removeBirthdayId.count != usersBirthday.count {
                                        
                                        if array.count > 0 {
                                            let count1 = usersBirthday.count
                                            for i  in 0 ..< count1 {
                                                
                                                
                                                
                                                if let dic = usersBirthday[i] as? NSDictionary{
                                                    let id  = dic["user_id"] as! Int
                                                    if array.contains(id){
                                                        // usersBirthday.remove(at: i )
                                                        ////print("count")
                                                        array.remove(object: id)
                                                        ////print(usersBirthday.count)
                                                        
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                else{
                                    
                                    removeBirthdayId.removeAll()
                                    UserDefaults.standard.removeObject(forKey: "SavedbirthdayArray")
                                    
                                }
                            }
                            
                            
                            
                            //  Birthday
                            
                            
                            
                            
                            if usersBirthday.count > 0 {
                                
                                
                                var counter = 0
                                for dict in usersBirthday
                                {
                                    
                                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject:dict), forKey: "Birthdays\(counter)")
                                    counter = counter + 1
                                }
                            }
                            
                            if greetingsArray.count > 0 {
                                var counter1 = 0
                                
                                
                                for dict in greetingsArray
                                {
                                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject:dict), forKey: "Greetings\(counter1)")
                                    counter1 = counter1 + 1
                                }
                            }
                            self.getUIOfGreetings()
                        }
                    }
                    
                })
                
            }
        }
    }
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       
        
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
            self.greetingsWebView.frame.size.height = height as! CGFloat
            self.webframe.frame.size.height = self.greetingsWebView.frame.size.height
            self.updateAfterWebView()
            
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(String(describing: decisionHandler))")
        
        switch navigationAction.navigationType {
        case .linkActivated:
            if let url = navigationAction.request.url{
                
                let presentedVC = ExternalWebViewController()
                presentedVC.url = url.absoluteString
                let navigationController = UINavigationController(rootViewController: presentedVC)
                self.present(navigationController, animated: true, completion: nil)
                decisionHandler(.cancel)
                return
            }
            
        default:
            break
        }
        
        
        decisionHandler(.allow)
    }
    
    

    
    func updateAfterWebView()
    {
        self.webframe.frame.size.height = self.greetingsWebView.frame.size.height
        self.webframe.isHidden = false
        self.greetingsWebView.isHidden = false
        if isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved {
            self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.greetingsWebView) + 5
            self.scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView) + 5
            tableHeaderHight = getBottomEdgeY(inputView: self.scrollableCategory)
        }
        else {
            tableHeaderHight = storiesViewHeight + 5 + self.postView.frame.size.height + 7 + self.webframe.frame.size.height
        }
        //self.scrollableCategory.frame.origin.y = self.webframe.frame.size.height + 5
        
        //tableHeaderHight = self.webframe.frame.size.height + 5
        globalFeedHeight = tableHeaderHight
        feedObj.tableView.reloadData()
        showfeedFilter()
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        
        if locationOnhome != 1 || isChangeManually != 1
        {
            tourCount = 3
        }
        return tourCount
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
            //  self.postView.layer.cornerRadius = self.postView.frame.width / 2
            //   skipView.isHidden = false
            var   coachMark1 : CoachMark
            coachMark1 = coachMarksController.helper.makeCoachMark(for: postView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.view.bounds.width - 15,y: self.view.bounds.height - 20), radius: CGFloat(80), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                
                
                return circlePath//UIBezierPath(ovalIn: frame.insetBy(dx: -5, dy: -5))
                
            }
            //  coachMark1.disableOverlayTap = true
            coachMark1.gapBetweenCoachMarkAndCutoutPath = 6.0
            // We'll also enable the ability to touch what's inside
            // the cutoutPath.
            //  coachMark1.allowTouchInsideCutoutPath = true
            return coachMark1
        case 1:
            
            var  coachMark2 : CoachMark
            coachMark2 = coachMarksController.helper.makeCoachMark(for: postView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: 140,y: 110 + self.storiesViewHeight + 5), radius: CGFloat(70), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath//UIBezierPath(ovalIn: frame.insetBy(dx: -5, dy: -5))
                
            }
            // coachMark2.disableOverlayTap = true
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            
            
            // coachMark2.allowTouchInsideCutoutPath = true
            return coachMark2
            
        case 2:
            
            var  coachMark2 : CoachMark
            var origin_x : CGFloat = 80.0
            var radious : Int = 50
            if isshow_app_name == 1{
                //   skipView.isHidden = true
                origin_x = self.view.bounds.width - 15.0
                radious = 30
            }
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: postView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                
                
                
                return circlePath//UIBezierPath(ovalIn: frame.insetBy(dx: -5, dy: -5))
                
            }
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
        case 3:
            // skipView.isHidden = true
            var  coachMark3 : CoachMark
            var origin_x : CGFloat = self.view.bounds.width - 15.0
            var radious : Int = 50
            if isshow_app_name == 1{
                origin_x = self.view.bounds.width - 75.0
                radious = 40
            }
            coachMark3 = coachMarksController.helper.makeCoachMark(for: postView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                
                
                
                return circlePath//UIBezierPath(ovalIn: frame.insetBy(dx: -5, dy: -5))
                
            }
            // coachMark3.disableOverlayTap = true
            coachMark3.gapBetweenCoachMarkAndCutoutPath = 6.0
            
            // coachMark2.allowTouchInsideCutoutPath = true
            
            // coachMark2.disableOverlayTap = true
            return coachMark3
            
        default:
            coachMark = coachMarksController.helper.makeCoachMark()
            coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        }
        
        
        
        return coachMark
    }
    
    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController, at index: Int) -> Bool{
        targetCheckValueAAF = 0
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
        case 0:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        case 2:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        // coachViews.bodyView.isUserInteractionEnabled = false
        default:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
        case 0:
            coachViews.bodyView.hintLabel.text = NSLocalizedString("App Dashboard to Navigate across the app.", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Next ", comment: "")
            coachViews.bodyView.countTourLabel.text = String(format: NSLocalizedString(" 1/%@", comment: ""), "\(self.tourCount)")
        case 1:
            coachViews.bodyView.hintLabel.text = NSLocalizedString("Wondering how to share updates with your friends ? Tap here to add new posts, Photos, Videos and a lot more.", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Next ", comment: "")
            coachViews.bodyView.countTourLabel.text = String(format: NSLocalizedString(" 2/%@", comment: ""), "\(self.tourCount)")
        case 2:
            coachViews.bodyView.hintLabel.text = NSLocalizedString("Want to Search anything in particular? Search from here.", comment: "")
            if self.tourCount == 3
            {
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Want to Search anything in particular? Search from here.", comment: "")
            }
            else
            {
                coachViews.bodyView.nextLabel.text = NSLocalizedString("Next ", comment: "")
            }
            coachViews.bodyView.countTourLabel.text = String(format: NSLocalizedString(" 3/%@", comment: ""), "\(self.tourCount)")
        case 3:
            coachViews.bodyView.hintLabel.text = NSLocalizedString("Set App's Location for Location Based Result across the app.", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
            coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 4/4", comment: "")
            
            
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        
        
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool)
    {
        targetCheckValueAAF = 0
        //print("End Skip")
        //  self.blackScreen.alpha = 0.0
        
    }
    func showAppTour(){
        
        if logoutUser == false {
            let defaults = UserDefaults.standard
            if let name = defaults.object(forKey: "showHomePageAppTour")
            {
                if  UserDefaults.standard.object(forKey: "showHomePageAppTour") != nil {
                    
                    targetCheckValue = name as! Int
                    targetCheckValueAAF = targetCheckValue
                    
                }
                
            }
            
            if targetCheckValue == 1 {
                
                UserDefaults.standard.set(2, forKey: "showHomePageAppTour")
                coachMarksController.dataSource = self
                coachMarksController.delegate = self
                coachMarksController.overlay.allowTap = true
                coachMarksController.overlay.fadeAnimationDuration = 0.5
                coachMarksController.start(on: self)
            }
        }
        
    }
    
    func getUIOfGreetings (){
        if usersBirthday.count > 0 && (removeBirthdayId.count != usersBirthday.count){
            
            if usersBirthday.count > 0 {
                var counter = 0
                var userName = [String]()
                var userImage = [String]()
                //var birthdayTitle = [String]()
                for _ in usersBirthday {
                    
                    if let data = UserDefaults.standard.object(forKey: "Birthdays\(counter)") as? NSData{
                        if data.length != 0
                        {
                            counter = counter + 1
                            
                            let save = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSDictionary
                            
                            userName.append("\(save["displayname"]!)")
                            userImage.append(save["image"] as! String)
                            userBirthdayName.updateValue("\(save["displayname"]!)", forKey: save["user_id"]  as! Int)
                            userBirthdayImage.updateValue(save["image"] as! String, forKey: save["user_id"]  as! Int)
                            // birthdayTitle.append(save["birthday_title"] as! String)
                            dictBirthdayValue.updateValue(save["birthday_title"] as! String, forKey: save["user_id"]  as! Int)
                            
                        }
                        
                    }
                }
                
                var showFirstBirthday = true
                var loopCheckCount = 0
                for (key ,value) in dictBirthdayValue {
                    if showFirstBirthday == true {
                        if !(removeBirthdayId.contains(key)){
                            
                            birthdayView.isHidden = false
                            let fileUrl = NSURL(string: userBirthdayImage[key] as String? ?? "")
                            
                            
                            birthdayUserimage.kf.indicatorType = .activity
                            (birthdayUserimage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            birthdayUserimage.kf.setImage(with: fileUrl! as URL, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            })
                            birthdayImage.image = UIImage(named: "BirthdayImage.png")
                            birthdayTitle.text = value
                            birthdayTitle.numberOfLines = 2
                            birthdayTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                            birthdayTitle.sizeToFit()
                            birthdayTitle.frame.size.width = view.bounds.width - 2*PADING
                            birthdayUserName.text = userBirthdayName[key] ?? ""//userName[loopCheckCount] as! String
                            //   crossBdayView.isHidden = false
                            crossBdayView.tag = key
                            frndsbirthdayPost.tag = key
                            frndsBirthdayMsg.tag = key
                            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AdvanceActivityFeedViewController.imageTapped(gesture:)))
                            birthdayUserimage.addGestureRecognizer(tapGesture)
                            birthdayUserimage.tag = key
                            birthdayUserimage.isUserInteractionEnabled = true
                            frndsbirthdayPost.addTarget(self, action: #selector(AdvanceActivityFeedViewController.postBirthday(sender:)), for: .touchUpInside)
                            frndsBirthdayMsg.addTarget(self, action: #selector(AdvanceActivityFeedViewController.postMsg(sender:)), for: .touchUpInside)
                            crossBdayView.addTarget(self, action: #selector(AdvanceActivityFeedViewController.RemoveBId(sender:)), for: .touchUpInside)
                            showFirstBirthday = false
                            if key != currentUserId {
                                birthdaybuttonsFrame.isHidden = false
                            }
                            else{
                                birthdaybuttonsFrame.isHidden = true
                            }
                            loopCheckCount = loopCheckCount + 1
                            //                            if isAddFriendWidgetEnable == 1 {
                            //                              self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.birthdayView) + birthdaybuttonsFrame.frame.size.height + 5
                            //                                self.scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView) + 5
                            //                            }
                            
                        }
                        else{
                            loopCheckCount = loopCheckCount + 1
                        }
                        
                    }
                }
                if isVisible(view: birthdaybuttonsFrame){
                    if isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved {
                        self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.greetingsWebView) + 5
                        scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView)
                        tableHeaderHight = postView.frame.size.height + 225 + birthdaybuttonsFrame.frame.size.height + storiesViewHeight + self.noContentView.frame.size.height
                    }
                    else {
                        scrollableCategory.frame.origin.y = postView.frame.size.height + 225 + birthdaybuttonsFrame.frame.size.height + storiesViewHeight
                        tableHeaderHight = postView.frame.size.height + 225 + birthdaybuttonsFrame.frame.size.height + storiesViewHeight
                    }
                    
                    globalFeedHeight = tableHeaderHight
                    feedObj.tableView.reloadData()
                }
                else{
                    if isAddFriendWidgetEnable == 1 {
                        scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView)
                    }
                    else {
                        scrollableCategory.frame.origin.y = postView.frame.size.height + 225 + storiesViewHeight
                    }
                    tableHeaderHight = postView.frame.size.height + 225 + storiesViewHeight
                    if isAddFriendWidgetEnable == 1 {
                        globalFeedHeight = tableHeaderHight + self.noContentView.frame.size.height
                    }
                    else {
                        globalFeedHeight = tableHeaderHight
                    }
                    
                    feedObj.tableView.reloadData()
                }
                
                
                
                
            }
            
            if self.feedObj.tableView.viewWithTag(2017) == nil{
                if isfeedfilter == 1
                {
                    // DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    if isAddFriendWidgetEnable == 1 {
                        tableHeaderHight = self.noContentView.frame.size.height
                        globalFeedHeight = tableHeaderHight
                    }
                    self.showfeedFilter()
                    //  })
                    
                }
            }
        }
        else
        {
            
            if greetingsArray.count > 0  && (removeGreetingsId.count != greetingsArray.count){
                if isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved {
                    self.noContentView.frame.origin.y = getBottomEdgeY(inputView: greetingsWebView) + 2
                    birthdayView.frame.size.height = 0
                    birthdaybuttonsFrame.frame.size.height = 0
                    scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView)
                    tableHeaderHight = getBottomEdgeY(inputView: self.scrollableCategory)
                }
                else {
                    scrollableCategory.frame.origin.y = postView.frame.size.height + greetingsWebView.bounds.height + 5 + storiesViewHeight
                    tableHeaderHight = postView.frame.size.height + greetingsWebView.bounds.height + 10 + storiesViewHeight
                }
                
                globalFeedHeight = tableHeaderHight
                feedObj.tableView.reloadData()
                var counter1 = 0
                greetingsId.removeAll()
                //var greetingsId = [Int]()
                //var body = ""
                for _ in greetingsArray {
                    
                    if let data = UserDefaults.standard.object(forKey: "Greetings\(counter1)") as? NSData{
                        if data.length != 0
                        {
                            counter1 = counter1 + 1
                            
                            let save = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSDictionary
                            
                            greetingsId.append(save["greeting_id"]  as! Int)
                            //body = (save["body"] as! String)
                            dictCheckValue.updateValue(save["body"] as! String, forKey: save["greeting_id"]  as! Int)
                            
                            
                        }
                        
                    }
                }
                
                var showFirstImage = true
                for (key ,value) in dictCheckValue {
                    if showFirstImage == true {
                        if !(removeGreetingsId.contains(key)){
                            let aString = "\(value)"
                            let newString = aString.replacingOccurrences(of: "[USER_NAME]", with: "\(displayName!)", options: .literal, range: nil)
                            greetingsWebView.tag = key
                            //webframe.isHidden = false
                            //greetingsWebView.isHidden = false
                            
                            //    crossView.isHidden = false
                            showFirstImage = false
                            crossView.tag = key
                            crossView.addTarget(self, action: #selector(AdvanceActivityFeedViewController.RemoveId(sender:)), for: .touchUpInside)
                            
//                            let temp = "<head><style>img{max-width:100% !important;height:auto !important}</style></head><body style=\"background-color: transparent;text-align: justify;\">"
//                            let greetingHtml = "\(temp) " + String(newString) + " </body>"
//                            greetingsWebView.loadHTMLString(greetingHtml, baseURL: nil)
                            
                            let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"></HEAD><BODY>"
                            let htmlEnd = "</BODY></HTML>"
                            let htmlString = "\(htmlStart)\(newString)\(htmlEnd)"
                            greetingsWebView.loadHTMLString(htmlString, baseURL: nil)
                            
                            //greetingsWebView.sizeToFit()
                        }
                    }
                }
            }
            
            if self.feedObj.tableView.viewWithTag(2017) == nil{
                if isfeedfilter == 1
                {
                    // DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    
                    self.showfeedFilter()
                    // })
                    
                }
            }
        }
    }
    
    @objc func imageTapped(gesture : UITapGestureRecognizer){
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = "\(gesture.view?.tag)"
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    @objc func postBirthday(sender: UIButton){
        removeBirthdayId.append(sender.tag)
        birthdaybuttonsFrame.isUserInteractionEnabled = false
        let defaults = UserDefaults.standard
        defaults.set(removeBirthdayId, forKey: "SavedbirthdayArray")
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        UserDefaults.standard.setValue(day, forKey: "Bday")
        
        if removeBirthdayId.count == dictBirthdayValue.count {
            crossBdayView.removeFromSuperview()
            birthdayView.removeFromSuperview()
            birthdaybuttonsFrame.removeFromSuperview()
            if isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved{
                self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.postView)
                scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView)
            }
            else {
                scrollableCategory.frame.origin.y = postView.frame.size.height + 5 + storiesViewHeight
            }
            if greetingsArray.count > 0{
                
                tableHeaderHight = postView.frame.size.height + 65 + storiesViewHeight
            }
            else{
                tableHeaderHight = postView.frame.size.height + 8 + storiesViewHeight
            }
            globalFeedHeight = tableHeaderHight
            feedObj.tableView.reloadData()
        }
        
        
        if let newFeedsButton = self.feedObj.tableView.viewWithTag(2017) {
            // myButton already existed
            newFeedsButton.removeFromSuperview()
            
        }
        
        
        
        getUIOfGreetings ()
        
        subject_unique_id = "\(sender.tag)"
        subject_unique_type = "user"
        let presentedVC = AdvancePostFeedViewController()
        presentedVC.postFeedDelegate = self
        presentedVC.isAAFPost = true
        presentedVC.checkfrom = "Greetings"
        presentedVC.openfeedStyle = 0
        presentedVC.delegateQuickContent = self
        let navigationController = UINavigationController(rootViewController: presentedVC)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated:true, completion: nil)
    }
    
    @objc func postMsg(sender: UIButton){
        removeBirthdayId.append(sender.tag)
        birthdaybuttonsFrame.isUserInteractionEnabled = false
        let defaults = UserDefaults.standard
        defaults.set(removeBirthdayId, forKey: "SavedbirthdayArray")
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        UserDefaults.standard.setValue(day, forKey: "Bday")
        
        if removeBirthdayId.count == dictBirthdayValue.count {
            crossBdayView.removeFromSuperview()
            birthdayView.removeFromSuperview()
            birthdaybuttonsFrame.removeFromSuperview()
            if isAddFriendWidgetEnable == 1 {
                scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView)
            }
            else {
                scrollableCategory.frame.origin.y = postView.frame.size.height + 5 + storiesViewHeight
            }
            if greetingsArray.count > 0{
                
                tableHeaderHight = postView.frame.size.height + 65 + storiesViewHeight
            }
            else{
                tableHeaderHight = postView.frame.size.height + 8 + storiesViewHeight
            }
            globalFeedHeight = tableHeaderHight
            feedObj.tableView.reloadData()
            
        }
        
        if let newFeedsButton = self.feedObj.tableView.viewWithTag(2017) {
            // myButton already existed
            newFeedsButton.removeFromSuperview()
            
        }
        
        
        
        getUIOfGreetings ()
        
        if isChannelizeAvailable{
            let data : [AnyHashable:Any] = [AnyHashable("userId"):sender.tag]
            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                    channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: data)
                }
            }
        } else{
            let presentedVC = MessageCreateController()
            presentedVC.checkfrom = "Greetings"
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            presentedVC.userID = "\(sender.tag)"
            presentedVC.fromProfile = true
            if userBirthdayName[sender.tag] != nil && userBirthdayName[sender.tag] != ""   {
                presentedVC.profileName =  userBirthdayName[sender.tag]
            }
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    
    @objc func RemoveBId(sender: UIButton){
        crossBdayView.isHidden = true
        crossView.isHidden = true
        birthdaybuttonsFrame.isUserInteractionEnabled = false
        removeBirthdayId.append(sender.tag)
        let defaults = UserDefaults.standard
        defaults.set(removeBirthdayId, forKey: "SavedbirthdayArray")
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        UserDefaults.standard.setValue(day, forKey: "Bday")
        
        if removeBirthdayId.count == dictBirthdayValue.count {
            crossBdayView.removeFromSuperview()
            birthdayView.removeFromSuperview()
            birthdaybuttonsFrame.removeFromSuperview()
            
            if isAddFriendWidgetEnable == 1 && self.noContentView.isHidden == false && !self.friendWidgetRemoved{
                self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.postView) + 5
                scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView) + 5
            }
            else {
                scrollableCategory.frame.origin.y = postView.frame.size.height + 5 + storiesViewHeight
            }
            if greetingsArray.count > 0{
                
                tableHeaderHight = postView.frame.size.height + 8 + storiesViewHeight
            }
            else{
                tableHeaderHight = postView.frame.size.height + 8 + storiesViewHeight
                
            }
            if isAddFriendWidgetEnable == 1 {
                tableHeaderHight = tableHeaderHight + self.noContentView.frame.size.height
            }
            globalFeedHeight = tableHeaderHight
            feedObj.tableView.reloadData()
            
            
        }
        
        if let newFeedsButton = self.feedObj.tableView.viewWithTag(2017) {
            // myButton already existed
            newFeedsButton.removeFromSuperview()
            
        }
        
        getUIOfGreetings ()
        
    }
    
    @objc func RemoveId(sender: UIButton){
        crossView.isHidden = true
        removeGreetingsId.append(sender.tag)
        let defaults = UserDefaults.standard
        defaults.set(removeGreetingsId, forKey: "SavedGreetingsArray")
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        UserDefaults.standard.setValue(day, forKey: "Gday")
        if removeGreetingsId.count == dictCheckValue.count {
            greetingsWebView.isHidden = true
            crossView.removeFromSuperview()
            greetingsWebView.removeFromSuperview()
            webframe.removeFromSuperview()
            if isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved {
                self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.postView) + 5
                scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView) + 5
                tableHeaderHight = getBottomEdgeY(inputView: self.scrollableCategory)
            }
            else {
                scrollableCategory.frame.origin.y = postView.frame.size.height + 8 + storiesViewHeight
                tableHeaderHight = postView.frame.size.height + 65 + storiesViewHeight
            }
            globalFeedHeight = tableHeaderHight
            feedObj.tableView.reloadData()
            //                showfeedFilter()
            
            
        }
        else{
            
            self.webframe.frame.size.height = 1
            self.greetingsWebView.frame.size.height = 1
            if let newFeedsButton = self.feedObj.tableView.viewWithTag(2017) {
                // myButton already existed
                newFeedsButton.removeFromSuperview()
                
            }
        }
        
        
        getUIOfGreetings ()
        
        
        
    }
    
    @objc func applicationWillEnterForeground(_ application: UIApplication) {
        
        checkapp()
        // checkLiveTimeSetting()
        if setLocation == true && locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1{
            if (CLLocationManager.locationServicesEnabled())
            {
                let defaults = UserDefaults.standard
                switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    //  //print("No access")
                    if AppLauchForLocation == true {
                        AppLauchForLocation = false
                        // At the time of app installation , user also login at time ios default pop up show , so first time we don't show our custom pop-up
                        if defaults.bool(forKey: "showMsg")
                        {
                            currentLocation(controller: self)
                        }
                        setLocation = true
                        defaults.set(true, forKey: "showMsg")
                    }
                case .authorizedAlways, .authorizedWhenInUse:
                    //   //print("Access")
                    if updateLocation == false
                    {
                        setLocation = true
                    }
                }
                
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.requestWhenInUseAuthorization()
                locationManager.startUpdatingLocation()
            }
            else
            {
                if AppLauch == true {
                    setLocation = true
                    AppLauch = false
                    gpsLocation(controller: self)
                }
            }
        }
    }
    
    @objc func viewProfileClicked(notification: Notification) {
        if let userId = notification.userInfo?["userId"] as? String {
            // do something with your user Id
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = userId
            presentedVC.fromActivity = false
            searchDic.removeAll(keepingCapacity: false)
            presentedVC.hidesBottomBarWhenPushed = true
            presentedVC.showTabBar = false
            //presentedVC.hidest
            //let nativationController = UINavigationController(rootViewController: presentedVC)
            //nativationController.hidesBottomBarWhenPushed = true
            let controller = notification.userInfo?["controller"] as? UINavigationController
            //controller?.hidesBottomBarWhenPushed = true
            //controller?.present(nativationController,animated:true,completion:nil)
            controller?.pushViewController(presentedVC, animated: true)
            
        }else{
            let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                channelizeClass.getMessageCount(completion: {(count) in
                    messageCount = count
                    if messageIndex > 0{
                        baseController.tabBar.items?[messageIndex].badgeValue = messageCount > 0 ? "\(messageCount)" : nil
                    }
                })
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let userLocation :CLLocation = locations[0] as CLLocation
        if didFindLocation == false && setLocation == true
        {
            updateLocation = true
            setLocation = false
            self.didFindLocation = true
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
                if (error != nil){
                    //print("error in reverseGeocode")
                }
                
                if placemarks != nil {
                    let placemark = placemarks! as [CLPlacemark]
                    
                    if placemark.count>0{
                        let placemark = placemarks![0]
                        // //print("\(placemarks!)")
                        var place : String = ""
                        var subLocality : String = ""
                        var locality : String = ""
                        var administrativeArea : String = ""
                        var country : String = ""
                        var postalCode : String = ""
                        
                        var state : String = ""
                        var city : String = ""
                        var countryCode : String = ""
                        
                        if placemark.addressDictionary != nil
                        {
                            
                            if let State = placemark.addressDictionary!["State"] as? String
                            {
                                state = State
                            }
                            
                            if let City = placemark.addressDictionary!["City"] as? String
                            {
                                city = City
                            }
                            
                            if let cd = placemark.addressDictionary!["CountryCode"] as? String
                            {
                                countryCode = cd
                            }
                            
                            if let FormattedAddressLines = placemark.addressDictionary!["FormattedAddressLines"] as? NSArray
                            {
                                if let pla = FormattedAddressLines[0] as? String
                                {
                                    place = pla
                                }
                            }
                            
                        }
                        
                        if placemark.postalCode != nil
                        {
                            postalCode = placemark.postalCode!
                        }
                        
                        
                        let defaults = UserDefaults.standard
                        
                        // //print(postalCode)
                        var prePostalCode = defaults.string(forKey:"postalCode")
                        if prePostalCode == nil
                        {
                            prePostalCode = "0"
                        }
                        //  //print(prePostalCode!)
                        //                        postalCode != prePostalCode! && locationOnhome == 1
                        if locationOnhome == 1 && isChangeManually == 1 && autodetectLocation == 1
                        {
                            
                            if placemark.country != nil
                            {
                                country = placemark.country!
                            }
                            
                            if placemark.subLocality != nil
                            {
                                subLocality = placemark.subLocality!
                                defaultlocation = "\(subLocality),"
                            }
                            else if place != ""
                            {
                                defaultlocation = "\(place),"
                            }
                            if placemark.locality != nil
                            {
                                locality = placemark.locality!
                                defaultlocation.append(" \(locality)")
                            }
                            else if placemark.administrativeArea != nil
                            {
                                administrativeArea = placemark.administrativeArea!
                                defaultlocation.append(" \(administrativeArea)")
                            }
                            else if placemark.country != nil
                            {
                                country = placemark.country!
                                defaultlocation.append(" \(country)")
                            }
                            
                            defaults.set(postalCode, forKey: "postalCode")
                            
                            defaults.set(defaultlocation, forKey: "Location")
                            //self.view.makeToast(NSLocalizedString("Your current location is set to ",comment: "")+"\(defaultlocation).", duration: 5, position: "bottom")
                            showToast(message: NSLocalizedString("Your current location is set to ",comment: "")+"\(defaultlocation).", controller: self)
                            let location = locations.last! as CLLocation
                            let currentLatitude = location.coordinate.latitude
                            let currentLongitude = location.coordinate.longitude
                            
                            defaults.set(currentLatitude, forKey: "Latitude")
                            defaults.set(currentLongitude, forKey: "Longitude")
                            
                            // //print(currentLatitude)
                            // //print(currentLongitude)
                            
                            setDeviceLocation(location: defaultlocation, latitude: currentLatitude, longitude: currentLongitude, country: country, state: state, zipcode: postalCode, city: city, countryCode: countryCode)
                        }
                    }
                }
                
            }
        }
    }
    
    
    func showfeedFilter()
    {
        
        let buttonPadding:CGFloat = 0
        var xOffset:CGFloat = 0
        //  if logoutUser == false {
        if let newFeedsButton = self.feedObj.tableView.viewWithTag(2017) {
            // myButton already existed
            newFeedsButton.removeFromSuperview()
            
        }
        //  }
        
        if isfeedfilter == 1
        {
            if logoutUser == true
            {
                tableHeaderHight = 5
            }
            
            crossBdayView.isHidden = false
            crossView.isHidden = false
            birthdaybuttonsFrame.isUserInteractionEnabled = true
            scrollableCategory = UIScrollView(frame: CGRect(x: 0, y: tableHeaderHight , width: view.bounds.width, height: 60))
            view.addSubview(scrollableCategory)
            scrollableCategory.tag = 2017
            scrollableCategory.translatesAutoresizingMaskIntoConstraints = false
            scrollableCategory.showsHorizontalScrollIndicator = false
            var i = 0
            let width = (scrollableCategory.frame.size.width)/5
            let height: CGFloat = 60
            
            var viewFilter = UIView()
            if logoutUser && gutterMenu1.count < 1 {
                self.gutterMenu1 = feedFilterAsGuest
            }
            for menu in gutterMenu1{
                if let dic = menu as? NSDictionary{
                    
                    if let dicparam = dic["urlParams"] as? NSDictionary
                    {
                        if let filtertype = dicparam["filter_type"] as? String
                        {
                            if i < 4
                            {
                                
                                
                                viewFilter = createView(CGRect(x: xOffset, y: CGFloat(buttonPadding), width: width, height: height), borderColor: UIColor.clear, shadow: false)
                                viewFilter.tag = i
                                scrollableCategory.addSubview(viewFilter)
                                
                                let button   = UIButton()
                                button.tag = i
                                button.addTarget(self, action: #selector(AdvanceActivityFeedViewController.feedFilterAction(sender:)), for: .touchUpInside)
                                button.frame = CGRect(x: width/2 - 17, y: 5, width: 35, height: 35)
                                button.titleLabel?.font = UIFont(name: "FontAwesome", size: 14.0)
                                button.alpha = 0.3
                                button.layer.cornerRadius =  button.bounds.size.width/2
                                button.clipsToBounds = true
                                
                                switch filtertype {
                                case "all":
                                    button.setTitle("\u{f0ac}", for: .normal)
                                    button.backgroundColor = color7
                                    button.titleLabel?.font = UIFont(name: "FontAwesome", size: 18.0)
                                    button.alpha = 0.8
                                    break
                                    
                                case "membership":
                                    button.setTitle("\u{f2c0}", for: .normal)
                                    button.backgroundColor = colorFriends
                                    break
                                    
                                case "photo":
                                    
                                    button.setTitle("\u{f03e}", for: .normal)
                                    button.backgroundColor = colorPhoto
                                    break
                                    
                                case "video":
                                    button.setTitle("\u{f03d}", for: .normal)
                                    button.backgroundColor = colorVideo
                                    break
                                    
                                case "sitepage":
                                    button.setTitle("\u{f15c}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "posts":
                                    button.setTitle("\u{f03e}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitenews":
                                    button.setTitle("\u{f09e}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "siteevent":
                                    button.setTitle("\u{f073}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "group":
                                    button.setTitle("\u{f0c0}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "hidden_post":
                                    button.setTitle("\u{f070}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "schedule_post":
                                    button.setTitle("\u{f03d}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "memories":
                                    button.setTitle("\u{f274}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "like":
                                    button.setTitle("\u{f164}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "advertise":
                                    button.setTitle("\u{f03d}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "classified":
                                    button.setTitle("\u{f03a}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "poll":
                                    button.setTitle("\u{f080}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitestore":
                                    button.setTitle("\u{f290}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitestoreproduct":
                                    button.setTitle("\u{f291}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "user_saved":
                                    button.setTitle("\u{f0c7}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                    
                                case "sitereview_listtype_11":
                                    button.setTitle("\u{f040}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitereview_listtype_14":
                                    button.setTitle("\u{f03d}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "music":
                                    button.setTitle("\u{f001}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitereview_listtype_19":
                                    button.setTitle("\u{f072}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                    
                                case "sitereview_listtype_18":
                                    button.setTitle("\u{f15c}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitereview_listtype_20":
                                    button.setTitle("\u{f0f2}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "network_list":
                                    button.setTitle("\u{f03d}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                case "sitetagcheckin":
                                    button.setTitle("\u{f041}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                default:
                                    button.setTitle("\u{f17d}", for: .normal)
                                    button.backgroundColor = UIColor.purple
                                    break
                                    
                                }
                                
                                viewFilter.addSubview(button)
                                let titlelbl = UILabel()
                                titlelbl.tag = i
                                titlelbl.text = (dic["tab_title"] as! String)
                                titlelbl.font = UIFont(name: fontName, size: FONTSIZEMedium - 2)
                                titlelbl.frame = CGRect(x: 0, y: button.frame.size.height + button.frame.origin.y - 0, width: width, height: 20)
                                titlelbl.textColor = textColorMedium
                                titlelbl.textAlignment = .center
                                titlelbl.backgroundColor = textColorLight
                                viewFilter.addSubview(titlelbl)
                                xOffset = xOffset + width
                                i = i+1
                            }
                        }
                    }
                    
                }
            }
            
            viewFilter = createView(CGRect(x: xOffset, y: CGFloat(buttonPadding), width: width, height: height), borderColor: UIColor.clear, shadow: false)
            viewFilter.tag = i
            scrollableCategory.addSubview(viewFilter)
            let button   = UIButton()
            button.tag = i
            button.addTarget(self, action: #selector(AdvanceActivityFeedViewController.showFeedFilterOptions(sender:)), for: .touchUpInside)
            button.frame = CGRect(x: width/2 - 17, y: 5, width: 35, height: 35)
            button.titleLabel?.font = UIFont(name: "FontAwesome", size: 18.0)
            button.setTitle(optionIcon, for: .normal)
            button.alpha = 0.3
            button.layer.cornerRadius =  button.bounds.size.width/2
            button.clipsToBounds = true
            //  button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0)
            button.backgroundColor = colorFriends
            viewFilter.addSubview(button)
            if gutterMenu1.count < 5 {
                button.isEnabled = false
            }
            else {
                button.isEnabled = true
            }
            let titlelbl = UILabel()
            titlelbl.tag = i
            titlelbl.text = NSLocalizedString("More",comment: "")
            titlelbl.font = UIFont(name: fontName, size: FONTSIZEMedium - 2)
            titlelbl.frame = CGRect(x: 0, y: button.frame.size.height + button.frame.origin.y - 0, width: width, height: 20)
            titlelbl.textColor = textColorMedium
            titlelbl.textAlignment = .center
            titlelbl.backgroundColor = textColorLight
            viewFilter.addSubview(titlelbl)
            xOffset = xOffset + width
            i = i+1
            scrollableCategory.contentSize = CGSize(width: xOffset, height: scrollableCategory.frame.height)
            feedObj.tableView.addSubview(scrollableCategory)
            tableHeaderHight = tableHeaderHight + scrollableCategory.frame.size.height
            // if logoutUser == false {
            if isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved {
                noContentView.frame.size.height = 100
                noContentView.backgroundImage.frame.size.height = 100
                noContentView.findFriendsLabel.frame.origin.y = 2
                noContentView.imageView.frame.origin.y = getBottomEdgeY(inputView: noContentView.findFriendsLabel) + 5
                noContentView.descriptionLabel.frame.origin.y = noContentView.imageView.frame.origin.y
                noContentView.button.frame.origin.y = noContentView.imageView.frame.origin.y + 15
                noContentView.crossButton.frame.origin.y = 1
                noContentView.crossButton.isHidden = false
                if birthdayView.isHidden == false {
                    self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.birthdayView) + self.birthdaybuttonsFrame.frame.size.height + 5
                }
                else if birthdayView.isHidden == true && greetingsWebView.isHidden == false {
                    self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.postView) + 5 + webframe.frame.size.height
                }
                    
                else {
                    self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.postView) + 5
                }
                //                if birthdaybuttonsFrame.frame.size.height > 5 {
                //                    self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.greetingsWebView) + 5
                //                }
                scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView) + 5
                tableHeaderHight = getBottomEdgeY(inputView: scrollableCategory) + 5
                self.noContentView.isHidden = false
            }
            globalFeedHeight = tableHeaderHight
            feedObj.tableView.reloadData()
            // }
        }
        
    }
    // MARK: - Activity Feed Filter Options & Gutter Menu
    
    // Show Feed Filter Options Action for more options
    @objc func showFeedFilterOptions(sender: UIButton){
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        let currentButton = sender as UIButton
        currentButton.isHighlighted = true
        if currentButton.isHighlighted == true
        {
            currentButton.alpha = 0.8
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        var i = 0
        for menu in gutterMenu1{
            if let dic = menu as? NSDictionary
            {
                self.feedFilterFlag = true
                if i >= 4
                {
                    alertController.addAction(UIAlertAction(title: (dic["tab_title"] as? String ?? ""), style: .default, handler:{ (UIAlertAction) -> Void in
                        if isAddFriendWidgetEnable == 0 {
                            self.noContentView.isHidden = true
                        }
                        let views = self.scrollableCategory.subviews
                        for obj in views
                        {
                            if (obj .isKind(of: UIView.self))
                            {
                                let buttons = obj.subviews
                                for obj in buttons
                                {
                                    if (obj .isKind(of: UIButton.self))
                                    {
                                        if obj != currentButton
                                        {
                                            (obj as! UIButton).isHighlighted = false
                                            (obj as! UIButton).alpha = 0.3
                                        }
                                    }
                                }
                            }
                            
                        }
                        
                        // Set Parameters for Feed Filter
                        if let params = dic["urlParams"] as? NSDictionary{
                            for (key, value) in params
                            {
                                if let id = value as? NSNumber {
                                    searchDic["\(key)"] = String(id as? Int ?? 0)
                                }
                                
                                if let receiver = value as? NSString {
                                    searchDic["\(key)"] = receiver as String
                                }
                                filterSeachDic = searchDic
                            }
                        }
                        // Make Hard Refresh request for selected Feed Filter & Reset all VAriable
                        feedArray.removeAll(keepingCapacity: false)
                        self.dynamicRowHeight.removeAll(keepingCapacity: false)
                        self.maxid = 0
                        maxidTikTok = 0
                        self.feed_filter = 1
                        self.showSpinner = true
                        self.browseFeed()
                        self.API_getAAFList()
                        
                    }))
                }
                i = i+1
            }
            
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:{ (action: UIAlertAction!) in
                
                currentButton.isHighlighted = false
                if currentButton.isHighlighted == false
                {
                    currentButton.alpha = 0.4
                }
                
            }))
        }
        else
        {
            // Present Alert as! Popover for iPad
            if let popoverController = alertController.popoverPresentationController {
                showIpadActionSheet(sourceView: self.view, popoverController: popoverController)
            }
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    
    
    
    func checkAndAskForReview ()
    {
        guard let appOpenCount = Defaults.value(forKey: UserDefaultsKeys.APP_OPENED_COUNT) as? Int else {
            Defaults.set(1, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
            return
        }
        
        switch(appOpenCount)
        {
        case _ where appOpenCount % 30 == 0 :
            requestReview()
        default :
            ////print("App Run Count is : \(appOpenCount)")
            break
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
            let alert = UIAlertController(title: "Rate App", message: "Are you enjoying the app? Please rate our app", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Not Now", style: .cancel, handler: nil)
            let action2 = UIAlertAction(title: "Rate Now", style: .default, handler: {
                (UIAlertAction) -> Void in
                
                UserDefaults.standard.setValue("Yes", forKey: "isAppRated")
                let mainId = String(appId)
                let appURLString: String
                appURLString = "itms-apps://itunes.apple.com/app/id\(mainId)?mt=8&action=write-review"
                UIApplication.shared.openURL(URL(string: appURLString)!)
            })
            alert.addAction(action1)
            alert.addAction(action2)
            self.present(alert, animated: true, completion: nil)
        }
        //AdvanceActivityFeedViewController().rateApp()
        //ConfigurationFormViewController().rateApp()
    }
    
    
    func rateApp ()
    {
        let alert = UIAlertController(title: "Rate App", message: "Are you enjoying the app? Please rate our app", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Not Now", style: .cancel, handler: nil)
        let action2 = UIAlertAction(title: "Rate Now", style: .default, handler: {
            (UIAlertAction) -> Void in
            let appURLString: String
            appURLString = "https://itunes.apple.com/us/app/fellopages/id1250487313?mt=8"
            UIApplication.shared.openURL(URL(string: appURLString)!)
        })
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func feedFilterAction(sender : UIButton)
    {
        self.noPostViewSet = false
        if isAddFriendWidgetEnable == 0 {
            noContentView.isHidden = true
        }
        let currentButton = sender as UIButton
        currentButton.isHighlighted = true
        if currentButton.isHighlighted == true
        {
            currentButton.alpha = 0.8
        }
        let views = scrollableCategory.subviews
        for obj in views
        {
            if (obj .isKind(of: UIView.self))
            {
                let buttons = obj.subviews
                for obj in buttons
                {
                    if (obj .isKind(of: UIButton.self))
                    {
                        if obj != currentButton
                        {
                            (obj as! UIButton).isHighlighted = false
                            (obj as! UIButton).alpha = 0.3
                        }
                    }
                }
            }
            
        }
        searchDic.removeAll(keepingCapacity: false)
        if let dic = gutterMenu1[sender.tag] as? NSDictionary
        {
            self.feedFilterFlag = true
            // Set Parameters for Feed Filter
            if let params = dic["urlParams"] as? NSDictionary{
                for (key, value) in params{
                    if let id = value as? NSNumber {
                        searchDic["\(key)"] = String(id as? Int ?? 0)
                    }
                    
                    if let receiver = value as? NSString {
                        searchDic["\(key)"] = receiver as String
                    }
                    filterSeachDic = searchDic
                }
            }
            
            // Make Hard Refresh request for selected Feed Filter & Reset all VAriable
            feedArray.removeAll(keepingCapacity: false)
            self.dynamicRowHeight.removeAll(keepingCapacity: false)
            self.maxid = 0
            maxidTikTok = 0
            self.feed_filter = 1
            removeQuickContentPost()
            self.showSpinner = true
            self.browseFeed()
            self.API_getAAFList()
        }
        
        
    }
    
    func setNavigationcontroller()
    {
        
        self.navigationItem.title = app_title
        setNavigationImage(controller: self)
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvanceActivityFeedViewController.openSlideMenu))
        leftNavView.addGestureRecognizer(tapView)
        
        if (logoutUser == false && (totalNotificationCount !=  nil) && (totalNotificationCount > 0))
        {
            let countLabel = createLabel(CGRect(x:17,y:3,width:17,height:17), text: String(totalNotificationCount), alignment: .center, textColor: textColorLight)
            countLabel.backgroundColor = UIColor.red
            countLabel.layer.cornerRadius = countLabel.frame.size.width / 2;
            countLabel.layer.masksToBounds = true
            countLabel.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
            leftNavView.addSubview(countLabel)
        }
        
        // self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    
    func browseEmoji(contentItems: NSDictionary)
    {
        scrollViewEmoji.backgroundColor = .clear
        arrowView.backgroundColor = .clear
        for ob in scrollViewEmoji.subviews{
            ob.removeFromSuperview()
            arrowView.removeFromSuperview()
        }
        scrollViewEmoji.backgroundColor = .clear
        arrowView.backgroundColor = .clear
        if let allReactionsValueDic = sortedReactionDictionary(dic: contentItems) as? Dictionary<String, AnyObject>
        {
            let space:CGFloat = 15
            let vSpace:CGFloat = 9
            let viewWidth = self.view.frame.width - 12
            let iconHeight = (viewWidth/6) - (space*7)/6
            let viewHeight = iconHeight + (2*vSpace)
            scrollViewEmoji.frame = CGRect(x:0,y: 0,width: viewWidth,height: viewHeight)
            arrowView.frame = CGRect(x: 0, y: 0, width: 14, height: 10)
            scrollViewEmoji.backgroundColor = UIColor.black.withAlphaComponent(0.85)//UIColor.clear
            arrowView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
            scrollViewEmoji.layer.cornerRadius = CGFloat(viewHeight/2)
            var menuWidth = CGFloat()
            var origin_x:CGFloat = 15
            var i : Int = 0
            for key in allReactionsValueDic.keys.sorted(by: <) {
                if let   v = allReactionsValueDic[key]
                {
                    
                    if let icon = v["icon"] as? NSDictionary{
                        
                        menuWidth = iconHeight
                        let   emoji = createButton(CGRect(x: origin_x,y: vSpace,width: iconHeight,height: iconHeight), title: "", border: false, bgColor: false, textColor: textColorLight)
                        emoji.addTarget(self, action: #selector(AdvanceActivityFeedViewController.feedMenuReactionLike(sender:)), for: .touchUpInside)
                        emoji.tag = v["reactionicon_id"] as? Int ?? 0
                        if let imageUrl = icon["reaction_image_large_icon"] as? String
                        {
                            let url = NSURL(string:imageUrl)
                            if url != nil
                            {
                                emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                })
                            }
                        }
                        else if let imageUrl = icon["reaction_image_icon"] as? String
                        {
                            let url = NSURL(string:imageUrl)
                            if url != nil
                            {
                                emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                })
                            }
                        }
                        
                        emoji.imageView?.contentMode = .scaleAspectFit
                        scrollViewEmoji.addSubview(emoji)
                        origin_x = origin_x + menuWidth + CGFloat(space)
                        i = i + 1
                    }
                    
                }
            }
            scrollViewEmoji.contentSize = CGSize(width: origin_x, height: CGFloat(viewHeight))
            scrollViewEmoji.bounces = false
            scrollViewEmoji.isUserInteractionEnabled = true
            scrollViewEmoji.showsVerticalScrollIndicator = false
            scrollViewEmoji.showsHorizontalScrollIndicator = true
            scrollViewEmoji.alwaysBounceHorizontal = true
            scrollViewEmoji.alwaysBounceVertical = false
            scrollViewEmoji.isDirectionalLockEnabled = true;
            scrollViewEmoji.isHidden = true
            arrowView.isHidden = true
        }
    }
    
    
    func animateReaction() {
        arrowView.isHidden = true
        let frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        let image = reactionButtonImage.imageView?.image
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        imageView.center = (self.view.parentViewController()?.view.center)!
        imageView.isHidden = false
        view.addSubview(imageView)
        view.bringSubviewToFront(imageView)
        imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            imageView.transform = .identity
        }, completion: { (_) in
            imageView.isHidden = true
            imageView.removeFromSuperview()
        }
        )
    }
    
    
    @objc func feedMenuReactionLike(sender:UIButton){
        reactionButtonImage = sender
        arrowView.isHidden = true
        if  let feed = feedArray[scrollViewEmoji.tag] as? NSDictionary
        {
            let action_id = feed["action_id"] as? Int ?? 0
            if openSideMenu{
                openSideMenu = false
                
                return
            }
            animateReaction()
            
            var reaction = ""
            for (_,v) in reactionsDictionary
            {
                var updatedDictionary = Dictionary<String, AnyObject>()
                if let v = v as? NSDictionary
                {
                    if  let reactionId = v["reactionicon_id"] as? Int
                    {
                        if reactionId == sender.tag
                        {
                            
                            reaction = (v["reaction"] as? String ?? "")
                            updatedDictionary["reactionicon_id"] = v["reactionicon_id"]  as AnyObject?
                            updatedDictionary["caption" ] = v["caption"]  as AnyObject?
                            if let icon  = v["icon"] as? NSDictionary{
                                
                                updatedDictionary["reaction_image_icon"] = icon["reaction_image_icon"]  as AnyObject?
                                
                            }
                            var url = ""
                            url = "advancedactivity/like"
                            DispatchQueue.main.async(execute: {
                                soundEffect("Like")
                            })
                            
                            feedObj.updateReaction(url: url, reaction: reaction, action_id: action_id, updateMyReaction: updatedDictionary as NSDictionary, feedIndex: scrollViewEmoji.tag)
                            
                        }
                    }
                }
            }
        }
    }
    
    @objc func LocationAction()
    {
        if Locationdic != nil
        {
            if let type = Locationdic["locationType"] as? String
            {
                if type == "notspecific"
                {
                    let view = BrowseLocationViewController()
                    view.iscomingFrom = "feed"
                    self.navigationController?.pushViewController(view, animated: true)
                    
                }
                else
                {
                    let view = BrowseSpecificLocationViewController()
                    view.iscomingFrom = "feed"
                    self.navigationController?.pushViewController(view, animated: true)
                }
            }
        }
    }
    func messageAction()
    {
        let VC = MessageViewController()
        self.navigationController?.pushViewController(VC, animated: true)
    }
    @objc func userLoggedIn(_ notification: NSNotification)
    {
        getLocationdata()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "UserLoggedIn"), object: nil)
    }
    func getheaderSetting()
    {
        if isshow_app_name == 0
        {
            let searchBar = UISearchBar()
            if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
                textfield.textColor = UIColor.blue
                textfield.textAlignment = .center
                if let backgroundview = textfield.subviews.first {
                    
                    // Rounded corner
                    backgroundview.layer.cornerRadius = 15
                    backgroundview.clipsToBounds = true
                    backgroundview.backgroundColor = UIColor.clear
                    
                }
            }
            _ = SearchBarContainerView(self, customSearchBar:searchBar, isKeyboardAppear:false)
            searchBar.setPlaceholderWithColor(NSLocalizedString("Search",  comment: ""))
            searchBar.delegate = self
            
            
            setNavigationImage(controller: self)
            
        }
    }
    func getLocationdata()
    {
        
        if isshow_app_name == 0
        {
            if Locationdic != nil
            {
                if locationOnhome == 1 && isChangeManually == 1
                {
                    
                    let button   = UIButton(type: UIButton.ButtonType.system) as UIButton
                    button.frame = CGRect(x: self.view.bounds.size.width-100,y: 0,width: 18,height: 18)
                    button.backgroundColor = UIColor.clear
                    let loctionimg = UIImage(named: "Location")!.maskWithColor(color: textColorPrime)
                    button.setImage(loctionimg , for: UIControl.State.normal)
                    button.addTarget(self, action: #selector(AdvanceActivityFeedViewController.LocationAction), for: UIControl.Event.touchUpInside)
                    let locButton = UIBarButtonItem()
                    locButton.customView = button
                    self.navigationItem.setRightBarButtonItems([locButton], animated: true)
                    
                }
                
            }
        }
        else
        {
            
            if Locationdic != nil
            {
                if locationOnhome == 1 && isChangeManually == 1
                {
                    
                    let searchIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvanceActivityFeedViewController.searchItem))
                    let button   = UIButton(type: UIButton.ButtonType.system) as UIButton
                    button.frame = CGRect(x: self.view.bounds.size.width-100,y: 0,width: 20,height: 20)
                    button.backgroundColor = UIColor.clear
                    let loctionimg = UIImage(named: "Location")!.maskWithColor(color: textColorPrime)
                    button.setImage(loctionimg , for: UIControl.State.normal)
                    button.addTarget(self, action: #selector(AdvanceActivityFeedViewController.LocationAction), for: UIControl.Event.touchUpInside)
                    let locButton = UIBarButtonItem()
                    locButton.customView = button
                    self.navigationItem.setRightBarButtonItems([searchIcon,locButton], animated: true)
                    
                    
                }
                else
                {
                    let searchIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvanceActivityFeedViewController.searchItem))
                    self.navigationItem.rightBarButtonItem = searchIcon
                    
                }
            }
            else
            {
                let searchIcon = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(AdvanceActivityFeedViewController.searchItem))
                self.navigationItem.rightBarButtonItem = searchIcon
                
            }
        }
        
        
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if openSideMenu{
            openSideMenu = false
            
            return
            
        }
        DispatchQueue.main.async {
            let pv = CoreAdvancedSearchViewController()
            feedUpdate = false
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(pv, animated: false)
        }
        
        
    }
    
    // Show Post Feed Option Selection (Status, Photos, Checkin)
    @objc func openPostFeed(sender:UIButton){
        
        if (sender.tag - 1990) == 1  && AgoraId != "" && enableLiveStreaming == true{
            let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            if let liveStreamingClass = NSClassFromString(moduleName + "." + "LiveObjectViewController") as? LiveStreamingObjectDelegates.Type{
                liveStreamingClass.redirectToPreview(self)
            }
        }
        else{
            if openSideMenu
            {
                openSideMenu = false
                
                return
            }
            stopMyTimer()
            
            likeCommentContentType = ""
            likeCommentContent_id = ""
            
            let presentedVC = AdvancePostFeedViewController()
            UserDefaults.standard.setValue("everyone", forKey: "privacy")
            presentedVC.isAAFPost = true
            presentedVC.postFeedDelegate = self
            presentedVC.delegateQuickContent = self
            if enableLiveStreaming && sender.tag == 1993 {
                presentedVC.openfeedStyle = (sender.tag - 1992)
            }
            else {
                presentedVC.openfeedStyle = (sender.tag - 1990)
            }
            
            let navigationController = UINavigationController(rootViewController: presentedVC)
            navigationController.modalPresentationStyle = .fullScreen
            if presentedVC.openfeedStyle == 3 {
                presentedVC.isCheckIn = true
            }
            self.present(navigationController, animated:true, completion: nil)
                
            
        }
        
    }
    
    // Show Slide Menu
    @objc func openSlideMenu(){
        let dashObj = DashboardViewController()
        dashObj.getDynamicDashboard()
        dashObj.dashboardTableView.reloadData()
        //
        openSideMenu = true
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            
            openMenu = false
            openMenuSlideOnView(mainView)
            mainView.removeGestureRecognizer(tapGesture)
            
        }
    }
        
    func viewWillLoadData()
    {
        
        if feedPostMenu == false
        {
            
            if logoutUser == false
            {
                //Stories View
                if show_story == 1
                {
                    self.storiesViewHeight = 115.0
                    self.storiesView?.frame.origin.y = 0
                }
                else
                {
                    self.storiesViewHeight = 0.0
                }
                self.postView.isHidden = true
                self.postView.frame.size.height = 0
                
                if self.birthdayView.isHidden == true{
                    self.birthdayView.frame.origin.y = 0
                    self.birthdaybuttonsFrame.frame.origin.y = 0
                }
                else
                {
                    self.birthdayView.frame.origin.y = self.postView.frame.size.height + 5 + self.storiesViewHeight
                    self.birthdaybuttonsFrame.frame.origin.y = 215 + self.postView.frame.size.height + 5 + self.storiesViewHeight
                }
                self.webframe.frame.origin.y = self.postView.frame.size.height + 7 + self.storiesViewHeight
                
                self.tableHeaderHight = self.storiesViewHeight + 5 + self.postView.frame.size.height + 7 + self.webframe.frame.size.height
                globalFeedHeight = self.tableHeaderHight
                
            }
            if browseAsGuest {
                browseFeed()
            }
            if isAddFriendWidgetEnable == 1 {
                self.tableHeaderHight = tableHeaderHight + self.noContentView.frame.size.height
                globalFeedHeight = self.tableHeaderHight
                
            }
            self.showfeedFilter()
        }
        
        startMyTimer()
        API_getStoryCreate()
        UserDefaults.standard.removeObject(forKey: "SellSomething")
        if greetingsCheck == true {
            greetingsCheck = false
            getUIOfGreetings ()
        }
        //rateApp()
        if openAppRating
        {
            openAppRating = false
            if isEnableRate == 1 {
                checkAndAskForReview()
            }
            
        }
        
        // hidingNavBarManager?.viewWillAppear(animated)
        ScheduleDisctionary.removeAll()
        TargetDictionary.removeAll()
        removeNavigationViews(controller: self)
        feedObj.feedShowingFrom = "ActivityFeed"
        if conditionalProfileForm == "AAF"
        {
            IsRedirctToProfile()
        }
        self.browseEmoji(contentItems: reactionsDictionary)
        self.getLikeIconImage(contentItems: reactionsDictionary)
        tableViewFrameType = "AdvanceActivityFeedViewController"
        
        setNavigationImage(controller: self)
        self.navigationItem.title = app_title
        videoAttachFromAAF = ""
        openSideMenu = false
        subject_unique_type = nil
        subject_unique_id = nil
        if isQuickContentInProcess == 0
        {
            if feedUpdate == true
            {
                // Set Default & request to hard Refresh
                
                globalFeedHeight = tableHeaderHight
                self.feedObj.refreshLikeUnLike = true
                self.feedObj.tableView.reloadData()
                feedUpdate = false
                maxid = 0
                maxidTikTok = 0
                showSpinner = true
                feed_filter = 1
                browseFeed()
            }
            else
            {
                globalFeedHeight = tableHeaderHight
                if checkQuickContentPostExist() == false
                {
                    feedArray = feedArrayTemp + feedArray
                }
                self.feedObj.globalArrayFeed = feedArray
                if !fromExternalWebView{
                    self.feedObj.refreshLikeUnLike = true
                    self.feedObj.tableView.reloadData()
                    //                    delay(0.5) {
                    //                        self.feedObj.playPlayeVideos()
                    //                    }
                    
                }else{
                    fromExternalWebView = false
                }
                
            }
        }
    }
    
    func checkQuickContentPostExist()-> Bool
    {
        for activityFeed in feedArray
        {
            if let t = activityFeed["isDummyResponse"] as? Int
            {
                return true
            }
        }
        if feedArrayTemp.count == 0
        {
            return true
        }
        return false
    }
    
    func removeQuickContentPost()
    {
        feedArrayTemp.removeAll()
        for (index,activityFeed) in feedArray.enumerated()
        {
            if let t = activityFeed["isDummyResponse"] as? Int
            {
                feedArray.remove(at: index)
            }
        }
    }
    
    // Perform on Every Time when ActivityFeed View is Appeared
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
        
        if let pmNotificationData = notificationData{
            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                notificationData = nil
                let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                    channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: pmNotificationData)
                }
            }
        }
        let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
        if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
            channelizeClass.getMessageCount(completion: {(count) in
                messageCount = count
                if messageIndex > 0{
                    baseController.tabBar.items?[messageIndex].badgeValue = messageCount > 0 ? "\(messageCount)" : nil
                }
            })
        }
        
        
        checkapp()
        // checkLiveTimeSetting()
        view.backgroundColor = bgColor
        self.enableDisableVideoAutoPlay()
        globalFeedHeight = tableHeaderHight
        self.feedObj.tableView.reloadData()
        
        
        
        if feedArray.count == 0 && noContentView.isHidden == false && isAddFriendWidgetEnable == 0 {
            self.feedObj.tableView.tableFooterView?.isHidden = true
        }
        maxidTikTok = 0
        API_getAAFList()
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.delegate = self
        if self.feedFilterFlag == true
        {
            if searchDic.count == 0
            {
                searchDic = filterSeachDic
            }
            
        }
        if show_story == 1
        {
            if self.storiesView?.collectionViewStories != nil
            {
                self.storiesView?.collectionViewStories?.reloadData()
            }
        }
        if isViewWillAppearCall == 0
        {
            hidingNavBarManager?.viewWillAppear(animated)
            DispatchQueue.main.async {
                self.viewWillLoadData()
            }
        }
        else
        {
            modifyDataAsPerStoryFlow()
        }
    }
    
    func enableDisableVideoAutoPlay() {
        let netStatus = reachability.connection
        var statusString = ""
        switch netStatus {
        case .none:
            statusString = "never"
            break
        case .wifi:
            statusString = "wifi"
            break
        case .cellular:
            statusString = "always"
            break
        }
        
        print(statusString)
        let defaults = UserDefaults.standard
        if #available(iOS 10.0, *)
        {
            if UIDevice.current.batteryLevel > 0.19 {
                
                if let name = defaults.object(forKey: "AutoPlayStatus")
                {
                    if  UserDefaults.standard.object(forKey: "AutoPlayStatus") != nil
                    {
                        
                        
                        if name as! String == statusString && !isVideoPlayingInPIP{
                            NotPlay = 0
                        }
                        else{
                            NotPlay = 1
                        }
                        
                        if name as! String == "never"{
                            NotPlay = 1
                        }
                        if name as! String == "always" && !isVideoPlayingInPIP{
                            NotPlay = 0
                        }
                        
                        
                    }
                    
                }
                else{
                    if !isVideoPlayingInPIP {
                        NotPlay = 0
                    }
                    else {
                        NotPlay = 1
                    }
                }

            }
        }

        else{
            NotPlay = 1
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hidingNavBarManager?.viewDidLayoutSubviews()
        
    }
    // Stop Timer on Disappear of Activity Feed View
    override func viewWillDisappear(_ animated: Bool)
    {
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        
        if isQuickContentInProcess == 0
        {
            for (index,activityFeed) in feedArray.enumerated()
            {
                if let t = activityFeed["isDummyResponse"] as? Int, t == 2
                {
                    feedArray.remove(at: index)
                }
            }
        }
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        if self.noPostViewSet == false {
            feedObj.tableView.tableFooterView?.isHidden = true
        }
        else {
            feedObj.tableView.tableFooterView?.isHidden = false
        }
        stopMyTimer()
        hidingNavBarManager?.viewWillDisappear(animated)
        // tableViewFrameType = ""
        frndTagValue.removeAll()
        setNavigationImage(controller: self)
        filterSearchFormArray.removeAll(keepingCapacity: false)
    }
    
    func modifyDataAsPerStoryFlow()
    {
        if isViewWillAppearCall == 2
        {
            isViewWillAppearCall = 0
            if isStoryShare == true
            {
                if isStoryPost == true
                {
                    showToast(message: "Your story and feed will be posted shortly", controller: self)
                }
                else
                {
                    showToast(message: NSLocalizedString("Your story will be posted shortly",comment: ""), controller: self)
                }
                storiesView?.updateStoriesData(isDataUpdate: true)
                API_shareStory()
            }
            else if isStoryPost == true
            {
                showToast(message: NSLocalizedString("Your feed will be posted shortly",comment: ""), controller: self)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                API_postStory()
            }
        }
        else if isViewWillAppearCall == 3
        {
            isViewWillAppearCall = 0
            storiesView?.updateStoriesData(isDataUpdate: true)
            API_getBrowseStories()
        }
        else if isViewWillAppearCall == 7
        {
            globalFeedHeight = tableHeaderHight
            self.feedObj.refreshLikeUnLike = true
            feedObj.tableView.reloadData()
            isViewWillAppearCall = 0
            
        }
        else if isViewWillAppearCall == 5
        {
            isViewWillAppearCall = 0
            API_getBrowseStories()
        }
        else if isViewWillAppearCall == 6
        {
            isViewWillAppearCall = 0
            API_getBrowseStories()
        }
        else if isViewWillAppearCall == 4
        {
            isViewWillAppearCall = 0
        }
        else if isViewWillAppearCall == 8
        {
            isViewWillAppearCall = 0
            showSpinner = false
            maxid = 0
            maxidTikTok = 0
            feed_filter = 1
            self.updateNewFeed = false
            browseFeed()
        }
        else
        {
            isViewWillAppearCall = 0
        }
    }
    
    func IsRedirctToProfile()
    {
        if conditionalProfileForm == "AAF"
        {
            conditionalProfileForm = ""
            if enabledModules.contains("sitevideo")
            {
                
                let presentedVC = AdvanceVideoProfileViewController()
                presentedVC.videoProfileTypeCheck = ""
                
                presentedVC.videoId = createResponse["video_id"] as? Int ?? 0
                presentedVC.videoType = createResponse["type"] as? Int
                presentedVC.videoUrl = createResponse["video_url"] as? String ?? ""
                let nativationController = UINavigationController(rootViewController: presentedVC)
                nativationController.modalPresentationStyle = .fullScreen
                self.parent?.present(nativationController, animated:true, completion: nil)
            }
            else{
                
                VideoObject().redirectToVideoProfilePage(self, videoId : createResponse["video_id"] as? Int ?? 0, videoType : createResponse["type"] as? Int ?? 0, videoUrl : createResponse["video_url"] as? String ?? "")
            }
            
        }
        
    }
    
    
    // Initialize Timer for Check Updates in Feeds
    func startMyTimer(){
        self.stopMyTimer()
        myTimer = Timer.scheduledTimer(timeInterval: 30, target:self, selector:  #selector(AdvanceActivityFeedViewController.newfeedsUpdate), userInfo: nil, repeats: true)
        
    }
    
    // Stop Timer for Check Updation
    func stopMyTimer(){
        if myTimer != nil{
            myTimer.invalidate()
        }
    }
    
    
    
    // Show Post Feed Option to User based on Permission from Server & Save these options
    func postFeedOption()
    {
        var postPermission_variable_video : Int = 0
        var postPermission_variable_photo : Int = 0
        var postPermission_variable_checkIn : Int = 0
        /// Read Post Permission saved in NSUserDefaults
        if let data = UserDefaults.standard.object(forKey: "postMenu") as? NSData{
            if data.length != 0
            {
                if postView != nil {
                    for ob in postView.subviews
                    {
                        if ob.tag != 108
                        {
                            ob.removeFromSuperview()
                        }
                        
                    }
                }
                if let  postPermission = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? NSDictionary
                {
                    var postMenu = [String]()
                    var menuIcon = [String]()
                    var colorIcon = [UIColor]()
                    if postPermission.count > 0{
                        
                        if AgoraId != "" && enableLiveStreaming == true{
                            postMenu.append(NSLocalizedString(" Go Live", comment: ""))
                            menuIcon.append("\(previewCameraIcon)")
                            colorIcon.append(CheckInIconColor)
                            
                            
                            
                            if let photo = postPermission["photo"] as? Bool{
                                if photo{
                                    postMenu.append(NSLocalizedString(" Photo", comment: ""))
                                    menuIcon.append("\u{f030}")
                                    colorIcon.append(PhotoIconColor)
                                }
                            }
                            
                            if let status = postPermission["video"] as? Bool{
                                if status
                                {
                                    for (key,value) in videoattachmentType
                                    {
                                        if key as! String == "3"
                                        {
                                            postMenu.append(NSLocalizedString(" Video", comment: ""))
                                            menuIcon.append(videoIcon)
                                            colorIcon.append(videoIconColor)
                                            postPermission_variable_video = 1
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            if let status = postPermission["video"] as? Bool{
                                if status
                                {
                                    for (key,value) in videoattachmentType
                                    {
                                        if key as! String == "3"
                                        {
                                            postMenu.append(NSLocalizedString(" Video", comment: ""))
                                            menuIcon.append(videoIcon)
                                            colorIcon.append(videoIconColor)
                                            postPermission_variable_video = 1
                                        }
                                    }
                                }
                            }
                            
                            if let photo = postPermission["photo"] as? Bool{
                                if photo{
                                    postPermission_variable_photo = 2
                                    postMenu.append(NSLocalizedString(" Photo", comment: ""))
                                    menuIcon.append("\u{f030}")
                                    colorIcon.append(PhotoIconColor)
                                }
                            }
                            if apiServerKey != ""{
                                if let checkIn = postPermission["checkin"] as? Bool{
                                    if checkIn{
                                        postMenu.append(NSLocalizedString(" Check In", comment: ""))
                                        menuIcon.append("\u{f041}")
                                        postPermission_variable_checkIn = 3
                                        colorIcon.append(CheckInIconColor)
                                    }
                                }
                            }
                        }
                    }
                    
                    let  feedTextView = createButton(CGRect(x: 60 + PADING,y: 0 ,width: view.bounds.width-(60 + PADING),height:64), title: NSLocalizedString("What's on your mind?",comment: "") , border: false ,bgColor: false, textColor: textColorMedium)
                    feedTextView.titleLabel?.font =  UIFont(name: fontName, size:FONTSIZELarge)
                    
                    let border = CALayer()
                    let width = CGFloat(0.5)
                    let borderColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1.0)
                    border.borderColor = borderColor.cgColor
                    border.frame = CGRect(x: 0, y: 69, width: view.bounds.width , height: 1)
                    border.borderWidth = width
                    
                    postView.layer.addSublayer(border)
                    postView.layer.masksToBounds = true
                    
                    feedTextView.tag = 1990
                    feedTextView.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                    feedTextView.addTarget(self, action: #selector(AdvanceActivityFeedViewController.openPostFeed(sender:)), for: .touchUpInside)
                    feedTextView.backgroundColor = lightBgColor
                    postView.addSubview(feedTextView)
                    
                    //Add Post Feed Option
                    
                    for i in 0 ..< postMenu.count
                    {
                        let origin_x = (CGFloat(i) * (view.bounds.width/CGFloat(postMenu.count)))
                        let postFeed = createButton(CGRect(x: origin_x,y: 70 ,width: view.bounds.width/CGFloat(postMenu.count),height: 35), title: "" , border: false ,bgColor: false, textColor: textColorMedium )
                        switch i {
                        case 0:
                            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: menuIcon[0])
                            attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                            attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: colorIcon[0], range: NSMakeRange(0, attrString.length))
                            let descString: NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("\(postMenu[0])",comment: ""))
                            descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                            descString.addAttribute(NSAttributedString.Key.foregroundColor, value: iconTextColor, range: NSMakeRange(0, descString.length))
                            attrString.append(descString);
                            
                            postFeed.setAttributedTitle(attrString, for: UIControl.State.normal)
                            break
                        case 1:
                            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: menuIcon[1])
                            attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                            attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: colorIcon[1], range: NSMakeRange(0, attrString.length))
                            let descString: NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("\(postMenu[1])",comment: ""))
                            descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                            descString.addAttribute(NSAttributedString.Key.foregroundColor, value: iconTextColor, range: NSMakeRange(0, descString.length))
                            attrString.append(descString);
                            
                            postFeed.setAttributedTitle(attrString, for: UIControl.State.normal)
                            break
                        case 2:
                            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: menuIcon[2])
                            attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size: FONTSIZELarge)!, range: NSMakeRange(0, attrString.length))
                            attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: colorIcon[2], range: NSMakeRange(0, attrString.length))
                            let descString: NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString("\(postMenu[2])",comment: ""))
                            descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZELarge)!, range: NSMakeRange(0, descString.length))
                            descString.addAttribute(NSAttributedString.Key.foregroundColor, value: iconTextColor, range: NSMakeRange(0, descString.length))
                            attrString.append(descString);
                            
                            postFeed.setAttributedTitle(attrString, for: UIControl.State.normal)
                            break
                        default:
                            break
                        }
                        
                        postFeed.titleLabel?.textAlignment = NSTextAlignment.center
                        postFeed.backgroundColor = lightBgColor
                        if postPermission_variable_video == 1{
                            postFeed.tag = i+1 + 1990
                            if postPermission_variable_photo != 2 && postPermission_variable_checkIn == 3 && i != 0
                            {
                                postFeed.tag = postPermission_variable_checkIn + 1990
                            }
                        }
                        else
                        {
                            postFeed.tag = i+2 + 1990
                            if postPermission_variable_photo != 2
                            {
                                postFeed.tag = postPermission_variable_checkIn + 1990
                            }
                            print("postPermission_variable_photo\(postPermission_variable_photo)")
                            if postPermission_variable_photo != 2 && postPermission_variable_checkIn == 0 && i == 0 {
                                postFeed.tag = postPermission_variable_checkIn + 1990 + 1
                            }
                            if postMenu.count == 2 && i == 1 && AgoraId != "" && enableLiveStreaming {
                                postFeed.tag = postPermission_variable_checkIn + 1990 + 2
                            }
                        }
                        postFeed.addTarget(self, action: #selector(AdvanceActivityFeedViewController.openPostFeed(sender:)), for: .touchUpInside)
                        postView.addSubview(postFeed)
                        //                        if isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved {
                        //                          self.noContentView.frame.origin.y = getBottomEdgeY(inputView: postView) + 5
                        //                        }
                    }
                    
                    postMenu.removeAll(keepingCapacity: false)
                }
            }
        }
        
    }
    
    func checkLiveTimeSetting(){
        let url1 = "get-settings"
        
        let dic = [String : String]()
        
        let method1 = "GET"
        
        post(dic , url: "\(url1)", method: method1) { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                
                if msg{
                    
                    if let body = succeeded["body"] as? NSDictionary{
                        if let liveDic = body["livestreamingvideo"] as? NSDictionary{
                            if liveDic["duration"] != nil {
                                timeLimit = (liveDic["duration"] as! Int)
                            }
                            if liveDic["enableBroadcast"] != nil {
                                enableLiveStreaming = liveDic["enableBroadcast"] as! Bool
                            }
                            if (logoutUser == false)
                            {
                                self.postFeedOption()
                            }
                            
                        }
                        
                    }
                    print("test timing=====")
                    
                    
                }
                    
                else{
                    // Handle Server Side Error
                    if succeeded["message"] != nil{
                        showToast(message: succeeded["message"] as! String, controller: self)
                    }
                }
            })
        }
    }
    
    // Pull to Request Action
    @objc func refresh(){
        
        DispatchQueue.main.async(execute:{
            soundEffect("Activity")
        })
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            arrGlobalFacebookAds.removeAll()
            self.feedObj.checkforAds()
            removeQuickContentPost()
            // Pull to Refreh for Recent Feeds (Reset Variables)
            showSpinner = false
            maxid = 0
            maxidTikTok = 0
            feed_filter = 1
            self.updateNewFeed = false
            self.API_getAAFList()
            browseFeed()
        }
        else
        {
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( centerPoint: CGPoint, msg: String, timer:Bool){
        mainView.addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
            self.createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer for remove Alert
    @objc func stopTimer() {
        //  updateScrollFlag = true
        stop()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Selcted tab index - ",tabBarController.selectedIndex)
        print("Message tab index - ",messageIndex)
        if ( tabBarController.selectedIndex == 0)
        {
            scrollToTop()
        } else if (tabBarController.selectedIndex == messageIndex){
            if isChannelizeAvailable{
                if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                    let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                    if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                        if channelizeClass.getChannelizeCurrentUserId() != nil{
                            channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: nil)
                        } else{
                            if let pmAccessToken = UserDefaults.standard.value(forKey: "pmAccessToken") as? String{
                                channelizeClass.updateChannelizeToken(token: pmAccessToken)
                                let userId = currentUserId
                                let stringId = String(describing: userId)
                                channelizeClass.getUserObjectWithId(userId: stringId, completion: {(user,error) in
                                    if let error = error{
                                        print("Fail to get User Object")
                                    } else if let user = user{
                                        channelizeClass.initializeRealmObjects()
                                        channelizeClass.updateUserObject(userObject: user, token: pmAccessToken)
                                        channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: nil)
                                    }
                                    
                                })
                            }
                        }
                    }
                }
            }
        }
    }
    
    func scrollToTop()
    {
        let indexPath = IndexPath(row: 0, section: 0)
        if !((self.feedObj.tableView.indexPathsForVisibleRows?.contains(indexPath))!) {
            // Your code here
            
            
            
            if feedObj.tableView.contentOffset.y != -TOPPADING {
                feedObj.tableView.contentOffset.y = 0
            }
            
            if self.feedObj.tableView.numberOfRows(inSection: 0) > 0
            {
                
                let indexPath = IndexPath(row: 0, section: 0)
                self.feedObj.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
            }
        }
    }
    
    // Request to Show New Stories Feed
    @objc func updateNewFeed(sender:UIButton){
        sender.removeFromSuperview()
        self.newFeedUpdateCounter = 0
        self.updateNewFeed = false
        self.browseFeed()
        if searchDic.count == 0 && gutterMenu1.count > 0
        {
            if let dic = self.gutterMenu1[0] as? NSDictionary
            {
                // Set Parameters for Feed Filter
                if let params = dic["urlParams"] as? NSDictionary
                {
                    searchDic["filter_type"] = params["filter_type"] as? String
                }
            }
        }
        else
        {
            searchDic = filterSeachDic
            //searchDic["filter_type"] = "all"
            
            
        }
        // Reload Tabel After Updation
        self.feedObj.refreshLikeUnLike = true
        self.feedObj.tableView.reloadData()
        self.activityFeeds.removeAll(keepingCapacity: false)
        let indexPath = IndexPath(row: 0, section: 0)
        self.feedObj.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
        
    }
    
    // Make Updation in Core Data for every Recent Activity Feed (All Updates)
    func updateActivityFeed(feeds:[ActivityFeed]){
        // Save Response in Core Data
        let request:NSFetchRequest<ActivityFeedData>
        if #available(iOS 10.0, *)
        {
            request = ActivityFeedData.fetchRequest() as! NSFetchRequest<ActivityFeedData>
        }
        else
        {
            request = NSFetchRequest(entityName: "ActivityFeedData")
        }
        request.returnsObjectsAsFaults = false
        let results = try? context.fetch(request)
        if(results?.count>0)
        {
            
            // If exist than Delete all entries
            for result: AnyObject in results! {
                context.delete(result as! NSManagedObject)
            }
            do {
                try context.save()
            } catch _ {
            }
            // Update Saved Feed
            updateSavedFeed(feeds: feeds)
        }
            
        else
        {
            // Update Saved Feed
            updateSavedFeed(feeds: feeds)
        }
    }
    

    // Updates Saved Feed in Core Data For Recent Feed
    func updateSavedFeed(feeds:[ActivityFeed]){
        var i = 0
        for feed in feeds{
            // Insert FeedData in Entity ActivityFeedData
            let newfeed = NSEntityDescription.insertNewObject(forEntityName: "ActivityFeedData", into: context) as NSManagedObject
            if feed.action_id != nil{
                newfeed.setValue( feed.action_id , forKey: "action_Id")
            }
            
            if feed.subject_id != nil{
                newfeed.setValue( feed.subject_id , forKey: "subject_Id")
            }
            if feed.share_params_id != nil{
                newfeed.setValue( feed.share_params_id , forKey: "share_params_id")
            }
            if feed.share_params_type != nil{
                newfeed.setValue( feed.share_params_type , forKey: "share_params_type")
            }
            if feed.attachment != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.attachment ?? []) , forKey: "attachment")
            }
            if feed.attactment_Count != nil{
                newfeed.setValue( feed.attactment_Count , forKey: "attachmentCount")
            }
            if feed.comment != nil{
                newfeed.setValue( feed.comment , forKey: "canComment")
            }
            if feed.delete != nil{
                newfeed.setValue( feed.delete , forKey: "canDelete")
            }
            if feed.share != nil{
                newfeed.setValue( feed.share , forKey: "canShare")
            }
            if feed.comment_count != nil{
                newfeed.setValue( feed.comment_count , forKey: "commentCount")
            }
            if feed.feed_createdAt != nil{
                newfeed.setValue( feed.feed_createdAt , forKey: "creationDate")
            }
            if feed.feed_menus != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.feed_menus ?? []) , forKey: "feedMenu")
            }
            if feed.feed_footer_menus != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.feed_footer_menus ?? [:]) , forKey: "feed_footer_menus")
            }
            if feed.feed_reactions != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.feed_reactions ?? [:]) , forKey: "feed_reactions")
            }
            if feed.my_feed_reaction != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.my_feed_reaction ?? [:]) , forKey: "my_feed_reaction")
            }
            if feed.feed_title != nil{
                newfeed.setValue( feed.feed_title , forKey: "feedTitle")
            }
            if feed.feed_Type != nil{
                newfeed.setValue( feed.feed_Type , forKey: "feedType")
            }
            if feed.is_like != nil{
                newfeed.setValue( feed.is_like , forKey: "isLike")
            }
            if feed.likes_count != nil{
                newfeed.setValue( feed.likes_count , forKey: "likeCount")
            }
            if feed.subject_image != nil{
                newfeed.setValue( feed.subject_image , forKey: "subjectAvatarImage")
            }
            if feed.photo_attachment_count != nil{
                newfeed.setValue( feed.photo_attachment_count , forKey: "photo_attachment_count")
            }
            if feed.object_id != nil{
                newfeed.setValue( feed.object_id , forKey: "object_id")
            }
            if feed.object_type != nil{
                newfeed.setValue( feed.object_type , forKey: "object_type")
            }
            if feed.params != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.params ?? [:]) , forKey: "params")
            }
            if feed.tags != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.tags ?? []) , forKey: "tags")
            }
            if feed.action_type_body_params != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.action_type_body_params ?? []) , forKey: "action_type_body_params")
            }
            if feed.action_type_body != nil{
                newfeed.setValue( feed.action_type_body , forKey: "action_type_body")
            }
            if feed.object != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.object ?? [:]) , forKey: "object")
                
            }
            if feed.hashtags != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.hashtags ?? []) , forKey: "hashtags")
            }
            if feed.userTag != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.userTag ?? []) , forKey: "userTag")
            }
            if feed.decoration != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.decoration!) , forKey: "decoration")
            }
            if feed.wordStyle != nil{
                newfeed.setValue( NSKeyedArchiver.archivedData(withRootObject: feed.wordStyle!) , forKey: "wordStyle")
            }
            if feed.publish_date != nil{
                newfeed.setValue( feed.publish_date , forKey: "publish_date")
            }
            if feed.isNotificationTurnedOn != nil{
                newfeed.setValue( feed.isNotificationTurnedOn , forKey: "isNotificationTurnedOn")
            }
            if feed.attachment_content_type != nil{
                newfeed.setValue( feed.attachment_content_type , forKey: "attachment_content_type")
            }
            do {
                try context.save()
            } catch _ {
            }
            i += 1
            
        }
    }
    
    // Update/ Sink feedArray from [ActivityFeed] to show updates in ActivityFeed Table
    func updateFeedsArray(feeds:[ActivityFeed]){
        var existingFeedIntegerArray = [Int]()
        
        for tempFeedArrays in feedArray {
            existingFeedIntegerArray.append(tempFeedArrays["action_id"] as? Int ?? 0)
        }
        for feed in feeds{
            let newDictionary:NSMutableDictionary = [:]
            
            
            if feed.action_id != nil{
                newDictionary["action_id"] = feed.action_id
            }
            if feed.feed_privacy != nil{
                newDictionary["privacy"] = feed.feed_privacy
            }
            if feed.feed_privacyIcon != nil{
                newDictionary["privacy_icon"] = feed.feed_privacyIcon
            }
            
            if feed.subject_id != nil{
                newDictionary["subject_id"] = feed.subject_id
            }
            if feed.share_params_type != nil{
                newDictionary["share_params_type"] = feed.share_params_type
            }
            if feed.share_params_id != nil{
                newDictionary["share_params_id"] = feed.share_params_id
            }
            if feed.attachment != nil{
                newDictionary["attachment"] = feed.attachment
            }
            if feed.attactment_Count != nil{
                newDictionary["attactment_Count"] = feed.attactment_Count
            }
            if feed.comment != nil{
                newDictionary["comment"] = feed.comment
            }
            if feed.delete != nil{
                newDictionary["delete"] = feed.delete
            }
            if feed.share != nil{
                newDictionary["share"] = feed.share
            }
            if feed.comment_count != nil{
                newDictionary["comment_count"] = feed.comment_count
            }
            if feed.feed_createdAt != nil{
                newDictionary["feed_createdAt"] = feed.feed_createdAt
            }
            if feed.feed_menus != nil{
                newDictionary["feed_menus"] = feed.feed_menus
            }
            if feed.feed_footer_menus != nil{
                newDictionary["feed_footer_menus"] = feed.feed_footer_menus
            }
            if feed.feed_reactions != nil{
                newDictionary["feed_reactions"] = feed.feed_reactions
            }
            if feed.my_feed_reaction != nil{
                newDictionary["my_feed_reaction"] = feed.my_feed_reaction
            }
            if feed.feed_title != nil{
                newDictionary["feed_title"] = feed.feed_title
            }
            if feed.feed_Type != nil{
                newDictionary["feed_Type"] = feed.feed_Type
            }
            if feed.is_like != nil{
                newDictionary["is_like"] = feed.is_like
            }
            if feed.likes_count != nil{
                newDictionary["likes_count"] = feed.likes_count
            }
            if feed.subject_image != nil{
                newDictionary["subject_image"] = feed.subject_image
            }
            if feed.photo_attachment_count != nil{
                newDictionary["photo_attachment_count"] = feed.photo_attachment_count
            }
            if feed.object_id != nil{
                newDictionary["object_id"] = feed.object_id
            }
            if feed.object_type != nil{
                newDictionary["object_type"] = feed.object_type
            }
            
            if feed.params != nil{
                newDictionary["params"] = feed.params
            }
            if feed.tags != nil{
                newDictionary["tags"] = feed.tags
            }
            if feed.action_type_body_params != nil{
                newDictionary["action_type_body_params"] = feed.action_type_body_params
            }
            if feed.action_type_body != nil{
                newDictionary["action_type_body"] = feed.action_type_body
            }
            if feed.object != nil{
                newDictionary["object"] = feed.object
            }
            if feed.hashtags != nil{
                newDictionary["hashtags"] = feed.hashtags
            }
            if feed.userTag != nil{
                newDictionary["userTag"] = feed.userTag
            }
            if feed.decoration != nil{
                newDictionary["decoration"] = feed.decoration
            }
            if feed.wordStyle != nil{
                newDictionary["wordStyle"] = feed.wordStyle
            }
            if feed.publish_date != nil{
                newDictionary["publish_date"] = feed.publish_date
            }
            if feed.isNotificationTurnedOn != nil{
                newDictionary["isNotificationTurnedOn"] = feed.isNotificationTurnedOn
                
            }
            
            if feed.attachment_content_type != nil{
                newDictionary["attachment_content_type"] = feed.attachment_content_type
            }
            
            if feed.pin_post_duration != nil{
                newDictionary["pin_post_duration"] = feed.pin_post_duration
            }
            if feed.isPinned != nil{
                newDictionary["isPinned"] = feed.isPinned
            }
            
            
            
            
            let actionId  = newDictionary["action_id"] as! Int
            
            if !existingFeedIntegerArray.contains(actionId){
                
                feedArray.append(newDictionary)
            }
            
            
        }
        existingFeedIntegerArray.removeAll(keepingCapacity: true)
        //Header height
        globalFeedHeight =  tableHeaderHight
        self.feedObj.refreshLikeUnLike = true
        
        if checkQuickContentPostExist() == false
        {
            feedArray = feedArrayTemp + feedArray
        }
        self.feedObj.globalArrayFeed = feedArray
        self.feedObj.tableView.reloadData()
    }
    
    // Update/ Sink feedArray from [ActivityFeed] to show updates in ActivityFeed Table
    func updateFeedsArrayTikTok(feeds:[ActivityFeed]){
        var existingFeedIntegerArray = [Int]()
        for tempFeedArrays in feedArrayTikTok {
            existingFeedIntegerArray.append(tempFeedArrays["action_id"] as? Int ?? 0)
        }
        for feed in feeds{
            let newDictionary:NSMutableDictionary = [:]
            if feed.action_id != nil{
                newDictionary["action_id"] = feed.action_id
            }
            if feed.feed_privacy != nil{
                newDictionary["privacy"] = feed.feed_privacy
            }
            if feed.feed_privacyIcon != nil{
                newDictionary["privacy_icon"] = feed.feed_privacyIcon
            }
            
            if feed.subject_id != nil{
                newDictionary["subject_id"] = feed.subject_id
            }
            if feed.share_params_type != nil{
                newDictionary["share_params_type"] = feed.share_params_type
            }
            if feed.share_params_id != nil{
                newDictionary["share_params_id"] = feed.share_params_id
            }
            if feed.attachment != nil{
                newDictionary["attachment"] = feed.attachment
            }
            if feed.attactment_Count != nil{
                newDictionary["attactment_Count"] = feed.attactment_Count
            }
            if feed.comment != nil{
                newDictionary["comment"] = feed.comment
            }
            if feed.delete != nil{
                newDictionary["delete"] = feed.delete
            }
            if feed.share != nil{
                newDictionary["share"] = feed.share
            }
            if feed.comment_count != nil{
                newDictionary["comment_count"] = feed.comment_count
            }
            if feed.feed_createdAt != nil{
                newDictionary["feed_createdAt"] = feed.feed_createdAt
            }
            if feed.feed_menus != nil{
                newDictionary["feed_menus"] = feed.feed_menus
            }
            if feed.feed_footer_menus != nil{
                newDictionary["feed_footer_menus"] = feed.feed_footer_menus
            }
            if feed.feed_reactions != nil{
                newDictionary["feed_reactions"] = feed.feed_reactions
            }
            if feed.my_feed_reaction != nil{
                newDictionary["my_feed_reaction"] = feed.my_feed_reaction
            }
            if feed.feed_title != nil{
                newDictionary["feed_title"] = feed.feed_title
            }
            if feed.feed_Type != nil{
                newDictionary["feed_Type"] = feed.feed_Type
            }
            if feed.is_like != nil{
                newDictionary["is_like"] = feed.is_like
            }
            if feed.likes_count != nil{
                newDictionary["likes_count"] = feed.likes_count
            }
            if feed.subject_image != nil{
                newDictionary["subject_image"] = feed.subject_image
            }
            if feed.photo_attachment_count != nil{
                newDictionary["photo_attachment_count"] = feed.photo_attachment_count
            }
            if feed.object_id != nil{
                newDictionary["object_id"] = feed.object_id
            }
            if feed.object_type != nil{
                newDictionary["object_type"] = feed.object_type
            }
            if feed.params != nil{
                newDictionary["params"] = feed.params
            }
            if feed.tags != nil{
                newDictionary["tags"] = feed.tags
            }
            if feed.action_type_body_params != nil{
                newDictionary["action_type_body_params"] = feed.action_type_body_params
            }
            if feed.action_type_body != nil{
                newDictionary["action_type_body"] = feed.action_type_body
            }
            if feed.object != nil{
                newDictionary["object"] = feed.object
            }
            if feed.hashtags != nil{
                newDictionary["hashtags"] = feed.hashtags
            }
            if feed.userTag != nil{
                newDictionary["userTag"] = feed.userTag
            }
            if feed.decoration != nil{
                newDictionary["decoration"] = feed.decoration
            }
            if feed.wordStyle != nil{
                newDictionary["wordStyle"] = feed.wordStyle
            }
            if feed.publish_date != nil{
                newDictionary["publish_date"] = feed.publish_date
            }
            if feed.isNotificationTurnedOn != nil{
                newDictionary["isNotificationTurnedOn"] = feed.isNotificationTurnedOn
            }
            if feed.attachment_content_type != nil{
                newDictionary["attachment_content_type"] = feed.attachment_content_type
            }
            if feed.pin_post_duration != nil{
                newDictionary["pin_post_duration"] = feed.pin_post_duration
            }
            if feed.isPinned != nil{
                newDictionary["isPinned"] = feed.isPinned
            }
            let actionId  = newDictionary["action_id"] as! Int
            if !existingFeedIntegerArray.contains(actionId){
                feedArrayTikTok.append(newDictionary)
            }
        }
        existingFeedIntegerArray.removeAll(keepingCapacity: true)
    }
    // MARK: - Optimise later PhotoLayout Work
    
    // MARK: - Server Connection For Activity Feeds Updation
    @objc func newfeedsUpdate()
    {
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            
            // if subject_id == 0 && subject_type == ""{
            parameters = ["limit": "\(limit)" ,"minid":String(minid),"feed_count_only":"1","getAttachedImageDimention":"0"]
            if feedFilterFlag == true{
                parameters.merge(searchDic)
            }
            // Set userinteractionflag for request
            userInteractionOff = false
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute:{
                    // Reset Object after Response from server
                    userInteractionOff = true
                    // On Success Update Feeds
                    if msg{
                        
                        // Check response of Activity Feeds
                        self.newFeedUpdateCounter = 0
                        if let newFeedCountInteger = succeeded["body"]  as? Int{
                            if newFeedCountInteger > 0{
                                self.newFeedUpdateCounter += newFeedCountInteger
                                if isQuickContentInProcess == 0
                                {
                                    self.updateNewFeed = true
                                    self.maxid = 0
                                    maxidTikTok = 0
                                    updateAfterAlert = false
                                    if self.feedObj.tableView.contentOffset.y < 20 {
                                    self.browseFeed()
                                    }
                                    else {
                                        self.newFeedSButtonSet()
                                    }
                                }
                                
                                
                            }
                        }
                            
                        else{
                            
                            //self.shimmeringView.isShimmering = false
                            //self.feedObj.tableView.tableFooterView?.isHidden = true
                            
                            self.refresher.endRefreshing()
                        }
                        
                    }else{
                        // Show Message on Failour
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
    
    func newFeedSButtonSet() {
        if self.updateNewFeed == true && self.feedObj.tableView.contentOffset.y > 20
        {
            if self.newFeedUpdateCounter > 0
            {
                _ = self.newFeedUpdateCounter
                var newFeedCount = ""
                newFeedCount = String(format: NSLocalizedString("%@ New Updates", comment: ""), "\u{f062}")
                if let newFeedsButton = self.mainView.viewWithTag(2020) {
                    // myButton already existed
                    newFeedsButton.removeFromSuperview()
                    
                }
                let newFeeds = createButton(CGRect(x: 0,y: TOPPADING + 20 ,width: findWidthByText(newFeedCount) + 40 ,height: ButtonHeight - PADING),title: newFeedCount, border: false,bgColor: true, textColor: textColorLight)
                newFeeds.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                newFeeds.isHidden = false
                newFeeds.tag = 2020
                newFeeds.center = CGPoint(x:self.view.center.x, y:newFeeds.frame.origin.y)
                newFeeds.layer.cornerRadius = newFeeds.bounds.height/2
                newFeeds.addTarget(self, action: #selector(AdvanceActivityFeedViewController.updateNewFeed(sender:)), for: .touchUpInside)
                self.mainView.addSubview(newFeeds)
                self.feedObj.refreshLikeUnLike = true
                self.feedObj.tableView.reloadData()
                
            }
            
        }
        else
        {
            // Reload Tabel After Updation
            self.newFeedUpdateCounter = 0
            self.feedObj.refreshLikeUnLike = true
            if self.birthdayView.isHidden == false && isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved{
                self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.birthdayView) + self.birthdaybuttonsFrame.frame.size.height + 5
                self.scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView) + 5
            }
            self.feedObj.tableView.reloadData()
            if afterPost == true{
                afterPost = false
                DispatchQueue.main.async(execute:  {
                    soundEffect("post")
                })
                
            }
            self.activityFeeds.removeAll(keepingCapacity: false)
            // Create Timer for Check UPdtes Repeatlly
        }
        self.startMyTimer()
    }
    
    // Make Hard Refresh Request to server for Activity Feeds
    
    @objc func browseFeed()
    {
        if self.noContentLabel.isHidden == false {
            self.noContentLabel.removeFromSuperview()
        }
        if self.noPostViewSet == false {
            feedObj.tableView.tableFooterView?.isHidden = true
        }
        self.noPostViewSet = false
        quickContentIncrementIndex = 0
        if logoutUser == false && show_story == 1
        {
            API_getBrowseStories()
        }
        
        if feedArray.count > 0  && isAddFriendWidgetEnable == 0{
            noContentView.isHidden = true
        }
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            if UserDefaults.standard.bool(forKey: "appTour")
            {
                self.showAppTour()
            }
            removeAlert()
            stopMyTimer()
            if (showSpinner)
            {
                
                activityIndicatorView.center = view.center
                
                if updateScrollFlag == false
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height - tabBarHeight - 25)
                }
                if quickContentIncrementIndex == 0
                {
                    self.view.addSubview(activityIndicatorView)
                    activityIndicatorView.startAnimating()
                }
                
            }
            
            // Reset Objects for Hard Refresh Request
            if (maxid == 0)
            {
                if feedArray.count == 0
                {
                    feedObj.tableView.reloadData()
                    
                }
            }
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            parameters = ["maxid": String(maxid),"feed_filter": "\(feed_filter)","object_info":"1","getAttachedImageDimention":"0"]
            if updateScrollFlag == false{
                if defaultFeedCount > 0 {
                    parameters["limit"] = "\(defaultFeedCount)"
                }
            }
            // Set userinteractionflag for request
            userInteractionOff = false
            
            // Check for FeedFilter Option in Request
            if feedFilterFlag == true
            {
                if searchDic.count == 0
                {
                    searchDic = filterSeachDic
                }
                parameters.merge(searchDic)
            }
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    //                    self.view.isUserInteractionEnabled = true
                    //                    self.tabBarController?.tabBar.isUserInteractionEnabled = true
                    //                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                    self.showSpinner = false
                    // Stop Shimmering
                    isshimmer = false
                    // Reset Object after Response from server
                    
                    //self.shimmeringView.isShimmering = false
                    activityIndicatorView.stopAnimating()
                    self.refresher.endRefreshing()
                    self.appUpdateAvailable(completion: { (check) in
                        
                        var checkBoolUpgrade : Bool = false
                        let defaults = UserDefaults.standard
                        if let name = defaults.object(forKey: "forceUpgrade")
                        {
                            if  UserDefaults.standard.object(forKey: "forceUpgrade") != nil {
                                
                                checkBoolUpgrade = name as! Bool
                                
                            }
                        }
                        
                        
                        if checkBoolUpgrade == true {
                            print("======updates here=====")
                        }
                        else{
                            if let tabBarObject = self.tabBarController?.tabBar
                            {
                                tabBarObject.isUserInteractionEnabled = true
                                self.view.isUserInteractionEnabled = true
                                userInteractionOff = true
                                self.navigationController?.navigationBar.isUserInteractionEnabled = true
                            }
                        }
                        
                    })
                    //self.feedObj.tableView.tableFooterView?.isHidden = true
                    
                    // On Success Update Feeds
                    if msg
                    {
                        // //print(succeeded)
                        // If Message in Response show the Message
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        // Reset feedArray for Sink with Feed Results
                        if self.maxid == 0
                        {
                            feedArray.removeAll(keepingCapacity: false)
                            self.dynamicRowHeight.removeAll(keepingCapacity: false)
                        }
                        self.activityFeeds.removeAll(keepingCapacity: false)
                        // Check response of Activity Feeds
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            
                            if let showFilterType = response["showFilterType"] as? Int
                            {
                                isfeedfilter = showFilterType
                            }
                            // Set MinId for Feeds Result
                            if let minID = response["minid"] as? Int{
                                self.minid = minID
                            }
                            // Set MinId for Feeds Result
                            if let feedCount = response["defaultFeedCount"] as? Int{
                                self.defaultFeedCount = feedCount
                            }
                            
                            // Check for Feed Filter Options
                            if let menu = response["filterTabs"] as? NSArray{
                                self.gutterMenu1 = menu
                                if logoutUser {
                                    feedFilterAsGuest = menu
                                }
                                if logoutUser == true {
                                    if self.view.viewWithTag(2017) == nil{
                                        if isfeedfilter == 1
                                        {
                                            self.showfeedFilter()
                                        }
                                    }
                                }
                                else
                                {
                                    if greetingsAllow == 0 {
                                        if isfeedfilter == 1
                                        {
                                            if self.view.viewWithTag(2017) == nil{
                                                self.showfeedFilter()
                                            }
                                        }
                                    }
                                }
                                
                                if searchDic.count == 0
                                {
                                    if let dic = self.gutterMenu1[0] as? NSDictionary
                                    {
                                        // Set Parameters for Feed Filter
                                        if let params = dic["urlParams"] as? NSDictionary{
                                            for (key, value) in params{
                                                if let id = value as? NSNumber {
                                                    searchDic["\(key)"] = String(id as? Int ?? 0)
                                                }
                                                
                                                if let receiver = value as? NSString {
                                                    searchDic["\(key)"] = receiver as String
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            // Check for Feeds
                            if response["data"] != nil{
                                if let activity_feed = response["data"] as? NSArray{
                                    // Extract FeedInfo from response by ActivityFeed class
                                    self.activityFeeds = ActivityFeed.loadActivityFeedInfo(activity_feed)
                                    // Update feedArray
                                    self.updateFeedsArray(feeds: self.activityFeeds)
                                }
                            }
                            if greetingsAllow == 1 {
                                if self.firstGreetings {
                                    self.firstGreetings = false
                                    if (logoutUser == false)
                                    {
                                        self.getGreetings()
                                    }
                                }
                            }
                            // Check for Video Attachment type
                            // update Recent Top 20 Feeds in Core Data
                            if self.maxid == 0 && searchDic.count == 0  /*&& self.subject_type == ""*/
                            {
                                self.updateActivityFeed(feeds: self.activityFeeds)
                            }
                            
                            // Check that whether Reaction Plugin is enable or not
                            if let reactionsEnable = response["reactionsEnabled"] as? Bool{
                                if reactionsEnable == true{
                                    if let reactions = response["reactions"] as? NSDictionary
                                    {
                                        reactionsDictionary = reactions
                                        emojiReactionDictionary = reactions
                                        ReactionPlugin = true
                                        self.browseEmoji(contentItems: reactions)
                                        self.getLikeIconImage(contentItems: reactions)
                                    }
                                }
                                else
                                {
                                    ReactionPlugin = false
                                }
                            }
                            
                            // Check that whether Sticker Plugin is enable or not
                            if let stickersEnable = response["stickersEnabled"] as? Bool{
                                if stickersEnable == true{
                                    StickerPlugin = true
                                }
                            }
                            // Check that whether Image Attachment for comments is enable or not
                            if let emojiEnable = response["emojiEnabled"] as? Bool{
                                if emojiEnable == true{
                                    emojiEnabled = true
                                }
                            }
                            if response["video_source"] != nil
                            {
                                videoattachmentType = response["video_source"] as! NSDictionary
                            }
                            
                            // Set MaxId for Feeds Result
                            if let maxid = response["maxid"] as? Int{
                                self.maxid = maxid
                            }
                            
                            // Check for Post Feed Options
                            if response["feed_post_menu"] != nil && !(response["feed_post_menu"] is NSNull){
                                postPermission = response["feed_post_menu"] as! NSDictionary
                                self.API_getFeedPostMenus()
                                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject:postPermission), forKey: "postMenu")
                                if (logoutUser == false)
                                {
                                    self.postFeedOption()
                                }
                                
                                feedPostMenu = true
                            }
                            else
                            {
                                feedPostMenu = false
                                
                            }
                            
                            if  feedPostMenu == false
                            {
                                if logoutUser == false
                                {
                                    //Stories View
                                    if show_story == 1
                                    {
                                        self.storiesViewHeight = 115.0
                                        self.storiesView?.frame.origin.y = 0
                                    }
                                    else
                                    {
                                        self.storiesViewHeight = 0.0
                                    }
                                    self.postView.isHidden = true
                                    self.postView.frame.size.height = 0
                                    
                                    if self.birthdayView.isHidden == true{
                                        self.birthdayView.frame.origin.y = 0
                                        self.birthdaybuttonsFrame.frame.origin.y = 0
                                    }
                                    else
                                    {
                                        self.birthdayView.frame.origin.y = self.postView.frame.size.height + 5 + self.storiesViewHeight
                                        self.birthdaybuttonsFrame.frame.origin.y = 215 + self.postView.frame.size.height + 5 + self.storiesViewHeight
                                        if isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved {
                                            self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.birthdayView) + self.birthdaybuttonsFrame.frame.size.height + 5
                                            self.scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView)
                                        }
                                    }
                                    self.webframe.frame.origin.y = self.postView.frame.size.height + 7 + self.storiesViewHeight
                                    if isAddFriendWidgetEnable == 1 {
                                        self.tableHeaderHight = self.storiesViewHeight + 5 + self.postView.frame.size.height + 7 + self.webframe.frame.size.height + self.noContentView.frame.size.height
                                    }
                                    else {
                                        self.tableHeaderHight = self.storiesViewHeight + 5 + self.postView.frame.size.height + 7 + self.webframe.frame.size.height
                                    }
                                    globalFeedHeight = self.tableHeaderHight
                                    self.feedObj.tableView.reloadData()
                                    self.showfeedFilter()
                                }
                            }
                            else if show_storySetting != UserDefaults.standard.integer(forKey: "isSitestoriesEnable")
                            {
                                show_storySetting = UserDefaults.standard.integer(forKey: "isSitestoriesEnable")
                                if logoutUser == false
                                {
                                    //Stories View
                                    if show_story == 1 && show_storySetting == 1
                                    {
                                        self.storiesViewHeight = 115.0
                                        self.storiesView =  StoriesView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.storiesViewHeight), vc: self)
                                        self.storiesView?.objAAF = self
                                        self.storiesView?.delegateStoryNotUploaded = self
                                        self.storiesView?.layer.borderWidth = 0.0
                                        self.storiesView?.layer.borderColor = cellBackgroundColor.cgColor
                                        self.feedObj.tableView.addSubview(self.storiesView!)
                                        self.postView.frame.origin.y = self.storiesViewHeight+5
                                        self.storiesView?.isHidden = false
                                        
                                        self.storiesView?.objAAF = self
                                        self.storiesView?.delegateStoryNotUploaded = self
                                        self.storiesView?.updateStoriesData(isDataUpdate: false)
                                    }
                                    else
                                    {
                                        self.storiesViewHeight = 0.0
                                        self.postView.frame.origin.y = self.storiesViewHeight
                                        self.storiesView?.isHidden = true
                                    }
                                    //                                    self.postView.isHidden = true
                                    //                                    self.postView.frame.size.height = 0
                                    
                                    if self.birthdayView.isHidden == true{
                                        self.birthdayView.frame.origin.y = 0
                                        self.birthdaybuttonsFrame.frame.origin.y = 0
                                    }
                                    else
                                    {
                                        self.birthdayView.frame.origin.y = self.postView.frame.size.height + 5 + self.storiesViewHeight
                                        self.birthdaybuttonsFrame.frame.origin.y = 215 + self.postView.frame.size.height + 5 + self.storiesViewHeight
                                        if isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved {
                                            self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.birthdayView) + self.birthdaybuttonsFrame.frame.size.height + 5
                                            self.scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView)
                                        }
                                    }
                                    self.webframe.frame.origin.y = self.postView.frame.size.height + 7 + self.storiesViewHeight
                                    if isAddFriendWidgetEnable == 1 {
                                        self.tableHeaderHight = self.storiesViewHeight + 5 + self.postView.frame.size.height + 7 + self.webframe.frame.size.height + self.noContentView.frame.size.height
                                    }
                                    else {
                                        self.tableHeaderHight = self.storiesViewHeight + 5 + self.postView.frame.size.height + 7 + self.webframe.frame.size.height
                                    }
                                    globalFeedHeight = self.tableHeaderHight
                                    
                                }
                                self.showfeedFilter()
                            }
                            else if show_storySetting != UserDefaults.standard.integer(forKey: "isSitestoriesEnable")
                            {
                                show_storySetting = UserDefaults.standard.integer(forKey: "isSitestoriesEnable")
                                if logoutUser == false
                                {
                                    //Stories View
                                    if show_story == 1 && show_storySetting == 1
                                    {
                                        self.storiesViewHeight = 115.0
                                        self.storiesView =  StoriesView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.storiesViewHeight), vc: self)
                                        self.storiesView?.objAAF = self
                                        self.storiesView?.delegateStoryNotUploaded = self
                                        self.storiesView?.layer.borderWidth = 0.0
                                        self.storiesView?.layer.borderColor = cellBackgroundColor.cgColor
                                        self.feedObj.tableView.addSubview(self.storiesView!)
                                        self.postView.frame.origin.y = self.storiesViewHeight+5
                                        self.storiesView?.isHidden = false
                                        
                                        self.storiesView?.objAAF = self
                                        self.storiesView?.delegateStoryNotUploaded = self
                                        self.storiesView?.updateStoriesData(isDataUpdate: false)
                                    }
                                    else
                                    {
                                        self.storiesViewHeight = 0.0
                                        self.postView.frame.origin.y = self.storiesViewHeight
                                        self.storiesView?.isHidden = true
                                    }
                                    //                                    self.postView.isHidden = true
                                    //                                    self.postView.frame.size.height = 0
                                    
                                    if self.birthdayView.isHidden == true{
                                        self.birthdayView.frame.origin.y = 0
                                        self.birthdaybuttonsFrame.frame.origin.y = 0
                                    }
                                    else
                                    {
                                        self.birthdayView.frame.origin.y = self.postView.frame.size.height + 5 + self.storiesViewHeight
                                        self.birthdaybuttonsFrame.frame.origin.y = 215 + self.postView.frame.size.height + 5 + self.storiesViewHeight
                                        if isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved {
                                            self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.birthdayView) + self.birthdaybuttonsFrame.frame.size.height + 5
                                            self.scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView)
                                        }
                                    }
                                    self.webframe.frame.origin.y = self.postView.frame.size.height + 7 + self.storiesViewHeight
                                    if isAddFriendWidgetEnable == 1 {
                                        self.tableHeaderHight = self.storiesViewHeight + 5 + self.postView.frame.size.height + 7 + self.webframe.frame.size.height + self.noContentView.frame.size.height
                                    }
                                    else {
                                        self.tableHeaderHight = self.storiesViewHeight + 5 + self.postView.frame.size.height + 7 + self.webframe.frame.size.height
                                    }
                                    
                                    globalFeedHeight = self.tableHeaderHight
                                    
                                }
                                self.showfeedFilter()
                            }
                            self.feedObj.globalArrayFeed = feedArray
                            // Set View If their is no feed in response
                            if isAddFriendWidgetEnable == 0 || self.friendWidgetRemoved  {
                                if feedArray.count == 0
                                {
                                    if self.friendWidgetRemoved {
                                        self.feedObj.tableView.addSubview(self.noContentView)
                                        self.noContentView.frame.size.height = 120
                                        self.noContentView.backgroundImage.frame.size.height = 120
                                    }
                                    self.noContentView.crossButton.isHidden = true
                                    self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.scrollableCategory) + 13
                                    if self.scrollableCategory.frame.height > 0 {
                                        self.noContentView.isHidden = false
                                        self.noContentView.button.titleLabel?.adjustsFontSizeToFitWidth = true
                                    }
                                    else {
                                        self.noContentView.isHidden = true
                                    }
                                    
                                    self.feedObj.tableView.tableFooterView?.isHidden = true
                                }
                                else {
                                    self.noContentView.isHidden = true
                                }
                            }
                            if feedArray.count == 0 && isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved {
                                self.noContentLabel = UILabel()
                                self.noContentLabel.isHidden = false
                                self.noContentLabel.frame = CGRect(x: 0, y: getBottomEdgeY(inputView: self.scrollableCategory) + 25, width: self.view.frame.size.width, height: 40)
                                self.noContentLabel.numberOfLines = 2
                                self.noContentLabel.font = UIFont.systemFont(ofSize: FONTSIZENormal)
                                self.noContentLabel.center.x = self.view.center.x
                                self.noContentLabel.textAlignment = .center
                                self.feedObj.tableView.addSubview(self.noContentLabel)
                                self.noContentLabel.textColor = buttonColor
                                self.noContentLabel.text = "No feeds to display at this \nmoment"
                            }
                            else {
                                self.noContentLabel.isHidden = true
                            }
                            if isAddFriendWidgetEnable == 0 {
                                if feedArray.count < self.defaultFeedCount{
                                    
                                    self.feedObj.tableView.tableFooterView?.isHidden = false
                                    self.feedObj.tableView.tableFooterView?.frame.size.height = 120
                                    let noPostView = NoPostView(frame: (self.feedObj.tableView.tableFooterView?.frame)!)
                                    self.feedObj.tableView.tableFooterView = noPostView
                                    noPostView.button.layer.cornerRadius = noPostView.button.frame.height/2
                                    self.noPost = false
                                    noPostView.button.titleLabel?.adjustsFontSizeToFitWidth = true
                                    noPostView.button.addTarget(self, action: #selector(self.goToMember), for: .touchUpInside)
                                    self.noPostViewSet = true
                                    noPostView.crossButton.isHidden = true
                                    self.noContentView.isHidden = true
                                    
                                }
                            }
                            else
                            {
                                // Reload Tabel After Updation
                                self.newFeedUpdateCounter = 0
                                self.feedObj.refreshLikeUnLike = true
                                if self.birthdayView.isHidden == false && isAddFriendWidgetEnable == 1 && !self.friendWidgetRemoved{
                                     self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.birthdayView) + self.birthdaybuttonsFrame.frame.size.height + 5
                                     self.scrollableCategory.frame.origin.y = getBottomEdgeY(inputView: self.noContentView) + 5
                                }
                            }
                            self.feedObj.tableView.reloadData()
                            if NotPlay != 1 {
                                self.feedObj.pausePlayeVideos()
                            }
                            
                            if afterPost == true{
                                afterPost = false
                                DispatchQueue.main.async(execute:  {
                                    soundEffect("post")
                                })
                                
                            }
                            self.updateScrollFlag = true
                            self.activityFeeds.removeAll(keepingCapacity: false)
                            self.startMyTimer()
                            // Create Timer for Check UPdtes Repeatlly
                           
                            
                        }
                        
                    }
                    else
                    {
                        // Show Message on Failour
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        self.updateScrollFlag = true
                    }
                })
            }
        }
        else
        {
            // No Internet Connection Message
            if feedArray.count > 0
            {
                if checkQuickContentPostExist() == false
                {
                    feedArray = feedArrayTemp + feedArray
                }
                self.feedObj.globalArrayFeed = feedArray
                self.feedObj.refreshLikeUnLike = true
                self.feedObj.tableView.reloadData()
            }
            showToast(message: network_status_msg, controller: self)
            
            
        }
         self.startMyTimer()
        
        
    }
    
    // MARK:  UIScrollViewDelegate
    // Handle Scroll For Pagination
    func didScroll(){
        //func ScrollingactionAdvanceActivityFeed(_ notification: NSNotification){
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        greetingsWebView.scrollView.contentOffset.y = 0
        // Removing new feed tip while on top
        if feedObj.tableView.contentOffset.y < 20 && self.updateNewFeed == true
        {
            if let newFeedsButton = self.mainView.viewWithTag(2020) {
                // myButton already existed
                newFeedsButton.removeFromSuperview()
            }
            self.browseFeed()
            self.newFeedUpdateCounter = 0
            self.updateNewFeed = false
            if searchDic.count == 0 && gutterMenu1.count > 0
            {
                if let dic = self.gutterMenu1[0] as? NSDictionary
                {
                    // Set Parameters for Feed Filter
                    if let params = dic["urlParams"] as? NSDictionary
                    {
                        
                        searchDic["filter_type"] = params["filter_type"] as? String
                        
                    }
                }
            }
            else
            {
                searchDic["filter_type"] = "all"
                
                
            }
            
        }
        if updateScrollFlag{
            // Check for PAGINATION
            if feedObj.tableView.contentSize.height > feedObj.tableView.bounds.size.height{
                if feedObj.tableView.contentOffset.y >= (feedObj.tableView.contentSize.height - feedObj.tableView.bounds.size.height)
                {
                    if Reachabable.isConnectedToNetwork()
                    {
                        if feedArray.count > 0
                        {
                            if maxid == 0
                            {
                                if isAddFriendWidgetEnable == 0 {
                                    if self.noPostViewSet == false {
                                        feedObj.tableView.tableFooterView?.isHidden = false
                                        feedObj.tableView.tableFooterView?.frame.size.height = 120
                                        let noPostView = NoPostView(frame: (feedObj.tableView.tableFooterView?.frame)!)
                                        feedObj.tableView.tableFooterView = noPostView
                                        noPostView.button.layer.cornerRadius = noPostView.button.frame.height/2
                                        noPost = false
                                        
                                        noPostView.button.addTarget(self, action: #selector(goToMember), for: .touchUpInside)
                                    }
                                }
                                
                            }
                            else
                            {
                                if self.noPostViewSet == false {
                                    feedObj.tableView.tableFooterView?.isHidden = true
                                }
                                else {
                                    feedObj.tableView.tableFooterView?.isHidden = false
                                }
                                // Request for Pagination
                                updateScrollFlag = false
                                if searchDic["filter_type"] == "schedule_post"{
                                    feed_filter = 1
                                    //                                    if noPost == true
                                    //                                    {
                                    //                                        feedObj.tableView.tableFooterView?.isHidden = true
                                    ////                                        feedObj.tableView.tableFooterView?.frame.size.height = 120
                                    ////                                        let noPostView = NoPostView(frame: (feedObj.tableView.tableFooterView?.frame)!)
                                    ////                                        feedObj.tableView.tableFooterView = noPostView
                                    ////                                        noPostView.button.layer.cornerRadius = noPostView.button.frame.height/2
                                    ////                                        noPost = false
                                    ////
                                    ////                                        noPostView.button.addTarget(self, action: #selector(goToMember), for: .touchUpInside)
                                    //                                    }
                                }
                                else{
                                    feed_filter = 0
                                    if self.noPostViewSet == false {
                                        showSpinner = true
                                        CreateFooter()
                                    }
                                    
                                }
                                
                                if adsType_feeds == 2 || adsType_feeds == 4{
                                    
                                    delay(0.1) {
                                        self.feedObj.checkforAds()
                                    }
                                }
                                self.browseFeed()
                                self.API_getAAFList()
                            }
                            noPost = true
                        }
                    }
                }
            }
        }
        
    }
    @objc func goToMember() {
        let vc = MemberViewController()
        vc.contentType = "members"
        vc.mapormember = 1
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openMessage(sender:UIButton)
    {
        if logoutUser == true
        {
            
            showToast(message: "You are not allowed to see this page !!", controller: self)
            
        }else{
            
            let presentedVC = MessageViewController()
            (presentedVC as MessageViewController).showOnlyMyContent = false
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        
    }
    
    func openRequest(sender:UIButton){
        
        if logoutUser == true{
            showToast(message: "You are not allowed to see this page !!", controller: self)
        }else{
            let presentedVC = RequestViewController()
            presentedVC.showOnlyMyContent = false
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        
    }
    
    func openNotification(sender:UIButton){
        if logoutUser == true{
            showToast(message: "You are not allowed to see this page !!", controller: self)
            
        }else{
            let presentedVC = NotificationViewController()
            (presentedVC as NotificationViewController).showOnlyMyContent = false
            navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        
    }
    
    func checkMiniMenu()
    {
        
        if (logoutUser == false && (totalNotificationCount !=  nil))
        {
            
            let leftNavView = UIView(frame: CGRect(x: 0,y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            
            let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvanceActivityFeedViewController.openSlideMenu))
            leftNavView.addGestureRecognizer(tapView)
            let menuImageView = createImageView(CGRect(x:0,y:12,width:22,height:22), border: false)
            menuImageView.image = UIImage(named: "dashboard_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(menuImageView)
            
            if totalNotificationCount > 0
            {
                
                let countLabel = createLabel(CGRect(x: 17, y: 3, width: 17,height: 17), text: String(totalNotificationCount), alignment: .center, textColor: textColorLight)
                countLabel.backgroundColor = UIColor.red
                countLabel.layer.cornerRadius = countLabel.frame.size.width / 2;
                countLabel.layer.masksToBounds = true
                countLabel.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
                leftNavView.addSubview(countLabel)
                let barButtonItem = UIBarButtonItem(customView: leftNavView)
                self.navigationItem.leftBarButtonItem = barButtonItem
            }
            
        }
        
        
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func changeColor(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            let presentedVC = NotificationViewController()
            (presentedVC as NotificationViewController).showOnlyMyContent = false
            navigationController?.pushViewController(presentedVC, animated: true)
            self.view.backgroundColor = UIColor.green
        case 2:
            self.view.backgroundColor = UIColor.blue
        default:
            self.view.backgroundColor = UIColor.purple
            
            
        }
    }
    
    @objc func showProfile()
    {
        
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.strProfileImageUrl = coverImage
        presentedVC.strUserName = displayName
        presentedVC.subjectType = "user"
        presentedVC.subjectId = "\(currentUserId)"
        presentedVC.fromActivity = false
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    
    func sideMenuWillOpen() {
        openSideMenu = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(AdvanceActivityFeedViewController.openSlideMenu))
        mainView.addGestureRecognizer(tapGesture)
        self.view.isUserInteractionEnabled = false
    }
    
    func sideMenuWillClose() {
        openSideMenu = false
        mainView.removeGestureRecognizer(tapGesture)
        self.view.isUserInteractionEnabled = true
    }
    
    @objc func searchItem()
    {
        if openSideMenu{
            openSideMenu = false
            //
            return
            
        }
        DispatchQueue.main.async {
            let pv = CoreAdvancedSearchViewController()
            feedUpdate = false
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(pv, animated: false)
        }
        
    }
    
    // Get suggetions from server
    @objc func getSuggestions()
    {
        if Reachabable.isConnectedToNetwork(){
            
            let parameters = ["limit": String(suggestionsLimit), "restapilocation": ""]
            userSuggestions.removeAll(keepingCapacity: false)
            let url = "suggestions/suggestion-listing"
            post(parameters, url: url, method: "GET", postCompleted: { (succeeded, msg) in
                
                DispatchQueue.main.async(execute: {
                    if msg{
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if response["users"] != nil {
                                if let suggestion = response["users"] as? NSArray {
                                    userSuggestions = userSuggestions + suggestion
                                    enableSuggestion = true // If we set it false then only starting suggested friends will always shown and no any further calling of api of suggestion.
                                    self.feedObj.isHomeFeeds = true
                                    self.feedObj.refreshLikeUnLike = true
                                    self.feedObj.tableView.reloadData()
                                }
                            }
                            
                        }
                        
                    }
                    else
                    {
                        // Handle Server Error
                        if succeeded["message"] != nil && enabledModules.contains("suggestion")
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                    }
                })
            })
        }
        
    }
    
    func CreateFooter()
    {
        var yAxis = -12
        if DeviceType.IS_IPHONE_X
        {
            yAxis = -9
        }
        let
        footerView = UIView(frame: CGRect(x: 0, y: yAxis, width: Int(self.view.bounds.width), height: 25))
        footerView.backgroundColor = UIColor.clear
        
        let activityIndicator = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicator.center = footerView.center//CGPoint(x:(footerView.bounds.width - 25)/2, y:2.0)
        footerView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        feedObj.tableView.tableFooterView = footerView
        feedObj.tableView.tableFooterView?.isHidden = true
    }
    
    func getchacheFeed()
    {
        let request:NSFetchRequest<ActivityFeedData>
        
        if #available(iOS 10.0, *)
        {
            request = ActivityFeedData.fetchRequest() as! NSFetchRequest<ActivityFeedData>
        }
        else
        {
            request = NSFetchRequest(entityName: "ActivityFeedData")
        }
        request.returnsObjectsAsFaults = false
        let results = try? context.fetch(request)
        if(results?.count>0)
        {
            // If exist Token than Update
            for result: AnyObject in results!
            {
                
                let newDictionary:NSMutableDictionary = [:]
                if result.value(forKey: "subjectAvatarImage") != nil
                {
                    newDictionary["subject_image"] = result.value(forKey: "subjectAvatarImage")
                }
                if result.value(forKey: "subjectAvatarImage")  != nil{
                    newDictionary["subject_image"] = result.value(forKey:"subjectAvatarImage")
                }
                if result.value(forKey: "feedTitle")  != nil{
                    newDictionary["feed_title"] = result.value(forKey:"feedTitle")
                }
                if result.value(forKey: "creationDate")   != nil{
                    newDictionary["feed_createdAt"] = result.value(forKey:"creationDate")
                }
                if result.value(forKey: "commentCount")  != nil{
                    newDictionary["comment_count"] = result.value(forKey:"commentCount")
                }
                if result.value(forKey: "likeCount")  != nil{
                    newDictionary["likes_count"] = result.value(forKey:"likeCount")
                }
                if result.value(forKey: "attachment")  != nil{
                    newDictionary["attachment"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"attachment") as! NSData) as Data)
                }
                if result.value(forKey: "attachmentCount")  != nil{
                    newDictionary["attactment_Count"] = result.value(forKey:"attachmentCount")
                }
                if result.value(forKey: "action_Id") != nil{
                    newDictionary["action_id"] = result.value(forKey:"action_Id")
                }
                if result.value(forKey: "subject_Id") != nil{
                    newDictionary["subject_id"] = result.value(forKey:"subject_Id")
                }
                if result.value(forKey: "share_params_id") != nil{
                    newDictionary["share_params_id"] = result.value(forKey: "share_params_id")
                }
                if result.value(forKey: "share_params_type") != nil{
                    newDictionary["share_params_type"] = result.value(forKey: "share_params_type")
                }
                if result.value(forKey: "feedType")  != nil{
                    newDictionary["feed_Type"] = result.value(forKey: "feedType")
                }
                if result.value(forKey: "feedMenu")  != nil{
                    newDictionary["feed_menus"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey: "feedMenu") as! NSData) as Data)
                }
                if result.value(forKey: "feed_footer_menus")  != nil{
                    newDictionary["feed_footer_menus"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey: "feed_footer_menus") as! NSData) as Data)
                }
                if result.value(forKey: "feed_reactions")  != nil{
                    newDictionary["feed_reactions"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey: "feed_reactions") as! NSData) as Data)
                }
                if result.value(forKey: "my_feed_reaction")  != nil{
                    newDictionary["my_feed_reaction"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey: "my_feed_reaction") as! NSData) as Data)
                }
                if result.value(forKey: "canComment")   != nil{
                    newDictionary["comment"] = result.value(forKey: "canComment")
                }
                if result.value(forKey: "canDelete")   != nil{
                    newDictionary["delete"] = result.value(forKey: "canDelete")
                }
                if result.value(forKey: "canShare")   != nil{
                    newDictionary["share"] = result.value(forKey: "canShare")
                }
                if result.value(forKey: "isLike")   != nil{
                    newDictionary["is_like"] = result.value(forKey: "isLike")
                }
                
                if result.value(forKey: "photo_attachment_count")   != nil{
                    newDictionary["photo_attachment_count"] = result.value(forKey: "photo_attachment_count")
                    
                }
                if result.value(forKey: "object_id")   != nil{
                    newDictionary["object_id"] = result.value(forKey: "object_id")
                }
                if result.value(forKey: "object_type")  != nil{
                    newDictionary["object_type"] = result.value(forKey: "object_type")
                }
                if result.value(forKey:"params")   != nil{
                    newDictionary["params"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"params") as! NSData) as Data)
                }
                if result.value(forKey:"object")  != nil{
                    newDictionary["object"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"object") as! NSData) as Data)
                }
                
                
                if result.value(forKey:"tags")   != nil{
                    newDictionary["tags"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"tags") as! NSData) as Data)
                    
                }
                if result.value(forKey:"action_type_body_params")   != nil{
                    newDictionary["action_type_body_params"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"action_type_body_params") as! NSData) as Data)
                }
                if result.value(forKey:"action_type_body")   != nil{
                    newDictionary["action_type_body"] = result.value(forKey:"action_type_body")
                }
                if result.value(forKey:"hashtags")  != nil{
                    newDictionary["hashtags"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"hashtags") as! NSData) as Data)
                }
                if result.value(forKey:"userTag")   != nil{
                    newDictionary["userTag"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"userTag") as! NSData) as Data)
                }
                if result.value(forKey:"decoration")   != nil{
                    newDictionary["decoration"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"decoration") as! NSData) as Data)
                }
                if result.value(forKey:"wordStyle")   != nil{
                    newDictionary["wordStyle"] = NSKeyedUnarchiver.unarchiveObject(with: (result.value(forKey:"wordStyle") as! NSData) as Data)
                }
                if result.value(forKey: "publish_date")  != nil{
                    newDictionary["publish_date"] = result.value(forKey:"publish_date")
                }
                if result.value(forKey: "isNotificationTurnedOn")  != nil{
                    newDictionary["isNotificationTurnedOn"] = result.value(forKey:"isNotificationTurnedOn")
                    
                }
                if result.value(forKey: "attachment_content_type")  != nil{
                    newDictionary["attachment_content_type"] = result.value(forKey: "attachment_content_type")
                }
                
                // Update feedArray to show 1st Time Feed from Core Data Result
                feedArray.append(newDictionary)
                
            }
            
            do {
                try context.save()
            } catch _ {
            }
        }
        
    }
    
    @objc func showMassNotification(userInfo: NSNotification)
    {
        if let contentInfo = userInfo.userInfo
        {
            //            print(contentInfo)
            guard let aps = contentInfo[AnyHashable("aps")] as? NSDictionary, let alert = aps["alert"] as? String else
            {
                return
            }
            let alertBox = UIAlertController(title: "Notification", message: alert, preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertBox.addAction(action)
            self.present(alertBox, animated: true, completion: nil)
        }
    }
    // MARK: Redirecting through push notification
    @objc func showContent(userInfo: NSNotification)
    {
        //let view1 =  feedObj.tableView.subviews
        
        activityIndicatorView.center = CGPoint(x: UIScreen.main.bounds.width/2 , y : UIScreen.main.bounds.height/2)
        UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)//addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        appUpdateAvailable(completion: { (check) in
            
            var checkBoolUpgrade : Bool = false
            let defaults = UserDefaults.standard
            if let name = defaults.object(forKey: "forceUpgrade")
            {
                if  UserDefaults.standard.object(forKey: "forceUpgrade") != nil {
                    
                    checkBoolUpgrade = name as! Bool
                    
                }
            }
            
            
            if checkBoolUpgrade == true {
                print("======updates here=====")
            }
            else{
                
                if let contentInfo = userInfo.userInfo {
                    let objectType = contentInfo["type"] as? String ?? ""
                    //                    print("objectType -- ",objectType)
                    var objectId : Int = 0
                    if contentInfo["id"] != nil{
                        let objId = "\(contentInfo["id"]!)"
                        objectId = Int(objId) ?? 0
                    }
                    //                    print(type(of : contentInfo["id"]!))
                    //                    print("objectId -- ",objectId)
                    var parentId : Int = 0
                    if contentInfo["parent_id"] != nil{
                        let ParId = "\(contentInfo["parent_id"]!)"
                        parentId  = Int(ParId) ?? 0
                    }
                    //                    print("parentId -- ",parentId)
                    let objectUrl = contentInfo["href"] as? String ?? ""
                    //                    print("objectUrl -- ",objectUrl)
                    let parentType = contentInfo["parent_type"] as? String ?? ""
                    //                    print("parentType -- ", parentType)
                    var video_type :Int = 0
                    if contentInfo["video_type"] != nil{
                        let VideoId = "\(contentInfo["video_type"]!)"
                        video_type = Int(VideoId) ?? 0
                    }
                    //                    print("video_type -- ", video_type)
                    let enable_module = contentInfo["enable_module"] as? String ?? ""
                    print("enable_module -- ",enable_module)
                    
                    switch (objectType){
                        
                    case "friendRequest":
                        let presentedVC = FriendRequestViewController()
                        presentedVC.contentType = "friendmembers"
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        break
                        
                    case "user":
                        
                        
                        let presentedVC = ContentActivityFeedViewController()
                        presentedVC.subjectType = "user"
                        presentedVC.subjectId = "\(objectId)"
                        presentedVC.fromDashboard =  true
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        break
                        
                        //            case "activity_action":
                        //                let presentedVC = FeedViewPageViewController()
                        //                presentedVC.action_id = objectId
                        //                navigationController?.pushViewController(presentedVC, animated: true)
                        //                break
                        
                    case "activity_action":
                        
                        likeCommentContent_id = "\(objectId)"
                        likeCommentContentType = objectType
                        let presentedVC = CommentsViewController()
                        presentedVC.openCommentTextView = 1
                        presentedVC.actionId = "\(objectId)"
                        //presentedVC.activityfeedIndex = indexPath.row
                        presentedVC.activityFeedComment = true
                        presentedVC.fromActivityFeed = true
                        presentedVC.fromSingleFeed = true
                        presentedVC.fromNotification = true
                        presentedVC.commentPermission = 1
                        presentedVC.reactionsIcon = []
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        
                    case "activity_comment":
                        
                        likeCommentContent_id = "\(parentId)"
                        likeCommentContentType = parentType //"activity_action"//objectType
                        let presentedVC = CommentsViewController()
                        presentedVC.openCommentTextView = 1
                        
                        // Set to parentId. Earlier it was set to commentId. So error was comming when openening CommentViewController
                        presentedVC.actionId = "\(parentId)"
                        //presentedVC.activityfeedIndex = indexPath.row
                        presentedVC.activityFeedComment = true
                        presentedVC.fromActivityFeed = true
                        presentedVC.fromSingleFeed = true
                        presentedVC.fromNotification = true
                        presentedVC.commentPermission = 1
                        presentedVC.reactionsIcon = []
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        
                    case "blog":
                        BlogObject().redirectToBlogDetailPage(self, blogId: objectId, title: "")
                        break
                        
                    case "classified":
                        ClassifiedObject().redirectToProfilePage(self, id: objectId)
                        break
                        
                    case "music_playlist":
                        MusicObject().redirectToPlaylistPage(self,id: objectId)
                        break
                        
                    case "album":
                        let presentedVC = AlbumProfileViewController()
                        presentedVC.albumId = "\(objectId)"
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        break
                        
                    case "group":
                        let presentedVC = ContentFeedViewController()
                        presentedVC.subjectType = "group"
                        presentedVC.subjectId = "\(objectId)"
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        break
                        
                    case "siteevent_event":
                        let presentedVC = ContentFeedViewController()
                        presentedVC.subjectType = "advancedevents"
                        presentedVC.subjectId = "\(objectId)"
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        break
                        
                    case "event":
                        let presentedVC = ContentFeedViewController()
                        presentedVC.subjectType = "event"
                        presentedVC.subjectId = "\(objectId)"
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        break
                        
                    case "sitevideo_channel":
                        SitevideoObject().redirectToChannelProfilePage(self, videoId: "\(objectId)",subjectType: objectType)
                        //print("channel")
                        break
                        
                    case "sitepage_page":
                        SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: "\(objectId)")
                        break
                        
                    case "poll":
                        let presentedVC = PollProfileViewController()
                        presentedVC.pollId = objectId
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                        break
                        
                    case "video":
                        
                        print(contentInfo)
                        if contentInfo["notification_type"] as! String == "live_streaming" {
                            let url = "livestreamingvideo/is-live"
                            let method = "GET"
                            var dic1 = [String : String]()
                            var chName = ""
                            if contentInfo["stream_name"] != nil {
                                dic1["stream_name"] = contentInfo["stream_name"] as! String
                                chName = contentInfo["stream_name"] as! String
                            }
                            var main_subject_id :Int = 0
                            if contentInfo["main_subject_id"] != nil{
                                let VideoId = "\(contentInfo["main_subject_id"]!)"
                                main_subject_id = Int(VideoId) ?? 0
                            }
                            var main_subject_type = ""//contentInfo["main_subject_type"] as! String
                            if contentInfo["main_subject_type"] != nil {
                                main_subject_type = contentInfo["main_subject_type"] as! String
                            }
                            
                            post(dic1 , url: "\(url)", method: method) { (succeeded, msg) -> () in
                                DispatchQueue.main.async(execute: {
                                    
                                    
                                    if msg{
                                        //   activityIndicatorView.stopAnimating()
                                        if succeeded["body"] != nil
                                        {
                                            
                                            if let response = succeeded["body"] as? NSDictionary
                                            {
                                                if response["isLive"] as! Int == 0 {
                                                    
                                                    
                                                    if response["endType"] as! String == "normal" || response["endType"] as! String == "story"{
                                                        showToast(message: "Live Streaming is not available.", controller: self)
                                                    }
                                                    else{
                                                        VideoObject().redirectToVideoProfilePage(self, videoId : objectId, videoType : video_type, videoUrl : objectUrl)
                                                        
                                                    }
                                                }
                                                    
                                                else{
                                                    CFRunLoopWakeUp(CFRunLoopGetCurrent())
                                                   
                                                    let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                                                    if let liveStreamingClass = NSClassFromString(moduleName + "." + "LiveObjectViewController") as? LiveStreamingObjectDelegates.Type{
                                                        liveStreamingClass.redirectToLivePageFromNotification(self , isBroadcaster: false , chName: chName, videoId : main_subject_id , videoType : main_subject_type)
                                                    }
                                                }
                                                
                                                
                                            }
                                        }
                                        
                                    }
                                        
                                    else{
                                        
                                        
                                    }
                                })
                            }
                        }
                            
                        else
                        {
                            
                            
                            if enable_module == "sitevideo"{
                                if video_type == 3 {
                                    let presentedVC = AdvanceVideoViewController()
                                    //(presentedVC as NotificationViewController).showOnlyMyContent = false
                                    self.navigationController?.pushViewController(presentedVC, animated: true)
                                }
                                else{
                                    SitevideoObject().redirectToAdvVideoProfilePage(self,videoId: objectId,videoType:video_type,videoUrl: objectUrl)
                                }
                            }
                            else{
                                
                                VideoObject().redirectToVideoProfilePage(self, videoId : objectId, videoType : video_type, videoUrl : objectUrl)
                            }
                        }
                        break
                        
                    case "messages_conversation":
                        let presentedVC = ConverstationViewController()
                        presentedVC.displaysendername = ""
                        presentedVC.conversation_id = objectId
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        break
                        
                    case "sitereview_wishlist":
                        
                        let presentedVC = WishlistDetailViewController()
                        presentedVC.subjectId = objectId
                        presentedVC.wishlistName = "" //
                        presentedVC.descriptionWishlist = "" // objectDictionary["body"] as! String
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        
                        break
                        
                    case "sitegroup_group":
                        SiteAdvGroupObject().redirectToAdvGroupProfilePage(self, subject_type: "sitegroup_group", subject_id: "\(objectId)")
                        break
                        
                    case "sitestore_store":
                        SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: "\(objectId)")
                        break
                        
                    case "sitestoreproduct_product":
                        SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false, product_id:"\(objectId)")
                        break
                        
                    case "sitestoreproduct_wishlist":
                        let presentedVC = WishlistDetailViewController()
                        presentedVC.productOrOthers = true
                        presentedVC.subjectId = objectId
                        presentedVC.wishlistName = "" //
                        presentedVC.descriptionWishlist = "" // objectDictionary["body"] as! String
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        
                        break
                        
                    case "sitestoreproduct_order":
                        SiteStoreObject().redirectToMyStore(viewController: self)
                        break
                        
                    case "sitestoreproduct_review":
                        let presentedVC = PageReviewViewController()
                        presentedVC.mytitle = ""
                        presentedVC.subjectId = "\(objectId)"
                        presentedVC.contentType = "product"
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        break
                        
                    case "forum_topic":
                        let presentedVC = ForumTopicViewController()
                        let url =  objectUrl
                        let arr = url.components(separatedBy: "/")
                        let count = arr.count - 1
                        presentedVC.slug = arr[count]
                        presentedVC.topicId = objectId
                        presentedVC.topicName = ""
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        break
                        
                        //TODO: sitepage_review type notification is not being received or generated
                        //            case "sitepage_review":
                        //                break
                        
                        //TODO: sitegroup_review type notification is not being received or generated
                        //            case "sitegroup_review":
                        //                break
                        
                        //TODO: sitereview_review type notification is not being received or generated
                        //            case "sitereview_review":
                        //                break
                        
                        //TODO: sitereview_listing type notification is not being received or generated
                        //            case "sitereview_listing":
                        //                break
                        
                    default:
                        //                        let presentedVC = ExternalWebViewController()
                        //                        if objectUrl != ""{
                        //                            presentedVC.url = objectUrl
                        //                             presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        //                            let navigationController = UINavigationController(rootViewController: presentedVC)
                        //                            self.present(navigationController, animated: true, completion: nil)
                        //                        }
                        let presentedVC = NotificationViewController()
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        break
                    }
                    
                }
            }
        })
    }
    
    // Redirection by universal link
    @objc func universalLinkRedirection()
    {
        var name : String = ""
        var viewPage : Bool = false
        var listingtype_id : Int = 0
        var objectId : String!
        var feedPage :Bool = false
        var videoStroViewPage:Bool = false
        var nameKey : String = ""
        let valueURL = UniversalLinkClickUrl
        UniversalLinkClickUrl = ""
        universalLinkdic.setValue("core_main_album", forKey: "albums")
        print("valueURL : ",valueURL)
        
        let fullNameArr = valueURL.components(separatedBy: "/")
        
        print("fullNameArr  : ",fullNameArr)
        print("0 index : ",fullNameArr[0])
        
        var temp : String = "UniversalLink"
        var flag : Bool = false
        
        if fullNameArr.count > 5, let actionId = fullNameArr[5] as? String , actionId == "action_id"{
            
            if fullNameArr.count > 7,let showComment = fullNameArr[7] as? String , showComment == "show_comments"
            {
                name = "profile"
                let tempArr = temp.components(separatedBy: "_")
                print("tempArr  : ",tempArr)
                
                if fullNameArr.count > 6,let secondPart = fullNameArr[6] as? String {
                    print("second part :", secondPart)
                    objectId = secondPart
                }
                
                feedPage = true
            }
        }
        if fullNameArr.count > 3 {
            if let keyName = fullNameArr[3] as? String
            {
                nameKey = keyName
                if nameKey.contains("?"){
                    if let range = nameKey.range(of: "?") {
                        nameKey = nameKey.substring(to: range.lowerBound)
                    }
                }
                
            }
        }
        if !feedPage {
            print(nameKey)
            if let value = universalLinkdic[nameKey] as? String
            {
                flag = true
                temp = value
                if value.contains("?"){
                    if let range = value.range(of: "?") {
                        temp = value.substring(to: range.lowerBound)
                    }
                }
                
            }
            else if let value = universalLinkdic[nameKey] as? NSDictionary
            {
                if fullNameArr.count > 4
                {
                    if let v1 = value[fullNameArr[4]] as? String
                    {
                        flag = true
                        temp = v1
                        
                        if v1.contains("?"){
                            if let range = v1.range(of: "?") {
                                temp = v1.substring(to: range.lowerBound)
                            }
                        }
                    }
                    else if let v2 = value[fullNameArr[4]+"_view"] as? String
                    {
                        flag = true
                        viewPage = true
                        videoStroViewPage = true
                        temp = v2
                        
                        if v2.contains("?"){
                            if let range = v2.range(of: "?") {
                                temp = v2.substring(to: range.lowerBound)
                            }
                        }
                    }
                    else
                    {
                        if let v1 = value[nameKey] as? String
                        {
                            flag = true
                            temp = v1
                            
                            if v1.contains("?"){
                                if let range = v1.range(of: "?") {
                                    temp = v1.substring(to: range.lowerBound)
                                }
                            }
                        }
                    }
                }
                else
                {
                    if let v1 = value[nameKey] as? String
                    {
                        flag = true
                        temp = v1
                        
                        if v1.contains("?"){
                            if let range = v1.range(of: "?") {
                                temp = v1.substring(to: range.lowerBound)
                            }
                        }
                    }
                }
            }
            else if let value1 = universalLinkdic[nameKey+"_view"]  as? String{
                flag = true
                viewPage = true
                temp = value1
                
                if value1.contains("?"){
                    if let range = value1.range(of: "?") {
                        temp = value1.substring(to: range.lowerBound)
                    }
                }
            }
            else {
                flag = false
            }
        }
        /////////////////////////////////////
        if flag {
            print("temp ",temp)
            name = temp
            
            let tempArr = temp.components(separatedBy: "_")
            print("tempArr  : ",tempArr)
            
            var numArray = [Int]()
            
            for index in 0 ..< (tempArr.count) {
                if let num = Int(tempArr[index]) {
                    numArray.append(num)
                    print("Valid Integer : ",num)
                }
            }
            
            if numArray.count > 0
            {
                var number = numArray[0]
                print("number: \(number)")
                listingtype_id = number
                
                if let range = temp.range(of: "_\(number)") {
                    let firstPart = temp.substring(to: range.lowerBound)
                    print("firstPart :" , firstPart) // print Hello
                    
                    name = firstPart
                    
                    if name == "sitereview_listing"
                    {
                        if numArray.count > 1
                        {
                            number = numArray[1]
                            print("categoryNumber : ",numArray[1])
                        }
                    }
                    
                    if videoStroViewPage {
                        
                        if fullNameArr.count > (4+number+1),var secondPart = fullNameArr[4+number+1] as? String {
                            print("second part :", secondPart)
                            
                            if secondPart.contains("?"){
                                if let range = secondPart.range(of: "?") {
                                    secondPart = secondPart.substring(to: range.lowerBound)
                                }
                            }
                            
                            
                            objectId = secondPart
                        }
                        
                    }
                    else if fullNameArr.count > (3+number+1),var secondPart = fullNameArr[3+number+1] as? String {
                        print("second part :", secondPart)
                        
                        if secondPart.contains("?"){
                            if let range = secondPart.range(of: "?") {
                                secondPart = secondPart.substring(to: range.lowerBound)
                            }
                        }
                        
                        objectId = secondPart
                    }
                }
                
                
            }
            if let dashboard = dashboardMenu{
                for i in 0 ..< dashboardMenu.count
                {
                    if let dic = dashboardMenu[i] as? NSDictionary
                    {
                        if let key = dic["name"] as? String
                        {
                            if key == name
                            {
                                //                            print("-----  dictionary -------")
                                //                            print(sitereviewMenuDictionary)
                                sitereviewMenuDictionary = dic
                                if let listingtypeId = dic["listingtype_id"] as? Int
                                {
                                    if listingtypeId == listingtype_id
                                    {
                                        sitereviewMenuDictionary = dic
                                        
                                        print("-----  dictionary -------")
                                        print(sitereviewMenuDictionary)
                                        break
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
        else
        {
            if fullNameArr.count > 4 && fullNameArr[3] == "core" && fullNameArr[4] == "link" {
                let presentedVC = ExternalWebViewController()
                presentedVC.url = valueURL
                presentedVC.fromDashboard = false
                self.navigationController?.pushViewController(presentedVC, animated: true)
            }
            else {
                if !feedPage {
                    print("Link not found")
                    return
                }
            }
        }
        var presentedVC : UIViewController!
        print("name---\(name)")
        if name == "profile"{
            likeCommentContent_id = objectId
            likeCommentContentType = "activity_action"
            let presentedVC = CommentsViewController()
            presentedVC.openCommentTextView = 1
            presentedVC.actionId = objectId
            //presentedVC.activityfeedIndex = indexPath.row
            presentedVC.activityFeedComment = true
            presentedVC.fromActivityFeed = true
            presentedVC.fromSingleFeed = true
            presentedVC.fromNotification = true
            presentedVC.commentPermission = 1
            presentedVC.reactionsIcon = []
            self.navigationController?.pushViewController(presentedVC, animated: true)
            return
        }
        else if name == "core_main_group"{
            if viewPage && objectId != nil {
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "group"
                presentedVC.subjectId = objectId
                self.navigationController?.pushViewController(presentedVC, animated: true)
                return
            }
            else
            {
                GroupObject().redirectToBrowsePage(self, showOnlyMyContent: false)
                return
            }
        }
        else if name == "core_main_notification" {
            presentedVC = NotificationViewController()
            (presentedVC as! NotificationViewController).showOnlyMyContent = false
        }
        else if name == "core_main_sitegroup"{
            if viewPage && objectId != nil {
                SiteAdvGroupObject().redirectToAdvGroupProfilePage(self, subject_type: "sitegroup_group", subject_id: objectId)
            }
            else
            {
                SiteAdvGroupObject().redirectToAdvGroupBrowsePage(self, showOnlyMyContent: false)
            }
            return
        }
            
        else if name == "core_main_album"{
            if fullNameArr.contains("album_id") {
                presentedVC = AlbumProfileViewController()
                let albumIdIndex = fullNameArr.index(of: "album_id")! + 1
                let albumId = fullNameArr[albumIdIndex] as? String ?? "0"
                allPhotos.removeAll()
                (presentedVC as! AlbumProfileViewController).albumId = albumId
                if fullNameArr.contains("photo_id") {
                    let photoIdIndex = fullNameArr.index(of: "photo_id")! + 1
                    let photoId = fullNameArr[photoIdIndex] as? String ?? "0"
                    (presentedVC as! AlbumProfileViewController).deeplinkingPhotoId = photoId
                }
            }
            else if fullNameArr.contains("browse") {
                presentedVC = AlbumViewController()
                (presentedVC as! AlbumViewController).showOnlyMyContent = false
            }
            else if fullNameArr.count > fullNameArr.lastIndex(of: nameKey)!  {
                if let albumId = fullNameArr[fullNameArr.count - 1] as? String {
                    presentedVC = AlbumProfileViewController()
                    allPhotos.removeAll()
                    (presentedVC as! AlbumProfileViewController).albumId = albumId
                }
            }
            else {
                presentedVC = AlbumViewController()
                (presentedVC as! AlbumViewController).showOnlyMyContent = false
                
            }
            
        }
        else if name == "core_mini_messages"{
            let presentedVC = MessageViewController()
            (presentedVC as! MessageViewController).showOnlyMyContent = false
            self.navigationController?.pushViewController(presentedVC, animated: true)
            return
        }
        else if name == "core_main_event"{
            if viewPage && objectId != nil {
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "event"
                presentedVC.subjectId = objectId
                self.navigationController?.pushViewController(presentedVC, animated: true)
            }
            else {
                EventObject().redirectToEventBrowsePage(self, showOnlyMyContent: false)
            }
            return
        }
            //hardcode value redirect to advancedevent
        else if name == "core_main_user"
        {
            if viewPage && objectId != nil {
                let presentedVC = ContentActivityFeedViewController()
                presentedVC.subjectType = "user"
                presentedVC.subjectId = objectId
                presentedVC.fromDashboard =  true
                self.navigationController?.pushViewController(presentedVC, animated: true)
                return
            }
            else {
                presentedVC = MemberViewController()
                (presentedVC as! MemberViewController).contentType = "members"
                var dashboardInfo:NSDictionary
                dashboardInfo = sitereviewMenuDictionary
                
                if let id : Int = dashboardInfo["memberViewType"] as? Int{
                    
                    (presentedVC as! MemberViewController).mapormember = id
                }
            }
        }
        else if name == "core_main_video"{
            VideoObject().redirectToVideoBrowsePage(self, showOnlyMyContent: false)
            return
            
        }
        else if name == "core_main_sitevideo"{
            if  fullNameArr.contains("-") {
                let videoIdIndex = fullNameArr.index(of: "-")! - 1
                let videoId = fullNameArr[videoIdIndex]
                if fullNameArr.contains("videoType") {
                    let videoTypeIndex = fullNameArr.index(of: "videoType")! + 1
                    let videoType = fullNameArr[videoTypeIndex]
                    SitevideoObject().redirectToAdvVideoProfilePage(self,videoId: Int(videoId)!,videoType:Int(videoType)!,videoUrl: "", isFromDeeplink: true)
                }
                else {
                    SitevideoObject().redirectToAdvVideoBrowsePage(self, showOnlyMyContent: false)
                }
                return
            }
            else if fullNameArr.contains("video") {
                let videoIdIndex = fullNameArr.index(of: "video")! - 1
                let videoId = fullNameArr[videoIdIndex]
                if fullNameArr.contains("videoType") {
                    let videoTypeIndex = fullNameArr.index(of: "videoType")! + 1
                    let videoType = fullNameArr[videoTypeIndex]
                    SitevideoObject().redirectToAdvVideoProfilePage(self,videoId: Int(videoId)!,videoType:Int(videoType)!,videoUrl: "", isFromDeeplink: true)
                }
                else {
                    SitevideoObject().redirectToAdvVideoBrowsePage(self, showOnlyMyContent: false)
                }
                return
            }
            else if fullNameArr.contains("channel_id") {
                let videoIdIndex = fullNameArr.index(of: "channel_id")! - 2
                let videoId = fullNameArr[videoIdIndex]
                if fullNameArr.contains("videoType") {
                    let videoTypeIndex = fullNameArr.index(of: "videoType")! + 1
                    let videoType = fullNameArr[videoTypeIndex]
                    SitevideoObject().redirectToAdvVideoProfilePage(self,videoId: Int(videoId)!,videoType:Int(videoType)!,videoUrl: "", isFromDeeplink: true)
                }
                else {
                    SitevideoObject().redirectToAdvVideoBrowsePage(self, showOnlyMyContent: false)
                }
                return
            }
            SitevideoObject().redirectToAdvVideoBrowsePage(self, showOnlyMyContent: false)
            return
            
        }
        else if name == "core_main_sitevideochannel"{
            if viewPage && objectId != nil {
                SitevideoObject().redirectToChannelProfilePage(self, videoId: objectId,subjectType: "sitevideo_channel")
            }
            else {
                SitevideoObject().redirectToChannelBrowsePage(self, showOnlyMyContent: false)
            }
            return
            //presentedVC = ChannelProfileViewController()
        }
        else if name == "core_main_sitevideoplaylist"{
            if viewPage && objectId != nil {
                if let id = objectId {
                    if let obj = Int(id) {
                        SitevideoObject().redirectToPlaylistProfilePage(self, playlistId: "\(obj)" ,subjectType: "sitevideo_playlist")
                    }
                    else {
                        let index = fullNameArr.index(of: objectId!)! - 1
                        SitevideoObject().redirectToPlaylistProfilePage(self, playlistId: fullNameArr[index] ,subjectType: "sitevideo_playlist")
                    }
                }
            }
            else {
                SitevideoObject().redirectToPlaylistBrowsePage(self, showOnlyMyContent: false)
            }
            return
        }
        else if name == "core_main_siteevent"
        {
            if viewPage && objectId != nil {
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "advancedevents"
                presentedVC.subjectId = objectId
                self.navigationController?.pushViewController(presentedVC, animated: true)
                return
            }
            else
            {
                AdvanceEventObject().redirectToAdvanceEventBrowsePage(self, showOnlyMyContent: false)
            }
            return
        }
            //For multiple listings
        else if name == "sitereview_listing" {
            if viewPage && objectId != nil {
                SiteMltObject().redirectToMltProfilePage(self ,subjectType : "sitereview_listing" , listingTypeIdValue : listingtype_id , listingIdValue : objectId, viewTypeValue : sitereviewMenuDictionary["viewProfileType"] as! Int)
            }
            else {
                showGoogleMapView = false
                mltToggleView = false
                listingNameToShow = sitereviewMenuDictionary["headerLabel"] as! String
                
                let browseType = sitereviewMenuDictionary["viewBrowseType"] as! Int
                let viewType = sitereviewMenuDictionary["viewProfileType"] as! Int
                
                if MLTbrowseOrMyListings == nil{
                    MLTbrowseOrMyListings = true
                }
                SiteMltObject().redirectToMltBrowsePage(self, showOnlyMyContent: false, listingTypeIdValue : sitereviewMenuDictionary["listingtype_id"] as! Int , listingNameValue : sitereviewMenuDictionary["headerLabel"] as! String , MLTbrowseorMyListingsValue : MLTbrowseOrMyListings! , browseTypeValue : browseType , viewTypeValue : viewType,dashboardMenuDic : sitereviewMenuDictionary)
            }
            return
        }
        else if name == "core_main_sitepage"{
            if viewPage && objectId != nil {
                SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: objectId)
            }
            else {
                if fullNameArr.contains("album_id") {
                    presentedVC = AlbumProfileViewController()
                    (presentedVC as! AlbumProfileViewController).contentType = "sitepage_photo"
                    let albumIdIndex = fullNameArr.index(of: "album_id")! + 1
                    let albumId = fullNameArr[albumIdIndex] as? String ?? "0"
                    allPhotos.removeAll()
                    (presentedVC as! AlbumProfileViewController).albumId = albumId
                    if fullNameArr.contains("photo_id") {
                        let photoIdIndex = fullNameArr.index(of: "photo_id")! + 1
                        let photoId = fullNameArr[photoIdIndex] as? String ?? "0"
                        (presentedVC as! AlbumProfileViewController).deeplinkingPhotoId = photoId
                       
                    }
                    if fullNameArr.contains("page_id") {
                        let pageIndex = fullNameArr.index(of: "page_id")! + 1
                        let pageId = fullNameArr[pageIndex] as? String ?? "0"
                        (presentedVC as! AlbumProfileViewController).pageId = Int(pageId)
                       
                    }
                     self.navigationController?.pushViewController(presentedVC, animated: true)
                }
                else {
                    SitePageObject().redirectToPageBrowsePage(self, showOnlyMyContent: false)
                }
                
            }
            return
        }
            
        else if name == "core_main_sitestore"{
            if viewPage && objectId != nil {
                SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: objectId)
            }
            else {
                SiteStoreObject().redirectToStoresBrowse(viewController: self, showOnlyMyContent: false)
            }
            return
        }
        else if name == "core_main_sitestoreproduct"{
            if viewPage && objectId != nil {
                SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false, product_id:objectId)
            }
            else {
                SiteStoreObject().redirectToProductsViewPage(viewController: self, showOnlyMyContent: false)
            }
            return
        }
            // Api end pending
        else if name == "core_main_music"{
            print("music--")
            MusicObject().redirectToMusicBrowsePage(self, showOnlyMyContent: false )
            return
        }
        else if name == "core_main_classified"{
            listingNameToShow = sitereviewMenuDictionary["headerLabel"] as! String
            ClassifiedObject().redirectToClassifiedBrowsePage(self,showOnlyMyContent: false)
            return
        }
        else if name == "core_main_blog"{
            
            BlogObject().redirectToBlogBrowsePage(self, showOnlyMyContent: false)
            return
        }
        else if name == "core_main_forum"{
            presentedVC = ForumHomePageController()
        }
        else if name == "core_main_poll"{
            
            PollObject().redirectToPollBrowsePage(self, showOnlyMyContent: false)
            return
            
        }
        else if name == "core_main_wishlist"
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
        else if name == "core_main_diaries"
        {
            
            presentedVC = WishlistBrowseViewController()
            iscomingfrom = "\(name)"
            (presentedVC as! WishlistBrowseViewController).wishlistType = "diary"
            (presentedVC as! WishlistBrowseViewController).showOnlyMyContent = false
        }
        else if name == "core_main_sitestoreproduct_orders"
        {
            SiteStoreObject().redirectToMyStore(viewController: self)
            iscomingfrom = "sidemenu"
            return
        }
        else if name == "core_main_sitestoreoffer"{
            SiteStoreObject().redirectToCouponsBrowse(viewController: self, showOnlyMyContent: false, fromStore: false, storeId: 0)
            return
        }
        else if name == "core_main_sitestoreproduct_cart"
        {
            SiteStoreObject().redirectToManageCart(viewController: self)
            return
        }
        else
        {
            return
        }
        
        self.navigationController?.pushViewController(presentedVC, animated: true)
        
        return
        
        
    }
    func setViewHideShow(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        })
    }
    
    //MARK: Protocol StoryNotUploaded
    func methodStoryNotUploadedCell(data: StoriesBrowseData) {
        if data.story_id != 0
        {
            //  //print(data.gutterMenu)
            for customModel in data.gutterMenu
            {
                if let strName = customModel["name"] as? String, strName == "mute"
                {
                    let str = customModel["label"] as! String
                    if let first = str.components(separatedBy: " ").first
                    {
                        if first == "Mute"
                        {
                            storyNotUploaded.lblMuteUnmute.text = str
                            storyNotUploaded.imgMuteIcon.image = UIImage(named: "muteIcon")!.maskWithColor(color: navColor)
                            storyNotUploaded.isMute = true
                        }
                        else
                        {
                            storyNotUploaded.lblMuteUnmute.text = str
                            storyNotUploaded.imgMuteIcon.image = UIImage(named: "unmuteIcon")!.maskWithColor(color: navColor)
                            storyNotUploaded.isMute = false
                        }
                        storyNotUploaded.muteURl = customModel["url"] as! String
                    }
                }
            }
            storyNotUploaded.lblLongPressUser.text = "More Action for \(data.owner_title.capitalized)"
            storyNotUploaded.dataStory = data
            storyNotUploaded.viewNoStory.isHidden = true
            storyNotUploaded.viewMuteUnMuteStory.isHidden = false
            setViewHideShow(view: storyNotUploaded, hidden: false)
        }
        else
        {
            storyNotUploaded.updateData(data: data)
            storyNotUploaded.viewNoStory.isHidden = false
            storyNotUploaded.viewMuteUnMuteStory.isHidden = true
            setViewHideShow(view: storyNotUploaded, hidden: false)
        }
        
        
    }
    //MARK:- API Methods
    func API_getBrowseStories(){
        
        if logoutUser == false
        {
            if reachability.connection != .none
            {
                let parameters = [String:String]()
                post(parameters, url: "advancedactivity/stories/browse", method: "GET") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg {
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                                
                            }
                            var arrStoriesData = [StoriesBrowseData]()
                            if let dict = succeeded["body"] as? [String:AnyObject], let arrTemp = dict["response"] as? [AnyObject]
                            {
                                //  print(dict)
                                var userData = StoriesBrowseData()
                                for dicDataValue in arrTemp
                                {
                                    let data = StoriesBrowseData()
                                    data.story_id = dicDataValue["story_id"] as? Int ?? 0
                                    data.owner_id = dicDataValue["owner_id"] as? Int ?? 0
                                    data.photo_id = dicDataValue["photo_id"] as? Int ?? 0
                                    data.file_id = dicDataValue["file_id"] as? Int ?? 0
                                    data.duration = dicDataValue["duration"] as? Int ?? 0
                                    data.view_count = dicDataValue["view_count"] as? Int ?? 0
                                    data.comment_count = dicDataValue["comment_count"] as? Int ?? 0
                                    data.mute_story = dicDataValue["mute_story"] as? Int ?? 0
                                    data.status = dicDataValue["status"] as? Int ?? 0
                                    data.total_stories = dicDataValue["total_stories"] as? Int ?? 0
                                    data.owner_type_Stories = dicDataValue["owner_type"] as? String ?? ""
                                    data.privacy = dicDataValue["privacy"] as? String ?? ""
                                    data.description_Stories = dicDataValue["description"] as? String ?? ""
                                    data.owner_title = dicDataValue["owner_title"] as? String ?? ""
                                    data.image = dicDataValue["image"] as? String ?? ""
                                    data.content_url = dicDataValue["content_url"] as? String ?? ""
                                    data.owner_image_icon = dicDataValue["owner_image"] as? String ?? ""
                                    data.videoUrl = dicDataValue["videoUrl"] as? String ?? ""
                                    if let dicGutter = dicDataValue["gutterMenu"] as? [[String : Any]]
                                    {
                                        data.gutterMenu = dicGutter
                                    }
                                    if let id = dicDataValue["owner_id"] as? Int, id == currentUserId
                                    {
                                        userData = data
                                    }
                                    else if let id = dicDataValue["owner_id"] as? Int, id == 0
                                    {
                                        userData = data
                                    }
                                    else
                                    {
                                        arrStoriesData.append(data)
                                    }
                                    if let id = dicDataValue["isMute"] as? Int, id == 1
                                    {
                                        data.isMute = 1
                                    }
                                    else
                                    {
                                        data.isMute = 0
                                    }
                                }
                                if userData.owner_id != 0
                                {
                                    arrStoriesData.insert(userData , at: 0)
                                }
                                let storiesBrowseData = NSKeyedArchiver.archivedData(withRootObject: arrStoriesData)
                                UserDefaults.standard.set(storiesBrowseData, forKey: "storiesBrowseData")
                                self.storiesView?.updateStoriesData(isDataUpdate: false)
                            }
                            else
                            {
                                // Handle Server Error
                                if succeeded["message"] != nil && enabledModules.contains("suggestion")
                                {
                                    showToast(message: succeeded["message"] as! String, controller: self)
                                    
                                }
                            }
                        }
                        else{
                            // Handle Server Side Error
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
    }
    
    func API_getStoryCreate(){
        if Reachabable.isConnectedToNetwork()
        {
            let parameters = [String:String]()
            post(parameters, url: "advancedactivity/stories/create", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg {
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if let arrTemp = succeeded["body"] as? [AnyObject]
                        {
                            var arrGetStoryCreate = [CustomFeedPostMenuData]()
                            if let storiesBrowseData = UserDefaults.standard.object(forKey: "arrGetStoryCreate") as? Data {
                                if let arrStoriesDataTemp = NSKeyedUnarchiver.unarchiveObject(with: storiesBrowseData) as? [CustomFeedPostMenuData] {
                                    arrGetStoryCreate = arrStoriesDataTemp
                                    
                                }
                                
                            }
                            for dic in arrTemp
                            {
                                if let label = dic["label"] as? String, label == NSLocalizedString("View Privacy", comment: ""), let multiOptions = dic["multiOptions"] as? [String : String]
                                {
                                    for (key, value) in multiOptions
                                    {
                                        let data = CustomFeedPostMenuData()
                                        data.key = "\(key)"
                                        data.value = "\(value)"
                                        if !arrGetStoryCreate.contains(where: { $0.key == data.key }) {
                                            arrGetStoryCreate.append(data)
                                        }
                                        //                                        if !arrGetStoryCreate.contains(where: { $0.value == data.value }) {
                                        //                                            arrGetStoryCreate.append(data)
                                        //                                        }
                                    }
                                }
                            }
                            let storiesBrowseData = NSKeyedArchiver.archivedData(withRootObject: arrGetStoryCreate)
                            UserDefaults.standard.set(storiesBrowseData, forKey: "arrGetStoryCreate")
                        }
                        else
                        {
                            // Handle Server Error
                            if succeeded["message"] != nil && enabledModules.contains("suggestion")
                            {
                                showToast(message: succeeded["message"] as! String, controller: self)
                                
                            }
                        }
                    }
                    
                })
                
            }
        }
    }
    func API_getFeedPostMenus(){
        
        if postPermission.count != 0
        {
            if  let privacy = postPermission["userprivacy"] as? NSDictionary
            {
                var arrGetFeedPostMenus = [CustomFeedPostMenuData]()
                if let storiesBrowseData = UserDefaults.standard.object(forKey: "arrGetFeedPostMenus") as? Data {
                    if let arrStoriesDataTemp = NSKeyedUnarchiver.unarchiveObject(with: storiesBrowseData) as? [CustomFeedPostMenuData] {
                        arrGetFeedPostMenus = arrStoriesDataTemp
                        
                    }
                    
                }
                
                for (key, value) in privacy
                {
                    let data = CustomFeedPostMenuData()
                    data.key = "\(key)"
                    data.value = "\(value)"
                    if !arrGetFeedPostMenus.contains(where: { $0.key == data.key }) {
                        arrGetFeedPostMenus.append(data)
                    }
                    //                    if !arrGetFeedPostMenus.contains(where: { $0.value == data.value }) {
                    //                        arrGetFeedPostMenus.append(data)
                    //                    }
                }
                let storiesBrowseData = NSKeyedArchiver.archivedData(withRootObject: arrGetFeedPostMenus)
                UserDefaults.standard.set(storiesBrowseData, forKey: "arrGetFeedPostMenus")
                
            }
            
        }
    }
    func API_CheckVideoSize()
    {
        if Reachabable.isConnectedToNetwork()
        {
            let path = "get-server-settings"
            let parameters = [String:String]()
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                //  DispatchQueue.main.async(execute: {
                
                if msg
                {
                    if let response = succeeded["body"] as? NSDictionary
                    {
                        if  let videoSize = response["upload_max_size"] as? String
                        {
                            var name = videoSize
                            name.remove(at: name.index(before: name.endIndex))
                            UserDefaults.standard.set(name, forKey: "videoSize")
                            UserDefaults.standard.synchronize()
                            
                        }
                        if  let videoSize = response["rest_space"] as? Int
                        {
                            UserDefaults.standard.set(videoSize, forKey: "rest_space")
                            UserDefaults.standard.synchronize()
                        }
                    }
                }
                else
                {
                    UserDefaults.standard.removeObject(forKey: "rest_space")
                    UserDefaults.standard.removeObject(forKey: "videoSize")
                    UserDefaults.standard.synchronize()
                }
                // })
            }
        }
    }
    func saveFileInDocumentDirectoryForStory(_ images :[AnyObject], data : Data) ->([String]){
        var getImagePath = [String]()
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        var i = 0
        for image in images{
            i += 1
            var filename = ""
            if image is URL{
                if let str = (image as? URL)?.lastPathComponent
                {
                    filename = "\(str)" // "\((image as! URL).lastPathComponent)"
                }
            }else{
                let tempImageString = randomStringWithLength(8)
                filename = "\(tempImageString)\(i).png"
            }
            let filePathToWrite = "\(paths)/\(filename)"
            ////print(filePathToWrite)
            if fileManager.fileExists(atPath: filePathToWrite){
                removeFileFromDocumentDirectoryAtPath(filePathToWrite)
            }
            
            var imageData: Data?
            if image is URL{
                ////print("video case")
                if image is URL
                {
                    imageData = data//try? Data(contentsOf: imageT)
                }
                else if let imageT = image as? UIImage
                {
                    imageData =  imageT.pngData()
                }
                
            }else{
                // imageData = UIImagePNGRepresentation(image as! UIImage)
                if image is UIImage
                {
                    imageData =  (image as! UIImage).pngData()
                }
                ////print("length \(imageData.count)")
                
            }
            fileManager.createFile(atPath: filePathToWrite, contents: imageData, attributes: nil)
            getImagePath.append(paths.stringByAppendingPathComponent("\(filename)"))
            
        }
        
        return getImagePath;
    }
    func API_shareStory()
    {
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
            var parameters = [String : AnyObject]()
            var filePathKey = ""
            var sinPhoto = true
            if let asset = arrSelectedAssests[0] as? TLPHAsset, asset.isVideoSelected == true
            {
                var arryVideo = [AnyObject]()
                filePathKey = "filedata"
                sinPhoto = true
                parameters = ["type" : "3" as AnyObject , "post_attach" : "1" as AnyObject, "description" : asset.strDescription as AnyObject, "privacy" : strPrivacykey as AnyObject, "duration" :  asset.videoDuration as AnyObject]
                mediaType = "video"
                arryVideo.append(asset.strVideoPath as AnyObject)
                arryVideo.append(asset.imgFinalPassAPI as AnyObject)
                if asset.imgFinalTransparentVideoImage.size.width != 0
                {
                    arryVideo.append(asset.imgFinalTransparentVideoImage as AnyObject)
                }
                filePathArray.removeAll(keepingCapacity: false)
                filePathArray = saveFileInDocumentDirectoryForStory(arryVideo, data: asset.videoData)
            }
            else
            {
                var arrImages = [UIImage]()
                mediaType = "image"
                filePathKey = "photo"
                for (index,asset) in arrSelectedAssests.enumerated()
                {
                    arrImages.append(asset.imgFinalPassAPI)
                    if index == 0
                    {
                        parameters["description"] = asset.strDescription as AnyObject
                        parameters["photo"] = "photo" as AnyObject
                        parameters["privacy"] = strPrivacykey as AnyObject
                    }
                    else
                    {
                        parameters["description\(index)"] = asset.strDescription as AnyObject
                        parameters["photo_\(index)"] = "photo" as AnyObject
                        parameters["privacy"] = strPrivacykey as AnyObject
                    }
                    
                }
                if arrImages.count>1
                {
                    sinPhoto = false
                }
                filePathArray.removeAll(keepingCapacity: false)
                filePathArray = saveFileInDocumentDirectory(arrImages)
            }
            
            isStoryUploadingCompleted = false
            let path = "advancedactivity/stories/create"
            postActivityForm(parameters, url: path, filePath: filePathArray, filePathKey: filePathKey, SinglePhoto: sinPhoto){ (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    isStoryUploadingCompleted = true
                    if msg{
                        self.API_getBrowseStories()
                        for path in filePathArray{
                            removeFileFromDocumentDirectoryAtPath(path)
                        }
                        filePathArray.removeAll(keepingCapacity: false)
                        if isStoryPost == true
                        {
                            self.API_postStory()
                            showToast(message: NSLocalizedString("Your story and feed posted successfully.",comment: ""), controller: self)
                        }
                        else
                        {
                            isStoryShare = false
                            arrSelectedAssests.removeAll()
                            showToast(message: NSLocalizedString("Your story posted successfully.",comment: ""), controller: self)
                        }
                        
                        
                    }else{
                        // Handle Server Side Error
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
    
    func API_postStory()
    {
        isStoryUploadingCompleted = true
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            if let asset = arrSelectedAssests[0] as? TLPHAsset, asset.isVideoSelected == false
            {
                API_postStoryImage()
            }
            else
            {
                API_postStoryVideo()
            }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
        
    }
    func API_postStoryImage()
    {
        var arrImages = [UIImage]()
        var parameters = [String : AnyObject]()
        for (_,asset) in arrSelectedAssests.enumerated()
        {
            arrImages.append(asset.imgFinalPassAPI)
        }
        parameters["type"] = "photo" as AnyObject
        parameters["body"] = "" as AnyObject
        parameters["auth_view"] = strPostkey as AnyObject
        parameters["post_attach"] = "1" as AnyObject
        //    //print(parameters)
        mediaType = "image"
        filePathArray.removeAll(keepingCapacity: false)
        filePathArray = saveFileInDocumentDirectory(arrImages)
        let path = "advancedactivity/feeds/post"
        var sinPhoto = true
        if arrImages.count>1
        {
            sinPhoto = false
        }
        postActivityForm(parameters, url: path, filePath: filePathArray, filePathKey: "photo", SinglePhoto: sinPhoto){ (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if msg{
                    self.refresh()
                    for path in filePathArray{
                        removeFileFromDocumentDirectoryAtPath(path)
                    }
                    filePathArray.removeAll(keepingCapacity: false)
                    arrSelectedAssests.removeAll()
                    if isStoryShare == false
                    {
                        isStoryShare = false
                        showToast(message: NSLocalizedString("Your feed posted successfully.",comment: ""), controller: self)
                    }
                    
                    
                }else{
                    // Handle Server Side Error
                    if succeeded["message"] != nil{
                        showToast(message: succeeded["message"] as! String, controller: self)
                    }
                }
            })
            
        }
    }
    // Create video calling
    func API_postStoryVideo(){
        
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
        
        var parameters = [String:AnyObject]()
        parameters = ["title": "" as AnyObject,"auth_view": strPostkey as AnyObject,"type" : "3" as AnyObject , "post_attach" : "1" as AnyObject ]
        var path = ""
        if enabledModules.contains("sitevideo"){
            path = "advancedvideos/create"
        }
        else{
            path = "videos/create"
        }
        mediaType = "video"
        let asset = arrSelectedAssests[0]
        var arryVideo = [AnyObject]()
        arryVideo.append(asset.strVideoPath as AnyObject)
        arryVideo.append(asset.imgFinalPassAPI as AnyObject)
        if asset.imgFinalTransparentVideoImage.size.width != 0
        {
            arryVideo.append(asset.imgFinalTransparentVideoImage as AnyObject)
        }
        filePathArray.removeAll(keepingCapacity: false)
        filePathArray = saveFileInDocumentDirectoryForStory(arryVideo, data: asset.videoData)
        
        postActivityForm(parameters as Dictionary<String, AnyObject>, url: path, filePath: filePathArray, filePathKey: "filedata", SinglePhoto: true){ (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if msg{
                    self.refresh()
                    for path in filePathArray{
                        removeFileFromDocumentDirectoryAtPath(path)
                    }
                    filePathArray.removeAll(keepingCapacity: false)
                    arrSelectedAssests.removeAll()
                    if isStoryShare == false
                    {
                        isStoryShare = false
                        showToast(message: NSLocalizedString("Your video is in queue to be processed - you will be notified when it is ready to be viewed.", comment: ""), controller: self)
                    }
                    
                    
                }else{
                    // Handle Server Side Error
                    if succeeded["message"] != nil{
                        showToast(message: succeeded["message"] as! String, controller: self)
                    }
                }
            })
            
        }
    }
    
    //MARK: QUick Data Posting Delegate Methods
    func activityBuildQueryString(fromDictionary parameters: [String:Any]) -> String {
        
        // Create Query String From Parameters For GET Request
        var urlVars = [String]()
        for (k, var v) in parameters {
            
            let characters = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
            
            characters.removeCharacters(in: "&")
            if v is Int
            {
                continue
            }
            let vAsAnyObject = v as AnyObject
            let vAfteraddingPercentEncoding = vAsAnyObject.addingPercentEncoding(withAllowedCharacters: characters as CharacterSet)
            v = vAfteraddingPercentEncoding! as String
            
            urlVars += [k + "=" + (v as! String)]
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                //print(error.localizedDescription)
            }
        }
        return nil
    }
    // Create video calling
    func postVideoQuickPosting(parameters : Dictionary<String, AnyObject>, path : String)
    {
        datauploadParams(parameters: parameters, path: path, singlePhoto: true, attachment_content_type: "video")
    }
    
    func postImageQuickPosting(parameters: Dictionary<String, AnyObject>, path: String, singlePhoto: Bool)
    {
        datauploadParams(parameters: parameters, path: path, singlePhoto: singlePhoto, attachment_content_type: "photo")
        
    }
    var sellType = 0
    func postSellSomethingQuickPosting(parameters: Dictionary<String, AnyObject>, path: String, type: Int)
    {
        sellType = type
        datauploadParams(parameters: parameters, path: path, singlePhoto: true, attachment_content_type: "sellSomething")
        
    }
    
    func postTextWithImageQuickPosting(parameters : Dictionary<String, AnyObject>, path : String, passTempDic : [String : String])
    {
        imageGetAttachementLink = ""
        titleGetAttachementLink = ""
        descriptionGetAttachementLink = ""
        strURLTextBanner = ""
        background_color = ""
        strURLcolor = ""
        latitude = 0.0
        longitude = 0.0
        
        if let title = passTempDic["title"], title.length != 0
        {
            imageGetAttachementLink = passTempDic["image"]!
            titleGetAttachementLink = title
            descriptionGetAttachementLink = passTempDic["description"]!
            datauploadParams(parameters: parameters, path: path, singlePhoto: true, attachment_content_type: "composer")
            
        }
        else if let composer = parameters["composer"] as? String
        {
            if let dict = convertToDictionary(text: composer), let dic = dict["banner"] as? [String : AnyObject]
            {
                if let imageURL = dic["image"] as? String
                {
                    let strUrl = imageURL.replacingOccurrences(of: "\\", with: "")
                    let strUrl2 = strUrl.replacingOccurrences(of: "url(", with: "")
                    strURLTextBanner = strUrl2.replacingOccurrences(of: ")", with: "")
                    background_color = dic["background-color"] as! String
                    strURLcolor = dic["color"] as! String
                    
                }
            }
            else if let dict = convertToDictionary(text: composer), let dic = dict["checkin"] as? [String : AnyObject]
            {
                if let latitude = dic["latitude"] as? String
                {
                    self.latitude = Double(latitude)!                    
                }
                self.longitude = Double(dic["longitude"] as! String)!
            }
            datauploadParams(parameters: parameters, path: path, singlePhoto: true, attachment_content_type: "composer")
        }
        else
        {
            datauploadParams(parameters: parameters, path: path, singlePhoto: true, attachment_content_type: "composer")
        }
        
    }
    
    func datauploadParams(parameters : Dictionary<String, AnyObject>, path: String, singlePhoto: Bool, attachment_content_type : String )
    {
        if quickContentIncrementIndex < 0
        {
            quickContentIncrementIndex = 0
        }
        quickContentIncrementIndex += 1
        
        var dic = Dictionary<String, AnyObject>()
        if(logoutUser == false){
            dic["oauth_token"] = oauth_token as AnyObject?
            dic["oauth_secret"] = oauth_secret as AnyObject?
        }
        dic["oauth_consumer_secret"] = "\(oauth_consumer_secret)" as AnyObject?
        dic["oauth_consumer_key"] = "\(oauth_consumer_key)" as AnyObject?
        dic["language"] = "\( (Locale.current as NSLocale).object(forKey: NSLocale.Key.languageCode)!)" as AnyObject?
        if ios_version != nil && ios_version != "" {
            dic["_IOS_VERSION"] = ios_version as AnyObject?
            
        }
        dic["notifyItemAt"] = quickContentIncrementIndex as AnyObject
        dic.update(parameters)
        
        let dict = NSMutableDictionary()
        
        switch attachment_content_type {
        case "video":
            dic["duration"] = "\(videoDurationInSeconds)" as AnyObject
            let request = createActivityRequest(dic, url: path, path: filePathArray, filePathKey: "filedata",SinglePhoto: singlePhoto)
            print("-----------------------------")
            print(request)
            print(dic)
            print("-----------------------------")
            dict["requestObject"] = request as AnyObject?
            dict["previewImageVideo"] = filePathArray[1] as AnyObject
            dict["filePathArray"] = filePathArray as AnyObject
        case "photo":
            let request = createActivityRequest(dic, url: path, path: filePathArray, filePathKey: "filedata",SinglePhoto: singlePhoto)
            print("-----------------------------")
            print(request)
            print(dic)
            print("-----------------------------")
            dict["requestObject"] = request as AnyObject?
            dict["filePathArray"] = filePathArray as AnyObject
        case "sellSomething":
            if sellType == 1
            {
                let request = createActivityRequest(dic, url: path, path: filePathArray, filePathKey: "filedata",SinglePhoto: singlePhoto)
                dict["requestObject"] = request as AnyObject?
                dict["filePathArray"] = filePathArray as AnyObject
            }
            else
            {
                let finalurl = URL(string: baseUrl+path+activityBuildQueryString(fromDictionary:dic))!
                let request = NSMutableURLRequest(url: finalurl)
                request.httpMethod = "POST"
                if (request.httpMethod == "POST") {
                    let str = activityStringFromDictionary(dic)
                    request.httpBody = (str as NSString).data(using: String.Encoding.utf8.rawValue)
                }
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                dict["requestObject"] = request as AnyObject?
            }
        case "composer":
            let finalurl = URL(string: baseUrl+path+activityBuildQueryString(fromDictionary:dic))!
            let request = NSMutableURLRequest(url: finalurl)
            print("***************------------****************")
            print(dic)
            print(finalurl)
            print("***************------------****************")
            request.httpMethod = "POST"
            if (request.httpMethod == "POST") {
                let str = activityStringFromDictionary(dic)
                request.httpBody = (str as NSString).data(using: String.Encoding.utf8.rawValue)
            }
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            dict["requestObject"] = request as AnyObject?
            if titleGetAttachementLink.length != 0
            {
                dict["imageGetAttachementLink"] = imageGetAttachementLink as AnyObject
                dict["titleGetAttachementLink"] = titleGetAttachementLink as AnyObject
                dict["descriptionGetAttachementLink"] = descriptionGetAttachementLink as AnyObject
            }
            else if strURLTextBanner.length != 0
            {
                dict["strURLTextBanner"] = strURLTextBanner as AnyObject
                dict["background_color"] = background_color as AnyObject
                dict["strURLcolor"] = strURLcolor as AnyObject
            }
            else if latitude != 0.0
            {
                dict["latitude"] = latitude as AnyObject
                dict["longitude"] = longitude as AnyObject
            }
        default: break
            //print("none")
        }
        
        dict["isDummyResponse"] = 1 as AnyObject
        dict["action_id"] = 101 as AnyObject
        dict["attachment_content_type"] = attachment_content_type as AnyObject
        dict["params"] = parameters as AnyObject
        dict["path"] = path as AnyObject
        dict["singlePhoto"] = singlePhoto as AnyObject
        dict["downloaded"] = false as AnyObject?
        dict["index"] = quickContentIncrementIndex - 1 as AnyObject?
        dict["notifyItemAt"] = quickContentIncrementIndex as AnyObject
        // //print("notifyItemAt == \(dic["notifyItemAt"] as! Int)")
        filePathArray.removeAll()
        //feedArray.removeLast()
        feedArrayTemp.insert(dict, at: quickContentIncrementIndex - 1)
        feedArray.insert(dict, at: quickContentIncrementIndex - 1)
        self.feedObj.globalArrayFeed = feedArray
        
        let indexPath = IndexPath(item: quickContentIncrementIndex - 1, section: 0)
        self.feedObj.tableView.insertRows(at: [indexPath], with: .fade)
        // self.feedObj.tableView.reloadData()
        // self.feedObj.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    //MARK:- TikTok API
    func API_getAAFList()
    {
        if Reachabable.isConnectedToNetwork()
        {
            var parameters = [String:String]()
            parameters = ["maxid": String(maxidTikTok),"feed_filter": "1","post_elements": "1","post_menus":"1","object_info":"1","getAttachedImageDimention":"0","filter_type":"video","onlyMyDeviceVideo":"1"]
            if updateScrollFlag == false{
                if defaultFeedCountTikTok > 0 {
                    parameters["limit"] = "\(defaultFeedCountTikTok)"
                }
            }
            subjectIdTikTok = ""
            subjectTypeTikTok = ""
            //  //print(parameters)
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg {
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        ////print(succeeded)
                        // Set MaxId for Feeds Result
                        if maxidTikTok == 0
                        {
                            feedArrayTikTok.removeAll()
                        }
                        if let dicTemp = succeeded["body"] as? [String : AnyObject], let activity_feed = dicTemp["data"] as? NSArray
                        {
                            // //print(dicTemp)
                            
                            if let maxid = dicTemp["maxid"] as? Int{
                                maxidTikTok = maxid
                            }
                            if let feedCount = dicTemp["defaultFeedCount"] as? Int{
                                defaultFeedCountTikTok = feedCount
                            }
                            let activityFeeds:[ActivityFeed] = ActivityFeed.loadActivityFeedInfo(activity_feed)
                            self.updateFeedsArrayTikTok(feeds: activityFeeds)
                        }
                        else
                        {
                            // Handle Server Error
                            if succeeded["message"] != nil && enabledModules.contains("suggestion")
                            {
                                showToast(message: succeeded["message"] as! String, controller: self)
                                
                            }
                        }
                    }
                    else{
                        // Handle Server Side Error
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
}

public func isVisible(view: UIView) -> Bool {
    
    if view.window == nil {
        return false
    }
    
    var currentView: UIView = view
    while let superview = currentView.superview {
        
        if (superview.bounds).intersects(currentView.frame) == false {
            return false
        }
        
        if currentView.isHidden {
            return false
        }
        
        currentView = superview
    }
    
    return true
}

extension Array where Element: Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}


extension AdvanceActivityFeedViewController: PostFeedDelegate, ActivityFeedDelegate {
    func didPostFeed() {
        if feedArray.count == 0 {
            if friendWidgetRemoved {
                self.noContentView.removeFromSuperview()
                self.noContentLabel.removeFromSuperview()
            }
            else {
                self.noContentLabel.removeFromSuperview()
            }
        }
    }
    func didCancelPost() {
        print("cancel")
    }
    func feedDeleted() {
        if feedArray.count == 0 {
            if isAddFriendWidgetEnable == 1 {
                if friendWidgetRemoved {
                    self.feedObj.tableView.addSubview(self.noContentView)
                    self.noContentView.frame.size.height = 120
                    self.noContentView.backgroundImage.frame.size.height = 120
                    self.noContentView.crossButton.isHidden = true
                    self.noContentView.frame.origin.y = getBottomEdgeY(inputView: self.scrollableCategory) + 13
                    if self.scrollableCategory.frame.height > 0 {
                        self.noContentView.isHidden = false
                        self.noContentView.button.titleLabel?.adjustsFontSizeToFitWidth = true
                    }
                }
                else {
                    self.noContentLabel = UILabel()
                    self.noContentLabel.isHidden = false
                    self.noContentLabel.frame = CGRect(x: 0, y: getBottomEdgeY(inputView: self.scrollableCategory) + 25, width: self.view.frame.size.width, height: 40)
                    self.noContentLabel.numberOfLines = 2
                    self.noContentLabel.font = UIFont.systemFont(ofSize: FONTSIZENormal)
                    self.noContentLabel.center.x = self.view.center.x
                    self.noContentLabel.textAlignment = .center
                    self.feedObj.tableView.addSubview(self.noContentLabel)
                    self.noContentLabel.textColor = buttonColor
                    self.noContentLabel.text = "No feeds to display at this \nmoment"
                }
            }
            
        }
    }
}

extension AdvanceActivityFeedViewController: QuickUploadFailedDelegate {
    // refresh feeds when image uploading is failed
    func refreshDummyFeed() {
        refresh()
    }
}

