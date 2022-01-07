
//
//  BlogViewController.swift
//  SocailEngineDemoForSwift
//
//  Created by bigstep on 17/12/14.
//  Copyright (c) 2014 bigstep. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer

// Global Variable Initialization Used in Blog Module

class MusicPlayerViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate , TTTAttributedLabelDelegate {
    var musicTitle : TTTAttributedLabel!
    var sliderTimer = NSTimer()
    var playListId:Int!                        // Edit BlogID
    let mainView = UIView()
    var browseOrMyBlog = true                   // true for Browse Blog & false for My Blog
    var showSpinner = true                      // not show spinner at pull to refresh
    var blogResponse = [AnyObject]()            // For response come from Server
    var isPageRefresing = false                 // For Pagination
    var blogTableView:UITableView!              // TAbleView to show the blog Contents
    var browseBlog:UIButton!                    // Blog Types
    var myBlog:UIButton!
    var searchBar = UISearchBar()               // searchBar
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
    var fromActivityFeed = false
    var deleteBlogEntry:Bool!
    var objectId:Int!
    var showOnlyMyContent = true
    var bgImage: UIImageView!
    var imagePath: String!
    
    var pausePlay : UIButton!
    var previous : UIButton!
    var next : UIButton!
    var player:AVPlayer = AVPlayer()
    
    
    var CurrentSongId: Int!
    var currentPlayingSong: String!
    var currentTime:NSTimeInterval!
    
    var playSlider: UISlider!
    var beginTime:UILabel!
    var endTime:UILabel!
    
    
    var songIndex = 0

    
    // Flag to refresh Blog
    // Initialization of class Object
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        browseEntries()
       
        deleteBlogEntry = false;
        searchDic.removeAll(keepCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.hidden = false
        openMenu = false
        updateAfterAlert = true
        
        let subViews = mainView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        
        
        if showOnlyMyContent == false {
            // Add Side Menu as ChlildView Controller
            let sidePanelController = SidePanelViewController()
            addChildViewController(sidePanelController)
            sidePanelController.view.frame = CGRectMake(0, 0, 320 * 0.8, CGRectGetHeight(view.bounds))
            view.addSubview(sidePanelController.view)
            // Set left Menu Icon
            let menu = UIBarButtonItem(title:dashboardIcon, style: UIBarButtonItemStyle.Plain , target:self , action: "openSlideMenu")
            menu.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!], forState: UIControlState.Normal)
            self.navigationItem.leftBarButtonItem = menu
        }
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
      
        musicTitle = TTTAttributedLabel(frame:CGRectMake(PADING, TOPPADING, CGRectGetWidth(view.bounds), 80) )
        musicTitle.numberOfLines = 0
        musicTitle.delegate = self
        view.addSubview(musicTitle)
        let url = NSURL(string: imagePath)!
        
        let data = NSData(contentsOfURL: url) //make sure your image in this url does exist, otherwise unwrap in a if let check
        if(data != nil){
            var image: UIImage =  UIImage(data: data!)!
            bgImage = UIImageView(image: image)
        }
        bgImage!.frame = CGRectMake(PADING,TOPPADING+80,CGRectGetWidth(view.bounds),200)
        self.view.addSubview(bgImage!)

        
        
        
