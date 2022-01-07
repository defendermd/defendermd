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
//  MLTClassifiedAdvancedTypeViewController.swift
//  seiosnativeapp
//

import UIKit
import NVActivityIndicatorView

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

var profileFields : NSDictionary!
class MLTClassifiedAdvancedTypeViewController: UIViewController , TTTAttributedLabelDelegate ,UITableViewDelegate,UIScrollViewDelegate, UITextViewDelegate , UITabBarControllerDelegate{
    
    var productMoreOrLess : UIButton!
    var productMoreOrLessView :UIView!
    var RedirectText : String!
    var listingTitle:String!
    var like_comment = UIView()
    var lastContentOffset: CGFloat = 0
    var listingId = ""
    var listingTypeId :  Int!
    var subjectId:Int = 0                         // For use Activity Feed updates in Other Modules
    var subjectType:String = ""                   // For use Activity Feed updates in Other Modules
    var showSpinner = true                      // show spinner flag for pull to refresh
    var refresher:UIRefreshControl!             // Refresher for Pull to Refresh
    var maxid:Int!                              // MaxID for Pagination
    var minid:Int!                              // MinID for New Feeds
    var myTimer:Timer!                        // Timer for Update feed after particular time repeation
    var dynamicHeight:CGFloat = 44              // Defalut Dynamic Height for each Row
    var updateScrollFlag = true                 // Flag for Pagination by ScrollView Delegate
    var deleteFeed = false                      // Flag for Delete Feed Updation
    var feedFilter: UIButton!                   // Feed Filter Option
    var activityFeeds:[ActivityFeed] = []       // To save Activity Feeds from Response (subclass of ActivityFeed)
    var menuOptionSelected:String!              // Set Option Selected for Feed Gutter Menu
    var tempcontentFeedArray = [Int:AnyObject]()       // Hold TemproraryFeedMenu for Hide Row (Undo, HideAll)
    var feed_filter = 1                         // Set Value for Feed Filter options in browse Feed Request to get feed_filter in response
    var feedFilterFlag = false                  // Flag to merge Feed Filter Params in browse Feed Request
    var fullDescriptionCell = [Int]()           // Contain Array of all cell to show full description
    var dynamicRowHeight = [Int:CGFloat]()      // Save table Dynamic RowHeight
    var groupDescriptionView : TTTAttributedLabel!
    var shareDescription : String!
    var coverImageUrl : String! = ""
    var mainSubView:UIView!
    var coverImage:UIImageView!
    var contentName:UILabel!
    var extraMenuLeft:UIButton!
    var extraMenuRight:UIButton!
    var tabsContainerMenu:UIScrollView!
    var headerHeight:CGFloat = 0
    var categoryMember : TTTAttributedLabel!
    var detailWebView : UITextView!
    var maxHeight : CGFloat!
    var contentTitle : String!
    var shareTitle:String!
    var imageScrollView: UIScrollView!
    var joinlabel : UILabel!
    var navBarTitle : UILabel!
    var user_id : Int!
    var descriptionGroupCompleteContent : String!
    var ownerName : UILabel!
    let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
    let offset_B_LabelHeader:CGFloat = 320.0 // At this offset the Black label reaches the Header
    let distance_W_LabelHeader:CGFloat = 100.0 // The distance between the bottom of the Header and the top of the White Label
    var contentview : UIView!
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
    var isJobApplied = false
    var imgUser: UIImageView!
    var shareUrl : String!
    var applyUrl : String!
    var showApplyButton : Bool! = false
    var applyButton : UIButton!
    var shareParam : NSDictionary!
    var info : UILabel!
    var canInviteEventOrGroup = false
    var toastView : UIView!
    var UserId:Int!
   // var imageCache = [String:UIImage]()
    var titleshow :Bool  = false
    var titleHeight:CGFloat = 0
    var temptitleInfo : String = ""
    var action_id:Int!
    var actionIdArray = [Int]()
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
    var priceValue : Double!
    var priceTextField : UITextField!
    var currencySymbol = ""
    var marqueeHeader : MarqueeLabel!
    var webviewText : String!
    var rightBarButtonItem : UIBarButtonItem!
    var leftBarButtonItem : UIBarButtonItem!
    var contentUrl = ""
    let subscriptionNoticeLinkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.gray,
        // NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    let subscriptionNoticeActiveLinkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.80),
        //NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    
    var mltProfileTabMenu: NSArray = []
    var feedObj = FeedTableViewController()
    
