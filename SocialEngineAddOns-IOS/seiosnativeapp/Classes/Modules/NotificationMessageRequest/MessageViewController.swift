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
//  MessageViewController.swift
//  seiosnativeapp


import UIKit
import Foundation
import NVActivityIndicatorView
import Instructions

// Global Variable Initialization Used in Blog Module
var messageUpdate: Bool!
// true for Browse Blog & false for My Blog
var browseMessage:UIButton!                    // Blog Types
var myMessage:UIButton!
var createMessage = false
var deleteMessage:Bool! = false


class MessageViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , CoachMarksControllerDataSource, CoachMarksControllerDelegate{

    var editBlogID:Int = 0                          // Edit BlogID
    let mainView = UIView()
    var browseOrMyMessage = true
    var showSpinner = true                      // not show spinner at pull to refresh
    var blogResponse:[Message] = []
    var isPageRefresing = false                 // For Pagination
    var blogTableView:UITableView!              // TAbleView to show the blog Contents
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 80              // Dynamic Height fort for Cell
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent = false                // Flag to refresh Blog
    var customSegmentControl : UISegmentedControl!
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    var sendersDisplayNmae: String!
    var colorUnread:UIColor!
    var refresherTable = false
  //  var imageCache = [String:UIImage]()
    var leftBarButtonItem : UIBarButtonItem!
    var redirectedFrom = ""
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    // Initialization of class Object
    override func viewDidLoad() {
        
        super.viewDidLoad()
        messageUpdate = true
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        openMenu = false
        updateAfterAlert = true
        isPageRefresing = true
        let subViews = mainView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        
        // Navigation buttons
        createNavigation()

        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        self.navigationItem.title = NSLocalizedString("Messages",  comment: "")
        if tabBarController != nil{
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        }

        // Initialize Blog Types
        browseMessage = createNavigationButton(CGRect(x: 0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) , title: NSLocalizedString("Inbox",  comment: ""), border: true, selected: true)
        browseMessage.tag = 11
        browseMessage.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        browseMessage.addTarget(self, action: #selector(MessageViewController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(browseMessage)
        browseMessage.isHidden = false
        
        
        
        myMessage = createNavigationButton(CGRect(x: view.bounds.width/2.0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) , title: NSLocalizedString("Sent",  comment: ""), border: true, selected: false)
        myMessage.tag = 22
        //        myMessage.layer.cornerRadius = 2.5
        myMessage.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        myMessage.addTarget(self, action: #selector(MessageViewController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(myMessage)
        myMessage.isHidden = false
        
        let items = ["Inbox", "Sent Messages"]
        customSegmentControl = UISegmentedControl(items: items)
        customSegmentControl.addTarget(self, action: #selector(MessageViewController.indexChanged(_:)), for: UIControl.Event.valueChanged)
        customSegmentControl.frame = CGRect(x: 0,y: 0, width: view.bounds.width, height: ButtonHeight)
        customSegmentControl.selectedSegmentIndex = 0
        
        // Create Filter Search Link
        let filter = createButton(CGRect(x: 0, y: TOPPADING + contentPADING + ButtonHeight, width: 0 , height: 0), title: fiterIcon, border: true,bgColor: false, textColor: textColorDark)
        filter.addTarget(self, action: #selector(MessageViewController.filterSerach), for: .touchUpInside)
        filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        mainView.addSubview(filter)
        filter.isHidden = true
        
        
         // Initialize Blog Table
        blogTableView = UITableView(frame: CGRect(x: 0, y: filter.bounds.height + filter.frame.origin.y, width: view.bounds.width, height: view.bounds.height-(filter.bounds.height + filter.frame.origin.y) - tabBarHeight), style: .grouped)
        blogTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        blogTableView.dataSource = self
        blogTableView.delegate = self
        blogTableView.estimatedRowHeight = 80
        blogTableView.rowHeight = UITableView.automaticDimension
        blogTableView.backgroundColor = tableViewBgColor
        blogTableView.separatorColor = TVSeparatorColor
        if #available(iOS 11.0, *) {
            self.blogTableView.estimatedRowHeight = 0
            self.blogTableView.estimatedSectionHeaderHeight = 0
            self.blogTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(blogTableView)
        

        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(MessageViewController.refresh), for: UIControl.Event.valueChanged)
        blogTableView.addSubview(refresher)
        
        
        if logoutUser == true || showOnlyMyContent == true{
            browseMessage.isHidden = true
            myMessage.isHidden = true
            filter.frame.origin.y = TOPPADING

            blogTableView.frame.origin.y = filter.bounds.height + 2 * contentPADING + filter.frame.origin.y
            blogTableView.frame.size.height = view.bounds.height - (filter.bounds.height + 2 * contentPADING + filter.frame.origin.y)
            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.plain , target:self , action: #selector(MessageViewController.cancleSearch))
            self.navigationItem.rightBarButtonItem = addCancel
            
            
        }
 
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        blogTableView.tableFooterView = footerView
        blogTableView.tableFooterView?.isHidden = true
        
        browseEntries()
        
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        let flatCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(rect: frame)
        }
        //  self.blackScreen.alpha = 0.5
        var coachMark : CoachMark
        switch(index) {
            
            
            
            
        case 0:
            // skipView.isHidden = true
            var  coachMark2 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 15.0
            let radious : Int = 40
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
            coachMark2.disableOverlayTap = true
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
            
        default:
            coachMark = coachMarksController.helper.makeCoachMark()
            coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        }
        
        
        return coachMark
    }
    
    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController, at index: Int) -> Bool{
        
        coachMarksController.stop(immediately: true)
        return false
        
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        //  var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        // For the coach mark at index 2, we disable the ability to tap on the
        // coach mark to get to the next one, forcing the user to perform
        // the appropriate action.
        switch(index) {
        case 0:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        // coachViews.bodyView.isUserInteractionEnabled = false
        default:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
            //        case 0:
            //            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: "")) \n\n  1/2  "
            //            coachViews.bodyView.nextLabel.text = "Next"
            
        case 0:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(messageTourText)", comment: ""))"
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Got It", comment: "")
            
            
            
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        
        
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool)
    {
        print("End Skip")
        //  self.blackScreen.alpha = 0.0
        
    }
    
    func showAppTour(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showMessageAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showMessageAppTour") != nil {
                
                self.targetCheckValue = name as! Int
                
                
            }
            
        }
        
        if self.targetCheckValue == 1 {
            
            UserDefaults.standard.set(2, forKey: "showMessageAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(blogTableView != nil){
            blogTableView.tableFooterView?.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UpdateNotifications()
        removeNavigationViews(controller: self)
        if tabBarController != nil{
            self.tabBarController?.selectedIndex = 0
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        }
    }
    
    // Update BadgeCount
    @objc func UpdateNotifications(){
        
        // Check Internet Connectivity
        if reachability.connection != .none {
            // Reset Objects
            
            var path = ""
            
            path = "messages/mark-message-read-unread"
            
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
    
    func createNavigation()
    {
        if redirectedFrom != "AAF"
        {
            self.navigationItem.hidesBackButton = true
        }
        else
        {
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(MessageViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
        }
    }
    // MARK: - Back action
    @objc func goBack()
    {
        
          redirectedFrom = ""
        _ = self.navigationController?.popToRootViewController(animated: false)
    }
    @objc func indexChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            browseOrMyMessage = true
            self.browseEntries()
        case 1:
            browseOrMyMessage = false
            self.browseEntries()
        default:
            break;
        }
    }
    
    // Check for Blog Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        if deleteMessage == true{
            browseEntries()
            deleteMessage = false
        }
        
        //
        //            blogTableView.reloadData()
        
        if (messageUpdate == true && isPageRefresing == true){
            pageNumber = 1
            showSpinner = true
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
    
    // Open Filter Search Form
    @objc func filterSerach(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{

            searchDic.removeAll(keepingCapacity: false)
            messageUpdate = false
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "blogs/browse-search-form"
            presentedVC.serachFor = "blog"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    // Handle Browse Blog or My Blog PreAction
    @objc func prebrowseEntries(_ sender: UIButton){
        //print("1")
        //print(browseOrMyMessage)
        // true for Browse Blog & false for My Blog
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        if sender.tag == 22 {
            browseOrMyMessage = false
        }else if sender.tag == 11 {
            browseOrMyMessage = true
        }
        blogTableView.tableFooterView?.isHidden = true
        self.blogResponse.removeAll(keepingCapacity: false)
        searchDic.removeAll(keepingCapacity: false)
        updateScrollFlag = false
        pageNumber = 1
        // Update for Blog
        //print("2")
        showSpinner = true
        //print(browseOrMyMessage)
        browseEntries()
    }
    
    // Pull to Request Action
    @objc func refresh(){
        //        refresherTable = true
        // Check Internet Connectivity
        //  if blogResponse.count != 0{
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
    @objc func stopTimer() {
        stop()
    }
    
    // Update Blog
    @objc func browseEntries(){
        
        let subViews = mainView.subviews
        for ob in subViews{
            if ob.tag == 1000{
                ob.removeFromSuperview()
            }
            if(ob .isKind(of: NWCalendarView.self))
            {
                ob.removeFromSuperview()
            }
        }
        
        //print(browseOrMyMessage)
        contentIcon.isHidden = true
        refreshButton.isHidden = true
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            if showOnlyMyContent == true{
                browseOrMyMessage = false
            }
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            if (self.pageNumber == 1){
                if updateAfterAlert == true || searchDic.count > 0 {
                    //                    self.blogResponse.removeAll(keepingCapacity: false)
                    removeAlert()
                    self.blogTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
             //   spinner.center = mainView.center
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
            //print("4")
            //print(browseOrMyMessage)
            var path = ""
            var parameters = [String:String]()
            // Set Parameters for Browse/myMessage
            if browseOrMyMessage {
                //                browseOrMyMessage = false
                path = "messages/inbox"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                browseMessage.setSelectedButton()
                myMessage.setUnSelectedButton()
                
            }else{
                //                browseOrMyMessage = true
                path = "messages/outbox"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                browseMessage.setUnSelectedButton()
                myMessage.setSelectedButton()
                
            }
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            userInteractionOff = false
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    //})
                    self.blogTableView.tableFooterView?.isHidden = true
                    if msg{
                        self.isPageRefresing = false
                        if self.pageNumber == 1{
                            self.blogResponse.removeAll(keepingCapacity: false)
                        }
                        
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if response["response"] != nil{
                                if let messages = response["response"] as? NSArray {
                                    self.blogResponse += Message.loadMessages(messages)
                                }
                            }
                            
                            if response["getTotalItemCount"] != nil{
                                self.totalItems = response["getTotalItemCount"] as! Int
                            }
                            if canSendMessage != "none" {
                                let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(MessageViewController.composeMessage))
                                self.navigationItem.setRightBarButtonItems([addBlog], animated: true)
                                addBlog.tintColor = textColorPrime
                            }
                            if self.showOnlyMyContent == false && logoutUser == false && canSendMessage != "none"{
                                self.showAppTour()
                            }
                            
                        }
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        
                        //Reload Blog Tabel
                        self.blogTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.blogResponse.count == 0{
                            
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30, y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(messageIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.tag = 1000
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 40)
                            self.mainView.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any message.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.mainView.addSubview(self.info)
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING ), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(MessageViewController.browseEntries), for: UIControl.Event.touchUpInside)
                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.refreshButton.tag = 1000
                            self.mainView.addSubview(self.refreshButton)
                            
                            self.contentIcon.isHidden = false
                            self.refreshButton.isHidden = false
                            
                            
                        }
                        //   }
                        // })
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
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.tag = (indexPath as NSIndexPath).row
        let blogInfo = blogResponse[(indexPath as NSIndexPath).row]
        
        cell.imgUser.frame = CGRect(x: 5, y: 5, width: 70, height: 70)
        
        var message:NSDictionary
        message = blogInfo.message as NSDictionary
        
        
        var recipient:NSDictionary = [:]
        
        if blogInfo.recipient != nil
        {
        recipient = blogInfo.recipient as NSDictionary
        }
        var sender:NSDictionary
        sender = blogInfo.sender as NSDictionary
        
        var title = "No Subject"
        
        if var conversationTitle = message["title"] as? String{
            if conversationTitle.length > 35{
                conversationTitle = (conversationTitle as NSString).substring(to: 35-3) as String
                conversationTitle  = ((conversationTitle as String) + ("...")) as String
            }
            title = conversationTitle
        }
        
        var displayName = ""
        if (sender["displayname"] != nil){
            displayName  = sender["displayname"]! as! String
            sendersDisplayNmae = sender["displayname"]! as! String
        }
        
        // Set Blog Title
        cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10,width: (UIScreen.main.bounds.width - 75) , height: 100)
        cell.labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
        cell.labTitle.text = displayName
        sendersDisplayNmae =  cell.labTitle.text
        
        
        if let showVariable = recipient["inbox_read"] as? Int{
            if(showVariable == 0){
                if(cell.tag == (indexPath as NSIndexPath).row){
                    if browseOrMyMessage{
                        colorUnread = UIColor(red: 41/255 , green: 121/255 , blue: 255/255 , alpha: 0.1)
                        cell.backgroundColor = colorUnread
                    }
                }
                //cell.labTitle.textColor = navColor
                //                    mutableAttributedString.addAttribute(kCTForegroundColorAttributeName as! NSString, value: navColor, range: range)
            }else{
                //                    mutableAttributedString.addAttribute(kCTForegroundColorAttributeName as! NSString, value: textColorDark, range: range)
                cell.backgroundColor = UIColor.white
                
                //  cell.labTitle.textColor = textColorDark
            }
        }
        
        
        cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.labTitle.sizeToFit()
        
        if let postedDate = message["date"] as? String{
            let postedOn = dateDifference(postedDate)
            cell.labMessage.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5,width: (UIScreen.main.bounds.width - (cell.imgUser.bounds.width + 10)) , height: 100)
            var labMsg = ""
            labMsg = String(format: NSLocalizedString("%@\n%@", comment: ""), title, postedOn)
            
            cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString:NSMutableAttributedString?) -> NSMutableAttributedString? in
                let boldFont = CTFontCreateWithName( (fontName as CFString?)!, FONTSIZESmall, nil)
                let range = (labMsg as NSString).range(of: title as String)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value: textColorMedium, range: range)
                
                // TODO: Clean this up..
                return mutableAttributedString
            })
            
        }
        cell.labMessage.numberOfLines = 2
        cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.labMessage.sizeToFit()
        
