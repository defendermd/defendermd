
//
//  MusicPlayListViewController.Swift
//  SocailEngineDemoForSwift
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


import UIKit
import Foundation
import AVFoundation
import MediaPlayer
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

var songIndex:Int!
var songIdCheck: Int!
var pausingRemain = ""
var playlistResponse = [AnyObject]()
// Global Variable Initialization Used in Blog Module

class MusicPlayListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate , UITabBarControllerDelegate {
    var musicTitle : TTTAttributedLabel!
    var sliderTimer = Timer()
    var playListId:Int!                        // Edit BlogID
    let mainView = UIView()
    var showSpinner = true                      // not show spinner at pull to refresh
    
    var isPageRefresing = false                 // For Pagination
    var playlistTableView:UITableView!              // TAbleView to show the blog Contents
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
    var fromActivityFeed = false
    var deletePlaylistEntry:Bool!
    var objectId:Int!
    var showOnlyMyContent = true
    var bgImage: UIImageView!
    var playerViewButton: UIButton!
    var contentSelection : UIButton!
    var tempInfo : String!
    var playlistTitleString : String!
    var contentDescription1 : String = ""
    var shareDescription : String = ""
    var descriptionAttributedLabel : TTTAttributedLabel!
    var like_comment : UIView!
    var musicIconn = "\u{f01d}"
    var mainSubView:UIView!
    var coverImage:UIImageView!
    var browseOrMyMusic1:Bool! = false
    var profilePic: UIImageView!
    var marqueeHeader : MarqueeLabel!
    
    var pausePlay : UIButton!
    var previous : UIButton!
    var player:AVPlayer = AVPlayer()
    
    
    var CurrentSongId: Int!
    var currentPlayingSong: String!
    var currentTime:TimeInterval!
    
    var playSlider: UISlider!
    var beginTime:UILabel!
    var endTime:UILabel!
    
    var imageIcon:NSString!
    var imageProfile:NSString!
    
    
    var songPlayLabel : UILabel!
    var descriptionText : UITextView!
    
    var playListTitle : UILabel!
    var ownerTitle : UILabel!
    
    var ownerId : Int!
    
    var navBarTitle: UILabel!
    
    var shareUrl : String!
    var shareParam : NSDictionary!
    var topMainView : UIView!
    var descriptionResult: String!
    