    var memberProfilePhoto:UIImageView!
    var userCoverPicUrl : String!
    var topMainView : UIView!
    var contentSelection : UIButton!
    var profilePhotoMenu: NSArray = []
    var coverPhotoMenu: NSArray = []
    var imageMenus: NSArray = []
    var profileOrCoverChange: Bool!
    var camIconOnCover: UILabel!
    var camIconOnProfile: UILabel!
    var userProfilePicUrl : String!
    var coverValue : Int! = 0
    var profileValue : Int! = 0
    private var dismissEmojiView: UITapGestureRecognizer?
    override func viewDidLoad() {
        super.viewDidLoad()
        Messag_Owner = false
        tableViewFrameType = "MLTClassifiedAdvancedTypeViewController"
        view.backgroundColor = UIColor.white
        //listingUpdate = false
        // self.title = listingName
        listingDetailUpdate = true
        deleteListingEntry = false
        contentFeedArray.removeAll(keepingCapacity: false)
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MLTClassifiedAdvancedTypeViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        self.tabBarController?.delegate = self
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        // Initial table to show Activity Feeds
        feedObj.willMove(toParent: self)
        self.view.addSubview(feedObj.view)
        self.addChild(feedObj)
        
        
        navBarTitle = createLabel(CGRect(x: 0,y: 0,width: view.bounds.width,height: TOPPADING), text: "", alignment: .center, textColor: textColorLight)
        
        navBarTitle.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        feedObj.tableView.addSubview(navBarTitle)
        navBarTitle.isHidden = true
        
        self.navigationItem.rightBarButtonItem = nil
        removeNavigationImage(controller: self)
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            mainSubView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 370), borderColor: borderColorLight, shadow: false)
            mainSubView.layer.borderWidth = 0.0
            coverImage =   CoverImageViewWithGradient(frame:CGRect(x: 0, y: 0, width: mainSubView.bounds.width, height: 370))
            imageScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.bounds.width,height: 370))
        }else{
            mainSubView = createView(CGRect(x: 0,y: 0, width: view.bounds.width, height: 270), borderColor: borderColorLight, shadow: false)
            mainSubView.layer.borderWidth = 0.0
            
            coverImage =   CoverImageViewWithGradient(frame:CGRect(x: 0, y: 0, width: mainSubView.bounds.width, height: 270))
            imageScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: view.bounds.width,height: 270))
        }
        //        mainSubView.isHidden = true
        mainSubView.backgroundColor = tableViewBgColor //UIColor(red: 240/255.0, green: 240/255.0, blue: 240/255.0, alpha: 1.0)//aafBgColor//placeholderColor
        feedObj.tableView.addSubview(mainSubView)
        coverImage.contentMode = UIView.ContentMode.scaleAspectFill
        coverImage.layer.masksToBounds = true
        coverImage.backgroundColor = placeholderColor
        coverImage.tag = 123
        coverImage.isUserInteractionEnabled = true
        mainSubView.addSubview(coverImage)
        
        imageScrollView.delegate = self
        imageScrollView.backgroundColor = placeholderColor
        imageScrollView.showsHorizontalScrollIndicator = false
        mainSubView.addSubview(imageScrollView)
        
        totalPic = TTTAttributedLabel(frame:CGRect(x: view.bounds.width-45, y: 100 ,width: 45, height: 50) )
        totalPic.numberOfLines = 0
        
        totalPic.textColor = textColorLight
        totalPic.backgroundColor = UIColor.clear
        totalPic.delegate = self
        totalPic.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
        totalPic.layer.shadowColor = shadowColor.cgColor
        totalPic.layer.shadowOpacity = shadowOpacity
        totalPic.layer.shadowRadius = shadowRadius
        totalPic.layer.shadowOffset = shadowOffset
        mainSubView.addSubview(totalPic)
        totalPic.isHidden = true
        
        
        contentName = createLabel(CGRect(x: contentPADING, y: 230, width: mainSubView.bounds.width - (2 * contentPADING), height: 40), text: "", alignment: .left, textColor: textColorLight)
        contentName.font = UIFont(name: fontBold, size: 30)
        contentName.numberOfLines = 3
        contentName.longPressLabel()
        contentName.layer.shadowColor = shadowColor.cgColor
        contentName.layer.shadowOpacity = shadowOpacity
        contentName.layer.shadowRadius = shadowRadius
        contentName.layer.shadowOffset = shadowOffset
        mainSubView.addSubview(contentName)
        
        topView = createView(CGRect(x: 0, y: coverImage.bounds.height, width: view.bounds.width, height: 70), borderColor: UIColor.clear, shadow: false)
        topView.backgroundColor = lightBgColor
        mainSubView.addSubview(topView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MLTClassifiedAdvancedTypeViewController.openProfile))
        topView.addGestureRecognizer(tap)
        
        priceTextField = createTextField(CGRect(x: view.bounds.width - 100, y: 25, width: 90, height: 20), borderColor: textColorDark, placeHolderText: "", corner: false)
        
        priceTextField.backgroundColor = textColorDark
        priceTextField.isHidden = true
        topView.addSubview(priceTextField)
        
        priceLabel = createLabel(CGRect(x: view.bounds.width - 110, y: 20, width: 10, height: 30), text: "", alignment: .left, textColor: textColorDark)
        topView.addSubview(priceLabel)
        
        ownerName = createLabel(CGRect(x: 65, y: 20, width: view.bounds.width - 70, height: 30), text: "", alignment: .left, textColor: textColorDark)
        ownerName.font = UIFont(name: fontName, size: FONTSIZEMedium)
        ownerName.lineBreakMode =  NSLineBreakMode.byTruncatingTail
        topView.addSubview(ownerName)
        
        imgUser = createImageView(CGRect(x: 10, y: 10, width: 50, height: 50), border: true)
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.clear.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.clipsToBounds = true
        imgUser.image = UIImage(named: "user_profile_image.png")
        topView.addSubview(imgUser)
        
        
        
        
        detailWebView = createTextView(CGRect(x: PADING,y: mainSubView.bounds.height+70 , width: view.bounds.width - 2 * PADING, height: 10), borderColor: borderColorMedium, corner: false )
        detailWebView.backgroundColor = bgColor
        detailWebView.isUserInteractionEnabled = true
        detailWebView.isScrollEnabled = false
        detailWebView.isEditable = false
        detailWebView.delegate = self
        detailWebView.text = NSLocalizedString("",  comment: "")
        detailWebView.font = UIFont(name: fontName, size: FONTSIZENormal)
        detailWebView.textColor = textColorDark
        detailWebView.layer.borderWidth = 0.0
        detailWebView.isHidden = true
        detailWebView.showsVerticalScrollIndicator = false
        //detailWebView.autocorrectionType = UITextAutocorrectionType.No
        mainSubView.addSubview(detailWebView)
        
        productMoreOrLessView = createView(CGRect(x: PADING, y: detailWebView.frame.size.height + detailWebView.frame.origin.y ,  width: view.bounds.width - 2 * PADING, height: 30), borderColor: UIColor.white, shadow: false)
        productMoreOrLessView.isHidden = true
        productMoreOrLessView.backgroundColor = UIColor.white
        mainSubView.addSubview(productMoreOrLessView)
        
        
        productMoreOrLess = createButton(CGRect(x: self.view.bounds.width - 50, y: 0 ,  width: 40, height: 30), title: "More", border: false,bgColor: false, textColor: navColor)
        productMoreOrLess.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        productMoreOrLess.isHidden = true
        productMoreOrLess.addTarget(self, action: #selector(MLTClassifiedAdvancedTypeViewController.showFeedFilterOptions), for: .touchUpInside)
        
        productMoreOrLessView.addSubview(productMoreOrLess)
        label1 = TTTAttributedLabel(frame:CGRect(x: PADING,y: 10,width: self.mainSubView.bounds.width/2 - PADING , height: 30) )
        label3 = TTTAttributedLabel(frame:CGRect(x: PADING,y: 10,width: self.mainSubView.bounds.width/2 - PADING , height: 30) )
        label1.isHidden = true
        label3.isHidden = true
        
        profileView.addSubview(label1)
        profileView.addSubview(label3)
        
        profileFieldLabel = TTTAttributedLabel(frame:CGRect(x: PADING + contentPADING + 10 , y: 300  , width: view.bounds.width - (PADING + contentPADING + 10) , height: 1000) )
        profileFieldLabel.numberOfLines = 0
        profileFieldLabel.textColor = textColorMedium
        profileFieldLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        profileFieldLabel.longPressLabel()
        profileFieldLabel.layer.borderColor = navColor.cgColor
        profileFieldLabel.delegate = self
        mainSubView.addSubview(profileFieldLabel)
        profileFieldLabel.isHidden = true
        
        
        applyButton = createButton(CGRect(x: 20, y: self.headerHeight + 5, width: view.bounds.width-40, height: 0), title: "Apply Now", border: false, bgColor: true, textColor: textColorPrime)
        applyButton.layer.cornerRadius = 5.0
        applyButton.isHidden = true
        feedObj.tableView.addSubview(applyButton)
        //mainSubView.addSubview(applyButton)
        
        addWishList = createButton(CGRect(x: self.mainSubView.bounds.width/2, y: applyButton.frame.size.height+applyButton.frame.origin.y+5, width: self.mainSubView.bounds.width/2-10, height: ButtonHeight-PADING), title: "", border: false,bgColor: false, textColor: textColorPrime)
        addWishList.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        addWishList.isHidden = true
        
        addWishList.addTarget(self, action: #selector(MLTClassifiedAdvancedTypeViewController.performReviewOrWishlistAction(_:)), for: .touchUpInside)
        feedObj.tableView.addSubview(addWishList)
        
        
        tabsContainerMenu = UIScrollView(frame: CGRect(x: PADING, y: 350,width: view.bounds.width-2*PADING ,height: ButtonHeight ))
        tabsContainerMenu.backgroundColor = TabMenubgColor
        tabsContainerMenu.isHidden = true
        tabsContainerMenu.showsHorizontalScrollIndicator = false
        feedObj.tableView.addSubview(tabsContainerMenu)
        
        feedFilter = createButton(CGRect(x: PADING, y: 2*contentPADING , width: view.bounds.width - 2 * PADING, height: ButtonHeight),title: NSLocalizedString("Everyone",  comment: "") , border: false, bgColor: false,textColor: textColorMedium)
        feedFilter.isEnabled = false
        feedFilter.backgroundColor = lightBgColor
        feedFilter.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        feedFilter.isHidden = true
        feedFilter.addTarget(self, action: #selector(MLTClassifiedAdvancedTypeViewController.showFeedFilterOption(_:)), for: .touchUpInside)
        feedObj.tableView.addSubview(feedFilter)
        
        // Filter Icon on Left site
        let filterIcon = createLabel(CGRect(x: feedFilter.bounds.width - feedFilter.bounds.height, y: 0 ,width: feedFilter.bounds.height ,height: feedFilter.bounds.height), text: "\(searchFilterIcon)", alignment: .center, textColor: textColorMedium)
        filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        feedFilter.addSubview(filterIcon)
        
        
        // Initialize Pull to Refresh to ActivityFeed Table
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(MLTClassifiedAdvancedTypeViewController.refresh), for: UIControl.Event.valueChanged)
        feedObj.tableView.addSubview(refresher)
        
        // Cover Photo and Profile Photo
        
        camIconOnCover = createLabel(CGRect(x: coverImage.bounds.width - 30, y: coverImage.bounds.height - 30, width: 20, height: 20), text: "\(cameraIcon)", alignment: .center, textColor: textColorLight)
        camIconOnCover.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        camIconOnCover.isHidden = true
        mainSubView.addSubview(camIconOnCover)
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            memberProfilePhoto = createImageView(CGRect(x: 20, y: coverImage.bounds.height - (2 * contentPADING) - 100, width: 100, height: 100 ), border: true)
        }else{
            memberProfilePhoto = createImageView(CGRect(x: 10, y: coverImage.bounds.height - (2 * contentPADING) - 80, width: 80, height: 80), border: true)
        }
        
        memberProfilePhoto.layer.borderColor = UIColor.white.cgColor
        memberProfilePhoto.layer.borderWidth = 2.5
        memberProfilePhoto.layer.cornerRadius = memberProfilePhoto.frame.size.width / 2
        memberProfilePhoto.backgroundColor = placeholderColor
        memberProfilePhoto.contentMode = UIView.ContentMode.scaleAspectFill
        memberProfilePhoto.layer.masksToBounds = true
        memberProfilePhoto.image = UIImage(named: "user_profile_image.png")
        memberProfilePhoto.tag = 321
        memberProfilePhoto.isUserInteractionEnabled = true
        
        mainSubView.addSubview(memberProfilePhoto)
        
        memberProfilePhoto.isHidden = true
        
        camIconOnProfile = createLabel(CGRect(x: (memberProfilePhoto.bounds.width/2) - 15, y: memberProfilePhoto.bounds.height - 30, width: 30, height: 30), text: "\(cameraIcon)", alignment: .center, textColor: textColorLight)
        camIconOnProfile.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        
        camIconOnProfile.layer.shadowColor = shadowColor.cgColor
        camIconOnProfile.layer.shadowOpacity = shadowOpacity
        camIconOnProfile.layer.shadowRadius = shadowRadius
        camIconOnProfile.layer.shadowOffset = shadowOffset
        camIconOnProfile.isHidden = true
        memberProfilePhoto.addSubview(camIconOnProfile)

        // Do any additional setup after loading the view.
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        feedObj.tableView.tableFooterView = footerView
        feedObj.tableView.tableFooterView?.isHidden = true
        
        dismissEmojiView = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        
        if let tap = dismissEmojiView {
            
            view.addGestureRecognizer(tap)
            
        }

    }
    
    @objc private func dismissView() {
       
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        
        //view.removeGestureRecognizer(tap)
        
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        self.browseEmoji(contentItems: reactionsDictionary)
        //  updateAfterAlert = false
        tableViewFrameType = "MLTClassifiedAdvancedTypeViewController"
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.alpha = 1
        NotificationCenter.default.addObserver(self, selector: #selector(MLTClassifiedAdvancedTypeViewController.ScrollingactionMLTClassifiedAdvancedType(_:)), name: NSNotification.Name(rawValue: "ScrollingactionMLTClassifiedAdvancedType"), object: nil)
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        removeNavigationImage(controller: self)
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
        }
        subject_unique_id = "\(listingId)"
        subject_unique_type = "sitereview_listing"
        
        let allviews = view.subviews
        for obj in allviews
        {
            if obj .isKind(of: Like_CommentView.self)
            {
                obj.removeFromSuperview()
            }
        }
        
        if listingDetailUpdate == true{
            listingTypeId_global = listingTypeId
            IsRedirctToVideoProfile(videoTypeCheck : "listings",navigationController:navigationController!, vc: self)
            // Set Default & request to hard Refresh
            listingDetailUpdate = false
            feedUpdate = false
            maxid = 0
            maxidTikTok = 0
            profileView = createView(CGRect(x: PADING, y: 350, width: view.bounds.width - 2 * PADING, height: 100), borderColor: borderColorDark, shadow: false)
            profileView.layer.borderWidth = 0.0
            // profileView.backgroundColor = UIColor.white
            mainSubView.addSubview(profileView)
            
            profileView.isHidden = true
            label1.isHidden = true
            label3.isHidden = true
            profileView.isHidden = true
            
            showSpinner = true
            feed_filter = 1
            exploreContent()
        }
        else{
            // Reload TableView without Hard Refresh
            if logoutUser == false
            {
                globalFeedHeight = feedFilter.frame.origin.y + ButtonHeight + 10  + 3
            }
            else
            {
                globalFeedHeight = feedFilter.frame.origin.y + ButtonHeight + 10
            }
            self.feedObj.globalArrayFeed = contentFeedArray
            if !fromExternalWebView{
                self.feedObj.refreshLikeUnLike = true
                feedObj.tableView.reloadData()
            }else{
                fromExternalWebView = false
            }
        }
        
        self.view.addSubview(self.like_comment)
        
        maxidTikTok = 0
        API_getAAFList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        feedObj.tableView.tableFooterView?.isHidden = true
        tableViewFrameType = ""
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        self.navigationItem.rightBarButtonItem = nil
        setNavigationImage(controller: self)
        self.navigationController?.navigationBar.alpha = 1
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func shareItem(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        alertController.addAction(UIAlertAction(title:  String(format: NSLocalizedString("Share on %@", comment: ""),app_title), style: .default) { action -> Void in
            let presentedVC = AdvanceShareViewController()
            presentedVC.param = self.shareParam as! [AnyHashable : Any] as NSDictionary
            presentedVC.url = self.shareUrl
            presentedVC.Sharetitle = self.shareTitle
            if (self.RedirectText != nil) {
                presentedVC.ShareDescription = self.RedirectText
            }
            if self.coverImageUrl != nil && self.coverImageUrl != ""{
                presentedVC.imageString = self.coverImageUrl
            }
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:true, completion: nil)
        })
        
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share Outside",comment: ""), style: UIAlertAction.Style.default) { action -> Void in
            
            var sharingItems = [AnyObject]()
            
            sharingItems.append(self.contentUrl as AnyObject)
          
            let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                
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
                presentationController?.sourceRect = CGRect(x: self.view.bounds.width/2 , y: self.view.bounds.width/2, width: 0, height: 0)
                presentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                
            }
            
            self.present(activityViewController, animated: true, completion: nil)
            
        })
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = self.view
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    @objc func showFeedFilterOptions(){
        if self.detailWebView != nil{
            let presentedVC = MLTInfoViewController()
            presentedVC.label1 = self.RedirectText
            navigationController?.pushViewController(presentedVC, animated: true)
            
        }
    }
    
    // MARK: - Activity Feed Filter Options & Gutter Menu
    
    // Show Feed Filter Options Action
    @objc func showFeedFilterOption(_ sender: UIButton){
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        //      if logoutUser != true {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        
        for menu in filterGutterMenu{
            if let dic = menu as? NSDictionary{
                alertController.addAction(UIAlertAction(title: (dic["tab_title"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                    // Set Feed Filter Option Title
                    self.feedFilter.setTitle((dic["tab_title"] as! String), for: UIControl.State())
                    self.feedFilterFlag = true
                    
                    // Set Parameters for Feed Filter
                    if let params = dic["urlParams"] as? NSDictionary{
                        for (key, value) in params{
                            if let id = value as? NSNumber {
                                searchDic["\(key)"] = String(id as! Int)
                            }
                            
                            if let receiver = value as? NSString {
                                searchDic["\(key)"] = receiver as String
                            }
                        }
                    }
                    
                    // Make Hard Refresh request for selected Feed Filter & Reset all VAriable
                    contentFeedArray.removeAll(keepingCapacity: false)
                    self.dynamicRowHeight.removeAll(keepingCapacity: false)
                    self.maxid = 0
                    maxidTikTok = 0
                    self.feed_filter = 1
                     self.showSpinner = true
                    self.browseFeed()
                    
                }))
            }
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height - (self.feedFilter.frame.origin.y+self.feedFilter.frame.size.height + TOPPADING), y: view.bounds.width/2, width: 0, height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        self.present(alertController, animated:true, completion: nil)
        //        }
    }
    
    @objc func openProfile(){
        if (self.user_id != nil){
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(user_id!)"
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    @objc func onImageViewTap(_ sender:UITapGestureRecognizer)
    {
        
        let totalClassifiedImageDic = self.totalClassifiedImage[sender.view!.tag] as! NSDictionary
        let imageString = totalClassifiedImageDic["image"] as? String
        let presentedVC = AdvancePhotoViewController()  
        presentedVC.allphotos = allPhotos
        presentedVC.photoID = sender.view!.tag
        presentedVC.imageUrl = imageString
        presentedVC.photoType = "sitereview_photo"
        presentedVC.photoForViewer = photos
        presentedVC.total_items = self.totalPhoto
        presentedVC.notShowComment = true
        presentedVC.listingTypeId = listingTypeId
        presentedVC.url = "/listings/photo/" + String(cId)
        presentedVC.attachmentID = "\(totalClassifiedImageDic["album_id"]!)"
        self.navigationController?.pushViewController(presentedVC, animated: false)

    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true
        {
            _ = self.navigationController?.popViewController(animated: false)
        }
        
    }
    
    func exploreContent(){
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

            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["listingtype_id": String(listingTypeId), "gutter_menu": "1"], url: "listing/view/" + String(listingId), method: "GET") { (succeeded, msg) -> () in
                
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Blog Detail
                        
                        if let listing = succeeded["body"] as? NSDictionary {
                            if let sitevideoPluginEnabled = listing["sitevideoPluginEnabled"] as? Int
                            {
                                sitevideoPluginEnabled_mlt = sitevideoPluginEnabled
                            }
                            if let content_url = listing["content_url"] as? String {
                                self.contentUrl = content_url
                            }
                            if let menu = listing["gutterMenu"] as? NSArray{
                                self.gutterMenu  = menu  as NSArray
                                self.wishlistGutterMenu = menu  as NSArray
                                
                                if let owner_id = listing["owner_id"] as? Int{
                                    self.user_id = owner_id
                                    Messag_OwnerId = owner_id
                                }
                                if logoutUser == false {
                                if let applyjob = listing["isApplyJob"] as? Int
                                {
                                    self.showApplyButton = true
                                    if applyjob == 1
                                    {
                                        self.isJobApplied = true
                                    }
                                    else
                                    {
                                        self.applyButton.alpha = 1.0
                                    }
                                }
                                }
                                
                                var isCancel = false
                                
                                for tempMenu in self.gutterMenu{
                                    if let tempDic = tempMenu as? NSDictionary{
                                        
                                        if tempDic["name"] as! String == "messageowner" {
                                            Messag_Owner = true
                                            if let url = tempDic["url"] as? String {
                                                Messag_Url = url
                                            }
                                        }
                                        
                                        if tempDic["name"] as! String == "share" {
                                            self.shareUrl = tempDic["url"] as! String
                                            self.shareParam = tempDic["urlParams"] as! NSDictionary
                                        }
                                        else
                                        {
                                            isCancel = true
                                        }
                                        if tempDic["name"] as! String == "apply-now"
                                        {
                                            if let url = tempDic["url"] as? String
                                            {
                                                self.applyUrl = url
                                                self.showApplyButton = true
                                            }
                                        }
                                        
                                    }
                                }
                                
                                likeCommentContent_id = "\(self.listingId)"
                                likeCommentContentType = "sitereview_listing"
                                like_CommentStyle = 1
                                self.like_comment = Like_CommentView()
                                self.like_comment.alpha = 1
                                self.like_comment.layer.shadowColor = shadowColor.cgColor
                                self.like_comment.layer.shadowOffset = shadowOffset
                                self.like_comment.layer.shadowRadius = shadowRadius
                                self.like_comment.layer.shadowOpacity = shadowOpacity
                                //like_comment.backgroundColor = UIColor.black
                                self.view.addSubview(self.like_comment)
                                
                                if logoutUser == false{
                                    
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")!.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    shareButton.addTarget(self, action: #selector(MLTClassifiedAdvancedTypeViewController.shareItem), for: .touchUpInside)
                                    rightNavView.addSubview(shareButton)
                                    
                                    let optionButton = createButton(CGRect(x: 22,y: 0,width: 45,height: 45), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")!.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    optionButton.addTarget(self, action: #selector(MLTClassifiedAdvancedTypeViewController.showGutterMenu), for: .touchUpInside)
                                   // rightNavView.addSubview(optionButton)
                                    if isCancel == false
                                    {
                                        shareButton.frame.origin.x = 44
                                    }
                                    else
                                    {
                                        rightNavView.addSubview(optionButton)
                                    }
                                    self.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
                                    
                                    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                                }
                                
                            }
                            
                            var profileFieldString = ""
                            var profileFieldString2 = ""
                            
                            // Update  tabContainer Menu
                            if let tabsContainerMenuItems = listing["profile_tabs"] as? NSArray
                            {
                                self.mltProfileTabMenu = tabsContainerMenuItems
                                self.tabsContainerMenu.isHidden = false
                            }
                            
                            let response = listing
                            if response.count > 0 {
                                
                                // set Blog Title
                                self.shareTitle = response["title"] as? String
                                self.priceValue = response["price"] as? Double
                                if response["currency"] != nil {
                                self.currencySymbol = getCurrencySymbol(response["currency"] as! String)
                                }
                                let a  = findWidthByText("\(self.currencySymbol) \(self.priceValue)")
                                
                                let price = response["price"] as? Int
                                if price > 0  {
                                    
                                    let icon = "\u{f0d9}"
                                    // self.priceTextField.isHidden = false
                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                        let defaults = UserDefaults.standard
                                        if let name = defaults.object(forKey: "Currency")
                                        {
                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price!)
                                            let showPrice = (String(format:"%.2f", changePrice))
                                            
                                            self.priceTextField.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                            
                                        }
                                    }
                                    else{
                                    self.priceTextField.text = "\(self.currencySymbol)" + String(self.priceValue)
                                    }
                                    self.priceTextField.frame.origin.x = self.view.bounds.width - ( a + 10)
                                    self.priceLabel.frame.origin.x = self.view.bounds.width - ( a + 19.5)
                                    self.priceTextField.frame.size.width = a + 10
                                    
                                    self.ownerName.frame.size.width = self.view.bounds.width - (65 + a + 20)
                                    self.priceTextField.textColor  = UIColor.white
                                    
                                    self.priceLabel.text  = "\(icon)"
                                    self.priceLabel.isHidden = true
                                    self.priceLabel.font = UIFont(name: "FontAwesome", size: 40)
                                    self.priceTextField.font = UIFont(name: "FontAwesome", size: 14)
                                    
                                }
                                if let _ : Int = response["default_cover"] as? Int{
                                    
                        
                                    self.imageScrollView.isHidden = true
                                    
                                    let tap1 = UITapGestureRecognizer(target: self, action: #selector(MLTClassifiedAdvancedTypeViewController.showProfileCoverImageMenu(_:)))
                                    self.coverImage.addGestureRecognizer(tap1)
                                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(MLTClassifiedAdvancedTypeViewController.showProfileCoverImageMenu(_:)))
                                    self.memberProfilePhoto.addGestureRecognizer(tap2)
                                    
                                    if let cover : Int = response["default_cover"] as? Int{
                                        
                                        if (response["cover_image"] as? String) != nil{
                                            
                                            
                                            if cover == 1{
                                                self.coverValue = 0
                                            }
                                            else{
                                                self.coverValue = 1
                                            }
                                        }
                                        else{
                                            self.coverValue = cover
                                        }
                                        
                                    }

                                    
                                  self.contentName.text = response["title"] as? String
                                    if let _ = response["title"] as? String{
                                        self.contentTitle = (response["title"] as? String)!
                                        self.contentName.font = UIFont(name: fontBold, size: 27)
                                        self.contentName.frame.origin.x = self.memberProfilePhoto.bounds.width + 15
                                        self.contentName.frame.size.width = self.coverImage.bounds.width - (self.memberProfilePhoto.bounds.width + 15)
                                        self.contentName.frame.origin.y = self.coverImage.bounds.height-60
                                        if self.contentTitle.length > 15{
                                            self.contentName.frame.origin.y = self.coverImage.bounds.height-70
                                        }

                                        if self.contentTitle.length > 22{
                                            self.contentName.frame.origin.y = self.coverImage.bounds.height-90
                                        }
                                        if self.contentTitle.length > 45{
                                            self.contentName.frame.origin.y = self.coverImage.bounds.height-120
                                        }
                                    }
                                    

                                    
                                    self.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
                                    self.contentName.sizeToFit()
                                    
                                    self.contentName.frame.origin.y = self.coverImage.bounds.height-(self.contentName.bounds.size.height + 10)
                                    if let photoId = response["photo_id"] as? Int
                                    {
                                        if photoId != 0{
                                            self.profileValue = 1
                                        }

                                        if (response["cover_image"] as? String) != nil{
                                        self.coverImageUrl = response["cover_image"] as! String
                                        }
                                        
                                        self.userCoverPicUrl = self.coverImageUrl
                                        
                                        if self.coverImageUrl != ""{
                                            if let url = URL(string: response["cover_image"] as! String){
                                                self.coverImage.kf.indicatorType = .activity
                                                (self.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                                self.coverImage.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                    
                                                })
                                            }}else{
                                            self.coverImage.image =  imageWithImage( UIImage(named: "plain-backgrounds.jpg")!, scaletoWidth: self.coverImage.bounds.width)
                                            
                                        }
                                    }
                                    
                                    self.getCoverGutterMenu()

                                    self.memberProfilePhoto.isHidden = false
                                    
                                    self.userProfilePicUrl = response["image"] as! String
                                    
                                    if (response["cover_image"] as? String) != nil{
                                            self.userCoverPicUrl = response["cover_image"] as! String
                                    }
                                    
                                    if let url = URL(string: response["image"] as! String){
                                      
                                        self.memberProfilePhoto.kf.indicatorType = .activity
                                        (self.memberProfilePhoto.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                        self.memberProfilePhoto.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                            if let img = image
                                            {
                                                self.memberProfilePhoto.image = imageWithImage(img, scaletoWidth: self.coverImage.bounds.width)
                                            }
                                        })

                                    }
                                    
                                    }
                                
                                else{
                                    
                                    self.contentName.text = response["title"] as? String
                                    
                                    if let _ = response["title"] as? String{
                                        self.contentTitle = (response["title"] as? String)!
                                       
                                        if self.contentTitle.length > 22{
                                            self.contentName.frame.origin.y = self.coverImage.bounds.height-75
                                        }
                                        if self.contentTitle.length > 45{
                                            self.contentName.frame.origin.y = self.coverImage.bounds.height-110
                                        }
                                    }
                                    
                                    self.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
                                    self.contentName.sizeToFit()
                                    
                                    
                                    if let photoId = response["photo_id"] as? Int{
                                        
                                        self.coverImageUrl = response["image"] as! String
                                        
                                        if photoId != 0{
                                            
                                            if let url = URL(string: response["image"] as! String){
                                                self.coverImage.kf.indicatorType = .activity
                                                (self.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                                self.coverImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                    
                                                })
                                            }
                                            
                                        }else{
                                            self.coverImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: self.coverImage.bounds.width)
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    if let classifiedImages = response["images"] as? NSArray{
                                        self.totalClassifiedImage = classifiedImages
                                        self.totalPhoto = classifiedImages.count
                                        if classifiedImages.count > 1{
                                            
                                            let message = String(format: NSLocalizedString(" \(forwordIcon) \n\n \(classifiedImages.count) \(cameraIcon)", comment: ""), classifiedImages.count)
                                            
                                            self.totalPic.isHidden = false
                                            self.totalPic.setText(message, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                
                                                // TODO: Clean this up..
                                                return mutableAttributedString
                                            })
                                        }else{
                                            self.totalPic.isHidden = true
                                        }
                                        
                                        if classifiedImages.count > 0 {
                                            let tempClassifiedImagesDic = classifiedImages[0] as! NSDictionary
                                            
                                            if let tempImageString = tempClassifiedImagesDic["image"] as? String {
                                                self.contentImage = tempImageString
                                            }
                                            
                                            
                                            self.imageScrollView.isHidden = false
                                            var originX = ImageViewPading
                                            
                                            for images in classifiedImages {
                                                if let dic = images as? NSDictionary {
                                                    let frame = CGRect( x: originX , y: 0, width: self.view.bounds.width, height: 270  )
                                                    
                                                    var welcomeImageView = ClassifiedCoverImageViewWithGradient(frame: frame)
                                                    
                                                    
                                                    welcomeImageView.tag = self.count
                                                    welcomeImageView.isUserInteractionEnabled = true
                                                    
                                                    self.Id = dic["photo_id"] as! Int
                                                    self.cId = dic["listing_id"] as! Int
                                                    let url = URL(string:dic["image"] as! String)!
                                                    welcomeImageView.kf.indicatorType = .activity
                                                    (welcomeImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                                    welcomeImageView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                        
                                                    })
                                                    welcomeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MLTClassifiedAdvancedTypeViewController.onImageViewTap(_:))))
                                                    self.count += 1
                                                    
                                                    self.imageScrollView.addSubview(welcomeImageView)
                                                }
                                                originX += self.view.bounds.width
                                            }
                                            //self.imageScrollView.addSubview(self.classifiedTitle)
                                            if(UIDevice.current.userInterfaceIdiom == .pad){
                                                self.imageScrollView.contentSize = CGSize(width: originX , height: 370)
                                            }
                                            else{
                                                self.imageScrollView.contentSize = CGSize(width: originX , height: 270)
                                            }
                                            self.imageScrollView.isPagingEnabled = true
                                            self.imageScrollView.bounces = true
                                            self.imageScrollView.isUserInteractionEnabled = true
                                            
                                        }
                                        
                                    }
                                    else{
                                        
                                        self.imageScrollView.isHidden = false
                                        let originX = ImageViewPading
                                        let frame = CGRect( x: originX , y: 0, width: self.view.bounds.width, height: 270  )
                                        
                                        
                                        let welcomeImageView = ClassifiedCoverImageViewWithGradient(frame: frame)
                                        welcomeImageView.isUserInteractionEnabled = false
                                        
                                        welcomeImageView.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: self.coverImage.bounds.width)
                                        self.imageScrollView.addSubview(welcomeImageView)
                                        self.imageScrollView.contentSize = CGSize(width: originX , height: 270)
                                    }
                                }
                                
                                self.ownerName.text = response["owner_title"] as? String
                                if let url = URL(string: response["owner_image_normal"] as! String){
                              
                                    self.imgUser.kf.indicatorType = .activity
                                     (self.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    self.imgUser.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        DispatchQueue.main.async {
                                            if let img = image {
                                                self.imgUser.image = imageWithImage(img, scaletoWidth: self.coverImage.bounds.width)
                                            }
                                        }
                                    })
                                    
                                }
                                
