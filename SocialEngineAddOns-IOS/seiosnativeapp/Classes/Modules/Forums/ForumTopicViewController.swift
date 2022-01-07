//
//  ForumTopicViewController.swift
//  seiosnativeapp
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
import NVActivityIndicatorView
import WebKit

var forumtopicViewUpdate:Bool!
var conditionForm : String! = ""
var Reload = ""
class ForumTopicViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,TTTAttributedLabelDelegate,WKNavigationDelegate,WKUIDelegate {
    
    var topicId:Int!
    var gutterMenu: NSArray = []
    var topicName:String!
    var showSpinner = true                      // not show spinner at pull to refresh
    var topicResponse = [AnyObject]()            // For response come from Server
    var topicMenu = [AnyObject]()
    var isPageRefresing = false                 // For Pagination
    var forumTopicTableView:UITableView!              // TAbleView to show the forum Contents
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var updateScrollFlag = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 160              // Dynamic Height fort for Cell
    var dynamicRowHeight = [Int:CGFloat]()      // Save table Dynamic RowHeight
    var deleteTopic = false
    var popAfterDelay = false
    var slug : String = ""
    var topic : NSDictionary!
    var menuTopic : NSDictionary!
    var forumRes: NSArray = []
    var formTitleString : String = ""
    var myDictionary : NSDictionary!
   // var imageCache = [String:UIImage]()
    var arrtag = [Int]()
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        forumtopicViewUpdate = true
        self.title = String(format: NSLocalizedString(" %@ ", comment: ""), topicName)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ForumTopicViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        // Initialize Forum Table
        if tabBarHeight > 0
        {
            forumTopicTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING , width: view.bounds.width, height: view.bounds.height - (TOPPADING + tabBarHeight)), style: .grouped)
        }
        else
        {
            forumTopicTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING , width: view.bounds.width, height: view.bounds.height - TOPPADING ), style: .grouped)
        }
        
        // forumTopicTableView.registerClass(ForumTopicTableViewCell.self, forCellReuseIdentifier: "Cell")
        forumTopicTableView.dataSource = self
        forumTopicTableView.delegate = self
        forumTopicTableView.estimatedRowHeight = 160.0
        forumTopicTableView.rowHeight = UITableView.automaticDimension
        forumTopicTableView.backgroundColor = tableViewBgColor
        forumTopicTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            forumTopicTableView.estimatedSectionHeaderHeight = 0
        }
        view.addSubview(forumTopicTableView)
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(ForumTopicViewController.refresh), for: UIControl.Event.valueChanged)
        forumTopicTableView.addSubview(refresher)
        self.automaticallyAdjustsScrollViewInsets = false;
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        forumTopicTableView.tableFooterView = footerView
        forumTopicTableView.tableFooterView?.isHidden = true
  
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        forumTopicTableView.tableFooterView?.isHidden = true
    }
    
    // Check for Forum Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        if (forumtopicViewUpdate == true) {
            forumtopicViewUpdate = false
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            browseEntries()
        }
    }
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            browseEntries()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            self.showAlertMessage(view.center , msg: network_status_msg , timer: false)
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
        if popAfterDelay == true{
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func showTopicMenu(_ sender:UIButton){
        let topic = topicResponse[sender.tag] as! NSDictionary
        // Set Sequence for menu
        if let feed_menu = topic["menu"] as? NSArray{
            
            // Generate Feed Filter Gutter Menu for Feed Come From Server as! Alert Popover
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menuItem in feed_menu{
                if let dic = menuItem as? NSDictionary {
                    let titleString = dic["name"] as! String
                    if titleString.range(of: "delete") != nil{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive , handler:{ (UIAlertAction) -> Void in
                            let condition = dic["name"] as! String
                            switch(condition){
                            case "delete":
                                displayAlertWithOtherButton(NSLocalizedString("Delete", comment: ""),message: NSLocalizedString("Are you sure that you want to delete this Post? This action cannot be undone.",comment: "") , otherButton: NSLocalizedString("Delete Post", comment: "")) { () -> () in
                                    
                                    self.updateForumTopicMenuAction(dic["urlParams"] as! NSDictionary, url: dic["url"] as! String)
                                }
                                self.present(alert, animated: true, completion: nil)
                            default:
                                self.showAlertMessage(self.view.center, msg: unconditionalMessage, timer: false)
                            }
                        }))
                    }
                        
                    else{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            let condition = dic["name"] as! String
                            switch(condition){
                            case "edit", "quote":
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                if condition  == "edit"{
                                    conditionForm = "forumEditing"
                                    // Reload = "Not Refresh"
                                    isCreateOrEdit = false
                                    let defaults = UserDefaults.standard
                                    defaults.set("Coding Explorer", forKey: "forumcheckkey")
                                    UserDefaults.standard.removeObject(forKey: "preferenceName")
                                    presentedVC.formTitle = NSLocalizedString("Edit Post", comment: "")
                                }else{
                                    conditionForm = "forumQuoting"
                                    // Reload = "Not Refresh"
                                    isCreateOrEdit = false
                                    let defaults = UserDefaults.standard
                                    defaults.set("Coding Explorer", forKey: "forumcheckkey")
                                    UserDefaults.standard.removeObject(forKey: "preferenceName")
                                    presentedVC.formTitle = NSLocalizedString("Quoting", comment: "")
                                }
                                presentedVC.contentType = "forum"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                nativationController.modalPresentationStyle = .fullScreen
                                self.present(nativationController, animated:false, completion: nil)

                            case "report":
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                            default:
                                fatalError("init(coder:) has not been implemented")
                            }
                            
                        }))
                        
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
                popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2, width: 0, height: 0)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
        
    }
    
    @objc func showGutterMenu(){
        let alertController1 = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary
            {
                
                alertController1.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                    let condition = dic["name"] as! String
                    switch(condition){
                    case "post_reply", "rename", "move" :
                        var type = "forum1"
                        isCreateOrEdit = false
                        if condition == "post_reply"{
                            type = "forum"
                            isCreateOrEdit = true
                            conditionForm = "postReply"
                            let defaults = UserDefaults.standard
                            defaults.set("Coding Explorer", forKey: "forumcheckkey")
                            UserDefaults.standard.removeObject(forKey: "preferenceName")
                        }
                        if condition == "move"{
                            type = "forum1"
                            conditionForm = "formMove"
                        }
                        if condition == "rename"{
                            type = "forum1"
                            conditionForm = "formRename"
                        }
                        let presentedVC = FormGenerationViewController()
                        if condition == "post_reply"{
                            
                            self.formTitleString = NSLocalizedString("Post Reply", comment: "")
                            
                        }else if condition == "rename"{
                            
                            self.formTitleString = NSLocalizedString("Rename Topic", comment: "")
                        }else if condition == "move"{
                            
                            self.formTitleString = NSLocalizedString("Move Topic", comment: "")
                        }
                        
                        presentedVC.formTitle = self.formTitleString
                        presentedVC.contentType = type
                        presentedVC.url = dic["url"] as! String
                        presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let nativationController = UINavigationController(rootViewController: presentedVC)
                        self.present(nativationController, animated:false, completion: nil)

                        
                    case "watch_topic","stop_watch_topic" , "make_sticky", "close" ,"remove_sticky","open":
                        Reload = "Not Refresh"
                        self.updateForumTopicMenuAction(dic["urlParams"] as! NSDictionary, url: dic["url"] as! String)
                        
                    case "delete":
                        displayAlertWithOtherButton(NSLocalizedString("Delete Topic", comment: ""),message: NSLocalizedString("Are you sure you want to delete this topic?",comment: "") , otherButton: NSLocalizedString("Delete Topic", comment: "")) { () -> () in
                            self.deleteTopic = true
                            self.updateForumTopicMenuAction(dic["urlParams"] as! NSDictionary, url: dic["url"] as! String)
                            
                        }
                        self.present(alert, animated: true, completion: nil)
                        
                        
                    default:
                        fatalError("init(coder:) has not been implemented")
                    }
                    
                    
                }))
            }
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController1.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController1.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController1.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height-50, y: view.bounds.width, width: 0, height: 0)
            popover?.permittedArrowDirections = UIPopoverArrowDirection.up
        }
        self.present(alertController1, animated:true, completion: nil)
        
    }
    
    // MARK: - Server Connection For Forum Updation
    func updateForumTopicMenuAction(_ parameter: NSDictionary, url : String){
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
            var method:String
            
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            // Send Server Request
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center,msg: succeeded["message"] as! String, timer:true )
                        }
                        if self.deleteTopic == true{
                            forumViewUpdate = true
                            self.popAfterDelay = true
                            return
                        }
                        self.browseEntries()
                    }
                        
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center,msg: succeeded["message"] as! String, timer:false )
                        }
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg, timer:false )
        }
        
    }
    
    // Update Forum
    func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            if (self.pageNumber == 1){
                self.topicResponse.removeAll(keepingCapacity: false)
                if Reload != "Not Refresh"{
                    self.forumTopicTableView.reloadData()
                }
            }
            if (showSpinner){
             //   spinner.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = view.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
           //     activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            // Send Server Request to Browse Forum Entries
            
            var dic = [String : String]()
            dic["topic_id"] = "\(topicId!)"
            dic["gutter_menu"] = "1"
            dic["page"] = "\(pageNumber)"
            dic["limit"] = "\(limit)"
            
            let url1 : String = "forums/topic/" + String(topicId) + "/" + String(slug) + "/view"
            
            post(dic, url: url1, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
//                    if self.showSpinner{
//                        activityIndicatorView.stopAnimating()
//                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.topicResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center , msg: succeeded["message"] as! String, timer: true)
                        }
                        if let response = succeeded["body"] as? NSDictionary{
                            self.myDictionary = response
                            if let menu = response["gutterMenu"] as? NSArray{
                                self.gutterMenu = menu
                                let menu = UIBarButtonItem(title:optionIcon, style: UIBarButtonItem.Style.plain , target:self , action: #selector(ForumTopicViewController.showGutterMenu))
                                menu.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!], for: UIControl.State())
                                menu.tintColor = textColorPrime
                                self.navigationItem.rightBarButtonItem = menu
                            }
                            if response["response"] != nil{
                                if let topics = response["response"] as? NSArray {
                                    self.topicResponse = self.topicResponse + (topics as [AnyObject])
                                }
                            }
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                            
                            self.isPageRefresing = false
                            //Reload  Tabel
                            if Reload != "Not Refresh"{
                                Reload = ""
                                self.arrtag.removeAll()
                                self.forumTopicTableView.reloadData()
                            }
                        }
                    }else{
                        
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center , msg: succeeded["message"] as! String, timer: false)
                            forumViewUpdate = true
                            _ = self.navigationController?.popViewController(animated: true)
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
    // Set Forum Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Forum Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001//30.0
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if dynamicRowHeight[(indexPath as NSIndexPath).row] != nil{
            return dynamicRowHeight[(indexPath as NSIndexPath).row]!
        }
        else
        {
            return 80
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        if dynamicRowHeight[(indexPath as NSIndexPath).row] != nil{
            return dynamicRowHeight[(indexPath as NSIndexPath).row]!
        }
        //        var rowHeight:CGFloat = 100
        //        if let _ = topicResponse[indexPath.row] as? NSDictionary{
        //            if topicResponse.count > indexPath.row {
        //                if dynamicRowHeight[indexPath.row] != nil{
        //                    rowHeight = dynamicRowHeight[indexPath.row]!
        //                }
        //            }
        //        }
        //        return rowHeight
        
        return 80
    }
    
    // Set  Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set no. of rows in Every section of TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return topicResponse.count
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cellIdentifier = String((indexPath as NSIndexPath).section) + "-" + String((indexPath as NSIndexPath).row)
        forumTopicTableView.register(ForumTopicTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ForumTopicTableViewCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.editDetail.isHidden = true
        

        var tempInfo1 = ""
        var editBy = ""
        if let topic = topicResponse[(indexPath as NSIndexPath).row] as? NSDictionary{
            
            if let modifiedDate = topic["modified_date"] as? String{
                
                let date = dateDifferenceWithEventTime(modifiedDate)
                var DateC = date.components(separatedBy: ", ")
                tempInfo1 += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo1 += " at \(DateC[3])"
                }
            }
            
            if let posted_by = topic["editBy"] as? NSDictionary{
                editBy = (posted_by["displayname"] as? String)!
                if editBy != "" {
                    cell.detail.frame.origin.y = cell.ownerIcon.bounds.height + cell.ownerIcon.frame.origin.y + 40
                    cell.editDetail.text = "This Post was edited by \(editBy) on \(tempInfo1)."
                }
            }
            
        }
        if let menu2 = myDictionary["response"] as? NSArray
        {
            self.topicMenu = self.topicMenu + (menu2 as [AnyObject])
            menuTopic = topicMenu[(indexPath as NSIndexPath).row] as? NSDictionary
            if let menu1 = menuTopic["menu"] as? NSArray{
                if ( menu1.count > 0){
                    cell.menu.isHidden = false
                    cell.menu.tag = (indexPath as NSIndexPath).row
                    cell.menu.addTarget(self, action: #selector(ForumTopicViewController.showTopicMenu(_:)), for: .touchUpInside)
                    
                }
            }
        }
        
        // set the cell's text with the new string formatting
        if let topic = topicResponse[(indexPath as NSIndexPath).row] as? NSDictionary{
            var tempOwnerInfo = ""
            let postedBy = ""
            if let posted_by = topic["posted_by"] as? NSDictionary{
                
                // Set  Owner Image
                if let url = URL(string: posted_by["image_icon"] as! String)
                {
                    cell.ownerIcon.kf.indicatorType = .activity
                    (cell.ownerIcon.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.ownerIcon.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
                
                // Set user info
                if let postedBy = posted_by["displayname"] as? String {
                    tempOwnerInfo = "\(postedBy)"
                }else{
                    tempOwnerInfo = ""
                }
                
                if let totalPost = posted_by["post_count"] as? Int{
                    tempOwnerInfo += "\n"
                    tempOwnerInfo += singlePluralCheck(NSLocalizedString(" Post", comment: ""), plural: NSLocalizedString(" Posts", comment: ""), count: totalPost)
                }
                
                if let modifiedDate = topic["modified_date"] as? String{
                    let postedOn = dateDifference(modifiedDate)
                    tempOwnerInfo += " - \(postedOn)"
                    //tempOwnerInfo += "This Post was edited by \(editBy) on \(tempInfo1)"
                }
                
            }
            
            cell.ownerInfo.setText(tempOwnerInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in

                let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, 13, nil)
                
                let range = (tempOwnerInfo as NSString).range(of: postedBy)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value: textColorDark, range: range)
                
                // TODO: Clean this up..
                return mutableAttributedString
            })
            
            let range = (tempOwnerInfo as NSString).range(of: NSLocalizedString(postedBy,  comment: ""))
            cell.ownerInfo.addLink(toTransitInformation: [ "id" : (topic["user_id"] as? Int)!,"type" : "user"], with:range)
            cell.ownerInfo.delegate = self
            cell.ownerInfo.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            
            if let topicDescription = topic["body"] as? String
            {
                cell.detail.navigationDelegate = self
                cell.detail.uiDelegate = self
                cell.detail.tag = (indexPath as NSIndexPath).row
                cell.detail.sizeToFit()
                cell.detail.contentMode = .scaleAspectFit
                
                
                let htmlStart = "<HTML><HEAD><meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0, shrink-to-fit=no\"></HEAD><BODY>"
                let htmlEnd = "</BODY></HTML>"
                let htmlString = "\(htmlStart)\(topicDescription)\(htmlEnd)"
               
                
                if let _ = arrtag.index(of: (indexPath as NSIndexPath).row)
                {
                    //print("loaded...")
                }
                else
                {
                    cell.detail.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
                }
                
            }
            
        }
        cell.cellView.frame.size.height = cell.detail.bounds.height + cell.detail.frame.origin.y + 10
        //print("height====%@",cell.cellView.frame.size.height)
        return cell
        
    }
    
   
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        print("UIDelegetae callng====")
        if let frame = navigationAction.targetFrame,
            frame.isMainFrame {
            return nil
        }
        // for _blank target or non-mainFrame target
        webView.load(navigationAction.request)
        return nil
    }
    
    //MARK: -  WKWebView DidStart Delegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation - webView.url: \(String(describing: webView.url?.description))")
        self.view.addSubview(activityIndicatorView)
        activityIndicatorView.center = self.view.center
        activityIndicatorView.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish - webView.url: \(String(describing: webView.url?.description))")
        

        
        activityIndicatorView.stopAnimating()
        
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (height, error) in
            
            webView.frame.size.height = height as! CGFloat
            webView.isUserInteractionEnabled = true
            self.arrtag.append(webView.tag)
            self.dynamicRowHeight[webView.tag] = webView.frame.size.height + webView.frame.origin.y + 10
            self.forumTopicTableView.reloadData()
            
           
        })
       
    }
    
   func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(String(describing: decisionHandler))")
        switch navigationAction.navigationType {
        case .linkActivated:
            if let url = navigationAction.request.url{
                
                let presentedVC = ExternalWebViewController()
                presentedVC.url = url.absoluteString
                let navigationController = UINavigationController(rootViewController: presentedVC)
                self.present(navigationController, animated: true, completion: nil)
                decisionHandler(.cancel)
                return
            }
            
        default:
            break
        }
        
        
        decisionHandler(.allow)
    }
    

    
    func someSelector()
    {
        var runLoop:CFRunLoop? = nil
        runLoop = RunLoop.current.getCFRunLoop()
        CFRunLoopStop(runLoop)
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if updateScrollFlag
        {
            // Check for Page Number for Browse Forum
            
            if arrtag.contains(limit*pageNumber-1)
            {
                if forumTopicTableView.contentOffset.y >= forumTopicTableView.contentSize.height - forumTopicTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            browseEntries()
                        }
                    }
                    
                }
                
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
                if arrtag.contains(limit*pageNumber-1)
                {
                if (!isPageRefresing  && limit*pageNumber < totalItems){
                    if Reachabable.isConnectedToNetwork() {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        forumTopicTableView.tableFooterView?.isHidden = false
                        // if searchDic.count == 0{
                        browseEntries()
                        // }
                    }
                }
                }
                else
                {
                    forumTopicTableView.tableFooterView?.isHidden = true
                }
            }
            
        }
        
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        let type = components["type"] as! String
        switch(type){
        case "user":
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(components["id"]!)"
            self.navigationController?.pushViewController(presentedVC, animated: true)
            
        default:
            print("User Not Match")
            
        }
    }
    
    @objc func goBack()
    {    //forumViewUpdate = true
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(forumRenameTitle != nil  && forumRenameTitle != ""){
            //self.title = NSLocalizedString("\(forumRenameTitle)",  comment: "")
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), forumRenameTitle)
            forumRenameTitle = nil
            self.browseEntries()
        }
        else{
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), topicName)
            // self.title = NSLocalizedString("\(topicName)",  comment: "")
        }
        // self.browseEntries()
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