        // Set Blog Owner Image
        let url = URL(string: sender["image"] as! String)

        cell.imgUser.kf.indicatorType = .activity
        (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
        cell.imgUser.kf.setImage(with: url as URL?, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
            
        })
        cell.accessoryView = nil
        cell.accessoryType = .disclosureIndicator

        
        return cell
        
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell:UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.tag = (indexPath as NSIndexPath).row
        
        if (selectedCell.tag == (indexPath as NSIndexPath).row){
            selectedCell.backgroundColor = UIColor.white
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        //        var blogInfo:NSDictionary
        //        blogInfo = Message[indexPath.row] as! NSDictionary
        let blogInfo = blogResponse[indexPath.row]
        let message = blogInfo.message as NSDictionary
        var subjectName : String
        let sender = blogInfo.sender as NSDictionary
        
        //print("\(String(describing: message["user_id"]))........>>>>>>>>>>>")
        
        if message["user_id"] != nil {
            if (message["user_id"] as? Int)! > 0 {
                let recipientcount = message["recipients_count"] as! Int
                if(recipientcount > 1){
                    subjectName = "\(recipientcount) people"
                }else{
                    if let name = sender["displayname"] as? String {
                        subjectName = name
                    }
                    else {
                    subjectName = "\(recipientcount) people"
                    }
                }
                
                let convId = message["conversation_id"] as! Int
                self.readMessage(convId as Int)
                let presentedVC = ConverstationViewController()
                presentedVC.subject = subjectName
                presentedVC.displaysendername = subjectName
                presentedVC.conversation_id = convId
                navigationController?.pushViewController(presentedVC, animated: true)
                DispatchQueue.main.async(execute: {
                    
                })
            }
        }
    }
    
