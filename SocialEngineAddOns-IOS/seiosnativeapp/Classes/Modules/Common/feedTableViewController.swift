//
//  feedTableViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 08/06/16.
//  Copyright © 2016 bigstep. All rights reserved.
//
//import GoogleMobileAds
import FBAudienceNetwork
import UIKit
import AVKit
import AVFoundation
import Kingfisher
import WebKit
var otherFeedCount:Int = 0
var scrollViewheight : CGFloat = 0.0
var currentOffset : CGFloat = 0.0
var maxOffset : CGFloat = 0.0
var globalFeedHeight : CGFloat! = 10.0
var scrollopoint:CGPoint!
var tableViewFrameType = ""
var advGroupDetailUpdate = true
var reportDic:NSDictionary = [:]
var arrGlobalFacebookAds = [FBNativeAd]()
let uploadService = UploadService()
var NotPlay = 0

protocol DelegateTikTokVidyoPlayer{
    func updateTikTokPlayer(videoURL : String, currentTime : Double, timeScale : CMTimeScale)
    func updateTableAfterVideoRemoval(videoId : Int)
}


class FeedTableViewController: UITableViewController, TTTAttributedLabelDelegate, UIGestureRecognizerDelegate, FBNativeAdDelegate, FBNativeAdsManagerDelegate, WKNavigationDelegate, QuickContentDelegate, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, DelegateTikTokVidyoPlayer{
    
    
    // Constants
    let AdsCellidentifier = "nativeAdCell"
    let suggestionCellidentifier = "slideshowCell"
    let feedCellidentifier = "cell"
    
    var refreshLikeUnLike = true
    
    //Variable
    var globalArrayFeed = [AnyObject]()
    var userFeeds:Bool = false
    var feedShowingFrom:String = ""
    var RedirectText : String!
    var listingTitle:String!
    // var imageView : UIImageView!
    var lastContentOffset: CGFloat = 0
    var listingId:Int!
    var listingTypeId :  Int!
    var subjectId:Int!                         // For use Activity Feed updates in Other Modules
    var subjectType:String!                    // For use Activity Feed updates in Other Modules
    var showSpinner = true                      // show spinner flag for pull to refresh
    var refresher:UIRefreshControl!             // Refresher for Pull to Refresh
    var maxid:Int!                              // MaxID for Pagination
    var minid:Int!                              // MinID for New Feeds
    var myTimer:Timer!                        // Timer for Update feed after particular time repeation
    // activityFeedTable to display Activity Feeds
    var dynamicHeight:CGFloat = 44              // Defalut Dynamic Height for each Row
    var updateScrollFlag = true                 // Flag for Pagination by ScrollView Delegate
    var deleteFeed = false                      // Flag for Delete Feed Updation
    // Feed Filter Option
    var activityFeeds:[ActivityFeed] = []       // To save Activity Feeds from Response (subclass of ActivityFeed)
    var menuOptionSelected:String!              // Set Option Selected for Feed Gutter Menu
    var tempcontentFeedArray = [Int:AnyObject]()       // Hold TemproraryFeedMenu for Hide Row (Undo, HideAll)
    var feed_filter = 1                         // Set Value for Feed Filter options in browse Feed Request to get feed_filter in response
    var feedFilterFlag = false                  // Flag to merge Feed Filter Params in browse Feed Request
    var fullDescriptionCell = [Int]()           // Contain Array of all cell to show full description
    var dynamicRowHeight = [Int:CGFloat]()      // Save table Dynamic RowHeight
    
    var contentUrl : String!
    var shareDescription : String!
    var coverImageUrl : String!
    
    
    var extraMenuLeft:UIButton!
    var extraMenuRight:UIButton!
    var headerHeight:CGFloat = 0
    var categoryMember : TTTAttributedLabel!
    var detailWebView : UITextView!
    var maxHeight : CGFloat!
    var shareTitle:String!
    var imageScrollView: UIScrollView!
    var joinlabel : UILabel!
    
    var user_id : Int!
    var descriptionGroupCompleteContent : String!
    var ownerName : UILabel!
    let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
    let offset_B_LabelHeader:CGFloat = 320.0 // At this offset the Black label reaches the Header
    let distance_W_LabelHeader:CGFloat = 100.0 // The distance between the bottom of the Header and the top of the White Label
    
    var contentDescription : String!
    var deleteContent : Bool!
    var popAfterDelay:Bool!
    var showFulldescription = false
    var contentExtraInfo: NSDictionary!
    var rsvp:UIView!
    var profile_rsvp_value = 0
    var transparentView :UIView!
    var gutterMenu: NSArray = []
    var filterGutterMenu: NSArray = []
    var join_rsvp:Int!
    var joinFlag = false
    var topView: UIView!
    var shareUrl : String!
    var shareParam : NSDictionary!
    var info : UILabel!
    var canInviteEventOrGroup = false
    var toastView : UIView!
    var UserId:Int!
    // var imageCache = [String:UIImage]()
    var titleshow :Bool  = false
    var action_id:Int!
    var noCommentMenu:Bool = false
    var noshareMenu:Bool = true
    var descRedirectionButton : UIButton!
    var mainView = UIView()
    var totalClassifiedImage : NSArray!
    var totalPic : TTTAttributedLabel!
    var totalPhoto: Int!
    var contentImage: String!
    var count:Int = 0
    var Id : Int!
    var cId : Int!
    var profileFieldLabel : TTTAttributedLabel!
    var profileView = UIView()
    var profileView2 = UIView()
    var addWishList : UIButton!
    var wishlistGutterMenu: NSArray = []
    var flag : Bool = false
    var deleteListingEntry:Bool!
    var urlDictionary = ["reviewUrl": "", "wishlistUrl":""]
    var reviewId:Int!
    var photos:[PhotoViewer] = []
    var noPost : Bool = true
    var label1 : TTTAttributedLabel!
    var label3 : TTTAttributedLabel!
    var priceLabel : UILabel!
    var priceValue : NSNumber!
    var priceTextField : UITextField!
    var currencySymbol : String!
    var nativeAdArray = [AnyObject]()
    // Native AdMob Variable
//    var adLoader: GADAdLoader!
    var loadrequestcount:Int = 0
    var adsCount:Int = 0
    var isnativeAd:Bool = true
    var displyedAdsCount:Int = 0
    
    // Native FacebookAd Variable
    var adsCellheight:CGFloat = 250.0
    var adChoicesView: FBAdChoicesView!
    var adTitleLabel:UILabel!
    var adIconImageView:UIImageView!
    var adImageView:FBMediaView!
    var adBodyLabel:UILabel!
    var cadUrl : UILabel!
    var cadTitle : UILabel!
    var ctaButton : UIButton!
    var adCallToActionButton:UIButton!
    var fbView:UIView!
    var nativeAd:FBNativeAd!
    var hidingNavBarManager: HidingNavigationBarManager?
    var admanager:FBNativeAdsManager!
    var feedArrayTikTokTemp = [AnyObject]()
    var reactionsIcon = [AnyObject]()
    weak var feedDelegate : ActivityFeedDelegate?
    
    var heightAtIndexPath = NSMutableDictionary()
    //  var myimageCache = [String:UIImage]()
    let subscriptionTagLinkAttributes = [
        NSAttributedString.Key.foregroundColor: textColorDark,
        // NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    
    let subscriptionNoticeLinkAttributes = [
        NSAttributedString.Key.foregroundColor: buttonColor,
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
    var enterdPinDays : Int = 0
    
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
    var customTitleView : UIView!
    var adSponserdTitleLabel:UILabel!
    var adSponserdLikeCount:UILabel!
    var adSponserdUserImage : UIButton!
    var adSponserdLikeTitle : TTTAttributedLabel!
    var addLikeTitle : UIButton!
    var imageButton : UIButton!
    var videoclickButton = UIButton()
    var muteButton : UIButton!
    var isLike:Bool!
    var communityAdsValues : NSMutableArray = []
    var adsReportView : AdsReportViewController!
    var parametersNeedToAdd = Dictionary<String, String>()
    var blackScreenForAdd : UIView!
    var adsImage : UIImageView!
    var cdAds : ContentSlideshowScrollView!
    
    
    var isHomeFeeds = false
    var placeholderImage : UIImage!
    var tagOtherUserCount : Int = 0
    var defaultimg = UIImage(named: "user_profile_image.png")
    var delegate:refresh?
    var delegatepin:pinrefresh?
    var delegateScroll: scrollDelegate?
    var suggetionCollectionView:SuggetionView!      // Add CollectionView for showing suggestions
    var timerFB = Timer()
    var viewSubview = UIView()
    var taskVideoPlayPause : DispatchWorkItem?
    weak var quickUploadFailedDelegate : QuickUploadFailedDelegate?
    
    // Create uploadsSession here, to set self as delegate
    lazy var uploadsSession: URLSession = {
        //    let configuration = URLSessionConfiguration.default
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
    }()
    
    var sharedVideoPlayer = VideoPlayerController()
    var shared1 = VideoPlayerController()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if tableViewFrameType != "CommentsViewController"
        {
            sharedVideoPlayer = VideoPlayerController()
            shared1 = VideoPlayerController()
        }
        
        let colorforimage = hexStringToUIColor(hex: "#eeeeee")
        placeholderImage = imagefromColor(colorforimage)
        
        if tableViewFrameType == "Pages" || tableViewFrameType == "MLTClassifiedAdvancedTypeViewController" || tableViewFrameType == "MLTClassifiedSimpleTypeViewController" || tableViewFrameType == "MLTBlogTypeViewController" || tableViewFrameType == "advGroup"
        {
            tableView.backgroundColor = aafBgColor
        }
        else
        {
            tableView.backgroundColor = tableViewBgColor//aafBgColor
        }
        // MARK: - TableView Start after Navigation in case of Pages
        if tableViewFrameType == "HashTagFeedViewController"
        {
            DispatchQueue.main.async {
                let offset = CGPoint.init(x: 0, y: -TOPPADING)
                self.tableView.setContentOffset(offset, animated: false)
            }
            tableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height - 22 - TOPPADING), style: UITableView.Style.grouped)
        }
        else
        {
            
            if tableViewFrameType == "AdvanceActivityFeedViewController"
            {
                uploadService.uploadsSession = uploadsSession
                
                if DeviceType.IS_IPHONE_X{
                    tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 40), style: UITableView.Style.grouped)
                }
                else{
                    
                    tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 22), style: UITableView.Style.grouped)
                }
                
                
            }
            else if tableViewFrameType == "CommentsViewController"
            {
                tableView = UITableView(frame: CGRect(x: 0, y: -35, width: view.bounds.width, height: view.bounds.height - 35), style: UITableView.Style.grouped)
                let offset = CGPoint.init(x: 0, y: -TOPPADING)
                self.tableView.setContentOffset(offset, animated: false)
                tableView.backgroundColor = textColorLight
            }
            else if tableViewFrameType == "FeedViewPageViewController" {
                tableView = UITableView(frame: CGRect(x: 0, y: 25, width: view.bounds.width, height: view.bounds.height - 25), style: UITableView.Style.grouped)
            }
            else
            {
                tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 22), style: UITableView.Style.grouped)
            }
            
            
        }
        //        if #available(iOS 10.0, *) {
        //            tableView.prefetchDataSource = self
        //        } else {
        //            // Fallback on earlier versions
        //        } //akash
        tableView.register(AAFActivityFeedTableViewCell.self, forCellReuseIdentifier: feedCellidentifier)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = UIColor(red: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1.0)//TVSeparatorColorClear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
            self.tableView.estimatedRowHeight = 0
            self.tableView.estimatedSectionHeaderHeight = 0
            self.tableView.estimatedSectionFooterHeight = 0
        }
        
        delay(2) {
            self.initialiseAdsReportData()
        }
        //        timerFB = Timer.scheduledTimer(timeInterval: 5,target: self,selector: #selector(FeedTableViewController.checkforAds),
        //        userInfo: nil,
        //                                                           repeats: false)
        //        if adsType_advancedevent == 2 || adsType_advancedevent == 4
        //        {
        //            checkforAds()
        //        }
        //        else
        //        {
        if firstCompletionTime == true
        {
            checkforAds()
            firstCompletionTime = false
        }
        else
        {
            timerFB = Timer.scheduledTimer(timeInterval: 5,
                                           target: self,
                                           selector: #selector(FeedTableViewController.checkforAds),
                                           userInfo: nil,
                                           repeats: false)
        }
        // }
        
        adsCount = globalArrayFeed.count/(kFrequencyAdsInCells_feeds-1)
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //  if tableViewFrameType != "CommentsViewController"
        //  {
        delay(0.0) {
            self.shared1.pauseVideosFor(tableView: self.tableView)
            self.sharedVideoPlayer.pauseVideosFor(tableView: self.tableView)
            self.taskVideoPlayPause?.cancel()
            //     }
        }
        
        timerFB.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if tableViewFrameType != "CommentsViewController"
        {
            delay(0.0) {
                if NotPlay != 1 {
                    self.pausePlayeVideos()
                }
            }
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appEnteredFromBackground),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoCompletion), name: Notification.Name("NotificationVideoCompletion"), object: nil)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if tableViewFrameType != "CommentsViewController"
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
        }
    }
    
    @objc func checkforAds()
    {
        self.nativeAdArray.removeAll(keepingCapacity: false)
        switch adsType_feeds {
        case 0:
            if kFrequencyAdsInCells_feeds > 4 && adUnitID != ""
            {
                //showNativeAd()
                
            }
            break
        case 1:
            if kFrequencyAdsInCells_feeds > 4 && placementID != ""
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
                        self.reloadDataTableView()
                    }
                }
                
            }
            break
        default:
            checkCommunityAds()
        }
    }
    
    func reloadDataTableView()
    {
        self.tableView.reloadData()
        if tableViewFrameType != "CommentsViewController"
        {
            if NotPlay != 1 {
                self.pausePlayeVideos()
            }
            delay(0.5) {
                if NotPlay != 1 {
                    self.pausePlayeVideos()
                }
            }
        }
    }
    //MARK: -  Functions that we are using for community ads and sponsered stories
    func checkCommunityAds()
    {
        
        if Reachabable.isConnectedToNetwork()
        {
            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
            
            dic["type"] =  "\(adsType_feeds)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_feeds)"
            post(dic, url: "communityads/index/index", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if let advertismentsArray = body["advertisments"] as? NSArray
                                {
                                    self.communityAdsValues = advertismentsArray as! NSMutableArray
                                    self.initialiseAdsReportData()
                                    switch adsType_feeds {
                                    case 2:
                                        
                                        self.uiOfCommunityAds(count: advertismentsArray.count){
                                            (status : Bool) in
                                            if status == true{
                                                self.reloadDataTableView()
                                            }
                                        }
                                        
                                        break
                                    case 4:
                                        self.uiOfSponseredAds(count: advertismentsArray.count){
                                            (status : Bool) in
                                            if status == true{
                                                self.reloadDataTableView()
                                            }
                                        }
                                        
                                        break
                                    default:
                                        break
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
            showToast(message: network_status_msg, controller: self, onView: false, time: 5.0)
        }
        
    }
    
    func animateLikeReaction() {
        arrowView.isHidden = true
        let frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        let imageView = UIImageView(frame: frame)
        imageView.image = likeIconImage
        imageView.center = (self.view.parentViewController()?.view.center)!
        imageView.isHidden = false
        imageView.frame.origin.y = UIScreen.main.bounds.height/2 - 35
        imageView.frame.origin.x = UIScreen.main.bounds.width/2 - 35
        UIApplication.shared.keyWindow?.addSubview(imageView)
        UIApplication.shared.keyWindow?.bringSubviewToFront(imageView)
        imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 10.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            imageView.transform = .identity
        }, completion: { (_) in
            imageView.isHidden = true
            imageView.removeFromSuperview()
        }
        )
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
                tap.cancelsTouchesInView = false
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
                adCallToActionButton.addTarget(self, action: #selector(FeedTableViewController.actionAfterClick(_:)), for: .touchUpInside)
                self.fbView.addSubview(adCallToActionButton)
                if  (UIDevice.current.userInterfaceIdiom == .phone)
                {
                    imageButton = createButton(CGRect(x: 5,y: self.adsImage.bounds.height + 15 + self.adsImage.frame.origin.y,width: self.fbView.bounds.width-10,height: 165),title: "", border: false, bgColor: false, textColor: textColorLight)
                    adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.imageButton.bounds.width,height: 165), border: false)
                }
                else
                {
                    imageButton = createButton(CGRect(x: 5,y: self.adsImage.bounds.height + 10 + self.adsImage.frame.origin.y,width: self.fbView.bounds.width-10,height: 165),title: "", border: false, bgColor: false, textColor: textColorLight)
                    adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.fbView.bounds.width-10,height: 165), border: false)
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
                    
                    cdAds = ContentSlideshowScrollView(frame: CGRect(x: 12,y: self.adsImage.bounds.height + 15 + self.adsImage.frame.origin.y,width: self.fbView.bounds.width-24,height: 260))
                    cdAds.backgroundColor = UIColor.white
                    cdAds.delegate = self
                    if dic["carousel"] != nil {
                        cdAds.browseAdsSellContent(contentItems: dic["carousel"] as! [AnyObject] , comingFrom: "")
                    }
                    self.fbView.addSubview(self.cdAds)
                }
                else if dic["cmd_ad_format"] as! String == "video"{
                    
                    
                    videoclickButton = createButton(CGRect(x: 5,y: self.adsImage.bounds.height + 10 + self.adsImage.frame.origin.y,width: self.fbView.bounds.width-55,height: self.fbView.bounds.height - (self.adsImage.bounds.height + 10 + self.adsImage.frame.origin.y)),title: "", border: false, bgColor: false, textColor: textColorLight)
                    
                    
                    videoclickButton.addTarget(self, action: #selector(FeedTableViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
                    self.fbView.addSubview(videoclickButton)
                    
                    
                }
                else{
                    imageButton.addTarget(self, action: #selector(FeedTableViewController.tappedOnAds(_:)), for: .touchUpInside)
                    
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
                    tap1.cancelsTouchesInView = false
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
                        
                        ctaButton.addTarget(self, action: #selector(FeedTableViewController.tappedOnAds(_:)), for: .touchUpInside)
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
                    adBodyLabel.frame.size.width = ctaButton.frame.origin.x - 10
                    
                    
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
    
    func uiOfSponseredAds(count : Int,completion: @escaping (_ status: Bool) -> Void){
        var status  = false
        
        for i in 0  ..< communityAdsValues.count{
            var userCount = 0
            var titleOfAds = ""
            var resourceTitle = ""
            var userLikeImage = ""
            let usersLike: NSMutableArray = []
            if  let dic = communityAdsValues[i]  as? NSDictionary {
                if let likesdic =  dic["likes"] as? NSArray{
                    for tempdic in likesdic{
                        if let particularLikeDictionary = tempdic as? NSDictionary{
                            let userTitle = particularLikeDictionary["user_title"] ?? ""
                            usersLike.add(userTitle)
                            userLikeImage = particularLikeDictionary["image"] as? String ?? ""
                        }
                        
                    }
                    userCount =  usersLike.count
                    switch userCount {
                    case 1:
                        titleOfAds = String(format: NSLocalizedString("%@ likes", comment: ""), usersLike[0] as? String ?? "")
                        break
                    case 2:
                        titleOfAds = String(format: NSLocalizedString("%@,%@ like", comment: ""), String(describing: usersLike[0]),String(describing: usersLike[1]))
                        break
                    case 3:
                        titleOfAds = String(format: NSLocalizedString("%@,%@ and %@ like", comment: ""), String(describing: usersLike[0]),String(describing: usersLike[1]),String(describing: usersLike[2]))
                        break
                    default:
                        break
                    }
                    resourceTitle = String(describing: dic["resource_title"] ?? "")
                    titleOfAds = titleOfAds + " \(resourceTitle)"
                    
                }
                
                // UI
                if(UIDevice.current.userInterfaceIdiom == .pad)
                {
                    self.fbView = UIView(frame: CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: 430))
                }
                else
                {
                    self.fbView = UIView(frame: CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: 270))
                }
                self.fbView.backgroundColor = UIColor.clear
                self.fbView.tag = 1001001
                
                
                
                adSponserdUserImage = createButton(CGRect(x:  10,y: 5,width: 40,height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
                adSponserdUserImage.layer.cornerRadius = 20.0
                self.fbView.addSubview(adSponserdUserImage)
                let urlOfImage = URL(string:userLikeImage)
                
                adSponserdUserImage.kf.setImage(with: urlOfImage, for: .normal, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                    
                    
                })
                
                
                adSponserdLikeTitle = TTTAttributedLabel(frame:CGRect(x:  adSponserdUserImage.frame.origin.x + adSponserdUserImage.frame.size.width + 5 ,y: 5,width: self.fbView.bounds.width-(30 + adSponserdUserImage.frame.origin.x + adSponserdUserImage.frame.size.width + 5 ),height: 40))
                adSponserdLikeTitle.numberOfLines = 0
                adSponserdLikeTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                adSponserdLikeTitle.delegate = self
                adSponserdLikeTitle.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
                adSponserdLikeTitle.setText(titleOfAds, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                    let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZENormal, nil)
                    
                    let range4 = (titleOfAds as NSString).range(of:NSLocalizedString("\(resourceTitle)",  comment: ""))
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range4)
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range4)
                    
                    
                    if let tags = dic["likes"] as? NSArray{
                        if tags.count > 0{
                            for i in 0 ..< tags.count {
                                if let tag = (tags[i] as! NSDictionary)["user_title"] as? String{
                                    let length = mutableAttributedString?.length
                                    var range = NSMakeRange(0, length!)
                                    while(range.location != NSNotFound)
                                    {
                                        range = (titleOfAds as NSString).range(of:tag, options: NSString.CompareOptions(), range: range)
                                        if(range.location != NSNotFound) {
                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:buttonColor , range: range)
                                            range = NSMakeRange(range.location + range.length, length! - (range.location + range.length));
                                            
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                    // TODO: Clean this up..
                    return mutableAttributedString!
                })
                adSponserdLikeTitle.sizeToFit()
                adSponserdLikeTitle.frame.size.height = 40
                adSponserdLikeTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                self.fbView.addSubview(adSponserdLikeTitle)
                
                
                if let tags = dic["likes"] as? NSArray{
                    
                    if tags.count > 0{
                        
                        for i in 0 ..< tags.count {
                            
                            if let tag = (tags[i] as! NSDictionary)["user_title"] as? String{
                                
                                let tag_id = (tags[i] as! NSDictionary)["user_id"] as? Int
                                
                                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\(titleOfAds)")
                                let length = attrString.length
                                var range = NSMakeRange(0, attrString.length)
                                while(range.location != NSNotFound)
                                {
                                    range = (titleOfAds as NSString).range(of: tag, options: NSString.CompareOptions(), range: range)
                                    if(range.location != NSNotFound) {
                                        adSponserdLikeTitle.addLink(toTransitInformation: ["id" : "\(tag_id!)", "type" : "user"], with:range)
                                        range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                                        
                                    }
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                }
                let range4 = (titleOfAds as NSString).range(of:NSLocalizedString("\(resourceTitle)",  comment: ""))
                adSponserdLikeTitle.addLink(toTransitInformation: ["adsId" : "\(i)", "type" : "stories"], with:range4)
                
                
                adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-(25), y: 20,width: 15,height: 15))
                adCallToActionButton.setImage(UIImage(named: "cross_icon")!.maskWithColor(color: textColorDark), for: UIControl.State())
                adCallToActionButton.backgroundColor = UIColor.clear
                adCallToActionButton.layer.cornerRadius = 2;
                adCallToActionButton.layer.shouldRasterize = true
                adCallToActionButton.layer.isOpaque = true// this value vary as per your desire
                adCallToActionButton.layer.rasterizationScale = UIScreen.main.scale
                adCallToActionButton.tag = i
                adCallToActionButton.addTarget(self, action: #selector(FeedTableViewController.actionAfterClick(_:)), for: .touchUpInside)
                self.fbView.addSubview(adCallToActionButton)
                
                let originY = adSponserdLikeTitle.frame.origin.y + adSponserdLikeTitle.frame.size.height +  10
                
                if  (UIDevice.current.userInterfaceIdiom == .phone)
                {
                    customAlbumView = createView(CGRect(x: 10,y: originY, width: self.fbView.bounds.width-(20) ,height: 160) , borderColor: UIColor.clear , shadow: false)
                }
                else
                {
                    customAlbumView =  createView(CGRect(x: 10,y: originY, width: self.fbView.bounds.width-(20) ,height: 300) , borderColor: UIColor.clear , shadow: false)
                }
                
                customAlbumView.tag = i
                customAlbumView.backgroundColor = UIColor.clear
                self.fbView.addSubview(customAlbumView)
                
                
                if  (UIDevice.current.userInterfaceIdiom == .phone)
                {
                    adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.customAlbumView.bounds.width,height: 160), border: false)
                }
                else
                {
                    adImageView1 = createImageView(CGRect(x: 5,y: 0,width: self.customAlbumView.bounds.width,height: 300), border: false)
                }
                adImageView1.contentMode = UIView.ContentMode.scaleAspectFill
                adImageView1.clipsToBounds = true
                customAlbumView.addSubview(adImageView1)
                if dic["image"] != nil{
                    let icon = dic["image"]
                    let url = URL(string:icon as! String)
                    
                    //                    adImageView1.kf.indicatorType = .activity
                    //                    (adImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    adImageView1.kf.setImage(with: url! as URL, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                    
                }
                
                let aTap = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewController.tappedSponseredAds(sender:)))
                aTap.cancelsTouchesInView = false
                customAlbumView.addGestureRecognizer(aTap)
                
                let  addLikeTitleHeight: CGFloat  = 60
                
                customTitleView = createView(CGRect(x: 10,y: customAlbumView.frame.size.height + customAlbumView.frame.origin.y, width: self.fbView.bounds.width - (addLikeTitleHeight + 20),height: 55) , borderColor: UIColor.clear , shadow: false)
                customTitleView.tag = i
                customTitleView.backgroundColor = UIColor.clear
                self.fbView.addSubview(customTitleView)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewController.tappedSponseredAds(sender:)))
                tapGesture.cancelsTouchesInView = false
                customTitleView.addGestureRecognizer(tapGesture)
                
                adSponserdTitleLabel = UILabel(frame: CGRect(x:  0,y: 0,width: self.customTitleView.bounds.width ,height: customTitleView.bounds.height))
                adSponserdTitleLabel.numberOfLines = 1
                adSponserdTitleLabel.textColor = textColorDark
                adSponserdTitleLabel.tag = i
                //adSponserdTitleLabel.backgroundColor = UIColor.green
                
                adSponserdTitleLabel.font = UIFont(name: fontBold, size: 18.0)
                adSponserdTitleLabel.text = String(describing: dic["resource_title"] ?? "")
                customTitleView.addSubview(adSponserdTitleLabel)
                
                
                let islike = (dic["isLike"] as? Int ?? 0)
                
                if islike == 0
                {
                    let border = CALayer()
                    let width = CGFloat(0.5)
                    let borderColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1.0)
                    border.borderColor = borderColor.cgColor
                    border.frame = CGRect(x: self.fbView.bounds.width - addLikeTitleHeight, y: customAlbumView.frame.size.height + customAlbumView.frame.origin.y + 10, width: 1 , height: 35)
                    border.borderWidth = width
                    self.fbView.layer.addSublayer(border)
                    
                    
                    addLikeTitle = UIButton(frame:CGRect(x:  self.fbView.bounds.width - (addLikeTitleHeight + 1),y: customAlbumView.frame.size.height + customAlbumView.frame.origin.y ,width:addLikeTitleHeight,height: 55))
                    addLikeTitle.titleLabel?.font = UIFont(name: "FontAwesome", size: 28)
                    addLikeTitle.setTitle("\(likeIcon)", for: UIControl.State.normal)
                    addLikeTitle.contentHorizontalAlignment = .center
                    addLikeTitle.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                    addLikeTitle.tag = i
                    addLikeTitle.setTitleColor(textColorMedium, for: UIControl.State.normal)
                    // addLikeTitle.backgroundColor = UIColor.red
                    addLikeTitle.addTarget(self, action: #selector(FeedTableViewController.actionLikeUnlike(_:)), for: .touchUpInside)
                    self.fbView.addSubview(addLikeTitle)
                    
                }
                
                nativeAdArray.append(self.fbView)
                
                if i == count - 1{
                    status = true
                    completion(status)
                    
                }
            }
        }
    }
    
    
    func initialiseAdsReportData()
    {
        if communityAdsValues.count > 0
        {
            var dictionary = Dictionary<String, String>()
            dictionary["type"] =  "\(adsType_feeds)"
            dictionary["placementCount"] = "\(kFrequencyAdsInCells_feeds)"
            let dic = communityAdsValues[0] as? NSDictionary
            if dic!["userad_id"] != nil{
                dictionary["adsId"] =  String(dic!["userad_id"] as! Int)
            }
            else if dic?["ad_id"] != nil{
                dictionary["adsId"] =  String(describing: dic?["ad_id"]!)
            }
            parametersNeedToAdd = dictionary
            if reportDic.count == 0{
                //     activityIndicatorView.startAnimating()
                if Reachabable.isConnectedToNetwork() {
                    // Send Server Request for Comments
                    post(dictionary, url: "communityads/index/remove-ad", method: "GET") { (succeeded, msg) -> () in
                        DispatchQueue.main.async(execute: {
                            //      activityIndicatorView.stopAnimating()
                            if msg
                            {
                                if succeeded["body"] != nil{
                                    if let body = succeeded["body"] as? NSDictionary{
                                        if let form = body["form"] as? NSArray
                                        {
                                            if let  key = form as? [NSDictionary]
                                            {
                                                for dic in key
                                                {
                                                    for(k,v) in dic{
                                                        if let kk = k as? String, kk == "multiOptions"{
                                                            reportDic = v as! NSDictionary
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        )
                    }
                    
                }
            }
        }
    }
    @objc func actionAfterClick(_ sender: UIButton){
        
        
        var dictionary = Dictionary<String, String>()
        dictionary["type"] =  "\(adsType_feeds)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_feeds)"
        let dic = communityAdsValues[sender.tag] as? NSDictionary
        if dic!["userad_id"] != nil{
            dictionary["adsId"] =  String(dic!["userad_id"] as! Int) //String(describing: dic?["campaign_id"]!)
        }
        else if dic?["ad_id"] != nil{
            dictionary["adsId"] =  String(describing: dic?["ad_id"]!)
        }
        
        parametersNeedToAdd = dictionary
        if reportDic.count == 0{
            //     activityIndicatorView.startAnimating()
            self.parent?.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            if Reachabable.isConnectedToNetwork() {
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
                                        if  let  key = form as? [NSDictionary]
                                        {
                                            for dic in key
                                            {
                                                for(k,v) in dic{
                                                    if let kk = k as? String, kk == "multiOptions"{
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
                        }
                    })
                }
                
            }
            else{
                // No Internet Connection Message
                showToast(message: network_status_msg, controller: self, onView: false, time: 5.0)
            }
        }
        else {
            
            self.blackScreenForAdd = UIView(frame: (self.parent?.view.frame)!)
            self.blackScreenForAdd.backgroundColor = UIColor.black
            self.blackScreenForAdd.alpha = 0.0
            self.parent?.view.addSubview(self.blackScreenForAdd)
            self.adsReportView = AdsReportViewController(frame:CGRect(x:  10,y: (self.parent?.view.bounds.height)!/2  ,width: self.view.bounds.width - (20),height: 100))
            self.adsReportView.showMenu(dic: reportDic as NSDictionary,parameters : dictionary,view : self)
            self.adsReportView.alpha = 1
            self.parent?.view.addSubview(self.adsReportView)
            UIView.animate(withDuration: 0.2) { () -> Void in
                self.adsReportView.frame.origin.y = (self.parent?.view.bounds.height)!/2 - self.adsReportView.frame.height/2 - 50
                self.blackScreenForAdd.alpha = 0.5
                
            }
            
        }
        
    }
    
    @objc func tappedOnAds(_ sender: UIButton){
        
        let dic = communityAdsValues[sender.tag] as? NSDictionary
        if dic?["cads_url"] != nil
        {
            var communityAdId = ""
            let param = Dictionary<String,String>()
            if let adId = dic?["userad_id"] as? Int
            {
                communityAdId = String(adId)
            }
            let adUrl = "communityads/update-click-count/"+communityAdId
            post(param, url: adUrl, method: "post") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg
                    {
                        //print("updated")
                    }
                })
            }
            fromExternalWebView = true
            let presentedVC = ExternalWebViewController()
            presentedVC.url = dic?["cads_url"] as? String ?? ""
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated: true, completion: nil)
        }
        
    }
    
    @objc func tappedSponseredAds(sender: UITapGestureRecognizer){
        
        let view = sender.view
        let tag = view?.tag ?? 0
        let dic = communityAdsValues[tag] as? NSDictionary
        
        let resourceId = dic?["resource_id"]
        if dic?["resource_type"] != nil{
            if let resourceType = dic?["resource_type"] as? String
            {
                if resourceType == "video"{
                    VideoObject().redirectToVideoProfilePage(self,videoId: resourceId as? Int ?? 0,videoType: dic?["video_type"] as? Int ?? 0,videoUrl: dic?["video_url"] as? String ?? "")
                    
                }
                else if resourceType == "blog"{
                    BlogObject().redirectToBlogDetailPage(self,blogId: resourceId as? Int ?? 0,title: "")
                }
                else if resourceType == "classified"{
                    ClassifiedObject().redirectToProfilePage(self, id: resourceId as? Int ?? 0)
                }
                else if resourceType == "album"{
                    let presentedVC = AlbumProfileViewController()
                    presentedVC.albumId = "\(resourceId!)"
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                }
                else if resourceType == "music_playlist"{
                    MusicObject().redirectToPlaylistPage(self,id: resourceId as? Int ?? 0)
                }
                else if resourceType == "poll"{
                    let presentedVC = PollProfileViewController()
                    presentedVC.pollId =   resourceId as? Int ?? 0
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                    
                }
                else if resourceType == "sitepage_page"{
                    SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: "\(resourceId)")
                }
                else if resourceType == "group"{
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "group"
                    presentedVC.subjectId = "\(resourceId)"
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                }
                else if resourceType == "event"{
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "event"
                    presentedVC.subjectId = "\(resourceId)"
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                }
                else if resourceType == "siteevent_event"{
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "advancedevents"
                    presentedVC.subjectId =  "\(resourceId)"
                    self.navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if resourceType == "sitestoreproduct_product"
                {
                    SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id: "\(resourceId)")
                }
                else if resourceType == "sitestore_store"{
                    SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: "\(resourceId)")
                }
                
            }
        }
    }
    
    @objc func actionLikeUnlike(_ sender: UIButton){
        //   activityIndicatorView.startAnimating()
        
        
        
        let tempDic : NSMutableDictionary = [:]
        if let dic = communityAdsValues[sender.tag] as? NSDictionary
        {
            let islike = dic["isLike"] as? Int ?? 0
            var path = ""
            switch islike {
            case 0:
                path = "like"
                break
            default:
                path = "unlike"
                break
            }
            
            for(k,v) in dic{
                let islike1 = (dic["isLike"] as? Int ?? 0)
                
                if (k as! String == "isLike"){
                    if islike1 == 0{
                        
                        tempDic["isLike"] = 1
                        sender.setTitleColor(navColor, for: UIControl.State.normal)
                        self.reloadDataTableView()
                        
                    }
                    else{
                        tempDic["isLike"] = 0
                        sender.setTitleColor(textColorMedium, for: UIControl.State.normal)
                        self.reloadDataTableView()
                        
                    }
                }
                else{
                    tempDic[k] = v
                }
            }
            self.communityAdsValues[sender.tag] = tempDic
            
            let resourceId = dic["resource_id"] as? Int ?? 0
            let resourceType = dic["resource_type"] as? String ?? ""
            post(["subject_id":String(describing: resourceId), "subject_type": resourceType], url: path, method: "POST") {
                (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            //  activityIndicatorView.stopAnimating()
                        }
                    }
                })
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
        
        parametersNeedToAdd["adCancelReason"] =  configArray["\(sender.tag)"] ?? ""
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
    @objc func removeAd(){
        //    activityIndicatorView.startAnimating()
        self.doneAfterReportSelect()
        showToast(message: NSLocalizedString("Thanks for your feedback. Your report has been submitted.", comment: ""), controller: self)
        
        self.parent?.view.addSubview(activityIndicatorView)
        activityIndicatorView.center.x = UIScreen.main.bounds.width/2 - 5 //self.view.center
        activityIndicatorView.center.y = UIScreen.main.bounds.height/2 - 5
        activityIndicatorView.startAnimating()
        if Reachabable.isConnectedToNetwork() {
            
            post(parametersNeedToAdd, url: "communityads/index/remove-ad", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    if msg
                    {
                        if succeeded["body"] != nil{
                            self.nativeAdArray.removeAll(keepingCapacity: false)
                            // self.parametersNeedToAdd = [:]
                            self.checkCommunityAds()
                            activityIndicatorView.stopAnimating()
                        }
                    }
                    else{
                        activityIndicatorView.stopAnimating()
                    }
                })
            }
            
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self.parent!)
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
            self.reloadDataTableView()
        }
    }
    

    func nativeAdsFailedToLoadWithError(_ error: Error)
    {
        ////print(error)
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
//            //            request.testDevices = [kGADSimulatorID,"bc29f25fa57e135618e267a757a5fa35"]
//            self.adLoader.load(request)
//        })
//    }
//
//    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
//        //print("\(adLoader) failed with error: \(error.localizedDescription)")
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
//            self.reloadDataTableView()
//        }
//    }
//
//
//    func adLoader(_ adLoader: GADAdLoader!, didReceive nativeContentAd: GADNativeContentAd!) {
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
//            self.reloadDataTableView()
//        }
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Tableview Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView.tag == 11{
            return guttermenuoption.count
        }
        else
        {
            if globalArrayFeed.count == 0 && isshimmer == true
            {
                return 4
            }
            else
            {
                if nativeAdArray.count > 0
                {
                    
                    // For showing facebook ads count
                    if globalArrayFeed.count > kFrequencyAdsInCells_feeds-1
                    {
                        //  adsCount = globalArrayFeed.count/(kFrequencyAdsInCells_feeds-1)
                        let b = globalArrayFeed.count
                        let Totalrowcount = adsCount+b
                        // Remove ads from last row
                        //                        if Totalrowcount % kFrequencyAdsInCells_feeds == 0
                        //                        {
                        //                            return Totalrowcount-1
                        //                        }
                        //                        else
                        //                        {
                        //                            return Totalrowcount
                        //                        }
                        //print("Totalrowcount == \(Totalrowcount)")
                        return Totalrowcount
                    }
                    else
                    {
                        
                        return globalArrayFeed.count
                    }
                    
                }
                return globalArrayFeed.count
                
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.tag == 11{
            return 0.00001
        }
        else
        {
            
            
            if globalArrayFeed.count == 0 && isshimmer == true
            {
                return globalFeedHeight + 5
                
            }
            else
            {
                return globalFeedHeight
            }
            
            
            
        }
    }
    //  set Dynamic Height For Every Cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView.tag == 11 {
            return 50
        }
        else
        {
            if globalArrayFeed.count == 0 && isshimmer == true
            {
                return 170
            }
            var rowHeight:CGFloat = 60
            var row = (indexPath as NSIndexPath).row as Int
            if nativeAdArray.count > 0
            {
                if (kFrequencyAdsInCells_feeds > 4 && ((row % kFrequencyAdsInCells_feeds) == (kFrequencyAdsInCells_feeds)-1))
                {
                    if adsType_feeds == 1 {
                        return adsCellheight + 5
                    }
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        return 325
                    }
                    if adsType_feeds == 2 {
                        return 325
                    }
                    return 275
                    
                }
                else if row == (suggestionSlideshowPosition - 1) && userSuggestions.count > 0 && showSuggestions == 1 && isHomeFeeds{
                    return 405
                }
                else
                {
                    
                    let row = (indexPath as NSIndexPath).row/kFrequencyAdsInCells_feeds
                    var index = (indexPath as NSIndexPath).row-row
                    
                    if showSuggestions == 1 && indexPath.row > (suggestionSlideshowPosition - 1) && userSuggestions.count > 0 && isHomeFeeds{
                        index = index - 1
                    }
                    if globalArrayFeed.count > index {
                        if let activityFeed = globalArrayFeed[index] as? NSDictionary{
                            let id = activityFeed["action_id"] as? Int ?? 0
                            if dynamicRowHeight[id] != nil{
                                rowHeight = dynamicRowHeight[id] ?? 0
                                // //print("Row Height \(rowHeight) index \(index)")
                            }
                        }
                    }
                    
                }
            }
            else if row == (suggestionSlideshowPosition - 1) && userSuggestions.count > 0 && showSuggestions == 1 && isHomeFeeds{
                return 405
            }
            else
            {
                if showSuggestions == 1 && indexPath.row > (suggestionSlideshowPosition - 1) && userSuggestions.count > 0 && isHomeFeeds{
                    row = row - 1
                }
                let index = row
                
                if globalArrayFeed.count > index {
                    if let activityFeed = globalArrayFeed[index] as? NSDictionary{
                        let id = activityFeed["action_id"] as? Int ?? 0
                        if dynamicRowHeight[id] != nil{
                            rowHeight = dynamicRowHeight[id]!
                            //   ////print("Row Height \(rowHeight)")
                        }
                    }
                }
            }
            return rowHeight
            
        }
        
    }
    
    //  set Dynamic Height For Every Cell
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        if tableView.tag == 11 {
            return 50
        }
        else
        {
            if globalArrayFeed.count == 0 && isshimmer == true
            {
                return 170
            }
            
            if let height = heightAtIndexPath.object(forKey: indexPath) as? NSNumber {
                return CGFloat(height.floatValue)
            } else {
                return UITableView.automaticDimension
            }
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        
        let height = NSNumber(value: Float(cell.frame.size.height))
        heightAtIndexPath.setObject(height, forKey: indexPath as NSCopying)
        cell.contentView.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)
        var row = indexPath.row as Int
        if (kFrequencyAdsInCells_feeds > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_feeds) == (kFrequencyAdsInCells_feeds)-1))
        {
            if adsType_feeds == 2{
                
                displyedAdsCount = (row / kFrequencyAdsInCells_feeds)
                row = row - displyedAdsCount
                if let cell1 = cell as? NativeAdinstallFeedCell
                {
                    var Adcount: Int = 0
                    Adcount = row/(kFrequencyAdsInCells_feeds-1)
                    
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
            else{
                displyedAdsCount = (row / kFrequencyAdsInCells_feeds)
                row = row - displyedAdsCount
            }
        }
        
        if showSuggestions == 1 && indexPath.row > (suggestionSlideshowPosition - 1) && userSuggestions.count > 0 && isHomeFeeds{
            row = row - 1
        }
        cell.tag = row
        guard globalArrayFeed.count > row else
        {
            return
        }
        if globalArrayFeed.count > row
        {
            if let activityFeed = globalArrayFeed[row] as? NSDictionary
            {
                if let cellT = cell as? AAFActivityFeedTableViewCell
                {
                    var strURLDeviceVideo = ""
                    cellT.imgReplayVideo.center = cellT.contentImageView.center
                    cellT.lblReplayVideo.center = CGPoint(x: cellT.imgReplayVideo.center.x, y: cellT.imgReplayVideo.center.y + 30)
                    cellT.imgVideo.center = cellT.contentImageView.center
                    cellT.viewVideo.frame = cellT.contentImageView.frame
                    cellT.imgViewOverLay.frame = cellT.contentImageView.frame
                    
                    if let attachement = activityFeed["attachment"] as? [AnyObject],attachement.count > 0 ,let dicAttachement = attachement[0] as? [String : AnyObject],dicAttachement != nil, let videoURL = dicAttachement["attachment_video_url"] as? String, dicAttachement != nil
                    {
                        let attachment_video_type = dicAttachement["attachment_video_type"] as? Int ?? 0
                        if let objectType = dicAttachement["attachment_type"] as? String, objectType == "video"
                        {
                            if attachment_video_type == 3
                            {
                                let attachment_video_type = dicAttachement["attachment_video_type"] as? Int ?? 0
                                if let objectType = dicAttachement["attachment_type"] as? String, objectType == "video"
                                {
                                    if attachment_video_type == 3
                                    {
                                        strURLDeviceVideo = videoURL
                                    }
                                }
                            }
                        }
                    }
                    cellT.playerController = sharedVideoPlayer
                    
                    if strURLDeviceVideo.length != 0
                    {
                        cellT.btnMuteUnMuteIcon.isHidden = false
                        if NotPlay == 1 {
                            cellT.btnMuteUnMuteIcon.isHidden = true
                        }
                        else {
                            cellT.btnMuteUnMuteIcon.isHidden = false
                        }
                        cellT.viewVideo.isHidden = false
                        cellT.playVideo(strURL: strURLDeviceVideo)
                    }
                    else
                    {
                        cellT.btnMuteUnMuteIcon.isHidden = true
                        cellT.viewVideo.isHidden = true
                        cellT.playVideo(strURL: nil)
                    }
                    
                    
                }
            }
        }
        
    }
    // Set Table Section
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    // Set Tabel Footer Height
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if tableView.tag == 11
        {
            return 0.00001
        }
        else
        {
            return 0 //80
        }
    }
    
    // Set Table Section
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    // In table view delegate
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if tableView.tag != 11
        {
            let row = indexPath.row as Int
            if globalArrayFeed.count == 0 && isshimmer == true
            {
            }
            else if (kFrequencyAdsInCells_feeds > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_feeds) == (kFrequencyAdsInCells_feeds)-1))
            {
                if let cell1 = cell as? AutoPlayVideoLayerContainer
                {
                    shared1.removeLayerFor(cell: cell1 )
                }
                // videoUrl = nil
            }
            else if indexPath.row == (suggestionSlideshowPosition - 1) && userSuggestions.count > 0 && showSuggestions == 1 && isHomeFeeds
            {
            }
            else if let cellT = cell as? AAFActivityFeedTableViewCell
            {
                
                configureCellEndDisplay(cell: cellT, indexPath: indexPath)
                
            }
        }
    }
    func configureCellEndDisplay(cell:AAFActivityFeedTableViewCell,indexPath:IndexPath)
    {
        cell.subject_photo.kf.cancelDownloadTask()
        cell.img_mapButton.kf.cancelDownloadTask()
        cell.img_imageButton1.kf.cancelDownloadTask()
        cell.img_imageButton2.kf.cancelDownloadTask()
        cell.img_imageButton3.kf.cancelDownloadTask()
        cell.img_imageButton4.kf.cancelDownloadTask()
        cell.img_imageButton5.kf.cancelDownloadTask()
        cell.img_imageButton6.kf.cancelDownloadTask()
        cell.img_imageButton7.kf.cancelDownloadTask()
        cell.img_imageButton8.kf.cancelDownloadTask()
        cell.img_imageButton9.kf.cancelDownloadTask()
        cell.imageViewWithText.kf.cancelDownloadTask()
        cell.img_bannerButton.kf.cancelDownloadTask()
        cell.contentImageView.kf.cancelDownloadTask()
        cell.imgViewOverLay.kf.cancelDownloadTask()
        sharedVideoPlayer.removeLayerFor(cell: cell)
        
    }
    // Set Cell of TabelView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if tableView.tag == 11
        {
            
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.textLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
            cell.separatorInset.left = 10.0
            cell.separatorInset.right = 10.0
            cell.backgroundColor = tableViewBgColor
            if let feed = globalArrayFeed[currentCell] as? NSDictionary
            {
                var imageName = ""
                if let feed_menu = feed["feed_menus"] as? NSArray{
                    let  menuItem = feed_menu[indexPath.row]
                    if let dic = menuItem as? NSDictionary, let d = dic["name"] as? String {
                        if d == "update_save_feed"{
                            imageName = "save-link"
                        }
                        else if d  == "edit_feed"{
                            imageName = "edit"
                        }
                        else if d == "hide"{
                            imageName = "hide-icon"
                        }
                        else if d == "report_feed"{
                            imageName = "report-feed"
                        }
                            
                        else if dic["name"] as! String == "delete_feed"{
                            imageName = "FeedNewDelete"
                        }
                        else if d == "disable_comment"{
                            imageName = "comment-disable"
                        }
                        else if d == "lock_this_feed"{
                            imageName = "feed-lock"
                        }
                        else if dic["name"] as! String == "feed_link"{
                            imageName = "NewCopy"
                        }
                        else if dic["name"] as! String == "on_off_notification"{
                            imageName = "OnOffNotification"
                        }
                        else if dic["name"] as! String == "unpin_post" || dic["name"] as! String == "pin_post" {
                            imageName = "pinpost"
                        }
                    }
                }
                let image = UIImage(named: imageName)
                let tintedImage = image?.withRenderingMode(.alwaysTemplate)
                cell.imageView?.image = tintedImage
                cell.imageView?.tintColor = iconColor
                cell.textLabel?.text = guttermenuoption[indexPath.row]
            }
            
            
            return cell
            
        }
        else
        {
            if globalArrayFeed.count == 0 && isshimmer == true
            {
                self.tableView.register(Shimmeringcell.self, forCellReuseIdentifier: "Shimmeringcell")
                let cell = tableView.dequeueReusableCell(withIdentifier:"Shimmeringcell", for: indexPath) as! Shimmeringcell
                return cell
            }
            let row = indexPath.row as Int
            //Showing Ads cell
            if (kFrequencyAdsInCells_feeds > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_feeds) == (kFrequencyAdsInCells_feeds)-1))
            {  // or 9 == if you don't want the first cell to be an ad!
                self.tableView.register(NativeAdinstallFeedCell.self, forCellReuseIdentifier: AdsCellidentifier)
                let cell1 = tableView.dequeueReusableCell(withIdentifier: AdsCellidentifier, for: indexPath as IndexPath) as! NativeAdinstallFeedCell
                cell1.selectionStyle = UITableViewCell.SelectionStyle.none
                cell1.backgroundColor = UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)//cellBackgroundColor
                var Adcount: Int = 0
                Adcount = row/(kFrequencyAdsInCells_feeds-1)
                
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
                
                if nativeAdArray.count > 0 && (nativeAdArray.count > (Adcount))
                {
                    if let obj = cell1.cellView.viewWithTag(1001001) {
                        // myButton already existed
                        obj.removeFromSuperview()
                    }
                    if adsType_feeds == 2{
                        print("com ads \(communityAdsValues[Adcount])")
                        let activityFeed = communityAdsValues[Adcount] as! NSMutableDictionary
                        cell1.Adimageview.isHidden = false
                        if adsType_feeds == 2{
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
                                        //cell.btnMuteUnMuteIcon.setTitle("\(muteVideoIcon)", for: .normal)
                                    }
                                    else
                                    {
                                        cell1.btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                                        //cell.btnMuteUnMuteIcon.setTitle("\(unMuteIconIcon)", for: .normal)
                                    }
                                    
                                    let url1 = NSURL(string: strUrl1)
                                    //                            cell.Adimageview.kf.indicatorType = .activity
                                    //                            (cell.Adimageview.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    getThumbnailImageFromVideoUrl(url: url1 as! URL) { (thumbImage) in
                                        cell1.Adimageview.image = thumbImage
                                    }
                                    
                                    cell1.Adimageview.isHidden = false
                                }
                                else{
                                    cell1.Adimageview.isHidden = true
                                }
                                
                                //                        if activityFeed["image"] != nil{
                                //                            cell.Adimageview.isHidden = false
                                //                            let icon = activityFeed["image"]
                                //                            let url = URL(string:icon as! String)
                                //
                                //                            //                    adImageView1.kf.indicatorType = .activity
                                //                            //                    (adImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                //                            cell.Adimageview.kf.setImage(with: url! as URL, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                //
                                //                            })
                                //                        }
                            }
                            //  cell1.Adimageview.image = activityFeed["image"]
                        }
                    }
                    //  cell1.Adimageview.image = activityFeed["image"]
                    print("view1 \(nativeAdArray[Adcount])")
                    let view = nativeAdArray[Adcount]
                    cell1.cellView.addSubview(view as! UIView)
                    cell1.cellView.frame.size.height = view.frame.size.height
                    adsCellheight = cell1.cellView.frame.size.height + 5
                    
                    
                }
                
                return cell1
                
            }
                //Showing suggetion cell
                
            else if indexPath.row == (suggestionSlideshowPosition - 1) && userSuggestions.count > 0 && showSuggestions == 1 && isHomeFeeds
            {
                self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: suggestionCellidentifier)
                let slideShowCell = tableView.dequeueReusableCell(withIdentifier: suggestionCellidentifier, for: indexPath as IndexPath)
                if suggetionCollectionView == nil {
                    
                    slideShowCell.selectionStyle = UITableViewCell.SelectionStyle.none
                    slideShowCell.backgroundColor = UIColor(red: 207/255.0, green: 208/255.0, blue: 212/255.0, alpha: 0.3)//cellBackgroundColor
                    
                    // Add collection view for showing suggetions
                    suggetionCollectionView = SuggetionView(frame: CGRect(x:0, y:5, width:slideShowCell.frame.size.width, height:slideShowCell.frame.size.height - 5))
                    suggetionCollectionView.createSuggetionView(comingFrom: "feed")
                    slideShowCell.addSubview(suggetionCollectionView)
                    return slideShowCell
                }
                return slideShowCell
            }
            else
            {
                
                let cell = tableView.dequeueReusableCell(withIdentifier:feedCellidentifier) as! AAFActivityFeedTableViewCell
                // Configure cell
                cell.backgroundColor =  UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)//cellBackgroundColor
                cell.imgVideo.isHidden = true
                cell.imgVideo.tag = row
                cell.gifImageViewShare.isHidden = true
                configureCell(cell: cell, indexPath:indexPath)
                cell.imgVideo.addTarget(self, action: #selector(FeedTableViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
                cell.lblReplayVideo.isHidden = true
                cell.imgReplayVideo.isHidden = true
                cell.imgReplayVideo.addTarget(self, action: #selector(FeedTableViewController.btnVideoReplayClicked(_:)), for: .touchUpInside)
                cell.btnMuteUnMuteIcon.addTarget(self, action: #selector(FeedTableViewController.btnVideoMuteUnmuteIcon(_:)), for: .touchUpInside)
                cell.btnMuteUnMuteIcon.frame.origin.y = cell.contentImageView.bounds.height - 50
                if muteVideo == true
                {
                    cell.btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                    //cell.btnMuteUnMuteIcon.setTitle("\(muteVideoIcon)", for: .normal)
                }
                else
                {
                    cell.btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                    //cell.btnMuteUnMuteIcon.setTitle("\(unMuteIconIcon)", for: .normal)
                }
                return cell
            }
            
        }
        
    }

    func configureCell(cell:AAFActivityFeedTableViewCell,indexPath:IndexPath)
    {
        
        var row = indexPath.row as Int
        cell.feedInfo.isHidden = true
        cell.feedInfo.text = ""
        cell.scheduleFeedLabel.isHidden = true
        cell.customAlbumView.isHidden = true
        cell.customAlbumView.frame.size.height = 0
        cell.cntentShareFeedView.isHidden = true
        cell.cntentShareFeedView.frame.size.height = 0
        cell.bodyHashtaglbl.isHidden = true
        noCommentMenu = false
        noshareMenu = true
        //Alter row index due to ads and suggestion cell
        if kFrequencyAdsInCells_feeds > 4 && nativeAdArray.count > 0
        {
            displyedAdsCount = (row / kFrequencyAdsInCells_feeds)
            row = row - displyedAdsCount
            
        }
        if showSuggestions == 1 && indexPath.row > (suggestionSlideshowPosition - 1) && userSuggestions.count > 0 && isHomeFeeds{
            row = row - 1
        }
        cell.tag = row
        guard globalArrayFeed.count > row else
        {
            return
        }
        let activityFeed = globalArrayFeed[row] as! NSMutableDictionary
        
        if activityFeed["isDummyResponse"] != nil
        {
            dummyDataInitialSetup(cell: cell)
            if let contentTpe = activityFeed["attachment_content_type"] as? String
            {
                var tempHeight : CGFloat = 0.0
                if let dicParams = activityFeed["params"] as? [String : AnyObject]
                {
                    cell.body.font = UIFont(name: fontName, size: FONTSIZEExtraLarge)
                    if let str = dicParams["body"] as? String
                    {
                        cell.body.isHidden = false
                        cell.body.text = str
                        cell.body.lineBreakMode = NSLineBreakMode.byWordWrapping
                        cell.body.sizeToFit()
                        cell.body.frame = CGRect(x: 10, y: getBottomEdgeY(inputView: cell.subject_photo) + 5, width: cell.cellView.bounds.width - 15, height: cell.body.bounds.height + 10)
                        tempHeight = cell.body.frame.size.height
                    }
                    else if let str = dicParams["title"] as? String
                    {
                        cell.body.isHidden = false
                        cell.body.text = str
                        cell.body.lineBreakMode = NSLineBreakMode.byWordWrapping
                        cell.body.sizeToFit()
                        cell.body.frame = CGRect(x: 10, y: getBottomEdgeY(inputView: cell.subject_photo) + 5, width: cell.cellView.bounds.width - 15, height: cell.body.bounds.height + 10)
                        tempHeight = cell.body.frame.size.height
                    }
                    else
                    {
                        cell.body.isHidden = true
                        tempHeight = 0.0
                    }
                    
                }
                switch contentTpe {
                case "video":
                    videoDummyViewWhileUploading(cell: cell, activityFeed: activityFeed, indexPath: row, textHeight: tempHeight)
                case "photo":
                    imageDummyViewWhileUploading(cell: cell, activityFeed: activityFeed, indexPath: row, textHeight: tempHeight)
                case "sellSomething":
                    sellSomethingDummyViewWhileUploading(cell: cell, activityFeed: activityFeed, indexPath: row, textHeight: tempHeight)
                case "composer":
                    composerDummyViewWhileUploading(cell: cell, activityFeed: activityFeed, indexPath: row, textHeight: tempHeight)
                default: break
                    //print("Invalid type")
                }
                
            }
            cell.viewBlur.isHidden = false
            cell.viewBlur.frame = CGRect(x: 0 ,y: getBottomEdgeY(inputView: cell.viewContianerProgressView) ,width: cell.frame.size.width ,height: cell.cellView.frame.size.height - cell.viewContianerProgressView.frame.size.height)
        }
        else
        {
            cell.viewContianerProgressView.frame = CGRect(x: 0 ,y: 0 ,width: cell.frame.size.width ,height: 0)
            cell.viewContianerProgressView.isHidden = true
            cell.progressView.isHidden = true
            cell.viewBlur.isHidden = true
            cell.subject_photo.frame = CGRect(x: 3, y: 3, width: 50, height: 50)
            cell.title.frame = CGRect(x: cell.subject_photo.bounds.width + 15,y: 10, width: cell.cellView.bounds.width-(cell.subject_photo.bounds.width + 65),height: 15)
            
            cell.pinMenu.isHidden = true
            if  (activityFeed["isPinned"] as? Bool) != nil{
                if activityFeed["isPinned"] as! Bool == true{
                    cell.pinMenu.isHidden = false
                }
            }
            if globalArrayFeed.count > row
            {
                if let activityFeed = globalArrayFeed[row] as? NSDictionary
                {
                    action_id = activityFeed["action_id"] as! Int
                    if tempcontentFeedArray[activityFeed["action_id"] as? Int ?? 0] != nil
                    {
                        
                        dynamicHeight = 90
                        cell.cellView.frame.size.height = 75
                        //Hide views for hiding cell
                        for ob in cell.cellView.subviews{
                            
                            if ob .isKind(of: UIImageView.self){
                                (ob as! UIImageView).isHidden = true
                            }
                            if ob .isKind(of: UILabel.self){
                                (ob as! UILabel).isHidden = true
                            }
                            if ob .isKind(of: UIButton.self){
                                (ob as! UIButton).isHidden = true
                            }
                            if ob .isKind(of: UIView.self){
                                (ob as UIView).isHidden = true
                            }
                            if ob .isKind(of: TTTAttributedLabel.self){
                                (ob as! TTTAttributedLabel).isHidden = true
                            }
                        }
                        
                        if let undoDic = tempcontentFeedArray[activityFeed["action_id"] as? Int ?? 0] as? NSDictionary
                        {
                            cell.feedInfo.isHidden = false
                            cell.feedInfo.delegate = self
                            cell.feedInfo.numberOfLines = 0
                            cell.feedInfo.frame = CGRect(x: 20,y: 5,width: cell.cellView.bounds.width-40,height: cell.cellView.frame.size.height-10)
                            var tempFeedInfo = ""
                            if let dic = undoDic["undo"] as? NSDictionary{
                                tempFeedInfo = dic["label"] as? String ?? ""
                                tempFeedInfo = tempFeedInfo + NSLocalizedString("   Undo  ", comment: "")
                                
                            }
                            if let dic1 = undoDic["hide_all"] as? NSDictionary
                            {
                                tempFeedInfo = tempFeedInfo + (dic1["label"] as? String ?? "")
                            }
                            cell.feedInfo.activeLinkAttributes = subscriptionNoticeActiveLinkAttributes
                            tempFeedInfo = tempFeedInfo.replacingOccurrences(of: "<br />", with: "\n")
                            //tempFeedInfo = tempFeedInfo.html2String
                            cell.feedInfo.setText(tempFeedInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                let boldFont = CTFontCreateWithName((fontBold as CFString?)!, FONTSIZEMedium, nil)
                                let range = (tempFeedInfo as NSString).range(of:NSLocalizedString("Undo",  comment: ""))
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                                return mutableAttributedString
                            })
                            
                            
                            
                            if let dic = undoDic["undo"] as? NSDictionary
                            {
                                let range = (tempFeedInfo as NSString).range(of: NSLocalizedString("Undo",  comment: ""))
                                cell.feedInfo.addLink(toTransitInformation: ["urlParams" : dic["urlParams"] as! NSDictionary, "type" : "undo","url" : dic["url"] as! String, "index" : row, "action_id" :activityFeed["action_id"] as! Int], with:range)
                            }
                            if let dic = undoDic["hide_all"] as? NSDictionary{
                                if let d = dic["name"] as? String,d == "hide_all" {
                                    let range = (tempFeedInfo as NSString).range(of: dic["label"] as! String)
                                    cell.feedInfo.addLink(toTransitInformation: ["urlParams" : dic["urlParams"] as! NSDictionary, "type" : "hide_all","url" : dic["url"] as! String, "index" : row], with:range)
                                }else if let d = dic["name"] as? String, d == "report"{
                                    let range = (tempFeedInfo as NSString).range(of: dic["label"] as! String)
                                    cell.feedInfo.addLink(toTransitInformation: ["urlParams" : dic["urlParams"] as! NSDictionary, "type" : "report","url" : dic["url"] as! String], with:range)
                                    
                                }
                            }
                        }
                    }
                    else
                    {
                        // Clear Cell Contents ScrollView
                        cell.cellView.isHidden = false
                        cell.title.text = ""
                        cell.title.isHidden = false
                        cell.subject_photo.isHidden = false
                        cell.subject_photo1.isHidden = false
                        var addMoreDescription = false
                        var titleSubject : String!
                        var objectTypee : String = ""
                        var ObjectId:Int!
                        var statusBody : String = ""
                        var title : String = ""
                        
                        // Start Showing User image  of post
                        if let imgUrl = activityFeed["subject_image"] as? String
                        {
                            if imgUrl != ""
                            {
                                if let url = URL(string:imgUrl)
                                {
                                    
                                    //                                    cell.subject_photo.kf.indicatorType = .activity
                                    //                                    (cell.subject_photo.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                                    cell.subject_photo.kf.setImage(with: url, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        DispatchQueue.main.async {
                                            cell.subject_photo.isHidden = false
                                            cell.subject_photo1.tag = row
                                            cell.subject_photo1.addTarget(self, action: #selector(FeedTableViewController.showUserProfile(sender:)), for: .touchUpInside)
                                        }
                                    })
                                    
                                }
                                
                            }
                        }
                        // End Showing User image  of post
                        
                        // Post Title work start
                        cell.title.frame = CGRect(x: cell.subject_photo.bounds.width + 15,y: 10, width: cell.cellView.bounds.width-(cell.subject_photo.bounds.width + 65),height: 15)
                        var titlearr = [String]()
                        //                    // Set Feed Main Title
                        if var _ = activityFeed["action_type_body"] as? String
                        {
                            title = (activityFeed["action_type_body"] as? String ?? "")
                            let actiontypebodytitle = title
                            if  let body_param = activityFeed["action_type_body_params"] as? NSArray{
                                
                                for i in 0 ..< body_param.count
                                {
                                    
                                    if  let body1 = body_param[i] as? NSDictionary
                                    {
                                        let search = body1["search"] as? String ?? ""
                                        if let d = body1["search"] as? String, d == "{actors:$subject:$object}"
                                        {
                                            if (body1["object"] != nil)
                                            {
                                                if let  objectSubject =   body1["object"] as? NSDictionary
                                                {
                                                    if(objectSubject["label"] is String )
                                                    {
                                                        
                                                        titleSubject = objectSubject["label"] as? String ?? ""
                                                        
                                                    }
                                                    if( objectSubject["id"] is Int )
                                                    {
                                                        
                                                        ObjectId = objectSubject["id"] as? Int ?? 0
                                                        
                                                    }
                                                    if(objectSubject["type"] is String){
                                                        
                                                        objectTypee = objectSubject["type"] as? String ?? ""
                                                        
                                                    }
                                                }
                                                title =  search + " \u{2794} " + titleSubject
                                                //title =  "<b>" + search + " &rarr; " + titleSubject + "</b>"
                                                
                                            }
                                            
                                        }
                                        if(body1["search"] is String)
                                        {
                                            if (body1["label"] is String)
                                            {
                                                let label =  body1["label"] as? String ?? ""
                                                if(search == "{body:$body}")
                                                {
                                                    if title.range(of:search) != nil
                                                    {
                                                        title = title.replacingOccurrences(of: search, with: "", options: String.CompareOptions.literal, range: nil)
                                                        
                                                    }
                                                    if  tableViewFrameType == "FeedViewPageViewController" || tableViewFrameType == "CommentsViewController"
                                                    {
                                                        statusBody = label
                                                    }
                                                    else
                                                    {
                                                        let SeeMore : Int = Int((view.bounds.height/2) - 106) // for iphone x it's 300.
                                                        
                                                        if label.length < SeeMore
                                                        {
                                                            if title.range(of:search) != nil
                                                            {
                                                                title = title.replacingOccurrences(of: search, with: "", options: String.CompareOptions.literal, range: nil)
                                                            }
                                                            if  tableViewFrameType == "FeedViewPageViewController" || tableViewFrameType == "CommentsViewController"
                                                            {
                                                                statusBody = String(label)
                                                            }
                                                            else
                                                            {
                                                                statusBody = String(label)
                                                            }
                                                            
                                                        }
                                                        else
                                                        {
                                                            statusBody = (label as NSString).substring(to: SeeMore-13)
                                                            statusBody += NSLocalizedString("...See more",  comment: "")
                                                            addMoreDescription = true
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    if title.range(of:search) != nil{
                                                        title = title.replacingOccurrences(of: search, with: label, options: String.CompareOptions.literal, range: nil)
                                                        
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                if (body1["label"] is Int)
                                                {
                                                    let label =  body1["label"] as? Int ?? 0
                                                    if(search == "{body:$body}")
                                                    {
                                                        if title.range(of:search) != nil
                                                        {
                                                            title = title.replacingOccurrences(of: search, with: "", options: String.CompareOptions.literal, range: nil)
                                                            statusBody = String(label)
                                                        }
                                                    }
                                                    else
                                                    {
                                                        if title.range(of:search) != nil
                                                        {
                                                            title = title.replacingOccurrences(of: search, with: String(label), options: String.CompareOptions.literal, range: nil)
                                                            statusBody = String(label)
                                                        }
                                                    }
                                                }
                                                
                                            }
                                        }
                                        
                                    }
                                }
                                
                            }
                            
                            // Check for Tags in Title
                            if let tags = activityFeed["tags"] as? NSArray{
                                // Get tagged string
                                title = getTaggedstring(title: title, tagarr: tags)
                                
                            }
                            // Check for CheckIn  in Title
                            if let params = activityFeed["params"] as? NSDictionary{
                                // Get CheckIn string
                                title = getCheckInstring(title: title, checkinparams: params)
                                
                            }
                            titlearr = title.components(separatedBy: " ")
                            //title = title.html2String as String
                            title = Emoticonizer.emoticonizeString("\(title)" as NSString) as String
                            title = title.replacingOccurrences(of: "<br />", with: "")
                            title = title.replacingOccurrences(of: "\r\n", with: "")
                            //title = title.html2String
                            cell.title.delegate = self
                            cell.title.setText(title, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                for var titleword in titlearr
                                {
                                    if actiontypebodytitle.range(of:titleword) != nil{
                                        if titleword.length < 10
                                        {
                                            titleword = " " + titleword + " "
                                        }
                                        let normalFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                                        let range4 = (title as NSString).range(of:NSLocalizedString(titleword,  comment: ""))
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: normalFont, range: range4)
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range4)
                                        
                                    }
                                    
                                }
                                return mutableAttributedString
                            })
                            
                            // DispatchQueue.global(qos: .default).async {
                            
                            // tagged user
                            DispatchQueue.global(qos: .userInitiated).async {
                                if let tags = activityFeed["tags"] as? NSArray
                                {
                                    if tags.count > 0
                                    {
                                        //Loop runs twice because we are showing only 2 tageed user
                                        for i in 0 ..< tags.count{
                                            if let tag = ((tags[i] as! NSDictionary)["tag_obj"] as! NSDictionary)["displayname"] as? String{
                                                let tag_id = ((tags[i] as! NSDictionary)["tag_obj"] as! NSDictionary)["user_id"] as? Int ?? 0
                                                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\(title)")
                                                let length = attrString.length
                                                var range = NSMakeRange(0, attrString.length)
                                                while(range.location != NSNotFound)
                                                {
                                                    range = (title as NSString).range(of: tag, options: NSString.CompareOptions(), range: range)
                                                    if(range.location != NSNotFound) {
                                                        cell.title.addLink(toTransitInformation: ["id" : tag_id, "type" : "user"], with:range)
                                                        range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                                                        
                                                    }
                                                }
                                                
                                            }
                                            
                                            if tags.count > 2
                                            {
                                                break
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                
                            }
                            
                            
                            // checkin User
                            if let params = activityFeed["params"] as? NSDictionary{
                                if params.count > 0{
                                    if let checkIn = params["checkin"] as? NSDictionary{
                                        let location = checkIn["label"] as? String ?? ""
                                        var place_id = ""
                                        if let tempPlaceId = checkIn["place_id"] as? String{
                                            place_id = tempPlaceId
                                        }
                                        let range = (title as NSString).range(of: NSLocalizedString(location,  comment: ""))
                                        cell.title.addLink(toTransitInformation: ["type" : "map","location" : location, "place_id" : place_id], with:range)
                                        
                                    }
                                    
                                }
                            }
                            
                            
                            
                            //Link work
                            if let links = activityFeed["action_type_body_params"] as? NSArray
                            {
                                for link in links
                                {
                                    if let dic = link as? NSDictionary
                                    {
                                        if dic["id"] != nil &&  dic["type"] != nil
                                        {
                                            let id = dic["id"] as? Int ?? 0
                                            let type = dic["type"] as? String ?? ""
                                            let value = String(describing: dic["label"] ?? "")
                                            let range = (title as NSString).range(of: value)
                                            //let range = (title as NSString).range(of: value.html2String)
                                            cell.title.addLink(toTransitInformation: ["type" : type,"id" : id, "feed" : activityFeed, "feedIndex":row], with:range )
                                            
                                            
                                        }
                                        
                                    }
                                }
                            }
                            
                            // Make othe user clickable start
                            DispatchQueue.global(qos: .userInitiated).async {
                                if(titleSubject != nil)
                                {
                                    let range = (title as NSString).range(of:titleSubject)
                                    cell.title.addLink(toTransitInformation: ["id" : ObjectId, "type" : "\(objectTypee)"], with:range)
                                    
                                } // Make Make othe user clickable end
                                
                                // Other tagged user
                                if self.tagOtherUserCount > 0 {
                                    let range = (title as NSString).range(of:NSLocalizedString("\(self.tagOtherUserCount) others",  comment: ""))
                                    cell.title.addLink(toTransitInformation: ["tags": activityFeed["tags"] as? NSArray? as Any, "id" : activityFeed["action_id"] as! Int, "type" : "tagother","index" : row], with:range)
                                }
                                
                            }
                            
                            
                            
                        }
                        //cell.title.text = "Raghu ram is posted on feed"
                        cell.title.lineBreakMode = NSLineBreakMode.byWordWrapping
                        cell.title.sizeToFit()
                        // Post Title  work ended
                        
                        // Set Feed Post Time (Feed Creation Date)
                        cell.createdAt.frame.origin.y = cell.title.frame.origin.y + cell.title.bounds.height
                        cell.createdAt.text = ""
                        cell.createdAt.isHidden = false
                        
                        
                        
                        // Feed Created date
                        if refreshLikeUnLike == true
                        {
                            if let postedDate = activityFeed["feed_createdAt"] as? String{
                                var iconString = ""
                                iconString = "\u{f0ac}"
                                DispatchQueue.global().async {
                                    let postedOn = dateDifference(postedDate)
                                    DispatchQueue.main.async {
                                        if let privacy = activityFeed["privacy_icon"] as? String {
                                            
                                            switch privacy {
                                            case "onlyme":
                                                iconString = "\u{f023}"
                                                break
                                            case "networks":
                                                iconString = "\(groupIcon)"
                                                break
                                            case "friends":
                                                iconString = "\u{f007}"
                                                break
                                                
                                            case "network_list_custom":
                                                iconString = "\(groupIcon)"
                                                break
                                            case "friend_list_custom":
                                                iconString = "\(listingDefaultIcon)"
                                                break
                                                
                                            default:
                                                iconString = "\u{f0ac}"
                                                break
                                            }
                                            cell.createdAt.text =  String(format: NSLocalizedString("%@  %@", comment: ""), postedOn,iconString)
                                            // return
                                        }
                                        else
                                        {
                                            cell.createdAt.text = String(format: NSLocalizedString("%@ %@", comment: ""),postedOn ,iconString )
                                        }
                                    }
                                }
                                
                            }
                        }
                        var originY:CGFloat = cell.subject_photo.frame.origin.y + cell.subject_photo.bounds.height + 10
                        if originY < cell.createdAt.bounds.height + cell.createdAt.frame.origin.y + 5{
                            
                            originY = cell.createdAt.bounds.height + cell.createdAt.frame.origin.y + 5
                            
                        }
                        
                        
                        // Post Bpody  work started
                        switch statusBody {
                        case "":
                            cell.body.frame.size.height = 0
                            break
                        default:
                            cell.body.frame.size.height = 50
                            cell.body.frame.size.width = cell.cellView.bounds.width - 15
                            break
                        }
                        
                        cell.body.frame.size.height = 0
                        if (activityFeed["userTag"] as? NSArray) != nil{
                            cell.body.linkAttributes = subscriptionTagLinkAttributes
                        }
                        else{
                            cell.body.linkAttributes = subscriptionNoticeLinkAttributes
                        }
                        var nsurl: NSURL!
                        var url:String!
                        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                        let matches = detector.matches(in: statusBody, options: [], range: NSMakeRange(0, statusBody.count))
                        cell.body.delegate = self
                        cell.body.isHidden = false
                        var bodyColor = textColorDark//textColorMedium
                        var fontSize : Int = Int(FONTSIZENormal)
                        
                        
                        if (activityFeed["decoration"] as? NSDictionary) != nil{
                            let dict = activityFeed["decoration"] as! NSDictionary
                            var check = dict["font_color"] as! String
                            let _ = check.remove(at: (check.startIndex))
                            bodyColor = UIColor(hex: "\(check)")
                            fontSize = (dict["font_size"] as! Int)
                            
                            
                        }
                        
                        
                        cell.body.textColor = bodyColor
                        
                        cell.body.frame.origin.y = originY
                        var hashtagString : String! = ""
                        let words = statusBody.components(separatedBy: " ")
                        
                        cell.body.setText(statusBody, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                            let boldFont = CTFontCreateWithName((fontNormal as CFString?)!, CGFloat(fontSize), nil)
                            
                            let range = (statusBody as NSString).range(of:statusBody)
                            
                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                            
                            let boldFont1 = CTFontCreateWithName((fontBold as CFString?)!, CGFloat(fontSize), nil)
                            
                            let range2 = (statusBody as NSString).range(of:NSLocalizedString("See more",  comment: ""))
                            
                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range2)
                            
                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range2)
                            
                            let paragraphStyle = NSMutableParagraphStyle()
                            
                            // *** set LineSpacing property in points ***
                            paragraphStyle.lineSpacing = 1.5 // Whatever line spacing you want in points
                            
                            // *** Apply attribute to string ***
                            mutableAttributedString?.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, (mutableAttributedString?.length)!))
                            
                            for match in matches {
                                var stringurl = ""
                                nsurl = match.url! as NSURL?
                                url = "\(nsurl!)"
                                let original = url
                                stringurl = original!
                                
                                let boldFont2 = CTFontCreateWithName((fontBold as CFString?)!, FONTSIZEMedium, nil)
                                let range3 = (statusBody as NSString).range(of:NSLocalizedString("\(stringurl)",  comment: ""))
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont2, range: range2)
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:buttonColor , range: range3)
                                
                            }
                            
                            if let tags = activityFeed["userTag"] as? NSArray{
                                if tags.count > 0{
                                    for i in 0 ..< tags.count {
                                        if let tag = ((tags[i] as! NSDictionary))["resource_name"] as? String{
                                            let length = mutableAttributedString?.length
                                            var range = NSMakeRange(0, length!)
                                            while(range.location != NSNotFound)
                                            {
                                                range = (statusBody as NSString).range(of:tag, options: NSString.CompareOptions(), range: range)
                                                if(range.location != NSNotFound) {
                                                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range)
                                                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                                                    range = NSMakeRange(range.location + range.length, length! - (range.location + range.length));
                                                    
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                            }
                            for word in words {
                                if word.hasPrefix("#") {
                                    hashtagString  =  hashtagString + word
                                    let length = mutableAttributedString?.length
                                    var range = NSMakeRange(0, length!)
                                    while(range.location != NSNotFound)
                                    {
                                        range = (statusBody as NSString).range(of:"\(word)", options: NSString.CompareOptions(), range: range)
                                        if(range.location != NSNotFound) {
                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range)
                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                                            range = NSMakeRange(range.location + range.length, length! - (range.location + range.length));
                                            
                                        }
                                    }
                                }
                            }
                            
                            if (activityFeed["wordStyle"] as? NSArray) != nil{
                                let dictArray = activityFeed["wordStyle"] as! NSArray
                                var bodyWordStyle = textColorDark
                                var tag = ""
                                if dictArray.count > 0 {
                                    for i in (0..<dictArray.count) {
                                        if dictArray[i] as? NSDictionary != nil {
                                            let  dict = dictArray[i] as! NSDictionary
                                            
                                            var check = dict["color"] as! String
                                            let _ = check.remove(at: (check.startIndex))
                                            bodyWordStyle = UIColor(hex: "\(check)")
                                            tag = dict["title"] as! String
                                            
                                            //                        fontSize = dict["font_size"] as! Int
                                            
                                        }
                                    }
                                }
                                
                                
                                let length = mutableAttributedString?.length
                                var range = NSMakeRange(0, length!)
                                while(range.location != NSNotFound)
                                {
                                    range = (statusBody as NSString).range(of:tag, options: .caseInsensitive, range: range)
                                    if(range.location != NSNotFound) {
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range)
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:bodyWordStyle , range: range)
                                        range = NSMakeRange(range.location + range.length, length! - (range.location + range.length));
                                        
                                    }
                                }
                            }
                            
                            
                            return mutableAttributedString
                        })
                        cell.body.lineBreakMode = NSLineBreakMode.byWordWrapping
                        cell.body.sizeToFit()
                        cell.body.frame.size.height = cell.body.bounds.height + 10
                        
                        DispatchQueue.global(qos: .default).async {
                            if addMoreDescription
                            {
                                let range = (statusBody as NSString).range(of:NSLocalizedString("...See more",  comment: ""))
                                cell.body.addLink(toTransitInformation: ["id" : activityFeed["action_id"] as! Int, "type" : "more1","index" : row], with:range)
                                
                            }
                            for match in matches {
                                var stringurl = ""
                                let nsurl = match.url!
                                url = "\(nsurl)"
                                let original = url
                                stringurl = original!
                                let range = (statusBody as NSString).range(of:NSLocalizedString("\(stringurl)",  comment: ""))
                                cell.body.addLink(toTransitInformation: ["id" :activityFeed["action_id"] as! Int, "type" : "link","objectUrl": url], with:range)
                            }
                            
                            for word in words {
                                if word.hasPrefix("#") {
                                    let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\(statusBody)")
                                    let length = attrString.length
                                    var range = NSMakeRange(0, attrString.length)
                                    while(range.location != NSNotFound)
                                    {
                                        range = (statusBody as NSString).range(of:"\(word)", options: NSString.CompareOptions(), range: range)
                                        if(range.location != NSNotFound) {
                                            cell.body.addLink(toTransitInformation: ["type" : "hashtags", "hashtagString" : "\(word)"], with:range)
                                            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                                            
                                        }
                                    }
                                }
                            }
                            if let tags = activityFeed["userTag"] as? NSArray{
                                
                                if tags.count > 0{
                                    
                                    for i in 0 ..< tags.count {
                                        
                                        if let tag = ((tags[i] as! NSDictionary))["resource_name"] as? String{
                                            let tag_id = ((tags[i] as! NSDictionary))["resource_id"] as? Int
                                            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\(statusBody)")
                                            let length = attrString.length
                                            var range = NSMakeRange(0, attrString.length)
                                            while(range.location != NSNotFound)
                                            {
                                                range = (statusBody as NSString).range(of: tag, options: NSString.CompareOptions(), range: range)
                                                if tag_id != nil {
                                                    if(range.location != NSNotFound) {
                                                        cell.body.addLink(toTransitInformation: ["id" : tag_id!, "type" : "user"], with:range)
                                                        range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                                                        
                                                    }
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        // Post Bpody  work ended
                        //Attachment and hashtag work start
                        if activityFeed["attactment_Count"] as? Int == 0
                        {
                            cell.sellSlideShowView.isHidden = true
                            if activityFeed["feed_Type"] as? String == "sitetagcheckin_checkin" || activityFeed["feed_Type"] as? String == "sitetagcheckin_status"{
                                if let params = activityFeed["params"] as? NSDictionary{
                                    if params.count > 0 {
                                        if let checkIn = params["checkin"] as? NSDictionary{
                                            
                                            if let long = checkIn["longitude"] as? Double {
                                                let lat = checkIn["latitude"] as! Double
                                                
                                                let staticMapUrl: String = "http://maps.google.com/maps/api/staticmap?key=\(apiServerKey)&markers=color:red|\(lat),\(long)&\("zoom=13&size=720x720")&sensor=true"
                                                
                                                let imageUrl = URL(string: staticMapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
                                                
                                                cell.customAlbumView.frame.origin.y = getBottomEdgeY(inputView: cell.body) + 5
                                                cell.customAlbumView.isHidden = false
                                                cell.cntentShareFeedView.isHidden = true
                                                cell.imageButton1.isHidden = true
                                                cell.mapButton.isHidden = false
                                                cell.bannerButton.isHidden = true
                                                cell.imageButton2.isHidden = true
                                                cell.imageButton3.isHidden = true
                                                cell.imageButton4.isHidden = true
                                                cell.imageButton5.isHidden = true
                                                cell.imageButton6.isHidden = true
                                                cell.imageButton7.isHidden = true
                                                cell.imageButton8.isHidden = true
                                                cell.imageButton9.isHidden = true
                                                
                                                cell.img_imageButton1.isHidden = true
                                                cell.img_mapButton.isHidden = false
                                                cell.img_bannerButton.isHidden = true
                                                cell.img_imageButton2.isHidden = true
                                                cell.img_imageButton3.isHidden = true
                                                cell.img_imageButton4.isHidden = true
                                                cell.img_imageButton5.isHidden = true
                                                cell.img_imageButton6.isHidden = true
                                                cell.img_imageButton7.isHidden = true
                                                cell.img_imageButton8.isHidden = true
                                                cell.img_imageButton9.isHidden = true
                                                
                                                cell.imageViewWithText.isHidden = true
                                                let tempHeight = ceil(cell.cellView.bounds.width * 0.8)
                                                cell.customAlbumView.frame.size.height = tempHeight + 10
                                                cell.mapButton.frame.size.height = tempHeight
                                                dynamicHeight = tempHeight + 10
                                                self.dynamicHeight = cell.customAlbumView.frame.size.height
                                                
                                                cell.mapButton.backgroundColor = .clear
                                                // cell.img_mapButton.kf.indicatorType = .activity
                                                // (cell.img_mapButton.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                                                cell.img_mapButton.frame = cell.mapButton.frame
                                                cell.img_mapButton.kf.setImage(with: imageUrl, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                                    
                                                })
                                                cell.img_mapButton.contentMode = .scaleAspectFill
                                                cell.mapButton.addTarget(self, action: #selector(FeedTableViewController.mapRedirection(sender:)), for: .touchUpInside)
                                                cell.mapButton.tag = row
                                                if activityFeed["hashtags"] != nil
                                                {
                                                    // Create Hashtag
                                                    createhashtag(row: row,cell: cell)
                                                    
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                            else
                            {
                                dynamicHeight = 0
                                cell.customAlbumView.isHidden = true
                                cell.cntentShareFeedView.isHidden = true
                                cell.customAlbumView.frame.size.height = 0
                                cell.customAlbumView.frame.origin.y = getBottomEdgeY(inputView: cell.body) + 5
                                if activityFeed["hashtags"] != nil
                                {
                                    // Create Hashtag
                                    createhashtag(row: row,cell: cell)
                                }
                            }
                        }
                        else if activityFeed["attachment_content_type"] as? String == "advancedactivity_sell"
                        {
                            
                            if let attachmentArray = activityFeed["attachment"] as? NSArray{
                                var title = ""
                                var price = ""
                                var loc = ""
                                var desc = ""
                                var currency = ""
                                //var showUrl = ""
                                var sellDescLabel = ""
                                var showSellMoreDesc = false
                                if let feed = attachmentArray[0] as? NSDictionary
                                {
                                    if feed["title"]  != nil {
                                        title = String(describing: feed["title"] as AnyObject)
                                    }
                                    if feed["price"]  != nil {
                                        price = String(describing: feed["price"] as AnyObject)
                                        
                                    }
                                    if feed["currency"]  != nil {
                                        currency = String(describing: feed["currency"] as AnyObject)
                                        
                                    }
                                    if feed["place"]  != nil {
                                        loc = String(describing: feed["place"] as AnyObject)
                                        
                                    }
                                    if feed["body"]  != nil {
                                        desc = String(describing:feed["body"] as AnyObject)
                                        sellDescLabel = desc
                                        
                                    }
                                    if feed["uri"]  != nil {
                                        // showUrl = String(describing:feed["uri"] as AnyObject)
                                        
                                    }
                                    
                                    if let dic1 = feed["sell_image"] as? NSArray
                                    {
                                        
                                        
                                        cell.sellSlideShowView.frame.origin.y = getBottomEdgeY(inputView: cell.body)
                                        cell.sellSlideshow.browseSellContent(contentItems: dic1 as [AnyObject],comingFrom : "")
                                        cell.sellSlideshow.frame.size.height = 250
                                        
                                    }
                                    else{
                                        cell.sellSlideshow.frame.size.height = 0
                                        
                                    }
                                    cell.sellSlideShowView.isHidden = false
                                    cell.sellSlideShowView.layoutIfNeeded()
                                    
                                    cell.sellTitle.frame.origin.y = cell.sellSlideshow.bounds.size.height + 10 + cell.sellSlideshow.frame.origin.y
                                    cell.sellTitle.text = title
                                    cell.sellTitle.numberOfLines = 0
                                    cell.sellTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
                                    cell.sellTitle.sizeToFit()
                                    cell.sellTitle.frame.size.width = cell.cellView.frame.size.width - 20
                                    
                                    cell.sellPrice.frame.origin.y = cell.sellTitle.bounds.size.height + 10 + cell.sellTitle.frame.origin.y
                                    
                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                        let defaults = UserDefaults.standard
                                        if let name = defaults.object(forKey: "Currency")
                                        {
                                            print("=== \(name)== \(defaults.object(forKey: "PriceRate") as! Float)=")
                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(truncating: (feed["price"] as AnyObject) as! NSNumber)
                                            let showPrice = (String(format:"%.2f", changePrice))
                                            
                                            cell.sellPrice.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                            
                                        }
                                    }
                                    else{
                                        
                                        cell.sellPrice.text = "\(dollarIcon) \(currency) \(price)"
                                    }
                                    cell.sellPrice.textColor = UIColor(red: 34/255.0, green: 139/255.0, blue: 34/255.0, alpha: 1.0)//rgb(34,139,34)//UIColor.green
                                    cell.sellPrice.numberOfLines = 0
                                    cell.sellPrice.lineBreakMode = NSLineBreakMode.byTruncatingTail
                                    cell.sellPrice.sizeToFit()
                                    cell.sellPrice.frame.size.width = cell.cellView.frame.size.width - 20
                                    
                                    
                                    cell.sellLocation.frame.origin.y = cell.sellPrice.bounds.size.height + 10 + cell.sellPrice.frame.origin.y
                                    if loc != "" {
                                        cell.sellLocation.text = "\(locationIcon) \(loc)"
                                    }
                                    
                                    cell.sellLocation.sizeToFit()
                                    cell.sellLocation.numberOfLines = 0
                                    cell.sellLocation.lineBreakMode = NSLineBreakMode.byTruncatingTail
                                    cell.sellLocation.frame.size.width = cell.cellView.frame.size.width - 20
                                    
                                    
                                    
                                    
                                    cell.sellDesc.frame.origin.y = cell.sellLocation.bounds.size.height + 10 + cell.sellLocation.frame.origin.y
                                    cell.sellDesc.linkAttributes = [kCTForegroundColorAttributeName as AnyHashable : linkColor.cgColor,kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: false)]
                                    cell.sellDesc.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                                    if  tableViewFrameType == "FeedViewPageViewController" || tableViewFrameType == "CommentsViewController"
                                    {
                                        desc = sellDescLabel
                                    }
                                    else{
                                        let SeeMore : Int = Int((view.bounds.height/2) - 106) // for iphone x it's 300.
                                        
                                        if sellDescLabel.length < SeeMore
                                        {
                                            desc = sellDescLabel
                                        }
                                        else
                                        {
                                            desc = (sellDescLabel as NSString).substring(to: SeeMore-13)
                                            desc += "  ...See more"
                                            showSellMoreDesc = true
                                        }
                                    }
                                    cell.sellDesc.delegate = self
                                    cell.sellDesc.numberOfLines = 0
                                    // cell.sellDesc.lineBreakMode = NSLineBreakMode.byTruncatingTail
                                    cell.sellDesc.setText(desc, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                        
                                        let sellFont = CTFontCreateWithName((fontNormal as CFString?)!, CGFloat(fontSize), nil)
                                        let range = (desc as NSString).range(of:desc)
                                        
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: sellFont, range: range)
                                        
                                        let boldFont1 = CTFontCreateWithName((fontBold as CFString?)!, CGFloat(fontSize), nil)
                                        
                                        let range2 = (statusBody as NSString).range(of:NSLocalizedString("See more",  comment: ""))
                                        
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range2)
                                        
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range2)
                                        
                                        let paragraphStyle = NSMutableParagraphStyle()
                                        
                                        // *** set LineSpacing property in points ***
                                        paragraphStyle.lineSpacing = 1.5 // Whatever line spacing you want in points
                                        
                                        // *** Apply attribute to string ***
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, (mutableAttributedString?.length)!))
                                        
                                        return mutableAttributedString!
                                    })
                                    
                                    cell.sellDesc.sizeToFit()
                                    cell.sellDesc.frame.size.height =  cell.sellDesc.bounds.size.height + 20
                                    
                                    DispatchQueue.global(qos: .default).async {
                                        if showSellMoreDesc
                                        {
                                            let range = (desc as NSString).range(of:NSLocalizedString("  ...See more",  comment: ""))
                                            cell.sellDesc.addLink(toTransitInformation: ["id" : activityFeed["action_id"] as! Int, "type" : "more1","index" : row], with:range)
                                            
                                        }
                                    }
                                    
                                    cell.sellDesc.frame.size.width = cell.cellView.frame.size.width - 20
                                    cell.sellSlideShowView.frame.size.height = cell.sellDesc.frame.origin.y + cell.sellDesc.frame.size.height + 20
                                    
                                    self.dynamicHeight = cell.sellSlideShowView.frame.size.height//cell.sellDesc.frame.origin.y + cell.sellDesc.bounds.height + 10 //cell.sellSlideShowView.frame.size.height
                                    
                                    
                                    // }
                                }
                            }
                        }
                            
                        else
                        {
                            cell.sellSlideShowView.isHidden = true
                            cell.contentImageView.image = placeholderImage
                            if let photosAttachmentCount = activityFeed["photo_attachment_count"] as? Int
                            {
                                var imageUrlArray = [String]()
                                // Get url of all attachment
                                imageUrlArray = getattachmentUrl(activityFeed: activityFeed)
                                cell.customAlbumView.frame.origin.y = getBottomEdgeY(inputView: cell.body) + 5
                                
                                switch (photosAttachmentCount)
                                {
                                case 0:
                                    var imageUrl = ""
                                    if let attachmentArray = activityFeed["attachment"] as? NSArray{
                                        
                                        if attachmentArray.count > 0 {
                                            if let feed = attachmentArray[0] as? NSDictionary
                                            {
                                                if (feed["uri"] as? String) != nil
                                                {
                                                    imageUrl = ""//imageurl
                                                    shareattachmentFeed(cell:cell,activityFeed: activityFeed,imageUrl:imageUrl,attchmentcount:0,imgHeight: 0.0,imgWidth: 0.0)
                                                }
                                                else if feed["title"] != nil {
                                                    imageUrl = ""
                                                    shareattachmentFeed(cell:cell,activityFeed: activityFeed,imageUrl:imageUrl,attchmentcount:0,imgHeight: 0.0,imgWidth: 0.0)
                                                }
                                                else{
                                                    dynamicHeight = 0
                                                    cell.customAlbumView.isHidden = true
                                                    cell.cntentShareFeedView.isHidden = true
                                                    cell.customAlbumView.frame.size.height = 0
                                                    cell.customAlbumView.frame.origin.y = getBottomEdgeY(inputView: cell.body) + 5
                                                    
                                                }
                                            }
                                        }
                                        else
                                        {
                                            dynamicHeight = 0
                                            cell.customAlbumView.isHidden = true
                                            cell.cntentShareFeedView.isHidden = true
                                            cell.customAlbumView.frame.size.height = 0
                                            cell.customAlbumView.frame.origin.y = getBottomEdgeY(inputView: cell.body) + 5
                                            
                                        }
                                    }
                                    break
                                case 1:
                                    var cardViewFeed = false
                                    var imageUrl = ""
                                    var height : CGFloat = 0
                                    var width : CGFloat = 0
                                    if let attachmentArray = activityFeed["attachment"] as? NSArray{
                                        
                                        if let feed = attachmentArray[0] as? NSDictionary
                                        {
                                            if let feedAttachmentType = feed["attachment_type"] as? String
                                            {
                                                if feedAttachmentType.range(of: "video") != nil{
                                                    cell.imgVideo.isHidden = false
                                                }
                                                else
                                                {
                                                    cell.imgVideo.isHidden = true
                                                }
                                                if feedAttachmentType.range(of: "_photo") != nil
                                                {
                                                    cardViewFeed = false
                                                }
                                                else
                                                {
                                                    cardViewFeed = true
                                                }
                                            }
                                            if let share_params_type = activityFeed["share_params_type"] as? String
                                            {
                                                if share_params_type.range(of: "_photo") != nil
                                                {
                                                    cardViewFeed = false
                                                }
                                                else
                                                {
                                                    cardViewFeed = true
                                                }
                                            }
                                            if let dic = feed["image_main"] as? NSDictionary
                                            {
                                                imageUrl = dic["src"] as? String ?? ""
                                                if let size = dic["size"] as? NSDictionary
                                                {
                                                    height = CGFloat(size["height"] as? Int ?? 0)
                                                    width = CGFloat(size["width"] as? Int ?? 0)
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                    }
                                    if cardViewFeed == true
                                    {
                                        shareattachmentFeed(cell:cell,activityFeed: activityFeed,imageUrl:imageUrl,attchmentcount:0,imgHeight: height,imgWidth: width)
                                        
                                    }
                                    else
                                    {
                                        cell.customAlbumView.isHidden = false
                                        cell.cntentShareFeedView.isHidden = true
                                        cell.bannerButton.isHidden = true
                                        cell.mapButton.isHidden = true
                                        cell.imageButton1.isHidden = false
                                        cell.imageButton2.isHidden = true
                                        cell.imageButton3.isHidden = true
                                        cell.imageButton4.isHidden = true
                                        cell.imageButton5.isHidden = true
                                        cell.imageButton6.isHidden = true
                                        cell.imageButton7.isHidden = true
                                        cell.imageButton8.isHidden = true
                                        cell.imageButton9.isHidden = true
                                        cell.imageViewWithText.isHidden = true
                                        
                                        cell.img_imageButton1.isHidden = false
                                        cell.img_mapButton.isHidden = true
                                        cell.img_bannerButton.isHidden = true
                                        cell.img_imageButton2.isHidden = true
                                        cell.img_imageButton3.isHidden = true
                                        cell.img_imageButton4.isHidden = true
                                        cell.img_imageButton5.isHidden = true
                                        cell.img_imageButton6.isHidden = true
                                        cell.img_imageButton7.isHidden = true
                                        cell.img_imageButton8.isHidden = true
                                        cell.img_imageButton9.isHidden = true
                                        
                                        //dynamicHeight = tempHeight + 10
                                        dynamicHeight = getBottomEdgeY(inputView: cell.customAlbumView)
                                        if imageUrl != ""
                                        {
                                            if (imageUrl.range(of: ".gif") != nil){
                                                cell.gifImageView.isHidden = false
                                            }else{
                                                cell.gifImageView.isHidden = true
                                            }
                                            let url = NSURL(string:imageUrl)
                                            cell.imageButton1.addTarget(self, action: #selector(FeedTableViewController.openSingleImage(sender:)), for: .touchUpInside)
                                            cell.imageButton1.tag = row
                                            
                                            if height !=  0
                                            {
                                                // Resize imageview according to fix width
                                                let resizeimage = imagesize(height: height,width: width, scaletoWidth: cell.imageButton1.frame.size.width)
                                                cell.imageButton1.frame = CGRect(x: ceil((cell.customAlbumView.frame.size.width - resizeimage.width)/2) ,y: 5,width: resizeimage.width ,height: resizeimage.height)
                                                cell.gifImageView.center = cell.imageButton1.center
                                                cell.customAlbumView.frame.size.height = cell.imageButton1.frame.size.height + 10
                                                self.dynamicHeight = cell.customAlbumView.frame.size.height
                                                
                                                cell.imageButton1.backgroundColor = .clear
                                                //  cell.img_imageButton1.kf.indicatorType = .activity
                                                //  (cell.img_imageButton1.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                                                cell.img_imageButton1.frame = cell.imageButton1.frame
                                                cell.img_imageButton1.kf.setImage(with: url! as URL, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                                    
                                                })
                                                
                                            }
                                            else
                                            {
                                                
                                                //let tempHeight = ceil(UIScreen.main.bounds.width)
                                                let tempHeight = ceil(UIScreen.main.bounds.width * 0.80)
                                                let ttheight = tempHeight-60
                                                cell.imageButton1.frame = CGRect(x: 0 ,y: 5,width: cell.frame.size.width ,height: ttheight)
                                                cell.customAlbumView.frame.size.height = cell.imageButton1.frame.size.height + 10
                                                //cell.imageButton1.setImage(img, for: .normal)
                                                cell.gifImageView.center = cell.imageButton1.center
                                                self.dynamicHeight = cell.customAlbumView.frame.size.height
                                                
                                                cell.imageButton1.backgroundColor = .clear
                                                // cell.img_imageButton1.kf.indicatorType = .activity
                                                // (cell.img_imageButton1.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                                                cell.img_imageButton1.frame = cell.imageButton1.frame
                                                cell.img_imageButton1.contentMode = .scaleAspectFill
                                                cell.img_imageButton1.clipsToBounds = true
                                                cell.img_imageButton1.kf.setImage(with: url! as URL, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                                    
                                                    
                                                    
                                                })
                                                
                                            }
                                        }
                                        
                                    }
                                    break
                                    
                                case 2:
                                    
                                    cell.customAlbumView.isHidden = false
                                    cell.cntentShareFeedView.isHidden = true
                                    cell.bannerButton.isHidden = true
                                    cell.mapButton.isHidden = true
                                    cell.imageButton1.isHidden = true
                                    cell.imageButton2.isHidden = false
                                    cell.imageButton3.isHidden = false
                                    cell.imageButton4.isHidden = true
                                    cell.imageButton5.isHidden = true
                                    cell.imageButton6.isHidden = true
                                    cell.imageButton7.isHidden = true
                                    cell.imageButton8.isHidden = true
                                    cell.imageButton9.isHidden = true
                                    
                                    cell.img_imageButton1.isHidden = true
                                    cell.img_mapButton.isHidden = true
                                    cell.img_bannerButton.isHidden = true
                                    cell.img_imageButton2.isHidden = false
                                    cell.img_imageButton3.isHidden = false
                                    cell.img_imageButton4.isHidden = true
                                    cell.img_imageButton5.isHidden = true
                                    cell.img_imageButton6.isHidden = true
                                    cell.img_imageButton7.isHidden = true
                                    cell.img_imageButton8.isHidden = true
                                    cell.img_imageButton9.isHidden = true
                                    
                                    
                                    cell.imageViewWithText.isHidden = true
                                    let tempHeight = ceil(cell.cellView.bounds.width * 0.65)
                                    cell.customAlbumView.frame.size.height = tempHeight + 10
                                    if imageUrlArray.count > 0 {
                                        if imageUrlArray[0] != ""
                                        {
                                            let imageUrl = imageUrlArray[0]
                                            if (imageUrl.range(of: ".gif") != nil){
                                                cell.gifImageView1.isHidden = false
                                                cell.gifImageView1.center = cell.imageButton2.center
                                            }else{
                                                cell.gifImageView1.isHidden = true
                                            }
                                            let url = NSURL(string:imageUrl)
                                            
                                            cell.imageButton2.backgroundColor = .clear
                                            // cell.img_imageButton2.kf.indicatorType = .activity
                                            // (cell.img_imageButton2.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                                            cell.img_imageButton2.frame = cell.imageButton2.frame
                                            cell.img_imageButton2.contentMode = .scaleAspectFill
                                            cell.img_imageButton2.clipsToBounds = true
                                            cell.img_imageButton2.kf.setImage(with: url! as URL, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                                
                                            })
                                            
                                            cell.imageButton2.addTarget(self, action:#selector(FeedTableViewController.firstPhotoClick(sender:)) , for: .touchUpInside)
                                            cell.imageButton2.tag = row
                                        }
                                        if imageUrlArray[1] != ""
                                        {
                                            let imageUrl = imageUrlArray[1]
                                            if (imageUrl.range(of: ".gif") != nil){
                                                cell.gifImageView2.isHidden = false
                                                cell.gifImageView2.center = cell.imageButton3.center
                                            }else{
                                                cell.gifImageView2.isHidden = true
                                            }
                                            let url = NSURL(string:imageUrl)
                                            cell.imageButton3.backgroundColor = .clear
                                            //                                            cell.img_imageButton3.kf.indicatorType = .activity
                                            //                                            (cell.img_imageButton3.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                                            cell.img_imageButton3.frame = cell.imageButton3.frame
                                            cell.img_imageButton3.contentMode = .scaleAspectFill
                                            cell.img_imageButton3.clipsToBounds = true
                                            cell.img_imageButton3.kf.setImage(with: url! as URL, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                                
                                            })
                                            
                                            cell.imageButton3.addTarget(self, action: #selector(FeedTableViewController.secondPhotoClick(sender:)) , for: .touchUpInside)
                                            cell.imageButton3.tag = row
                                        }
                                    }
                                    dynamicHeight = tempHeight + 10
                                    break
                                    
                                    
                                case 3:
                                    cell.customAlbumView.isHidden = false
                                    cell.cntentShareFeedView.isHidden = true
                                    cell.bannerButton.isHidden = true
                                    cell.mapButton.isHidden = true
                                    cell.imageButton1.isHidden = true
                                    cell.imageButton2.isHidden = true
                                    cell.imageButton3.isHidden = true
                                    cell.imageButton4.isHidden = false
                                    cell.imageButton5.isHidden = false
                                    cell.imageButton6.isHidden = false
                                    cell.imageButton7.isHidden = true
                                    cell.imageButton8.isHidden = true
                                    cell.imageButton9.isHidden = true
                                    
                                    cell.img_imageButton1.isHidden = true
                                    cell.img_mapButton.isHidden = true
                                    cell.img_bannerButton.isHidden = true
                                    cell.img_imageButton2.isHidden = true
                                    cell.img_imageButton3.isHidden = true
                                    cell.img_imageButton4.isHidden = false
                                    cell.img_imageButton5.isHidden = false
                                    cell.img_imageButton6.isHidden = false
                                    cell.img_imageButton7.isHidden = true
                                    cell.img_imageButton8.isHidden = true
                                    cell.img_imageButton9.isHidden = true
                                    
                                    cell.imageViewWithText.isHidden = true
                                    
                                    let tempHeight = ceil(cell.cellView.bounds.width * 0.8)
                                    cell.customAlbumView.frame.size.height = tempHeight + 10
                                    if imageUrlArray.count > 0 {
                                        if imageUrlArray[0] != "" {
                                            let imageUrl = imageUrlArray[0]
                                            if (imageUrl.range(of: ".gif") != nil){
                                                cell.gifImageView3.isHidden = false
                                                cell.gifImageView3.center = cell.imageButton4.center
                                            }else{
                                                cell.gifImageView3.isHidden = true
                                            }
                                            let url = NSURL(string:imageUrl)
                                            
                                            cell.imageButton4.backgroundColor = .clear
                                            //                                            cell.img_imageButton4.kf.indicatorType = .activity
                                            //                                            (cell.img_imageButton4.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                                            cell.img_imageButton4.frame = cell.imageButton4.frame
                                            cell.img_imageButton4.contentMode = .scaleAspectFill
                                            cell.img_imageButton4.clipsToBounds = true
                                            cell.img_imageButton4.kf.setImage(with: url! as URL, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                                
                                            })
                                            cell.imageButton4.addTarget(self, action: #selector(FeedTableViewController.firstPhotoClick(sender:)) , for: .touchUpInside)
                                            cell.imageButton4.tag = row
                                        }
                                        if imageUrlArray[1] != "" {
                                            let imageUrl = imageUrlArray[1]
                                            if (imageUrl.range(of: ".gif") != nil){
                                                cell.gifImageView4.isHidden = false
                                                cell.gifImageView4.center = cell.imageButton5.center
                                            }else{
                                                cell.gifImageView4.isHidden = true
                                            }
                                            let url = NSURL(string:imageUrl)
                                            
                                            cell.imageButton5.backgroundColor = .clear
                                            //                                            cell.img_imageButton5.kf.indicatorType = .activity
                                            //                                            (cell.img_imageButton5.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                                            cell.img_imageButton5.frame = cell.imageButton5.frame
                                            cell.img_imageButton5.contentMode = .scaleAspectFill
                                            cell.img_imageButton5.clipsToBounds = true
                                            cell.img_imageButton5.kf.setImage(with: url! as URL, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                                
                                            })
                                            cell.imageButton5.addTarget(self, action:#selector(FeedTableViewController.secondPhotoClick(sender:)) , for: .touchUpInside)
                                            cell.imageButton5.tag = row
                                        }
                                        if imageUrlArray[2] != "" {
                                            let imageUrl = imageUrlArray[2]
                                            if (imageUrl.range(of: ".gif") != nil){
                                                cell.gifImageView5.isHidden = false
                                                cell.gifImageView5.center = cell.imageButton6.center
                                            }else{
                                                cell.gifImageView5.isHidden = true
                                            }
                                            let url = NSURL(string:imageUrl)
                                            cell.imageButton6.backgroundColor = .clear
                                            //                                            cell.img_imageButton6.kf.indicatorType = .activity
                                            //                                            (cell.img_imageButton6.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                                            cell.img_imageButton6.frame = cell.imageButton6.frame
                                            cell.img_imageButton6.contentMode = .scaleAspectFill
                                            cell.img_imageButton6.clipsToBounds = true
                                            cell.img_imageButton6.kf.setImage(with: url! as URL, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                                
                                            })
                                            cell.imageButton6.addTarget(self, action: #selector(FeedTableViewController.thirdPhotoClick(sender:)) , for: .touchUpInside)
                                            cell.imageButton6.tag = row
                                        }
                                    }
                                    dynamicHeight = tempHeight + 10
                                    
                                    break
                                    
                                    
                                default:
                                    cell.customAlbumView.isHidden = false
                                    cell.cntentShareFeedView.isHidden = true
                                    cell.bannerButton.isHidden = true
                                    cell.mapButton.isHidden = true
                                    cell.imageButton1.isHidden = true
                                    cell.imageButton2.isHidden = true
                                    cell.imageButton3.isHidden = true
                                    cell.imageButton4.isHidden = true
                                    cell.imageButton5.isHidden = true
                                    cell.imageButton6.isHidden = true
                                    cell.imageButton7.isHidden = false
                                    cell.imageButton8.isHidden = false
                                    cell.imageButton9.isHidden = false
                                    
                                    cell.img_imageButton1.isHidden = true
                                    cell.img_mapButton.isHidden = true
                                    cell.img_bannerButton.isHidden = true
                                    cell.img_imageButton2.isHidden = true
                                    cell.img_imageButton3.isHidden = true
                                    cell.img_imageButton4.isHidden = true
                                    cell.img_imageButton5.isHidden = true
                                    cell.img_imageButton6.isHidden = true
                                    cell.img_imageButton7.isHidden = false
                                    cell.img_imageButton8.isHidden = false
                                    cell.img_imageButton9.isHidden = false
                                    
                                    cell.imageViewWithText.isHidden = false
                                    let tempHeight = ceil(cell.cellView.bounds.width * 0.8)
                                    cell.customAlbumView.frame.size.height = tempHeight + 10
                                    
                                    switch photosAttachmentCount {
                                    case 4:
                                        cell.countlabel.isHidden = true
                                        break
                                    default:
                                        cell.countlabel.isHidden = false
                                        cell.countlabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                                        let photoCount = photosAttachmentCount - 4
                                        cell.countlabel.text = "+\(photoCount)"
                                        break
                                    }
                                    if imageUrlArray.count > 0 {
                                        if imageUrlArray[0] != ""
                                        {
                                            let imageUrl = imageUrlArray[0]
                                            let url = NSURL(string:imageUrl)
                                            cell.imageButton7.backgroundColor = .clear
                                            //                                            cell.img_imageButton7.kf.indicatorType = .activity
                                            //                                            (cell.img_imageButton7.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                                            cell.img_imageButton7.frame = cell.imageButton7.frame
                                            cell.img_imageButton7.contentMode = .scaleAspectFill
                                            cell.img_imageButton7.clipsToBounds = true
                                            cell.img_imageButton7.kf.setImage(with: url! as URL, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                                
                                            })
                                            
                                            cell.imageButton7.addTarget(self, action: #selector(FeedTableViewController.firstPhotoClick(sender:)) , for: .touchUpInside)
                                            cell.imageButton7.tag = row
                                        }
                                        if imageUrlArray[1] != ""
                                        {
                                            let imageUrl = imageUrlArray[1]
                                            let url = NSURL(string:imageUrl)
                                            cell.imageButton8.backgroundColor = .clear
                                            //                                            cell.img_imageButton8.kf.indicatorType = .activity
                                            //                                            (cell.img_imageButton8.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                                            cell.img_imageButton8.frame = cell.imageButton8.frame
                                            cell.img_imageButton8.contentMode = .scaleAspectFill
                                            cell.img_imageButton8.clipsToBounds = true
                                            cell.img_imageButton8.kf.setImage(with: url! as URL, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                                
                                            })
                                            
                                            cell.imageButton8.addTarget(self, action:#selector(FeedTableViewController.secondPhotoClick(sender:)) , for: .touchUpInside)
                                            cell.imageButton8.tag = row
                                            
                                        }
                                        if imageUrlArray[2] != ""
                                        {
                                            let imageUrl = imageUrlArray[2]
                                            let url = NSURL(string:imageUrl)
                                            cell.imageButton9.backgroundColor = .clear
                                            //                                            cell.img_imageButton9.kf.indicatorType = .activity
                                            //                                            (cell.img_imageButton9.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                                            cell.img_imageButton9.frame = cell.imageButton9.frame
                                            cell.img_imageButton9.contentMode = .scaleAspectFill
                                            cell.img_imageButton9.clipsToBounds = true
                                            cell.img_imageButton9.kf.setImage(with: url! as URL, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                                
                                            })
                                            
                                            cell.imageButton9.addTarget(self, action:#selector(FeedTableViewController.thirdPhotoClick(sender:)) , for: .touchUpInside)
                                            cell.imageButton9.tag = row
                                        }
                                        if imageUrlArray[3] != ""
                                        {
                                            let imageUrl = imageUrlArray[3]
                                            let url = NSURL(string:imageUrl)
                                            
                                            //                                            cell.imageViewWithText.kf.indicatorType = .activity
                                            //                                            (cell.imageViewWithText.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                                            cell.imageViewWithText.contentMode = .scaleAspectFill
                                            cell.imageViewWithText.clipsToBounds = true
                                            cell.imageViewWithText.kf.setImage(with: url! as URL, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler: nil)
                                            
                                            
                                        }
                                    }
                                    cell.imageViewWithText.isUserInteractionEnabled = true
                                    let aTap = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewController.multiplePhotoClick(sender:)))
                                    aTap.cancelsTouchesInView = false
                                    cell.imageViewWithText.addGestureRecognizer(aTap)
                                    dynamicHeight = tempHeight + 10
                                    cell.imageViewWithText.tag = row
                                    
                                    break
                                }
                            }
                            else
                            {
                                cell.customAlbumView.isHidden = true
                                cell.customAlbumView.frame.size.height = 0
                                cell.customAlbumView.frame.origin.y = getBottomEdgeY(inputView: cell.body) + 5
                                dynamicHeight = 0.0
                                
                            }
                            if activityFeed["hashtags"] != nil
                            {
                                // Create Hashtag
                                createhashtag(row: row,cell: cell)
                            }
                            
                        }//Attachment and hashtag work End
                        
                        // Reaction and commentinfo work
                        cell.bannerTitle.isHidden = true
                        var bannerUrl = ""
                        var bannerbackgroundColor = ""
                        var bannertextColor = ""
                        if let params = activityFeed["params"] as? NSDictionary{
                            
                            if let feedBaner = params["feed-banner"] as? NSDictionary {
                                if feedBaner["feed_banner_url"] != nil {
                                    bannerUrl = feedBaner["feed_banner_url"] as! String
                                    bannerbackgroundColor = feedBaner["background-color"] as! String
                                    bannertextColor = feedBaner["color"] as! String
                                }
                                
                            }
                        }
                        if bannerUrl != "" || bannerbackgroundColor != "" {
                            cell.body.isHidden = true
                            cell.body.frame.size.height = 0
                            var check = bannerbackgroundColor
                            let _ = check.remove(at: (check.startIndex))
                            cell.bannerButton.isHidden = false
                            cell.bannerButton.backgroundColor = UIColor(hex: "\(check)")
                            cell.customAlbumView.frame.origin.y = originY
                            
                            cell.customAlbumView.isHidden = false
                            cell.cntentShareFeedView.isHidden = true
                            cell.mapButton.isHidden = true
                            cell.imageButton1.isHidden = true
                            cell.imageButton2.isHidden = true
                            cell.imageButton3.isHidden = true
                            cell.imageButton4.isHidden = true
                            cell.imageButton5.isHidden = true
                            cell.imageButton6.isHidden = true
                            cell.imageButton7.isHidden = true
                            cell.imageButton8.isHidden = true
                            cell.imageButton9.isHidden = true
                            
                            cell.img_imageButton1.isHidden = true
                            cell.img_mapButton.isHidden = true
                            cell.img_bannerButton.isHidden = false
                            cell.img_bannerButton.backgroundColor = UIColor(hex: "\(check)")
                            cell.img_imageButton2.isHidden = true
                            cell.img_imageButton3.isHidden = true
                            cell.img_imageButton4.isHidden = true
                            cell.img_imageButton5.isHidden = true
                            cell.img_imageButton6.isHidden = true
                            cell.img_imageButton7.isHidden = true
                            cell.img_imageButton8.isHidden = true
                            cell.img_imageButton9.isHidden = true
                            
                            cell.imageViewWithText.isHidden = true
                            let tempHeight = ceil(cell.cellView.bounds.width * 0.8)
                            cell.customAlbumView.frame.size.height = tempHeight + 10
                            cell.bannerButton.frame.size.height = tempHeight
                            self.dynamicHeight = cell.customAlbumView.frame.size.height
                            let _ = bannertextColor.remove(at: (bannertextColor.startIndex))
                            cell.bannerTitle.textColor = UIColor(hex: "\(bannertextColor)")
                            cell.bannerTitle.isHidden = false
                            cell.bannerTitle.delegate = self
                            
                            cell.bannerTitle.linkAttributes = [kCTForegroundColorAttributeName as AnyHashable : linkColor.cgColor,kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: true)]
                            cell.bannerTitle.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                            cell.bannerTitle.numberOfLines = 0
                            cell.bannerTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                            
                            cell.bannerTitle.setText(statusBody, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                let boldFont = CTFontCreateWithName((fontBold as CFString?)!, CGFloat(feedFontSize), nil)
                                
                                let range = (statusBody as NSString).range(of:statusBody)
                                
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                                
                                let boldFont1 = CTFontCreateWithName((fontBold as CFString?)!, CGFloat(fontSize), nil)
                                
                                let range2 = (statusBody as NSString).range(of:NSLocalizedString("See more",  comment: ""))
                                
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range2)
                                
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range2)
                                
                                let paragraphStyle = NSMutableParagraphStyle()
                                
                                // *** set LineSpacing property in points ***
                                paragraphStyle.lineSpacing = 2 // Whatever line spacing you want in points
                                paragraphStyle.alignment = NSTextAlignment.center
                                
                                // *** Apply attribute to string ***
                                mutableAttributedString?.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, (mutableAttributedString?.length)!))
                                
                                
                                
                                if let tags = activityFeed["userTag"] as? NSArray{
                                    if tags.count > 0{
                                        for i in 0 ..< tags.count {
                                            if let tag = ((tags[i] as! NSDictionary))["resource_name"] as? String{
                                                let length = mutableAttributedString?.length
                                                var range = NSMakeRange(0, length!)
                                                while(range.location != NSNotFound)
                                                {
                                                    range = (statusBody as NSString).range(of:tag, options: NSString.CompareOptions(), range: range)
                                                    if(range.location != NSNotFound) {
                                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range)
                                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                                                        range = NSMakeRange(range.location + range.length, length! - (range.location + range.length));
                                                        
                                                        
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                
                                
                                return mutableAttributedString
                            })
                            
                            cell.bannerTitle.sizeToFit()
                            //  cell.bannerTitle.frame.size.height = cell.body.bounds.height + 10
                            
                            cell.bannerTitle.frame.size.width = cell.contentImageView.bounds.width - 20
                            cell.bannerTitle.frame.size.height = cell.customAlbumView.frame.size.height - 10
                            cell.bannerTitle.textAlignment = NSTextAlignment.center
                            
                            
                            
                            DispatchQueue.global(qos: .default).async {
                                if addMoreDescription
                                {
                                    let range = (statusBody as NSString).range(of:NSLocalizedString("...See more",  comment: ""))
                                    cell.bannerTitle.addLink(toTransitInformation: ["id" : activityFeed["action_id"] as! Int, "type" : "more1","index" : row], with:range)
                                    
                                }
                                
                                
                                
                                if let tags = activityFeed["userTag"] as? NSArray{
                                    
                                    if tags.count > 0{
                                        
                                        
                                        for i in 0 ..< tags.count {
                                            
                                            
                                            if let tag = ((tags[i] as! NSDictionary))["resource_name"] as? String{
                                                let tag_id = ((tags[i] as! NSDictionary))["resource_id"] as? Int
                                                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\(statusBody)")
                                                let length = attrString.length
                                                var range = NSMakeRange(0, attrString.length)
                                                while(range.location != NSNotFound)
                                                {
                                                    range = (statusBody as NSString).range(of: tag, options: NSString.CompareOptions(), range: range)
                                                    if tag_id != nil {
                                                        if(range.location != NSNotFound) {
                                                            cell.bannerTitle.addLink(toTransitInformation: ["id" : tag_id!, "type" : "user"], with:range)
                                                            range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                                                            
                                                        }
                                                    }
                                                }
                                                
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            let imageUrl = URL(string: bannerUrl)
                            cell.bannerButton.backgroundColor = .clear
                            //                            cell.img_bannerButton.kf.indicatorType = .activity
                            //                            (cell.img_bannerButton.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                            cell.img_bannerButton.frame = cell.bannerButton.frame
                            cell.img_bannerButton.kf.setImage(with: imageUrl, placeholder: UIImage(named : ""), options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                
                            })
                            
                            
                        }
                        
                        reactionandlikeCommentInfo(row: row, cell: cell)
                        
                    }
                    
                }
            }
            self.dynamicRowHeight[activityFeed["action_id"] as? Int ?? 0] = self.dynamicHeight
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 11 {
            popover.dismiss()
            
            if globalArrayFeed.count > currentCell {
                if let feed = globalArrayFeed[currentCell] as? NSDictionary
                {
                    deleteFeed = false
                    menuOptionSelected = ""
                    var pinDays : Int = 0
                    if feed["pin_post_duration"] != nil {
                        pinDays = feed["pin_post_duration"] as! Int
                    }
                    if let feed_menu = feed["feed_menus"] as? NSArray{
                        let  menuItem = feed_menu[indexPath.row]
                        if let dic = menuItem as? NSDictionary {
                            self.menuOptionSelected = dic["name"] as? String ?? ""
                            if let d = dic["name"] as? String,d == "delete_feed"{
                                
                                // Confirmation Alert for Delete Feed
                                displayAlertWithOtherButton(NSLocalizedString("Delete Activity Item?", comment: "") ,message: NSLocalizedString("Are you sure that you want to delete this activity item? This action cannot be undone.", comment: "") ,otherButton: NSLocalizedString("Delete", comment: ""), otherButtonAction: { () -> () in
                                    self.deleteFeed = true
                                    // Update Feed Gutter Menu
                                    self.updateFeedMenu(parameter: dic["urlParams"] as! NSDictionary, url:dic["url"] as! String,feedIndex: self.currentCell)
                                })
                                self.present(alert, animated: true, completion: nil)
                            }
                            else if let d = dic["name"] as? String,d == "edit_feed"{
                                
                                var body_t :  String!
                                var statusBody : String = ""
                                
                                if  let body_param = feed["action_type_body_params"] as? NSArray{
                                    for i in 0 ..< body_param.count {
                                        if let body1 = body_param[i] as? NSDictionary
                                        {
                                            if let str = body1["search"] as? String, str == "{body:$body}"{
                                                if ( body1["label"] is String){
                                                    body_t =   body1["label"] as? String ?? ""
                                                    //  body_t = body_t.replacingOccurrences(of: "\n", with: "<br/>")
                                                    
                                                    body_t = body_t.replacingOccurrences(of: "<br />", with: "\n")
                                                    //body_t = body_t.html2String as String
                                                    
                                                }
                                                statusBody = body_t
                                                
                                            }
                                        }
                                        
                                    }
                                }
                                
                                let presentedVC = AdvancePostFeedViewController()//EditFeedViewController()
                                presentedVC.editFeedDict = globalArrayFeed[currentCell] as! NSDictionary
                                presentedVC.editBody = statusBody
                                presentedVC.editId   =  feed["action_id"] as? Int ?? 0
                                presentedVC.activityfeedIndex = currentCell
                                
                                presentedVC.attachmentCount = (feed["attactment_Count"] as? Int)!
                                
                                //       notScroll = true
                                //                        if let  obj = self.parent as? ContentActivityFeedViewController {
                                //                            obj.notScroll = true
                                //                        }
                                presentedVC.isEditFeed = true
                                
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                // self.navigationController?.pushViewController(presentedVC, animated: false)
                            }
                                
                            else if dic["name"] as! String == "feed_link"{
                                
                                UIPasteboard.general.string = "\(dic["feed_link"] as! String)"
                                showToast(message: NSLocalizedString("Link copied to clipboard", comment: ""), controller: self, onView: false, time: 2.0)
                                
                            }
                            else if dic["name"] as! String == "pin_post"{
                                
                                var userIdTextField: UITextField?
                                
                                // Declare Alert message
                                let dialogMessage = UIAlertController(title: "Set Pin Reset Time", message: "Please enter number of days less than or equal to \(pinDays) after which pin will automatically set to unpin", preferredStyle: .alert)
                                
                                // Create OK button with action handler
                                let ok = UIAlertAction(title: "Pin", style: .default, handler: { (action) -> Void in
                                    //print("Ok button tapped")
                                    
                                    if let userInput = userIdTextField!.text {
                                        if userInput != "" {
                                            //print("User entered \(userInput)")
                                            self.enterdPinDays = Int(userInput)!
                                        }
                                        else{
                                            showToast(message: "Please Enter Number Of Days", controller: self)
                                        }
                                    }
                                    
                                    
                                    self.updateFeedMenu(parameter: dic["urlParams"] as! NSDictionary, url:dic["url"] as! String,feedIndex: self.currentCell)
                                })
                                
                                // Create Cancel button with action handlder
                                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                                    //print("Cancel button tapped")
                                }
                                
                                //Add OK and Cancel button to dialog message
                                dialogMessage.addAction(ok)
                                dialogMessage.addAction(cancel)
                                
                                // Add Input TextField to dialog message
                                dialogMessage.addTextField { (textField) -> Void in
                                    
                                    userIdTextField = textField
                                    userIdTextField?.placeholder = "Please Enter Number Of Days"
                                }
                                
                                // Present dialog message to user
                                self.present(dialogMessage, animated: true, completion: nil)
                                
                            }
                            else{
                                if let d = dic["name"] as? String, d == "hits_feed"{
                                    // Reset variable for Hard Refresh
                                    self.deleteFeed = true
                                    self.maxid = 0
                                }
                                // Update Feed Gutter Menu
                                self.updateFeedMenu(parameter: dic["urlParams"] as! NSDictionary, url:dic["url"] as! String,feedIndex: currentCell)
                            }
                        }
                    }
                }
            }
        }
        var row = (indexPath as NSIndexPath).row as Int
        if (kFrequencyAdsInCells_feeds > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_feeds) == (kFrequencyAdsInCells_feeds)-1))
        {
            
            if let cell = tableView.cellForRow(at: indexPath) as? NativeAdinstallFeedCell {
                cell.selectionStyle = .none
                
                cell.backgroundColor = .clear
                
                if muteVideo == true
                {
                    muteVideo = false
                    shared1.muteVideosFor(tableView: self.tableView)
                    cell.btnMuteUnMuteIcon.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                    //sender.setTitle("\(unMuteIconIcon)", for: .normal)
                }
                else
                {
                    muteVideo = true
                    shared1.muteVideosFor(tableView: self.tableView)
                    cell.btnMuteUnMuteIcon.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
                    //sender.setTitle("\(muteVideoIcon)", for: .normal)
                }
            }
        }
        
    }
    //Redirect on map
    @objc func mapRedirection(sender:UIButton)
    {
        if  let activityFeed = globalArrayFeed[sender.tag] as? NSDictionary
        {
            if let params = activityFeed["params"] as? NSDictionary{
                if params.count > 0{
                    if let checkIn = params["checkin"] as? NSDictionary{
                        let presentedVC = MapViewController()
                        presentedVC.location = checkIn["label"] as? String ?? ""
                        presentedVC.place_id = checkIn["place_id"] as? String ?? ""
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                    }
                    
                }
                
            }
        }
    }
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if tableViewFrameType != "CommentsViewController"
        {
            // videoPauseIcon()
            if NotPlay != 1 {
                self.pausePlayeVideos()
            }
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if tableViewFrameType != "CommentsViewController"
            {
                //videoPauseIcon()
                if NotPlay != 1 {
                    self.pausePlayeVideos()
                }
            }
        }
    }
    
    func videoPauseIcon() {
        let visisbleCells = self.tableView.visibleCells
        var maxHeight: CGFloat = 0.0
        var selectedCell : AAFActivityFeedTableViewCell?
        for cellView in visisbleCells {
            guard let containerCell = cellView as? AutoPlayVideoLayerContainer,
                let videoCellURL = containerCell.videoURL else {
                    continue
            }
            let height = containerCell.visibleVideoHeight()
            if maxHeight < height {
                maxHeight = height
                selectedCell = containerCell as? AAFActivityFeedTableViewCell
            }
        }
        selectedCell?.imgReplayVideo.isHidden = true
        selectedCell?.lblReplayVideo.isHidden = true
        selectedCell?.imgVideo.isHidden = true
        
    }
    
    func pausePlayeVideos(){
        if tableViewFrameType != "CommentsViewController"
        {
            if targetCheckValueAAF != 1
            {
                shared1.pausePlayeVideosFor(tableView: tableView)
                
                if isVideoReplyIconVisible() == false
                {
                    sharedVideoPlayer.pausePlayeVideosFor(tableView: tableView)
                }
            }
        }
    }
    
    @objc func appEnteredFromBackground() {
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
    }
    @objc func appMovedToBackground() {
        self.shared1.pauseVideosFor(tableView: self.tableView)
        self.sharedVideoPlayer.pauseVideosFor(tableView: self.tableView)
        self.taskVideoPlayPause?.cancel()
        
        let visisbleCells = self.tableView.visibleCells
        var maxHeight: CGFloat = 0.0
        var selectedCell : AAFActivityFeedTableViewCell?
        for cellView in visisbleCells {
            guard let containerCell = cellView as? AutoPlayVideoLayerContainer,
                let videoCellURL = containerCell.videoURL else {
                    continue
            }
            let height = containerCell.visibleVideoHeight()
            if maxHeight < height {
                maxHeight = height
                selectedCell = containerCell as? AAFActivityFeedTableViewCell
            }
        }
        selectedCell?.viewVideo.isHidden = false
        selectedCell?.imgReplayVideo.isHidden = true
        selectedCell?.lblReplayVideo.isHidden = true
        selectedCell?.imgVideo.isHidden = true
        
    }
    func updateTikTokPlayer(videoURL: String, currentTime: Double, timeScale: CMTimeScale) {
        
        sharedVideoPlayer.videoURL = videoURL
        let currentPlayer = sharedVideoPlayer.currentVideoContainer()?.player
        let time = CMTimeMakeWithSeconds(currentTime, preferredTimescale: timeScale)
        currentPlayer?.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { (finiesh) in
            do {
                //                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.mixWithOthers)
            }
            catch {
                // report for an error
            }
            currentPlayer?.play()
            
        })
    }
    
    func updateTableAfterVideoRemoval(videoId : Int) {
        for (index,feed) in globalArrayFeed.enumerated()
        {
            if let activityFeed = feed as? NSDictionary
            {
                if let attachment = activityFeed["attachment"] as? NSArray
                {
                    if attachment.count != 0
                    {
                        let attechmentDic = attachment[0] as! NSDictionary
                        if let attachment_id = attechmentDic["attachment_id"] as? Int
                        {
                            if attachment_id == videoId
                            {
                                globalArrayFeed.remove(at: index)
                            }
                        }
                    }
                }
            }
        }
        self.tableView.reloadData()
    }
    
    @objc func videoCompletion() {
        let visisbleCells = self.tableView.visibleCells
        var maxHeight: CGFloat = 0.0
        var selectedCell : AAFActivityFeedTableViewCell?
        for cellView in visisbleCells {
            guard let containerCell = cellView as? AutoPlayVideoLayerContainer,
                let videoCellURL = containerCell.videoURL else {
                    continue
            }
            let height = containerCell.visibleVideoHeight()
            if maxHeight < height {
                maxHeight = height
                selectedCell = containerCell as? AAFActivityFeedTableViewCell
            }
        }
        selectedCell?.viewVideo.isHidden = true
        selectedCell?.imgReplayVideo.isHidden = false
        selectedCell?.lblReplayVideo.isHidden = false
        selectedCell?.imgVideo.isHidden = true
        shared1.currentVideoContainer()?.playOn = true
        if NotPlay != 1 {
            self.pausePlayeVideos()
        }
        
    }
    
    func isVideoReplyIconVisible() -> Bool
    {
        let visisbleCells = self.tableView.visibleCells
        var maxHeight: CGFloat = 0.0
        var selectedCell : AAFActivityFeedTableViewCell?
        for cellView in visisbleCells {
            guard let containerCell = cellView as? AutoPlayVideoLayerContainer,
                let videoCellURL = containerCell.videoURL else {
                    continue
            }
            let height = containerCell.visibleVideoHeight()
            if maxHeight < height {
                maxHeight = height
                selectedCell = containerCell as? AAFActivityFeedTableViewCell
            }
        }
        selectedCell?.imgVideo.isHidden = true
        if selectedCell?.imgReplayVideo.isHidden == false
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        currentOffset = scrollView.contentOffset.y
        maxOffset = scrollView.contentSize.height
        scrollViewheight = scrollView.frame.size.height
        // self.pausePlayeVideos()
        scrollopoint = scrollView.contentOffset
        
        //        print("currentOffset ---> ",currentOffset)
        //        print("maxOffset ---> ",maxOffset)
        
        switch tableViewFrameType {
        case "ContentFeedViewController":
            let obj = NotificationCenter.default
            obj.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionContentFeed"), object: nil)
            
            break
        case "Pages":
            let obj1 = NotificationCenter.default
            obj1.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionPage"), object: nil)
            break
        case "advGroup":
            let obj1 = NotificationCenter.default
            obj1.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionAdvGroup"), object: nil)
            break
            
        case "HashTagFeedViewController":
            let obj = NotificationCenter.default
            obj.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionHashTagFeed"), object: nil)
            break
        case "ContentActivityFeedViewController":
            let obj = NotificationCenter.default
            obj.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionContentActivityFeed"), object: nil)
            break
        case "AdvanceActivityFeedViewController":
            delegateScroll?.didScroll()
            //let obj = NotificationCenter.default
            //obj.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionAdvanceActivityFeed"), object: nil)
            break
        case "FeedViewPageViewController":
            let obj = NotificationCenter.default
            obj.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionFeedViewPage"), object: nil)
            break
        case "MLTBlogTypeViewController":
            let obj = NotificationCenter.default
            obj.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionMLTBlogType"), object: nil)
            break
        case "MLTClassifiedSimpleTypeViewController":
            let obj = NotificationCenter.default
            obj.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionMLTClassifiedSimpleType"), object: nil)
            break
        case "MLTClassifiedAdvancedTypeViewController":
            let obj = NotificationCenter.default
            obj.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionMLTClassifiedAdvancedType"), object: nil)
            break
            
        case "ChannelProfileViewController":
            let obj = NotificationCenter.default
            obj.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionAdvVideoChannel"), object: nil)
            break
            
        default:
            break
        }
    }
    // MARK: - Share image attachment work
    func shareattachmentFeed(cell:AAFActivityFeedTableViewCell,activityFeed:NSDictionary,imageUrl :String,attchmentcount:Int,imgHeight:CGFloat,imgWidth:CGFloat)
    {
        cell.cntentShareFeedView.frame.origin.y = getBottomEdgeY(inputView: cell.body) + 5
        cell.customAlbumView.isHidden = true
        cell.cntentShareFeedView.isHidden = false
        cell.customAlbumView.frame.size.height = 0
        var attachment_title = ""
        var attachment_description = ""
        var attachment_type = ""
        var imgVideoOverLay = ""
        if let attachmentArray = activityFeed["attachment"] as? NSArray
        {
            
            if let feed = attachmentArray[0] as? NSDictionary{
                if let attachmetTitle = feed["title"]{
                    attachment_title = String(describing: attachmetTitle)
                }
                if let attachmentType = feed["attachment_type"] {
                    attachment_type =  String(describing: attachmentType)
                }
                
                if let attachmentBody = feed["body"]{
                    attachment_description = String(describing: attachmentBody)
                    attachment_description = Emoticonizer.emoticonizeString("\(attachment_description)" as NSString) as String
                }
                if let dicVideoOverlay = feed["video_overlay_image"] as? NSDictionary, let urlOverlay = dicVideoOverlay["url"] as? String{
                    imgVideoOverLay = urlOverlay
                }
            }
        }
        
        
        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\(attachment_title)")
        let boldFont = CTFontCreateWithName((fontBold as CFString?)!, FONTSIZENormal, nil)
        attrString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSMakeRange(0, attrString.length))
        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, attrString.length))
        
        if attachment_description != ""
        {
            let descString: NSMutableAttributedString = NSMutableAttributedString(string:  String("\n\n\(attachment_description)"))
            descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZENormal)!, range: NSMakeRange(0, descString.length))
            attrString.append(descString);
        }
        cell.contentAttributedLabel.attributedText = attrString
        var totalheight = attrString.height(withConstrainedWidth: cell.contentAttributedLabel.frame.size.width)
        cell.contentAttributedLabel.numberOfLines = 5
        cell.contentAttributedLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        if totalheight > 100
        {
            totalheight = 100
        }
        
        if attachment_title == "" && attachment_description == ""{
            cell.contentAttributedLabel.isHidden = true
            cell.contentAttributedLabel.frame.size.height = 0
            
        }
        else
        {
            cell.contentAttributedLabel.isHidden = false
            cell.contentAttributedLabel.frame.size.height = totalheight
            
        }
        // dynamicHeight = tempHeight + 10
        var image = UIImage()
        if attchmentcount == 1
        {
            image = placeholderImage
        }
        else
        {
            image = placeholderImage
            
        }
        if imgVideoOverLay != ""
        {
            let url = NSURL(string:imgVideoOverLay)
            if let urlT = url as URL?
            {
                //                cell.imgViewOverLay.kf.indicatorType = .activity
                //                (cell.imgViewOverLay.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                cell.imgViewOverLay.kf.setImage(with: urlT, placeholder: image, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
            }
            
        }
        else
        {
            cell.imgViewOverLay.image = UIImage(named: "")
        }
        if imageUrl != ""
        {
            let url = NSURL(string:imageUrl)
            
            // Download Image from Server
            if imgHeight !=  0
            {
                // Resize imageview according to fix width
                let resizeimage = imagesize(height: imgHeight,width: imgWidth, scaletoWidth: cell.contentImageView.frame.size.width)
                cell.contentImageView.frame = CGRect(x: ceil((cell.cntentShareFeedView.frame.size.width - resizeimage.width)/2) ,y: 0,width: resizeimage.width ,height: resizeimage.height)
                if refreshLikeUnLike == true
                {
                    cell.contentImageView.isHidden = false
                    //                    cell.contentImageView.kf.indicatorType = .activity
                    //                    (cell.contentImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImageView.kf.setImage(with: url! as URL, placeholder: image, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        DispatchQueue.main.async {
                            if let imageT = image
                            {
                                let resizeimage = imageWithImage1(imageT, newHeight: resizeimage.height, newwidth: resizeimage.width)
                                cell.contentImageView.image = resizeimage
                            }
                        }
                    })
                }
                if cell.imgVideo.isHidden == false
                {
                    cell.imgReplayVideo.center = cell.contentImageView.center
                    cell.lblReplayVideo.center = CGPoint(x: cell.imgReplayVideo.center.x, y: cell.imgReplayVideo.center.y + 35)
                    cell.imgVideo.center = cell.contentImageView.center
                    cell.viewVideo.frame = cell.contentImageView.frame
                    cell.imgViewOverLay.frame = cell.contentImageView.frame
                }
                
            }
            else
            {
                let tempHeight = ceil(UIScreen.main.bounds.width * 0.80)
                cell.cntentShareFeedView.frame.size.height = tempHeight + 10
                cell.contentImageView.frame.size.height = tempHeight - 60
                cell.contentImageView.contentMode = .scaleToFill
                if attachment_type == "sitestoreproduct_product" || attachment_type == "sitereaction_sticker"{
                    cell.contentImageView.contentMode = .scaleAspectFit
                }
                let tempWidth = Double(cell.contentImageView.bounds.width)
                let ttheight = Double(tempHeight - 60)
                if let urlT = url as URL?
                {
                    //                    cell.contentImageView.kf.indicatorType = .activity
                    //                    (cell.contentImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                    cell.contentImageView.isHidden = false
                    cell.contentImageView.kf.setImage(with: urlT, placeholder: image, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        DispatchQueue.main.async {
                            if let imageT = image
                            {
                                cell.contentImageView.image = cropToBounds(imageT, width: tempWidth, height: ttheight)
                                // cell.layoutIfNeeded()
                            }
                        }
                    })
                }
                if cell.imgVideo.isHidden == false
                {
                    cell.imgReplayVideo.center = cell.contentImageView.center
                    cell.lblReplayVideo.center = CGPoint(x: cell.imgReplayVideo.center.x, y: cell.imgReplayVideo.center.y - 30)
                    cell.imgVideo.center = cell.contentImageView.center
                    cell.viewVideo.frame = cell.contentImageView.frame
                    cell.imgViewOverLay.frame = cell.contentImageView.frame
                }
            }
            
        }
        else
        {
            cell.contentAttributedLabel.frame.origin.y = 0
            cell.contentImageView.frame.size.height = 0
            cell.contentImageView.isHidden = true
        }
        
        
        if (imageUrl.range(of: ".gif") != nil)
        {
            cell.gifImageViewShare.isHidden = false
            cell.gifImageViewShare.center = cell.contentImageView.center
        }
        else
        {
            cell.gifImageViewShare.isHidden = true
        }
        cell.contentAttributedLabel.frame.origin.y = getBottomEdgeY(inputView: cell.contentImageView) + 5
        cell.cntentShareFeedView.frame.size.height = cell.contentImageView.frame.size.height + cell.contentAttributedLabel.frame.size.height + 10
        self.dynamicHeight = cell.cntentShareFeedView.frame.size.height
        cell.cntentShareFeedView.frame.size.height = dynamicHeight
        let aTap = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewController.tappedContent(sender:)))
        aTap.cancelsTouchesInView = false
        cell.cntentShareFeedView.addGestureRecognizer(aTap)
    }
    
    // MARK: - Hashtag work
    func createhashtag(row:Int,cell:AAFActivityFeedTableViewCell)
    {
        cell.bodyHashtaglbl.isHidden = false
        let activityFeed = globalArrayFeed[row] as! NSDictionary
        var hashtagString : String! = ""
        let hashtags = activityFeed["hashtags"] as! NSArray
        hashtagString = hashtags.componentsJoined(by: " ")
        
        let originY:CGFloat = cell.body.frame.origin.y + cell.body.bounds.height + 5
        cell.bodyHashtaglbl.frame.origin.y = originY + dynamicHeight + 10
        cell.bodyHashtaglbl.font = UIFont(name: fontBold, size: FONTSIZENormal)
        cell.bodyHashtaglbl.delegate = self
        cell.bodyHashtaglbl.text = hashtagString
        cell.bodyHashtaglbl.numberOfLines = 0
        cell.bodyHashtaglbl.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.bodyHashtaglbl.sizeToFit()
        cell.bodyHashtaglbl.frame.size.width = cell.cellView.bounds.width - 20
        if hashtags.count > 0
        {
            DispatchQueue.global(qos: .userInitiated).async {
                for i in 0 ..< hashtags.count {
                    let range2 = (hashtagString as NSString).range(of: NSLocalizedString("\(hashtags[i])",  comment: ""))
                    cell.bodyHashtaglbl.addLink(toTransitInformation: [ "type" : "hashtags", "hashtagString" : "\(hashtags[i])"], with:range2)
                }
                DispatchQueue.main.async {
                    
                }
            }
            
        }
        dynamicHeight = dynamicHeight  + cell.bodyHashtaglbl.bounds.height + 15
    }
    
    // MARK: - Reaction and comment info work
    func reactionandlikeCommentInfo(row:Int,cell:AAFActivityFeedTableViewCell)
    {
        let activityFeed = globalArrayFeed[row] as! NSDictionary
        var infoTitle = ""
        var commentTitle = ""
        cell.likeCommentInfo.setTitle("", for: .normal)
        cell.borderView.isHidden = true
        cell.scheduleFeedLabel.isHidden = true
        
        for ob in (cell.cellMenu.subviews){
            ob.removeFromSuperview()
        }
        for ob in (cell.reactionsInfo.subviews){
            ob.removeFromSuperview()
        }
        if ReactionPlugin == false
        {
            commentTitle = ""
            cell.reactionsInfo.isHidden = true
            cell.commentInfo.isHidden = true
            cell.borderView.isHidden = true
            if activityFeed["comment"] as? Bool == true{
                // Like Comment Information for FEED
                if let likes  = activityFeed["likes_count"] as? Int
                {
                    if likes > 1
                    {
                        infoTitle =  String(format: NSLocalizedString("%d Likes ", comment: ""),likes)
                    }
                    else if likes == 1
                    {
                        infoTitle =  String(format: NSLocalizedString("%d Like ", comment: ""),likes)
                    }
                }
                if let comments  = activityFeed["comment_count"] as? Int
                {
                    if comments > 1
                    {
                        infoTitle += String(format: NSLocalizedString(" %d Comments", comment: ""),comments)
                    }
                    else if comments == 1
                    {
                        infoTitle += String(format: NSLocalizedString(" %d Comment", comment: ""),comments)
                    }
                }
                if infoTitle != ""
                {
                    cell.likeCommentInfo.isHidden = false
                    cell.borderView.isHidden = false
                    let originY:CGFloat = cell.body.frame.origin.y + cell.body.bounds.height + 5
                    if dynamicHeight != 0
                    {
                        
                        cell.likeCommentInfo.frame.origin.y = dynamicHeight + originY + 5
                        cell.borderView.frame.origin.y = dynamicHeight + originY + 5 + 35
                        
                    }
                    else
                    {
                        cell.likeCommentInfo.frame.origin.y =  originY + 5
                        cell.borderView.frame.origin.y =  originY + 5 + 35
                    }
                    cell.likeCommentInfo.contentHorizontalAlignment = .left
                    cell.likeCommentInfo.setTitle("\(infoTitle)", for: .normal)
                    cell.likeCommentInfo.tag = row
                    cell.likeCommentInfo.addTarget(self, action:#selector(FeedTableViewController.likeCommentInfo(_:)) , for: .touchUpInside)
                    
                }
                else
                {
                    cell.likeCommentInfo.isHidden = true
                    cell.borderView.isHidden = true
                }
            }
            else
            {
                noCommentMenu = true
            }
        }
        else
        {
            if activityFeed["comment"] as? Bool == true
            {
                ////print(activityFeed)
                if let reactions = activityFeed["feed_reactions"] as? NSDictionary{
                    
                    cell.reactionsInfo.isHidden = false
                    var menuWidth = CGFloat()
                    var origin_x:CGFloat = 5.0
                    var i : Int = 0
                    for (_,value) in reactions
                    {
                        if let reaction = value as? NSDictionary{
                            if i <= 2
                            {
                                if (reaction["reaction_image_icon"] as? String) != nil{
                                    menuWidth = 15
                                    let   emoji = createButton(CGRect(x: origin_x ,y: 5,width: menuWidth,height: 20), title: "", border: false, bgColor: false, textColor: textColorLight)
                                    emoji.imageEdgeInsets =  UIEdgeInsets(top: 4, left: 0, bottom: 1, right: 0)
                                    let imageUrl = reaction["reaction_image_icon"] as? String
                                    let url = NSURL(string:imageUrl!)
                                    
                                    if url != nil
                                    {
                                        
                                        emoji.kf.setImage(with: url! as URL, for: .normal, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                            
                                            
                                        })
                                        
                                    }
                                    emoji.tag = row
                                    emoji.addTarget(self, action:#selector(FeedTableViewController.likeCommentInfo(_:)) , for: .touchUpInside)
                                    cell.reactionsInfo.addSubview(emoji)
                                    origin_x += (menuWidth) + 2
                                    i = i + 1
                                    
                                }
                                
                            }
                        }
                        
                    }
                    cell.reactionsInfo.tag = row
                    cell.reactionsInfo.frame.size.width = origin_x
                    cell.likeCommentInfo.frame.origin.x = (cell.reactionsInfo.frame.size.width) + (cell.reactionsInfo.frame.origin.x) + 2
                }
                else
                {
                    cell.likeCommentInfo.frame.origin.x = 5
                    cell.reactionsInfo.isHidden = true
                    cell.commentInfo.isHidden = true
                    
                }
                
                if let d = activityFeed["is_like"] as? Bool, d == true
                {
                    if let likes  = activityFeed["likes_count"] as? Int
                    {
                        switch likes {
                        case 0:
                            break
                        case 1:
                            infoTitle =  String(format: NSLocalizedString("You reacted on this", comment: ""),likes)
                            break
                        case 2:
                            infoTitle =  String(format: NSLocalizedString(" You and %d other reacted ", comment: ""),likes - 1)
                            break
                        default:
                            infoTitle =  String(format: NSLocalizedString(" You and %d others reacted ", comment: ""),likes - 1)
                            break
                        }
                    }
                    
                }
                else
                {
                    if let likes  = activityFeed["likes_count"] as? Int{
                        if likes >= 1{
                            infoTitle =  String(format: NSLocalizedString("%@ ", comment: ""), suffixNumber(number: likes))
                        }
                    }
                    
                }
                if infoTitle != ""{
                    
                    cell.likeCommentInfo.isHidden = false
                    cell.borderView.isHidden = false
                    let originY:CGFloat = (cell.body.frame.origin.y) + (cell.body.bounds.height) + 5
                    switch dynamicHeight {
                    case 0:
                        cell.likeCommentInfo.frame.origin.y =  originY + 5
                        cell.borderView.frame.origin.y = originY + 5 + 35
                        cell.reactionsInfo.frame.origin.y = originY + 5
                        break
                        
                    default:
                        cell.likeCommentInfo.frame.origin.y = dynamicHeight + originY + 5
                        cell.borderView.frame.origin.y = dynamicHeight + originY + 5 + 35
                        cell.reactionsInfo.frame.origin.y = dynamicHeight + originY + 5
                        break
                    }
                    cell.likeCommentInfo.contentHorizontalAlignment = .left
                    cell.likeCommentInfo.setTitle("\(infoTitle)", for: .normal)
                    cell.likeCommentInfo.tag = row
                    cell.likeCommentInfo.addTarget(self, action:#selector(FeedTableViewController.likeCommentInfo(_:)) , for: .touchUpInside)
                    
                }
                else
                {
                    cell.likeCommentInfo.isHidden = true
                    cell.reactionsInfo.isHidden = true
                    cell.borderView.isHidden = true
                }
                
                if let comments  = activityFeed["comment_count"] as? Int{
                    switch comments {
                    case 0: break
                        
                    case 1:
                        commentTitle += String(format: NSLocalizedString(" %@ Comment", comment: ""),suffixNumber(number: comments))
                        break
                    default:
                        commentTitle += String(format: NSLocalizedString(" %@ Comments", comment: ""),suffixNumber(number: comments))
                        break
                    }
                    
                }
                
                if commentTitle != ""{
                    
                    
                    if tableViewFrameType != "CommentsViewController"
                    {
                        
                        cell.commentInfo.isHidden = false
                        cell.borderView.isHidden = false
                        
                    }
                    let originY:CGFloat = (cell.body.frame.origin.y) + (cell.body.bounds.height) + 5
                    switch dynamicHeight {
                    case 0:
                        cell.commentInfo.frame.origin.y =  originY + 5
                        cell.borderView.frame.origin.y =  originY + 5 + 35
                        break
                        
                    default:
                        cell.commentInfo.frame.origin.y = dynamicHeight + originY + 5
                        cell.borderView.frame.origin.y = dynamicHeight + originY + 5 + 35
                        break
                    }
                    cell.commentInfo.setTitle("\(commentTitle)", for: .normal)
                    cell.commentInfo.tag = row
                    cell.commentInfo.addTarget(self, action:#selector(FeedTableViewController.commentAction(_:)) , for: .touchUpInside)
                    
                }
                else
                {
                    cell.commentInfo.isHidden = true
                    
                }
                
            }
            else
            {
                noCommentMenu = true
            }
        }
        if let feed_menu = activityFeed["feed_footer_menus"] as? NSDictionary{
            
            if infoTitle != "" {
                cell.cellMenu.frame.origin.y = (cell.likeCommentInfo.frame.origin.y) + (cell.likeCommentInfo.bounds.height) + 15
            }
            if commentTitle != "" {
                cell.cellMenu.frame.origin.y = (cell.commentInfo.frame.origin.y) + (cell.commentInfo.bounds.height) + 15
            }
            else if infoTitle == "" && commentTitle == "" {
                let originY:CGFloat = (cell.body.frame.origin.y) + (cell.body.bounds.height) + 5
                switch dynamicHeight {
                case 0:
                    cell.cellMenu.frame.origin.y =  originY + 15
                    break
                    
                default:
                    cell.cellMenu.frame.origin.y = dynamicHeight + originY + 15
                    break
                }
                
            }
            // Set the sequence for Menu
            var menuSequence = [String]()
            var menuCount = 0
            if activityFeed["comment"] as? Bool == true{
                menuCount = menuCount + 2
                menuSequence = menuSequence + ["like"]
            }
            if activityFeed["share"] as? Bool == true{
                menuCount = menuCount + 1
                menuSequence = menuSequence + ["share"]
            }
            
            // Find out the Menu Width
            let menuItemWidth:CGFloat = (cell.cellView.bounds.width - 40)/CGFloat(menuCount)
            var origin_x:CGFloat = 0
            for menu in menuSequence{
                var title = ""
                var icon = ""
                var textcolor : UIColor
                switch(menu){
                case "like":
                    
                    if feed_menu["like"] != nil{
                        for i in 0 ..< 2  {
                            if i==0{
                                if let d = activityFeed["is_like"] as? Bool,d == true{
                                    icon = "thumbs_up"
                                    if ReactionPlugin == true{
                                        if let myReaction = activityFeed["my_feed_reaction"] as? NSDictionary{
                                            let titleReaction = myReaction["caption"] as? String ?? ""
                                            title =  NSLocalizedString("\(titleReaction)", comment: "")
                                            if let myIcon = myReaction["reaction_image_icon"] as? String{
                                                var ImageView: UIButton!
                                                if menuCount == 2 {
                                                    
                                                    let bounds = UIScreen.main.bounds
                                                    let height = bounds.size.height
                                                    switch height
                                                    {
                                                    case 568.0:
                                                        ImageView = createButton(CGRect(x:(menuItemWidth/2) - 29,y: 0,width: 40,height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
                                                    case 667.0:
                                                        ImageView = createButton(CGRect(x:(menuItemWidth/2) - 29,y: 0,width: 40,height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
                                                    case 736.0:
                                                        ImageView = createButton(CGRect(x:(menuItemWidth/2) - 39,y: 0,width: 40,height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
                                                    case 812.0:
                                                        ImageView = createButton(CGRect(x:(menuItemWidth/2) - 39,y: 0,width: 40,height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
                                                    case 1024.0:
                                                        ImageView = createButton(CGRect(x:(menuItemWidth/2) - 39,y: 0,width: 40,height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
                                                    default:
                                                        ImageView = createButton(CGRect(x:(menuItemWidth/2) - 39,y: 0,width: 40,height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
                                                        
                                                    }
                                                    
                                                    //                                                     ImageView = createButton(CGRect(x:(menuItemWidth/2) - 36,y: 0,width: 40,height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
                                                }
                                                else {
                                                    ImageView = createButton(CGRect(x: 7,y: 0,width: 40,height: 40), title: "", border: false, bgColor: false, textColor: textColorLight)
                                                }
                                                ImageView.imageEdgeInsets =  UIEdgeInsets(top: 3, left: 7.5, bottom: 12, right: 7.5)
                                                let imageUrl = myIcon
                                                let url = NSURL(string:imageUrl)
                                                
                                                
                                                ImageView.kf.setImage(with: url! as URL, for: .normal, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                                    
                                                    
                                                })
                                                
                                                cell.cellMenu.addSubview(ImageView)
                                                cell.cellMenu.bringSubviewToFront(ImageView)
                                            }
                                            
                                        }
                                    }
                                    else
                                    {
                                        title = String(format: NSLocalizedString("%@  Like", comment: ""), likeIcon)
                                    }
                                    textcolor = buttonColor
                                }
                                else
                                {
                                    icon = "thumbs_up"
                                    //                                    title = String(format: NSLocalizedString("%@  Like", comment: ""), likeIcon)
                                    title = likeIcon
                                    title += NSLocalizedString(" Like", comment: "")
                                    textcolor = iconColor
                                }
                                
                                let menu : UIButton!
                                var likeButton: UIButton!
                                let likeButtonView: UIView!
                                if ReactionPlugin == true
                                {
                                    //                                    likeButton = UIButton()
                                    if let d = activityFeed["is_like"] as? Bool, d == true{
                                        menu = createButton(CGRect(x: 35,y: 0 ,width: menuItemWidth, height: 40), title: " \(title)", border: false,bgColor: false, textColor: iconColor)
                                        likeButtonView = createView(CGRect(x: 38,y: 0 ,width: menuItemWidth-3, height: 40), borderColor: UIColor.clear, shadow: false)
                                        menu.titleEdgeInsets.top = -7
                                        likeButtonView.backgroundColor = .clear
                                        if menuCount == 2
                                        {
                                            likeButton = createButton(CGRect(x: 0,y: 0 ,width: 60, height: 40), title: " \(title)", border: false,bgColor: false, textColor: iconColor)
                                            likeButtonView.addSubview(likeButton)
                                            likeButton.frame.origin.x = (likeButtonView.frame.width - likeButton.frame.width)/2
                                            likeButton.frame.origin.x = 30
                                            likeButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
                                            likeButton.titleEdgeInsets.left = 14
                                            likeButton.titleEdgeInsets.top = -7
                                            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FeedTableViewController.longPressed(sender:)))
                                            likeButton.addGestureRecognizer(longPressRecognizer)
                                            
                                        }
                                        else {
                                            likeButton = createButton(CGRect(x: 0,y: 0 ,width: 60, height: 40), title: " \(title)", border: false,bgColor: false, textColor: iconColor)
                                            likeButtonView.addSubview(likeButton)
                                            likeButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                                            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FeedTableViewController.longPressed(sender:)))
                                            likeButton.addGestureRecognizer(longPressRecognizer)
                                            likeButton.titleEdgeInsets.left = 2
                                            likeButton.titleEdgeInsets.top = -7
                                            
                                        }
                                        likeButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        likeButton.addTarget(self, action: #selector(FeedTableViewController.feedMenuLike(sender:)), for: .touchUpInside)
                                        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FeedTableViewController.longPressed(sender:)))
                                        likeButton.addGestureRecognizer(longPressRecognizer)
                                    }
                                    else
                                    {
                                        menu = createButton(CGRect(x: 20, y: 0, width: menuItemWidth,height: 40), title: "", border: false,bgColor: false, textColor: iconColor)
                                        likeButtonView = createView(CGRect(x: 20,y: 0 ,width: menuItemWidth, height: 40), borderColor: UIColor.clear, shadow: false)
                                        if menuCount == 2
                                        {
                                            likeButton = createButton(CGRect(x: 0, y: 0, width: 60,height: 40), title: "", border: false,bgColor: false, textColor: iconColor)
                                            likeButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
                                            let padding = (likeButton.frame.width-25)/2
                                            likeButton.imageEdgeInsets.left = padding
                                            likeButton.imageEdgeInsets.right = padding
                                            
                                            likeButtonView.addSubview(likeButton)
                                            likeButton.frame.origin.x = (likeButtonView.frame.width - likeButton.frame.width)/2
                                            likeButton.addTarget(self, action: #selector(FeedTableViewController.feedMenuLike(sender:)), for: .touchUpInside)
                                            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FeedTableViewController.longPressed(sender:)))
                                            likeButton.addGestureRecognizer(longPressRecognizer)
                                        }
                                        else {
                                            likeButton = createButton(CGRect(x: 0, y: 0, width: 60,height: 40), title: "", border: false,bgColor: false, textColor: iconColor)
                                            likeButton.imageView?.frame.size = CGSize(width: 25, height: 25)
                                            likeButtonView.addSubview(likeButton)
                                            likeButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                                            likeButton.imageEdgeInsets.right = likeButton.frame.width - 25
                                            likeButton.addTarget(self, action: #selector(FeedTableViewController.feedMenuLike(sender:)), for: .touchUpInside)
                                            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FeedTableViewController.longPressed(sender:)))
                                            likeButton.addGestureRecognizer(longPressRecognizer)
                                            
                                        }
                                        likeButton.imageEdgeInsets.top = 3
                                        likeButton.imageEdgeInsets.bottom = 12
                                        likeButton.tag = row
                                        //menu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
                                        // menu.setImage(#imageLiteral(resourceName: "likeIcon"), for: .normal)
                                        likeButton.setImage(UIImage(named:"likeIcon"), for: .normal)
                                        
                                    }
                                    
                                    
                                }
                                else
                                {
                                    menu = createButton(CGRect(x: 20 + origin_x,y: 0 , width: menuItemWidth,height: 40), title: "\(title)", border: false,bgColor: false, textColor: iconColor)
                                    likeButtonView = createView(CGRect(x: 20,y: 0 ,width: menuItemWidth, height: 40), borderColor: UIColor.clear, shadow: false)
                                    //                                    likeButton = UIButton()
                                    // menu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
                                    //menu.titleLabel?.adjustsFontSizeToFitWidth = true
                                    
                                    likeButton = createButton(CGRect(x: 0, y: 0, width: 60, height: 40), title: "", border: false, bgColor: false, textColor: iconColor)
                                    
                                    if let d = activityFeed["is_like"] as? Bool, d == true{
                                        let originalImage = UIImage(named: "likeIcon")
                                        let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
                                        likeButton.setImage(tintedImage, for: .normal)
                                        likeButton.tintColor = buttonColor
                                    }
                                    else {
                                        likeButton.setImage(UIImage(named:"likeIcon"), for: .normal)
                                    }
                                    
                                    likeButton.imageEdgeInsets.top = 3
                                    likeButton.imageEdgeInsets.bottom = 12
                                    likeButton.titleEdgeInsets.left = 2
                                    
                                    if menuCount == 2 {
                                        likeButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
                                        let padding = (likeButton.frame.width-25)/2
                                        likeButton.imageEdgeInsets.left = padding
                                        likeButton.imageEdgeInsets.right = padding
                                        likeButton.frame.origin.x = (likeButtonView.frame.width - likeButton.frame.width)/2
                                    }
                                    else {
                                        likeButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                                        likeButton.imageEdgeInsets.right = likeButton.frame.width - 25
                                    }
                                    
                                }
                                
                                likeButton.titleLabel?.textColor = iconColor
                                likeButton.setTitleColor(textcolor, for: .normal)
                                likeButton.tag = row
                                likeButton.backgroundColor =  textColorclear
                                likeButtonView.addSubview(likeButton)
                                likeButton.addTarget(self, action: #selector(FeedTableViewController.feedMenuLike(sender:)), for: .touchUpInside)
                                cell.cellMenu.addSubview(likeButtonView)
                                
                            }
                            else
                            {
                                //title = String(format: NSLocalizedString("%@  Comment", comment: ""), commentIcon)
                                // icon = "comment_icon"
                                let menu = createButton(CGRect(x: 20 + origin_x,y: 0, width: menuItemWidth,height: 40), title: "", border: false,bgColor: false, textColor: iconColor)
                                let commentView = createView(CGRect(x: 20 + origin_x,y: 0, width: menuItemWidth, height: 40), borderColor: UIColor.clear, shadow: false)
                                commentView.tag = row
                                commentView.layer.borderWidth = 2
                                let commentButton = createButton(CGRect(x: 0,y: 0, width: 60,height: 40), title: "", border: false,bgColor: false, textColor: iconColor)
                                commentButton.tag = row
                                commentButton.setImage(#imageLiteral(resourceName: "commentIcon"), for: .normal)
                                commentButton.imageEdgeInsets.top = 3
                                commentButton.imageEdgeInsets.bottom = 12
                                commentView.addSubview(commentButton)
                                commentButton.frame.origin.x = (commentView.frame.width - commentButton.frame.width)/2
                                // menu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
                                //menu.titleLabel?.adjustsFontSizeToFitWidth = true
                                if menuCount == 2
                                {
                                    commentButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
                                    commentButton.imageEdgeInsets.left = commentButton.frame.width - 25
                                    let padding = (commentButton.frame.width-25)/2
                                    commentButton.imageEdgeInsets.left = padding
                                    commentButton.imageEdgeInsets.right = padding
                                }
                                else
                                {
                                    commentButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
                                    let padding = (commentButton.frame.width-25)/2
                                    commentButton.imageEdgeInsets.left = padding
                                    commentButton.imageEdgeInsets.right = padding
                                }
                                
                                commentButton.backgroundColor = textColorLight
                                commentButton.addTarget(self, action: #selector(FeedTableViewController.commentAction(_:)), for: .touchUpInside)
                                // cell.cellMenu.addSubview(menu)
                                cell.cellMenu.addSubview(commentView)
                                if tableViewFrameType == "CommentsViewController"
                                {
                                    commentButton.isEnabled = false
                                }
                            }
                            origin_x += menuItemWidth
                        }
                        continue
                    }
                case "share":
                    if feed_menu["share"] != nil{
                        noshareMenu = false
                        let shareView = createView(CGRect(x: 20 + origin_x,y: 0, width: menuItemWidth, height: 40), borderColor: UIColor.clear, shadow: false)
                        shareView.tag = row
                        let shareButton = createButton(CGRect(x: 0 ,y: 0, width: 60, height: 40), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                        shareView.addSubview(shareButton)
                        shareView.bringSubviewToFront(shareButton)
                        shareButton.imageEdgeInsets.top = 3
                        shareButton.addTarget(self, action: #selector(FeedTableViewController.feedMenuShare(sender:)), for: .touchUpInside)
                        cell.cellMenu.addSubview(shareView)
                        shareButton.imageEdgeInsets.bottom = 12
                        shareButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
                        shareButton.imageEdgeInsets.left = shareButton.frame.width - 25
                        shareButton.frame.origin.x = shareView.frame.width - shareButton.frame.width
                        if menuSequence.count == 1{
                            shareButton.frame.origin.x = (shareView.frame.width - shareButton.frame.width)/2
                            shareButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
                            let padding = (shareButton.frame.width-25)/2
                            shareButton.imageEdgeInsets.left = padding
                            shareButton.imageEdgeInsets.right = padding
                            
                        }
                        let image = #imageLiteral(resourceName: "shareFeedIcon")
                        shareButton.setImage(image, for: .normal)
                        shareButton.tag = row
                        
                        
                    }
                    
                default: break
                    //print("Error")
                }
            }
            
        }
        // Set Gutter Menu for Feed
        if logoutUser == false
        {
            cell.sideMenu.tag = row
            if let feed_gutter_menu = activityFeed["feed_menus"] as? NSArray{
                if feed_gutter_menu.count > 0
                {
                    cell.sideMenu.isHidden = false
                    let recognizer = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewController.handleTapped(recognizer:)))
                    recognizer.delegate = self
                    recognizer.cancelsTouchesInView = false
                    cell.sideMenu.addGestureRecognizer(recognizer)
                    //cell.sideMenu.addTarget(self, action: #selector(FeedTableViewController.showGutterMenu(_:)), for: .touchUpInside)
                }
                else
                {
                    cell.sideMenu.isHidden = true
                }
            }
            
        }
        // Check for LogoutUser
        if logoutUser == true {
            cell.reactionsInfo.isHidden = true
            cell.commentInfo.isHidden = true
            cell.likeCommentInfo.isHidden = true
            cell.borderView.isHidden = true
            cell.cellMenu.isHidden = true
            
            
            
            let originY:CGFloat = (cell.body.frame.origin.y) + (cell.body.bounds.height) + 5
            
            
            if dynamicHeight == 0
            {
                cell.cellView.frame.size.height =  originY + 5
            }
            else
            {
                cell.cellView.frame.size.height = dynamicHeight + originY + 5
            }
            if let scheduleTime = activityFeed["publish_date"] as? String {
                if scheduleTime.length != 0 {
                    cell.scheduleFeedLabel.text = "  \(clockIcon) This feed will post on \(scheduleTime)"
                    cell.scheduleFeedLabel.isHidden = false
                    cell.scheduleFeedLabel.frame.origin.y = cell.cellView.frame.size.height
                    cell.cellView.frame.size.height = cell.cellView.frame.size.height + 30
                }
            }
            dynamicHeight = ((cell.cellView.frame.size.height) + 5)
            
        }
        else if (noCommentMenu == true) && (noshareMenu == true)
        {
            cell.likeCommentInfo.isHidden = true
            cell.borderView.isHidden = true
            cell.reactionsInfo.isHidden = true
            cell.commentInfo.isHidden = true
            cell.cellMenu.isHidden = true
            
            let originY:CGFloat = (cell.body.frame.origin.y) + (cell.body.bounds.height) + 5
            if dynamicHeight == 0{
                cell.cellView.frame.size.height =  originY + 5
            }
            else
            {
                cell.cellView.frame.size.height = dynamicHeight + originY + 5
                
            }
            if let scheduleTime = activityFeed["publish_date"] as? String {
                if scheduleTime.length != 0 {
                    cell.scheduleFeedLabel.text = "  \(clockIcon) This feed will post on \(scheduleTime)"
                    cell.scheduleFeedLabel.isHidden = false
                    cell.scheduleFeedLabel.frame.origin.y = cell.cellView.frame.size.height
                    cell.cellView.frame.size.height = cell.cellView.frame.size.height + 30
                }
            }
            dynamicHeight = ((cell.cellView.frame.size.height) + 5)
            
            
        }
        else
        {
            cell.cellMenu.isHidden = false
            cell.cellView.frame.size.height = (cell.cellMenu.frame.origin.y) + (cell.cellMenu.bounds.height)
            if let scheduleTime = activityFeed["publish_date"] as? String {
                if scheduleTime.length != 0{
                    cell.likeCommentInfo.isHidden = true
                    cell.borderView.isHidden = true
                    cell.reactionsInfo.isHidden = true
                    cell.commentInfo.isHidden = true
                    cell.cellMenu.isHidden = true
                    cell.scheduleFeedLabel.text = "  \(clockIcon) This feed will post on \(scheduleTime)"
                    cell.scheduleFeedLabel.isHidden = false
                    // cell.cellView.frame.size.height = cell.cellView.frame.size.height - (cell.cellMenu.bounds.height)
                    cell.scheduleFeedLabel.frame.origin.y = cell.cellView.frame.size.height
                    cell.cellView.frame.size.height = cell.cellView.frame.size.height + 30
                }
            }
            dynamicHeight = ((cell.cellView.frame.size.height) + 5)
            
        }
        
        
        
        self.dynamicRowHeight[activityFeed["action_id"] as! Int] = self.dynamicHeight
    }
    
    // Present Feed Gutter Menus
    @objc func showGutterMenu(_ sender:UIButton)
    {
        if openSideMenu
        {
            openSideMenu = false
            
            return
        }
        deleteFeed = false
        menuOptionSelected = ""
        let feed = globalArrayFeed[sender.tag] as! NSDictionary
        // Set Sequence for menu
        if let feed_menu = feed["feed_menus"] as? NSArray{
            
            // Generate Feed Filter Gutter Menu for Feed Come From Server as! Alert Popover
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            
            for menuItem in feed_menu{
                if let dic = menuItem as? NSDictionary {
                    
                    if let titleString = dic["label"] as? String
                    {
                        if titleString.range(of: "Delete") != nil{
                            alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                                self.menuOptionSelected = dic["name"] as! String
                                // Delete Activity Feed Entry
                                if let d = dic["name"] as? String, d == "delete_feed"{
                                    
                                    // Confirmation Alert for Delete Feed
                                    displayAlertWithOtherButton(NSLocalizedString("Delete Activity Item?", comment: "") ,message: NSLocalizedString("Are you sure that you want to delete this activity item? This action cannot be undone.", comment: "") ,otherButton: NSLocalizedString("Delete", comment: ""), otherButtonAction: { () -> () in
                                        self.deleteFeed = true
                                        
                                        // Update Feed Gutter Menu
                                        self.updateFeedMenu(parameter: dic["urlParams"] as! NSDictionary, url:dic["url"] as! String,feedIndex: sender.tag)
                                    })
                                    self.present(alert, animated: true, completion: nil)
                                }else{
                                    if let d = dic["name"] as? String, d == "hits_feed"{
                                        // Reset variable for Hard Refresh
                                        self.deleteFeed = true
                                        self.maxid = 0
                                        
                                    }
                                    
                                    // Update Feed Gutter Menu
                                    self.updateFeedMenu(parameter: dic["urlParams"] as! NSDictionary, url:dic["url"] as! String,feedIndex: sender.tag )
                                }
                                
                                
                            }))
                        }else{
                            alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                                self.menuOptionSelected = dic["name"] as? String ?? ""
                                // Delete Activity Feed Entry
                                if let d = dic["name"] as? String, d == "delete_feed"{
                                    
                                    // Confirmation Alert for Delete Feed
                                    displayAlertWithOtherButton(NSLocalizedString("Delete Activity Item?", comment: "") ,message: NSLocalizedString("Are you sure that you want to delete this activity item? This action cannot be undone.", comment: "") ,otherButton: NSLocalizedString("Delete", comment: ""), otherButtonAction: { () -> () in
                                        self.deleteFeed = true
                                        // Update Feed Gutter Menu
                                        self.updateFeedMenu(parameter: dic["urlParams"] as! NSDictionary, url:dic["url"] as! String,feedIndex: sender.tag  )
                                    })
                                    self.present(alert, animated: true, completion: nil)
                                } else if let d = dic["name"] as? String, d == "edit_feed"{
                                    var body_t :  String!
                                    var statusBody : String = ""
                                    
                                    if  let body_param = feed["action_type_body_params"] as? NSArray{
                                        for i in 0 ..< body_param.count {
                                            let body1 = body_param[i] as! NSDictionary
                                            if body1["search"] as! String == "{body:$body}"{
                                                if ( body1["label"] is String){
                                                    body_t = body1["label"] as! String
                                                    //body_t = body_t.replacingOccurrences(of: "\n", with: "<br/>")
                                                    body_t = body_t.replacingOccurrences(of: "<br/>", with: "\n")
                                                    //body_t = body_t.html2String as String
                                                    body_t = Emoticonizer.emoticonizeString("\(body_t!)" as NSString) as String
                                                }
                                                statusBody = body_t
                                            }
                                            
                                        }
                                    }
                                    
                                    let presentedVC = EditFeedViewController()
                                    presentedVC.editBody = statusBody
                                    presentedVC.editId   =  feed["action_id"] as? Int ?? 0
                                    self.navigationController?.pushViewController(presentedVC, animated: false)
                                }
                                else{
                                    if let d = dic["name"] as? String, d == "hits_feed"{
                                        // Reset variable for Hard Refresh
                                        self.deleteFeed = true
                                        self.maxid = 0
                                        
                                    }
                                    
                                    // Update Feed Gutter Menu
                                    self.updateFeedMenu(parameter: dic["urlParams"] as! NSDictionary, url:dic["url"] as! String,feedIndex: sender.tag  )
                                }
                                
                            }))
                        }
                    }
                    
                }
            }
            if  (UIDevice.current.userInterfaceIdiom == .phone)
            {
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
                
            }else{
                
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                
                popover?.sourceRect = CGRect(x: view.bounds.height/2,y: view.bounds.width/2,width: 0,height: 0)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
            
        }
    }
    
    // Update Feed Gutter Menu
    func updateFeedMenu(parameter: NSDictionary , url : String,feedIndex: Int)
    {
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
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
            
            if url.range(of:"delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            let feed = globalArrayFeed[feedIndex] as! NSDictionary
            if enterdPinDays > 0 {
                
                dic["time"] = "\(enterdPinDays)"
            }
            
            
            var newDictionary:NSMutableDictionary = [:]
            //Getting temporary feed dic for updating locally
            newDictionary =  self.getfeedDic(feed: feed)
            
            // Check case for update Particular Feed Gutter Menu Option Select for Updation
            var updatedLabel = ""
            if self.menuOptionSelected == "on_off_notification" {
                
                
                let tempComment = feed["isNotificationTurnedOn"] as! Bool
                switch tempComment
                {
                    
                case true:
                    newDictionary["isNotificationTurnedOn"] = false
                    updatedLabel = NSLocalizedString("Turn On Notification", comment: "")
                    break
                default:
                    newDictionary["isNotificationTurnedOn"] = true
                    updatedLabel = NSLocalizedString("Turn Off Notification", comment: "")
                    break
                    
                }
                if feed["feed_menus"]  != nil{
                    var tempArray = [AnyObject]()
                    //  var tempMutableArray : NSArray
                    if  let tempMutableArray = feed["feed_menus"]! as? NSArray
                    {
                        for menu in tempMutableArray{
                            if let menuDic = menu as? NSMutableDictionary{
                                let subMenuDictionary:NSMutableDictionary = [:]
                                if menuDic["name"] as? String == self.menuOptionSelected {
                                    for (key, value) in menuDic{
                                        if key as! String == "label"{
                                            subMenuDictionary["label"] = updatedLabel
                                        }else{
                                            subMenuDictionary["\(key)"] = value
                                        }
                                    }
                                }else{
                                    for (key, value) in menuDic{
                                        subMenuDictionary["\(key)"] = value
                                    }
                                }
                                tempArray.append(subMenuDictionary)
                            }
                            
                        }
                    }
                    newDictionary["feed_menus"] = tempArray
                    tempArray.removeAll(keepingCapacity: false)
                }
                
                self.globalArrayFeed[feedIndex] = newDictionary
                
                
                let index = Int()
                let indexPath = IndexPath(row: index, section: 0)
                self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
            
            userInteractionOff = false
            // Send Server Request to Update Feed Gutter Menu
            post(dic, url: url, method: method) { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute:  {
                    userInteractionOff = true
                    if msg
                    {
                        if self.menuOptionSelected != "on_off_notification" {
                            // Check for Delete Particular FEED
                            if self.deleteFeed == true{
                                // Make Hard Referesh For Delete Feed & REset VAriable
                                self.maxid = 0
                                self.feed_filter = 0
                                self.deleteFeed = false
                                self.globalArrayFeed.remove(at:feedIndex)
                                // Updating corresponding array
                                if self.feedShowingFrom == "ActivityFeed"
                                {
                                    
                                    feedArray.remove(at:feedIndex)
                                }
                                else if self.feedShowingFrom == "UserFeed"
                                {
                                    
                                    userFeedArray.remove(at:feedIndex)
                                }
                                else
                                {
                                    
                                    contentFeedArray.remove(at:feedIndex)
                                }
                                advGroupDetailUpdate = true
                                if isQuickContentInProcess == 1
                                {
                                    //                                    var index = Int()
                                    //                                    if kFrequencyAdsInCells_feeds > 4 && self.nativeAdArray.count > 0
                                    //                                    {
                                    //                                        index = feedIndex + self.adsCount
                                    //                                    }
                                    //                                    else
                                    //                                    {
                                    //                                        index = feedIndex
                                    //                                    }
                                    //                                    //print(index)
                                    let indexPath = IndexPath(row: feedIndex, section: 0)
                                    self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                                    if let cell = self.tableView.cellForRow(at: indexPath) as? AAFActivityFeedTableViewCell
                                    {
                                        self.sharedVideoPlayer.removeLayerFor(cell: cell)
                                    }
                                    
                                }
                                else
                                {
                                    self.reloadDataTableView()
                                }
                                self.delegate?.deleteFeed()
                                self.feedDelegate?.feedDeleted()
                                showToast(message: NSLocalizedString("Your post has been deleted successfully", comment: ""), controller: self, onView: false, time: 5.0)
                            }
                            else
                            {
                                
                                let feed = self.globalArrayFeed[feedIndex] as! NSDictionary
                                var newDictionary:NSMutableDictionary = [:]
                                //Getting temporary feed dic for updating locally
                                newDictionary =  self.getfeedDic(feed: feed)
                                
                                // Check case for update Particular Feed Gutter Menu Option Select for Updation
                                var updatedLabel = ""
                                switch (self.menuOptionSelected)
                                {
                                case "like" , "unlike":
                                    let tempLike = feed["is_like"] as! Bool
                                    switch tempLike
                                    {
                                        
                                    case true:
                                        newDictionary["is_like"] = false
                                        newDictionary["likes_count"] = ((feed["likes_count"] as? Int)!-1)
                                        if newDictionary["feed_Type"] as! String != "share"
                                        {
                                            let temp = newDictionary["photo_attachment_count"] as? Int
                                            
                                            if temp == 1 {
                                                
                                                if newDictionary["attachment"] != nil
                                                {
                                                    var dic:NSMutableDictionary = [:]
                                                    let array = newDictionary["attachment"] as! NSMutableArray
                                                    if array.count > 0{
                                                        dic = array[0] as! NSMutableDictionary
                                                        if dic["is_like"] != nil
                                                        {
                                                            dic["is_like"] = false
                                                        }
                                                        
                                                        if dic["likes_count"] != nil
                                                        {
                                                            
                                                            dic["likes_count"] = ((feed["likes_count"] as? Int)!+1)
                                                        }
                                                        if dic["like_count"] != nil
                                                        {
                                                            
                                                            dic["like_count"] = ((feed["likes_count"] as? Int)!+1)
                                                        }
                                                        array.removeObject(at: 0)
                                                        array.add(dic)
                                                        newDictionary["attachment"] = array
                                                    }
                                                    
                                                }
                                            }
                                        }
                                        break
                                    default:
                                        newDictionary["is_like"] = true
                                        newDictionary["likes_count"] = ((feed["likes_count"] as? Int)!+1)
                                        if newDictionary["feed_Type"] as! String != "share"
                                        {
                                            let temp = newDictionary["photo_attachment_count"] as? Int
                                            
                                            if temp == 1 {
                                                
                                                if newDictionary["attachment"] != nil
                                                {
                                                    var dic:NSMutableDictionary = [:]
                                                    let array = newDictionary["attachment"] as! NSMutableArray
                                                    if array.count > 0{
                                                        dic = array[0] as! NSMutableDictionary
                                                        if dic["is_like"] != nil
                                                        {
                                                            dic["is_like"] = true
                                                        }
                                                        
                                                        if dic["likes_count"] != nil
                                                        {
                                                            
                                                            dic["likes_count"] = ((feed["likes_count"] as? Int)!+1)
                                                        }
                                                        if dic["like_count"] != nil
                                                        {
                                                            
                                                            dic["like_count"] = ((feed["likes_count"] as? Int)!+1)
                                                        }
                                                        array.removeObject(at: 0)
                                                        array.add(dic)
                                                        newDictionary["attachment"] = array
                                                    }
                                                    
                                                }
                                            }
                                        }
                                        break
                                        
                                    }
                                case "disable_comment":
                                    let tempComment = feed["comment"] as! Bool
                                    switch tempComment
                                    {
                                        
                                    case true:
                                        newDictionary["comment"] = false
                                        updatedLabel = NSLocalizedString("Enable Comment", comment: "")
                                        break
                                    default:
                                        newDictionary["comment"] = true
                                        updatedLabel = NSLocalizedString("Disable Comment", comment: "")
                                        break
                                        
                                    }
                                    
                                    //                            case "on_off_notification":
                                    //
                                    //                                let tempComment = feed["isNotificationTurnedOn"] as! Bool
                                    //                                switch tempComment
                                    //                                {
                                    //
                                    //                                case true:
                                    //                                    newDictionary["isNotificationTurnedOn"] = false
                                    //                                    updatedLabel = NSLocalizedString("Turn On Notification", comment: "")
                                    //                                    break
                                    //                                default:
                                    //                                    newDictionary["isNotificationTurnedOn"] = true
                                    //                                    updatedLabel = NSLocalizedString("Turn Off Notification", comment: "")
                                    //                                    break
                                    //
                                    //                                }
                                    
                                case "pin_post" , "unpin_post":
                                    self.enterdPinDays = 0
                                    let tempComment = feed["isPinned"] as! Bool
                                    switch tempComment
                                    {
                                        
                                    case true:
                                        newDictionary["isPinned"] = false
                                        updatedLabel = NSLocalizedString("Pin the post", comment: "")
                                        break
                                    default:
                                        newDictionary["isPinned"] = true
                                        updatedLabel = NSLocalizedString("Unpin the post", comment: "")
                                        break
                                        
                                    }
                                    
                                    
                                    
                                    
                                    
                                case "lock_this_feed":
                                    
                                    let tempShare = feed["share"] as! Bool
                                    switch tempShare
                                    {
                                        
                                    case true:
                                        newDictionary["share"] = false
                                        updatedLabel = NSLocalizedString("Unlock this Feed", comment: "")
                                        break
                                    default:
                                        newDictionary["share"] = true
                                        updatedLabel = NSLocalizedString("Lock this Feed", comment: "")
                                        break
                                    }
                                    
                                case "update_save_feed":
                                    
                                    if let body = succeeded["body"] as? Int{
                                        switch body
                                        {
                                            
                                        case 1:
                                            updatedLabel = NSLocalizedString("Save Feed", comment: "")
                                            break
                                        default:
                                            updatedLabel = NSLocalizedString("Unsave Feed", comment: "")
                                            break
                                        }
                                        
                                    }
                                case "hide", "report_feed":
                                    if let body = succeeded["body"] as? NSDictionary
                                    {
                                        self.tempcontentFeedArray[feed["action_id"] as! Int] = body
                                        
                                    }
                                    isRefresh = true
                                    break
                                case "undo":
                                    self.tempcontentFeedArray.removeValue(forKey: feed["action_id"] as! Int)
                                    isRefresh = true
                                    break
                                default:
                                    ////print("Error", terminator: "")
                                    break
                                }
                                
                                // Update Menu Option without Hard Refresh
                                if self.menuOptionSelected == "disable_comment" || self.menuOptionSelected == "lock_this_feed" || self.menuOptionSelected == "update_save_feed"  || self.menuOptionSelected == "pin_post" || self.menuOptionSelected == "unpin_post"{
                                    
                                    if self.menuOptionSelected == "update_save_feed" || self.menuOptionSelected == "on_off_notification" {
                                        delay(2.0, closure: {
                                            if feed["feed_menus"]  != nil{
                                                var tempArray = [AnyObject]()
                                                //  var tempMutableArray : NSArray
                                                if  let tempMutableArray = feed["feed_menus"]! as? NSArray
                                                {
                                                    for menu in tempMutableArray{
                                                        if let menuDic = menu as? NSMutableDictionary{
                                                            let subMenuDictionary:NSMutableDictionary = [:]
                                                            if menuDic["name"] as? String == self.menuOptionSelected {
                                                                for (key, value) in menuDic{
                                                                    if key as! String == "label"{
                                                                        subMenuDictionary["label"] = updatedLabel
                                                                    }else{
                                                                        subMenuDictionary["\(key)"] = value
                                                                    }
                                                                }
                                                            }else{
                                                                for (key, value) in menuDic{
                                                                    subMenuDictionary["\(key)"] = value
                                                                }
                                                            }
                                                            tempArray.append(subMenuDictionary)
                                                        }
                                                        
                                                    }
                                                }
                                                newDictionary["feed_menus"] = tempArray
                                                tempArray.removeAll(keepingCapacity: false)
                                            }
                                            
                                        })
                                    }
                                    else{
                                        
                                        
                                        if feed["feed_menus"]  != nil{
                                            var tempArray = [AnyObject]()
                                            //  var tempMutableArray : NSArray
                                            if  let tempMutableArray = feed["feed_menus"]! as? NSArray
                                            {
                                                for menu in tempMutableArray{
                                                    if let menuDic = menu as? NSMutableDictionary{
                                                        let subMenuDictionary:NSMutableDictionary = [:]
                                                        if menuDic["name"] as? String == self.menuOptionSelected {
                                                            for (key, value) in menuDic{
                                                                if key as! String == "label"{
                                                                    subMenuDictionary["label"] = updatedLabel
                                                                }else{
                                                                    subMenuDictionary["\(key)"] = value
                                                                }
                                                            }
                                                        }else{
                                                            for (key, value) in menuDic{
                                                                subMenuDictionary["\(key)"] = value
                                                            }
                                                        }
                                                        tempArray.append(subMenuDictionary)
                                                    }
                                                    
                                                }
                                            }
                                            newDictionary["feed_menus"] = tempArray
                                            tempArray.removeAll(keepingCapacity: false)
                                        }
                                        
                                        
                                    }
                                }
                                // Sink feedArray with Updation
                                if self.menuOptionSelected == "pin_post" || self.menuOptionSelected == "unpin_post"{
                                    self.maxid = 0
                                    self.feed_filter = 0
                                    
                                    self.delegatepin?.reloadpin()
                                    ////print(newDictionary)
                                }
                                else{
                                    self.globalArrayFeed[feedIndex] = newDictionary
                                    
                                    var index = Int()
                                    if kFrequencyAdsInCells_feeds > 4 && self.nativeAdArray.count > 0
                                    {
                                        index = feedIndex + self.adsCount
                                    }
                                    else
                                    {
                                        index = feedIndex
                                    }
                                    ////print(index)
                                    // delay(2.0, closure: {
                                    if self.menuOptionSelected == "update_save_feed" || self.menuOptionSelected == "on_off_notification" {
                                        let indexPath = IndexPath(row: index, section: 0)
                                        self.tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
                                        self.tableView.contentOffset = .zero
                                    }
                                    else{
                                        self.reloadDataTableView()
                                    }
                                    
                                    
                                    self.delegate?.reloaddata()
                                }
                            }
                            
                        }
                    }
                    
                })
            }
            
        }
        else
        {
            showToast(message: network_status_msg, controller: self, onView: false, time: 5.0)
        }
    }
    
    
    // MARK:  TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable : Any]!)
    {
        
        let components = components as NSDictionary
        let type = components["type"] as! String
        var attchmendic = NSDictionary()
        var activityfeed = NSDictionary()
        
        if (components["feed"] as? NSDictionary) != nil
        {
            
            activityfeed = components["feed"] as! NSDictionary
        }
        else
        {
            activityfeed = components
            
        }
        
        //Check for Attachment
        if let attachmentarr = activityfeed["attachment"] as? NSArray
        {
            attchmendic = attachmentarr[0] as! NSDictionary
        }
        
        var feedindex = 0
        if let index = components["feedIndex"] as? Int
        {
            feedindex = index
        }
        //Check for objectID
        if let objectID = components["id"] as? Int
        {
            
            contentRedirection(feedtype: type, activityFeed:activityfeed ,objectID:objectID, attechmentDic : attchmendic,feedIndex : feedindex)
        }
        else
        {
            let objectID = 0
            contentRedirection(feedtype: type, activityFeed:activityfeed ,objectID:objectID, attechmentDic : attchmendic, feedIndex : feedindex)
        }
        
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        //UIApplication.shared.openURL(url!)
        let presentedVC = ExternalWebViewController()
        presentedVC.url = url.absoluteString
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navigationController = UINavigationController(rootViewController: presentedVC)
        self.present(navigationController, animated: true, completion: nil)
        
    }
    
    // MARK: Content redirection
    @objc func tappedContent(sender: UITapGestureRecognizer)
    {
        //using sender, we can get the point in respect to the table view
        let tapLocation = sender.location(in: self.tableView)
        
        //using the tapLocation, we retrieve the corresponding indexPath
        let indexPath = self.tableView.indexPathForRow(at: tapLocation)
        
        //finally, we //print out the value
        if var rowIndexPath = (indexPath?.row)
        {
            // Calculate actuall index after removing ads cell
            if kFrequencyAdsInCells_feeds > 4 && nativeAdArray.count > 0 && globalArrayFeed.count > kFrequencyAdsInCells_feeds-1
            {
                rowIndexPath = rowIndexPath - (rowIndexPath / kFrequencyAdsInCells_feeds)
            }
            
            // Calculate actuall index after removing people you may know cell
            if rowIndexPath > suggestionSlideshowPosition - 1 && showSuggestions == 1 &&  isHomeFeeds && userSuggestions.count > 0
            {
                rowIndexPath = rowIndexPath - 1
            }
            
            let activityFeed = globalArrayFeed[rowIndexPath] as! NSDictionary
            
            if activityFeed["feed_Type"] as! String == "share"
            {
                if let attachment = activityFeed["attachment"] as? NSArray
                {
                    if let object_type_string = activityFeed["share_params_type"] as? String
                    {
                        if object_type_string.range(of: "_photo") != nil
                        {
                            // TODO: Need Changes Here
                            let pv = ActivityFeedPhotoViewController()
                            pv.photoAttachmentArray = attachment
                            pv.photoIndex = 0
                            if let photo_type = activityFeed["share_params_type"] as? String
                            {
                                pv.photoType = "\(photo_type)"
                            }
                            else
                            {
                                pv.photoType = "album_photo"
                            }
                            let nativationController = UINavigationController(rootViewController: pv)
                            nativationController.modalPresentationStyle = .fullScreen
                            present(nativationController, animated:true, completion: nil)
                        }
                        else if object_type_string == "forum_topic" {
                            let presentedVC = ForumTopicViewController()
                            if let attachment = activityFeed["attachment"] as? NSArray {
                                for param in attachment {
                                    if let dic = param as? NSDictionary {
                                        if let type = dic["attachment_type"] as? String, type == "forum_topic" {
                                            if let url = dic["uri"] as? String {
                                                let arr = url.components(separatedBy: "/")
                                                let count = arr.count - 1
                                                presentedVC.slug = arr[count]
                                                presentedVC.topicId = dic["attachment_id"] as! Int
                                                presentedVC.topicName = dic["title"] as! String
                                                navigationController?.pushViewController(presentedVC, animated: true)
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                            
                        else if objectType.contains(object_type_string)
                        {
                            if let attchmentarr = activityFeed["attachment"] as? NSArray
                            {
                                let attechmentDic = attchmentarr[0] as! NSDictionary
                                let objectID = attechmentDic["attachment_id"] as! Int
                                // Redirection
                                contentRedirection(feedtype: object_type_string , activityFeed: activityFeed,objectID:objectID, attechmentDic : attechmentDic,feedIndex: rowIndexPath)
                                
                            }
                        }
                        else
                        {
                            if attachment.count > 0
                            {
                                if let attachmentDic = attachment[0] as? NSDictionary
                                {
                                    if let attachment_type = attachmentDic["attachment_type"] as? String
                                    {
                                        if attachment_type == "core_link" || attachment_type == "sitepageoffer_offer"
                                        {
                                            if let objectUrl = attachmentDic["uri"] as? String
                                            {
                                                let presentedVC = ExternalWebViewController()
                                                presentedVC.url = objectUrl
                                                presentedVC.fromDashboard = false
                                                navigationController?.pushViewController(presentedVC, animated: true)
                                            }
                                        }
                                        else
                                        {
                                            if let objectDictionary = activityFeed["object"] as? NSDictionary
                                            {
                                                if let objectUrl = objectDictionary["url"] as? String
                                                {
                                                    fromExternalWebView = true
                                                    let presentedVC = ExternalWebViewController()
                                                    presentedVC.url = objectUrl
                                                    presentedVC.fromDashboard = false
                                                    navigationController?.pushViewController(presentedVC, animated: true)
                                                }
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
                    if let objectDictionary = activityFeed["object"] as? NSDictionary
                    {
                        if let objectUrl = objectDictionary["url"] as? String
                        {
                            fromExternalWebView = true
                            let presentedVC = ExternalWebViewController()
                            presentedVC.url = objectUrl
                            presentedVC.fromDashboard = false
                            navigationController?.pushViewController(presentedVC, animated: true)
                            
                        }
                    }
                }
            }
            else
            {
                if let attchmentarr = activityFeed["attachment"] as? NSArray
                {
                    let attechmentDic = attchmentarr[0] as! NSDictionary
                    let objectID = attechmentDic["attachment_id"] as! Int
                    if let objectType = attechmentDic["attachment_type"] as? String
                    {
                        
                        contentRedirection(feedtype: objectType , activityFeed: activityFeed,objectID:objectID, attechmentDic : attechmentDic,feedIndex: rowIndexPath)
                    }
                }
                else
                {
                    if let objectDictionary = activityFeed["object"] as? NSDictionary{
                        if let objectUrl = objectDictionary["url"] as? String{
                            fromExternalWebView = true
                            let presentedVC = ExternalWebViewController()
                            presentedVC.url = objectUrl
                            presentedVC.fromDashboard = false
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                        
                    }
                }
                
            }
        }
        
    }
    
    // MARK: Content redirection
    func contentRedirection(feedtype:String,activityFeed:NSDictionary,objectID : Int,attechmentDic:NSDictionary,feedIndex:Int)
    {
        
        switch(feedtype)
        {
            
        case "undo":
            self.updateFeedMenu(parameter: activityFeed["urlParams"] as! NSDictionary, url:activityFeed["url"] as! String ,feedIndex: activityFeed["index"] as! Int  )
            self.tempcontentFeedArray.removeValue(forKey: activityFeed["action_id"] as! Int)
            break
        case "hide_all":
            deleteFeed = true
            dynamicRowHeight.removeAll(keepingCapacity: false)
            tempcontentFeedArray.removeAll(keepingCapacity: false)
            self.updateFeedMenu(parameter: activityFeed["urlParams"] as! NSDictionary, url:activityFeed["url"] as! String ,feedIndex: activityFeed["index"] as! Int  )
            break
        case "report":
            let presentedVC = ReportContentViewController()
            presentedVC.param = activityFeed["urlParams"] as! NSDictionary
            presentedVC.url = activityFeed["url"] as! String
            self.navigationController?.pushViewController(presentedVC, animated: false)
            break
            
        case "more1":
            fullDescriptionCell.append(activityFeed["id"] as! Int)
            showComments(feedIndex: activityFeed["index"] as! Int, openTextView: 1, contentID: activityFeed["id"] as! Int)
            break
        case "more":
            
            break
        case "less":
            for (index,value) in fullDescriptionCell.enumerated()
            {
                if value == activityFeed["id"] as! Int
                {
                    fullDescriptionCell.remove(at: index)
                    break
                    
                }
            }
            break
        case "user1":
            let presentedVC = ContentActivityFeedViewController()
            if let imgUrl = activityFeed["subject_image"] as? String
            {
                presentedVC.strProfileImageUrl = imgUrl
            }
            //            if  let body = activityFeed["object"] as? NSDictionary, let strName = body["owner_title"] as? String
            //            {
            //                presentedVC.strUserName = strName
            //            }
            if  let body_param = activityFeed["action_type_body_params"] as? NSArray
            {
                if  let body1 = body_param[0] as? NSDictionary
                {
                    if let body = body1["label"] as? String
                    {
                        presentedVC.strUserName = body
                    }
                }
            }
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(objectID)"
            presentedVC.fromActivity = true
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
            break
            
        case "user":
            
            let presentedVC = ContentActivityFeedViewController()
            if let imgUrl = activityFeed["subject_image"] as? String
            {
                presentedVC.strProfileImageUrl = imgUrl
            }
            //            if  let body = activityFeed["object"] as? NSDictionary, let strName = body["owner_title"] as? String
            //            {
            //                presentedVC.strUserName = strName
            //            }
            if  let body_param = activityFeed["action_type_body_params"] as? NSArray
            {
                if  let body1 = body_param[0] as? NSDictionary
                {
                    if let body = body1["label"] as? String
                    {
                        presentedVC.strUserName = body
                    }
                }
            }
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(objectID)"
            presentedVC.fromActivity = true
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
            break
            
        case "map" :
            let presentedVC = MapViewController()
            presentedVC.location = activityFeed["location"] as! String
            presentedVC.place_id = activityFeed["place_id"] as! String
            self.navigationController?.pushViewController(presentedVC, animated: false)
            break
            
        case "tagother":
            let presentedVC = TagListViewController()
            presentedVC.contentType = "feedTitle"
            presentedVC.blogResponse = ((activityFeed["tags"] as! NSArray)) as [AnyObject]
            self.navigationController?.pushViewController(presentedVC, animated: true)
            break
            
            
        case "link" :
            
            if activityFeed["objectUrl"] != nil{
                fromExternalWebView = true
                let presentedVC = ExternalWebViewController()
                presentedVC.url = activityFeed["objectUrl"]! as! String
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let navigationController = UINavigationController(rootViewController: presentedVC)
                self.present(navigationController, animated: true, completion: nil)
            }
            break
            
        case "hashtags" :
            let original = activityFeed["hashtagString"] as! String
            let singleString = String(original.dropFirst())
            let presentedVC = HashTagFeedViewController()
            presentedVC.hashtagString = singleString
            navigationController?.pushViewController(presentedVC, animated: true)
            break
            
        case "group":
            let presentedVC = ContentFeedViewController()
            presentedVC.subjectType = "group"
            presentedVC.subjectId = "\(objectID)"
            self.navigationController?.pushViewController(presentedVC, animated: true)
            break
        case "event":
            let presentedVC = ContentFeedViewController()
            presentedVC.subjectType = "event"
            presentedVC.subjectId = "\(objectID)"
            self.navigationController?.pushViewController(presentedVC, animated: true)
            break
        case "album":
            let presentedVC = AlbumProfileViewController()
            presentedVC.albumId = "\(objectID)"
            self.navigationController?.pushViewController(presentedVC, animated: false)
            break
        case "blog":
            
            BlogObject().redirectToBlogDetailPage(self,blogId: objectID,title: "")
            break
        case "video":
            if let attachment = activityFeed["attachment"] as? NSArray
            {
                let attechmentDic = attachment[0] as! NSDictionary
                let attachment_video_type = attechmentDic["attachment_video_type"] as? Int ?? 0
                if let objectType = attechmentDic["attachment_type"] as? String, objectType == "video"
                {
                    if attachment_video_type == 3
                    {
                        if tableViewFrameType == "ContentActivityFeedViewController"
                        {
                            feedArrayTikTok = feedArrayTikTokTemp
                        }
                        var isQuickVideoDeviceVCExist = false
                        if tableViewFrameType == "CommentsViewController"
                        {
                            if let viewControllers = self.navigationController?.viewControllers
                            {
                                for controller in viewControllers
                                {
                                    if controller is QuickVideoDeviceVC
                                    {
                                        isQuickVideoDeviceVCExist = true
                                        if globalArrayFeed.count != 0
                                        {
                                            if let dic = globalArrayFeed[0] as? NSMutableDictionary
                                            {
                                                if let myParent = self.parent as? CommentsViewController {
                                                    myParent.delegateComments?.countLikeandComments(data: dic)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if isQuickVideoDeviceVCExist == true
                        {
                            self.navigationController?.popViewController(animated: true)
                        }
                        else
                        {
                            var indexSelectedVideo = -1
                            for (index, feed) in feedArrayTikTok.enumerated()
                            {
                                if feed["action_id"] as! Int == activityFeed["action_id"] as! Int
                                {
                                    indexSelectedVideo = index
                                }
                            }
                            if indexSelectedVideo == -1
                            {
                                feedAddInTikTokArray()
                                for (index, feed) in feedArrayTikTok.enumerated()
                                {
                                    if feed["action_id"] as! Int == activityFeed["action_id"] as! Int
                                    {
                                        indexSelectedVideo = index
                                    }
                                }
                            }
                            if indexSelectedVideo == -1
                            {
                                indexSelectedVideo = 0
                                feedArrayTikTok.append(activityFeed)
                            }
                            else
                            {
                                feedArrayTikTok[indexSelectedVideo] = activityFeed
                            }
                            if var viewControllers = self.navigationController?.viewControllers
                            {
                                for controller in viewControllers
                                {
                                    if controller is QuickVideoDeviceVC
                                    {
                                        viewControllers.remove(object: controller)
                                        self.navigationController?.viewControllers = viewControllers
                                    }
                                }
                            }
                            // print(activityFeed)
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc  = storyboard.instantiateViewController(withIdentifier: "QuickVideoDeviceVC") as! QuickVideoDeviceVC
                            vc.feedShowingFrom = feedShowingFrom
                            
                            vc.indexSelectedVideo = indexSelectedVideo
                            vc.delegateTikTokVidyoPlayer = self
                            vc.currentPlayer = sharedVideoPlayer.currentVideoContainer()?.player
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true)
                        }
                    }
                    else
                    {
                        if enabledModules.contains("sitevideo")
                        {
                            SitevideoObject().redirectToAdvVideoProfilePage(self,videoId: (attachment[0] as! NSDictionary)["attachment_id"] as! Int,videoType:(attachment[0] as! NSDictionary)["attachment_video_type"] as! Int,videoUrl: (attachment[0] as! NSDictionary)["attachment_video_url"] as! String)
                        }
                        else
                        {
                            VideoObject().redirectToVideoProfilePage(self,videoId: (attachment[0] as! NSDictionary)["attachment_id"] as! Int,videoType: (attachment[0] as! NSDictionary)["attachment_video_type"] as! Int,videoUrl: (attachment[0] as! NSDictionary)["attachment_video_url"] as! String)
                        }
                    }
                    
                }
            }
            break
            
        case "poll":
            let presentedVC = PollProfileViewController()
            presentedVC.pollId = objectID
            self.navigationController?.pushViewController(presentedVC, animated: false)
            break
            
        case "forum_topic":
            
            let presentedVC = ForumTopicViewController()
            let dic = activityFeed["object"] as? NSDictionary
            let url =  dic!["url"] as! String
            let arr = url.components(separatedBy: "/")
            let count = arr.count - 1
            presentedVC.slug = arr[count]
            presentedVC.topicId = dic!["topic_id"] as! Int
            presentedVC.topicName = dic!["title"] as! String
            navigationController?.pushViewController(presentedVC, animated: true)
            break
            
        case "forum":
            let presentedVC = ForumsViewPageController()
            if let params = activityFeed["action_type_body_params"] as? NSArray {
                for param in params {
                    if let dic = param as? NSDictionary {
                        if let type = dic["type"] as? String, type == "forum" {
                            presentedVC.forumId = "\(dic["id"]!)"
                            presentedVC.forumName = dic["label"] as? String
                            presentedVC.forumSlug = dic["slug"] as? String
                        }
                    }
                }
            }
            
            navigationController?.pushViewController(presentedVC, animated: true)
            
        case "album_photo":
            // TODO: Need Changes Here
            let pv = ActivityFeedPhotoViewController()
            if let attchmentarr = activityFeed["attachment"] as? NSArray
            {
                pv.photoAttachmentArray = attchmentarr
            }
            pv.photoIndex = 0
            if let photo_type = attechmentDic["attachment_type"] as? String{
                pv.photoType = "\(photo_type)"
                
            }else{
                pv.photoType = "album_photo"
            }
            let nativationController = UINavigationController(rootViewController: pv)
            nativationController.modalPresentationStyle = .fullScreen
            present(nativationController, animated:true, completion: nil)
            break
        case "classified":
            
            ClassifiedObject().redirectToProfilePage(self, id: objectID)
            break
            
        case "music_playlist" :
            
            MusicObject().redirectToPlaylistPage(self,id: objectID)
            break
            
        case "music_playlist_song":
            
            let PlaylistId = attechmentDic["playlist_id"] as! Int
            MusicObject().redirectToPlaylistPage(self,id: PlaylistId)
            break
            
        case "core_link":
            
            fromExternalWebView = true
            let presentedVC = ExternalWebViewController()
            presentedVC.url = attechmentDic["uri"] as! String
            presentedVC.fromDashboard = false
            navigationController?.pushViewController(presentedVC, animated: true)
            break
            
        case "sitereview_review":
            
            if let objectDictionary = activityFeed["object"] as? NSDictionary
            {
                if let objectTypeId = objectDictionary["listingtype_id"] as? Int
                {
                    listingTypeId = objectTypeId
                    
                }
                else if let objectTypeId = attechmentDic["listingtype_id"] as? Int
                {
                    listingTypeId = objectTypeId
                }
            }
            if listingTypeId != 0
            {
                
                let presentedVC = UserReviewViewController()
                presentedVC.mytitle = activityFeed["feed_title"] as! String
                if attechmentDic["id"] != nil {
                    let product_id =   attechmentDic["id"] as! Int//activityFeed["object_id"] as? Int
                    presentedVC.subjectId = "\(product_id)"
                }
                presentedVC.listingTypeId = listingTypeId
                presentedVC.contentType = "listings"
                navigationController?.pushViewController(presentedVC, animated: true)
                
            }
            
        case "sitereview_listing":
            
            if feedtype == "sitereview_review"
            {
                
                if let objectDictionary = activityFeed["object"] as? NSDictionary
                {
                    if let objectTypeId = objectDictionary["listingtype_id"] as? Int
                    {
                        listingTypeId = objectTypeId
                        
                    }
                    else if let objectTypeId = attechmentDic["listingtype_id"] as? Int
                    {
                        listingTypeId = objectTypeId
                    }
                }
                if listingTypeId != 0
                {
                    
                    let presentedVC = UserReviewViewController()
                    presentedVC.mytitle = activityFeed["feed_title"] as! String
                    presentedVC.subjectId = "\(objectID)"
                    presentedVC.listingTypeId = listingTypeId
                    presentedVC.contentType = "listings"
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                
            }
            else if (feedtype == "sitereview_listing")
            {
                if let objectDictionary = activityFeed["object"] as? NSDictionary
                {
                    if let objectTypeId = objectDictionary["listingtype_id"] as? Int
                    {
                        listingTypeId = objectTypeId
                        
                    }
                    else if let objectTypeId = attechmentDic["listingtype_id"] as? Int
                    {
                        listingTypeId = objectTypeId
                    }
                }
                
                if listingTypeId != 0
                {
                    var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingTypeId]!
                    let viewType = tempBrowseViewTypeDic["viewType"]!
                    SiteMltObject().redirectToMltProfilePage(self ,subjectType : "sitereview_listing" , listingTypeIdValue : listingTypeId , listingIdValue : "\(objectID)" , viewTypeValue : viewType)
                    
                    
                }
                
            }
            break
        case "siteevent_event":
            if (activityFeed["attachment"] as? NSArray) != nil
            {
                if attechmentDic["attachment_type"] as! String == "siteevent_review"
                {
                    let presentedVC = UserReviewViewController()
                    presentedVC.mytitle = activityFeed["feed_title"] as! String
                    presentedVC.subjectId = "\(objectID)"
                    presentedVC.contentType = "advancedevents"
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                else
                {
                    
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "advancedevents"
                    presentedVC.subjectId = "\(objectID)"
                    self.navigationController?.pushViewController(presentedVC, animated: true)
                }
                
            }
            else
            {
                
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "advancedevents"
                presentedVC.subjectId = "\(objectID)"
                self.navigationController?.pushViewController(presentedVC, animated: true)
            }
            break
        case "sitepage_page":
            
            if (activityFeed["attachment"] as? NSArray) != nil
            {
                
                if attechmentDic["attachment_type"] as! String == "sitepagereview_review"
                {
                    let presentedVC = PageReviewViewController()
                    presentedVC.mytitle = activityFeed["feed_title"] as! String
                    presentedVC.subjectId = "\(objectID)"
                    presentedVC.contentType = "Pages"
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                else
                {
                    
                    SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: "\(objectID)")
                    
                }
            }
            else
            {
                SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: "\(objectID)")
                
            }
            break
            
        case "sitepagereview_review":
            
            let presentedVC = PageReviewViewController()
            presentedVC.mytitle = activityFeed["feed_title"] as! String
            presentedVC.subjectId = "\(objectID)"
            presentedVC.contentType = "Pages"
            navigationController?.pushViewController(presentedVC, animated: true)
            break
            
        case "sitegroup_group":
            
            if let attachment = activityFeed["attachment"] as? NSArray
            {
                
                if attechmentDic["attachment_type"] != nil && attechmentDic["attachment_type"] as! String == "sitegroupreview_review"
                {
                    let presentedVC = PageReviewViewController()
                    presentedVC.mytitle = (attachment[0] as! NSDictionary)["title"] as! String//activityFeed["feed_title"] as! String
                    presentedVC.subjectId = "\(objectID)"
                    presentedVC.contentType = "sitegroup"
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                else if (attechmentDic["attachment_type"] != nil && attechmentDic["attachment_type"] as! String == "video"){
                    
                    if enabledModules.contains("sitevideo")
                    {
                        SitevideoObject().redirectToAdvVideoProfilePage(self,videoId: (attachment[0] as! NSDictionary)["attachment_id"] as! Int,videoType:3,videoUrl: (attachment[0] as! NSDictionary)["attachment_video_url"] as! String)
                    }
                    else
                    {
                        VideoObject().redirectToVideoProfilePage(self,videoId: (attachment[0] as! NSDictionary)["attachment_id"] as! Int,videoType: attechmentDic["attachment_video_type"] as! Int,videoUrl: attechmentDic["attachment_video_url"] as! String)
                    }
                    
                }
                else if attechmentDic["attachment_type"] != nil && attechmentDic["attachment_type"] as! String == "core_link"{
                    fromExternalWebView = true
                    let presentedVC = ExternalWebViewController()
                    presentedVC.url = attechmentDic["uri"] as! String
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let navigationController = UINavigationController(rootViewController: presentedVC)
                    self.present(navigationController, animated: true, completion: nil)
                    
                }
                else
                {
                    SiteAdvGroupObject().redirectToAdvGroupProfilePage(self, subject_type: "sitegroup_group", subject_id: "\(objectID)")
                }
            }
            else{
                SiteAdvGroupObject().redirectToAdvGroupProfilePage(self, subject_type: "sitegroup_group", subject_id: "\(objectID)")
                
            }
            break
        case "sitereview_wishlist":
            
            let presentedVC = WishlistDetailViewController()
            if let attachment = activityFeed["attachment"] as? NSArray{
                if let wishlist_id = (attachment[0] as! NSDictionary)["attachment_id"] as? Int{
                    presentedVC.subjectId = wishlist_id
                }
                if let wishlist_Title = (attachment[0] as! NSDictionary)["title"] as? String{
                    presentedVC.wishlistName = wishlist_Title
                }
                if let wishlist_desc = (attachment[0] as! NSDictionary)["body"] as? String{
                    presentedVC.descriptionWishlist = wishlist_desc
                }
            }
            navigationController?.pushViewController(presentedVC, animated: true)
            //            if let objectDictionary = activityFeed["object"] as? NSDictionary
            //            {
            //
            //                presentedVC.subjectId  = objectID
            //                if let tempBody = objectDictionary["body"] as? String{
            //                    presentedVC.descriptionWishlist = tempBody
            //                }
            //
            //                if let tempTitle = objectDictionary["title"] as? String{
            //                    presentedVC.wishlistName = tempTitle
            //                }
            //                navigationController?.pushViewController(presentedVC, animated: true)
            //            }
            
            break
            
        case "sitevideo_channel":
            SitevideoObject().redirectToChannelProfilePage(self, videoId: "\(objectID)",subjectType: feedtype)
            break
            
        case "sitevideo_playlist":
            SitevideoObject().redirectToPlaylistProfilePage(self, playlistId: "\(objectID)",subjectType: feedtype)
            break
            
        case  "sitestoreproduct_product":
            if (activityFeed["attachment"] as? NSArray) != nil
            {
                
                if attechmentDic["attachment_type"] as! String == "sitestoreproduct_product"
                {
                    if let product_id = attechmentDic["attachment_id"] as? Int{
                        SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id:"\(product_id)")
                    }
                    
                }
                    
                else if attechmentDic["attachment_type"] as! String == "sitestore_store"
                {
                    if let product_id = attechmentDic["attachment_id"] as? Int{
                        SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: "\(product_id)")
                        
                    }
                }
                else  if attechmentDic["attachment_type"] as! String == "sitestoreproduct_wishlist"
                {
                    let presentedVC = WishlistDetailViewController()
                    presentedVC.productOrOthers = true
                    if let wishlist_id = attechmentDic["attachment_id"] as? Int{
                        presentedVC.subjectId = wishlist_id
                    }
                    if let wishlist_Title = attechmentDic["title"] as? String{
                        presentedVC.wishlistName = wishlist_Title
                    }
                    if let wishlist_desc = attechmentDic["body"] as? String{
                        presentedVC.descriptionWishlist = wishlist_desc
                    }
                    //                    if let productInfo = activityFeed["object"] as? NSDictionary {
                    //
                    ////                        if let wishlist_id =  productInfo["wishlist_id"] as? Int{
                    ////                            presentedVC.subjectId = wishlist_id
                    ////                        }
                    //                        presentedVC.wishlistName = productInfo["title"] as? String
                    //                        presentedVC.descriptionWishlist = productInfo["body"] as? String
                    //                    }
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                else if attechmentDic["attachment_type"] as! String == "sitestoreproduct_order"
                {
                    SiteStoreObject().redirectToMyStore(viewController: self)
                }
                    
                else if attechmentDic["attachment_type"] as! String == "sitestoreproduct_review"
                {
                    if (attechmentDic["attachment_id"] as? Int) != nil{
                        let presentedVC = PageReviewViewController()
                        //  if (activityFeed["object"] as? NSDictionary) != nil {
                        if attechmentDic["id"] != nil {
                            let product_id =   attechmentDic["id"] as! Int//activityFeed["object_id"] as? Int
                            
                            presentedVC.subjectId = "\(product_id)"
                        }
                        //  }
                        presentedVC.mytitle = ""
                        presentedVC.contentType = "product"//"siteproduct_review"
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    
                    
                }
                
            }
            else
            {
                if let productInfo = activityFeed["object"] as? NSDictionary {
                    let product_id = "\(productInfo["product_id"]!)"
                    SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id:product_id)
                    
                    
                }
                
            }
        case   "sitestoreproduct_wishlist":
            if let attachment = activityFeed["attachment"] as? NSArray
            {
                
                if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestoreproduct_product"
                {
                    if let product_id = (attachment[0] as! NSDictionary)["attachment_id"] as? Int{
                        SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id:"\(product_id)")
                    }
                    
                }
                else if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestore_store"
                {
                    if let product_id = (attachment[0] as! NSDictionary)["attachment_id"] as? Int{
                        SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: "\(product_id)")
                    }
                }
                else  if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestoreproduct_wishlist"
                {
                    let presentedVC = WishlistDetailViewController()
                    presentedVC.productOrOthers = true
                    if let wishlist_id = (attachment[0] as! NSDictionary)["attachment_id"] as? Int{
                        presentedVC.subjectId = wishlist_id
                    }
                    if let wishlist_Title = (attachment[0] as! NSDictionary)["title"] as? String{
                        presentedVC.wishlistName = wishlist_Title
                    }
                    if let wishlist_desc = (attachment[0] as! NSDictionary)["body"] as? String{
                        presentedVC.descriptionWishlist = wishlist_desc
                    }
                    //                    if let productInfo = activityFeed["object"] as? NSDictionary {
                    //
                    ////                        if let wishlist_id =  productInfo["wishlist_id"] as? Int{
                    ////                            presentedVC.subjectId = wishlist_id
                    ////                        }
                    //                        presentedVC.wishlistName = productInfo["title"] as? String
                    //                        presentedVC.descriptionWishlist = productInfo["body"] as? String
                    //                    }
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                else if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestoreproduct_order"
                {
                    SiteStoreObject().redirectToMyStore(viewController: self)
                }
                    
                else if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestoreproduct_review"
                {
                    if ((attachment[0] as! NSDictionary)["attachment_id"] as? Int) != nil{
                        let presentedVC = PageReviewViewController()
                        if (activityFeed["object"] as? NSDictionary) != nil {
                            let product_id =   activityFeed["object_id"] as? Int
                            presentedVC.subjectId = "\(product_id!)"
                        }
                        
                        presentedVC.mytitle = ""
                        presentedVC.contentType = "product"//"siteproduct_review"
                        navigationController?.pushViewController(presentedVC, animated: true)
                        
                    }
                    
                    
                }
            }
            else{
                let presentedVC = WishlistDetailViewController()
                presentedVC.productOrOthers = true
                if let attachment = activityFeed["attachment"] as? NSArray{
                    if let wishlist_id = (attachment[0] as! NSDictionary)["attachment_id"] as? Int{
                        presentedVC.subjectId = wishlist_id
                    }
                    if let wishlist_Title = (attachment[0] as! NSDictionary)["title"] as? String{
                        presentedVC.wishlistName = wishlist_Title
                    }
                    if let wishlist_desc = (attachment[0] as! NSDictionary)["body"] as? String{
                        presentedVC.descriptionWishlist = wishlist_desc
                    }
                }
                //                if let productInfo = activityFeed["object"] as? NSDictionary {
                //
                ////                    if let wishlist_id =  productInfo["wishlist_id"] as? Int{
                ////                        presentedVC.subjectId = wishlist_id
                ////                    }
                //                    presentedVC.wishlistName = productInfo["title"] as? String
                //                    presentedVC.descriptionWishlist = productInfo["body"] as? String
                //                }
                
                navigationController?.pushViewController(presentedVC, animated: true)
                
            }
            break
        case "sitestore_store":
            
            if let attachment = activityFeed["attachment"] as? NSArray
            {
                
                if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestoreproduct_product"
                {
                    if let product_id = (attachment[0] as! NSDictionary)["attachment_id"] as? Int{
                        SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id:"\(product_id)")
                    }
                    
                    
                }
                else if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestore_store"
                {
                    if let product_id = (attachment[0] as! NSDictionary)["attachment_id"] as? Int{
                        SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: "\(product_id)")
                        
                    }
                }
                else  if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestoreproduct_wishlist"
                {
                    
                    
                    let presentedVC = WishlistDetailViewController()
                    presentedVC.productOrOthers = true
                    if let wishlist_id = (attachment[0] as! NSDictionary)["attachment_id"] as? Int{
                        presentedVC.subjectId = wishlist_id
                    }
                    if let wishlist_Title = (attachment[0] as! NSDictionary)["title"] as? String{
                        presentedVC.wishlistName = wishlist_Title
                    }
                    if let wishlist_desc = (attachment[0] as! NSDictionary)["body"] as? String{
                        presentedVC.descriptionWishlist = wishlist_desc
                    }
                    //                    if let productInfo = activityFeed["object"] as? NSDictionary {
                    //
                    ////                        if let wishlist_id =  productInfo["wishlist_id"] as? Int{
                    ////                            presentedVC.subjectId = wishlist_id
                    ////
                    ////
                    ////                        }
                    //                        presentedVC.wishlistName = productInfo["title"] as? String
                    //                        presentedVC.descriptionWishlist = productInfo["body"] as? String
                    //                    }
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                    
                    
                else if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestoreproduct_order"
                {
                    SiteStoreObject().redirectToMyStore(viewController: self)
                }
                    
                else if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestoreproduct_review"
                {
                    if ((attachment[0] as! NSDictionary)["attachment_id"] as? Int) != nil{
                        let presentedVC = PageReviewViewController()
                        if (activityFeed["object"] as? NSDictionary) != nil {
                            let product_id =   activityFeed["object_id"] as? Int
                            presentedVC.subjectId = "\(product_id!)"
                            
                        }
                        //                                            presentedVC.reviewId = review_id
                        presentedVC.mytitle = ""
                        presentedVC.contentType = "product"//"siteproduct_review"
                        navigationController?.pushViewController(presentedVC, animated: true)
                        
                    }
                    
                    
                }
                
            }
            else{
                if let storeInfo = activityFeed["object"] as? NSDictionary {
                    let store_id = "\(storeInfo["store_id"]!)"
                    SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: store_id)
                }
            }
            break
        case "sitestoreproduct_review" :
            if let attachment = activityFeed["attachment"] as? NSArray
            {
                if ((attachment[0] as! NSDictionary)["attachment_id"] as? Int) != nil{
                    let presentedVC = PageReviewViewController()
                    if attechmentDic["id"] != nil {
                        let product_id =   attechmentDic["id"] as! Int//activityFeed["object_id"] as? Int
                        presentedVC.subjectId = "\(product_id)"
                    }
                    //                                            presentedVC.reviewId = review_id
                    presentedVC.mytitle = ""
                    presentedVC.contentType = "product"//"siteproduct_review"
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
            }
        case  "sitestoreproduct_order" :
            SiteStoreObject().redirectToMyStore(viewController: self)
            break
            
        case "sitereaction_sticker":
            //print("Sticker pressed")
            break
            
        case "stories":
            
            var adsId : Int!
            if(activityFeed["adsId"] is String )
            {
                adsId =  Int(activityFeed["adsId"]! as! String)
            }
            let dic = communityAdsValues[adsId] as! NSDictionary
            let resourceId = dic["resource_id"] as! Int
            if dic["resource_type"] != nil
            {
                let resourceType = dic["resource_type"] as! String?
                switch resourceType! {
                case "video":
                    if enabledModules.contains("sitevideo")
                    {
                        SitevideoObject().redirectToAdvVideoProfilePage(self,videoId: resourceId,videoType:dic["video_type"] as! Int,videoUrl: dic["video_url"] as! String)
                    }
                    else
                    {
                        VideoObject().redirectToVideoProfilePage(self,videoId: resourceId,videoType: dic["video_type"] as! Int,videoUrl: dic["video_url"] as! String)
                    }
                    break
                case "blog":
                    BlogObject().redirectToBlogDetailPage(self,blogId: resourceId ,title: "")
                    break
                case "classified":
                    ClassifiedObject().redirectToProfilePage(self, id: resourceId )
                    break
                case "album":
                    let presentedVC = AlbumProfileViewController()
                    presentedVC.albumId = "\(resourceId)"
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                    break
                case "music_playlist":
                    MusicObject().redirectToPlaylistPage(self,id: resourceId )
                    break
                case "poll":
                    let presentedVC = PollProfileViewController()
                    presentedVC.pollId =   resourceId as Int?
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                    break
                case "sitepage_page":
                    SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: "\(resourceId)" )
                    break
                case "group":
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "group"
                    presentedVC.subjectId =  "\(resourceId)"
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                    break
                case "event":
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "event"
                    presentedVC.subjectId = "\(resourceId)"
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                    break
                case "siteevent_event":
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "advancedevents"
                    presentedVC.subjectId = "\(resourceId)"
                    self.navigationController?.pushViewController(presentedVC, animated: true)
                    break
                case "sitestoreproduct_product":
                    SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id: "\(resourceId)" )
                    break
                case "sitestore_store":
                    SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: "\(resourceId)" )
                    break
                    
                default:
                    break
                }
                
                
            }
            
            break
            
        case "activity_action":
            let presentedVC = FeedViewPageViewController()
            presentedVC.action_id = "\(objectID)"
            navigationController?.pushViewController(presentedVC, animated: true)
            
            
            //                likeCommentContent_id = objectID
            //                likeCommentContentType = "activity_action"
            //                let presentedVC = CommentsViewController()
            //                presentedVC.openCommentTextView = 0
            //                presentedVC.activityfeedIndex = feedIndex
            //                presentedVC.activityFeedComment = true
            //                presentedVC.fromActivityFeed = true
            //                presentedVC.commentPermission = 1
            //                // add
            //                presentedVC.commentFeedArray =  globalArrayFeed
            //
            //                if feedShowingFrom == "ActivityFeed"
            //                {
            //                    presentedVC.activityFeedComment = true
            //                    presentedVC.userActivityFeedComment = false
            //                    presentedVC.contentActivityFeedComment = false
            //
            //                }
            //                else if feedShowingFrom == "UserFeed"
            //                {
            //
            //                    presentedVC.activityFeedComment = false
            //                    presentedVC.userActivityFeedComment = true
            //                    presentedVC.contentActivityFeedComment = false
            //                }
            //                else
            //                {
            //                    presentedVC.activityFeedComment = false
            //                    presentedVC.userActivityFeedComment = false
            //                    presentedVC.contentActivityFeedComment = true
            //                }
            //
            //                // add
            //                presentedVC.actionIdDelete = action_id
            //                presentedVC.actionId = objectID
            //                presentedVC.reactionsIcon = reactionsIcon
            //                presentedVC.fromSingleFeed = true
            //                presentedVC.isComingFromAAF = true
            //                presentedVC.commentTabelHeight = dynamicRowHeight[action_id]!
            //                self.navigationController?.pushViewController(presentedVC, animated: true)
            break
            
            
        default:
            
            if let attachmentArray = activityFeed["attachment"] as? NSArray {
                if let feed = attachmentArray[0] as? NSDictionary
                {
                    if let objectUrl = feed["uri"] as? String {
                        fromExternalWebView = true
                        let presentedVC = ExternalWebViewController()
                        presentedVC.url = objectUrl
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let navigationController = UINavigationController(rootViewController: presentedVC)
                        self.present(navigationController, animated: true, completion: nil)
                    }
                }
            }
            else if let objectDictionary = activityFeed["object"] as? NSDictionary{
                if let objectUrl = objectDictionary["url"] as? String{
                    fromExternalWebView = true
                    let presentedVC = ExternalWebViewController()
                    presentedVC.url = objectUrl
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let navigationController = UINavigationController(rootViewController: presentedVC)
                    self.present(navigationController, animated: true, completion: nil)
                }
                
            }
        }
        
    }
    @objc func openSingleImage(sender: UIButton)
    {
        let activityFeed = globalArrayFeed[sender.tag] as! NSDictionary
        ////print(activityFeed)
        if let attachment = activityFeed["attachment"] as? NSArray
        {
            if ((attachment[0] as! NSDictionary)["attachment_type"] as! String).range(of: "_photo") != nil
            {
                let pv = ActivityFeedPhotoViewController()
                pv.photoAttachmentArray = attachment
                pv.photoIndex = 0
                pv.feedDic = activityFeed
                pv.feedposition = sender.tag
                if feedShowingFrom == "ActivityFeed"
                {
                    if let feedMenu = activityFeed["feed_menus"] as? NSArray, feedMenu.count > 0 {
                        if let linkDic = feedMenu[0] as? NSDictionary {
                            if let link = linkDic["feed_link"] as? String, link != "" {
                                pv.feedLinkUrl = link
                            }
                        }
                    }
                    pv.activityFeedComment = true
                    pv.userActivityFeedComment = false
                    pv.contentActivityFeedComment = false
                    
                }
                else if feedShowingFrom == "UserFeed"
                {
                    if let feedMenu = activityFeed["feed_menus"] as? NSArray, feedMenu.count > 0 {
                        if let linkDic = feedMenu[0] as? NSDictionary {
                            if let link = linkDic["feed_link"] as? String, link != "" {
                                pv.feedLinkUrl = link
                            }
                        }
                    }
                    pv.activityFeedComment = false
                    pv.userActivityFeedComment = true
                    pv.contentActivityFeedComment = false
                }
                else
                {
                    pv.activityFeedComment = false
                    pv.userActivityFeedComment = false
                    pv.contentActivityFeedComment = true
                }
                if let photo_type = (attachment[0] as! NSDictionary)["attachment_type"] as? String
                {
                    pv.photoType = "\(photo_type)"
                    
                }
                else
                {
                    pv.photoType = "album_photo"
                    
                }
                let nativationController = UINavigationController(rootViewController: pv)
                nativationController.modalPresentationStyle = .fullScreen
                present(nativationController, animated:true, completion: nil)
                
                
            }
            else if activityFeed["feed_Type"] as! String == "share"
            {
                if let object_type_string = activityFeed["share_params_type"] as? String
                {
                    if object_type_string.range(of:"_photo") != nil
                    {
                        let pv = ActivityFeedPhotoViewController()
                        pv.photoAttachmentArray = attachment
                        pv.photoIndex = 0
                        pv.feedDic = activityFeed
                        pv.feedposition = sender.tag
                        if let photo_type = activityFeed["share_params_type"] as? String{
                            pv.photoType = "\(photo_type)"
                        }
                        else
                        {
                            pv.photoType = "album_photo"
                        }
                        let nativationController = UINavigationController(rootViewController: pv)
                        nativationController.modalPresentationStyle = .fullScreen
                        present(nativationController, animated:true, completion: nil)
                        
                    }
                    
                }
            }
            else
            {
                
                if let objectDictionary = activityFeed["object"] as? NSDictionary{
                    if let objectUrl = objectDictionary["url"] as? String{
                        
                        fromExternalWebView = true
                        let presentedVC = ExternalWebViewController()
                        presentedVC.url = objectUrl
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let navigationController = UINavigationController(rootViewController: presentedVC)
                        self.present(navigationController, animated: true, completion: nil)
                    }
                }
                
            }
        }
        
    }
    @objc func handleTapped(recognizer: UITapGestureRecognizer) {
        currentCell = (recognizer.view?.tag)!
        
        let tapPositionOneFingerTap = recognizer.location(in: nil)
        var count  = 0
        guttermenuoption.removeAll(keepingCapacity: false)
        if openSideMenu{
            openSideMenu = false
            
            return
        }
        let feed = globalArrayFeed[currentCell] as! NSDictionary
        if let feed_menu = feed["feed_menus"] as? NSArray{
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
        
        let heightOfPopoverTableView : CGFloat = CGFloat(count) * 50.0
        if((view.bounds.height - tapPositionOneFingerTap.y) > heightOfPopoverTableView) {
            let startPoint = CGPoint(x: self.view.frame.width - 15, y: tapPositionOneFingerTap.y )
            self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
            popoverTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: self.view.frame.width, height: heightOfPopoverTableView),style: .grouped)
            popoverTableView.delegate = self
            popoverTableView.dataSource = self
            popoverTableView.isScrollEnabled = false
            // For ios 11 spacing issue below the navigation controller
            if #available(iOS 11.0, *) {
                self.popoverTableView.estimatedSectionHeaderHeight = 0
                
            }
            popoverTableView.tag = 11
            popover.show(popoverTableView, point: startPoint)
            popoverTableView.reloadData()
            
            
        }
        else
        {
            
            let heightt : CGFloat = CGFloat(count) * 50.0
            let startPoint = CGPoint(x: self.view.frame.width - 15, y: tapPositionOneFingerTap.y )
            if tableViewFrameType != "CommentsViewController"
            {
                self.popover = Popover(options: self.popoverOptionsUp, showHandler: nil, dismissHandler: nil)
            }
            else{
                self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
            }
            popoverTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: self.view.frame.width, height: heightt))
            popoverTableView.delegate = self
            popoverTableView.dataSource = self
            popoverTableView.isScrollEnabled = false
            // For ios 11 spacing issue below the navigation controller
            if #available(iOS 11.0, *) {
                self.popoverTableView.estimatedSectionHeaderHeight = 0
                
            }
            popoverTableView.tag = 11
            popover.show(popoverTableView, point: startPoint)
            popoverTableView.reloadData()
        }
    }
    
    // MARK: Photo Redirection
    @objc func firstPhotoClick(sender:UIButton){
        let activityFeed = globalArrayFeed[sender.tag] as! NSDictionary
        if let attachment = activityFeed["attachment"] as? NSArray{
            let pv = ActivityFeedPhotoViewController()
            pv.photoAttachmentArray = attachment
            pv.photoIndex = 0
            pv.feedDic = activityFeed
            pv.feedposition = sender.tag
            if feedShowingFrom == "ActivityFeed"
            {
                pv.activityFeedComment = true
                pv.userActivityFeedComment = false
                pv.contentActivityFeedComment = false
                
            }
            else if feedShowingFrom == "UserFeed"
            {
                
                pv.activityFeedComment = false
                pv.userActivityFeedComment = true
                pv.contentActivityFeedComment = false
            }
            else
            {
                pv.activityFeedComment = false
                pv.userActivityFeedComment = false
                pv.contentActivityFeedComment = true
            }
            if let photo_type = (attachment[0] as! NSDictionary)["attachment_type"] as? String{
                pv.photoType = "\(photo_type)"
            }else{
                pv.photoType = "album_photo"
                
            }
            let nativationController = UINavigationController(rootViewController: pv)
            nativationController.modalPresentationStyle = .fullScreen
            present(nativationController, animated:true, completion: nil)
        }
        
        
    }
    
    @objc func secondPhotoClick(sender:UIButton){
        let activityFeed = globalArrayFeed[sender.tag] as! NSDictionary
        if let attachment = activityFeed["attachment"] as? NSArray{
            let pv = ActivityFeedPhotoViewController()
            pv.photoAttachmentArray = attachment
            pv.photoIndex = 1
            pv.feedDic = activityFeed
            pv.feedposition = sender.tag
            if feedShowingFrom == "ActivityFeed"
            {
                pv.activityFeedComment = true
                pv.userActivityFeedComment = false
                pv.contentActivityFeedComment = false
                
            }
            else if feedShowingFrom == "UserFeed"
            {
                
                pv.activityFeedComment = false
                pv.userActivityFeedComment = true
                pv.contentActivityFeedComment = false
            }
            else
            {
                pv.activityFeedComment = false
                pv.userActivityFeedComment = false
                pv.contentActivityFeedComment = true
            }
            if let photo_type = (attachment[0] as! NSDictionary)["attachment_type"] as? String{
                pv.photoType = "\(photo_type)"
            }else{
                pv.photoType = "album_photo"
            }
            let nativationController = UINavigationController(rootViewController: pv)
            nativationController.modalPresentationStyle = .fullScreen
            present(nativationController, animated:true, completion: nil)
        }
        
    }
    
    @objc func thirdPhotoClick(sender:UIButton){
        let activityFeed = globalArrayFeed[sender.tag] as! NSDictionary
        if let attachment = activityFeed["attachment"] as? NSArray{
            let pv = ActivityFeedPhotoViewController()
            pv.photoAttachmentArray = attachment
            pv.photoIndex = 2
            pv.feedDic = activityFeed
            pv.feedposition = sender.tag
            if feedShowingFrom == "ActivityFeed"
            {
                pv.activityFeedComment = true
                pv.userActivityFeedComment = false
                pv.contentActivityFeedComment = false
                
            }
            else if feedShowingFrom == "UserFeed"
            {
                
                pv.activityFeedComment = false
                pv.userActivityFeedComment = true
                pv.contentActivityFeedComment = false
            }
            else
            {
                pv.activityFeedComment = false
                pv.userActivityFeedComment = false
                pv.contentActivityFeedComment = true
            }
            if let photo_type = (attachment[0] as! NSDictionary)["attachment_type"] as? String{
                pv.photoType = "\(photo_type)"
            }else{
                pv.photoType = "album_photo"
            }
            let nativationController = UINavigationController(rootViewController: pv)
            nativationController.modalPresentationStyle = .fullScreen
            present(nativationController, animated:true, completion: nil)
            
        }
        
    }
    
    @objc func multiplePhotoClick(sender: UITapGestureRecognizer){
        //using sender, we can get the point in respect to the table view
        let tapLocation = sender.location(in:self.tableView)
        
        //using the tapLocation, we retrieve the corresponding indexPath
        let indexPath = self.tableView.indexPathForRow(at:tapLocation)
        
        
        //finally, we //print out the value
        if var rowIndexPath = (indexPath?.row){
            
            if kFrequencyAdsInCells_feeds > 4 && nativeAdArray.count > 0 && globalArrayFeed.count > kFrequencyAdsInCells_feeds-1
            {
                rowIndexPath = rowIndexPath - (rowIndexPath / kFrequencyAdsInCells_feeds)
            }
            
            if rowIndexPath > suggestionSlideshowPosition - 1 && showSuggestions == 1 &&  isHomeFeeds && userSuggestions.count > 0
            {
                rowIndexPath = rowIndexPath - 1
            }
            let activityFeed = globalArrayFeed[rowIndexPath] as! NSDictionary
            
            if let attachment = activityFeed["attachment"] as? NSArray{
                // TODO: Need Changes Here
                let pv = ActivityFeedPhotoViewController()
                pv.photoAttachmentArray = attachment
                pv.photoIndex = 3
                pv.feedDic = activityFeed
                pv.feedposition = rowIndexPath
                if feedShowingFrom == "ActivityFeed"
                {
                    pv.activityFeedComment = true
                    pv.userActivityFeedComment = false
                    pv.contentActivityFeedComment = false
                    
                }
                else if feedShowingFrom == "UserFeed"
                {
                    
                    pv.activityFeedComment = false
                    pv.userActivityFeedComment = true
                    pv.contentActivityFeedComment = false
                }
                else
                {
                    pv.activityFeedComment = false
                    pv.userActivityFeedComment = false
                    pv.contentActivityFeedComment = true
                }
                if let photo_type = (attachment[0] as! NSDictionary)["attachment_type"] as? String{
                    pv.photoType = "\(photo_type)"
                }else{
                    pv.photoType = "album_photo"
                }
                let nativationController = UINavigationController(rootViewController: pv)
                nativationController.modalPresentationStyle = .fullScreen
                present(nativationController, animated:true, completion: nil)
            }
            
        }
        
    }
    // MARK: - Activity Feed Actions for Like, Comment & Share
    
    // Activity Feed Like Action
    @objc func feedMenuLike(sender:UIButton)
    {
        arrowView.isHidden = true
        reactionButtonImage = sender
        refreshLikeUnLike = true
        let feed = globalArrayFeed[sender.tag] as! NSDictionary
        if feed["is_like"] as! Bool == true{
            sender.setTitleColor(textColorMedium, for: .normal)
            sender.tintColor = textColorMedium
            if ReactionPlugin == false {
                animationEffectOnButton(sender)
            }
        }
        else{
            sender.setTitleColor(buttonColor, for: .normal)
            sender.tintColor = buttonColor
            if ReactionPlugin == false {
                animationEffectOnButton(sender)
                
            }
        }
        sender.isEnabled = false
        
        if openSideMenu{
            openSideMenu = false
            
            return
        }
        
        var url = ""
        if feed["is_like"] as! Bool == true{
            url = "advancedactivity/unlike"
        }else{
            url = "advancedactivity/like"
            
            
        }
        DispatchQueue.main.async(execute:  {
            soundEffect("Like")
        })
        
        // ////print(feed)
        if feed["is_like"] as! Bool == false{
            if (ReactionPlugin == true){
                let feed = globalArrayFeed[sender.tag] as! NSDictionary
                let action_id = feed["action_id"] as! Int
                var reaction = ""
                for (k,v) in reactionsDictionary
                {
                    let v = v as! NSDictionary
                    var updatedDictionary = Dictionary<String, AnyObject>()
                    if  (v["reactionicon_id"] as? Int) != nil
                    {
                        if k as! String == "like"
                        {
                            reaction = (v["reaction"] as? String)!
                            updatedDictionary["reactionicon_id"] = v["reactionicon_id"]  as AnyObject?
                            updatedDictionary["caption" ] = v["caption"]  as AnyObject?
                            
                            if let icon  = v["icon"] as? NSDictionary{
                                animateLikeReaction()
                                updatedDictionary["reaction_image_icon"] = icon["reaction_image_icon"] as! String as AnyObject?
                                
                            }
                            var url = ""
                            url = "advancedactivity/like"
                            
                            DispatchQueue.main.async(execute:  {
                                soundEffect("Like")
                                self.updateReaction(url: url,reaction : reaction,action_id  : action_id, updateMyReaction : updatedDictionary as NSDictionary,feedIndex: sender.tag)
                            })
                            
                            
                        }
                    }
                }
                
            }
            else
            {
                
                if let feed_menu = feed["feed_footer_menus"] as? NSDictionary{
                    if let like  = feed_menu["like"] as? NSDictionary{
                        menuOptionSelected = like["name"] as! String
                        updateFeedMenu(parameter: like["urlParams"] as! NSDictionary, url:url, feedIndex: sender.tag )
                    }
                }
            }
            
            
        }
        else
        {
            if (ReactionPlugin == true)
            {
                
                let feed = globalArrayFeed[sender.tag] as! NSDictionary
                let action_id = feed["action_id"] as! Int
                let reaction = ""
                var updatedDictionary = Dictionary<String, AnyObject>()
                updatedDictionary = [ : ]
                
                var url = ""
                url = "advancedactivity/unlike"
                
                DispatchQueue.main.async(execute:  {
                    soundEffect("Like")
                    self.deleteReaction(url: url,reaction : reaction,action_id  : action_id, updateMyReaction : updatedDictionary as NSDictionary,feedIndex: sender.tag)
                })
                
                
                
            }
            else
            {
                
                if let feed_menu = feed["feed_footer_menus"] as? NSDictionary{
                    if let like  = feed_menu["like"] as? NSDictionary{
                        menuOptionSelected = like["name"] as! String
                        updateFeedMenu(parameter: like["urlParams"] as! NSDictionary, url:url, feedIndex: sender.tag )
                    }
                }
            }
        }
        
        
    }
    
    // Perform Comment Action for particular Comment
    @objc func commentAction(_ sender:UIButton){
        let feed = globalArrayFeed[sender.tag] as! NSDictionary
        showComments(feedIndex: sender.tag, openTextView: 1, contentID: feed["action_id"] as! Int)
    }
    
    // Show Like, Comment Info for Feed
    @objc func likeCommentInfo(_ sender:UIButton){
        let feed = globalArrayFeed[sender.tag] as! NSDictionary
        let presentedVC = MembersViewController()
        likeCommentContentType = "activity_action"
        presentedVC.action_idd =  "\(feed["action_id"]!)"
        likeCommentContent_id = "\(feed["action_id"]!)"
        presentedVC.contentType = "activityFeed"
        presentedVC.contentType = "activityFeed"
        navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    // Perform Comment Feed Action
    func showComments(feedIndex: Int, openTextView: Int, contentID: Int ){
        if openSideMenu{
            openSideMenu = false
            
            return
        }
        
        
        // Stop Timer
        if myTimer != nil{
            myTimer.invalidate()
        }
        
        let feed = globalArrayFeed[feedIndex] as! NSDictionary
        if ReactionPlugin == true{
            reactionsIcon.removeAll(keepingCapacity: false)
            if let reactions = feed["feed_reactions"] as? NSDictionary{
                var i = 0
                
                for (_,v) in reactions
                {
                    let tempValueDic = v as! NSDictionary
                    if i <= 2{
                        if let icon = tempValueDic["reaction_image_icon"] as? String{
                            reactionsIcon.append(icon as AnyObject)
                            
                        }
                        
                    }
                    i = i + 1
                }
                
                
            }
            
        }
        // Set Parameters for Activity Feed Comment & Present CommentsViewController
        likeCommentContent_id = "\(contentID)"
        likeCommentContentType = "activity_action"
        let presentedVC = CommentsViewController()
        presentedVC.openCommentTextView = openTextView
        presentedVC.activityfeedIndex = feedIndex
        presentedVC.activityFeedComment = true
        presentedVC.fromActivityFeed = true
        presentedVC.actionIdDelete = action_id
        presentedVC.actionId = "\(contentID)"
        presentedVC.reactionsIcon = reactionsIcon
        presentedVC.fromSingleFeed = true
        presentedVC.isComingFromAAF = true
        presentedVC.commentTabelHeight = dynamicRowHeight[contentID]!
        
        presentedVC.commentPermission = 1 //feed["comment"] as! Int
        // add
        presentedVC.commentFeedArray =  globalArrayFeed
        if feedShowingFrom == "ActivityFeed"
        {
            presentedVC.activityFeedComment = true
            presentedVC.userActivityFeedComment = false
            presentedVC.contentActivityFeedComment = false
            
        }
        else if feedShowingFrom == "UserFeed"
        {
            presentedVC.activityFeedComment = false
            presentedVC.userActivityFeedComment = true
            presentedVC.contentActivityFeedComment = false
        }
        else
        {
            presentedVC.activityFeedComment = false
            presentedVC.userActivityFeedComment = false
            presentedVC.contentActivityFeedComment = true
        }
        
        // add
        self.navigationController?.pushViewController(presentedVC, animated: true)
        
    }
    
    // ActivityFeed Share Option
    @objc func feedMenuShare(sender:UIButton){
        if openSideMenu{
            openSideMenu = false
            
            return
        }
        
        if myTimer != nil{
            myTimer.invalidate()
        }
        
        // Open ShareContentView to Share Feed
        let feed = globalArrayFeed[sender.tag] as! NSDictionary
        if let feed_menu = feed["feed_footer_menus"] as? NSDictionary{
            if let share  = feed_menu["share"] as? NSDictionary{
                self.shareTitle = feed["feed_title"] as? String
                if self.shareTitle.length > 130{
                    self.shareTitle = (self.shareTitle as NSString).substring(to: 130-3)
                    self.shareTitle  = self.shareTitle + "..."
                }
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
                alertController.addAction(UIAlertAction(title:  String(format: NSLocalizedString("Share on %@", comment: ""),app_title), style: .default) { action -> Void in
                    
                    
                    if let attachmentCount = feed["attactment_Count"] as? Int{
                        if attachmentCount > 0
                        {
                            if attachmentCount == 1{
                                if let attachment = feed["attachment"] as? NSArray{
                                    if (attachment[0] as! NSDictionary)["attachment_type"] as! String != "album_photo"{
                                        let presentedVC = AdvanceShareViewController()
                                        presentedVC.param = (share["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                        presentedVC.url = share["url"] as! String
                                        let photoDictionary = (attachment[0] as! NSDictionary)
                                        if let photoMainDictionary = photoDictionary["image_main"] as? NSDictionary {
                                            if let url =  photoMainDictionary["src"] as? String
                                            {
                                                presentedVC.imageString = url
                                            }
                                            
                                        }
                                        if let attachment_title = photoDictionary["title"] as? String{
                                            presentedVC.Sharetitle = attachment_title
                                        }
                                        if let attachment_description = photoDictionary["body"] as? String{
                                            presentedVC.ShareDescription = attachment_description
                                        }
                                        presentedVC.modalPresentationStyle = .fullScreen
                                        let nativationController = UINavigationController(rootViewController: presentedVC)
                                        nativationController.modalPresentationStyle = .fullScreen
                                        self.present(nativationController, animated:true, completion: nil)
                                        
                                    }
                                    else{
                                        let presentedVC = AdvanceShareViewController()
                                        presentedVC.param = (share["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                        presentedVC.url = share["url"] as! String
                                        let photoDictionary = (attachment[0] as! NSDictionary)
                                        if let photoMainDictionary = photoDictionary["image_main"] as? NSDictionary
                                        {
                                            if let url =  photoMainDictionary["src"] as? String
                                            {
                                                presentedVC.imageString = url
                                            }
                                            
                                        }
                                        
                                        if let attachment_title = photoDictionary["title"] as? String{
                                            presentedVC.Sharetitle = attachment_title
                                        }
                                        if let attachment_description = photoDictionary["body"] as? String{
                                            presentedVC.ShareDescription = attachment_description
                                        }
                                        presentedVC.modalPresentationStyle = .fullScreen
                                        let nativationController = UINavigationController(rootViewController: presentedVC)
                                        nativationController.modalPresentationStyle = .fullScreen
                                        self.present(nativationController, animated:true, completion: nil)
                                        
                                    }
                                    
                                }
                                else{
                                    let presentedVC = AdvanceShareViewController()
                                    presentedVC.param = share["urlParams"] as! NSDictionary
                                    presentedVC.url = share["url"] as! String
                                    presentedVC.Sharetitle = feed["feed_title"] as? String
                                    presentedVC.ShareDescription = feed["body"] as? String
                                    presentedVC.imageString = ""
                                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                    self.present(nativationController, animated:true, completion: nil)
                                    
                                }
                            }
                        }
                        else
                        {
                            let presentedVC = AdvanceShareViewController()
                            presentedVC.param = (share["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            presentedVC.url = share["url"] as! String
                            presentedVC.Sharetitle = feed["feed_title"] as? String
                            presentedVC.ShareDescription = feed["body"] as? String
                            presentedVC.imageString = ""
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:true, completion: nil)
                            
                        }
                        
                        
                    }else{
                        let presentedVC = AdvanceShareViewController()
                        presentedVC.param = share["urlParams"] as! NSDictionary
                        presentedVC.url = share["url"] as! String
                        presentedVC.Sharetitle = feed["feed_title"] as? String
                        presentedVC.ShareDescription = feed["body"] as? String
                        presentedVC.imageString = ""
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let nativationController = UINavigationController(rootViewController: presentedVC)
                        self.present(nativationController, animated:true, completion: nil)
                        
                    }
                })
                
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share Outside",comment: ""), style: UIAlertAction.Style.default) { action -> Void in
                    
                    var sharingItems = [AnyObject]()
                    
                    if let text = self.shareTitle {
                        sharingItems.append(text as AnyObject)
                    }
                    if let feedMenu = feed["feed_menus"] as? NSArray, feedMenu.count > 0 {
                        if let linkDic = feedMenu[0] as? NSDictionary {
                            if let link = linkDic["feed_link"] as? String, link != "" {
                                let finalUrl = NSURL(string: link)!
                                sharingItems.append(finalUrl)
                            }
                        }
                    }
                    else if let attachment = feed["attachment"] as? NSArray,attachment.count > 0{
                        if let attachmentDic = attachment[0] as? NSDictionary {
                            if let url = attachmentDic["content_url"] as? String {
                                let finalUrl = NSURL(string: url)!
                                sharingItems.append(finalUrl)
                            }
                            else if let url = attachmentDic["uri"] as? String {
                                let finalUrl = NSURL(string: url)!
                                sharingItems.append(finalUrl)
                            }
                        }
                    }
                    
                    let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
                    activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
                    
                    if (UIDevice.current.userInterfaceIdiom == .phone){
                        
                        if(activityViewController.popoverPresentationController != nil) {
                            activityViewController.popoverPresentationController?.sourceView = self.view;
                            let frame = UIScreen.main.bounds
                            activityViewController.popoverPresentationController?.sourceRect = frame;
                        }
                        
                    }
                    else
                    {
                        
                        let presentationController = activityViewController.popoverPresentationController
                        presentationController?.sourceView = self.view
                        presentationController?.sourceRect = CGRect(x: self.view.bounds.width/2 ,y: self.view.bounds.width/2,width: 0,height: 0)
                        presentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                        
                    }
                    self.present(activityViewController, animated: true, completion: nil)
                    
                })
                
                if  (UIDevice.current.userInterfaceIdiom == .phone){
                    alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
                }
                else
                {
                    // Present Alert as! Popover for iPad
                    alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                    let popover = alertController.popoverPresentationController
                    popover?.sourceView = self.view
                    popover?.sourceRect = CGRect(x: view.bounds.width/2,y: view.bounds.height/2 ,width: 1,height: 1)
                    popover?.permittedArrowDirections = UIPopoverArrowDirection()
                }
                self.present(alertController, animated:true, completion: nil)
                
            }
        }
        
    }
    
    @objc func showUserProfile(sender:UIButton){
        let activityFeed = globalArrayFeed[sender.tag] as! NSDictionary
        var boolvariableforstore = false
        var boolvariableforpage = false
        
        if  let body_param = activityFeed["action_type_body_params"] as? NSArray
        {
            for i in 0 ..< body_param.count
            {
                let body1 = body_param[i] as! NSDictionary
                if body1["search"] as! String == "{item:$object}"
                {
                    if let type = body1["type"] as? String
                    {
                        if type == "sitestore_store"
                        {
                            boolvariableforstore = true
                        }
                        if type == "sitepage_page"
                        {
                            boolvariableforpage = true
                        }
                    }
                }
            }
            
        }
        if boolvariableforstore == true{
            if let storeInfo = activityFeed["object"] as? NSDictionary {
                SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: "\(storeInfo["store_id"]!)")
            }
        }
        else if boolvariableforpage == true
        {
            if let pageInfo = activityFeed["object"] as? NSDictionary
            {
                let objectId = "\(pageInfo["page_id"]!)"
                SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: objectId)
            }
        }
        else
        {
            
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            if(activityFeed["subject_id"] is NSInteger){
                UserId = activityFeed["subject_id"] as! NSInteger
            }
            if let imgUrl = activityFeed["subject_image"] as? String
            {
                presentedVC.strProfileImageUrl = imgUrl
            }
            //            if  let body = activityFeed["object"] as? NSDictionary, let strName = body["owner_title"] as? String
            //            {
            //                presentedVC.strUserName = strName
            //            }
            if  let body_param = activityFeed["action_type_body_params"] as? NSArray
            {
                if  let body1 = body_param[0] as? NSDictionary
                {
                    if let body = body1["label"] as? String
                    {
                        presentedVC.strUserName = body
                    }
                }
            }
            presentedVC.subjectId = "\(UserId!)"
            presentedVC.fromActivity = false
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        scrollViewEmoji.layer.shadowColor = UIColor.black.cgColor
        scrollViewEmoji.layer.borderColor = UIColor.black.cgColor
        arrowView.layer.shadowColor = UIColor.black.cgColor
        
        var scrollViewOrigin: CGFloat = 0
        let  Currentcell = (sender.view?.tag)!
        let activityFeed = globalArrayFeed[(sender.view?.tag)!] as! NSDictionary
        var menuCount = 0
        if activityFeed["comment"] as? Bool == true{
            menuCount = menuCount + 2
            
        }
        if activityFeed["share"] as? Bool == true{
            menuCount = menuCount + 1
            
        }
        let menuItemWidth:CGFloat = (self.view.bounds.width - 40)/CGFloat(menuCount)
        if menuCount == 2 {
            scrollViewOrigin = menuItemWidth/2
        }
        else {
            scrollViewOrigin = 34
        }
        
        
        scrollViewEmoji.backgroundColor = UIColor.black.withAlphaComponent(0.85)//UIColor.clear
        arrowView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        
        let tapLocation = sender.location(in: UIApplication.shared.keyWindow?.parentViewController()?.view)
        scrollViewEmoji.center.x = self.view.center.x
        if sender.state == .began {
            soundEffect("reactions_popup")
            if tapLocation.y < TOPPADING + scrollViewEmoji.frame.height + arrowView.frame.height + 20{
                scrollViewEmoji.frame.origin.y = tapLocation.y + arrowView.frame.height + 20
                arrowView.transform = CGAffineTransform(rotationAngle: .pi)
                arrowView.frame.origin = CGPoint(x: scrollViewOrigin, y: scrollViewEmoji.frame.origin.y - arrowView.frame.height)
                
            }
            else {
                arrowView.transform = .identity
                scrollViewEmoji.frame.origin.y = tapLocation.y - scrollViewEmoji.frame.height - arrowView.frame.height - 20
                arrowView.frame.origin = CGPoint(x: scrollViewOrigin, y: getBottomEdgeY(inputView: scrollViewEmoji) - 2)
            }
            if tableViewFrameType == "CommentsViewController"
            {
                UIApplication.shared.keyWindow?.removeGestureRecognizer(sender)
            }
            else
            {
                view.removeGestureRecognizer(sender)
            }
            let stackView = scrollViewEmoji.subviews.reversed()
            stackView.forEach({ (emoji) in
                emoji.alpha = 0
                scrollViewEmoji.bringSubviewToFront(emoji)
                emoji.transform = CGAffineTransform(translationX: -100, y: emoji.frame.origin.y)
            })
            arrowView.alpha = 0
            arrowView.alpha = 0
            arrowView.tag = Currentcell
            scrollViewEmoji.alpha = 0
            scrollViewEmoji.isHidden = false
            scrollViewEmoji.tag =  Currentcell
            UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(scrollViewEmoji)
            UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(arrowView)
            UIApplication.shared.keyWindow?.rootViewController?.view.bringSubviewToFront(arrowView)
            let centeredX = (view.frame.width - scrollViewEmoji.frame.width)/2
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                scrollViewEmoji.alpha = 1
                arrowView.alpha = 1
                arrowView.isHidden = false
            }, completion: { (_) in
                
            }
            )
            UIView.animate(withDuration:0.2, animations: {
                let stackView = scrollViewEmoji.subviews.reversed()
                stackView.forEach({ (emoji) in
                    
                    emoji.alpha = 1
                    emoji.transform = .identity
                })
            }) { (_) in
                //
            }
        }
    }
    
    func removeEmoji(recognizer: UITapGestureRecognizer){
        scrollViewEmoji.isHidden = true
        view.removeGestureRecognizer(recognizer)
        
    }
    
    func updateReaction(url : String,reaction : String,action_id : Int,updateMyReaction : NSDictionary,feedIndex: Int){
        scrollViewEmoji.isHidden = true
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            //feedUpdate = true
            let feed = self.globalArrayFeed[feedIndex] as! NSDictionary
            //  ////print(feed)
            var newDictionary:NSMutableDictionary = [:]
            //Getting temporary feed dic for updating locally
            newDictionary = self.getfeedDic(feed: feed)
            
            let changedDictionary : NSMutableDictionary = [:]
            changedDictionary.removeAllObjects()
            let tempchangedDictionary : NSMutableDictionary = [:]
            tempchangedDictionary.removeAllObjects()
            var addDictionary : Bool! = false
            let tempLike = feed["is_like"] as! Bool
            
            // when already like just need to replace
            if(tempLike == true)
            {
                addDictionary = true
                newDictionary["my_feed_reaction"] = updateMyReaction
                if let myReaction = feed["my_feed_reaction"] as? NSDictionary{
                    
                    if myReaction.count > 0{
                        let reactionId = myReaction["reactionicon_id"] as? Int
                        if let reactions =  feed["feed_reactions"]  as? NSDictionary{
                            if reactions.count > 0{
                                // remove  reaction that is already liked from feed_reaction Dictionary
                                for(k,v) in reactions{
                                    let dicValue = v as! NSDictionary
                                    let currentId = Int((k as! String))
                                    if reactionId == currentId
                                    {
                                        if let countOfFeed = dicValue["reaction_count"] as? Int {
                                            if countOfFeed != 1 {
                                                if let dic = v as? NSDictionary{
                                                    var dict = Dictionary<String, AnyObject>()
                                                    for (key, value) in dic{
                                                        
                                                        if key as! String == "reaction_count"
                                                        {
                                                            dict["reaction_count"] = (value as! Int - 1) as AnyObject?
                                                        }
                                                        else{
                                                            dict["\(key)"] = value as AnyObject?
                                                            
                                                        }
                                                        
                                                    }
                                                    tempchangedDictionary["\(k)"] = dict
                                                    
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        tempchangedDictionary["\(k)"] = v
                                    }
                                    
                                }
                                
                                // add reaction that you like in feed_reaction Dictionary
                                for(k,v) in tempchangedDictionary{
                                    let idReaction : Int = updateMyReaction["reactionicon_id"] as! Int
                                    let currentId = Int((k as! String))
                                    if currentId == idReaction {
                                        addDictionary = false
                                        var dict = Dictionary<String, AnyObject>()
                                        if let dic = v as? NSDictionary{
                                            for (key, value) in dic{
                                                if key as! String == "reaction_count" {
                                                    dict["reaction_count"] = ((value as! Int) + 1) as AnyObject
                                                }
                                                else{
                                                    dict["\(key)"] = value as AnyObject?
                                                }
                                            }
                                            changedDictionary["\(k)"] = dict
                                        }
                                    }
                                    else{
                                        changedDictionary["\(k)"] = v
                                    }
                                }
                                
                            }
                            
                            
                        }
                        
                    }
                }
                
                
            }
            else
            {
                addDictionary = true
                newDictionary["is_like"] = true
                newDictionary["likes_count"] = ((feed["likes_count"] as? Int)!+1)
                newDictionary["my_feed_reaction"] = updateMyReaction
                
                if newDictionary["feed_Type"] as! String != "share"
                {
                    let temp = newDictionary["photo_attachment_count"] as? Int
                    
                    if temp == 1 {
                        
                        if newDictionary["attachment"] != nil
                        {
                            var dic:NSMutableDictionary = [:]
                            let array = newDictionary["attachment"] as! NSMutableArray
                            ////print(array)
                            dic = array[0] as! NSMutableDictionary
                            if dic["is_like"] != nil
                            {
                                let temp = newDictionary["photo_attachment_count"] as? Int
                                
                                if temp == 1 {
                                    
                                    if newDictionary["attachment"] != nil
                                    {
                                        var dic:NSMutableDictionary = [:]
                                        let array = newDictionary["attachment"] as! NSMutableArray
                                        dic = array[0] as! NSMutableDictionary
                                        if dic["is_like"] != nil
                                        {
                                            dic["is_like"] = true
                                        }
                                        array.removeObject(at: 0)
                                        array.add(dic)
                                        newDictionary["attachment"] = array
                                        
                                    }
                                }
                            }
                            
                            if dic["likes_count"] != nil
                            {
                                
                                dic["likes_count"] = ((feed["likes_count"] as? Int)!+1)
                            }
                            if dic["like_count"] != nil
                            {
                                
                                dic["like_count"] = ((feed["likes_count"] as? Int)!+1)
                            }
                            array.removeObject(at: 0)
                            array.add(dic)
                            newDictionary["attachment"] = array
                            ////print(array)
                            
                        }
                    }
                }
                
                if let reactions =  feed["feed_reactions"]  as? NSDictionary{
                    if reactions.count > 0{
                        
                        for(k,v) in reactions{
                            
                            let idReaction : Int = updateMyReaction["reactionicon_id"] as! Int
                            let currentId = Int((k as! String))
                            if currentId == idReaction {
                                addDictionary = false
                                var dict = Dictionary<String, AnyObject>()
                                if let dic = v as? NSDictionary{
                                    for (key, value) in dic{
                                        
                                        if key as! String == "reaction_count" {
                                            let reactioncount = ((value as! Int) + 1)
                                            dict["reaction_count"] = reactioncount as AnyObject?
                                            
                                        }
                                        else{
                                            dict["\(key)"] = value as AnyObject?
                                            
                                        }
                                        
                                    }
                                    
                                    changedDictionary["\(k)"] = dict
                                    
                                }
                            }
                            else{
                                changedDictionary["\(k)"] = v
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
            if addDictionary == true{
                var dict2 = Dictionary<String, AnyObject>()
                for (k,v) in updateMyReaction{
                    dict2["\(k)"] = v as AnyObject?
                    
                }
                dict2["reaction_count"] = 1 as AnyObject?
                changedDictionary["\(updateMyReaction["reactionicon_id"]!)"] = dict2
                
            }
            
            
            // Updating attachment array while liking or reacting any image feed
            if let arr = feed["attachment"] as? NSMutableArray
            {
                // ////print(arr)
                let  attachmentDic = arr[0] as! NSMutableDictionary
                attachmentDic["is_like"] = newDictionary["is_like"]
                attachmentDic["likes_count"] = newDictionary["likes_count"]
                //  total_Likes = newDictionary["likes_count"] as? Int ?? 0
                attachmentDic["comment_count"] = newDictionary["comment_count"]
                
                let reactionDic : NSMutableDictionary = [:]
                reactionDic["feed_reactions"] = changedDictionary
                reactionDic["my_feed_reaction"] = updateMyReaction
                attachmentDic["reactions"] = reactionDic
                arr[0] = attachmentDic
                newDictionary["attachment"] = arr
                //////print(arr)
            }
            
            // Updating global feed array
            newDictionary["feed_reactions"] = changedDictionary
            
            
            self.globalArrayFeed[feedIndex] = newDictionary
            
            
            // Updating corresponding
            if feedShowingFrom == "ActivityFeed"
            {
                feedArray[feedIndex] = newDictionary
            }
            else if feedShowingFrom == "UserFeed"
            {
                userFeedArray[feedIndex] = newDictionary
            }
            else
            {
                if contentFeedArray.count > 0
                {
                    
                    contentFeedArray[feedIndex] = newDictionary
                }
                else
                {
                    userFeedArray[feedIndex] = newDictionary
                }
            }
            //self.reloadDataTableView()
            
            //                        UIView.performWithoutAnimation {
            //
            //                            if #available(iOS 11.0, *) {
            //
            //                                self.tableView.performBatchUpdates({
            //                                    UIView.setAnimationsEnabled(false)
            //                                    self.tableView.beginUpdates()
            //                                    self.reload(feedIndex)
            //                                    self.tableView.endUpdates()
            //                                    //self.tableView.reloadData()
            //                                }, completion: { _ in
            //                                    DispatchQueue.main.async(execute: {
            //                                       // self.appMovedToBackground()
            //                                        if tableViewFrameType != "CommentsViewController"
            //                                        {
            //                                          // self.pausePlayeVideos()
            //                                        }
            //                                        UIView.setAnimationsEnabled(true)
            //                                    })
            //
            //                                })
            //
            //                            }
            //                        }
            
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
            }
            
            self.appMovedToBackground()
            if tableViewFrameType != "CommentsViewController"
            {
                sharedVideoPlayer.currentVideoContainer()?.playOn = true
                
                if NotPlay != 1 {
                    self.pausePlayeVideos()
                }
            }
            var dic = Dictionary<String, String>()
            dic["reaction"] = "\(reaction)"
            dic["action_id"] = "\(action_id)"
            dic["sendNotification"] = "\(0)"
            
            delegate?.reloadOnLike(newDictionary: newDictionary)
            userInteractionOff = false
            // Send Server Request to Update Feed Gutter Menu
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    if msg{
                        // On Success Update Feed Gutter Menu
                        var url = ""
                        url = "advancedactivity/send-like-notitfication"
                        var dict = Dictionary<String, String>()
                        dict["action_id"] = "\(action_id)"
                        // call notificatiom
                        if Reachabable.isConnectedToNetwork() {
                            removeAlert()
                            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                                DispatchQueue.main.async(execute:{
                                    userInteractionOff = true
                                    
                                })
                            }
                        }
                        else
                        {
                            
                            showToast(message: network_status_msg, controller: self, onView: false, time: 5.0)
                        }
                    }
                    else
                    {
                        //     activityIndicatorView.stopAnimating()
                        
                    }
                    
                })
                
            }
            
        }
        else
        {
            
            showToast(message: network_status_msg, controller: self, onView: false, time: 5.0)
        }
        
    }
    func deleteReaction(url : String,reaction : String,action_id : Int,updateMyReaction : NSDictionary,feedIndex: Int)
    {
        scrollViewEmoji.isHidden = true
        if Reachabable.isConnectedToNetwork()
        {
            removeAlert()
            
            var dic = Dictionary<String, String>()
            dic["reaction"] = "\(reaction)"
            dic["action_id"] = "\(action_id)"
            
            
            var newDictionary:NSMutableDictionary = [:]
            let feed = self.globalArrayFeed[feedIndex] as! NSDictionary
            
            //Getting temporary feed dic for updating locally
            newDictionary = self.getfeedDic(feed: feed)
            
            let changedDictionary : NSMutableDictionary = [:]
            let tempLike = feed["is_like"] as! Bool
            if(tempLike == true)
            {
                
                newDictionary["is_like"] = false
                newDictionary["likes_count"] = ((feed["likes_count"] as? Int)!-1)
                newDictionary["my_feed_reaction"] = updateMyReaction
                if newDictionary["feed_Type"] as! String != "share"
                {
                    let temp = newDictionary["photo_attachment_count"] as? Int
                    
                    if temp == 1 {
                        
                        if newDictionary["attachment"] != nil
                        {
                            var dic:NSMutableDictionary = [:]
                            let array = newDictionary["attachment"] as! NSMutableArray
                            ////print(array)
                            
                            dic = array[0] as! NSMutableDictionary
                            if dic["is_like"] != nil
                            {
                                dic["is_like"] = false
                            }
                            if dic["likes_count"] != nil
                            {
                                
                                dic["likes_count"] = ((feed["likes_count"] as? Int)!-1)
                            }
                            if dic["like_count"] != nil
                            {
                                
                                dic["like_count"] = ((feed["likes_count"] as? Int)!-1)
                            }
                            
                            dic["comment_count"] = newDictionary["comment_count"]
                            
                            array.removeObject(at: 0)
                            array.add(dic)
                            newDictionary["attachment"] = array
                            ////print(array)
                        }
                    }
                }
                if let reactions =  feed["feed_reactions"]  as? NSDictionary
                {
                    for(k,v) in reactions
                    {
                        let dicValue = v as! NSDictionary
                        let currentId = Int((k as! String))
                        if let myReaction = feed["my_feed_reaction"] as? NSDictionary{
                            if myReaction.count > 0
                            {
                                if let reactionId = myReaction["reactionicon_id"] as? Int
                                {
                                    
                                    if reactionId == currentId
                                    {
                                        if let countOfFeed = dicValue["reaction_count"] as? Int {
                                            if countOfFeed != 1{
                                                
                                                var dict = Dictionary<String, AnyObject>()
                                                if let dic = v as? NSDictionary{
                                                    
                                                    for (key, value) in dic
                                                    {
                                                        
                                                        if key as! String == "reaction_count"
                                                        {
                                                            dict["reaction_count"] = (value as! Int - 1) as AnyObject?
                                                        }
                                                        else
                                                        {
                                                            dict["\(key)"] = value as AnyObject?
                                                            
                                                        }
                                                        
                                                    }
                                                    changedDictionary["\(k)"] = dict
                                                }
                                                
                                            }
                                        }
                                        
                                    }
                                    else{
                                        changedDictionary["\(k)"] = v
                                    }
                                }
                                else
                                {
                                    changedDictionary["\(k)"] = v
                                    
                                }
                            }
                            else
                            {
                                changedDictionary["\(k)"] = v
                                
                            }
                        }
                    }
                    
                }
            }
            newDictionary["feed_reactions"] = changedDictionary
            newDictionary["my_feed_reaction"] = updateMyReaction
            // ////print(newDictionary)
            
            //            if newDictionary["attachment"] != nil
            //            {
            //                var dic:NSMutableDictionary = [:]
            //                let array = newDictionary["attachment"] as! NSMutableArray
            //                ////print(array)
            //                dic = array[0] as! NSMutableDictionary
            //                if dic["reactions"] != nil
            //                {
            //                    var dic_reactions:NSMutableDictionary = [:]
            //                    dic_reactions = dic["reactions"] as! NSMutableDictionary
            //
            //                    if dic_reactions["feed_reactions"] != nil
            //                    {
            //                        dic_reactions["feed_reactions"] = changedDictionary
            //
            //                    }
            //                    if dic_reactions["my_feed_reaction"] != nil
            //                    {
            //                        dic_reactions["my_feed_reaction"] = updateMyReaction
            //
            //                    }
            //                    dic["reactions"] = dic_reactions
            //                }
            //                array.removeObject(at: 0)
            //                array.add(dic)
            //                newDictionary["attachment"] = array
            //                ////print(array)
            //            }
            if let arr = newDictionary["attachment"] as? NSMutableArray
            {
                
                let  attachmentDic = arr[0] as! NSMutableDictionary
                var reactionDic : NSMutableDictionary = [:]
                if attachmentDic["reactions"] != nil {
                    reactionDic = attachmentDic["reactions"] as! NSMutableDictionary
                    reactionDic["feed_reactions"] = changedDictionary
                    reactionDic["my_feed_reaction"] = updateMyReaction
                    attachmentDic["reactions"] = reactionDic
                    arr[0] = attachmentDic
                    newDictionary["attachment"] = arr
                }
                
            }
            
            //   ////print(newDictionary)
            //   total_Likes = newDictionary["likes_count"] as? Int ?? 0
            self.globalArrayFeed[feedIndex] = newDictionary
            if feedShowingFrom == "ActivityFeed"
            {
                feedArray[feedIndex] = newDictionary
            }
            else if feedShowingFrom == "UserFeed"
            {
                userFeedArray[feedIndex] = newDictionary
            }
            else
            {
                if contentFeedArray.count > 0
                {
                    
                    contentFeedArray[feedIndex] = newDictionary
                }
                else
                {
                    userFeedArray[feedIndex] = newDictionary
                }
            }
            
            
            //                        UIView.performWithoutAnimation {
            //
            //                            if #available(iOS 11.0, *) {
            //
            //                                self.tableView.performBatchUpdates({
            //                                    UIView.setAnimationsEnabled(false)
            //                                    self.tableView.beginUpdates()
            //                                    self.reload(feedIndex)
            //                                    self.tableView.endUpdates()
            //                                    //self.tableView.reloadData()
            //                                }, completion: { _ in
            //                                    DispatchQueue.main.async(execute: {
            //                                       // self.appMovedToBackground()
            //                                        if tableViewFrameType != "CommentsViewController"
            //                                        {
            //                                          // self.pausePlayeVideos()
            //                                        }
            //                                        UIView.setAnimationsEnabled(true)
            //                                    })
            //
            //                                })
            //
            //                            }
            //                        }
            
            
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
            }
            
            self.appMovedToBackground()
            if tableViewFrameType != "CommentsViewController"
            {
                sharedVideoPlayer.currentVideoContainer()?.playOn = true
                if NotPlay != 1 {
                    self.pausePlayeVideos()
                }
            }
            delegate?.reloadOnLike(newDictionary: newDictionary)
            userInteractionOff = false
            // Send Server Request to Update Feed Gutter Menu
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    if msg
                    {
                        
                        // On Success Update Feed Gutter Menu
                        
                    }
                    
                })
                
            }
            
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self, onView: false, time: 5.0)
            
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
    // Stop Timer for remove Alert
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true {
            _ = self.navigationController?.popViewController(animated: true)
            
        }
    }
    // Get tagged string
    func getTaggedstring(title : String, tagarr:NSArray) -> String
    {
        var titlestr : String = ""
        titlestr = title
        if tagarr.count > 0{
            titlestr += NSLocalizedString(" — with",  comment: "")
            outerLoop:   for i in 0 ..< tagarr.count {
                if let tag = ((tagarr[i] as! NSDictionary)["tag_obj"] as! NSDictionary)["displayname"] as? String{
                    if i == 0
                    {
                        titlestr += " \(tag)"
                        
                    }
                    else if (i == (tagarr.count - 1)) && (tagarr.count == 2)
                    {
                        titlestr += NSLocalizedString(" and",  comment: "")
                        titlestr += " \(tag)"
                        
                    }
                    else
                    {
                        let tempCount = tagarr.count - 1
                        let i = 0
                        if i == 0
                        {
                            titlestr += " and \(tempCount) others"
                            tagOtherUserCount = tempCount
                        }
                        break outerLoop
                        
                    }
                }
            }
        }
        return titlestr
    }
    func getCheckInstring(title : String, checkinparams:NSDictionary) -> String
    {
        var titlestr : String = ""
        titlestr = title
        if checkinparams.count > 0{
            if let checkIn = checkinparams["checkin"] as? NSDictionary{
                if  checkIn["place_id"] != nil {
                    let location = checkIn["label"] as! String
                    titlestr += NSLocalizedString(" — in",  comment: "")
                    titlestr += " \(location)"
                }
            }
            
        }
        return titlestr
    }
    // Get url of all attachment
    func getattachmentUrl(activityFeed : NSDictionary) -> [String]
    {
        var imageUrlArray = [String]()
        if let attachmentArray = activityFeed["attachment"] as? NSArray
        {
            ////print(attachmentArray)
            for i in 0 ..< attachmentArray.count
            {
                if let feed = attachmentArray[i] as? NSDictionary{
                    if let dic = feed["image_main"] as? NSDictionary{
                        if let url =  dic["src"] as? String
                        {
                            imageUrlArray.append(url)
                        }
                    }
                }
            }
        }
        return imageUrlArray
    }
    //Getting temporary feed dic for updating locally
    func getfeedDic(feed:NSDictionary) -> NSMutableDictionary
    {
        
        let newDictionary:NSMutableDictionary = [:]
        
        if feed["subject_image"]  != nil{
            newDictionary["subject_image"] = feed["subject_image"]
        }
        if feed["feed_title"]  != nil{
            newDictionary["feed_title"] = feed["feed_title"]
        }
        if feed["feed_createdAt"]  != nil{
            newDictionary["feed_createdAt"] = feed["feed_createdAt"]
        }
        if feed["comment_count"]  != nil{
            newDictionary["comment_count"] = feed["comment_count"]
        }
        if feed["likes_count"]  != nil{
            newDictionary["likes_count"] = feed["likes_count"]
        }
        if feed["attachment"]  != nil{
            newDictionary["attachment"] = feed["attachment"]
            
        }
        if feed["attactment_Count"]  != nil{
            newDictionary["attactment_Count"] = feed["attactment_Count"]
        }
        if feed["attachment_content_type"]  != nil{
            newDictionary["attachment_content_type"] = feed["attachment_content_type"]
        }
        if feed["action_id"]  != nil{
            newDictionary["action_id"] = feed["action_id"]
        }
        if feed["subject_id"]  != nil{
            newDictionary["subject_id"] = feed["subject_id"]
        }
        if feed["share_params_type"]  != nil{
            newDictionary["share_params_type"] = feed["share_params_type"]
        }
        if feed["share_params_id"]  != nil{
            newDictionary["share_params_id"] = feed["share_params_id"]
        }
        if feed["feed_Type"]  != nil{
            newDictionary["feed_Type"] = feed["feed_Type"]
        }
        if feed["feed_menus"]  != nil{
            newDictionary["feed_menus"] = feed["feed_menus"]
        }
        if feed["feed_footer_menus"]  != nil{
            newDictionary["feed_footer_menus"] = feed["feed_footer_menus"]
        }
        if feed["feed_reactions"]  != nil{
            newDictionary["feed_reactions"] = feed["feed_reactions"]
        }
        if feed["my_feed_reaction"]  != nil{
            newDictionary["my_feed_reaction"] = feed["my_feed_reaction"]
        }
        if feed["comment"]  != nil{
            newDictionary["comment"] = feed["comment"]
        }
        if feed["like"]  != nil{
            newDictionary["like"] = feed["like"]
        }
        if feed["delete"]  != nil{
            newDictionary["delete"] = feed["delete"]
        }
        if feed["share"]  != nil{
            newDictionary["share"] = feed["share"]
        }
        if feed["photo_attachment_count"] != nil{
            newDictionary["photo_attachment_count"] = feed["photo_attachment_count"]
        }
        if feed["object_id"] != nil{
            newDictionary["object_id"] = feed["object_id"]
        }
        if feed["object_type"] != nil{
            newDictionary["object_type"] = feed["object_type"]
        }
        if feed["params"] != nil{
            newDictionary["params"] = feed["params"]
        }
        if feed["tags"] != nil{
            newDictionary["tags"] = feed["tags"]
        }
        if feed["action_type_body_params"] != nil{
            newDictionary["action_type_body_params"] = feed["action_type_body_params"]
        }
        if feed["action_type_body"] != nil{
            newDictionary["action_type_body"] = feed["action_type_body"]
        }
        if feed["object"] != nil{
            newDictionary["object"] = feed["object"]
        }
        if feed["is_like"] != nil{
            newDictionary["is_like"] = feed["is_like"]
        }
        if feed["hashtags"]  != nil{
            newDictionary["hashtags"] = feed["hashtags"]
        }
        
        if feed["decoration"] != nil{
            newDictionary["decoration"] = feed["decoration"]
        }
        if feed["wordStyle"] != nil{
            newDictionary["wordStyle"] = feed["wordStyle"]
        }
        if feed["privacy"] != nil{
            newDictionary["privacy"] = feed["privacy"]
        }
        if feed["privacy_icon"] != nil{
            newDictionary["privacy_icon"] = feed["privacy_icon"]
        }
        if feed["isNotificationTurnedOn"]  != nil{
            newDictionary["isNotificationTurnedOn"] = feed["isNotificationTurnedOn"]
        }
        if feed["pin_post_duration"] != nil{
            newDictionary["pin_post_duration"] = feed["pin_post_duration"]
        }
        if feed["isPinned"] != nil{
            newDictionary["isPinned"] = feed["isPinned"]
        }
        if feed["publish_date"] != nil{
            newDictionary["publish_date"] =  feed["publish_date"]
        }
        
        return newDictionary
    }
    
    // MARK: Video Icon Action
    @objc func btnVideoMuteUnmuteIcon(_ sender: UIButton)
    {
        if muteVideo == true
        {
            muteVideo = false
            sharedVideoPlayer.muteVideosFor(tableView: self.tableView)
            sender.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
            //sender.setTitle("\(unMuteIconIcon)", for: .normal)
        }
        else
        {
            muteVideo = true
            sharedVideoPlayer.muteVideosFor(tableView: self.tableView)
            sender.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
            //sender.setTitle("\(muteVideoIcon)", for: .normal)
        }
        
    }
    @objc func btnAdsVideoMuteUnmuteIcon(_ sender: UIButton)
    {
        if muteVideo == true
        {
            muteVideo = false
            shared1.muteVideosFor(tableView: self.tableView)
            sender.setImage(UIImage(named: "unmuteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
            //sender.setTitle("\(unMuteIconIcon)", for: .normal)
        }
        else
        {
            muteVideo = true
            shared1.muteVideosFor(tableView: self.tableView)
            sender.setImage(UIImage(named: "muteIcon1")!.maskWithColor(color: textColorLight), for: UIControl.State.normal)
            //sender.setTitle("\(muteVideoIcon)", for: .normal)
        }
        
    }
    @objc func btnVideoReplayClicked(_ sender: UIButton)
    {
        let touchPoint = sender.convert(CGPoint.zero, to: self.tableView)
        if let rowIndexPathTable  = self.tableView.indexPathForRow(at: touchPoint)
        {
            if let cell = tableView.cellForRow(at: rowIndexPathTable) as? AAFActivityFeedTableViewCell
            {
                cell.lblReplayVideo.isHidden = true
                cell.imgReplayVideo.isHidden = true
                cell.viewVideo.isHidden = false
                let currentPlayer = sharedVideoPlayer.currentVideoContainer()?.player
                currentPlayer?.seek(to: CMTime.zero)
                currentPlayer?.play()
            }
        }
    }
    @objc func btnVideoIconClicked(_ sender: UIButton)
    {
        //var rowIndexPath = sender.tag
        let touchPoint = sender.convert(CGPoint.zero, to: self.tableView)
        var rowIndexPathTable  = self.tableView.indexPathForRow(at: touchPoint)
        var rowIndexPath = rowIndexPathTable?.row ?? 0
        
        if kFrequencyAdsInCells_feeds > 4 && nativeAdArray.count > 0 && globalArrayFeed.count > kFrequencyAdsInCells_feeds-1
        {
            rowIndexPath = rowIndexPath - (rowIndexPath / kFrequencyAdsInCells_feeds)
        }
        
        // Calculate actuall index after removing people you may know cell
        if rowIndexPath > suggestionSlideshowPosition - 1 && showSuggestions == 1 &&  isHomeFeeds && userSuggestions.count > 0
        {
            rowIndexPath = rowIndexPath - 1
        }
        
        let activityFeed = globalArrayFeed[rowIndexPath] as! NSDictionary
        
        // //print(activityFeed)
        if let attachment = activityFeed["attachment"] as? NSArray
        {
            let attechmentDic = attachment[0] as! NSDictionary
            let attachment_video_type = attechmentDic["attachment_video_type"] as? Int ?? 0
            let attachment_video_url = attechmentDic["attachment_video_url"] as? String ?? ""
            let attachment_video_code = attechmentDic["attachment_video_code"] as? String ?? ""
            if let objectType = attechmentDic["attachment_type"] as? String, objectType == "video"
            {
                if attachment_video_type == 3
                {
                    if tableViewFrameType == "ContentActivityFeedViewController"
                    {
                        feedArrayTikTok = feedArrayTikTokTemp
                    }
                    var isQuickVideoDeviceVCExist = false
                    if tableViewFrameType == "CommentsViewController"
                    {
                        if let viewControllers = self.navigationController?.viewControllers
                        {
                            for controller in viewControllers
                            {
                                if controller is QuickVideoDeviceVC
                                {
                                    isQuickVideoDeviceVCExist = true
                                    if globalArrayFeed.count != 0
                                    {
                                        if let dic = globalArrayFeed[0] as? NSMutableDictionary
                                        {
                                            if let myParent = self.parent as? CommentsViewController {
                                                myParent.delegateComments?.countLikeandComments(data: dic)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    if isQuickVideoDeviceVCExist == true
                    {
                        self.navigationController?.popViewController(animated: true)
                    }
                    else
                    {
                        var indexSelectedVideo = -1
                        for (index, feed) in feedArrayTikTok.enumerated()
                        {
                            if feed["action_id"] as! Int == activityFeed["action_id"] as! Int
                            {
                                indexSelectedVideo = index
                            }
                        }
                        if indexSelectedVideo == -1
                        {
                            feedAddInTikTokArray()
                            for (index, feed) in feedArrayTikTok.enumerated()
                            {
                                if feed["action_id"] as! Int == activityFeed["action_id"] as! Int
                                {
                                    indexSelectedVideo = index
                                }
                            }
                        }
                        if indexSelectedVideo == -1
                        {
                            indexSelectedVideo = 0
                            feedArrayTikTok.append(activityFeed)
                        }
                        else
                        {
                            feedArrayTikTok[indexSelectedVideo] = activityFeed
                        }
                        if var viewControllers = self.navigationController?.viewControllers
                        {
                            for controller in viewControllers
                            {
                                if controller is QuickVideoDeviceVC
                                {
                                    viewControllers.remove(object: controller)
                                    self.navigationController?.viewControllers = viewControllers
                                }
                            }
                        }
                        //print(activityFeed)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc  = storyboard.instantiateViewController(withIdentifier: "QuickVideoDeviceVC") as! QuickVideoDeviceVC
                        vc.feedShowingFrom = feedShowingFrom
                        
                        vc.indexSelectedVideo = indexSelectedVideo
                        vc.delegateTikTokVidyoPlayer = self
                        vc.currentPlayer = sharedVideoPlayer.currentVideoContainer()?.player
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true)
                    }
                }
                else
                {
                    implemnetPlayer(videoType: attachment_video_type, videoURL: attachment_video_url, videoCode: attachment_video_code, sender : sender)
                }
                
            }
        }
    }
    @objc func btnVideoIconClosedAction()
    {
        //        self.tabBarController?.tabBar.isHidden = false
        //        self.navigationController?.navigationBar.isHidden = false
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
    }
    var originalPosition = CGPoint(x: 0, y: 0)
    // MARK: - Player & Webview Implimentation
    func implemnetPlayer(videoType : Int, videoURL : String, videoCode : String, sender : UIButton)
    {
        if videoType == 3
        {
            if let url = URL(string:videoURL)
            {
                let player = AVPlayer(url: url)
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
            //  self.tabBarController?.tabBar.isHidden = true
            //   self.navigationController?.navigationBar.isHidden = true
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
        
        // var currentPositionTouched = CGPoint(x: 0, y: 0)
        if panGesture.state == .began {
            // originalPosition = viewSubview.center
            //  currentPositionTouched = panGesture.location(in: viewSubview)
        } else if panGesture.state == .changed {
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
    
    
 
    
    //MARK: Quick Content Methods
    //Helper Funtions
    func dummyDataInitialSetup(cell:AAFActivityFeedTableViewCell)
    {
        cell.quickContentDelegate = self
        //Hide views for hiding cell
        for ob in cell.cellView.subviews{
            
            if ob .isKind(of: UIImageView.self){
                (ob as! UIImageView).isHidden = true
            }
            if ob .isKind(of: UILabel.self){
                (ob as! UILabel).isHidden = true
            }
            if ob .isKind(of: UIButton.self){
                (ob as! UIButton).isHidden = true
            }
            if ob .isKind(of: UIView.self){
                (ob as UIView).isHidden = true
            }
            if ob .isKind(of: TTTAttributedLabel.self){
                (ob as! TTTAttributedLabel).isHidden = true
            }
        }
        cell.progressView.isHidden = false
        cell.viewContianerProgressView.isHidden = false
        cell.viewContianerProgressView.frame = CGRect(x: 0 ,y: 0 ,width: cell.frame.size.width ,height: 50)
        cell.borderViewProgressBar.frame = CGRect(x: 0,y: getBottomEdgeY(inputView: cell.viewContianerProgressView) - 1 ,width: cell.frame.size.width , height: 1)
        cell.subject_photo.image = imageProfile
        cell.subject_photo.frame = CGRect(x: 3, y: getBottomEdgeY(inputView: cell.viewContianerProgressView) + 3, width: 50, height: 50)
        cell.title.frame = CGRect(x: cell.subject_photo.bounds.width + 15,y: getBottomEdgeY(inputView: cell.viewContianerProgressView) + 10, width: cell.cellView.bounds.width-(cell.subject_photo.bounds.width + 65),height: 15)
        cell.title.text = displayName
        if feedTextColor != "" {
            var check = feedTextColor
            let _ = check.remove(at: (check.startIndex))
            cell.body.textColor = UIColor(hex: "\(check)")
        }
    }
    
    func reload(_ row: Int) {
        self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
    }
    func dataUploading(cell:AAFActivityFeedTableViewCell, activityFeed : NSMutableDictionary, indexPath : Int)
    {
        if activityFeed["isDummyResponse"] as! Int == 1
        {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            cell.showHideIndicator(show: true)
            activityFeed["isDummyResponse"] = 0 as AnyObject
            globalArrayFeed[indexPath] = activityFeed
            feedArray[indexPath] = activityFeed as AnyObject
            uploadService.startUpload(activityFeed)
        }
    }
    
    func sellSomethingDummyViewWhileUploading(cell:AAFActivityFeedTableViewCell, activityFeed : NSMutableDictionary, indexPath : Int, textHeight : CGFloat)
    {
        fixViewsHideForDummyData(cell: cell)
        cell.img_imageButton1.isHidden = false
        let tempHeight = ceil(UIScreen.main.bounds.width * 0.80) - 60
        cell.customAlbumView.frame = CGRect(x: 0 ,y: getBottomEdgeY(inputView: cell.subject_photo) + 15 + textHeight ,width: cell.frame.size.width ,height: tempHeight)
        cell.img_imageButton1.frame = CGRect(x: 0 ,y: 0 ,width: cell.frame.size.width ,height: tempHeight)
        cell.img_imageButton1.contentMode = .scaleAspectFill
        let dicParams = activityFeed["params"] as! [String : AnyObject]
        var title = ""
        var price = ""
        var loc = ""
        var desc = ""
        var currency = ""
        
        if dicParams["title"]  != nil {
            title = String(describing: dicParams["title"] as AnyObject)
        }
        if dicParams["price"]  != nil {
            price = String(describing: dicParams["price"] as AnyObject)
        }
        if dicParams["currency"]  != nil {
            currency = String(describing: dicParams["currency"] as AnyObject)
        }
        if dicParams["location"]  != nil {
            loc = String(describing: dicParams["location"] as AnyObject)
        }
        if dicParams["description"]  != nil {
            desc = String(describing: dicParams["description"] as AnyObject)
        }
        cell.sellSlideShowView.frame.origin.y = getBottomEdgeY(inputView: cell.subject_photo) + 10 + textHeight
        if let dic1 = activityFeed["filePathArray"] as? NSArray
        {
            cell.sellSlideshow.browseSellContent(contentItems: dic1 as [AnyObject],comingFrom : "")
            cell.sellSlideshow.frame.size.height = 250
            
        }
        else{
            cell.sellSlideshow.frame.size.height = 0
            
        }
        cell.sellSlideShowView.isHidden = false
        cell.sellSlideShowView.layoutIfNeeded()
        
        cell.sellTitle.frame.origin.y = cell.sellSlideshow.bounds.size.height + 10 + cell.sellSlideshow.frame.origin.y
        cell.sellTitle.text = title
        cell.sellTitle.numberOfLines = 0
        cell.sellTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        cell.sellTitle.sizeToFit()
        cell.sellTitle.frame.size.width = cell.cellView.frame.size.width - 20
        
        cell.sellPrice.frame.origin.y = cell.sellTitle.bounds.size.height + 10 + cell.sellTitle.frame.origin.y
        cell.sellPrice.text = "\(dollarIcon) \(currency) \(price)"
        cell.sellPrice.textColor = UIColor(red: 34/255.0, green: 139/255.0, blue: 34/255.0, alpha: 1.0)//rgb(34,139,34)//UIColor.green
        cell.sellPrice.numberOfLines = 0
        cell.sellPrice.lineBreakMode = NSLineBreakMode.byTruncatingTail
        cell.sellPrice.sizeToFit()
        cell.sellPrice.frame.size.width = cell.cellView.frame.size.width - 20
        cell.sellLocation.frame.origin.y = cell.sellPrice.bounds.size.height + 10 + cell.sellPrice.frame.origin.y
        if loc != "" {
            cell.sellLocation.text = "\(locationIcon) \(loc)"
        }
        cell.sellLocation.sizeToFit()
        cell.sellLocation.numberOfLines = 0
        cell.sellLocation.lineBreakMode = NSLineBreakMode.byTruncatingTail
        cell.sellLocation.frame.size.width = cell.cellView.frame.size.width - 20
        cell.sellDesc.frame.origin.y = cell.sellLocation.bounds.size.height + 10 + cell.sellLocation.frame.origin.y
        cell.sellDesc.numberOfLines = 0
        cell.sellDesc.isHidden = false
        cell.sellDesc.text = desc
        cell.sellDesc.sizeToFit()
        cell.sellDesc.frame.size.height =  cell.sellDesc.bounds.size.height + 20
        cell.sellDesc.frame.size.width = cell.cellView.frame.size.width - 20
        cell.sellSlideShowView.frame.size.height = cell.sellDesc.frame.origin.y + cell.sellDesc.frame.size.height + 20
        
        dynamicHeight = cell.sellSlideShowView.frame.size.height + 140 + textHeight
        cell.cellView.frame.size.height = dynamicHeight - 5
        self.dynamicRowHeight[activityFeed["action_id"] as? Int ?? 0] = dynamicHeight
        dataUploading(cell: cell, activityFeed: activityFeed, indexPath: indexPath)
    }
    
    func composerDummyViewWhileUploading(cell:AAFActivityFeedTableViewCell, activityFeed : NSMutableDictionary, indexPath : Int, textHeight : CGFloat)
    {
        fixViewsHideForDummyData(cell: cell)
        if let attachment_title = activityFeed["titleGetAttachementLink"] as? String, attachment_title.length != 0
        {
            cell.cntentShareFeedView.frame.origin.y = getBottomEdgeY(inputView: cell.subject_photo) + 15 + textHeight
            cell.customAlbumView.isHidden = true
            cell.cntentShareFeedView.isHidden = false
            cell.customAlbumView.frame.size.height = 0
            let imageUrl = activityFeed["imageGetAttachementLink"] as! String
            let attachment_description = activityFeed["descriptionGetAttachementLink"] as! String
            
            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\(attachment_title)")
            let boldFont = CTFontCreateWithName((fontBold as CFString?)!, FONTSIZENormal, nil)
            attrString.addAttribute(NSAttributedString.Key.font, value: boldFont, range: NSMakeRange(0, attrString.length))
            attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, attrString.length))
            let descString: NSMutableAttributedString = NSMutableAttributedString(string:  String("\n\n\(attachment_description)"))
            descString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontName , size: FONTSIZENormal)!, range: NSMakeRange(0, descString.length))
            attrString.append(descString);
            cell.contentAttributedLabel.attributedText = attrString
            var totalheight = attrString.height(withConstrainedWidth: cell.contentAttributedLabel.frame.size.width)
            cell.contentAttributedLabel.numberOfLines = 5
            cell.contentAttributedLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
            if totalheight > 100
            {
                totalheight = 100
            }
            cell.contentAttributedLabel.isHidden = false
            cell.contentAttributedLabel.frame.size.height = totalheight
            if imageUrl != ""
            {
                let url = NSURL(string:imageUrl)
                
                let tempHeight = ceil(UIScreen.main.bounds.width * 0.80)
                cell.cntentShareFeedView.frame.size.height = tempHeight + 10
                cell.contentImageView.frame.size.height = tempHeight - 60
                cell.contentImageView.contentMode = .scaleToFill
                let tempWidth = Double(cell.contentImageView.bounds.width)
                let ttheight = Double(tempHeight - 60)
                if let urlT = url as URL?
                {
                    //                        cell.contentImageView.kf.indicatorType = .activity
                    //                        (cell.contentImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
                    cell.contentImageView.isHidden = false
                    cell.contentImageView.kf.setImage(with: urlT, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        DispatchQueue.main.async {
                            if let imageT = image
                            {
                                cell.contentImageView.image = cropToBounds(imageT, width: tempWidth, height: ttheight)
                            }
                        }
                    })
                }
            }
            
            cell.contentAttributedLabel.frame.origin.y = getBottomEdgeY(inputView: cell.contentImageView) + 5
            cell.cntentShareFeedView.frame.size.height = cell.contentImageView.frame.size.height + cell.contentAttributedLabel.frame.size.height + 10
            self.dynamicHeight = 140 + cell.cntentShareFeedView.frame.size.height
        }
        else if let imgUrl = activityFeed["strURLTextBanner"] as? String, imgUrl.length != 0
        {
            let bannerUrl = imgUrl
            let bannerbackgroundColor = activityFeed["background_color"] as! String
            var bannertextColor = activityFeed["strURLcolor"] as! String
            cell.body.isHidden = true
            cell.body.frame.size.height = 0
            var check = bannerbackgroundColor
            let _ = check.remove(at: (check.startIndex))
            cell.bannerButton.isHidden = false
            cell.bannerButton.backgroundColor = UIColor(hex: "\(check)")
            cell.customAlbumView.isHidden = false
            cell.img_bannerButton.isHidden = false
            cell.img_bannerButton.backgroundColor = UIColor(hex: "\(check)")
            let tempHeight = ceil(cell.cellView.bounds.width * 0.8)
            cell.customAlbumView.frame = CGRect(x: 0 ,y: getBottomEdgeY(inputView: cell.subject_photo) + 15 ,width: cell.frame.size.width ,height: tempHeight + 10)
            cell.bannerButton.frame.size.height = tempHeight
            let _ = bannertextColor.remove(at: (bannertextColor.startIndex))
            cell.bannerTitle.textColor = UIColor(hex: "\(bannertextColor)")
            cell.bannerTitle.numberOfLines = 0
            cell.bannerTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.bannerTitle.isHidden = false
            cell.bannerTitle.text = cell.body.text
            cell.bannerTitle.sizeToFit()
            cell.bannerTitle.frame.size.width = cell.contentImageView.bounds.width - 20
            cell.bannerTitle.frame.size.height = cell.customAlbumView.frame.size.height - 10
            cell.bannerTitle.textAlignment = NSTextAlignment.center
            let imageUrl = URL(string: bannerUrl)
            cell.bannerButton.backgroundColor = .clear
            //            cell.img_bannerButton.kf.indicatorType = .activity
            //            (cell.img_bannerButton.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
            cell.img_bannerButton.frame = cell.bannerButton.frame
            cell.img_bannerButton.kf.setImage(with: imageUrl, placeholder: UIImage(named : ""), options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                
            })
            dynamicHeight =  140 + cell.customAlbumView.frame.size.height
            
        }
        else if let lat = activityFeed["latitude"] as? Double
        {
            let long = activityFeed["longitude"] as! Double
            let staticMapUrl: String = "http://maps.google.com/maps/api/staticmap?markers=color:red|\(lat),\(long)&\("zoom=13&size=720x720")&sensor=true"
            
            let imageUrl = URL(string: staticMapUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            cell.customAlbumView.frame.origin.y = getBottomEdgeY(inputView: cell.subject_photo) + 15 + textHeight
            cell.customAlbumView.isHidden = false
            cell.mapButton.isHidden = false
            cell.img_mapButton.isHidden = false
            let tempHeight = ceil(cell.cellView.bounds.width * 0.8)
            cell.customAlbumView.frame.size.height = tempHeight + 10
            cell.mapButton.frame.size.height = tempHeight
            cell.mapButton.backgroundColor = .clear
            //            cell.img_mapButton.kf.indicatorType = .activity
            //            (cell.img_mapButton.kf.indicator?.view as? UIActivityIndicatorView)?.color = navColor
            cell.img_mapButton.frame = cell.mapButton.frame
            cell.img_mapButton.kf.setImage(with: imageUrl, placeholder: placeholderImage, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                
            })
            dynamicHeight = tempHeight + 140 + textHeight
            
        }
        else
        {
            dynamicHeight = 140 + textHeight
        }
        cell.cellView.frame.size.height = dynamicHeight - 5
        self.dynamicRowHeight[activityFeed["action_id"] as? Int ?? 0] = dynamicHeight
        dataUploading(cell: cell, activityFeed: activityFeed, indexPath: indexPath)
    }
    
    func videoDummyViewWhileUploading(cell:AAFActivityFeedTableViewCell, activityFeed : NSMutableDictionary, indexPath : Int, textHeight : CGFloat)
    {
        fixViewsHideForDummyData(cell: cell)
        cell.img_imageButton1.isHidden = false
        let tempHeight = ceil(UIScreen.main.bounds.width * 0.80) - 60
        cell.customAlbumView.frame = CGRect(x: 0 ,y: getBottomEdgeY(inputView: cell.subject_photo) + 15 + textHeight ,width: cell.frame.size.width ,height: tempHeight)
        cell.img_imageButton1.frame = CGRect(x: 0 ,y: 0 ,width: cell.frame.size.width ,height: tempHeight)
        cell.img_imageButton1.contentMode = .scaleAspectFill
        if let imgUrl = activityFeed["previewImageVideo"] as? String
        {
            if FileManager.default.fileExists(atPath: imgUrl) {
                if let url = URL(string:imgUrl)
                {
                    cell.img_imageButton1.image = UIImage(contentsOfFile: url.path)
                }
            }
            else
            {
                //  cell.deleteQuickContent()
                //  return
            }
        }
        dynamicHeight = tempHeight + 140 + textHeight
        cell.cellView.frame.size.height = dynamicHeight - 5
        self.dynamicRowHeight[activityFeed["action_id"] as? Int ?? 0] = dynamicHeight
        dataUploading(cell: cell, activityFeed: activityFeed, indexPath: indexPath)
    }
    func imageDummyViewWhileUploading(cell:AAFActivityFeedTableViewCell, activityFeed : NSMutableDictionary, indexPath : Int, textHeight : CGFloat)
    {
        let filePathArrayTemp = activityFeed["filePathArray"] as! [String]
        imagesShowBasedOnCount(cell: cell, count : filePathArrayTemp.count)
        switch filePathArrayTemp.count {
        case 1:
            let tempHeight = ceil(UIScreen.main.bounds.width * 0.80) - 60
            cell.customAlbumView.frame = CGRect(x: 0 ,y: getBottomEdgeY(inputView: cell.subject_photo) + 15 + textHeight ,width: cell.frame.size.width ,height: tempHeight)
            cell.img_imageButton1.frame = CGRect(x: 0 ,y: 0 ,width: cell.frame.size.width ,height: tempHeight)
            cell.img_imageButton1.contentMode = .scaleAspectFill
            if FileManager.default.fileExists(atPath: filePathArrayTemp[0]) {
                if let url = URL(string:filePathArrayTemp[0])
                {
                    cell.img_imageButton1.image = UIImage(contentsOfFile: url.path)
                }
            }
            dynamicHeight = tempHeight + 140 + textHeight
            cell.cellView.frame.size.height = dynamicHeight - 5
            self.dynamicRowHeight[activityFeed["action_id"] as? Int ?? 0] = dynamicHeight
            dataUploading(cell: cell, activityFeed: activityFeed, indexPath: indexPath)
            
        case 2:
            let tempHeight = ceil(UIScreen.main.bounds.width * 0.65) + 10
            cell.customAlbumView.frame = CGRect(x: 0 ,y: getBottomEdgeY(inputView: cell.subject_photo) + 15 + textHeight ,width: cell.frame.size.width ,height: tempHeight)
            
            if FileManager.default.fileExists(atPath: filePathArrayTemp[0]) {
                if let url = URL(string:filePathArrayTemp[0])
                {
                    cell.img_imageButton2.image = UIImage(contentsOfFile: url.path)
                }
            }
            
            if FileManager.default.fileExists(atPath: filePathArrayTemp[1]) {
                if let url = URL(string:filePathArrayTemp[1])
                {
                    cell.img_imageButton3.image = UIImage(contentsOfFile: url.path)
                }
            }
            
            dynamicHeight = tempHeight + 140 + textHeight
            cell.cellView.frame.size.height = dynamicHeight - 5
            self.dynamicRowHeight[activityFeed["action_id"] as? Int ?? 0] = dynamicHeight
            dataUploading(cell: cell, activityFeed: activityFeed, indexPath: indexPath)
        case 3:
            let tempHeight = ceil(UIScreen.main.bounds.width * 0.8)
            cell.customAlbumView.frame = CGRect(x: 0 ,y: getBottomEdgeY(inputView: cell.subject_photo) + 15 + textHeight ,width: cell.frame.size.width ,height: tempHeight + 10)
            
            if FileManager.default.fileExists(atPath: filePathArrayTemp[0]) {
                if let url = URL(string:filePathArrayTemp[0])
                {
                    cell.img_imageButton4.image = UIImage(contentsOfFile: url.path)
                }
            }
            
            if FileManager.default.fileExists(atPath: filePathArrayTemp[1]) {
                if let url = URL(string:filePathArrayTemp[1])
                {
                    cell.img_imageButton5.image = UIImage(contentsOfFile: url.path)
                }
            }
            
            if FileManager.default.fileExists(atPath: filePathArrayTemp[2]) {
                if let url = URL(string:filePathArrayTemp[2])
                {
                    cell.img_imageButton6.image = UIImage(contentsOfFile: url.path)
                }
            }
            
            dynamicHeight = tempHeight + 140 + textHeight
            cell.cellView.frame.size.height = dynamicHeight - 5
            self.dynamicRowHeight[activityFeed["action_id"] as? Int ?? 0] = dynamicHeight
            dataUploading(cell: cell, activityFeed: activityFeed, indexPath: indexPath)
        default:
            
            switch filePathArrayTemp.count {
            case 4:
                cell.countlabel.isHidden = true
                break
            default:
                cell.countlabel.isHidden = false
                cell.countlabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                let photoCount = filePathArrayTemp.count - 4
                cell.countlabel.text = "+\(photoCount)"
                break
            }
            
            let tempHeight = ceil(UIScreen.main.bounds.width * 0.8) + textHeight
            cell.customAlbumView.frame = CGRect(x: 0 ,y: getBottomEdgeY(inputView: cell.subject_photo) + 15 + textHeight ,width: cell.frame.size.width ,height: tempHeight + 10)
            
            if FileManager.default.fileExists(atPath: filePathArrayTemp[0]) {
                if let url = URL(string:filePathArrayTemp[0])
                {
                    cell.img_imageButton7.image = UIImage(contentsOfFile: url.path)
                }
            }
            
            if FileManager.default.fileExists(atPath: filePathArrayTemp[1]) {
                if let url = URL(string:filePathArrayTemp[1])
                {
                    cell.img_imageButton8.image = UIImage(contentsOfFile: url.path)
                }
            }
            
            if FileManager.default.fileExists(atPath: filePathArrayTemp[2]) {
                if let url = URL(string:filePathArrayTemp[2])
                {
                    cell.img_imageButton9.image = UIImage(contentsOfFile: url.path)
                }
            }
            if FileManager.default.fileExists(atPath: filePathArrayTemp[3]) {
                if let url = URL(string:filePathArrayTemp[3])
                {
                    cell.imageViewWithText.image = UIImage(contentsOfFile: url.path)
                }
            }
            dynamicHeight = tempHeight + 140
            cell.cellView.frame.size.height = dynamicHeight - 5
            self.dynamicRowHeight[activityFeed["action_id"] as? Int ?? 0] = dynamicHeight
            dataUploading(cell: cell, activityFeed: activityFeed, indexPath: indexPath)
        }
        
    }
    
    func imagesShowBasedOnCount(cell:AAFActivityFeedTableViewCell, count: Int)
    {
        fixViewsHideForDummyData(cell: cell)
        
        switch count {
        case 0:
            print("")
        case 1:
            cell.img_imageButton1.isHidden = false
        case 2:
            cell.img_imageButton2.isHidden = false
            cell.img_imageButton3.isHidden = false
        case 3:
            cell.img_imageButton4.isHidden = false
            cell.img_imageButton5.isHidden = false
            cell.img_imageButton6.isHidden = false
        default:
            cell.img_imageButton7.isHidden = false
            cell.img_imageButton8.isHidden = false
            cell.img_imageButton9.isHidden = false
            cell.imageViewWithText.isHidden = false
        }
    }
    func fixViewsHideForDummyData(cell:AAFActivityFeedTableViewCell)
    {
        cell.cntentShareFeedView.isHidden = true
        cell.mapButton.isHidden = true
        cell.bannerButton.isHidden = true
        cell.imageButton1.isHidden = true
        cell.imageButton2.isHidden = true
        cell.imageButton3.isHidden = true
        cell.imageButton4.isHidden = true
        cell.imageButton5.isHidden = true
        cell.imageButton6.isHidden = true
        cell.imageButton7.isHidden = true
        cell.imageButton8.isHidden = true
        cell.imageButton9.isHidden = true
        cell.img_mapButton.isHidden = true
        cell.img_bannerButton.isHidden = true
        cell.img_imageButton1.isHidden = true
        cell.img_imageButton2.isHidden = true
        cell.img_imageButton3.isHidden = true
        cell.img_imageButton4.isHidden = true
        cell.img_imageButton5.isHidden = true
        cell.img_imageButton6.isHidden = true
        cell.img_imageButton7.isHidden = true
        cell.img_imageButton8.isHidden = true
        cell.img_imageButton9.isHidden = true
        cell.imageViewWithText.isHidden = true
        cell.sellSlideShowView.isHidden = true
        //cell.body.isHidden = true
        cell.feedInfo.isHidden = true
        cell.bodyHashtaglbl.isHidden = true
        cell.bannerTitle.isHidden = true
        cell.sellDesc.isHidden = true
        cell.customAlbumView.isHidden = false
        cell.subject_photo.isHidden = false
        cell.subject_photo1.isHidden = false
        cell.title.isHidden = false
        
    }
    
    //Delegate
    func quickContentUpdateRequest(index : Int) {
        self.globalArrayFeed = feedArray
        // self.tableView.reloadData()
        let indexPath = IndexPath(item: index , section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    func quickContentDeleteRequest(_ cell: AAFActivityFeedTableViewCell)
    {
        DispatchQueue.main.async{
            if let indexPath = self.tableView.indexPath(for: cell) {
                cell.updateDisplay(progress: 0.0)
                isQuickContentInProcess = 0
                quickContentIncrementIndex -= 1
                if indexPath.row < feedArrayTemp.count
                {
                    feedArrayTemp.remove(at: indexPath.row)
                }
                let activityFeed = self.globalArrayFeed[indexPath.row] as! NSMutableDictionary
                uploadService.cancelUpload(activityFeed)
                if let filePathArrayTemp = activityFeed["filePathArray"] as? [String]
                {
                    for path in filePathArrayTemp{
                        //print("path removing==\(path)")
                        removeFileFromDocumentDirectoryAtPath(path)
                    }
                }
                // newDictionary["isDummyResponse"] = 2 as AnyObject
                // feedArray[index] = newDictionary
                feedArray.remove(at: indexPath.row)
                self.globalArrayFeed = feedArray
                //self.tableView.reloadData()
                let indexPath = IndexPath(item: indexPath.row , section: 0)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                if let cell = self.tableView.cellForRow(at: indexPath) as? AAFActivityFeedTableViewCell
                {
                    self.sharedVideoPlayer.removeLayerFor(cell: cell)
                }
                self.reload(indexPath.row)
            }
            
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async{
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if error != nil {
                if let e = error as? URLError, e.code == .notConnectedToInternet {
                    //Not connected to internet
                    //print(error?.localizedDescription)
                }
                else
                {
                    if let e = error as? URLError, e.code.rawValue == NSURLErrorTimedOut || Reachabable.isConnectedToNetwork()
                    {
                        //print("error?.localizedDescription \(error?.localizedDescription) code == \(e.code)")
                        
                        showToast(message: "Upload failed", controller: self, onView: false, time: 5.0)
                        
                        //print("session \(String(describing: error?.localizedDescription))")
                        // 1
                        guard let sourceURL = task.originalRequest else { return }
                        let download = uploadService.activeUploads[sourceURL]
                        uploadService.activeUploads[sourceURL] = nil
                        if  let filePathArrayTemp = download?.activityFeed["filePathArray"] as? [String]
                        {
                            for path in filePathArrayTemp{
                                ////print("path removing==\(path)")
                                removeFileFromDocumentDirectoryAtPath(path)
                            }
                        }
                        isQuickContentInProcess = 0
                        quickContentIncrementIndex -= 1
                        for (index,dic) in feedArrayTemp.enumerated()
                        {
                            if let dicT = dic as? NSMutableDictionary, dicT == download?.activityFeed
                            {
                                feedArrayTemp.remove(at: index)
                            }
                        }
                        for (index,dic) in self.globalArrayFeed.enumerated()
                        {
                            if let dicT = dic as? NSMutableDictionary, dicT == download?.activityFeed
                            {
                                self.globalArrayFeed.remove(at: index)
                                feedArray = self.globalArrayFeed
                                //self.tableView.reloadData()
                                let indexPath = IndexPath(item: index , section: 0)
                                self.tableView.deleteRows(at: [indexPath], with: .fade)
                                if let cell = self.tableView.cellForRow(at: indexPath) as? AAFActivityFeedTableViewCell
                                {
                                    self.sharedVideoPlayer.removeLayerFor(cell: cell)
                                }
                                self.reload(indexPath.row)
                            }
                            
                        }
                        
                    }
                }
            }
            else
            {
                // 1
                guard let sourceURL = task.originalRequest else { return }
                let download = uploadService.activeUploads[sourceURL]
                uploadService.activeUploads[sourceURL] = nil
                if  let filePathArrayTemp = download?.activityFeed["filePathArray"] as? [String]
                {
                    for path in filePathArrayTemp{
                        ////print("path removing==\(path)")
                        removeFileFromDocumentDirectoryAtPath(path)
                    }
                }
                if let trackCell = self.tableView.cellForRow(at: IndexPath(row: download?.activityFeed["index"] as! Int,                                                                       section: 0)) as? AAFActivityFeedTableViewCell {
                    trackCell.updateDisplay(progress: 0.0)
                }
                isQuickContentInProcess = 0
                
                do
                {
                    guard let dataT = download?.resumeData as Data? else {
                        return
                    }
                    if let json = try JSONSerialization.jsonObject(with: dataT, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary
                    {
                        if (json["status_code"] != nil)
                        {
                            if (json["status_code"] as! Int == 200)
                            {
                                if json["body"] != nil{
                                    
                                    if let dic = json["body"] as? [String : AnyObject], let activity_feed = dic["data"] as? NSArray{
                                        let activityFeeds = ActivityFeed.loadActivityFeedInfo(activity_feed)
                                        // //print(dic)
                                        self.updateFeedsArray(feed: activityFeeds.first!, index: dic["notifyItemAt"] as! Int)
                                    }
                                }
                                if ScheduleDisctionary.count > 0 {
                                    ScheduleDisctionary.removeAll()
                                    self.quickUploadFailedDelegate?.refreshDummyFeed()
                                     UIApplication.shared.keyWindow?.makeToast("Feed will post in a scheduled time.", duration: 4, position: "bottom")
                                }
                            }
                            else {
                                let msg = json["message"] as! String as AnyObject?
                                self.quickUploadFailedDelegate?.refreshDummyFeed()
                                UIApplication.shared.keyWindow?.makeToast(msg as! String, duration: 2, position: "bottom")
                            }
                        }
                        
                    }
                }
                catch
                {
                    print("Error:",error)
                    //                    print(String(data: Data!, encoding: .utf8) as Any)
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        DispatchQueue.main.async{
            // 1
            guard let url = task.originalRequest,
                let download = uploadService.activeUploads[url]  else { return }
            // 2
            download.progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
            
            isQuickContentInProcess = 1
            
            if let trackCell = self.tableView.cellForRow(at: IndexPath(row: download.activityFeed["index"] as! Int,                                                                       section: 0)) as? AAFActivityFeedTableViewCell {
                ////print("Progress == \(download.progress) index == \(download.activityFeed["index"] as! Int)")
                trackCell.updateDisplay(progress: download.progress)
                if download.progress == 1.0
                {
                    trackCell.showHideIndicator(show: false)
                }
                else
                {
                    trackCell.showHideIndicator(show: true)
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        //  //print("session \(session), received response \(response)")
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        DispatchQueue.main.async{
            // 1
            guard let url = dataTask.originalRequest,
                let download = uploadService.activeUploads[url]  else { return }
            // 2
            download.resumeData.append(data)
            uploadService.activeUploads[url] = download
        }
    }
    
    // Update/ Sink feedArray from [ActivityFeed] to show updates in ActivityFeed Table
    func updateFeedsArray(feed: ActivityFeed, index: Int){
        
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
        
        quickContentIncrementIndex -= 1
        for (indexTemp,dic) in feedArrayTemp.enumerated()
        {
            if let indexNotify = dic["notifyItemAt"] as? Int, indexNotify == index
            {
                if indexTemp < feedArrayTemp.count
                {
                    feedArrayTemp.remove(at: indexTemp)
                }
            }
        }
        var boolExistValue = false
        for (indexT,dic) in feedArray.enumerated()
        {
            if let isDummyResponse = dic["isDummyResponse"] as? Int, isDummyResponse != 2
            {
                if let indexNotify = dic["notifyItemAt"] as? Int, indexNotify == index
                {
                    boolExistValue = true
                    feedArray[indexT] = newDictionary
                    //feedArray.removeLast()
                    self.globalArrayFeed = feedArray
                    let indexPath = IndexPath(item: indexT , section: 0)
                    // self.tableView.insertRows(at: [indexPath], with: .fade)
                    self.tableView.reloadRows(at: [indexPath], with: .fade)
                    // self.tableView.reloadData()
                    feedArrayTikTok.insert(newDictionary, at: 0)
                }
            }
        }
        
        if boolExistValue == false
        {
            if let viewObj = self.parent as? AdvanceActivityFeedViewController
            {
                viewObj.browseFeed()
            }
        }
    }
    
    func feedAddInTikTokArray()
    {
        for activityFeed in globalArrayFeed
        {
            if let attachment = activityFeed["attachment"] as? NSArray
            {
                let attechmentDic = attachment[0] as! NSDictionary
                let attachment_video_type = attechmentDic["attachment_video_type"] as? Int ?? 0
                if let objectType = attechmentDic["attachment_type"] as? String, objectType == "video"
                {
                    if attachment_video_type == 3
                    {
                        if !feedArrayTikTok.contains{ $0 as! NSDictionary == activityFeed as! NSDictionary } {
                            // feedArrayTikTok.append(activityFeed)
                            if feedArrayTikTok.count != 0
                            {
                                feedArrayTikTok.insert(activityFeed, at: 0)
                            }
                        }
                        //                        var indexSelectedVideo = -1
                        //                        for (index, feed) in feedArrayTikTok.enumerated()
                        //                        {
                        //                            if feed["action_id"] as! Int == activityFeed["action_id"] as! Int
                        //                            {
                        //                                indexSelectedVideo = index
                        //                            }
                        //                        }
                    }
                }
            }
        }
    }
}

extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return boundingBox.height
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return boundingBox.width
    }
}
// MARK: - UITableViewDataSourcePrefetching
//extension FeedTableViewController: UITableViewDataSourcePrefetching {
//    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        ////print("prefetchRowsAt \(indexPaths)")
//      //  let urls = indexPaths.flatMap { ////print($0) }
//        //ImagePrefetcher(urls: urls).start()
//    }
//
//    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
//        ////print("cancelPrefetchingForRowsAt \(indexPaths)")
//    }
//}
extension UIActivityIndicatorView {
    func assignColor(_ color: UIColor) {
        style = .white
        self.color = color
    }
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}

// View when there is no feed to show in AAF
class NoPostView: UIView {
    var findFriendsLabel = UILabel()
    var imageView = UIImageView()
    var descriptionLabel = UILabel()
    var button = UIButton()
    var crossButton = UIButton()
    var backgroundImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        backgroundImage.frame = self.bounds
        backgroundImage.image = UIImage(named: "Add_Friend_Block_Background")
        backgroundImage.alpha = 0.4
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        backgroundImage.layer.masksToBounds = true
        self.insertSubview(backgroundImage, at: 0)
        let view = UIView()
        view.frame = self.bounds
        view.backgroundColor = .black
        view.alpha = 0.0000001
        insertSubview(view, at: 1)
        insertSubview(findFriendsLabel, at: 2)
        findFriendsLabel.frame = CGRect(x: 12, y: 5, width: 150, height: 20)
        insertSubview(imageView, at: 2)
        imageView.frame = CGRect(x: 12, y: getBottomEdgeY(inputView: findFriendsLabel) + 10, width: 70, height: 70)
        insertSubview(button, at: 2)
        imageView.image = UIImage(named: "Add_Friend_Block_Icon")
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            button.frame = CGRect(x: self.bounds.width - 80, y: self.bounds.height/2 - 10, width: 70, height: 30)
            descriptionLabel.frame = CGRect(x: getRightEdgeX(inputView: imageView)+15, y: getBottomEdgeY(inputView: findFriendsLabel) + 10, width: self.bounds.width - (getRightEdgeX(inputView: imageView)+5)-70, height: imageView.frame.height)
            descriptionLabel.font = UIFont.systemFont(ofSize: 14)
            descriptionLabel.text = NSLocalizedString("Add Friends to see new\nupdates and keep up with\nlatest news.", comment: "")
            descriptionLabel.numberOfLines = 3
        }
        else {
            button.frame = CGRect(x: self.bounds.width - 100, y: self.bounds.height/2 - 10, width: 90, height: 30)
            descriptionLabel.frame = CGRect(x: getRightEdgeX(inputView: imageView)+25, y: getBottomEdgeY(inputView: findFriendsLabel) + 10, width: self.bounds.width - (getRightEdgeX(inputView: imageView)+5)-70, height: imageView.frame.height)
            descriptionLabel.font = UIFont.systemFont(ofSize: 18)
            descriptionLabel.text = NSLocalizedString("Add Friends to see new updates and keep up with\nlatest news.", comment: "")
            descriptionLabel.numberOfLines = 2
            descriptionLabel.textAlignment = .center
        }
        
        insertSubview(descriptionLabel, at: 2)
        findFriendsLabel.text = NSLocalizedString("Find Friends", comment: "")
        findFriendsLabel.font = UIFont.systemFont(ofSize: 14)
        
        
        descriptionLabel.adjustsFontSizeToFitWidth = true
        descriptionLabel.textColor = UIColor.gray
        button.layer.borderWidth = 1
        button.layer.borderColor = buttonColor.cgColor
        button.setTitle(NSLocalizedString("Add", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = buttonColor
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.layer.cornerRadius = button.frame.height/2
        crossButton.frame = CGRect(x: self.bounds.width - 50, y: 5, width: 40, height: 40)
        crossButton.setTitle("X", for: .normal)
        crossButton.titleEdgeInsets.top = 1
        insertSubview(crossButton, at: 3)
        bringSubviewToFront(crossButton)
        crossButton.setTitleColor(textColorDark, for: .normal)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// Display view when there is no content to show in browse pages
class NoContentView: UIView {
    var image = UIImageView()
    var label = UILabel()
    var button = UIButton()
    var imageHeight:CGFloat = 200
    var buttonWidth: CGFloat = 100
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let gifImage = UIImage(gifName: "GIF_NO_CONTENT_500PX", levelOfIntegrity:0.8)
        let gifmanager = SwiftyGifManager(memoryLimit:20)
        image.setGifImage(gifImage, manager: gifmanager, loopCount: 1)
        image.contentMode = UIView.ContentMode.scaleAspectFill
        addSubview(image)
        addSubview(label)
        addSubview(button)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        image.frame = CGRect(x: frame.width/2 - (imageHeight/2), y: 5, width: imageHeight, height: imageHeight)
        label.frame = CGRect(x: 0, y: getBottomEdgeY(inputView: image) - 20, width: self.bounds.width, height: 40)
        label.numberOfLines = 2
        label.textColor = UIColor.gray
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        button.frame = CGRect(x: frame.width/2 - (buttonWidth/2), y: getBottomEdgeY(inputView: label)+20, width: buttonWidth, height: 35)
        button.layer.cornerRadius = button.frame.height/2
        button.layer.masksToBounds = true
        button.clipsToBounds = true
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = buttonColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// display arrow under the emoji view when we long press the like button
class Triangle: UIView {
    override func draw(_ rect: CGRect) {
        let mask = CAShapeLayer()
        mask.frame = self.layer.bounds
        mask.strokeColor = UIColor.black.cgColor
        mask.lineWidth = 1.0
        
        let width = self.layer.frame.size.width
        let height = self.layer.frame.size.height
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width/2, y: height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

protocol QuickUploadFailedDelegate: class {
    func refreshDummyFeed()
}




