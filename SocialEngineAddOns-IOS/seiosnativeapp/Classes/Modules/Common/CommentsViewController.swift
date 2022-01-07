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
//  CommentsViewController.swift
//  seiosnativeapp
//

protocol refresh{
    func reloaddata()
    func deleteFeed()
    func reloadOnLike(newDictionary : NSDictionary)
}

import UIKit
import Photos
var commentsUpdate : Bool = false
var allStickersValueDic = Dictionary<String, AnyObject>() // all stickers with ordered corresponding to particular sticker
var allStickersDic = Dictionary<String, AnyObject>() // Stickers in ordered that present in our app
var sticterArray : NSMutableArray = [] // Stickers that present in our app
var isRefresh = false
let subscriptionTagLinkAttributes = [
    NSAttributedString.Key.foregroundColor: textColorDark,
    // NSUnderlineStyleAttributeName: NSNumber(bool:true),
]
class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, TTTAttributedLabelDelegate, UIGestureRecognizerDelegate, UIPopoverPresentationControllerDelegate, UISearchBarDelegate,ELCImagePickerControllerDelegate, UIImagePickerControllerDelegate,refresh {
    
    var delegateComments : DelegateCommentUI?
    var cancel1 = UIBarButtonItem()
    // Variables for Comments
    var openCommentTextView:Int = 0
    var commentPermission:Int!
    var pushFlag = false
    var commenttableView:UITableView!
    var allComments:[Comment] = []
    var commentTextView:UITextView!
    var commentPost:UIButton!
    var canComment:Bool!
    var likes:UIButton!
    var extraParameters = Dictionary<String, String>()
    var activityFeedComment = false // Coming from Main AAF or home feed
    var activityfeedIndex:Int!
    var fullDescriptionCell = [Int]()           // Contain Array of all cell to show full description
    var myLimit:Int!
    var contentActivityFeedComment = false // Coming from content page feed
    var userActivityFeedComment = false // Coming from user profile feed
    var contentIcon : UILabel!
    var noCommentTitle = UILabel()
    var fromActivityFeed = false
    var dynamicHeight = [Int:CGFloat]()
    var pageNumber:Int = 1
    var isPageRefresing = false
    var updateScrollFlag = false
    var actionId:String!
    var actionIdDelete:Int!
    var likeCount:Int!
    var commentCount:Int!
    var commentFeedArray = [AnyObject]()
    var reactionsIcon = [AnyObject]()
    var tapGesture = UITapGestureRecognizer()
    // Initialize MembersViewController Class
    // Sticker Work
    var stickers = UIButton()
    var searchStickersArray : NSArray = []
    let stickerScrollView = UIScrollView()
    let particularStickersView =  UIScrollView()
    var openStickerViewVariable = false
    var allStickersOfParticularSticker : NSArray = []
    var allStickersOfParticularStickernNew  = [NSArray]()
    var totalStickerViewHeight : CGFloat! = 260//250
    var stickerScrollViewHeight : CGFloat! = 40
    var particularStickersViewHeight : CGFloat! = 210
    var searchDictionary = Dictionary<String, String>()
    var searchedStickers : NSArray = []
    var statusofResponse : Bool = false
    var addSticker : UIButton!
    let searchBar = UISearchBar()
    var stickerParameters = Dictionary<String, String>()
    let searchedStickersView = UIScrollView()
    var currentPage : Int = 0
    var stickerImageStringToPost : String = ""
    var dictionaryForStickerImageStringToPost = Dictionary<String, String>()
    var callStickerDirect : Bool = false
    var indexOfSelectedSticker : Int!
    var leftBarButtonItem : UIBarButtonItem!
    var fromPhotoViewer = false
    var commentTabelHeight : CGFloat = TOPPADING
    var navbarHeight : CGFloat = TOPPADING
    // Varibles for Image Attachment In Comments
    var attachImage = UIButton()
    var allPhotos = [UIImage]()
    var sampleImage = UIImageView()
    var ImageAttachmentHeight : CGFloat = 0
    var addedPhotos : Bool = false
    var imagePost:Bool! = false
    var dictionaryForImageToPost = Dictionary<String, String>()
    
    var noCommentIcon = UIImageView()
    var showUserTableView:UITableView! // Showing user for taging
    var suggestedHashTags = [AnyObject]()
    var dynamicHeightValue:CGFloat = 70
    var frndTags = UILabel()
    var selectedString = ""
    var CheckParameters = [String:String]()
    var collect = [NSDictionary]()
    var selectArray = [String]()
    var imageviewUrl = [String]()
    var keyBoardHeight1 :  CGFloat = 0
    //let singleFeed = FeedViewPageViewController()
    var fromSingleFeed = false // For showing feed or not
    var fromNotification = false
    var isComingFromTikTokPage = false
    var i : Int = 0
    var scrollingComment = UIScrollView()
    var ContainerView = UIView()
    var feedObj = FeedTableViewController()
    var commentTextViewHeight : CGFloat = 50 + iphonXBottomsafeArea
    var activityFeeds:[ActivityFeed] = []       // To save Activity Feeds from Response (subclass of ActivityFeed)
    var feedArray1 = [AnyObject]()
    var tempHeight : CGFloat = 0
    var reactionsInfo : UIView!
    var isComingFromAAF = false // Coming from AAF ot not
    var searchText : String = ""
    var NotifyCommentId : Int = 0
    private var dismissEmojiView: UITapGestureRecognizer?
    override func viewDidLoad()
    {
        super.viewDidLoad()
        listingDetailUpdate = false
        pageDetailUpdate = false
        reviewUpdate = false
        myLimit = 0
        tableViewFrameType = "CommentsViewController"
        view.backgroundColor = textColorLight
        feedObj.delegate = self
        allPhotos.removeAll(keepingCapacity: false)
        
    
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            particularStickersViewHeight = 300
            totalStickerViewHeight  = 340
        }
        //Notification for showing/Hiding keyboard
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CommentsViewController.keyboardWasShown),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CommentsViewController.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
   
        
         // Top bar for showing like and reactions count
        setReactionLikeCountBar()
        
        // Add Navigation bar
        setNavigation()
        
        // Comment Textview and Image work
        bottombarUI()
        
        // Adding Feedtableview and commentstableview on scrollview for showing feed and comment
        commentsUI()

        
        // For resign keyboard on click on view anywhere
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(CommentsViewController.resignKeyboard))
        tapGesture.delegate = self
        tapGesture.cancelsTouchesInView = false;
        if fromSingleFeed == true{
          scrollingComment.addGestureRecognizer(tapGesture)
        }
        else{
           commenttableView.addGestureRecognizer(tapGesture)
        }
 
        // All sticker stuff calling and UI
        self.stickerUI()
        dismissEmojiView = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        dismissEmojiView?.cancelsTouchesInView = false
        if let tap = dismissEmojiView {
            view.addGestureRecognizer(tap)
        }
       
        if self.fromSingleFeed == false{
            self.noCommentIcon.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
            self.noCommentIcon.center = self.view.center
            self.noCommentIcon.image = #imageLiteral(resourceName: "noCommentIcon")
            self.view.addSubview(self.noCommentIcon)
            self.noCommentIcon.isHidden = true
            self.noCommentTitle.frame = CGRect(x: 0, y: getBottomEdgeY(inputView: self.noCommentIcon)-5, width: self.view.bounds.width, height: 20)
            self.noCommentTitle.center.x = self.view.center.x
            self.noCommentTitle.text = NSLocalizedString("Be the first one to comment", comment: "")
            self.noCommentTitle.textAlignment = .center
            self.noCommentTitle.font = UIFont.systemFont(ofSize: 16)
            self.noCommentTitle.textColor = .gray
            self.noCommentTitle.isHidden = true
            self.view.addSubview(self.noCommentTitle)
        }
    
    }
    
    @objc private func dismissView() {
      
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        
        //view.removeGestureRecognizer(tap)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        //commenttableView.reloadData()
        tableViewFrameType = "CommentsViewController"
        self.browseEmoji(contentItems: reactionsDictionary)
        if commentsUpdate == true{
            self.browseFeed()
            commentsUpdate = false
        }
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = true
            
        }
        self.title =  NSLocalizedString("Comments ", comment: "")
        if self.allComments.count > 0
        {
            if self.fromSingleFeed == true
            {
              
              self.commenttableView.frame.size.height = self.commenttableView.contentSize.height
              self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight
            }
            else
            {
           
              self.commenttableView.frame.size.height = self.view.bounds.height - (self.commentTabelHeight + self.commentTextViewHeight)
            }

        }
        
        if activityFeedComment == true
        {
            feedObj.feedShowingFrom = "ActivityFeed"

            
        }
        else if userActivityFeedComment == true
        {
            feedObj.feedShowingFrom = "UserFeed"
           
        }
        else if contentActivityFeedComment == true
        {
            feedObj.feedShowingFrom = ""
        }
    }
    
    // Add Navigation bar
    func setNavigation()
    {
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(CommentsViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
    }
    
    // Comment Textview and attachment work
    func bottombarUI()
    {
        if commentPermission != nil
        {
            if (commentPermission == 1)
            {
                
                // Check that whether Image Attachment for comments is enable or not
//                if emojiEnabled == true{
//                    attachImage = createButton(CGRect(x: 0,y: view.bounds.height-45-iphonXBottomsafeArea , width: 40, height: 40), title: "\u{f030}", border: false,bgColor: true, textColor: UIColor.lightGray )
//                    attachImage.backgroundColor = UIColor.clear
//                    attachImage.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
//                    attachImage.isHidden = true
//                    view.addSubview(attachImage)
//                    attachImage.tag = 0
//                    attachImage.addTarget(self, action: #selector(CommentsViewController.photoOptions), for: .touchUpInside)
//                    commentTextView = createTextView(CGRect(x: 40,y: view.bounds.height-45-iphonXBottomsafeArea , width: view.bounds.width-(70 + 40), height: 40), borderColor: borderColorMedium, corner: false )
//                }
//                else
//                {
//                    commentTextView = createTextView(CGRect(x: 5,y: view.bounds.height - 45 - iphonXBottomsafeArea, width: view.bounds.width-70, height: 40), borderColor: borderColorMedium, corner: false )
//                }

                let imageSize:CGSize = CGSize(width: 25, height: 25)
                attachImage.frame = CGRect(x: 0,y: view.bounds.height-45-iphonXBottomsafeArea , width: 40, height: 40)
                attachImage.imageEdgeInsets = UIEdgeInsets(
                    top: (attachImage.frame.size.height - imageSize.height) / 2,
                    left: (attachImage.frame.size.width - imageSize.width) / 2,
                    bottom: (attachImage.frame.size.height - imageSize.height) / 2,
                    right: (attachImage.frame.size.width - imageSize.width) / 2)
                attachImage.setImage(#imageLiteral(resourceName: "cameraIcon"), for: .normal)
                attachImage.isHidden = true
                view.addSubview(attachImage)
                attachImage.tag = 0
                attachImage.addTarget(self, action: #selector(CommentsViewController.photoOptions), for: .touchUpInside)
                commentTextView = createTextView(CGRect(x: 40,y: view.bounds.height-45-iphonXBottomsafeArea , width: view.bounds.width-(70 + 40), height: 40), borderColor: borderColorMedium, corner: false )
                
                
                commentTextView.isHidden = true
                commentTextView.layer.cornerRadius = 5.0
                commentTextView.delegate = self
                commentTextView.text = NSLocalizedString("Write a Comment...",  comment: "")
                commentTextView.font = UIFont(name: fontName, size: FONTSIZELarge )
                commentTextView.textColor = textColorMedium
                commentTextView.autocorrectionType = UITextAutocorrectionType.yes
                commentTextView.returnKeyType = UIReturnKeyType.done
                view.addSubview(commentTextView)
                view.bringSubviewToFront( commentTextView)
                
                if StickerPlugin == true{
                    searchDictionary.removeAll(keepingCapacity: false)
                    let imageSize:CGSize = CGSize(width: 25, height: 25)
                       stickers = createButton(CGRect(x: commentTextView.bounds.width-40,y: 0 , width: 40, height: 40), title: "", border: false,bgColor: true, textColor: UIColor.lightGray )
                    stickers.backgroundColor = UIColor.clear
                    stickers.imageEdgeInsets = UIEdgeInsets(
                        top: (stickers.frame.size.height - imageSize.height) / 2,
                        left: (stickers.frame.size.width - imageSize.width) / 2,
                        bottom: (stickers.frame.size.height - imageSize.height) / 2,
                        right: (stickers.frame.size.width - imageSize.width) / 2)
                    stickers.setImage(#imageLiteral(resourceName: "emojiicon"), for: .normal)
                    stickers.isHidden = true
                    commentTextView.addSubview(stickers)
                    stickers.tag = 0
                    stickers.addTarget(self, action: #selector(CommentsViewController.stickerView(_:)), for: .touchUpInside)
                }
                
                if #available(iOS 9.0, *) {
                    let item : UITextInputAssistantItem = commentTextView.inputAssistantItem
                    item.leadingBarButtonGroups = []
                    item.trailingBarButtonGroups = []
                }
                commentPost = createButton(CGRect(x: view.bounds.width-65,y: view.bounds.height - 45-iphonXBottomsafeArea, width: 60, height: 40), title: "", border: false,bgColor: true, textColor: navColor)
                let iconImageSize = CGSize(width: 30, height: 30)
                commentPost.setImage(#imageLiteral(resourceName: "sendIcon").maskWithColor(color: navColor), for: .normal)
                commentPost.imageEdgeInsets = UIEdgeInsets(
                    top: (commentPost.frame.size.height - iconImageSize.height) / 2,
                    left: (commentPost.frame.size.width - iconImageSize.width) / 2,
                    bottom: (commentPost.frame.size.height - iconImageSize.height) / 2,
                    right: (commentPost.frame.size.width - iconImageSize.width) / 2)
                commentPost.isHidden = true
                commentPost.backgroundColor = UIColor.clear
                commentPost.isEnabled = false
                //commentPost.titleLabel?.font = UIFont(name: "FontAwesome" , size: FONTSIZEExtraLarge)
                commentPost.addTarget(self, action: #selector(CommentsViewController.postComment), for: .touchUpInside)
                view.addSubview(commentPost)
            }
            else
            {
                commentTextViewHeight = 0
            }
            
        }
    }
    
    // Adding Feedtableview and commentstableview on scrollview for showing feed and commen
    func commentsUI()
    {
        if fromSingleFeed == true
        {
            scrollingComment = UIScrollView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height - commentTextViewHeight - TOPPADING))
            view.addSubview(scrollingComment)
            scrollingComment.alwaysBounceVertical = true
            scrollingComment.translatesAutoresizingMaskIntoConstraints = false
            scrollingComment.showsHorizontalScrollIndicator = false
            scrollingComment.addSubview(feedObj.view)
            scrollingComment.delegate = self
            scrollingComment.backgroundColor = textColorLight
            scrollingComment.isHidden = true
            feedObj.tableView.bounces = false
            feedObj.tableView.isScrollEnabled = false
            self.addChild(feedObj)
            self.browseFeed()

            
        }
        else
        {
          findAllComments()
        }
      
        commenttableView = UITableView(frame: CGRect(x: 0, y: commentTabelHeight, width: view.bounds.width, height: 0), style: UITableView.Style.grouped)
        commenttableView.dataSource = self
        commenttableView.delegate = self
        commenttableView.bounces = false
        commenttableView.rowHeight = UITableView.automaticDimension
        commenttableView.estimatedRowHeight = 44
        commenttableView.backgroundColor = textColorLight
        commenttableView.separatorColor = TVSeparatorColor
        commenttableView.isScrollEnabled = false
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            commenttableView.estimatedRowHeight = 0
            commenttableView.estimatedSectionHeaderHeight = 0
            commenttableView.estimatedSectionFooterHeight = 0
        }
        
        
        // Showing user for taging
        showUserTableView = UITableView(frame: CGRect(x: 10, y: TOPPADING + 80, width: view.bounds.width - 40, height: view.bounds.height - keyBoardHeight - 50 - TOPPADING - 150), style: UITableView.Style.plain)
        showUserTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        showUserTableView.dataSource = self
        showUserTableView.delegate = self
        showUserTableView.rowHeight = 50
        showUserTableView.backgroundColor = textColorLight
        showUserTableView.separatorColor = UIColor.clear//TVSeparatorColor
        showUserTableView.tag = 22
        showUserTableView.isHidden = true
        showUserTableView.layer.masksToBounds = false
        showUserTableView.layer.shadowOffset = CGSize(width: 0, height: 5);
        showUserTableView.layer.shadowOpacity = 0.5
        if fromSingleFeed == true
        {
            scrollingComment.addSubview(commenttableView)
            self.view.addSubview(showUserTableView)
        }
        else
        {
            self.view.addSubview(commenttableView)
            self.view.addSubview(showUserTableView)
        }
        if #available(iOS 11.0, *) {
            showUserTableView.estimatedRowHeight = 0
            showUserTableView.estimatedSectionHeaderHeight = 0
            showUserTableView.estimatedSectionFooterHeight = 0
        }
    }
    
    // Top bar for showing like and reactions count
    func setReactionLikeCountBar()
    {
        if ReactionPlugin == true
        {
            reactionsInfo = createView(CGRect(x: 0,y: TOPPADING ,width: view.bounds.width , height: 36), borderColor: UIColor.clear, shadow: false)
            reactionsInfo.isHidden = true
            view.addSubview(reactionsInfo)
            let bottomBorder = UIView(frame: CGRect(x: 0, y: reactionsInfo.frame.size.height - 0.5, width: reactionsInfo.frame.size.width , height: 0.5))
            bottomBorder.backgroundColor = TVSeparatorColor
            bottomBorder.tag = 1000
            reactionsInfo.addSubview(bottomBorder)
            let arrowicon = createImageView(CGRect(x: view.bounds.width - 20,y: 9.5,width: 17,height: 17), border: false)
            arrowicon.image = UIImage(named: "Forward")
            reactionsInfo.addSubview(arrowicon)
        }
        else{
            likes = createButton(CGRect(x: 0,y: TOPPADING,width: view.bounds.width,height: 36), title: "", border: false,bgColor: false, textColor: textColorMedium)
            likes.backgroundColor = textColorLight
            likes.isHidden = true
            likes.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            likes.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
            likes.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            likes.addTarget(self, action: #selector(CommentsViewController.showLikes), for: .touchUpInside)
            view.addSubview(likes)
            let bottomBorder = UIView(frame: CGRect(x: 0, y: likes.frame.size.height - 0.5, width: likes.frame.size.width , height: 0.5))
            bottomBorder.backgroundColor = TVSeparatorColor
            bottomBorder.tag = 1000
            likes.addSubview(bottomBorder)
            let arrowicon = createImageView(CGRect(x: view.bounds.width - 20,y: 9.5,width: 17,height: 17), border: false)
            arrowicon.image = UIImage(named: "Forward")
            likes.addSubview(arrowicon)
        }
    }
    func stickerUI()
    {
        getIntialSticker()
        self.stickersUI()
        stickerScrollView.isHidden = true
        particularStickersView.isHidden = true
        addSticker.isHidden = true
    }
    
    

    
    @objc func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.commenttableView.layoutIfNeeded()
        keyBoardHeight1 = keyboardFrame.size.height
       
        // Animation On TextView Begin Editing
        UIView.animate(withDuration: 0.5, animations:
         {
            
            
            
            if  self.stickerScrollView.isHidden == true
            {
                self.commentTextView.frame.origin.y = self.view.bounds.height - (self.keyBoardHeight1 + self.commentTextViewHeight)
                if self.fromSingleFeed == false && total_Comments < 1
                 {
                    self.noCommentIcon.frame.origin.y =  self.commentTextView.frame.origin.y  - self.noCommentIcon.frame.height - 20
                    self.noCommentTitle.frame.origin.y = self.commentTextView.frame.origin.y - self.noCommentTitle.frame.height - 20
                }
                self.commentPost.frame.origin.y = self.view.bounds.height - (self.keyBoardHeight1 + self.commentTextViewHeight)
            //if emojiEnabled == true{
                if enabledModules.contains("nestedcomment")
                {
                    self.attachImage.frame.origin.y = self.view.bounds.height - (self.keyBoardHeight1 + self.commentTextViewHeight)
                    self.attachImage.isHidden = false
                }
                if self.addedPhotos == true{
                    self.sampleImage.frame.origin.y -= (self.keyBoardHeight1)
                }
            //}
            if self.fromSingleFeed == true
            {
                 self.scrollingComment.frame.size.height = self.view.bounds.height - (self.navbarHeight+self.commentTextViewHeight + self.keyBoardHeight1 + self.ImageAttachmentHeight )
                self.commenttableView.frame.size.height = self.commenttableView.contentSize.height
                if total_Comments > 0 {
                    
                  
                    self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight
                    if self.ImageAttachmentHeight > 0 {
                       // self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight + self.ImageAttachmentHeight
                        self.scrollingComment.frame.size.height = self.commenttableView.contentSize.height + self.commentTabelHeight + self.ImageAttachmentHeight + 10//self.view.bounds.height-(self.navbarHeight+self.commentTextViewHeight+self.ImageAttachmentHeight + 20 + self.keyBoardHeight1)
                        
                    }
                    }
                    else {
                        self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight + self.noCommentIcon.frame.height + self.noCommentTitle.frame.height + 20
                    }
                
               
                    
                    

                self.scrollToBottom()
            }
            else
            {

                self.commenttableView.frame.size.height = self.view.bounds.height - (self.commentTabelHeight + self.commentTextViewHeight + self.keyBoardHeight1 + self.ImageAttachmentHeight)
                if self.allComments.count > 0
                {
                    let indexPath = IndexPath(row: self.allComments.count - 1, section: 0)
                    self.commenttableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                }

            }

            }})
        
    }
    

    @objc func keyboardWillHide(sender: NSNotification)
    {
       
        UIView.animate(withDuration: 0.5, animations: {
            if  self.stickerScrollView.isHidden == true{
        
            self.commentTextView.frame.origin.y = self.view.bounds.height - self.commentTextViewHeight
            if self.fromSingleFeed == false && total_Comments < 1 {
                    self.noCommentIcon.center = self.view.center
                    self.noCommentTitle.frame.origin.y = getBottomEdgeY(inputView: self.noCommentIcon) - 9
            }
            self.commentPost.frame.origin.y = self.view.bounds.height - self.commentTextViewHeight
            //if emojiEnabled == true{
                if self.attachImage != nil{
                    self.attachImage.frame.origin.y = self.view.bounds.height - self.commentTextViewHeight
                }
                if self.addedPhotos == true{
                    self.sampleImage.frame.origin.y += (self.keyBoardHeight1)
                }
            //}
            if self.fromSingleFeed == true && total_Comments > 0
            {
                self.scrollingComment.frame.size.height = self.view.bounds.height-(self.navbarHeight+self.commentTextViewHeight+self.ImageAttachmentHeight)
                if self.ImageAttachmentHeight > 0 {
                    self.scrollingComment.frame.size.height = self.view.bounds.height-(self.navbarHeight+self.commentTextViewHeight+self.ImageAttachmentHeight + 20)
                }
                self.commenttableView.frame.size.height = self.commenttableView.contentSize.height
                self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight + 50
         
                //Set scrolloffset
                self.scrollToBottom()
            }
            else if self.fromSingleFeed == false
            {
                self.commenttableView.frame.size.height = self.view.bounds.height - (self.commentTabelHeight + self.commentTextViewHeight)
            }
            if total_Comments == 0  && self.fromSingleFeed{
                
                self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight + self.noCommentIcon.frame.height + self.noCommentTitle.frame.height + 20
                    self.scrollingComment.frame.size.height += self.keyBoardHeight1

                }
           
            
            }})
        
        
    }
    func scrollToBottom(){
        //Set scrolloffset
        if self.scrollingComment.contentSize.height > self.scrollingComment.bounds.size.height
        {
            
            let bottomOffset = CGPoint(x: 0, y: self.scrollingComment.contentSize.height - self.scrollingComment.bounds.size.height + self.scrollingComment.contentInset.bottom + 35 )
            self.scrollingComment.setContentOffset(bottomOffset, animated: false)
        }
        
        
    }
    @objc func resignKeyboard() {
        if self.fromSingleFeed == false {
       
        }
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        if stickerScrollView.isHidden == true{
            if commentTextView.canBecomeFirstResponder
            {
              commentTextView.resignFirstResponder()
            }
            if searchBar.canBecomeFirstResponder
            {
            searchBar.resignFirstResponder()
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        if let tabBarObject = self.tabBarController?.tabBar
        {
            tabBarObject.isHidden = false
            
        }
        if scrollViewEmoji.isDescendant(of: (UIApplication.shared.keyWindow)!)
        {
            scrollViewEmoji.isHidden = true
        }
        tableViewFrameType = ""
        self.title = ""
        afterPost = false
        contentfeedArrUpdate = true
        frndTagValue.removeAll()
        searchDictionary.removeAll(keepingCapacity: false)
    }
    
    
    //MARK: Start Code for Image Attachment
    
    //When click on Camera Icon
    @objc func photoOptions(){
        commentTextView.resignFirstResponder()
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Camera",comment: ""), style: .default) { action -> Void in
            self.openCamera()
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Gallery",comment: ""), style: UIAlertAction.Style.default) { action -> Void in
            self.openGallery()
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
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
    }
    
    //Open Gallery
    func openGallery() {
        let imagePicker = ELCImagePickerController(imagePicker: ())
        imagePicker?.maximumImagesCount = 1
        imagePicker?.returnsOriginalImage = true
        imagePicker?.returnsImage = true
        imagePicker?.onOrder = true
        imagePicker?.imagePickerDelegate = self
        
        let photoAuthorization = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorization
        {
        case .authorized:
            present(imagePicker!, animated: false, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if newStatus == PHAuthorizationStatus.authorized
                {
                    self.present(imagePicker!, animated: false, completion: nil)
                }
            })
            print("It is not determined until now")
        case .denied, .restricted:
            photoPermission(controller: self)
            print("User has denied the permission.")
        }
        
        //present(imagePicker!, animated: false, completion: nil)
    }
    
    //Open Camera
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.camera
            image.allowsEditing = true
            self.present(image, animated: true, completion: nil)
        }
    }
    
    // MARK: ELCImagePickerControllerDelegate Methods
    
    func elcImagePickerControllerDidCancel(_ picker: ELCImagePickerController!) {
        dismiss(animated: true, completion: nil)
        ImageAttachmentHeight = 0
        if StickerPlugin == true{
            stickers.isHidden = false
        }
    }
    
    func elcImagePickerController(_ picker: ELCImagePickerController!, didFinishPickingMediaWithInfo info: [Any]!) {
        dismiss(animated: true, completion: nil)
        allPhotos.removeAll(keepingCapacity: false)
        
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isSynchronous = true
        for dic in info
        {
            if let photoDic = dic as? PHAsset
            {
                if photoDic.mediaType == PHAssetMediaType.image
                {
                    manager.requestImage(for: photoDic , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: requestOptions, resultHandler: { (pickedImage, info) in
                        
                        self.allPhotos.append(pickedImage!) // you can get image like this way
                        
                    })
                }
            }
        }
        
        for dic in info{
            if let photoDic = dic as? NSDictionary{
                if photoDic.object(forKey: UIImagePickerController.InfoKey.mediaType) as! String == ALAssetTypePhoto {
                    if (photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) != nil){
                        let image = photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) as! UIImage
                        allPhotos.append(image)
                    }
                }
            }
        }
        
        
        
        adjustPhoto()
    }
    // MARK:  UIImagePickerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: nil)
