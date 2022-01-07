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
//  PageDetailViewController.swift
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

var pageDetailUpdate = false
var sitevideoPluginEnabled_page : Int = 0
class PageDetailViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate , UITabBarControllerDelegate{
    
    
    
    var lastContentOffset: CGFloat = 0
    var subjectId:String!                         // For use Activity Feed updates in Other Modules
    var subjectType:String!                    // For use Activity Feed updates in Other Modules
    var showSpinner = true                      // show spinner flag for pull to refresh
    var refresher:UIRefreshControl!             // Refresher for Pull to Refresh
    var maxid:Int!                              // MaxID for Pagination
    var minid:Int!                              // MinID for New Feeds
    var updateScrollFlag = true                 // Flag for Pagination by ScrollView Delegate
    var activityFeeds:[ActivityFeed] = []       // To save Activity Feeds from Response (subclass of ActivityFeed)
    var contentUrl : String!
    var shareDescription : String!
    var coverImageUrl : String! = ""
    var mainSubView:UIView!
    var coverImage:UIImageView = {
        let image = UIImageView()
        image.contentMode = UIView.ContentMode.scaleAspectFill
        image.layer.masksToBounds = true
        image.isUserInteractionEnabled = true
        return image
    }()
    var tabsContainerMenu = UIScrollView()
    var staticTabMenu:UIScrollView!
    var isPageReviewed = 0
    var headerHeight:CGFloat = 0
    var maxHeight : CGFloat!
    var contentTitle : String!
    var shareTitle:String!
    var user_id : Int!
    
    var pageName : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    var ownerName = UILabel()
    var categoryLabel = UILabel()
    var borderLine = UIView()
    var borderLine1 = UIView()
    var locationLabel = UILabel()
    var locationButton = UIButton()
    var locationDescriptionBlock = UIView()
    var bottomMessageBlock  = UIView()
    var descriptionLabel : TTTAttributedLabel!
    var bottomMessage = UIButton()
    var visitWebsite = UIButton()
    var bottomCall = UIButton()
    var websiteDetail = ""
    var popAfterDelay:Bool!
    var gutterMenu:NSMutableArray = []
    var topView: UIView!
    var ratingLabel: UILabel?
    
    var pageProfileImage: UIImageView = {
        let image = UIImageView()
        image.layer.masksToBounds = false
        image.clipsToBounds = true
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.clear.cgColor
        image.contentMode = UIView.ContentMode.scaleAspectFill
        image.isUserInteractionEnabled = true
        return image
    }()
    
    var shareUrl : String!
    var shareParam : NSDictionary!
    var info = UILabel()
    var UserId:Int!
    var isLike = false
    let characterCount = 200
    var upperView = UIView()
    var titleshow :Bool  = false
    var titleHeight:CGFloat = 0
    var temptitleInfo : String = ""
    var action_id:Int!
    var actionIdArray = [Int]()
    var noCommentMenu:Bool = false
    var descRedirectionButton : UIButton!
    var mainView = UIView()
    var deleteListingEntry:Bool!
    var webviewText : String!
    var feedObj = FeedTableViewController()
    var profileView = UIView()
    var tabMenuPage: NSArray = []
    var followUrl = ""
    var reviewUrl = ""
    var checkUpdate : Bool = false
    var marqueeHeader : MarqueeLabel!
    var contactInfo = NSDictionary()
    var isowner = Bool()
    var likeCallBlock = UIView()
    var likeButton = UIButton()
    var callButton = UIButton()
    var reviewButton = UIButton()
    var messageButton = UIButton()
    var selectedMoreLess = false
    var pageDescription = ""
    var likes : Int!
    var phoneNum = ""
    var locationNavigationButton = UIButton()
    var currencySymbol = ""
    
