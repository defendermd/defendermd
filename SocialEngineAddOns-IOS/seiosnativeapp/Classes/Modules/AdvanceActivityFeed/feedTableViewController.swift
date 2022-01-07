//
//  feedTableViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 08/06/16.
//  Copyright © 2016 bigstep. All rights reserved.
//
import GoogleMobileAds
import FBAudienceNetwork
import UIKit

var globalFeedHeight : CGFloat! = 10.0
var scrollopoint:CGPoint!
var tableViewFrameType = ""
var advGroupDetailUpdate = true
var reportDic:NSDictionary = [:]
class FeedTableViewController: UITableViewController, TTTAttributedLabelDelegate, UIGestureRecognizerDelegate,GADNativeAppInstallAdLoaderDelegate, FBNativeAdDelegate, FBNativeAdsManagerDelegate{
    
    
    var globalArrayFeed = [AnyObject]()
    var userFeeds:Bool = false
    var RedirectText : String!
    var listingTitle:String!
    
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
    var imageCache = [String:UIImage]()
    var titleshow :Bool  = false
    var action_id:Int!
    var noCommentMenu:Bool = false
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
    var adLoader: GADAdLoader!
    var loadrequestcount:Int = 0
    var adsCount:Int = 0
    var isnativeAd:Bool = true
    var displyedAdsCount:Int = 0
    
    // Native FacebookAd Variable
    var facebookAdViewContainer : FBNativeAdView!
    var adChoicesView: FBAdChoicesView!
    var adTitleLabel:UILabel!
    var adIconImageView:UIImageView!
    var adImageView:FBMediaView!
    var adBodyLabel:UILabel!
    var adCallToActionButton:UIButton!
    var fbView:UIView!
    var nativeAd:FBNativeAd!
    var hidingNavBarManager: HidingNavigationBarManager?
    var admanager:FBNativeAdsManager!
    
    var reactionsIcon = [AnyObject]()
    
    let subscriptionTagLinkAttributes = [
        NSForegroundColorAttributeName: textColorDark,
        // NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]

    let subscriptionNoticeLinkAttributes = [
        NSForegroundColorAttributeName: navColor,
        // NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    let subscriptionNoticeActiveLinkAttributes = [
        NSForegroundColorAttributeName: UIColor.gray.withAlphaComponent(0.80),
        //NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    var guttermenuoption = [String]()
    var guttermenuoptionname = [String]()
    var feedMenu : NSArray = []
    var currentCell : Int = 0
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
    var adSponserdTitleLabel:UILabel!
    var adSponserdLikeTitle : TTTAttributedLabel!
    var addLikeTitle : UIButton!
    var imageButton : UIButton!
    var isLike:Bool!
    var communityAdsValues : NSMutableArray = []
    var adsReportView : AdsReportViewController!
    var parametersNeedToAdd = Dictionary<String, String>()
    var blackScreenForAdd : UIView!
    var adsImage : UIImageView!
    
    //User suggestions
    var userSuggestions = [Any]()
    var suggestionsCellView: UIView!
    var viewTitle: UILabel!
    var suggestionsScrollView: UIScrollView!
    var suggestionView: UIView!
    var suggestionImageView: UIImageView!
    var suggestionDetailView: UIView!
    var contentTitle: UILabel!
    var contentDetail: UILabel!
    var addFriend: UIButton!
    var removeSuggestion: UIButton!
    var seeAll: UIButton!
    var findMoreSuggestions: UIButton!
    var contentRedirectionView: UIButton!
    var isHomeFeeds = false
    var placeholderImage : UIImage!
    var tagOtherUserCount : Int = 0
    var arrayForCell = NSMutableArray()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        nativeAdArray.removeAll(keepingCapacity : false)
        checkforAds()
        
        let colorforimage = hexStringToUIColor(hex: "#eeeeee")
        placeholderImage = imagefromColor(colorforimage)
        
        // MARK: - TableView Start after Navigation in case of Pages
        if footerDashboard == true
        {
            if tableViewFrameType == "AdvanceActivityFeedViewController" || tableViewFrameType == "HashTagFeedViewController"
            {
                tableView = UITableView(frame: CGRect(x: 0, y: 64, width: view.bounds.width, height: view.bounds.height - 30 - 64), style: UITableViewStyle.grouped)
            }
            else
            {
                tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 30), style: UITableViewStyle.grouped)
            }
            
        }
        else
        {
            if tableViewFrameType == "AdvanceActivityFeedViewController"  || tableViewFrameType == "HashTagFeedViewController"
            {
                tableView = UITableView(frame: CGRect(x: 0, y: 64, width: view.bounds.width, height: view.bounds.height + 20 - 64), style: UITableViewStyle.grouped)
            }
            else
            {
                tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height + 20), style: UITableViewStyle.grouped)
            }
            
        }
        tableView.register(AAFActivityFeedTableViewCell.self, forCellReuseIdentifier: "cell")