    var selectedMoreLess:Bool = false
    var contentUrl : String!
    var checkStart : Int!
    var lastContentOffset: CGFloat = 0
    var photourl : String!
    var leftBarButtonItem : UIBarButtonItem!
    var popAfterDelay:Bool!
    // Flag to refresh Blog
    // Initialization of class Object
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    var rightBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        deletePlaylistEntry = false
        popAfterDelay = false
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        openMenu = false
        updateAfterAlert = true
        musicPlaying = false
        self.tabBarController?.delegate = self

        
        isPageRefresing = true
        self.navigationItem.rightBarButtonItem = nil
        removeNavigationImage(controller: self)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MusicPlayListViewController.goBack))
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
        
        playlistTableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - 40 - tabBarHeight ), style: .grouped)
        playlistTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        playlistTableView.dataSource = self
        playlistTableView.delegate = self
        playlistTableView.backgroundColor = tableViewBgColor
        playlistTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            playlistTableView.contentInsetAdjustmentBehavior = .never
            playlistTableView.estimatedRowHeight = 0
            playlistTableView.estimatedSectionHeaderHeight = 0
            playlistTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(playlistTableView)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        playlistTableView.tableFooterView = footerView
        playlistTableView.tableFooterView?.isHidden = true
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            topMainView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 450), borderColor: UIColor.clear, shadow: false)
            mainSubView = createView(CGRect(x: 0, y: 0, width: view.bounds.width, height: 350), borderColor: UIColor.clear, shadow: false)
        }
        else
        {
            topMainView = createView(CGRect(x: 0,y: 0, width: view.bounds.width, height: 380), borderColor: UIColor.clear, shadow: false)
            mainSubView = createView(CGRect(x: 0,y: 0, width: view.bounds.width, height: 250), borderColor: UIColor.clear, shadow: false)
        }
        playlistTableView.addSubview(topMainView)
        
        

        mainSubView.isHidden = false
        mainSubView.backgroundColor = lightBgColor
        topMainView.backgroundColor = UIColor.clear //UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        topMainView.addSubview(mainSubView)
        
        navBarTitle = createLabel(CGRect(x: 0,y: 0,width: view.bounds.width,height: TOPPADING), text: "", alignment: .center, textColor: textColorLight)
        navBarTitle.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        topMainView.addSubview(navBarTitle)
        navBarTitle.isHidden = true
        
        coverImage = CoverImageViewWithGradient(frame: CGRect(x: 0, y: 0, width: mainSubView.bounds.width, height: mainSubView.bounds.height))
        //coverImage.contentMode = UIView.ContentMode.Top
        coverImage.layer.masksToBounds = true
        coverImage.isUserInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(MusicPlayListViewController.onImageViewTap))
        coverImage.addGestureRecognizer(tap1)
        mainSubView.addSubview(coverImage)
        
        
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            profilePic = createImageView(CGRect(x: view.bounds.width - 150,  y: coverImage.bounds.height - (2 * contentPADING) - 80,width: 120 ,height: 120 ), border: true)
            contentSelection = createButton(CGRect(x: view.bounds.width - 150,  y: coverImage.bounds.height - (2 * contentPADING) - 80,width: 120 ,height: 120 ), title: "", border: false,bgColor: false, textColor: textColorLight)
        }else{
            profilePic = createImageView(CGRect(x: view.bounds.width - 100,  y: coverImage.bounds.height - (2 * contentPADING) - 40 ,width: 80 , height: 80 ), border: true)
            contentSelection = createButton(CGRect(x: view.bounds.width - 100,  y: coverImage.bounds.height - (2 * contentPADING) - 40 ,width: 80 , height: 80 ), title: "", border: false,bgColor: false, textColor: textColorLight)
        }
        
        
        contentSelection.layer.borderColor = UIColor.white.cgColor
        contentSelection.layer.borderWidth = 2.5
        contentSelection.layer.cornerRadius = contentSelection.frame.size.width / 2;
        contentSelection.backgroundColor = placeholderColor
        contentSelection.contentMode = UIView.ContentMode.scaleAspectFill
        contentSelection.layer.masksToBounds = true
        
        contentSelection.addTarget(self, action: #selector(MusicPlayListViewController.openOwnersProfile(_:)), for: UIControl.Event.touchUpInside)
        
        mainSubView.addSubview(contentSelection)
        mainSubView.layer.borderColor = UIColor.clear.cgColor
        
        playListTitle = createLabel(CGRect(x: 10, y: coverImage.bounds.height - 40, width: view.bounds.width-160, height: 30), text: "", alignment: .left, textColor: textColorLight)
        playListTitle.font = UIFont(name: fontBold, size: FONTSIZEExtraLarge)
        playListTitle.numberOfLines = 0
        playListTitle.layer.shadowColor = shadowColor.cgColor
        playListTitle.layer.shadowOpacity = shadowOpacity
        playListTitle.layer.shadowRadius = shadowRadius
        playListTitle.layer.shadowOffset = shadowOffset
        coverImage.addSubview(playListTitle)
        
        songPlayLabel = createLabel(CGRect(x: 10, y: coverImage.bounds.height + 10, width: view.bounds.width - 120, height: 25), text: "", alignment: .left, textColor: textColorMedium)
        songPlayLabel.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        mainSubView.addSubview(songPlayLabel)
        
        musicTitle = TTTAttributedLabel(frame:CGRect(x: PADING, y: TOPPADING, width: view.bounds.width - 60, height: 80) )
        musicTitle.numberOfLines = 0
        musicTitle.delegate = self
        coverImage.addSubview(musicTitle)
        coverImage.backgroundColor = placeholderColor
        musicTitle.isHidden = true

        if(UIDevice.current.userInterfaceIdiom == .pad){
            ownerTitle = createLabel(CGRect(x: view.bounds.width - 180, y: songPlayLabel.frame.origin.y + songPlayLabel.bounds.height - 10, width: 180, height: 30), text: "", alignment: .center, textColor: textColorLight)
        }else{
            ownerTitle = createLabel(CGRect(x: view.bounds.width - 120, y: songPlayLabel.frame.origin.y + songPlayLabel.bounds.height - 10, width: 120, height: 30), text: "", alignment: .center, textColor: textColorLight)

        }
        ownerTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
        ownerTitle.numberOfLines = 0
        ownerTitle.textColor = textColorDark
        ownerTitle.textAlignment = NSTextAlignment.center
        mainSubView.addSubview(ownerTitle)
        
        
        descriptionAttributedLabel = TTTAttributedLabel(frame:CGRect(x: PADING , y: songPlayLabel.frame.origin.y + songPlayLabel.bounds.height + 20 , width: view.bounds.width, height: 100) )
        descriptionAttributedLabel.numberOfLines = 0
        descriptionAttributedLabel.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        descriptionAttributedLabel.textColor = textColorDark
        descriptionAttributedLabel.delegate = self
        topMainView.addSubview(descriptionAttributedLabel)
        
        playerViewButton = createButton(CGRect(x: view.bounds.width - 65, y: songPlayLabel.frame.origin.y + songPlayLabel.bounds.height + 60, width: 55, height: 55), title: "\u{f04b}", border: true,bgColor: false, textColor: textColorLight)
        playerViewButton.backgroundColor = navColor
        playerViewButton.layer.borderColor = UIColor.clear.cgColor
        playerViewButton.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZENormal)
        playerViewButton.layer.borderWidth = 2.5
        playerViewButton.layer.cornerRadius = playerViewButton.frame.size.width / 2;
        playerViewButton.layer.masksToBounds = true
        
        view.addSubview(playerViewButton)
        playerViewButton.addTarget(self, action: #selector(MusicPlayListViewController.playerView(_:)), for: .touchUpInside)
        playerViewButton.isHidden = true
        
        
        
        descriptionText = createTextView(CGRect(x: PADING , y: songPlayLabel.frame.origin.y + songPlayLabel.bounds.height + 5 , width: view.bounds.width, height: 100), borderColor: UIColor.clear, corner: false)
        descriptionText.textColor = textColorDark//textColorMedium
        descriptionText.backgroundColor = UIColor.green
        descriptionText.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        
        descriptionText.isHidden = true
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(MusicPlayListViewController.refresh), for: UIControl.Event.valueChanged)
        playlistTableView.addSubview(refresher)
        
        
        playlistTableView.tableHeaderView = topMainView
        
        
        if logoutUser == true || showOnlyMyContent == true{
            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.plain , target:self , action: #selector(MusicPlayListViewController.cancleSearch))
            self.navigationItem.rightBarButtonItem = addCancel
            
            
        }
        
        
        
        likeCommentContent_id = "\(playListId!)"
        likeCommentContentType = "music_playlist"
        like_CommentStyle = 1
        like_comment = Like_CommentView()
        like_comment.layer.shadowColor = shadowColor.cgColor
        like_comment.layer.shadowOffset = shadowOffset
        like_comment.layer.shadowRadius = shadowRadius
        like_comment.layer.shadowOpacity = shadowOpacity
        view.addSubview(like_comment)
        
  
    }
    
    // Check for Blog Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        playlistTableView.reloadData()
        checkStart = musicRestart
        pageNumber = 1
        showSpinner = true
        updateScrollFlag = false
        if(isPageRefresing == true)
        {
            browseEntries()
        }
    }
  
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    // Cancle Search Result for Logout User
    @objc func cancleSearch(){
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = ""
        pageNumber = 1
        showSpinner = true
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        browseEntries()
    }
    
    
    // Handle Browse music or My music PreAction
    func prebrowseEntries(_ sender: UIButton){
        // true for Browse music & false for My music
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        playlistTableView.tableFooterView?.isHidden = true
        playlistResponse.removeAll(keepingCapacity: false)
        searchDic.removeAll(keepingCapacity: false)
        updateScrollFlag = false
        pageNumber = 1
        showSpinner = true
        // Update for music
        browseEntries()
    }
    
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        //  if playlistResponse.count != 0{
        if Reachabable.isConnectedToNetwork() {
            searchDic.removeAll(keepingCapacity: false)
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            
            browseEntries()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
            
        }
        //   }
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
    @objc func stopTimer()
    {
        stop()
        if popAfterDelay == true
        {

            _ = self.navigationController?.popViewController(animated: false)
            
        }
    }
    
    // Update music
    func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            
            if (self.pageNumber == 1){
                playlistResponse.removeAll(keepingCapacity: false)
                
                if updateAfterAlert == true || searchDic.count > 0 {
                    removeAlert()
                    self.playlistTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
                //spinner.center = mainView.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = mainView.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
            //    activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            
            path = "music/playlist/view/" + String(playListId)
            parameters = ["playlist_id": String(playListId), "gutter_menu": "1", "page":"\(pageNumber)", "limit": "\(limit)"]
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse music Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.playlistTableView.tableFooterView?.isHidden = true
                    
                    if msg{
                        
                        if self.pageNumber == 1{
                            playlistResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if let menu = response["gutterMenu"] as? NSArray{
                                gutterMenu  = menu
                                if logoutUser == false{
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    shareButton.addTarget(self, action: #selector(MusicPlayListViewController.shareItem), for: .touchUpInside)
                                    rightNavView.addSubview(shareButton)
                                    
                                    let optionButton = createButton(CGRect(x: 44,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    optionButton.addTarget(self, action: #selector(MusicPlayListViewController.showMenu), for: .touchUpInside)
                                    rightNavView.addSubview(optionButton)
                                    
                                    self.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
                                    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                                    
                                }
                                
                                
                                for tempMenu in menu{
                                    if let tempDic = tempMenu as? NSDictionary{
                                        
                                        if tempDic["name"] as! String == "share" {
                                            self.shareUrl = tempDic["url"] as! String
                                            self.shareParam = tempDic["urlParams"] as! NSDictionary
                                        }
                                    }
                                }
                                
                                
                            }
                            
                            self.playlistTitleString = response["title"] as? String
                            self.playListTitle.text = response["title"] as? String
                            self.playListTitle.sizeToFit()
                            self.playListTitle.numberOfLines = 0

//                            if self.playlistTitleString.length > 25
//                            {
                                self.playListTitle.frame.origin.y = self.coverImage.bounds.height - self.playListTitle.frame.height - 5
//                            }
                            
                            self.imageIcon = response["title"] as? String as NSString?
                            if let url = URL(string: response["image"] as! String)
                            {
                                
                                self.photourl =  response["image"] as! String
                                self.coverImage.kf.indicatorType = .activity
                                (self.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                self.coverImage.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                })

                                
                            }else{
                                self.coverImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: self.coverImage.bounds.width)
                            }
                            
                            
                            self.ownerId = response["owner_id"] as! Int
                            
                            if let url1 = URL(string: response["owner_image"] as! String){
                                self.contentSelection.kf.setImage(with: url1 as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                    
                                })
                            }else{

                                self.contentSelection.setImage(UIImage(named: "nophoto_group_thumb_profile.png")!, for: UIControl.State())
                                
                            }
                            if let str = response["image"] as? NSString
                            {
                              self.imageProfile =  str
                            }
                            self.ownerTitle.text = response["owner_title"] as? String
                            if let music = response["playlist_songs"] as? NSArray {
                                playlistResponse = playlistResponse + (music as [AnyObject])
                                
                                let firstPlaylistResponseDic = playlistResponse[0] as! NSDictionary
                                self.CurrentSongId = firstPlaylistResponseDic["song_id"]! as! Int
                                songIdCheck = self.CurrentSongId
                            }
                            let songCount = playlistResponse.count
                            
                            let a = singlePluralCheck( NSLocalizedString(" song", comment: ""),  plural: NSLocalizedString(" songs", comment: ""), count: songCount)
                            
                            var totalView = ""
                            let musicIcon = "\u{f001}"
                            let playIcon = "\u{f04b}"
                            
                            totalView += "\(musicIcon) \(a)    "
                            if let views = response["play_count"] as? Int{
                                let a = singlePluralCheck( NSLocalizedString(" play", comment: ""),  plural: NSLocalizedString(" plays", comment: ""), count: views)
                                
                                totalView += "     \(playIcon) \(a) "
                            }
                            
                            self.songPlayLabel.text = totalView
                            self.songPlayLabel.textColor = textColorMedium
                            self.descriptionAttributedLabel.text = response["description"] as? String
                            self.descriptionAttributedLabel.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                            self.descriptionAttributedLabel.textColor = textColorDark//textColorMedium
                            self.descriptionAttributedLabel.sizeToFit()
                            self.descriptionResult = response["description"] as? String
                            self.moreOrLess()
                           
                            self.contentUrl = response["content_url"] as? String
                            self.mainSubView.sizeToFit()
                            
                            // play_count playlist_songs
                            var description = ""
                            let ownerName = response["owner_title"] as? String
                            
                            if ownerName != ""{
                                description = "\(ownerName!)\n"
                            }
                            let postedDate = response["creation_date"] as? String
                            if postedDate != ""{
                                let postedOn = dateDifference(postedDate!)
                                description += postedOn
                            }
                            
                            description += "\n"
                            
                            let viewCount = response["view_count"] as? Int
                            var viewInfo = ""
                            if viewCount > 1{
                                viewInfo =  String(format: NSLocalizedString("%d views", comment: ""), viewCount!)
                            }else{
                                viewInfo = String(format: NSLocalizedString("%d view", comment: ""), viewCount!)
                            }
                            
                            description += "\(viewInfo) , "
                            
                            let playCount = response["play_count"] as? Int
                            var playInfo = ""
                            if playCount > 1{
                                playInfo =  String(format: NSLocalizedString("%d plays", comment: ""), playCount!)
                            }else{
                                playInfo = String(format: NSLocalizedString("%d plays", comment: ""), playCount!)
                            }
                            description += "\(playInfo)"
                            self.musicTitle.textColor = textColorMedium
                            self.musicTitle.font = UIFont(name: fontName, size: FONTSIZESmall)
                            self.totalItems = playlistResponse.count
                        }
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        self.isPageRefresing = false
                        //Reload music Tabel
                        self.playlistTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if playlistResponse.count == 0{
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width , height: 50), text: NSLocalizedString("No updates at this moment . Check again any \nother time.",  comment: "") , alignment: .center, textColor: textColorLight)
                            self.info.center = self.view.center
                            self.info.backgroundColor = .white
                            self.info.font = UIFont(name: fontName, size: FONTSIZENormal)
                            self.info.numberOfLines = 2
                            self.info.tag = 1000
                            self.mainView.addSubview(self.info)
                            
                        }
                    }
                    else
                    {
                        
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
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set music Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set music Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.00001
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 11{
            return 44
        }else{
            return dynamicHeight
        }
    }
    
    // Set music Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 11 {
            return 3
        }else{
            return playlistResponse.count
        }
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView.tag == 11{
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            cell.textLabel?.textColor = UIColor.darkGray
            cell.textLabel?.text = ShareOption[(indexPath as NSIndexPath).row]
            return cell
            
        }
        else
        {

            var musicInfo:NSDictionary
            if playlistResponse.count > 0
            {
                musicInfo = playlistResponse[(indexPath as NSIndexPath).row] as! NSDictionary
                
                let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
                if descriptionResult != nil{
                    if descriptionResult == ""{
                        cell.frame.origin.y = 200
                    }else{
                        cell.frame.origin.y = descriptionAttributedLabel.bounds.height + 10
                    }
                    
                }
                else{
                    cell.frame.origin.y = 200
                }

                let songTitle = musicInfo["title"]!
//                let songPlayCount = musicInfo["play_count"] as! Int
//                cell.textLabel?.text = "\(musicIconn)    \(songTitle)"
//                cell.textLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                let label1 = createLabel(CGRect(x: 10, y: 0, width: view.bounds.width - 60, height: 50), text: "\(musicIconn)    \(songTitle)", alignment: .left, textColor: textColorDark)
                label1.font = UIFont(name: "FontAwesome", size:FONTSIZENormal)
                cell.contentView.addSubview(label1)
                // cell.accessoryView = nil
                if (browseOrMyMusic) {
                    cell.accessoryView = nil
                }
                else
                {
                    let optionMenu = createButton(CGRect(x: view.bounds.width - 40, y: 0, width: 40, height: cell.bounds.height),title: optionIcon, border: false, bgColor: false, textColor: textColorDark)
                    optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZENormal)
                    optionMenu.addTarget(self, action: #selector(MusicPlayListViewController.showMenu1(_:)), for: .touchUpInside)
                    optionMenu.tag = (indexPath as NSIndexPath).row
                    cell.accessoryView = optionMenu
                }
                if (musicPlaying)
                {
                    self.playerViewButton.isHidden = true
                    if((indexPath as NSIndexPath).row  == songIndex)
                    {
                        cell.backgroundColor = UIColor(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1.0)
                        
                    }
                    else
                    {
                        cell.backgroundColor = UIColor.white
                    }
                    
                }
                
                return cell
            }
            
        }
        
        let cell = UITableViewCell()
        return cell
    }
    
    @objc func showMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                let titleString = dic["name"] as! String
                
                if titleString.range(of: "delete") != nil{
                    alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                        // Write For Edit Album Entry
                        let condition = dic["name"] as! String
                        
                        switch(condition){
                            
                        case "delete":
                            displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this playlist?",comment: "") , otherButton: NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                                self.deletePlaylistEntry = true
                                self.updateMusic(dic["url"] as! String)
                            }
                            self.present(alert, animated: true, completion: nil)
                            
                        default:
                            showToast(message: unconditionalMessage, controller: self)
                            
                        }
                        
                        
                    }))
                }else{
                    let a = dic["name"] as! String
                    
                    if a != "edit" && a != "share"{
                        
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            
                            switch(condition){
                            case "report":
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
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
            popover?.sourceRect = CGRect(x: view.bounds.height-50, y: view.bounds.width, width: 0, height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    // Handle music Table Cell Selection
    func updateMusicMenuAction(_ url : String){
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
            let dic = Dictionary<String, String>()
            // Send Server Request to Explore Classified Contents with Classified_ID
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update Classified Detail
                        // Update Classified Detail
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        updateAfterAlert = false
                        self.browseEntries()
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
    
    @objc func showMenu1(_ sender:UIButton){
        
        var musicInfo:NSDictionary
        musicInfo = playlistResponse[sender.tag] as! NSDictionary
        let menuOption = ["Delete"]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for menu in menuOption{
            let titleString = menu
            if titleString.range(of: "Delete") != nil{
                
                alertController.addAction(UIAlertAction(title: (titleString ), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                    
                    let condition = titleString
                    
                    switch(condition){
                        
                        
                        
                    case "Delete":
                        let songId = musicInfo["song_id"] as! Int
                        let url = "/music/song/\(songId)/delete"
                        displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this song ?",comment: "") , otherButton: NSLocalizedString("Delete Playlist", comment: "")) { () -> () in
                            
                            self.updateMusicMenuAction(url )
                        }
                        self.present(alert, animated: true, completion: nil)
                    default:
                        showToast(message: unconditionalMessage, controller: self)
                    }
                    
                }))
                
            }
            
            
        }
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else if  (UIDevice.current.userInterfaceIdiom == .pad){
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            
            popover?.sourceView = UIButton()
            
            popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2 , width: 1, height: 1)
            
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
            
        }
        
        self.present(alertController, animated:true, completion: nil)
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
        if tableView.tag == 11{
            self.popover.dismiss()
            if (indexPath as NSIndexPath).row == 0{
                
                var sharingItems = [AnyObject]()
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
                
            }else if (indexPath as NSIndexPath).row == 1{
                
                let pv = AdvanceShareViewController()
                pv.url = self.shareUrl
                pv.param = self.shareParam as! [AnyHashable : Any] as NSDictionary
                pv.Sharetitle = self.playlistTitleString
                pv.imageString = self.imageProfile as String
                pv.ShareDescription = self.descriptionResult!
                pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: pv)
                self.present(nativationController, animated:true, completion: nil)

            }else if (indexPath as NSIndexPath).row == 2{
                UIPasteboard.general.url = URL(string: self.contentUrl)
                showToast(message: NSLocalizedString("Link copied.",comment: ""), controller: self)
            }
            
        }else{
            

            let presentedVC = PlayerViewController()
            //presentedVC.playListResponse = playlistResponse
            presentedVC.imageProfile = self.imageProfile as String
            presentedVC.changeSong = true

            let playlistResponseSong = playlistResponse[(indexPath as NSIndexPath).row] as! NSDictionary
            musicRestart = playlistResponseSong["song_id"] as! Int

            songIdCheck = musicRestart
            
            songIndex = (indexPath as NSIndexPath).row
            if musicCheck != ""{
                if checkStart == musicRestart{
                    presentedVC.changeSong = false
                }
                else{
                    pausingRemain = ""
                }
                
            }
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    func moreOrLess(){
        
        if let description = descriptionResult
        {
            
            var tempInfo = ""
            
            if description != ""
            {
                
                let tempTextLimit =  descriptionTextLimit - 20
                if description.length > tempTextLimit{
                    
                    if self.selectedMoreLess == false
                    {
                        
                        tempInfo += (description as NSString).substring(to: tempTextLimit-3)
                        
                        tempInfo += NSLocalizedString(" >> see more",  comment: "")
                        
                        self.topMainView.frame.size.height =  385
                        
                    }
                    else
                    {
                        
                        tempInfo += description
                        
                        tempInfo += NSLocalizedString("... less",  comment: "")
                        
                        self.topMainView.frame.size.height = 380 + descriptionAttributedLabel.bounds.height + 110
                        
                    }
                    
                }
                else
                {
                    
                    tempInfo += description
                    
                    // self.topMainView.frame.size.height = 380 + CGRectGetHeight(descriptionAttributedLabel.bounds)
                    self.topMainView.frame.size.height =  self.descriptionAttributedLabel.bounds.height + self.descriptionAttributedLabel.frame.origin.y
                    
                }
                
            }
            else
            {
                
                self.topMainView.frame.size.height =   300
            }
            
            self.descriptionAttributedLabel.numberOfLines = 0
            
            self.descriptionAttributedLabel.delegate = self
            
            self.descriptionAttributedLabel.font = UIFont(name: fontNormal, size: 14)
            
            self.descriptionAttributedLabel.textColor = textColorDark
            
            self.descriptionAttributedLabel.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in

                
                let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZENormal, nil)
                
                let range2 = (tempInfo as NSString).range(of: NSLocalizedString(">> see more",  comment: ""))
                
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTFontAttributeName as NSString) as String as String), value: boldFont, range: range2)
                
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTForegroundColorAttributeName as NSString) as String as String), value:textColorDark , range: range2)
                
                let range1 = (tempInfo as NSString).range(of: NSLocalizedString("less",  comment: ""))
                
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTFontAttributeName as NSString) as String as String), value: boldFont, range: range1)
                
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTForegroundColorAttributeName as NSString) as String as String), value:textColorDark , range: range1)
                
                // TODO: Clean this up...
                
                return mutableAttributedString
                
            })
            
            self.descriptionAttributedLabel.sizeToFit()
            
            let range = (tempInfo as NSString).range(of: NSLocalizedString(">> see more",  comment: ""))
            
            self.descriptionAttributedLabel.addLink(toTransitInformation: [ "type" : "moreContentInfo"], with:range)
            
            let range1 = (tempInfo as NSString).range(of: NSLocalizedString("less",  comment: ""))
            
            self.descriptionAttributedLabel.addLink(toTransitInformation: ["type" : "lessContentInfo"], with:range1)
            
            self.descriptionAttributedLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            
        }
        
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        
        let type = components["type"] as! String
        
        switch(type){
            
        case "moreContentInfo":
            
            selectedMoreLess = true
            
            self.moreOrLess()
            
            playlistTableView.reloadData()
            
            
            
        case "lessContentInfo":
            
            selectedMoreLess = false
            
            self.moreOrLess()
            
            playlistTableView.reloadData()
            
        default:
            
            print("error")
            
            //            fatalError("init(coder:) has not been implemented")
            
        }
        
    }
    
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        arrowView.isHidden = true
//        if updateScrollFlag{
//            // Check for Page Number for Browse Music
//            if playlistTableView.contentOffset.y >= playlistTableView.contentSize.height - playlistTableView.bounds.size.height{
//                if (!isPageRefresing  && limit*pageNumber < totalItems){
//
//
//                    if Reachabable.isConnectedToNetwork() {
//
//
//                        updateScrollFlag = false
//                        pageNumber += 1
//                        isPageRefresing = true
//                        if searchDic.count == 0{
//                            browseEntries()
//                        }
//                    }
//                }
//
//            }
//
//        }
        
        let scrollOffset = scrollView.contentOffset.y
        
        
        if (scrollOffset > 60.0){
            _ = self.navigationController?.navigationBar
            let barAlpha = max(0, min(1, (scrollOffset/125)))
            
            
            self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
            self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = textColorPrime
            self.marqueeHeader.text = self.playlistTitleString
            self.marqueeHeader.alpha = barAlpha
            self.navigationController?.navigationBar.alpha = barAlpha
            self.playListTitle.alpha = 1-barAlpha
            self.contentSelection.alpha = 1-barAlpha
            if (self.lastContentOffset > scrollView.contentOffset.y) {
                // move up
                self.like_comment.fadeIn()
            }
            else if (self.lastContentOffset < scrollView.contentOffset.y){
                // move down
                self.like_comment.fadeOut()
            }
            // update the new position acquired
            self.lastContentOffset = scrollView.contentOffset.y
            
        }else{
            _ = max(0, min(1, (scrollOffset/125)))
            removeNavigationImage(controller: self)
            self.marqueeHeader.alpha = 1
            self.like_comment.alpha = 1
            if (scrollOffset < 10.0){
                self.playListTitle.alpha = 1
                self.contentSelection.alpha = 1
            }
            
        }
        
        
        
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                if (!isPageRefresing  && limit*pageNumber < totalItems){
                    if Reachabable.isConnectedToNetwork() {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        playlistTableView.tableFooterView?.isHidden = false
                      
                        browseEntries()
                        //}
                    }
                }
                else
                {
                    playlistTableView.tableFooterView?.isHidden = true
                }
                
            }
            
        }
        
    }
    
    func handleLongPress(_ longPress: UILongPressGestureRecognizer) {
        switch longPress.state {
        case .changed:
            _ = longPress.location(in: view)

        default:
            break
        }
    }
    
    func updateMusic(_ url : String){
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
            
            let dic = Dictionary<String, String>()
            // Send Server Request to Explore music Contents with music_ID
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        // On Success Update music Detail
                        // Update music Detail
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if self.deletePlaylistEntry == true
                        {
                            musicUpdate = true
                            self.createTimer(self)
                            self.popAfterDelay = true
                            return
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
            
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        playlistTableView.tableFooterView?.isHidden = true

    self.marqueeHeader.text = ""
    removeMarqueFroMNavigaTion(controller: self)

        _ = self.navigationController?.navigationBar
        self.navigationItem.rightBarButtonItem = nil
        setNavigationImage(controller: self)
        
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }

    func showAlertMessage( _ centerPoint: CGPoint, msg: String){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        // Initialization of Timer
       self.createTimer(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }

    @objc func playerView(_ sender:UIButton){
        let presentedVC = PlayerViewController()
        // presentedVC.playListResponse = playlistResponse
        presentedVC.changeSong = false
        presentedVC.imageProfile = imageProfile as String
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    @objc func openOwnersProfile(_ sender:UIButton){
        
        if (ownerId != nil){
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(self.ownerId)"
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
        }
        removeNavigationImage(controller: self)
    }
    
    @objc func onImageViewTap()
    {
        if self.photourl != nil && self.photourl != "" {
            let presentedVC = SinglePhotoLightBoxController()
            presentedVC.imageUrl = self.photourl
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            present(nativationController, animated:false, completion: nil)
        }
    }
    
    @objc func shareItem(){
        
        let startPoint = CGPoint(x: self.view.frame.width - 72, y: 50)
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
        let ShareOptionHeightCount:CGFloat = CGFloat(44*ShareOption.count)
        let tableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: self.view.frame.width, height: ShareOptionHeightCount))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.tag = 11
        tableView.estimatedRowHeight = 34.0
        popover.show(tableView, point: startPoint)
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
