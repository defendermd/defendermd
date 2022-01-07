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
//  ConverstationViewController.swift
//  seiosnativeapp

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

//var singleFeed:Bool = false
class HashTagFeedViewController: UIViewController  , UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate,TTTAttributedLabelDelegate ,UISearchBarDelegate{
    var completionHandler:(() -> ())?
    let mainView = UIView()
    var searchBar = UISearchBar()
    var searchResultTableView : UITableView!
    var suggestedHashTags = [AnyObject]()
    var maxid:Int!                              // MaxID for Pagination
    var activity_id: Int!
    var hashtagString : String = ""
    var info:UILabel!
    var contentIcon : UILabel!
    var dynamicHeight:CGFloat = 44
    var dynamicHeight1:CGFloat = 50// Defalut Dynamic Height for each Row
    var updateScrollFlag = true                 // Flag for Pagination by ScrollView Delegate
    var deleteFeed = false                      // Flag for Delete Feed Updation
    var feedFilter: UIButton!                   // Feed Filter Option
    var activityFeeds:[ActivityFeed] = []       // To save Activity Feeds from Response (subclass of ActivityFeed)
    var menuOptionSelected:String!              // Set Option Selected for Feed Gutter Menu
    var tempFeedArray = [Int:AnyObject]()       // Hold TemproraryFeedMenu for Hide Row (Undo, HideAll)
    var feed_filter = 1                         // Set Value for Feed Filter options in browse Feed Request to get feed_filter in response
    var feedFilterFlag = false                  // Flag to merge Feed Filter Params in browse Feed Request
    var fullDescriptionCell = [Int]()           // Contain Array of all cell to show full description
    var dynamicRowHeight = [Int:CGFloat]()      // Save table Dynamic RowHeight
    var action_id : Int!
    var feedArray1 = [AnyObject]()
    var noCommentMenu:Bool = false
 //   var imageCache = [String:UIImage]()
  //  var userImageCache = [String:UIImage]()
    var titleHeight:CGFloat = 0
    var temptitleInfo : String = ""
    var UserId:Int!
    var showSpinner = true
    var actionIdArray = [Int]()
     var feedObj = FeedTableViewController()
    var leftBarButtonItem : UIBarButtonItem!
    let subscriptionNoticeLinkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.gray,
        // NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    let subscriptionNoticeActiveLinkAttributes = [
        NSAttributedString.Key.foregroundColor: UIColor.gray.withAlphaComponent(0.80),
        //NSUnderlineStyleAttributeName: NSNumber(bool:true),
    ]
    private var dismissEmojiView: UITapGestureRecognizer?
    
    // Initialize Class
    override func viewDidLoad() {
        
        tableViewFrameType = "HashTagFeedViewController"
        view.backgroundColor = aafBgColor
//        searchBar.delegate = self
//        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search",  comment: ""))
//        searchBar.text = NSLocalizedString("#\(hashtagString)",  comment: "")
//        searchBar.resignFirstResponder()
//        searchBar.backgroundColor = UIColor.clear
//        self.navigationItem.titleView = searchBar

        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search",  comment: ""))
        searchBar.delegate = self
        searchBar.text = NSLocalizedString("#\(hashtagString)",  comment: "")
        searchBar.resignFirstResponder()
        
        mainView.frame = view.frame
        mainView.backgroundColor = aafBgColor
        view.addSubview(mainView)

        
        searchResultTableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height-120), style: UITableView.Style.grouped)
        searchResultTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        searchResultTableView.rowHeight = 50
        searchResultTableView.backgroundColor = tableViewBgColor
        searchResultTableView.separatorColor = TVSeparatorColor
        searchResultTableView.tag = 33
        searchResultTableView.isHidden = true
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            searchResultTableView.estimatedSectionHeaderHeight = 0
        }
        mainView.addSubview(searchResultTableView)
        
        
        maxid = 0       // Set Default maxid for browseFeed
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(HashTagFeedViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        // Initial table to show Activity Feeds
        feedObj.willMove(toParent: self)
        self.view.addSubview(feedObj.view)
        self.addChild(feedObj)
        
        
        
        info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
        self.info.sizeToFit()
        self.info.numberOfLines = 0
        self.info.center = self.view.center
        self.info.backgroundColor = aafBgColor
        self.info.tag = 1000
        self.mainView.addSubview(self.info)
        info.isHidden = true
        
        self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(blogIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
        self.contentIcon.tag = 2000
        self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
        self.mainView.addSubview(self.contentIcon)
        contentIcon.isHidden = true
        
        
        
        // Create a Feed Filter to perform Feed Filtering
        feedFilter = createButton(CGRect(x: PADING, y: 0 , width: 0,height: 0),title: NSLocalizedString("All Updates",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
        feedFilter.isEnabled = false
        feedFilter.backgroundColor = lightBgColor
        feedFilter.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        feedFilter.addTarget(self, action: Selector(("showFeedFilterOptions:")), for: .touchUpInside)
        feedObj.tableView.addSubview(feedFilter)
        
        // Filter Icon on Left site
        let filterIcon = createLabel(CGRect(x: feedFilter.bounds.width - feedFilter.bounds.height, y: 0 ,width: 0,height: 0), text: "\u{f107}", alignment: .center, textColor: textColorMedium)
        filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        feedFilter.addSubview(filterIcon)

        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        feedObj.tableView.tableFooterView = footerView
        feedObj.tableView.tableFooterView?.isHidden = true
        
        browseFeed()
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

    
    // Perform on Every Time when ActivityFeed View is Appeared
    override func viewWillAppear(_ animated: Bool)
    {
        feedObj.feedShowingFrom = "ActivityFeed"
        self.browseEmoji(contentItems: reactionsDictionary)
        tableViewFrameType = "HashTagFeedViewController"
        NotificationCenter.default.addObserver(self, selector: #selector(HashTagFeedViewController.ScrollingactionHashTagFeed(_:)), name: NSNotification.Name(rawValue: "ScrollingactionHashTagFeed"), object: nil)
        setNavigationImage(controller: self)
    //    maxidTikTok = 0
   //     API_getAAFList()
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
            feedArray1.append(newDictionary)
            
        }
        if logoutUser == false
        {
            globalFeedHeight =  0.00001 + 3
        }
        else
        {
            globalFeedHeight = 0.00001
        }
        self.feedObj.globalArrayFeed = feedArray1
        self.feedObj.refreshLikeUnLike = true
        self.feedObj.tableView.reloadData()

    }
    
    // Make Hard Refresh Request to server for Activity Feeds
    //MARK:- TikTok API
    func API_getAAFList()
    {
        if Reachabable.isConnectedToNetwork()
        {
            var parameters = [String:String]()
            parameters = ["limit": "\(limit)","maxid": String(maxidTikTok),"feed_filter": "1","post_elements": "1","post_menus":"1","object_info":"1","getAttachedImageDimention":"0","filter_type":"video","hashtag": "%23\(hashtagString)","onlyMyDeviceVideo":"1"]
            
            subjectTypeTikTok = ""
            subjectIdTikTok = ""
            
            
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
    
    func browseFeed(){
        singleFeed = true
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            API_getAAFList()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            if showSpinner
            {
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            }
            
            
            // Remove new Activity Feed InfoLabel, NO Stories
            for ob in mainView.subviews{
                if ob.tag == 10000{
                    ob.removeFromSuperview()
                }
            }
            for ob in view.subviews{
                if ob.tag == 2020{
                    ob.removeFromSuperview()
                }
            }
            for ob in view.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            for ob in view.subviews{
                if ob.tag == 2000{
                    ob.removeFromSuperview()
                }
            }

            // Reset feedArray for Sink with Feed Results
            if self.maxid == 0{
                feedArray1.removeAll(keepingCapacity: false)
                self.dynamicRowHeight.removeAll(keepingCapacity: false)
                self.feedObj.refreshLikeUnLike = true
                self.feedObj.tableView.reloadData()
            }
            
            
            
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            //            parameters = ["limit": "\(limit)","action_id":"\(self.action_id)","object_info":"1"]
            parameters =   ["maxid": String(maxid) , "limit": "\(limit)" ,"feed_filter": "\(feed_filter)","object_info":"1","hashtag": "%23\(hashtagString)","getAttachedImageDimention":"0"]
            
            // Set userinteractionflag for request
            userInteractionOff = false
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            // Check for FeedFilter Option in Request
            //            if feedFilterFlag == true{
            //                parameters.merge(searchDic)
            //            }
            //
            // Send Server Request for Activity Feed
            post(parameters, url: "/advancedactivity/feeds", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    // Reset Object after Response from server
                    userInteractionOff = true
                    
                    activityIndicatorView.stopAnimating()
                    self.showSpinner = false
                    self.feedObj.tableView.tableFooterView?.isHidden = true
                    // On Success Update Feeds
                    if msg{
                        
                        self.activityFeeds.removeAll(keepingCapacity: false)
                        

                        // Check response of Activity Feeds
                        if let response = succeeded["body"] as? NSDictionary{
                            
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
                                    // Update feedArray
                                    self.updateFeedsArray(self.activityFeeds)
                                }
                            }
                            
                            // Set MaxId for Feeds Result
                            if let maxid = response["maxid"] as? Int{
                                self.maxid = maxid
                            }
                            
                            //                            // update Recent Feeds in Core Data
                            //                            if searchDic.count == 0  /*&& self.subject_type == ""*/{
                            //                                self.updateActivityFeed(self.activityFeeds)
                            //                            }
                            
                            if self.feedFilter.isHidden == true{
                                self.feedFilter.isHidden = false
                            }
                            
                            // Set Label If their is no feed in response
                            if self.feedArray1.count == 0 {
                                self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(blogIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                                self.info.tag = 2000
                                self.mainView.addSubview(self.contentIcon)
                                
                                self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any  entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.info.sizeToFit()
                                self.info.numberOfLines = 0
                                self.info.center = self.view.center
                                self.info.backgroundColor = aafBgColor
                                self.info.tag = 1000
                                self.mainView.addSubview(self.info)
                                
                                self.info.isHidden = false
                                self.contentIcon.isHidden = false
                                
                                //        self.mainView.makeToast("There are no more posts to show.", duration: 5, position: "bottom")
                            }else{
                                self.info.isHidden = true
                                self.contentIcon.isHidden = true
                            }
                            
                            
                            // Reload Tabel After Updation
                            self.feedObj.refreshLikeUnLike = true
                            self.feedObj.tableView.reloadData()
                            self.updateScrollFlag = true
                            self.activityFeeds.removeAll(keepingCapacity: false)
                        }
                        
                    }else{
                        
                        self.updateScrollFlag = true
                    }
                })
            }
        }else{
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
                        emoji.addTarget(self, action: #selector(HashTagFeedViewController.feedMenuReactionLike(sender:)), for: .touchUpInside)
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
    

    
    //  set Dynamic Height For Every Cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
   
            return dynamicHeight1
     
    }
    
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
            return  0.00001
        
    
    }
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
            return  0.00001
        
        
    }
     // Set Table Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
     
            return  suggestedHashTags.count
       
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
  
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            for ob in mainView.subviews{
                if ob.tag == 1000 {
                    ob.removeFromSuperview()
                }
                if ob.tag == 2000 {
                    ob.removeFromSuperview()
                }
                
            }
            
        if let response = suggestedHashTags[(indexPath as NSIndexPath).row] as? NSDictionary {
            cell.labTitle.frame.size.width = (UIScreen.main.bounds.width - (cell.imgUser.bounds.width + 15))
            // Set Name People who Likes Content
            cell.labTitle.text = response["label"] as? String
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labTitle.sizeToFit()
            
            dynamicHeight = cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5
            
            if dynamicHeight < (cell.imgUser.bounds.height + 10){
                dynamicHeight = (cell.imgUser.bounds.height + 10)
            }
            
            // Set Frnd Image
            // Set Feed Owner Image
            if let imgUrl = response["image_icon"] as? String{
                let url = URL(string:imgUrl)
                if url != nil
                {
                    cell.imgUser.image = nil
                    cell.imgUser.kf.indicatorType = .activity
                    (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgUser.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            var hashTagString : String!
            if let response = suggestedHashTags[(indexPath as NSIndexPath).row] as? NSDictionary {
//                searchBar.setPlaceholderWithColor((response["label"] as? String)!)
                hashTagString = response["label"] as? String
            }
            
            searchDic.removeAll(keepingCapacity: false)
            if hashTagString.range(of: "#") != nil{
                let original = hashTagString
                  searchBar.text = original
                let singleString = String(original!.dropFirst())
                self.hashtagString = singleString
            }
            
            updateAutoSearchArray(str: hashTagString)
            searchBar.resignFirstResponder()
            maxid = 0
            searchDic.removeAll(keepingCapacity: false)
            self.searchResultTableView.isHidden = true
            self.feedObj.tableView.isHidden = false
            browseFeed()
      
    }
    // Make Custom Links from Activity Feed
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchDic.removeAll(keepingCapacity: false)
        if searchBar.text!.range(of: "#") != nil{
            let original = searchBar.text
            let singleString = String(original!.dropFirst())
            searchDic["search"] = singleString
            self.hashtagString = singleString
        }else{
            searchDic["search"] = searchBar.text!
        }
        searchBar.resignFirstResponder()
        maxid = 0
        browseFeed()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.length > 0 && searchBar.text![searchBar.text!.startIndex] == "#"{
            
            self.searchResultTableView.isHidden = false
            self.feedObj.tableView.isHidden = true
            hashTagSearch(searchBar.text!)
        }
        else{
            
            if searchBar.text?.length != 0
            {
                self.suggestedHashTags.removeAll(keepingCapacity: false)
                self.searchResultTableView.reloadData()
                self.searchResultTableView.isHidden = true
                self.feedObj.tableView.isHidden = false
            }
            else
            {
                _ = completionHandler?()
                goBack()
            }
            
        }
        
    }
 
    
    func hashTagSearch(_ searchText:String){
        // Check Internet Connection
        info.isHidden = true
        contentIcon.isHidden = true
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            activityIndicatorView.center = CGPoint(x: view.center.x, y: 140)
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
          //  activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            userInteractionOff = false
            // Send Server Request to Share Content
            post(["hashtag":"\(searchText)", "limit": "10"], url: "sitehashtag/browse", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
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
                            
                            self.searchResultTableView.reloadData()
                        }
                        
                        //  println(succeeded)
                        
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
    
    
    override func viewWillDisappear(_ animated: Bool) {
        scrollViewEmoji.isHidden = true
        arrowView.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        searchBar.resignFirstResponder()
         feedObj.tableView.tableFooterView?.isHidden = true
        tableViewFrameType = ""
        setNavigationImage(controller: self)
        
    }
    
    
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    // Handle Scroll For Pagination
     @objc func ScrollingactionHashTagFeed(_ notification: Foundation.Notification)
    {
        scrollViewEmoji.isHidden = true
        // Check for PAGINATION
        if feedObj.tableView.contentSize.height > feedObj.tableView.bounds.size.height{
            if feedObj.tableView.contentOffset.y >= (feedObj.tableView.contentSize.height - feedObj.tableView.bounds.size.height){
                if Reachabable.isConnectedToNetwork() {
                    
                    if feedArray1.count > 0{
                        if maxid == 0 {
                            //                                if noPost == true{
                            //                                    self.view.makeToast("There are no more posts to show." , duration: 5, position: "bottom")
                            //                                    noPost = false
                            
                            feedObj.tableView.tableFooterView?.isHidden = true
                        }
                    }
                    else
                    {
                        // Request for Pagination
                        //                                updateScrollFlag = false
                        
                        feedObj.tableView.tableFooterView?.isHidden = false
                        feed_filter = 0
                        //                                showSpinner = true
                        browseFeed()
                    }
                }
            }
        }
    }
    
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer() {
        stop()
        _ = navigationController?.popViewController(animated: true)
    }
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer:Bool){
        mainView.addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    
    func updateAutoSearchArray(str : String) {
        if !arrRecentSearchOptions.contains(str)
        {
            arrRecentSearchOptions.insert(str, at: 0)
            if arrRecentSearchOptions.count > 6 {
                arrRecentSearchOptions.remove(at: 6)
            }
            UserDefaults.standard.set(arrRecentSearchOptions, forKey: "arrRecentSearchOptions")
        }
    }
    
}
