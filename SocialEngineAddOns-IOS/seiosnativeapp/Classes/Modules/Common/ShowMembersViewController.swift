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
//  ShowMembersViewController.swift
//  seiosnativeapp
import UIKit
import NVActivityIndicatorView

class ShowMembersViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate ,UISearchBarDelegate, TTTAttributedLabelDelegate , UITabBarControllerDelegate{
    
    // Variables for Likes
    var allMembers = [AnyObject]()
    var gpMemberstableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var isPageRefresing = false
    var mytitle:String!
    //  var groupID:Int!
    var searchBar:UISearchBar!
    var info:UILabel!
    var checkWaiting:UIButton!
    var waitingMembers = false
    var updatedStaff:UITextField!
    var url: String!
    var param: NSDictionary! = [:]
    var contentType : String!
    var object = ""
    var dynamicHeight:CGFloat = 70
    var editPermission = false
    var totalItem:Int!
    var memberInfo:NSDictionary!
    var showMenuOrNot:Bool! = false
    var optionMenu:UIButton!
    var condition1 : String!
    var condition2 : String!
    var id : String!
    var nextButton : UIButton!
    var canInvite = false
    var guid : String!
    var msgUrl : String!
    var ownerId : Int = 0
    var leftBarButtonItem : UIBarButtonItem!
    var marqueeHeader = MarqueeLabel()
    var resourceId : Int = 0
    var showSpinner = true
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ShowMembersViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        self.tabBarController?.delegate = self
        // Set Title for navigation Bar
        if !(contentType == "event" || contentType == "group" || contentType == "advancedevents" || contentType == "sitegroup"){
            self.title = NSLocalizedString("Members", comment: "")
        }
        if (self.contentType == "userFollow"){
            self.title = NSLocalizedString("Followers", comment: "")
        }
        
        
        view.backgroundColor = bgColor
        searchDic.removeAll(keepingCapacity: false)
        searchBar = UISearchBar()
        searchBar.layer.borderWidth = 3
        searchBar.isHidden = true
        
        searchBar.layer.borderColor = UIColor.white.cgColor
        searchBar.backgroundColor = UIColor.clear
        searchBar.frame = CGRect(x: 0, y: TOPPADING-3, width: view.bounds.width, height: 0)
        //searchBar.frame = CGRect(x:0, TOPPADING-6, view.bounds.width, ButtonHeight - PADING)
        searchBar.delegate = self
        condition1 = ""
        condition2 = ""
        
        if (self.contentType == "group"){
            searchBar.placeholder = NSLocalizedString("Search Members", comment: "")
        }
        else{
            searchBar.placeholder = NSLocalizedString("Search Guests", comment: "")
        }
        
        view.addSubview(searchBar)
        
        switch(contentType){
        case "group":
            object = "member"
        case "event":
            object = "guest"
        default:
            print("group")
        }
        
        for subView in searchBar.subviews  {
            for subsubView in subView.subviews  {
                if let textField = subsubView as? UITextField {
                    textField.textColor = textColorDark
                    textField.font = UIFont(name: fontName, size: FONTSIZENormal)
                }
            }
        }
        
