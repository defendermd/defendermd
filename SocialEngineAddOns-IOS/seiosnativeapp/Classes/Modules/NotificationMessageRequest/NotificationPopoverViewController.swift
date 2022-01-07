//
//  NotificationViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 11/05/15.
//  Copyright (c) 2015 bigstep. All rights reserved.
//

import UIKit

class NotificationPopoveViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate {
    let mainView = UIView()                  // true for Browse Blog & false for My Blog
    var showSpinner = true                      // not show spinner at pull to refresh
    var notificationsResponse = [AnyObject]()            // For response come from Server
    var isPageRefresing = false                 // For Pagination
    var notificationTableView:UITableView!              // TAbleView to show the notifications Contents
    var notifications:UIButton!                    // notifications Types
    var requests:UIButton!
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent = false;
    var titleLabel :UILabel!
    // Initialization of class Object
    override func viewDidLoad() {
        
        super.viewDidLoad()
        blogUpdate = true
        searchDic.removeAll(keepCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.hidden = false
        
        self.title = "some title"
//        navigationController?.navigationBar.title = "some title"
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
        
        
        self.title = NSLocalizedString("Notifications",  comment: "")
        
         titleLabel = createLabel(CGRectMake(0, 0, CGRectGetWidth(view.bounds), TOPPADING), text: "Notifications", alignment: .Center, textColor: textColorLight)
        titleLabel.text = "Notifications"
        // Initialize notifications Types
        notifications = createButton(CGRectMake(PADING, TOPPADING ,CGRectGetWidth(view.bounds)/2.0 - PADING , ButtonHeight) , title: NSLocalizedString("Notifications",  comment: ""), border: true,bgColor: false, textColor: textColorDark)
        notifications.tag = 11
        notifications.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        notifications.addTarget(self, action: "prebrowseEntries:", forControlEvents: .TouchUpInside)
        mainView.addSubview(notifications)
        
        
        requests = createButton(CGRectMake(CGRectGetWidth(view.bounds)/2.0, TOPPADING ,CGRectGetWidth(view.bounds)/2.0 - PADING , ButtonHeight), title: NSLocalizedString("Requests",  comment: ""), border: true,bgColor: false, textColor: textColorDark)
        requests.tag = 22
        requests.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        requests.addTarget(self, action: "requestView:", forControlEvents: .TouchUpInside)
        mainView.addSubview(requests)
        
        // Initialize notifications Table
        notificationTableView = UITableView(frame: CGRectMake(0, TOPPADING  , CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)), style: .Grouped)
        notificationTableView.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        notificationTableView.dataSource = self
        notificationTableView.delegate = self
        notificationTableView.estimatedRowHeight = 50.0
        notificationTableView.rowHeight = UITableViewAutomaticDimension
        notificationTableView.backgroundColor = tableViewBgColor
        notificationTableView.separatorColor = TVSeparatorColor
        mainView.addSubview(notificationTableView)
        
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        notificationTableView.addSubview(refresher)
        
        
        if logoutUser == true || showOnlyMyContent == true{
            notifications.hidden = true
            requests.hidden = true
            requests.frame.origin.y = TOPPADING
            notificationTableView.frame.origin.y = CGRectGetHeight(requests.bounds) + 2 * contentPADING + requests.frame.origin.y
            notificationTableView.frame.size.height = CGRectGetHeight(view.bounds) - (CGRectGetHeight(requests.bounds) + 2 * contentPADING + requests.frame.origin.y)
            
        }
        
    }
    
    
    
