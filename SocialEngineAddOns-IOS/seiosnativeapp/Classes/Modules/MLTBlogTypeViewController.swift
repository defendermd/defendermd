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
//  MLTBlogTypeViewController.swift
//  seiosnativeapp
//

import UIKit
import StoreKit
import WebKit

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

var listingDetailUpdate: Bool!
var contentListingType = ""

class MLTBlogTypeViewController: UIViewController,  UIScrollViewDelegate, TTTAttributedLabelDelegate, UITableViewDelegate{
    var marqueeHeader : MarqueeLabel!
    var mytitle:String = ""
    var listingName:String!
    var RedirectText : String!
    var listingTitle:String!
    var like_comment = UIView()
    var lastContentOffset: CGFloat = 0
    var listingId:String!
    var listingTypeId :  Int!
    var subjectId:Int!                         // For use Activity Feed updates in Other Modules
    var subjectType:String!                    // For use Activity Feed updates in Other Modules
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
    
    var contentUrl : String!
    
    var shareDescription : String!
    var coverImageUrl : String!
    
    var mainSubView:UIView!
    var coverImage:UIImageView!
    var contentName:UILabel!
    var extraMenuLeft:UIButton!
    var extraMenuRight:UIButton!
    var tabsContainerMenu:UIScrollView!
    var headerHeight:CGFloat = 0
    var categoryMember : TTTAttributedLabel!
    var detailWebView = WKWebView()
    var lbl_smallDescription : UILabel!
    var descriptionMore = UIView()
    var btn_descriptionMoreButton : UIButton!
    var maxHeight : CGFloat!
    var contentTitle : String!
    var shareTitle:String!
    var smallDesctiptionString : String!
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
    var gutterMenu:NSArray = []
    var filterGutterMenu: NSArray = []
    var join_rsvp:Int!
    var joinFlag = false
    var categoryView : UIView!
    var topView: UIView!
    //var ownerName : UILabel!
    var imgUser: UIImageView!
    var applyButton : UIButton!
    
    var shareUrl : String!
    var applyUrl : String!
    var showApplyButton : Bool! = false
    var shareParam : NSDictionary!
    var info : UILabel!
    var canInviteEventOrGroup = false
    var toastView : UIView!
    var isJobApplied = false
    
    var UserId:Int!
 //   var imageCache = [String:UIImage]()
    var titleshow :Bool  = false
    var titleHeight:CGFloat = 0
    var temptitleInfo : String = ""
    var action_id:Int!
    var actionIdArray = [Int]()
    var noCommentMenu:Bool = false
    var descRedirectionButton : UIButton!
    var mainView = UIView()
    var deleteListingEntry:Bool!
    var currencySymbol = ""
    var rightBarButtonItem : UIBarButtonItem!
    var feedObj = FeedTableViewController()
    let subscriptionNoticeLinkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.gray,
        // NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    let subscriptionNoticeActiveLinkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.80),
        //NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    
    var mltProfileTabMenu: NSArray = []
    var leftBarButtonItem : UIBarButtonItem!
    var padingAfterWebView: CGFloat = 10
    