        info = createLabel(CGRect(x: PADING,  y: searchBar.frame.origin.y ,width: self.view.bounds.width - 2*PADING , height: ButtonHeight), text: "", alignment: .left, textColor: textColorDark)
        info.numberOfLines = 0
        info.font = UIFont(name: fontName, size: FONTSIZENormal)
        view.addSubview(info)
        
        
        gpMemberstableView = UITableView(frame: CGRect(x: 0, y: info.bounds.height + info.frame.origin.y , width: view.bounds.width, height: view.bounds.height-(info.bounds.height + info.frame.origin.y + tabBarHeight)), style: UITableView.Style.grouped)
        gpMemberstableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "Cell")
        gpMemberstableView.rowHeight = 65.0
        gpMemberstableView.dataSource = self
        gpMemberstableView.delegate = self
        gpMemberstableView.backgroundColor = tableViewBgColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            gpMemberstableView.estimatedRowHeight = 0
            gpMemberstableView.estimatedSectionHeaderHeight = 0
            gpMemberstableView.estimatedSectionFooterHeight = 0
        }
        gpMemberstableView.bounces = false
        view.addSubview(gpMemberstableView)
        
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        gpMemberstableView.tableFooterView = footerView
        gpMemberstableView.tableFooterView?.isHidden = true
        
        tblAutoSearchSuggestions = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 420), style: UITableView.Style.plain)
        tblAutoSearchSuggestions.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        tblAutoSearchSuggestions.dataSource = self
        tblAutoSearchSuggestions.delegate = self
        tblAutoSearchSuggestions.rowHeight = 50
        tblAutoSearchSuggestions.backgroundColor = tableViewBgColor
        tblAutoSearchSuggestions.separatorColor = TVSeparatorColor
        tblAutoSearchSuggestions.tag = 122
        tblAutoSearchSuggestions.isHidden = true
        view.addSubview(tblAutoSearchSuggestions)
        tblAutoSearchSuggestions.keyboardDismissMode = .onDrag
        
        if let arr = UserDefaults.standard.array(forKey: "arrRecentSearchOptions") as? [String]{
            arrRecentSearchOptions = arr
        }
        if arrRecentSearchOptions.count != 0
        {
            tblAutoSearchSuggestions.reloadData()
            tblAutoSearchSuggestions.isHidden = true
        }
        else
        {
            tblAutoSearchSuggestions.isHidden = true
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if self.contentType == "sitegroup"{
            if let navigationBar = self.navigationController?.navigationBar {
                let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
                marqueeHeader = MarqueeLabel(frame: firstFrame)
                marqueeHeader.tag = 101
                marqueeHeader.setDefault()
                navigationBar.addSubview(marqueeHeader)
            }
            
            self.marqueeHeader.text =  mytitle
        }
        
        tblAutoSearchSuggestions.isHidden = true
        if url != nil {
            showMembers(url, parameter: param)
        }
        
        for ob in self.view.subviews{
            if (ob.tag == 11) || (ob.tag == 22) || (ob.tag == 33){
                ob.removeFromSuperview()
            }
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
    
    func showMembers(_ url:String, parameter: NSDictionary){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            // Set Spinner
            //            spinner.center = self.view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            self.view.addSubview(spinner)
            if showSpinner
            {
                self.view.addSubview(activityIndicatorView)
                // activityIndicatorView.center = self.view.center
                activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                activityIndicatorView.startAnimating()
            }
            
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            dic["limit"] = "\(limit)"
            dic["page"] = "\(pageNumber)"
            dic["menu"] = "1"
            
            if waitingMembers {
                self.checkWaiting.setTitle("", for: UIControl.State())
                dic["waiting"] = "1"
            }
            
            if condition2 == "Approved"{
                self.checkWaiting.setTitle("", for: UIControl.State())
            }
            
            if pageNumber == 1{
                allMembers.removeAll(keepingCapacity: false)
                gpMemberstableView.reloadData()
            }
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                dic.merge(searchDic)
                //  searchBar.endEditing(true)
                tblAutoSearchSuggestions.isHidden = true
            }
            if (self.contentType == "userFollow"){
                dic["resource_type"] = "user"
                dic["resource_id"] = "\(resourceId)"
            }
            
            // Send Server Request to Share Content
            post(dic, url: url, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    self.showSpinner = false
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            
                            
                            if let body = succeeded["body"] as? NSDictionary{
                                if let canEdit = body["canEdit"] as? Bool{
                                    self.editPermission = canEdit
                                }
                                if let msg = body["messageGuest"] as? NSDictionary{
                                    
                                    self.msgUrl = msg["url"] as! String
                                }
                                
                                if let members = body["members"] as? NSArray{
                                    self.allMembers = self.allMembers + (members as [AnyObject])
                                }
                                if let members = body["response"] as? NSArray{
                                    self.allMembers = self.allMembers + (members as [AnyObject])
                                }
                                
                                
                                if self.ownerId == 1
                                {
                                    
                                    if self.canInvite == true
                                    {
                                        if let _ = body["messageGuest"] as? NSDictionary
                                        {
                                            
                                            let msgItem = UIBarButtonItem(title: "\(messageIcon)", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ShowMembersViewController.msgGuest))
                                            msgItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
                                            
                                            let addMember = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ShowMembersViewController.addNewMember))
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(ShowMembersViewController.searchItem))
                                            
                                            self.navigationItem.setRightBarButtonItems([addMember,msgItem,searchItem], animated: true)
                                            searchItem.tintColor = textColorPrime
                                            addMember.tintColor = textColorPrime
                                            msgItem.tintColor = textColorPrime
                                        }
                                        else
                                        {
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(ShowMembersViewController.searchItem))
                                            let addMember = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ShowMembersViewController.addNewMember))
                                            
                                            self.navigationItem.setRightBarButtonItems([addMember,searchItem], animated: true)
                                            searchItem.tintColor = textColorPrime
                                            addMember.tintColor = textColorPrime
                                            
                                            
                                            
                                        }
                                        
                                        
                                    }
                                    else
                                    {
                                        
                                        if let _ = body["messageGuest"] as? NSDictionary
                                        {
                                            let msgItem = UIBarButtonItem(title: "\(messageIcon)", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ShowMembersViewController.msgGuest))
                                            msgItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(ShowMembersViewController.searchItem))
                                            
                                            
                                            self.navigationItem.setRightBarButtonItems([msgItem,searchItem], animated: true)
                                            searchItem.tintColor = textColorPrime
                                            
                                        }
                                    }
                                    
                                    
                                    
                                }
                                else
                                {
                                    if self.canInvite == true
                                    {
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(ShowMembersViewController.searchItem))
                                        let addMember = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ShowMembersViewController.addNewMember))
                                        
                                        self.navigationItem.setRightBarButtonItems([addMember,searchItem], animated: true)
                                        searchItem.tintColor = textColorPrime
                                        addMember.tintColor = textColorPrime
                                        
                                    }
                                    else{
                                        if let _ = body["messageGuest"] as? NSDictionary
                                        {
                                            let msgItem = UIBarButtonItem(title: "\(messageIcon)", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ShowMembersViewController.msgGuest))
                                            msgItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(ShowMembersViewController.searchItem))
                                            
                                            
                                            self.navigationItem.setRightBarButtonItems([msgItem,searchItem], animated: true)
                                            searchItem.tintColor = textColorPrime
                                            
                                        }
                                        else{
                                            
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(ShowMembersViewController.searchItem))
                                            
                                            self.navigationItem.setRightBarButtonItems([searchItem], animated: true)
                                            searchItem.tintColor = textColorPrime
                                        }
                                        
                                    }
                                    
                                }
                                //self.totalItem = body["getTotalItemCount"] as! Int
                                self.info.frame.size.width = self.view.bounds.width - 2*PADING
                                if self.waitingMembers{
                                    self.searchBar.isHidden = true
                                    self.info.frame.origin.y = TOPPADING
                                }else{
                                    self.searchBar.isHidden = false
                                    self.info.frame.origin.y = self.searchBar.bounds.height + self.searchBar.frame.origin.y
                                    var memberCount = 0
                                    if let _ = body["getTotalItemCount"] as? Int {
                                        memberCount = body["getTotalItemCount"] as! Int
                                    }
                                    if let _ = body["totalItemCount"] as? Int {
                                        memberCount = body["totalItemCount"] as! Int
                                    }
                                    self.totalItems = memberCount
                                    if (self.contentType == "userFollow"){
                                        //self.title = NSLocalizedString("Guests", comment: "")
                                        if self.condition1 == ""{
                                            if memberCount == 1 {
                                                let main_string = String(format: NSLocalizedString("Follower (\(memberCount))", comment: ""),memberCount)
                                                self.title = String(format: NSLocalizedString(" %@ ", comment: ""), main_string)
                                            }
                                            else{
                                                let main_string = String(format: NSLocalizedString("Followers (\(memberCount))", comment: ""),memberCount)
                                                self.title = String(format: NSLocalizedString(" %@ ", comment: ""), main_string)
                                            }
                                            
                                            //self.title = NSLocalizedString("Members (\(memberCount)): \(self.mytitle)", comment: "")
                                        }
                                    }
                                    
                                    if (self.contentType == "group"){
                                        //self.title = NSLocalizedString("Guests", comment: "")
                                        if self.condition1 == ""{
                                            let main_string = String(format: NSLocalizedString("Members (\(memberCount))", comment: ""),memberCount)
                                            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), main_string)
                                            //self.title = NSLocalizedString("Members (\(memberCount)): \(self.mytitle)", comment: "")
                                        }
                                    }
                                    if (self.contentType == "event") || (self.contentType == "advancedevents"){
                                        if self.condition1 == ""{
                                            let main_string = String(format: NSLocalizedString("Guests (\(memberCount))", comment: ""),memberCount)
                                            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), main_string)
                                            //self.title = NSLocalizedString("Guests (\(memberCount)): \(self.mytitle)", comment: "")
                                        }
                                    }
                                    if memberCount == 1{
                                        
                                        self.info.isHidden = false
                                        
                                    }else if memberCount > 1 {
                                        self.info.isHidden = false
                                        
                                    }else if memberCount < 1 {
                                        self.info.isHidden = true
                                        showToast(message: "No members found.", controller: self)
                                        self.searchBar.resignFirstResponder()
                                    }
                                }
                                
                                self.info.lineBreakMode = NSLineBreakMode.byCharWrapping
                                self.info.sizeToFit()
                                
                                for ob in self.view.subviews{
                                    if (ob.tag == 11) || (ob.tag == 22) || (ob.tag == 33){
                                        ob.removeFromSuperview()
                                    }
                                }
                                
                                if let waiting = body["getWaitingItemCount"] as? Int
                                {
                                    
                                    if waiting > 0{
                                        if !self.waitingMembers {
                                            let waitingCount = singlePluralCheck( NSLocalizedString(" member waiting", comment: ""),  plural: NSLocalizedString(" members waiting", comment: ""), count: waiting) as String
                                            self.checkWaiting = createButton(CGRect(x: PADING, y: self.searchBar.bounds.height + self.searchBar.frame.origin.y, width: 160, height: 30), title: "\(waitingCount)", border: false, bgColor: false, textColor: linkColor)
                                            self.checkWaiting.tag = 22
                                            self.nextButton = createButton(CGRect(x: self.view.bounds.width-30, y: self.searchBar.bounds.height + self.searchBar.frame.origin.y, width: 30, height: 30), title: ">", border: false, bgColor: false, textColor: linkColor)
                                            self.nextButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                                            
                                            self.nextButton.addTarget(self, action:#selector(ShowMembersViewController.showMember(_:)) , for: .touchUpInside)
                                            self.view.addSubview(self.nextButton)
                                            self.nextButton.tag = 33
                                            
                                            self.checkWaiting.titleLabel?.textAlignment = NSTextAlignment.left
                                            self.checkWaiting.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                                            self.checkWaiting.addTarget(self, action:#selector(ShowMembersViewController.showMember(_:)) , for: .touchUpInside)
                                            
                                            self.view.addSubview(self.checkWaiting)
                                            self.info.frame.origin.y = self.checkWaiting.bounds.height + self.checkWaiting.frame.origin.y
                                            self.gpMemberstableView.frame.origin.y = self.info.bounds.height + self.info.frame.origin.y + PADING
                                        }else{
                                            self.condition2 = "Approved"
                                            self.checkWaiting = createButton(CGRect(x: PADING, y: self.info.bounds.height + self.info.frame.origin.y, width: findWidthByText(NSLocalizedString("<  View all approved members", comment: ""))+20, height: 30), title: NSLocalizedString("<  View all approved members", comment: ""),border: false ,bgColor: false, textColor: linkColor)
                                            self.checkWaiting.tag = 11
                                            self.gpMemberstableView.frame.origin.y = self.checkWaiting.bounds.height + self.checkWaiting.frame.origin.y
                                        }
                                        
                                        
                                    }
                                    else
                                    {
                                        self.gpMemberstableView.frame.origin.y = self.info.bounds.height + self.info.frame.origin.y - PADING
                                    }
                                    
                                    
                                    
                                    self.gpMemberstableView.frame.size.height = self.view.bounds.height - self.gpMemberstableView.frame.origin.y - tabBarHeight
                                }
                                else
                                {
                                    for ob in self.view.subviews{
                                        if (ob.tag == 11) || (ob.tag == 22) || (ob.tag == 33)
                                        {
                                            ob.removeFromSuperview()
                                        }
                                    }
                                    self.gpMemberstableView.frame.origin.y = self.info.bounds.height + self.info.frame.origin.y - PADING
                                    self.gpMemberstableView.frame.size.height = self.view.bounds.height - self.gpMemberstableView.frame.origin.y + PADING - tabBarHeight
                                    
                                }
                                
                                
                                // Reload Table on Getting Data from Server
                                self.isPageRefresing = false
                                self.gpMemberstableView.reloadData()
                            }
                        }
                        // })
                        
                        //  self.totalItems = succeeded["getTotalLikes"] as! Int
                        
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            self.searchBar.resignFirstResponder()
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            searchBar.resignFirstResponder()
        }
        
    }
    
    // Handle Simple Search on Search Click
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        condition1 = "title"
        // Add search text to searchDic
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
        pageNumber = 1
        showSpinner = true
        waitingMembers = false
        searchBar.resignFirstResponder()
        // Update Blog for Search Text
        if url != nil {
            showMembers(url, parameter: param)
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        if searchBar.text?.length != 0
        {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.reload(_:)), object: searchBar)
            perform(#selector(self.reload(_:)), with: searchBar, afterDelay: 0.5)
        }
        else
        {
            activityIndicatorView.stopAnimating()
            if arrRecentSearchOptions.count != 0
            {
                tblAutoSearchSuggestions.reloadData()
                tblAutoSearchSuggestions.isHidden = true
                self.gpMemberstableView.isHidden = true
            }
            else
            {
                tblAutoSearchSuggestions.isHidden = true
            }
        }
        
    }
    @objc func reload(_ searchBar: UISearchBar) {
        if searchBar.text?.length != 0
        {
            tblAutoSearchSuggestions.isHidden = true
            searchQueryInAutoSearch()
        }
        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    
    func updateAutoSearchArray(str : String) {
        if !arrRecentSearchOptions.contains(str)
        {
            arrRecentSearchOptions.insert(str, at: 0)
            if arrRecentSearchOptions.count > 6 {
                arrRecentSearchOptions.remove(at: 6)
            }
            tblAutoSearchSuggestions.reloadData()
            UserDefaults.standard.set(arrRecentSearchOptions, forKey: "arrRecentSearchOptions")
        }
    }
    func searchQueryInAutoSearch(){
        condition1 = "title"
        // Add search text to searchDic
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
        pageNumber = 1
        showSpinner = true
        waitingMembers = false
        //  searchBar.resignFirstResponder()
        // Update Blog for Search Text
        if url != nil {
            showMembers(url, parameter: param)
        }
    }
    @objc func showMember(_ sender:UIButton){
        let presentedVC = WaitingMemberViewController()
        presentedVC.contentType = "\(self.contentType)"
        
        presentedVC.url1 = url
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    
    func configurationTextField(_ textField: UITextField!){
        
        if let tField = textField {
            updatedStaff = tField
        }
    }
    
    @objc func updateStaff(_ sender:UIButton){
        let  alert1 = UIAlertController(title:NSLocalizedString("Edit Staff", comment: "") , message: NSLocalizedString("Update Staff", comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert1.addTextField(configurationHandler: configurationTextField)
        alert1.addAction(UIAlertAction(title: NSLocalizedString("Submit", comment: ""), style: .default, handler:{
            (UIAlertAction) -> Void in
            
            
            if (self.updatedStaff.text == ""){
                showToast(message: "Please update staff.", controller: self)
                
                self.updatedStaff.becomeFirstResponder()
                return
            }
            
            //TODO: Update Staff
            
            //  self.updateMembers(["group_id":"\(self.groupID)", "user_id": "\(sender.tag)", "title" : "\(self.updatedStaff.text)"], url: "groups/member/edit")
            
        }))
        alert1.addAction(UIAlertAction(title: "Cancel", style: .default, handler:nil ))
        present(alert1, animated: true, completion: nil)
    }
    
    func updateMembers(_ parameter: NSDictionary , url1 : String){
        
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
            
            if url1.range(of: "remove") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url1)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Blog Detail
                        // Update Blog Detail
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if self.url != "" {
                            self.showMembers(self.url, parameter: self.param)
                        }
                        
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
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    //set Height for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 122{
            return dynamicHeightAutoSearch
        }else{
            return dynamicHeight
        }
    }
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
        }else{
            return 0.001
        }
    }
    
    // Set Table Header Height
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        if tableView.tag == 122{
            let labTitle = createLabel(CGRect( x: 14, y: 0,width: view.bounds.width, height: 40), text: NSLocalizedString("RECENT SEARCHES", comment: ""), alignment: .left, textColor: textColorDark)
            labTitle.font = UIFont(name: fontBold, size: FONTSIZELarge)
            vw.addSubview(labTitle)
            return vw
        }
        else
        {
            return vw
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if tableView.tag == 122{
            return 40
        }
        else
        {
            return 0.00001
        }
    }
    
    // Set Table Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }
        else
        {
            return allMembers.count
        }
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if tableView.tag == 122{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = .none
            cell.backgroundColor = .white
            cell.contentView.backgroundColor = .white
            let blogInfo = arrRecentSearchOptions[(indexPath as NSIndexPath).row]
            cell.imgSearch.isHidden = false
            cell.labTitle.frame = CGRect(x: cell.imgSearch.bounds.width + 24, y: 0,width: UIScreen.main.bounds.width - (cell.imgSearch.bounds.width + 24), height: 45)
            // cell.labTitle.center.y = cell.bounds.midY + 5
            cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
            cell.labTitle.text = blogInfo
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labTitle.numberOfLines = 2
            
            cell.imgUser.isHidden = true
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            memberInfo = allMembers[(indexPath as NSIndexPath).row] as! NSDictionary
            cell.author_photo.frame = CGRect(x: 5,y: 5,width: 60,height: 60)
            
            // Set Name People who Likes Content
            if (self.contentType == "group") || (self.contentType == "sitegroup") || (self.contentType == "userFollow"){
                cell.author_title.frame = CGRect(x: cell.author_photo.bounds.width+10, y: 25, width: self.view.bounds.width-(cell.author_photo.bounds.width+15), height: 100)
            }
            else{
                cell.author_title.frame = CGRect(x: cell.author_photo.bounds.width+10, y: 9, width: self.view.bounds.width-(cell.author_photo.bounds.width+15), height: 100)
            }
            //cell.author_title.delegate = self
            cell.author_title.font = UIFont(name: fontBold, size: FONTSIZELarge)
            cell.author_title.text = memberInfo["displayname"] as? String
            //cell.author_title.sizeToFit()
            var userId : Int = 0
            
            if memberInfo["user_id"] != nil {
                userId = memberInfo["user_id"] as! Int
            }
            cell.author_title.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.author_title.sizeToFit()
            
            cell.imageButton.accessibilityIdentifier = "\((indexPath as NSIndexPath).row)"
            cell.imageButton.addTarget(self, action: #selector(ShowMembersViewController.showProfile(_:)), for: UIControl.Event.touchUpInside)
            cell.imageButton.tag = userId
            
            cell.staff.isHidden = true
            if contentType == "group"{
                if let staff = memberInfo["staff"] as? String{
                    
                    if staff != "" {
                        
                        cell.staff.setTitle("(\(staff))", for: UIControl.State())
                        if memberInfo["user_id"] != nil {
                            cell.staff.tag = memberInfo["user_id"] as! Int
                        }
                        
                        // cell.staff.tag = (memberInfo["user_id"] as? Int)!
                        
                        cell.staff.isHidden = false
                        
                        cell.staff.frame.origin.x = cell.author_title.frame.size.width + cell.author_title.frame.origin.x + 10
                        cell.staff.frame.origin.y = cell.author_title.frame.origin.y - 4
                        cell.staff.frame.size.width = (findWidthByText("(\(staff))")+22)
                        
                        if logoutUser == false && editPermission == true{
                            
                            cell.staff.addTarget(self, action: #selector(ShowMembersViewController.updateStaff(_:)), for: .touchUpInside)
                            
                            cell.staff.setImage(UIImage(named: "icon-edit.png"), for: UIControl.State())
                            
                            // the space between the image and text
                            let spacing:CGFloat = 2.0;
                            // lower the text and push it left so it appears centered
                            //  below the image
                            let imageSize = (cell.staff.imageView?.image?.size)!;
                            
                            cell.staff.titleEdgeInsets = UIEdgeInsets(
                                top: 0.0, left: -imageSize.width, bottom: 0.0, right: 0.0);
                            
                            // raise the image and push it right so it appears centered
                            //  above the text
                            //  var titleSize = [cell.staff.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
                            cell.staff.imageEdgeInsets = UIEdgeInsets(
                                top: 0.0, left: (cell.staff.frame.size.width + spacing - 22), bottom: 0.0, right: 0.0);
                        }else{
                            cell.staff.setTitleColor(textColorMedium, for: UIControl.State())
                        }
                        
                        
                        
                    }
                    
                    
                    
                }
            }
            
            
            cell.status.isHidden = true
            
            
            // In Case of Event Check for RSVP
            cell.comment_date.isHidden = true
            if contentType == "event"{
                
                
                
                if let rsvp = memberInfo["rsvp"] as? Int{
                    switch(rsvp){
                    case 0:
                        cell.comment_date.text = NSLocalizedString("Not Attending", comment: "")
                    case 1:
                        cell.comment_date.text = NSLocalizedString("May be Attending", comment: "")
                    case 2:
                        cell.comment_date.text = NSLocalizedString("Attending", comment: "")
                    case 3:
                        cell.comment_date.text = NSLocalizedString("Awaiting Reply", comment: "")
                    default:
                        print("error")
                    }
                    cell.comment_date.frame.origin.x = cell.author_title.frame.origin.x
                    cell.comment_date.frame.origin.y = cell.status.frame.origin.y + cell.status.bounds.height + 2
                    cell.comment_date.isHidden = false
                    cell.comment_date.textColor = textColorMedium
                }
            }
            
            if contentType == "advancedevents"{
                
                
                
                if let rsvp = memberInfo["rsvp"] as? Int{
                    switch(rsvp){
                    case 0:
                        cell.comment_date.text = NSLocalizedString("Not Attending", comment: "")
                    case 1:
                        cell.comment_date.text = NSLocalizedString("May be Attending", comment: "")
                    case 2:
                        cell.comment_date.text = NSLocalizedString("Attending", comment: "")
                    case 3:
                        cell.comment_date.text = NSLocalizedString("Awaiting Reply", comment: "")
                    default:
                        print("error")
                    }
                    cell.comment_date.frame.origin.x = cell.author_title.frame.origin.x
                    cell.comment_date.frame.size.width = 110
                    cell.comment_date.frame.origin.y = cell.status.frame.origin.y + cell.status.bounds.height + 2
                    cell.comment_date.isHidden = false
                    cell.comment_date.textColor = textColorMedium
                }
            }
            
            cell.option1.isHidden = true
            cell.option2.isHidden = true
            
            optionMenu = createButton(CGRect(x: view.bounds.width - 40, y: 20, width: 40, height: cell.bounds.height-20), title: optionIcon, border: false, bgColor: false, textColor: textColorDark)
            optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
            optionMenu.addTarget(self, action: #selector(ShowMembersViewController.showMenu(_:)), for: .touchUpInside)
            optionMenu.tag = (indexPath as NSIndexPath).row
            if logoutUser != true {
                
                cell.accessoryView = optionMenu
            }
            
            if (memberInfo["menu"] as? NSArray != nil){
                optionMenu.isHidden = false
            }
            else{
                optionMenu.isHidden = true
                
            }
            
            
            // Set Owner Image
            cell.author_photo.image = (UIImage(named: "user_profile_image.png"))
            if memberInfo["image"] != nil {
                let url = URL(string: memberInfo["image"] as! String)
                if url != nil
                {
                    cell.author_photo.kf.indicatorType = .activity
                    (cell.author_photo.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.author_photo.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
            }
            
            return cell
        }
    }
    
    @objc func showMenu(_ sender:UIButton){
        
        var confirmationTitle = ""
        var message = ""
        var url = ""
        var param: NSDictionary = [:]
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let currentRow = sender.tag
        
        memberInfo = allMembers[currentRow] as! NSDictionary
        if (memberInfo["menu"] as? NSArray != nil){
            
            if let menu = memberInfo["menu"] as? NSArray{
                
                for i in 0 ..< menu.count {
                    
                    if let menuOption = menu[i] as? NSDictionary{
                        
                        alertController.addAction(UIAlertAction(title: (menuOption["label"]! as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            let condition = menuOption["name"]! as! String
                            switch(condition){
                            case "remove_member":
                                contentFeedUpdate = true
                                
                                confirmationTitle = NSLocalizedString("Remove Member", comment: "")
                                message = NSLocalizedString("Are you sure you want to remove this member from the \(self.contentType!)", comment: "")
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                
                            case "make_officer":
                                confirmationTitle = NSLocalizedString("Promote Member", comment: "")
                                message = NSLocalizedString("Are you sure you want to promote this member to officer?", comment: "")
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            case "remove_admin":
                                
                                contentFeedUpdate = true
                                
                                confirmationTitle = NSLocalizedString("Remove Admin", comment: "")
                                message = NSLocalizedString("Are you sure you want to remove the admin member from the \(self.contentType!)", comment: "")
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                
                            case "make_admin":
                                
                                confirmationTitle = NSLocalizedString("Make Admin", comment: "")
                                message = NSLocalizedString("Are you sure you want to make this member admin", comment: "")
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                
                            case "demote_officer":
                                confirmationTitle = NSLocalizedString("Demote Member", comment: "")
                                message = NSLocalizedString("Are you sure you want to demote this member from officer?", comment: "")
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                
                            case "cancel_invite":
                                if self.allMembers.count == 1{
                                    self.waitingMembers = false
                                }
                                
                                confirmationTitle = NSLocalizedString("Cancel Invite Request", comment: "")
                                message = NSLocalizedString("Would you like to cancel your request for an invite to this \(self.contentType)?", comment: "")
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                
                            case "approved_member":
                                
                                contentFeedUpdate = true
                                
                                if self.allMembers.count == 1{
                                    self.waitingMembers = false
                                }
                                if self.contentType == "advancedevents" || self.contentType == "event" {
                                    confirmationTitle = NSLocalizedString("Approve Event Membership Request", comment: "")
                                    message = NSLocalizedString("Would you like to approve the request for membership of this event?", comment: "")
                                }
                                else {
                                    confirmationTitle = NSLocalizedString("Approve Group Membership Request", comment: "")
                                    message = NSLocalizedString("Would you like to approve the request for membership in this group?", comment: "")
                                }
                               
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                
                            case "reject_member":
                                if self.allMembers.count == 1{
                                    self.waitingMembers = false
                                }
                                confirmationTitle = NSLocalizedString("Reject Group Invitation", comment: "")
                                message = NSLocalizedString("Would you like to reject the invitation to this group?", comment: "")
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                
                            case "member_follow":
                                confirmationTitle = NSLocalizedString("Add Friend", comment: "")
                                message = NSLocalizedString("Would you like to add this member as a friend? ", comment: "")
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                
                            case "member_unfollow":
                                confirmationTitle = NSLocalizedString("Remove Friend", comment: "")
                                message = NSLocalizedString("Are you sure you want to remove this member as a friend?", comment: "")
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                
                            case "cancel_follow":
                                confirmationTitle = NSLocalizedString("Cancel Friend Request", comment: "")
                                message = NSLocalizedString("Do you want to cancel your friend request? ", comment: "")
                                url = menuOption["url"] as! String
                                param = (menuOption["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                
                                
                            default:
                                
                                print("error")
                                
                                
                            }
                            displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                self.updateMembers(param as NSDictionary,url1: url)
                            }
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            
                        }))
                        
                    }
                    
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
        
    }
    
    // MARK:  TTTAttributedLabelDelegate
    @objc func showProfile(_ sender: UIButton){
        if let strIndex = sender.accessibilityIdentifier, let index = Int(strIndex), let photoInfo = allMembers[index] as? NSDictionary {
            if let str = photoInfo["displayname"] as? String
            {
                updateAutoSearchArray(str: str)
            }
        }
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = "\(sender.tag)"
        presentedVC.fromActivity = false
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.tag == 122{
            searchBar.text = arrRecentSearchOptions[(indexPath as NSIndexPath).row]
            arrRecentSearchOptions.remove(at: (indexPath as NSIndexPath).row)
            arrRecentSearchOptions.insert(searchBar.text!, at: 0)
            UserDefaults.standard.set(arrRecentSearchOptions, forKey: "arrRecentSearchOptions")
            if searchBar.text?.range(of: "#") != nil
            {
                let hashTagString = searchBar.text!
                let singleString : String!
                
                searchDic.removeAll(keepingCapacity: false)
                
                if hashTagString.range(of: "#") != nil{
                    let original = hashTagString
                    singleString = String(original.dropFirst())
                    
                }
                else{
                    singleString = hashTagString
                }
                updateAutoSearchArray(str: hashTagString)
                searchBar.resignFirstResponder()
                searchDic.removeAll(keepingCapacity: false)
                self.gpMemberstableView.isHidden = true
                
                let presentedVC = HashTagFeedViewController()
                presentedVC.completionHandler = {
                    
                    self.searchBar.text = nil
                    self.searchBar.becomeFirstResponder()
                    self.tblAutoSearchSuggestions.reloadData()
                    
                }
                presentedVC.hashtagString = singleString
                navigationController?.pushViewController(presentedVC, animated: false)
                
            }
            else{
                tblAutoSearchSuggestions.isHidden = true
                searchBar.resignFirstResponder()
                searchQueryInAutoSearch()
            }
            
        }
        else{
            tableView.deselectRow(at: indexPath, animated: true)
            
            memberInfo = allMembers[(indexPath as NSIndexPath).row] as! NSDictionary
            if let str = memberInfo["displayname"] as? String
            {
                updateAutoSearchArray(str: str)
            }
            //   if contentType == "group" || contentType == "advancedevents"{
            if memberInfo["user_id"] != nil {
                let user_id = memberInfo["user_id"] as? Int
                
                let presentedVC = ContentActivityFeedViewController()
                presentedVC.subjectType = "user"
                presentedVC.subjectId = "\(user_id!)"
                searchDic.removeAll(keepingCapacity: false)
                self.navigationController?.pushViewController(presentedVC, animated: false)
                
            }
            
        }
        
        
    }
    
    @objc func addNewMember(){
        
        var tempUrl : String = ""
        if (self.contentType == "sitegroup"){
            
            let presentedVC = MessageCreateController()
            presentedVC.iscoming = "sitegroup"
            presentedVC.url = "advancedgroups/member/invite-members/" + String(id)
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        else {
            
            if (self.contentType == "event"){
                tempUrl  = "events/member/invite/" + String(id)
            }
            if (self.contentType == "group"){
                tempUrl = "groups/member/invite/" + String(id)
            }
            if (self.contentType == "advancedevents")
            {
                tempUrl  = "advancedevents/member/invite/" + String(id)
            }
            let presentedVC = InviteMemberViewController()
            presentedVC.contentType = self.contentType
            
            presentedVC.url = tempUrl as String
            presentedVC.param = Dictionary<String, String>() as NSDictionary? //menuItem["urlParams"] as! NSDictionary
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func msgGuest()
    {
        if (self.contentType == "sitegroup"){
            let presentedVC = AdvancedGroupMsgViewController()
            presentedVC.guid = self.guid
            presentedVC.url = msgUrl
            presentedVC.groupId = "\(id!)"
            self.navigationController?.pushViewController(presentedVC, animated: true)
            
        }
        else{
            let presentedVC = AdvMsgGuestViewController()
            presentedVC.guid = self.guid
            presentedVC.url = msgUrl
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
        
    }
    
    // Make Custom Links from Activity Feed
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        
        let type = components["type"] as! String
        
        switch(type){
            
            
        case "user":
            
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(components["user_id"]!)"
            presentedVC.fromActivity = false
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
            
            
        default:
            print("default")
        }
        
        
    }
    
    @objc func searchItem(){
        let presentedVC = ShowMemberSearchViewController()
        presentedVC.url = url
        presentedVC.contentType = contentType
        presentedVC.resourceId = resourceId
        self.navigationController?.pushViewController(presentedVC, animated: false)
        globalCatg = ""
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //
    //        // if updateScrollFlag{
    //        // Check for Page Number for Browse Blog
    //        if gpMemberstableView.contentOffset.y >= gpMemberstableView.contentSize.height - gpMemberstableView.bounds.size.height{
    //            if (!isPageRefresing  && limit*pageNumber < totalItems){
    //                if Reachabable.isConnectedToNetwork() {
    //                    //            updateScrollFlag = false
    //                    pageNumber += 1
    //                    isPageRefresing = true
    //                    if searchDic.count == 0{
    //                        if url != nil{
    //                            showMembers(url, parameter: param)
    //                        }
    //                    }
    //
    //                }
    //            }
    //
    //        }
    //
    //        //  }
    //
    //    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
//        if tblAutoSearchSuggestions.isHidden == true
//        {
            let currentOffset = scrollView.contentOffset.y
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
            
            if maximumOffset - currentOffset <= 10
            {
                //      if updateScrollFlag{
                if (!isPageRefresing  && limit*pageNumber < totalItems){
                    if Reachabable.isConnectedToNetwork() {
                        //            updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        gpMemberstableView.tableFooterView?.isHidden = false
                        //   if searchDic.count == 0{
                        if url != nil{
                            showMembers(url, parameter: param)
                        }
                        // }
                        
                    }
                }
                else
                {
                    gpMemberstableView.tableFooterView?.isHidden = true
                }
                
                //     }
                
            }
     //   }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
        gpMemberstableView.tableFooterView?.isHidden = true
        if self.contentType == "sitegroup"{
            self.marqueeHeader.text = ""
            removeMarqueFroMNavigaTion(controller: self)
        }
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
