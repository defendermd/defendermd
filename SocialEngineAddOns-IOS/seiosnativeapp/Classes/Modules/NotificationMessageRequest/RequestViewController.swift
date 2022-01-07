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
//  RequestViewController.swift
//  seiosnativeapp

import UIKit
import NVActivityIndicatorView

class RequestViewController: UIViewController , UITableViewDataSource, UITableViewDelegate  {
    let mainView = UIView()
    var showSpinner = true                      // not show spinner at pull to refresh
    var blogResponse = [AnyObject]()            // For response come from Server
    var isPageRefresing = false                 // For Pagination
    var requestTableView:UITableView!              // TAbleView to show the blog Contents
    var notifications:UIButton!                    // Blog Types
    var requests:UIButton!
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 500.0              // Dynamic Height fort for Cell
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent = false
    var requestIcon : UILabel!
    var refreshButton : UIButton!
    var leftBarButtonItem : UIBarButtonItem!
    
    // Initialization of class Object
    override func viewDidLoad() {
        
        super.viewDidLoad()
        blogUpdate = true
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        openMenu = false
        updateAfterAlert = true
        isPageRefresing = true
        let subViews = mainView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        requestIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(requestIcon)
        requestIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        
        
        self.title = NSLocalizedString("Requests",  comment: "")
        
        
        
        notifications = createNavigationButton(CGRect(x: 0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) , title: NSLocalizedString("Notifications",  comment: ""), border: true, selected: false)
        notifications.tag = 11
        notifications.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)

        notifications.addTarget(self, action: #selector(RequestViewController.notificationButton(_:)), for: .touchUpInside)
        mainView.addSubview(notifications)
        
        requests = createNavigationButton(CGRect(x: view.bounds.width/2.0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) , title: NSLocalizedString("Requests",  comment: ""), border: true, selected: true)
        requests.tag = 22
        requests.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        requests.addTarget(self, action: #selector(RequestViewController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(requests)
        
        
        // Initialize Blog Table
        requestTableView = UITableView(frame: CGRect(x: 0, y: requests.bounds.height + requests.frame.origin.y  , width: view.bounds.width, height: view.bounds.height-(requests.bounds.height + requests.frame.origin.y) - tabBarHeight ), style: .grouped)
        requestTableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: "Cell")
        requestTableView.dataSource = self
        requestTableView.delegate = self
        requestTableView.estimatedRowHeight = 50.0
        requestTableView.rowHeight = UITableView.automaticDimension
        requestTableView.backgroundColor = tableViewBgColor
        requestTableView.separatorColor = TVSeparatorColor
        if #available(iOS 11.0, *) {
            self.requestTableView.estimatedRowHeight = 0
            self.requestTableView.estimatedSectionHeaderHeight = 0
            self.requestTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(requestTableView)
        
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(RequestViewController.refresh), for: UIControl.Event.valueChanged)
        requestTableView.addSubview(refresher)
   
        
        if logoutUser == true || showOnlyMyContent == true{
            notifications.isHidden = true
            requests.isHidden = true
            requests.frame.origin.y = TOPPADING
            requestTableView.frame.origin.y = requests.bounds.height + 2 * contentPADING + requests.frame.origin.y
            requestTableView.frame.size.height = view.bounds.height - (requests.bounds.height + 2 * contentPADING + requests.frame.origin.y)
            
        }
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        requestTableView.tableFooterView = footerView
        requestTableView.tableFooterView?.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        removeNavigationViews(controller: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        requestTableView.tableFooterView?.isHidden = true
    }
    // Check for  Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        
        requestTableView.reloadData()
        