    // Initialize Class Object
    override func viewDidLoad() {
        super.viewDidLoad()
        Messag_Owner = false
        
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.isHidden = false
        listingUpdate = false
        listingDetailUpdate = true
        deleteListingEntry = false
        contentFeedArray.removeAll(keepingCapacity: false)
        tableViewFrameType = "MLTBlogTypeViewController"
        
        removeNavigationImage(controller: self)
        self.navigationItem.rightBarButtonItem = nil
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MLTBlogTypeViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        // Initial table to show Activity Feeds
        feedObj.willMove(toParent: self)
        self.view.addSubview(feedObj.view)
        self.addChild(feedObj)
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            mainSubView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 370), borderColor: borderColorLight, shadow: false)
            mainSubView.layer.borderWidth = 0.0
            coverImage =   CoverImageViewWithGradient(frame:CGRect(x: 0, y: 0, width: mainSubView.bounds.width, height: 370))
        }else{
            mainSubView = createView(CGRect(x: 0,y: 0, width: view.bounds.width, height: 270), borderColor: borderColorLight, shadow: false)
            mainSubView.layer.borderWidth = 0.0
            
            coverImage =   CoverImageViewWithGradient(frame:CGRect(x: 0, y: 0, width: mainSubView.bounds.width, height: 270))
            
        }
        mainSubView.backgroundColor = UIColor.clear
        feedObj.tableView.addSubview(mainSubView)
        
        coverImage.contentMode = UIView.ContentMode.scaleAspectFill
        coverImage.layer.masksToBounds = true
        coverImage.backgroundColor = placeholderColor
        coverImage.isUserInteractionEnabled = true
        coverImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MLTBlogTypeViewController.onImageViewTap(_:))))
        mainSubView.addSubview(coverImage)
        
        contentview = createView(CGRect(x: 0, y: coverImage.bounds.height-45, width: view.bounds.width, height: 115), borderColor: UIColor.clear, shadow: false)
        contentview.backgroundColor = UIColor.clear
        coverImage.addSubview(contentview)
        
        
        contentName = createLabel(CGRect(x: contentPADING, y: 0, width: mainSubView.bounds.width - (2 * contentPADING), height: 40), text: "", alignment: .left, textColor: textColorLight)
        contentName.font = UIFont(name: fontBold, size: 30)
        contentName.numberOfLines = 3
        contentName.layer.shadowColor = shadowColor.cgColor
        contentName.layer.shadowOpacity = shadowOpacity
        contentName.layer.shadowRadius = shadowRadius
        contentName.layer.shadowOffset = shadowOffset
        contentview.addSubview(contentName)
        
        topView = createView(CGRect(x: 0, y: coverImage.bounds.height, width: view.bounds.width, height: 70), borderColor: UIColor.clear, shadow: false)
        topView.backgroundColor = lightBgColor
        
        mainSubView.addSubview(topView)
        
        ownerName = createLabel(CGRect(x: 65, y: 20, width: view.bounds.width, height: 30), text: "", alignment: .left, textColor: textColorDark)
        ownerName.font = UIFont(name: fontName, size: FONTSIZEMedium)
        topView.addSubview(ownerName)
        
        imgUser = createImageView(CGRect(x: 10, y: 10, width: 50, height: 50), border: true)
        
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.clear.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.clipsToBounds = true
        imgUser.image = UIImage(named: "user_profile_image.png")
        topView.addSubview(imgUser)
        
        applyButton = createButton(CGRect(x: 20, y: 0, width: view.bounds.width-40, height: 0), title: "Apply Now", border: false, bgColor: true, textColor: textColorPrime)
        applyButton.layer.cornerRadius = 5.0
        applyButton.isHidden = true
        mainSubView.addSubview(applyButton)
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(MLTBlogTypeViewController.openProfile))
        topView.addGestureRecognizer(tap)
        
        lbl_smallDescription = createLabel(CGRect(x:PADING,y:0,width: view.bounds.width-(PADING*2),height:0), text: "", alignment: NSTextAlignment.left, textColor: textColorDark)
        lbl_smallDescription.isHidden = true
        mainSubView.addSubview(lbl_smallDescription)
        
        descriptionMore = createView(CGRect(x:0,y:lbl_smallDescription.frame.origin.y+lbl_smallDescription.frame.size.height,width:self.view.bounds.width,height:0), borderColor: UIColor.clear, shadow: false)
        descriptionMore.isHidden = true
        mainSubView.addSubview(descriptionMore)
        
        btn_descriptionMoreButton = createButton(CGRect(x:self.view.bounds.width-90,y:0,width:80,height:0), title: "More", border: false, bgColor: false, textColor: navColor)
        btn_descriptionMoreButton.isHidden = true
        btn_descriptionMoreButton.titleLabel?.font = UIFont(name: fontName, size: 15)
        descriptionMore.addSubview(btn_descriptionMoreButton)
        
        
        // WebView for listing Detail
        detailWebView.frame = CGRect( x: PADING, y: 0 ,width: view.bounds.width - 10 , height: 0)
        detailWebView.isUserInteractionEnabled = true
        detailWebView.backgroundColor = UIColor.white
       // detailWebView.isHidden = true
        detailWebView.navigationDelegate = self
        detailWebView.scrollView.isScrollEnabled = false
        //detailWebView.sizeToFit()
        self.detailWebView.contentMode = .scaleAspectFit
       // detailWebView.scalesPageToFit = true
        mainSubView.addSubview(detailWebView)
 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableViewFrameType = "MLTBlogTypeViewController"
        NotificationCenter.default.addObserver(self, selector: #selector(MLTBlogTypeViewController.ScrollingactionMLTBlogType(_:)), name: NSNotification.Name(rawValue: "ScrollingactionMLTBlogType"), object: nil)
        removeNavigationImage(controller: self)
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
           // marqueeHeader.text = mytitle
            navigationBar.addSubview(marqueeHeader)
        }
        
        subject_unique_id = "\(listingId!)"
        subject_unique_type = "sitereview_listing"
        
        let allviews = view.subviews
        for obj in allviews
        {
            if obj .isKind(of: Like_CommentView.self)
            {
                //obj.removeFromSuperview()
            }
        }
        
        if listingDetailUpdate == true{
            
            listingTypeId_global = listingTypeId
            
            // Set Default & request to hard Refresh
            listingDetailUpdate = false
            feedUpdate = false
            maxid = 0
            showSpinner = true
            feed_filter = 1
            explorelisting()
        }
        else
        {
            globalFeedHeight = self.headerHeight
            if !fromExternalWebView{
                self.feedObj.refreshLikeUnLike = true
                feedObj.tableView.reloadData()
            }else{
                fromExternalWebView = false
            }
        }
        
        self.view.addSubview(self.like_comment)
    }
    
    // Explore listing Detail On View Appear
    override func viewDidAppear(_ animated: Bool) {
        if listingDetailUpdate == true{
            listingDetailUpdate = false
            explorelisting()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.view.isUserInteractionEnabled = true
        tableViewFrameType = ""
        self.marqueeHeader.text = ""
        removeNavigationImage(controller: self)
        setNavigationImage(controller: self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Server Connection For listing Updation
    

    
    // Explore listing Detail
    func explorelisting(){
        
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
            self.navigationController?.view.isUserInteractionEnabled = false
            
            // Send Server Request to Explore listing Contents with listing_id
            post(["listingtype_id": String(listingTypeId), "gutter_menu": "1"], url: "listing/view/" + String(listingId), method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    //activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Blog Detail
                        
                        if let listing = succeeded["body"] as? NSDictionary
                        {
                            
                            self.contentTitle = (listing["title"] as? String)!
                            self.shareTitle = listing["title"] as? String
                            
                            if let owner_id = listing["owner_id"] as? Int{
                                self.user_id = owner_id
                                Messag_OwnerId = owner_id
                            }
                            
                            if let applyjob = listing["isApplyJob"] as? Int
                            {
                                self.showApplyButton = true
                                if applyjob == 1
                                {
                                    self.isJobApplied = true
                                }
                            }
                            
                           // self.marqueeHeader.text = listing["title"] as? String
                            self.mytitle = (listing["title"] as? String)!
                            
                            if let menu = listing["gutterMenu"] as? NSArray
                            {
                                self.gutterMenu  = menu
                                 var isCancel = false
                                for tempMenu in self.gutterMenu
                                {
                                    if let tempDic = tempMenu as? NSDictionary
                                    {
                                        if tempDic["name"] as! String == "messageowner" {
                                            Messag_Owner = true
                                            if let url = tempDic["url"] as? String {
                                                Messag_Url = url
                                            }
                                        }
                                        
                                        if tempDic["name"] as! String == "share"
                                        {
                                            
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
                                
                                if logoutUser == false{
                                    
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")!.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    shareButton.addTarget(self, action: #selector(MLTBlogTypeViewController.shareItem), for: .touchUpInside)
                                    rightNavView.addSubview(shareButton)
                                    
                                    let optionButton = createButton(CGRect(x: 22,y: 0,width: 45,height: 45), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")!.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    optionButton.addTarget(self, action: #selector(MLTBlogTypeViewController.showGutterMenu), for: .touchUpInside)
                                 //   rightNavView.addSubview(optionButton)
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
                            
                            likeCommentContent_id = "\(self.listingId!)"
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
                            
                            let response = listing
                            
                            if response.count > 0{
                                
                                // set Blog Title
                                self.shareTitle = response["title"] as? String
                                self.contentName.font = UIFont(name: fontName, size: 30)
                                self.contentName.text = response["title"] as? String
                                
                                if let _ = response["title"] as? String{
                                    self.contentTitle = (response["title"] as? String)!
                                    if self.contentTitle.length > 22{
                                        self.contentview.frame.origin.y = self.coverImage.bounds.height-75
                                    }
                                    if self.contentTitle.length > 45{
                                        self.contentview.frame.origin.y = self.coverImage.bounds.height-110
                                    }
                                }
                                
                                self.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
                                self.contentName.sizeToFit()
                                
                                self.ownerName.text = response["owner_title"] as? String
                                if let url = URL(string: response["owner_image_normal"] as! String){
                                    self.imgUser.kf.indicatorType = .activity
                                    (self.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    self.imgUser.kf.setImage(with: url as URL?, placeholder: UIImage(named: "defaultcat.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        if let img = image
                                        {
                                            self.imgUser.image = imageWithImage(img, scaletoWidth: self.coverImage.bounds.width)
                                        }
                                    })
                                }
                                
                                if let photoId = response["photo_id"] as? Int
                                {
                                    if let coverimageurl = response["image"] as? String
                                    {
                                        self.coverImageUrl = coverimageurl
                                        if let url = URL(string: coverimageurl)
                                        {
                                            self.coverImage.kf.indicatorType = .activity
                                            (self.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                            self.coverImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                
                                            })
                                        }
                                    }
                                    else
                                    {
                                        self.coverImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: self.coverImage.bounds.width)
                                    }
                                    
                                }
                                if self.showApplyButton
                                {
                                    self.applyButton.frame.origin.y = getBottomEdgeY(inputView: self.topView)+15
                                    self.applyButton.frame.size.height = 40
                                    self.applyButton.isHidden = false
                                    if self.isJobApplied == false
                                    {
                                        self.applyButton.addTarget(self, action: #selector(MLTBlogTypeViewController.applyJob), for: .touchUpInside)
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
                                self.contentUrl =  response["content_url"] as! String
                                self.detailWebView.frame.origin.y = getBottomEdgeY(inputView: self.applyButton)+15
                                var topicDescription = (response["body"] as! String)
                                if response["overview"] != nil
                                {
                                    self.lbl_smallDescription.frame.origin.y = getBottomEdgeY(inputView: self.applyButton)+15
                                    if topicDescription != "" {
                                    self.lbl_smallDescription.frame.size.height = 80
                                    }
                                    else{
                                      self.lbl_smallDescription.frame.size.height = 0
                                    }
                                    //let htmlData = topicDescription.html2String
                                    if let htmlData = topicDescription.html2String as? String{
                                        do {
                                            //let attributedText = try NSAttributedString(data: htmlData, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                                            
                                            let attributedText = NSAttributedString(string: htmlData)
                                            //let attributedText = try NSAttributedString(data: htmlData, options: [:], documentAttributes: nil)
                                            self.lbl_smallDescription.attributedText = attributedText

                                            let linecount = findHeightByText(attributedText.string)
                                            if linecount > 4
                                            {
                                                self.smallDesctiptionString = attributedText.string
                                                self.descriptionMore.frame.size.height = 30
                                                self.descriptionMore.frame.origin.y = getBottomEdgeY(inputView: self.lbl_smallDescription)
                                                self.descriptionMore.isHidden = false
                                                self.btn_descriptionMoreButton.frame.size.height = 30
                                                self.btn_descriptionMoreButton.isHidden = false
                                                self.btn_descriptionMoreButton.addTarget(self, action: #selector(MLTBlogTypeViewController.showSmallDescription), for: .touchUpInside)
                                                self.detailWebView.frame.origin.y = getBottomEdgeY(inputView: self.descriptionMore)+15
                                            }
                                            else
                                            {
                                                self.detailWebView.frame.origin.y = getBottomEdgeY(inputView: self.lbl_smallDescription)+15
                                            }
                                            
                                        } catch let e as NSError {
                                            print("Couldn't translate \(topicDescription): \(e.localizedDescription) ")
                                        }
                                    }
                                    
                                    self.lbl_smallDescription.isHidden = false
                                    self.lbl_smallDescription.backgroundColor = UIColor.white
                                    self.lbl_smallDescription.font = UIFont(name: fontName, size: FONTSIZENormal)
                                    self.lbl_smallDescription.lineBreakMode = NSLineBreakMode.byWordWrapping
                                    //self.smallDescription.sizeToFit()
                                    self.lbl_smallDescription.numberOfLines = 4
                                    
                                    
                                    topicDescription = response["overview"] as! String
                                    self.RedirectText = (response["body"] as! String)
                                }
                                else
                                {
                                    topicDescription = (response["body"] as! String)
                                    self.RedirectText = (response["body"] as! String)
                                }
                                
                              //  self.detailWebView.isHidden = true
                                let url = self.contentUrl! + "?disableHeaderAndFooter=1&token=" + oauth_token
                                self.detailWebView.load(URLRequest(url: URL(string: url)!))
                                if topicDescription == ""
                                {
                                    self.detailWebView.frame.size.height = 0
                                }
                                self.detailWebView.frame.size.width = self.view.bounds.width - 2 * PADING
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
    
    @objc func showSmallDescription()
    {
        let presentedVC = DescriptionViewController()
        presentedVC.mytitle = ""
        presentedVC.subjectId = ""
        presentedVC.url = ""
        presentedVC.headertitle = "Description"
        presentedVC.smallDescription = self.smallDesctiptionString
        navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    // Handle Scroll For Pagination
    @objc func ScrollingactionMLTBlogType(_ notification: Foundation.Notification)
    {
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        let scrollOffset = scrollopoint.y
        if (scrollOffset > 60.0){
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            setNavigationImage(controller: self)
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
    
    @objc func openProfile()
    {
        
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = "\(self.user_id!)"
        presentedVC.fromActivity = false
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    
  
    
    @objc func goBack()
    {
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
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String , timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
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
    
    func shareTextImageAndURL(sharingText: String?, sharingImage: UIImage?)
    {
        var shareText = ""
        var shareImage : UIImage?
        var shareURL = "none"
        
        if let text = sharingText
        {
            shareText = text
        }
        if let image = sharingImage
        {
            shareImage = image
        }
        
        let activityItems = ActivityShareItemSources(text: shareText, image: shareImage!, url: URL(string: shareURL)!)

        let activityViewController = UIActivityViewController(activityItems: [activityItems], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        
        
        if(activityViewController.popoverPresentationController != nil) {
            activityViewController.popoverPresentationController?.sourceView = self.view;
            let frame = UIScreen.main.bounds
            
            activityViewController.popoverPresentationController?.sourceRect = frame;
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // Show Gutter Menus
    @objc func showGutterMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        var url = ""
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                var params = Dictionary<String, AnyObject>()
                
//                if dic["name"] as! String == "videoCreate"{
//                    continue
//                }
                
                if dic["name"] as! String != "share" {
                    let titleString = dic["name"] as! String
                    if titleString.range(of: "delete") != nil{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                                
                            case "delete":
                                
                                displayAlertWithOtherButton(NSLocalizedString("Delete Listing", comment: ""),message: NSLocalizedString("Are you sure you want to delete this listing entry?",comment: "") , otherButton: NSLocalizedString("Delete Listing", comment: "")) { () -> () in
                                    self.deleteListingEntry = true
                                    let params: NSDictionary = [:]
                                    self.updateListing(params as NSDictionary, url: dic["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                        }))
                    }else{

                        if dic["name"] as! String != "apply-now"
                        {
                            alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.default, handler:{ (UIAlertAction) -> Void in
                                // Write For Edit Album Entry
                                let condition = dic["name"] as! String
                                switch(condition){
                                    
                                case "videoCreate" :
                                    addvideo_click = 1
                                    manage_advvideoshow = true
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
//                                case "create" :
//
//                                    isCreateOrEdit = true
//                                    let presentedVC = FormGenerationViewController()
//                                    presentedVC.formTitle = dic["label"] as! String
//                                    presentedVC.contentType = "advancedevents"
//                                    presentedVC.eventExtensionCheck = true
//                                    presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
//                                    url = dic["url"] as! String
//                                    presentedVC.url = url
//                                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
//                                    let nativationController = UINavigationController(rootViewController: presentedVC)
//                                    self.present(nativationController, animated:true, completion: nil)
                                    
                                case "tellafriend":
                                    
                                    //confirmationAlert = false
                                    let presentedVC = TellAFriendViewController();
                                    url = dic["url"] as! String
                                    presentedVC.url = url
                                    self.navigationController?.pushViewController(presentedVC, animated: true)
                                    
                                    
                                case "report":
                                    let presentedVC = ReportContentViewController()
                                    presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    
                                    presentedVC.url = dic["url"] as! String
                                    self.navigationController?.pushViewController(presentedVC, animated: false)
                                    
                                    
                                    
                                case "edit":
                                    
                                    isCreateOrEdit = false
                                    let presentedVC = FormGenerationViewController()
                                    presentedVC.contentType = "listings"
                                    var editFormTitle = "Edit Listing"
                                    if dic["label"] != nil{
                                        editFormTitle = dic["label"] as! String
                                    }
                                    presentedVC.formTitle = NSLocalizedString(editFormTitle, comment: "")
                                    presentedVC.listingTypeId = self.listingTypeId
                                    presentedVC.url = dic["url"] as! String
                                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                    self.present(nativationController, animated:false, completion: nil)
                                    
                                    
                                case "wishlist":
                                    
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
                                    
                                    isCreateOrEdit = true
                                    globFilterValue = ""
                                    
                                    let presentedVC = FormGenerationViewController()
                                    presentedVC.formTitle = NSLocalizedString("Write a Review", comment: "")
                                    presentedVC.contentType = "Review"
                                    var tempDic = NSDictionary()
                                    tempDic = ["listingtype_id" : String(self.listingTypeId)]
                                    
                                    presentedVC.param = tempDic as! [AnyHashable : Any] as NSDictionary
                                    presentedVC.url = dic["url"] as! String
                                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                    self.present(nativationController, animated:false, completion: nil)
                                    
                                case "update":
                                    
                                    isCreateOrEdit = true
                                    globFilterValue = ""
                                    
                                    let presentedVC = FormGenerationViewController()
                                    presentedVC.formTitle = NSLocalizedString("Update Review", comment: "")
                                    presentedVC.contentType = "Review"
                                    let param = dic["urlParams"] as! NSDictionary
                                    let reviewid = param["review_id"] as! Int
                                    var tempDic = NSDictionary()
                                    tempDic = ["listingtype_id" : String(self.listingTypeId),"review_id":"\(reviewid)"]
                                    presentedVC.param = tempDic as! [AnyHashable : Any] as NSDictionary
                                    presentedVC.url = dic["url"] as! String
                                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                    self.present(nativationController, animated:false, completion: nil)
                                    
                                    
                                case "close", "open":
                                    Reload = "Not Refresh"
                                    self.updateListing(params as NSDictionary, url: dic["url"] as! String)
                                    
                                    
                                case "messageowner":
                                    
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
                                    
                                case "subscribe":
                                    
                                    Reload = "Not Refresh"
                                    
                                    var message = ""
                                    let title = dic["label"] as! String
                                    message = String(format: NSLocalizedString("You have successfully subscribed to %@!", comment: ""), title)
                                    
                                    params["message"] = message as AnyObject?
                                    params["listingtype_id"] = self.listingTypeId as AnyObject?
                                    self.updateListing(params as NSDictionary, url: dic["url"] as! String)
                                    
                                    
                                case "unsubscribe":
                                    
                                    Reload = "Not Refresh"
                                    
                                    
                                    var message = ""
                                    let title = dic["label"] as! String
                                    message = String(format: NSLocalizedString("You have successfully subscribed to %@!", comment: ""), title)
                                    params["message"] = message as AnyObject?
                                    params["listingtype_id"] = self.listingTypeId as AnyObject?
                                    self.updateListing(params as NSDictionary, url: dic["url"] as! String)
                                    
                                case "claim":
                                    
                                    //confirmationAlert = false
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
                                    presentedVC.Sharetitle = self.contentTitle
                                    presentedVC.ShareDescription = ""//self.topicDescription
                                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                    self.present(nativationController, animated:true, completion: nil)
                                    
                                    
                                case "apply-now":
                                    //confirmationAlert = false
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
                            }))
                        }
                    }
                }
            }
        }
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel", comment: ""), style: .cancel, handler:nil))
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
    
    func updateListing(_ params: NSDictionary, url: String){
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
            
            if url.range(of: "subscribe") != nil{
                dic["owner_id"] = "\(self.user_id)"
            }
            
            
            // Send Server Request to Explore listing Contents with listing_ID
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
                            
                            _ = self.navigationController?.popViewController(animated: false)
                            //self.createTimer(self)
                            return
                        }
                        self.explorelisting()
                        
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
    
    // Refersh table content
    func refresh(){
        DispatchQueue.main.async(execute: {
            soundEffect("Activity")
        })
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            showSpinner = false
            updateAfterAlert = false
            explorelisting()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    //FUNCTION FOR CLICKING ON ACTIVITY OPTIONS LIKE STATUS PHOTO AND CHECKIN
    func openPostFeed(_ sender:UIButton){
        
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
    
    @objc func applyJob()
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
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true
        {
            _ = self.navigationController?.popViewController(animated: false)
        }
        
    }
    
    // Coverimage selection
    @objc func onImageViewTap(_ sender:UITapGestureRecognizer)
    {
        if self.coverImageUrl != nil && self.coverImageUrl != "" {
            let presentedVC = SinglePhotoLightBoxController()
            presentedVC.imageUrl = self.coverImageUrl
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            present(nativationController, animated:false, completion: nil)
        }
    }

}

extension MLTBlogTypeViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
            webView.frame.size.height = height as! CGFloat
           
            if webView.frame.size.height > 0 {
              activityIndicatorView.stopAnimating()
            }
            
            self.mainSubView.isHidden = false
            self.detailWebView.frame.size.height = height as! CGFloat
            
            self.detailWebView.frame.size.width = self.view.frame.size.width
            self.padingAfterWebView = getBottomEdgeY(inputView: self.detailWebView)
            self.mainSubView.frame.size.height = self.padingAfterWebView
            self.headerHeight =  self.padingAfterWebView + 10
            globalFeedHeight = self.headerHeight
            self.feedObj.refreshLikeUnLike = true
            self.feedObj.tableView.reloadData()
            self.navigationController?.view.isUserInteractionEnabled = true
            
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(String(describing: decisionHandler))")
        activityIndicatorView.startAnimating()
       
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
}