//                                if self.showApplyButton
//                                {
//                                    self.applyButton.frame.origin.y = self.headerHeight+10
//                                    self.applyButton.frame.size.height = 40
//                                    self.applyButton.isHidden = false
//                                    if self.isJobApplied == false
//                                    {
//                                        self.applyButton.addTarget(self, action: #selector(MLTClassifiedSimpleTypeViewController.applyJob), for: .touchUpInside)
//                                    }
//                                    else
//                                    {
//                                        self.applyButton.setTitle("Already Applied", for: .normal)
//                                        self.applyButton.isEnabled = false
//                                    }
//
//                                }
//                                else
//                                {
//                                    self.applyButton.frame.origin.y = getBottomEdgeY(inputView: self.topView)
//                                }
                                
                                
                                
                                self.profileFieldLabel.frame.origin.y = self.topView.bounds.height + self.topView.frame.origin.y + 5
                                self.profileFieldLabel.backgroundColor = UIColor.red
                                var origin_labelheight_y = self.topView.bounds.height + self.topView.frame.origin.y + 10
                                var origin_labelheight_y2 = self.topView.bounds.height + self.topView.frame.origin.y + 10

                                //Work for showing profile fields
                                
                                var labelKey : String!
                                var labelDesc : String!
                                
                                var labelKey2 : String!
                                var labelDesc2 : String!
                                
                                if listing["profile_fields"] != nil {
                                    
                                    if let profileField = listing["profile_fields"] as? NSDictionary{
                                        
                                        profileFields = profileField
                                        
                                        self.profileView.isHidden = false
                                        self.profileView.backgroundColor = UIColor.white
                                        
                                        if profileField.count > 0{
                                            var loop : Int = 0
                                            for(k,v) in profileField{
                                                
                                                if v is NSInteger{
                                                    if v as! NSInteger == 0{
                                                        continue
                                                    }
                                                }else{
                                                    
                                                    if (v as? String) == nil || (v as? String) == ""{
                                                        continue
                                                    }
                                                    
                                                }
                                                if loop % 2 == 0{
                                                    
                                                    self.label1 = TTTAttributedLabel(frame:CGRect(x:2 * PADING,y:origin_labelheight_y + 0,width:self.mainSubView.bounds.width/2 - 2 * PADING , height:30) )
                                                    self.label1.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
                                                    self.label1.textColor = textColorDark
                                                    self.label1.delegate = self
                                                    self.label1.isHidden = false
                                                    
                                                    labelKey = ((k as? String)! + ": ")
                                                    
                                                    if k as! String == "Price"{
                                                        
                                                        
                                                        if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                                            let defaults = UserDefaults.standard
                                                            if let name = defaults.object(forKey: "Currency")
                                                            {
                                                                let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(truncating: (v as AnyObject) as! NSNumber)
                                                                let showPrice = (String(format:"%.2f", changePrice))
                                                                
                                                               // self.priceTextField.text =  "\(name) \(showPrice)"
                                                                labelDesc = "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                                                profileFieldString = labelKey + labelDesc + "\n" + "\n"
                                                                
                                                            }
                                                        }
                                                        else{
                                                            labelDesc = String(describing: v)
                                                            profileFieldString = labelKey + labelDesc + "\n" + "\n"
                                                        }
                                                        
                                                    }
                                                    
                                                    else{
                                                    
                                                    if v is NSInteger {
                                                        labelDesc = String(describing: v)
                                                        profileFieldString = labelKey + labelDesc + "\n" + "\n"
                                                    }else{
                                                        labelDesc = (v as? String)
                                                        profileFieldString = (labelKey + labelDesc) + "\n" + "\n"
                                                    }
                                                    }
                                                    //      profileFieldString = ((labelKey as! String) + (labelDesc as! String)) as AnyObject
                                                    
                                                    self.label1.backgroundColor = UIColor.white//aafBgColor
                                                    
                                                    self.label1.font = UIFont(name: fontName, size: FONTSIZENormal)
                                                    self.label1.numberOfLines = 0
                                                    self.label1.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                    
                                                    let linkColor = UIColor.blue
                                                    let linkActiveColor = UIColor.green
                                                    
                                                    //  profileFieldLabel.delegate = self
                                                    
                                                    self.label1.linkAttributes = [kCTForegroundColorAttributeName as AnyHashable : linkColor.cgColor,kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: true as Bool)]
                                                    self.label1.activeLinkAttributes = [NSAttributedString.Key.foregroundColor : linkActiveColor]
                                                    self.label1.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                                                    self.label1.enabledTextCheckingTypes = NSTextCheckingAllTypes
                                                    self.label1.isUserInteractionEnabled = true
                                                    self.label1.text = profileFieldString
                                                    
                                                    self.label1.setText(profileFieldString , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                        
                                                        let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                                                        
                                                        let range1 = (profileFieldString as NSString).range(of: labelDesc as String)
                                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                                                        
                                                        return mutableAttributedString
                                                    })
                                                    
                                                    if profileField.count == 1
                                                    {
                                                        self.label1.frame = CGRect(x: 2*PADING, y:origin_labelheight_y + 0, width: self.mainSubView.bounds.width - 4*PADING, height: 30)
                                                        
                                                    }
                                                    else
                                                    {
                                                        self.label1.sizeToFit()
                                                    }
                                                    
                                                    origin_labelheight_y  = origin_labelheight_y + self.label1.bounds.height
                                                    
                                                    loop = loop + 1

                                                    self.mainSubView.addSubview(self.label1)
                                                }
                                                else
                                                {
                                                    
                                                    loop = loop + 1
                                                    
                                                    self.label3 = TTTAttributedLabel(frame:CGRect(x: self.mainSubView.bounds.width/2 + 2 * PADING,y: origin_labelheight_y2 + 0,width: self.mainSubView.bounds.width/2 - 3 * PADING, height: 30) )
                                                    self.label3.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
                                                    self.label3.textColor = textColorDark
                                                    self.label3.delegate = self
                                                    self.label3.isHidden = false
                                                    
                                                    
                                                    labelKey2 = ((k as? String)! + ": ") as AnyObject as! String
                                                    
                                                    if k as! String == "Price"{
                                                        
                                                        
                                                        if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                                            let defaults = UserDefaults.standard
                                                            if let name = defaults.object(forKey: "Currency")
                                                            {
                                                                let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(truncating: (v as AnyObject) as! NSNumber)
                                                                let showPrice = (String(format:"%.2f", changePrice))
                                                                
                                                                // self.priceTextField.text =  "\(name) \(showPrice)"
                                                                labelDesc2 = "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                                                profileFieldString2 = ((labelKey2 as String) + (labelDesc2 as String)) + "\n" + "\n"
                                                                
                                                            }
                                                        }
                                                        else{
                                                            labelDesc2 = "\(v)"
                                                            profileFieldString2 = ((labelKey2 as String) + (labelDesc2 as String)) + "\n" + "\n"
                                                        }
                                                        
                                                    }
                                                    else{
                                                    if v is NSInteger{
                                                        labelDesc2 = "\(v)"
                                                        profileFieldString2 = ((labelKey2 as String) + (labelDesc2 as String)) + "\n" + "\n"
                                                    }
                                                    else{
                                                        labelDesc2 = (v as? String)
                                                        profileFieldString2 = ((labelKey2 as String) + (labelDesc2 as String)) + "\n" + "\n"
                                                    }
                                                    }
                                                    
                                                    self.label3.backgroundColor = UIColor.white//aafBgColor //UIColor.red
                                                    
                                                    
                                                    self.label3.font = UIFont(name: fontName, size: FONTSIZENormal)
                                                    self.label3.numberOfLines = 0
                                                    self.label3.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                    
                                                    let linkColor = UIColor.blue
                                                    let linkActiveColor = UIColor.green
                                                    
                                                    
                                                    self.label3.linkAttributes = [kCTForegroundColorAttributeName as AnyHashable : linkColor.cgColor,kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: true as Bool)]
                                                    self.label3.activeLinkAttributes = [NSAttributedString.Key.foregroundColor : linkActiveColor]
                                                    self.label3.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                                                    self.label3.enabledTextCheckingTypes = NSTextCheckingAllTypes
                                                    self.label3.isUserInteractionEnabled = true
                                                    
                                                    
                                                    self.label3.text = profileFieldString2
                                                    self.label3.setText(profileFieldString2 , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                        
                                                        let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                                                        
                                                        let range1 = (profileFieldString2 as NSString).range(of: labelDesc2 as String)
                                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                                                        
                                                        return mutableAttributedString
                                                    })
                                                    
                                                    self.label3.sizeToFit()
                                                    
                                                    origin_labelheight_y2  = origin_labelheight_y2 + self.label3.bounds.height
                                                    
                                                    
                                                    self.mainSubView.addSubview(self.label3)
                                                }
                                                
                                            }
                                            
                                            
                                        }
                                        else
                                        {
                                            
                                            origin_labelheight_y = origin_labelheight_y - 15
                                        }
                                        self.profileView.sizeToFit()
                                        
                                    }
                                }
                                else
                                {
                                    origin_labelheight_y = origin_labelheight_y - 15
                                    origin_labelheight_y2 = origin_labelheight_y2 - 15
                                }
                                
                                
                                if origin_labelheight_y2 > origin_labelheight_y
                                {
                                    
                                    self.detailWebView.frame.origin.y = origin_labelheight_y2 + 15
                                    self.profileView.frame.size.height = origin_labelheight_y2 - (self.topView.bounds.height + self.topView.frame.origin.y + 5)
                                    
                                    
                                }
                                else
                                {
                                    if logoutUser == true {
                                        self.detailWebView.frame.origin.y = origin_labelheight_y + 20
                                    }
                                    else{
                                    self.detailWebView.frame.origin.y = origin_labelheight_y + 10
                                    }
                                    self.profileView.frame.size.height = origin_labelheight_y - (self.topView.bounds.height + self.topView.frame.origin.y + 5)
                                    
                                    
                                }
                                
                                
                                //  self.detailWebView.frame.size.height = self.view.bounds.height - (self.detailWebView.frame.origin.y )
                                let topicDescription = (response["body"] as! String)
                                self.RedirectText = (response["body"] as! String)
                                if response["overview"] != nil {
                                    self.webviewText = response["overview"] as! String
                                }
                                
                                
                                let lineCount = findHeightByText(topicDescription)
                                self.detailWebView.text = topicDescription.html2String
                                
                                self.detailWebView.font = UIFont(name: fontName, size: FONTSIZENormal)
                                // self.detailWebView.sizeToFit()
                                // self.detailWebView.numberOfLines = 0
                                self.detailWebView.textContainer.maximumNumberOfLines = 4
                                self.detailWebView.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail
                                self.detailWebView.backgroundColor = textColorLight//aafBgColor
                                self.detailWebView.isHidden = false
                                //self.detailWebView.loadHTMLString(topicDescription1, baseURL: nil)
                                self.detailWebView.sizeToFit()
                                if lineCount > 4{
                                    self.productMoreOrLess.isHidden = false
                                    self.productMoreOrLessView.isHidden = false
                                    self.productMoreOrLessView.frame.origin.y = self.detailWebView.frame.size.height + self.detailWebView.frame.origin.y
                                    
                                }
                                else{
                                    self.productMoreOrLessView.frame.size.height = 0.0
                                }
                                
                                
                                self.detailWebView.frame.size.width = self.view.bounds.width - 2 * PADING
                                self.mainSubView.isHidden = false
                                
                                self.mainSubView.frame.size.height = self.detailWebView.bounds.height + self.detailWebView.frame.origin.y + self.productMoreOrLessView.frame.size.height
                                self.showtabMenu()
                                self.headerHeight =  self.mainSubView.frame.size.height
                                self.tabsContainerMenu.frame.origin.y =   self.mainSubView.frame.size.height
                                
                                if self.showApplyButton
                                {
                                    self.applyButton.frame.origin.y = self.headerHeight+10
                                    self.applyButton.frame.size.height = ButtonHeight-PADING
                                    self.applyButton.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
                                    self.applyButton.isHidden = false
                                    self.headerHeight = self.headerHeight + 5 + ButtonHeight-PADING
                                    if self.isJobApplied == false
                                    {
                                        self.applyButton.addTarget(self, action: #selector(MLTClassifiedAdvancedTypeViewController.applyJob), for: .touchUpInside)
                                    }
                                    else
                                    {
                                        self.applyButton.setTitle("Already Applied", for: .normal)
                                        self.applyButton.isEnabled = false
                                    }
                                    
                                }
                                else
                                {
                                    self.applyButton.frame.origin.y = getBottomEdgeY(inputView: self.topView)
                                }
                                
                                
                                //  self.feedFilter.isHidden = false
                                self.tabsContainerMenu.isHidden = false
                                for tempMenu in self.wishlistGutterMenu{
                                    if let tempDic = tempMenu as? NSDictionary{
                                        
                                        let wishListPading : CGFloat = 20
                                        if tempDic["name"] as! String == "review" || tempDic["name"] as! String == "update" || tempDic["name"] as! String == "wishlist" {
                                            
                                            
                                            // MARK: - menu work
                                            if tempDic["name"] as! String == "review"
                                            {
                                                self.flag = true
                                                
                                                let writeReview = createButton(CGRect(x: wishListPading, y: self.headerHeight + 8, width: self.mainSubView.bounds.width - 2 * wishListPading, height: ButtonHeight-PADING), title: "", border: false,bgColor: false, textColor: textColorPrime)
                                                writeReview.setTitle("Write a Review", for: UIControl.State())
                                                writeReview.backgroundColor = navColor
                                                writeReview.layer.cornerRadius = 5.0
                                                writeReview.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
                                                writeReview.addTarget(self, action: #selector(MLTClassifiedAdvancedTypeViewController.performReviewOrWishlistAction(_:)), for: .touchUpInside)
                                                writeReview.tag = 60
                                                self.urlDictionary["reviewUrl"] = tempDic["url"] as? String
                                                self.feedObj.tableView.addSubview(writeReview)
                                                self.headerHeight = self.headerHeight + 5 + ButtonHeight-PADING
                                            }
                                            
                                            if tempDic["name"] as! String == "update"
                                            {
                                                self.flag = true
                                                let writeReview = createButton(CGRect(x: wishListPading, y: self.headerHeight + 8, width: self.mainSubView.bounds.width - 2 * wishListPading, height: ButtonHeight-PADING), title: "", border: false,bgColor: false, textColor: textColorPrime)
                                                writeReview.setTitle("Update Review", for: UIControl.State())
                                                writeReview.backgroundColor = navColor
                                                writeReview.layer.cornerRadius = 5.0
                                                writeReview.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
                                                writeReview.addTarget(self, action: #selector(MLTClassifiedAdvancedTypeViewController.performReviewOrWishlistAction(_:)), for: .touchUpInside)
                                                self.feedObj.tableView.addSubview(writeReview)
                                                writeReview.tag = 61
                                                self.urlDictionary["reviewUrl"] = tempDic["url"] as? String
                                                let param = tempDic["urlParams"] as! NSDictionary
                                                self.reviewId = param["review_id"] as! Int
                                                self.headerHeight = self.headerHeight + 5 + ButtonHeight-PADING
                                            }
                                            
                                            
                                            if (tempDic["name"] as! String == "wishlist") && self.flag == true{
                                                
                                                self.addWishList.frame = CGRect(x: wishListPading, y: self.headerHeight + 8, width: self.mainSubView.bounds.width - 2 * wishListPading, height: ButtonHeight-PADING)

                                                self.addWishList.setTitle("Add to Wishlist", for: UIControl.State())
                                                self.addWishList.isHidden = false
                                                self.addWishList.backgroundColor = navColor
                                                self.addWishList.layer.cornerRadius = 5.0
                                                
                                                self.addWishList.tag = 62
                                                self.urlDictionary["wishlistUrl"] = tempDic["url"] as? String

                                                self.headerHeight = self.headerHeight + 5 + ButtonHeight-PADING
//                                                self.tabsContainerMenu.frame.origin.y = self.headerHeight + 20 + 2 * ButtonHeight - PADING                                                
                                            }
                                            
                                            if (tempDic["name"] as! String == "wishlist") && self.flag == false{
                                                
                                                self.addWishList.frame = CGRect(x: wishListPading, y: self.headerHeight + 8, width: self.mainSubView.bounds.width -  2 * wishListPading, height: ButtonHeight-PADING)
                                                self.addWishList.setTitle("Add to Wishlist", for: UIControl.State())
                                                self.addWishList.isHidden = false
                                                
                                                self.addWishList.backgroundColor = navColor
                                                self.addWishList.layer.cornerRadius = 5.0
                                                self.addWishList.tag = 62
                                                self.urlDictionary["wishlistUrl"] = tempDic["url"] as? String
                                                self.headerHeight = self.headerHeight + 5 + ButtonHeight-PADING
//                                                self.tabsContainerMenu.frame.origin.y = self.headerHeight + 15 + ButtonHeight - PADING
                                                
                                            }
                                        }
                                    }
                                    
                                     self.tabsContainerMenu.frame.origin.y = self.headerHeight+10
                                }
                                self.tabsContainerMenu.frame.origin.y = self.headerHeight+10
                                if logoutUser == true{
                                    self.tabsContainerMenu.frame.origin.y = self.headerHeight + 15
                                }
                                
                                self.feedFilter.frame.origin.y = self.tabsContainerMenu.frame.origin.y + self.tabsContainerMenu.bounds.height +  ButtonHeight + 20
                                if logoutUser == true
                                {
                                    self.feedFilter.frame.origin.y = self.tabsContainerMenu.frame.origin.y + self.tabsContainerMenu.bounds.height + 15
                                }
 
                                if logoutUser == false
                                {
                                    globalFeedHeight = self.feedFilter.frame.origin.y + ButtonHeight + 10  + 3
                                }
                                else
                                {
                                    globalFeedHeight = self.feedFilter.frame.origin.y + ButtonHeight + 10
                                }
                                
                                self.browseFeed()
                                self.feedObj.refreshLikeUnLike = true
                                self.feedObj.tableView.reloadData()
                            }
                            
                        }
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                    }else{
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            let message = succeeded["message"] as? String
                            if message == "You do not have the access of this page."
                            {
                                self.popAfterDelay = true
                                self.createTimer(self)
                                
                            }
                            
                        }
                    }
                })
                
                
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    func getCoverGutterMenu(){
        
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["subject_type": subjectType , "subject_id": String(listingId) , "special": "both" , "cover_photo" : String(coverValue) , "profile_photo" : String(profileValue)], url: "coverphoto/get-cover-photo-menu", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let coverData = response["response"] as? NSDictionary {
                                    if let coverPhotoMenu = coverData["coverPhotoMenu"] as? NSArray{
                                        self.coverPhotoMenu = coverPhotoMenu
                                        self.camIconOnCover.isHidden = false
                                    }
                                    if let mainPhotoMenu = coverData["profilePhotoMenu"] as? NSArray{
                                        
                                        self.profilePhotoMenu = mainPhotoMenu
                                        self.camIconOnProfile.isHidden = false
                                    }
                                    
                                }
                            }
                        }
                        
                     }
                    else{
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
    
    @objc func showProfileCoverImageMenu(_ sender: UITapGestureRecognizer){
        
        var isProfileOrCover = true
        if sender.view!.tag == 123{
            imageMenus = coverPhotoMenu
            isProfileOrCover = false
        }else if sender.view!.tag == 321{
            imageMenus = profilePhotoMenu
            isProfileOrCover = true
        }
        
        if imageMenus.count > 0{
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            
            for menu in imageMenus{
                if let dic = menu as? NSDictionary{
                    
                    
                    if dic["name"] as! String == "remove_photo" || dic["name"] as! String == "remove_cover_photo"{
                        
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive , handler:{ (UIAlertAction) -> Void in
                            // Delete Activity Feed Entry
                            if dic["name"] as! String == "remove_photo"{
                                
                                // Confirmation Alert for Delete Feed
                                displayAlertWithOtherButton(NSLocalizedString("Remove Profile Photo?", comment: "") ,message: NSLocalizedString("Are you sure that you want to remove this profile photo? Doing so will set your photo back to the default photo.", comment: "") ,otherButton: NSLocalizedString("Remove Photo", comment: ""), otherButtonAction: { () -> () in
                                    
                                    var urlParams : NSDictionary = [:]
                                    
                                    urlParams = (dic["urlParams"] as? NSDictionary)!
                                    // Update Feed Gutter Menu
                                    self.performPhotoActions(urlParams as NSDictionary, url:dic["url"] as! String)
                                })
                                self.present(alert, animated: true, completion: nil)
                            }
                            else if dic["name"] as! String == "remove_cover_photo"{
                                
                                // Confirmation Alert for Delete Feed
                                displayAlertWithOtherButton(NSLocalizedString("Remove Cover Photo?", comment: "") ,message: NSLocalizedString("Are you sure that you want to remove this cover photo? Doing so will set your photo back to the default photo.", comment: "") ,otherButton: NSLocalizedString("Remove Photo", comment: ""), otherButtonAction: { () -> () in
                                    
                                    var urlParams : NSDictionary = [:]
                                    
                                    urlParams = (dic["urlParams"] as? NSDictionary)!
                                    
                                    // Update Feed Gutter Menu
                                    self.performPhotoActions(urlParams as NSDictionary, url:dic["url"] as! String)
                                })
                                self.present(alert, animated: true, completion: nil)
                            }
                        }))
                        
                    }else{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.default, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                            case "upload_cover_photo":
                                
                                let presentedVC = EditProfilePhotoViewController()
                                presentedVC.currentImageUrl = self.userCoverPicUrl
                                presentedVC.url = "coverphoto/upload-cover-photo/"
                                presentedVC.pageTitle = NSLocalizedString("Edit Cover Photo", comment: "")
                                presentedVC.contentType = "sitereview_listing"
                                presentedVC.contentId = "\(self.listingId)"
                                presentedVC.showCameraButton = false
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "choose_from_album":
                                
                                let presentedVC = ChoosePhotoViewController()
                                presentedVC.showOnlyMyContent = true
                                presentedVC.contentId = "\(self.listingId)"
                                presentedVC.listingTypeId = self.listingTypeId!
                                presentedVC.contentType = "sitereview_listing"//self.subjectType
                                presentedVC.profileOrCoverChange = isProfileOrCover
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                                
                            case "view_cover_photo":
                                
                                let presentedVC = SinglePhotoLightBoxController()
                                presentedVC.imageUrl = self.userCoverPicUrl//dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                                
                            case "upload_photo":
                                
                                let presentedVC = EditProfilePhotoViewController()
                                presentedVC.currentImageUrl = self.userProfilePicUrl
                                
                                presentedVC.url = "coverphoto/upload-cover-photo/"
                                presentedVC.pageTitle = NSLocalizedString("Edit Profile Photo", comment: "")
                                presentedVC.contentType = "sitereview_listing"
                                presentedVC.contentId = "\(self.listingId)"
                                presentedVC.special = "profile"
                                
                                presentedVC.showCameraButton = true
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                                
                            case "view_profile_photo":
                                
                                let presentedVC = SinglePhotoLightBoxController()
                                presentedVC.imageUrl = self.userProfilePicUrl//dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                            
                            
                        }))}
                    
                    
                }
            }
            
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }else{
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                alertController.popoverPresentationController?.sourceView = view
                alertController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width/2 , y: view.bounds.height/2, width: 0, height: 0)
                alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection()
                
            }
            
            self.present(alertController, animated:true, completion: nil)
        }
        else{
            if sender.view!.tag == 123{
                if self.userCoverPicUrl != nil && self.userCoverPicUrl != "" {
                    let presentedVC = SinglePhotoLightBoxController()
                    presentedVC.imageUrl = self.userCoverPicUrl
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    present(nativationController, animated:false, completion: nil)
                }
            }else if sender.view!.tag == 321{
                if self.userProfilePicUrl != nil && self.userProfilePicUrl != "" {
                    let presentedVC = SinglePhotoLightBoxController()
                    presentedVC.imageUrl = self.userProfilePicUrl
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    present(nativationController, animated:false, completion: nil)
                }
            }
        }
        
        
    }
    
    // Update Feed Gutter Menu
    func performPhotoActions(_ parameter: NSDictionary , url : String){
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
            
            var method: String!
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }
            else{
                method = "POST"
            }
            
            
            userInteractionOff = false
            // Send Server Request to Update Feed Gutter Menu
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    
                    if msg{
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        //updateUserData()
                        self.coverImageUrl = ""
                        self.exploreContent()
                        
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

    //MARK:- TikTok API
    func API_getAAFList()
    {
        if Reachabable.isConnectedToNetwork()
        {
            var parameters = [String:String]()
            parameters = ["limit": "\(limit)","maxid": String(maxidTikTok),"feed_filter": "1","post_menus":"1","object_info":"1","getAttachedImageDimention":"0","filter_type":"video","onlyMyDeviceVideo":"1"]
            if listingId != nil{
                parameters["subject_id"] = String(listingId)
                subjectIdTikTok = "\(listingId)"
            }
            else{
                subjectIdTikTok = ""
            }
            if subjectType != ""{
                parameters["subject_type"] = subjectType
                subjectTypeTikTok = subjectType
            }
            else{
                subjectTypeTikTok = ""
            }
            
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg {
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                            
                        }
                       // print(succeeded)
                        // Set MaxId for Feeds Result
                        if maxidTikTok == 0
                        {
                            feedArrayTikTok.removeAll()
                        }
                        if let dicTemp = succeeded["body"] as? [String : AnyObject], let activity_feed = dicTemp["data"] as? NSArray
                        {
                            if let maxid = dicTemp["maxid"] as? Int{
                                maxidTikTok = maxid
                            }
                            let activityFeeds:[ActivityFeed] = ActivityFeed.loadActivityFeedInfo(activity_feed)
                            self.updateFeedsArrayTikTok(feeds: activityFeeds)
                        }
                        else
                        {
                            // Handle Server Error
                            if succeeded["message"] != nil && enabledModules.contains("suggestion")
                            {
                                showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                                
                            }
                        }
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2.0)
                        }
                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self, onView: false, time: 2.0)
        }
    }
    
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
    
    
    
    // MARK: - Activity Feed functions
    
    func browseFeed(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            API_getAAFList()
            removeAlert()
            // stopMyTimer()
            // Remove new Activity Feed InfoLabel, NO Stories
            for ob in self.feedObj.tableView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            for ob in view.subviews{
                if ob.tag == 2000{
                    ob.removeFromSuperview()
                }
            }
            
            
            // Reset Objects for Hard Refresh Request
            if maxid == 0{
                
                if contentFeedArray.count == 0{
                    self.feedObj.tableView.reloadData()
                }
                
            }

            // Check for Show Spinner Position for Request
            if (showSpinner){
                activityIndicatorView.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85-(tabBarHeight/4))
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                self.view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
             //   activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            
            
            parameters = ["maxid":String(maxid) , "limit": "\(limit)", "subject_type": subjectType , "subject_id": String(listingId), "post_menus":"1", "feed_filter": "1","getAttachedImageDimention":"0","object_info":"1"]
            
            // Set userinteractionflag for request
            userInteractionOff = false
            
            // Check for FeedFilter Option in Request
            if feedFilterFlag == true{
                parameters.merge(searchDic)
            }
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    // Reset Object after Response from server
                    userInteractionOff = true
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }else{
                        self.refresher.endRefreshing()
                        
                    }
                    self.feedObj.tableView.tableFooterView?.isHidden = true
                    self.showSpinner = false
                    
                    // On Success Update Feeds
                    if msg{
                        // If Message in Response show the Message
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        // Reset contentFeedArray for Sink with Feed Results
                        if self.maxid == 0{
                            contentFeedArray.removeAll(keepingCapacity: false)
                            self.dynamicRowHeight.removeAll(keepingCapacity: false)
                        }
                        self.activityFeeds.removeAll(keepingCapacity: false)
                        
                       // print(succeeded)
                        // Check response of Activity Feeds
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            // Set MinId for Feeds Result
                            if let minID = response["minid"] as? Int{
                                self.minid = minID
                            }
                            // Check that whether Reaction Plugin is enable or not
                            if let reactionsEnable = response["reactionsEnabled"] as? Bool{
                                if reactionsEnable == true{
                                    if let reactions = response["reactions"] as? NSDictionary
                                    {
                                        reactionsDictionary = reactions
                                        ReactionPlugin = true
                                        self.browseEmoji(contentItems: reactions)
                                    }
                                }
                            }
                            else{
                                ReactionPlugin = false
                            }
                            
                            // Check for Feed Filter Options
                            if let menu = response["filterTabs"] as? NSArray{
                                self.feedFilter.isHidden = false
                                self.feedFilter.isEnabled = true
                                self.filterGutterMenu = menu
                            }
                            
                            // Check for Feeds
                            if response["data"] != nil{
                                if let activity_feed = response["data"] as? NSArray{
                                    // Extract FeedInfo from response by ActivityFeed class
                                    self.activityFeeds = ActivityFeed.loadActivityFeedInfo(activity_feed)
                                    // Update contentFeedArray
                                    self.updateFeedsArray(self.activityFeeds)
                                }
                            }
                            
                            if self.feedFilter.isHidden == true{
                                //self.feedFilter.isHidden = false
                            }
                            
                            
                            // Set MaxId for Feeds Result
                            
                            if let maxid = response["maxid"] as? Int{
                                self.maxid = maxid
                            }
                            
                            // Check for Post Feed Options
                            if response["feed_post_menu"] != nil{
                                postPermission = response["feed_post_menu"] as! NSDictionary
                                UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: postPermission), forKey: "postMenu")
                                if (logoutUser == false){
                                    self.postFeedOption()
                                }
                            }
                            
                            if contentFeedArray.count == 0 {
                                
                                self.info  = createLabel(CGRect(x: 0,y: self.feedFilter.frame.origin.y + ButtonHeight + 10,width: self.view.bounds.width, height: 50), text: NSLocalizedString("No updates at this moment . Check again any \nother time.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.info.backgroundColor = .white
                                self.info.font = UIFont(name: fontName, size: FONTSIZENormal)
                                self.info.tag = 1000
                                self.info.textAlignment = .center
                                self.info.numberOfLines = 2
                                self.feedObj.tableView.frame.size.height = self.view.bounds.height - 40 - tabBarHeight
                                self.feedObj.tableView.addSubview(self.info)
                                self.info.isHidden = false
                                globalFeedHeight = self.feedFilter.frame.origin.y + ButtonHeight + 10
                                if logoutUser == false
                                {
                                    globalFeedHeight = self.feedFilter.frame.origin.y + ButtonHeight + 10 + 40
                                }
                            }
                            self.feedObj.globalArrayFeed = contentFeedArray
                            // Reload Tabel After Updation
                            self.feedObj.refreshLikeUnLike = true
                            self.feedObj.tableView.reloadData()
                            if afterPost == true{
                                afterPost = false
                                DispatchQueue.main.async(execute: {
                                    soundEffect("post")
                                })
                                
                            }
                            self.updateScrollFlag = true
                            self.activityFeeds.removeAll(keepingCapacity: false)
                            // self.startMyTimer()    // Create Timer for Check UPdtes Repeatlly
                        }
                        
                    }else{
                        // Show Message on Failour
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                            
                        }
                        self.updateScrollFlag = true
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    
    func browseEmoji(contentItems: NSDictionary)
    {
        scrollViewEmoji.backgroundColor = .clear
        arrowView.backgroundColor = .clear
        for ob in scrollViewEmoji.subviews{
            ob.removeFromSuperview()
            arrowView.removeFromSuperview()
        }
        // var allReactionsValueDic = Dictionary<String, AnyObject>() // sorted Reaction Dictionary
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
            //                scrollViewEmoji.layer.borderWidth = 2.0
            //                scrollViewEmoji.layer.borderColor = aafBgColor.cgColor  //UIColor.red.cgColor //tableViewBgColor.cgColor
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
                        emoji.addTarget(self, action: #selector(MLTClassifiedAdvancedTypeViewController.feedMenuReactionLike(sender:)), for: .touchUpInside)
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
        arrowView.isHidden = true
        reactionButtonImage = sender
        let feed = contentFeedArray[scrollViewEmoji.tag] as! NSDictionary
        let action_id = feed["action_id"] as! Int
        if openSideMenu{
            openSideMenu = false
             
            return
        }
        
        animateReaction()
        var reaction = ""
        
        for (_,v) in reactionsDictionary
        {
            var updatedDictionary = Dictionary<String, AnyObject>()
            let v = v as! NSDictionary
            if  let reactionId = v["reactionicon_id"] as? Int
            {
                if reactionId == sender.tag
                {
                    
                    reaction = (v["reaction"] as? String)!
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
                    
                    feedObj.updateReaction(url: url,reaction : reaction,action_id  : action_id, updateMyReaction : updatedDictionary as NSDictionary,feedIndex: scrollViewEmoji.tag)
                    
                }
            }
        }
        
        
        
    }
    
    func postFeedOption(){
        /// Read Post Permission saved in NSUserDefaults
        if let data = UserDefaults.standard.object(forKey: "postMenu") as? Data{
            if data.count != 0{
                for ob in view.subviews{
                    if ob.tag == 1 || ob.tag == 2 || ob.tag == 3{
                        ob.removeFromSuperview()
                    }
                }
                
                postPermission = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
                
                var postMenu = [String]()
                if postPermission.count > 0{
                    if let status = postPermission["status"] as? Bool{
                        if status{
                            postMenu.append(statusIcon+NSLocalizedString(" Status", comment: ""))
                        }
                    }
                    if let photo = postPermission["photo"] as? Bool{
                        if photo{
                            postMenu.append(cameraIcon+NSLocalizedString(" Photo", comment: ""))
                        }
                    }
                    if let checkIn = postPermission["checkin"] as? Bool{
                        if checkIn{
                            postMenu.append(locationIcon+NSLocalizedString(" Check In", comment: ""))
                        }
                    }
                }
                
                
                for ob in feedObj.tableView.subviews{
                    if ob.tag >= 1991 && ob.tag <= 1993{
                        ob.removeFromSuperview()
                    }
                }
                
                
                //Add Post Feed Option
                for i in 0 ..< postMenu.count {
                    let origin_x = PADING + (CGFloat(i) * ((view.bounds.width - (2 * PADING))/CGFloat(postMenu.count)))
                    let postFeed = createButton(CGRect(x: origin_x, y: tabsContainerMenu.frame.origin.y + tabsContainerMenu.bounds.height + contentPADING + 5, width: view.bounds.width/CGFloat(postMenu.count), height: ButtonHeight - PADING), title: postMenu[i] , border: false ,bgColor: false, textColor: textColorMedium)
                    postFeed.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZENormal)
                    postFeed.backgroundColor = lightBgColor
                    postFeed.tag = i+1 + 1990
                    postFeed.addTarget(self, action: #selector(MLTClassifiedAdvancedTypeViewController.openPostFeed(_:)), for: .touchUpInside)
                    feedObj.tableView.addSubview(postFeed)
                }
                
                postMenu.removeAll(keepingCapacity: false)
            }
        }
    }
    
    @objc func openPostFeed(_ sender:UIButton){
        
        if openSideMenu{
            openSideMenu = false
             
            return
        }
        
        let presentedVC = AdvancePostFeedViewController()
        if (sender.tag - 1990) == 1 {
            presentedVC.openfeedStyle = 0//(sender.tag - 1990)
        }
        else{
            presentedVC.openfeedStyle = (sender.tag - 1990)
        }
        if presentedVC.openfeedStyle == 3 {
            presentedVC.isCheckIn = true
        }
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:false, completion: nil)
        
    }
    
    func updateFeedsArray(_ feeds:[ActivityFeed]){
        
        for feed in feeds{
            let newDictionary:NSMutableDictionary = [:]
            
            if feed.action_id != nil{
                newDictionary["action_id"] = feed.action_id
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
            
            if feed.feed_reactions != nil{
                newDictionary["feed_reactions"] = feed.feed_reactions
            }
            if feed.my_feed_reaction != nil{
                newDictionary["my_feed_reaction"] = feed.my_feed_reaction
            }

            if feed.wordStyle != nil{
                newDictionary["wordStyle"] = feed.wordStyle
            }
            
            if feed.decoration != nil{
                newDictionary["decoration"] = feed.decoration
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
            
            contentFeedArray.append(newDictionary)
            
        }
        if logoutUser == false
        {
            globalFeedHeight = feedFilter.frame.origin.y + ButtonHeight + 10  + 3
        }
        else
        {
            globalFeedHeight = feedFilter.frame.origin.y + ButtonHeight + 10
        }
        self.feedObj.globalArrayFeed = contentFeedArray
        self.feedObj.refreshLikeUnLike = true
        self.feedObj.tableView.reloadData()
        
    }
    
    @objc func ScrollingactionMLTClassifiedAdvancedType(_ notification: Foundation.Notification)
    {
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        if updateScrollFlag{
            
            
            // Check for PAGINATION
            if feedObj.tableView.contentSize.height > feedObj.tableView.bounds.size.height{
                
                if feedObj.tableView.contentOffset.y >= (feedObj.tableView.contentSize.height - feedObj.tableView.bounds.size.height){
                    
                    if Reachabable.isConnectedToNetwork() {
                        
                        if contentFeedArray.count > 0{
                            if maxid == 0 {
                       
                                if noPost == true
                                {
                                    feedObj.tableView.tableFooterView?.isHidden = true
                                    showToast(message: NSLocalizedString("There are no more posts to show.",  comment: ""), controller: self)
                                    noPost = false                                }
                               
                             
                            }else{
                                
                                // Request for Pagination
                                updateScrollFlag = false
                                feed_filter = 0
                              //  showSpinner = true
                                feedObj.tableView.tableFooterView?.isHidden = false
                                if adsType_feeds == 2 || adsType_feeds == 4 
                                {
                                    delay(0.1) {
                                        self.feedObj.checkforAds()
                                    }
                                }
                                browseFeed()
                            }
                        }
                    }
                }
            }
        }
        
        let scrollOffset = scrollopoint.y
        
        if (scrollOffset > 60.0){
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
            self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = textColorPrime
            self.marqueeHeader.text = self.contentTitle
            self.marqueeHeader.textColor = textColorPrime
            self.navigationController?.navigationBar.alpha = barAlpha
            self.marqueeHeader.alpha = barAlpha
            self.contentName.alpha = 1-barAlpha
            
            if (self.lastContentOffset > scrollopoint.y) {
                // move up
                self.like_comment.fadeIn()
            }
            else if (self.lastContentOffset < scrollopoint.y){
                // move down
                self.like_comment.fadeOut()
            }
            // update the new position acquired
            self.lastContentOffset = scrollopoint.y
        }
        else
        {
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            self.marqueeHeader.text = ""
            removeNavigationImage(controller: self)
            self.contentName.alpha = 1-barAlpha
            self.marqueeHeader.alpha = 1
            self.like_comment.alpha = 1
            if (scrollOffset < 10.0){
                self.like_comment.alpha = 1
            }
        }
        
        
    }
    @objc func goToMember() {
        let vc = MemberViewController()
        vc.contentType = "members"
        vc.mapormember = 1
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func showtabMenu(){
        
        for ob in tabsContainerMenu.subviews{
            if ob.tag == 101{
                ob.removeFromSuperview()
            }
        }
        
        var origin_x:CGFloat = 0
        for menu in mltProfileTabMenu{
            if let menuItem = menu as? NSDictionary{
                
                var button_title = menuItem["label"] as! String
                if menuItem["label"] as! String == "Specification"{
                    button_title = NSLocalizedString("Info", comment: "")
                }
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                
                let width = findWidthByText(button_title) + 10
                
                let menu = createButton(CGRect(x: origin_x,y: 0 ,width: width , height: tabsContainerMenu.bounds.height),title: button_title , border: false,bgColor: false, textColor: textColorDark)
                menu.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                menu.tag = 101
                menu.addTarget(self, action: #selector(MLTClassifiedAdvancedTypeViewController.tabMenuAction(_:)), for: .touchUpInside)
                tabsContainerMenu.addSubview(menu)
                origin_x += width
                
                if button_title == "Updates"{
                    menu.setTitleColor(textColorDark, for: UIControl.State())
                }
                else{
                    menu.setTitleColor(textColorMedium, for: UIControl.State())
                }
                
            }
        }
        
        tabsContainerMenu.contentSize = CGSize(width: origin_x, height: tabsContainerMenu.bounds.height)
        
    }
    
    @objc func tabMenuAction(_ sender:UIButton){
        for menu in mltProfileTabMenu{
            if let menuItem = menu as? NSDictionary{
                
                var button_title = menuItem["label"] as! String
                
                if menuItem["label"] as! String == "Specification"{
                    button_title = NSLocalizedString("Info", comment: "")
                }
                
                // if button_title != "Fourms Posts" {
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                
                if sender.titleLabel?.text == button_title{
                    if menuItem["name"] as! String == "specification"{
                        
                        if self.detailWebView != nil{
                            let presentedVC = MLTInfoViewController()
                            presentedVC.label1 = self.RedirectText
                            presentedVC.viewTitle = button_title
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                    }
                    if menuItem["name"] as! String == "overview"{
                        
                        if self.detailWebView != nil{
                            let presentedVC = OverViewViewController()
                            presentedVC.label1 = self.webviewText
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                    }
                    
                    if menuItem["name"] as! String == "advevents"{
                        let presentedVC = AdvancedEventViewController()
                        presentedVC.showOnlyMyContent = true
                        presentedVC.sitegroupCheck = "listing"
                        if menuItem["totalItemCount"] as? Int != nil {
                            presentedVC.eventCount = menuItem["totalItemCount"] as! Int
                        }
                        if let dic1 = menuItem["urlParams"] as? NSDictionary{
                            presentedVC.user_id = "\(dic1["subject_id"])"
                        }
                        presentedVC.fromTab = true
                        
                        
                        navigationController?.pushViewController(presentedVC, animated: false)
                    }
                    
                    if menuItem["name"] as! String == "video"{
                        if sitevideoPluginEnabled_mlt == 1
                        {
                            let presentedVC = AdvanceVideoViewController()
                            presentedVC.user_id = "\(listingId)"
                            presentedVC.fromTab = true
                            presentedVC.showOnlyMyContent = false
                            presentedVC.countListTitle = button_title
                            presentedVC.other_module = true
                            presentedVC.videoTypeCheck = "listings"
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.listingTypeId = listingTypeId
                            presentedVC.subject_type = menuItem["subject_type"] as! String
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                        else
                        {
                            let presentedVC = VideoBrowseViewController()
                            presentedVC.showOnlyMyContent = true
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.listingTypeId = listingTypeId
                            presentedVC.videoTypeCheck = "listings"
                            presentedVC.listingId = "\(listingId)"
                            presentedVC.fromTab = true
                            presentedVC.countListTitle =  button_title
                            
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                        
                    }

                    if menuItem["name"] as! String == "reviews"
                    {
                        let presentedVC = UserReviewViewController()
                        presentedVC.mytitle = "\(contentTitle!)"//"\((self.title)!)"
                        presentedVC.subjectId = "\(listingId)"
                        presentedVC.listingTypeId = listingTypeId
                        presentedVC.contentType = "listings"
                        
                        if let totalItem = menuItem["totalItemCount"] as? Int
                        {
                            if totalItem > 0
                            {
                                presentedVC.count = totalItem
                                
                            }
                            
                        }

                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    if menuItem["name"] as! String == "map"
                    {
                        let presentedVC = GoogleMapMarkerViewController()
                        if let location = menuItem["location"] as? NSDictionary
                        {
                            if let lat = location["latitude"] as? Double
                            {
                                if let lang = location["longitude"] as? Double
                                {
                                    presentedVC.location = location["label"] as? String ?? ""
                                    presentedVC.kCameraLatitude = lat
                                    presentedVC.kCameraLongitude = lang
                                }
                            }
                            
                        }
                        presentedVC.mytitle = "\(contentTitle!)"
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    if menuItem["name"] as! String == "photos"{
                        let presentedVC = PhotoListViewController()
                        presentedVC.contentType = "sitereview_photo"
                        presentedVC.listingId = listingId
                        let tempUrl = menuItem["url"] as! String
                        presentedVC.listingTypeId = listingTypeId
                        presentedVC.mytitle = self.contentTitle
                        presentedVC.url = tempUrl
                        presentedVC.param = ["subject_type": "sitereview_album","listingtype_id":String(listingTypeId!)]
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                        
                    }
                    
                    
                }
            }
            // }
        }
    }
    
    @objc func goBack(){
        sitevideoPluginEnabled_mlt = 0
        if conditionalProfileForm == "BrowsePage"
        {
            listingUpdate = true
            _ = self.navigationController?.popToRootViewController(animated: false)
        }
        else
        {
            _ = self.navigationController?.popViewController(animated: false)
        }
    }
    
    @objc func refresh(){
        DispatchQueue.main.async(execute: {
            soundEffect("Activity")
        })
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            searchDic.removeAll(keepingCapacity: false)
            
            showSpinner = false
            updateAfterAlert = false
            exploreContent()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    // Show Gutter Menus of listing
    @objc func showGutterMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        
        deleteContent = false
        let confirmationTitle = ""
        
        let message = ""
        var url = ""
        
        var confirmationAlert = true
        
        
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                
                var params = Dictionary<String, AnyObject>()
//                if dic["name"] as! String == "videoCreate"{
//                    continue
//                }
                
                if dic["name"] as! String != "share"{
                    let titleString = dic["name"] as! String
                    if titleString.range(of: "delete") != nil{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                                
                            case "delete":
                                
                                displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this listing?",comment: "") , otherButton: NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                                    self.deleteListingEntry = true
                                    
                                    self.performListingMenuAction(params as NSDictionary, url: dic["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                        }))
                    }else{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.default, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                               
                            case "videoCreate" :
                                addvideo_click = 1
                                manage_advvideoshow = false
                                isCreateOrEdit = true
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Add New Video", comment: "")
                                presentedVC.contentType = "Advanced Video"
                                if sitevideoPluginEnabled_mlt == 1
                                {
                                    let subject_type = dic["subject_type"] as! String
                                    let subject_id =   dic["subject_id"] as! Int
                                    presentedVC.param = ["subject_id":"\(subject_id)","subject_type" :"\(subject_type)" ]
                                }
                                url = dic["url"] as! String
                                presentedVC.url = url
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                            case "create" :
                                
                                if dynamicEventPackageEnabled == 1
                                {
                                    isCreateOrEdit = true
                                    let presentedVC = PackageViewController()
                                    presentedVC.contentType = "advancedevents"
                                    presentedVC.url = "advancedevents/packages"
                                    presentedVC.extensionParam = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    url = dic["url"] as! String
                                    presentedVC.extensionUrl = url
                                    presentedVC.eventExtensionCheck = true
                                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                    self.present(nativationController, animated:false, completion: nil)
                                    
                                }
                                else{
                                
                                isCreateOrEdit = true
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = dic["label"] as! String
                                presentedVC.contentType = "advancedevents"
                                presentedVC.eventExtensionCheck = true
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                url = dic["url"] as! String
                                presentedVC.url = url
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                }
                                
                            case "tellafriend":
                                
                                confirmationAlert = false
                                let presentedVC = TellAFriendViewController();
                                url = dic["url"] as! String
                                presentedVC.url = url
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                            case "messageowner":
                                
                                confirmationAlert = false
                                
                                if isChannelizeAvailable{
                                    if let userId = self.user_id{
                                        let data : [AnyHashable:Any] = [AnyHashable("userId"):userId]
                                        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                                            let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                                            if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                                                channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: data)
                                            }else{
                                                let presentedVC = MessageOwnerViewController();
                                                presentedVC.url = dic["url"] as! String
                                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                            }
                                            
                                        }
                                    }
                                } else{
                                    let presentedVC = MessageOwnerViewController();
                                    presentedVC.url = dic["url"] as! String
                                    self.navigationController?.pushViewController(presentedVC, animated: false)
                                }
                            case "report":
                                confirmationAlert = false
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                                
//                            case "create":
//
//                                let presentedVC = FormGenerationViewController()
//                                presentedVC.formTitle = NSLocalizedString("Write New Entry", comment: "")
//                                presentedVC.contentType = "blog"
//                                presentedVC.url = dic["url"] as! String
//                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
//                                let nativationController = UINavigationController(rootViewController: presentedVC)
//                                self.present(nativationController, animated:false, completion: nil)

                                
                            case "edit":
                                
                                confirmationAlert = false
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                var editFormTitle = "Edit Listing"
                                if dic["label"] != nil{
                                    editFormTitle = dic["label"] as! String
                                }
                                presentedVC.formTitle = NSLocalizedString(editFormTitle, comment: "")
                                presentedVC.listingTypeId = self.listingTypeId
                                presentedVC.contentType = "listings"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            case "wishlist":
                                
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Add To Wishlist", comment: "")
                                presentedVC.contentType = "wishlist"
                                let tempDic = dic["urlParams"] as! NSDictionary
                                tempDic.setValue(self.listingTypeId, forKey: "listingtype_id")
                                presentedVC.param = tempDic as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                                
                            case "review":
                                
                                confirmationAlert = false
                                isCreateOrEdit = true
                                globFilterValue = ""
                                
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Write a Review", comment: "")
                                presentedVC.contentType = "Review"
                                var tempDic = NSDictionary()
                                tempDic = ["listingtype_id" : "\(self.listingTypeId)"]
                                presentedVC.param = tempDic as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            case "update":
                                
                                
                                isCreateOrEdit = true
                                globFilterValue = ""
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Update Review", comment: "")
                                presentedVC.contentType = "Review"
                                let param = dic["urlParams"] as! NSDictionary
                                var tempDic = NSDictionary()
                                if let reviewid = param["review_id"] as? Int
                                {
                                    tempDic = ["listingtype_id" : "\(self.listingTypeId!)","review_id":"\(reviewid)"]
                                }
                                presentedVC.param = tempDic as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                                
                            case "close":
                                confirmationAlert = false
                                Reload = "Not Refresh"
                                
                                let params = ["close": 1]
                                self.performListingMenuAction(params as NSDictionary, url: dic["url"] as! String)
                                
                            case "open":
                                confirmationAlert = false
                                Reload = "Not Refresh"
                                
                                let params = ["close": 0]
                                self.performListingMenuAction(params as NSDictionary, url: dic["url"] as! String)
                                
                            case "subscribe":
                                
                                Reload = "Not Refresh"
                                confirmationAlert = false
                                var message = ""
                                let title = dic["label"] as! String
                                message = String(format: NSLocalizedString("You have successfully subscribed to %@!", comment: ""), title)
                                params["listingtype_id"] = self.listingTypeId as AnyObject?
                                params["message"] = message as AnyObject?
                                
                                self.performListingMenuAction(params as NSDictionary, url: dic["url"] as! String)
                                
                                
                            case "unsubscribe":
                                
                                Reload = "Not Refresh"
                                confirmationAlert = false
                                
                                var message = ""
                                let title = dic["label"] as! String
                                message = String(format: NSLocalizedString("You have successfully subscribed to %@!", comment: ""), title)
                                params["message"] = message as AnyObject?
                                params["listingtype_id"] = self.listingTypeId as AnyObject?
                                self.performListingMenuAction(params as NSDictionary, url: dic["url"] as! String)
                                
                            case "favourite":
                                Reload = "Not Refresh"
                                confirmationAlert = false
                                var message = ""
                                let title = dic["label"] as! String
                                message = String(format: NSLocalizedString("You have successfully", comment: ""), title)
                                params["listingtype_id"] = self.listingTypeId as AnyObject?
                                params["message"] = message as AnyObject?
                                let paramdic = (dic["urlParams"] as! NSDictionary)
                                params["listing_id"] = paramdic["listing_id"] as AnyObject?
                                self.performListingMenuAction(params as NSDictionary, url: dic["url"] as! String)
                                
                            case "claim":
                                
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Claim Listing", comment: "")
                                presentedVC.contentType = "Listings claim"
                                presentedVC.listingTypeId = self.listingTypeId
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            case "share":
                                //confirmationAlert = false
                                let presentedVC = AdvanceShareViewController()
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                presentedVC.Sharetitle = self.shareTitle
                                presentedVC.ShareDescription = self.detailWebView.text
                                presentedVC.imageString = self.coverImageUrl
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)

                            case "apply-now":
                                confirmationAlert = false
                                isCreateOrEdit = true
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Apply job", comment: "")
                                presentedVC.contentType = "applynow"
                                let tempDic = NSDictionary()
                                presentedVC.param = tempDic
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                                
                            case "makePayment":
                                
                                confirmationAlert = false
                                let presentedVC = ExternalWebViewController()
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let navigationController = UINavigationController(rootViewController: presentedVC)
                                self.present(navigationController, animated: true, completion: nil)
                                
                            case "upgrade_package":
                                let presentedVC = PackageViewController()
                                presentedVC.contentType = "listings"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.urlParams = dic["urlParams"] as! NSDictionary
                                presentedVC.listingTypeId = self.listingTypeId
                                presentedVC.isUpgradePackageScreen = true
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                            if confirmationAlert == true {
                                displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                    // self.updateContentAction(param,url: url)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            
                        }))
                        
                    }
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
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    func performListingMenuAction(_ params: NSDictionary, url: String){
        
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
            
            for (key, value) in params{
                
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
                        // On Success Update Listing Detail
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if self.deleteListingEntry == true{
                            listingUpdate = true
                            listingDetailUpdate = true
                            feedUpdate = true
                            _ = self.navigationController?.popViewController(animated: false)
                            
                            //self.createTimer(self)
                            return
                        }
                        self.exploreContent()
                        
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //
    }
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
       // UIApplication.shared.openURL(url!)
       
            let presentedVC = ExternalWebViewController()
            presentedVC.url = url.absoluteString
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated: true, completion: nil)
        
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithPhoneNumber phoneNumber: String!) {
        //print("\(phoneNumber)")
        if let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.openURL(url)
        }
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String , timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    

    @objc func applyJob()
    {
        if self.applyUrl != nil
        {
        isCreateOrEdit = true
        let presentedVC = FormGenerationViewController()
        presentedVC.formTitle = NSLocalizedString("Apply job", comment: "")
        presentedVC.contentType = "applynow"
        presentedVC.url = self.applyUrl
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:false, completion: nil)
        }
    }
    
    @objc func performReviewOrWishlistAction(_ sender:UIButton){
        switch (sender.tag)
        {
        case 59:
            
            let presentedVC = AdvancePostFeedViewController()
            presentedVC.openfeedStyle = 4
            presentedVC.subjectId = "\(listingId)"
            presentedVC.subjectType = subjectType
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:true, completion: nil)

            break
        case 60:
            
            isCreateOrEdit = true
            globFilterValue = ""
            
            let presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Write a Review", comment: "")
            presentedVC.contentType = "Review"
            var tempDic = NSDictionary()
            tempDic = ["listingtype_id" : String(self.listingTypeId)]
            presentedVC.param = tempDic as! [AnyHashable : Any] as NSDictionary
            presentedVC.url = self.urlDictionary["reviewUrl"]
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:false, completion: nil)
            
        case 61:
            
            isCreateOrEdit = true
            globFilterValue = ""
            
            let presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Update Review", comment: "")
            presentedVC.contentType = "Review"
            
            let reviewid = reviewId
            var tempDic = NSDictionary()
            tempDic = ["listingtype_id" : "\(self.listingTypeId!)","review_id":"\(String(describing: reviewid!))"]
            presentedVC.param = tempDic as! [AnyHashable : Any] as NSDictionary
            presentedVC.url = self.urlDictionary["reviewUrl"]
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:false, completion: nil)

            break
        case 62:
            
            let presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Add To Wishlist", comment: "")
            presentedVC.contentType = "wishlist"
            let tempDic = ["listing_id" : self.listingId, "listingtype_id" : self.listingTypeId] as [String : Any]
            presentedVC.param = tempDic as NSDictionary
            presentedVC.url = self.urlDictionary["wishlistUrl"]
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:false, completion: nil)
            break
        default:
            break
        }
    }

 
}