//        tableView.estimatedRowHeight = 60.0
//        tableView.rowHeight = UITableViewAutomaticDimension
        if tableViewFrameType == "Pages" || tableViewFrameType == "MLTClassifiedAdvancedTypeViewController" || tableViewFrameType == "MLTClassifiedSimpleTypeViewController" || tableViewFrameType == "MLTBlogTypeViewController" || tableViewFrameType == "advGroup"
        {
            tableView.backgroundColor = aafBgColor
        }
        else
        {
            tableView.backgroundColor = tableViewBgColor//aafBgColor
        }
        tableView.separatorColor = TVSeparatorColorClear
    }
    
    func checkforAds()
    {
        switch adsType_feeds {
        case 0:
            if kFrequencyAdsInCells_feeds > 4 && adUnitID != ""
            {
                showNativeAd()
                
            }
            break
        case 1:
            if kFrequencyAdsInCells_feeds > 4 && placementID != ""
            {
                
                self.showFacebookAd()
                
            }
            break
        default:
            checkCommunityAds()
        }
    }
    
    //MARK: -  Functions that we are using for community ads and sponsered stories
    func checkCommunityAds()
    {
        
        spinner.startAnimating()
        if reachability.isReachable
        {
            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
            
            dic["type"] =  "\(adsType_feeds)"
            dic["placementCount"] = "\(kFrequencyAdsInCells_feeds)"
            post(dic, url: "communityads/index", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if let advertismentsArray = body["advertisments"] as? NSArray
                                {
                                    self.communityAdsValues = advertismentsArray as! NSMutableArray
                                    switch adsType_feeds {
                                    case 2:
                                        if kFrequencyAdsInCells_feeds > 4 && adUnitID != ""
                                        {
                                            self.uiOfCommunityAds(count: advertismentsArray.count){
                                                (status : Bool) in
                                                if status == true{
                                                    self.tableView.reloadData()
                                                }
                                            }
                                            
                                        }
                                        break
                                    case 4:
                                        if kFrequencyAdsInCells_feeds > 4 && placementID != ""
                                        {
                                            self.uiOfSponseredAds(count: advertismentsArray.count){
                                                (status : Bool) in
                                                if status == true{
                                                    self.tableView.reloadData()
                                                }
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
            UIApplication.shared.keyWindow?.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    
    func uiOfCommunityAds(count : Int,completion: @escaping (_ status: Bool) -> Void)
    {
        var status  = false
        for i in 0  ..< communityAdsValues.count{
            
            if  let dic = communityAdsValues[i]  as? NSDictionary {
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
                
                adsImage = createImageView(CGRect(x: 0, y: 0, width: 18, height: 15), border: true)
                adsImage.image = UIImage(named: "ad_badge.png")
                self.fbView.addSubview(adsImage)
                
                adTitleLabel = UILabel(frame: CGRect(x:  23,y: 10,width: self.fbView.bounds.width-(40),height: 30))
                adTitleLabel.numberOfLines = 0
                adTitleLabel.textColor = textColorDark
                adTitleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                let title = String(describing: dic["cads_title"]!)
                adTitleLabel.text = title
                adTitleLabel.sizeToFit()
                self.fbView.addSubview(adTitleLabel)
                
                
                adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-(20), y: 10,width: 15,height: 15))
                adCallToActionButton.setImage(UIImage(named: "cross_icon")!.maskWithColor(color: textColorDark), for: UIControlState())
                adCallToActionButton.backgroundColor = UIColor.clear
                adCallToActionButton.layer.cornerRadius = 2;
                adCallToActionButton.layer.shouldRasterize = true
                adCallToActionButton.layer.rasterizationScale = UIScreen.main.scale
                adCallToActionButton.layer.isOpaque = true

                adCallToActionButton.tag = i
                adCallToActionButton.addTarget(self, action: #selector(FeedTableViewController.actionAfterClick(_:)), for: .touchUpInside)
                self.fbView.addSubview(adCallToActionButton)
                if  (UIDevice.current.userInterfaceIdiom == .phone)
                {
                    imageButton = createButton(CGRect(x: 5,y: self.adTitleLabel.bounds.height + 15 + self.adTitleLabel.frame.origin.y,width: self.fbView.bounds.width-10,height: 160),title: "", border: false, bgColor: false, textColor: textColorLight)
                    adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.fbView.bounds.width-10,height: 160), border: false)
                }
                else
                {
                    imageButton = createButton(CGRect(x: 5,y: self.adTitleLabel.bounds.height + 10 + self.adTitleLabel.frame.origin.y,width: self.fbView.bounds.width-10,height: 300),title: "", border: false, bgColor: false, textColor: textColorLight)
                    adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.fbView.bounds.width-10,height: 300), border: false)
                }

                adImageView1.contentMode = UIViewContentMode.scaleAspectFill
                adImageView1.clipsToBounds = true
                adImageView1.setShowActivityIndicator(true)
                adImageView1.setIndicatorStyle(.gray)
                if dic["image"] != nil{
                    let icon = dic["image"]
                    let url = URL(string:icon as! String)
                    adImageView1.sd_setImage(with: url as URL!)
                }
                imageButton.tag = i
                imageButton.addTarget(self, action: #selector(FeedTableViewController.tappedOnAds(_:)), for: .touchUpInside)
                
                
                self.fbView.addSubview(imageButton)
                imageButton.addSubview(adImageView1)
                
                
                adBodyLabel = UILabel(frame: CGRect(x: 10,y: imageButton.bounds.height + 15 + imageButton.frame.origin.y,width: self.fbView.bounds.width-20,height: 40))
                adBodyLabel.numberOfLines = 0
                adBodyLabel.textColor = textColorDark
                adBodyLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
                self.fbView.addSubview(adBodyLabel)
                var description = String(describing: dic["cads_body"]!)
                description = description.html2String
                adBodyLabel.text = description
                
                nativeAdArray.append(self.fbView)
                if i == count - 1{
                    status = true
                    completion(status)
                    
                }
                
            }
        }
        
    }
    
    func uiOfSponseredAds(count : Int,completion: @escaping (_ status: Bool) -> Void){
        var status  = false
        
        for i in 0  ..< communityAdsValues.count{
            var userCount = 0
            var titleOfAds = ""
            var resourceTitle = ""
            let usersLike: NSMutableArray = []
            if  let dic = communityAdsValues[i]  as? NSDictionary {
                if let likesdic =  dic["likes"] as? NSArray{
                    for tempdic in likesdic{
                        if let particularLikeDictionary = tempdic as? NSDictionary{
                            let userTitle = particularLikeDictionary["user_title"]!
                            usersLike.add(userTitle)
                            
                        }
                        
                    }
                    userCount =  usersLike.count
                    switch userCount {
                    case 1:
                        titleOfAds = String(format: NSLocalizedString("%@ likes", comment: ""), usersLike[0] as! String)
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
                    resourceTitle = String(describing: dic["resource_title"]!)
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
                
                
                adSponserdLikeTitle = TTTAttributedLabel(frame:CGRect(x:  10,y: 5,width: self.fbView.bounds.width-(30),height: 40))
                adSponserdLikeTitle.numberOfLines = 0
                adSponserdLikeTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                adSponserdLikeTitle.delegate = self
                adSponserdLikeTitle.setText(titleOfAds, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                    let boldFont = CTFontCreateWithName( fontBold as CFString?, FONTSIZENormal, nil)
                    
                    let range4 = (titleOfAds as NSString).range(of:NSLocalizedString("\(resourceTitle)",  comment: ""))
                    mutableAttributedString?.addAttribute(kCTFontAttributeName as String, value: boldFont, range: range4)
                    mutableAttributedString?.addAttribute(kCTForegroundColorAttributeName as String, value:textColorDark , range: range4)
                    
                    
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
                                            mutableAttributedString?.addAttribute(kCTFontAttributeName as String, value: boldFont, range: range)
                                            mutableAttributedString?.addAttribute(kCTForegroundColorAttributeName as String, value:navColor , range: range)
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
                
                
                adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-(20), y: 5,width: 15,height: 15))
                adCallToActionButton.setImage(UIImage(named: "cross_icon")!.maskWithColor(color: textColorDark), for: UIControlState())
                adCallToActionButton.backgroundColor = UIColor.clear
                adCallToActionButton.layer.cornerRadius = 2;
                adCallToActionButton.layer.shouldRasterize = true
                adCallToActionButton.layer.isOpaque = true// this value vary as per your desire
                adCallToActionButton.layer.rasterizationScale = UIScreen.main.scale
                adCallToActionButton.tag = i
                adCallToActionButton.addTarget(self, action: #selector(FeedTableViewController.actionAfterClick(_:)), for: .touchUpInside)
                self.fbView.addSubview(adCallToActionButton)
                
                ///
                let originY = adSponserdLikeTitle.frame.origin.y + adSponserdLikeTitle.frame.size.height +  10
                
                if  (UIDevice.current.userInterfaceIdiom == .phone)
                {
                    customAlbumView = createView(CGRect(x: 10,y: originY, width: self.fbView.bounds.width-(20) ,height: 150 + 30) , borderColor: UIColor.clear , shadow: false)
                }
                else
                {
                    customAlbumView =  createView(CGRect(x: 10,y: originY, width: self.fbView.bounds.width-(20) ,height: 300 + 30) , borderColor: UIColor.clear , shadow: false)
                }
            
                customAlbumView.tag = i
                customAlbumView.backgroundColor = UIColor.clear
                self.fbView.addSubview(customAlbumView)
                
                
                if  (UIDevice.current.userInterfaceIdiom == .phone)
                {
                    adImageView1 = createImageView(CGRect(x: 0,y: 0,width: self.customAlbumView.bounds.width,height: 150), border: false)
                }
                else
                {
                    adImageView1 = createImageView(CGRect(x: 5,y: 0,width: self.customAlbumView.bounds.width,height: 300), border: false)
                }
                adImageView1.contentMode = UIViewContentMode.scaleAspectFill
                adImageView1.clipsToBounds = true
                adImageView1.setShowActivityIndicator(true)
                adImageView1.setIndicatorStyle(.gray)
                if dic["image"] != nil{
                    let icon = dic["image"]
                    let url = URL(string:icon as! String)
                    adImageView1.sd_setImage(with: url as URL!)
                }
                customAlbumView.addSubview(adImageView1)
                
                let aTap = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewController.tappedSponseredAds(sender:)))
                customAlbumView.addGestureRecognizer(aTap)
                
                
                adSponserdTitleLabel = UILabel(frame: CGRect(x:  0,y: adImageView1.frame.size.height + adImageView1.frame.origin.y,width: self.customAlbumView.bounds.width,height: 30))
                adSponserdTitleLabel.numberOfLines = 2
                adSponserdTitleLabel.textColor = textColorDark
                adSponserdTitleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                adSponserdTitleLabel.text = String(describing: dic["resource_title"]!)
                customAlbumView.addSubview(adSponserdTitleLabel)
                let islike = (dic["isLike"] as? Int)!
                if islike == 0{
                    var likeTitle = ""
                    var resourceType = ""
                    resourceType =  String(describing: dic["module_title"]!)
                    likeTitle = String(format: NSLocalizedString("Like This %@", comment:""),resourceType)
                    addLikeTitle = UIButton(frame:CGRect(x:  customAlbumView.bounds.width/2 - 50,y: customAlbumView.frame.size.height + customAlbumView.frame.origin.y,width: self.fbView.bounds.width - (customAlbumView.bounds.width/2 - 50),height: 30))
                    addLikeTitle.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                    addLikeTitle.backgroundColor = navColor
                    addLikeTitle.setTitle("\(likeIcon) \(likeTitle)", for: UIControlState.normal)
                    addLikeTitle.contentHorizontalAlignment = .center
                    addLikeTitle.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
                    addLikeTitle.sizeToFit()
                    addLikeTitle.tag = i
                    addLikeTitle.addTarget(self, action: #selector(FeedTableViewController.actionLikeUnlike(_:)), for: .touchUpInside)
                    self.fbView.addSubview(addLikeTitle)
                    addLikeTitle.frame.origin.x = customAlbumView.bounds.width/2 - addLikeTitle.frame.size.width/2
                    
                    
                    
                }
                
                nativeAdArray.append(self.fbView)
                
                if i == count - 1{
                    status = true
                    completion(status)
                    
                }
                
                
            }
        }
    }
    
    func actionAfterClick(_ sender: UIButton){
        
        
        var dictionary = Dictionary<String, String>()
        dictionary["type"] =  "\(adsType_feeds)"
        dictionary["placementCount"] = "\(kFrequencyAdsInCells_feeds)"
        let dic = communityAdsValues[sender.tag] as? NSDictionary
        if dic?["campaign_id"] != nil{
            dictionary["adsId"] =  String(describing: dic?["campaign_id"]!)
        }
        else if dic?["ad_id"] != nil{
            dictionary["adsId"] =  String(describing: dic?["ad_id"]!)
        }
        parametersNeedToAdd = dictionary
        if reportDic.count == 0{
            if reachability.isReachable {
                // Send Server Request for Comments
                post(dictionary, url: "communityads/index/remove-ad", method: "GET") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        spinner.stopAnimating()
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
                                                    
                                                    
                                                    UIView.animate(withDuration: 0.5) { () -> Void in
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
                UIApplication.shared.keyWindow?.makeToast(network_status_msg, duration: 5, position: "bottom")
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
            
            
            UIView.animate(withDuration: 0.5) { () -> Void in
                self.adsReportView.frame.origin.y = (self.parent?.view.bounds.height)!/2 - self.adsReportView.frame.height/2 - 50
                self.blackScreenForAdd.alpha = 0.5
                
            }
            
        }
        
    }
    
    func tappedOnAds(_ sender: UIButton){
        let dic = communityAdsValues[sender.tag] as? NSDictionary
        if dic?["cads_url"] != nil{
            fromExternalWebView = true
            let presentedVC = ExternalWebViewController()
            presentedVC.url = dic?["cads_url"]! as! String
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated: true, completion: nil)
        }
        
    }
    
    func tappedSponseredAds(sender: UITapGestureRecognizer){
        
        let view = sender.view
        let tag = view?.tag
        let dic = communityAdsValues[tag!] as? NSDictionary
        let resourceId = dic?["resource_id"]
        if dic?["resource_type"] != nil{
            let resourceType = dic?["resource_type"] as! String!
            if resourceType == "video"{
                VideoObject().redirectToVideoProfilePage(self,videoId: resourceId as! Int,videoType: dic?["video_type"] as! Int,videoUrl: dic?["video_url"] as! String)
                
            }
            else if resourceType == "blog"{
                BlogObject().redirectToBlogDetailPage(self,blogId: resourceId as! Int,title: "")
            }
            else if resourceType == "classified"{
                ClassifiedObject().redirectToProfilePage(self, id: resourceId as! Int)
            }
            else if resourceType == "album"{
                let presentedVC = AlbumProfileViewController()
                presentedVC.albumId = resourceId as! Int!
                self.navigationController?.pushViewController(presentedVC, animated: false)
            }
            else if resourceType == "music_playlist"{
                MusicObject().redirectToPlaylistPage(self,id: resourceId as! Int)
            }
            else if resourceType == "poll"{
                let presentedVC = PollProfileViewController()
                presentedVC.pollId =   resourceId as! Int!
                self.navigationController?.pushViewController(presentedVC, animated: false)
                
            }
            else if resourceType == "sitepage_page"{
                SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: resourceId as! Int)
            }
            else if resourceType == "group"{
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "group"
                presentedVC.subjectId =   resourceId as! Int!
                self.navigationController?.pushViewController(presentedVC, animated: false)
            }
            else if resourceType == "event"{
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "event"
                presentedVC.subjectId =   resourceId as! Int!
                self.navigationController?.pushViewController(presentedVC, animated: false)
            }
            else if resourceType == "siteevent_event"{
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "advancedevents"
                presentedVC.subjectId =   resourceId as! Int!
                self.navigationController?.pushViewController(presentedVC, animated: true)
            }
            else if resourceType == "sitestoreproduct_product"
            {
                SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id: resourceId as! Int)
            }
            else if resourceType == "sitestore_store"{
                SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: resourceId as! Int)
            }
            
        }
        
    }
    
    func actionLikeUnlike(_ sender: UIButton){
        spinner.startAnimating()
        let dic = communityAdsValues[sender.tag] as? NSDictionary
        
        let islike = (dic?["isLike"] as? Int)!
        var path = ""
        switch islike {
        case 0:
            path = "like"
            break
        default:
            path = "unlike"
            break
        }
        let resourceId = dic?["resource_id"] as! Int!
        let resourceType = dic?["resource_type"] as! String!
        post(["subject_id":String(describing: resourceId!), "subject_type": resourceType!], url: path, method: "POST") {
            (succeeded, msg) -> () in
            
            DispatchQueue.main.async(execute: {
                if msg{
                    // On Success Update
                    if succeeded["message"] != nil{
                        spinner.stopAnimating()
                        
                        var likeTitle = ""
                        var resourceTitle = ""
                        resourceTitle = dic?["module_title"] as! String!
                        let tempDic : NSMutableDictionary! = [:]
                        
                        for(k,v) in dic!{
                            let islike1 = (dic?["isLike"] as? Int)!
                            if (k as! String == "isLike"){
                                if islike1 == 0{
                                    
                                    tempDic["isLike"] = 1
                                    likeTitle = String(format: NSLocalizedString("Unlike This %@", comment:""),resourceTitle)
                                    self.tableView.reloadData()
                                    
                                }
                                else{
                                    tempDic["isLike"] = 0
                                    likeTitle = String(format: NSLocalizedString("Like This %@", comment:""),resourceTitle)
                                    self.tableView.reloadData()
                                    
                                }
                            }
                            else{
                                tempDic[k] = v
                            }
                        }
                        
                        self.communityAdsValues[sender.tag] = tempDic
                        sender.frame.size.width = 120
                        sender.setTitle("\(likeIcon) \(likeTitle)", for: UIControlState.normal)
                        sender.sizeToFit()
                        
                    }
                }
            })
        }
        
    }
    
    func doneAfterReportSelect(){
        for ob in adsReportView.subviews{
            if ob is UITextField{
                ob.resignFirstResponder()
            }
            
        }
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
    
    func pressedAd(_ sender: UIButton){
        parametersNeedToAdd["adCancelReason"] =  configArray["\(sender.tag)"]!
        sender.setTitle("\u{f111}", for: UIControlState.normal)
        if parametersNeedToAdd["adCancelReason"] != "Other"{
            removeAd()
        }
        else{
            for ob in adsReportView.subviews{
                if ob is UITextField{
                    ob.isHidden = false
                }
                if ob.tag == 1000{
                    ob.isHidden = false
                }
            }
        }
    }
    
    func removeAd(){
        spinner.startAnimating()
        self.parent?.view.makeToast(NSLocalizedString("Thanks for your feedback. Your report has been submitted.", comment: ""), duration: 5, position: "bottom")
        self.doneAfterReportSelect()
        if reachability.isReachable {
            post(parametersNeedToAdd, url: "communityads/index/remove-ad", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    spinner.stopAnimating()
                    if msg
                    {
                        if succeeded["body"] != nil{
                            self.nativeAdArray.removeAll(keepingCapacity: false)
                            self.checkCommunityAds()
                        }
                    }
                })
            }
            
        }
        else
        {
            // No Internet Connection Message
            self.parent?.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    
    func removeOtherReason(){
        for ob in adsReportView.subviews{
            if ob is UITextField{
                let view = ob as? UITextField
                parametersNeedToAdd["adDescription"] = view?.text
            }
        }
        removeAd()
        
    }
    
    // MARK: - FacebookAd Delegate
    func showFacebookAd()
    {
        //FBAdSettings.addTestDevices(fbTestDevice)
        //FBAdSettings.addTestDevice("HASHED ID")
        admanager = FBNativeAdsManager(placementID: placementID, forNumAdsRequested: 15)
        admanager.delegate = self
        admanager.mediaCachePolicy = FBNativeAdsCachePolicy.all
        admanager.loadAds()
        
    }
    
    func nativeAdsLoaded()
    {
        for _ in 0 ..< 10
        {
            self.nativeAd = admanager.nextNativeAd()
            self.fetchAds(nativeAd: self.nativeAd)
        }
        
    }
    
    func fetchAds(nativeAd: FBNativeAd)
    {
        
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
        self.adIconImageView = UIImageView(frame: CGRect(x: 5,y: 5,width: 40,height: 40))
        nativeAd.icon?.loadAsync(block: { (iconImage) -> Void in
            if let image = iconImage {
                
                self.adIconImageView.image = image
            }
            
        })
        
        self.fbView.addSubview(self.adIconImageView)
        
        
        adTitleLabel = UILabel(frame: CGRect(x: self.adIconImageView.bounds.width + 10,y: 5,width: self.fbView.bounds.width-(self.adIconImageView.bounds.width + 55),height: 30))
        adTitleLabel.numberOfLines = 0
        adTitleLabel.textColor = textColorDark
        adTitleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
        adTitleLabel.text = nativeAd.title
        self.fbView.addSubview(adTitleLabel)
        
        
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            adImageView = FBMediaView(frame: CGRect(x: 5,y: self.adIconImageView.bounds.height + 10 + self.adIconImageView.frame.origin.y,width: self.fbView.bounds.width-10,height: 150))
        }
        else
        {
            adImageView = FBMediaView(frame: CGRect(x: 5,y: self.adIconImageView.bounds.height + 10 + self.adIconImageView.frame.origin.y,width: self.fbView.bounds.width-10,height: 300))
        }
        
        self.adImageView.nativeAd = nativeAd
        self.adImageView.clipsToBounds = true
        self.fbView.addSubview(adImageView)
        
        
        adBodyLabel = UILabel(frame: CGRect(x: 10,y: adImageView.bounds.height + 10 + adImageView.frame.origin.y,width: self.fbView.bounds.width-100,height: 40))
        
        if let _ = nativeAd.body {
            adBodyLabel.text = nativeAd.body
        }
        
        adBodyLabel.numberOfLines = 0
        adBodyLabel.textColor = textColorDark
        adBodyLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        self.fbView.addSubview(adBodyLabel)
        
        adCallToActionButton = UIButton(frame:CGRect(x: self.fbView.bounds.width-80, y: adImageView.bounds.height + 20 + adImageView.frame.origin.y,width: 70,height: 30))
        
        adCallToActionButton.setTitle(nativeAd.callToAction, for: UIControlState.normal)
        
        adCallToActionButton.titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
        adCallToActionButton.titleLabel?.textColor = navColor
        adCallToActionButton.backgroundColor = navColor
        adCallToActionButton.layer.cornerRadius = 2
        adCallToActionButton.layer.shouldRasterize = true
        adCallToActionButton.layer.isOpaque = true; // this value vary as per your desire
        adCallToActionButton.layer.rasterizationScale = UIScreen.main.scale
        adCallToActionButton.clipsToBounds = true
        self.fbView.addSubview(adCallToActionButton)
        
        
        nativeAd.registerView(forInteraction: self.fbView, with: self)
        nativeAdArray.append(self.fbView)
        
        if nativeAdArray.count == 10
        {
            self.tableView.reloadData()
        }
        
        
    }
    
    func nativeAdsFailedToLoadWithError(_ error: Error)
    {
        
    }
    
    // MARK: - GADAdLoaderDelegate
    func showNativeAd()
    {
        
        var adTypes = [String]()
        if iscontentAd == true
        {
            if isnativeAd
            {
                adTypes.append(kGADAdLoaderAdTypeNativeAppInstall)
                isnativeAd = false
            }
            else
            {
                adTypes.append(kGADAdLoaderAdTypeNativeContent)
                isnativeAd = true
            }
            
        }
        else
        {
            adTypes.append(kGADAdLoaderAdTypeNativeAppInstall)
        }
        
        
        let options = GADNativeAdImageAdLoaderOptions()
        options.preferredImageOrientation = .landscape
        
        adLoader = GADAdLoader(adUnitID: adUnitID, rootViewController: self,
                               adTypes: adTypes, options: [options])
        adLoader.delegate = self
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID,"5431f9841e382a606b19b38a7846df81","c6adea630f210d80ef5673aa4a78b500","40cd3e71cf06e1754ada161ff60ab41e"]
        
        adLoader.load(request)
        
        
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(adLoader) failed with error: \(error.localizedDescription)")
        
    }
    
    // Mark: - GADNativeAppInstallAdLoaderDelegat
    func adLoader(_ adLoader: GADAdLoader!, didReceive nativeAppInstallAd: GADNativeAppInstallAd!)
    {
        
        if loadrequestcount <= 10
        {
            loadrequestcount = loadrequestcount+1
            showNativeAd()
            
        }
        
        let appInstallAdView = Bundle.main.loadNibNamed("NativeAdAdvancedevent", owner: nil,
                                                        options: nil)?.first as! GADNativeAppInstallAdView
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            appInstallAdView.frame = CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: appInstallAdView.frame.size.height+150)
        }
        else
        {
            appInstallAdView.frame = CGRect(x:0,y: 0,width: UIScreen.main.bounds.width,height: appInstallAdView.frame.size.height-10)
            
        }
        
        // Associate the app install ad view with the app install ad object. This is required to make
        // the ad clickable.
        appInstallAdView.nativeAppInstallAd = nativeAppInstallAd
        appInstallAdView.tag = 1001001
        
        
        (appInstallAdView.iconView as! UIImageView).frame = CGRect(x:5,y: 5,width: 40,height: 40)
        (appInstallAdView.iconView as! UIImageView).image = nativeAppInstallAd.icon?.image
        
        (appInstallAdView.headlineView as! UILabel).frame = CGRect(x: (appInstallAdView.iconView as! UIImageView).bounds.width + 10 ,y: 5,width: appInstallAdView.bounds.width-((appInstallAdView.iconView as! UIImageView).bounds.width + 55),height: 30)
        (appInstallAdView.headlineView as! UILabel).numberOfLines = 0
        (appInstallAdView.headlineView as! UILabel).textColor = textColorDark
        (appInstallAdView.headlineView as! UILabel).font = UIFont(name: fontBold, size: FONTSIZENormal)
        (appInstallAdView.headlineView as! UILabel).text = nativeAppInstallAd.headline
        
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            (appInstallAdView.imageView as! UIImageView).frame = CGRect(x: 5,y: (appInstallAdView.iconView as! UIImageView).bounds.height + 10 + (appInstallAdView.iconView as! UIImageView).frame.origin.y,width: appInstallAdView.bounds.width-10,height: 150)
        }
        else
        {
            (appInstallAdView.imageView as! UIImageView).frame = CGRect(x: 5,y: (appInstallAdView.iconView as! UIImageView).bounds.height+10+(appInstallAdView.iconView as! UIImageView).frame.origin.y,width: appInstallAdView.bounds.width-10,height: 300)
        }
        
        let imgheight = Double(appInstallAdView.frame.size.height)
        (appInstallAdView.imageView as! UIImageView).image = cropToBounds((nativeAppInstallAd.images?.first as! GADNativeAdImage).image, width: (Double)((appInstallAdView.imageView as! UIImageView).frame.size.width), height: imgheight)
        //(appInstallAdView.imageView as! UIImageView).contentMode = .ScaleAspectFit
        
        (appInstallAdView.bodyView as! UILabel).frame = CGRect(x: 10,y: (appInstallAdView.imageView as! UIImageView).bounds.height + 10 + (appInstallAdView.imageView as! UIImageView).frame.origin.y,width: appInstallAdView.bounds.width-100,height: 40)
        
        (appInstallAdView.bodyView as! UILabel).text = nativeAppInstallAd.body
        (appInstallAdView.bodyView as! UILabel).numberOfLines = 0
        (appInstallAdView.bodyView as! UILabel).textColor = textColorDark
        (appInstallAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZENormal)
        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
        
        
        (appInstallAdView.callToActionView as! UIButton).frame = CGRect(x: appInstallAdView.bounds.width-75, y:(appInstallAdView.imageView as! UIImageView).bounds.height + 15 + (appInstallAdView.imageView as! UIImageView).frame.origin.y,width: 60,height: 30)
        
        (appInstallAdView.callToActionView as! UIButton).setTitle(
            nativeAppInstallAd.callToAction, for: UIControlState.normal)
        (appInstallAdView.callToActionView as! UIButton).isUserInteractionEnabled = false
        (appInstallAdView.callToActionView as! UIButton).titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
        (appInstallAdView.callToActionView as! UIButton).titleLabel?.textColor = navColor
        (appInstallAdView.callToActionView as! UIButton).backgroundColor = bgColor
        
        nativeAdArray.append(appInstallAdView)
        if nativeAdArray.count == 10
        {
            self.tableView.reloadData()
        }
        //self.tableView.reloadData()
    }
    
    func adLoader(adLoader: GADAdLoader!, didReceiveNativeContentAd nativeContentAd: GADNativeContentAd!) {
        
        
        if loadrequestcount <= 10
        {
            loadrequestcount = loadrequestcount+1
            showNativeAd()
            //adLoader1.delegate = self
        }
        
        
        let contentAdView = Bundle.main.loadNibNamed("ContentAdsFeedview", owner: nil,
                                                     options: nil)?.first as! GADNativeContentAdView
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            contentAdView.frame = CGRect(x: 0,y: 0, width: UIScreen.main.bounds.width,height: contentAdView.frame.size.height+150)
        }
        else
        {
            contentAdView.frame = CGRect(x: 0,y:  0, width: UIScreen.main.bounds.width,height: contentAdView.frame.size.height-10)
            
            
        }
        
        // Associate the app install ad view with the app install ad object. This is required to make
        // the ad clickable.
        contentAdView.nativeContentAd = nativeContentAd
        contentAdView.tag = 1001001
        
        // Populate the app install ad view with the app install ad assets.
        // Some assets are guaranteed to be present in every app install ad.
        (contentAdView.headlineView as! UILabel).frame = CGRect(x: 10 ,y: 5,width: contentAdView.bounds.width-55, height: 30)
        (contentAdView.headlineView as! UILabel).numberOfLines = 0
        (contentAdView.headlineView as! UILabel).textColor = textColorDark
        (contentAdView.headlineView as! UILabel).font = UIFont(name: fontBold, size: FONTSIZENormal)
        (contentAdView.headlineView as! UILabel).text = nativeContentAd.headline
        
        
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 5,y: (contentAdView.headlineView as! UILabel).bounds.height + 10 + (contentAdView.headlineView as! UILabel).frame.origin.y,width: contentAdView.bounds.width-10,height: 160)
        }
        else
        {
            (contentAdView.imageView as! UIImageView).frame = CGRect(x: 5,y: (contentAdView.headlineView as! UILabel).bounds.height + 10 + (contentAdView.headlineView as! UILabel).frame.origin.y,width: contentAdView.bounds.width-10,height: 300)
        }
        
        let imgheight = Double(contentAdView.frame.size.height)
        
        (contentAdView.imageView as! UIImageView).image = cropToBounds((nativeContentAd.images?.first as! GADNativeAdImage).image, width: (Double)((contentAdView.imageView as! UIImageView).frame.size.width), height: imgheight)
        
        
        (contentAdView.bodyView as! UILabel).frame = CGRect(x:10 ,y: (contentAdView.imageView as! UIImageView).bounds.height + 10 + (contentAdView.imageView as! UIImageView).frame.origin.y,width: contentAdView.bounds.width-100,height: 40)
        
        (contentAdView.bodyView as! UILabel).text = nativeContentAd.body
        (contentAdView.bodyView as! UILabel).numberOfLines = 0
        (contentAdView.bodyView as! UILabel).textColor = textColorDark
        (contentAdView.bodyView as! UILabel).font = UIFont(name: fontName, size: FONTSIZENormal)
        //(appInstallAdView.bodyView as! UILabel).sizeToFit()
        
        
        (contentAdView.callToActionView as! UIButton).frame = CGRect(x: contentAdView.bounds.width-75, y: (contentAdView.imageView as! UIImageView).bounds.height + 15 + (contentAdView.imageView as! UIImageView).frame.origin.y,width: 60,height: 30)
        
        (contentAdView.callToActionView as! UIButton).setTitle(
            nativeContentAd.callToAction, for: UIControlState.normal)
        (contentAdView.callToActionView as! UIButton).isUserInteractionEnabled = false
        (contentAdView.callToActionView as! UIButton).titleLabel?.font = UIFont(name: fontBold , size: FONTSIZESmall)
        (contentAdView.callToActionView as! UIButton).titleLabel?.textColor = navColor
        (contentAdView.callToActionView as! UIButton).backgroundColor = bgColor
        
        
        nativeAdArray.append(contentAdView)
        
        (contentAdView.callToActionView as! UIButton).isUserInteractionEnabled = false
        if nativeAdArray.count == 10
        {
            self.tableView.reloadData()
        }
        
    }
    
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
                return 2
            }
            else
            {
                if nativeAdArray.count > 0
                {
                    // For showing facebook ads count
                    if globalArrayFeed.count > kFrequencyAdsInCells_feeds-1
                    {
                        adsCount = globalArrayFeed.count/(kFrequencyAdsInCells_feeds-1)
                        let b = globalArrayFeed.count
                        let Totalrowcount = adsCount+b
                        if Totalrowcount % kFrequencyAdsInCells_feeds == 0
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
                return globalFeedHeight + 10
                
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
            return 40
        }
        else
        {
            if globalArrayFeed.count == 0 && isshimmer == true
            {
               return 210
            }
            var rowHeight:CGFloat = 60
            var row = (indexPath as NSIndexPath).row as Int
            if nativeAdArray.count > 0
            {
                if (kFrequencyAdsInCells_feeds > 4 && ((row % kFrequencyAdsInCells_feeds) == (kFrequencyAdsInCells_feeds)-1))
                {
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        return 430
                    }
                    return 280
                    
                }
                else if row == (suggestionSlideshowPosition - 1) && userSuggestions.count > 0 && showSuggestions == 1 && isHomeFeeds{
                    return 300
                }
                else
                {
                    
                    let row = (indexPath as NSIndexPath).row/kFrequencyAdsInCells_feeds
                    var index = (indexPath as NSIndexPath).row-row
                    
                    if showSuggestions == 1 && indexPath.row > (suggestionSlideshowPosition - 1) && self.userSuggestions.count > 0 && isHomeFeeds{
                        index = index - 1
                    }
                    if globalArrayFeed.count > index {
                        if let activityFeed = globalArrayFeed[index] as? NSDictionary{
                            let id = activityFeed["action_id"] as! Int
                            if dynamicRowHeight[id] != nil{
                                rowHeight = dynamicRowHeight[id]!
                            }
                        }
                    }
                    
                }
            }
            else if row == (suggestionSlideshowPosition - 1) && userSuggestions.count > 0 && showSuggestions == 1 && isHomeFeeds{
                return 300
            }
            else
            {
                if showSuggestions == 1 && indexPath.row > (suggestionSlideshowPosition - 1) && self.userSuggestions.count > 0 && isHomeFeeds{
                    row = row - 1
                }
                let index = row
                
                if globalArrayFeed.count > index {
                    if let activityFeed = globalArrayFeed[index] as? NSDictionary{
                        let id = activityFeed["action_id"] as! Int
                        if dynamicRowHeight[id] != nil{
                            rowHeight = dynamicRowHeight[id]!
                        }
                    }
                }
            }
            return rowHeight - PADING
            
        }
        
    }
    
    //  set Dynamic Height For Every Cell
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        if tableView.tag == 11 {
            return 40
        }
        else
        {
            if globalArrayFeed.count == 0 && isshimmer == true
            {
                return 210
            }
            var rowHeight:CGFloat = 60
            var row = (indexPath as NSIndexPath).row as Int
            if nativeAdArray.count > 0
            {
                if (kFrequencyAdsInCells_feeds > 4 && ((row % kFrequencyAdsInCells_feeds) == (kFrequencyAdsInCells_feeds)-1))
                {
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        return 430
                    }
                    return 280
                    
                }
                else
                {
                    if kFrequencyAdsInCells_feeds > 4
                    {
                        let row = (indexPath as NSIndexPath).row/kFrequencyAdsInCells_feeds
                        var index = (indexPath as NSIndexPath).row-row
                        
                        if showSuggestions == 1 && indexPath.row > (suggestionSlideshowPosition - 1) && self.userSuggestions.count > 0 && isHomeFeeds{
                            index = index - 1
                        }
                        
                        if globalArrayFeed.count > index {
                            if let activityFeed = globalArrayFeed[index] as? NSDictionary{
                                let id = activityFeed["action_id"] as! Int
                                if dynamicRowHeight[id] != nil{
                                    rowHeight = dynamicRowHeight[id]!
                                }
                            }
                        }
                    }
                }
            }
            else if row == (suggestionSlideshowPosition - 1) && userSuggestions.count > 0 && showSuggestions == 1 && isHomeFeeds{
                return 300
            }
            else
            {
                if showSuggestions == 1 && indexPath.row > (suggestionSlideshowPosition - 1) && self.userSuggestions.count > 0 && isHomeFeeds{
                    row = row - 1
                }
                let index = row
                if globalArrayFeed.count > index {
                    if let activityFeed = globalArrayFeed[index] as? NSDictionary{
                        let id = activityFeed["action_id"] as! Int
                        if dynamicRowHeight[id] != nil{
                            rowHeight = dynamicRowHeight[id]!
                        }
                    }
                }
            }
            return rowHeight - PADING
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
    
    
    // Set Cell of TabelView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView.tag == 11
        {
            
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            // For seprator x-position
            cell.preservesSuperviewLayoutMargins = false
            cell.separatorInset = UIEdgeInsets.zero
            cell.layoutMargins = UIEdgeInsets.zero
            
            cell.backgroundColor = tableViewBgColor
            cell.textLabel?.text = guttermenuoption[indexPath.row]
            cell.textLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
            return cell
            
        }
        else
        {
            if globalArrayFeed.count == 0 && isshimmer == true
            {
              self.tableView.register(Shimmeringcell.self, forCellReuseIdentifier: "Shimmeringcell")
              let cell = tableView.dequeueReusableCell(withIdentifier:"Shimmeringcell", for: indexPath) as! Shimmeringcell
                if (arrayForCell.count>indexPath.row)
                {
                    return arrayForCell.object(at: indexPath.row) as! Shimmeringcell
                    
                }
                return cell
            }
            let row = indexPath.row as Int
            //Showing Ads cell
            if (kFrequencyAdsInCells_feeds > 4 && nativeAdArray.count > 0 && ((row % kFrequencyAdsInCells_feeds) == (kFrequencyAdsInCells_feeds)-1))
            {  // or 9 == if you don't want the first cell to be an ad!
                self.tableView.register(NativeAdinstallFeedCell.self, forCellReuseIdentifier: "nativeAdCell")
                let cell1 = tableView.dequeueReusableCell(withIdentifier: "nativeAdCell", for: indexPath as IndexPath) as! NativeAdinstallFeedCell
                if (arrayForCell.count>indexPath.row)
                {
                    return arrayForCell.object(at: indexPath.row) as! NativeAdinstallFeedCell
                    
                }
                return cell1
                
            }
            //Showing suggetion cell
            else if indexPath.row == (suggestionSlideshowPosition - 1) && self.userSuggestions.count > 0 && showSuggestions == 1 && isHomeFeeds
            {
                
                
                //if self.userSuggestions.count > 1{
                self.tableView.register(SuggestionSlideshowTableViewCell.self, forCellReuseIdentifier: "slideshowCell")
                let slideShowCell = tableView.dequeueReusableCell(withIdentifier: "slideshowCell", for: indexPath as IndexPath) as! SuggestionSlideshowTableViewCell
                if (arrayForCell.count>indexPath.row)
                {
                    return arrayForCell.object(at: indexPath.row) as! NativeAdinstallFeedCell
                    
                }
                return slideShowCell
                
            }
            else
            {
                
                let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! AAFActivityFeedTableViewCell
               // configureCell(cell: cell, indexPath:indexPath)
                if (arrayForCell.count>indexPath.row)
                {
                    return arrayForCell.object(at: indexPath.row) as! AAFActivityFeedTableViewCell
                    
                }
                return cell
            }
            
        }
        
    }

    func configureCell(cell:AAFActivityFeedTableViewCell,indexPath:IndexPath)
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
            self.tableView.register(NativeAdinstallFeedCell.self, forCellReuseIdentifier: "nativeAdCell")
            let cell1 = tableView.dequeueReusableCell(withIdentifier: "nativeAdCell", for: indexPath as IndexPath) as! NativeAdinstallFeedCell
            cell1.selectionStyle = UITableViewCellSelectionStyle.none
            cell1.backgroundColor = UIColor.clear
            var Adcount: Int = 0
            Adcount = row/(kFrequencyAdsInCells_feeds-1)
            
            while Adcount > 10
            {
                Adcount = Adcount%10
            }
            
            if Adcount > 0
            {
                Adcount = Adcount-1
            }
            
            if nativeAdArray.count > 0 && (nativeAdArray.count > (Adcount))
            {
                if let obj = cell1.cellView.viewWithTag(1001001) {
                    // myButton already existed
                    obj.removeFromSuperview()
                }
                let view = nativeAdArray[Adcount]
                cell1.cellView.addSubview(view as! UIView)
            }
            
            return cell1
            
        }
            //Showing suggetion cell
        else if indexPath.row == (suggestionSlideshowPosition - 1) && self.userSuggestions.count > 0 && showSuggestions == 1 && isHomeFeeds
        {
            
            
            //if self.userSuggestions.count > 1{
            self.tableView.register(SuggestionSlideshowTableViewCell.self, forCellReuseIdentifier: "slideshowCell")
            let slideShowCell = tableView.dequeueReusableCell(withIdentifier: "slideshowCell", for: indexPath as IndexPath) as! SuggestionSlideshowTableViewCell
            slideShowCell.selectionStyle = UITableViewCellSelectionStyle.none
            slideShowCell.backgroundColor = aafBgColor
            slideShowCell.userSuggestions = self.userSuggestions
            slideShowCell.frame.size.height = 300
            
            if let obj = slideShowCell.viewWithTag(786) {
                // myButton already existed
                obj.removeFromSuperview()
            }
            
            suggestionsCellView = createView(CGRect(x: 0.0, y: 10.0, width: slideShowCell.frame.size.width, height: slideShowCell.frame.size.height - 10), borderColor: .clear, shadow: true)
            suggestionsCellView.tag = 786
            // suggestionView.backgroundColor = UIColor.black
            slideShowCell.addSubview(suggestionsCellView)
            
            viewTitle = createLabel(CGRect(x: PADING + 8, y: PADING, width: suggestionsCellView.frame.size.width - PADING, height: suggestionsCellView.frame.size.height * 0.1), text: "People you may know", alignment: .left, textColor: textColorDark)
            suggestionsCellView.addSubview(viewTitle)
            
            suggestionsScrollView = UIScrollView(frame: CGRect(x: PADING, y: getBottomEdgeY(inputView: viewTitle), width: suggestionsCellView.frame.size.width - PADING, height: suggestionsCellView.frame.size.height * 0.80))
            suggestionsCellView.addSubview(suggestionsScrollView)
            
            //MARK: Loop for adding suggestions
            var i = 0
            for contentItem in self.userSuggestions{
                
                let contentItem = contentItem as! NSDictionary
                let xpoint = (CGFloat(i) * ((suggestionsScrollView.bounds.width * 0.5) + 10)) + 10
                suggestionView = createView(CGRect(x: xpoint, y: PADING, width: suggestionsCellView.frame.width * 0.5, height: suggestionsScrollView.frame.height * 0.9), borderColor: .clear, shadow: true)
                suggestionsScrollView.addSubview(suggestionView)
                
                suggestionImageView = createImageView(CGRect(x: 0.0, y: 0.0, width: suggestionView.frame.width, height: suggestionView.frame.height * 0.6), border: false)
                if let photoId = contentItem["photo_id"] as? Int{
                    
                    if photoId != 0{
                        let url1 = NSURL(string: contentItem["image"] as! NSString as String)
                        suggestionImageView.sd_setImage(with: url1! as URL!)
                    }
                    else{
                        suggestionImageView.image = nil
                        suggestionImageView.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: suggestionImageView.bounds.width)
                        
                    }
                }
                suggestionView.addSubview(suggestionImageView)
                
                suggestionDetailView = createView(CGRect(x: 0.0, y: suggestionImageView.frame.height, width: suggestionView.frame.width, height: suggestionView.frame.height * 0.45), borderColor: .clear, shadow: false)
                suggestionView.addSubview(suggestionDetailView)
                
                contentTitle = createLabel(CGRect(x: PADING + 5, y: 0, width: suggestionDetailView.frame.width - PADING, height: suggestionDetailView.frame.size.height * 0.2), text: "Test User", alignment: .left, textColor: textColorDark)
                contentTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                contentTitle.text = contentItem["displayname"] as? String
                suggestionDetailView.addSubview(contentTitle)
                
                contentDetail = createLabel(CGRect(x: PADING + 5, y: getBottomEdgeY(inputView: contentTitle), width: suggestionDetailView.frame.width - (2*PADING)-10, height: suggestionDetailView.frame.size.height * 0.2), text: "", alignment: .left, textColor: textColorMedium)
                contentDetail.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
                contentDetail.lineBreakMode = NSLineBreakMode.byTruncatingTail
                if contentItem["mutualfriendCount"] as? Int != 0{
                    let mutualFriendCount = String(contentItem["mutualfriendCount"] as! Int)
                    contentDetail.text = "\(groupIcon) " + mutualFriendCount + " mutual friends"
                }else if contentItem["location"] as? String != nil && contentItem["location"] as? String != ""{
                    let location = contentItem["location"] as! String
                    contentDetail.text = "\(locationIcon) " + location
                }
                suggestionDetailView.addSubview(contentDetail)
                
                addFriend = createButton(CGRect(x: 2*PADING, y: getBottomEdgeY(inputView: contentDetail) + 5, width: suggestionDetailView.frame.width - (4*PADING), height: suggestionDetailView.frame.size.height * 0.2), title: friendReuestIcon + " Add Friend", border: true, bgColor: true, textColor: navColor)
                addFriend.backgroundColor = UIColor.clear
                addFriend.titleLabel?.font = UIFont(name: "FontAwesome", size:FONTSIZESmall)
                addFriend.layer.borderColor = navColor.cgColor
                addFriend.layer.cornerRadius = (suggestionDetailView.frame.size.height * 0.3)/4
                addFriend.layer.shouldRasterize = true
                addFriend.layer.isOpaque = true
                addFriend.layer.rasterizationScale = UIScreen.main.scale
                addFriend.addTarget(self, action: #selector(FeedTableViewController.addFriendSuggestion(_:)), for: .touchUpInside)
                if contentItem["friendship_type"] as? String == "cancel_request"{
                    addFriend.setTitle("Undo request", for: UIControlState.normal)
                    suggestionsScrollView.contentOffset = CGPoint(x: getRightEdgeX(inputView: suggestionView)/2, y: 0)
                }
                addFriend.tag = 555 + i
                suggestionDetailView.addSubview(addFriend)
                
                removeSuggestion = createButton(CGRect(x: PADING, y: getBottomEdgeY(inputView: addFriend) + 5, width: suggestionDetailView.frame.width - PADING, height: suggestionDetailView.frame.size.height * 0.2), title: "Remove", border: false, bgColor: false, textColor: textColorMedium)
                removeSuggestion.titleLabel?.font = UIFont(name: fontName, size:FONTSIZESmall)
                removeSuggestion.addTarget(self, action: #selector(FeedTableViewController.removeSuggestionItem(_:)), for: .touchUpInside)
                removeSuggestion.tag = 555 + i
                suggestionDetailView.addSubview(removeSuggestion)
                
                
                //ContentSelection
                contentRedirectionView = createButton(CGRect(x: 0.0, y: 0.0, width: suggestionView.frame.width, height: suggestionView.frame.height * 0.7), title: "", border: false, bgColor: false, textColor: textColorMedium)
                contentRedirectionView.titleLabel?.font = UIFont(name: fontName, size:FONTSIZESmall)
                contentRedirectionView.addTarget(self, action: #selector(FeedTableViewController.suggestionProfile(_:)), for: .touchUpInside)
                contentRedirectionView.tag = 666 + (contentItem["user_id"] as! Int)
                suggestionView.addSubview(contentRedirectionView)
                
                
                i += 1
            }
            
            //Adding empty element
            
            let xpoint = (CGFloat(i) * ((suggestionsScrollView.bounds.width * 0.5) + 10)) + 10
            suggestionView = createView(CGRect(x: xpoint, y: PADING, width: suggestionsCellView.frame.width * 0.5, height: suggestionsScrollView.frame.height * 0.9), borderColor: .clear, shadow: true)
            suggestionsScrollView.addSubview(suggestionView)
            
            suggestionImageView = createImageView(CGRect(x: 0.0, y: 0.0, width: suggestionView.frame.width, height: suggestionView.frame.height * 0.6), border: false)
            suggestionImageView.image = nil
            suggestionImageView.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: suggestionImageView.bounds.width)
            suggestionView.addSubview(suggestionImageView)
            
            suggestionDetailView = createView(CGRect(x: 0.0, y: suggestionImageView.frame.height, width: suggestionView.frame.width, height: suggestionView.frame.height * 0.4), borderColor: .clear, shadow: false)
            suggestionView.addSubview(suggestionDetailView)
            
            
            findMoreSuggestions = createButton(CGRect(x: PADING, y: suggestionDetailView.frame.size.height/2, width: suggestionDetailView.frame.width - PADING, height: suggestionDetailView.frame.size.height * 0.2), title: "Find more friends", border: false, bgColor: false, textColor: textColorDark)
            findMoreSuggestions.titleLabel?.font = UIFont(name: fontName, size:FONTSIZENormal)
            findMoreSuggestions.addTarget(self, action: #selector(FeedTableViewController.seeAllSuggestions(_:)), for: UIControlEvents.touchUpInside)
            suggestionDetailView.addSubview(findMoreSuggestions)
            
            // Finished adding empty element
            i+=1
            let widthpoint = (CGFloat(i) * ((suggestionsScrollView.bounds.width * 0.5) + 10)) + 10
            suggestionsScrollView.contentSize = CGSize(width: widthpoint, height: suggestionsScrollView.frame.size.height)
            
            // Loop for Suggestion ends
            
            seeAll = createButton(CGRect(x: PADING, y: getBottomEdgeY(inputView: suggestionsScrollView)-2, width: suggestionsCellView.frame.size.width - PADING, height: suggestionView.frame.size.height * 0.1), title: "See All", border: false, bgColor: false, textColor: textColorMedium)
            seeAll.tag = 7869
            seeAll.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
            seeAll.addTarget(self, action: #selector(FeedTableViewController.seeAllSuggestions(_:)), for: UIControlEvents.touchUpInside)
            suggestionsCellView.addSubview(seeAll)
            return slideShowCell
            
        }

                var row = indexPath.row as Int
                cell.feedInfo.isHidden = true
                cell.feedInfo.text = ""
                cell.customAlbumView.isHidden = true
                cell.customAlbumView.frame.size.height = 0
                cell.customAlbumViewshare.isHidden = true
                cell.customAlbumViewshare.frame.size.height = 0
                cell.bodyHashtaglbl.isHidden = true
                noCommentMenu = false
                //Alter row index due to ads and suggestion cell
                if kFrequencyAdsInCells_feeds > 4 && nativeAdArray.count > 0
                {
                    row = row - (row / kFrequencyAdsInCells_feeds)
                    displyedAdsCount = (row / kFrequencyAdsInCells_feeds)
                    
                }
                if showSuggestions == 1 && indexPath.row > (suggestionSlideshowPosition - 1) && self.userSuggestions.count > 0 && isHomeFeeds{
                    row = row - 1
                }
                cell.tag = row
                let activityFeed = globalArrayFeed[row] as! NSDictionary
                action_id = activityFeed["action_id"] as! Int
                if tempcontentFeedArray[activityFeed["action_id"] as! Int] != nil
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
                    
                    if let undoDic = tempcontentFeedArray[activityFeed["action_id"] as! Int] as? NSDictionary
                    {
                        cell.feedInfo.isHidden = false
                        cell.feedInfo.delegate = self
                        cell.feedInfo.numberOfLines = 0
                        cell.feedInfo.frame = CGRect(x: 20,y: 5,width: cell.cellView.bounds.width-40,height: cell.cellView.frame.size.height-10)
                        var tempFeedInfo = ""
                        if let dic = undoDic["undo"] as? NSDictionary{
                            tempFeedInfo = dic["label"] as! String + "   Undo  "
                            
                        }
                        
                        if let dic1 = undoDic["hide_all"] as? NSDictionary
                        {
                            tempFeedInfo = tempFeedInfo + (dic1["label"] as! String)
                            
                        }
                        cell.feedInfo.activeLinkAttributes = subscriptionNoticeActiveLinkAttributes
                        tempFeedInfo = tempFeedInfo.html2String
                        cell.feedInfo.setText(tempFeedInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                            let boldFont = CTFontCreateWithName(fontBold as CFString?, FONTSIZEMedium, nil)
                            
                            let range = (tempFeedInfo as NSString).range(of:NSLocalizedString("Undo",  comment: ""))
                            mutableAttributedString?.addAttribute(kCTFontAttributeName as String, value: boldFont, range: range)
                            mutableAttributedString?.addAttribute(kCTForegroundColorAttributeName as String, value:textColorDark , range: range)
                            
                            return mutableAttributedString
                        })
                        
                        
                        
                        if let dic = undoDic["undo"] as? NSDictionary
                        {
                            let range = (tempFeedInfo as NSString).range(of: NSLocalizedString("Undo",  comment: ""))
                            cell.feedInfo.addLink(toTransitInformation: ["urlParams" : dic["urlParams"] as! NSDictionary, "type" : "undo","url" : dic["url"] as! String, "index" : row, "action_id" :activityFeed["action_id"] as! Int], with:range)
                        }
                        if let dic = undoDic["hide_all"] as? NSDictionary{
                            if dic["name"] as! String == "hide_all" {
                                let range = (tempFeedInfo as NSString).range(of: dic["label"] as! String)
                                cell.feedInfo.addLink(toTransitInformation: ["urlParams" : dic["urlParams"] as! NSDictionary, "type" : "hide_all","url" : dic["url"] as! String, "index" : row], with:range)
                            }else if dic["name"] as! String == "report"{
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
                                cell.subject_photo.sd_setImage(with: url, placeholderImage: UIImage(named: "user_profile_image.png"), options: SDWebImageOptions.highPriority, completed: { (image, error, ImageChache, ImageUrl) in
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
                    cell.title.frame = CGRect(x: cell.subject_photo.bounds.width + 15,y: 10, width: cell.cellView.bounds.width-(cell.subject_photo.bounds.width + 40),height: 100)
                    var titlearr = [String]()
                    // Set Feed Main Title
                    if var _ = activityFeed["action_type_body"] as? String
                    {
                        title = (activityFeed["action_type_body"] as? String)!
                        let actiontypebodytitle = title
                        if  let body_param = activityFeed["action_type_body_params"] as? NSArray{
                            
                            for i in 0 ..< body_param.count
                            {
                                
                                let body1 = body_param[i] as! NSDictionary
                                let search = body1["search"] as! String
                                if body1["search"] as! String == "{actors:$subject:$object}"
                                {
                                    if (body1["object"] != nil)
                                    {
                                        let  objectSubject =   body1["object"] as! NSDictionary
                                        if(objectSubject["label"] is String )
                                        {
                                            
                                            titleSubject = objectSubject["label"] as! String
                                            
                                        }
                                        if( objectSubject["id"] is Int )
                                        {
                                            
                                            ObjectId = objectSubject["id"] as! Int
                                            
                                        }
                                        if(objectSubject["type"] is String){
                                            
                                            objectTypee = objectSubject["type"] as! String
                                            
                                        }
                                        title =  "<b>" + search + " &rarr; " + titleSubject + "</b>"
                                        
                                    }
                                    
                                }
                                if(body1["search"] is String)
                                {
                                    if (body1["label"] is String)
                                    {
                                        let label =  body1["label"] as! String
                                        if(search == "{body:$body}")
                                        {
                                            if title.range(of:search) != nil
                                            {
                                                title = title.replacingOccurrences(of: search, with: "", options: String.CompareOptions.literal, range: nil)
                                                
                                            }
                                            if  UserDefaults.standard.object(forKey: "showFeedPage") != nil
                                            {
                                                UserDefaults.standard.removeObject(forKey: "showFeedPage")
                                                statusBody = label
                                            }
                                            else
                                            {
                                                if label.length < 150
                                                {
                                                    statusBody = label
                                                }
                                                else
                                                {
                                                    statusBody = (label as NSString).substring(to: 150-13)
                                                    statusBody += "...See more"
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
                                            let label =  body1["label"] as! Int
                                            if(search == "{body:$body}")
                                            {
                                                if title.range(of:search) != nil
                                                {
                                                    title = title.replacingOccurrences(of: search, with: "", options: String.CompareOptions.literal, range: nil)
                                                }
                                            }
                                            else
                                            {
                                                if title.range(of:search) != nil
                                                {
                                                    title = title.replacingOccurrences(of: search, with: String(label), options: String.CompareOptions.literal, range: nil)
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
                        title = title.html2String as String
                        title = Emoticonizer.emoticonizeString("\(title)" as NSString) as String
                        title = title.html2String
                        cell.title.delegate = self
                        cell.title.setText(title, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                            for titleword in titlearr
                            {
                                if actiontypebodytitle.range(of:titleword) != nil{
                                    let boldFont = CTFontCreateWithName(fontName as CFString?, FONTSIZENormal, nil)
                                    let range4 = (title as NSString).range(of:NSLocalizedString(titleword,  comment: ""))
                                    mutableAttributedString?.addAttribute(kCTFontAttributeName as String, value: boldFont, range: range4)
                                    mutableAttributedString?.addAttribute(kCTForegroundColorAttributeName as String, value:textColorDark , range: range4)

                                }
                                
                            }
                            return mutableAttributedString
                        })
                        
                        DispatchQueue.global(qos: .default).async {
                            
                        // tagged user
                        if let tags = activityFeed["tags"] as? NSArray
                        {
                            if tags.count > 0
                            {
                                //Loop runs twice because we are showing only 2 tageed user
                                for i in 0 ..< tags.count{
                                    if let tag = ((tags[i] as! NSDictionary)["tag_obj"] as! NSDictionary)["displayname"] as? String{
                                        let tag_id = ((tags[i] as! NSDictionary)["tag_obj"] as! NSDictionary)["user_id"] as? Int
                                        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\(title)")
                                        let length = attrString.length
                                        var range = NSMakeRange(0, attrString.length)
                                        while(range.location != NSNotFound)
                                        {
                                            range = (title as NSString).range(of: tag, options: NSString.CompareOptions(), range: range)
                                            if(range.location != NSNotFound) {
                                                cell.title.addLink(toTransitInformation: ["id" : tag_id!, "type" : "user"], with:range)
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

                        // checkin User
                        if let params = activityFeed["params"] as? NSDictionary{
                            if params.count > 0{
                                if let checkIn = params["checkin"] as? NSDictionary{
                                    let location = checkIn["label"] as! String
                                    var place_id = ""
                                    if let tempPlaceId = checkIn["place_id"] as? String{
                                        place_id = tempPlaceId
                                    }
                                    let range = (title as NSString).range(of: NSLocalizedString(location,  comment: ""))
                                    cell.title.addLink(toTransitInformation: ["type" : "map","location" : location, "place_id" : place_id], with:range)
                                }
                            }
                        }
                            
                        if let links = activityFeed["action_type_body_params"] as? NSArray
                        {
                            for link in links
                            {
                                if let dic = link as? NSDictionary
                                {
                                    // var tempDictionary = Dictionary<String, AnyObject>()
                                    // Make link For attAchmentContent
                                    //tempDictionary = MakelinkForattAchmentContent(activityFeed: activityFeed, dic: dic)
                                    if dic["id"] != nil &&  dic["type"] != nil
                                    {
                                        let id = dic["id"] as! Int
                                        let type = dic["type"] as! String
                                        let value = String(describing: dic["label"]!)
                                        let range = (title as NSString).range(of: value)
                                        cell.title.addLink(toTransitInformation: ["type" : type,"id" : id, "feed" : activityFeed], with:range )
                                    }
                                    
                                }
                            }
                        }
                        
                        // Make othe user clickable start
                        if(titleSubject != nil)
                        {
                            let range = (title as NSString).range(of:titleSubject)
                            cell.title.addLink(toTransitInformation: ["id" : ObjectId, "type" : "\(objectTypee)"], with:range)

                        } // Make Make othe user clickable end
                        
                        // Other tagged user
                        let range = (title as NSString).range(of:NSLocalizedString("\(self.tagOtherUserCount) others",  comment: ""))
                        cell.title.addLink(toTransitInformation: ["tags": activityFeed["tags"] as? NSArray! as Any, "id" : activityFeed["action_id"] as! Int, "type" : "tagother","index" : row], with:range)
                        }
                    }
                    cell.title.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.title.sizeToFit()
                    // Post Title  work ended
                    

                    // Set Feed Post Time (Feed Creation Date)
                    cell.createdAt.frame.origin.y = cell.title.frame.origin.y + cell.title.bounds.height
                    cell.createdAt.text = ""
                    cell.createdAt.isHidden = false
                    
                    if let postedDate = activityFeed["feed_createdAt"] as? String{
                        DispatchQueue.global().async {
                            let postedOn = dateDifference(postedDate)
                            DispatchQueue.main.async {
                                cell.createdAt.text = String(format: NSLocalizedString("%@ ", comment: ""),postedOn)
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

                    if (activityFeed["userTag"] as? NSArray) != nil{
                        cell.body.linkAttributes = subscriptionTagLinkAttributes
                    }
                    else{
                        cell.body.linkAttributes = subscriptionNoticeLinkAttributes
                    }
                    var nsurl: NSURL!
                    var url:String!
                    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                    let matches = detector.matches(in: statusBody, options: [], range: NSMakeRange(0, statusBody.characters.count))
                    cell.body.delegate = self
                    cell.body.isHidden = false
                    cell.body.frame.origin.y = originY
                    var hashtagString : String! = ""
                    let words = statusBody.components(separatedBy: " ")
                    statusBody = statusBody.html2String
                    cell.body.setText(statusBody, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let boldFont = CTFontCreateWithName(fontNormal as CFString?, FONTSIZENormal, nil)
                        
                        let range = (statusBody as NSString).range(of:statusBody)
                        
                        mutableAttributedString?.addAttribute(kCTFontAttributeName as String, value: boldFont, range: range)

                        let boldFont1 = CTFontCreateWithName(fontBold as CFString?, FONTSIZENormal, nil)
                        
                        let range2 = (statusBody as NSString).range(of:NSLocalizedString("See more",  comment: ""))
                        
                        mutableAttributedString?.addAttribute(kCTFontAttributeName as String, value: boldFont1, range: range2)
                        
                        mutableAttributedString?.addAttribute(kCTForegroundColorAttributeName as String, value:textColorMedium , range: range2)
                        for match in matches {
                            var stringurl = ""
                            nsurl = match.url! as NSURL!
                            url = "\(nsurl!)"
                            let original = url
                            stringurl = original!
                            
                            let boldFont2 = CTFontCreateWithName(fontBold as CFString?, FONTSIZEMedium, nil)
                            let range3 = (statusBody as NSString).range(of:NSLocalizedString("\(stringurl)",  comment: ""))
                            mutableAttributedString?.addAttribute(kCTFontAttributeName as String, value: boldFont2, range: range2)
                            mutableAttributedString?.addAttribute(kCTForegroundColorAttributeName as String, value:navColor , range: range3)

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
                                                mutableAttributedString?.addAttribute(kCTFontAttributeName as String, value: boldFont1, range: range)
                                                mutableAttributedString?.addAttribute(kCTForegroundColorAttributeName as String, value:textColorDark , range: range)
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
                                        mutableAttributedString?.addAttribute(kCTFontAttributeName as String, value: boldFont1, range: range)
                                        mutableAttributedString?.addAttribute(kCTForegroundColorAttributeName as String, value:textColorDark , range: range)
                                        range = NSMakeRange(range.location + range.length, length! - (range.location + range.length));
                                        
                                    }
                                }
                            }
                        }
                        
                        return mutableAttributedString
                    })
                    cell.body.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.body.sizeToFit()

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
                    
                    }
                    // Post Bpody  work ended
                    
                    //Attachment and hashtag work start
                    if activityFeed["attachment_count"] as? Int == 0
                    {
                        dynamicHeight = 0
                        cell.customAlbumView.isHidden = true
                        cell.customAlbumViewshare.isHidden = true
                        cell.customAlbumView.frame.size.height = 0
                        cell.customAlbumView.frame.origin.y = getBottomEdgeY(inputView: cell.body) + 5
                        if activityFeed["hashtags"] != nil
                        {
                            // Create Hashtag
                            createhashtag(row: row,cell: cell)

                        }
                    }
                    else
                    {
                        cell.imageButton1.setImage(placeholderImage, for: .normal)
                        cell.imageButton2.setImage(placeholderImage, for: .normal)
                        cell.imageButton3.setImage(placeholderImage, for: .normal)
                        cell.imageButton4.setImage(placeholderImage, for: .normal)
                        cell.imageButton5.setImage(placeholderImage, for: .normal)
                        cell.imageButton6.setImage(placeholderImage, for: .normal)
                        cell.imageButton7.setImage(placeholderImage, for: .normal)
                        cell.imageButton8.setImage(placeholderImage, for: .normal)
                        cell.imageButton9.setImage(placeholderImage, for: .normal)
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
                                break
                            case 1:
                                    var cardViewFeed = false
                                    var imageUrl = ""
                                    if let attachmentArray = activityFeed["attachment"] as? NSArray{
                                        
                                        if let feed = attachmentArray[0] as? NSDictionary
                                        {
                                            if let feedAttachmentType = feed["attachment_type"] as? String
                                            {
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
                                            if let dic = feed["image_main"] as? String
                                            {
                                                imageUrl = (dic)
                                                
                                            }
                                            
                                        }
                                    }
                                    if cardViewFeed == true
                                    {
                                        cell.customAlbumViewshare.frame.origin.y = getBottomEdgeY(inputView: cell.body) + 5
                                        cell.customAlbumView.isHidden = true
                                        cell.customAlbumViewshare.isHidden = false
                                        cell.customAlbumView.frame.size.height = 0
                                        cell.customAlbumView.frame.origin.y = getBottomEdgeY(inputView: cell.body) + 5
                                        var tempHeight = cell.cellView.bounds.width * 0.80
                                        cell.customAlbumViewshare.frame.size.height = tempHeight + 10
                                        cell.customAlbumView.frame.size.height = tempHeight + 10
                                        var attachment_title = ""
                                        var attachment_description = ""
                                        if let attachmentArray = activityFeed["attachment"] as? NSArray
                                        {
                                            
                                            if let feed = attachmentArray[0] as? NSDictionary{
                                                if let attachmetTitle = feed["title"]{
                                                    attachment_title = String(describing: attachmetTitle)
                                                }
                                                if let attachmentBody = feed["body"]{
                                                    attachment_description = String(describing: attachmentBody)
                                                    attachment_description = attachment_description.html2String
                                                    attachment_description = Emoticonizer.emoticonizeString("\(attachment_description)" as NSString) as String
                                                }
                                            }
                                        }
                                        
                                        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\(attachment_title)")
                                        let boldFont = CTFontCreateWithName(fontBold as CFString?, FONTSIZENormal, nil)
                                        attrString.addAttribute(NSFontAttributeName, value: boldFont, range: NSMakeRange(0, attrString.length))
                                        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black, range: NSMakeRange(0, attrString.length))
                                        
                                        let descString: NSMutableAttributedString = NSMutableAttributedString(string:  String("\n\(attachment_description)"))
                                        descString.addAttribute(NSFontAttributeName, value: UIFont(name: fontName , size: FONTSIZENormal)!, range: NSMakeRange(0, descString.length))
                                        attrString.append(descString);
                                        cell.contentAttributedLabel.attributedText = attrString

                                        cell.contentAttributedLabel.numberOfLines = 3
                                        cell.contentAttributedLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail

                                        cell.contentImageView.setShowActivityIndicator(true)
                                        cell.contentImageView.setIndicatorStyle(.gray)
                                        if attachment_title == "" && attachment_description == ""{
                                            cell.contentAttributedLabel.isHidden = true
                                            tempHeight = tempHeight - 60
                                            cell.cntentShareFeedView.frame.size.height = 10 + cell.contentAttributedLabel.bounds.height
                                            cell.customAlbumViewshare.frame.size.height = 10 + cell.contentAttributedLabel.bounds.height
                                        }
                                        else
                                        {
                                            cell.cntentShareFeedView.frame.size.height = cell.contentAttributedLabel.frame.size.height+10+cell.contentImageView.frame.size.height
                                            tempHeight = cell.cntentShareFeedView.frame.size.height
                                            cell.customAlbumViewshare.frame.size.height = tempHeight + 10
                                        }
                                        dynamicHeight = tempHeight + 10
                                        
                                        if imageUrl != "" {
                                            let url = NSURL(string:imageUrl)
                                            let tempWidth = Double(cell.cntentShareFeedView.bounds.width)
                                            let ttheight = Double(tempHeight - 60)
                                            
                                            cell.contentImageView.sd_setImage(with: url as! URL, placeholderImage: placeholderImage, options: SDWebImageOptions.highPriority, completed: { (image, error, cacheType, imageURL) in
                                                DispatchQueue.main.async(execute:
                                                    {
                                                        let image = cell.contentImageView.image
                                                        if image != nil
                                                        {
                                                            cell.contentImageView.image = cropToBounds(image!, width: tempWidth, height: ttheight)
                                                        }
                                                        
                                                })
                                            })
                                        }
                                        cell.customAlbumViewshare.frame.size.height = dynamicHeight
                                        cell.customAlbumView.frame.size.height = dynamicHeight
                                        let aTap = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewController.tappedContent(sender:)))
                                        cell.cntentShareFeedView.addGestureRecognizer(aTap)
                                        
                                    }
                                    else
                                    {
                                        cell.customAlbumView.isHidden = false
                                        cell.customAlbumViewshare.isHidden = true
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
                                        let tempHeight = cell.cellView.bounds.width * 0.8
                                        cell.customAlbumView.frame.size.height = tempHeight + 10
                                        cell.imageButton1.frame.size.height = tempHeight
                                        
                                        dynamicHeight = tempHeight + 10
                                        if imageUrl != ""
                                        {
                                            let url = NSURL(string:imageUrl)
                                            cell.imageButton1.addTarget(self, action: #selector(FeedTableViewController.openSingleImage(sender:)), for: .touchUpInside)
                                            cell.imageButton1.tag = row
                                            if let img = imageCache[imageUrl]
                                            {
                                                cell.imageButton1.frame = CGRect(x: (cell.customAlbumView.frame.size.width - img.size.width)/2 ,y: 5,width: img.size.width ,height: img.size.height)
                                                cell.customAlbumView.frame.size.height = cell.imageButton1.frame.size.height + 10
                                                cell.imageButton1.setImage(img, for: .normal)
                                                self.dynamicHeight = cell.customAlbumView.frame.size.height

                                            }
                                            else
                                            {
                                                cell.imageButton1.setImage(placeholderImage, for: .normal)
                                                // Download Image from Server
                                                downloadData(url! as URL, downloadCompleted: { (downloadedData, msg) -> () in
                                                    if msg{
                                                        DispatchQueue.main.async(execute: {
                                                            let image: UIImage  = UIImage(data: downloadedData)!
                                                            
                                                            // Resize image according to fix width
                                                            let resizeimage = imageWithImage(image, scaletoWidth: cell.imageButton1.frame.size.width)
                                                            cell.imageButton1.setImage(resizeimage, for: .normal)
                                                            self.imageCache[imageUrl] = resizeimage
                                                            cell.imageButton1.frame = CGRect(x: (cell.customAlbumView.frame.size.width - resizeimage.size.width)/2 ,y: 5,width: resizeimage.size.width ,height: resizeimage.size.height)
                                                            cell.customAlbumView.frame.size.height = cell.imageButton1.frame.size.height + 10
                                                            self.dynamicHeight = cell.customAlbumView.frame.size.height
                                                             UIView.setAnimationsEnabled(false)
                                                             self.tableView.reloadData()
                                                             UIView.setAnimationsEnabled(true)

                                                        })
                                                    }
                                                })
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                break
                                
                            case 2:
                                
                                cell.customAlbumView.isHidden = false
                                cell.customAlbumViewshare.isHidden = true
                                cell.imageButton1.isHidden = true
                                cell.imageButton2.isHidden = false
                                cell.imageButton3.isHidden = false
                                cell.imageButton4.isHidden = true
                                cell.imageButton5.isHidden = true
                                cell.imageButton6.isHidden = true
                                cell.imageButton7.isHidden = true
                                cell.imageButton8.isHidden = true
                                cell.imageButton9.isHidden = true
                                cell.imageViewWithText.isHidden = true
                                let tempHeight = cell.cellView.bounds.width * 0.65
                                cell.customAlbumView.frame.size.height = tempHeight + 10
                                    if imageUrlArray[0] != ""
                                    {
                                        let imageUrl = imageUrlArray[0]
                                        let url = NSURL(string:imageUrl)
                                        cell.imageButton2.sd_setImage(with: url as URL!, for: .normal, placeholderImage: placeholderImage)
                                        cell.imageButton2.addTarget(self, action:#selector(FeedTableViewController.firstPhotoClick(sender:)) , for: .touchUpInside)
                                        cell.imageButton2.tag = row
                                        
                                    }
                                    if imageUrlArray[1] != ""
                                    {
                                        let imageUrl = imageUrlArray[1]
                                        let url = NSURL(string:imageUrl)
                                        cell.imageButton3.sd_setImage(with: url as URL!, for: .normal, placeholderImage: placeholderImage)
                                        cell.imageButton3.addTarget(self, action: #selector(FeedTableViewController.secondPhotoClick(sender:)) , for: .touchUpInside)
                                        cell.imageButton3.tag = row
                                    }
                                    dynamicHeight = tempHeight + 10

                                break
                                
                                
                            case 3:
                                cell.customAlbumView.isHidden = false
                                cell.customAlbumViewshare.isHidden = true
                                cell.imageButton1.isHidden = true
                                cell.imageButton2.isHidden = true
                                cell.imageButton3.isHidden = true
                                cell.imageButton4.isHidden = false
                                cell.imageButton5.isHidden = false
                                cell.imageButton6.isHidden = false
                                cell.imageButton7.isHidden = true
                                cell.imageButton8.isHidden = true
                                cell.imageButton9.isHidden = true
                                cell.imageViewWithText.isHidden = true

                                let tempHeight = cell.cellView.bounds.width * 0.8
                                cell.customAlbumView.frame.size.height = tempHeight + 10
                                    
                                    if imageUrlArray[0] != "" {
                                        let imageUrl = imageUrlArray[0]
                                        let url = NSURL(string:imageUrl)
                                        
                                        cell.imageButton4.sd_setImage(with: url as URL!, for: .normal, placeholderImage: placeholderImage)
                                        cell.imageButton4.addTarget(self, action: #selector(FeedTableViewController.firstPhotoClick(sender:)) , for: .touchUpInside)
                                        cell.imageButton4.tag = row
                                    }
                                    if imageUrlArray[1] != "" {
                                        let imageUrl = imageUrlArray[1]
                                        let url = NSURL(string:imageUrl)
                                        
                                        cell.imageButton5.sd_setImage(with: url as URL!, for: .normal, placeholderImage: placeholderImage)
                                        cell.imageButton5.addTarget(self, action:#selector(FeedTableViewController.secondPhotoClick(sender:)) , for: .touchUpInside)
                                        cell.imageButton5.tag = row
                                    }
                                    if imageUrlArray[2] != "" {
                                        let imageUrl = imageUrlArray[2]
                                        let url = NSURL(string:imageUrl)
                                        
                                        cell.imageButton6.sd_setImage(with: url as URL!, for: .normal, placeholderImage: placeholderImage)
                                        cell.imageButton6.addTarget(self, action: #selector(FeedTableViewController.thirdPhotoClick(sender:)) , for: .touchUpInside)
                                        cell.imageButton6.tag = row
                                    }
                                    dynamicHeight = tempHeight + 10

                                break
                                
                                
                            default:
                            
                                cell.customAlbumView.isHidden = false
                                cell.customAlbumViewshare.isHidden = true
                                cell.imageButton1.isHidden = true
                                cell.imageButton2.isHidden = true
                                cell.imageButton3.isHidden = true
                                cell.imageButton4.isHidden = true
                                cell.imageButton5.isHidden = true
                                cell.imageButton6.isHidden = true
                                cell.imageButton7.isHidden = false
                                cell.imageButton8.isHidden = false
                                cell.imageButton9.isHidden = false
                                cell.imageViewWithText.isHidden = false
                                let tempHeight = cell.cellView.bounds.width * 0.8
                                cell.customAlbumView.frame.size.height = tempHeight + 10
                                
                                switch photosAttachmentCount {
                                case 4:
                                    cell.countlabel.isHidden = true
                                    break
                                default:
                                    cell.countlabel.isHidden = false
                                    let photoCount = photosAttachmentCount - 4
                                    cell.countlabel.text = "+\(photoCount)"
                                    break
                                }

                                    cell.imageViewWithText.setShowActivityIndicator(true)
                                    cell.imageViewWithText.setIndicatorStyle(.white)

                                    if imageUrlArray[0] != ""
                                    {
                                        let imageUrl = imageUrlArray[0]
                                        let url = NSURL(string:imageUrl)
                                        cell.imageButton7.sd_setImage(with: url as URL!, for: .normal, placeholderImage: placeholderImage)
                                        cell.imageButton7.addTarget(self, action: #selector(FeedTableViewController.firstPhotoClick(sender:)) , for: .touchUpInside)
                                        cell.imageButton7.tag = row
                                    }
                                    if imageUrlArray[1] != ""
                                    {
                                        let imageUrl = imageUrlArray[1]
                                        let url = NSURL(string:imageUrl)
                                        cell.imageButton8.sd_setImage(with: url as URL!, for: .normal, placeholderImage: placeholderImage)
                                        cell.imageButton8.addTarget(self, action:#selector(FeedTableViewController.secondPhotoClick(sender:)) , for: .touchUpInside)
                                        cell.imageButton8.tag = row
                                        
                                    }
                                    if imageUrlArray[2] != ""
                                    {
                                        let imageUrl = imageUrlArray[2]
                                        let url = NSURL(string:imageUrl)
                                        
                                        cell.imageButton9.sd_setImage(with: url as URL!, for: .normal, placeholderImage: placeholderImage)
                                        cell.imageButton9.addTarget(self, action:#selector(FeedTableViewController.thirdPhotoClick(sender:)) , for: .touchUpInside)
                                        cell.imageButton9.tag = row
                                    }
                                    if imageUrlArray[3] != ""
                                    {
                                        let imageUrl = imageUrlArray[3]
                                        let url = NSURL(string:imageUrl)
                                        cell.imageViewWithText.sd_setImage(with: url as URL!, placeholderImage: placeholderImage)
                                        
                                    }
                                    cell.imageViewWithText.isUserInteractionEnabled = true
                                    let aTap = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewController.multiplePhotoClick(sender:)))
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
                    reactionandlikeCommentInfo(row: row, cell: cell)
 
                }
                self.dynamicRowHeight[activityFeed["action_id"] as! Int] = self.dynamicHeight


    
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 11 {
            popover.dismiss()
            let feed = globalArrayFeed[currentCell] as! NSDictionary
            deleteFeed = false
            menuOptionSelected = ""
            if let feed_menu = feed["feed_menus"] as? NSArray{
                let  menuItem = feed_menu[indexPath.row]
                if let dic = menuItem as? NSDictionary {
                    self.menuOptionSelected = dic["name"] as! String
                    if dic["name"] as! String == "delete_feed"{
                        
                        // Confirmation Alert for Delete Feed
                        displayAlertWithOtherButton(NSLocalizedString("Delete Activity Item?", comment: "") ,message: NSLocalizedString("Are you sure that you want to delete this activity item? This action cannot be undone.", comment: "") ,otherButton: NSLocalizedString("Delete", comment: ""), otherButtonAction: { () -> () in
                            
                            self.deleteFeed = true
                            // Update Feed Gutter Menu
                            self.updateFeedMenu(parameter: dic["urlParams"] as! NSDictionary, url:dic["url"] as! String,feedIndex: self.currentCell  )
                        })
                        self.present(alert, animated: true, completion: nil)
                    } else if dic["name"] as! String == "edit_feed"{
                        var body_t :  String!
                        var statusBody : String = ""
                        
                        if  let body_param = feed["action_type_body_params"] as? NSArray{
                            for i in 0 ..< body_param.count {
                                let body1 = body_param[i] as! NSDictionary
                                if body1["search"] as! String == "{body:$body}"{
                                    if ( body1["label"] is String){
                                        body_t =   body1["label"] as! String
                                        body_t = body_t.replacingOccurrences(of: "\n", with: "<br/>")
                                        body_t = body_t.html2String as String
                                        
                                    }
                                    statusBody = body_t
                                    
                                }
                                
                            }
                        }
                        
                        let presentedVC = EditFeedViewController()
                        presentedVC.editBody = statusBody
                        presentedVC.editId   =  feed["action_id"] as! Int
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                    }
                    else{
                        if dic["name"] as! String == "hits_feed"{
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        
        if tableView.tag != 11
        {
            if globalArrayFeed.count>0
            {
                cell.backgroundColor = aafBgColor
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                let height = cell.frame.size.height
                var row = indexPath.row as Int
                if kFrequencyAdsInCells_feeds > 4 && nativeAdArray.count > 0
                {
                    row = row - (row / kFrequencyAdsInCells_feeds)
                    
                }
                if showSuggestions == 1 && indexPath.row > (suggestionSlideshowPosition - 1) && self.userSuggestions.count > 0 && isHomeFeeds
                {
                    row = row - 1
                }
                let activityFeed = globalArrayFeed[row] as! NSDictionary
                self.dynamicRowHeight[activityFeed["action_id"] as! Int] = height
            }
            else
            {
                cell.backgroundColor = aafBgColor
                cell.selectionStyle = UITableViewCellSelectionStyle.none
            }
        }
        
    }
    
    //Scrollview Delegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        scrollopoint = scrollView.contentOffset
        switch tableViewFrameType {
        case "ContentFeedViewController":
            let obj = NotificationCenter.default
            obj.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionContentFeed"), object: nil)

            break
        case "Pages":
            let obj1 = NotificationCenter.default
            obj1.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionPage"), object: nil)
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
            let obj = NotificationCenter.default
            obj.post(name: Foundation.Notification.Name(rawValue: "ScrollingactionAdvanceActivityFeed"), object: nil)
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

        default:
            break
        }
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
            for i in 0 ..< hashtags.count {
                let range2 = (hashtagString as NSString).range(of: NSLocalizedString("\(hashtags[i])",  comment: ""))
                cell.bodyHashtaglbl.addLink(toTransitInformation: [ "type" : "hashtags", "hashtagString" : "\(hashtags[i])"], with:range2)
            }
        }
        dynamicHeight = dynamicHeight  + cell.bodyHashtaglbl.bounds.height + 10
    }
    
    // MARK: - Reaction and comment info work
    func reactionandlikeCommentInfo(row:Int,cell:AAFActivityFeedTableViewCell)
    {
        let activityFeed = globalArrayFeed[row] as! NSDictionary
        var infoTitle = ""
        var commentTitle = ""
        cell.likeCommentInfo.setTitle("", for: .normal)
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
                    let originY:CGFloat = cell.body.frame.origin.y + cell.body.bounds.height + 5
                    if dynamicHeight != 0
                    {

                        cell.likeCommentInfo.frame.origin.y = dynamicHeight + originY + 5
                        
                    }
                    else
                    {
                        cell.likeCommentInfo.frame.origin.y =  originY + 5
                    }
                    cell.likeCommentInfo.contentHorizontalAlignment = .left
                    cell.likeCommentInfo.setTitle("\(infoTitle)", for: .normal)
                    cell.likeCommentInfo.tag = row
                    cell.likeCommentInfo.addTarget(self, action:#selector(FeedTableViewController.likeCommentInfo(_:)) , for: .touchUpInside)
                    
                }
                else
                {
                    cell.likeCommentInfo.isHidden = true
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
                if let reactions = activityFeed["feed_reactions"] as? NSDictionary{
                    cell.reactionsInfo.isHidden = false
                    var menuWidth = CGFloat()
                    var origin_x:CGFloat = 0.0
                    var i : Int = 0
                    for (_,value) in reactions
                    {
                        if let reaction = value as? NSDictionary{
                            if i <= 2
                            {
                                if (reaction["reaction_image_icon"] as? String) != nil{
                                    menuWidth = 13
                                    let   emoji = createButton(CGRect(x: origin_x ,y: 5,width: menuWidth,height: 18), title: "", border: false, bgColor: false, textColor: textColorLight)
                                    emoji.imageEdgeInsets =  UIEdgeInsets(top: 4, left: 0, bottom: 1, right: 0)
                                    let imageUrl = reaction["reaction_image_icon"] as? String
                                    let url = NSURL(string:imageUrl!)
                                    
                                    if url != nil
                                    {
                                        
                                        emoji.sd_setImage(with: url as URL!, for: .normal)
                                    }
                                    emoji.tag = row
                                    emoji.addTarget(self, action:#selector(FeedTableViewController.likeCommentInfo(_:)) , for: .touchUpInside)
                                    cell.reactionsInfo.addSubview(emoji)
                                    origin_x += (menuWidth)
                                    i = i + 1
                                    
                                }
                                
                            }
                        }
                        
                    }
                    cell.reactionsInfo.tag = row
                    cell.reactionsInfo.frame.size.width = origin_x
                    cell.likeCommentInfo.frame.origin.x = (cell.reactionsInfo.frame.size.width) + (cell.reactionsInfo.frame.origin.x) + 5
                }
                else
                {
                    cell.likeCommentInfo.frame.origin.x = 5
                    cell.reactionsInfo.isHidden = true
                    cell.commentInfo.isHidden = true
                    
                }
                
                if activityFeed["is_like"] as! Bool == true
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
                    let originY:CGFloat = (cell.body.frame.origin.y) + (cell.body.bounds.height) + 5
                    switch dynamicHeight {
                    case 0:
                        cell.likeCommentInfo.frame.origin.y =  originY + 5
                        cell.reactionsInfo.frame.origin.y = originY + 5
                        break
                        
                    default:
                        cell.likeCommentInfo.frame.origin.y = dynamicHeight + originY + 5
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
                
                    cell.commentInfo.isHidden = false
                    let originY:CGFloat = (cell.body.frame.origin.y) + (cell.body.bounds.height) + 5
                    switch dynamicHeight {
                    case 0:
                        cell.commentInfo.frame.origin.y =  originY + 5
                        break

                    default:
                        cell.commentInfo.frame.origin.y = dynamicHeight + originY + 5
                        break
                    }
                    cell.commentInfo.setTitle("\(commentTitle)", for: .normal)
                    cell.commentInfo.tag = row
                    cell.commentInfo.addTarget(self, action:#selector(FeedTableViewController.likeCommentInfo(_:)) , for: .touchUpInside)
                    
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
                cell.cellMenu.frame.origin.y = (cell.likeCommentInfo.frame.origin.y) + (cell.likeCommentInfo.bounds.height) + 5
            }
            if commentTitle != "" {
                cell.cellMenu.frame.origin.y = (cell.commentInfo.frame.origin.y) + (cell.commentInfo.bounds.height) + 5
            }
            else if infoTitle == "" && commentTitle == "" {
                let originY:CGFloat = (cell.body.frame.origin.y) + (cell.body.bounds.height) + 5
                switch dynamicHeight {
                case 0:
                    cell.cellMenu.frame.origin.y =  originY + 5
                    break
                    
                default:
                    cell.cellMenu.frame.origin.y = dynamicHeight + originY + 5
                    break
                }

            }
            // Set the sequence for Menu
            var menuSequence = [String]()
            var menuCount = 0
            if activityFeed["comment"] as? Bool == true{
                menuCount += 2
                menuSequence += ["like"]
            }
            if activityFeed["share"] as? Bool == true{
                menuCount += 1
                menuSequence += ["share"]
            }
            
            // Find out the Menu Width
            let menuItemWidth:CGFloat = (cell.cellView.bounds.width)/CGFloat(menuCount)
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
                                if activityFeed["is_like"] as! Bool == true{
                                    icon = "thumbs_up"
                                    if ReactionPlugin == true{
                                        if let myReaction = activityFeed["my_feed_reaction"] as? NSDictionary{
                                            let titleReaction = myReaction["caption"] as! String
                                            title =  NSLocalizedString("\(titleReaction)", comment: "")
                                            if let myIcon = myReaction["reaction_image_icon"] as? String{
                                                let ImageView = createButton(CGRect(x: 10,y: 10,width: 15,height: 20), title: "", border: false, bgColor: false, textColor: textColorLight)
                                                ImageView.imageEdgeInsets =  UIEdgeInsets(top: 2, left: 0, bottom: 3, right: 0)
                                                let imageUrl = myIcon
                                                let url = NSURL(string:imageUrl)
                                                ImageView.sd_setImage(with: url as URL!, for: .normal)
                                                cell.cellMenu.addSubview(ImageView)
                                            }

                                        }
                                    }
                                    else
                                    {
                                        title = String(format: NSLocalizedString("%@  Like", comment: ""), likeIcon)
                                    }
                                    textcolor = navColor
                                }
                                else
                                {
                                    icon = "thumbs_up"
                                    title = String(format: NSLocalizedString("%@  Like", comment: ""), likeIcon)
                                    textcolor = textColorMedium
                                }
                                let menu : UIButton!
                                if ReactionPlugin == true
                                {
                                    if activityFeed["is_like"] as! Bool == true{
                                        menu = createButton(CGRect(x: 27,y: 0 ,width: menuItemWidth - 40, height: 40), title: " \(title)", border: false,bgColor: false, textColor: textColorMedium )
                                        menu.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
                                        menu.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                    }
                                    else
                                    {
                                        menu = createButton(CGRect(x: 15, y: 0, width: menuItemWidth - 15,height: 40), title: " \(title)", border: false,bgColor: false, textColor: textColorMedium )
                                        menu.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
                                        menu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
                                        menu.titleLabel?.adjustsFontSizeToFitWidth = true

                                    }
                                    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FeedTableViewController.longPressed(sender:)))
                                    menu.addGestureRecognizer(longPressRecognizer)
                                }
                                else
                                {
                                    menu = createButton(CGRect(x: origin_x,y: 0 , width: menuItemWidth,height: 40), title: " \(title)", border: false,bgColor: false, textColor: textColorMedium )
                                    menu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
                                    menu.titleLabel?.adjustsFontSizeToFitWidth = true
                                }
                                
                                menu.titleLabel?.textColor = textcolor
                                menu.setTitleColor(textcolor, for: .normal)
                                menu.tag = row
                                menu.backgroundColor =  UIColor.clear
                                menu.addTarget(self, action: #selector(FeedTableViewController.feedMenuLike(sender:)), for: .touchUpInside)
                                cell.cellMenu.addSubview(menu)
                            }
                            else
                            {
                                title = String(format: NSLocalizedString("%@  Comment", comment: ""), commentIcon)
                                icon = "comment_icon"
                                let menu = createButton(CGRect(x: origin_x,y: 0, width: menuItemWidth,height: 40), title: " \(title)", border: false,bgColor: false, textColor: textColorMedium )
                                menu.tag = row
                                menu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
                                menu.titleLabel?.adjustsFontSizeToFitWidth = true
                                menu.backgroundColor = textColorLight
                                menu.addTarget(self, action: #selector(FeedTableViewController.commentAction(_:)), for: .touchUpInside)
                                cell.cellMenu.addSubview(menu)
                            }
                            origin_x += menuItemWidth
                        }
                        continue
                    }
                case "share":
                    if feed_menu["share"] != nil{
                        title = (feed_menu["share"] as! NSDictionary)["label"] as! String
                        icon = "share_icon"
                        
                        let menu = createButton(CGRect(x: origin_x,y: 0, width: menuItemWidth, height: 40), title: "", border: false,bgColor: false, textColor: textColorMedium)
                        menu.tag = row
                        menu.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
                        menu.setTitle(" \(title)", for: UIControlState.normal)
                        menu.titleLabel?.textColor = textColorMedium
                        menu.tintColor = textColorMedium
                        let image = UIImage(named: "\(icon)")
                        menu.setImage(image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
                        menu.backgroundColor = textColorLight
                        menu.addTarget(self, action: #selector(FeedTableViewController.feedMenuShare(sender:)), for: .touchUpInside)
                        cell.cellMenu.addSubview(menu)
                        
                    }
                    
                default:
                    print("Error")
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
                    cell.sideMenu.addGestureRecognizer(recognizer)
                    cell.sideMenu.addTarget(self, action: Selector(("showGutterMenu:")), for: .touchUpInside)
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
            dynamicHeight = ((cell.cellView.frame.size.height) + 10)
            
        }
        else if (noCommentMenu == true)
        {
            cell.likeCommentInfo.isHidden = true
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
            dynamicHeight = ((cell.cellView.frame.size.height) + 10)
            
            
        }
        else
        {
            cell.cellMenu.isHidden = false
            cell.cellView.frame.size.height = (cell.cellMenu.frame.origin.y) + (cell.cellMenu.bounds.height)
            dynamicHeight = ((cell.cellView.frame.size.height) + 10)
            
        }
        self.dynamicRowHeight[activityFeed["action_id"] as! Int] = self.dynamicHeight
    }
    
    // Present Feed Gutter Menus
    func showGutterMenu(sender:UIButton)
    {
        if openSideMenu
        {
            openSideMenu = false
            toggleSideMenuView()
            return
        }
        deleteFeed = false
        menuOptionSelected = ""
        let feed = globalArrayFeed[sender.tag] as! NSDictionary
        // Set Sequence for menu
        if let feed_menu = feed["feed_menus"] as? NSArray{
            
            // Generate Feed Filter Gutter Menu for Feed Come From Server as! Alert Popover
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            for menuItem in feed_menu{
                if let dic = menuItem as? NSDictionary {
                    
                    let titleString = dic["label"] as! String
                    if titleString.range(of: "Delete") != nil{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertActionStyle.destructive, handler:{ (UIAlertAction) -> Void in
                            self.menuOptionSelected = dic["name"] as! String
                            // Delete Activity Feed Entry
                            if dic["name"] as! String == "delete_feed"{
                                
                                // Confirmation Alert for Delete Feed
                                displayAlertWithOtherButton(NSLocalizedString("Delete Activity Item?", comment: "") ,message: NSLocalizedString("Are you sure that you want to delete this activity item? This action cannot be undone.", comment: "") ,otherButton: NSLocalizedString("Delete", comment: ""), otherButtonAction: { () -> () in
                                    self.deleteFeed = true
                                    
                                    // Update Feed Gutter Menu
                                    self.updateFeedMenu(parameter: dic["urlParams"] as! NSDictionary, url:dic["url"] as! String,feedIndex: sender.tag)
                                })
                                self.present(alert, animated: true, completion: nil)
                            }else{
                                if dic["name"] as! String == "hits_feed"{
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
                            self.menuOptionSelected = dic["name"] as! String
                            // Delete Activity Feed Entry
                            if dic["name"] as! String == "delete_feed"{
                                
                                // Confirmation Alert for Delete Feed
                                displayAlertWithOtherButton(NSLocalizedString("Delete Activity Item?", comment: "") ,message: NSLocalizedString("Are you sure that you want to delete this activity item? This action cannot be undone.", comment: "") ,otherButton: NSLocalizedString("Delete", comment: ""), otherButtonAction: { () -> () in
                                    self.deleteFeed = true
                                    // Update Feed Gutter Menu
                                    self.updateFeedMenu(parameter: dic["urlParams"] as! NSDictionary, url:dic["url"] as! String,feedIndex: sender.tag  )
                                })
                                self.present(alert, animated: true, completion: nil)
                            } else if dic["name"] as! String == "edit_feed"{
                                var body_t :  String!
                                var statusBody : String = ""
                                
                                if  let body_param = feed["action_type_body_params"] as? NSArray{
                                    for i in 0 ..< body_param.count {
                                        let body1 = body_param[i] as! NSDictionary
                                        if body1["search"] as! String == "{body:$body}"{
                                            if ( body1["label"] is String){
                                                body_t = body1["label"] as! String
                                                body_t = body_t.replacingOccurrences(of: "\n", with: "<br/>")
                                                body_t = body_t.html2String as String
                                                body_t = Emoticonizer.emoticonizeString("\(body_t!)" as NSString) as String
                                            }
                                            statusBody = body_t
                                        }
                                        
                                    }
                                }
                                
                                let presentedVC = EditFeedViewController()
                                presentedVC.editBody = statusBody
                                presentedVC.editId   =  feed["action_id"] as! Int
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                            }
                            else{
                                if dic["name"] as! String == "hits_feed"{
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
            if  (UIDevice.current.userInterfaceIdiom == .phone){
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
        if reachability.isReachable {
            removeAlert()
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as Int)
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
            userInteractionOff = false
            // Send Server Request to Update Feed Gutter Menu
            post(dic, url: url, method: method) { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute:  {
                    userInteractionOff = true
                    
                    if msg
                    {
                        
                        // Check for Delete Particular FEED
                        if self.deleteFeed == true{
                            // Make Hard Referesh For Delete Feed & REset VAriable
                            self.maxid = 0
                            self.feed_filter = 0
                            self.deleteFeed = false
                            self.globalArrayFeed.remove(at:feedIndex)
                            advGroupDetailUpdate = true
                            var index = Int()
                            if kFrequencyAdsInCells_feeds > 4 && self.nativeAdArray.count > 0
                            {
                                
                                index = feedIndex + self.adsCount
                                self.tableView.reloadData()
                            }
                            else
                            {
                                index = feedIndex
                                let indexPath = IndexPath(row: index, section: 0)
                                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                                self.tableView.endUpdates()
                                self.tableView.reloadData()
                            }
                            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("Your post has been deleted successfully", comment: ""), duration: 5, position: "bottom")
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
                                        if newDictionary["attachment"] != nil
                                        {
                                            var dic:NSMutableDictionary = [:]
                                            let array = newDictionary["attachment"] as! NSMutableArray
                                            dic = array[0] as! NSMutableDictionary
                                            if dic["is_like"] != nil
                                            {
                                                dic["is_like"] = false
                                            }
                                            if dic["likes_count"] != nil
                                            {
                                                dic["likes_count"] = ((dic["likes_count"] as? Int)!-1)
                                            }
                                            array.removeObject(at: 0)
                                            array.add(dic)
                                            newDictionary["attachment"] = array
                                            
                                        }
                                    }
                                    break
                                default:
                                    newDictionary["is_like"] = true
                                    newDictionary["likes_count"] = ((feed["likes_count"] as? Int)!+1)
                                    if newDictionary["feed_Type"] as! String != "share"
                                    {
                                        if newDictionary["attachment"] != nil
                                        {
                                            var dic:NSMutableDictionary = [:]
                                            let array = newDictionary["attachment"] as! NSMutableArray
                                            dic = array[0] as! NSMutableDictionary
                                            if dic["is_like"] != nil
                                            {
                                                dic["is_like"] = true
                                            }
                                            if dic["likes_count"] != nil
                                            {
                                                dic["likes_count"] = ((dic["likes_count"] as? Int)!+1)
                                            }
                                            array.removeObject(at: 0)
                                            array.add(dic)
                                            newDictionary["attachment"] = array
                                            
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
                                        updatedLabel = NSLocalizedString("Saved Feed", comment: "")
                                        break
                                    default:
                                        updatedLabel = NSLocalizedString("Unsaved Feed", comment: "")
                                        break
                                    }

                                }
                            case "hide", "report_feed":
                                if let body = succeeded["body"] as? NSDictionary
                                {
                                    self.tempcontentFeedArray[feed["action_id"] as! Int] = body
                                }
                                break
                            case "undo":
                                self.tempcontentFeedArray.removeValue(forKey: feed["action_id"] as! Int)
                                break
                            default:
                                print("Error", terminator: "")
                                break
                            }
                            
                            // Update Menu Option without Hard Refresh
                            if self.menuOptionSelected == "disable_comment" || self.menuOptionSelected == "lock_this_feed" || self.menuOptionSelected == "update_save_feed" {
                                if feed["feed_menus"]  != nil{
                                    var tempArray = [AnyObject]()
                                    var tempMutableArray : NSArray
                                    tempMutableArray = feed["feed_menus"]! as! NSArray
                                    for menu in tempMutableArray{
                                        if let menuDic = menu as? NSMutableDictionary{
                                            let subMenuDictionary:NSMutableDictionary = [:]
                                            
                                            if menuDic["name"] as! String == self.menuOptionSelected {
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
                                    newDictionary["feed_menus"] = tempArray
                                    tempArray.removeAll(keepingCapacity: false)
                                }
                            }
                            // Sink feedArray with Updation
                            self.globalArrayFeed[feedIndex] = newDictionary
                            self.tableView.reloadData()
                            
                        }
                        
                    }
                    
                })
            }
            
        }
        else
        {
            UIApplication.shared.keyWindow?.makeToast(network_status_msg, duration: 5, position: "bottom")
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
        //Check for objectID
        if let objectID = components["id"] as? Int
        {
            contentRedirection(feedtype: type, activityFeed:activityfeed ,objectID:objectID, attechmentDic : attchmendic)
        }
        else
        {
            let objectID = 0
          contentRedirection(feedtype: type, activityFeed:activityfeed ,objectID:objectID, attechmentDic : attchmendic)
        }

    }    

    // MARK: Content redirection
    func tappedContent(sender: UITapGestureRecognizer)
    {
        //using sender, we can get the point in respect to the table view
        let tapLocation = sender.location(in: self.tableView)
        
        //using the tapLocation, we retrieve the corresponding indexPath
        let indexPath = self.tableView.indexPathForRow(at: tapLocation)
        
        //finally, we print out the value
        if var rowIndexPath = (indexPath?.row)
        {
            // Calculate actuall index after removing ads cell
            if kFrequencyAdsInCells_feeds > 4 && nativeAdArray.count > 0 && globalArrayFeed.count > kFrequencyAdsInCells_feeds-1
            {
                rowIndexPath = rowIndexPath - (rowIndexPath / kFrequencyAdsInCells_feeds)
            }
            
            // Calculate actuall index after removing people you may know cell
            if rowIndexPath > suggestionSlideshowPosition - 1 && showSuggestions == 1 &&  isHomeFeeds && self.userSuggestions.count > 0
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
                            present(nativationController, animated:true, completion: nil)
                        }
                        
                        if objectType.contains(object_type_string)
                        {
                            if let attchmentarr = activityFeed["attachment"] as? NSArray
                            {
                                let attechmentDic = attchmentarr[0] as! NSDictionary
                                let objectID = attechmentDic["attachment_id"] as! Int
                                // Redirection
                                contentRedirection(feedtype: object_type_string , activityFeed: activityFeed,objectID:objectID, attechmentDic : attechmentDic)
                                
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

                        contentRedirection(feedtype: objectType , activityFeed: activityFeed,objectID:objectID, attechmentDic : attechmentDic)
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
    func contentRedirection(feedtype:String,activityFeed:NSDictionary,objectID : Int,attechmentDic:NSDictionary)
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
            let presentedVC = FeedViewPageViewController()
            presentedVC.action_id = objectID
            navigationController?.pushViewController(presentedVC, animated: true)
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
            presentedVC.subjectType = "user"
            presentedVC.subjectId = objectID
            presentedVC.fromActivity = true
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
            break
            
        case "user":
            
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId =   objectID
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
            let singleString = String(original.characters.dropFirst())
            let presentedVC = HashTagFeedViewController()
            presentedVC.hashtagString = singleString
            navigationController?.pushViewController(presentedVC, animated: true)
            break
 
        case "group":
            let presentedVC = ContentFeedViewController()
            presentedVC.subjectType = "group"
            presentedVC.subjectId = objectID
            self.navigationController?.pushViewController(presentedVC, animated: true)
            break
        case "event":
            let presentedVC = ContentFeedViewController()
            presentedVC.subjectType = "event"
            presentedVC.subjectId = objectID
            self.navigationController?.pushViewController(presentedVC, animated: true)
            break
        case "album":
            let presentedVC = AlbumProfileViewController()
            presentedVC.albumId = objectID
            self.navigationController?.pushViewController(presentedVC, animated: false)
            break
        case "blog":
            
            BlogObject().redirectToBlogDetailPage(self,blogId: objectID,title: "")
            break
        case "video":
            
            if let attachment = activityFeed["attachment"] as? NSArray{
                VideoObject().redirectToVideoProfilePage(self,videoId: (attachment[0] as! NSDictionary)["attachment_id"] as! Int,videoType: (attachment[0] as! NSDictionary)["attachment_video_type"] as! Int,videoUrl: (attachment[0] as! NSDictionary)["attachment_video_url"] as! String)

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
            presentedVC.forumId = activityFeed["id"] as! Int
            presentedVC.forumName = activityFeed["label"] as! String
            presentedVC.forumSlug = activityFeed["slug"] as! String
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
                present(nativationController, animated:true, completion: nil)
            break
         case "classified":
            
            ClassifiedObject().redirectToProfilePage(self, id: objectID)
            break
            
        case "music_playlist":
            
            MusicObject().redirectToPlaylistPage(self,id: objectID)
            break

        case "core_link":
            
            fromExternalWebView = true
            let presentedVC = ExternalWebViewController()
            presentedVC.url = attechmentDic["uri"] as! String
            presentedVC.fromDashboard = false
            navigationController?.pushViewController(presentedVC, animated: true)
            break
            

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
                    presentedVC.subjectId = objectID
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
                    SiteMltObject().redirectToMltProfilePage(self ,subjectType : "sitereview_listing" , listingTypeIdValue : listingTypeId , listingIdValue : objectID , viewTypeValue : viewType)
                    
                    
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
                    presentedVC.subjectId = objectID
                    presentedVC.contentType = "advancedevents"
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                else
                {
                    
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "advancedevents"
                    presentedVC.subjectId = objectID
                    self.navigationController?.pushViewController(presentedVC, animated: true)
                }
                
            }
            else
            {
                
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "advancedevents"
                presentedVC.subjectId = objectID
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
                    presentedVC.subjectId = objectID
                    presentedVC.contentType = "Pages"
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                else
                {
                    
                    SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: objectID)
                    
                }
            }
            else
            {
                SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: objectID)
                
            }
            break
        case "sitegroup_group":
            
            if let attachment = activityFeed["attachment"] as? NSArray
            {
                
                if attechmentDic["attachment_type"] as! String == "sitegroupreview_review"
                {
                    let presentedVC = PageReviewViewController()
                    presentedVC.mytitle = (attachment[0] as! NSDictionary)["title"] as! String//activityFeed["feed_title"] as! String
                    presentedVC.subjectId = objectID
                    presentedVC.contentType = "sitegroup"
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                else if (attechmentDic["attachment_type"] as! String == "video"){
                    
                    VideoObject().redirectToVideoProfilePage(self,videoId: (attachment[0] as! NSDictionary)["attachment_id"] as! Int,videoType: attechmentDic["attachment_video_type"] as! Int,videoUrl: attechmentDic["attachment_video_url"] as! String)
                    
                }
                else if attechmentDic["attachment_type"] as! String == "core_link"{
                    fromExternalWebView = true
                    let presentedVC = ExternalWebViewController()
                    presentedVC.url = attechmentDic["uri"] as! String
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let navigationController = UINavigationController(rootViewController: presentedVC)
                    self.present(navigationController, animated: true, completion: nil)
                    
                }
                else
                {
                    SiteAdvGroupObject().redirectToAdvGroupProfilePage(self, subject_type: "sitegroup_group", subject_id: objectID)
                }
            }
            else{
                SiteAdvGroupObject().redirectToAdvGroupProfilePage(self, subject_type: "sitegroup_group", subject_id: objectID)
                
            }
            break
        case "sitereview_wishlist":
            
            let presentedVC = WishlistDetailViewController()
            if let objectDictionary = activityFeed["object"] as? NSDictionary
            {
                presentedVC.subjectId  = objectID
                if let tempBody = objectDictionary["body"] as? String{
                    presentedVC.descriptionWishlist = tempBody
                }
                
                if let tempTitle = objectDictionary["title"] as? String{
                    presentedVC.wishlistName = tempTitle
                }
                navigationController?.pushViewController(presentedVC, animated: true)
            }
            break
            
        case  "sitestoreproduct_product":
            if (activityFeed["attachment"] as? NSArray) != nil
            {
                
                if attechmentDic["attachment_type"] as! String == "sitestoreproduct_product"
                {
                    if let product_id = attechmentDic["attachment_id"] as? Int{
                        SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id:product_id)
                    }
                    
                }
                    
                else if attechmentDic["attachment_type"] as! String == "sitestore_store"
                {
                    if let product_id = attechmentDic["attachment_id"] as? Int{
                        SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: product_id)
                        
                    }
                }
                else  if attechmentDic["attachment_type"] as! String == "sitestoreproduct_wishlist"
                {
                    let presentedVC = WishlistDetailViewController()
                    presentedVC.productOrOthers = true
                    if let productInfo = activityFeed["object"] as? NSDictionary {
                        if let wishlist_id =  productInfo["wishlist_id"] as? Int{
                            presentedVC.subjectId = wishlist_id
                        }
                        presentedVC.wishlistName = productInfo["title"] as? String
                        presentedVC.descriptionWishlist = productInfo["body"] as? String
                    }
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
                        if (activityFeed["object"] as? NSDictionary) != nil {
                            let product_id =   activityFeed["object_id"] as? Int
                            presentedVC.subjectId = product_id
                        }
                        presentedVC.mytitle = ""
                        presentedVC.contentType = "product"//"siteproduct_review"
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    
                    
                }
                
            }
            else
            {
                if let productInfo = activityFeed["object"] as? NSDictionary {
                    let product_id =   productInfo["product_id"] as? Int
                    SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id:product_id!)
                    
                    
                }
                
            }
        case   "sitestoreproduct_wishlist":
            if let attachment = activityFeed["attachment"] as? NSArray
            {
                
                if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestoreproduct_product"
                {
                    if let product_id = (attachment[0] as! NSDictionary)["attachment_id"] as? Int{
                        SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id:product_id)
                    }
                    
                }
                else if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestore_store"
                {
                    if let product_id = (attachment[0] as! NSDictionary)["attachment_id"] as? Int{
                        SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: product_id)
                    }
                }
                else  if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestoreproduct_wishlist"
                {
                    let presentedVC = WishlistDetailViewController()
                    presentedVC.productOrOthers = true
                    if let productInfo = activityFeed["object"] as? NSDictionary {
                        if let wishlist_id =  productInfo["wishlist_id"] as? Int{
                            presentedVC.subjectId = wishlist_id
                        }
                        presentedVC.wishlistName = productInfo["title"] as? String
                        presentedVC.descriptionWishlist = productInfo["body"] as? String
                    }
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
                            presentedVC.subjectId = product_id
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
                if let productInfo = activityFeed["object"] as? NSDictionary {
                    if let wishlist_id =  productInfo["wishlist_id"] as? Int{
                        presentedVC.subjectId = wishlist_id
                    }
                    presentedVC.wishlistName = productInfo["title"] as? String
                    presentedVC.descriptionWishlist = productInfo["body"] as? String
                }
                navigationController?.pushViewController(presentedVC, animated: true)
                
            }
            break
        case "sitestore_store":
            
            if let attachment = activityFeed["attachment"] as? NSArray
            {
                
                if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestoreproduct_product"
                {
                    if let product_id = (attachment[0] as! NSDictionary)["attachment_id"] as? Int{
                        SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id:product_id)
                    }
                    
                    
                }
                else if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestore_store"
                {
                    if let product_id = (attachment[0] as! NSDictionary)["attachment_id"] as? Int{
                        SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: product_id)
                        
                    }
                }
                else  if (attachment[0] as! NSDictionary)["attachment_type"] as! String == "sitestoreproduct_wishlist"
                {
                    
                    
                    let presentedVC = WishlistDetailViewController()
                    presentedVC.productOrOthers = true
                    if let productInfo = activityFeed["object"] as? NSDictionary {
                        if let wishlist_id =  productInfo["wishlist_id"] as? Int{
                            presentedVC.subjectId = wishlist_id
                            
                            
                        }
                        presentedVC.wishlistName = productInfo["title"] as? String
                        presentedVC.descriptionWishlist = productInfo["body"] as? String
                    }
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
                            presentedVC.subjectId = product_id
                            
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
                    let store_id = storeInfo["store_id"] as! Int
                    SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: store_id)
                }
            }
            break
        case  "sitestoreproduct_order" :
            SiteStoreObject().redirectToMyStore(viewController: self)
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
                let resourceType = dic["resource_type"] as! String!
                switch resourceType! {
                case "video":
                    VideoObject().redirectToVideoProfilePage(self,videoId: resourceId,videoType: dic["video_type"] as! Int,videoUrl: dic["video_url"] as! String)
                    break
                case "blog":
                    BlogObject().redirectToBlogDetailPage(self,blogId: resourceId ,title: "")
                    break
                case "classified":
                    ClassifiedObject().redirectToProfilePage(self, id: resourceId )
                    break
                case "album":
                    let presentedVC = AlbumProfileViewController()
                    presentedVC.albumId = resourceId as Int!
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                    break
                case "music_playlist":
                    MusicObject().redirectToPlaylistPage(self,id: resourceId )
                    break
                case "poll":
                    let presentedVC = PollProfileViewController()
                    presentedVC.pollId =   resourceId as Int!
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                    break
                case "sitepage_page":
                    SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: resourceId )
                    break
                case "group":
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "group"
                    presentedVC.subjectId =   resourceId as Int!
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                    break
                case "event":
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "event"
                    presentedVC.subjectId =   resourceId as Int!
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                    break
                case "siteevent_event":
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "advancedevents"
                    presentedVC.subjectId =   resourceId as Int!
                    self.navigationController?.pushViewController(presentedVC, animated: true)
                    break
                case "sitestoreproduct_product":
                    SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id: resourceId )
                    break
                case "sitestore_store":
                    SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: resourceId )
                    break

                default:
                    break
                }

                
            }
            
            break

        default:

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
    func openSingleImage(sender: UIButton)
    {
        let activityFeed = globalArrayFeed[sender.tag] as! NSDictionary
        if let attachment = activityFeed["attachment"] as? NSArray
        {
            if ((attachment[0] as! NSDictionary)["attachment_type"] as! String).range(of: "_photo") != nil
            {
                
                let pv = ActivityFeedPhotoViewController()
                pv.photoAttachmentArray = attachment
                pv.photoIndex = 0
                if let photo_type = (attachment[0] as! NSDictionary)["attachment_type"] as? String
                {
                    pv.photoType = "\(photo_type)"
                    
                }
                else
                {
                    pv.photoType = "album_photo"
                    
                }
                let nativationController = UINavigationController(rootViewController: pv)
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
                        if let photo_type = activityFeed["share_params_type"] as? String{
                            pv.photoType = "\(photo_type)"
                        }
                        else
                        {
                            pv.photoType = "album_photo"
                        }
                        let nativationController = UINavigationController(rootViewController: pv)
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
    func handleTapped(recognizer: UITapGestureRecognizer) {
        currentCell = (recognizer.view?.tag)!
        let tapPositionOneFingerTap = recognizer.location(in: nil)
        var count  = 0
        guttermenuoption.removeAll(keepingCapacity: false)
        if openSideMenu{
            openSideMenu = false
            toggleSideMenuView()
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
        
        let heightOfPopoverTableView : CGFloat = CGFloat(count) * 40.0
        if((view.bounds.height - tapPositionOneFingerTap.y) > heightOfPopoverTableView) {
            let startPoint = CGPoint(x: self.view.frame.width - 15, y: tapPositionOneFingerTap.y )
            self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
            popoverTableView = UITableView(frame: CGRect(x: 0, y: 64, width: self.view.frame.width, height: heightOfPopoverTableView))
            popoverTableView.delegate = self
            popoverTableView.dataSource = self
            popoverTableView.isScrollEnabled = false
            popoverTableView.tag = 11
            popover.show(popoverTableView, point: startPoint)
            popoverTableView.reloadData()
            
            
        }
        else{
            let heightt : CGFloat = CGFloat(count) * 40.0
            let startPoint = CGPoint(x: self.view.frame.width - 15, y: tapPositionOneFingerTap.y )
            self.popover = Popover(options: self.popoverOptionsUp, showHandler: nil, dismissHandler: nil)
            popoverTableView = UITableView(frame: CGRect(x: 0, y: 64, width: self.view.frame.width, height: heightt))
            popoverTableView.delegate = self
            popoverTableView.dataSource = self
            popoverTableView.isScrollEnabled = false
            popoverTableView.tag = 11
            popover.show(popoverTableView, point: startPoint)
            popoverTableView.reloadData()
        }
    }
    
    // MARK: Photo Redirection
    func firstPhotoClick(sender:UIButton){
        let activityFeed = globalArrayFeed[sender.tag] as! NSDictionary
        if let attachment = activityFeed["attachment"] as? NSArray{
            let pv = ActivityFeedPhotoViewController()
            pv.photoAttachmentArray = attachment
            pv.photoIndex = 0
            if let photo_type = (attachment[0] as! NSDictionary)["attachment_type"] as? String{
                pv.photoType = "\(photo_type)"
            }else{
                pv.photoType = "album_photo"
                
            }
            let nativationController = UINavigationController(rootViewController: pv)
            present(nativationController, animated:true, completion: nil)
        }
        
        
    }
    
    func secondPhotoClick(sender:UIButton){
        let activityFeed = globalArrayFeed[sender.tag] as! NSDictionary
        if let attachment = activityFeed["attachment"] as? NSArray{
            let pv = ActivityFeedPhotoViewController()
            pv.photoAttachmentArray = attachment
            pv.photoIndex = 1
            if let photo_type = (attachment[0] as! NSDictionary)["attachment_type"] as? String{
                pv.photoType = "\(photo_type)"
            }else{
                pv.photoType = "album_photo"
            }
            let nativationController = UINavigationController(rootViewController: pv)
            present(nativationController, animated:true, completion: nil)
        }
        
    }
    
    func thirdPhotoClick(sender:UIButton){
        let activityFeed = globalArrayFeed[sender.tag] as! NSDictionary
        if let attachment = activityFeed["attachment"] as? NSArray{
            let pv = ActivityFeedPhotoViewController()
            pv.photoAttachmentArray = attachment
            pv.photoIndex = 2
            if let photo_type = (attachment[0] as! NSDictionary)["attachment_type"] as? String{
                pv.photoType = "\(photo_type)"
            }else{
                pv.photoType = "album_photo"
            }
            let nativationController = UINavigationController(rootViewController: pv)
            present(nativationController, animated:true, completion: nil)
            
        }
        
    }
    
    func multiplePhotoClick(sender: UITapGestureRecognizer){
        //using sender, we can get the point in respect to the table view
        let tapLocation = sender.location(in:self.tableView)
        
        //using the tapLocation, we retrieve the corresponding indexPath
        let indexPath = self.tableView.indexPathForRow(at:tapLocation)
        
        
        //finally, we print out the value
        if var rowIndexPath = (indexPath?.row){
            
            if kFrequencyAdsInCells_feeds > 4 && nativeAdArray.count > 0 && globalArrayFeed.count > kFrequencyAdsInCells_feeds-1
            {
                rowIndexPath = rowIndexPath - (rowIndexPath / kFrequencyAdsInCells_feeds)
            }
            
            if rowIndexPath > suggestionSlideshowPosition - 1 && showSuggestions == 1 &&  isHomeFeeds && self.userSuggestions.count > 0
            {
                rowIndexPath = rowIndexPath - 1
            }
            let activityFeed = globalArrayFeed[rowIndexPath] as! NSDictionary
            
            if let attachment = activityFeed["attachment"] as? NSArray{
                // TODO: Need Changes Here
                let pv = ActivityFeedPhotoViewController()
                pv.photoAttachmentArray = attachment
                pv.photoIndex = 3
                if let photo_type = (attachment[0] as! NSDictionary)["attachment_type"] as? String{
                    pv.photoType = "\(photo_type)"
                }else{
                    pv.photoType = "album_photo"
                }
                let nativationController = UINavigationController(rootViewController: pv)
                present(nativationController, animated:true, completion: nil)
            }
            
        }
        
    }
    // MARK: - Activity Feed Actions for Like, Comment & Share
    
    // Activity Feed Like Action
    func feedMenuLike(sender:UIButton)
    {
        let feed = globalArrayFeed[sender.tag] as! NSDictionary
        
        if feed["is_like"] as! Bool == true{
            sender.setTitleColor(textColorMedium, for: .normal)
            sender.tintColor = textColorMedium
            if ReactionPlugin == false {
                animationEffectOnButton(sender)
            }
            
        }
        else{
            sender.setTitleColor(navColor, for: .normal)
            sender.tintColor = navColor
            if ReactionPlugin == false {
                animationEffectOnButton(sender)
                
            }
        }
        sender.isEnabled = false
        
        if openSideMenu{
            openSideMenu = false
            toggleSideMenuView()
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
                                
                                updatedDictionary["reaction_image_icon"] = icon["reaction_image_icon"] as! String as AnyObject?
                                
                            }
                            var url = ""
                            url = "advancedactivity/like"
                            
                            DispatchQueue.main.async(execute:  {
                                soundEffect("Like")
                            })
                            updateReaction(url: url,reaction : reaction,action_id  : action_id, updateMyReaction : updatedDictionary as NSDictionary,feedIndex: sender.tag)
                            
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
                })
                
                deleteReaction(url: url,reaction : reaction,action_id  : action_id, updateMyReaction : updatedDictionary as NSDictionary,feedIndex: sender.tag)
                
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
    func commentAction(_ sender:UIButton){
        let feed = globalArrayFeed[sender.tag] as! NSDictionary
        showComments(feedIndex: sender.tag, openTextView: 1, contentID: feed["action_id"] as! Int)
    }
    
    // Show Like, Comment Info for Feed
    func likeCommentInfo(_ sender:UIButton){
        let feed = globalArrayFeed[sender.tag] as! NSDictionary
        showComments(feedIndex: sender.tag, openTextView: 0, contentID: feed["action_id"] as! Int)
    }
    
    // Perform Comment Feed Action
    func showComments(feedIndex: Int, openTextView: Int, contentID: Int ){
        if openSideMenu{
            openSideMenu = false
            toggleSideMenuView()
            return
        }
        
        
        // Stop Timer
        if myTimer != nil{
            myTimer.invalidate()
        }
        if ReactionPlugin == true{
            let feed = globalArrayFeed[feedIndex] as! NSDictionary
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
        likeCommentContent_id = contentID
        likeCommentContentType = "activity_action"
        let presentedVC = CommentsViewController()
        presentedVC.openCommentTextView = openTextView
        presentedVC.activityfeedIndex = feedIndex
        presentedVC.activityFeedComment = true
        presentedVC.fromActivityFeed = true
        presentedVC.commentPermission = 1
        // add
        presentedVC.commentFeedArray =  globalArrayFeed
        if userFeeds == true{
            presentedVC.userActivityFeedComment = true
        }
        else{
            presentedVC.contentActivityFeedComment = true
        }
        // add
        presentedVC.actionIdDelete = action_id
        presentedVC.reactionsIcon = reactionsIcon
        
        if footerDashboard == true
        {
            self.navigationController?.pushViewController(presentedVC, animated: true)

        }
        else
        {
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    // ActivityFeed Share Option
    func feedMenuShare(sender:UIButton){
        if openSideMenu{
            openSideMenu = false
            toggleSideMenuView()
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
                
                
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share on \(app_title)",comment: ""), style: .default) { action -> Void in
                    
                    
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
                                        if let photoMainDictionary = photoDictionary["image_main"] as? String {
                                            let imageUrl = photoMainDictionary
                                            if imageUrl != "" {
                                                presentedVC.imageString = imageUrl
                                            }
                                        }
                                        if let attachment_title = photoDictionary["title"] as? String{
                                            presentedVC.Sharetitle = attachment_title
                                        }
                                        if let attachment_description = photoDictionary["body"] as? String{
                                            presentedVC.ShareDescription = attachment_description
                                        }
                                        if footerDashboard == true {
                                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                            let nativationController = UINavigationController(rootViewController: presentedVC)
                                            self.present(nativationController, animated:true, completion: nil)
                                        }else{
                                            let presentedVC = AdvanceShareViewController()
                                            presentedVC.param = (share["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                            presentedVC.url = share["url"] as! String
                                            let photoDictionary = (attachment[0] as! NSDictionary)
                                            if let photoMainDictionary = photoDictionary["image_main"] as? String {
                                                let imageUrl = photoMainDictionary
                                                if imageUrl != "" {
                                                    presentedVC.imageString = imageUrl
                                                }
                                            }
                                            if let attachment_title = photoDictionary["title"] as? String{
                                                presentedVC.Sharetitle = attachment_title
                                            }
                                            if let attachment_description = photoDictionary["body"] as? String{
                                                presentedVC.ShareDescription = attachment_description
                                            }
                                            
                                            if footerDashboard == true {
                                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                                self.present(nativationController, animated:true, completion: nil)
                                            }else{
                                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                            }
                                            
                                        }
                                    }else{
                                        let presentedVC = AdvanceShareViewController()
                                        presentedVC.param = (share["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                        presentedVC.url = share["url"] as! String
                                        let photoDictionary = (attachment[0] as! NSDictionary)
                                        
                                        if let photoMain = photoDictionary["image_main"] as? String {
                                            
                                            presentedVC.imageString = photoMain
                                            
                                        }
                                        if let attachment_title = photoDictionary["title"] as? String{
                                            presentedVC.Sharetitle = attachment_title
                                        }
                                        if let attachment_description = photoDictionary["body"] as? String{
                                            presentedVC.ShareDescription = attachment_description
                                        }
                                        if footerDashboard == true {
                                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                            let nativationController = UINavigationController(rootViewController: presentedVC)
                                            self.present(nativationController, animated:true, completion: nil)
                                        }else{
                                            self.navigationController?.pushViewController(presentedVC, animated: false)
                                        }
                                        
                                    }
                                    
                                }else{
                                    let presentedVC = AdvanceShareViewController()
                                    presentedVC.param = share["urlParams"] as! NSDictionary
                                    presentedVC.url = share["url"] as! String
                                    presentedVC.Sharetitle = feed["feed_title"] as? String
                                    presentedVC.ShareDescription = ""
                                    presentedVC.imageString = ""
                                    if footerDashboard == true {
                                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                        let nativationController = UINavigationController(rootViewController: presentedVC)
                                        self.present(nativationController, animated:true, completion: nil)
                                    }else{
                                        self.navigationController?.pushViewController(presentedVC, animated: false)
                                    }
                                    
                                }
                            }
                        }else{
                            let presentedVC = AdvanceShareViewController()
                            presentedVC.param = (share["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            presentedVC.url = share["url"] as! String
                            presentedVC.Sharetitle = feed["feed_title"] as? String
                            presentedVC.ShareDescription = ""
                            presentedVC.imageString = ""
                            if footerDashboard == true {
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                            }else{
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                            }
                            
                        }
                        
                        
                    }else{
                        let presentedVC = AdvanceShareViewController()
                        presentedVC.param = share["urlParams"] as! NSDictionary
                        presentedVC.url = share["url"] as! String
                        presentedVC.Sharetitle = feed["feed_title"] as? String
                        presentedVC.ShareDescription = ""
                        presentedVC.imageString = ""
                        if footerDashboard == true {
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:true, completion: nil)
                        }else{
                            self.navigationController?.pushViewController(presentedVC, animated: false)
                        }
                        
                    }
                })
                
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share Outside",comment: ""), style: UIAlertActionStyle.default) { action -> Void in
                    
                    var sharingItems = [AnyObject]()
                    
                    if let text = self.shareTitle {
                        sharingItems.append(text as AnyObject)
                    }
                    
                    if let objectDictionary = feed["object"] as? NSDictionary{
                        
                        if let url = objectDictionary["url"] as? String {
                            let finalUrl = NSURL(string: url)!
                            sharingItems.append(finalUrl)
                        }
                    }
                    
                    let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
                    activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
                    
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
    
    func showUserProfile(sender:UIButton){
        let activityFeed = globalArrayFeed[sender.tag] as! NSDictionary
        var boolvariableforstore = false
        if  let body_param = activityFeed["action_type_body_params"] as? NSArray{
            for i in 0 ..< body_param.count {
                let body1 = body_param[i] as! NSDictionary
                if body1["search"] as! String == "{item:$object}"{
                    if let type = body1["type"] as? String {
                        if type == "sitestore_store"{
                            boolvariableforstore = true
                        }
                    }
                }
            }
            
        }
        if boolvariableforstore == true{
            if let storeInfo = activityFeed["object"] as? NSDictionary {
                SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: storeInfo["store_id"] as! Int)
            }
        }
        else{
            
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            if(activityFeed["subject_id"] is NSInteger){
                UserId = activityFeed["subject_id"] as! NSInteger
            }
            presentedVC.subjectId = UserId
            presentedVC.fromActivity = false
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    func longPressed(sender: UILongPressGestureRecognizer)
    {
        
        let aTap = UITapGestureRecognizer(target: self, action: #selector(FeedTableViewController.removeEmoji(recognizer:)))
        mainView.addGestureRecognizer(aTap)
        
        
        let  Currentcell = (sender.view?.tag)!
        
        let tapLocation = sender.location(in: self.view)
        
        
       if sender.state == .began {
            soundEffect("reactions_popup")
            scrollViewEmoji.frame.origin.x = tapLocation.x
            scrollViewEmoji.frame.origin.y = tapLocation.y - 50
            //Do Whatever You want on Began of Gesture
            scrollViewEmoji.alpha = 0
            scrollViewEmoji.isHidden = false
            scrollViewEmoji.tag =  Currentcell
            view.addSubview(scrollViewEmoji)
            UIView.animate(withDuration: 0.5, delay: 0.4, options: .curveEaseOut, animations: {
                scrollViewEmoji.alpha = 1
            }, completion: nil)
            
        }
        
    }
    
    func removeEmoji(recognizer: UITapGestureRecognizer){
        scrollViewEmoji.isHidden = true
        mainView.removeGestureRecognizer(recognizer)
        
    }
    
    func updateReaction(url : String,reaction : String,action_id : Int,updateMyReaction : NSDictionary,feedIndex: Int){
        scrollViewEmoji.isHidden = true
        if reachability.isReachable {
            removeAlert()
            let feed = globalArrayFeed[feedIndex] as! NSDictionary
            let tempLike1 = feed["is_like"] as! Bool
            var dic = Dictionary<String, String>()
            dic["reaction"] = "\(reaction)"
            dic["action_id"] = "\(action_id)"
            if(tempLike1 == true){
                
                dic["sendNotification"] = "\(1)"
            }
            else
            {
                dic["sendNotification"] = "\(0)"
            }
            
            userInteractionOff = false
            // Send Server Request to Update Feed Gutter Menu
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    
                    
                    if msg{
                        // On Success Update Feed Gutter Menu
                        let feed = self.globalArrayFeed[feedIndex] as! NSDictionary
                        var url = ""
                        url = "advancedactivity/send-like-notitfication"
                        var dict = Dictionary<String, String>()
                        dict["action_id"] = "\(action_id)"
                        // call notificatiom
                        if reachability.isReachable {
                            removeAlert()
                            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                                DispatchQueue.main.async(execute:{
                                    userInteractionOff = true
                                    
                                })
                            }
                        }
                        else
                        {

                            UIApplication.shared.keyWindow?.makeToast(network_status_msg, duration: 5, position: "bottom")
                        }
                        // call notification
                        
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
                            
                            addDictionary = false
                            newDictionary["is_like"] = true
                            newDictionary["likes_count"] = ((feed["likes_count"] as? Int)!+1)
                            newDictionary["my_feed_reaction"] = updateMyReaction
                            if newDictionary["feed_Type"] as! String != "share"
                            {
                                if newDictionary["attachment"] != nil
                                {
                                    var dic:NSMutableDictionary = [:]
                                    let array = newDictionary["attachment"] as! NSMutableArray
                                    dic = array[0] as! NSMutableDictionary
                                    if dic["is_like"] != nil
                                    {
                                        dic["is_like"] = true
                                    }
                                    if dic["likes_count"] != nil
                                    {
                                        dic["likes_count"] = ((dic["likes_count"] as? Int)!+1)
                                    }
                                    array.removeObject(at: 0)
                                    array.add(dic)
                                    newDictionary["attachment"] = array
                                    
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
                         newDictionary["feed_reactions"] = changedDictionary
                        
                        self.globalArrayFeed[feedIndex] = newDictionary
                        
                        self.tableView.reloadData()
                        
                    }
                    
                })
                
            }
            
        }
        else
        {
            
            UIApplication.shared.keyWindow?.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    
    func deleteReaction(url : String,reaction : String,action_id : Int,updateMyReaction : NSDictionary,feedIndex: Int)
    {
        scrollViewEmoji.isHidden = true
        if reachability.isReachable
        {
            removeAlert()
            
            var dic = Dictionary<String, String>()
            dic["reaction"] = "\(reaction)"
            dic["action_id"] = "\(action_id)"
            userInteractionOff = false
            // Send Server Request to Update Feed Gutter Menu
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    if msg
                    {
                        // On Success Update Feed Gutter Menu
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
                                if newDictionary["attachment"] != nil
                                {
                                    var dic:NSMutableDictionary = [:]
                                    let array = newDictionary["attachment"] as! NSMutableArray
                                    dic = array[0] as! NSMutableDictionary
                                    if dic["is_like"] != nil
                                    {
                                        dic["is_like"] = false
                                    }
                                    if dic["likes_count"] != nil
                                    {
                                        dic["likes_count"] = ((dic["likes_count"] as? Int)!-1)
                                    }
                                    array.removeObject(at: 0)
                                    array.add(dic)
                                    newDictionary["attachment"] = array
                                    
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
                        self.globalArrayFeed[feedIndex] = newDictionary
                        self.tableView.reloadData()
                        
                    }
                    
                })
                
            }
            
        }
        else
        {
            // No Internet Connection Message
            UIApplication.shared.keyWindow?.makeToast(network_status_msg, duration: 5, position: "bottom")
            
        }
        
        
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
            createTimer(self)
        }
    }
    
    // Stop Timer for remove Alert
    func stopTimer() {
        stop()
        if popAfterDelay == true {
            _ = self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    func seeAllSuggestions(_ sender: UIButton){
        
        let vc = SuggestionsBrowseViewController()
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    func removeSuggestionItem(_ sender: UIButton) {
        let suggestionIndex = sender.tag - 555
        let updateRow = IndexPath(row: suggestionSlideshowPosition - 1, section: 0)
        
        let selectedSuggestion = self.userSuggestions[suggestionIndex] as! NSDictionary
        
        let suggestedUserId = selectedSuggestion["user_id"]
        
        if reachability.isReachable{
            
            let parameters = ["limit":"2", "restapilocation": "", "user_id": "\(suggestedUserId!)"]
            
            let url = "suggestions/remove"
            
            spinner.startAnimating()
            post(parameters , url: url, method: "POST", postCompleted: { (succeeded, msg) in
                DispatchQueue.main.async(execute: {
                    if msg{
                        spinner.stopAnimating()
                        self.userSuggestions.remove(at: suggestionIndex)
                        self.tableView.beginUpdates()
                        self.tableView.reloadRows(at: [updateRow], with: UITableViewRowAnimation.automatic)
                        self.tableView.endUpdates()
                        
                        if suggestionIndex == self.userSuggestions.count{
                            self.tableView.reloadData()
                        }
                    }else{
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            UIApplication.shared.keyWindow?.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                    }
                })
                
            })
        }
    }
    
    func addFriendSuggestion(_ sender: UIButton) {
        let suggestionIndex = sender.tag - 555
        let updateRow = IndexPath(row: suggestionSlideshowPosition-1, section: 0)
        
        let selectedSuggestion = self.userSuggestions[suggestionIndex] as! NSDictionary
        
        let suggestedUserId = selectedSuggestion["user_id"]
        
        let userAction = selectedSuggestion["friendship_type"] as! String
        
        if reachability.isReachable{
            
            let parameters = ["user_id": "\(suggestedUserId!)"]
            
            var url = "user/add"
            if userAction == "cancel_request"{
                url = "user/cancel"
            }
            spinner.startAnimating()
            post(parameters , url: url, method: "POST", postCompleted: { (succeeded, msg) in
                DispatchQueue.main.async(execute: {
                    if msg{
                        spinner.stopAnimating()
                        
                        if userAction == "cancel_request"{
                            selectedSuggestion.setValue("add_friend", forKey: "friendship_type")
                        }else{
                            selectedSuggestion.setValue("cancel_request", forKey: "friendship_type")
                        }
                        self.userSuggestions[suggestionIndex] = selectedSuggestion
                        self.tableView.beginUpdates()
                        self.tableView.reloadRows(at: [updateRow], with: UITableViewRowAnimation.automatic)
                        self.tableView.endUpdates()
                        
                    }else{
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            UIApplication.shared.keyWindow?.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                    }
                })
                
            })
        }
        
    }

    func suggestionProfile(_ sender: UIButton){
        let userId = sender.tag - 666
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = userId
        presentedVC.fromActivity = false
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
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
            for i in 0 ..< attachmentArray.count
            {
                if let feed = attachmentArray[i] as? NSDictionary{
                    if let dic = feed["image_medium"] as? String{
                        imageUrlArray.append(dic)
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
        return newDictionary
    }
}
