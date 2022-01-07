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
//  ContentFeedViewController.swift
//  seiosnativeapp
//


import UIKit
import EventKit
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

var contentFeedUpdate:Bool!
var subject_unique_id : String!
var subject_unique_type : String!
var shareLimit : Int = 30
var globalCatg = ""
var sitevideoPluginEnabled_event : Int = 0
var video_clicked : Int = 0

class ContentFeedViewController: UIViewController, UINavigationControllerDelegate, TTTAttributedLabelDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UITableViewDelegate,UITabBarControllerDelegate {
    
    
    var eventMoreOrLess:UIButton!
    var groupMoreOrLess:UIButton!
    var subjectId:String = ""                         // For use Activity Feed updates in Other Modules
    var subjectType:String = ""
    
    var showSpinner = true                      // show spinner flag for pull to refresh
    var refresher:UIRefreshControl!             // Refresher for Pull to Refresh
    var maxid:Int!                              // MaxID for Pagination
    var minid:Int = 0                            // MinID for New Feeds
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
    var contentUrl : String!
    var shareDescription : String!
    var coverImageUrl : String!
    var addEventToDiary = -1
    var mainSubView:UIView!
    var coverImage:UIImageView!
    var contentName:UILabel!
    var tabsContainerMenu:UIScrollView!
    var headerHeight:CGFloat = 0
    var categoryMember : TTTAttributedLabel!
    var descriptionContent : UITextView!
    var maxHeight : CGFloat!
    var contentTitle : String!
    var shareTitle:String!
    var joinlabel : UILabel!
    var navBarTitle : UILabel!
    var user_id : Int!
    var marqueeHeader : MarqueeLabel!
    var descriptionGroupCompleteContent : String!
    
    var hostName : UILabel!
    var hostedBy : UILabel!
    var eventInfo1 : TTTAttributedLabel!
    var eventInfo2 : TTTAttributedLabel!
    var eventInfo3 : TTTAttributedLabel!
    
    let offset_HeaderStop:CGFloat = 40.0 // At this offset the Header stops its transformations
    let offset_B_LabelHeader:CGFloat = 320.0 // At this offset the Black label reaches the Header
    let distance_W_LabelHeader:CGFloat = 100.0 // The distance between the bottom of the Header and the top of the White Label
    var bookNowEnabled = false
    var contentview : UIView!
    
    var contentDescription : String!
    var deleteContent : Bool!
    var popAfterDelay:Bool!
    var showFulldescription = false
    var contentExtraInfo: NSDictionary!
    
    var rsvp:UIView!
    var profile_rsvp_value = 0
    
    var transparentView :UIView!
    var contentGutterMenu: NSArray = []
    var join_rsvp:Int!
    var joinFlag = false
    
    var topView: UIView!
    
    var EventStatulabel: UILabel!
    var imgUser: UIImageView!
    
    var shareUrl : String!
    var shareParam : NSDictionary!
    var info : UILabel!
    var canInviteEventOrGroup = false
    var cameraBtn:UIButton!
    var subView : UIView!
    var guid : String!
    var ownerCheckId : Int! = 0
    var toastView : UIView!
    var rightBarButtonItem: UIBarButtonItem!
    
    
    var UserId:Int!
   // var imageCache = [String:UIImage]()
    var titleshow :Bool  = false
    var titleHeight:CGFloat = 0
    var temptitleInfo : String = ""
    var action_id:Int!
    var actionIdArray = [Int]()
    var noCommentMenu:Bool = false
    var isshowrsvp :String = "true"
    var eventinfoHeight:CGFloat = 0
    var feedObj = FeedTableViewController()
    var addedToCalandar: [Int] = []
    let subscriptionNoticeLinkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.gray,
        // NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    let subscriptionNoticeActiveLinkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.80),
        //NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    //For Rating
    var ratingView : UIView!
    var rated: Bool!
    var responsedic:NSDictionary!
    var leftBarButtonItem : UIBarButtonItem!
    //FOR GROUP OR EVENT PROFILE PROFILE TAB MENUS
    var groupEventProfileTabMenu: NSArray = []
    
    // For Cover Photo
    
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

    // Floating Message Button Variables
    var btnFloaty = UIButton()
    var FloatybtnUI = UIView()
    var imgIcon = UILabel()

    // Initialize Class
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableViewFrameType = "ContentFeedViewController"
        
        view.backgroundColor = aafBgColor
        navigationController?.navigationBar.isHidden = false
        maxid = 0       // Set Default maxid for browseFeed
        maxidTikTok = 0
        contentFeedUpdate = true
        category_filterId = nil
        popAfterDelay = false
        searchDic.removeAll(keepingCapacity: false)
        groupUpdate = false
        eventUpdate = false
        self.tabBarController?.delegate = self
        
        subject_unique_id = subjectId
        if subjectType == "advancedevents"
        {
            subject_unique_type = "siteevent_event"
        }
        else
        {
            subject_unique_type = subjectType
        }

        self.contentTitle = NSLocalizedString("Loading...", comment: "" )
        contentFeedArray.removeAll(keepingCapacity: false)
        self.feedObj.globalArrayFeed = contentFeedArray
        