    // For Cover Photo
    var userCoverPicUrl : String!
    var topMainView : UIView!
    var contentSelection : UIButton!
    var profilePhotoMenu: NSArray = []
    var coverPhotoMenu: NSArray = []
    var imageMenus: NSArray = []
    var camIconOnCover: UILabel!
    var camIconOnProfile: UILabel!
    var userProfilePicUrl : String!
    var coverValue : Int! = 0
    var profileValue : Int! = 0
    var pageTitle : String!
    var ownerTitle : String!
    var categoryTitle : String!
    var descriptionString : String!
    var locationInfo : String!
    var coverImageUrl1 = ""
    var pageProfileUrl = ""
    var shimmerTabView = UIView()
    var shimmerViews = UIView()
    var isComingFromPage = false
    let textColorshimmer = UIColor(red: 227/255.0, green: 227/255.0, blue: 227/255.0, alpha: 1.0)
    override func viewDidLoad()
    {
        super.viewDidLoad()
        isshimmer = true
        Messag_Owner = false
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.isHidden = false
        maxid = 0       // Set Default maxid for browseFeed
        
        pageUpdate = false
        checkUpdate = false
        tableViewFrameType = "Pages"
        pageDetailUpdate = false
        deleteListingEntry = false
        contentFeedArray.removeAll(keepingCapacity: false)
        self.feedObj.globalArrayFeed = contentFeedArray
        self.tabBarController?.delegate = self
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(PageDetailViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        feedObj.willMove(toParent: self)
        self.view.addSubview(feedObj.view)
        feedObj.tableView.backgroundColor = .white
        self.addChild(feedObj)
        NotificationCenter.default.addObserver(self, selector: #selector(PageDetailViewController.ScrollingactionPage(_:)), name: NSNotification.Name(rawValue: "ScrollingactionPage"), object: nil)
        
        removeNavigationImage(controller: self)
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            mainSubView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 370), borderColor: borderColorLight, shadow: false)
            mainSubView.layer.borderWidth = 0.0
        }
        else
        {
            mainSubView = createView(CGRect(x: 0,y: 0, width: view.bounds.width, height: 250), borderColor: borderColorLight, shadow: false)
            mainSubView.layer.borderWidth = 0.0
        }
        mainSubView.backgroundColor = .white
        self.feedObj.tableView.addSubview(mainSubView)
        upperView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 410)
        self.feedObj.tableView.tableHeaderView = upperView
        
        
        coverImage.frame = CGRect(x: 0, y: 0, width: mainSubView.bounds.width, height: mainSubView.bounds.height)
        coverImage.tag = 123
        coverImage.backgroundColor = textColorshimmer
        upperView.addSubview(coverImage)
        coverImage.isHidden = true
        
        topView = createView(CGRect(x: 0, y: coverImage.bounds.height , width: view.bounds.width, height: 120), borderColor: UIColor.clear, shadow: false)
        topView.backgroundColor = lightBgColor //UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        upperView.addSubview(topView)
        topView.isHidden = true
        
        pageProfileImage.frame = CGRect(x: 5, y: (topView.frame.size.height - 80)/2, width: 80, height: 80)
        pageProfileImage.backgroundColor = textColorshimmer
        pageProfileImage.layer.cornerRadius = pageProfileImage.frame.height/2
        pageProfileImage.tag = 321
        topView.addSubview(pageProfileImage)
        
        pageName.frame = CGRect(x: getRightEdgeX(inputView: pageProfileImage) + 12, y: 30, width: view.bounds.width - (pageProfileImage.frame.size.width + 10), height: 20)
        pageName.textColor = textColorDark
        pageName.textAlignment = .left
        topView.addSubview(pageName)
        
        ownerName = createLabel(CGRect(x: getRightEdgeX(inputView: pageProfileImage) + 12, y: getBottomEdgeY(inputView: pageName), width: 150, height: 20), text: "", alignment: .left, textColor: textColorDark)
        ownerName.font = UIFont.systemFont(ofSize: 14)
        ownerName.lineBreakMode = .byTruncatingTail
        topView.addSubview(ownerName)
        
        categoryLabel = createLabel(CGRect(x: getRightEdgeX(inputView: pageProfileImage) + 12, y: getBottomEdgeY(inputView: ownerName), width: 150, height: 20), text: "", alignment: .left, textColor: textColorDark)
        categoryLabel.font = UIFont.systemFont(ofSize: 14)
        categoryLabel.lineBreakMode = .byTruncatingTail
        categoryLabel.text = categoryTitle
        topView.addSubview(categoryLabel)
        
        ratingLabel = createLabel(CGRect(x: getRightEdgeX(inputView: pageProfileImage) + 12, y: getBottomEdgeY(inputView: categoryLabel) + 3, width: 150, height: 20), text: "", alignment: .left, textColor: UIColor(red: 1.0, green: 0.74, blue: 0.30, alpha: 1))
        ratingLabel?.isHidden = true
        ratingLabel!.font = UIFont(name: "FontAwesome", size:12)
        topView.addSubview(ratingLabel!)
        
        
        borderLine.frame = CGRect(x: 0, y: getBottomEdgeY(inputView: self.topView) - 1, width: self.view.frame.size.width, height: 1)
        borderLine.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        self.upperView.addSubview(borderLine)
        borderLine.isHidden = true
        
        self.upperView.addSubview(likeCallBlock)
        likeCallBlock.backgroundColor = .white
        likeCallBlock.frame = CGRect(x: 0, y: getBottomEdgeY(inputView: self.coverImage) + self.topView.frame.size.height, width: self.view.frame.width, height: 85)
        let buttonWidth = (self.view.frame.width - 55)/4
        likeButton.frame = CGRect(x: 5, y: 5, width: buttonWidth, height: likeCallBlock.frame.size.height - 10)
        callButton.frame = CGRect(x: getRightEdgeX(inputView: likeButton) + 15, y: 5, width: buttonWidth, height: likeCallBlock.frame.size.height - 10)
        reviewButton.frame = CGRect(x: getRightEdgeX(inputView: callButton) + 15, y: 5, width: buttonWidth, height: likeCallBlock.frame.size.height - 10)
        messageButton.frame = CGRect(x: getRightEdgeX(inputView: reviewButton) + 15, y: 5, width: buttonWidth, height: likeCallBlock.frame.size.height - 10)
        likeCallBlock.addSubview(likeButton)
        likeCallBlock.addSubview(callButton)
        likeCallBlock.addSubview(reviewButton)
        likeCallBlock.addSubview(messageButton)
        likeCallBlock.isHidden = true
        
        
        reviewButton.addTarget(self, action: #selector(PageDetailViewController.writeReview), for: .touchUpInside)
        
        let fontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: textColorDark]
        
        
        let attributedString2 = "\u{f095}"
        let myAttribute2 = [ NSAttributedString.Key.foregroundColor: iconColor, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:30.0)]
        let myAttrString2 = NSAttributedString(string: attributedString2, attributes: myAttribute2)
        let nonAttributedString2 = NSAttributedString(string:NSLocalizedString("\nCall", comment: "") , attributes: fontAttribute )
        let finalString2 = NSMutableAttributedString()
        finalString2.append(myAttrString2)
        finalString2.append(nonAttributedString2)
        callButton.titleLabel?.numberOfLines = 2
        callButton.titleLabel?.textAlignment = .center
        callButton.setAttributedTitle(finalString2, for: .normal)
        callButton.isHidden = false
        callButton.isUserInteractionEnabled = false
        
        
        let attributedString3 = "\u{f040}"
        let myAttribute3 = [ NSAttributedString.Key.foregroundColor: iconColor, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:30.0)]
        let myAttrString3 = NSAttributedString(string: attributedString3, attributes: myAttribute3)
        let nonAttributedString3 = NSAttributedString(string:NSLocalizedString("\nReview", comment: "") , attributes: fontAttribute )
        let finalString3 = NSMutableAttributedString()
        finalString3.append(myAttrString3)
        finalString3.append(nonAttributedString3)
        reviewButton.titleLabel?.numberOfLines = 2
        reviewButton.titleLabel?.textAlignment = .center
        reviewButton.setAttributedTitle(finalString3, for: .normal)
        reviewButton.isHidden = false
        reviewButton.isUserInteractionEnabled = false
        
        
        let attributedString4 = "\u{f003}"
        let myAttribute4 = [ NSAttributedString.Key.foregroundColor: iconColor, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:30.0)]
        let myAttrString4 = NSAttributedString(string: attributedString4, attributes: myAttribute4)
        let nonAttributedString4 = NSAttributedString(string:NSLocalizedString("\nMessage", comment: "") , attributes: fontAttribute )
        let finalString4 = NSMutableAttributedString()
        finalString4.append(myAttrString4)
        finalString4.append(nonAttributedString4)
        messageButton.titleLabel?.numberOfLines = 2
        messageButton.titleLabel?.textAlignment = .center
        messageButton.setAttributedTitle(finalString4, for: .normal)
        messageButton.isHidden = false
        messageButton.isUserInteractionEnabled = false
        
        
        borderLine1.frame = CGRect(x: 0, y: getBottomEdgeY(inputView: messageButton) - 4, width: self.view.frame.size.width, height: 1)
        borderLine1.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        likeCallBlock.addSubview(borderLine1)
        borderLine1.isHidden = false
        
        
        locationDescriptionBlock.frame = CGRect(x: 0, y: getBottomEdgeY(inputView: likeCallBlock), width: self.view.frame.size.width, height: 150)
        locationDescriptionBlock.backgroundColor = .white
        self.upperView.frame.size.height = getBottomEdgeY(inputView: locationDescriptionBlock)
        self.upperView.addSubview(locationDescriptionBlock)
        
        locationLabel.frame = CGRect(x: 7, y: 1, width: 250, height: 0)
        locationLabel.numberOfLines = 3
        locationLabel.isHidden = true
        locationDescriptionBlock.addSubview(locationLabel)
        
        locationNavigationButton.frame = CGRect(x: getRightEdgeX(inputView: locationLabel), y: 5, width: 30, height: 20)
        locationDescriptionBlock.addSubview(locationNavigationButton)
        locationNavigationButton.isHidden = true
        locationNavigationButton.setImage(UIImage(named: "locationIcon"), for: .normal)
        locationNavigationButton.addTarget(self, action: #selector(PageDetailViewController.redirectToMap(sender:)), for: .touchUpInside)
        locationNavigationButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 18)
        
        
        descriptionLabel = TTTAttributedLabel(frame: CGRect(x: 7,  y: getBottomEdgeY(inputView: locationLabel) + 5, width: view.bounds.width - 14, height: 0))
        descriptionLabel.delegate = self
        descriptionLabel.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        descriptionLabel.numberOfLines = 0
        descriptionLabel.longPressLabel()
        self.descriptionLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        locationDescriptionBlock.addSubview(descriptionLabel)
        self.descriptionLabel.textAlignment = .justified
        
        tabsContainerMenu = UIScrollView(frame: CGRect(x: PADING, y: getBottomEdgeY(inputView: descriptionLabel),width: view.bounds.width-2*PADING ,height: ButtonHeight ))
        tabsContainerMenu.backgroundColor = TabMenubgColor
        tabsContainerMenu.isHidden = true
        self.upperView.addSubview(tabsContainerMenu)
        
        staticTabMenu = UIScrollView(frame: CGRect(x: PADING, y: TOPPADING,width: view.bounds.width-2*PADING ,height: ButtonHeight ))
        staticTabMenu.isHidden = true
        staticTabMenu.backgroundColor = TabMenubgColor
        self.upperView.addSubview(staticTabMenu)
        
        
        // Initialize Pull to Refresh to ActivityFeed Table
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(PageDetailViewController.refresh), for: UIControl.Event.valueChanged)
        self.feedObj.tableView.addSubview(refresher)
        
        // Cover Photo and Profile Photo
        
        camIconOnCover = createLabel(CGRect(x: coverImage.bounds.width - 30, y: coverImage.bounds.height - 30, width: 20, height: 20), text: "\(cameraIcon)", alignment: .center, textColor: textColorLight)
        camIconOnCover.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        camIconOnCover.isHidden = true
        coverImage.addSubview(camIconOnCover)
        
        
        camIconOnProfile = createLabel(CGRect(x: (pageProfileImage.bounds.width/2) - 15, y: pageProfileImage.bounds.height - 30, width: 30, height: 30), text: "\(cameraIcon)", alignment: .center, textColor: textColorLight)
        camIconOnProfile.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        camIconOnProfile.layer.shadowColor = shadowColor.cgColor
        camIconOnProfile.layer.shadowOpacity = shadowOpacity
        camIconOnProfile.layer.shadowRadius = shadowRadius
        camIconOnProfile.layer.shadowOffset = shadowOffset
        camIconOnProfile.isHidden = true
        pageProfileImage.addSubview(camIconOnProfile)
        
        
        self.automaticallyAdjustsScrollViewInsets = false;
        
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        feedObj.tableView.tableFooterView = footerView
        feedObj.tableView.tableFooterView?.isHidden = true
        
        if self.isComingFromPage {
            createUpperView()
            self.feedObj.tableView.reloadData()
            self.bottomMessageBlock.isHidden = true
            self.shimmerTabs()
        }
        else {
            self.shimmerView()
        }
        exploreContent()
        
    }
    @objc private func dismissView() {
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
    }
    
    @objc func redirectToMap(sender : UIButton) {
        let vc = MapViewController()
        vc.location = self.locationInfo
        vc.place_id = ""
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.browseEmoji(contentItems: reactionsDictionary)
        //  updateAfterAlert = false
        tableViewFrameType = "Pages"
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        NotificationCenter.default.addObserver(self, selector: #selector(PageDetailViewController.ScrollingactionPage(_:)), name: NSNotification.Name(rawValue: "ScrollingactionPage"), object: nil)
        removeNavigationImage(controller: self)
        //scrollopoint = CGPointMake(0, 0)
        
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
        }
        
        let allviews = view.subviews
        for obj in allviews
        {
            if obj .isKind(of: Like_CommentView.self)
            {
                obj.removeFromSuperview()
            }
        }
        
        subject_unique_id =  subjectId
        subject_unique_type = "sitepage_page"
        
        self.view.addSubview(self.bottomMessageBlock)
        maxidTikTok = 0
        API_getAAFList()
        
        if pageDetailUpdate {
            pageDetailUpdate = false
            contentFeedArray.removeAll()
            exploreContent()
            updatePage()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        feedObj.tableView.tableFooterView?.isHidden = true
        self.marqueeHeader.text = ""
        tableViewFrameType = ""
        removeMarqueFroMNavigaTion(controller: self)
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = textColorPrime
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
    
    @objc func writeReview() {
        isCreateOrEdit = true
        globFilterValue = ""
        if self.isPageReviewed == 0 {
            let presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Write a Review", comment: "")
            presentedVC.contentType = "Review"
            presentedVC.param = [ : ]
            presentedVC.url = "sitepage/reviews/create/" + subjectId + "/"
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:true, completion: nil)
        }
        else {
            showToast(message: "You have already reviewed on this page", controller: self)
        }
    }
    
    
    func createUpperView() {
        coverImage.isHidden = false
        topView.isHidden = false
        borderLine.isHidden = false
        likeCallBlock.isHidden = false
        self.coverImage.kf.setImage(with: URL(string: self.coverImageUrl1), placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
            
        })
        self.pageProfileImage.kf.setImage(with: URL(string: self.pageProfileUrl), placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
            if image == nil {
                self.pageProfileImage.image = UIImage(named: "user_profile_image.png")
            }
        })
        var name = ""
        name = NSLocalizedString("by ", comment: "")
        self.ownerName.text = name + ownerTitle
        pageName.text = self.pageTitle
        
        if locationInfo != nil && locationInfo != "" {
            let locationIcon = "\u{f041}"
            let nonAttrFont = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: textColorDark]
            let nonAttString1 = NSAttributedString(string:NSLocalizedString("Details:\n\n", comment: "") , attributes: nonAttrFont )
            let locationAttr = [ NSAttributedString.Key.foregroundColor: textColorDark, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:12.0)]
            let attrString = NSAttributedString(string: locationIcon, attributes: locationAttr)
            let nonAttrString2 = NSAttributedString(string:NSLocalizedString("  \(locationInfo!)", comment: "") , attributes: nonAttrFont )
            let finalStr = NSMutableAttributedString()
            finalStr.append(nonAttString1)
            finalStr.append(attrString)
            finalStr.append(nonAttrString2)
            self.locationLabel.attributedText = finalStr
            self.locationLabel.isHidden = false
            if self.locationLabel.intrinsicContentSize.width > self.view.frame.size.width - 80 {
                self.locationLabel.frame.size.width = self.view.frame.size.width - 80
            }
            else {
                self.locationLabel.frame.size.width = self.locationLabel.intrinsicContentSize.width
            }
            self.locationLabel.frame.size.height = 60
            self.locationNavigationButton.frame.origin.x = getRightEdgeX(inputView: self.locationLabel) + 5
            self.locationNavigationButton.frame.origin.y = getBottomEdgeY(inputView: self.locationLabel) -  20
            self.locationNavigationButton.isHidden = false
        }
        else {
            self.locationLabel.isHidden = true
            self.locationNavigationButton.isHidden = true
            
        }
        if self.descriptionString.count < self.characterCount {
            self.descriptionLabel.setText(self.descriptionString, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                
                // TODO: Clean this up...
                return mutableAttributedString
            })
            self.descriptionLabel.sizeToFit()
            self.descriptionLabel.frame.origin.y = getBottomEdgeY(inputView: self.locationLabel)
            self.locationDescriptionBlock.frame.size.height = getBottomEdgeY(inputView: self.descriptionLabel) + 10
            self.upperView.frame.size.height = getBottomEdgeY(inputView: self.descriptionLabel) + 10
            self.feedObj.tableView.tableHeaderView?.frame.size.height =  self.upperView.frame.size.height
        }
        else {
            self.pageDescription = descriptionString
            self.moreOrLess()
        }
        likeButton.titleLabel?.font = UIFont(name: "FontAwesome", size:30.0)
        likeButton.setTitle("\u{f087}", for: .normal)
        likeButton.titleLabel?.textAlignment = .center
        likeButton.isHidden = false
        likeButton.isUserInteractionEnabled = false
        self.likeButton.setTitleColor(buttonColor, for: .normal)
        let attributedString1 = "\u{f087}"
        let myAttribute1 = [ NSAttributedString.Key.foregroundColor: iconColor, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:30.0)]
        let myAttrString1 = NSAttributedString(string: attributedString1, attributes: myAttribute1)
        let fontAttribute1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: textColorDark]
        let nonAttributedString1 = NSAttributedString(string:NSLocalizedString("\n\(self.likes!)", comment: "") , attributes: fontAttribute1 )
        let finalString1 = NSMutableAttributedString()
        finalString1.append(myAttrString1)
        if self.likes > 0 {
            finalString1.append(nonAttributedString1)
        }
        self.likeButton.titleLabel?.numberOfLines = 2
        self.likeButton.titleLabel?.textAlignment = .center
        self.likeButton.setAttributedTitle(finalString1, for: .normal)
    }
    
    func exploreContent(){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            
            // Send Server Request to Explore Page Contents with Page_ID
            post([ "gutter_menu": "1"], url: "sitepage/view/" + String(subjectId), method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    self.shimmerTabView.stop()
                    self.shimmerTabView.removeFromSuperview()
                    self.shimmerViews.stop()
                    self.shimmerViews.removeFromSuperview()
                    if msg{
                        // On Success Update Page Detail
                        self.likeCallBlock.isHidden = false
                        self.borderLine.isHidden = false
                        self.coverImage.isHidden = false
                        self.topView.isHidden = false
                        if let listing = succeeded["body"] as? NSDictionary {
                            if let sitevideoPluginEnabled = listing["sitevideoPluginEnabled"] as? Int
                            {
                                sitevideoPluginEnabled_page = sitevideoPluginEnabled
                            }
                            if let owner_id = listing["owner_id"] as? Int{
                                self.user_id = owner_id
                            }
                            if let currency = listing["currency"] as? String {
                                self.currencySymbol = getCurrencySymbol(currency)
                            }
                            
                            if let menu = listing["gutterMenu"] as? NSArray{
                                var isCancel = false
                                self.gutterMenu  = menu as NSArray as! NSMutableArray
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
                                    }
                                }
                                if Messag_Owner {
                                    self.messageButton.addTarget(self, action: #selector(PageDetailViewController.messageToOwner), for: .touchUpInside)
                                }
                                else {
                                    self.messageButton.isEnabled = false
                                }
                                
                                if logoutUser == false{
                                    
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")!.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    shareButton.addTarget(self, action: #selector(PageDetailViewController.shareItem), for: .touchUpInside)
                                    rightNavView.addSubview(shareButton)
                                    
                                    let optionButton = createButton(CGRect(x: 22,y: 0,width: 45,height: 45), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")!.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    optionButton.addTarget(self, action: #selector(PageDetailViewController.showGutterMenu), for: .touchUpInside)
                                    //    rightNavView.addSubview(optionButton)
                                    if isCancel == false
                                    {
                                        shareButton.frame.origin.x = 44
                                    }
                                    else
                                    {
                                        rightNavView.addSubview(optionButton)
                                    }
                                    let barButtonItem = UIBarButtonItem(customView: rightNavView)
                                    
                                    self.navigationItem.rightBarButtonItem = barButtonItem
                                }
                                
                            }
                            
                            if let cover = listing["cover_image"] as? String {
                                self.coverImage.kf.setImage(with: URL(string: cover), placeholder: nil, options: [.transition(.fade(1.0))], progressBlock: nil, completionHandler: { (image, error, cache, url) in
                                    //
                                })
                            }
                            if let isReviewed = listing["hasPosted"] as? Int {
                                self.isPageReviewed = isReviewed
                            }
                            
                            if let pageProfileUrl = listing["image_profile"] as? String {
                                self.pageProfileImage.kf.setImage(with: URL(string: pageProfileUrl), placeholder: nil, options: [.transition(.fade(1.0))], progressBlock: nil, completionHandler: { (image, error, cache, url) in
                                    //
                                })
                            }
                            if let ownerTitle = listing["owner_title"] as? String {
                                var name = ""
                                name = NSLocalizedString("by ", comment: "")
                                self.ownerName.text = name + ownerTitle
                            }
                            if let page = listing["title"] as? String {
                                self.pageName.text = page
                            }
                            if let rating = listing["rating"] as? Int {
                                if rating > 0 {
                                    self.ratingLabel!.isHidden = false
                                    self.ratingLabel!.textColor = UIColor(red: 1.0, green: 0.74, blue: 0.30, alpha: 1)
                                    self.ratingLabel!.font = UIFont(name: "FontAwesome", size:12)
                                    self.ratingLabel!.text = ""
                                    var ratingString = ""
                                    if rating % 1 == 0 {
                                        for _ in 1...rating {
                                            ratingString += "\u{f005}"
                                        }
                                    }
                                    else {
                                        
                                        let rem = rating % 1
                                        let intValue = rating - rem
                                        for _ in 1...intValue {
                                            ratingString += "\u{f005}"
                                        }
                                        ratingString += "\u{f123}"
                                    }
                                    if let reviewCount = listing["review_count"] as? Int, reviewCount > 0 {
                                        ratingString += "  (\(reviewCount))"
                                    }
                                    
                                    self.ratingLabel!.text = ratingString
                                }
                                
                            }
                            if let location = listing["location"] as? String {
                                if  location != "" {
                                    self.locationInfo = location
                                    let locationIcon = "\u{f041}"
                                    let nonAttrFont = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: textColorDark]
                                    let nonAttString1 = NSAttributedString(string:NSLocalizedString("Details:\n\n", comment: "") , attributes: nonAttrFont )
                                    let locationAttr = [ NSAttributedString.Key.foregroundColor: textColorDark, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:12.0)]
                                    let attrString = NSAttributedString(string: locationIcon, attributes: locationAttr)
                                    let nonAttrString2 = NSAttributedString(string:NSLocalizedString("  \(location)", comment: "") , attributes: nonAttrFont )
                                    let finalStr = NSMutableAttributedString()
                                    finalStr.append(nonAttString1)
                                    finalStr.append(attrString)
                                    finalStr.append(nonAttrString2)
                                    self.locationLabel.attributedText = finalStr
                                    self.locationLabel.isHidden = false
                                    if self.locationLabel.intrinsicContentSize.width > self.view.frame.size.width - 80 {
                                        self.locationLabel.frame.size.width = self.view.frame.size.width - 80
                                    }
                                    else {
                                        self.locationLabel.frame.size.width = self.locationLabel.intrinsicContentSize.width
                                    }
                                    self.locationLabel.frame.size.height = 60
                                    self.locationNavigationButton.frame.origin.x = getRightEdgeX(inputView: self.locationLabel) + 5
                                    self.locationNavigationButton.frame.origin.y = getBottomEdgeY(inputView: self.locationLabel) -  20
                                    self.locationNavigationButton.isHidden = false
                                }
                                else {
                                    self.locationLabel.isHidden = true
                                    self.locationNavigationButton.isHidden = true
                                    
                                }
                            }
                            if let description = listing["body"] as? String {
                                self.descriptionString = description
                                if description.count < self.characterCount {
                                    self.descriptionLabel.setText(description, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                        
                                        // TODO: Clean this up...
                                        return mutableAttributedString
                                    })
                                    self.descriptionLabel.sizeToFit()
                                    self.descriptionLabel.frame.origin.y = getBottomEdgeY(inputView: self.locationLabel)
                                    self.locationDescriptionBlock.frame.size.height = getBottomEdgeY(inputView: self.descriptionLabel) + 10
                                    self.upperView.frame.size.height = getBottomEdgeY(inputView: self.descriptionLabel) + 10
                                    self.feedObj.tableView.tableHeaderView?.frame.size.height =  getBottomEdgeY(inputView: self.upperView) + 5
                                }
                                else {
                                    self.pageDescription = description
                                    self.moreOrLess()
                                }
                            }
                            if let likeCount = listing["like_count"] as? Int {
                                self.likeButton.titleLabel?.font = UIFont(name: "FontAwesome", size:30.0)
                                self.likeButton.setTitle("\u{f087}", for: .normal)
                                self.likeButton.titleLabel?.textAlignment = .center
                                self.likeButton.isHidden = false
                                self.likeButton.isUserInteractionEnabled = false
                                self.likeButton.setTitleColor(buttonColor, for: .normal)
                                let attributedString1 = "\u{f087}"
                                let myAttribute1 = [ NSAttributedString.Key.foregroundColor: iconColor, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:30.0)]
                                let myAttrString1 = NSAttributedString(string: attributedString1, attributes: myAttribute1)
                                let fontAttribute1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: textColorDark]
                                let nonAttributedString1 = NSAttributedString(string:NSLocalizedString("\n\(likeCount)", comment: "") , attributes: fontAttribute1 )
                                let finalString1 = NSMutableAttributedString()
                                finalString1.append(myAttrString1)
                                if likeCount > 0 {
                                    finalString1.append(nonAttributedString1)
                                }
                                self.likeButton.titleLabel?.numberOfLines = 2
                                self.likeButton.titleLabel?.textAlignment = .center
                                self.likeButton.setAttributedTitle(finalString1, for: .normal)
                            }
                            
                            self.bottomMessageBlock.alpha = 1
                            self.bottomMessageBlock.layer.shadowColor = shadowColor.cgColor
                            self.bottomMessageBlock.layer.shadowOffset = shadowOffset
                            self.bottomMessageBlock.layer.shadowRadius = shadowRadius
                            self.bottomMessageBlock.layer.shadowOpacity = shadowOpacity
                            self.bottomMessageBlock.backgroundColor = .white
                            self.view.addSubview(self.bottomMessageBlock)
                            
                            let buttonWidth1 = 0.6 * (self.view.frame.width - 40)/2
                            let buttonWidth2 = 0.4 * (self.view.frame.width - 40)
                            self.bottomMessage.frame = CGRect(x: 5 , y: 5, width: buttonWidth1, height: 60)
                            self.visitWebsite.frame = CGRect(x: getRightEdgeX(inputView: self.bottomMessage) + 15 , y: 5, width: buttonWidth1, height: 60)
                            self.bottomCall.frame = CGRect(x: getRightEdgeX(inputView: self.visitWebsite) + 15 , y: 15, width: buttonWidth2, height: 40)
                            self.bottomMessageBlock.addSubview(self.bottomMessage)
                            self.bottomMessageBlock.addSubview(self.visitWebsite)
                            self.bottomMessageBlock.addSubview(self.bottomCall)
                            
                            let fontAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: textColorDark]
                            let attributedString3 = "\u{f09d}"
                            let myAttribute3 = [ NSAttributedString.Key.foregroundColor: iconColor, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:30.0)]
                            let myAttrString3 = NSAttributedString(string: attributedString3, attributes: myAttribute3)
                            let nonAttributedString3 = NSAttributedString(string:NSLocalizedString("\nVisit Website", comment: "") , attributes: fontAttribute )
                            let finalString3 = NSMutableAttributedString()
                            finalString3.append(myAttrString3)
                            finalString3.append(nonAttributedString3)
                            self.visitWebsite.titleLabel?.numberOfLines = 2
                            self.visitWebsite.titleLabel?.textAlignment = .center
                            self.visitWebsite.setAttributedTitle(finalString3, for: .normal)
                            
                            if let website = listing["website"] as? String {
                                self.websiteDetail = website
                            }
                            self.visitWebsite.addTarget(self, action: #selector(PageDetailViewController.openWebsite), for: .touchUpInside)
                            if let phoneNumber = listing["phone"] as? String, phoneNumber != "" {
                                let newString = phoneNumber.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
                                self.phoneNum = newString
                                self.callButton.tag = Int(newString) ?? 0
                            }
                            else {
                                self.callButton.alpha = 0.5
                            }
                            self.callButton.addTarget(self, action: #selector(PageDetailViewController.openDialPad(sender:)), for: .touchUpInside)
                            self.likeButton.addTarget(self, action: #selector(PageDetailViewController.likeUnlike), for: .touchUpInside)
                            
                            if let phoneNumber = listing["phone"] as? String, phoneNumber != "" {
                                let newString = phoneNumber.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
                                self.phoneNum = newString
                                self.callButton.tag = Int(newString) ?? 0
                            }
                            else {
                                self.callButton.alpha = 0.5
                            }
                            self.callButton.addTarget(self, action: #selector(PageDetailViewController.openDialPad(sender:)), for: .touchUpInside)
                            self.likeButton.addTarget(self, action: #selector(PageDetailViewController.likeUnlike), for: .touchUpInside)

                            self.likeButton.isUserInteractionEnabled = true
                            self.callButton.isUserInteractionEnabled = true
                            if enabledModules.contains("sitepagereview") {
                                self.reviewButton.isUserInteractionEnabled = true
                                self.reviewButton.alpha = 1.0
                            }
                            else {
                                self.reviewButton.isUserInteractionEnabled = false
                                self.reviewButton.alpha = 0.5
                            }
                            self.messageButton.isUserInteractionEnabled = true
                            
                            if let phoneNumber = listing["phone"] as? String, phoneNumber == "" {
                                let temp = self.bottomMessage.frame
                                self.bottomMessage.frame = self.bottomCall.frame
                                self.bottomCall.frame = temp
                                
                                
                                let callIcon = "\u{f003}"
                                let callText = " Message"
                                
                                self.bottomMessage.titleLabel?.font = UIFont(name: "FontAwesome", size:16.0)
                                self.bottomMessage.titleLabel?.numberOfLines = 1
                                self.bottomMessage.setTitleColor(textColorPrime, for: .normal)
                                self.bottomMessage.setTitle(callIcon + callText, for: .normal)
                                self.bottomMessage.titleLabel?.textAlignment = .center
                                self.bottomMessage.backgroundColor = buttonColor
                                self.bottomMessage.contentVerticalAlignment = .fill
                                
                                
                                let attributedString4 = "\u{f095}"
                                let myAttribute4 = [ NSAttributedString.Key.foregroundColor: iconColor, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:30.0)]
                                let myAttrString4 = NSAttributedString(string: attributedString4, attributes: myAttribute4)
                                let nonAttributedString4 = NSAttributedString(string:NSLocalizedString("\nCall", comment: "") , attributes: fontAttribute )
                                let finalString4 = NSMutableAttributedString()
                                finalString4.append(myAttrString4)
                                finalString4.append(nonAttributedString4)
                                self.bottomCall.titleLabel?.numberOfLines = 2
                                self.bottomCall.backgroundColor = .white
                                self.bottomCall.titleLabel?.textAlignment = .center
                                self.bottomCall.setAttributedTitle(finalString4, for: .normal)
                                
                            }
                            else {
                                let attributedString4 = "\u{f003}"
                                let myAttribute4 = [ NSAttributedString.Key.foregroundColor: iconColor, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:30.0)]
                                let myAttrString4 = NSAttributedString(string: attributedString4, attributes: myAttribute4)
                                let nonAttributedString4 = NSAttributedString(string:NSLocalizedString("\nMessage", comment: "") , attributes: fontAttribute )
                                let finalString4 = NSMutableAttributedString()
                                finalString4.append(myAttrString4)
                                finalString4.append(nonAttributedString4)
                                self.bottomMessage.titleLabel?.numberOfLines = 2
                                self.bottomMessage.titleLabel?.textAlignment = .center
                                self.bottomMessage.setAttributedTitle(finalString4, for: .normal)
                                
                                
                                let callIcon = "\u{f095}"
                                let callText = " Call"
                                self.bottomCall.titleLabel?.font = UIFont(name: "FontAwesome", size:18.0)
                                self.bottomCall.setTitleColor(textColorPrime, for: .normal)
                                self.bottomCall.setTitle(callIcon + callText, for: .normal)
                                self.bottomCall.titleLabel?.textAlignment = .center
                                self.bottomCall.backgroundColor = buttonColor
                                self.bottomCall.contentVerticalAlignment = .fill
                            }
                            
                            self.bottomCall.addTarget(self, action: #selector(PageDetailViewController.openDialPad(sender:)), for: .touchUpInside)
                            if self.phoneNum == "" {
                                self.bottomCall.alpha = 0.5
                            }
                            self.bottomCall.tag = Int(self.phoneNum) ?? 0
                            
                            if DeviceType.IS_IPHONE_X{
                                self.bottomMessageBlock.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 70 - tabBarHeight,width: UIScreen.main.bounds.width,height: 70)
                                
                            }
                            else{
                                self.bottomMessageBlock.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 70 - tabBarHeight,width: UIScreen.main.bounds.width,height: 70)
                                
                            }
                            if Messag_Owner {
                                self.bottomMessage.addTarget(self, action: #selector(PageDetailViewController.messageToOwner), for: .touchUpInside)
                            }
                            else {
                                self.bottomMessage.isEnabled = false
                            }
                            
                            if let tabsContainerMenuItems = listing["profile_tabs"] as? NSArray
                            {
                                self.tabMenuPage = tabsContainerMenuItems as NSArray
                                self.tabsContainerMenu.isHidden = false
                            }
                            
                            let response = listing
                            
                            if response.count > 0{
                                
                                // set Page Title
                                self.shareTitle = response["title"] as? String
                                
                                if let category = response["category_title"] as? String {
                                    var categ = ""
                                    categ = category
                                    if let subCategory = response["subcategory_title"] as? String {
                                        categ = category + ", " + subCategory
                                        if let subsubCategory = response["subsubcategory_title"] as? String {
                                            categ = category + ", " + subCategory + ", " + subsubCategory
                                        }
                                    }
                                    self.categoryLabel.text = categ
                                }
                                if let likeCount = response["like_count"] as? Int {
                                    if likeCount > 0 {
                                        self.likes = likeCount
                                        
                                    }
                                    else {
                                        self.likes = likeCount
                                    }
                                }
                                
                                
                                if let isLiked = response["is_like"] as? Bool {
                                    self.isLike = isLiked
                                    if isLiked {
                                        self.likeButton.setTitleColor(buttonColor, for: .normal)
                                        let attributedString1 = "\u{f087}"
                                        let myAttribute1 = [ NSAttributedString.Key.foregroundColor: buttonColor, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:30.0)]
                                        let myAttrString1 = NSAttributedString(string: attributedString1, attributes: myAttribute1)
                                        let fontAttribute1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: buttonColor]
                                        let nonAttributedString1 = NSAttributedString(string:NSLocalizedString("\n\(self.likes!)", comment: "") , attributes: fontAttribute1 )
                                        let finalString1 = NSMutableAttributedString()
                                        finalString1.append(myAttrString1)
                                        if self.likes > 0 {
                                            finalString1.append(nonAttributedString1)
                                        }
                                        
                                        self.likeButton.titleLabel?.numberOfLines = 2
                                        self.likeButton.titleLabel?.textAlignment = .center
                                        self.likeButton.setAttributedTitle(finalString1, for: .normal)
                                    }
                                    else {
                                        self.likeButton.setTitleColor(buttonColor, for: .normal)
                                        let attributedString1 = "\u{f087}"
                                        let myAttribute1 = [ NSAttributedString.Key.foregroundColor: iconColor, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:30.0)]
                                        let myAttrString1 = NSAttributedString(string: attributedString1, attributes: myAttribute1)
                                        let fontAttribute1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: textColorDark]
                                        let nonAttributedString1 = NSAttributedString(string:NSLocalizedString("\n\(self.likes!)", comment: "") , attributes: fontAttribute1 )
                                        let finalString1 = NSMutableAttributedString()
                                        finalString1.append(myAttrString1)
                                        finalString1.append(nonAttributedString1)
                                        self.likeButton.titleLabel?.numberOfLines = 2
                                        self.likeButton.titleLabel?.textAlignment = .center
                                        self.likeButton.setAttributedTitle(finalString1, for: .normal)
                                    }
                                    
                                }
                                
                                if let _ : Int = response["default_cover"] as? Int{
                                    
                                    
                                    let tap1 = UITapGestureRecognizer(target: self, action: #selector(PageDetailViewController.showProfileCoverImageMenu(_:)))
                                    self.coverImage.addGestureRecognizer(tap1)
                                    let tap2 = UITapGestureRecognizer(target: self, action: #selector(PageDetailViewController.showProfileCoverImageMenu(_:)))
                                    self.pageProfileImage.addGestureRecognizer(tap2)
                                    
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
                                    
                                    if let photoId = response["photo_id"] as? Int
                                    {
                                        
                                        if photoId != 0{
                                            self.profileValue = 1
                                        }
                                        if (response["cover_image"] as? String) != nil{
                                            self.coverImageUrl = response["cover_image"] as! String
                                        }
                                        self.userCoverPicUrl = self.coverImageUrl
                                    }
                                    self.getCoverGutterMenu()
                                    
                                    self.userProfilePicUrl = response["image"] as! String
                                    
                                    if (response["cover_image"] as? String) != nil{
                                        
                                        self.userCoverPicUrl = response["cover_image"] as! String
                                    }
                                    
                                }
                                    
                                else{
                                    
                                    let tap1 = UITapGestureRecognizer(target: self, action: #selector(PageDetailViewController.onImageViewTap))
                                    self.coverImage.addGestureRecognizer(tap1)
                                    if let _ = response["title"] as? String
                                    {
                                        self.contentTitle = (response["title"] as? String)!
                                    }
                                    
                                }
                                
                                
                                self.contentUrl =  response["content_url"] as! String
                                
                                if let contactDic = response["contactInfo"] as? NSDictionary{
                                    self.contactInfo = contactDic
                                }
                                if let is_owner = response["isOwner"] as? Bool{
                                    self.isowner = is_owner
                                    //  self.setUpContact()
                                }else{
                                    if self.contactInfo.count>0{
                                        self.isowner = false
                                        //self.setUpContact()
                                    }
                                }
                                
                                if response["overview"] != nil {
                                    self.webviewText = String(describing: response["overview"]! as AnyObject)
                                    self.descriptionString = self.webviewText
                                }
                                
                                self.showtabMenu()
                                self.showTabMenu1()
                                
                                self.tabsContainerMenu.isHidden = false
                                self.tabsContainerMenu.frame.origin.y = getBottomEdgeY(inputView: self.locationDescriptionBlock) + 3
                                self.feedObj.tableView.tableHeaderView?.frame.size.height =  self.upperView.frame.size.height
                                
                                self.browseFeed()
                                self.feedObj.refreshLikeUnLike = true
                                self.feedObj.tableView.reloadData()
                            }
                            
                        }
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
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
    
    
    @objc func likeUnlike() {
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            var path = ""
            let followPath = "sitepage/follow/\(self.subjectId!)"
            // Set path for Like & UnLike
            if self.isLike == true{
                path = "unlike"
                
                let attributedString1 = "\u{f087}"
                let myAttribute1 = [ NSAttributedString.Key.foregroundColor: iconColor, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:30.0)]
                let myAttrString1 = NSAttributedString(string: attributedString1, attributes: myAttribute1)
                let fontAttribute1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: textColorDark]
                let nonAttributedString1 = NSAttributedString(string:NSLocalizedString("\n\(self.likes - 1)", comment: "") , attributes: fontAttribute1 )
                let finalString1 = NSMutableAttributedString()
                finalString1.append(myAttrString1)
                finalString1.append(nonAttributedString1)
                self.likeButton.titleLabel?.numberOfLines = 2
                self.likeButton.titleLabel?.textAlignment = .center
                self.likeButton.setAttributedTitle(finalString1, for: .normal)
                
            }else{
                path = "like"
                let attributedString1 = "\u{f087}"
                let myAttribute1 = [ NSAttributedString.Key.foregroundColor: buttonColor, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:30.0)]
                let myAttrString1 = NSAttributedString(string: attributedString1, attributes: myAttribute1)
                let fontAttribute1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: buttonColor]
                let nonAttributedString1 = NSAttributedString(string:NSLocalizedString("\n\(self.likes + 1)", comment: "") , attributes: fontAttribute1 )
                let finalString1 = NSMutableAttributedString()
                finalString1.append(myAttrString1)
                finalString1.append(nonAttributedString1)
                self.likeButton.titleLabel?.numberOfLines = 2
                self.likeButton.titleLabel?.textAlignment = .center
                self.likeButton.setAttributedTitle(finalString1, for: .normal)
                
            }
            self.likeButton.isEnabled = false
            // Send Server Request to Like/Unlike Content
            post(["subject_id":String(subjectId), "subject_type": subjectType], url: path, method: "POST") {
                (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            self.likeButton.isEnabled = true
                            if(self.isLike == true){
                                self.isLike = false
                                self.likes = self.likes - 1
                            }
                            else
                            {
                                self.isLike = true
                                self.likes = self.likes + 1
                                
                            }
                            let dic = ["": ""]
                            post(dic, url: followPath, method: "POST") { (succeeded, msg) -> () in
                                DispatchQueue.main.async(execute: {
                                    activityIndicatorView.stopAnimating()
                                    if msg{
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
                            
                        }
                        
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            
                        }
                        
                    }
                })
            }
        }else{
            // No Internet Connection Message
            displayAlert("Info", error: network_status_msg)
        }
    }
    
    @objc func openWebsite() {
        if self.websiteDetail == "" {
            showToast(message: NSLocalizedString("Details not added yet",  comment: ""), controller: self)
        }
        else {
            
            if let url = URL(string: self.websiteDetail),
                UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
            
        }
    }
    
    @objc func openDialPad(sender : UIButton) {
        if let phoneCallURL = URL(string: "tel://\(sender.tag)") {
            if "\(sender.tag)".count > 9 {
                let application:UIApplication = UIApplication.shared
                if (application.canOpenURL(phoneCallURL)) {
                    application.open(phoneCallURL, options: [:], completionHandler: nil)
                }
            }
            else {
                showToast(message: NSLocalizedString("Details not added yet",  comment: ""), controller: self)
            }
        }
    }
    func getCoverGutterMenu(){
        
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["subject_type": subjectType , "subject_id": String(subjectId) , "special": "both" , "cover_photo" : String(coverValue) , "profile_photo" : String(profileValue)], url: "coverphoto/get-cover-photo-menu", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
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
                            //showToast(message: succeeded["message"] as! String, controller: self)
                            
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
                                presentedVC.contentType = "sitepage_page"
                                presentedVC.contentId = "\(self.subjectId!)"
                                presentedVC.showCameraButton = false
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "choose_from_album":
                                
                                let presentedVC = ChooseFromAlbumsViewController()
                                presentedVC.showOnlyMyContent = true
                                presentedVC.profileOrCoverChange = isProfileOrCover
                                presentedVC.contentType = "sitepage_page"
                                presentedVC.contentId = "\(self.subjectId!)"
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
                                presentedVC.contentType = "sitepage_page"
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
    
    func moreOrLess(){
        let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZENormal, nil)
        
        if let description = pageDescription as? String{
            var tempInfo = ""
            if description != ""  {
                if self.selectedMoreLess == false{
                    tempInfo += (description as NSString).substring(to: characterCount-3)
                    tempInfo += NSLocalizedString(" More...",  comment: "")
                    self.descriptionLabel.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let range2 = (tempInfo as NSString).range(of: NSLocalizedString("More",  comment: ""))
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTFontAttributeName as NSString) as String as String), value: boldFont, range: range2)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTForegroundColorAttributeName as NSString) as String as String), value:textColorDark , range: range2)
                        
                        return mutableAttributedString
                    })
                    let range = (tempInfo as NSString).range(of: NSLocalizedString("More",  comment: ""))//NSLocalizedString("More",  comment: ""))
                    self.descriptionLabel.addLink(toTransitInformation: [ "type" : "moreContentInfo"], with:range)
                    self.descriptionLabel.sizeToFit()
                    self.descriptionLabel.frame.origin.y = getBottomEdgeY(inputView: self.locationLabel)
                    self.locationDescriptionBlock.frame.size.height = getBottomEdgeY(inputView: self.descriptionLabel) + 8
                    self.tabsContainerMenu.frame.origin.y = getBottomEdgeY(inputView: self.locationDescriptionBlock) + 3
                    for ob in self.upperView.subviews{
                        if ob.tag >= 1991 && ob.tag <= 1993{
                            ob.frame.origin.y = getBottomEdgeY(inputView:  self.tabsContainerMenu) + 5
                        }
                    }
                    
                    self.upperView.frame.size.height = getBottomEdgeY(inputView: self.tabsContainerMenu) + ButtonHeight - PADING + 10
                    self.info.frame.origin.y = getBottomEdgeY(inputView: self.upperView)
                    globalFeedHeight = self.upperView.frame.origin.y
                    self.feedObj.tableView.reloadData()
                    
                }else{
                    tempInfo += description
                    tempInfo += NSLocalizedString(" Less",  comment: "")
                    
                    self.descriptionLabel.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let range1 = (tempInfo as NSString).range(of: NSLocalizedString("Less",  comment: ""))
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTFontAttributeName as NSString) as String as String), value: boldFont, range: range1)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)
                        return mutableAttributedString
                    })
                    let range1 = (tempInfo as NSString).range(of:NSLocalizedString("Less",  comment: ""))//NSLocalizedString("Less",  comment: ""))
                    self.descriptionLabel.addLink(toTransitInformation: ["type" : "lessContentInfo"], with:range1)
                    self.descriptionLabel.sizeToFit()
                    self.descriptionLabel.frame.origin.y = getBottomEdgeY(inputView: self.locationLabel)
                    self.locationDescriptionBlock.frame.size.height = getBottomEdgeY(inputView: self.descriptionLabel) + 8
                    self.tabsContainerMenu.frame.origin.y = getBottomEdgeY(inputView: self.locationDescriptionBlock) + 3
                    for ob in self.upperView.subviews{
                        if ob.tag >= 1991 && ob.tag <= 1993{
                            ob.frame.origin.y = getBottomEdgeY(inputView:  self.tabsContainerMenu)
                        }
                    }
                    self.upperView.frame.size.height = getBottomEdgeY(inputView: self.tabsContainerMenu) + ButtonHeight - PADING + 10
                    self.info.frame.origin.y = getBottomEdgeY(inputView: self.upperView)
                    globalFeedHeight = self.upperView.frame.origin.y
                    self.feedObj.tableView.reloadData()
                    
                }
                
            }
            
        }
        
        self.descriptionLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
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
                        self.updatePage()
                        
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
    @objc func contactAction(_ sender:UIButton){
        let VC = CotactDetailViewController()
        profileField = self.contactInfo
        VC.isowner  = isowner
        VC.subjectId = "\(subjectId!)"
        self.navigationController?.pushViewController(VC, animated: false)
    }
    @objc func performReviewOrWishlistAction(_ sender:UIButton)
    {
        
        switch (sender.tag)
        {
        case 59:
            
            let presentedVC = AdvancePostFeedViewController()
            presentedVC.openfeedStyle = 4
            presentedVC.subjectId = "\(subjectId!)"
            presentedVC.subjectType = subjectType!
            presentedVC.modalPresentationStyle = .fullScreen
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:true, completion: nil)
            
            break
            
        case 60:
            
            globFilterValue = ""
            
            let presentedVC = FormGenerationViewController()
            if sender.titleLabel!.text != nil
            {
                presentedVC.formTitle = NSLocalizedString("\(sender.titleLabel!.text!)", comment: "")
            }
            else
            {
                presentedVC.formTitle = ""
            }
            presentedVC.contentType = "Review"
            presentedVC.param = [ : ]
            presentedVC.url = self.reviewUrl
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:true, completion: nil)
            
        case 61:
            
            let param: NSDictionary = [ : ]
            self.updateListing(param as NSDictionary, url: followUrl)
            break
            
        default:
            break
        }
    }
    
    // MARK: - Browse pages server calling
    //MARK:- TikTok API
    func API_getAAFList()
    {
        if Reachabable.isConnectedToNetwork()
        {
            var parameters = [String:String]()
            parameters = ["limit": "\(limit)","maxid": String(maxidTikTok),"feed_filter": "1","post_elements": "1","post_menus":"1","object_info":"1","getAttachedImageDimention":"0","filter_type":"video","onlyMyDeviceVideo":"1"]
            
            if subjectId != ""{
                parameters["subject_id"] = String(subjectId)
                subjectIdTikTok = "\(subjectId!)"
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
    
    func browseFeed(){
        self.info.removeFromSuperview()
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            self.API_getAAFList()
            
            for ob in view.subviews{
                if ob.tag == 2020{
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
                //activityIndicatorView.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight/4))
                    self.view.addSubview(activityIndicatorView)
                    activityIndicatorView.startAnimating()
                }
                
            }
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            
            
            parameters = ["maxid": String(maxid), "limit": "\(limit)", "subject_type": subjectType , "subject_id": String(subjectId), "post_menus":"1", "feed_filter": "1", "object_info":"1","getAttachedImageDimention":"0"]
            
            // Set userinteractionflag for request
            userInteractionOff = false
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds/", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    isshimmer = false
                    self.bottomMessageBlock.isHidden = false
                    self.feedObj.tableView.backgroundColor = aafBgColor
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
                            
                            // Check for Feeds
                            if response["data"] != nil{
                                if let activity_feed = response["data"] as? NSArray{
                                    // Extract FeedInfo from response by ActivityFeed class
                                    self.activityFeeds = ActivityFeed.loadActivityFeedInfo(activity_feed)
                                    // Update contentFeedArray
                                    self.updateFeedsArray(self.activityFeeds)
                                }
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

                            self.upperView.frame.size.height = getBottomEdgeY(inputView: self.tabsContainerMenu) + 50
                            globalFeedHeight = self.upperView.frame.origin.y
                            self.feedObj.tableView.frame.size.height = self.view.bounds.height - 40 - tabBarHeight
                            if contentFeedArray.count == 0 {
                                self.upperView.frame.size.height += 50
                                self.info  = createLabel(CGRect(x: 0,y: getBottomEdgeY(inputView: self.upperView) - 40  ,width: self.view.bounds.width, height: 50), text: NSLocalizedString("No updates at this moment . Check again any \nother time.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.info.backgroundColor = .white
                                self.info.font = UIFont(name: fontName, size: FONTSIZENormal)
                                self.info.tag = 1000
                                self.info.numberOfLines = 2
                                self.feedObj.tableView.addSubview(self.info)
                                self.info.isHidden = false
                                
                            }
                            else {
                                self.info.isHidden = true
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
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    
    // MARK: - Checkin wideget server calling
    
    func browseEmoji(contentItems: NSDictionary)
    {
        scrollViewEmoji.backgroundColor = .clear
        arrowView.backgroundColor = .clear
        for ob in scrollViewEmoji.subviews{
            ob.removeFromSuperview()
            arrowView.removeFromSuperview()
        }
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
                        emoji.addTarget(self, action: #selector(PageDetailViewController.feedMenuReactionLike(sender:)), for: .touchUpInside)
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
                for ob in self.upperView.subviews{
                    if ob.tag == 1 || ob.tag == 2 || ob.tag == 3{
                        ob.removeFromSuperview()
                    }
                }
                
                postPermission = NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary
                
                var postMenu = [String]()
                if postPermission.count > 0{
                    if let status = postPermission["status"] as? Bool{
                        if status{
                            postMenu.append(NSLocalizedString("\(statusIcon) Status", comment: ""))
                        }
                    }
                    if let photo = postPermission["photo"] as? Bool{
                        if photo{
                            postMenu.append(NSLocalizedString("\(cameraIcon) Photo", comment: ""))
                        }
                    }
                    if let checkIn = postPermission["checkin"] as? Bool{
                        if checkIn{
                            postMenu.append(locationIcon+NSLocalizedString(" Check In", comment: ""))
                        }
                    }
                }
                
                
                for ob in self.upperView.subviews{
                    if ob.tag >= 1991 && ob.tag <= 1993{
                        ob.removeFromSuperview()
                    }
                }
                
                var postFeed = UIButton()
                //Add Post Feed Option
                for i in 0 ..< postMenu.count {
                    let origin_x = PADING + (CGFloat(i) * ((view.bounds.width - (2 * PADING))/CGFloat(postMenu.count)))
                    postFeed = createButton(CGRect(x: origin_x, y: tabsContainerMenu.frame.origin.y + tabsContainerMenu.bounds.height + 7, width: view.bounds.width/CGFloat(postMenu.count), height: ButtonHeight - PADING), title: postMenu[i] , border: false ,bgColor: false, textColor: textColorMedium)
                    postFeed.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZENormal)
                    postFeed.backgroundColor = lightBgColor
                    postFeed.tag = i+1 + 1990
                    postFeed.addTarget(self, action: #selector(PageDetailViewController.openPostFeed(_:)), for: .touchUpInside)
                    self.upperView.addSubview(postFeed)
                }
                
                self.feedObj.tableView.tableHeaderView?.frame.size.height =  getBottomEdgeY(inputView: postFeed) + 5
                globalFeedHeight = getBottomEdgeY(inputView: postFeed) + 5
                self.upperView.frame.size.height = globalFeedHeight
                self.feedObj.tableView.reloadData()
                
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
        let nativationController = UINavigationController(rootViewController: presentedVC)
        nativationController.modalPresentationStyle = .fullScreen
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
            if feed.isPinned != nil {
                newDictionary["isPinned"] = feed.isPinned
            }
            contentFeedArray.append(newDictionary)
            self.feedObj.globalArrayFeed = contentFeedArray
            
            if logoutUser == false
            {
                globalFeedHeight = (self.upperView.bounds.height + self.upperView.frame.origin.y )
            }
            else
            {
                globalFeedHeight = (self.upperView.bounds.height + self.upperView.frame.origin.y )
            }
            self.feedObj.refreshLikeUnLike = true
            self.feedObj.tableView.reloadData()
            
            
        }
        
    }
    
    @objc func ScrollingactionPage(_ notification: Foundation.Notification)
    {
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        arrowView.isHidden = true
        
        if updateScrollFlag{
            
            // Check for PAGINATION
            if self.feedObj.tableView.contentSize.height > self.feedObj.tableView.bounds.size.height{
                if self.feedObj.tableView.contentOffset.y >= (self.feedObj.tableView.contentSize.height - self.feedObj.tableView.bounds.size.height){
                    if Reachabable.isConnectedToNetwork() {
                        if contentFeedArray.count > 0{
                            if maxid == 0{
                                showToast(message: NSLocalizedString("There are no more posts to show.",comment: ""), controller: self)
                                feedObj.tableView.tableFooterView?.isHidden = true
                                
                            }else{
                                // Request for Pagination
                                updateScrollFlag = false
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
        if (scrollOffset > 60){
            
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
            self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = textColorPrime
            self.marqueeHeader.text = self.contentTitle
            self.navigationController?.navigationBar.alpha = barAlpha
            self.marqueeHeader.alpha = barAlpha
            self.marqueeHeader.textColor = textColorPrime
            
            if (self.lastContentOffset > scrollOffset) {
                // move up
                self.bottomMessageBlock.fadeIn()
            }
            else if (self.lastContentOffset < scrollOffset){
                // move down
                self.bottomMessageBlock.fadeOut()
            }
            
            // update the new position acquired
            self.lastContentOffset = scrollOffset
        }else{
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            self.marqueeHeader.text = ""
            removeNavigationImage(controller: self)
            self.marqueeHeader.alpha = 1
            
            if (scrollOffset < 10.0){
                self.bottomMessageBlock.alpha = 1
            }
        }
        
        
        
    }
    
    // Show Gutter Menus
    @objc func showGutterMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        
        let confirmationTitle = ""
        let message = ""
        var url = ""
        var confirmationAlert = true
        
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                var params = Dictionary<String, AnyObject>()
               
                if dic["name"] as! String != "share"{
                    let titleString = dic["name"] as! String
                    if titleString.range(of: "delete") != nil{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                                
                            case "delete":
                                
                                displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this Page entry?",comment: "") , otherButton: NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                                    self.deleteListingEntry = true
                                    let params: NSDictionary = [:]
                                    self.updateListing(params as NSDictionary, url: dic["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                            
                            if confirmationAlert == true {
                                displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                        }))
                    }else{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.default, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                                
                            case "videoCreate" :
                                addvideo_click = 1
                                isCreateOrEdit = true
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Add New Video", comment: "")
                                presentedVC.contentType = "Advanced Video"
                                if sitevideoPluginEnabled_page == 1
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
                                
                                
                            case "report":
                                confirmationAlert = false
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "edit":
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                isCreateOrEdit = false
                                presentedVC.formTitle = NSLocalizedString("Edit Page", comment: "")
                                //presentedVC.listingTypeId = self.listingTypeId
                                presentedVC.contentType = "Page"
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
                                presentedVC.ShareDescription = self.descriptionString
                                presentedVC.imageString = self.coverImageUrl
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                            case "create_review":
                                
                                isCreateOrEdit = true
                                globFilterValue = ""
                                
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Write a Review", comment: "")
                                presentedVC.contentType = "Review"
                                presentedVC.param = [ : ]
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                            case "update_review":
                                
                                isCreateOrEdit = false
                                globFilterValue = ""
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Update Review", comment: "")
                                presentedVC.contentType = "Review"
                                presentedVC.param = [ : ]
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                            case "close", "open" , "follow" , "unfollow":
                                confirmationAlert = false
                                Reload = "Not Refresh"
                                self.updateListing(params as NSDictionary, url: dic["url"] as! String)
                                
                            case "messageowner":
                                
                                confirmationAlert = false
                                let presentedVC = MessageOwnerViewController();
                                presentedVC.url = dic["url"] as! String
                                
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "subscribe":
                                
                                Reload = "Not Refresh"
                                
                                var message = ""
                                let title = dic["label"] as! String
                                message = String(format: NSLocalizedString("You have successfully subscribed to %@!", comment: ""), title)
                                params["message"] = message as AnyObject?
                                self.updateListing(params as NSDictionary, url: dic["url"] as! String)
                                
                            case "unsubscribe":
                                
                                Reload = "Not Refresh"
                                
                                var message = ""
                                let title = dic["label"] as! String
                                message = String(format: NSLocalizedString("You have successfully subscribed to %@!", comment: ""), title)
                                params["message"] = message as AnyObject?
                                
                                self.updateListing(params as NSDictionary, url: dic["url"] as! String)
                                
                            case "package_payment":
                                
                                confirmationAlert = false
                                let presentedVC = ExternalWebViewController()
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let navigationController = UINavigationController(rootViewController: presentedVC)
                                self.present(navigationController, animated: true, completion: nil)
                                
                            case "upgrade_package":
                                let presentedVC = PackageViewController()
                                presentedVC.contentType = "Page"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.urlParams = dic["urlParams"] as! NSDictionary
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
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width/2 , y: view.bounds.height/2, width: 0, height: 0)
            alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    
    @objc func messageToOwner() {
        let presentedVC = MessageOwnerViewController();
        presentedVC.url = Messag_Url
        
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    
    func updateListing(_ params: NSDictionary, url: String){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
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
            // Send Server Request to Explore Page Contents with Page_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        // On Success Update Listing Detail
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if self.deleteListingEntry == true{
                            pageUpdate = true
                            feedUpdate = true
                            _ = self.navigationController?.popViewController(animated: false)
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
    
    func showtabMenu(){
        for ob in tabsContainerMenu.subviews{
            if ob.tag == 101{
                ob.removeFromSuperview()
            }
        }
        
        var tempLabelCount = 0
        for tempArray in tabMenuPage {
            let tempTabMenuPage = tempArray as! NSDictionary
            if tempTabMenuPage["totalItemCount"] as? Int > 0{
                tempLabelCount += 1
            }
            if tempTabMenuPage["name"] as! String == "update"{
                tempLabelCount += 1
            }
            
            if tempTabMenuPage["name"] as! String == "info"{
                tempLabelCount += 1
            }
        }
        
        var origin_x:CGFloat = 0
        
        for menu in tabMenuPage{
            if let menuItem = menu as? NSDictionary{
                var button_title = menuItem["label"] as! String
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                let width = findWidthByText(button_title) + 10
                let menu = createNavigationButton(CGRect(x: origin_x,y: 0 ,width: width , height: tabsContainerMenu.bounds.height ) , title: button_title, border: true, selected: false)
                
                if menuItem["name"] as! String == "update"{
                    menu.setSelectedButton()
                }
                else{
                    menu.setUnSelectedButton()
                }
                menu.backgroundColor = TabMenubgColor
                
                menu.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                menu.tag = 101
                menu.addTarget(self, action: #selector(PageDetailViewController.tabMenuAction(_:)), for: .touchUpInside)
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
    
    func showTabMenu1(){
        var origin_x1:CGFloat = 0
        var tempLabelCount = 0
        for tempArray in tabMenuPage {
            let tempTabMenuPageDic = tempArray as! NSDictionary
            
            if tempTabMenuPageDic["totalItemCount"] as? Int > 0{
                tempLabelCount += 1
            }
            if tempTabMenuPageDic["name"] as! String == "update"{
                tempLabelCount += 1
            }
            
            if tempTabMenuPageDic["name"] as! String == "info"{
                tempLabelCount += 1
            }
        }
        
        
        for menu1 in tabMenuPage{
            if let menuItem = menu1 as? NSDictionary{
                var button_title = menuItem["label"] as! String
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                let width = findWidthByText(button_title) + 10
                let menu1 = createNavigationButton(CGRect(x: origin_x1,y: 0 ,width: width , height: tabsContainerMenu.bounds.height ) , title: button_title, border: true, selected: false)
                if menuItem["name"] as! String == "update"{
                    menu1.setSelectedButton()
                }
                else{
                    menu1.setUnSelectedButton()
                }
                menu1.backgroundColor  =  TabMenubgColor
                
                menu1.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                menu1.tag = 102
                menu1.addTarget(self, action: #selector(PageDetailViewController.tabMenuAction(_:)), for: .touchUpInside)
                staticTabMenu.addSubview(menu1)
                origin_x1 += width
                
                if button_title == "Updates"{
                    menu1.setTitleColor(textColorDark, for: UIControl.State())
                }
                else{
                    menu1.setTitleColor(textColorMedium, for: UIControl.State())
                }
            }
        }
        staticTabMenu.contentSize = CGSize(width: origin_x1, height: tabsContainerMenu.bounds.height)
        
    }
    
    @objc func tabMenuAction(_ sender:UIButton){
        for menu in tabMenuPage{
            if let menuItem = menu as? NSDictionary{
                var button_title = menuItem["label"] as! String
                
                // if button_title != "Fourms Posts" {
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                print("title---\((sender.titleLabel?.text)!)     \(button_title)")
                if (sender.titleLabel?.text)! == button_title{
                    if menuItem["name"] as! String == "information"{
                        if self.descriptionString != nil{
                            let presentedVC = MLTInfoViewController()
                            presentedVC.infoUrl = menuItem["url"] as! String
                            presentedVC.containText = false
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                    }
                    if menuItem["name"] as! String == "overview"{
                        
                        if self.descriptionString != nil{
                            let presentedVC = OverViewViewController()
                            presentedVC.label1 = self.webviewText
                            navigationController?.pushViewController(presentedVC, animated: false)
                        }
                    }
                    
                    if menuItem["name"] as! String == "video"{
                        
                        if sitevideoPluginEnabled_page == 1
                        {
                            let presentedVC = AdvanceVideoViewController()
                            presentedVC.user_id = "\(subjectId!)"
                            presentedVC.fromTab = true
                            presentedVC.showOnlyMyContent = false
                            presentedVC.countListTitle = button_title
                            presentedVC.other_module = true
                            presentedVC.videoTypeCheck = "Pages"
                            presentedVC.url = menuItem["url"] as! String//"advancedvideos/index/\(self.subjectId)"
                            presentedVC.subject_type = menuItem["subject_type"] as! String
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                        else
                        {
                            let presentedVC = VideoBrowseViewController()
                            presentedVC.showOnlyMyContent = true
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.videoTypeCheck = "Pages"
                            presentedVC.listingId = "\(subjectId!)"
                            presentedVC.fromTab = true
                            presentedVC.countListTitle =  button_title
                            
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                        
                    }
                    
                    if menuItem["name"] as! String == "advevents"{
                        let presentedVC = AdvancedEventViewController()
                        presentedVC.showOnlyMyContent = true
                        presentedVC.sitegroupCheck = "sitepage"
                        if menuItem["totalItemCount"] as? Int != nil {
                            presentedVC.eventCount = menuItem["totalItemCount"] as! Int
                        }
                        if let dic1 = menuItem["urlParams"] as? NSDictionary{
                            presentedVC.user_id = "\(dic1["subject_id"]!)"
                        }
                        presentedVC.fromTab = true
                        
                        navigationController?.pushViewController(presentedVC, animated: false)
                    }
                    
                    if menuItem["name"] as! String == "reviews"
                    {
                        let presentedVC = PageReviewViewController()
                        presentedVC.mytitle = contentTitle //"\((self.title)!)"
                        presentedVC.subjectId = "\(subjectId!)"
                        presentedVC.contentType = "Pages"
                        if let totalItem = menuItem["totalItemCount"] as? Int
                        {
                            if totalItem > 0
                            {
                                presentedVC.currentReviewcount = totalItem
                            }
                        }
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                    }
                    
                    if menuItem["name"] as! String == "photos"{
                        let presentedVC = AlbumViewController()
                        presentedVC.contentType = "sitepage_photo"
                        presentedVC.countListTitle = button_title
                        // presentedVC.listingId = listingId
                        presentedVC.showOnlyMyContent = true
                        let tempUrl = menuItem["url"] as! String
                        presentedVC.path = tempUrl
                        presentedVC.user_id = subjectId
                        presentedVC.fromTab = true
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                        
                    }
                    
                    
                }
            }
            
        }
    }
    
    func updatePage(){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            
            // Send Server Request to Explore Page Contents with Page_ID
            post([ "gutter_menu": "1"], url: "sitepage/view/" + String(subjectId), method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    if msg{
                        // On Success Update Page Detail
                        if let listing = succeeded["body"] as? NSDictionary {
                            if let coverImage = listing["cover_image"] as? String {
                                self.coverImage.kf.indicatorType = .activity
                                (self.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                self.coverImage.kf.setImage(with: URL(string: coverImage), placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                            }
                            
                            if let pageProfileImage = listing["image_profile"] as? String {
                                self.pageProfileImage.kf.indicatorType = .activity
                                (self.pageProfileImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                self.pageProfileImage.kf.setImage(with: URL(string: pageProfileImage), placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                })
                            }
                            
                            if let title = listing["title"] as? String {
                                self.pageTitle = title
                            }
                            
                            if let category = listing["category_title"] as? String {
                                var categ = ""
                                categ = category
                                if let subCategory = listing["subcategory_title"] as? String {
                                    categ = category + ", " + subCategory
                                    if let subsubCategory = listing["subsubcategory_title"] as? String {
                                        categ = category + ", " + subCategory + ", " + subsubCategory
                                    }
                                }
                                self.categoryLabel.text = categ
                            }
                            if let location = listing["location"] as? String, location != "" {
                                let locationIcon = "\u{f041}"
                                let nonAttrFont = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: textColorDark]
                                let nonAttString1 = NSAttributedString(string:NSLocalizedString("Details:\n\n", comment: "") , attributes: nonAttrFont )
                                let locationAttr = [ NSAttributedString.Key.foregroundColor: textColorDark, NSAttributedString.Key.font: UIFont(name: "FontAwesome", size:12.0)]
                                let attrString = NSAttributedString(string: locationIcon, attributes: locationAttr)
                                let nonAttrString2 = NSAttributedString(string:NSLocalizedString("  \(location)", comment: "") , attributes: nonAttrFont )
                                let finalStr = NSMutableAttributedString()
                                finalStr.append(nonAttString1)
                                finalStr.append(attrString)
                                finalStr.append(nonAttrString2)
                                self.locationLabel.attributedText = finalStr
                                self.locationLabel.isHidden = false
                                if self.locationLabel.intrinsicContentSize.width > self.view.frame.size.width - 80 {
                                    self.locationLabel.frame.size.width = self.view.frame.size.width - 80
                                }
                                else {
                                    self.locationLabel.frame.size.width = self.locationLabel.intrinsicContentSize.width
                                }
                                self.locationLabel.frame.size.height = 60
                                self.locationNavigationButton.frame.origin.x = getRightEdgeX(inputView: self.locationLabel) + 5
                                self.locationNavigationButton.frame.origin.y = getBottomEdgeY(inputView: self.locationLabel) -  20
                                self.locationNavigationButton.isHidden = false
                                
                            }
                            else {
                                self.locationLabel.isHidden = true
                                self.locationNavigationButton.isHidden = true
                                
                            }
                            if let description = listing["body"] as? String {
                                self.descriptionString = description
                                if description.count < self.characterCount {
                                    self.descriptionLabel.setText(description, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                        
                                        // TODO: Clean this up...
                                        return mutableAttributedString
                                    })
                                    self.descriptionLabel.sizeToFit()
                                    self.descriptionLabel.frame.size.width = self.view.bounds.width - 14
                                    self.locationDescriptionBlock.frame.size.height = getBottomEdgeY(inputView: self.descriptionLabel) + 10
                                    self.upperView.frame.size.height = getBottomEdgeY(inputView: self.descriptionLabel) + 10
                                    self.tabsContainerMenu.frame.origin.y = getBottomEdgeY(inputView: self.locationDescriptionBlock) + 5
                                    self.upperView.frame.size.height = getBottomEdgeY(inputView: self.tabsContainerMenu) + 5
                                    if postPermission.count > 0 {
                                        self.upperView.frame.size.height += (ButtonHeight - PADING)
                                    }
                                    globalFeedHeight = self.upperView.frame.origin.y
                                    self.feedObj.tableView.reloadData()
                                    
                                }
                                else {
                                    self.pageDescription = description
                                    self.moreOrLess()
                                }
                            }
                        }
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
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
    
    @objc func goBack(){
        if self.checkUpdate == true{
            pageUpdate = true
        }
        sitevideoPluginEnabled_page = 0
        _ = self.navigationController?.popViewController(animated: false)
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
            contentFeedArray.removeAll(keepingCapacity: false)
            exploreContent()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    
    @objc func shareItem(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title:  String(format: NSLocalizedString("Share on %@", comment: ""),app_title), style: .default) { action -> Void in
            
            let presentedVC = AdvanceShareViewController()
            presentedVC.param = self.shareParam as! [AnyHashable : Any] as NSDictionary
            presentedVC.url = self.shareUrl
            presentedVC.Sharetitle = self.shareTitle
            if (self.descriptionString != nil) {
                presentedVC.ShareDescription = self.descriptionString
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
    
    @objc func onImageViewTap()
    {
        if self.coverImageUrl != nil && self.coverImageUrl != "" {
            let presentedVC = SinglePhotoLightBoxController()
            presentedVC.imageUrl = self.coverImageUrl
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            present(nativationController, animated:false, completion: nil)
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
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
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer() {
        stop()
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
extension PageDetailViewController: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        let type = components["type"] as! String
        switch(type){
        case "moreContentInfo":
            selectedMoreLess = true
            self.moreOrLess()
            
            
        case "lessContentInfo":
            selectedMoreLess = false
            self.moreOrLess()
            
        default:
            print("error")
            
        }
    }
}

extension PageDetailViewController {
    func shimmerTabs() {
        let label1 = UIView()
        let label2 = UIView()
        let label3 = UIView()
        shimmerTabView.frame = CGRect(x: 0, y: getBottomEdgeY(inputView: locationDescriptionBlock), width: self.view.frame.size.width, height: 50)
        let labelWidth = (shimmerTabView.frame.size.width - 32)/3
        label1.frame = CGRect(x: 8, y: 22.5, width: labelWidth, height: 5)
        label2.frame = CGRect(x: getRightEdgeX(inputView: label1) + 8, y: 22.5, width: labelWidth, height: 5)
        label3.frame = CGRect(x: getRightEdgeX(inputView: label2) + 8, y: 22.5, width: labelWidth, height: 5)
        shimmerTabView.addSubview(label1)
        shimmerTabView.addSubview(label2)
        shimmerTabView.addSubview(label3)
        label1.backgroundColor = textColorshimmer
        label2.backgroundColor = textColorshimmer
        label3.backgroundColor = textColorshimmer
        upperView.addSubview(shimmerTabView)
        
        upperView.addSubview(shimmerTabView)
        globalFeedHeight = self.upperView.frame.origin.y
        self.feedObj.tableView.reloadData()
        shimmerTabView.start()
    }
    func shimmerView() {
        shimmerViews.frame = self.view.frame
        self.upperView.addSubview(self.shimmerViews)
        let coverImage = UIView()
        let pageProfile = UIView()
        let label1 = UIView()
        let label2 = UIView()
        let label3 = UIView()
        let locationShimmer = UIView()
        let descriptionShimmer = UIView()
        
        coverImage.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 0.4 * (self.view.frame.size.height))
        shimmerViews.addSubview(coverImage)
        coverImage.backgroundColor = textColorshimmer
        
        pageProfile.frame = CGRect(x: 8, y: getBottomEdgeY(inputView: coverImage) + 5, width: self.view.frame.size.width * 0.2, height: self.view.frame.size.width * 0.2)
        pageProfile.layer.cornerRadius = (self.view.frame.size.width * 0.2)/2
        pageProfile.backgroundColor = textColorshimmer
        shimmerViews.addSubview(pageProfile)
        
        label1.frame = CGRect(x: getRightEdgeX(inputView: pageProfile) + 8, y: pageProfile.frame.origin.y + 8, width: self.view.frame.size.width - (self.view.frame.size.width * 0.2) - 40 , height: (self.view.frame.size.width * 0.2) * 0.2)
        shimmerViews.addSubview(label1)
        label1.backgroundColor = textColorshimmer
        
        label2.frame = CGRect(x: getRightEdgeX(inputView: pageProfile) + 8, y: getBottomEdgeY(inputView: label1) + 12, width: self.view.frame.size.width - (self.view.frame.size.width * 0.2) - 90 , height: (self.view.frame.size.width * 0.2) * 0.10)
        shimmerViews.addSubview(label2)
        label2.backgroundColor = textColorshimmer
        
        label3.frame = CGRect(x: getRightEdgeX(inputView: pageProfile) + 8, y: getBottomEdgeY(inputView: label2) + 8, width: self.view.frame.size.width - (self.view.frame.size.width * 0.2) - 110 , height: (self.view.frame.size.width * 0.2) * 0.10)
        shimmerViews.addSubview(label3)
        label3.backgroundColor = textColorshimmer
        
        let iconViewWidth = self.view.frame.size.width/4
        var origin_x : CGFloat = 0
        for _ in 1...4 {
            let iconView = UIView()
            let icon = UIView()
            let iconText = UIView()
            iconView.frame = CGRect(x: origin_x, y: getBottomEdgeY(inputView: pageProfile) + 18, width: iconViewWidth, height: self.view.frame.size.width * 0.2)
            shimmerViews.addSubview(iconView)
            
            icon.frame = CGRect(x: (iconViewWidth - self.view.frame.size.width * 0.1)/2 , y: 5, width: self.view.frame.size.width * 0.1, height: self.view.frame.size.width * 0.1)
            icon.layer.cornerRadius = (self.view.frame.size.width * 0.1)/2
            icon.backgroundColor = textColorshimmer
            iconView.addSubview(icon)
            
            iconText.frame = CGRect(x: 8, y: getBottomEdgeY(inputView: icon) + 5, width: iconViewWidth - 16, height: 5)
            iconText.backgroundColor = textColorshimmer
            iconView.addSubview(iconText)
            
            origin_x = origin_x + iconViewWidth
        }
        
        locationShimmer.frame = CGRect(x: 8, y: getBottomEdgeY(inputView: pageProfile) + self.view.frame.size.width * 0.2 + 20, width: (self.view.frame.size.width * 0.5), height: 5)
        locationShimmer.backgroundColor = textColorshimmer
        shimmerViews.addSubview(locationShimmer)
        
        descriptionShimmer.frame = CGRect(x: 8, y: getBottomEdgeY(inputView: locationShimmer) + 8, width: (self.view.frame.size.width * 0.5) - 20, height: 5)
        descriptionShimmer.backgroundColor = textColorshimmer
        shimmerViews.addSubview(descriptionShimmer)
        
        shimmerViews.frame.size.height = getBottomEdgeY(inputView: descriptionShimmer) + 10
        globalFeedHeight = self.upperView.frame.origin.y
        self.feedObj.tableView.reloadData()
        shimmerViews.start()
        
    }
}