//        MPNowPlayingInfoCenter
        
        pausePlay = createButton(CGRectMake(PADING+(CGRectGetWidth(view.bounds))/3, TOPPADING+285 , (CGRectGetWidth(view.bounds))/3, 50), "\u{f04b}", true,false, textColorLight)
        pausePlay.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZENormal)
        pausePlay.layer.cornerRadius = cornerRadiusNormal
        pausePlay.backgroundColor = navColor//UIColor.redColor()
        pausePlay.layer.masksToBounds = true
        pausePlay.addTarget(self, action: "pausePlayAction:", forControlEvents: .TouchUpInside)
        
        // pausePlay.addTarget(self, action: <#Selector#>, forControlEvents: .Normal)
        view.addSubview(pausePlay)
        
        if(player.error == nil){
            sliderTimer =  NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("configurePlayer"), userInfo: nil, repeats: true)
        }
        
        previous = createButton(CGRectMake(PADING, TOPPADING+285 , (CGRectGetWidth(view.bounds))/3, 50), "\u{f04a}", true,false, textColorLight)
        previous.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZENormal)
        previous.layer.cornerRadius = cornerRadiusNormal
        previous.backgroundColor =  navColor //UIColor.redColor()
        previous.layer.masksToBounds = true
        
        previous.addTarget(self, action: "previousButton:", forControlEvents: .TouchUpInside)
        
        view.addSubview(previous)
        
        
        next = createButton(CGRectMake(PADING+2*((CGRectGetWidth(view.bounds))/3), TOPPADING+285 , (CGRectGetWidth(view.bounds))/3, 50), "\u{f04e}", true,false, textColorLight)
        next.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZENormal)
        next.layer.cornerRadius = cornerRadiusNormal
        next.backgroundColor = navColor //UIColor.redColor()
        next.layer.masksToBounds = true
        next.addTarget(self, action: "nextButton:", forControlEvents: .TouchUpInside)
        view.addSubview(next)
        
        
        playSlider = UISlider(frame:CGRectMake(PADING + 65, TOPPADING+350, CGRectGetWidth(view.bounds) - 150, 20))
        playSlider.minimumValue = 0.0
        