        self.navigationItem.rightBarButtonItem = nil
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ContentFeedViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        feedObj.willMove(toParent: self)
        self.view.addSubview(feedObj.view)
        self.addChild(feedObj)
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            mainSubView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 370), borderColor: borderColorDark, shadow: false)
        }else{
            mainSubView = createView(CGRect(x: 0,y: 0, width: view.bounds.width, height: 270), borderColor: borderColorLight, shadow: false)
            mainSubView.layer.borderWidth = 0.0
        }
        
        mainSubView.backgroundColor = aafBgColor
        feedObj.tableView.addSubview(mainSubView)
        
        coverImage =   CoverImageViewWithGradient(frame:CGRect(x: 0, y: 0, width: mainSubView.bounds.width, height: mainSubView.bounds.height))
        
        coverImage.contentMode = UIView.ContentMode.scaleAspectFill
        coverImage.layer.masksToBounds = true
        coverImage.tag = 123
        coverImage.backgroundColor = placeholderColor
        coverImage.isUserInteractionEnabled = true
        mainSubView.addSubview(coverImage)
        
        contentview = createView(CGRect(x: 0, y: coverImage.bounds.height-45, width: view.bounds.width, height: 115), borderColor: UIColor.clear, shadow: false)
        contentview.backgroundColor = UIColor.clear
        coverImage.addSubview(contentview)
        
        
        contentName = createLabel(CGRect(x: contentPADING, y: 0, width: mainSubView.bounds.width - (2 * contentPADING), height: 40), text: "", alignment: .left, textColor: textColorLight)
        contentName.font = UIFont(name: fontBold, size: 30)
        contentName.numberOfLines = 3
        contentName.longPressLabel()
        contentName.layer.shadowColor = shadowColor.cgColor
        contentName.layer.shadowOpacity = shadowOpacity
        contentName.layer.shadowRadius = shadowRadius
        contentName.layer.shadowOffset = shadowOffset
        
        contentview.addSubview(contentName)
        
        if subjectType == "advancedevents"{
            
            cameraBtn = createButton(CGRect(x: coverImage.bounds.size.width-50, y: coverImage.bounds.size.height-30, width: 30, height: 30),title:"\u{f030}" , border: false, bgColor: false,textColor: textColorMedium)
            cameraBtn.backgroundColor = UIColor.clear
            cameraBtn.titleLabel?.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
            cameraBtn.addTarget(self, action: #selector(ContentFeedViewController.changeImageOptions), for: .touchUpInside)
            coverImage.addSubview(cameraBtn)
            cameraBtn.isHidden = true
            
        }
        
        
        joinlabel = createLabel(CGRect(x: mainSubView.bounds.width - 70, y: coverImage.bounds.height-70, width: 50, height: 50), text: "", alignment: .left, textColor: textColorLight)
        joinlabel.numberOfLines = 0
        joinlabel.layer.shadowColor = shadowColor.cgColor
        joinlabel.layer.shadowOpacity = shadowOpacity
        joinlabel.layer.shadowRadius = shadowRadius
        joinlabel.layer.shadowOffset = shadowOffset
        coverImage.addSubview(joinlabel)
        
        
        categoryMember = TTTAttributedLabel(frame: CGRect(x: contentPADING, y: contentview.bounds.height-35, width: mainSubView.bounds.width - (2 * contentPADING), height: 20))
        
        categoryMember.textColor = textColorLight
        categoryMember.font = UIFont(name: fontName, size: 13)
        categoryMember.delegate = self
        contentview.addSubview(categoryMember)
        
        
        
        topView = createView(CGRect(x: 0, y: mainSubView.bounds.height, width: view.bounds.width, height: 70), borderColor: UIColor.clear, shadow: false)
        topView.backgroundColor = lightBgColor
        feedObj.tableView.addSubview(topView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ContentFeedViewController.openProfile))
        topView.addGestureRecognizer(tap)
        
        
        if subjectType == "advancedevents"
        {
            hostedBy = createLabel(CGRect(x: 65, y: 5, width: view.bounds.width, height: 20), text: "Hosted By", alignment: .left, textColor: textColorDark)
            hostedBy.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            topView.addSubview(hostedBy)
            hostName = createLabel(CGRect(x: 65, y: 20, width: view.bounds.width - 75, height: 30), text: "", alignment: .left, textColor: textColorDark)
            hostName.font = UIFont(name: fontName, size: FONTSIZENormal)
            hostName.lineBreakMode = NSLineBreakMode.byTruncatingTail
            topView.addSubview(hostName)
        }
        else
        {
            hostName = createLabel(CGRect(x: 65, y: 20, width: view.bounds.width - 75, height: 30), text: "", alignment: .left, textColor: textColorDark)
            hostName.font = UIFont(name: fontName, size: FONTSIZEMedium)
            hostName.lineBreakMode = NSLineBreakMode.byTruncatingTail
            topView.addSubview(hostName)
            
        }
        
        imgUser = createImageView(CGRect(x: 10, y: 10, width: 50, height: 50), border: true)
        
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.clear.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.clipsToBounds = true
        imgUser.image = UIImage(named: "user_profile_image.png")
        topView.addSubview(imgUser)
        
        if(self.subjectType != "group"){
            topView.isHidden = true
        }
        
        if self.subjectType != "advancedevents"{
            descriptionContent = createTextView(CGRect(x: 0,y: mainSubView.bounds.height+70 , width: topView.bounds.width, height: 100), borderColor: borderColorMedium, corner: false )
            descriptionContent.backgroundColor = bgColor
            //        descriptionContent.delegate = self
            descriptionContent.text = NSLocalizedString("",  comment: "")
            descriptionContent.font = UIFont(name: fontName, size: FONTSIZENormal)
            descriptionContent.textColor = textColorDark
            
            descriptionContent.autocorrectionType = UITextAutocorrectionType.no
            
            groupDescriptionView = TTTAttributedLabel(frame: CGRect(x: PADING ,y: mainSubView.bounds.height+70 + (2 * contentPADING) , width: topView.bounds.width - (2 * PADING), height: 200))
            
            groupDescriptionView.numberOfLines = 0
            groupDescriptionView.backgroundColor = bgColor
            groupDescriptionView.font =  UIFont(name: fontName, size: FONTSIZENormal)
            groupDescriptionView.longPressLabel()
            groupDescriptionView.delegate = self
            groupDescriptionView.textColor = textColorDark
            
            
            feedObj.tableView.addSubview(groupDescriptionView)
            groupMoreOrLess = createButton(CGRect(x: view.bounds.width - 50, y: groupDescriptionView.frame.size.height + mainSubView.bounds.height+70 + (2 * contentPADING) ,  width: 40, height: 30), title: NSLocalizedString("More", comment: ""), border: false,bgColor: false, textColor: navColor)
            groupMoreOrLess.isHidden = true
            groupMoreOrLess.sizeToFit()
            feedObj.tableView.addSubview(groupMoreOrLess)
            groupMoreOrLess.addTarget(self, action: #selector(ContentFeedViewController.detailContentView(_:)), for: .touchUpInside)
            groupMoreOrLess.tag = 1
            groupMoreOrLess.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            
            if(self.subjectType != "group"){
                descriptionContent.isHidden = true
                groupDescriptionView.isHidden = true
                groupMoreOrLess.isHidden = true
            }
            
        }
        
        tabsContainerMenu = UIScrollView(frame: CGRect(x: 0, y: 300,width: view.bounds.width ,height: ButtonHeight ))
        tabsContainerMenu.delegate = self
        tabsContainerMenu.backgroundColor = tableViewBgColor
        tabsContainerMenu.isHidden = true
        tabsContainerMenu.showsHorizontalScrollIndicator = false
        tabsContainerMenu.showsVerticalScrollIndicator = false
        tabsContainerMenu.tag = 222
        feedObj.tableView.addSubview(tabsContainerMenu)
        
        // Create a Feed Filter to perform Feed Filtering
        feedFilter = createButton(CGRect(x: PADING, y: 2*contentPADING , width: view.bounds.width - 2 * PADING, height: ButtonHeight),title: NSLocalizedString("Everyone",  comment: "") , border: false, bgColor: false,textColor: textColorMedium)
        feedFilter.isEnabled = false
        feedFilter.backgroundColor = lightBgColor
        feedFilter.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        feedFilter.isHidden = true
        feedFilter.addTarget(self, action: #selector(ContentFeedViewController.showFeedFilterOptions(_:)), for: .touchUpInside)
        feedObj.tableView.addSubview(feedFilter)
        
        // Filter Icon on Left site
        let filterIcon = createLabel(CGRect(x: feedFilter.bounds.width - feedFilter.bounds.height, y: 0 ,width: feedFilter.bounds.height ,height: feedFilter.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorMedium)
        filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        feedFilter.addSubview(filterIcon)
        
        
        // Initialize Pull to Refresh to ActivityFeed Table
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(ContentFeedViewController.refresh), for: UIControl.Event.valueChanged)
        feedObj.tableView.addSubview(refresher)
        
        // Cover Photo and Profile Photo
        
        camIconOnCover = createLabel(CGRect(x: coverImage.bounds.width - 30, y: coverImage.bounds.height - 30, width: 20, height: 20), text: "\(cameraIcon)", alignment: .center, textColor: textColorLight)
        camIconOnCover.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        camIconOnCover.isHidden = true
        coverImage.addSubview(camIconOnCover)
        
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
        memberProfilePhoto.clipsToBounds = true
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

        self.automaticallyAdjustsScrollViewInsets = false;
        
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

    // Floating Message Button UI
    func floatingMessageButton()
    {
        var lblmsg = UILabel()
        var img = UIImageView()
        
        self.FloatybtnUI = UIView(frame:CGRect(x:self.view.bounds.width-120, y:view.bounds.height-(tabBarHeight+60), width:110, height:40))
        self.FloatybtnUI.layer.borderWidth = 0.5
        self.FloatybtnUI.layer.borderColor = UIColor.gray.cgColor
        self.FloatybtnUI.shadowOffsets = CGSize(width:0.5,height:0.5)
        self.FloatybtnUI.shadowOpacitys = 0.5
        self.FloatybtnUI.layer.cornerRadius = self.FloatybtnUI.frame.height/2
        self.FloatybtnUI.backgroundColor = textColorLight
        self.view.addSubview(self.FloatybtnUI)
        
        self.imgIcon = createLabel(CGRect(x:4, y:4, width:32, height:32), text: "", alignment: .center, textColor: textColorLight)
        self.imgIcon.layer.masksToBounds = false
        self.imgIcon.layer.borderWidth = 1
        self.imgIcon.alpha = 1
        self.imgIcon.layer.borderColor = buttonColor.cgColor
        self.imgIcon.layer.cornerRadius = self.imgIcon.frame.size.height/2
        self.imgIcon.backgroundColor = buttonColor
        self.imgIcon.font = UIFont(name : "FontAwesome", size : FONTSIZENormal)
        self.imgIcon.clipsToBounds = true
        self.FloatybtnUI.addSubview(self.imgIcon)
        
        img = UIImageView(frame: CGRect(x:6, y:6, width:20, height:20))
        
        
        if isChannelizeAvailable{
            img.image = UIImage(named:"channelize_icon")?.maskWithColor(color: textColorLight)
        } else{
            img.image = UIImage(named:"messageIcon")?.maskWithColor(color: textColorLight)
        }
        img.contentMode = .scaleAspectFit
        self.imgIcon.addSubview(img)
        
        lblmsg = createLabel(CGRect(x:getRightEdgeX(inputView:self.imgIcon)+3, y:4, width:self.FloatybtnUI.frame.size.width-(getRightEdgeX(inputView: imgIcon)+4), height:32), text: NSLocalizedString("Message", comment: "" ), alignment: .left, textColor: textColorDark)
        lblmsg.font = UIFont(name : fontBold, size : FONTSIZENormal)
        self.FloatybtnUI.addSubview(lblmsg)
        
        self.btnFloaty = UIButton(frame:CGRect(x:self.view.bounds.width-120, y:view.bounds.height-(tabBarHeight+65), width:110, height:40))
        self.btnFloaty.addTarget(self, action: #selector(self.clickOnFloatyMsgButton), for: UIControl.Event.touchUpInside)
        self.view.addSubview(self.btnFloaty)
    }
    
    // Floating Message Button Action
    @objc func clickOnFloatyMsgButton()
    {
        if isChannelizeAvailable{
            if let userId = self.user_id{
                let data : [AnyHashable:Any] = [AnyHashable("userId"):userId]
                if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                    let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                    if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                        channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: data)
                    }
                }
            }
        } else{
            let presentedVC = MessageOwnerViewController()
            presentedVC.url = Messag_Url
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    // Show Post Feed Option Selection (Status, Photos, Checkin)
    @objc func openPostFeed(_ sender:UIButton){
        
        
        //stopMyTimer()
        
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
    
    // Perform on Every Time when ActivityFeed View is Appeared
    override func viewWillAppear(_ animated: Bool)
    {
        self.browseEmoji(contentItems: reactionsDictionary)
        //  updateAfterAlert = false
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        removeNavigationImage(controller: self)
        
        if let navigationBar = self.navigationController?.navigationBar
        {
            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
        }
        tableViewFrameType = "ContentFeedViewController"
        NotificationCenter.default.addObserver(self, selector: #selector(ContentFeedViewController.ScrollingactionContentFeed(_:)), name: NSNotification.Name(rawValue: "ScrollingactionContentFeed"), object: nil)
        subject_unique_id = subjectId
        if subjectType == "advancedevents"
        {
            subject_unique_type = "siteevent_event"
        }
        else
        {
            subject_unique_type = subjectType
        }
        
        
        //stopMyTimer()
        //startMyTimer()    // Create Timer for Check UPdtes Repeatlly
        
        if contentFeedUpdate == true{
            IsRedirctToVideoProfile(videoTypeCheck : "AdvEventVideo",navigationController:navigationController!, vc: self)
            // Set Default & request to hard Refresh
            contentFeedUpdate = false
            feedUpdate = false
            maxid = 0
            maxidTikTok = 0
            showSpinner = true
            feed_filter = 1
            exploreContent()
        }
        else
        {
            if logoutUser == false
            {
                globalFeedHeight = getBottomEdgeY(inputView: self.feedFilter) + 3
            }
            else
            {
                globalFeedHeight = getBottomEdgeY(inputView: self.feedFilter)
            }
            self.feedObj.globalArrayFeed = contentFeedArray //feedArray
            if !fromExternalWebView{
                self.feedObj.refreshLikeUnLike = true
                feedObj.tableView.reloadData()
            }else{
                fromExternalWebView = false
            }
        }
      
        maxidTikTok = 0
        API_getAAFList()
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        scrollviewEmojiLikeView.isHidden = true
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
         feedObj.tableView.tableFooterView?.isHidden = true
        self.marqueeHeader.text = ""
        self.navigationItem.rightBarButtonItem = nil
        setNavigationImage(controller: self)
        removeMarqueFroMNavigaTion(controller: self)
        tableViewFrameType = ""
        //stopMyTimer()
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }
    // Show Post Feed Option to User based on Permission from Server & Save these options
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
                var menuIcon = [String]()
                var colorIcon = [UIColor]()
                if postPermission.count > 0{
                    if let status = postPermission["video"] as? Bool{
                        if status{
                            postMenu.append(NSLocalizedString(" Video", comment: ""))
                            menuIcon.append(videoIcon)
                            colorIcon.append(videoIconColor)
                        }
                    }
                    if let photo = postPermission["photo"] as? Bool{
                        if photo{
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
                                colorIcon.append(CheckInIconColor)
                                
                            }
                        }
                    }
                }

                for ob in self.feedObj.tableView.subviews{
                    if ob.tag >= 1991 && ob.tag <= 1993{
                        ob.removeFromSuperview()
                    }
                }
                
                
                //Add Post Feed Option
                for i in 0 ..< postMenu.count {
                    let origin_x = PADING + (CGFloat(i) * ((view.bounds.width - (2 * PADING))/CGFloat(postMenu.count)))
                    let postFeed = createButton(CGRect(x: origin_x, y: tabsContainerMenu.frame.origin.y + tabsContainerMenu.bounds.height + contentPADING, width: view.bounds.width/CGFloat(postMenu.count), height: ButtonHeight - PADING), title: "" , border: false ,bgColor: false, textColor: textColorMedium)
                    if i == 0{
                        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\u{f044}")
                        attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size: 14.0)!, range: NSMakeRange(0, attrString.length))
                        
                        if let descString: NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString(" Status",comment: "")) {
                            if let fontValue = UIFont(name: fontBold , size: 14.0) {
                                descString.addAttribute(NSAttributedString.Key.font, value: fontValue, range: NSMakeRange(0, descString.length))
                            }
                            
                            attrString.append(descString);
                            
                            attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColorMedium, range: NSMakeRange(0, attrString.length))
                        }
                        postFeed.setAttributedTitle(attrString, for: UIControl.State())
                    }else if i == 1{
                        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\u{f030}")
                        attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size: 14.0)!, range: NSMakeRange(0, attrString.length))
                        
                        let descString: NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString(" Photo",comment: ""))
                        if let fontValue = UIFont(name: fontBold , size: 14.0) {
                            descString.addAttribute(NSAttributedString.Key.font, value: fontValue, range: NSMakeRange(0, descString.length))
                        }
                        
                        attrString.append(descString);
                        
                        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColorMedium, range: NSMakeRange(0, attrString.length))
                        postFeed.setAttributedTitle(attrString, for: UIControl.State())
                    }else if i == 2 {
                        let attrString: NSMutableAttributedString = NSMutableAttributedString(string: "\u{f041}")
                        attrString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size: 14.0)!, range: NSMakeRange(0, attrString.length))
                        
                        let descString: NSMutableAttributedString = NSMutableAttributedString(string: NSLocalizedString(" Check In",comment: ""))
                        if let fontValue = UIFont(name: fontBold , size: 14.0) {
                            descString.addAttribute(NSAttributedString.Key.font, value: fontValue, range: NSMakeRange(0, descString.length))
                        }
                        
                        attrString.append(descString);
                        
                        attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColorMedium, range: NSMakeRange(0, attrString.length))
                        postFeed.setAttributedTitle(attrString, for: UIControl.State())
                    }
                    postFeed.backgroundColor = lightBgColor
                    postFeed.tag = i+1 + 1990
                    postFeed.addTarget(self, action: #selector(ContentFeedViewController.openPostFeed(_:)), for: .touchUpInside)
                    feedObj.tableView.addSubview(postFeed)
                }
                
                postMenu.removeAll(keepingCapacity: false)
            }
        }
    }
    
    @objc func changeImageOptions()
    {
        let alertController = UIActionSheet(title: "Choose Option", delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), destructiveButtonTitle: nil, otherButtonTitles:"Gallery","Camera")
        
        alertController.show(in: self.view)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        switch buttonIndex
        {
            
        case 0:
            NSLog("Cancel");
            break;
        case 1:
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
            if UIDevice.current.userInterfaceIdiom != .pad{
                imagePickerController.allowsEditing = true
            }
            self.present(imagePickerController, animated: true, completion: {
                
            })
            
            break;
        case 2:
            NSLog("Camera");
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerController.SourceType.camera
            if UIDevice.current.userInterfaceIdiom != .pad{
                imagePickerController.allowsEditing = true
            }
            self.present(imagePickerController, animated: true, completion: {  
                
            })
            break;
            
        default:
            NSLog("Default");
            break;
    
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
//        for dic in info{
//            if let photoDic = dic as? NSDictionary{
//
//                if photoDic.object(forKey: UIImagePickerController.InfoKey.mediaType) as! String == ALAssetTypePhoto {
//
//                    if (photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) != nil){
//                        let image = photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) as! UIImage
//                        let selectedImage : UIImage = image
//                        coverImage.image = selectedImage
//                    }
//                }
//            }
//
//        }
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let selectedImage : UIImage = image
        coverImage.image = selectedImage
       
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
    {
        if touch.view == cameraBtn
        {
            // we touched a button, slider, or other UIControl
            return false; // ignore the touch
        }
        return true; // handle the touch
        
    }
    
    // Pull to Request Action
    @objc func refresh(){
        DispatchQueue.main.async(execute: {
            soundEffect("Activity")
        })
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            // Pull to Refreh for Recent Feeds (Reset Variables)
            showSpinner = false
            maxid = 0
            maxidTikTok = 0
            //   updateAfterAlert = false
            feed_filter = 1
            browseFeed()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
            
        }
        
    }
    
    // Request to Show New Stories Feed
    @objc func updateNewFeed(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            // Reset Variables
            maxid = 0
            maxidTikTok = 0
            //    updateAfterAlert = false
            feed_filter = 0
            browseFeed()
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            
            
        }
    }
    
    func showtabMenu(){
        
        for ob in tabsContainerMenu.subviews{
            if ob.tag == 101{
                ob.removeFromSuperview()
            }
        }
        
        
        var tempLabelCount = 0
        for tempArray in groupEventProfileTabMenu {
            
            if let tempMenuArr = tempArray as? NSDictionary{
                if tempMenuArr["totalItemCount"] as? Int > 0{
                    tempLabelCount += 1
                }
                if tempMenuArr["name"] as! String == "update"{
                    tempLabelCount += 1
                }
                
                if tempMenuArr["name"] as! String == "info"{
                    tempLabelCount += 1
                }
            }
            
            
        }
        
        var origin_x:CGFloat = 0
        for menu in groupEventProfileTabMenu{
            if let menuItem = menu as? NSDictionary{
                
                var button_title = menuItem["label"] as! String
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                let width = findWidthByText(button_title) + 10
                let menu = createNavigationButton(CGRect(x: origin_x,y: 0 - contentPADING ,width: width , height: tabsContainerMenu.bounds.height + contentPADING) , title: button_title, border: true, selected: false)
                
                if menuItem["name"] as! String == "update"{
                    menu.setSelectedButton()
                }
                else{
                    menu.setUnSelectedButton()
                }
                
                menu.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
                menu.tag = 101
                menu.addTarget(self, action: #selector(ContentFeedViewController.tabMenuAction(_:)), for: .touchUpInside)
                tabsContainerMenu.addSubview(menu)
                origin_x += width
                
            }
        }
        
        tabsContainerMenu.contentSize = CGSize(width: origin_x, height: tabsContainerMenu.bounds.height)
        
    }
    
    @objc func tabMenuAction(_ sender:UIButton){
        for menu in groupEventProfileTabMenu{
            if let menuItem = menu as? NSDictionary{
                var button_title = menuItem["label"] as! String
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                if sender.titleLabel?.text == button_title{
                    
                    if menuItem["name"] as! String == "members"{
                        if self.subjectType != "advancedevents"{
                            let presentedVC = ShowMembersViewController()
                            presentedVC.canInvite = self.canInviteEventOrGroup
                            presentedVC.contentType = subjectType
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.param = Dictionary<String, String>() as NSDictionary?
                            presentedVC.mytitle = "\((self.contentTitle)!)"
                            presentedVC.id = subjectId
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                        else
                        {
                            
                            let presentedVC = ShowMembersViewController()
                            presentedVC.canInvite = self.canInviteEventOrGroup
                            presentedVC.contentType = subjectType
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.ownerId = self.ownerCheckId
                            
                            presentedVC.param = Dictionary<String, String>() as NSDictionary?
                            presentedVC.mytitle = "\((self.contentTitle)!)"
                            presentedVC.id = subjectId
                            presentedVC.guid = self.guid
                            navigationController?.pushViewController(presentedVC, animated: true)
                            
                        }
                    }
                    if menuItem["name"] as! String == "description"
                    {
                        let presentedVC = DescriptionViewController()
                        presentedVC.mytitle = "\((self.contentTitle)!)"
                        presentedVC.subjectId = subjectId
                        presentedVC.headertitle = "Description"
                        presentedVC.url = menuItem["url"] as! String
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    if menuItem["name"] as! String == "overview"
                    {
                        let presentedVC = DescriptionViewController()
                        presentedVC.mytitle = "\((self.contentTitle)!)"
                        presentedVC.subjectId = subjectId
                        presentedVC.url = "\((menuItem["url"])!)"
                        presentedVC.headertitle = "Overview"
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    
                    if menuItem["name"] as! String == "information"
                    {
                        let presentedVC = InfoViewController()
                        presentedVC.mytitle = "\((menuItem["name"])!)"
                        presentedVC.subjectId = subjectId
                        presentedVC.url = "\((menuItem["url"])!)"
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    if menuItem["name"] as! String == "occurence_info"
                    {
                        
                        let presentedVC = DescriptionViewController()
                        presentedVC.mytitle = "\((self.contentTitle)!)"
                        presentedVC.subjectId = subjectId
                        presentedVC.url = "\((menuItem["url"])!)"
                        presentedVC.headertitle = NSLocalizedString("Info", comment: "")
                        navigationController?.pushViewController(presentedVC, animated: true)
                        
                    }
                    
                    if menuItem["name"] as! String == "occurence_index"
                    {
                        
                        if self.subjectType == "advancedevents"
                        {
                            let presentedVC = RepeatEventViewController()
                            
                            presentedVC.contentType = "advancedevents"
                            
                            let tempUrl = menuItem["url"] as! String
                            presentedVC.url = tempUrl
                            presentedVC.eventid = subjectId
                            presentedVC.mytitle = "\((self.contentTitle)!)"
                            presentedVC.guid = self.guid
                            presentedVC.ownerId = self.ownerCheckId
                            
                            self.navigationController?.pushViewController(presentedVC, animated: false)
                        }
                    }
                    
                    if menuItem["name"] as! String == "reviews"
                    {
                        let presentedVC = UserReviewViewController()
                        presentedVC.mytitle = "\((self.contentTitle)!)"
                        presentedVC.subjectId = subjectId
                        presentedVC.contentType = "advancedevents"
                        if let totalItem = menuItem["totalItemCount"] as? Int
                        {
                            if totalItem > 0
                            {
                                presentedVC.count = totalItem
                                
                            }
                            
                        }
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    if menuItem["name"] as! String == "video"{
                        if sitevideoPluginEnabled_event == 1
                        {
                            let presentedVC = AdvanceVideoViewController()
                            presentedVC.user_id = subjectId
                            presentedVC.fromTab = true
                            presentedVC.showOnlyMyContent = false
                            presentedVC.countListTitle = button_title
                            presentedVC.other_module = true
                            presentedVC.videoTypeCheck = "AdvEventVideo"
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.subject_type = menuItem["subject_type"] as! String
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                        else
                        {
                            let presentedVC = VideoBrowseViewController()
                            presentedVC.showOnlyMyContent = true
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.videoTypeCheck = "AdvEventVideo"
                            presentedVC.listingId = "\(subjectId)"
                            presentedVC.fromTab = true
                            presentedVC.countListTitle =  button_title
                            
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }


                    }
                    if menuItem["name"] as! String == "announcement"
                    {
                        let presentedVC = AnnouncementViewController()
                        presentedVC.mytitle = "\((self.contentTitle)!)"
                        presentedVC.subjectId = "\(subjectId)"
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    if menuItem["name"] as! String == "photos"{
                        
                        if self.subjectType == "advancedevents"{
                            let presentedVC = PhotoListViewController()
                            presentedVC.contentType = "siteevent_photo"//"siteevent_event"
                            presentedVC.mytitle = "\((self.contentTitle)!)"
                            presentedVC.url =   menuItem["url"] as! String//"albums/view-content-album"//tempUrl
                            presentedVC.param = ["subject_type" : "siteevent_album","subject_id":subjectId]
                            self.navigationController?.pushViewController(presentedVC, animated: false)
                        }
                        else
                        {
                            let presentedVC = PhotoListViewController()
                            if subjectType == "group"{
                                presentedVC.contentType = "group_photo"
                            } else if subjectType == "event"{
                                presentedVC.contentType = "event_photo"
                            }
                            var tempUrl = menuItem["url"] as! String
                            tempUrl += "/\(subjectId)"
                            presentedVC.mytitle = "\((self.contentTitle)!)"
                            presentedVC.url = tempUrl
                            presentedVC.param = menuItem["urlParams"] as! NSMutableDictionary
                            self.navigationController?.pushViewController(presentedVC, animated: false)
                        }
                        
                    }
                    
                    if menuItem["name"] as! String == "coupons"
                    {
                        let presentedVC = CouponsBrowseViewController()
                        //presentedVC.contentType = "siteevent_photo"
                        let tempUrl = menuItem["url"] as! String
                        presentedVC.content_id = subjectId
                        presentedVC.url = tempUrl
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                    }
                    
                }
            }
        }
    }
    
    // MARK: - Activity Feed Filter Options & Gutter Menu
    
    // Show Feed Filter Options Action
    @objc func showFeedFilterOptions(_ sender: UIButton){
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        
        for menu in gutterMenu{
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
        
    }
    
    // Present Feed Gutter Menus
    
    // MARK: - Activity Feed Actions for Like, Comment & Share
    
    // Update/ Sink contentFeedArray from [ActivityFeed] to show updates in ActivityFeed Table
    func updateFeedsArray(_ feeds:[ActivityFeed]){
        var existingFeedIntegerArray = [Int]()
        for tempFeedArrays in contentFeedArray {
            existingFeedIntegerArray.append(tempFeedArrays["action_id"] as! Int)
        }
        
        
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
            if feed.feed_reactions != nil{
                newDictionary["feed_reactions"] = feed.feed_reactions
            }
            if feed.my_feed_reaction != nil{
                newDictionary["my_feed_reaction"] = feed.my_feed_reaction
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
            
            let actionId  = newDictionary["action_id"] as! Int
            
            if !existingFeedIntegerArray.contains(actionId){
                contentFeedArray.append(newDictionary)
            }
            
        }
        if logoutUser == false
        {
            globalFeedHeight = (self.feedFilter.bounds.height + self.feedFilter.frame.origin.y ) + 3
        }
        else
        {
            globalFeedHeight = (self.feedFilter.bounds.height + self.feedFilter.frame.origin.y )
        }
        self.feedObj.globalArrayFeed = contentFeedArray
        self.feedObj.refreshLikeUnLike = true
        self.feedObj.tableView.reloadData()
        existingFeedIntegerArray.removeAll(keepingCapacity: true)
        
    }
    
    // MARK: - For Event Content Type
    
    @objc func rsvpAction(_ sender:UIButton){
        removeAlert()
        if sender.tag == profile_rsvp_value{
            return
        }
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var parameters: NSDictionary = [:]
            var url = ""
            if subjectType == "advancedevents"{
                
                parameters = ["rsvp":"\(sender.tag)"]
                
                url = "advancedevents/member/join/" + String(self.subjectId)
            }
            else{
                
                parameters = ["rsvp":"\(sender.tag)", "event_id": String(self.subjectId), "profile_rsvp": "1"]
                url = "events/view"
            }
            
            
            post( parameters as! Dictionary<String, String>, url: url, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                            self.profile_rsvp_value = sender.tag
                            self.updateRSVP()
                            
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
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    func updateRSVP()
    {
        let revpOptions = [[" Yes":2],[" Maybe ":1],[" No ":0]]
        var originY:CGFloat = 20 + PADING
        var origin_x:CGFloat = PADING
        let menuWidth = CGFloat((self.rsvp.bounds.width - (8*PADING))/3)
        var rsvpButton = UIButton()
        
        
        for menu in self.contentGutterMenu
        {
            if let menuItem = menu as? NSDictionary
            {
                
                if (menuItem["name"] as! String == "book_now")
                {
                    for view in self.rsvp.subviews {
                        if view.tag == 999 {
                            view.isHidden = true
                        }
                    }
                    let rsvpOption = createButton(CGRect(x: 5, y: originY, width: self.rsvp.bounds.width-15, height: ButtonHeight-PADING), title: "", border: false,bgColor: false, textColor: textColorLight)
                    rsvpOption.backgroundColor = navColor
                    rsvpOption.contentHorizontalAlignment = .center
                    rsvpOption.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
                    rsvpOption.setTitle(NSLocalizedString("Book Now",  comment: ""), for: UIControl.State())
                    rsvpOption.addTarget(self, action: #selector(ContentFeedViewController.RSVPJOINAction(_:)), for: .touchUpInside)
                    rsvpOption.tag = 15
                    self.rsvp.addSubview(rsvpOption)
                    self.bookNowEnabled = true
                }
            }
        }
        if !self.bookNowEnabled  {
            for ob in self.rsvp.subviews{
                if ob.tag == 0 || ob.tag == 1 || ob.tag == 2 {
                    ob.removeFromSuperview()
                }
            }
        for rsvpOption in revpOptions{
            for (key, value) in rsvpOption {
               
                rsvpButton = createButton(CGRect(x: origin_x, y: originY, width: menuWidth , height: ButtonHeight - PADING), title: "\(key)", border: true,bgColor: false, textColor: textColorLight)
                rsvpButton.addTarget(self, action: #selector(ContentFeedViewController.rsvpAction(_:)), for: .touchUpInside)
                rsvpButton.backgroundColor = lightBgColor
                self.rsvp.bringSubviewToFront(rsvpButton)
                rsvpButton.layer.cornerRadius = rsvpButton.frame.size.width / 2;
                rsvpButton.clipsToBounds = true
                rsvpButton.layer.borderWidth = 2.5
                rsvpButton.layer.masksToBounds = true
                rsvpButton.layer.cornerRadius = 5.0
                
                rsvpButton.contentHorizontalAlignment = .center
                rsvpButton.titleLabel?.font = UIFont(name: fontNormal, size: FONTSIZENormal)
                rsvpButton.layer.borderWidth = borderWidth
                rsvpButton.layer.borderColor = navColor.cgColor
                rsvpButton.tag = value as Int
                if self.profile_rsvp_value == value as Int{
                    rsvpButton.setTitle(" \(key)", for: UIControl.State())
                    rsvpButton.backgroundColor =  buttonColor
                    rsvpButton.setTitleColor(UIColor.white, for: UIControl.State())
                }else{
                    rsvpButton.setTitle(" \(key)", for: UIControl.State())
                    rsvpButton.backgroundColor =  UIColor.white
                    rsvpButton.setTitleColor(buttonColor, for: UIControl.State())
                }
                
                self.rsvp.addSubview(rsvpButton)
                origin_x += menuWidth + (2*PADING)
                
            }
            
        }
        }
        self.rsvp.layer.borderWidth = 3
        if subjectType == "advancedevents"
        {
            
            originY += ButtonHeight - PADING + 10
            let addToDairy = createButton(CGRect(x: 5, y: originY, width: self.rsvp.bounds.width-15, height: ButtonHeight-PADING), title: "Add To Diary", border: false,bgColor: false, textColor: textColorPrime)
            addToDairy.addTarget(self, action: #selector(ContentFeedViewController.addToDairyAction(_:)), for: .touchUpInside)
            addToDairy.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
            addToDairy.backgroundColor = navColor
           // self.rsvp.addSubview(addToDairy)
            
            
            let addToCalender = createButton(CGRect(x: 5, y: getBottomEdgeY(inputView: addToDairy)+PADING, width: self.rsvp.bounds.width-15, height: ButtonHeight-PADING), title: "Add To Calendar", border: false,bgColor: false, textColor: textColorPrime)
            addToCalender.addTarget(self, action: #selector(ContentFeedViewController.addToCalenderAction(_:)), for: .touchUpInside)
            addToCalender.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
            addToCalender.backgroundColor = navColor
            self.rsvp.addSubview(addToCalender)
            self.rsvp.bringSubviewToFront(addToCalender)
            if let calenderids = UserDefaults.standard.object(forKey: "eventids")
            {
                addedToCalandar = calenderids as! [Int]
                if addedToCalandar.contains(Int(subjectId) ?? 0)
                {
                    addToCalender.setTitle("Added To Calendar", for: .normal)
                    addToCalender.isEnabled = false
                    addToCalender.backgroundColor = navColor
                    addToCalender.alpha = 0.2
                }
             
            }
            if self.addEventToDiary == 1  || self.addEventToDiary == -1 {
                self.rsvp.addSubview(addToDairy)
            }
            else if self.addEventToDiary == 0 {
                addToCalender.frame.origin.y = originY
                self.rsvp.frame.size.height = getBottomEdgeY(inputView: addToCalender) + 10
            }

            for tempMenu in self.contentGutterMenu
            {
                if let tempDic = tempMenu as? NSDictionary
                {
                    
                    if tempDic["name"] as! String == "createReview" || tempDic["name"] as! String == "updateReview"
                    {
                        let writeReview = createButton(CGRect(x: 5, y: originY, width: self.rsvp.bounds.width/2-10, height: ButtonHeight-PADING), title: "Write a Review", border: false,bgColor: false, textColor: textColorPrime)
                        if tempDic["name"] as! String == "createReview"
                        {
                            writeReview.setTitle("Write a Review", for: UIControl.State())
                        }
                        else
                        {
                            writeReview.setTitle("Update Review", for: UIControl.State())
                        }
                        
                        writeReview.backgroundColor = navColor
                        writeReview.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
                        writeReview.addTarget(self, action: #selector(ContentFeedViewController.writeReviewAction(_:)), for: .touchUpInside)
                        self.rsvp.addSubview(writeReview)
                        
                        self.rsvp.frame.size.height = getBottomEdgeY(inputView: writeReview) + 10
                        addToDairy.frame = CGRect(x: self.rsvp.bounds.width/2, y: originY, width: self.rsvp.bounds.width/2-10, height: ButtonHeight-PADING)
                        
                        
                    }
                }
            }
        }
        
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
            post(["subject_type": "siteevent_event" , "subject_id": String(subjectId) , "special": "both" , "cover_photo" : String(coverValue) , "profile_photo" : String(profileValue)], url: "coverphoto/get-cover-photo-menu", method: "GET") { (succeeded, msg) -> () in
                
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
                        
                        
                        //self.detailWebView.loadHTMLString((succeeded["body"] as! String), baseURL: nil)
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
                                presentedVC.contentType = "siteevent_event"
                                presentedVC.contentId = self.subjectId
                                presentedVC.showCameraButton = false
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "choose_from_album":
                                
                                let presentedVC = ChoosePhotoViewController()
                                presentedVC.showOnlyMyContent = true
                                presentedVC.contentId = self.subjectId
                                presentedVC.contentType = "siteevent_event"//self.subjectType
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
                                presentedVC.contentType = "siteevent_event"
                                presentedVC.contentId = self.subjectId
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
    
    func updateEventInfo(_ response:NSDictionary)
    {
        
        for ob in self.feedObj.tableView.subviews{
            if ob.tag == 5001{
                ob.removeFromSuperview()
            }
        }
        let eventInfoSequence = ["starttime","location","category"]
        var origin_y:CGFloat = (self.mainSubView.bounds.height +  self.mainSubView.frame.origin.y + PADING)
        
        let topView = createView(CGRect(x: 0, y: origin_y - contentPADING, width: view.bounds.width, height: 70), borderColor: UIColor.clear, shadow: false)
        topView.backgroundColor = lightBgColor
        feedObj.tableView.addSubview(topView)
        
        
        var ownerTitle = ""
        var urlstring = ""
        if let hostDic = response["host"] as? NSDictionary
        {
            let imageDic = hostDic["image_icon"] as! NSDictionary
            // Setting Host image
            urlstring = imageDic["image"] as! String
            ownerTitle = hostDic["host_title"] as! String
            
        }
        else
        {
             ownerTitle = response["owner_title"] as! String
             urlstring = response["owner_image_normal"] as! String
        }
        if subjectType == "advancedevents"
        {
            
            hostedBy = createLabel(CGRect(x: 65, y: 5, width: view.bounds.width, height: 20), text: "Hosted By", alignment: .left, textColor: textColorDark)
            topView.addSubview(hostedBy)
            hostName = createLabel(CGRect(x: 65, y: 20, width: view.bounds.width, height: 30), text: ownerTitle, alignment: .left, textColor: textColorDark)
            hostName.font = UIFont(name: fontName, size: FONTSIZEMedium)
            topView.addSubview(hostName)
        }
        else
        {
            hostName = createLabel(CGRect(x: 65, y: 20, width: view.bounds.width, height: 30), text:ownerTitle, alignment: .left, textColor: textColorDark)
            hostName.font = UIFont(name: fontName, size: FONTSIZENormal)
            topView.addSubview(hostName)
            
        }
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ContentFeedViewController.openProfile))
        topView.addGestureRecognizer(tap)
        
        
        imgUser = createImageView(CGRect(x: 10, y: 10, width: 50, height: 50), border: true)
        
        // imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.clear.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.clipsToBounds = true
        imgUser.image = UIImage(named: "user_profile_image.png")
        topView.addSubview(imgUser)
        
        
        if subjectType == "advancedevents"
        {
            ratingView = createView(CGRect(x: hostName.frame.origin.x, y: hostName.frame.origin.y+15, width: 150, height: 20), borderColor: UIColor.clear, shadow: false)
            ratingView.backgroundColor = UIColor.clear
            topView.addSubview(ratingView)
            if let rating = response["rating_avg"] as? Int
            {
                self.rated = true
                self.updateRating(rating, ratingCount: (response["rating_avg"] as? Int)!)
            }
            
        }
        
        if let url = URL(string: urlstring){
            self.imgUser.kf.indicatorType = .activity
             (self.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            self.imgUser.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                if let img = image{
                    self.imgUser.image = imageWithImage(img, scaletoWidth: self.coverImage.bounds.width)
                }
                
            })
        }

        origin_y += 70
        let location1 = response["location"] as? String
        let categ1 = response["category_title"] as? String
        if location1 != "" && location1 != nil{
            for event in eventInfoSequence{
                eventInfo1 = TTTAttributedLabel(frame: CGRect(x: 2 * PADING, y: origin_y, width: self.view.bounds.width/2 - PADING, height: 55))
                eventInfo1.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
                eventInfo1.font = UIFont(name: "FontAwesome", size:FONTSIZENormal )
                eventInfo1.backgroundColor = textColorclear//bgColor
                eventInfo1.numberOfLines = 0
                eventInfo1.longPressLabel()
                eventInfo1.tag = 5001
                eventInfo1.textColor = textColorMedium
                
                self.feedObj.tableView.addSubview(eventInfo1)
                
                eventInfo2 = TTTAttributedLabel(frame: CGRect(x: self.view.bounds.width/2 + 2 * PADING, y: origin_y, width: self.view.bounds.width/2 - 4 * PADING, height: 55))
                eventInfo2.font = UIFont(name: fontName, size:FONTSIZENormal )
                eventInfo2.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
                eventInfo2.backgroundColor = textColorclear//bgColor
                eventInfo2.longPressLabel()
                eventInfo2.numberOfLines = 0
                eventInfo2.tag = 5001
                eventInfo2.textColor = textColorMedium
                self.feedObj.tableView.addSubview(eventInfo2)
                
                
                
                var tempInfo = ""
                var locationInfo = ""
                var location = ""
                var boldText  = ""
                if event == "starttime"{
                    if let info = response["\(event)"] as? String{
                        
                        let date = dateDifferenceWithEventTime(info)
                        var dateArray = date.components(separatedBy: ", ")
                        //                    boldText += dateArray[0]
                        if let info1 = response["endtime"] as? String{
                            let date1 = dateDifferenceWithEventTime(info1)
                            
                            var dateArray1 = date1.components(separatedBy: ", ")
                            
                            tempInfo = "\(boldText)"
                            
                            
                           // tempInfo = "\(boldText)"
                            boldText += NSLocalizedString("\u{f073}  Date\n\n", comment: "")
                            boldText += "\(dateArray[1]) \(dateArray[0]) \(dateArray[2]) at \(dateArray[3]) to \n\(dateArray1[1]) \(dateArray1[0]) \(dateArray1[2]) at \(dateArray1[3]) "
                            tempInfo += boldText
                        }
                        var string :String! = ""
                        var showString = ""
                        if (response["status"]  != nil){
                            string = response["status"] as! String
                            if string == "This occurrence is ongoing" || string == "This occurrence has not started"
                            {
                                tempInfo += "\n\n\(string!)\n"
                                showString = "\n\n\(string!)\n"
                            }
                            else
                            {
                                tempInfo += "\n\n\(string!)\n"
                                showString = "\n\n\(string!)\n"
                            }
                        }
                        var colorCode = textColorDark
                        if (response["status_color"] != nil){
                        if response["status_color"] as! String == "R"
                        {
                          colorCode = UIColor.red
                        }
                        if response["status_color"] as! String == "G"
                        {
                                colorCode = UIColor(red: 44/255.0, green: 113/255.0, blue: 80/255.0, alpha: 1.0)
                        }
                        if response["status_color"] as! String == "B"
                        {
                                colorCode = navColor
                        }
                        }
                        
                        
                        let iconFont = CTFontCreateWithName(("fontAwesome" as CFString?)!, FONTSIZENormal, nil)
                        let textFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                        let iconPart = NSMutableAttributedString(string: "\(boldText)", attributes: [NSAttributedString.Key.font:iconFont ,  NSAttributedString.Key.foregroundColor : textColorDark])
                        
                        let textPart = NSMutableAttributedString(string: "  \(showString)", attributes: [NSAttributedString.Key.font:textFont , NSAttributedString.Key.foregroundColor : colorCode])
                        iconPart.append(textPart)
                        eventInfo2.attributedText = iconPart

                        
                    }
                }
                
                if  event == "location"{
                    if let info = response["\(event)"] as? String{
                        if info != ""{
                            //  locationInfo = "\u{f041} Location\n\n \(info)"
                            locationInfo = NSLocalizedString("\u{f041} Location\n\n", comment: "")
                            locationInfo += info
                            location = info
                            
                            eventInfo1.setText(locationInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZESmall, nil)
                                
                                let range = (locationInfo as NSString).range(of: NSLocalizedString("\(info)", comment: ""))
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                                // TODO: Clean this up...
                                return mutableAttributedString
                            })
                        }
                    }
                }
                
                let range = (locationInfo as NSString).range(of: NSLocalizedString("\(location)",  comment: ""))
                eventInfo1.delegate = self
                
                eventInfo1.addLink(toTransitInformation: [ "type" : "map", "location":"\(location)","place_id" : ""], with:range)
                eventInfo1.lineBreakMode = NSLineBreakMode.byWordWrapping
                
                eventInfo1.sizeToFit()
                eventInfo2.sizeToFit()
                
                view.layer.masksToBounds = true
                if event == "starttime"
                {
                    eventinfoHeight = eventInfo2.frame.size.height + 10
                }
                if eventInfo2.frame.size.height > eventinfoHeight
                {
                    eventinfoHeight = eventInfo2.frame.size.height + 10
                }
                if eventInfo1.frame.size.height > eventinfoHeight
                {
                    eventinfoHeight = eventInfo1.frame.size.height + 10
                }
                
                
            }
            if eventinfoHeight>0
            {
                origin_y = origin_y  + eventinfoHeight + 5
            }
            else
            {
                origin_y = origin_y  + 90
            }
            
            let lineView = UIView(frame: CGRect(x: 0,y: origin_y,width: view.frame.size.width,height: 0.5))
            lineView.layer.borderWidth = 0.5
            
            lineView.layer.borderColor = textColorMedium.cgColor
            
            self.feedObj.tableView.addSubview(lineView)
            
            let lineView1 = UIView(frame: CGRect(x: (view.frame.size.width)/2,y: 337,width: 0.5,height: origin_y - 337))
            lineView1.layer.borderWidth = 0.5
            
            lineView1.layer.borderColor = textColorMedium.cgColor
            
            self.feedObj.tableView.addSubview(lineView1)
            
            
            if subjectType != "advancedevents"{
                for event in eventInfoSequence{
                    
                    var categoryTitle = ""
                    var categoryInfo = ""
                    
                    eventInfo3 = TTTAttributedLabel(frame: CGRect(x: 2 * PADING, y: origin_y + 10 , width: (self.view.bounds.width - (3 * PADING)), height: 30))
                    eventInfo3.font = UIFont(name: "FontAwesome", size:14.0 )
                    eventInfo3.longPressLabel()
                    eventInfo3.backgroundColor = bgColor
                    eventInfo3.numberOfLines = 0
                    eventInfo3.tag = 5001
                    eventInfo3.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
                    eventInfo3.textColor = textColorMedium
                    
                    self.feedObj.tableView.addSubview(eventInfo3)
                    
                    
                    
                    if  event == "category"{
                        
                        if let category = response["category_title"] as? String{
                            globalCatg = category
                            categoryTitle = category
                            if category != "" {
                                let text = String(format: NSLocalizedString("%@  Category: ", comment:""),"\u{f1c0}")
                                categoryInfo += text//NSLocalizedString("\u{f1c0}  Category: ", comment: "")
                                categoryInfo += category
                            }
                        }
                        
                        eventInfo3.setText(NSLocalizedString("\(categoryInfo)", comment: ""), afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                            let boldFont = CTFontCreateWithName( (fontBold as CFString?)! , FONTSIZENormal, nil)
                            
                            let range = (categoryInfo as NSString).range(of: NSLocalizedString("\(categoryTitle)", comment: ""))
                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                            // TODO: Clean this up...
                            return mutableAttributedString
                        })
                        if categoryTitle != "" {
                            let range1 = (categoryInfo as NSString).range(of: categoryTitle)
                            eventInfo3.delegate = self
                            eventInfo3.addLink(toTransitInformation: ["type" : "catgory", "category_id": response["category_id"] as! Int], with:range1)
                        }
                        
                    }
                    
                    
                }
                
                origin_y +=   eventInfo3.bounds.height + 10
                
                
                if categ1 != nil && categ1 != ""{
                    
                    origin_y += (contentPADING - 2)
                }
                else
                {
                    origin_y += (contentPADING - 2) - 30
                }
            }
            
        }
        else
        {
            for event in eventInfoSequence
            {
                
                eventInfo1 = TTTAttributedLabel(frame: CGRect(x: 2 * PADING, y: origin_y, width: self.view.bounds.width/2 - PADING, height: 55))
                
                eventInfo1.font = UIFont(name: "FontAwesome", size:14.0 )
                eventInfo1.backgroundColor = textColorclear//bgColor
                eventInfo1.numberOfLines = 0
                eventInfo1.tag = 5001
                eventInfo1.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
                eventInfo1.textColor = textColorMedium
                eventInfo1.isHidden = true
                
                self.feedObj.tableView.addSubview(eventInfo1)
                
                eventInfo2 = TTTAttributedLabel(frame: CGRect(x: 10, y: origin_y, width: self.view.bounds.width - PADING, height: 55))
                eventInfo2.font = UIFont(name: fontName, size:14.0 )
                eventInfo2.backgroundColor = textColorclear//bgColor
                eventInfo2.numberOfLines = 0
                eventInfo2.tag = 5001
                eventInfo2.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
                eventInfo2.textColor = textColorMedium
                
                self.feedObj.tableView.addSubview(eventInfo2)
                
                var tempInfo = ""
                var locationInfo = ""
                var location = ""
                var boldText  = ""
                
                if event == "starttime"{
                    if let info = response["\(event)"] as? String{
                        
                        let date = dateDifferenceWithEventTime(info)
                        
                        
                        var dateArray = date.components(separatedBy: ", ")
                        
                        if let info1 = response["endtime"] as? String{
                            let date1 = dateDifferenceWithEventTime(info1)
                            var dateArray1 = date1.components(separatedBy: ", ")
                            
                            tempInfo = "\(boldText)"
                            boldText += NSLocalizedString("\u{f073}  Date\n\n", comment: "")
                            boldText += "\(dateArray[1]) \(dateArray[0]) \(dateArray[2]) at \(dateArray[3]) to \(dateArray1[1]) \(dateArray1[0]) \(dateArray1[2]) at \(dateArray1[3]) "
                            tempInfo += boldText
                        }
                        var string :String! = ""
                        var showString = ""
                        if (response["status"]  != nil){
                            string = response["status"] as! String
                            if string == "This occurrence is ongoing" || string == "This occurrence has not started"
                            {
                                tempInfo += "\n\n\(string!)\n"
                                showString = "\n\n\(string!)\n"
                            }
                            else
                            {
                                tempInfo += "\n\n\(string!)\n"
                                showString = "\n\n\(string!)\n"
                            }
                        }
                        var colorCode = textColorDark
                        if (response["status_color"] != nil){
                            if response["status_color"] as! String == "R"
                            {
                                colorCode = UIColor.red
                            }
                            if response["status_color"] as! String == "G"
                            {
                                colorCode = UIColor(red: 44/255.0, green: 113/255.0, blue: 80/255.0, alpha: 1.0)
                            }
                            if response["status_color"] as! String == "B"
                            {
                                colorCode = navColor
                            }
                        }
                        
                        
                        let iconFont = CTFontCreateWithName(("fontAwesome" as CFString?)!, FONTSIZENormal, nil)
                        let textFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                        let iconPart = NSMutableAttributedString(string: "\(boldText)", attributes: [NSAttributedString.Key.font:iconFont ,  NSAttributedString.Key.foregroundColor : textColorDark])
                        
                        let textPart = NSMutableAttributedString(string: "  \(showString)", attributes: [NSAttributedString.Key.font:textFont , NSAttributedString.Key.foregroundColor : colorCode])
                        iconPart.append(textPart)
                        eventInfo2.attributedText = iconPart
                        
                        

                    }
                }
                if  event == "location"{
                    if let info = response["\(event)"] as? String{
                        if info != ""{
                            
                            locationInfo = NSLocalizedString("\u{f041} Location\n\n", comment: "")
                            locationInfo += info
                            location = info
                            
                            eventInfo1.setText(locationInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                let boldFont = CTFontCreateWithName(("FontName" as CFString?)!, FONTSIZENormal, nil)
                                
                                let range = (locationInfo as NSString).range(of: NSLocalizedString("\(info)", comment: ""))
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                                // TODO: Clean this up...
                                return mutableAttributedString
                            })
                        }
                    }
                }
                
                let range = (locationInfo as NSString).range(of: NSLocalizedString("\(location)",  comment: ""))
                eventInfo1.delegate = self
                eventInfo1.addLink(toTransitInformation: [ "type" : "map", "location":"\(location)","place_id" : ""], with:range)
                eventInfo1.lineBreakMode = NSLineBreakMode.byWordWrapping
                
                
                eventInfo1.sizeToFit()
                eventInfo2.sizeToFit()
                
                view.layer.masksToBounds = true
                
                if event == "starttime"
                {
                    eventinfoHeight = eventInfo2.frame.size.height + 10
                }
                if eventInfo2.frame.size.height > eventinfoHeight
                {
                    eventinfoHeight = eventInfo2.frame.size.height + 10
                }
                if eventInfo1.frame.size.height > eventinfoHeight
                {
                    eventinfoHeight = eventInfo1.frame.size.height + 10
                }
                
            }
            
            if eventinfoHeight>0
            {
                origin_y = origin_y  + eventinfoHeight
            }
            else
            {
                origin_y = origin_y  + 60
            }
            let lineView = UIView(frame: CGRect(x: 0,y: origin_y,width: view.frame.size.width,height: 0.5))
            lineView.layer.borderWidth = 0.5
            lineView.layer.borderColor = textColorMedium.cgColor
            self.feedObj.tableView.addSubview(lineView)
            
            // condition for adv event
            
            if subjectType != "advancedevents"{
                
                for event in eventInfoSequence{
                    
                    var categoryTitle = ""
                    var categoryInfo = ""
                    
                    eventInfo3 = TTTAttributedLabel(frame: CGRect(x: 2 * PADING, y: origin_y + 10 , width: (self.view.bounds.width - (3 * PADING)), height: 30))
                    eventInfo3.font = UIFont(name: "FontAwesome", size:14.0 )
                    eventInfo3.backgroundColor = bgColor
                    eventInfo3.numberOfLines = 0
                    eventInfo3.tag = 5001
                    eventInfo3.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
                    eventInfo3.textColor = textColorMedium
                    
                    self.feedObj.tableView.addSubview(eventInfo3)
                    if  event == "category"{
                        if let category = response["category_title"] as? String{
                            categoryTitle = category
                            if category != "" {
                                categoryInfo += String(format: NSLocalizedString("%@ Category: ", comment: ""), "\u{f1c0}")
                                categoryInfo += category
                            }
                        }
                        
                        eventInfo3.setText(NSLocalizedString("\(categoryInfo)", comment: ""), afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                            let boldFont = CTFontCreateWithName( (fontBold as CFString?)! , FONTSIZENormal, nil)
                            
                            let range = (categoryInfo as NSString).range(of: NSLocalizedString("\(categoryTitle)", comment: ""))
                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String  as String), value:textColorDark , range: range)
                            // TODO: Clean this up...
                            return mutableAttributedString
                        })
                        if categoryTitle != "" {
                            let range1 = (categoryInfo as NSString).range(of: categoryTitle)
                            eventInfo3.delegate = self
                            eventInfo3.addLink(toTransitInformation: ["type" : "catgory", "category_id": response["category_id"] as! Int], with:range1)
                        }
                        
                    }
                    
                }
                origin_y +=   eventInfo3.bounds.height + 10
                
                if categ1 != nil && categ1 != ""{
                    
                    origin_y += (contentPADING - 2)
                }
                else{
                    origin_y += (contentPADING - 2) - 30
                }
            }
            
        }
        
        var eventInfoSequence1 = ["get_attending_count", "get_maybe_count","get_not_attending_count","get_awaiting_reply_count"]
        var origin_x:CGFloat = PADING;
        
        for i in 0  ..< eventInfoSequence1.count {
            var value = ""
            let eventInfo = eventInfoSequence1[i]
            
            if let info = response["\(eventInfo)"] as? Int{
                value = String(info)
                
                switch(eventInfo){
                case "get_attending_count":
                    value = "\(value)\nattending"
                case "get_maybe_count":
                    value = "\(value)\nmaybe\nattending"
                case "get_not_attending_count":
                    value = "\(value)\nnot\nattending"
                case "get_awaiting_reply_count":
                    value = "\(value)\nawaiting\nreply"
                    
                default:
                    
                    print("error")
                    
                }
                
                
                
                let infoValue = TTTAttributedLabel(frame: CGRect( x: origin_x, y: origin_y, width: (self.view.bounds.width - (2*PADING))/4, height: 0))
                infoValue.textAlignment = .center
                
                infoValue.tag = 5001
                infoValue.textColor = textColorDark
                infoValue.font = UIFont(name: fontName, size: FONTSIZENormal)
                infoValue.setText(value, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                    let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZENormal, nil)
                    
                    let range = (value as NSString).range(of: String(info))
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                    // TODO: Clean this up...
                    return mutableAttributedString
                })
                
                infoValue.numberOfLines = 0
                infoValue.backgroundColor = lightBgColor
                self.feedObj.tableView.addSubview(infoValue)
            }
            origin_x += (self.view.bounds.width - 10)/4
            
        }
        
        origin_y +=  PADING // 80 +
        
        if let description = response["description"] as? String{
            var tempInfo = ""
            if description != ""  {
                
                tempInfo += ""
                if description.length > descriptionTextLimit{
                    if self.showFulldescription == false{
                        tempInfo += (description as NSString).substring(to: descriptionTextLimit-3)
                        
                        tempInfo += NSLocalizedString("...",  comment: "")
                    }else{
                        tempInfo += description
                        
                    }
                }else{
                    tempInfo += description
                }
            }
            
            
            let detailView = createView(CGRect(x: PADING, y: origin_y, width: (self.view.bounds.width-(2*PADING)), height: 150), borderColor: tableViewBgColor, shadow: false)
            detailView.tag = 5001
            detailView.backgroundColor = tableViewBgColor
            self.feedObj.tableView.addSubview(detailView)
            
            let info = TTTAttributedLabel(frame:CGRect(x: PADING, y: contentPADING , width: detailView.bounds.width - (2 * PADING) , height: detailView.bounds.height - (2 * contentPADING)))
            info.numberOfLines = 0
            
            info.textColor = textColorDark
            info.delegate = self
            info.longPressLabel()
            info.font = UIFont(name: fontName, size: FONTSIZENormal)
            info.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZENormal, nil)
                let range = (tempInfo as NSString).range(of: NSLocalizedString("Details", comment: ""))
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                
                // TODO: Clean this up...
                return mutableAttributedString
            })
            
            info.lineBreakMode = NSLineBreakMode.byWordWrapping
            info.sizeToFit()
            detailView.addSubview(info)
            eventMoreOrLess = createButton(CGRect(x: view.bounds.width - 50, y: info.frame.size.height + contentPADING ,  width: 40, height: 30), title: NSLocalizedString("More", comment: ""), border: false,bgColor: false, textColor: navColor)
            eventMoreOrLess.addTarget(self, action: #selector(ContentFeedViewController.detailContentView(_:)), for: .touchUpInside)
            eventMoreOrLess.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            eventMoreOrLess.isHidden = true
            eventMoreOrLess.sizeToFit()
            if  showFulldescription == false{
                eventMoreOrLess.tag = 1
                eventMoreOrLess.setTitle(NSLocalizedString("More", comment: ""), for: UIControl.State())
            }
            else
            {
                eventMoreOrLess.tag = 2
                eventMoreOrLess.setTitle(NSLocalizedString("Less", comment: ""), for: UIControl.State())
            }
            if description.length > descriptionTextLimit{
                eventMoreOrLess.isHidden = false
                
            }
            else{
                eventMoreOrLess.isHidden = true
                eventMoreOrLess.frame.size.height = 0.0
            }
            detailView.addSubview(eventMoreOrLess)
            detailView.frame.size.height = info.bounds.height +  contentPADING + eventMoreOrLess.frame.size.height
            origin_y += detailView.frame.size.height
            
        }
        
        
        origin_y += contentPADING
        if rsvp != nil
        {
            rsvp.frame.origin.y = origin_y
            origin_y += contentPADING + rsvp.bounds.height
            
            
        }
        self.mainSubView.isHidden = false
        self.tabsContainerMenu.frame.origin.y = origin_y
        self.showtabMenu()
        self.headerHeight =  self.tabsContainerMenu.frame.origin.y + self.tabsContainerMenu.bounds.height
        self.feedFilter.isHidden = false
        if logoutUser != true
        {
            
            self.postFeedOption()
            
            if self.subjectType != "advancedevents"{
                self.feedFilter.frame.origin.y = self.headerHeight + ButtonHeight + contentPADING
            }
            else{
                self.feedFilter.frame.origin.y = self.headerHeight + 5
            }
            
        }
        else
        {
            self.feedFilter.frame.origin.y = self.headerHeight + 5
        }
        if self.info != nil
        {
            self.info.frame.origin.y  = self.feedFilter.bounds.height + self.feedFilter.frame.origin.y
        }
        if logoutUser == false
        {
            globalFeedHeight = (self.feedFilter.bounds.height + self.feedFilter.frame.origin.y ) + 3
        }
        else
        {
            globalFeedHeight = (self.feedFilter.bounds.height + self.feedFilter.frame.origin.y )
        }
        self.feedObj.refreshLikeUnLike = true
        self.feedObj.tableView.reloadData()
    }
    
    @objc func detailContentView(_ sender:UIButton){
        if sender.tag == 1{
            
            showFulldescription = true
            
            if(self.subjectType == "group"){
                self.updateDescriptionOfGroup()
            }else{
                self.updateEventInfo(self.contentExtraInfo)
            }
            
        }
        else {
            
            showFulldescription = false
            if(self.subjectType == "group"){
                self.updateDescriptionOfGroup()
            }else{
                self.updateEventInfo(self.contentExtraInfo)
            }
            
        }
        updateGroupViewTableInfo(contentExtraInfo)
    }
    
    func searchCategoryGp(_ sender:UIButton){
        groupUpdate = true
        searchDic["category_id"] = "\(sender.tag)"
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func updateGroupViewTableInfo(_ response: NSDictionary){
        
        var origin_y:CGFloat
        
        if (subjectType == "group" ){
            
            let category1 = response["category_id"] as? Int
            if category1 != 0{
                
                origin_y = mainSubView.bounds.height + topView.bounds.height + 5
                
                eventInfo3 = TTTAttributedLabel(frame: CGRect(x: 2 * PADING, y: origin_y + 5 , width: (self.view.bounds.width - (3 * PADING)), height: 30))
                eventInfo3.font = UIFont(name: "FontAwesome", size:14.0 )
                eventInfo3.backgroundColor = bgColor
                eventInfo3.numberOfLines = 0
                eventInfo3.tag = 5001
                eventInfo3.linkAttributes = [kCTForegroundColorAttributeName:textColorMedium]
                eventInfo3.textColor = textColorMedium
                
                self.feedObj.tableView.addSubview(eventInfo3)
                
                var categoryTitle = ""
                var categoryInfo = ""
                
                if let category = response["category_title"] as? String{
                    categoryTitle = category
                    globalCatg = category
                    if category != "" {
                        categoryInfo += String(format: NSLocalizedString("%@ Category: ", comment: ""), "\u{f1c0}")
                        categoryInfo += category
                    }
                }
                
                eventInfo3.setText(NSLocalizedString("\(categoryInfo)", comment: ""), afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                    let boldFont = CTFontCreateWithName( (fontBold as CFString?)! , FONTSIZENormal, nil)
                    
                    let range = (categoryInfo as NSString).range(of: NSLocalizedString("\(categoryTitle)", comment: ""))
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                    // TODO: Clean this up...
                    return mutableAttributedString
                })
                if categoryTitle != "" {
                    let range1 = (categoryInfo as NSString).range(of: categoryTitle)
                    eventInfo3.delegate = self
                    eventInfo3.addLink(toTransitInformation: ["type" : "category", "category_id": response["category_id"] as! Int], with:range1)
                }
                
                
                let lineView = UIView(frame: CGRect(x: 0,y: origin_y + 40,width: view.frame.size.width,height: 0.5))
                lineView.layer.borderWidth = 0.5
                // lineView.layer.borderColor = tableViewBgColor.cgColor
                lineView.layer.borderColor = textColorMedium.cgColor
                self.feedObj.tableView.addSubview(lineView)
                groupDescriptionView.frame.origin.y = origin_y + 50
                
                groupMoreOrLess.frame.origin.y = origin_y + 50 + groupDescriptionView.frame.size.height
            }
            
            
            
            let category2 = response["category_id"] as? Int
            let totalHeight = groupDescriptionView.bounds.height + mainSubView.bounds.height + topView.bounds.height
            origin_y = totalHeight + (3 * contentPADING)  + groupMoreOrLess.frame.size.height
            
            if category2 != 0{
                origin_y = origin_y + 50
            }
            else{
                origin_y = origin_y + 10
            }
            self.tabsContainerMenu.frame.origin.y = origin_y
            self.showtabMenu()
            self.headerHeight =  self.tabsContainerMenu.frame.origin.y + self.tabsContainerMenu.bounds.height
            self.feedFilter.isHidden = false
            
            if logoutUser == false {
                
                self.postFeedOption()
                self.feedFilter.frame.origin.y = self.headerHeight + ButtonHeight + contentPADING
            }else{
                
                self.feedFilter.frame.origin.y = self.headerHeight + 8
                
            }
            if self.info != nil{
                self.info.frame.origin.y  = self.feedFilter.bounds.height + self.feedFilter.frame.origin.y
            }
            
            
            
            
            if logoutUser == false
            {
                globalFeedHeight = (self.feedFilter.bounds.height + self.feedFilter.frame.origin.y ) + 3
            }
            else
            {
                globalFeedHeight = (self.feedFilter.bounds.height + self.feedFilter.frame.origin.y )
            }
            self.feedObj.refreshLikeUnLike = true
            self.feedObj.tableView.reloadData()
            //            self.feedObj.tableView.reloadData()
        }
        
    }
    
    // MARK: - Server Connection For Activity Feeds Updation
    //MARK:- TikTok API
    func API_getAAFList()
    {
        if Reachabable.isConnectedToNetwork()
        {
            var parameters = [String:String]()
            parameters = ["limit": "\(limit)","maxid": String(maxidTikTok),"feed_filter": "1","post_elements": "1","post_menus":"1","object_info":"1","getAttachedImageDimention":"0","filter_type":"video","onlyMyDeviceVideo":"1"]
            if subjectType == "advancedevents"
            {
                subjectTypeTikTok = "siteevent_event"
                parameters["subject_type"] = subjectTypeTikTok
            }
            else
            {
                if subjectType != ""{
                    parameters["subject_type"] = subjectType
                    subjectTypeTikTok = subjectType
                }
                else{
                    subjectTypeTikTok = ""
                }
            }
            if subjectId != ""{
                parameters["subject_id"] = String(subjectId)
                subjectIdTikTok = "\(subjectId)"
            }
            else{
                subjectIdTikTok = ""
            }          
            
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg {
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2)
                            
                        }
                        //print(succeeded)
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
                                showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2)
                                
                            }
                        }
                    }
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                           showToast(message: succeeded["message"] as! String, controller: self, onView: false, time: 2)
                        }
                    }
                })
                
            }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self, onView: false, time: 2)
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
    
    func newfeedsUpdate(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            
            if subjectId == "" && subjectType == ""{
                parameters = ["limit": "\(limit)" ,"minid":String(minid),"feed_count_only":"1","getAttachedImageDimention":"0"]
            }else{
                parameters = ["limit": "\(limit)","minid":String(minid),"feed_count_only":"1","getAttachedImageDimention":"0" ,"subject_id": String(subjectId), "subject_type": subjectType]
            }
            
            if feedFilterFlag == true{
                parameters.merge(searchDic)
            }
            
            // Set userinteractionflag for request
            userInteractionOff = false
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    // Reset Object after Response from server
                    userInteractionOff = true
                    
                    // On Success Update Feeds
                    if msg{
                        
                        // Check response of Activity Feeds
                        if let response = succeeded["body"] as? NSDictionary{
                            if let newFeedCount = response["response"] as? Int{
                                for ob in self.view.subviews{
                                    if ob.tag == 2020{
                                        ob.removeFromSuperview()
                                    }
                                }
                                
                                if newFeedCount > 0{
                                    
                                    //Show New Feed Option for new Stories
                                    let newFeedCount =  String(format: NSLocalizedString("%d new stories", comment:""),newFeedCount)
                                    
                                    let newFeeds = createButton(CGRect( x: 0, y: self.feedFilter.bounds.height + self.feedFilter.frame.origin.y + TOPPADING + ButtonHeight , width: findWidthByText(newFeedCount) + 40 , height: ButtonHeight - PADING),title: newFeedCount, border: false,bgColor: true, textColor: textColorLight)
                                    newFeeds.tag = 2020
                                    newFeeds.center = CGPoint(x: self.view.center.x, y: newFeeds.frame.origin.y)
                                    newFeeds.layer.cornerRadius = newFeeds.bounds.height/2
                                    newFeeds.addTarget(self, action: #selector(ContentFeedViewController.updateNewFeed), for: .touchUpInside)
                                    self.view.addSubview(newFeeds)
                                    
                                }
                            }
                            
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
    
    // Explore Group Detail
    func exploreContent()
    {
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
            removeAlert()
            // Checkin calling
//            if enabledModules.contains("sitetagcheckin")
//            {
//                self.ischekin()
//            }
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
//            self.view.addSubview(spinner)

            
            
            var url = ""
            var parameters = ["gutter_menu": "1", "profile_tabs" : "1"]
            if subjectType == "group"
            {
                parameters["group_id"] = String(self.subjectId)
                url = "groups/view/" + String(self.subjectId)
            }
            else  if subjectType == "event"
            {
                parameters["event_id"] = String(self.subjectId)
                parameters["profile_rsvp"] = "1"
                url = "events/view/" + String(self.subjectId)
            }
            else if subjectType == "advancedevents"
            {
                
                parameters["event_id"] = String(self.subjectId)
                parameters["rsvp_form"] = "1"
                url = "advancedevents/view/" + String(self.subjectId)
                
            }
            
            likeCommentContentType = subjectType
            if subjectType == "advancedevents"
            {
                likeCommentContentType = "siteevent_event"
            }
            likeCommentContent_id = self.subjectId
            
            // Send Server Request to Explore Group Contents with Group_ID
            post( parameters, url: url, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        
                        self.browseFeed()
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if succeeded["body"] != nil
                        {
                            
                            // On Success Update Content Detail
                            if let contentInfo = succeeded["body"] as? NSDictionary
                            {
                                
                                // Update Content Gutter Menu
                                if let menu = contentInfo["gutterMenu"] as? NSArray{
                                    self.contentGutterMenu = menu
                                    
                                    for tempMenu in self.contentGutterMenu{
                                        if let tempDic = tempMenu as? NSDictionary{
                                            
                                            if tempDic["name"] as! String == "messageowner" {
                                                Messag_Owner = true
                                                if let url = tempDic["url"] as? String {
                                                    Messag_Url = url
                                                }
                                                self.floatingMessageButton()
                                            }
                                            
                                            if tempDic["name"] as! String == "share" {
                                                
                                                self.shareUrl = tempDic["url"] as! String
                                                self.shareParam = tempDic["urlParams"] as! NSDictionary
                                            }
                                        }
                                    }
                                    
                                    for tempMenu in self.contentGutterMenu{
                                        if let tempDic = tempMenu as? NSDictionary{
                                            
                                            if tempDic["name"] as! String == "invite" {
                                                self.canInviteEventOrGroup = true
                                                
                                            }
                                            
                                            
                                        }
                                    }
                                    
                                    for menu in self.contentGutterMenu
                                    {
                                        if let menuItem = menu as? NSDictionary
                                        {
                                            
                                            if (menuItem["name"] as! String == "request_invite") || (menuItem["name"] as! String == "cancel_invite") || (menuItem["name"] as! String == "join") || (menuItem["name"] as! String == "join-waitlist") || (menuItem["name"] as! String == "book_now")
                                            {
                                                self.isshowrsvp = "false"
                                                break
                                            }
                                            
                                        }
                                    }
                                    
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear

                                    if logoutUser == false{
                                        let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                        shareButton.setImage(UIImage(named: "upload")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                        shareButton.addTarget(self, action: #selector(ContentFeedViewController.shareItem), for: .touchUpInside)
                                        rightNavView.addSubview(shareButton)
                                        
                                        let optionButton = createButton(CGRect(x: 22,y: 0,width: 45,height: 45), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                        optionButton.setImage(UIImage(named: "option")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                        optionButton.addTarget(self, action: #selector(ContentFeedViewController.showMainGutterMenu), for: .touchUpInside)
                                        
                                        rightNavView.addSubview(optionButton)
                                        
                                        self.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
                                        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                                    }
                                    
                                    
                                }
                                
                                
                                // Update Group tabContainer Menu
                                if let menu = contentInfo["profile_tabs"] as? NSArray{
                                    self.groupEventProfileTabMenu = menu
                                    self.tabsContainerMenu.isHidden = false
                                }
                                
                                
                                
                                if let response = contentInfo["response"] as? NSDictionary
                                {
                                    if let sitevideoPluginEnabled = response["sitevideoPluginEnabled"] as? Int
                                    {
                                       sitevideoPluginEnabled_event = sitevideoPluginEnabled
                                    }
                                    //sitevideoPluginEnabled_event = (response["sitevideoPluginEnabled"] as! Int)
                                    self.contentTitle = response["title"] as? String
                                    self.responsedic = response
                                    if let owner_id = response["user_id"] as? Int{
                                        self.user_id = owner_id
                                        Messag_OwnerId = owner_id
                                    }
                                    else if let owner_id = response["owner_id"] as? Int{
                                        self.user_id = owner_id
                                        Messag_OwnerId = owner_id
                                    }
                                    else if let owner_id = response["owner_id"] as? Int{
                                        self.user_id = owner_id
                                    }
                                    
                                    if self.subjectType != "advancedevents"{
                                        self.contentDescription = response["description"] as! String
                                        self.hostName.text = response["owner_title"] as? String
                                        self.groupDescriptionView.font = UIFont(name: fontName, size: FONTSIZENormal)
                                        
                                        if let description = response["description"] as? String{
                                            self.descriptionGroupCompleteContent = description
                                            if (self.subjectType == "group"){
                                                self.updateDescriptionOfGroup()
                                            }
                                        }
                                        var categoryMemberTitle = ""
                                        if (self.subjectType == "group"){
                                            if (response["category_title"] != nil || response["member_count"] != nil){
                                                if (response["category_title"] != nil){
                                                    categoryMemberTitle = response["category_title"] as! String
                                                }
                                                
                                            }
                                        }
                                        
                                        // self.categoryMember.text = categoryMemberTitle
                                        self.categoryMember.setText(categoryMemberTitle, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                            return mutableAttributedString
                                            
                                        })
                                        
                                        self.categoryMember.sizeToFit()
                                        
                                    }
                                    else
                                    {
                                        self.contentDescription = response["body"] as? String
                                        
                                    }

                                    
                                    if let tempUrl = response["content_url"] as? String{
                                        self.contentUrl = tempUrl
                                    }

                                    if self.subjectType == "advancedevents"
                                    {
                                        if response["guid"] as? String != nil {
                                        self.guid = response["guid"] as! String
                                        }
                                        if response["isowner"] is Bool
                                        {
                                            let isOwner = response["isowner"] as! Bool
                                            if !isOwner
                                            {
                                                self.ownerCheckId = 0
                                            }
                                        }
                                        else
                                        {
                                            if response["isowner"] as? Int != nil {
                                            self.ownerCheckId = response["isowner"] as! Int
                                            }
                                        }
                                        if let addtoDiary = response["addEventToDiaries"] as? Int {
                                            self.addEventToDiary = addtoDiary
                                        }
                                        
                                    }
                                    
                                    self.mainSubView.isHidden = false
                                    
                                    if let _ : Int = response["default_cover"] as? Int
                                    {
                                        
                                        let tap1 = UITapGestureRecognizer(target: self, action: #selector(ContentFeedViewController.showProfileCoverImageMenu(_:)))
                                        self.coverImage.addGestureRecognizer(tap1)
                                        let tap2 = UITapGestureRecognizer(target: self, action: #selector(ContentFeedViewController.showProfileCoverImageMenu(_:)))
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
                                        
                                        if let _ = response["title"] as? String
                                        {
                                            self.contentTitle = (response["title"] as? String)!
                                            self.contentName.font = UIFont(name: fontBold, size: 27)
                                            self.contentview.frame.origin.x = self.memberProfilePhoto.bounds.width + 15
                                            self.contentview.frame.origin.y = self.coverImage.bounds.height-60
                                            self.contentName.frame.size.width = self.view.bounds.width - (self.memberProfilePhoto.bounds.width + 20)
                                            self.contentview.frame.size.width = self.view.bounds.width - (self.memberProfilePhoto.bounds.width + 15)
                                            if self.contentTitle.length > 15{
                                                self.contentview.frame.origin.y = self.coverImage.bounds.height-70
                                            }
                                            if self.contentTitle.length > 20{
                                                self.contentview.frame.origin.y = self.coverImage.bounds.height-90
                                            }
                                            if self.contentTitle.length > 42
                                            {
                                                self.contentview.frame.origin.y = self.coverImage.bounds.height-110
                                            }
                                        }
                                        
                                        self.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
                                        self.contentName.sizeToFit()
                                        
                                        
                                        if let photoId = response["photo_id"] as? Int
                                        {
                                            if photoId != 0{
                                                self.profileValue = 1
                                            }

                                            if (response["cover_image"] as? String) != nil{
                                                self.coverImageUrl = response["cover_image"] as! String
                                            }

                                            
                                            self.userCoverPicUrl = self.coverImageUrl

                                            
                                            if self.coverImageUrl != "" && self.coverImageUrl != nil
                                            {
                                                if let url = URL(string: response["cover_image"] as! String){
                                                    self.coverImage.kf.indicatorType = .activity
                                                    (self.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                                    self.coverImage.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                        
                                                    })
                                                }
                                            }
                                            else
                                            {
                                                self.coverImage.image =  imageWithImage( UIImage(named: "plain-backgrounds.jpg")!, scaletoWidth: self.coverImage.bounds.width)
                                                
                                            }
                                        }
                                        self.getCoverGutterMenu()
                                        self.memberProfilePhoto.isHidden = false
                                        
                                        if (response["cover_image"] as? String) != nil{
                                            
                                            self.userCoverPicUrl = response["cover_image"] as! String
                                        }

                                        
                                       
                                        self.userProfilePicUrl = response["image"] as! String
                                        
                                        //self.camIconOnProfile.isHidden  = false
                                        
                                        if let url = URL(string: response["image"] as! String){
                                    
                                            self.memberProfilePhoto.kf.indicatorType = .activity
                                            (self.memberProfilePhoto.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                            self.memberProfilePhoto.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                if let img = image{
                                                    self.memberProfilePhoto.image = imageWithImage(img, scaletoWidth: self.coverImage.bounds.width)
                                                }
                                                
                                            })
                                            
                                        }
                                        
                                        
                                    }
                                    else{
                                        
                                        let tap1 = UITapGestureRecognizer(target: self, action: #selector(ContentFeedViewController.onImageViewTap))
                                        self.coverImage.addGestureRecognizer(tap1)
                                        self.contentName.text = response["title"] as? String
                                        
                                        if let _ = response["title"] as? String
                                        {
                                            self.contentTitle = (response["title"] as? String)!
                                            if self.contentTitle.length > 20{
                                                self.contentview.frame.origin.y = self.coverImage.bounds.height-75
                                            }
                                            if self.contentTitle.length > 45
                                            {
                                                self.contentview.frame.origin.y = self.coverImage.bounds.height-110
                                            }
                                        }
                                        
                                        self.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
                                        self.contentName.sizeToFit()
                                        
                                        
                                        if let photoId = response["photo_id"] as? Int
                                        {
                                            self.coverImageUrl = response["image"] as! String
                                            
                                            if photoId != 0{
                                                if let url = URL(string: response["image"] as! String){
                                                    self.coverImage.kf.indicatorType = .activity
                                                    (self.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                                    self.coverImage.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                        
                                                    })
                                                }}else{
                                                self.coverImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: self.coverImage.bounds.width)
                                                
                                            }
                                        }
                                    }

                                    
                                    self.contentExtraInfo = response
                                    
                                    
                                    if self.subjectType == "group"{
                                        
                                        self.updateGroupViewTableInfo(response)
                                    }
                                    else if self.subjectType == "event"
                                    {
                                        if self.rsvp != nil{
                                            for ob in self.rsvp.subviews{
                                                ob.removeFromSuperview()
                                            }
                                            self.rsvp.removeFromSuperview()
                                            self.rsvp = nil
                                        }
                                        
                                        if let _ = contentInfo["profile_rsvp_form"] as? NSArray
                                        {
                                            
                                            self.profile_rsvp_value = contentInfo["profile_rsvp_value"] as! Int
                                            self.rsvp = createView(CGRect(x: PADING, y: 305, width: (self.view.bounds.width - (2*PADING)), height: (1*ButtonHeight)+5+20), borderColor: borderColorMedium, shadow: false)
                                            self.rsvp.layer.borderWidth = 0.0
                                            self.rsvp.backgroundColor = bgColor
                                            self.feedObj.tableView.addSubview(self.rsvp)
                                            
                                            let infoLabel = createLabel(CGRect(x: 0, y: 0, width: self.rsvp.bounds.width, height: 20), text: NSLocalizedString("Your RSVP", comment: ""), alignment: .center, textColor: textColorDark)
                                            infoLabel.backgroundColor = UIColor.clear
                                            infoLabel.tag = 999
                                            infoLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                                            self.rsvp.addSubview(infoLabel)
                                            
                                            self.updateRSVP()
                                        }
                                        self.updateEventInfo(response)
                                        
                                    }
                                    else if self.subjectType == "advancedevents"
                                    {
                                        
                                        if let _ = response["rsvp"] as? Int
                                        {
                                            self.profile_rsvp_value = response["rsvp"] as! Int
                                        }
                                        if self.rsvp != nil
                                        {
                                            for ob in self.rsvp.subviews
                                            {
                                                ob.removeFromSuperview()
                                            }
                                            self.rsvp.removeFromSuperview()
                                            self.rsvp = nil
                                        }
                                        
                                        if let _ = contentInfo["profile_rsvp_form"] as? NSArray
                                        {
                                            self.rsvp = createView(CGRect(x: PADING+10, y: 305, width: (self.view.bounds.width - (2*PADING)-20), height: (4*ButtonHeight) - (4*PADING)+5), borderColor: borderColorMedium, shadow: false)
                                            self.rsvp.layer.borderWidth = 0.0
                                            self.rsvp.backgroundColor = bgColor
                                            
                                            
                                            let infoLabel = createLabel(CGRect(x: 0, y: 0, width: self.rsvp.bounds.width, height: 20), text: NSLocalizedString("Your RSVP", comment: ""), alignment: .center, textColor: textColorDark)
                                            infoLabel.backgroundColor = UIColor.clear//lightBgColor
                                            // infoLabel.layer.borderWidth = borderWidth
                                            infoLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
                                            //infoLabel.layer.borderColor = borderColorMedium.cgColor
                                            self.rsvp.addSubview(infoLabel)
                                            self.feedObj.tableView.addSubview(self.rsvp)
                                            self.updateRSVP()
                                        }
                                        else
                                        {
                                            var rsvpOption = UIButton()
                                            if self.isshowrsvp == "true"
                                            {
                                                self.rsvp = createView(CGRect(x: PADING+10, y: 305, width: (self.view.bounds.width - (2*PADING)-20), height: ButtonHeight+ButtonHeight+7), borderColor: borderColorMedium, shadow: false)
                                                self.rsvp.layer.borderWidth = 0.0
                                                self.rsvp.backgroundColor = bgColor
                                                self.feedObj.tableView.addSubview(self.rsvp)
                                                
                                                
                                                rsvpOption = createButton(CGRect(x: 5, y: 2, width: self.rsvp.bounds.width-15, height: 0), title: "", border: true,bgColor: false, textColor: textColorLight)
                                                rsvpOption.backgroundColor = lightBgColor
                                                
                                                rsvpOption.layer.cornerRadius = rsvpOption.frame.size.width / 2;
                                                rsvpOption.clipsToBounds = true
                                                rsvpOption.layer.borderWidth = 2.5
                                                rsvpOption.layer.masksToBounds = true
                                                rsvpOption.layer.cornerRadius = 5.0
                                                
                                                rsvpOption.contentHorizontalAlignment = .center
                                                rsvpOption.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
                                                rsvpOption.layer.borderWidth = borderWidth
                                                rsvpOption.layer.borderColor = navColor.cgColor
                                                rsvpOption.isHidden = true
                                                self.rsvp.addSubview(rsvpOption)
                                            }
                                            else
                                            {
                                                self.rsvp = createView(CGRect(x: PADING+10, y: 305, width: (self.view.bounds.width - (2*PADING)-20), height: ButtonHeight+ButtonHeight+ButtonHeight+5), borderColor: borderColorMedium, shadow: false)
                                                self.rsvp.layer.borderWidth = 0.0
                                                self.rsvp.backgroundColor = bgColor
                                                self.feedObj.tableView.addSubview(self.rsvp)
                                                
                                                
                                                rsvpOption = createButton(CGRect(x: 5, y: 2, width: self.rsvp.bounds.width-15, height: ButtonHeight-PADING), title: "", border: true,bgColor: false, textColor: textColorLight)
                                                rsvpOption.backgroundColor = lightBgColor
                                                
                                                rsvpOption.layer.cornerRadius = rsvpOption.frame.size.width / 2;
                                                rsvpOption.clipsToBounds = true
                                                rsvpOption.layer.borderWidth = 2.5
                                                rsvpOption.layer.masksToBounds = true
                                                rsvpOption.layer.cornerRadius = 5.0
                                                
                                                rsvpOption.contentHorizontalAlignment = .center
                                                rsvpOption.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
                                                rsvpOption.layer.borderWidth = borderWidth
                                                rsvpOption.layer.borderColor = navColor.cgColor
                                                rsvpOption.isHidden = true
                                                self.rsvp.addSubview(rsvpOption)
                                            }
                                            
                                            //Only one option will be shown at a time
                                            for menu in self.contentGutterMenu
                                            {
                                                if let menuItem = menu as? NSDictionary
                                                {
                                                    
                                                    if (menuItem["name"] as! String == "request_invite")
                                                    {
                                                        rsvpOption.setTitle(NSLocalizedString("Request Invite",  comment: ""), for: UIControl.State())
                                                        rsvpOption.addTarget(self, action: #selector(ContentFeedViewController.RSVPJOINAction(_:)), for: .touchUpInside)
                                                        rsvpOption.isHidden = false
                                                        rsvpOption.tag = 11
                                                        break
                                                    }
                                                    else if (menuItem["name"] as! String == "cancel_invite")
                                                    {
                                                        rsvpOption.setTitle(NSLocalizedString("Cancel Invite Request",  comment: ""), for: UIControl.State())
                                                        rsvpOption.addTarget(self, action: #selector(ContentFeedViewController.RSVPJOINAction(_:)), for: .touchUpInside)
                                                        rsvpOption.isHidden = false
                                                        rsvpOption.tag = 12
                                                        break
                                                        
                                                    }
                                                    else if (menuItem["name"] as! String == "join")
                                                    {
                                                        rsvpOption.setTitle(NSLocalizedString("RSVP / JOIN",  comment: ""), for: UIControl.State())
                                                        rsvpOption.addTarget(self, action: #selector(ContentFeedViewController.RSVPJOINAction(_:)), for: .touchUpInside)
                                                        rsvpOption.isHidden = false
                                                        rsvpOption.tag = 13
                                                        break
                                                    }

                                                    else if (menuItem["name"] as! String == "join-waitlist")
                                                    {
                                                        rsvpOption.setTitle(NSLocalizedString("Add me to waitlist",  comment: ""), for: UIControl.State())
                                                        rsvpOption.addTarget(self, action: #selector(ContentFeedViewController.RSVPJOINAction(_:)), for: .touchUpInside)
                                                        rsvpOption.isHidden = false
                                                        rsvpOption.tag = 14
                                                        break
                                                        
                                                    }
                                                    
                                                    else if (menuItem["name"] as! String == "book_now")
                                                    {
                                                        for view in self.rsvp.subviews {
                                                            if view.tag == 999 {
                                                                view.isHidden = true
                                                            }
                                                        }
                                                       rsvpOption.setTitle(NSLocalizedString("Book Now",  comment: ""), for: UIControl.State())
                                                        rsvpOption.addTarget(self, action: #selector(ContentFeedViewController.RSVPJOINAction(_:)), for: .touchUpInside)
                                                        rsvpOption.isHidden = false
                                                        rsvpOption.tag = 15
                                                        break
                                                        
                                                    }

                                                }
                                            }
                                            
                                            rsvpOption.setTitleColor(navColor, for: UIControl.State())
                                            
                                            
                                            let addToDairy = createButton(CGRect(x: 5, y: rsvpOption.frame.height+10, width: self.rsvp.bounds.width-15, height: ButtonHeight-PADING), title: "Add To Diary", border: false,bgColor: false, textColor: textColorPrime)
                                            addToDairy.backgroundColor = navColor
                                            
                                            addToDairy.addTarget(self, action: #selector(ContentFeedViewController.addToDairyAction(_:)), for: .touchUpInside)
                                            addToDairy.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
                                            if self.addEventToDiary == 1  || self.addEventToDiary == -1 {
                                            self.rsvp.addSubview(addToDairy)
                                            }
                                            else if self.addEventToDiary == 0 {
                                                self.rsvp.frame.size.height -= addToDairy.frame.size.height
                                            }
                                           
                                            let addToCalender = createButton(CGRect(x: 5, y: addToDairy.frame.origin.y + addToDairy.frame.size.height+PADING, width: self.rsvp.bounds.width-15, height: ButtonHeight-PADING), title: "Add To Calendar", border: false,bgColor: false, textColor: textColorPrime)
                                            
                                            addToCalender.addTarget(self, action: #selector(ContentFeedViewController.addToCalenderAction(_:)), for: .touchUpInside)
                                            addToCalender.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
                                            addToCalender.backgroundColor = navColor
                                            self.rsvp.addSubview(addToCalender)
                                            if let calenderids = UserDefaults.standard.object(forKey: "eventids")
                                            {
                                                self.addedToCalandar = calenderids as! [Int]
                                                if self.addedToCalandar.contains(Int(self.subjectId) ?? 0)
                                                {
                                                    addToCalender.setTitle("Added To Calendar", for: .normal)
                                                    addToCalender.isEnabled = false
                                                    addToCalender.backgroundColor = navColor
                                                    addToCalender.alpha = 0.2
                                                }
                                                
                                            }
                                            if self.addEventToDiary == 0 {
                                                addToCalender.frame = CGRect(x: 5, y: rsvpOption.frame.height+10, width: self.rsvp.bounds.width-15, height: ButtonHeight-PADING)
                                            }
                                            
                                            
                                            for menu in self.contentGutterMenu
                                            {
                                                if let menuItem = menu as? NSDictionary
                                                {
                                                    
                                                    if menuItem["name"] as! String == "createreview" || menuItem["name"] as! String == "updateReview"
                                                    {
                                                        
                                                        let writeReview = createButton(CGRect(x: 0, y: rsvpOption.frame.height+10, width: self.rsvp.bounds.width/2-5, height: ButtonHeight-PADING), title: "Write a Review", border: false,bgColor: false, textColor: textColorPrime)
                                                        if menuItem["name"] as! String == "createreview"
                                                        {
                                                            writeReview.setTitle("Write a Review", for: UIControl.State())
                                                        }
                                                        else
                                                        {
                                                            writeReview.setTitle("Update Review", for: UIControl.State())
                                                        }
                                                        
                                                        writeReview.backgroundColor = navColor
                                                        writeReview.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
                                                        writeReview.addTarget(self, action: #selector(ContentFeedViewController.writeReviewAction(_:)), for: .touchUpInside)
                                                        self.rsvp.addSubview(writeReview)
                                                        
                                                        
                                                        let addToDairy = createButton(CGRect(x: self.rsvp.bounds.width/2+5, y: rsvpOption.frame.height+10, width: self.rsvp.bounds.width/2-5, height: ButtonHeight-PADING), title: "Add To Diary", border: false,bgColor: false, textColor: textColorPrime)
                                                        addToDairy.backgroundColor = navColor
                                                        
                                                        addToDairy.addTarget(self, action: #selector(ContentFeedViewController.addToDairyAction(_:)), for: .touchUpInside)
                                                        addToDairy.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
                                                        self.rsvp.addSubview(addToDairy)
                                                        
                                                        
                    
                                                    }
                                                    
                                                    
                                                }
                                            }
                                            
                                        }
                                        self.updateEventInfo(response)
                                    }
                                    
                                }
                            }
                        }
                    }
                    else
                    {
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
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    // Make Hard Refresh Request to server for Activity Feeds
    func browseFeed(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            API_getAAFList()
            removeAlert()
            //stopMyTimer()
            // Remove new Activity Feed InfoLabel, NO Stories
            for ob in self.view.subviews{
                if ob.tag == 10000 {
                    ob.removeFromSuperview()
                }
            }
            for ob in view.subviews{
                if ob.tag == 2020{
                    ob.removeFromSuperview()
                }
            }
            
            for ob1 in self.feedObj.tableView.subviews
            {
                if  ob1.tag == 1000{
                    ob1.removeFromSuperview()
                }
            }
            // Reset Objects for Hard Refresh Request
            if (maxid == 0){
                
                if contentFeedArray.count == 0{
                    self.feedObj.tableView.reloadData()
                }
                
            }
            
            
            // Check for Show Spinner Position for Request
            if (showSpinner){
                activityIndicatorView.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                self.view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
              //  activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            
            
            if subjectType == "advancedevents"
            {
                parameters = ["maxid":String(maxid), "limit": "\(limit)","subject_id": String(subjectId) , "subject_type": "siteevent_event" , "post_menus":"1", "feed_filter": "1","getAttachedImageDimention":"0" ]
            }
            else
            {
                parameters = ["maxid":String(maxid), "limit": "\(limit)","subject_id": String(subjectId) , "subject_type": subjectType , "post_menus":"1", "feed_filter": "1","getAttachedImageDimention":"0" ]
                
            }
            
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
                    
                    if self.showSpinner
                    {
                        activityIndicatorView.stopAnimating()
                    }
                    else
                    {
                        self.refresher.endRefreshing()
                       
                    }
                     self.showSpinner = false
                    self.feedObj.tableView.tableFooterView?.isHidden = true
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
                        
                        
                        // Check response of Activity Feeds
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            // Set MinId for Feeds Result
                            if let minID = response["minid"] as? Int{
                                self.minid = minID
                            }
                            
                            // Check for Feed Filter Options
                            if let menu = response["filterTabs"] as? NSArray{
                                self.feedFilter.isEnabled = true
                                gutterMenu = menu
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
                            // Check that whether Sticker Plugin is enable or not
                            if let stickersEnable = response["stickersEnabled"] as? Bool{
                                if stickersEnable == true{
                                    StickerPlugin = true
                                }
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
                                self.feedFilter.isHidden = false
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
                                
                                self.info  = createLabel(CGRect(x: 0,y: self.feedFilter.bounds.height + self.feedFilter.frame.origin.y + 10,width: self.view.bounds.width , height: 50), text: NSLocalizedString("No updates at this moment . Check again any \nother time.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                //                                self.info.center = self.view.center
                                self.info.backgroundColor = .white
                                self.info.font = UIFont(name: fontName, size: FONTSIZENormal)
                                self.info.tag = 1000
                                self.feedObj.tableView.addSubview(self.info)
                                self.info.isHidden = false
                                self.info.numberOfLines = 2
                                self.info.font = UIFont(name: fontName, size: FONTSIZENormal)
                                
                                
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
                            //self.startMyTimer()    // Create Timer for Check UPdtes Repeatlly
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
                        emoji.addTarget(self, action: #selector(ContentFeedViewController.feedMenuReactionLike(sender:)), for: .touchUpInside)
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
        view.bringSubviewToFront( imageView)
        
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
    
    @objc func showMainGutterMenu(){
        
        
        // Generate Group Menu Come From Server as! Alert Popover
        
        deleteContent = false
        var confirmationTitle = ""
        
        var message = ""
        var url = ""
        var param: NSDictionary = [:]
        var confirmationAlert = true
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        for menu in contentGutterMenu{
            if let menuItem = menu as? NSDictionary{
                
                if (menuItem["name"] as! String != "share")  && (menuItem["name"] as! String != "join-waitlist"){
                    
                    let titleString = menuItem["name"] as! String
                    
                    if ((titleString.range(of: "delete") != nil) || (titleString.range(of: "leave") != nil) || (titleString.range(of: "cancel_request") != nil) || (titleString.range(of: "reject_request") != nil) || (titleString.range(of: "close") != nil))
                    {
                        
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .destructive , handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            switch(condition){
                                
                            case "leave_group":
                                confirmationTitle = NSLocalizedString("Leave Group", comment: "")
                                message = NSLocalizedString("Are you sure you want to leave this group?", comment: "")
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary // menuItem["urlParams"] as! NSDictionary
                                
                            case "cancel_request":
                                if self.subjectType == "group"{
                                    confirmationTitle = NSLocalizedString("Cancel Group Membership Request", comment: "")
                                    message = NSLocalizedString("Would you like to cancel your request for membership in this group?", comment: "")
                                }else if self.subjectType == "event"{
                                    confirmationTitle = NSLocalizedString("Cancel Event Membership Request", comment: "")
                                    message = NSLocalizedString("Would you like to cancel your request for membership in this event?", comment: "")
                                }
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary // menuItem["urlParams"] as! NSDictionary
                                
                                
                            case "reject_request":
                                if self.subjectType == "group"{
                                    confirmationTitle = NSLocalizedString("Reject Group Invitation", comment: "")
                                }else if self.subjectType == "event"{
                                    confirmationTitle = NSLocalizedString("Reject Event Invitation", comment: "")
                                }
                                message = NSLocalizedString("Would you like to reject the invitation to this \(self.subjectType)?", comment: "")
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary
                                
                                
                            case "delete":
                                self.deleteContent = true
                                if self.subjectType == "event"{
                                    confirmationTitle = NSLocalizedString("Delete Event", comment: "")
                                    
                                    message = NSLocalizedString("Are you sure you want to delete this event?", comment: "")
                                } else if self.subjectType == "group"{
                                    confirmationTitle = NSLocalizedString("Delete Group", comment: "")
                                    
                                    message = NSLocalizedString("Are you sure you want to delete this group?", comment: "")
                                }else if self.subjectType == "advancedevents"{
                                    confirmationTitle = NSLocalizedString("Delete Advanced Events", comment: "")
                                    
                                    message = NSLocalizedString("Are you sure you want to delete this Advanced Events?", comment: "")
                                }
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary //menuItem["urlParams"] as! NSDictionary
                                
                            case "leave":
                                if self.subjectType == "event"{
                                    confirmationTitle = NSLocalizedString("Leave Event", comment: "")
                                    message = NSLocalizedString("Are you sure you want to leave this event?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    
                                }else if self.subjectType == "group"{
                                    
                                    confirmationTitle = NSLocalizedString("Leave Group", comment: "")
                                    message = NSLocalizedString("Would you like to leave this group?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    
                                    
                                }
                                else if self.subjectType == "advancedevents"{
                                    confirmationTitle = NSLocalizedString("Leave Event", comment: "")
                                    message = NSLocalizedString("Are you sure you want to leave this event?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                    
                                }
                            case "close":
                                
                                if self.subjectType == "advancedevents"{
                                    if (menuItem["isclosed"] as! Int == 0)
                                    {
                                        confirmationTitle = NSLocalizedString("Cancel Event", comment: "")
                                        message = NSLocalizedString("Would you like to cancel this event?", comment: "")
                                        
                                        url = menuItem["url"] as! String
                                        param = Dictionary<String, String>() as NSDictionary // menuItem["urlParams"] as! NSDictionary
                                        
                                    }
                                    else
                                    {
                                        confirmationTitle = NSLocalizedString("Re-publish Event", comment: "")
                                        message = NSLocalizedString("Would you like to Re-publish this event?", comment: "")
                                        
                                        url = menuItem["url"] as! String
                                        param = Dictionary<String, String>() as NSDictionary // menuItem["urlParams"] as! NSDictionary
                                        
                                    }
                                }else{
                                    confirmationTitle = NSLocalizedString("Cancel Event", comment: "")
                                    message = NSLocalizedString("Would you like to cancel this event?", comment: "")
                                    
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary // menuItem["urlParams"] as! NSDictionary
                                }
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                            
                            if confirmationAlert == true {
                                displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                    self.updateContentAction(param as NSDictionary,url: url)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        }))
                        
                        
                    }
                    else
                    {
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            switch(condition){
                            case "edit":
                                confirmationAlert = false
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                if self.subjectType == "event"
                                {
                                    presentedVC.formTitle = NSLocalizedString("Edit Event", comment: "")
                                }
                                else if self.subjectType == "group"
                                {
                                    presentedVC.formTitle = NSLocalizedString("Edit Group", comment: "")
                                }
                                else if self.subjectType == "advancedevents"
                                {
                                    presentedVC.formTitle = NSLocalizedString("Edit Event", comment: "")
                                }
                                presentedVC.contentType = self.subjectType
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                            case "invite":
                                confirmationAlert = false
                                let presentedVC = InviteMemberViewController()
                                presentedVC.contentType = self.subjectType
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.param = Dictionary<String, String>() as NSDictionary? //menuItem["urlParams"] as! NSDictionary
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "join_group":
                                confirmationTitle = NSLocalizedString("Join Group", comment: "")
                                message = NSLocalizedString("Would you like to join this group?", comment: "")
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary
                                
                                
                            case "request_member":
                                if self.subjectType == "group"{
                                    confirmationTitle = NSLocalizedString("Request Group Membership", comment: "")
                                    message = NSLocalizedString("Would you like to request membership in this group?", comment: "")
                                }else if self.subjectType == "event"{
                                    confirmationTitle = NSLocalizedString("Request Event Membership", comment: "")
                                    message = NSLocalizedString("Would you like to request membership in this event?", comment: "")
                                }
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary //menuItem["urlParams"] as! NSDictionary
                                
                                
                            case "accept_request":
                                if self.subjectType == "group"
                                {
                                    confirmationTitle = NSLocalizedString("Accept Group Invitation", comment: "")
                                    
                                }
                                else if self.subjectType == "event"
                                {
                                    confirmationTitle = NSLocalizedString("Accept Event Invitation", comment: "")
                                    
                                }
                                message = NSLocalizedString("Would you like to join this \(self.subjectType)?", comment: "")
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary
                                
                            case "join":
                                
                                if self.subjectType == "event" || self.subjectType == "advancedevents"{
                                    self.showCustomJoinAlert(2, joinOrAccept : true)
                                    return
                                }else if self.subjectType == "group"{
                                    confirmationTitle = NSLocalizedString("Join Group", comment: "")
                                    message = NSLocalizedString("Would you like to join this group?", comment: "")
                                    url = menuItem["url"] as! String
                                    param = Dictionary<String, String>() as NSDictionary
                                }
                                
                            case "request_invite":
                                
                                confirmationAlert = true
                                confirmationTitle = NSLocalizedString("Request Event Membership", comment: "")
                                message = NSLocalizedString("Would you like to request membership in this event?", comment: "")
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary //menuItem["urlParams"] as! NSDictionary
                                
                            case "messageowner":
                                
                                confirmationAlert = false
                                
                                if isChannelizeAvailable{
                                    if let userId = self.user_id{
                                        let data : [AnyHashable:Any] = [AnyHashable("userId"):userId]
                                        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                                            let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                                            if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                                                channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: data)
                                            }
                                        }
                                    }
                                } else{
                                    let presentedVC = MessageOwnerViewController()
                                    url = menuItem["url"] as! String
                                    presentedVC.url = url
                                    self.navigationController?.pushViewController(presentedVC, animated: true)
                                }
                                
                            case "tellafriend":
                                
                                confirmationAlert = false
                                let presentedVC = TellAFriendViewController();
                                url = menuItem["url"] as! String
                                presentedVC.url = url
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                                
                            case "report":
                                
                                confirmationAlert = false
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = menuItem["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "notification_settings":
                                
                                confirmationAlert = false
                                let presentedVC = NotificationsSettingsViewController()
                                url = menuItem["url"] as! String
                                presentedVC.url = url
                                presentedVC.contentType = "advancedeventsview"
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                            case "accept_invite":
                                
                                confirmationAlert = false
                                self.showCustomJoinAlert(2, joinOrAccept : false)
                                
                                
                            case "cancel_invite":
                                
                                confirmationAlert = true
                                confirmationTitle = NSLocalizedString("Cancel Event Invitation", comment: "")

                                message = NSLocalizedString("Would you like to Cancel this \(self.subjectType)?", comment: "")
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary
                                
                            case "diary":
                                
                                isCreateOrEdit = true
                                confirmationAlert = false
                                globFilterValue = ""
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Add to Diary", comment: "")
                                presentedVC.contentType = "AddToDiary"
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            case "videoCreate" :
                                video_clicked  = 1
                                isCreateOrEdit = true
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Add New Video", comment: "")
                                presentedVC.contentType = "Advanced Video"
                                if sitevideoPluginEnabled_event == 1
                                {
                                    let subject_type = menuItem["subject_type"] as! String
                                    let subject_id =   menuItem["subject_id"] as! Int
                                    presentedVC.param = ["subject_id":"\(subject_id)","subject_type" :"\(subject_type)" ]
                                }
                                url = menuItem["url"] as! String
                                presentedVC.url = url
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                                
                            case "capacity_waitlist":
                                
                                isCreateOrEdit = true
                                globFilterValue = ""
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Capacity & Waitlist", comment: "")
                                presentedVC.contentType = "capacitywaitlist"
                                let tempDic = NSDictionary()
                                presentedVC.param = tempDic as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
 
                                
                            case "package_payment":
                                
                                confirmationAlert = false
                                let presentedVC = ExternalWebViewController()
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let navigationController = UINavigationController(rootViewController: presentedVC)
                                self.present(navigationController, animated: true, completion: nil)
                                
                            case "createReview":
                                
                                isCreateOrEdit = true
                                globFilterValue = ""
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Write a Review", comment: "")
                                presentedVC.contentType = "Review"
                                let tempDic = NSDictionary()
                                presentedVC.param = tempDic as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                                
                            case "updateReview":
                                
                                isCreateOrEdit = true
                                globFilterValue = ""
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Update Review", comment: "")
                                presentedVC.contentType = "Review"
                                let param =  menuItem["urlParams"] as! NSDictionary
                                let reviewid = param["review_id"] as! Int
                                var tempDic = NSDictionary()
                                tempDic = ["review_id":"\(reviewid)"]
                                presentedVC.param = tempDic as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                                
                            case "upgrade_package":
                                let presentedVC = PackageViewController()
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.urlParams = menuItem["urlParams"] as! NSDictionary
                                presentedVC.isUpgradePackageScreen = true
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                                
                            case "book_now":
                                
                                confirmationAlert = false
                                let presentedVC = TicketDetailPageViewController()
                                presentedVC.eventtitle = self.responsedic["title"] as! String
                                presentedVC.locationtitle = self.responsedic["location"] as! String
                                let datet = "\(self.responsedic["starttime"] as! String)"
                                let datet1 = "\(self.responsedic["endtime"] as! String)"
                                presentedVC.startdatetitle = datet
                                presentedVC.enddatetitle = datet1
                                presentedVC.status = self.responsedic["status"] as! String
                                presentedVC.eventid = self.responsedic["event_id"] as! Int
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
//                                confirmationAlert = false
//                                let presentedVC = ExternalWebViewController()
//                                presentedVC.url = menuItem["contentUrl"] as! String
//                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
//                                let navigationController = UINavigationController(rootViewController: presentedVC)
//                                self.present(navigationController, animated: true, completion: nil)
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                            }
                            
                            if confirmationAlert == true {
                                displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                    self.updateContentAction(param as NSDictionary,url: url)
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
    
    @objc func RSVPJOINAction(_ sender: UIButton)
    {

            let tag = sender.tag
            switch tag {
            case 11:
                for menu in contentGutterMenu
                {
                    if let menuItem = menu as? NSDictionary
                    {
                        
                        if (menuItem["name"] as! String == "request_invite")
                        {
                            deleteContent = false
                            var confirmationTitle = ""
                            
                            var message = ""
                            var url = ""
                            var param: NSDictionary = [:]
                            var confirmationAlert = true
                            confirmationAlert = true
                            confirmationTitle = NSLocalizedString("Request Event Membership", comment: "")
                            message = NSLocalizedString("Would you like to request membership in this event?", comment: "")
                            
                            
                            url = menuItem["url"] as! String
                            param = Dictionary<String, String>() as NSDictionary //menuItem["urlParams"] as! NSDictionary
                            
                            if confirmationAlert == true {
                                displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                    self.updateContentAction(param as NSDictionary,url: url)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }
                    }
                }
                
                break
            case 12:
                for menu in contentGutterMenu
                {
                    if let menuItem = menu as? NSDictionary
                    {
                        
                        if (menuItem["name"] as! String == "cancel_invite")
                        {
                            deleteContent = false
                            var confirmationTitle = ""
                            
                            var message = ""
                            var url = ""
                            var param: NSDictionary = [:]
                            var confirmationAlert = true
                            confirmationAlert = true
                            confirmationTitle = NSLocalizedString("Cancel Event Invitation", comment: "")
                            message = NSLocalizedString("Would you like to Cancel this \(self.subjectType)?", comment: "")
                            url = menuItem["url"] as! String
                            param = Dictionary<String, String>() as NSDictionary //menuItem["urlParams"] as! NSDictionary
                            
                            if confirmationAlert == true {
                                displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                    self.updateContentAction(param as NSDictionary,url: url)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }
                    }
                }
                break
            case 13:
                self.showCustomJoinAlert(2, joinOrAccept : true)
                break
            case 15:
            
                let presentedVC = TicketDetailPageViewController()
                
                presentedVC.eventtitle = self.responsedic["title"] as! String
                presentedVC.locationtitle = self.responsedic["location"] as! String
                let datet = "\(self.responsedic["starttime"] as! String)"
                let datet1 = "\(self.responsedic["endtime"] as! String)"
                presentedVC.startdatetitle = datet
                presentedVC.enddatetitle = datet1
                presentedVC.status = self.responsedic["status"] as! String
                presentedVC.eventid = self.responsedic["event_id"] as! Int
                self.navigationController?.pushViewController(presentedVC, animated: false)
                break
            default:
                for menu in contentGutterMenu
                {
                    if let menuItem = menu as? NSDictionary
                    {
                    
                        if (menuItem["name"] as! String == "join-waitlist")
                        {
                            deleteContent = false
                            var confirmationTitle = ""
                            
                            var message = ""
                            var url = ""
                            var param: NSDictionary = [:]
                            var confirmationAlert = true
                            confirmationAlert = true
                            confirmationTitle = NSLocalizedString("Join Waitlist", comment: "")
                            message = NSLocalizedString("Would you like to Join Waitlist?", comment: "")
                            url = menuItem["url"] as! String
                            param = Dictionary<String, String>() as NSDictionary //menuItem["urlParams"] as! NSDictionary
                            if confirmationAlert == true {
                                displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                    self.updateContentAction(param as NSDictionary,url: url)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }
                    }
                }
                break
            }

        
        
    }
    
    func showCustomJoinAlert(_ selectedValue: Int, joinOrAccept : Bool){
        
        join_rsvp = selectedValue
        for menu in contentGutterMenu{
            if let menuItem = menu as? NSDictionary{
                if joinOrAccept == true{
                    if menuItem["name"] as! String == "join"{
                        joinFlag = true
                        let pv = JoinEventViewController()
                        pv.url = menuItem["url"] as! String
                        pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let nativationController = UINavigationController(rootViewController: pv)
                        present(nativationController, animated:true, completion: nil)
                        
                    }
                }else{
                    if menuItem["name"] as! String == "accept_invite"{
                        joinFlag = true
                        let pv = JoinEventViewController()
                        pv.url = menuItem["url"] as! String
                        pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let nativationController = UINavigationController(rootViewController: pv)
                        present(nativationController, animated:true, completion: nil)
                    }
                }
                
            }
        }
        
    }
    
    func rsvpAlertAction(_ sender: UIButton){
        showCustomJoinAlert(sender.tag, joinOrAccept : true)
    }
    // MARK:  Add to Diary
    @objc func addToDairyAction(_ sender: UIButton)
    {
        if logoutUser == true{
            
            showToast(message: "Please sign in first to continue.", controller: self)
            
        }
        for menu in contentGutterMenu
        {
            if let menuItem = menu as? NSDictionary
            {
                if menuItem["name"] as! String == "diary"
                {
                    isCreateOrEdit = true
                    globFilterValue = ""
                    let presentedVC = FormGenerationViewController()
                    presentedVC.formTitle = NSLocalizedString("Add to Diary", comment: "")
                    presentedVC.contentType = "AddToDiary"
                    presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                    presentedVC.url = menuItem["url"] as! String
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    self.present(nativationController, animated:false, completion: nil)

                }
            }
        }
        
    }
    // MARK:  Add to calandar
    @objc func addToCalenderAction(_ sender: UIButton){
        
        if logoutUser == true{
            
            showToast(message: "Please sign in first to continue.", controller: self)
            
        }
        else
        {
            let eventStore = EKEventStore()
            let Date1 = self.responsedic["starttime"] as! String
            let dateFormatter = DateFormatter()
            dateFormatter.formatterBehavior = DateFormatter.Behavior.behavior10_4
            dateFormatter.timeZone = TimeZone(identifier: "GMT")
            dateFormatter.dateFormat = "yyyy-LL-d  HH:mm:ss"
            
            let convertedDate = dateFormatter.date(from: Date1)
            let date = Date()
            var timeInterval = convertedDate?.timeIntervalSince(date)
            timeInterval = timeInterval! * -1
            if timeInterval < 1{
                timeInterval = date.timeIntervalSince(convertedDate!)
            }
            dateFormatter.dateFormat = "dd MMM, HH:mm"
            let startDate = Date(timeIntervalSince1970:(convertedDate?.timeIntervalSince1970)!)
            
            
            let Date2 = self.responsedic["endtime"] as! String
            let dateFormatter2 = DateFormatter()
            dateFormatter2.formatterBehavior = DateFormatter.Behavior.behavior10_4
            dateFormatter2.timeZone = TimeZone(identifier: "GMT")
            dateFormatter2.dateFormat = "yyyy-LL-d  HH:mm:ss"
            
            let convertedDate2 = dateFormatter2.date(from: Date2)
            let date2 = Date()
            var timeInterval2 = convertedDate2?.timeIntervalSince(date2)
            timeInterval2 = timeInterval2! * -1
            if timeInterval2 < 1{
                timeInterval2 = date2.timeIntervalSince(convertedDate2!)
            }
            dateFormatter2.dateFormat = "dd MMM, HH:mm"
            let endDate = Date(timeIntervalSince1970:(convertedDate2?.timeIntervalSince1970)!)
            let tittle = self.responsedic["title"] as! String
            if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                eventStore.requestAccess(to: .event, completion: {
                    granted, error in
                    self.createEvent(eventStore, title: tittle, startDate: startDate, endDate: endDate)
                    
                })
            }
            else
            {
                createEvent(eventStore, title: tittle, startDate: startDate, endDate: endDate)
            }
        }
    }
    
    func createEvent(_ eventStore: EKEventStore, title: String, startDate: Date, endDate: Date){
        
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        do
        {
            try eventStore.save(event, span: .thisEvent)
            //savedEventId = event.eventIdentifier
            let eventid = subjectId
            addedToCalandar.append(Int(eventid) ?? 0)
            UserDefaults.standard.set(addedToCalandar, forKey: "eventids")
            exploreContent()
            //self.view.makeToast("Event has been added successfully to your calendar.", duration: 5, position: "bottom")
            
        }
        catch
        {
            //print("Error Saving")
        }
        
    }
    
    @objc func writeReviewAction(_ sender: UIButton){
        
        
        for menu in contentGutterMenu
        {
            if let menuItem = menu as? NSDictionary
            {
                if menuItem["name"] as! String == "createReview"
                {
                    isCreateOrEdit = true
                    globFilterValue = ""
                    
                    let presentedVC = FormGenerationViewController()
                    presentedVC.formTitle = NSLocalizedString("Write a Review", comment: "")
                    presentedVC.contentType = "Review"
                    let tempDic = NSDictionary()
                    presentedVC.param = tempDic as! [AnyHashable : Any] as NSDictionary
                    presentedVC.url = menuItem["url"] as! String
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    self.present(nativationController, animated:false, completion: nil)

                }
                else if menuItem["name"] as! String == "updateReview"
                {
                    
                    
                    isCreateOrEdit = true
                    globFilterValue = ""
                    
                    let presentedVC = FormGenerationViewController()
                    presentedVC.formTitle = NSLocalizedString("Update Review", comment: "")
                    presentedVC.contentType = "Review"
                    let param =  menuItem["urlParams"] as! NSDictionary
                    let reviewid = param["review_id"] as! Int
                    var tempDic = NSDictionary()
                    tempDic = ["review_id":"\(reviewid)"]
                    presentedVC.param = tempDic as! [AnyHashable : Any] as NSDictionary
                    presentedVC.url = menuItem["url"] as! String
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    self.present(nativationController, animated:false, completion: nil)

                }
            }
        }
        
        
        
    }
    
    func hideCustomAlert(){
        for ob in transparentView.subviews{
            ob.removeFromSuperview()
        }
        transparentView.removeFromSuperview()
        //subView.isHidden = true
        transparentView = nil
    }
    
    func updateContentAction(_ parameter: NSDictionary , url : String){
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
            if joinFlag == true{
                joinFlag = false
                dic["rsvp"] = "\(join_rsvp)"
            }
            
            var method = "POST"
            
            if (url.range(of: "delete") != nil){
                method = "DELETE"
            }
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{

                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                            
                        }
                        if self.deleteContent == true{
                            groupUpdate = true
                            eventUpdate = true
                            advGroupDetailUpdate = true
                            pageDetailUpdate = true
                            listingDetailUpdate = true
                            storeDetailUpdate = true
                            self.popAfterDelay = true
                            self.createTimer(self)
                            
                            
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
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    func updateDescriptionOfGroup(){
        let tempTextLimit =  descriptionTextLimit
        if let description = descriptionGroupCompleteContent{
            var tempInfo = ""
            if description != ""  {
                //            tempInfo = NSLocalizedString("Details", comment: "")
                //            tempInfo += "\n"
                
                
                if description.length > tempTextLimit{
                    
                    if self.showFulldescription == false{
                        tempInfo += (description as NSString).substring(to: tempTextLimit-3)
                        tempInfo += NSLocalizedString("... ",  comment: "")
                        
                    }else{
                        tempInfo += description
                    }
                }else{
                    tempInfo += description
                }
            }
            self.groupDescriptionView.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZENormal, nil)
                
                let range = (tempInfo as NSString).range(of: NSLocalizedString("Details", comment: ""))
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTFontAttributeName as NSString) as String as String), value: boldFont, range: range)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTForegroundColorAttributeName as NSString) as String as String), value:textColorDark , range: range)
                
                
                // TODO: Clean this up...
                return mutableAttributedString
            })
            
            self.groupDescriptionView.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.groupDescriptionView.sizeToFit()
            
            
            if description.length > tempTextLimit{
                groupMoreOrLess.frame =  CGRect(x: view.bounds.width - 50, y: groupDescriptionView.frame.size.height + groupDescriptionView.frame.origin.y ,  width: 40, height: 30)
                groupMoreOrLess.isHidden = false
                if self.showFulldescription == false{
                    groupMoreOrLess.tag = 1
                    groupMoreOrLess.setTitle(NSLocalizedString("More", comment: ""), for: UIControl.State())
                }else{
                    groupMoreOrLess.tag = 2
                    groupMoreOrLess.setTitle(NSLocalizedString("Less", comment: ""), for: UIControl.State())
                    
                }
            }else{
                groupMoreOrLess.isHidden = true
                groupMoreOrLess.frame.size.height = 0.0
            }
            
            
            
            //}
        }
        
        
    }
    
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    
    // Stop Timer for remove Alert
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!)
    {
        let type = components["type"] as! String
        
        switch(type){
        case "moreContentInfo":
            showFulldescription = true
            
            if(self.subjectType == "group"){
                self.updateDescriptionOfGroup()
            }else{
                self.updateEventInfo(self.contentExtraInfo)
            }
        case "lessContentInfo":
            showFulldescription = false
            if(self.subjectType == "group")
            {
                self.updateDescriptionOfGroup()
            }
            else
            {
                self.updateEventInfo(self.contentExtraInfo)
            }
        case "map":
            
            let vc = MapViewController()
            vc.location = components["location"] as! String
            vc.place_id = components["place_id"] as! String
            self.navigationController?.pushViewController(vc, animated: false)
            
        default: break
        }
        if type == "moreContentInfo" || type == "lessContentInfo"
        {
            updateGroupViewTableInfo(contentExtraInfo)
        }
        
    }
    
    // MARK:  UIScrollViewDelegate
    @objc func ScrollingactionContentFeed(_ notification: Foundation.Notification)
    {
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        
        if updateScrollFlag{
            
            if tabsContainerMenu.contentOffset.x > 0 {
                
            }else if tabsContainerMenu.contentOffset.x <= 0 {
                
            }
            
            if tabsContainerMenu.contentOffset.x + tabsContainerMenu.bounds.width <  tabsContainerMenu.contentSize.width{
                
            }else if tabsContainerMenu.contentOffset.x + tabsContainerMenu.bounds.width ==  tabsContainerMenu.contentSize.width{
                
            }
            
            
            // Check for PAGINATION
            if self.feedObj.tableView.contentSize.height > self.feedObj.tableView.bounds.size.height{
                if self.feedObj.tableView.contentOffset.y >= (self.feedObj.tableView.contentSize.height - self.feedObj.tableView.bounds.size.height){
                    if Reachabable.isConnectedToNetwork() {
                        
                        if contentFeedArray.count > 0{
                            if maxid == 0{
                                
                                feedObj.tableView.tableFooterView?.isHidden = true
                                toastView = createView(CGRect(x: 0,y: (self.feedObj.tableView.bounds.size.height) - 20 , width: view.bounds.width, height: 20), borderColor: UIColor.clear, shadow: false)
                                toastView.backgroundColor = UIColor.clear
                                showToast(message: NSLocalizedString("There are no more posts to show.",comment: ""), controller: self)
                                view.addSubview(toastView)
                                self.toastView.hideToastActivity()
                                
                            }else{
                                // Request for Pagination
                                updateScrollFlag = false
                                feed_filter = 0
                               // showSpinner = false
                                feedObj.tableView.tableFooterView?.isHidden = false
                                if adsType_feeds == 2 || adsType_feeds == 4{
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
            setNavigationImage(controller: self)
            self.navigationController?.navigationBar.alpha = barAlpha
            self.marqueeHeader.text = contentTitle
            self.marqueeHeader.textColor = textColorPrime
            self.marqueeHeader.alpha = barAlpha
            contentName.alpha = 1-barAlpha
            
            //            if (subjectType == "group"){
            //                self.categoryMember.alpha = 1-barAlpha
            //            }
            
        }else{
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            
            self.marqueeHeader.text = ""
            removeNavigationImage(controller: self)
            self.marqueeHeader.alpha = 1
            contentName.alpha = 1-barAlpha
            
            //            if (subjectType == "group"){
            //                self.categoryMember.alpha = 1-barAlpha
            //            }
            
            if (scrollOffset < 10.0){
                contentName.alpha = 1
                //                if (subjectType == "group"){
                //                    self.categoryMember.alpha = 1
                //                }
            }
            
        }
        
        
        
    }
    
    fileprivate func adjustHeaderMaskWithScrollOffset(_ offset: CGFloat) {
        
        // Find bottom of header without growing effect
        _ = self.view.convert(CGPoint(x: 0, y: 44.0-offset), to: self.mainSubView)
        // We set appropriate frame to clip the header
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        //        self.navigationController.frame = CGRect(x:0, 0, self.mainSubView.bounds.size.width, maskBottom.y)
        CATransaction.commit()
    }
    
    @objc func shareItem()
    {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title:  String(format: NSLocalizedString("Share on %@", comment: ""),app_title), style: .default) { action -> Void in
            let pv = AdvanceShareViewController()
            pv.url = self.shareUrl
            pv.param = self.shareParam as! [AnyHashable : Any] as NSDictionary
            pv.Sharetitle = self.contentTitle
            if (self.contentDescription != nil) {
                pv.ShareDescription = self.contentDescription
            }
            pv.imageString = self.coverImageUrl
            pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: pv)
            self.present(nativationController, animated:true, completion: nil)

            
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share Outside",comment: ""), style: UIAlertAction.Style.default) { action -> Void in
            
            var sharingItems = [AnyObject]()
            
            if let text = self.contentTitle {
                sharingItems.append(text as AnyObject)
            }
            
            
            if let url = self.contentUrl {
                let finalUrl = URL(string: url)!
                sharingItems.append(finalUrl as AnyObject)
            }
            
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
    
    @objc func goBack(){
        sitevideoPluginEnabled_event = 0
        if conditionalProfileForm == "BrowsePage"
        {
            
            eventUpdate = true
            groupUpdate = true
            _ = self.navigationController?.popToRootViewController(animated: true)
            
        }
        else
        {
            _ = self.navigationController?.popViewController(animated: false)
        }
        
    }
    
    @objc func openProfile(){
        
        if let _ = responsedic["host"]
        {
            let hostInfo = responsedic["host"]as! NSDictionary
            
            if let hostId = hostInfo["host_id"] as? Int
            {
                if hostId != 0
                {
                    let  hostType = hostInfo["host_type"] as? String
                    if hostType == "user"{
                        
                        let presentedVC = ContentActivityFeedViewController()
                        presentedVC.subjectType = "user"
                        eventUpdate = false
                        presentedVC.subjectId = "\(hostId)"
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    else{
                        
                        let presentedVC = AdvHostMemberViewController()
                        presentedVC.hostId = hostId
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    
                }
                
            }
            else
            {
                showToast(message: "You do not have permission to view this private page.", controller: self)
            }
        }
        else if (self.user_id != nil){
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(user_id!)"
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    @objc func onImageViewTap(){
        if self.coverImageUrl != nil && self.coverImageUrl != "" {
            let presentedVC = SinglePhotoLightBoxController()
            presentedVC.imageUrl = self.coverImageUrl
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            present(nativationController, animated:false, completion: nil)
        }
    }
    // MARK:Rating Function
    func updateRating(_ rating:Int, ratingCount:Int){
        
        
        for ob in ratingView.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 0 as CGFloat
        
        for i in stride(from: 1, through: 5, by: 1){
            let rate = createButton(CGRect(x: origin_x, y: 10, width: 15, height: 15), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clear
            rate.setImage(UIImage(named: "graystar.png"), for: UIControl.State() )
            
            if rated == false
            {
                rate.tag = i
                rate.addTarget(self, action: Selector(("rateAction:")), for: .touchUpInside)
            }
            else
            {
                if i <= rating
                {
                    //                    rate.backgroundColor = UIColor.green
                    rate.setImage(UIImage(named: "yellowStar.png"), for: UIControl.State() )
                }
                
            }
            origin_x += 17
            ratingView.addSubview(rate)
        }
        
        
        var totalRated = ""
        totalRated = singlePluralCheck( NSLocalizedString(" rating", comment: ""),  plural: NSLocalizedString(" ratings", comment: ""), count: ratingCount)
        
        let ratedInfo = createLabel(CGRect(x: (ratingView.center.x - 50), y: 30,width: 75 , height: 17),text: totalRated, alignment: .center, textColor: textColorMedium)
        ratedInfo.font = UIFont(name: fontName, size:FONTSIZESmall)
        ratedInfo.isHidden = true
        ratingView.addSubview(ratedInfo)
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