    // Check for notifications Update Every Time when View Appears
    override func viewDidAppear(animated: Bool) {
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        
        notificationTableView.reloadData()
        
        if (blogUpdate == true){
            pageNumber = 1
            updateScrollFlag = false
            browseEntries()
        }
        
        if fromActivityFeed == true{
            //            fromActivityFeed = false
            //            let presentedVC  = BlogDetailViewController()
            //            presentedVC.blogId = objectId
            //            presentedVC.blogName = NSLocalizedString("Loading...", comment: "")
            //            navigationController?.pushViewController(presentedVC, animated: true)
        }
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
    
    // Handle Browse Blog or My Blog PreAction
    func prebrowseEntries(sender: UIButton){
        // true for Browse Blog & false for My Blog
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        
        self.notificationsResponse.removeAll(keepCapacity: false)
        updateScrollFlag = false
        pageNumber = 1
        // Update for Notifications
        browseEntries()
    }
    
    
    // Pull to Request Action
    func refresh(){
        // Check Internet Connectivity
        //  if notificationsResponse.count != 0{
        if reachability.isReachable() {
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
        showCustomAlert(centerPoint, msg: msg)
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
                    dic["\(key)"] = receiver as String
                }
            }
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
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
            
            
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            
            if (self.pageNumber == 1){
                self.notificationsResponse.removeAll(keepCapacity: false)
                
                if updateAfterAlert == true || searchDic.count > 0 {
                    removeAlert()
                    self.notificationTableView.reloadData()
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
            //            if browseOrMyBlog {
            path = "notifications"
            parameters = ["page":"\(pageNumber)" , "limit": "5", "hide_request": "1", "hide_recent_updates" : "0"]
            notifications.backgroundColor = buttonSelectColor
            requests.backgroundColor = buttonDeSelectColor
            self.title = NSLocalizedString("Notifications",  comment: "")
            
            //            }else{
            //                path = "blogs/manage"
            //                parameters = ["X-Auth-Token":"\(auth_token)" ,"X-Access-Token":"\(access_token)", "page":"\(pageNumber)" , "limit": "\(limit)"]
            //                myBlog.backgroundColor = buttonSelectColor
            //                notifications.backgroundColor = buttonDeSelectColor
            //                self.title = NSLocalizedString("Requests",  comment: "")
            //            }
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
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
                            self.notificationsResponse.removeAll(keepCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.mainView.center , msg: succeeded["message"] as String, timer: true)
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let blog_1 = response["response"] as? NSDictionary {
                                    if let blog = blog_1["recent_updates_notification"] as? NSArray {
                                        self.notificationsResponse += blog
                                    }
                                }
                            }
                            
                            if response["recentUpdateTotalItemCount"] != nil{
                                self.totalItems = response["recentUpdateTotalItemCount"] as Int
                            }
                            
                            if self.showOnlyMyContent == false {
                                
                                //                                if (response["canCreate"] as Bool == true){
                                //                                    //      let addBlog = UIBarButtonItem(title: "Create Blog", style:.Plain , target:self , action: "addNewBlog")
                                //                                    let addBlog = UIBarButtonItem(image: UIImage(named:"icon-new.png"), style: UIBarButtonItemStyle.Plain , target:self , action: "addNewBlog")
                                //                                    self.navigationItem.rightBarButtonItem = addBlog
                                //
                                //                                }
                            }
                        }
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        self.isPageRefresing = false
                        //Reload Blog Tabel
                        self.notificationTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.notificationsResponse.count == 0{
                            
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
        print(dynamicHeight)
        return dynamicHeight
    }
    
    // Set Blog Section
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return notificationsResponse.count
    }
    
    // Set Cell of TabelView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        
        var blogInfo:NSDictionary
        blogInfo = notificationsResponse[indexPath.row] as! NSDictionary
        
        // Set Blog Title
        cell.labTitle.frame = CGRectMake(CGRectGetWidth(cell.imgUser.bounds) + 10, 10,(CGRectGetWidth(UIScreen.mainScreen().bounds) - 75) , 100)
        cell.labTitle.text = blogInfo["title"] as? String
        cell.labTitle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.labTitle.sizeToFit()
        