        if (blogUpdate == true && isPageRefresing == true){
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            browseEntries()
        }
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    // Handle Browse Blog or My Blog PreAction
    @objc func prebrowseEntries(_ sender: UIButton){
        // true for Browse Blog & false for My Blog
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        requestTableView.tableFooterView?.isHidden = true
        self.blogResponse.removeAll(keepingCapacity: false)
        updateScrollFlag = false
        pageNumber = 1
        showSpinner = true
        // Update for Blog
        browseEntries()
    }
    
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        //  if blogResponse.count != 0{
        if Reachabable.isConnectedToNetwork() {
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
    @objc func stopTimer() {
        stop()
    }
    
    // MARK: - Server Connection For Blog Updation
    
    // For delete  a Blog
    func updateBlogMenuAction(_ parameter: NSDictionary , url : String){
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
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update Blog Detail
                        // Update Blog Detail
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
    
    // Update Blog
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            requestIcon.isHidden = true
            refreshButton.isHidden = true
            
            
            if (self.pageNumber == 1){
                self.blogResponse.removeAll(keepingCapacity: false)
                
                if updateAfterAlert == true || searchDic.count > 0 {
                    removeAlert()
                    self.requestTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
          //      spinner.center = mainView.center
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
               // activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            // Set Parameters for Browse/MyBlog
            path = "notifications"
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "myRequests": "1", "recentUpdates" : "0"]
            requests.setSelectedButton()
            notifications.setUnSelectedButton()
            self.title = NSLocalizedString("Requests",  comment: "")
            // Set Parameters for Search
            
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    //})
                    self.requestTableView.tableFooterView?.isHidden = true
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.blogResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if let blog = response["myRequests"] as? NSArray {
                                self.blogResponse = self.blogResponse + (blog as [AnyObject])
                            }
                            
                            if response["requestTotalItemCount"] != nil{
                                self.totalItems = response["requestTotalItemCount"] as! Int
                            }
                            
                        }
                        
                        
                        self.isPageRefresing = false
                        
                        //Reload Blog Tabel
                        self.requestTableView.reloadData()
                        
                        if self.blogResponse.count == 0{
                            
                            self.requestIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 25, y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(friendReuestIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            
                            self.requestIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.mainView.addSubview(self.requestIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You don't have any pending request.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.sizeToFit()
                            self.info.numberOfLines = 0
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.mainView.addSubview(self.info)
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)

                            self.refreshButton.addTarget(self, action: #selector(RequestViewController.browseEntries), for: UIControl.Event.touchUpInside)

                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.mainView.addSubview(self.refreshButton)
                            
                            self.requestIcon.isHidden = false
                            self.refreshButton.isHidden = false
                            
                            
                            
                        }
                        
                    }else{
                        
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
    
    // Set Blog Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Blog Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            dynamicHeight = 70.0
        }else{
            dynamicHeight = 90.0
        }
        
        return dynamicHeight
    }
    
    // Set Blog Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return blogResponse.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotificationTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.blue
        
        var blogInfo:NSDictionary
        blogInfo = blogResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        
        // Set Blog Title
        cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10,width: (UIScreen.main.bounds.width - 75) , height: 100)
        
        cell.labTitle.text = blogInfo["title"] as? String
        cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.labTitle.sizeToFit()
        
        let type = blogInfo["type"] as! String
        
        if let ownerName = blogInfo["feed_title"] as? String {
            if let postedDate = blogInfo["date"] as? String{
                let postedOn = dateDifference(postedDate)
                cell.labMessage.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10,width: (UIScreen.main.bounds.width - 75) , height: 100)
                
                var labMsg = ""
                
                
                var iconType : String
                if(type == "liked"){
                    iconType = likeIcon
                }else if(type == "commented_commented" || type == "commented"){
                    iconType = commentIcon
                }else if(type == "shared"){
                    iconType = shareIcon
                }else if(type.range(of: "message") != nil){
                    iconType = messageIcon
                }else if(type.range(of: "subscribe") != nil){
                    iconType = subscribeIcon
                }else if(type.range(of: "friend") != nil){
                    iconType = friendReuestIcon
                }else if(type == "group_invite"){
                    iconType = inviteIcon
                }else if(type == "event_invite"){
                    iconType = inviteIcon
                }
                else{
                    iconType = notificationDefaultIcon
                }
                
                labMsg = String(format: NSLocalizedString("%@ \n\n%@ %@", comment: ""), ownerName, iconType, postedOn )
                
                cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                    let boldFont = CTFontCreateWithName( (fontName as CFString?)! , FONTSIZENormal, nil)
                    
                    let range = (labMsg as NSString).range(of: ownerName)
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value: textColorDark, range: range)

                    
                    let range1 = (labMsg as NSString).range(of: iconType)
                    
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range1)
                    
