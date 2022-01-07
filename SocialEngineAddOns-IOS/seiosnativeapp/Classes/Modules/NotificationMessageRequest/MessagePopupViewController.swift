//
//  MessageViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 12/05/15.
//  Copyright (c) 2015 bigstep. All rights reserved.
//

import UIKit
import Foundation

// Global Variable Initialization Used in Blog Module
var messagesUpdate: Bool!

class MessagePopupViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate {
    var editBlogID:Int = 0                          // Edit BlogID
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
    var objectId:Int!
    var showOnlyMyContent = false                // Flag to refresh Blog
    var viewAllMessage:UIButton!
    
    var topLabel:UILabel!
    
    // Initialization of class Object
    override func viewDidLoad() {
        
        super.viewDidLoad()
        messagesUpdate = true
        searchDic.removeAll(keepCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.hidden = true
        openMenu = false
        updateAfterAlert = true
//        
//        var InitialNavController : UINavigationController
//        InitialNavController = new UINavigationController ();
//        window.RootViewController = InitialNavController;
//        
        
        
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
            let menu = UIBarButtonItem(image: UIImage(named:"icon-menu.png"), style: UIBarButtonItemStyle.Plain , target:self , action: "openSlideMenu")
            navigationItem.leftBarButtonItem = menu
        }
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        
        self.title = NSLocalizedString("Message",  comment: "")
        
        
        //        // Initialize Blog Types
        //        browseBlog = createButton(CGRectMake(PADING, TOPPADING ,CGRectGetWidth(view.bounds)/2.0 - PADING , ButtonHeight) , NSLocalizedString("Inbox",  comment: ""), true,false, textColorDark)
        //        browseBlog.tag = 11
        //        browseBlog.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        //        browseBlog.addTarget(self, action: "prebrowseEntries:", forControlEvents: .TouchUpInside)
        //        mainView.addSubview(browseBlog)
        //
        //
        //        myBlog = createButton(CGRectMake(CGRectGetWidth(view.bounds)/2.0, TOPPADING ,CGRectGetWidth(view.bounds)/2.0 - PADING , ButtonHeight), NSLocalizedString("Outbox",  comment: ""), true,false, textColorDark)
        //        myBlog.tag = 22
        //        myBlog.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        //        myBlog.addTarget(self, action: "prebrowseEntries:", forControlEvents: .TouchUpInside)
        //        mainView.addSubview(myBlog)
        //
        //
        //        // Create Filter Search Link
        //        let filter = createButton(CGRectMake(PADING, TOPPADING + contentPADING + ButtonHeight, ButtonHeight - PADING , ButtonHeight - PADING), "F", true,false, textColorDark)
        //        filter.addTarget(self, action: "filterSerach", forControlEvents: .TouchUpInside)
        //        mainView.addSubview(filter)
        //
        
        //        // Initialze Searcgh Bar
        //        searchBar.frame = CGRectMake( CGRectGetWidth(filter.bounds) + 2*PADING, TOPPADING + contentPADING + ButtonHeight , CGRectGetWidth(view.bounds) - (CGRectGetWidth(filter.bounds) + 3*PADING), CGRectGetHeight(filter.bounds))
        //        searchBar.delegate = self
        //        searchBar.placeholder = NSLocalizedString("Search",  comment: "")
        //        mainView.addSubview(searchBar)
        //
        //        for subView in searchBar.subviews  {
        //            for subsubView in subView.subviews  {
        //                if let textField = subsubView as? UITextField {
        //                    textField.textColor = textColorDark
        //                    textField.font = UIFont(name: fontBold, size: FONTSIZENormal)
        //                }
        //            }
        //        }
//        
//        var popOverWidth : CGFloat
//        var popOverHeight : CGFloat
//        
//        if  (UIDevice.currentDevice().userInterfaceIdiom == .Phone){
//            popOverWidth = CGRectGetWidth(view.bounds)*0.90
//            popOverWidth = CGRectGetHeight(view.bounds)*0.75
//            
//            
//        }else{
//            popOverWidth = CGRectGetWidth(view.bounds)*0.60
//            popOverHeight = CGRectGetHeight(view.bounds)*0.45
//            
//        }
        
        topLabel = createLabel(CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) , TOPPADING / 2), text: NSLocalizedString("Message",  comment: ""), alignment: .Center, textColor: textColorDark)
        
        mainView.addSubview(topLabel)
        
        // Initialize Blog Table
        blogTableView = UITableView(frame: CGRectMake(0, TOPPADING / 2 , CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)*0.50), style: .Grouped)
        blogTableView.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        blogTableView.dataSource = self
        blogTableView.delegate = self
        blogTableView.estimatedRowHeight = 50.0
        blogTableView.rowHeight = UITableViewAutomaticDimension
        blogTableView.backgroundColor = tableViewBgColor
        blogTableView.separatorColor = TVSeparatorColor
        mainView.addSubview(blogTableView)
        
        
        
        viewAllMessage = createButton(CGRectMake(0, CGRectGetHeight(view.bounds)*0.50 + TOPPADING + 20 , CGRectGetWidth(view.bounds) , ButtonHeight) , title: NSLocalizedString("Inbox",  comment: ""), border: true,bgColor: false, textColor: textColorDark)
        //        browseBlog.tag = 11
        viewAllMessage.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        viewAllMessage.addTarget(self, action: "viewAllMessages:", forControlEvents: .TouchUpInside)
        mainView.addSubview(viewAllMessage)
        
        //        secondViewController.preferredContentSize = CGSizeMake(CGRectGetWidth(view.bounds)*0.90,CGRectGetHeight(view.bounds)*0.75)
        //
        //    }else{
        //    secondViewController.preferredContentSize = CGSizeMake(500,450)
        
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        blogTableView.addSubview(refresher)
        
        
        if logoutUser == true || showOnlyMyContent == true{
            //            browseBlog.hidden = true
            //            myBlog.hidden = true
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
        
        if (messagesUpdate == true){
            pageNumber = 1
            searchBar.text = ""
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
    
    
    //    // Handle Simple Search on Search Click
    //    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    //
    //        // Add search text to searchDic
    //        searchDic.removeAll(keepCapacity: false)
    //        searchDic["search"] = searchBar.text
    //        pageNumber = 1
    //        blogResponse.removeAll(keepCapacity: false)
    //        searchBar.resignFirstResponder()
    //        // Update Blog for Search Text
    //
    //        if searchBar.text != "" && logoutUser == true{
    //            self.navigationItem.rightBarButtonItem?.title = "Cancle"
    //            self.navigationItem.rightBarButtonItem?.enabled = true
    //        }
    //
    //        browseEntries()
    //    }
    
    
    //    // Cancle Search Result for Logout User
    //    func cancleSearch(){
    //        searchDic.removeAll(keepCapacity: false)
    //        searchDic["search"] = ""
    //        pageNumber = 1
    //
    //        self.navigationItem.rightBarButtonItem?.title = ""
    //        self.navigationItem.rightBarButtonItem?.enabled = false
    //        browseEntries()
    //    }
    //
    //
    //    // Open Filter Search Form
    //    func filterSerach(){
    //        if openMenu{
    //            openMenu = false
    //            openMenuSlideOnView(mainView)
    //        }else{
    //            searchBar.text = ""
    //            searchBar.resignFirstResponder()
    //            searchDic.removeAll(keepCapacity: false)
    //            messagesUpdate = false
    //            var presentedVC = FilterSearchViewController()
    //            presentedVC.searchUrl = "blogs/browse-search-form"
    //            presentedVC.serachFor = "blog"
    //            isCreateOrEdit = true
    //            navigationController?.pushViewController(presentedVC, animated: true)
    //        }
    //    }
    
    
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
    
    //        // For delete  a Blog
    //        func updateBlogMenuAction(parameter: NSDictionary , url : String){
    //            // Check Internet Connection
    //            if reachability.isReachable() {
    //                removeAlert()
    //                spinner.center = view.center
    //                spinner.hidesWhenStopped = true
    //                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
    //                view.addSubview(spinner)
    //                spinner.startAnimating()
    //
    //
    //                var dic = Dictionary<String, String>()
    //                for (key, value) in parameter{
    //
    //                    if let id = value as? NSNumber {
    //                        dic["\(key)"] = String(id as Int)
    //                    }
    //
    //                    if let receiver = value as? NSString {
    //                        dic["\(key)"] = receiver
    //                    }
    //                }
    //                dic["token"] = "\(auth_token)"
    //
    //                // Send Server Request to Explore Blog Contents with Blog_ID
    //                post(dic, "\(url)", "POST") { (succeeded, msg) -> () in
    //                    dispatch_async(dispatch_get_main_queue(), {
    //                        spinner.stopAnimating()
    //
    //                        if msg{
    //                            // On Success Update Blog Detail
    //                            // Update Blog Detail
    //                            if succeeded["message"] != nil{
    //                                self.showAlertMessage(self.view.center,msg: succeeded["message"] as String, timer: true )
    //                            }
    //                            updateAfterAlert = false
    //                            self.browseEntries()
    //                        }
    //
    //                        else{
    //                            // Handle Server Side Error
    //                            if succeeded["message"] != nil{
    //                                self.showAlertMessage(self.view.center,msg: succeeded["message"] as String, timer: false )
    //                            }
    //                        }
    //                    })
    //                }
    //
    //            }else{
    //                // No Internet Connection Message
    //                showAlertMessage(view.center , msg: network_status_msg , timer: false)
    //            }
    //
    //        }
    //
    
    
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
            
            path = "messages/inbox"
            parameters = ["page":"\(pageNumber)" , "limit": "5"]
            //            browseBlog.backgroundColor = buttonSelectColor
            //            myBlog.backgroundColor = buttonDeSelectColor
            self.title = NSLocalizedString("Inbox",  comment: "")
            
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
                            self.blogResponse.removeAll(keepCapacity: false)
                        }
                        
                        
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.mainView.center , msg: succeeded["message"] as String, timer: true)
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if response["response"] != nil{
                                if let blog = response["response"] as? NSArray {
                                    self.blogResponse += blog
                                }
                            }
                            
                            if response["getTotalItemCount"] != nil{
                                self.totalItems = response["getTotalItemCount"] as Int
                            }
                            
                            //                                if self.showOnlyMyContent == false {
                            //
                            //                                    if (response["canCreate"] as Bool == true){
                            //                                        //      let addBlog = UIBarButtonItem(title: "Create Blog", style:.Plain , target:self , action: "addNewBlog")
                            //                                        let addBlog = UIBarButtonItem(image: UIImage(named:"icon-new.png"), style: UIBarButtonItemStyle.Plain , target:self , action: "addNewBlog")
                            //                                        self.navigationItem.rightBarButtonItem = addBlog
                            //
                            //                                    }
                            //                                }
                        }
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        self.isPageRefresing = false
                        //Reload Blog Tabel
                        self.blogTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.blogResponse.count == 0{
                            
                            self.info = createLabel(CGRectMake(0, 0,CGRectGetWidth(self.view.bounds) * 0.8 , 50), NSLocalizedString("You do not have any message entries.",  comment: "") , .Center, textColorLight)
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
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.Blue
        
        var blogInfo:NSDictionary
        blogInfo = blogResponse[indexPath.row] as! NSDictionary
        
        
        
        var message:NSDictionary
        message = blogInfo["message"] as! NSDictionary
        
        
        var recipient:NSDictionary
        recipient = blogInfo["recipient"] as! NSDictionary
        
        var sender:NSDictionary
        sender = blogInfo["sender"] as! NSDictionary
        
        
//        var title = message["title"] 
//        
//        //            println(message["title"])
//        //            return
//        
//        println(title?.length())
//        
//        println("srijan")
//        var titleLength = title?.length()
//        
//        if(titleLength! < 1){
//            title = "No Subject"
//        }
//        
//        // Set Blog Title
//        cell.labTitle.frame = CGRectMake(CGRectGetWidth(cell.imgUser.bounds) + 10, 10,(CGRectGetWidth(UIScreen.mainScreen().bounds) - 75) , 100)
//        cell.labTitle.text = title! as? String
        cell.labTitle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.labTitle.sizeToFit()
        
        if let var ownerName = sender["displayname"]! as? String {
            if let var postedDate = sender["creation_date"] as? String{
                var postedOn = dateDifference(postedDate)
                cell.labMessage.frame = CGRectMake(CGRectGetWidth(cell.imgUser.bounds) + 10, cell.labTitle.frame.origin.y + CGRectGetHeight(cell.labTitle.bounds) + 5,(CGRectGetWidth(UIScreen.mainScreen().bounds) - 75) , 100)
                var labMsg = ""
                if browseOrMyBlog {
                    labMsg = String(format: NSLocalizedString("By %@ on %@", comment: ""), ownerName, postedOn)
                }else{
                    labMsg = String(format: NSLocalizedString("On %@", comment: ""), postedOn)
                }
                
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
        
        //        // Set Blog Sub Message
        //        if let var ownerName = blogInfo["owner_title"] as? String {
        //            if let var postedDate = blogInfo["creation_date"] as? String{
        //                var postedOn = dateDifference(postedDate)
        //                cell.labMessage.frame = CGRectMake(65, cell.labTitle.frame.origin.y + CGRectGetHeight(cell.labTitle.bounds) + 5,(CGRectGetWidth(UIScreen.mainScreen().bounds) - 75) , 100)
        //                print("frame cell.labMessage.frame  \(cell.labMessage.frame)")
        //
        //                if browseOrMyBlog {
        //                cell.labMessage.text = String(format: NSLocalizedString("By %@ on %@", comment: ""), ownerName, postedOn)
        //                 }else{
        //                     cell.labMessage.text = String(format: NSLocalizedString("On %@", comment: ""), postedOn)
        //                }
        //                cell.labMessage.lineBreakMode = NSLineBreakMode.ByWordWrapping
        //                cell.labMessage.sizeToFit()
        //            }
        //        }
        
        
        
        // Set Blog Owner Image
        let url = NSURL(string: sender["image"] as! NSString as String)
        //  var fileName = "\((url?.lastPathComponent)!)"
        //  var ownerImage:NSData = getImageFromCache(fileName)
        //  if ownerImage.length == 0 {
        
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
        //            cell.imgUser.image =  UIImage(data: ownerImage)
        //        }
        // Set cell accessoryType
        
        
        if browseOrMyBlog {
            cell.accessoryView = nil
            cell.accessoryType = .DisclosureIndicator
        }else{
            //if (blogInfo["edit"] as Bool) || (blogInfo["delete"] as Bool) {
            let optionMenu = createButton(CGRectMake(CGRectGetWidth(view.bounds) - 40, 0, 40, CGRectGetHeight(cell.bounds)), "", false, false, textColorLight)
            optionMenu.setBackgroundImage(UIImage(named: "icon-option.png"), forState: .Normal)
            optionMenu.addTarget(self, action: "showMenu:", forControlEvents: .TouchUpInside)
            optionMenu.tag = indexPath.row
            cell.accessoryView = optionMenu
            //  cell.accessoryType = .DetailButton
            //   }
        }
        
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
        blogInfo = blogResponse[indexPath.row] as! NSDictionary
        
        print(blogInfo)
        
        if(blogInfo["allow_to_view"] as! Int == 1){
            
            let presentedVC = BlogDetailViewController()
            presentedVC.blogId = blogInfo["blog_id"] as! Int
            presentedVC.blogName = blogInfo["title"] as! String
            //        presentedVC.url = blogInfo["url"] as String
            navigationController?.pushViewController(presentedVC, animated: true)
        }else{
            showAlertMessage(mainView.center, msg: NSLocalizedString("You do not have permission to view this private page.", comment: ""), timer: true)
        }
        
    }
    
    
    
    
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    //    func scrollViewDidScroll(scrollView: UIScrollView) {
    //
    //        if updateScrollFlag{
    //            // Check for Page Number for Browse Blog
    //            if blogTableView.contentOffset.y >= blogTableView.contentSize.height - blogTableView.bounds.size.height{
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
    
    //    override func viewWillDisappear(animated: Bool) {
    //
    //        mainView.removeGestureRecognizer(tapGesture)
    //       //  searchDic.removeAll(keepCapacity: false)
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewAllMessages(sender:UIButton){
        //        navigationController?.navigationBar.hidden = false
        print("srijan")
        print(navigationController)
        
        navigationController?.navigationBar.hidden = false
        
        let nav = UINavigationController()
        let presentedVC = NotificationViewController()
                (presentedVC as NotificationViewController).showOnlyMyContent = false
                nav.pushViewController(presentedVC, animated: true)
        
        
//        println(navigationController)
//        
//        var window:UIWindow
//        
//        window = UIWindow(frame: UIScreen.mainScreen().bounds)
//        window.backgroundColor = UIColor.whiteColor()
//        
//        // Create a nav/vc pair using the custom ViewController class
//        
//        let nav = UINavigationController()
//        let vc = MessageViewController(nibName: "MessageViewController", bundle: nil)
//        
//        // Push the vc onto the nav
//        nav.pushViewController(vc, animated: false)
//        
//        // Set the window’s root view controller
//        window.rootViewController = nav
//        
//        // Present the window
//        window.makeKeyAndVisible()
//        
//        println("22")
//        println(navigationController)
        
//        return true
        
        
        
        //        navController = UINavigationController(rootViewController: Messa)
        
        //        view.addSubview(navigationController)
        
//        let presentedVC = NotificationViewController()
//        (presentedVC as NotificationViewController).showOnlyMyContent = false
//        navigationController?.pushViewController(presentedVC, animated: true)
        
        
//        let secondViewController = self.storyboard.instantiateViewControllerWithIdentifier("SecondViewController") as MessageViewController
//        
//        
//        self.navigationController.pushViewController(secondViewController, animated: true)
        
        
        //        let presentedVC = MessageViewController()
        //        (presentedVC as MessageViewController).showOnlyMyContent = false
        //         navigationController?.pushViewController(presentedVC, animated: true)
        
        //        MessagePopupViewController.removeFromParentViewController(self)
        
        //        MessagePopupViewController.removeFromSuperView()
        //        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func abc(){
        print("11")
        //        self.navigationController?.navigationBar.hidden = false
        print(self.navigationController)
        
        self.performSegueWithIdentifier("abcd", sender: nil)
        
        
        //        navController = UINavigationController(rootViewController: Messa)
        
        //        view.addSubview(navigationController)
        
        let presentedVC = NotificationViewController()
        (presentedVC as NotificationViewController).showOnlyMyContent = false
        self.navigationController?.pushViewController(presentedVC, animated: true)
        
        
        //        navigationController?.pushViewController(NotificationViewController, animated: true)
        
        //        self.navigationController?.setViewControllers(presentedVC, animated: true)
        
        
        //        NotificationViewController *ngView = [[NotificationViewController alloc]initWithNibName:Nil bundle:Nil];
        //        [UIView beginAnimations:nil context:NULL];
        //        [UIView setAnimationDuration: 0.50];
        //        [self presentViewController:ngView animated:NO completion:nil];
        
        
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