        if let var ownerName = blogInfo["feed_title"] as? String {
            if let var postedDate = blogInfo["date"] as? String{
                var postedOn = dateDifference(postedDate)
                cell.labMessage.frame = CGRectMake(CGRectGetWidth(cell.imgUser.bounds) + 10, cell.labTitle.frame.origin.y + CGRectGetHeight(cell.labTitle.bounds) + 5,(CGRectGetWidth(UIScreen.mainScreen().bounds) - 75) , 100)
                var labMsg = ""
                
                labMsg = String(format: NSLocalizedString("By %@ on %@", comment: ""), ownerName, postedOn)
                //                }else{
                //                    labMsg = String(format: NSLocalizedString("On %@", comment: ""), postedOn)
                //                }
                
                cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWithBlock: { (mutableAttributedString: NSMutableAttributedString!) -> NSMutableAttributedString! in
                    let boldFont = CTFontCreateWithName( fontBold, FONTSIZESmall, nil)
                    
                    let range = (labMsg as NSString).rangeOfString(ownerName)
                    mutableAttributedString.addAttribute(kCTFontAttributeName as NSString, value: boldFont, range: range)
                    mutableAttributedString.addAttribute(kCTForegroundColorAttributeName as NSString, value: textColorDark, range: range)
                    
                    // TODO: Clean this up..
                    return mutableAttributedString
                })
                
                //            let range = (labMsg as NSString).rangeOfString(NSLocalizedString(ownerName,  comment: ""))
                //            cell.labMessage.addLinkToTransitInformation([ "type" : "user"], withRange:range)
            }
        }
        
        cell.labMessage.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.labMessage.sizeToFit()
        
      
        let subject = blogInfo["subject"] as! NSDictionary
        
        
        
        let url = NSURL(string: subject["image_icon"] as NSString)
        var fileName = "\((url?.lastPathComponent)!)"
        var ownerImage:NSData = getImageFromCache(fileName)
        if ownerImage.length == 0 {
            
            downloadData(url!, { (downloadedData, msg) -> () in
                if msg{
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.imgUser.image = UIImage(data: downloadedData)
                        //                    if cell.imgUser.image != nil{
                        //                    saveFileInCacheDirectory(["\(fileName)":(cell.imgUser.image)!])
                        //                    }
                    })
                }
            })
            //        }else{
            cell.imgUser.image =  UIImage(data: ownerImage)
        }
        // Set cell accessoryType
        
      
        dynamicHeight = cell.labMessage.frame.origin.y + CGRectGetHeight(cell.labMessage.bounds) + 5
        
        if dynamicHeight < (CGRectGetHeight(cell.imgUser.bounds) + 10){
            dynamicHeight = (CGRectGetHeight(cell.imgUser.bounds) + 10)
        }
        
        return cell
    }
    
    
    // Handle Blog Table Cell Selection
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var blogInfo:NSDictionary
        blogInfo = notificationsResponse[indexPath.row] as! NSDictionary
        
        var blogDictionary = blogInfo["object"]  as! NSDictionary
        var a = blogInfo["object_type"] as! String
        if(a == "blog"){
            
            let presentedVC1 = BlogDetailViewController()
            presentedVC1.blogId = blogDictionary["blog_id"] as Int
            presentedVC1.blogName = blogDictionary["title"] as? String
            navigationController?.pushViewController(presentedVC1, animated: true)
            
        }else if(a == "music_playlist"){
            let presentedVC1 = MusicPlayListViewController()
            presentedVC1.playListId = blogDictionary["playlist_id"] as Int
//            presentedVC1.title = blogDictionary["title"] as? String
            navigationController?.pushViewController(presentedVC1, animated: true)
        }else if(a == "group"){
            let presentedVC  = ContentFeedViewController() //EventDetailViewController()
            presentedVC.subjectId = blogDictionary["group_id"] as Int
            presentedVC.subjectType = "group"
            //      presentedVC.eventId = objectId
            //presentedVC.eventName = NSLocalizedString("Loading...", comment: "")
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        else if (a == "event"){
            let presentedVC  = ContentFeedViewController() //EventDetailViewController()
            presentedVC.subjectId = blogDictionary["event_id"] as Int
            presentedVC.subjectType = "event"
            //      presentedVC.eventId = objectId
            //presentedVC.eventName = NSLocalizedString("Loading...", comment: "")
            navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        else if (a == "photo"){
            
            
            var presentedVC = PhotoViewController()
            //            presentedVC.attachmentID = (attachment[0] as NSDictionary)["attachment_id"] as Int
            presentedVC.photoType = "photo"
            presentedVC.photoID = 0
            //            presentedVC.photoForViewer = photos
            //            presentedVC.total_items = attachment.count
            navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        
        
        
        //        if(blogInfo["allow_to_view"] as Int == 1){
        
        //        let presentedVC = BlogDetailViewController()
        //        presentedVC.blogId = blogInfo["blog_id"] as Int
        //        presentedVC.blogName = blogInfo["title"] as String
        //      //  presentedVC.url = blogInfo["url"] as String
        //        navigationController?.pushViewController(presentedVC, animated: true)
        //        }else{
        //            showAlertMessage(mainView.center, msg: NSLocalizedString("You do not have permission to view this private page.", comment: ""), timer: true)
        //        }
        
    }
    
    
    
    
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        
//        if updateScrollFlag{
//            // Check for Page Number for Browse notifications
//            if notificationTableView.contentOffset.y >= notificationTableView.contentSize.height - notificationTableView.bounds.size.height{
//                if (!isPageRefresing  && limit*pageNumber < totalItems){
//                    if reachability.isReachable() {
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
    
    
    @IBAction func requestView(sender: UIButton) {
        //        let vc = TwoViewController(nibName: "TwoViewController", bundle: nil)
        navigationController?.pushViewController(RequestViewController(), animated: true)
        notifications.backgroundColor = buttonDeSelectColor
        requests.backgroundColor = buttonSelectColor
    }
    
    //        override func viewWillDisappear(animated: Bool) {
    //
    //            mainView.removeGestureRecognizer(tapGesture)
    //           //  searchDic.removeAll(keepCapacity: false)
    //        }
    
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