    func readMessage(_ msgId: Int){
        for (index,value) in self.blogResponse.enumerated(){
            if value.recipient["conversation_id"] as! Int == msgId{
                
                
                let tempOldLikeDictionary :NSMutableDictionary = [:]
                tempOldLikeDictionary["inbox_read"] = "1"
                tempOldLikeDictionary["user_id"] = value.recipient["user_id"]
                tempOldLikeDictionary["conversation_id"] = value.recipient["conversation_id"]
                tempOldLikeDictionary["inbox_message_id"] = value.recipient["inbox_message_id"]
                tempOldLikeDictionary["inbox_updated"] = value.recipient["inbox_updated"]
                tempOldLikeDictionary["inbox_deleted"] = value.recipient["inbox_deleted"]
                tempOldLikeDictionary["outbox_message_id"] = value.recipient["outbox_message_id"]
                tempOldLikeDictionary["outbox_updated"] = value.recipient["outbox_updated"]
                tempOldLikeDictionary["outbox_deleted"] = value.recipient["outbox_deleted"]
                tempOldLikeDictionary["inbox_view"] = value.recipient["inbox_view"]
                let newDictionary:NSMutableDictionary = [:]
                if let _ = value.message{
                    newDictionary["message"] = value.message
                }
                if let _ = value.sender{
                    newDictionary["sender"] = value.sender
                }
                newDictionary["recipient"] = tempOldLikeDictionary
                var newData = Message.loadMessagesfromDictionary(newDictionary)
                self.blogResponse[index] = newData[0] as Message
            }
            
            var parameters = [String:String]()
            
            parameters = ["message_id": "\(msgId)", "is_read" : "1"]
            
            post(parameters, url: "messages/mark-message-read-unread", method: "POST"){(succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                })
            }
            
            
            
            
        }
        
        
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if updateScrollFlag{
//            // Check for Page Number for Browse Blog
//            if blogTableView.contentOffset.y >= blogTableView.contentSize.height - blogTableView.bounds.size.height{
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
//                if blogTableView.contentOffset.y >= blogTableView.contentSize.height - blogTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            blogTableView.tableFooterView?.isHidden = false
                          //  if searchDic.count == 0{
                                browseEntries()
                          //  }
                        }
                    }
                    else
                    {
                        blogTableView.tableFooterView?.isHidden = true
                }
                    
             //   }
                
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        let blogInfo = blogResponse[(indexPath as NSIndexPath).row]
        let message = blogInfo.message as NSDictionary
        
        let conversation_id = message["conversation_id"] as! Int
        if editingStyle == UITableViewCell.EditingStyle.delete {
            //            blogResponse.remove(at:indexPath.row)
            
            //            self.myTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            self.blogTableView.beginUpdates()
            blogResponse.remove(at: (indexPath as NSIndexPath).row) // Check this out
            self.blogTableView.deleteRows(at: [indexPath], with: .fade)
            self.blogTableView.endUpdates()
            
            
            //
            var parameters = [String:String]()
            
            // if subject_id == 0 && subject_type == ""{
            parameters = ["conversation_ids": String(conversation_id) ]
            
            post(parameters, url: "messages/delete", method: "POST"){(succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if succeeded["message"] != nil{
                            //                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                    }else{
                        
                        // Handle Server Side Error
                        //                            if succeeded["message"] != nil{
                        //                                self.showAlertMessage(self.view.center,msg: (succeeded["message"] as! String), timer:true)
                        //
                        //                            }
                    }
                })
                //self.browseEntries()
            }
            //            self.blogTableView.setEditing(false, animated: true)
        }
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func composeMessage(){
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            isCreateOrEdit = true
            let presentedVC = MessageCreateController()
            presentedVC.iscoming = "Messageview"
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.navigationController?.pushViewController(presentedVC, animated: true)
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