//        for dic in info{
//            if let photoDic = dic as? NSDictionary{
//
//                if photoDic.object(forKey: UIImagePickerController.InfoKey.mediaType) as! String == ALAssetTypePhoto {
//
//                    if (photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) != nil){
//                        let image = photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) as! UIImage
//                        adjustCameraPhoto(image)
//                        allPhotos.append(image)
//                        let imageArray = [image as UIImage]
//                        filePathArray.removeAll(keepingCapacity: false)
//                        filePathArray = saveFileInDocumentDirectory(imageArray)
//                    }
//                }
//            }
//
//        }
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        adjustCameraPhoto(image)
        allPhotos.append(image)
        let imageArray = [image as UIImage]
        filePathArray.removeAll(keepingCapacity: false)
        filePathArray = saveFileInDocumentDirectory(imageArray)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker .dismiss(animated: true, completion: nil)
        ImageAttachmentHeight = 0
        if StickerPlugin == true{
            stickers.isHidden = false
        }
    }
    
    // Show Image In case of Camera
    func adjustCameraPhoto(_ image: UIImage!){
        addedPhotos = true
        if StickerPlugin == true{
            if stickers.tag == 1{
                stickerView(stickers)
            }
            stickers.isHidden = true
        }
        self.commentPost.isEnabled = true
        self.commentPost.alpha = 1
        self.commentPost.setTitleColor(buttonColor, for: UIControl.State())
        let originY:CGFloat = view.bounds.height - (commentTextView.frame.size.height + commentTextViewHeight)
        sampleImage = AAFMultipleImageViewWithGradient(frame: CGRect(x: 5, y: originY - 40, width: 70 , height: 70))
        sampleImage.isUserInteractionEnabled = true
        ImageAttachmentHeight = sampleImage.frame.size.height
        view.addSubview(sampleImage)
        sampleImage.image = image
        let cross =  createButton(CGRect(x: sampleImage.frame.size.width - 15, y: 0, width: 15, height: 15), title: "", border: false,bgColor: false, textColor: textColorLight)
        cross.setImage(UIImage(named: "cross_icon"), for: UIControl.State())
        cross.titleLabel?.font =  UIFont(name: fontBold, size:FONTSIZEExtraLarge)
        cross.addTarget(self, action: #selector(CommentsViewController.cancelCameraImage), for: .touchUpInside)
        sampleImage.addSubview(cross)
        
        if self.ImageAttachmentHeight > 0 {
            self.noCommentIcon.isHidden = true
            self.noCommentTitle.isHidden = true
        }
        
        if self.fromSingleFeed == true
        {
            
            self.commenttableView.frame.size.height = self.commenttableView.contentSize.height + self.ImageAttachmentHeight
            self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight + self.ImageAttachmentHeight
        }
        else
        {
            
            self.commenttableView.frame.size.height = self.view.bounds.height - (self.commentTabelHeight + self.commentTextViewHeight)
             self.scrollingComment.frame.size.height = self.view.bounds.height-(self.navbarHeight+self.commentTextViewHeight+self.ImageAttachmentHeight+60)
        }
        
//        self.commenttableView.frame.size.height = self.view.bounds.height-(self.commentTabelHeight+commentTextViewHeight) - self.ImageAttachmentHeight
//        self.scrollingComment.frame.size.height = self.view.bounds.height-(self.navbarHeight+self.commentTextViewHeight+self.ImageAttachmentHeight+60)
    }
    
    // Show Images that Selected in case of Gallery
    func adjustPhoto()
    {
        if allPhotos.count > 0{
            addedPhotos = true
            if StickerPlugin == true{
                if stickers.tag == 1{
                    stickerView(stickers)
                }
                stickers.isHidden = true
            }
            self.commentPost.isEnabled = true
            self.commentPost.alpha = 1
            self.commentPost.setTitleColor(buttonColor, for: UIControl.State())
            let originY:CGFloat = view.bounds.height - (commentTextView.frame.size.height + commentTextViewHeight)
            sampleImage = AAFMultipleImageViewWithGradient(frame: CGRect(x: 5, y: originY - 40, width: 70 , height: 70))
            sampleImage.isUserInteractionEnabled = true
            ImageAttachmentHeight = sampleImage.frame.size.height
            view.addSubview(sampleImage)
            sampleImage.image = allPhotos[0]
            let cross =  createButton(CGRect(x: sampleImage.frame.size.width - 20, y: 0, width: 20, height: 20), title: "", border: false,bgColor: false, textColor: textColorLight)
            cross.setImage(UIImage(named: "cross_icon"), for: UIControl.State())
            cross.titleLabel?.font =  UIFont(name: fontBold, size:FONTSIZEExtraLarge)
            cross.addTarget(self, action: #selector(CommentsViewController.cancelCameraImage), for: .touchUpInside)
            sampleImage.addSubview(cross)
            
            if self.ImageAttachmentHeight > 0 {
                self.noCommentIcon.isHidden = true
                self.noCommentTitle.isHidden = true
            }
            
            if self.fromSingleFeed == true
            {
                
                self.commenttableView.frame.size.height = self.commenttableView.contentSize.height + self.ImageAttachmentHeight
                self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight + self.ImageAttachmentHeight
            }
            else
            {
                
                self.commenttableView.frame.size.height = self.view.bounds.height - (self.commentTabelHeight + self.commentTextViewHeight)
                 self.scrollingComment.frame.size.height = self.view.bounds.height-(self.navbarHeight+self.commentTextViewHeight+self.ImageAttachmentHeight+60)
            }
            
            
            
//            self.commenttableView.frame.size.height = self.view.bounds.height-(self.commentTabelHeight+commentTextViewHeight) - self.ImageAttachmentHeight
//
//            self.scrollingComment.frame.size.height = self.view.bounds.height-(self.navbarHeight+self.commentTextViewHeight+self.ImageAttachmentHeight + 20)
//            if total_Comments == 0 {
//                self.scrollingComment.setContentOffset(CGPoint(x: 0, y: self.scrollingComment.contentSize.height - self.scrollingComment.bounds.size.height), animated: true)
//            }
        }
    }
    
    //Cancel Images after click on cross
    @objc func cancelCameraImage(){
        allPhotos.removeAll(keepingCapacity: false)
        addedPhotos = false
        sampleImage.image = nil
        self.ImageAttachmentHeight = 0
        sampleImage.removeFromSuperview()
        if StickerPlugin == true{
            stickers.isHidden = false
        }
        if commentTextView.textColor == textColorMedium{
            self.commentPost.isEnabled = false
            self.commentPost.alpha = 0.6
            self.commentPost.setTitleColor(UIColor.lightGray, for: UIControl.State())
        }
        if self.fromSingleFeed == true
        {
            self.scrollingComment.frame.size.height = self.view.bounds.height-(self.navbarHeight+self.commentTextViewHeight+self.ImageAttachmentHeight)
            
        }
        commentTextView.resignFirstResponder()
    }
    
    // Save Images
    func saveFileInDocumentDirectory(_ images :[AnyObject]) ->([String]){
        var getImagePath = [String]()
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        var i = 0
        for image in images{
            i += 1
            var filename = ""
            let tempImageString = randomStringWithLength(8)
            filename = "\(tempImageString)\(i).png"
            let filePathToWrite = "\(paths)/\(filename)"
            if fileManager.fileExists(atPath: filePathToWrite){
                removeFileFromDocumentDirectoryAtPath(filePathToWrite)
            }
            var imageData: Data!
            imageData =  (image as! UIImage).jpegData(compressionQuality:0.7)
            fileManager.createFile(atPath: filePathToWrite, contents: imageData, attributes: nil)
            getImagePath.append(paths.stringByAppendingPathComponent("\(filename)"))
        }
        return getImagePath;
    }
    
    //MARK: Finish Code for Image Attachment
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        // test if our control subview is on-screen
        if (touch.view == self.commentPost) {
            return false
            
        }
        return true // handle the touch
    }
    
    
    @objc func cancel()
    {
        
        if commentTextViewHeight != 0
        {
            commentTextView.resignFirstResponder()
        }
        if feedObj.globalArrayFeed.count != 0
        {
            if let dic = feedObj.globalArrayFeed[0] as? NSMutableDictionary
            {
                delegateComments?.countLikeandComments(data: dic)
            }
        }
        _ = self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
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
    
    @objc func showLikes(){
        let presentedVC = MembersViewController()
        if likeCommentContentType == "activity_action"{
            presentedVC.action_idd = "\(actionId)"
        }
        
        presentedVC.contentType = "activityFeed"
     //   if activityFeedComment == true || userActivityFeedComment == true || contentActivityFeedComment == true{
        //    presentedVC.contentType = "activityFeed"
      //  }else{
        //    presentedVC.contentType = "comments"
        //}
        
        presentedVC.fromPhotoViewer = fromPhotoViewer
        navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    @objc func showCommentLikes(_ sender: UIButton){
        let comment = allComments[sender.tag]
        let presentedVC = MembersViewController()
        presentedVC.action_idd = "\(actionId!)"
        presentedVC.contentType = "comments"
        presentedVC.commentsLike = comment.comment_id!
        presentedVC.fromPhotoViewer = fromPhotoViewer
        navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    //Update Activity Feed
    func updateActivityFeed(_ likeCount:Int, commentCount:Int){
        
        feedUpdate = false
        if fromNotification == false{
            if  self.contentActivityFeedComment == true {
                if let feed = commentFeedArray[activityfeedIndex] as? NSDictionary {
                    
                    let newDictionary:NSMutableDictionary = [:] //= [String:AnyObject]()
                    
                    if feed["subject_image"]  != nil{
                        newDictionary["subject_image"] = feed["subject_image"]
                    }
                    if feed["feed_title"]  != nil{
                        newDictionary["feed_title"] = feed["feed_title"]
                    }
                    if feed["feed_createdAt"]  != nil{
                        newDictionary["feed_createdAt"] = feed["feed_createdAt"]
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
                    if feed["delete"]  != nil{
                        newDictionary["delete"] = feed["delete"]
                    }
                    if feed["share"]  != nil{
                        newDictionary["share"] = feed["share"]
                    }
                    if feed["is_like"] != nil{
                        newDictionary["is_like"] = feed["is_like"]
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
                    
                    if feed["photo_attachment_count"] != nil{
                        newDictionary["photo_attachment_count"] = feed["photo_attachment_count"]
                    }
                    if feed["object_id"] != nil{
                        newDictionary["object_id"] = feed["object_id"]
                    }
                    if feed["object_type"] != nil{
                        newDictionary["object_type"] = feed["object_type"]
                    }
                    newDictionary["comment_count"] = commentCount
                    if(feed["likes_count"] != nil){
                        newDictionary["likes_count"] = likeCount
                    }
                    if feed["hashtags"] != nil{
                        newDictionary["hashtags"] = feed["hashtags"]
                    }
                    
                    if feed["decoration"] != nil{
                        newDictionary["decoration"] = feed["decoration"]
                    }
                    if feed["wordStyle"] != nil{
                        newDictionary["wordStyle"] = feed["wordStyle"]
                    }
                    if feed["publish_date"] != nil{
                        newDictionary["publish_date"] = feed["publish_date"]
                    }
                    if feed["isNotificationTurnedOn"] != nil{
                        newDictionary["isNotificationTurnedOn"] = feed["isNotificationTurnedOn"]
                        
                    }
                    
                    if feed["attachment_content_type"] != nil{
                        newDictionary["attachment_content_type"] = feed["attachment_content_type"]
                    }
                    
                    if feed["pin_post_duration"] != nil{
                        newDictionary["pin_post_duration"] = feed["pin_post_duration"]
                    }
                    if feed["isPinned"] != nil{
                        newDictionary["isPinned"] = feed["isPinned"]
                    }
                    
                    // var newData = ActivityFeed.loadActivityFeedInfofromDictionary(newDictionary)
                    commentFeedArray[activityfeedIndex] = newDictionary//newData[0] as! ActivityFeed
                }
            }
            else if self.userActivityFeedComment == true {
                if let feed = commentFeedArray[activityfeedIndex] as? NSDictionary {
                    
                    let newDictionary:NSMutableDictionary = [:] //= [String:AnyObject]()
                    
                    if feed["subject_image"]  != nil{
                        newDictionary["subject_image"] = feed["subject_image"]
                    }
                    if feed["feed_title"]  != nil{
                        newDictionary["feed_title"] = feed["feed_title"]
                    }
                    if feed["feed_createdAt"]  != nil{
                        newDictionary["feed_createdAt"] = feed["feed_createdAt"]
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
                    if feed["delete"]  != nil{
                        newDictionary["delete"] = feed["delete"]
                    }
                    if feed["share"]  != nil{
                        newDictionary["share"] = feed["share"]
                    }
                    if feed["is_like"] != nil{
                        newDictionary["is_like"] = feed["is_like"]
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
                    if feed["photo_attachment_count"] != nil{
                        newDictionary["photo_attachment_count"] = feed["photo_attachment_count"]
                    }
                    if feed["object_id"] != nil{
                        newDictionary["object_id"] = feed["object_id"]
                    }
                    if feed["object_type"] != nil{
                        newDictionary["object_type"] = feed["object_type"]
                    }
                    newDictionary["comment_count"] = commentCount
                    if feed["likes_count"] != nil{
                        newDictionary["likes_count"] = likeCount
                    }
                    if feed["hashtags"] != nil{
                        newDictionary["hashtags"] = feed["hashtags"]
                    }
                    
                    if feed["decoration"] != nil{
                        newDictionary["decoration"] = feed["decoration"]
                    }
                    if feed["wordStyle"] != nil{
                        newDictionary["wordStyle"] = feed["wordStyle"]
                    }
                    if feed["publish_date"] != nil{
                        newDictionary["publish_date"] = feed["publish_date"]
                    }
                    if feed["isNotificationTurnedOn"] != nil{
                        newDictionary["isNotificationTurnedOn"] = feed["isNotificationTurnedOn"]
                        
                    }
                    
                    if feed["attachment_content_type"] != nil{
                        newDictionary["attachment_content_type"] = feed["attachment_content_type"]
                    }
                    
                    if feed["pin_post_duration"] != nil{
                        newDictionary["pin_post_duration"] = feed["pin_post_duration"]
                    }
                    if feed["isPinned"] != nil{
                        newDictionary["isPinned"] = feed["isPinned"]
                    }
                    
                    // var newData = ActivityFeed.loadActivityFeedInfofromDictionary(newDictionary)
                    commentFeedArray[activityfeedIndex] = newDictionary//newData[0] as! ActivityFeed
                }
            }
            else{
                if let feed = commentFeedArray[activityfeedIndex] as? NSDictionary {
                    
                    let newDictionary:NSMutableDictionary = [:] //= [String:AnyObject]()
                    
                    if feed["subject_image"]  != nil{
                        newDictionary["subject_image"] = feed["subject_image"]
                    }
                    
                    if feed["feed_title"]  != nil{
                        newDictionary["feed_title"] = feed["feed_title"]
                    }
                    
                    if feed["feed_createdAt"]  != nil{
                        newDictionary["feed_createdAt"] = feed["feed_createdAt"]
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
                    
                    if feed["delete"]  != nil{
                        newDictionary["delete"] = feed["delete"]
                    }
                    
                    if feed["share"]  != nil{
                        newDictionary["share"] = feed["share"]
                    }
                    
                    if feed["is_like"] != nil{
                        newDictionary["is_like"] = feed["is_like"]
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
                    
                    if feed["photo_attachment_count"] != nil{
                        newDictionary["photo_attachment_count"] = feed["photo_attachment_count"]
                    }
                    
                    if feed["object_id"] != nil{
                        newDictionary["object_id"] = feed["object_id"]
                    }
                    
                    if feed["object_type"] != nil{
                        newDictionary["object_type"] = feed["object_type"]
                    }
                    
                    newDictionary["comment_count"] = commentCount
                    if feed["likes_count"] != nil{
                        newDictionary["likes_count"] = likeCount
                    }
                    
                    if feed["hashtags"] != nil{
                        newDictionary["hashtags"] = feed["hashtags"]
                    }
                    
                    if feed["decoration"] != nil{
                        newDictionary["decoration"] = feed["decoration"]
                    }
                    if feed["wordStyle"] != nil{
                        newDictionary["wordStyle"] = feed["wordStyle"]
                    }
                    if feed["publish_date"] != nil{
                        newDictionary["publish_date"] = feed["publish_date"]
                    }
                    if feed["isNotificationTurnedOn"] != nil{
                        newDictionary["isNotificationTurnedOn"] = feed["isNotificationTurnedOn"]
                        
                    }
                    
                    if feed["attachment_content_type"] != nil{
                        newDictionary["attachment_content_type"] = feed["attachment_content_type"]
                    }
                    
                    if feed["pin_post_duration"] != nil{
                        newDictionary["pin_post_duration"] = feed["pin_post_duration"]
                    }
                    if feed["isPinned"] != nil{
                        newDictionary["isPinned"] = feed["isPinned"]
                    }
                    
                    // var newData = ActivityFeed.loadActivityFeedInfofromDictionary(newDictionary)
                    commentFeedArray[activityfeedIndex] = newDictionary//newData[0] as! ActivityFeed
                }
            }
        }
    }
    
    // MARK: - Server Connection For Comments
    
    func findAllComments(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            // Show Spinner for Updation
            if activityIndicatorView.isAnimating == false{
                activityIndicatorView.center = view.center
                if updateScrollFlag == false && extraParameters.count > 0{
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-90)
                }

//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                self.view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
              //  activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            var parameters = ["subject_id":String(likeCommentContent_id), "subject_type": likeCommentContentType, "viewAllComments":"1", "limit":"\(limit)", "page":"\(pageNumber)"]
            
            if activityFeedComment == true
            {
                if actionId != nil
                {
                    parameters["action_id"] = String(actionId)
                }
                else
                {
                    if let feed = commentFeedArray[activityfeedIndex] as? NSDictionary{
                        if let action_id = feed["action_id"] as? Int{
                            parameters["action_id"] = String(action_id)
                            actionId = "\(action_id)"
                            
                        }
                    }
                }
            }
            else if contentActivityFeedComment == true {
                
                if let feed = commentFeedArray[activityfeedIndex] as? NSDictionary{
                    if let action_id = feed["action_id"] as? Int{
                        parameters["action_id"] = String(action_id)
                        actionId = "\(action_id)"
                        
                    }
                }
            }
            else if userActivityFeedComment == true {
                
                if let feed = commentFeedArray[activityfeedIndex] as? NSDictionary{
                    if let action_id = feed["action_id"] as? Int{
                        parameters["action_id"] = String(action_id)
                        actionId = "\(action_id)"
                    }
                }
            }
            
            if (self.pageNumber == 1){
                allComments.removeAll(keepingCapacity: false)
            }
            

            var url:String!
            
            switch(likeCommentContentType){
            case "activity_action":
                url = "advancedactivity/feeds/likes-comments"
            case "sitestorereview_review":
                parameters.updateValue(likeCommentContentType, forKey: "subject_type")
                url = "likes-comments"
            default:
                if enabledModules.contains("nestedcomment")
                {
                    url = "advancedcomments/likes-comments"
                }
                else
                {
                    url = "likes-comments"
                }
                
            }
            if self.fromSingleFeed {
                self.noCommentIcon.frame = CGRect(x: 0, y: self.commentTabelHeight, width: 150, height: 150)
                self.noCommentIcon.center.x = self.view.center.x
                self.noCommentIcon.contentMode = .scaleAspectFill
                self.scrollingComment.addSubview(self.noCommentIcon)
                self.scrollingComment.bringSubviewToFront( self.noCommentIcon)
                self.noCommentIcon.image = #imageLiteral(resourceName: "noCommentIcon")
                self.noCommentIcon.isHidden = true
                self.noCommentTitle.frame = CGRect(x: 0, y: getBottomEdgeY(inputView: self.noCommentIcon)-7, width: self.view.bounds.width, height: 20)
                self.noCommentTitle.center.x = self.view.center.x
                self.noCommentTitle.text = NSLocalizedString("Be the first one to comment", comment: "")
                self.noCommentTitle.textAlignment = .center
                self.noCommentTitle.font = UIFont.systemFont(ofSize: 16)
                self.noCommentTitle.textColor = .gray
                self.noCommentTitle.isHidden = true
                self.scrollingComment.addSubview(self.noCommentTitle)
                self.scrollingComment.bringSubviewToFront( self.noCommentTitle)
            }
            // Send Server Request for Comments
            post(parameters as! Dictionary<String, String>, url: url, method: "GET") { (succeeded, msg) -> () in
                // Stop Spinner
                DispatchQueue.main.async(execute: {
//                    activityIndicatorView.stopAnimating()
                    self.updateScrollFlag = true
                    self.scrollingComment.isHidden = false
                    if msg
                    {
                        if self.fromNotification == true
                        {
                            self.commenttableView.frame.origin.y = self.feedObj.tableView.contentSize.height - 70
                            self.commentTabelHeight  = self.commenttableView.frame.origin.y
                        }
                        if (self.pageNumber == 1){
                            self.allComments.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                
                                // Update title
                                total_Comments = body["getTotalComments"] as! Int
                                self.commentCount = total_Comments
                                
                                if total_Comments > 1{
                                    self.title =  String(format: NSLocalizedString("%d Comments ", comment: ""),total_Comments)
                                    
                                }else if total_Comments == 1{
                                    self.title =  String(format: NSLocalizedString("%d Comment ", comment: ""),total_Comments)
                                }
                                else if total_Comments == 0{
                                    self.title =  String(format: NSLocalizedString("Comments ", comment: ""))
                                }
                           
                                
                                if total_Comments < 1 && self.fromSingleFeed == false{
                                    self.noCommentIcon.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
                                    self.noCommentIcon.center = self.view.center
                                    self.noCommentIcon.image = #imageLiteral(resourceName: "noCommentIcon")
                                    self.view.addSubview(self.noCommentIcon)
                                    self.noCommentIcon.isHidden = false
                                    self.noCommentTitle.frame = CGRect(x: 0, y: getBottomEdgeY(inputView: self.noCommentIcon)-5, width: self.view.bounds.width, height: 20)
                                    self.noCommentTitle.center.x = self.view.center.x
                                    self.noCommentTitle.text = NSLocalizedString("Be the first one to comment", comment: "")
                                    self.noCommentTitle.textAlignment = .center
                                    self.noCommentTitle.font = UIFont.systemFont(ofSize: 16)
                                    self.noCommentTitle.textColor = .gray
                                    self.noCommentTitle.isHidden = false
                                    self.view.addSubview(self.noCommentTitle)
                                    if StickerPlugin == true{
//                                        self.contentIcon.frame.origin.y = self.view.bounds.height/2-120
                                    }
//                                    self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
//                                    self.view.addSubview(self.contentIcon)
                               
                                    if StickerPlugin == true{
//                                        self.contentIcon.frame.origin.y = self.view.bounds.height/2-120
                                    }
                                   
                                    if StickerPlugin == true{
                                     
                                    }
                                  
                                }
                                
                                
                                // Get total Likes and reaction count for topBar
                                total_Likes = body["getTotalLikes"] as! Int
                                if self.fromSingleFeed == false
                                {
                                    if ReactionPlugin == true{
                                        if self.reactionsIcon.count > 0{
                                            self.reactionsInfo.isHidden = false
                                            self.commentTabelHeight = TOPPADING + 36
                                            var menuWidth = CGFloat()
                                            var origin_x:CGFloat = 10.0
                                            for (index, _) in self.reactionsIcon.enumerated() {
                                                menuWidth = 13
                                                let   emoji = createButton(CGRect(x: origin_x ,y: 8, width: menuWidth, height: 18), title: "", border: false, bgColor: false, textColor: textColorLight)
                                                
                                                emoji.tag = index
                                                
                                                emoji.imageEdgeInsets =  UIEdgeInsets(top: 4, left: 0, bottom: 1, right: 0)
                                                emoji.addTarget(self, action: #selector(CommentsViewController.showLikes), for: .touchUpInside)
                                                
                                                let imageUrl = self.reactionsIcon[index]
                                                
                                                let url = NSURL(string:imageUrl as! String)
                                                if url != nil
                                                {
                                                    emoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in                        
                    })
                                                }
                                                
                                                self.reactionsInfo.addSubview(emoji)
                                                origin_x += (menuWidth)
                                                
                                            }
                                            
                                            let emoji = createButton(CGRect(x: origin_x + 2 ,y: 8, width: self.view.bounds.width - origin_x,height: 20), title: "", border: false, bgColor: false, textColor: textColorMedium)
                                            emoji.setTitle("\(total_Likes)", for: UIControl.State.normal)
                                            emoji.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                                            emoji.titleLabel?.font = UIFont(name: fontName, size: 14.0)
                                            emoji.addTarget(self, action: #selector(CommentsViewController.showLikes), for: .touchUpInside)
                                            self.reactionsInfo.addSubview(emoji)
                                            
                                        }
                                        else{
                                            if self.reactionsInfo != nil{
                                                self.reactionsInfo.isHidden = true
                                            }
                                            self.commentTabelHeight = TOPPADING
                                        }
                                        
                                    }
                                    else{
                                        if total_Likes == 0{
                                            self.likes.isHidden = true
                                            self.commentTabelHeight = TOPPADING
                                        }else {
                                            self.likes.isHidden = false
                                            self.commentTabelHeight = TOPPADING + 36
                                            if total_Likes == 1 {
                                                let main_string = String(format: NSLocalizedString("%@ 1 person likes this", comment: ""),likeIcon)
                                                //let main_string = " \(likeIcon) 1 person likes this"
                                                let string_to_color = "1 person"
                                                let range = (main_string as NSString).range(of: string_to_color)
                                                let range1 = (main_string as NSString).range(of: main_string)
                                                var myMutableString = NSMutableAttributedString()
                                                myMutableString = NSMutableAttributedString(
                                                    string: main_string,attributes: [NSAttributedString.Key.font:UIFont(name: "FontAwesome", size: FONTSIZENormal)!] )
                                                myMutableString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontBold,
                                                                                                                size: FONTSIZENormal)!,range: range)
                                                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColorMedium,range: range1)
                                                self.likes.setAttributedTitle(myMutableString, for: .normal)
                                            }
                                            else{
                                                let main_string = String(format: NSLocalizedString("%@ %d people like this", comment: ""),likeIcon,total_Likes)
                                                // let main_string = " \(likeIcon) \(total_Likes) people like this"
                                                let string_to_color = "\(total_Likes) people"
                                                let range = (main_string as NSString).range(of: string_to_color)
                                                let range1 = (main_string as NSString).range(of: main_string)
                                                var myMutableString = NSMutableAttributedString()
                                                myMutableString = NSMutableAttributedString(
                                                    string: main_string,attributes: [NSAttributedString.Key.font:UIFont(name: "FontAwesome", size: FONTSIZENormal)!])
                                                myMutableString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: fontBold,
                                                                                                                size: FONTSIZENormal)!,range: range)
                                                myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: textColorMedium,range: range1)
                                                self.likes.setAttributedTitle(myMutableString, for: .normal)
                                            }
                                            
                                        }
                                    }
                                }
                                // Ends Get total Likes and reaction count for topBar
                                
                                
                                // Set Updated Label Info
                                var finalText = ""
                                finalText = "\(total_Likes) \(likeIcon)"
                                finalText += " / "
                                finalText += "\(total_Comments) \(commentIcon)"
                                
                                
                                if ((self.activityFeedComment == true) || (self.contentActivityFeedComment == true) || (self.userActivityFeedComment == true)) {
                                    
                                    self.updateActivityFeed(total_Likes, commentCount: total_Comments)
                                }else{
                                    if info != nil{
                                        info.text = finalText
                                        
                                    }
                                }
                                
                                // Get all Comments
                                if let comments = body["viewAllComments"] as? NSArray{
                                    self.allComments +=  Comment.loadComments(comments)
                                }
                                
                                // Get Permission for Comment
                                self.canComment = body["canComment"] as! Bool
                                if (self.canComment == true)
                                {
                                    self.commentTextView.isHidden = false
                                    self.commentPost.isHidden = false
                                    if enabledModules.contains("nestedcomment")
                                    {
                                        self.attachImage.isHidden = false
                                    }
                                    self.commenttableView.frame = CGRect(x: 0, y: self.commentTabelHeight, width: self.view.bounds.width, height: self.view.bounds.height-(self.commentTabelHeight+self.commentTextViewHeight))
 
                                }
                                else
                                {
                                    self.commentTextViewHeight = 0
                                    self.commenttableView.frame = CGRect(x: 0, y: self.commentTabelHeight, width: self.view.bounds.width, height: self.view.bounds.height-self.commentTabelHeight)
                                    self.scrollingComment.frame.size.height = self.view.bounds.height - self.navbarHeight
                                    
                                }
                                
                                if self.extraParameters.count > 0 {
                                    if (self.canComment == true){
                                        self.commentTextView.isHidden = true
                                        self.commentPost.isHidden = true
                                        if enabledModules.contains("nestedcomment")
                                        {
                                            self.attachImage.isHidden = false
                                        }
                                    }
                                    self.commenttableView.frame = CGRect(x:0, y:self.commentTabelHeight,width: self.view.bounds.width, height: self.view.bounds.height-self.commentTabelHeight - self.commentTextViewHeight)
                                }
                                
                                // Reload Comment Tabel
                                if self.fromSingleFeed == true
                                {
                                    
                                    self.feedObj.tableView.frame.size.height = self.feedObj.tableView.contentSize.height
                                    self.commentTabelHeight = self.feedObj.tableView.frame.size.height - 72
                                    self.noCommentIcon.frame.origin.y = self.commentTabelHeight
                                    self.noCommentTitle.frame.origin.y = getBottomEdgeY(inputView: self.noCommentIcon)-7
                                    self.commenttableView.frame.origin.y = self.commentTabelHeight
                                  //  self.commenttableView.layoutIfNeeded()
                                  //  self.commenttableView.reloadData()
                                    
                                    if (self.canComment == true)
                                    {
                                      activityIndicatorView.stopAnimating()
                                      self.commenttableView.layoutIfNeeded()
                                      self.commenttableView.reloadData()
                                      self.commenttableView.frame.size.height = self.commenttableView.contentSize.height
                                         self.scrollingComment.contentSize.height = self.commenttableView.frame.origin.y + self.commenttableView.bounds.height
                                        
                                        if self.allComments.count == total_Comments && self.allComments.count > 0
                                        {
                                            let indexPath = IndexPath(row: self.allComments.count - 1, section: 0)
                                            self.commenttableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                            
                                            if (self.canComment == true) && self.openCommentTextView == 1
                                            {
                                                self.commentTextView.becomeFirstResponder()
                                            }
                                        }
                                        else if self.allComments.count > 0 && self.allComments.count != total_Comments
                                        {
                                            self.pageNumber += 1
                                            let indexPath = IndexPath(row: self.allComments.count - 1, section: 0)
                                            self.commenttableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                            self.findAllComments()
                                        }
                                        
                                    }
                                    else
                                    {
                                        self.commenttableView.layoutIfNeeded()
                                        self.commenttableView.reloadData()
                                        
                                        self.commenttableView.frame.size.height = self.commenttableView.contentSize.height
                                         self.scrollingComment.contentSize.height = self.commenttableView.frame.origin.y + self.commenttableView.bounds.height + 20
                               
                                        delay(2, closure: {
                                            
                                            self.feedObj.refreshLikeUnLike = true
                                            self.feedObj.tableView.reloadData()
                                            if total_Comments == 0 &&  total_Likes == 0
                                            {
                                                self.commentTabelHeight = self.commentTabelHeight + 35
                                                self.commenttableView.frame.origin.y = self.commentTabelHeight
                                                total_Likes = 1
                                                
                                            }
                                            else if total_Comments == 0 && total_Likes > 0{
                                                self.commentTabelHeight = self.commentTabelHeight - 35
                                                self.commenttableView.frame.origin.y = self.commentTabelHeight
                                                total_Likes = 0
                                            }
                                            
                                            self.commenttableView.frame.size.height = self.commenttableView.contentSize.height
                                            self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight + 50
                                            activityIndicatorView.stopAnimating()
                                        })
                                       


                                    }
                                    
                                   // self.scrollingComment.contentSize.height = getBottomEdgeY(inputView: self.commenttableView)
                                    
                                    
                                }
                                else
                                {
                                    activityIndicatorView.stopAnimating()
                                    self.commenttableView.reloadData()
                                    self.commenttableView.frame.size.height = self.view.bounds.height-(ButtonHeight+TOPPADING)//self.commenttableView.contentSize.height
                                    self.commenttableView.isScrollEnabled = true
                                    if self.allComments.count == total_Comments && total_Comments != 0 && self.allComments.count > 0
                                    {
                                        let indexPath = IndexPath(row: self.allComments.count - 1, section: 0)
                                        self.commenttableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                        
                                        if (self.canComment == true) && self.openCommentTextView == 1
                                        {
                                            self.commentTextView.becomeFirstResponder()
                                        }
                                    }
                                    else if self.allComments.count > 0 && self.allComments.count != total_Comments
                                    {
                                        self.pageNumber += 1
                                        let indexPath = IndexPath(row: self.allComments.count - 1, section: 0)
                                        self.commenttableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                                        self.findAllComments()
                                    }
                                    
                                }
                                //self.commentPost.isEnabled = true
                                self.isPageRefresing = false
                                if (self.canComment == true && self.openCommentTextView == 1 && self.allComments.count == 0 )
                                {
                                    self.commentTextView.becomeFirstResponder()
                                }
                                
                            }
                        }
                        
                        // Get stickers from server
                        if StickerPlugin == true
                        {
                            self.getStickers()
                        }
                        if total_Comments < 1 && self.fromSingleFeed
                        {
                            self.noCommentIcon.isHidden = false
                            self.noCommentTitle.isHidden = false
                            self.scrollingComment.contentSize.height = self.commentTabelHeight + self.noCommentIcon.frame.height + self.noCommentTitle.frame.height + 20
                            self.scrollingComment.setContentOffset(CGPoint(x: 0, y: self.scrollingComment.contentSize.height - self.scrollingComment.bounds.size.height), animated: true)
                            if self.fromNotification || self.isComingFromTikTokPage {
                                self.noCommentIcon.frame.origin.y =  self.scrollingComment.contentSize.height - self.noCommentIcon.frame.height - self.noCommentTitle.frame.height
                                self.noCommentTitle.frame.origin.y = getBottomEdgeY(inputView:  self.noCommentIcon)
                            }
                            
                        }

                    }
                    else
                    {
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            activityIndicatorView.stopAnimating()
                            self.feedObj.tableView.frame.size.height = self.feedObj.tableView.contentSize.height
                            self.commentTabelHeight = self.feedObj.tableView.frame.size.height - 72
                            self.commenttableView.frame.origin.y = self.commentTabelHeight
                            self.commenttableView.frame.size.height = self.commenttableView.contentSize.height
                            self.scrollingComment.contentSize.height = getBottomEdgeY(inputView: self.commenttableView)
                            self.scrollingComment.frame.size.height = self.view.bounds.height - self.navbarHeight                            
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
    // Update/ Sink feedArray from [ActivityFeed] to show updates in ActivityFeed Table
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
            if feed.object != nil{
                newDictionary["object"] = feed.object
            }
            if feed.action_type_body != nil{
                newDictionary["action_type_body"] = feed.action_type_body
            }
            if feed.hashtags != nil{
                newDictionary["hashtags"] = feed.hashtags
            }
            if feed.userTag != nil{
                newDictionary["userTag"] = feed.userTag
            }
            if feed.wordStyle != nil{
                newDictionary["wordStyle"] = feed.wordStyle
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
            feedArray1.append(newDictionary)
            
        }
       // if isQuickContentInProcess == 0
       // {
            globalFeedHeight = 0
            self.feedObj.globalArrayFeed = feedArray1
            self.feedObj.refreshLikeUnLike = true
            self.feedObj.tableView.reloadData()
       // }
        
    }
    
    // Make Hard Refresh Request to server for Activity Feeds
    func browseFeed(){
        singleFeed = true
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()

            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            parameters = ["limit": "\(limit)","action_id": String(self.actionId),"object_info":"1","getAttachedImageDimention":"0"]
            
            
            // Send Server Request for Activity Feed
            post(parameters, url: "advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    // On Success Update Feeds
                    if msg
                    {
                        
                        self.activityFeeds.removeAll(keepingCapacity: false)
                        self.feedArray1.removeAll()
                        // Check response of Activity Feeds
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            // Check for Feeds
                            if response["data"] != nil  {
                                
                                if let activity_feed = response["data"] as? NSArray{
                                    
                                    // Extract FeedInfo from response by ActivityFeed class
                                    self.activityFeeds = ActivityFeed.loadActivityFeedInfo(activity_feed)
                                    // Update feedArray
                                    self.updateFeedsArray(self.activityFeeds)
                                    self.findAllComments()

                                }
                                else{
                                    showToast(message: "This Post has been deleted.", controller: self)
                                    let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                    _ = self.navigationController?.popViewController(animated: true)
                                    })
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
                            }

                            // Set Label If their is no feed in response
                            if self.feedArray1.count == 0 {
                                showToast(message: NSLocalizedString("There are no more posts to show.",  comment: ""), controller: self)
                            }

                        }
                        
                    }else{
                        
                        self.updateScrollFlag = true
                    }
                })
            }
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
                        emoji.addTarget(self, action: #selector(CommentsViewController.feedMenuReactionLike(sender:)), for: .touchUpInside)
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
        guard feedArray.count > 0 else { return }
        let feed = feedArray1[scrollViewEmoji.tag] as! NSDictionary
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
    //MARK: Get All Initial Stickers
    func  getStickers(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
            if searchDictionary.count > 0{
                let keyword : String = searchDictionary["search"]!
                dic["sticker_search"] = keyword

            }
            post(dic, url: "reactions/stickers", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                   // activityIndicatorView.stopAnimating()
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                // Check for Stickers Array
                                if let stickerArray = body["collectionList"] as? NSArray
                                {
                                    if stickerArray.count > 0 {
                                        self.stickers.isHidden = false
                                        sticterArray = stickerArray as! NSMutableArray
                                        allStickersDic.removeAll(keepingCapacity : false)
                                        for i in 0..<sticterArray.count {
                                            let singleStickerDictionary = sticterArray[i] as! NSDictionary
                                            let order = singleStickerDictionary["order"] as? Int
                                            allStickersDic["\(order!)"] = singleStickerDictionary
                                        }
                                        if self.searchDictionary.count == 0{
                                            self.getIntialSticker()
                                            self.getAllStickers()
                                            self.currentPage = 1
                                        }
                                    }
                                }
                                if let searchStickersArray = body["searchList"] as? NSArray
                                {
                                    if searchStickersArray.count > 0 {
                                        self.searchStickersArray = searchStickersArray
                                        self.getIntialSticker()
                                        self.stickersUI()
                                    }
                                }
                                if let searchStickers = body["stickers"] as? NSArray
                                {
                                    if searchStickers.count > 0 {
                                        self.searchedStickers = searchStickers
                                        self.afterSearchStickers()
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
    
    //MARK: Show Stickers On View
    @objc func stickerView(_ sender: UIButton){
        commentTextView.resignFirstResponder()
        if stickerScrollView.isHidden == true {
            sender.tag = 1
            showStickerView()
            
        }
        else{
            searchBar.resignFirstResponder()
            sender.tag = 0
            hideStickerView()
        }
        
    }
    
    //MARK: Fetch All Stickers
    
    //MARK: Call function get All Stickers of Particular Sticker
    func getAllStickers(){
        allStickersValueDic.removeAll(keepingCapacity : false)
        for i in 1...sticterArray.count {
            self.getAllStickersOfParticularSticker(sender: i)
        }
    }
    
    //MARK: get All Stickers of Particular Sticker
    func  getAllStickersOfParticularSticker(sender : Int){
        var collectionId : Int!
        var order : Int = 0
        if let dic = sticterArray[sender - 1] as? NSDictionary{
            if let collectionid = dic["collection_id"] as? Int{
                collectionId = collectionid
            }
        }
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            //removeAlert()
            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
            dic["collection_id"] = String(collectionId)
            post(dic, url: "reactions/stickers", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if let stickerArray = body["collection"] as? NSDictionary{
                                    if let orderOfSticker = stickerArray["order"] as? Int{
                                        order = orderOfSticker
                                    }
                                }
                                // Check for Stickers Array
                                if let stickerArrayy = body["stickers"] as? NSArray
                                {
                                    if stickerArrayy.count > 0 {
                                        self.allStickersOfParticularSticker = stickerArrayy
                                        let value = stickerArrayy
                                        allStickersValueDic["\(order)"] = value
                                        if allStickersValueDic.keys.count == sticterArray.count{
                                            //   statusofResponse is the Varible that shows all response regarding all sticker whether come or not
                                            self.statusofResponse = true
                                            self.stickersUI()
                                            if self.stickers.tag == 1{
                                                self.particularStickersView.isHidden = false
                                            }
                                            
                                        }
                                        
                                    }
                                }
                                
                            }
                        }
                    }
                    else{
                        self.statusofResponse = false
                        
                    }
                })
            }
            
        }
        else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
        
    }
    
    //MARK:  After fetch all stickers then Set UI
    func stickersUI(){
        for ob in self.particularStickersView.subviews{
            ob.removeFromSuperview()
        }
        particularStickersView.frame = CGRect(x: 0, y: view.bounds.height - self.totalStickerViewHeight - iphonXBottomsafeArea, width: view.bounds.width , height: self.particularStickersViewHeight)
        particularStickersView.delegate = self
        particularStickersView.tag = 3;
        particularStickersView.backgroundColor = UIColor.red
        var menuWidth = CGFloat()
        var origin_x:CGFloat = 0
        let origin_y:CGFloat = 0
        var j = 0
        if searchStickersArray.count > 0{
            menuWidth = view.bounds.width
            j = 1
            let scrollViewParticularSticker = UIScrollView()
            scrollViewParticularSticker.frame = CGRect(x: origin_x, y: origin_y, width: view.bounds.width , height: self.particularStickersViewHeight)
            scrollViewParticularSticker.delegate = self
            scrollViewParticularSticker.backgroundColor = tableViewBgColor
            // SearchView that shows searchBar
            let searchView  =  UIView(frame:CGRect(x: 0, y: 0, width: scrollViewParticularSticker.bounds.width, height: 50))
            scrollViewParticularSticker.addSubview(searchView)
            // Set Color for Search Bar and For Search Icon
            let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
            textFieldInsideSearchBar?.textColor = UIColor.red
            let placeholderAttributes: [NSAttributedString.Key : Any] = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.lightGray, NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.systemFont(ofSize: UIFont.systemFontSize)]
            let attributedPlaceholder: NSAttributedString = NSAttributedString(string: NSLocalizedString("Search Stickers",  comment: ""), attributes: placeholderAttributes)
            textFieldInsideSearchBar?.attributedPlaceholder = attributedPlaceholder
            let imageV = textFieldInsideSearchBar?.leftView as! UIImageView
            imageV.image = imageV.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            imageV.tintColor = UIColor.lightGray
            
            searchBar.searchBarStyle = UISearchBar.Style.minimal
            searchBar.layer.borderWidth = 0;
            searchBar.layer.shadowOpacity = 0;
            searchBar.setTextColor(UIColor.lightGray)
            searchBar.sizeToFit()
            searchBar.delegate = self
            searchView.addSubview(searchBar)
            // Predefine Search Stickers
            let scrollViewForSearchSticker = UIScrollView()
            scrollViewForSearchSticker.frame = CGRect(x: 0, y: 50, width: view.bounds.width , height: self.particularStickersViewHeight - 50)
            scrollViewForSearchSticker.delegate = self
            scrollViewForSearchSticker.tag = 0
            scrollViewForSearchSticker.backgroundColor =  tableViewBgColor
            scrollViewParticularSticker.addSubview(scrollViewForSearchSticker)
            var loop : Int = 0
            var origin_labelheight_y2 : CGFloat = 5
            var origin_labelheight_y : CGFloat = 5
            // For Predefine Search Stickers
            for i in 1...self.searchStickersArray.count {
                if let dic = searchStickersArray[i-1] as? NSDictionary{
                    if loop % 2 == 0{
                        let  singleSticker =    createButton(CGRect(x: 5,y: origin_labelheight_y ,width: view.bounds.width/2 - 10 ,height: 40), title: "", border: false,bgColor: false, textColor: textColorLight)
                        singleSticker.layer.cornerRadius = 10.0
                        singleSticker.tag = i - 1
                        singleSticker.addTarget(self, action: #selector(CommentsViewController.searchParticularSticker(_:)), for: UIControl.Event.touchUpInside)
                        stickerScrollView.addSubview(singleSticker)
                        if dic["background_color"] != nil{
                            let color = dic["background_color"]
                            let realColor = hexStringToUIColor(hex: color as! String)
                            singleSticker.backgroundColor = realColor
                        }
                        var searchStickerView = createImageView(CGRect(x: 10, y: 10, width: 20, height: 20), border: false)
                        if dic["image"] != nil{
                            let icon = dic["image"]
                            let url = URL(string:icon as! String)
                            searchStickerView.kf.indicatorType = .activity
                             (searchStickerView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            searchStickerView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                        singleSticker.addSubview(searchStickerView)
                        let stickerSearchLabel = createLabel(CGRect(x: searchStickerView.frame.size.width + searchStickerView.frame.origin.x + 5,y: 0,width: singleSticker.frame.size.width - (searchStickerView.frame.size.width + searchStickerView.frame.origin.x + 5) , height: 40), text: "", alignment: .center, textColor: textColorLight)
                        stickerSearchLabel.font = UIFont(name: fontBold, size: FONTSIZELarge)
                        stickerSearchLabel.textAlignment = NSTextAlignment.left
                        if dic["title"] != nil{
                            var title =  String(describing: dic["title"]!)
                            title = title.capitalized
                            stickerSearchLabel.text = title
                        }
                        singleSticker.addSubview(stickerSearchLabel)
                        origin_labelheight_y  = origin_labelheight_y + singleSticker.bounds.height + 10
                        loop = loop + 1
                        scrollViewForSearchSticker.addSubview(singleSticker)
                    }
                    else{
                        let  singleSticker1 =    createButton(CGRect(x: view.bounds.width/2 + 5,y: origin_labelheight_y2 ,width: view.bounds.width/2 - 10 ,height: 40), title: "", border: false,bgColor: false, textColor: textColorMedium)
                        singleSticker1.tag = i - 1
                        singleSticker1.layer.cornerRadius = 10.0
                        singleSticker1.addTarget(self, action: #selector(CommentsViewController.searchParticularSticker), for: UIControl.Event.touchUpInside)
                        if dic["background_color"] != nil{
                            let color = dic["background_color"]
                            let realColor = hexStringToUIColor(hex: color as! String)
                            singleSticker1.backgroundColor = realColor
                        }
                        stickerScrollView.addSubview(singleSticker1)
                        var searchStickerView1 = createImageView(CGRect(x: 10, y: 10, width: 20, height: 20), border: false)
                        if dic["image"] != nil{
                            let icon = dic["image"]
                            let url = URL(string:icon as! String)
                            searchStickerView1.kf.indicatorType = .activity
                            (searchStickerView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            searchStickerView1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                        singleSticker1.addSubview(searchStickerView1)
                        let stickerSearchLabel1 = createLabel(CGRect(x: searchStickerView1.frame.size.width + searchStickerView1.frame.origin.x + 5,y: 0,width: singleSticker1.frame.size.width - (searchStickerView1.frame.size.width + searchStickerView1.frame.origin.x + 5) , height: 40), text: "", alignment: .center, textColor: textColorLight)
                        if dic["title"] != nil{
                            var title =  String(describing: dic["title"]!)
                            title = title.capitalized
                            stickerSearchLabel1.text = title
                        }
                        stickerSearchLabel1.textAlignment = NSTextAlignment.left
                        stickerSearchLabel1.font = UIFont(name: fontBold, size: FONTSIZELarge)
                        singleSticker1.addSubview(stickerSearchLabel1)
                        origin_labelheight_y2  = origin_labelheight_y2 + singleSticker1.bounds.height + 10
                        loop = loop + 1
                        scrollViewForSearchSticker.addSubview(singleSticker1)
                    }
                }
            }
            scrollViewForSearchSticker.contentSize = CGSize(width: view.bounds.width,height: origin_labelheight_y)
            particularStickersView.addSubview(scrollViewParticularSticker)
            origin_x = origin_x + scrollViewParticularSticker.bounds.width
        }
        // statusofResponse is the Varible that shows all response regarding all sticker whether come or not
        if statusofResponse == true{
            
            for(_,v) in allStickersValueDic.sorted(by: { $0.0 < $1.0 }){
                let scrollViewParticularSticker = UIScrollView()
                self.allStickersOfParticularSticker =  v as! NSArray
                let origin_x2:CGFloat = (self.view.bounds.width *  CGFloat(j))
                let origin_y2:CGFloat = 0
                // code for all stickers
                if self.allStickersOfParticularSticker.count > 0{
                    var menuWidth1 = CGFloat()
                    var menuHeight1 = CGFloat()
                    var origin_x1:CGFloat = PADING
                    var origin_y1:CGFloat = PADING
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        menuWidth1 = (self.view.bounds.width/8) - 10
                        menuHeight1 = (self.view.bounds.width/8) - 10
                    }
                    else{
                        menuWidth1 = (self.view.bounds.width/4) - 10
                        menuHeight1 = (self.view.bounds.width/4) - 10
                    }
                    scrollViewParticularSticker.frame = CGRect(x: origin_x2, y: origin_y2, width: view.bounds.width , height: self.particularStickersViewHeight)
                    scrollViewParticularSticker.delegate = self
                    scrollViewParticularSticker.tag = j
                    scrollViewParticularSticker.backgroundColor = tableViewBgColor
                    for  i in 1...self.allStickersOfParticularSticker.count {
                        let  imageViewClick : UIButton!
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            imageViewClick = createButton(CGRect( x: origin_x1,y: origin_y1, width: (self.view.bounds.width/8) - 10, height: (self.view.bounds.width/8) - 10), title: "", border: false, bgColor: false, textColor: textColorLight)
                        }
                        else{
                            imageViewClick = createButton(CGRect( x: origin_x1,y: origin_y1, width: (self.view.bounds.width/4) - 10, height: (self.view.bounds.width/4) - 10), title: "", border: false, bgColor: false, textColor: textColorLight)
                        }
                        var searchStickerView = createImageView(CGRect(x: 0, y: 0, width: imageViewClick.bounds.width, height: imageViewClick.bounds.height), border: true)
                        if let dic = allStickersOfParticularSticker[i - 1] as? NSDictionary{
                            if dic["image"] != nil{
                                let icon = dic["image"]
                                let url = URL(string:icon as! String)
                                if url != nil
                                {
                                    searchStickerView.kf.indicatorType = .activity
                                    (searchStickerView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    searchStickerView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        
                                    })
                                }
                                
                            }
                            if dic["collection_id"] != nil{
                                let stickerId = dic["collection_id"] as? Int
                                imageViewClick.tag = stickerId!
                            }
                            if dic["sticker_id"] != nil{
                                let stickerId = dic["sticker_id"] as? Int
                                imageViewClick.tag = stickerId!
                                imageViewClick.addTarget(self, action: #selector(CommentsViewController.postStickers(_:)), for: UIControl.Event.touchUpInside)
                            }
                        }
                        scrollViewParticularSticker.addSubview(imageViewClick)
                        imageViewClick.addSubview(searchStickerView)
                        origin_x1 = menuWidth1 + origin_x1 + 10
                        if(UIDevice.current.userInterfaceIdiom == .pad)
                        {
                            if i%8 == 0{
                                origin_x1 = PADING
                                origin_y1 = menuHeight1 + origin_y1 +  10 // + PADING
                            }
                        }
                        else{
                            if i%4 == 0{
                                origin_x1 = PADING
                                origin_y1 = menuHeight1 + origin_y1 +  10 // + PADING
                            }
                        }
                    }
                    if self.allStickersOfParticularSticker.count  % 4 != 0{
                        origin_y1 = menuHeight1 + origin_y1 + 10   // + PADING
                    }
                    particularStickersView.addSubview(scrollViewParticularSticker)
                    scrollViewParticularSticker.alwaysBounceHorizontal = false
                    scrollViewParticularSticker.alwaysBounceVertical = true
                    scrollViewParticularSticker.contentSize = CGSize(width: view.bounds.width,height: origin_y1)
                }
                j = j + 1
                origin_x = origin_x + menuWidth
            }
        }
        else{
            for  _ in 0..<sticterArray.count {
                origin_x = origin_x + menuWidth
            }
        }
        particularStickersView.contentSize = CGSize(width: origin_x,height: self.particularStickersViewHeight)
        particularStickersView.delegate = self
        particularStickersView.isPagingEnabled = true
        particularStickersView.bounces = false
        particularStickersView.isUserInteractionEnabled = true
        particularStickersView.isScrollEnabled = true
        particularStickersView.isHidden = true
        self.particularStickersView.alwaysBounceHorizontal = true
        self.particularStickersView.alwaysBounceVertical = false
        particularStickersView.isDirectionalLockEnabled = false
        view.addSubview(particularStickersView)
    }
    
    // MARK: Add parameters for searching Stickers
    @objc func postStickers(_ sender: UIButton){
        self.addedPhotos = false
        let currentStickerPage = currentPage - 1
        var index = 0
        for(_,v) in allStickersValueDic.sorted(by: { $0.0 < $1.0 }){
            if index == currentStickerPage{
                let dic = v as? NSArray
                for tempdic in dic!{
                    let actualDictionary = tempdic as! NSDictionary
                    let collectionID = actualDictionary["sticker_id"]! as? Int
                    if collectionID == sender.tag{
                        stickerParameters["attachment_id"] = actualDictionary["guid"] as? String
                        stickerParameters["attachment_type"] =  "sticker"
                        self.stickerImageStringToPost = (actualDictionary["image_profile"] as? String)!
                        dictionaryForStickerImageStringToPost["image_profile"] = self.stickerImageStringToPost
                        break
                    }
                }
            }
            index = index + 1
        }
        commentTextView.text = ""
        postComment()
        
    }
    
    // MARK: Add parameters for searching Stickers
    @objc func postStickersUsingSearchedStickers(_ sender: UIButton){
        for  i in 1...self.searchedStickers.count {
            if let dic = searchedStickers[i - 1] as? NSDictionary{
                let stickerId = dic["sticker_id"] as? Int
                if stickerId == sender.tag{
                    stickerParameters["attachment_id"] = dic["guid"] as? String
                    stickerParameters["attachment_type"] =  "sticker"
                    self.stickerImageStringToPost = (dic["image_profile"] as? String)!
                    dictionaryForStickerImageStringToPost["image_profile"] = self.stickerImageStringToPost
                    break
                    
                }
            }
        }
        commentTextView.text = ""
        postComment()
        
    }
    
    //MARK:  Get Intial Stickers
    func getIntialSticker(){
        stickerScrollView.frame = CGRect(x: 0, y: view.bounds.height - 40 - iphonXBottomsafeArea, width: view.bounds.width - 60 , height: 40)
        stickerScrollView.delegate = self
        stickerScrollView.tag = 2;
        stickerScrollView.isHidden = true
        var menuWidth = CGFloat()
        var origin_x:CGFloat = PADING
        menuWidth = 40
        for ob in self.stickerScrollView.subviews{
            ob.removeFromSuperview()
        }
        let viewBorder = UIView(frame:CGRect(x: 0, y: 0, width: view.bounds.width, height: 1))
        viewBorder.backgroundColor = UIColor.lightGray
        stickerScrollView.addSubview(viewBorder)
        
        if searchStickersArray.count > 0{
        let  singleSticker =    createButton(CGRect(x: origin_x,y: PADING ,width: 35,height: 35), title: "\u{f002}", border: false,bgColor: false, textColor: UIColor.lightGray)
        singleSticker.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        singleSticker.tag = 0
        singleSticker.backgroundColor = aafBgColor
        singleSticker.addTarget(self, action: #selector(CommentsViewController.viewParticularSticker(_:)), for: UIControl.Event.touchUpInside)
        stickerScrollView.addSubview(singleSticker)
        origin_x += menuWidth
        }
        var i = 0
         for(_,v) in allStickersDic.sorted(by: { $0.0 < $1.0 }){
            let  singleSticker =    createButton(CGRect(x: origin_x,y: PADING,width: 35,height: 35), title: "", border: false,bgColor: false, textColor: textColorMedium)
            let singleStickerDictionary = v as! NSDictionary
            if singleStickerDictionary["image_icon"] != nil{
                let icon = singleStickerDictionary["image_icon"]
                let url = URL(string:icon as! String)
                if searchStickersArray.count > 0{
                    singleSticker.tag = i + 1
                }
                 else{
                    singleSticker.tag = i
                }
                singleSticker.addTarget(self, action: #selector(CommentsViewController.viewParticularSticker(_:)), for: UIControl.Event.touchUpInside)
                singleSticker.backgroundColor = UIColor.clear
                singleSticker.kf.setImage(with: url as URL?, for: .normal, placeholder: UIImage(named: "nophoto_diary_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                    
                })
            }
            i = i + 1
            stickerScrollView.addSubview(singleSticker)
            origin_x += menuWidth
        }
        stickerScrollView.contentSize = CGSize(width: origin_x,height: 40)
        stickerScrollView.bounces = false
        stickerScrollView.isUserInteractionEnabled = true
        stickerScrollView.showsVerticalScrollIndicator = false
        stickerScrollView.showsHorizontalScrollIndicator = false
        self.stickerScrollView.alwaysBounceHorizontal = true
        self.stickerScrollView.alwaysBounceVertical = false
        stickerScrollView.isDirectionalLockEnabled = true
        view.addSubview(stickerScrollView)
        
        
        addSticker = createButton(CGRect(x: view.bounds.width - 60,y: view.bounds.height - 40 - iphonXBottomsafeArea ,width: 60,height: 40), title: "\u{f067}", border: false,bgColor: false, textColor: UIColor.lightGray)
        addSticker.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZELarge)
        addSticker.tag = 10000
        addSticker.isHidden = true
        for ob in self.view.subviews{
            if ob.tag == 10000{
                ob.removeFromSuperview()
                break
            }
        }
        addSticker.addTarget(self, action: #selector(CommentsViewController.addRemoveStickers), for: UIControl.Event.touchUpInside)
        view.addSubview(addSticker)
    }
    
    // MARK:  To Add or Remove Sticker for this redirect to AddRemoveStickersViewController
    @objc func addRemoveStickers(){
        let presentedVC = AddRemoveStickersViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    //MARK:  View Particular Stickers after Click On Particular Sticker
    @objc func viewParticularSticker(_ sender: UIButton)
    {
        callStickerDirect = true
        indexOfSelectedSticker = sender.tag
        let width = (sender.tag) * Int(view.bounds.width)
        particularStickersView.setContentOffset(CGPoint(x : width, y :0), animated: true)
    }
    
    //MARK: Search Stickers
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        searchDictionary.removeAll(keepingCapacity: false)
        searchDictionary["search"] = searchBar.text
        searchBar.resignFirstResponder()
        getStickers()
    }
    
    // MARK: When we click on predefine search stickers
    @objc func searchParticularSticker(_ sender: UIButton){
        if let dic = searchStickersArray[sender.tag] as? NSDictionary{
            let keyword = dic["keyword"] as! String
            searchBar.text = keyword
            searchText = keyword
            searchDictionary.removeAll(keepingCapacity: false)
            searchDictionary["search"] = keyword
            searchBar.resignFirstResponder()
            getStickers()
        }
    }
    
    //MARK: After Search for showing results
    func afterSearchStickers(){
        searchedStickersView.isHidden = false
        searchedStickersView.frame = CGRect(x: 0, y: 50, width: view.bounds.width , height: self.particularStickersViewHeight - 50)
        searchedStickersView.delegate = self
        searchedStickersView.tag = 0
        searchedStickersView.backgroundColor =  tableViewBgColor
        particularStickersView.addSubview(searchedStickersView)
        if searchDictionary.count > 0 {
            searchBar.text = searchDictionary["search"]
            var origin_x1:CGFloat = PADING
            var origin_y1:CGFloat = PADING
            var menuWidth1 = CGFloat()
            var menuHeight1 = CGFloat()
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                menuWidth1 = (self.view.bounds.width/8) - 10
                menuHeight1 = (self.view.bounds.width/8) - 10
            }
            else{
                menuWidth1 = (self.view.bounds.width/4) - 10
                menuHeight1 = (self.view.bounds.width/4) - 10
            }
            
            for ob in self.searchedStickersView.subviews{
                ob.removeFromSuperview()
            }
            if searchedStickers.count > 0{
                for  i in 1...self.searchedStickers.count {
                    let  imageViewClick : UIButton!
                    if(UIDevice.current.userInterfaceIdiom == .pad)
                    {
                        imageViewClick = createButton(CGRect( x: origin_x1,y: origin_y1, width: (self.view.bounds.width/8) - 10, height: (self.view.bounds.width/8) - 10), title: "", border: false, bgColor: false, textColor: textColorLight)
                    }
                    else{
                        imageViewClick = createButton(CGRect( x: origin_x1,y: origin_y1, width: (self.view.bounds.width/4) - 10, height: (self.view.bounds.width/4) - 10), title: "", border: false, bgColor: false, textColor: textColorLight)
                    }
                    
                    var searchStickerView = createImageView(CGRect(x: 0, y: 0, width: imageViewClick.bounds.width, height: imageViewClick.bounds.height), border: true)
                    if let dic = searchedStickers[i - 1] as? NSDictionary{
                        if dic["image"] != nil{
                            let icon = dic["image"]
                            let url = URL(string:icon as! String)
                            if url != nil
                            {
                                searchStickerView.kf.indicatorType = .activity
                                (searchStickerView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                searchStickerView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                    
                                })
                                searchStickerView.layer.borderWidth = 0.0
                            }
                            
                        }
                        if dic["sticker_id"] != nil{
                            let stickerId = dic["sticker_id"] as? Int
                            imageViewClick.tag = stickerId!
                            imageViewClick.addTarget(self, action: #selector(CommentsViewController.postStickersUsingSearchedStickers(_:)), for: UIControl.Event.touchUpInside)
                        }
                        
                    }
                    searchedStickersView.addSubview(imageViewClick)
                    imageViewClick.addSubview(searchStickerView)
                    origin_x1 = menuWidth1 + origin_x1 + 10
                    if i%4 == 0{
                        origin_x1 = PADING
                        origin_y1 = menuHeight1 + origin_y1 + 10
                    }
                }
                if self.searchedStickers.count  % 4 != 0{
                    origin_y1 = menuHeight1 + origin_y1 + 10
                }
            }
            else
            {
                let noStickers = createLabel(CGRect(x: origin_x1,y: origin_y1,width: searchedStickersView.frame.size.width , height: 30), text: "", alignment: .center, textColor: UIColor.lightGray)
                noStickers.text = NSLocalizedString("No Stickers to Show",  comment: "")
                noStickers.font = UIFont(name: fontBold, size: FONTSIZELarge)
                searchedStickersView.addSubview(noStickers)
                origin_y1 =  origin_y1 + 30
            }
            searchedStickersView.alwaysBounceHorizontal = false
            searchedStickersView.alwaysBounceVertical = true
            searchedStickersView.contentSize = CGSize(width: view.bounds.width,height: origin_y1)
        }
    }
    
   // MARK:  Search bar delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == ""{
            searchedStickersView.isHidden = true
            //hideStickerView()
            //searchBar.resignFirstResponder()
            
        }
    }

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {

        if searchText != ""
        {
            searchBar.resignFirstResponder()
            searchText = ""
            return false
        }
        else
        {
            return true
        }
    }
    //MARK:- Hide Sticker
    func hideStickerView()
    {
        stickerScrollView.isHidden = true
        particularStickersView.isHidden = true
        addSticker.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.commentTextView.frame.origin.y += self.totalStickerViewHeight
            self.commentPost.frame.origin.y += self.totalStickerViewHeight
            //if emojiEnabled == true{
                if self.attachImage != nil{
                    self.attachImage.frame.origin.y += self.totalStickerViewHeight
                }
                if self.addedPhotos == true{
                    self.sampleImage.frame.origin.y += (self.totalStickerViewHeight )
                }
            //}
            if self.fromSingleFeed == true{
            self.scrollingComment.frame.size.height = self.view.bounds.height  - (self.ImageAttachmentHeight + self.commentTextViewHeight + self.navbarHeight)
            }
            else
            {
                
                self.commenttableView.frame.size.height = self.view.bounds.height  - (self.commentTabelHeight + self.ImageAttachmentHeight + self.commentTextViewHeight)
                
            }

            
        })
        
    }
    //MARK:- Show Sticker
    func showStickerView()
    {
        stickerScrollView.isHidden = false
        particularStickersView.isHidden = false
        addSticker.isHidden = false
        searchBar.resignFirstResponder()
        commenttableView.resignFirstResponder()
        UIView.animate(withDuration: 0.5, animations: {
            self.commentTextView.frame.origin.y -= self.totalStickerViewHeight
            self.commentPost.frame.origin.y -= self.totalStickerViewHeight
            //if emojiEnabled == true{
                if self.attachImage != nil{
                    self.attachImage.frame.origin.y -= self.totalStickerViewHeight
                }
                if self.addedPhotos == true{
                    self.sampleImage.frame.origin.y -= (self.totalStickerViewHeight )
                }
            //}
            
            if self.fromSingleFeed == true{
                self.scrollingComment.frame.size.height = self.view.bounds.height  - (self.totalStickerViewHeight +  self.ImageAttachmentHeight + self.commentTextViewHeight+self.navbarHeight)
                if total_Comments == 0 {
                    self.scrollingComment.setContentOffset(CGPoint(x: 0, y: self.scrollingComment.contentSize.height - self.scrollingComment.bounds.size.height), animated: true)
                }
            }
            else
            {
                

                self.commenttableView.frame.size.height = self.view.bounds.height  - (self.commentTabelHeight + self.totalStickerViewHeight +  self.ImageAttachmentHeight + self.commentTextViewHeight)
                if total_Comments == 0 {
                    self.noCommentIcon.frame.origin.y =  self.commentTextView.frame.origin.y  - self.noCommentIcon.frame.height - 20
                    self.noCommentTitle.frame.origin.y = self.commentTextView.frame.origin.y - self.noCommentTitle.frame.height - 20
                }
                
            }
        })
    }
    
    // Post Comment on Any Content
    @objc func postComment()
    {
        self.noCommentIcon.isHidden = true
        self.noCommentTitle.isHidden = true
        afterPost = true
        feedUpdate = true
        removeAlert()
        frndTagValue.removeAll()
        extraParameters.removeAll(keepingCapacity: false)
        var postingText = ""
        if stickerParameters.count > 0{
            postingText = ""
        }
        else if allPhotos.count > 0 && commentTextView.textColor == textColorMedium{
            postingText = ""
        }
        else
        {
            let firstChar = commentTextView.text!.first
            
            if (firstChar == " ")
            {
                let updateCommentText : String = self.commentTextView.text!
                self.commentTextView.text! = String(updateCommentText.dropFirst())
            }
            
            postingText = commentTextView.text!
        }
        postingText = Emoticonizer.emoticonizeString(postingText as NSString) as String
        var parameters = ["subject_id":String(likeCommentContent_id!), "subject_type": likeCommentContentType,"body":postingText,"send_notification" :"0"]
        if activityFeedComment == true
        {
            if actionId != nil
            {
                parameters["action_id"] = String(actionId)
            }
            else
            {
                if let feed = commentFeedArray[activityfeedIndex] as? NSDictionary{
                    if let action_id: Any = feed["action_id"]{
                        parameters["action_id"] = String(describing: action_id)
                        
                        actionId = "\(action_id)"
                        
                    }
                }
                
            }
            
        }
        else if contentActivityFeedComment == true
        {
            
            if let feed = commentFeedArray[activityfeedIndex] as? NSDictionary{
                if let action_id: Any = feed["action_id"]{
                    parameters["action_id"] = String(describing: action_id)
                    actionId = "\(action_id)"
                    
                }
            }
        }
        else if userActivityFeedComment == true {
            
            if let feed = commentFeedArray[activityfeedIndex] as? NSDictionary{
                if let action_id: Any = feed["action_id"]{
                    parameters["action_id"] = String(describing: action_id)
                    actionId = "\(action_id)"
                }
            }
        }
        
        // Post Comment Validaion
        commentTextView.resignFirstResponder()
        if stickerParameters.count > 0 {
            for(k,v) in stickerParameters{
                parameters["\(k)"] = v
            }
        }
        else
        {
            if addedPhotos == false{
                if commentTextView.textColor == textColorMedium{
                    showToast(message: NSLocalizedString("Please Enter Comment.",  comment: ""), controller: self)
                    return
                }
            }
        }
        
        self.commentPost.setTitleColor(UIColor.lightGray, for: UIControl.State())
        self.commentPost.isEnabled = false
        self.commentPost.alpha = 0.6
        if allPhotos.count>0{
            imagePost = true
            filePathArray.removeAll(keepingCapacity: false)
            filePathArray = saveFileInDocumentDirectory(allPhotos)
            if addedPhotos == true{
                dictionaryForImageToPost["image_profile"] = filePathArray[0]
            }
        }
        else
        {
            imagePost = false
        }
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            var url:String!
            // Start Spinner
            
//            spinner.center = self.view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            self.view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            commentTextView.isEditable = false
            if likeCommentContentType == "activity_action"{
                url = "advancedactivity/comment"
            }
            else{
                if enabledModules.contains("nestedcomment")
                {
                    url = "advancedcomments/comment"//"comment-create"
                }
                else
                {
                    url = "comment-create"
                }
            }
            
            // Create New Dictionary for comment posting
            let newDictionary:NSMutableDictionary = [:]
            
            newDictionary["author_image"] = "\(coverImage)"
            newDictionary["author_title"] = displayName
            newDictionary["comment_body"] = postingText
            newDictionary["comment_date"] = ""
            newDictionary["comment_id"] = ""
            newDictionary["user_id"] = "\(currentUserId)"
            newDictionary["delete"] = ""
            newDictionary["like"] = ""
            newDictionary["userTag"] = collect
            
            if stickerParameters.count > 0 {
                newDictionary["attachment"] = dictionaryForStickerImageStringToPost
                newDictionary["attachment_type"] = "sitereaction_sticker"
                self.stickerParameters.removeAll(keepingCapacity: false)
                self.dictionaryForStickerImageStringToPost.removeAll(keepingCapacity: false)
            }
            if addedPhotos == true{
                newDictionary["attachment"] = dictionaryForImageToPost
                newDictionary["attachment_type"] = "album_photo"
            }
            // Added define dictionary to allComments Dictionary
            self.allComments += Comment.loadCommentsfromDictionary(newDictionary)
            if(self.allComments.count == 0) && fromSingleFeed == false
            {
//                self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(commentIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
               
                if StickerPlugin == true{
//                    self.contentIcon.frame.origin.y = self.view.bounds.height/2-120
                    
                    
                }
               // self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                //self.view.addSubview(self.contentIcon)
               
                if StickerPlugin == true{
                   
                    
                }
               
                
            }
          
            
            // Set Updated Label Info
            var finalText = ""
            finalText = "\(total_Likes) \(likeIcon)"
            finalText += " / "
            finalText += "\(total_Comments) \(commentIcon)"
            total_Comments = total_Comments + 1
            if self.activityFeedComment == false {
                if info != nil{
                    info.text = finalText
                }
            }
            
            if total_Comments > 1{
                self.title =  String(format: NSLocalizedString("%d Comments ", comment: ""),total_Comments)
            }else if total_Comments == 1{
                self.title =  String(format: NSLocalizedString("%d Comment ", comment: ""),total_Comments)
            }
            else if total_Comments == 0{
                self.title =  String(format: NSLocalizedString("Comments ", comment: ""))
            }
            
            self.commentTextView.text = NSLocalizedString("Write a Comment...",  comment: "")
            self.commentTextView.textColor = textColorMedium
            self.commenttableView.reloadData()
            self.sampleImage.image = nil
            self.sampleImage.removeFromSuperview()
            if self.allComments.count > 0
            {
                
                self.commenttableView.layoutIfNeeded()
                if self.fromSingleFeed == true{
                    self.commenttableView.frame.size.height = self.commenttableView.contentSize.height + 30
                    self.scrollingComment.contentSize.height = getBottomEdgeY(inputView: self.commenttableView)
                    self.scrollToBottom()
                }
                else
                {
                  self.commenttableView.frame.size.height = self.view.bounds.height - (commentTabelHeight+self.commentTextViewHeight)
                    if self.allComments.count > 0
                    {
                        let indexPath = IndexPath(row: self.allComments.count - 1, section: 0)
                        self.commenttableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: true)
                    }
                }
                

            }
            if imagePost == true
            {
                parameters["post_attach"] = "1"
                parameters["attachment_type"] = "photo"
                var sinPhoto = true
                if allPhotos.count>1
                {
                    sinPhoto = false
                }
                postActivityForm(parameters as Dictionary<String, AnyObject> , url: url, filePath: filePathArray, filePathKey: "photo", SinglePhoto: sinPhoto){ (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                        for path in filePathArray{
                            removeFileFromDocumentDirectoryAtPath(path)
                        }
                        filePathArray.removeAll(keepingCapacity: false)
//                        listingDetailUpdate = true
//                        pageDetailUpdate = true
//                        reviewUpdate = true
                        self.addedPhotos = false
                        self.ImageAttachmentHeight = 0
                        //advanceVideoProfileUpdate = true
                        self.allPhotos.removeAll(keepingCapacity: false)
                        self.dictionaryForImageToPost.removeAll(keepingCapacity: false)
                        self.myLimit = self.allComments.count+1
                        if self.fromSingleFeed == true
                        {
                            // Check for activityIndex. In case of push notification activityIndex is coming nil
                            if self.activityfeedIndex != nil
                            {
                               self.updateCommentCount(feedindex: self.activityfeedIndex, key: "comment_count", updatedvalue: total_Comments,delete: 0,likecount: total_Likes)
                            }
                            
                        }
                        if ((self.activityFeedComment == true) || (self.contentActivityFeedComment == true) || (self.userActivityFeedComment == true)) {
                            //feedUpdate = true
                            //contentFeedUpdate = true
                        }
                        self.commentTextView.text = NSLocalizedString("Write a Comment...",  comment: "")
                        self.commentTextView.textColor = textColorMedium
                        self.sampleImage.image = nil
                        self.sampleImage.removeFromSuperview()
                        if msg{
                            if let comments = succeeded["body"] as? NSDictionary{
                                // Remove dictionary that we added
                                self.allComments.remove(at: self.allComments.count - 1)
                                // Get  Comment
                                self.commentTextView.isEditable = true
                                // ADD Dictionary that come after response in allComments
                                if comments["comment_id"] != nil {
                                    self.NotifyCommentId =  comments["comment_id"] as! Int
                                }

                                self.allComments +=  Comment.loadCommentsfromDictionary(comments)
                                self.commenttableView.reloadData()
                            }
                            if StickerPlugin == true{
                                self.stickers.isHidden = false
                                if self.stickers.tag == 1{
                                    self.stickerView(self.stickers)
                                }
                            }
                            if afterPost == true{
                                afterPost = false
                                DispatchQueue.main.async(execute: {
                                    soundEffect("post")
                                })
                            }
                            if self.allComments.count > 0
                            {
                                
                                let indexPath = IndexPath(row: self.allComments.count - 1, section: 0)
                                self.commenttableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
                                
                                
                            }
                            self.backEndNotify()
                            
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
                
                if CheckParameters.count > 0{
                    parameters.update(CheckParameters)
                }
                // Send Server Request for Post Comment
                post(parameters as! Dictionary<String, String>, url: url, method: "POST") { (succeeded, msg) -> () in
                    
                    // Stop Spinner
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            // On Success Update
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                            }
//                            listingDetailUpdate = true
//                            pageDetailUpdate = true
//                            reviewUpdate = true
//                            advGroupDetailUpdate = true
//                            advanceVideoProfileUpdate = true
                            self.collect.removeAll()
                            self.myLimit = self.allComments.count+1
                            if self.fromSingleFeed == true
                            {
                                // Check for activityIndex. In case of push notification activityIndex is coming nil
                                if self.activityfeedIndex != nil
                                {
                                    self.updateCommentCount(feedindex: self.activityfeedIndex, key: "comment_count", updatedvalue: total_Comments,delete: 0,likecount: total_Likes)
                                }
                                
                            }
                            if ((self.activityFeedComment == true) || (self.contentActivityFeedComment == true) || (self.userActivityFeedComment == true)) {
                               // feedUpdate = true
                               // contentFeedUpdate = true
                                
                            }
                            self.commentTextView.text = NSLocalizedString("Write a Comment...",  comment: "")
                            self.commentTextView.textColor = textColorMedium
                            
                            if succeeded["body"] != nil{
                                // Remove dictionary that we added
                                self.allComments.remove(at: self.allComments.count - 1)
                                // Get  Comment
                                self.commentTextView.isEditable = true
                                if let comments = succeeded["body"] as? NSDictionary{
                                    // ADD Dictionary that come after response in allComments
                                    if comments["comment_id"] != nil {
                                        self.NotifyCommentId =  comments["comment_id"] as! Int
                                    }

                                    self.allComments +=  Comment.loadCommentsfromDictionary(comments)
                                }
                                
                                self.commenttableView.reloadData()
                                if StickerPlugin == true{
                                    self.stickers.isHidden = false
                                    if self.stickers.tag == 1{
                                        self.stickerView(self.stickers)
                                    }
                                }
                                if afterPost == true{
                                    afterPost = false
                                    DispatchQueue.main.async(execute: {
                                        soundEffect("post")
                                    })
                                    
                                }
                                
//                                if self.allComments.count > 0
//                                {
//                                    let bottomOffset = CGPoint(x: 0, y: self.scrollingComment.contentSize.height - self.scrollingComment.bounds.size.height + self.scrollingComment.contentInset.bottom)
//                                    self.scrollingComment.setContentOffset(bottomOffset, animated: false)
//
//
//
//                                }
                                
                            }
                            self.backEndNotify()
                            
                        }else{
                            // Handle Server Side Error
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                            }
                        }
                        
                    })
                }
            }
            
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    func backEndNotify(){
        var parameters = ["subject_id":String(likeCommentContent_id), "subject_type": likeCommentContentType,"comment_id": String(NotifyCommentId)]
        var url = "add-comment-notifications"
        
        if activityFeedComment == true
        {
            if actionId != nil
            {
                parameters["action_id"] = String(actionId)
                url =  "advancedactivity/add-comment-notifications"
            }
        }
        
        post(parameters as! Dictionary<String, String>, url: url, method: "POST") { (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                
                
            })
        }
        
    }
    
    // Update Comments (Like & Delete Comment with Comment ID)
    func updateComments(_ parameter: NSDictionary , url : String , comment_Id:Int, isReloadTableCommet : Bool){
        removeAlert()
       
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            if isReloadTableCommet == false
            {
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
                self.view.isUserInteractionEnabled = false
            }
            
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            if self.fromActivityFeed == true && actionId != nil{
                
                dic["action_id"] = String(actionId)
                
            }
            var method : String
            
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            
            post(dic, url: url, method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    if isReloadTableCommet == false
                    {
                        activityIndicatorView.stopAnimating()
                        if total_Comments == 0 {
                            self.noCommentIcon.isHidden = false
                            self.noCommentTitle.isHidden = false
                        }
                        self.view.isUserInteractionEnabled = true
                        // On Success Update All Comments
                        feedUpdate = true
                        for (index,value) in self.allComments.enumerated(){
                            if url.range(of: "delete") != nil{
                                self.commenttableView.reloadData()
                                if self.allComments.count > 0
                                {
                                    if self.fromSingleFeed == false{
                                        let indexPath = IndexPath(row: self.allComments.count - 1, section: 0)
                                        self.commenttableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
                                    }
                                }
                            }
                            else{
                                
                                if value.comment_id == comment_Id{
                                    
                                    let tempOldLikeDictionary :NSMutableDictionary = [:]
                                    
                                    if url.range(of: "unlike") != nil{
                                        tempOldLikeDictionary["isLike"] = 0
                                        tempOldLikeDictionary["label"] = "Like"
                                        tempOldLikeDictionary["url"] = "like"
                                        tempOldLikeDictionary["name"] = "like"
                                        tempOldLikeDictionary["urlParams"] = value.like["urlParams"] as! NSDictionary
                                        
                                        
                                    }else{
                                        tempOldLikeDictionary["isLike"] = 1
                                        tempOldLikeDictionary["label"] = "Unlike"
                                        tempOldLikeDictionary["url"] = "unlike"
                                        tempOldLikeDictionary["name"] = "unlike"
                                        tempOldLikeDictionary["urlParams"] = value.like["urlParams"] as! NSDictionary
                                        
                                    }
                                    
                                    let newDictionary:NSMutableDictionary = [:]
                                    
                                    newDictionary["author_image"] = value.author_image
                                    newDictionary["author_title"] = value.author_title
                                    newDictionary["comment_body"] = value.comment_body
                                    newDictionary["comment_date"] = value.comment_date
                                    newDictionary["comment_id"] = value.comment_id
                                    newDictionary["user_id"] = value.user_id
                                    
                                    if value.stickerImage != nil{
                                        newDictionary["attachment"] = value.stickerImage
                                    }
                                    
                                    if value.attachmentType != nil{
                                        newDictionary["attachment_type"] = value.attachmentType
                                    }
                                    
                                    if url.range(of: "unlike") != nil{
                                        if(value.likeCount != nil){
                                            newDictionary["like_count"] = value.likeCount - 1
                                        }
                                    }
                                    else{
                                        if(value.likeCount != nil){
                                            newDictionary["like_count"] = value.likeCount + 1
                                        }
                                        
                                    }
                                    
                                    if let _ = value.delete{
                                        newDictionary["delete"] = value.delete
                                    }
                                    
                                    newDictionary["like"] = tempOldLikeDictionary
                                    
                                    var newData = Comment.loadCommentsfromDictionary(newDictionary)
                                    self.allComments[index] = newData[0] as Comment
                                    
                                    self.commenttableView.reloadData()
                                    if self.allComments.count > 0
                                    {
                                        if self.fromSingleFeed == false{
                                            let indexPath = IndexPath(row: self.allComments.count - 1, section: 0)
                                            self.commenttableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.top, animated: true)
                                        }
                                    }
                                    
                                }
                            }
                            
                            
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            //  displayAlert("Info", network_status_msg , timer: false)
            showToast(message: network_status_msg, controller: self)
        }
        
        
    }
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    //  set Dynamic Height For Every Cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 22{
            return 50
        }
        else{
            
            if dynamicHeight[indexPath.row] != nil{
                return dynamicHeight[indexPath.row]!
            }
            else
            {
                return 45
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        if tableView.tag == 22{
            return 50
        }
        else{
            
            if dynamicHeight[indexPath.row] != nil{
                return dynamicHeight[indexPath.row]!
            }
            else
            {
                return 45
            }
        }
    }
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if ((limit*pageNumber < total_Comments) && (extraParameters.count > 0)){
            return 80
        }else{
            return 0.00001
        }
    }
    
    // Set Table Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 22{
            return  suggestedHashTags.count
        }
        else{
            return allComments.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 0.001
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView.tag == 22
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            
            
            if let response = suggestedHashTags[(indexPath as NSIndexPath).row] as? NSDictionary {
                cell.labTitle.frame.size.width = (UIScreen.main.bounds.width - (cell.imgUser.bounds.width + 15))
                // Set Name People who Likes Content
                cell.labTitle.text = response["label"] as? String
                cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.labTitle.sizeToFit()
                
                dynamicHeightValue = cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5
                if dynamicHeightValue < (cell.imgUser.bounds.height + 10){
                    dynamicHeightValue = (cell.imgUser.bounds.height + 10)
                }
                cell.imgUser.frame.size.width = 40
                cell.imgUser.frame.size.height = 40
                cell.imgUser.layer.cornerRadius = 20
                cell.imgUser.layer.masksToBounds = true
                // Set Frnd Image
                // Set Feed Owner Image
                if let imgUrl = response["image_icon"] as? String{
                    let url = URL(string:imgUrl)
                    if url != nil
                    {
                        cell.imgUser.image = nil
                        cell.imgUser.kf.indicatorType = .activity
                        (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.imgUser.kf.setImage(with: url as URL?, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                    }
                    
                }
                
                if let id = response["id"] as? Int{
                    if frndTag[id] != nil{
                        cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }else{
                        cell.accessoryType = UITableViewCell.AccessoryType.none
                    }
                }
                
            }
            return cell
        }
        else{
            
            var userId : Int!
            
            let cellIdentifier = String(indexPath.section) + "-" + String(indexPath.row)
            commenttableView.register(CommentTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CommentTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            let comment = allComments[(indexPath as NSIndexPath).row]
            cell.author_title.frame = CGRect(x: cell.author_photo.bounds.width+10, y: 5, width: self.view.bounds.width-(cell.author_photo.bounds.width+15), height: 100)
            cell.author_title.delegate = self
            cell.author_title.text = comment.author_title
            
            let length =  NSString(string: comment.author_title!).length
            if(comment.user_id != nil){
                userId = comment.user_id as Int
            }
            
            var likeTotalCount:Int!
            if((comment.likeCount) != nil){
                likeTotalCount = comment.likeCount as Int
            }
            
            if(comment.user_id != nil){
                cell.author_title.addLink(toTransitInformation: [ "type" : "user", "user_id" : userId  ], with:NSMakeRange(0,length))
            }
            cell.author_title.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.author_title.sizeToFit()
            
            if(comment.user_id != nil){
                cell.imageButton.addTarget(self, action: #selector(CommentsViewController.showProfile(_:)), for: UIControl.Event.touchUpInside)
                cell.imageButton.tag = userId
            }
            
            var nxtLabelHeight : CGFloat = 5
            
            // Set Comment
            cell.comment_body.frame = CGRect(x: cell.author_photo.bounds.width+10, y: cell.author_title.bounds.height + 10, width: self.view.bounds.width-(cell.author_photo.bounds.width+15), height: 100)
            var addMore = false
            
            let linkColor = UIColor.blue
            
            cell.comment_body.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]//[kCTForegroundColorAttributeName as AnyHashable : linkColor.cgColor,kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: true)]
            cell.comment_body.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue

            
            cell.comment_body.delegate = self
            var commentBody = ""
            if comment.comment_body != nil{
                
                commentBody = String(describing: comment.comment_body!)
                delay(0) {
                    commentBody = commentBody.html2String
                }
                commentBody = Emoticonizer.emoticonizeString(commentBody as NSString) as String
                if commentBody.length > descriptionTextLimit{
                    if comment.comment_id != nil {
                        if !fullDescriptionCell.contains(comment.comment_id!){
                            commentBody = (comment.comment_body! as! NSString).substring(to: descriptionTextLimit-3)
                            commentBody += NSLocalizedString("... more",  comment: "")
                        }else{
                            commentBody += NSLocalizedString(" ... less",  comment: "")
                        }
                        addMore = true
                    }
                }
            }
            
            cell.comment_body.isHidden = false
            cell.sticker.isHidden = true
            cell.comment_body.delegate = self
            
            // Set Feed Tittle & Description Link
            cell.comment_body.setText(commentBody as NSString, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZEMedium, nil)
                
                let myString = commentBody
                //            myString.remove(at: myString.startIndex)
                //            commentBody = myString
                
                let firstChar = myString.first
                if (firstChar == " ")
                {
                    delay(0) {
                        let abc : String = commentBody.html2String
                        
                        commentBody = String(abc.dropFirst())
                    }
                   
                    
                }
                
                
                if let tags = comment.tags{
                    if tags.count > 0{
                        for i in 0 ..< tags.count {
                            if let tag = ((tags[i] as! NSDictionary))["resource_name"] as? String{
                                //let length = mutableAttributedString?.length
                                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: commentBody)
                                let length = attrString.length
                                var range = NSMakeRange(0, length)
                                while(range.location != NSNotFound)
                                {
                                    range = (commentBody as NSString).range(of:tag, options: NSString.CompareOptions(), range: range)
                                    if(range.location != NSNotFound) {
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                                        range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                                        
                                    }
                                }
                                
                            }
                        }
                    }
                }
                
                
                
                
                let range1 = (commentBody as NSString).range(of: NSLocalizedString(" ... less",  comment: ""))
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range1)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)
                
                let range2 = (commentBody as NSString).range(of: NSLocalizedString("... more",  comment: ""))
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range2)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range2)
                
                
                // TODO: Clean this up..
                return mutableAttributedString
            })
            
            if let tags = comment.tags{
                
                if tags.count > 0{
                    
                    for i in 0 ..< tags.count {
                        
                        if let tag = ((tags[i] as! NSDictionary))["resource_name"] as? String{
                            let tag_id = ((tags[i] as! NSDictionary))["resource_id"] as? Int
                            let attrString: NSMutableAttributedString = NSMutableAttributedString(string: commentBody)
                            
                            let length = attrString.length
                            var range = NSMakeRange(0, length)
                            while(range.location != NSNotFound)
                            {
                                range = (commentBody as NSString).range(of: tag, options: NSString.CompareOptions(), range: range)
                                if(range.location != NSNotFound) {
                                    cell.comment_body.addLink(toTransitInformation: ["user_id" : tag_id as Any, "type" : "user"], with:range)
                                    range = NSMakeRange(range.location + range.length, length - (range.location + range.length));
                                    
                                }
                            }
                            
                            
                        }
                        
                    }
                    
                }
                
            }
            
            
            if addMore {
                // cell.moreDescription.isHidden == true
                if !fullDescriptionCell.contains(comment.comment_id!){
                    let range = (commentBody as NSString).range(of: NSLocalizedString("... more",  comment: ""))
                    cell.comment_body.addLink(toTransitInformation: ["id" :comment.comment_id!, "type" : "more","index" : (indexPath as NSIndexPath).row], with:range)
                }
                else{
                    let range1 = (commentBody as NSString).range(of: NSLocalizedString(" ... less",  comment: ""))
                    cell.comment_body.addLink(toTransitInformation: ["id" : comment.comment_id!, "type" : "less", "index" : (indexPath as NSIndexPath).row], with:range1)
                }
            }
            cell.comment_body.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.comment_body.sizeToFit()
            cell.comment_body.frame.size.height = cell.comment_body.frame.size.height + 5
            cell.imageviewButton.isHidden = true
            nxtLabelHeight = getBottomEdgeY(inputView: cell.comment_body) + 5
            
            //sticker if any then set sticker image in cell
            if (comment.stickerImage != nil){
                let image = comment.stickerImage?["image_profile"] as? String
                
                if comment.attachmentType == "album_photo"{
                    self.imageviewUrl.append(image!)
                    cell.imageviewButton.tag = i
                    i += 1
                    cell.imageviewButton.isHidden = false
                    cell.sticker.frame = CGRect(x: cell.author_photo.bounds.width+10, y: nxtLabelHeight, width: 200, height: 200)
                    cell.imageviewButton.frame = CGRect(x: cell.author_photo.bounds.width+10, y: nxtLabelHeight, width: 200, height: 200)
                    cell.imageviewButton.addTarget(self, action: #selector(lightBox(_:)), for: .touchUpInside)
                    cell.imageviewButton.backgroundColor = UIColor.clear
                }
                else{
                    cell.sticker.frame = CGRect(x: cell.author_photo.bounds.width+10, y: nxtLabelHeight, width: 100, height: 100)
                }
            
                let imageUrl = comment.stickerImage?["image_profile"] as? String
                let url = URL(string:image!)
                let image1    = UIImage(contentsOfFile: imageUrl!)
                if image1 != nil{
                    cell.sticker.image = image1
                }
                else{
                    cell.sticker.kf.indicatorType = .activity
                    (cell.sticker.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.sticker.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
                cell.sticker.isHidden = false
                nxtLabelHeight = getBottomEdgeY(inputView: cell.sticker) + 5
            }
            
            
            // Set Posted Date
            if comment.comment_date != ""{
                if let postedDate = comment.comment_date{
                    let postedOn = dateDifference(postedDate)
                    cell.comment_date.frame.origin.y = nxtLabelHeight
                    cell.comment_date.text = "\(postedOn)"
                }
            }
            else{
                cell.comment_date.frame.origin.y = nxtLabelHeight
                cell.comment_date.text = NSLocalizedString("Posting...", comment: "")
            }
            
            cell.comment_date.sizeToFit()
            
            let commentDateVerticalCenter = (cell.comment_date.frame.origin.y) + (cell.comment_date.frame.height)/2
            
            cell.likeDot.sizeToFit()
            cell.likeDot.frame.origin.x = getRightEdgeX(inputView: cell.comment_date) + 5
            cell.likeDot.frame.origin.y = commentDateVerticalCenter - (cell.likeDot.frame.height)/2
            
            // Set Comment Owner Image
            let url = URL(string:comment.author_image! )
            if url != nil{
                cell.author_photo.kf.setImage(with: url as URL?, placeholder: UIImage(named: "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                    
                })
            }
            
            // Set Comment Delete on Response
            cell.delete.isHidden = true
            cell.deleteDot.isHidden = true
            if let canDelete = comment.delete{
                cell.delete.addTarget(self, action:#selector(CommentsViewController.deleteComment(_:)), for: .touchUpInside)
                if let name = canDelete["label"] as? String{
                    
                    cell.delete.setTitle("\(name)", for: UIControl.State())
                    cell.delete.sizeToFit()
                    cell.deleteDot.sizeToFit()
                    //                cell.delete.frame.origin.y = nxtLabelHeight
                    cell.delete.frame.origin.y = commentDateVerticalCenter - (cell.delete.frame.height)/2
                    //                cell.deleteDot.frame.origin.y = nxtLabelHeight + 2
                    cell.deleteDot.frame.origin.y = commentDateVerticalCenter - (cell.deleteDot.frame.height)/2
                    cell.deleteDot.isHidden = false
                    cell.delete.isHidden = false
                    cell.delete.tag = (indexPath as NSIndexPath).row
                    
                }
                
                
            }
            
            // Set Comment Like on Response
            cell.like.isHidden = true
            cell.likeDot.isHidden = true
            if let commentLike = comment.like{
                cell.like.addTarget(self, action:#selector(CommentsViewController.updateComment(_:)), for: .touchUpInside)
                if let name = commentLike["label"] as? String{
                    cell.likeDot.frame.origin.y = nxtLabelHeight + 2
                    cell.likeDot.frame.origin.x = getRightEdgeX(inputView: cell.comment_date) + 5
                    cell.likeDot.frame.origin.y = commentDateVerticalCenter - (cell.likeDot.frame.height)/2
                    cell.like.setTitle(NSLocalizedString(String(name),  comment: ""), for: UIControl.State())
                    cell.like.sizeToFit()
                    //                cell.like.frame.origin.y = nxtLabelHeight
                    cell.like.frame.origin.y = commentDateVerticalCenter - (cell.like.frame.height)/2
                    cell.like.frame.origin.x = getRightEdgeX(inputView: cell.likeDot) + 5
                    
                    
                    if((comment.likeCount) != nil && comment.likeCount>0){
                        
                        cell.likeCountDot.isHidden = false
                        cell.likeCountDot.sizeToFit()
                        //                    cell.likeCountDot.frame.origin.y = nxtLabelHeight + 2
                        cell.likeCountDot.frame.origin.y = commentDateVerticalCenter - (cell.likeCountDot.frame.height)/2
                        cell.likeCountDot.frame.origin.x = getRightEdgeX(inputView: cell.like) + 5
                        
                        cell.unlike.isHidden = false
                        let tempLikeCountString = ("\(likeIcon) " + String(likeTotalCount)).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        cell.unlike.setTitle(tempLikeCountString, for: UIControl.State())
                        cell.unlike.sizeToFit()
                        //                    cell.unlike.frame.origin.y = nxtLabelHeight
                        cell.unlike.frame.origin.y = commentDateVerticalCenter - (cell.unlike.frame.height)/2
                        cell.unlike.frame.origin.x = getRightEdgeX(inputView: cell.likeCountDot) + 5
                        cell.unlike.addTarget(self, action:#selector(CommentsViewController.showCommentLikes(_:)), for: .touchUpInside)
                        cell.unlike.tag = (indexPath as NSIndexPath).row
                        
                        if  (UIDevice.current.userInterfaceIdiom == .phone){
                            cell.deleteDot.frame.origin.x = getRightEdgeX(inputView: cell.unlike) + 5
                            cell.delete.frame.origin.x = getRightEdgeX(inputView: cell.deleteDot) + 5
                            
                        }else{
                            cell.deleteDot.frame.origin.x = getRightEdgeX(inputView: cell.unlike) + 5
                            cell.delete.frame.origin.x = getRightEdgeX(inputView: cell.deleteDot) + 5
                            
                        }
                    }
                    else{
                        cell.unlike.isHidden = true
                        cell.likeCountDot.isHidden = true
                        if cell.delete.isHidden == false && cell.likeCountDot.isHidden == true {
                            
                            if  (UIDevice.current.userInterfaceIdiom == .phone){
                                cell.deleteDot.frame.origin.x = getRightEdgeX(inputView: cell.like) + 5
                                cell.delete.frame.origin.x = getRightEdgeX(inputView: cell.deleteDot) + 5
                                
                            }else{
                                cell.deleteDot.frame.origin.x = getRightEdgeX(inputView: cell.like) + 5
                                cell.delete.frame.origin.x = getRightEdgeX(inputView: cell.deleteDot) + 5
                                
                            }
                            
                            
                        }
                    }
                    
                    cell.likeDot.isHidden = false
                    cell.like.isHidden = false
                    cell.like.tag = (indexPath as NSIndexPath).row//comment.comment_id!
                }
                
            }
            
            dynamicHeight[indexPath.row] = nxtLabelHeight + cell.comment_date.bounds.height + 5
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView.tag == 22
        {
            
            if let response = suggestedHashTags[(indexPath as NSIndexPath).row] as? NSDictionary {
                
                frndTagValue[(response["guid"] as? String)!] = response["label"] as? String
                selectedString = ""
                selectedString = (response["label"] as? String)!
                for _ in 0 ..< frndTagValue.count{
                    let dictionaryA = [
                        "resource_name": "\(response["label"] as! String)",
                        "resource_id": (response["id"] as! Int),
                        
                        ] as [String : Any]
                    
                    collect.append(dictionaryA as NSDictionary)
                }
                
                
            }
            
            addFriendTag()
            self.suggestedHashTags.removeAll(keepingCapacity: false)
            self.showUserTableView.reloadData()
            self.showUserTableView.isHidden = true
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: frndTagValue, options:  [])
                let  finalString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
                
                
                var tempDic = [String:AnyObject]()
                tempDic.updateValue(finalString as AnyObject, forKey: "tag")
                let Replacefinal = finalString.replacingOccurrences(of: "{", with: "")
                let finalReplace = Replacefinal.replacingOccurrences(of: "}", with: "")
                let finalReplace1 = finalReplace.replacingOccurrences(of: "\"", with: "")
                let finalReplace2 = finalReplace1.replacingOccurrences(of: ",", with: "&")
                let finalReplace3 = finalReplace2.replacingOccurrences(of: ":", with: "=")
                let finalValue = "\"\(finalReplace3)\""
                let templocationString = "{\"tag\":"
                let locationString = templocationString + finalValue + "}"
                CheckParameters["composer"] = locationString
                // success ...
            } catch _ as NSError {
                // failure
                //print("Fetch failed: \(error.localizedDescription)")
            }
        }
    }
    
    func addFriendTagText(){
        let myString = commentTextView.text
        commentTextView.text = myString
        let attrStr = NSMutableAttributedString(string: commentTextView.text)
        let inputLength = attrStr.string.count
        let searchString = selectedString
        commentTextView.textColor = textColorDark
        
        selectArray.append(searchString)
        
        for i in 0 ..< selectArray.count {
            var range = NSRange(location: 0, length: attrStr.length)
            
            while (range.location != NSNotFound) {
                let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZEMedium, nil)
                range = (attrStr.string as NSString).range(of: selectArray[i], options: [], range: range)
                if (range.location != NSNotFound) {
                    attrStr.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: NSRange(location: range.location, length: selectArray[i].length))
                    attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: textColorDark, range: NSRange(location: range.location, length: selectArray[i].length))
                    range = NSRange(location: range.location + range.length, length: inputLength - (range.location + range.length))
                    commentTextView.attributedText = attrStr
                }
            }
        }
        
    }
    
    func addFriendTag(){
        let myString = commentTextView.text
        let myStringWithoutLastWord = myString?.components(separatedBy: " ").dropLast().joined(separator: " ")
        commentTextView.text = myStringWithoutLastWord
        commentTextView.text.append(" " + selectedString)
        commentTextView.becomeFirstResponder()
        let attrStr = NSMutableAttributedString(string: commentTextView.text)
        let inputLength = attrStr.string.count
        let searchString = selectedString
        selectArray.append(searchString)
        commentTextView.font = UIFont(name: fontName, size: FONTSIZELarge )
        for i in 0 ..< selectArray.count {
            var range = NSRange(location: 0, length: attrStr.length)
            
            while (range.location != NSNotFound) {
                range = (attrStr.string as NSString).range(of: selectArray[i], options: [], range: range)
                if (range.location != NSNotFound) {
                    let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZEMedium, nil)
                    attrStr.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: NSRange(location: range.location, length: selectArray[i].length))
                    attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: textColorDark, range: NSRange(location: range.location, length: selectArray[i].length))
                    range = NSRange(location: range.location + range.length, length: inputLength - (range.location + range.length))
                    commentTextView.attributedText = attrStr
                }
            }
        }
        
    }
    
    
    // Like Particular Comment
    @objc func updateComment(_ sender: UIButton){
        
        let comment = allComments[sender.tag]
        //print(comment)
        if let commentLike = comment.like{
            if self.fromActivityFeed == true{
                if commentLike["isLike"]! as! Int == 0{
                    updateLikeUnlikeUIInComments(value: comment, isLike: true, index: sender.tag)
                    updateComments(commentLike["urlParams"] as! NSDictionary , url: "advancedactivity/like", comment_Id: comment.comment_id!, isReloadTableCommet: true)
                }
                else if commentLike["isLike"] as! Int == 1{
                    updateLikeUnlikeUIInComments(value: comment, isLike: false, index: sender.tag)
                    updateComments(commentLike["urlParams"] as! NSDictionary , url: "advancedactivity/unlike", comment_Id: comment.comment_id!, isReloadTableCommet: true)
                }
            }
            else{
                updateComments(commentLike["urlParams"] as! NSDictionary , url: commentLike["url"] as! String, comment_Id: comment.comment_id!, isReloadTableCommet: false)
            }
            
        }
        
        
    }
    
    func updateLikeUnlikeUIInComments(value : Comment, isLike : Bool, index : Int){
        
        let tempOldLikeDictionary :NSMutableDictionary = [:]
        
        if isLike == false{
            tempOldLikeDictionary["isLike"] = 0
            tempOldLikeDictionary["label"] = "Like"
            tempOldLikeDictionary["url"] = "like"
            tempOldLikeDictionary["name"] = "like"
            tempOldLikeDictionary["urlParams"] = value.like["urlParams"] as! NSDictionary
            
            
        }else{
            tempOldLikeDictionary["isLike"] = 1
            tempOldLikeDictionary["label"] = "Unlike"
            tempOldLikeDictionary["url"] = "unlike"
            tempOldLikeDictionary["name"] = "unlike"
            tempOldLikeDictionary["urlParams"] = value.like["urlParams"] as! NSDictionary
            
        }
        
        let newDictionary:NSMutableDictionary = [:]
        
        newDictionary["author_image"] = value.author_image
        newDictionary["author_title"] = value.author_title
        newDictionary["comment_body"] = value.comment_body
        newDictionary["comment_date"] = value.comment_date
        newDictionary["comment_id"] = value.comment_id
        newDictionary["user_id"] = value.user_id
        
        if value.stickerImage != nil{
            newDictionary["attachment"] = value.stickerImage
        }
        
        if value.attachmentType != nil{
            newDictionary["attachment_type"] = value.attachmentType
        }
        
        if isLike == false{
            if(value.likeCount != nil){
                newDictionary["like_count"] = value.likeCount - 1
            }
        }
        else{
            if(value.likeCount != nil){
                newDictionary["like_count"] = value.likeCount + 1
            }
            
        }
        
        if let _ = value.delete{
            newDictionary["delete"] = value.delete
        }
        
        newDictionary["like"] = tempOldLikeDictionary
        
        var newData = Comment.loadCommentsfromDictionary(newDictionary)
        self.allComments[index] = newData[0] as Comment
        self.commenttableView.reloadData()
        
    }
    
    // Delete Particular Comment
    @objc func deleteComment(_ sender: UIButton){
        let urlDelete = "advancedactivity/delete"
        let comment = allComments[sender.tag]
        if let commentDelete = comment.delete
        {
            let alertController = UIAlertController(title: NSLocalizedString("Delete Comment", comment: ""), message:
                NSLocalizedString("Are you sure that you want to delete this comment?", comment: ""), preferredStyle: UIAlertController.Style.alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: UIAlertAction.Style.destructive,handler: { action -> Void in
                if self.fromActivityFeed == true{
                    // Set Updated Label Info
                    var finalText = ""
                    finalText =  singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: total_Likes)
                    total_Comments = total_Comments - 1
                    // self.title = singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: total_Comments)
                
                if total_Comments > 1{
                    self.title =  String(format: NSLocalizedString("%d Comments ", comment: ""),total_Comments)
                }else if total_Comments == 1{
                    self.title =  String(format: NSLocalizedString("%d Comment ", comment: ""),total_Comments)
                }
                else if total_Comments == 0 && self.fromSingleFeed{
                    self.scrollingComment.contentSize.height = self.commentTabelHeight + self.noCommentIcon.frame.height + self.noCommentTitle.frame.height + 20
                    self.scrollingComment.setContentOffset(CGPoint(x: 0, y: self.scrollingComment.contentSize.height - self.scrollingComment.bounds.size.height), animated: true)
                    if self.fromNotification || self.isComingFromTikTokPage {
                        self.noCommentIcon.frame.origin.y =  self.scrollingComment.contentSize.height - self.noCommentIcon.frame.height - self.noCommentTitle.frame.height
                        self.noCommentTitle.frame.origin.y = getBottomEdgeY(inputView:  self.noCommentIcon)
                    }
                }
                if total_Comments < 0 && self.fromSingleFeed == false {
                    self.noCommentIcon.isHidden = false
                    self.noCommentTitle.isHidden = false
                }
                    
                    finalText +=  singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: total_Comments)
                    
                    if ((self.activityFeedComment == true) || (self.contentActivityFeedComment == true) || (self.userActivityFeedComment == true)){
                        self.updateActivityFeed(total_Likes, commentCount: total_Comments)
                    }else{
                        if info != nil{
                            info.text = finalText
                        }
                    }
                    
                  
                    
                    let indexPath = IndexPath(row: sender.tag, section: 0)
                    self.commenttableView.beginUpdates()
                    self.allComments.remove(at: sender.tag)
                    self.commenttableView.deleteRows(at: [indexPath], with: .fade)
                    self.commenttableView.endUpdates()
                    //self.feedObj.tableView.reloadData()
                    if(self.allComments.count == 0) && self.fromSingleFeed == false
                    {
//                        self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(commentIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                       
                        if StickerPlugin == true{
//                            self.contentIcon.frame.origin.y = self.view.bounds.height/2-120
                          
                        }
//                        self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
//                        self.view.addSubview(self.contentIcon)
                    
                        if StickerPlugin == true{
//                            self.info1.frame.origin.y = self.view.bounds.height/2-40
                        }
   
                    }
                    
                    self.updateComments(commentDelete["urlParams"] as! NSDictionary , url: urlDelete, comment_Id: comment.comment_id!, isReloadTableCommet: false)
                }
                else{
                    // Set Updated Label Info
                    var finalText = ""
                    finalText =  singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: total_Likes)
                    total_Comments = total_Comments - 1
                    // self.title = singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: total_Comments)
                    if total_Comments > 1{
                        self.title =  String(format: NSLocalizedString("%d Comments ", comment: ""),total_Comments)
                    }else if total_Comments == 1{
                        self.title =  String(format: NSLocalizedString("%d Comment ", comment: ""),total_Comments)
                    }
                    else if total_Comments == 0{
                       self.title =  String(format: NSLocalizedString("Comments ", comment: ""))
                    }
                    finalText +=  singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: total_Comments)
                    
                    if ((self.activityFeedComment == true) || (self.contentActivityFeedComment == true) || (self.userActivityFeedComment == true)){
                        self.updateActivityFeed(total_Likes, commentCount: total_Comments)
                    }else{
                        if info != nil{
                            info.text = finalText
                        }
                    }
              
                    
                    let indexPath = IndexPath(row: sender.tag, section: 0)
                    self.commenttableView.beginUpdates()
                    self.allComments.remove(at: sender.tag)
                    self.commenttableView.deleteRows(at: [indexPath], with: .fade)
                    self.commenttableView.endUpdates()
                    
                    if(self.allComments.count == 0) && self.fromSingleFeed == false
                    {
//                        self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(commentIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                        if StickerPlugin == true{
//                            self.contentIcon.frame.origin.y = self.view.bounds.height/2-120
                        }
//                        self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
//                        self.view.addSubview(self.contentIcon)
                        
                        if StickerPlugin == true{
                        }
                    }
                    
                    self.updateComments(commentDelete["urlParams"] as! NSDictionary , url: commentDelete["url"] as! String, comment_Id: comment.comment_id!, isReloadTableCommet: false)
                }
                           if self.fromSingleFeed == true
                {
                    if total_Comments == 0
                    {
                        print(self.commenttableView.frame.size.height)
                        self.commenttableView.frame.size.height = self.commenttableView.contentSize.height
                        print("self.commenttableView.frame.size.height \(self.commenttableView.frame.size.height)")
                        self.commentTextView.becomeFirstResponder()
                        
//                        self.feedObj.tableView.frame.size.height = self.feedObj.tableView.contentSize.height
//                        self.commentTabelHeight = self.feedObj.tableView.frame.size.height - 72
//
//                        self.commenttableView.frame.size.height = self.commenttableView.contentSize.height
//
//                           self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight
////                        self.scrollingComment.contentSize.height = getBottomEdgeY(inputView: self.commenttableView)
//                        self.scrollToBottom()
                    }
//                    else
//                    {
//                        self.commenttableView.frame.size.height = self.commenttableView.contentSize.height + 30
//                        self.scrollingComment.contentSize.height = getBottomEdgeY(inputView: self.commenttableView)
//                        self.scrollToBottom()
//                    }
                    
                    
                    // Check for activityIndex. In case of push notification activityIndex is coming nil
                    if self.activityfeedIndex != nil
                    {
                        self.updateCommentCount(feedindex: self.activityfeedIndex, key: "comment_count", updatedvalue: total_Comments,delete: 1,likecount: total_Likes)
                    }
                  
                }
            }
            ))
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel",comment: ""), style: UIAlertAction.Style.cancel,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        arrowView.isHidden = true
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        if scrollViewEmoji.isDescendant(of: (UIApplication.shared.keyWindow)!)
        {
            scrollViewEmoji.isHidden = true
        }
        if updateScrollFlag{
            // Check for Page Number for Browse Blog

            if scrollingComment.contentOffset.y >= scrollingComment.contentSize.height - scrollingComment.bounds.size.height{
                if (!isPageRefresing  && limit*pageNumber < total_Comments){
                    if Reachabable.isConnectedToNetwork() {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        findAllComments()
                    }
                }
            }
        }
        if scrollView.tag == 3
        {

            let w = scrollView.frame.size.width
            let page = Int(scrollView.contentOffset.x / w)
            currentPage = Int(page)
            for ob in stickerScrollView.subviews{
                if ob is UIButton {
                    if ob.tag == page{
                        let totalWidthWithOriginY = ob.frame.origin.x + ob.frame.size.width
                        let widthOfParticularSticker = stickerScrollView.frame.size.width
                        if totalWidthWithOriginY > stickerScrollView.frame.size.width{
                            let difference = totalWidthWithOriginY - widthOfParticularSticker
                            stickerScrollView.setContentOffset(CGPoint(x : difference, y :0), animated: true)
                        }
                    }
                }
            }
        }
    }

    //MARK: When ScrollView Stop Scrolling
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView.tag == 3
        {
            let w = scrollView.frame.size.width
            let page = Int(scrollView.contentOffset.x / w)
            for ob in stickerScrollView.subviews{
                if ob is UIButton {
                    if ob.tag == page{
                        ob.backgroundColor = aafBgColor
                    }
                    else{
                        ob.backgroundColor = UIColor.clear
                    }
                }
            }
        }

    }

    // The scroll view calls this method when the scrolling movement comes to a halt
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if scrollView.tag == 3
        {
            let w = scrollView.frame.size.width
            let page = Int(scrollView.contentOffset.x / w)
            for ob in stickerScrollView.subviews{
                if ob is UIButton {
                    if ob.tag == page{
                        ob.backgroundColor = aafBgColor
                    }
                    else{
                        ob.backgroundColor = UIColor.clear
                    }
                }
            }
        }

    }
    
    func hashTagSearch(_ searchText:String){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            activityIndicatorView.center = CGPoint(x: view.center.x, y: 140)
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
        //    activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var str = searchText
            while str.hasPrefix("@") {
                str.remove(at: str.startIndex)
            }
            // Send Server Request to Share Content
            post(["search":"\(str)", "limit": "10"], url: "advancedactivity/friends/suggest", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            
                            if let response = succeeded["body"] as? NSArray{
                                self.suggestedHashTags = response as [AnyObject]
                                
                            }
                            
                            self.showUserTableView.frame.size.height = self.view.bounds.height - self.keyBoardHeight1 - 50 - TOPPADING - 150//self.view.bounds.height - self.keyBoardHeight1 - TOPPADING - 50
                            self.showUserTableView.reloadData()
                            if self.suggestedHashTags.count > 0 && self.suggestedHashTags.count < 4 {
                                self.showUserTableView.frame.size.height = CGFloat(self.suggestedHashTags.count * 50)
                            }
                            if self.suggestedHashTags.count == 0 {
                                self.suggestedHashTags.removeAll(keepingCapacity: false)
                                self.showUserTableView.reloadData()
                                self.showUserTableView.isHidden = true
                            }
                            
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
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    
    // MARK:  UITextViewDelegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
       // self.contentIcon.isHidden = true
        if StickerPlugin == true{
            if stickers.tag == 1{
                stickerView(stickers)
            }
        }
        if textView.textColor == textColorMedium {
            textView.text = nil
            textView.textColor = textColorDark
            
        }

        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        self.contentIcon.isHidden = false
        
        if textView.text.isEmpty{
            if StickerPlugin == true{
                self.stickers.isHidden = false
            }
            if emojiEnabled == true{
                if addedPhotos == true{
                    self.stickers.isHidden = true
                }
                else{
                    self.stickers.isHidden = false
                }
            }
            self.commentTextView.text = NSLocalizedString("Write a Comment...",  comment: "")
            self.commentTextView.textColor = textColorMedium
        }
        // Animation On TextView End Editing
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        self.contentIcon.isHidden = true
        let strin = textView.text
        if strin != "" {
            if strin?[(strin?.startIndex)!] == "@"{
                
                self.showUserTableView.isHidden = false
//                self.contentIcon.isHidden = true
                hashTagSearch(textView.text!)
            }
            else if(strin?.range(of: " @") != nil){
                if let videoID = strin?.components(separatedBy: " @").last {
                    
                    self.showUserTableView.isHidden = false
//                    self.contentIcon.isHidden = true
                    hashTagSearch(videoID)
                }
            }
        }
        else{
            
            self.suggestedHashTags.removeAll(keepingCapacity: false)
            self.showUserTableView.reloadData()
            self.showUserTableView.isHidden = true
//            self.contentIcon.isHidden = false
            
        }
        
        if textView.text == ""{
            if StickerPlugin == true{
                self.stickers.isHidden = false
            }
            if emojiEnabled == true{
                if addedPhotos == true{
                    self.stickers.isHidden = true
                }
                else{
                    self.stickers.isHidden = false
                }
            }
            textView.textColor = textColorDark
            if addedPhotos == true{
                self.commentPost.setTitleColor(buttonColor, for: UIControl.State())
               // self.commentPost.setImage(#imageLiteral(resourceName: "sendIcon").maskWithColor(color: buttonColor), for: .normal)
                self.commentPost.isEnabled = true
                self.commentPost.alpha = 1
            }
            else{
                
                self.commentPost.setTitleColor(UIColor.lightGray, for: UIControl.State())
                //self.commentPost.setImage(#imageLiteral(resourceName: "sendIcon").maskWithColor(color: UIColor.lightGray), for: .normal)
                self.commentPost.isEnabled = false
                self.commentPost.alpha = 0.6
            }
        }else{
            if StickerPlugin == true{
                self.stickers.isHidden = true
            }
         //   addFriendTagText()
            
            self.commentPost.setTitleColor(buttonColor, for: UIControl.State())
            self.commentPost.setTitleColor(buttonColor, for: UIControl.State())
            //self.commentPost.setImage(#imageLiteral(resourceName: "sendIcon").maskWithColor(color: buttonColor), for: .normal)
            self.commentPost.isEnabled = true
            self.commentPost.alpha = 1
            
        }
        
    }
    
    // MARK:  TTTAttributedLabelDelegate
    
    // Make Custom Links from Activity Feed
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        
        let type = components["type"] as! String
        
        switch(type){
            
        case "more":
            
            fullDescriptionCell.append(components["id"] as! Int)
            
        case "less":
            for (index,value) in fullDescriptionCell.enumerated(){
                if value == components["id"] as! Int{
                    fullDescriptionCell.remove(at: index)
                    break
                }
            }
            
        case "user":
            
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(components["user_id"]!)"
            presentedVC.fromActivity = false
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
            
        default:
            print("default")
        }
        
        if type == "more" || type == "less"{
            self.commenttableView.beginUpdates()
            self.commenttableView.reloadRows(at: [IndexPath(row: components["index"] as! Int, section: 0)], with: .none)
            self.commenttableView.endUpdates()
            if fromSingleFeed == true
            {
                self.commenttableView.frame.size.height = self.commenttableView.contentSize.height
                self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight
            }
//            var offset:CGPoint!
//            offset = self.commenttableView.contentOffset
//            commenttableView.reloadData()
//            self.commenttableView.setContentOffset(offset, animated: false)
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
    @objc func showProfile(_ sender: UIButton){
        
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = "\(sender.tag)"
        presentedVC.fromActivity = false
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    
    func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //sender: UIButton!
    @objc func lightBox(_ sender: UIButton)
    {
        let presentedVC = SinglePhotoLightBoxController()
        let image = self.imageviewUrl[sender.tag]
        presentedVC.imageUrl = image
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        present(nativationController, animated:false, completion: nil)
    }
    
    // MARK: - Refresh Delegate method  
    func reloaddata(){
        
        if isRefresh == true
        {
            isRefresh = false
            if tempHeight == 0
            {
                tempHeight = commentTabelHeight
                commenttableView.frame.origin.y = 90
            }
            else
            {
                tempHeight = 0
                commenttableView.frame.origin.y  =  commentTabelHeight
            }
        }
        else
        {
            commenttableView.reloadData()
        }
        
    }
    func deleteFeed()
    {
        scrollingComment.isHidden = true
        self.title =  NSLocalizedString("Comments ", comment: "")
        if fromSingleFeed == true
        {
            feedArray.remove(at: activityfeedIndex)
            _ = self.navigationController?.popViewController(animated: true)
            
        }
        
    }
    // Update like reaction dictionary
    func reloadOnLike(newDictionary : NSDictionary)
    {
        
        self.feedArray1.removeAll()
        feedArray1.append(newDictionary)
      //  if isQuickContentInProcess == 0
      //  {
            feedObj.globalArrayFeed = feedArray1
            self.feedObj.refreshLikeUnLike = true
            feedObj.tableView.reloadData()
       // }
        if total_Comments == 0 &&  total_Likes == 0
        {
            self.commentTabelHeight = self.commentTabelHeight + 35
            self.commenttableView.frame.origin.y = self.commentTabelHeight
            total_Likes = 1
            
        }
        else if total_Comments == 0 && total_Likes > 0{
            self.commentTabelHeight = self.commentTabelHeight - 35
            self.commenttableView.frame.origin.y = self.commentTabelHeight
            total_Likes = 0
        }
        
        self.commenttableView.frame.size.height = self.commenttableView.contentSize.height
        self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight + 50
        if total_Comments == 0  && self.fromSingleFeed{
            
            self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight + self.noCommentIcon.frame.height + self.noCommentTitle.frame.height + 20
           scrollToBottom()
            
        }

        
        // Update member page AAF while coming from feed
        if fromNotification == false {
            if isComingFromTikTokPage
            {
                updateFeedArrayTikTok(newDic: newDictionary)
            }
            else
            {
                if userActivityFeedComment == true
                {
                    userFeedArray[activityfeedIndex] = newDictionary
                    
                }
                else if activityFeedComment == true
                {
                    feedArray[activityfeedIndex] = newDictionary
                }
                else
                {
                    contentFeedArray[activityfeedIndex] = newDictionary
                }
            }
        }
  
    }
    
    func updateFeedArrayTikTok(newDic : NSDictionary)
    {
        if activityFeedComment == true
        {
            for (index, dic) in feedArray.enumerated()
            {
                if dic["action_id"] as! Int == newDic["action_id"] as! Int
                {
                    feedArray[index] = newDic
                }
            }
        }
        else if userActivityFeedComment == true
        {
            contentfeedArrUpdate = true
            for (index, dic) in userFeedArray.enumerated()
            {
                if dic["action_id"] as! Int == newDic["action_id"] as! Int
                {
                    userFeedArray[index] = newDic
                }
            }
        }
        else
        {
            for (index, dic) in contentFeedArray.enumerated()
            {
                if dic["action_id"] as! Int == newDic["action_id"] as! Int
                {
                    contentFeedArray[index] = newDic
                }
            }
        }
    }
    
    // MARK: - Updating comment count globally
    func updateCommentCount(feedindex:Int,key:String,updatedvalue:Int,delete:Int,likecount:Int)
    {
        
        let feed = feedArray1[0] as! NSDictionary
        var newDictionary:NSMutableDictionary = [:]
        newDictionary = feed as! NSMutableDictionary
        newDictionary["\(key)"] = updatedvalue
        
        // Updating attachment array while liking or reacting any image feed
        if let arr = newDictionary["attachment"] as? NSMutableArray
        {
            let  attachmentDic = arr[0] as! NSMutableDictionary
            attachmentDic["comment_count"] = newDictionary["comment_count"]
            arr[0] = attachmentDic
            newDictionary["attachment"] = arr
        }
        if fromNotification == false {
            if isComingFromTikTokPage
            {
                updateFeedArrayTikTok(newDic: newDictionary)
            }
            else
            {
                if userActivityFeedComment == true
                {
                    userFeedArray[activityfeedIndex] = newDictionary
                    
                }
                else if activityFeedComment == true
                {
                    feedArray[activityfeedIndex] = newDictionary
                }
                else
                {
                    contentFeedArray[activityfeedIndex] = newDictionary
                }
            }
        }
        if total_Comments == 0 || total_Comments == 1
        {
            self.feedArray1.removeAll()
            feedArray1.append(newDictionary)
          //  if isQuickContentInProcess == 0
          //  {
              feedObj.globalArrayFeed = feedArray1
              self.feedObj.refreshLikeUnLike = true
           // }
            
            //feedObj.tableView.reloadData()
            if updatedvalue == 1 && delete == 0 && likecount == 0
            {
                self.commentTabelHeight = self.commentTabelHeight + 35
                self.commenttableView.frame.origin.y = self.commentTabelHeight
                self.commenttableView.contentSize.height = self.commenttableView.contentSize.height + 35
                scrollToBottom()
         
       
            }
            else if updatedvalue == 0 && delete == 1 && likecount == 0
            {
                self.commentTabelHeight = self.commentTabelHeight - 35
                self.commenttableView.frame.origin.y = self.commentTabelHeight
                self.commenttableView.contentSize.height = self.commenttableView.contentSize.height - 35
              //  self.scrollingComment.contentSize.height = self.commenttableView.contentSize.height + self.commentTabelHeight
                
            //    self.scrollingComment.contentSize.height = getBottomEdgeY(inputView: self.commenttableView)
                scrollToBottom()
     
            }
           
        }

    }
    
}
