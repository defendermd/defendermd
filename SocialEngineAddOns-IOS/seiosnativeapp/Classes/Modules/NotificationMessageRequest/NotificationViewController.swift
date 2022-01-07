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

//  NotificationViewController.swift
import UIKit
import NVActivityIndicatorView
var notificationUpdate : Bool!

class NotificationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let mainView = UIView()                  // true for Browse Notifications & false for My Notifications
    var showSpinner = true                      // not show spinner at pull to refresh
    var notificationsResponse:[Notifications] = []            // For response come from Server
    var requestsResponse = [AnyObject]()            // For response come from Server
    var isPageRefresing = false                 // For Pagination
    var notificationTableView:UITableView!              // TAbleView to show the notifications Contents
    var requestTableView : UITableView!
    var notifications:UIButton!                    // notifications Types
    var requests:UIButton!
    var refresher:UIRefreshControl!             // Pull to refrresh
    var requestRefresher : UIRefreshControl!
    var pageNumber:Int = 1
    var requestsPageNumber:Int = 1
    var totalItems:Int = 0
    var requestsTotalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 80              // Dynamic Height fort for Cell
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent = false;
    var photos:[PhotoViewer] = []
    var notificationIcon : UILabel!
    var refreshbutton : UIButton!
    var colorUnread:UIColor!
    var refreshTable:Bool = false
    // var imageCache = [String:UIImage]()
    var browseNotificationRequest : Int = 0 //0 for Notifications, 1 for request
    var requestIcon : UILabel!
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        notificationUpdate = true
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        openMenu = false
        updateAfterAlert = true
        isPageRefresing = true
        
        setNavigationImage(controller: self)
        self.navigationItem.hidesBackButton = true
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        self.navigationItem.title = NSLocalizedString("Notifications",  comment: "")
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        }
        
        notificationIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(notificationIcon)
        notificationIcon.isHidden = true
        
        requestIcon = createLabel(CGRect(x:0,y:0,width:0,height:0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(requestIcon)
        requestIcon.isHidden = true
        
        refreshbutton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshbutton)
        refreshbutton.isHidden = true
        
        
        notifications = createNavigationButton(CGRect(x: 0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) , title: NSLocalizedString("Notifications",  comment: ""), border: true, selected: true)
        notifications.tag = 11
        notifications.layer.borderColor = navColor.cgColor
        notifications.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
        notifications.addTarget(self, action: #selector(NotificationViewController.requestView(_:)), for: .touchUpInside)
        mainView.addSubview(notifications)
        
        
        requests = createNavigationButton(CGRect(x: view.bounds.width/2.0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) , title: NSLocalizedString("Requests",  comment: ""), border: true, selected: false)
        requests.tag = 22
        requests.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
        requests.addTarget(self, action: #selector(NotificationViewController.requestView(_:)), for: .touchUpInside)
        mainView.addSubview(requests)
        
        // Initialize notifications Table
        notificationTableView = UITableView(frame: CGRect(x: 0, y: requests.bounds.height + requests.frame.origin.y  , width: view.bounds.width, height: view.bounds.height-(requests.bounds.height  + requests.frame.origin.y) - tabBarHeight), style: .grouped)
        notificationTableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: "Cell")
        notificationTableView.dataSource = self
        notificationTableView.delegate = self
        notificationTableView.estimatedRowHeight = 70
        notificationTableView.rowHeight = UITableView.automaticDimension
        notificationTableView.backgroundColor = tableViewBgColor
        notificationTableView.separatorColor = TVSeparatorColor
        if #available(iOS 11.0, *) {
            self.notificationTableView.estimatedRowHeight = 0
            self.notificationTableView.estimatedSectionHeaderHeight = 0
            self.notificationTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(notificationTableView)
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(NotificationViewController.refresh), for: UIControl.Event.valueChanged)
        notificationTableView.addSubview(refresher)
        
        // Initialize Blog Table
        requestTableView = UITableView(frame: CGRect(x:0, y:requests.bounds.height + requests.frame.origin.y  , width:view.bounds.width, height:view.bounds.height-(requests.bounds.height + requests.frame.origin.y) - tabBarHeight ), style: .grouped)
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
        
        requestRefresher = UIRefreshControl()
        requestRefresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        requestRefresher.addTarget(self, action: #selector(NotificationViewController.refresh), for: UIControl.Event.valueChanged)
        requestTableView.addSubview(requestRefresher)
        
        
        if logoutUser == true || showOnlyMyContent == true{
            notifications.isHidden = true
            requests.isHidden = true
            requests.frame.origin.y = TOPPADING
            notificationTableView.frame.origin.y = requests.bounds.height + 2 * contentPADING + requests.frame.origin.y
            notificationTableView.frame.size.height = view.bounds.height - (requests.bounds.height + 2 * contentPADING + requests.frame.origin.y)
        }
        if browseNotificationRequest == 0{
            notificationTableView.isHidden = false
            requestTableView.isHidden = true
        }else if browseNotificationRequest == 1{
            notificationTableView.isHidden = true
            requestTableView.isHidden = false
            
        }
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        notificationTableView.tableFooterView = footerView
        notificationTableView.tableFooterView?.isHidden = true
        
        let footerView2 = UIView(frame: frameActivityIndicator)
        footerView2.backgroundColor = UIColor.clear
        
        let activityIndicatorView2 = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView2.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView2.addSubview(activityIndicatorView2)
        activityIndicatorView2.startAnimating()
        
        requestTableView.tableFooterView = footerView2
        requestTableView.tableFooterView?.isHidden = true
        
        //browseEntries()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showSpinner = true
        browseEntries()
        UpdateNotifications()
        removeNavigationViews(controller: self)
    }
    
    // Check for notifications Update Every Time when View Appears
    
    override func viewDidAppear(_ animated: Bool) {
        
        setNavigationImage(controller: self)
        if(self.navigationController?.navigationBar.isHidden == true)
        {
            self.navigationController?.navigationBar.isHidden = false
        }
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        if notificationUpdate == true{
            if isPageRefresing == true{
                pageNumber = 1
                showSpinner = true
                updateScrollFlag = false
            }
            //browseEntries()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        notificationTableView.tableFooterView?.isHidden = true
        requestTableView.tableFooterView?.isHidden = true
        NotificationCenter.default.removeObserver(self)
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            showSpinner = false
            
            if browseNotificationRequest == 0{
                pageNumber = 1
            }else if browseNotificationRequest == 1{
                requestsPageNumber = 1
            }
            updateAfterAlert = false
            browseEntries()
        }else{
            // No Internet Connection Message
            if browseNotificationRequest == 0{
                refresher.endRefreshing()
            }else if browseNotificationRequest == 1{
                requestRefresher.endRefreshing()
            }
            showToast(message: network_status_msg, controller: self)
        }
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
    
    
    // Update Notifications
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            // Reset Objects
            
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            self.refreshbutton.isHidden = true
            self.notificationIcon.isHidden = true
            self.requestIcon.isHidden = true
            
            if (self.pageNumber == 1 || self.requestsPageNumber == 1){
                if updateAfterAlert == true || searchDic.count > 0 {
                    removeAlert()
                    //                    if browseNotificationRequest == 0{
                    //                        self.notificationTableView.reloadData()
                    //                    }else if browseNotificationRequest == 1{
                    //                        self.requestTableView.reloadData()
                    //                    }
                    
                    
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
                //     spinner.center = mainView.center
                if browseNotificationRequest == 0 && self.pageNumber == 1
                {
                    activityIndicatorView.center = mainView.center
                    updateScrollFlag = false
                }
                else if browseNotificationRequest == 1 && self.requestsPageNumber == 1
                {
                    activityIndicatorView.center = mainView.center
                    updateScrollFlag = false
                    
                }
                    
                else if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                    
                }
                self.view.addSubview(activityIndicatorView)
                
                activityIndicatorView.startAnimating()
                notifications.isUserInteractionEnabled = false
                requests.isUserInteractionEnabled = false
            }
            
            var path = ""
            var parameters = [String:String]()
            
            path = "notifications"
            
            if browseNotificationRequest == 0{
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "myRequests": "0", "recentUpdates" : "1"]
                notifications.setSelectedButton()
                requests.setUnSelectedButton()
                self.navigationItem.title = NSLocalizedString("Notifications",  comment: "")
            }else if browseNotificationRequest == 1{
                parameters = ["page":"\(requestsPageNumber)" , "limit": "\(limit)", "myRequests": "1", "recentUpdates" : "0"]
                requests.setSelectedButton()
                notifications.setUnSelectedButton()
                self.title = NSLocalizedString("Requests",  comment: "")
            }
            
            if tabBarController != nil{
                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
            }
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            notifications.isUserInteractionEnabled = false
            requests.isUserInteractionEnabled = false
            
            
            // Send Server Request to Browse Notifications Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.requestRefresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.notifications.isUserInteractionEnabled = true
                    self.requests.isUserInteractionEnabled = true
                    
                    if msg{
                        
                        
                        if self.pageNumber == 1 && self.browseNotificationRequest == 0{
                            self.notificationsResponse.removeAll(keepingCapacity: false)
                        }else if self.requestsPageNumber == 1 && self.browseNotificationRequest == 1{
                            self.requestsResponse.removeAll(keepingCapacity: false)
                            
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if self.browseNotificationRequest == 0{
                                if let notification = response["recentUpdates"] as? NSArray {
                                    self.notificationsResponse += Notifications.loadNotifications(notification)
                                }
                                if response["recentUpdateTotalItemCount"] != nil{
                                    self.totalItems = response["recentUpdateTotalItemCount"] as! Int
                                }
                            }else if self.browseNotificationRequest == 1{
                                if let request = response["myRequests"] as? NSArray{
                                    self.requestsResponse = self.requestsResponse + (request as [AnyObject])
                                }
                                if response["requestTotalItemCount"] != nil{
                                    self.requestsTotalItems = response["requestTotalItemCount"] as! Int
                                }
                            }
                            
                        }
                        
                        self.isPageRefresing = false
                        
                        if self.browseNotificationRequest == 0{
                            
                            
                            if self.notificationsResponse.count == 0{
                                self.notificationIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 25, y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(friendReuestIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.notificationIcon.font = UIFont(name: "FontAwesome", size: 40)
                                self.mainView.addSubview(self.notificationIcon)
                                self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any Notifications.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.info.center = self.view.center
                                self.info.backgroundColor = bgColor
                                self.info.tag = 1000
                                self.mainView.addSubview(self.info)
                                //if  (UIDevice.current.userInterfaceIdiom == .phone){
                                //imgUser = createImageView(CGRect(x: 10, y: 5, width: 80, height: 80), border: true)
                                // }
                                if (UIDevice.current.userInterfaceIdiom == .phone) {
                                    let frame = CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + ( 2*contentPADING), width: 80, height: 40)
                                    self.refreshbutton = createButton(frame, title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                                }
                                else {
                                    let frame = CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + ( 2*contentPADING), width: 100, height: 40)
                                    self.refreshbutton = createButton(frame, title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                                    self.refreshbutton.titleLabel?.adjustsFontSizeToFitWidth = true
                                }
                                self.refreshbutton.backgroundColor = bgColor
                                self.refreshbutton.layer.borderColor = navColor.cgColor
                                self.refreshbutton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                self.refreshbutton.titleLabel?.adjustsFontSizeToFitWidth = true
                                self.refreshbutton.addTarget(self, action: #selector(NotificationViewController.browseEntries), for: UIControl.Event.touchUpInside)
                                self.refreshbutton.layer.cornerRadius = 5.0
                                self.refreshbutton.layer.masksToBounds = true
                                self.refreshbutton.tag = 1000
                                self.mainView.addSubview(self.refreshbutton)
                                self.refreshbutton.isHidden = false
                                self.notificationIcon.isHidden = false
                            }
                            self.notificationTableView.reloadData()
                            
                        }
                        else if self.browseNotificationRequest == 1{
                            
                            if self.requestsResponse.count == 0{
                                
                                self.requestIcon = createLabel(CGRect(x:self.view.bounds.width/2 - 25, y:self.view.bounds.height/2-80,width:60 , height:60), text: NSLocalizedString("\(friendReuestIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.requestIcon.tag = 1000
                                self.requestIcon.font = UIFont(name: "FontAwesome", size: 50)
                                self.mainView.addSubview(self.requestIcon)
                                
                                self.info = createLabel(CGRect(x:0, y:0,width:self.view.bounds.width * 0.8 , height:50), text: NSLocalizedString("You don't have any pending request.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.info.sizeToFit()
                                self.info.numberOfLines = 0
                                self.info.center = self.view.center
                                self.info.backgroundColor = bgColor
                                self.info.tag = 1000
                                self.mainView.addSubview(self.info)
                                
                                if (UIDevice.current.userInterfaceIdiom == .phone) {
                                    let frame = CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + ( 2*contentPADING), width: 80, height: 40)
                                    self.refreshbutton = createButton(frame, title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                                }
                                else {
                                    let frame = CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + ( 2*contentPADING), width: 100, height: 40)
                                    self.refreshbutton = createButton(frame, title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                                    self.refreshbutton.titleLabel?.adjustsFontSizeToFitWidth = true
                                }
                                self.refreshbutton.backgroundColor = bgColor
                                self.refreshbutton.layer.borderColor = navColor.cgColor
                                self.refreshbutton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                self.refreshbutton.titleLabel?.adjustsFontSizeToFitWidth = true
                                self.refreshbutton.tag = 1000
                                self.refreshbutton.addTarget(self, action: #selector(NotificationViewController.browseEntries), for: UIControl.Event.touchUpInside)
                                self.refreshbutton.layer.cornerRadius = 5.0
                                self.refreshbutton.layer.masksToBounds = true
                                self.mainView.addSubview(self.refreshbutton)
                                
                                self.requestIcon.isHidden = false
                                self.refreshbutton.isHidden = false
                                
                            }
                            self.requestTableView.reloadData()
                            
                            
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
    
    
    // Update Notifications
    @objc func UpdateNotifications(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            // Reset Objects
            
            var path = ""
            
            path = "notifications/markallread"
            
            // Send Server Request to Browse Notifications Entries
            post([String:String](), url: path, method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if msg{
                        
                    }
                    else{
                        
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
    
    //    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //        return dynamicHeight
    //    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Notifications Tabel Footer Height
    
    //    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    //
    //
    //        var tempItems = 0
    //        if browseNotificationRequest == 0{
    //
    //            tempItems = requestsTotalItems
    //        }else if browseNotificationRequest == 1{
    //            tempItems = totalItems
    //        }
    //
    //        if (limit*pageNumber < tempItems){
    //
    //            return 0
    //
    //        }else{
    //
    //            return 0.00001
    //        }
    //    }
    
    // Set Notifications Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            
            return dynamicHeight
        }
        else
        {
            dynamicHeight = 110.0
        }
        
        
        return dynamicHeight
    }
    
    
    // Set Notifications Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if browseNotificationRequest == 1{
            return requestsResponse.count
        }
        
        return notificationsResponse.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotificationTableViewCell
        
        for ob in mainView.subviews{
            if ob.tag == 1000 || ob.tag == 1001 || ob.tag == 1002 {
                ob.removeFromSuperview()
                break
            }
        }
        if browseNotificationRequest == 1 && requestsResponse.count > 0{
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            
            var requestInfo:NSDictionary
            requestInfo = requestsResponse[indexPath.row] as! NSDictionary
            
            // Set Blog Title
            cell.labTitle.frame = CGRect(x:cell.imgUser.bounds.width + 10, y:10,width:(UIScreen.main.bounds.width - 75) , height:100)
            
            
            cell.labTitle.text = requestInfo["title"] as? String
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labTitle.sizeToFit()
            
            let type = requestInfo["type"] as! String
            
            if let ownerName = requestInfo["feed_title"] as? String {
                if let postedDate = requestInfo["date"] as? String{
                    let postedOn = dateDifference(postedDate)
                    //                    cell.labMessage.frame = CGRect(x:cell.imgUser.bounds.width + 10, y:10,width:(UIScreen.main.bounds.width - 75) , height:100)
                    
                    cell.labMessage.frame = CGRect(x: cell.imgUser.bounds.width + 20, y: 10,width: (UIScreen.main.bounds.width - cell.imgUser.bounds.width - 22) , height: cell.imgUser.bounds.height-5)
                    
                    cell.labIcon.frame = CGRect(x: cell.imgUser.bounds.width  - 20, y: 54,width: 30, height: 30)
                    //                    cell.labPostedDate.frame = CGRect(x: cell.imgUser.bounds.width + cell.labIcon.bounds.width + 14, y: 49,width: (UIScreen.main.bounds.width - 90) , height: 20)
                    
                    var labMsg = ""
                    var iconType : String
                    if(type == "liked"){
                        iconType = likeIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "DC143C")
                    }else if(type.range(of:"comment") != nil)//(type == "commented_commented" || type == "commented")
                    {
                        iconType = commentIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "006400")
                    }else if(type == "shared"){
                        iconType = shareIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "8B4513")
                    }else if(type.range(of:"message") != nil){
                        iconType = messageIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "000080")
                    }else if(type.range(of:"subscribe") != nil){
                        iconType = subscribeIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "4B0082")
                    }else if(type.range(of:"friend") != nil){
                        iconType = friendReuestIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "008080")
                    }else if(type == "group_invite"){
                        iconType = inviteIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "C71585")
                    }else if(type == "event_invite"){
                        iconType = inviteIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "C71585")
                    }
                    else if(type == "video" || type == "sitevideo_processed"){
                        iconType = videoIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "2E8B57")
                    }
                    else if(type == "friend_accepted"){
                        iconType = friendRequestIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "008080")
                    }
                        //                    else if(type == "event_suggestion"){
                        //                        iconType = inviteIcon
                        //                        cell.labIcon.backgroundColor = UIColor(hex: "C71585")
                        //                    }
                    else if(type == "friend_request"){
                        iconType = friendRequestIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "000080")
                    }
                    else if(type.range(of:"tagged") != nil)//(type == "tagged")
                    {
                        iconType = taggingIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "4B0082")
                    }
                    else if(type == "post_user"){
                        iconType = postedIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "8B008B")
                    }
                    else if(type == "sitegroup_join"){
                        iconType = joinGroupEventIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "C71585")
                    }
                    else if(type == "siteevent_join"){
                        iconType = joinGroupEventIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "C71585")
                    }
                    else{
                        iconType = notificationDefaultIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "800080")
                    }
                    
                    cell.labIcon.text = iconType
                    //  cell.labIcon.backgroundColor = .random
                    
                    labMsg = String(format: NSLocalizedString("%@ \n%@", comment: ""), ownerName,postedOn)
                    cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let boldFont = CTFontCreateWithName( (fontName as CFString?)! , FONTSIZENormal, nil)
                        
                        
                        // start work for bold title
                        if  let body_param = requestInfo["action_type_body_params"] as? NSArray{
                            for i in 0 ..< body_param.count{
                                let body1 = body_param[i] as! NSDictionary
                                let search = body1["label"] as! String
                                let boldFont = CTFontCreateWithName((fontBold as CFString?)!, FONTSIZEMedium, nil)
                                
                                let range = (labMsg as NSString).range(of:NSLocalizedString(search,  comment: ""))
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                            }
                        }
                        // finish work for bold title
                        
                        let range1 = (labMsg as NSString).range(of: postedOn)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range1)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size:FONTSIZESmall)!, range: range1)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                        
                        // TODO: Clean this up..
                        return mutableAttributedString
                    })
                    
                }
                
            }
            
            cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labMessage.sizeToFit()
            cell.labMessage.center.y = cell.imgUser.center.y
            
            let subject = requestInfo["subject"] as! NSDictionary
            
            let url = NSURL(string: subject["image_profile"] as! String)
            let fileName = "\((url?.lastPathComponent)!)"
            let ownerImage:NSData = getImageFromCache(fileName) as NSData
            if ownerImage.length == 0 {
                
                if url != nil
                {
                    cell.imgUser.kf.indicatorType = .activity
                    (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgUser.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                
            }
            
            
            
            cell.optionMenu.frame = CGRect(x:view.bounds.width - 30, y:35, width:30, height:35)
            cell.optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZELarge)
            cell.optionMenu.tag = indexPath.row
            cell.optionMenu.isHidden = false
            if(type == "event_invite"){
                cell.optionMenu.addTarget(self, action: #selector(NotificationViewController.showEventOptions(sender:)), for: .touchUpInside)
            }else if(type == "group_invite"){
                cell.optionMenu.addTarget(self, action: #selector(NotificationViewController.showGroupOptions(sender:)), for: .touchUpInside)
            }else if(type == "friend_request"){
                cell.optionMenu.addTarget(self, action: #selector(NotificationViewController.showFriendOptions(sender:)), for: .touchUpInside)
            }else{
                cell.optionMenu.isHidden = true
            }
            
            dynamicHeight = cell.labMessage.frame.origin.y + cell.labMessage.bounds.height + 5
            if dynamicHeight < (cell.imgUser.bounds.height + 10){
                dynamicHeight = (cell.imgUser.bounds.height + 10)
            }
            
        }else if browseNotificationRequest == 0 && notificationsResponse.count > 0{
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.tag = indexPath.row
            
            
            let notificationInfo = notificationsResponse[(indexPath as NSIndexPath).row]
            if  cell.tag == (indexPath as NSIndexPath).row{
                let isShow1  = notificationInfo.show
                if(isShow1 == 0){
                    self.colorUnread = UIColor(red: 41/255 , green: 121/255 , blue: 255/255 , alpha: 0.1)
                    cell.backgroundColor = self.colorUnread
                    
                }
                    
                else if(isShow1 == 1){
                    cell.backgroundColor = UIColor.white
                    
                }
            }
            if let ownerName = notificationInfo.feed_title {
                if let postedDate = notificationInfo.notification_date{
                    let postedOn = dateDifference(postedDate)
                    cell.labMessage.frame = CGRect(x: cell.imgUser.bounds.width + 20, y: 10,width: (UIScreen.main.bounds.width - cell.imgUser.bounds.width - 22) , height: cell.imgUser.bounds.height-5)
                    
                    cell.labIcon.frame = CGRect(x: cell.imgUser.bounds.width  - 20, y: 54,width: 30, height: 30)
                    
                    //                    cell.labPostedDate.frame = CGRect(x: cell.imgUser.bounds.width + cell.labIcon.bounds.width + 14, y: 49,width: (UIScreen.main.bounds.width - 90) , height: 20)
                    //
                    
                    var labMsg = ""
                    
                    let type = notificationInfo.type
                    var iconType : String
                    
                    if(type == "liked"){
                        iconType = likeIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "DC143C")
                    }else if(type?.range(of:"comment") != nil)//(type == "commented_commented" || type == "commented")
                    {
                        iconType = commentIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "006400")
                    }else if(type == "shared"){
                        iconType = shareIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "8B4513")
                    }else if(type?.range(of:"message") != nil){
                        iconType = messageIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "000080")
                    }else if(type?.range(of:"subscribe") != nil){
                        iconType = subscribeIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "4B0082")
                    }else if(type?.range(of:"friend") != nil){
                        iconType = friendReuestIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "008080")
                    }else if(type == "group_invite"){
                        iconType = inviteIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "C71585")
                    }else if(type == "event_invite"){
                        iconType = inviteIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "C71585")
                    }
                    else if(type == "video" || type == "sitevideo_processed"){
                        iconType = videoIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "2E8B57")
                    }
                    else if(type == "friend_accepted"){
                        iconType = friendRequestIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "008080")
                    }
                        //                    else if(type == "event_suggestion"){
                        //                        iconType = inviteIcon
                        //                        cell.labIcon.backgroundColor = UIColor(hex: "C71585")
                        //                    }
                    else if(type == "friend_request"){
                        iconType = friendRequestIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "000080")
                    }
                    else if(type?.range(of:"tagged") != nil)//(type == "tagged")
                    {
                        iconType = taggingIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "4B0082")
                    }
                    else if(type == "post_user"){
                        iconType = postedIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "8B008B")
                    }
                    else if(type == "sitegroup_join"){
                        iconType = joinGroupEventIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "C71585")
                    }
                    else if(type == "siteevent_join"){
                        iconType = joinGroupEventIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "C71585")
                    }
                    else{
                        iconType = notificationDefaultIcon
                        cell.labIcon.backgroundColor = UIColor(hex: "800080")
                    }
                    
                    //    labMsg = String(format: NSLocalizedString("%@ \n \n %@ %@", comment: ""), ownerName, iconType, postedOn)
                    labMsg = String(format: NSLocalizedString("%@ \n%@", comment: ""), ownerName,postedOn)
                    
                    cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        let boldFont = CTFontCreateWithName( (fontName as CFString?)!, FONTSIZENormal, nil)
                        
                        
                        // start work for bold title
                        if  let body_param = notificationInfo.actionBodyParam{
                            for i in 0 ..< body_param.count{
                                let body1 = body_param[i] as! NSDictionary
                                let search = String(describing: body1["label"] as AnyObject)
                                let boldFont = CTFontCreateWithName((fontBold as CFString?)!, FONTSIZEMedium, nil)
                                
                                let range = (labMsg as NSString).range(of:NSLocalizedString(search,  comment: ""))
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                            }
                        }
                        // finish work for bold title
                        //
                        //
                        let range1 = (labMsg as NSString).range(of: postedOn)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range1)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "FontAwesome", size:FONTSIZESmall)!, range: range1)
                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                        // TODO: Clean this up..
                        return mutableAttributedString!
                    })
                    
                    cell.labIcon.text = iconType
                    //   cell.labIcon.backgroundColor = .random
                    //     cell.labPostedDate.text = postedOn
                    
                }
                
            }
            
            cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labMessage.sizeToFit()
            
            cell.labMessage.center.y = cell.imgUser.center.y
            
            
            // Set Notifications Owner Image
            let subject = notificationInfo.subject
            cell.imgUser.image = UIImage(named: "user_profile_image.png")
            if let url = URL(string: subject?["image_profile"] as! String)
            {
                
                let urlconvert = String(describing: url)
                if urlconvert != ""
                {
                    
                    cell.imgUser.kf.indicatorType = .activity
                    (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgUser.kf.setImage(with: url as URL?, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                    
                }
                
            }
            
            dynamicHeight = 90
            
            if dynamicHeight < (cell.labMessage.frame.origin.y + cell.labMessage.bounds.height + 20)
            {
                dynamicHeight = (cell.labMessage.frame.origin.y + cell.labMessage.bounds.height + 20)+10
                // cell.cellView.frame.size.height = dynamicHeight
            }
            
        }
        
        
        return cell
        
    }
    
    // Handle Notifications Table Cell Selection
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.tag = (indexPath as NSIndexPath).row
        
        
        if (selectedCell.tag == (indexPath as NSIndexPath).row){
            selectedCell.backgroundColor = UIColor.white
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if browseNotificationRequest == 0{
            
            let notificationInfo = notificationsResponse[indexPath.row]
            if let objectDictionary =  notificationInfo.object {
                let object_type = notificationInfo.object_type
                let notificationId = notificationInfo.notification_id
                let share1 = notificationInfo.type
                activityIndicatorView.center = CGPoint(x: UIScreen.main.bounds.width/2 , y : UIScreen.main.bounds.height/2)
                UIApplication.shared.keyWindow?.addSubview(activityIndicatorView)//addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
                
                if (share1 == "shared")
                {
                    let subDic = notificationInfo.params
                    let dic1 = subDic?["label"] as! String
                    if dic1 == "blog"
                    {
                        
                        BlogObject().redirectToBlogDetailPage(self,blogId: objectDictionary["object_id"] as! Int,title: "")
                    }
                    
                }
                if share1 == "live_streaming"{
                    let subDic = notificationInfo.params
                    let streamName = subDic?["stream_name"] as! String
                    selectedCell.isUserInteractionEnabled = false
                    let main_videoId = subDic?["main_subject_id"] as! Int
                    let main_videoType = subDic?["main_subject_type"] as! String
                    
                    
                    let url = "livestreamingvideo/is-live"
                    let method = "GET"
                    var dic1 = [String : String]()
                    dic1["stream_name"] = streamName
                    
                    
                    post(dic1 , url: "\(url)", method: method) { (succeeded, msg) -> () in
                        DispatchQueue.main.async(execute: {
                            
                            
                            if msg{
                                
                                if succeeded["body"] != nil
                                {
                                    activityIndicatorView.stopAnimating()
                                    if let response = succeeded["body"] as? NSDictionary
                                    {
                                        if response["isLive"] as! Int == 0 {
                                            
                                            
                                            if response["endType"] as! String == "normal" || response["endType"] as! String == "story"{
                                                showToast(message: "Live Video Ended", controller: self)
                                            }
                                            else{
                                                if objectDictionary["video_url"] != nil {
                                                    let presentedVC = AdvanceVideoProfileViewController()
                                                    presentedVC.videoProfileTypeCheck = ""//"AdvEventProfile"
                                                    presentedVC.videoId = main_videoId
                                                    presentedVC.videoType = 3
                                                    
                                                    presentedVC.videoUrl = objectDictionary["video_url"] as! String
                                                    selectedCell.isUserInteractionEnabled = true
                                                    
                                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                                    nativationController.modalPresentationStyle = .fullScreen
                                                    self.parent?.present(nativationController, animated:true, completion: nil)
                                                }
                                                else{
                                                    selectedCell.isUserInteractionEnabled = true
                                                    showToast(message: "Video Upload is in Progress..", controller: self)
                                                }
                                            }
                                        }
                                            
                                        else{
                                            selectedCell.isUserInteractionEnabled = true
                                            let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                                            if let liveStreamingClass = NSClassFromString(moduleName + "." + "LiveObjectViewController") as? LiveStreamingObjectDelegates.Type{
                                                liveStreamingClass.redirectToLivePageFromNotification(self , isBroadcaster: false , chName: streamName, videoId : main_videoId , videoType : main_videoType)
                                            }
                                        }
                                        
                                        
                                    }
                                }
                                //    })
                                
                            }
                                
                            else{
                                
                                
                            }
                        })
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.readNotification(notificationId! as Int)
                    })
                    
                    return
                }
                if(object_type == "blog")
                {
                    BlogObject().redirectToBlogDetailPage(self,blogId: objectDictionary["blog_id"] as! Int,title: "")
                }
                else if (object_type == "sitestoreproduct_order")
                {
                    let presentedVC = OrderReviewViewController()
                    var orderId : Int = 0
                    if let oderId = objectDictionary["order_id"] as? Int
                    {
                        orderId = oderId
                    }
                    let oderid = "#"+"\(orderId)"
                    let orderUrl = "sitestore/orders/view/"+"\(orderId)"
                    presentedVC.orderId = oderid
                    presentedVC.url = orderUrl
                    presentedVC.iscomingFrom = "MYorders"
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "classified")
                {
                    
                    ClassifiedObject().redirectToProfilePage(self, id: objectDictionary["classified_id"] as! Int)
                    
                }
                else if (object_type == "video" || object_type == "sitevideo_processed")
                {
                    if enabledModules.contains("sitevideo")
                    {
                        
                        SitevideoObject().redirectToAdvVideoProfilePage(self,videoId: objectDictionary["video_id"] as! Int,videoType:objectDictionary["type"] as! Int,videoUrl: objectDictionary["video_url"] as! String)
                    }
                    else
                    {
                        VideoObject().redirectToVideoProfilePage(self, videoId : objectDictionary["video_id"] as! Int, videoType : objectDictionary["type"] as! Int, videoUrl : objectDictionary["video_url"] as! String)
                    }
                    
                }
                else if (object_type == "poll"){
                    let presentedVC = PollProfileViewController()
                    presentedVC.pollId = objectDictionary["poll_id"] as! Int
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "music_playlist")
                {
                    
                    MusicObject().redirectToPlaylistPage(self,id: objectDictionary["playlist_id"] as! Int)
                    
                }
                else if (object_type == "album")
                {
                    
                    let presentedVC = AlbumProfileViewController()
                    presentedVC.albumId = "\(objectDictionary["album_id"]!)"
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "album_photo")
                {
                    let presentedVC = AdvancePhotoViewController()
                    var photoArray = [NSDictionary]()
                    photoArray.append(objectDictionary)
                    presentedVC.allphotos = photoArray
                    presentedVC.photoID = 0
                    presentedVC.albumId = objectDictionary["album_id"] as! Int
                    presentedVC.photoType = "photo"
                    presentedVC.attachmentID = "\(objectDictionary["album_id"]!)"
                    presentedVC.ownerTitle = "null1"
                    presentedVC.total_items = 1
                    presentedVC.photoForViewer = photos
                    presentedVC.imageUrl = objectDictionary["image"] as! String
                    presentedVC.param = ["subject_type" : "album","subject_id" : String(objectDictionary["album_id"] as! Int)]
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "group")
                {
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
                }
                else if (object_type == "user"){
                    if let subjectDictionary =  notificationInfo.subject {
                        let presentedVC = ContentActivityFeedViewController()
                        presentedVC.subjectType = "user"
                        presentedVC.subjectId = "\(subjectDictionary["user_id"]!)"
                        if share1 == "post_user" {
                           presentedVC.subjectId = "\(objectDictionary["user_id"]!)"
                        }
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                }
                else if (object_type == "event"){
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "event"
                    presentedVC.subjectId = "\(objectDictionary["event_id"]!)"
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "suggestion"){
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "advancedevents"
                    presentedVC.subjectId = "\(objectDictionary["entity_id"]!)"
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "activity_action"){
                    
                    
                    likeCommentContent_id = "\(objectDictionary["action_id"]!)"
                    likeCommentContentType = "activity_action"
                    let presentedVC = CommentsViewController()
                    presentedVC.openCommentTextView = 1
                    presentedVC.actionId = "\(objectDictionary["action_id"]!)"
                    presentedVC.activityfeedIndex = indexPath.row
                    presentedVC.activityFeedComment = true
                    presentedVC.fromActivityFeed = true
                    presentedVC.fromSingleFeed = true
                    presentedVC.fromNotification = true
                    presentedVC.commentPermission = 1
                    // add
                    presentedVC.commentFeedArray =  notificationsResponse
                    // add
                    presentedVC.actionIdDelete = objectDictionary["action_id"] as! Int
                    presentedVC.reactionsIcon = []
                    
                    self.navigationController?.pushViewController(presentedVC, animated: true)
                    
                    
                }
                else if (object_type == "activity_comment"){
                    
                    likeCommentContent_id = "\(objectDictionary["resource_id"]!)"
                    likeCommentContentType = "activity_action"
                    let presentedVC = CommentsViewController()
                    presentedVC.openCommentTextView = 1
                    presentedVC.actionId = "\(objectDictionary["resource_id"]!)"
                    presentedVC.activityfeedIndex = indexPath.row
                    presentedVC.activityFeedComment = true
                    presentedVC.fromActivityFeed = true
                    presentedVC.fromSingleFeed = true
                    presentedVC.fromNotification = true
                    presentedVC.commentPermission = 1
                    // add
                    presentedVC.commentFeedArray =  notificationsResponse
                    // add
                    presentedVC.actionIdDelete = objectDictionary["resource_id"] as! Int
                    presentedVC.reactionsIcon = []
                    self.navigationController?.pushViewController(presentedVC, animated: true)
                    
                    
                }
                else if (object_type == "core_comment")
                {
                    
                    //print(objectDictionary)
                    likeCommentContent_id = "\(objectDictionary["resource_id"]!)"
                    likeCommentContentType = objectDictionary["resource_type"]! as! String
                    let presentedVC = CommentsViewController()
                    presentedVC.openCommentTextView = 1
                    presentedVC.actionId = "\(objectDictionary["resource_id"]!)"
                    presentedVC.activityfeedIndex = indexPath.row
                    presentedVC.activityFeedComment = true
                    presentedVC.fromActivityFeed = true
                    presentedVC.fromSingleFeed = false
                    presentedVC.fromNotification = true
                    presentedVC.commentPermission = 1
                    // add
                    presentedVC.commentFeedArray =  notificationsResponse
                    // add
                    presentedVC.actionIdDelete = objectDictionary["resource_id"] as! Int
                    presentedVC.reactionsIcon = []
                    self.navigationController?.pushViewController(presentedVC, animated: true)
                    
                    
                }
                else if (object_type == "forum_topic")
                {
                    
                    let presentedVC = ForumTopicViewController()
                    presentedVC.topicId = objectDictionary["topic_id"] as! Int
                    presentedVC.topicName = objectDictionary["title"] as! String
                    presentedVC.slug = objectDictionary["slug"] as! String
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                    
                else if (object_type == "sitepage_page"){
                    SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: "\(objectDictionary["page_id"]!)")
                    
                }
                else if object_type == "sitereview_review"{
                    if let listingtype_id = objectDictionary["listingtype_id"] as? Int{
                        let listingTypeId = listingtype_id
                        
                        if listingTypeId != 0{
                            
                            if let _ = objectDictionary["review_id"] as? Int{
                                if let listingId = objectDictionary["resource_id"] as? Int{
                                    let presentedVC = UserReviewViewController()
                                    presentedVC.mytitle = objectDictionary["title"] as! String
                                    presentedVC.subjectId = "\(listingId)"
                                    presentedVC.listingTypeId = listingTypeId
                                    presentedVC.contentType = "listings"
                                    
                                    navigationController?.pushViewController(presentedVC, animated: true)
                                }
                            }
                        }
                    }
                }
                else if object_type == "sitereview_wishlist"{
                    
                    let presentedVC = WishlistDetailViewController()
                    presentedVC.subjectId = objectDictionary["wishlist_id"] as! Int
                    presentedVC.wishlistName = objectDictionary["title"] as! String
                    presentedVC.descriptionWishlist = objectDictionary["body"] as! String
                    navigationController?.pushViewController(presentedVC, animated: true)
                    
                }
                else if (object_type == "sitegroup_group"){
                    SiteAdvGroupObject().redirectToAdvGroupProfilePage(self, subject_type: "sitegroup_group", subject_id: "\(objectDictionary["group_id"]!)")
                }
                    
                else if object_type == "sitereview_listing"{
                    if let listingtype_id = objectDictionary["listingtype_id"] as? Int{
                        let listingTypeId = listingtype_id
                        if listingTypeId != 0{
                            
                            var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingTypeId]!
                            let viewType = tempBrowseViewTypeDic["viewType"]!
                            
                            
                            if let listingId = objectDictionary["listing_id"] as? Int{
                                
                                SiteMltObject().redirectToMltProfilePage(self ,subjectType : "sitereview_listing" , listingTypeIdValue : listingTypeId , listingIdValue : "\(listingId)" , viewTypeValue : viewType)
                            }
                        }
                    }
                    
                }
                else if object_type == "sitevideo_channel"{
                    SitevideoObject().redirectToChannelProfilePage(self, videoId:"\(objectDictionary["channel_id"]!)",subjectType: object_type!)
                    
                }
                else if object_type == "sitevideo_playlist"{
                    SitevideoObject().redirectToPlaylistProfilePage(self, playlistId: "\(objectDictionary["playlist_id"]!)",subjectType: object_type!)
                }
                else
                {
                    let presentedVC = ExternalWebViewController()
                    
                    
                    if let webUrl = notificationInfo.object["url"] as? String{
                        presentedVC.url = webUrl
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let navigationController = UINavigationController(rootViewController: presentedVC)
                        self.present(navigationController, animated: true, completion: nil)
                    }
                }
                
                
                self.readNotification(notificationId! as Int)
                
                
            }
            
        }
        else if browseNotificationRequest == 1{
            var requestInfo:NSDictionary
            requestInfo = requestsResponse[indexPath.row] as! NSDictionary
            var subjectDictionary : NSDictionary = [:]
            if let subjectDic = requestInfo["subject"] as? NSDictionary
            {
                subjectDictionary = subjectDic
            }
            if let objectDictionary =  requestInfo["object"] as? NSDictionary{
                
                let object_type = requestInfo["object_type"] as? String
                //            let notificationId = requestInfo["notification_id"] as? Int
                let share1 = requestInfo["type"]  as? String
                if (share1 == "shared") {
                    let subDic = requestInfo["params"] as? NSDictionary
                    let dic1 = subDic!["label"] as! String
                    
                    if dic1 == "blog"{
                        let presentedVC = BlogDetailViewController()
                        presentedVC.blogId = objectDictionary["object_id"] as! Int
                        presentedVC.blogName = "Loading"
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    
                }
                
                if(object_type == "blog"){
                    let presentedVC = BlogDetailViewController()
                    presentedVC.blogId = objectDictionary["blog_id"] as! Int
                    presentedVC.blogName = "Loading..."
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "classified"){
                    let presentedVC = ClassifiedDetailViewController()
                    presentedVC.classifiedId = objectDictionary["classified_id"] as! Int
                    presentedVC.classifiedName = "Loading..."
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "video" || object_type == "sitevideo_processed"){
                    let presentedVC = VideoProfileViewController()
                    presentedVC.videoId = objectDictionary["video_id"] as! Int
                    presentedVC.videoType = objectDictionary["type"] as? Int
                    presentedVC.videoUrl = objectDictionary["video_url"] as! String
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if object_type == "sitevideo_channel"{
                    SitevideoObject().redirectToChannelProfilePage(self, videoId: "\(objectDictionary["video_id"]!)",subjectType: object_type!)
                }
                else if object_type == "sitevideo_playlist"{
                    SitevideoObject().redirectToPlaylistProfilePage(self, playlistId: "\(objectDictionary["playlist_id"]!)",subjectType: object_type!)
                }
                else if (object_type == "music_playlist"){
                    let presentedVC = MusicPlayListViewController()
                    presentedVC.playListId = objectDictionary["playlist_id"] as! Int
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "album"){
                    let presentedVC = AlbumProfileViewController()
                    presentedVC.albumId = "\(objectDictionary["album_id"]!)"
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "group"){
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
                    
                }
                else if (object_type == "user")
                {
                    let presentedVC = ContentActivityFeedViewController()
                    presentedVC.subjectType = "user"
                    presentedVC.subjectId = "\(subjectDictionary["user_id"]!)"
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "event" ){
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "event"
                    presentedVC.subjectId = "\(objectDictionary["event_id"]!)"
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "suggestion"){
                    let presentedVC = ContentFeedViewController()
                    presentedVC.subjectType = "advancedevents"
                    presentedVC.subjectId = "\(objectDictionary["entity_id"]!)"
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "activity_action"){
                    let presentedVC = FeedViewPageViewController()
                    presentedVC.action_id = "\(objectDictionary["action_id"]!)"
                    navigationController?.pushViewController(presentedVC, animated: true)
                }
                else if (object_type == "sitegroup_group"){
                    SiteAdvGroupObject().redirectToAdvGroupProfilePage(self, subject_type: "sitegroup_group", subject_id: "\(objectDictionary["group_id"]!)")
                }
                    
                else
                {
                    let presentedVC = ExternalWebViewController()
                    if let webUrl = requestInfo["url"] as? String
                    {
                        presentedVC.url = webUrl
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let navigationController = UINavigationController(rootViewController: presentedVC)
                        self.present(navigationController, animated: true, completion: nil)
                    }
                }
                
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if notificationTableView.isHidden == false
        {
            let notificationInfo = notificationsResponse[(indexPath as NSIndexPath).row]
            
            let isShow1  = notificationInfo.show
            if(isShow1 == 0){
                return true
            }
            else {
                return false
                
            }
        }
        else
        {
            return false
        }
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?  {
        
        if tableView.isEditing {
            
            
            let markAction = UITableViewRowAction(style: UITableViewRowAction.Style.default, title: "Mark" , handler: {
                
                (action:UITableViewRowAction, indexPath:IndexPath) -> Void in
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotificationTableViewCell
                self.markNotification((indexPath as NSIndexPath).row)
                tableView.isEditing = false
                
                let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
                selectedCell.tag = (indexPath as NSIndexPath).row
                if (selectedCell.tag == (indexPath as NSIndexPath).row){
                    selectedCell.backgroundColor = UIColor.white
                    selectedCell.isEditing = false
                }
                
                
                cell.notificationIcon.isHidden = true
                
            })
            
            markAction.backgroundColor = navColor
            return [markAction]
            
        }
        
        return .none
        
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    
    func markNotification(_ index : Int){
        let notificationInfo = notificationsResponse[index]
        let notificationId = notificationInfo.notification_id
        self.readNotification(notificationId! as Int)
        
    }
    
    func readNotification(_ msgId: Int){
        var parameters = [String:String]()
        parameters = ["notification_id": "\(msgId)"]
        post(parameters, url: "notifications/mark-notification-show", method: "POST"){(succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if msg{
                    for (index,value) in self.notificationsResponse.enumerated(){
                        
                        if(value.notification_id == msgId){
                            let tempOldLikeDictionary :NSMutableDictionary = [:]
                            tempOldLikeDictionary["show"] = 1
                            let newDictionary:NSMutableDictionary = [:]
                            if let _ = value.subject{
                                newDictionary["subject"] = value.subject
                            }
                            if let _ = value.object{
                                newDictionary["object"] = value.object
                            }
                            if let _ = value.params{
                                newDictionary["params"] = value.params
                            }
                            newDictionary["feed_title"] = value.feed_title
                            newDictionary["action_type_body_params"] = value.actionBodyParam
                            newDictionary["type"] = value.type
                            newDictionary["date"] = value.notification_date
                            newDictionary["notification_id"] = value.notification_id
                            newDictionary["object_type"] = value.object_type
                            newDictionary["url"] = value.url
                            newDictionary["show"] = tempOldLikeDictionary["show"]
                            var newData = Notifications.loadNotificationsfromDictionary(newDictionary)
                            self.notificationsResponse[index] = newData[0] as Notifications
                        }
                    }
                }
            })
        }
        
    }
    //    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    //        let lastSectionIndex = tableView.numberOfSections - 1
    //        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
    //        //print("\(indexPath.row)  \(lastRowIndex) \(notificationsResponse.count)")
    //        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
    //
    //            if updateScrollFlag{
    //
    //                if browseNotificationRequest == 0{
    //
    //                        if (!isPageRefresing  && limit*pageNumber < totalItems){
    //                            if Reachabable.isConnectedToNetwork() {
    //                                updateScrollFlag = false
    //                                pageNumber += 1
    //                                isPageRefresing = true
    ////
    ////                                let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 20))
    ////                                footerView.backgroundColor = UIColor.clear
    ////
    ////                                let activityIndicator = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: navColor, padding: nil)
    ////                                activityIndicator.center = CGPoint(x:(self.view.bounds.width - 20)/2, y:5.0)
    ////                                footerView.addSubview(activityIndicator)
    ////                                activityIndicator.startAnimating()
    ////
    ////                                notificationTableView.tableFooterView = footerView
    ////                                notificationTableView.tableFooterView?.isHidden = false
    ////
    //                                if searchDic.count == 0{
    //                                    browseEntries()
    //
    //                                }
    //
    //                            }
    //
    //                    }
    //                }else if browseNotificationRequest == 1{
    //                        if (!isPageRefresing  && limit*requestsPageNumber < requestsTotalItems){
    //                            if Reachabable.isConnectedToNetwork() {
    //                                updateScrollFlag = false
    //                                requestsPageNumber += 1
    //                                isPageRefresing = true
    ////
    ////                                let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 20))
    ////                                footerView.backgroundColor = UIColor.clear
    ////
    ////                                let activityIndicator = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: navColor, padding: nil)
    ////                                activityIndicator.center = CGPoint(x:(self.view.bounds.width - 20)/2, y:5.0)
    ////                                footerView.addSubview(activityIndicator)
    ////                                activityIndicator.startAnimating()
    ////
    ////                                requestTableView.tableFooterView = footerView
    ////                                requestTableView.tableFooterView?.isHidden = false
    ////
    ////
    //                                if searchDic.count == 0{
    //                                    browseEntries()
    //                                }
    //                            }
    //
    //                    }
    //                }
    //
    //            }
    //        }
    //    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            
            if updateScrollFlag{
                
                if browseNotificationRequest == 0{
                    
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            notificationTableView.tableFooterView?.isHidden = false
                            //if searchDic.count == 0
                            // {
                            browseEntries()
                        }
                    }
                    else
                    {
                        notificationTableView.tableFooterView?.isHidden = true
                        
                    }
                }else if browseNotificationRequest == 1{
                    if (!isPageRefresing  && limit*requestsPageNumber < requestsTotalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            requestsPageNumber += 1
                            isPageRefresing = true
                            requestTableView.tableFooterView?.isHidden = false
                            //  if searchDic.count == 0{
                            browseEntries()
                            //  }
                        }
                        
                    }
                    else
                    {
                        requestTableView.tableFooterView?.isHidden = true
                        
                    }
                }
                
            }
            
        }
        
    }
    
    
    // Handle Scroll For Pagination
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //
    //        if updateScrollFlag{
    //
    //            if browseNotificationRequest == 0{
    //                // Check for Page Number for Browse notifications
    //                if notificationTableView.contentOffset.y >= notificationTableView.contentSize.height - notificationTableView.bounds.size.height{
    //                    if (!isPageRefresing  && limit*pageNumber < totalItems){
    //                        if Reachabable.isConnectedToNetwork() {
    //                            updateScrollFlag = false
    //                            pageNumber += 1
    //                            isPageRefresing = true
    //                            if searchDic.count == 0{
    //                                browseEntries()
    //
    //                            }
    //
    //                        }
    //                    }
    //
    //                }
    //            }else if browseNotificationRequest == 1{
    //                if requestTableView.contentOffset.y >= requestTableView.contentSize.height - requestTableView.bounds.size.height{
    //                    if (!isPageRefresing  && limit*requestsPageNumber < requestsTotalItems){
    //                        if Reachabable.isConnectedToNetwork() {
    //                            updateScrollFlag = false
    //                            requestsPageNumber += 1
    //                            isPageRefresing = true
    //                            if searchDic.count == 0{
    //                                browseEntries()
    //                            }
    //                        }
    //                    }
    //
    //                }
    //            }
    //
    //        }
    //
    //    }
    
    
    @objc func showEventOptions(sender:UIButton){
        var requestInfo:NSDictionary
        requestInfo = requestsResponse[sender.tag] as! NSDictionary
        let event_id = requestInfo["object_id"] as! Int
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Attending",comment: ""), style: .default) { action -> Void in
            let url = "events/member/accept"
            self.updateOptions(url: url as String, id: event_id as Int)
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Maybe Attending",comment: ""), style: .default) { action -> Void in
            let url = "events/member/accept"
            self.updateOptions(url: url as String, id: event_id as Int)
        })
        
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Ignore",comment: ""), style: UIAlertAction.Style.destructive) { action -> Void in
            let url = "events/member/ignore"
            self.updateOptions(url: url as String, id: event_id as Int)
        })
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x:view.bounds.height/2, y:view.bounds.width/2, width:0, height:0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
            
        }
        self.present(alertController, animated:true, completion: nil)
    }
    
    @objc func showGroupOptions(sender:UIButton){
        var requestInfo:NSDictionary
        requestInfo = requestsResponse[sender.tag] as! NSDictionary
        
        let group_id = requestInfo["object_id"] as! Int
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Join Group",comment: ""), style: .default) { action -> Void in
            let url = "groups/member/accept"
            self.updateOptions(url: url as String, id: group_id as Int)
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Ignore Group",comment: ""), style: UIAlertAction.Style.destructive) { action -> Void in
            
            let url = "groups/member/ignore"
            self.updateOptions(url: url as String, id: group_id as Int)
        })
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x:view.bounds.width/2 , y:view.bounds.height/2 , width:1, height:1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
        
    }
    
    @objc func showFriendOptions(sender:UIButton){
        var requestInfo:NSDictionary
        requestInfo = requestsResponse[sender.tag] as! NSDictionary
        let subject_id = requestInfo["subject_id"] as! Int
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Accept",comment: ""), style: .default) { action -> Void in
            let url = "user/add"
            self.selectFriend(url:url as String, id : subject_id as Int)
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Reject",comment: ""), style: UIAlertAction.Style.destructive) { action -> Void in
            
            let url = "user/cancel"
            self.selectFriend(url:url as String, id: subject_id as Int)
        })
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x:view.bounds.height/2, y:view.bounds.width/2, width:0, height:0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    func selectFriend(url : String,id : Int){
        var dic = Dictionary<String, String>()
        dic["user_id"] = "\(id)"
        activityIndicatorView.startAnimating()
        post(dic, url: "\(url)", method: "POST") {
            (succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
                if msg{
                    self.browseEntries()
                    //self.requestsResponse.remove(at:indexPath.row)
                    self.requestTableView.reloadData()
                }
            })
            
        }
        
    }
    
    func updateOptions(url : String, id : Int){
        
        var dic = Dictionary<String, String>()
        
        if(url.range(of:"event") != nil){
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
    
    @IBAction func requestView(_ sender: UIButton) {
        //        let vc = TwoViewController(nibName: "TwoViewController", bundle: nil)
        
        self.requestIcon.isHidden = true
        self.refreshbutton.isHidden = true
        self.notificationIcon.isHidden = true
        
        if sender.tag == 11{
            
            notifications.backgroundColor = buttonDeSelectColor
            requests.backgroundColor = buttonSelectColor
            notifications.setSelectedButton()
            requests.setUnSelectedButton()
            browseNotificationRequest = 0
            if notificationsResponse.count == 0
            {
                requestTableView.isHidden = true
                pageNumber = 1
                showSpinner = true
                browseEntries()
            }
            else
            {
                for ob in mainView.subviews{
                    if ob.tag == 1000{
                        ob.removeFromSuperview()
                    }
                }
                notificationTableView.isHidden = false
                requestTableView.isHidden = true
                notificationTableView.reloadData()
                
            }
            
        }else if sender.tag == 22{
            
            notifications.backgroundColor = buttonSelectColor
            requests.backgroundColor = buttonDeSelectColor
            notifications.setUnSelectedButton()
            requests.setSelectedButton()
            browseNotificationRequest = 1
            if requestsResponse.count == 0
            {
                notificationTableView.isHidden = true
                requestsPageNumber = 1
                requestTableView.isHidden = false
                showSpinner = true
                browseEntries()
            }
            else
            {
                for ob in mainView.subviews{
                    if ob.tag == 1000{
                        ob.removeFromSuperview()
                    }
                }
                requestTableView.isHidden = false
                notificationTableView.isHidden = true
                requestTableView.reloadData()
                
            }
        }
        
        
    }
    
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