//        var duration = self.player.currentItem.asset.duration as CMTime;
//        var tempPlayingTime = CMTimeGetSeconds(duration) as Float64;
//        totalPlayingTime = Float(tempPlayingTime)
//        
//        refreshPlayer();
        playSlider.continuous = true
        playSlider.tintColor = navColor //UIColor.redColor()
        playSlider.value = 0
        playSlider.addTarget(self, action: "sliderValueDidChange:", forControlEvents: .ValueChanged)
        self.view.addSubview(playSlider)
        playSlider.backgroundColor = UIColor.redColor()
        
        
        
        beginTime = createLabel(CGRectMake(PADING + 10, TOPPADING+350, 50, 20), "", .Left, textColorDark)
        //        groupTitle.layer.shadowColor = UIColor.lightGrayColor().CGColor
        //        groupTitle.numberOfLines = 0
        //        groupTitle.layer.shadowOpacity = 1.0
        //        groupTitle.layer.shadowRadius = 4.0
        beginTime.numberOfLines = 0
        beginTime.layer.shadowColor = shadowColor.CGColor
        beginTime.layer.shadowOpacity = shadowOpacity
        beginTime.layer.shadowRadius = shadowRadius
        beginTime.layer.shadowOffset = shadowOffset
        self.view.addSubview(beginTime)
        
        
        endTime = createLabel(CGRectMake(CGRectGetWidth(view.bounds) - 150 + PADING + 65, TOPPADING+350, 50, 20), "", .Left, textColorDark)
        //        groupTitle.layer.shadowColor = UIColor.lightGrayColor().CGColor
        //        groupTitle.numberOfLines = 0
        //        groupTitle.layer.shadowOpacity = 1.0
        //        groupTitle.layer.shadowRadius = 4.0
        endTime.numberOfLines = 0
        endTime.layer.shadowColor = shadowColor.CGColor
        endTime.layer.shadowOpacity = shadowOpacity
        endTime.layer.shadowRadius = shadowRadius
        endTime.layer.shadowOffset = shadowOffset
        self.view.addSubview(endTime)
        //         self.endTime.text = "srijan"
        



 
        // Initialize Blog Table
        blogTableView = UITableView(frame: CGRectMake(0, TOPPADING+350  , CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)), style: .Grouped)
        blogTableView.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        blogTableView.dataSource = self
        blogTableView.delegate = self
        blogTableView.estimatedRowHeight = 50.0
        blogTableView.rowHeight = UITableViewAutomaticDimension
        blogTableView.backgroundColor = tableViewBgColor
        blogTableView.separatorColor = TVSeparatorColor
        mainView.addSubview(blogTableView)
        
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        blogTableView.addSubview(refresher)
        
        
        if logoutUser == true || showOnlyMyContent == true{
           
//            filter.frame.origin.y = TOPPADING
            searchBar.frame.origin.y = TOPPADING
//            blogTableView.frame.origin.y = CGRectGetHeight(filter.bounds) + 2 * contentPADING + filter.frame.origin.y
//            blogTableView.frame.size.height = CGRectGetHeight(view.bounds) - (CGRectGetHeight(filter.bounds) + 2 * contentPADING + filter.frame.origin.y)
            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.Plain , target:self , action: "cancleSearch")
            self.navigationItem.rightBarButtonItem = addCancel
            
            
        }
        
        
        
        
        //   self.edgesForExtendedLayout = UIRectEdge.None;
        //   self.automaticallyAdjustsScrollViewInsets = true;
        
    }
    
    
    
    // Check for Blog Update Every Time when View Appears
    override func viewDidAppear(animated: Bool) {
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        blogTableView.reloadData()
            pageNumber = 1
            searchBar.text = ""
            updateScrollFlag = false
            browseEntries()
    }
    
    
    // Show Slide Menu
    func openSlideMenu(){
        // Add TapGesture On Open Slide Menu
        if openMenu{
            openMenu = false
        }else{
            openMenu = true
            tapGesture = tapGestureCreation(self)
        }
        // openMenuSlideOnView(mainView)
        openMenuSlideOnView(mainView)
        
    }
    
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    // Check Condition when Search is Enable
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return false
        }else{
            return true
        }
    }
    
    
    // Handle Simple Search on Search Click
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        // Add search text to searchDic
        searchDic.removeAll(keepCapacity: false)
        searchDic["search"] = searchBar.text
        pageNumber = 1
        blogResponse.removeAll(keepCapacity: false)
        searchBar.resignFirstResponder()
        // Update Blog for Search Text
        
        if searchBar.text != "" && logoutUser == true{
            self.navigationItem.rightBarButtonItem?.title = "Cancle"
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        
        browseEntries()
    }
    
    
    // Cancle Search Result for Logout User
    func cancleSearch(){
        searchDic.removeAll(keepCapacity: false)
        searchDic["search"] = ""
        pageNumber = 1
        
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.enabled = false
        browseEntries()
    }
    
    
    // Open Filter Search Form
    func filterSerach(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            searchBar.text = ""
            searchBar.resignFirstResponder()
            searchDic.removeAll(keepCapacity: false)
            var presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "blogs/browse-search-form"
            presentedVC.serachFor = "blog"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    
    // Create Blog Form
    func addNewBlog(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            isCreateOrEdit = true
            var presentedVC = FormGenerationViewController()
            presentedVC.formTitle = NSLocalizedString("Write New Entry", comment: "")
            presentedVC.contentType = "blog"
            presentedVC.param = [ : ]
            presentedVC.url = "blogs/create"
            
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    
    
    
    // Handle Browse Blog or My Blog PreAction
    func prebrowseEntries(sender: UIButton){
        // true for Browse Blog & false for My Blog
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        if sender.tag == 22 {
            browseOrMyBlog = false
        }else if sender.tag == 11 {
            browseOrMyBlog = true
        }
        self.blogResponse.removeAll(keepCapacity: false)
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchDic.removeAll(keepCapacity: false)
        updateScrollFlag = false
        pageNumber = 1
        // Update for Blog
        browseEntries()
    }
    
    
    // Pull to Request Action
    func refresh(){
        // Check Internet Connectivity
        //  if blogResponse.count != 0{
        if reachability.isReachable() {
            searchBar.text = ""
            searchBar.resignFirstResponder()
            searchDic.removeAll(keepCapacity: false)
            
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            
            browseEntries()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            self.showAlertMessage(mainView.center , msg: network_status_msg , timer: false)
        }
        //   }
    }
    
    
    // Generate Custom Alert Messages
    func showAlertMessage( centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg)
        if timer {
            // Initialization of Timer
            createTimer(self)
        }
    }
    
    // Stop Timer
    func stopTimer() {
        stop()
    }
    // MARK: - Server Connection For Blog Updation
    
    // For delete  a Blog
    func updateBlogMenuAction(parameter: NSDictionary , url : String){
        // Check Internet Connection
        if reachability.isReachable() {
            removeAlert()
            spinner.center = view.center
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(spinner)
            spinner.startAnimating()
            
            
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver
                }
            }
            dic["token"] = "\(auth_token)"
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, "\(url)", "POST") { (succeeded, msg) -> () in
                dispatch_async(dispatch_get_main_queue(), {
                    spinner.stopAnimating()
                    
                    if msg{
                        // On Success Update Blog Detail
                        // Update Blog Detail
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center,msg: succeeded["message"] as String, timer: true )
                        }
                        updateAfterAlert = false
                        self.browseEntries()
                    }
                        
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center,msg: succeeded["message"] as String, timer: false )
                        }
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    
    
    // Update Blog
    func browseEntries(){
        
        // Check Internet Connectivity
        if reachability.isReachable() {
            
            if showOnlyMyContent == true{
                browseOrMyBlog = false
            }
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            
            if (self.pageNumber == 1){
                self.blogResponse.removeAll(keepCapacity: false)
                
                if updateAfterAlert == true || searchDic.count > 0 {
                    removeAlert()
                    self.blogTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
                spinner.center = mainView.center
                if updateScrollFlag == false {
                    spinner.center = CGPoint(x: view.center.x, y: view.bounds.height-50)
                }
                if (self.pageNumber == 1){
                    spinner.center = mainView.center
                    updateScrollFlag = false
                }
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                view.addSubview(spinner)
                spinner.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            // Set Parameters for Browse/MyBlog
           
                path = "music/playlist/view"
                parameters = ["token":"\(auth_token)","playlist_id":"\(playListId)", "gutter_menu": "1"]
            
                self.title = NSLocalizedString("Browse Entries",  comment: "")
            
            
            
           
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Blog Entries
            post(parameters, path, "GET") { (succeeded, msg) -> () in
                
                dispatch_async(dispatch_get_main_queue(),{
                    
                    if self.showSpinner{
                        spinner.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = true
                    self.updateScrollFlag = true
                    //})
                    
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.blogResponse.removeAll(keepCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.mainView.center , msg: succeeded["message"] as String, timer: true)
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if let menu = response["gutterMenu"] as? NSArray{
                                gutterMenu  = menu
                                let menu = UIBarButtonItem(image: UIImage(named:"icon-option.png"), style: UIBarButtonItemStyle.Plain , target:self , action: "showMenu")
                                self.navigationItem.rightBarButtonItem = menu
                            }
                            
                            
                            self.title = response["title"] as? String
                            
                                 if let blog = response["playlist_songs"] as? NSArray {
                                    self.blogResponse += blog
                                    
                                    self.setCurrentSoundTrack(self.blogResponse[0]["filePath"]! as String)
                                    self.CurrentSongId = self.blogResponse[0]["song_id"]! as Int

                                    
                                }
                            
                            
                            var description = ""
                            var ownerName = response["owner_title"] as? String
                            if ownerName != ""{
                                description = "\(ownerName!)\n"
                            }
                            var postedDate = response["creation_date"] as? String
                            if postedDate != ""{
                                var postedOn = dateDifference(postedDate!)
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
                            
                            var playCount = response["play_count"] as? Int
                            var playInfo = ""
                            if playCount > 1{
                                playInfo =  String(format: NSLocalizedString("%d plays", comment: ""), playCount!)
                            }else{
                                playInfo = String(format: NSLocalizedString("%d plays", comment: ""), playCount!)
                            }
                            description += "\(playInfo)"
                            self.musicTitle.textColor = textColorMedium
                            self.musicTitle.font = UIFont(name: fontName, size: FONTSIZESmall)
                            //
                            self.musicTitle.setText(description, afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString: NSMutableAttributedString!) -> NSMutableAttributedString! in
                                //                                                        var boldFont = CTFontCreateWithName( fontBold, FONTSIZESmall, nil)
                                //
                                //                                                        let range = (description as NSString).rangeOfString(categoryTitle!)
                                //                                                        mutableAttributedString.addAttribute(kCTFontAttributeName as NSString, value: boldFont, range: range)
                                //                                                        mutableAttributedString.addAttribute(kCTForegroundColorAttributeName as NSString, value:textColorDark , range: range)
                                
                                
                                var boldFont =  CTFontCreateWithName( fontBold, FONTSIZENormal, nil)
                                
                                let range1 = (description as NSString).rangeOfString(ownerName!)
                                mutableAttributedString.addAttribute(kCTFontAttributeName as NSString, value: boldFont, range: range1)
                                mutableAttributedString.addAttribute(kCTForegroundColorAttributeName as NSString, value:textColorDark , range: range1)
                                
                                return mutableAttributedString
                            })

                            
                            
                            
//                            }
                            
//                            if response["totalItemCount"] != nil{
                                self.totalItems = self.blogResponse.count as Int
//                            }
                            
                            if self.showOnlyMyContent == false {
                                
                            }
                        }
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        self.isPageRefresing = false
                        //Reload Blog Tabel
                        self.blogTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.blogResponse.count == 0{
                            
                            self.info = createLabel(CGRectMake(0, 0,CGRectGetWidth(self.view.bounds) * 0.8 , 50), NSLocalizedString("You do not have any blog entries. Get started by writing a new entry.",  comment: "") , .Center, textColorLight)
                            self.info.center = self.view.center
                            self.info.layer.cornerRadius = 25.0
                            self.info.layer.masksToBounds = true
                            self.info.backgroundColor = UIColor.blackColor()
                            self.info.tag = 1000
                            self.mainView.addSubview(self.info)
                            
                        }
                        //   }
                        // })
                        
                    }else{
                        
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.mainView.center , msg: succeeded["message"] as String, timer: false)
                        }
                        
                    }
                    
                })
            }
        }else{
            // No Internet Connection Message
            self.showAlertMessage(mainView.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Blog Tabel Footer Height
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 80
            
        }else{
            return 0.00001
        }
    }
    
    // Set Blog Tabel Header Height
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set Blog Section
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return blogResponse.count
    }
    
    // Set Cell of TabelView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var blogInfo:NSDictionary
        blogInfo = blogResponse[indexPath.row] as NSDictionary
      
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        
        var songTitle = blogInfo["title"] as String;
        
       var songPlayCount = blogInfo["play_count"] as Int;
        cell.textLabel?.text = songTitle
        
        if songPlayCount > 1{
            cell.detailTextLabel?.text =  String(format: NSLocalizedString("%d plays", comment: ""), songPlayCount)
        }else{
            cell.detailTextLabel?.text = String(format: NSLocalizedString("%d play", comment: ""), songPlayCount)
        }
        
        return cell
        
    }
    
    func showMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        searchDic.removeAll(keepCapacity: false)
        
        var title = ""
        
        alertController.addAction(UIAlertAction(title: title, style: .Default, handler:{ (UIAlertAction) -> Void in
            
        }))
        
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                
                alertController.addAction(UIAlertAction(title: (dic["label"] as String), style: .Default, handler:{ (UIAlertAction) -> Void in
                    // Write For Edit Album Entry
                    var condition = dic["name"] as String
                    
                    println(condition)
                    
                    switch(condition){
                        
                    case "share":
                        var presentedVC = ShareContentViewController()
                        presentedVC.param = dic["urlParams"] as NSDictionary
                        presentedVC.url = dic["url"] as String
                        presentedVC.shareContentTitle = self.title
                        presentedVC.shareContentSubTitle = "" //self.contentDescription
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        
                    case "report":
                        var presentedVC = ReportContentViewController()
                        presentedVC.param = dic["urlParams"] as NSDictionary
                        presentedVC.url = dic["url"] as String
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                        
                    case "delete_playlist":
                        
                        displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),NSLocalizedString("Are you sure you want to delete this playlist?",comment: "") , NSLocalizedString("Delete Entry", comment: "")) { () -> () in
                            self.deleteBlogEntry = true
                            self.updateMusic(dic["urlParams"] as NSDictionary ,url: dic["url"] as String)
                        }
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                    default:
                        fatalError("init(coder:) has not been implemented")
                    }
                    
                    
                }))
            }
        }
        if  (UIDevice.currentDevice().userInterfaceIdiom == .Phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .Cancel, handler:nil))
        }else{
            // Present Alert as Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRectMake(view.bounds.height-50, view.bounds.width, 0, 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.Up
        }
        self.presentViewController(alertController, animated:true, completion: nil)
        
    }
    
    // Handle Blog Table Cell Selection
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var blogInfo:NSDictionary
        blogInfo = blogResponse[indexPath.row] as NSDictionary
        songIndex = indexPath.row
        var song = blogInfo["filePath"]! as String
        CurrentSongId = blogInfo["song_id"]! as Int
        playSong(song as String)
        pausePlay.setTitle("\u{f04c}", forState: UIControlState.Normal)
        
    }
    
    
    
    
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if updateScrollFlag{
            // Check for Page Number for Browse Blog
            if blogTableView.contentOffset.y >= blogTableView.contentSize.height - blogTableView.bounds.size.height{
                if (!isPageRefresing  && limit*pageNumber < totalItems){
                    if reachability.isReachable() {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        if searchDic.count == 0{
                            browseEntries()
                        }
                    }
                }
                
            }
            
        }
        
    }
    
    //    override func viewWillDisappear(animated: Bool) {
    //    
    //        mainView.removeGestureRecognizer(tapGesture)
    //       //  searchDic.removeAll(keepCapacity: false)
    //    }
    
    
    
    func updateMusic(parameter: NSDictionary, url : String){
        // Check Internet Connection
        if reachability.isReachable() {
            removeAlert()
            spinner.center = view.center
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(spinner)
            spinner.startAnimating()
            
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver
                }
            }
            dic["token"] = "\(auth_token)"
            
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, "\(url)", "POST") { (succeeded, msg) -> () in
                dispatch_async(dispatch_get_main_queue(), {
                    spinner.stopAnimating()
                    if msg{
                        // On Success Update Blog Detail
                        // Update Blog Detail
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center,msg: succeeded["message"] as String )
                        }
                        if self.deleteBlogEntry == true{
                            musicUpdate = true
                            //                            self.popAfterDelay = true
                            return
                        }
                        self.browseEntries()
                        
                    }
                        
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center,msg: succeeded["message"] as String)
                        }
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg)
        }
        
    }
    
    
    func showAlertMessage( centerPoint: CGPoint, msg: String){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg)
        // Initialization of Timer
        createTimer(self)
    }
    
    func pausePlayAction(sender:UIButton){
        playPause()
    }
    func playPause(){
       
        println(player.rate)

        println(CurrentSongId)
        
        println(blogResponse[songIndex]["filePath"]! as String)
        
        if (player.rate > 0 && player.error == nil) {
            
            println("playing")
            
            pausePlay.setTitle("\u{f04b}", forState: UIControlState.Normal)
            
//            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
//            AVAudioSession.sharedInstance().setActive(true, error: nil)
//            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
            
            player.pause();

            
            
        }else{
            
//            updatePlayCount();
            println("pausing")
            
            if(currentTime != nil){
                pausePlay.setTitle("\u{f04c}", forState: UIControlState.Normal)
                self.player.play()
            }else{
                pausePlay.setTitle("\u{f04c}", forState: UIControlState.Normal)
                 playSong(blogResponse[songIndex]["filePath"]! as String)
            }
            
//             pausePlay.setTitle("\u{f04c}", forState: UIControlState.Normal)
            
            
//            let mpic = MPNowPlayingInfoCenter.defaultCenter()
//            mpic.nowPlayingInfo = [
//                MPMediaItemPropertyTitle: titleSong,
//                MPMediaItemPropertyArtist:"Srijan",
//                MPMediaItemPropertyPlaybackDuration : CMTimeGetSeconds(self.player.currentItem.asset.duration),
//                MPNowPlayingInfoPropertyPlaybackRate : 1
//            ]
            
            
            
//                playSong(blogResponse[songIndex]["filePath"]! as String)
            
//            AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
//            AVAudioSession.sharedInstance().setActive(true, error: nil)
//            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
//            player.play()
           
            
        }
        
    }
    
    
    func nextButton(sender:UIButton){
        nextPlay()
    }
    func nextPlay(){
        if (songIndex == self.blogResponse.count - 1){
            
            println("11223334")
            
            var song = blogResponse[0]["filePath"]! as String
            CurrentSongId = self.blogResponse[0]["song_id"]! as Int
            playSong(song as String)
            pausePlay.setTitle("\u{f04c}", forState: UIControlState.Normal)

        }else{
            
             println("1223")
            
        var song = blogResponse[songIndex+1]["filePath"]! as String
            
            CurrentSongId = self.blogResponse[songIndex+1]["song_id"]! as Int
            
        songIndex = songIndex + 1
        playSong(song as String)
        pausePlay.setTitle("\u{f04c}", forState: UIControlState.Normal)
        }
    }
    func previousButton(sender:UIButton){
        pre()
    }
    func pre(){
        if (songIndex == 0){
            songIndex = blogResponse.count - 1
            CurrentSongId = self.blogResponse[songIndex]["song_id"]! as Int
            
            var song = blogResponse[songIndex]["filePath"]! as String
            songIndex = songIndex - 1
            playSong(song as String)
            pausePlay.setTitle("\u{f04c}", forState: UIControlState.Normal)
        }else{
        var song = blogResponse[songIndex-1]["filePath"]! as String
        songIndex = songIndex - 1
        CurrentSongId = self.blogResponse[songIndex]["song_id"]! as Int
        playSong(song as String)
        pausePlay.setTitle("\u{f04c}", forState: UIControlState.Normal)
        }
    }
    
    func playSong(currentSoundTrack: String){
        
        println(currentSoundTrack)
        setCurrentSoundTrack(currentSoundTrack)
        
        
        var titleSong = blogResponse[songIndex]["title"]! as String
        
        println("ssssssss")
        player.play()
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()

        
        let mpic = MPNowPlayingInfoCenter.defaultCenter()
        mpic.nowPlayingInfo = [
            MPMediaItemPropertyTitle: titleSong,
            MPMediaItemPropertyArtist:"Srijan",
            MPMediaItemPropertyPlaybackDuration : CMTimeGetSeconds(self.player.currentItem.asset.duration),
            MPNowPlayingInfoPropertyPlaybackRate : 1
        ]

//        self.updatePlayCount()
        
        println("tttt")
        
        
        
        
        
        
//                if(player.error == nil){
//                    sliderTimer =  NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("configurePlayer"), userInfo: nil, repeats: true)
//                }
        
        
    }
    
    
    func setCurrentSoundTrack(currentSoundTrack: String){
     
        
        var steamingURL:NSURL! = NSURL(string:currentSoundTrack)
        self.player = AVPlayer(URL: steamingURL)
        
        let currentItem:AVPlayerItem = self.player.currentItem
         currentTime = CMTimeGetSeconds(currentItem.currentTime())
        
      
    }

   
    func configurePlayer(){
        
        if(self.player.currentItem != nil){
            let currentItems:AVPlayerItem = self.player.currentItem
            let tempCurrentTime:Float64 = CMTimeGetSeconds(currentItems.currentTime())
            let currentTime = Float(tempCurrentTime)
            
            let totaltime =  CMTimeGetSeconds(self.player.currentItem.asset.duration)
         
            
            if(self.player.currentItem != nil){
                let currentItems:AVPlayerItem = self.player.currentItem
                let tempCurrentTime:Float64 = CMTimeGetSeconds(currentItems.currentTime())
                let currentTime = Float(tempCurrentTime)
                
                println(currentTime)
                
                self.playSlider.minimumValue = 0.0
                
                self.playSlider.maximumValue = Float(totaltime)
                
                self.beginTime.text = "\(currentTime)"
                    
                    self.endTime.text = "\(totaltime)"
                
                println(Float(totaltime))
                
                playSlider.value = currentTime
//                var a = convertIntoSecondString(currentTime)
//                self.beginTime.text = a
            }
            
            
            if (totaltime == tempCurrentTime){
                
                
                self.nextPlay()
            }
            
            
//            playSlider.value = currentTime
//            var a = convertIntoSecondString(currentTime)
//            self.beginTime.text = a
        }
    }
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent) {
        let rc = event.subtype
        
        let p = self.player
        switch rc.rawValue {
        case 105:           // Previous
            
            if (player.rate > 0 && player.error == nil) {
                p.pause()
            }
            
            pre()
        case 101:           // Play Pause
            playPause()
        case 100:           // Play Pause
            playPause()
            
        case 104:           // Next
            
            if (player.rate > 0 && player.error == nil) {
              p.pause()
            }
            
            nextPlay()
        default:break
        }
        
    }
    
    
    
    func updatePlayCount(){
        post(["token":"\(auth_token)","song_id":"\(CurrentSongId!)"], "music/song/tally", "POST") {
            (succeeded, msg) -> () in
            
            dispatch_async(dispatch_get_main_queue(), {
                spinner.stopAnimating()
                if msg{
                    
                   if succeeded["message"] != nil{
                        self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
                    }
                }else{
                    // Handle Server Side Error
                    if succeeded["message"] != nil{
                        self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
                        
                    }
                }
            })
            self.browseEntries()
        }
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