                    mutableAttributedString?.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size:FONTSIZENormal)!, range: range1)
                    // TODO: Clean this up..
                    return mutableAttributedString
                })
                
            }
        }
        
        cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.labMessage.sizeToFit()
        
        let subject = blogInfo["subject"] as! NSDictionary
        
        let url = URL(string: subject["image_profile"] as! String)
        let fileName = "\((url?.lastPathComponent)!)"
        let ownerImage:Data = getImageFromCache(fileName)
        if ownerImage.count == 0 {
            if url != nil
            {
                cell.imgUser.kf.indicatorType = .activity
                (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
            }

        }
        // Set cell accessoryType
        
        if(type == "event_invite"){
            
            let optionMenu = createButton(CGRect(x: view.bounds.width - 30, y: 35, width: 30, height: 35), title: optionIcon, border: false, bgColor: false, textColor: textColorDark)
            optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)

            optionMenu.addTarget(self, action: #selector(RequestViewController.showEventOptions(_:)), for: .touchUpInside)

            optionMenu.tag = (indexPath as NSIndexPath).row
            cell.accessoryView = optionMenu
        }else if(type == "group_invite"){
            let optionMenu = createButton(CGRect(x: view.bounds.width - 30, y: 35, width: 30, height: 35), title: optionIcon, border: false, bgColor: false, textColor: textColorDark)
            optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)

            optionMenu.addTarget(self, action: #selector(RequestViewController.showGroupOptions(_:)), for: .touchUpInside)

            optionMenu.tag = (indexPath as NSIndexPath).row
            cell.accessoryView = optionMenu
        }else if(type == "friend_request"){
            let optionMenu = createButton(CGRect(x: view.bounds.width - 30, y: 35, width: 30, height: 35), title: optionIcon, border: false, bgColor: false, textColor: textColorDark)
            optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            optionMenu.addTarget(self, action: #selector(RequestViewController.showFriendOptions(_:)), for: .touchUpInside)

            optionMenu.tag = (indexPath as NSIndexPath).row
            cell.accessoryView = optionMenu
        }
        
        dynamicHeight = cell.labMessage.frame.origin.y + cell.labMessage.bounds.height + 5
        if dynamicHeight < (cell.imgUser.bounds.height + 10){
            dynamicHeight = (cell.imgUser.bounds.height + 10)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var notificationInfo:NSDictionary
        notificationInfo = blogResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.tag = (indexPath as NSIndexPath).row

        if (selectedCell.tag == (indexPath as NSIndexPath).row){
            selectedCell.backgroundColor = UIColor.white
        }
        tableView.deselectRow(at: indexPath, animated: true)
        if let objectDictionary =  notificationInfo["object"] as? NSDictionary{
        
            let object_type = notificationInfo["object_type"] as? String
            //            let notificationId = notificationInfo["notification_id"] as? Int
            let share1 = notificationInfo["type"]  as? String
            if (share1 == "shared") {
                let subDic = notificationInfo["params"] as? NSDictionary
                let dic1 = subDic!["label"] as! String
                
                if dic1 == "blog"{
                    BlogObject().redirectToBlogDetailPage(self,blogId: objectDictionary["object_id"] as! Int,title: "")
                }
            }
            if(object_type == "blog"){
                BlogObject().redirectToBlogDetailPage(self,blogId: objectDictionary["blog_id"] as! Int,title: "")
            }
            else if (object_type == "classified"){
                ClassifiedObject().redirectToProfilePage(self, id: objectDictionary["classified_id"] as! Int)
            } else if (object_type == "video"){
                
                VideoObject().redirectToVideoProfilePage(self, videoId : objectDictionary["video_id"] as! Int, videoType : objectDictionary["type"] as! Int, videoUrl : objectDictionary["video_url"] as! String)
                
            } else if (object_type == "music_playlist"){
                MusicObject().redirectToPlaylistPage(self,id: objectDictionary["playlist_id"] as! Int)
            } else if (object_type == "album"){
                let presentedVC = AlbumProfileViewController()
                presentedVC.albumId = "\(objectDictionary["album_id"]!)"
                navigationController?.pushViewController(presentedVC, animated: true)
            } else if (object_type == "group"){
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "group"
                presentedVC.subjectId = "\(objectDictionary["group_id"]!)"
                navigationController?.pushViewController(presentedVC, animated: true)
            }
            else if (object_type == "siteevent_event"){
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "advancedevents"
                presentedVC.subjectId = "\(objectDictionary["event_id"]!)"
                self.navigationController?.pushViewController(presentedVC, animated: true)
            }else if (object_type == "user"){
                let presentedVC = ContentActivityFeedViewController()
                presentedVC.subjectType = "user"
                presentedVC.subjectId = "\(objectDictionary["user_id"]!)"
                navigationController?.pushViewController(presentedVC, animated: true)
            }else if (object_type == "event"){
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "event"
                presentedVC.subjectId = "\(objectDictionary["event_id"]!)"
                navigationController?.pushViewController(presentedVC, animated: true)
            } else if (object_type == "activity_action"){
                let presentedVC = FeedViewPageViewController()
                presentedVC.action_id = "\(objectDictionary["action_id"]!)"
                navigationController?.pushViewController(presentedVC, animated: true)
            }else{
                let presentedVC = ExternalWebViewController()
                if let webUrl = notificationInfo["url"] as? String{
                    presentedVC.url = webUrl
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let navigationController = UINavigationController(rootViewController: presentedVC)
                    self.present(navigationController, animated: true, completion: nil)
                }
            }
            
            //            DispatchQueue.main.async(execute: {
            //                self.readNotification(notificationId! as Int)
            //            })
            
            
        }
        
        
        
    }
    
    @objc func showEventOptions(_ sender:UIButton){
        var blogInfo:NSDictionary
        blogInfo = blogResponse[sender.tag] as! NSDictionary
        let event_id = blogInfo["object_id"] as! Int
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Attending",comment: ""), style: .default) { action -> Void in
            let url = "events/member/accept"
            self.updateOptions(url as String, id: event_id as Int)
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Maybe Attending",comment: ""), style: .default) { action -> Void in
            let url = "events/member/accept"
            self.updateOptions(url as String, id: event_id as Int)
        })
        
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Ignore",comment: ""), style: UIAlertAction.Style.destructive) { action -> Void in
            let url = "events/member/ignore"
            self.updateOptions(url as String, id: event_id as Int)
        })
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2, width: 0, height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
    }

    @objc func showGroupOptions(_ sender:UIButton){
        var blogInfo:NSDictionary
        blogInfo = blogResponse[sender.tag] as! NSDictionary
        
        let group_id = blogInfo["object_id"] as! Int
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Join Group",comment: ""), style: .default) { action -> Void in
            let url = "groups/member/accept"
            self.updateOptions(url as String, id: group_id as Int)
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Ignore Group",comment: ""), style: UIAlertAction.Style.destructive) { action -> Void in
            
            let url = "groups/member/ignore"
            self.updateOptions(url as String, id: group_id as Int)

        })

        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.width/2 , y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
        
    }
    
    @objc func showFriendOptions(_ sender:UIButton){
        var blogInfo:NSDictionary
        blogInfo = blogResponse[sender.tag] as! NSDictionary

        let subject_id = blogInfo["subject_id"] as! Int

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Accept",comment: ""), style: .default) { action -> Void in
            let url = "user/add"
            self.selectFriend(url as String, id : subject_id as Int)
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Reject",comment: ""), style: UIAlertAction.Style.destructive) { action -> Void in
            
            let url = "user/cancel"
            self.selectFriend(url as String, id: subject_id as Int)

        })

        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2, width: 0, height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
        
    }

    func selectFriend(_ url : String,id : Int){
        var dic = Dictionary<String, String>()
        dic["user_id"] = "\(id)"
        post(dic, url: "\(url)", method: "POST") {
            (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if msg{
                    self.browseEntries()
                    //self.blogResponse.remove(at:indexPath.row)
                    self.requestTableView.reloadData()
                }
            })
        }
        
    }

    func updateOptions(_ url : String, id : Int){
        
        var dic = Dictionary<String, String>()
        
        if(url.range(of: "event") != nil){
            dic["event_id"] = "\(id)"
        }else{
            dic["group_id"] = "\(id)"
        }
        post(dic, url: "\(url)", method: "POST") {
            (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if msg{
                    self.browseEntries()
                    //self.blogResponse.remove(at:indexPath.row)
                    self.requestTableView.reloadData()
                }
            })
        }
        
        
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if updateScrollFlag{
//            // Check for Page Number for Browse Blog
//            if requestTableView.contentOffset.y >= requestTableView.contentSize.height - requestTableView.bounds.size.height{
//                if (!isPageRefresing  && limit*pageNumber < totalItems){
//                    if Reachabable.isConnectedToNetwork() {
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
//
//    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                // Check for Page Number for Browse Blog
//                if requestTableView.contentOffset.y >= requestTableView.contentSize.height - requestTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            requestTableView.tableFooterView?.isHidden = false
                           // if searchDic.count == 0{
                                browseEntries()
                           // }
                        }
                    }
                    else
                    {
                        requestTableView.tableFooterView?.isHidden = true
                }
                    
            //    }
                
            }
            
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func notificationButton(_ sender: UIButton) {
        //        let vc = TwoViewController(nibName: "TwoViewController", bundle: nil)
        navigationController?.pushViewController(NotificationViewController(), animated: false)
        notifications.backgroundColor = buttonSelectColor
        requests.backgroundColor = buttonDeSelectColor
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
