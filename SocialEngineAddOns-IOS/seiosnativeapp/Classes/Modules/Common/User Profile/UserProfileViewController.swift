////
////  UserProfileViewController.swift
////  seiosnativeapp
////
////  Created by bigstep on 02/04/15.
////  Copyright (c) 2015 bigstep. All rights reserved.
////
//
//import UIKit
//
//class UserProfileViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{
//    let mainView = UIView()
//    var mainSubView:UIView!
//    var userViewTable:UITableView!
//     var coverImage:UIImageView!
//    var userName:UILabel!
//    var extraMenuLeft:UIButton!
//    var extraMenuRight:UIButton!
//     var tabsContainerMenu:UIScrollView!
//     var headerHeight:CGFloat = 0
//    var myTitle:String!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//        
//        openMenu = false
//        view.backgroundColor = bgColor
//        navigationController?.navigationBar.hidden = false
//        
//        let sidePanelController = SidePanelViewController() //SlideMenuTableViewController()//
//        addChildViewController(sidePanelController)
//        view.insertSubview(sidePanelController.view, atIndex: 0)
//        sidePanelController.view.frame = CGRectMake(0, 64, 320 * 0.8, CGRectGetHeight(view.bounds)-64)
//        
//        let subViews = mainView.subviews
//        for subview in subViews{
//            subview.removeFromSuperview()
//        }
//        
//        mainView.frame = view.frame
//        mainView.backgroundColor = bgColor
//        view.addSubview(mainView)
//        mainView.removeGestureRecognizer(tapGesture)
//        
//        self.title = myTitle
//        
//        let menu = UIBarButtonItem(image: UIImage(named:"icon-menu.png"), style: UIBarButtonItemStyle.Plain , target:self , action: "openSlideMenu")
//        navigationItem.leftBarButtonItem = menu
//        
//        
//        userViewTable = UITableView(frame: CGRectMake(0, 0, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)),style: .Grouped)
//        userViewTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        userViewTable.dataSource = self
//        userViewTable.delegate = self
//        mainView.addSubview(userViewTable)
//        
//        
//        //    scrollView.frame = view.frame
//        
//        //  scrollView.delegate = self
//        
//        // Set Background Images on ScrollView
//        
//        
//        // scrollView.pagingEnabled = true
//        
//        
//        if(UIDevice.currentDevice().userInterfaceIdiom == .Pad){
//            mainSubView = createView(CGRectMake(PADING, PADING, CGRectGetWidth(view.bounds)-(2*PADING), 300), borderColorDark, false)
//        }else{
//            mainSubView = createView(CGRectMake(PADING, PADING, CGRectGetWidth(view.bounds)-(2*PADING), 200), borderColorDark, false)
//        }
//        mainSubView.hidden = true
//        userViewTable.addSubview(mainSubView)
//        
//        
//        coverImage = createImageView(CGRectMake(0, 0, CGRectGetWidth(mainSubView.bounds), CGRectGetHeight(mainSubView.bounds)), true)
//        coverImage.contentMode = UIViewContentMode.Top //UIViewContentMode.ScaleAspectFill
//        coverImage.layer.masksToBounds = true
//        coverImage.backgroundColor = UIColor.redColor()
//        mainSubView.addSubview(coverImage)
//        
//        
//        userName = createLabel(CGRectMake(contentPADING, CGRectGetHeight(coverImage.bounds)-100, CGRectGetWidth(mainSubView.bounds) - (2 * contentPADING), 100), "", .Left, textColorLight)
//        //        userName.layer.shadowColor = UIColor.lightGrayColor().CGColor
//        //        userName.numberOfLines = 0
//        //        userName.layer.shadowOpacity = 1.0
//        //        userName.layer.shadowRadius = 4.0
//        userName.numberOfLines = 0
//        userName.layer.shadowColor = shadowColor.CGColor
//        userName.layer.shadowOpacity = shadowOpacity
//        userName.layer.shadowRadius = shadowRadius
//        userName.layer.shadowOffset = shadowOffset
//        coverImage.addSubview(userName)
//        
//        
//        extraMenuLeft  = createButton(CGRectMake(0,300 , 20, ButtonHeight), "", false,false, textColorDark)
//        extraMenuLeft.backgroundColor = TabMenubgColor
//        extraMenuLeft.hidden = true
//        userViewTable.addSubview(extraMenuLeft)
//        
//        extraMenuRight  = createButton(CGRectMake(CGRectGetWidth(view.bounds)-20,300 , 20, ButtonHeight), "", false,false, textColorDark)
//        extraMenuRight.backgroundColor = TabMenubgColor
//        extraMenuRight.hidden = true
//        userViewTable.addSubview(extraMenuRight)
//        
//        
//        tabsContainerMenu = UIScrollView(frame: CGRectMake(20, 300,CGRectGetWidth(view.bounds)-40 ,ButtonHeight ))
//        tabsContainerMenu.delegate = self
//        tabsContainerMenu.backgroundColor = TabMenubgColor
//        tabsContainerMenu.hidden = true
//        userViewTable.addSubview(tabsContainerMenu)
//        
//
//        
//        
//    }
//
//    override func viewDidAppear(animated: Bool) {
//        if openMenu{
//            openMenu = false
//            openMenuSlideOnView(mainView)
//        }
//        
////        if groupView_Update == true{
////            groupView_Update = false
//            exploreUserProfile()
//  //      }
//    }
//    
//    // Show Slide Menu
//    func openSlideMenu(){
//        // Add TapGesture On Open Slide Menu
//        if openMenu{
//            openMenu = false
//        }else{
//            openMenu = true
//            tapGesture = tapGestureCreation(self)
//        }
//        openMenuSlideOnView(mainView)
//        
//    }
//    
//    
//    // Handle TapGesture On Open Slide Menu
//    func handleTap(recognizer: UITapGestureRecognizer) {
//        openMenu = false
//        openMenuSlideOnView(mainView)
//        mainView.removeGestureRecognizer(tapGesture)
//    }
//
//    
//    
//    // Generate Custom Alert Messages
//    func showAlertMessage( centerPoint: CGPoint, msg: String){
//        self.view .addSubview(validationMsg)
//        showCustomAlert(centerPoint, msg)
//        // Initialization of Timer
//        createTimer(self)
//    }
//    
//    // Stop Timer
//    func stopTimer() {
//        stop()
////        if popAfterDelay == true {
////            self.navigationController?.popViewControllerAnimated(true)
////        }
//    }
//
//    func showtabMenu(){
//        
//        for ob in tabsContainerMenu.subviews{
//            if ob.tag == 101{
//                ob.removeFromSuperview()
//            }
//        }
//        
//        var origin_x:CGFloat = 0
//        for menu in tabMenu{
//            if let menuItem = menu as? NSDictionary{
//            
//                 var button_title = menuItem["label"] as String
//                if let totalItem = menuItem["totalItemCount"] as? Int{
//                if totalItem > 0{
//                    button_title += " (\(totalItem))"
//                }
//            }
//                var width = findWidthByText(button_title) + 10
//                
//                var menu = createButton(CGRectMake(origin_x,0 ,width , CGRectGetHeight(tabsContainerMenu.bounds)),button_title , false,false, textColorDark)
//                menu.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
//                menu.tag = 101
//                //             //                //                if menuItem["name"] as String == "update"{
//                //                //                    menu.addTarget(self, action: "showUpdates", forControlEvents: .TouchUpInside)
//                //                //                }
//                //                if menuItem["name"] as String == "members"{
//                menu.addTarget(self, action: "tabMenuAction:", forControlEvents: .TouchUpInside)
//                //                }
//                //                if menuItem["name"] as String == "photos"{
//                //  menu.addTarget(self, action: "showPhotos:", forControlEvents: .TouchUpInside)
//                //               }
//                tabsContainerMenu.addSubview(menu)
//                origin_x += width
//            }
//        }
//        if origin_x > CGRectGetWidth(view.bounds){
//            extraMenuRight.setTitle(">", forState: .Normal)
//            //    extraMenuRight.addTarget(self, action: "moveRight", forControlEvents: .TouchUpInside)
//        }
//        
//        tabsContainerMenu.contentSize = CGSizeMake(origin_x, CGRectGetHeight(tabsContainerMenu.bounds))
//        
//    }
//    
//    func tabMenuAction(sender:UIButton){
//        for menu in tabMenu{
//            if let menuItem = menu as? NSDictionary{
//                var button_title = menuItem["label"] as String
//                if let totalItem = menuItem["totalItemCount"] as? Int{
//                    if totalItem > 0{
//                        button_title += " (\(totalItem))"
//                    }
//                }
//                if sender.titleLabel?.text == button_title{
//                    // Set Particular Tab MenuAction
//                    if menuItem["name"] as String == "info"{
////                        var presentedVC = ShowMembersViewController()
////                        presentedVC.contentType = "group"
////                        presentedVC.url = menuItem["url"] as String
////                        presentedVC.param = menuItem["urlParams"] as NSDictionary
////                        navigationController?.pushViewController(presentedVC, animated: true)
//                    }
//                    if menuItem["name"] as String == "friends"{
//                        var presentedVC = MembersViewController()
//                        presentedVC.contentType = "users"
//                        navigationController?.pushViewController(presentedVC, animated: true)
//                   }
//                    if menuItem["name"] as String == "blog"{
//                        var presentedVC = BlogViewController()
//                        navigationController?.pushViewController(presentedVC, animated: true)
//                   }
//                    if menuItem["name"] as String == "group"{
//                        var presentedVC = GroupViewController()
//                        navigationController?.pushViewController(presentedVC, animated: true)
//                      }
//                    if menuItem["name"] as String == "event"{
//                        var presentedVC = EventViewController()
//                        navigationController?.pushViewController(presentedVC, animated: true)
//                    }
//                }
//            }
//        }
//    }
//
//    
//    
//    
//    // Explore Group Detail
//    func exploreUserProfile(){
//        // Check Internet Connection
//        if reachability.isReachable() {
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
//            mainView.addSubview(spinner)
//            spinner.startAnimating()
//            
//            
//            
//            // Send Server Request to Explore Group Contents with Group_ID
//            post(["token":"\(auth_token)","user_id":"\(currentUserId)", "gutter_menu": "1", "profile_tabs" : "1"], "user/profile", "GET") { (succeeded, msg) -> () in
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    spinner.stopAnimating()
//                    
//                    if msg{
//                        
//                        if succeeded["message"] != nil{
//                            self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
//                            
//                        }
//                        if succeeded["body"] != nil{
//                            println(succeeded)
//                            
//                            // On Success Update Group Detail
//                            if let userInfo = succeeded["body"] as? NSDictionary {
//                                
////                                // Update Group Gutter Menu
////                                if let menu = userInfo["gutterMenu"] as? NSArray{
////                                    gutterMenu = menu
////                                    let menu = UIBarButtonItem(image: UIImage(named:"icon-option.png"), style: UIBarButtonItemStyle.Plain , target:self , action: "showGutterMenu")
////                                    self.navigationItem.rightBarButtonItem = menu
////                                    
////                                }
////                                
//                                // Update Group tabContainer Menu
//                                if let menu = userInfo["profile_tabs"] as? NSArray{
//                                    tabMenu = menu
//                                    self.tabsContainerMenu.hidden = false
//                                }
//                                
//                                
//                                if let response = userInfo["response"] as? NSDictionary{
//                                    // Update Blog Detail
//                                    //   dispatch_async(dispatch_get_main_queue(), {
//                                   // self.title = response["title"] as? String
//                                    
//                                    
////                                    self.groupDescription = response["description"] as String
//                                    self.mainSubView.hidden = false
//                                    
//                                    if var photoId = response["photo_id"] as? Int{
//                                        if photoId != 0{
//                                            if let url = NSURL(string: response["image"] as String){
//                                                downloadData(url, { (downloadedData, msg) -> () in
//                                                    if msg{
//                                                        dispatch_async(dispatch_get_main_queue(), {
//                                                            self.coverImage.image = imageWithImage(UIImage(data: downloadedData)!, CGRectGetWidth(self.coverImage.bounds))
//                                                            
//                                                          //  println(self.coverImage.image?.size)
//                                                            
//                                                        })
//                                                    }
//                                                })
//                                            }}else{
//                                            self.coverImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, CGRectGetWidth(self.coverImage.bounds))
//                                            
//                                        }
//                                    }
//                                    
//                                    self.userName.font = UIFont(name: fontName, size: FONTSIZEExtraLarge)
//                                    self.userName.text = response["title"] as? String
//                                    self.userName.lineBreakMode = NSLineBreakMode.ByCharWrapping
//                                    self.userName.sizeToFit()
//                                    // if findWidthByText((response["title"] as? String)!) > CGRectGetWidth(self.userName.bounds){
//                                    self.userName.frame.origin.y = CGRectGetHeight(self.coverImage.bounds) - (CGRectGetHeight(self.userName.bounds) + contentPADING)
//                                    // }
//                                    
////                                    self.userInfo = response
////                                    self.updateGroupViewTableInfo(response)
//                                     var origin_y:CGFloat = (CGRectGetHeight(self.mainSubView.bounds) + self.mainSubView.frame.origin.y + PADING)
//                                    self.tabsContainerMenu.frame.origin.y = origin_y + contentPADING
//                                    self.extraMenuLeft.frame.origin.y = origin_y + contentPADING
//                                    self.extraMenuRight.frame.origin.y = origin_y + contentPADING
//                                    self.extraMenuRight.hidden = false
//                                    self.extraMenuLeft.hidden = false
//                                    
//                                    self.headerHeight =  self.tabsContainerMenu.frame.origin.y + CGRectGetHeight(self.tabsContainerMenu.bounds)
////                                    activityFeed.view.hidden = false
////                                    activityFeed.view.frame = CGRectMake(0, tabsContainerMenu.frame.origin.y + CGRectGetHeight(tabsContainerMenu.bounds), CGRectGetWidth(view.bounds) ,CGRectGetHeight(view.bounds))
////                                    
////                                    self.headerHeight = activityFeed.view.frame.origin.y + CGRectGetHeight(activityFeed.view.bounds)
////                                    
////                                    //  self.activityFeed.view.frame = CGRectMake(0, self.tabsContainerMenu.frame.origin.y + CGRectGetHeight(self.tabsContainerMenu.bounds) - 64, CGRectGetWidth(self.view.bounds) ,CGRectGetHeight(self.view.bounds))
////                                    
////                                    // self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width  ,  self.view.frame.size.height)
////                                    
////                                    editGroupID = response["group_id"] as Int
//                                    
//                                    //  self.showgutterMenu()
//                                    self.showtabMenu()
//                                    
//                                    
//                                    self.userViewTable.reloadData()
//                                    
//                                }
//                                
//                            }
//                        }
//                    }else{
//                        // Handle Server Side Error
//                        if succeeded["message"] != nil{
//                            self.showAlertMessage(self.view.center,msg: (succeeded["message"] as String) )
//                        }
//                    }
//                })
//            }
//        }else{
//            // No Internet Connection Message
//            showAlertMessage(view.center , msg: network_status_msg)
//        }
//        
//    }
//    
//    // MARK:  UITableViewDelegate & UITableViewDataSource
//    
//    // Set Height for TableView Footer
//    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.00001
//    }
//    
//    // Set Height for TableView Header
//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        
//        return headerHeight // for main Info Section height is 0
//    }
//    
//    
//    // Set no. of sections in TableView
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    // Set no. of rows in Every section of TableView
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//        return 0
//    }
//    
//    
//    // Set Cell of TableView
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
//    {
//        // dequeue a cell for the given indexPath
//        var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
//        cell.selectionStyle = UITableViewCellSelectionStyle.None
//        cell.backgroundColor = tableViewBgColor
//        cell.textLabel?.text = "abc"
//        
//        
//        
//        /*  if indexPath.section == 0{
//        println("selctAll \(selectAll)")
//        if selectAll == true{
//        cell.accessoryType = .Checkmark
//        }else{
//        cell.accessoryType = .None
//        }
//        }
//        else if indexPath.section == 1{
//        println("\(indexPath.row) in \(indexPath.section)  & \(checkedInfo[indexPath.row])")
//        if selectAll == true{
//        cell.accessoryType = .Checkmark
//        }else{
//        if checkedInfo[indexPath.row] == true{
//        cell.accessoryType = .Checkmark
//        }else{
//        cell.accessoryType = .None
//        }
//        }
//        
//        }*/
//        
//        return cell
//    }
//    
//    
//    // Section of Row in TableView
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        // Deselect Selected Row
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
//        
//        /*     var cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
//        
//        // println(cell.accessoryType)
//        if indexPath.section == 0{
//        if selectAll == true{
//        selectAll = false
//        for(var i = 0 ;i < checkedInfo.count ; i++) {
//        checkedInfo[i] = false
//        }
//        
//        }else if selectAll == false{
//        selectAll = true
//        for(var i = 0 ;i < checkedInfo.count ; i++) {
//        checkedInfo[i] = true
//        }
//        }
//        }
//        if indexPath.section == 1{
//        if checkedInfo[indexPath.row] == true{
//        checkedInfo[indexPath.row] = false
//        }else{
//        checkedInfo[indexPath.row] = true
//        }
//        }
//        inviteTable.reloadData()*/
//    }
//    
//    
//    
//    // MARK:  UIScrollViewDelegate
//    
//    // Handle Scroll For Pagination
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        
//        // if scrollView == tabsContainerMenu{
//        if tabsContainerMenu.contentOffset.x > 0 {
//            extraMenuLeft.setTitle("<", forState: .Normal)
//        }else if tabsContainerMenu.contentOffset.x <= 0 {
//            extraMenuLeft.setTitle("", forState: .Normal)
//        }
//        
//        if tabsContainerMenu.contentOffset.x + CGRectGetWidth(tabsContainerMenu.bounds) <  tabsContainerMenu.contentSize.width{
//            extraMenuRight.setTitle(">", forState: .Normal)
//        }else if tabsContainerMenu.contentOffset.x + CGRectGetWidth(tabsContainerMenu.bounds) ==  tabsContainerMenu.contentSize.width{
//            extraMenuRight.setTitle("", forState: .Normal)
//        }
//        
//        
//    }
//    
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
