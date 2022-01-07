//
//  MembersViewController.swift
//  seiosnativeapp
//
//  Created by bigstep on 15/01/15.
//  Copyright (c) 2015 bigstep. All rights reserved.
//

import UIKit
var friendRequestPopover:Bool!

class FriendRequestPopoverViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    let mainView = UIView()
    // Variables for Likes
    var allMembers = [AnyObject]()
    var membersTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    //  var activityFeedLikes:Bool!
    var isPageRefresing = false
    var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
    var contentType = "members"
    var searchBar : UISearchBar!             // searchBar
    var contentId:Int!
    
    // Initialize MembersViewController Class
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        friendRequestPopover = true
        searchDic.removeAll(keepCapacity: false)
        //   findAllMembers()
        
        membersTableView = UITableView(frame: CGRectMake(0, TOPPADING  , CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds) - TOPPADING), style: UITableViewStyle.Grouped)
        membersTableView.registerClass(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        membersTableView.rowHeight = 50
        membersTableView.dataSource = self
        membersTableView.delegate = self
        membersTableView.bounces = false
        membersTableView.backgroundColor = tableViewBgColor
        membersTableView.separatorColor = TVSeparatorColor
        
        if contentType == "members" {
            // Set Title for navigation Bar
            self.title = NSLocalizedString("Friend Requests", comment: "")
            openMenu = false
            view.backgroundColor = bgColor
            navigationController?.navigationBar.hidden = false
            
            let sidePanelController = SidePanelViewController() //SlideMenuTableViewController()//
            addChildViewController(sidePanelController)
            view.insertSubview(sidePanelController.view, atIndex: 0)
            sidePanelController.view.frame = CGRectMake(0, 0, 320 * 0.8, CGRectGetHeight(view.bounds))
            
            let subViews = mainView.subviews
            for subview in subViews{
                subview.removeFromSuperview()
            }
            
            mainView.frame = view.frame
            mainView.backgroundColor = bgColor
            view.addSubview(mainView)
            mainView.removeGestureRecognizer(tapGesture)
            mainView.addSubview(membersTableView)
            
            var leftNavView = UIView(frame: CGRectMake(0, 0, 44, 44))
            leftNavView.backgroundColor = UIColor.clearColor()
            
            let tapView = UITapGestureRecognizer(target: self, action: Selector("openSlideMenu"))
            leftNavView.addGestureRecognizer(tapView)
            
            
            var menuLabel = createLabel(CGRectMake(0,5,40,35), text: "\(dashboardIcon)", alignment: .Center, textColor: textColorLight)
            menuLabel.font = UIFont(name: "fontAwesome", size: FONTSIZEExtraLarge)
            leftNavView.addSubview(menuLabel)
            
            if (logoutUser == false && (totalNotificationCount !=  nil) && (totalNotificationCount > 0)) {
                var countLabel = createLabel(CGRectMake(20,0,20,20), text: "\(totalNotificationCount)", alignment: .Center, textColor: textColorLight)
                countLabel.backgroundColor = UIColor.redColor()
                countLabel.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                leftNavView.addSubview(countLabel)
            }

            
            var barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
            
            // Create Filter Search Link
            let filter = createButton(CGRectMake(PADING, TOPPADING , ButtonHeight - PADING , ButtonHeight - PADING), title: "F", border: true,bgColor: false, textColor: textColorDark)
            filter.addTarget(self, action: "filterSerach", forControlEvents: .TouchUpInside)
            mainView.addSubview(filter)
            
            
            // Initialze Searcgh Bar
            searchBar = UISearchBar()
            searchBar.frame = CGRectMake( CGRectGetWidth(filter.bounds) + 2*PADING, TOPPADING , CGRectGetWidth(view.bounds) - (CGRectGetWidth(filter.bounds) + 3*PADING), CGRectGetHeight(filter.bounds))
            searchBar.delegate = self
            searchBar.placeholder = NSLocalizedString("Search",  comment: "")
            mainView.addSubview(searchBar)
            
            for subView in searchBar.subviews  {
                for subsubView in subView.subviews  {
                    if let textField = subsubView as? UITextField {
                        textField.textColor = textColorDark
                        textField.font = UIFont(name: fontBold, size: FONTSIZENormal)
                    }
                }
            }
            
            // Change Table Frame
            membersTableView.frame = CGRectMake(0, 0 , CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds))
            
        }else{
            // Set Title for navigation Bar
            self.title = NSLocalizedString("People who like this", comment: "")
            
            view.addSubview(membersTableView)
        }
        
        
        
        //  self.edgesForExtendedLayout = UIRectEdge.All;
        self.automaticallyAdjustsScrollViewInsets = false;
        
    }
    
    
    // Check for Blog Update Every Time when View Appears
    override func viewDidAppear(animated: Bool) {
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        //  membersTableView.reloadData()
        
        if friendRequestPopover == true{
            pageNumber = 1
            if searchBar != nil{
                searchBar.text = ""
            }
            findAllMembers()
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
        openMenuSlideOnView(mainView)
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
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
            friendRequestPopover = false
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "members/browse-search-form"
            presentedVC.serachFor = "members"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: true)
        }
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
    
    // MARK: - UISearchBar Delegates
    
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
        allMembers.removeAll(keepCapacity: false)
        searchBar.resignFirstResponder()
        // Update Blog for Search Text
        
        if searchBar.text != "" && logoutUser == true{
            self.navigationItem.rightBarButtonItem?.title = "Cancle"
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
        
        findAllMembers()
    }
    
    
    // MARK: - Server Connection For All Likes
    
    
    func menuAction(sender:UIButton){
        var memberInfo:NSDictionary
        memberInfo = allMembers[sender.tag] as! NSDictionary
        if let menuItem = memberInfo["request_action"] as? NSDictionary{
            
            updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String)
            self.findAllMembers()
        }
        
    }
    
    
    func updateMembers(parameter: NSDictionary , url : String){
        
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
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center,msg: succeeded["message"] as String, timer: true )
                        }
                        self.allMembers.removeAll(keepCapacity: false)
                        self.findAllMembers()
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
    
    
    
    
    func findAllMembers(){
        
        // Check Internet Connection
        if reachability.isReachable() {
            removeAlert()
            if (self.pageNumber == 1) && allMembers.count > 0{
                membersTableView.reloadData()
            }
            
            
            
            // Set Spinner
            spinner.center = self.view.center
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            if contentType == "members"{
                mainView.addSubview(spinner)
            }else{
                view.addSubview(spinner)
            }
            spinner.startAnimating()
            
            
            
            
            var url = ""
            var parameter = ["limit":"5", "page":"\(pageNumber)"]
            switch(contentType){
            case "activityFeed", "comments":
                url = "/likes-comments"
                parameter.merge(["content_id":"\(likeCommentContent_id)", "content_type": "\(likeCommentContentType)","viewAllLikes":"1"])
            case "user":
                parameter.merge(["user_id":"\(contentId)"])
                url = "user/get-friend-list"
            case "members":
                url = "notifications/friend-request"
                
            default:
                print("error")
            }
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameter.merge(searchDic)
            }
            
            // Send Server Request to Share Content
            post(parameter, url: url, method: "GET") { (succeeded, msg) -> () in
                
                // Remove Spinner
                dispatch_async(dispatch_get_main_queue(),{
                    spinner.stopAnimating()
                    
                    
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center,msg: succeeded["message"] as String, timer: true )
                        }
                        
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                
                                if (self.contentType == "members") || (self.contentType == "user"){
                                    if let likes = body["response"] as? NSArray{
                                        self.allMembers += likes
                                    }
                                    if let members = body["totalItemCount"] as? Int{
                                        self.totalItems = members
                                    }
                                }else{
                                    if let likes = body["viewAllLikesBy"] as? NSArray{
                                        self.allMembers += likes
                                    }
                                    if let members = body["getTotalLikes"] as? Int{
                                        self.totalItems = members
                                    }
                                }
                            }
                            
                            self.isPageRefresing = false
                            self.membersTableView.reloadData()
                            
                        }
                        
                        
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center,msg: succeeded["message"] as String, timer: false )
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            self.showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 80
        }else{
            return 0.001
        }
    }
    
    // Set Table Header Height
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set Table Section
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    // Set No. of Rows in Section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return allMembers.count
    }
    
    // Set Cell of TabelView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        var memberInfo:NSDictionary
        memberInfo = allMembers[indexPath.row] as! NSDictionary
        
        var subjectMember = memberInfo["subject"] as! NSDictionary
        
        var requestAction = memberInfo["request_action"] as! NSDictionary
        
        
        // Set Name People who Likes Content
        cell.labTitle.text = subjectMember["displayname"] as? String
        
        //        let tapGesture = UITapGestureRecognizer(target: self, action: "klikPlay:")
        //        cell.labTitle.addGestureRecognizer(tapGesture)
        //        view.addGestureRecognizer(tapGesture)
        
        
        
        cell.labTitle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        cell.labTitle.sizeToFit()
        
        
        // Set Owner Image
        let url = NSURL(string: subjectMember["image_icon"]! as NSString)
        downloadData(url!, { (downloadedData, msg) -> () in
            if msg{
                dispatch_async(dispatch_get_main_queue(), {
                    cell.imgUser.image = UIImage(data: downloadedData)
                })
            }
        })
        
        if let menu = memberInfo["request_action"] as? NSDictionary{
            var buttonTitle:String
            var menuName = menu["name"] as! String
            buttonTitle = ""
            if(menuName == "accept_request"){
                buttonTitle = "Accept"
            }
            
            let optionMenu = createButton(CGRectMake(CGRectGetWidth(view.bounds) - 100, 0, 100, CGRectGetHeight(cell.bounds)), buttonTitle, false, false, textColorDark)
            //  optionMenu.setBackgroundImage(UIImage(named: "icon-option.png"), forState: .Normal)
            optionMenu.addTarget(self, action: "menuAction:", forControlEvents: .TouchUpInside)
            optionMenu.tag = indexPath.row
            cell.accessoryView = optionMenu
        }
        
        dynamicHeight = cell.labTitle.frame.origin.y + CGRectGetHeight(cell.labTitle.bounds) + 5
        
        if dynamicHeight < (CGRectGetHeight(cell.imgUser.bounds) + 10){
            dynamicHeight = (CGRectGetHeight(cell.imgUser.bounds) + 10)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var memberInfo:NSDictionary
        memberInfo = allMembers[indexPath.row] as! NSDictionary
        
        var subjectMember = memberInfo["subject"] as! NSDictionary
        
        let presentedVC = ContentFeedViewController()//GroupDetailViewController()
        //        presentedVC.subjectId = subjectMember["user_id"] as Int
        //        presentedVC.subjectType = "users"
        //
        //        println(presentedVC.subjectId)
        //
        
        presentedVC.subjectType = "user"
        presentedVC.subjectId = subjectMember["user_id"] as Int
        
        
        //  let presentedVC = GroupDetailViewController()
        
        //            presentedVC.groupName = groupInfo["title"] as String
        //            presentedVC.groupId = groupInfo["group_id"] as Int
        navigationController?.pushViewController(presentedVC, animated: true)
        
        
        
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        
//        // if updateScrollFlag{
//        // Check for Page Number for Browse Blog
//        if membersTableView.contentOffset.y >= membersTableView.contentSize.height - membersTableView.bounds.size.height{
//            if (!isPageRefresing  && limit*pageNumber < totalItems){
//                if reachability.isReachable() {
//                    //            updateScrollFlag = false
//                    pageNumber += 1
//                    isPageRefresing = true
//                    findAllMembers()
//                }
//            }
//            
//        }
//        
//        //  }
//        
//    }
       
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
