
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
//  FriendListViewController.swift
//  seiosnativeapp

import UIKit
import NVActivityIndicatorView
import Instructions

/// Point of Interest Item which implements the GMUClusterItem protocol.


var fromFriendlist : Bool = false

class FriendListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    
    let mainView = UIView()
    // Variables for Likes
    var allMembers:[Members] = []
    var allMapMembers:[Members] = []
    var membersTableView:UITableView!
    var pageNumber:Int = 1
    var mapPageNumber:Int = 1
    var totalItems:Int = 0
    var isShimmer = false
    var isPageRefresing = false
    var dynamicHeight:CGFloat = 100              // Dynamic Height fort for Cell
    var contentType:String! = ""
    var contentId:String!
    var memberCount : Int!
    var updateScrollFlag = true
    var indexChange : Int!
    var showSpinner = true
    var navLeftIcon = false
    var leftBarButtonItem : UIBarButtonItem!
    var fromTab : Bool! = false
    
    var buttonView : UIView!
    var listbutton : UIButton!
    var mapButton : UIButton!
    var showType = "list"
    var mapView = GMSMapView()
    var clusterManager: GMUClusterManager!
    var userdata :[AnyObject] = []
    var phones = [String]()
    var imageConvert = [UIImage]()
    var nextButton = UIButton()
    var checkNext : Bool = true
    var totalMemberCount : Int = 0
    var mapTotalMemberCount : Int = 0
    var titleLabelField = UILabel()
    var mapormember : Int = 1 // 1 for listView
    var j = 0
    var deleteButton1 : UIButton!
    var customLimit : Int = 50
    var urlString: String!
    var param: NSDictionary!
    var kCameraLatitude : Double = 0.0
    var kCameraLongitude : Double = 0.0
    let defaults = UserDefaults.standard
    var viewType : String = "0"
    var firstTime : Bool = true
    var firstTimeForList : Bool = true
    
    var profileOfUserId : Int = 0
    var locationManager = CLLocationManager()
    var didFindLocation = false
    
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    var userId : Int = 0
    var shimmerCellCount : Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 NotificationCenter.default.addObserver(self,selector:#selector(MemberViewController.applicationWillEnterForeground),name: UIApplication.willEnterForegroundNotification,object: nil)
        self.shimmerCellCount = Int((self.view.frame.size.height - tabBarHeight)/shimmerCellHeight)
        self.isShimmer = true
        kCameraLatitude = self.defaults.double(forKey:"Latitude")
        kCameraLongitude = self.defaults.double(forKey:"Longitude") // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        membersUpdate1 = true
        searchDic.removeAll(keepingCapacity: false)
        if fromTab == false{
            self.navigationItem.setHidesBackButton(true, animated: false)
            setDynamicTabValue()
        }
        else{
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(MemberViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        
        if contentType == "AdvVideo"{
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(MemberViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        setNavigationImage(controller: self)
        
        if self.contentType == "user"{
            let addMember = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(MemberViewController.addNewMember))
            self.navigationItem.rightBarButtonItem = addMember
        }
        
        membersTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING , width: view.bounds.width, height: view.bounds.height-(TOPPADING)  - tabBarHeight), style: .grouped)
        membersTableView.register(MemberListViewCell.self, forCellReuseIdentifier: "Cell")
        membersTableView.rowHeight = 80
        membersTableView.dataSource = self
        membersTableView.delegate = self
        membersTableView.bounces = false
        membersTableView.backgroundColor = tableViewBgColor
        membersTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.membersTableView.estimatedSectionHeaderHeight = 0
        }
        
        view.addSubview(membersTableView)
        
        pageNumber = 1
        updateScrollFlag = false
        userdata.removeAll(keepingCapacity: false)
        allMembers.removeAll(keepingCapacity: true)
        findAllMembers()
        
        self.automaticallyAdjustsScrollViewInsets = false;
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        membersTableView.tableFooterView = footerView
        membersTableView.tableFooterView?.isHidden = true
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
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
            let origin_x : CGFloat = self.view.bounds.width - 60.0
            let radious : Int = 30
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 46 + iphonXTopsafeArea), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
            
        case 1:
            // skipView.isHidden = true
            var  coachMark2 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 46.0
            let radious : Int = 40
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 88 + iphonXTopsafeArea), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
            
        case 2:
            // skipView.isHidden = true
            var  coachMark2 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 15.0
            let radious : Int = 30
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 78), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
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
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        // coachViews.bodyView.isUserInteractionEnabled = false
        default:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
            //        case 0:
            //            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: "")) \n\n  1/2  "
            //            coachViews.bodyView.nextLabel.text = "Next"
            
        case 0:
            coachViews.bodyView.hintLabel.text = NSLocalizedString("Click here to search any particular member.", comment: "")
            coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 1/2", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Next ", comment: "")
            
        case 1:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("List/Map : Choose to See Users in List or Map View", comment: ""))"
            coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 2/2", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
            
        case 2:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("Show Map View", comment: ""))"
            coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 3/3", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
            
            
            
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
        if let name = defaults.object(forKey: "showMemberSearchPluginAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showMemberSearchPluginAppTour") != nil {
                
                self.targetCheckValue = name as! Int
                
                
            }
            
        }
        
        if self.targetCheckValue == 1 {
            
            UserDefaults.standard.set(2, forKey: "showMemberSearchPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        if go_Back == true {
            go_Back = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        membersTableView.tableFooterView?.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if searchDic.count > 0 {
            
            if viewType == "0"
            {
                pageNumber = 1
                //showSpinner = true
                allMembers.removeAll(keepingCapacity: false)
            }
            findAllMembers()
            filterSearchFormArray.removeAll(keepingCapacity: false)
        }
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
  
    
    @objc func nextMember(){
        nextButton.isHidden = false
        if self.allMapMembers.count < self.mapTotalMemberCount {
            mapPageNumber  = mapPageNumber + 1
            nextButton.isEnabled = false
            findAllMembers()
        }
        else{
            showToast(message: "No More Members", controller: self)
        }
    }
    
    // Open Filter Search Form
    @objc func filterSerach(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            //            searchDic.removeAll(keepingCapacity: false)
            membersUpdate1 = false
            filterSearchFormArray.removeAll(keepingCapacity: false)
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "members/browse-search-form"
            presentedVC.serachFor = "members"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showMemberContent")
        {
            if  UserDefaults.standard.object(forKey: "showMemberContent") != nil {
                
                contentType = name as! String
                
            }
            UserDefaults.standard.removeObject(forKey: "showMemberContent")
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
    
    // MARK: - Server Connection For All Likes
    @objc func menuAction(_ sender:UIButton){
        // Generate Feed Filter Gutter Menu for Feed Come From Server as! Alert Popover
        
        if viewType == "0"
        {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 6.0, options: UIView.AnimationOptions.allowUserInteraction, animations: {
                sender.transform = .identity
            }, completion: { (_) in
                if (sender.tag > -1){
                    let memberInfo = self.allMembers[sender.tag]
                    if let menuItem = memberInfo.menus{
                        let nameString1 = menuItem["name"]as! String
                        self.indexChange = sender.tag
                        self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : memberInfo.user_id, menuType : nameString1)
                        
                    }
                }
            }
            )
        }
        else {
            if (sender.tag > -1){
                let memberInfo = self.allMembers[sender.tag]
                if let menuItem = memberInfo.menus{
                    let nameString1 = menuItem["name"]as! String
                    self.indexChange = sender.tag
                    self.updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String , user_id : memberInfo.user_id, menuType : nameString1)
                    
                }
            }
        }
        
        
    }
    
    func updateMembers(_ parameter: NSDictionary , url : String , user_id : Int,menuType : String){
        
        // Check Internet Connection
        if reachability.connection != .none {
            var temp = allMembers
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            if self.viewType == "0"
            {
                
                for (index,value) in self.allMembers.enumerated(){
                    if url == "delete"{
                        feedUpdate = true
                        if value.user_id == user_id{
                            self.allMembers.remove(at: index)
                            self.userdata.remove(at: index)
                            // Set Updated Label Info
                            var finalText = ""
                            finalText =  singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: total_Likes)
                            total_Comments = total_Comments - 1
                            finalText +=  singlePluralCheck( NSLocalizedString(" Comment", comment: ""),  plural: NSLocalizedString(" Comments", comment: ""), count: total_Comments)
                            
                        }
                    }else{
                        
                        
                        if value.user_id == user_id{
                            
                            let tempOldMenuDictionary :NSMutableDictionary = [:]
                            //                                    let type = menuType
                            switch(menuType){
                            case "add_friend":
                                
                                if   value.isVerified != nil && value.isVerified == 1{
                                    tempOldMenuDictionary["label"] = "Cancel Request"
                                    tempOldMenuDictionary["url"] = "user/cancel"
                                    tempOldMenuDictionary["name"] = "cancel_request"
                                    tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                    
                                }
                                else{
                                    tempOldMenuDictionary["label"] = "Remove Friend"
                                    tempOldMenuDictionary["url"] = "user/remove"
                                    tempOldMenuDictionary["name"] = "remove_friend"
                                    tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                }
                                
                            case "cancel_request":
                                
                                tempOldMenuDictionary["label"] = "Add Friend"
                                tempOldMenuDictionary["url"] = "user/add"
                                tempOldMenuDictionary["name"] = "add_friend"
                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                
                            case "remove_friend":
                                
                                tempOldMenuDictionary["label"] = "Add Friend"
                                tempOldMenuDictionary["url"] = "user/add"
                                tempOldMenuDictionary["name"] = "add_friend"
                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                
                                
                            case "member_follow":
                                if  value.isVerified != nil && value.isVerified == 1 {
                                    tempOldMenuDictionary["label"] = "Cancel Follow Request"
                                    tempOldMenuDictionary["url"] = "user/cancel"
                                    tempOldMenuDictionary["name"] = "cancel_follow"
                                    tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                    
                                }
                                else{
                                    tempOldMenuDictionary["label"] = "Unfollow"
                                    tempOldMenuDictionary["url"] = "user/remove"
                                    tempOldMenuDictionary["name"] = "member_unfollow"
                                    tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                }
                                
                            case "member_unfollow":
                                tempOldMenuDictionary["label"] = "Follow"
                                tempOldMenuDictionary["url"] = "user/add"
                                tempOldMenuDictionary["name"] = "member_follow"
                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                
                                
                            case "cancel_follow":
                                tempOldMenuDictionary["label"] = "Follow"
                                tempOldMenuDictionary["url"] = "user/add"
                                tempOldMenuDictionary["name"] = "member_follow"
                                tempOldMenuDictionary["urlParams"] = value.menus["urlParams"] as! NSDictionary
                                
                            default:
                                print("default")
                            }
                            
                            
                            let newDictionary:NSMutableDictionary = [:] //= [String:AnyObject]()
                            newDictionary["image_profile"] = value.image_profile
                            newDictionary["displayname"] = value.displayname
                            newDictionary["user_id"] = value.user_id
                            newDictionary["isVerified"] = value.isVerified
                            newDictionary["location"] = value.location
                            newDictionary["latitude"] = value.latitude
                            newDictionary["longitude"] = value.longitude
                            newDictionary["mutualFriendCount"] = value.mutualFriendCount
                            newDictionary["image_normal"] = value.image_normal
                            newDictionary["mutualFriendCount"] = value.mutualFriendCount
                            newDictionary["menus"] = tempOldMenuDictionary
                            
                            var newData = Members.loadCommentsfromDictionary(newDictionary)
                            
                            self.allMembers[index] = newData[0] as Members
                            self.membersTableView.reloadData()
                            
                        }
                    }
                }
            }
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if url.range(of: "remove") != nil{
                            showToast(message: NSLocalizedString("This person has been removed from your friends.", comment: ""), controller: self)
                            
                        }else if url.range(of: "add") != nil {
                            showToast(message: NSLocalizedString("Your friend request has been sent", comment: ""), controller: self)
                            
                        }else if url.range(of: "cancel") != nil{
                            showToast(message: NSLocalizedString("Your friend request has been canceled.", comment: ""), controller: self)
                            
                        }else{
                            
                            // Handle Server Side Error
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                                self.allMembers = temp
                                self.membersTableView.reloadData()
                            }
                        }
                        
                     
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    func findAllMembers(){
        
        // Check Internet Connection
        if reachability.connection != .none {
            removeAlert()
            if viewType == "0"
            {
                if (self.pageNumber == 1) && allMembers.count > 0{
                    membersTableView.reloadData()
                }
            }
            
            if self.showSpinner{
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                    self.view.addSubview(activityIndicatorView)
                    //activityIndicatorView.startAnimating()
                }
                if (self.pageNumber == 1){
                    updateScrollFlag = false
                }
                
                
            }
            
          
            
            var parameter = [String:String]()
            let defaults = UserDefaults.standard
            let loc = defaults.string(forKey: "Location") ?? ""
            parameter = ["limit":"\(customLimit)", "page":"\(pageNumber)","viewType":"0"]
            
            var url = ""
            
            switch(contentType){
                
            case "user":
                parameter.merge(["user_id": String(contentId)])
                url = "user/get-friend-list"
            case "userFollow":
                parameter.merge(["resource_id": String(contentId), "resource_type": "user"])
                url = "advancedmember/following"
            case "userFollower":
                parameter.merge(["resource_id": String(contentId), "resource_type": "user"])
                url = "advancedmember/followers"
            case "AdvVideo":
                url = urlString
                parameter = param as! [String : String]
                break
                
            default:
                print("error")
            }
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameter.merge(searchDic)
            }
            searchDic.removeAll(keepingCapacity: false)
            // Send Server Request to Share Content
            post(parameter, url: url, method: "GET") { (succeeded, msg) -> () in
                
                // Remove Spinner
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.isShimmer = false
                    self.nextButton.isEnabled = true
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if self.contentType == "AdvVideo"{
                                    if let members = body["members"] as? NSArray{
                                        self.allMembers +=  Members.loadMembers(members)
                                    }
                                }
                                
                                if ((self.contentType == "user") ){
                                    if let likes = body["friends"] as? NSArray{
                                        self.userdata += likes as [AnyObject]
                                        
                                        self.allMembers += Members.loadMembers(likes)
                                    }
                                }
                                if  (self.contentType == "userFollow") || (self.contentType == "userFollower"){
                                    if let likes = body["response"] as? NSArray{
                                        self.allMembers += Members.loadMembers(likes)
                                    }
                                }
                                
                                if let members = body["totalItemCount"] as? Int{
                                    
                                    if self.viewType == "0"
                                    {
                                        self.totalMemberCount = members
                                    }
                                    else
                                    {
                                        self.mapTotalMemberCount = members
                                    }
                                    self.memberCount = members
                                    if self.contentType == "user"{
                                        self.title =  String(format: NSLocalizedString(" Friends (%d) ", comment: ""),self.memberCount)
                                    }
                                    else if self.contentType == "userFollow"{
                                        if self.memberCount == 1 {
                                            self.title =  String(format: NSLocalizedString(" Following (%d) ", comment: ""),self.memberCount)
                                        }
                                        else{
                                            self.title =  String(format: NSLocalizedString(" Followings (%d) ", comment: ""),self.memberCount)
                                        }
                                    }
                                    else if self.contentType == "userFollower"{
                                        if self.memberCount == 1 {
                                            self.title =  String(format: NSLocalizedString(" Follower (%d) ", comment: ""),self.memberCount)
                                        }
                                        else{
                                            self.title =  String(format: NSLocalizedString(" Followers (%d) ", comment: ""),self.memberCount)
                                        }
                                    }
                                        
                                        
                                    else if self.contentType == "AdvVideo"
                                    {
                                        self.title =  String(format: NSLocalizedString(" Subscribers (%d) ", comment: ""),self.memberCount)
                                    }
                                        
                                    else{
                                        self.title = NSLocalizedString("Members", comment: "")
                                        self.titleLabelField.text = "\(self.memberCount!) members found"
                                        self.titleLabelField.isHidden = false
                                    }
                                    
                                    self.totalItems = members
                                }
                            }
                            
                            self.isPageRefresing = false
                            self.membersTableView.reloadData()
                        }
                    }else{
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
    
    @objc func clickOnFloatyMsgButton(_ sender:UIButton)
    {
        let dic = self.allMembers[sender.tag]
        
        if isChannelizeAvailable{
            if let userId = dic.user_id{
                let data : [AnyHashable:Any] = [AnyHashable("userId"):userId]
                if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                    let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                    if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                        channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: data)
                    } else{
                        let presentedVC = MessageCreateController()
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        presentedVC.userID = "\(dic.user_id ?? 0)"
                        presentedVC.fromProfile = true
                        presentedVC.profileName =  dic.displayname
                        self.navigationController?.pushViewController(presentedVC, animated: true)
                    }
                }
            }
        } else{
            let presentedVC = MessageCreateController()
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            presentedVC.userID = "\(dic.user_id ?? 0)"
            presentedVC.fromProfile = true
            presentedVC.profileName =  dic.displayname
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    @objc func showMainGutterMenu(_ sender: UIButton){
        
        // Generate Group Menu Come From Server as! Alert Popover
        
        //        deleteContent = false
        var key_name = ""
        var confirmationTitle = ""
        //
        var message = ""
        var url = ""
        var param: NSDictionary = [:]
        let confirmationAlert = true
        
        let dic = self.allMembers[sender.tag]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        if let menuItem = dic.menus{
            
            key_name = menuItem["name"] as! String
            
            if (menuItem["name"] as! String != "share")  && (menuItem["name"] as! String != "join-waitlist"){
                
                let titleString = menuItem["name"] as! String
                
                if (titleString.range(of: "remove_friend") != nil || titleString.range(of: "member_unfollow") != nil || titleString.range(of: "cancel_request") != nil || titleString.range(of: "cancel_follow") != nil)
                {
                    
                    alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .destructive , handler:{ (UIAlertAction) -> Void in
                        let condition = menuItem["name"] as! String
                        switch(condition){
                            
                        case "remove_friend","member_unfollow":
                            confirmationTitle = NSLocalizedString("Remove Friend", comment: "")
                            message = NSLocalizedString("Are you sure you want to remove this member as a friend?", comment: "")
                            url = menuItem["url"] as! String
                            param = menuItem["urlParams"] as! NSDictionary
                            
                        case "cancel_request","cancel_follow":
                            confirmationTitle = NSLocalizedString("Cancel Friend Request", comment: "")
                            message = NSLocalizedString("Do you want to cancel your friend request?", comment: "")
                            url = menuItem["url"] as! String
                            param = menuItem["urlParams"] as! NSDictionary
                            
                        default:
                            showToast(message: unconditionalMessage, controller: self)
                            
                        }
                        
                        if confirmationAlert == true {
                            displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                
                                self.updateMembers(param, url: url , user_id : dic.user_id, menuType : condition)
                            }
                            self.present(alert, animated: true, completion: nil)
                        }
                    }))
                }
                else
                {
                    alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                        let condition = menuItem["name"] as! String
                        switch(condition){
                            
                        case "add_friend","member_follow":
                            confirmationTitle = NSLocalizedString("Add Friend", comment: "")
                            message = NSLocalizedString("Would you like to add this member as a friend? ", comment: "")
                            url = menuItem["url"] as! String
                            param = menuItem["urlParams"] as! NSDictionary
                            
                        default:
                            showToast(message: unconditionalMessage, controller: self)
                        }
                        
                        if confirmationAlert == true {
                            displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                self.updateMembers(param, url: url , user_id : dic.user_id, menuType : condition)
                            }
                            self.present(alert, animated: true, completion: nil)
                        }
                    }))
                }
            }
        }
        
        if key_name == "remove_friend" {
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Add To List",comment: ""), style: .default, handler:{ (UIAlertAction) -> Void in
                
                let presentedVC = AddtolistViewController()
                let id = self.allMembers[sender.tag]
                presentedVC.friend_id = id.user_id
                self.navigationController?.pushViewController(presentedVC, animated: false)
            }))
        }
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (customLimit*pageNumber < totalItems){
            return 0
        }else{
            return 0.001
        }
    }
    
    // Set Table Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isShimmer {
            return shimmerCellHeight
        }
        else {
            return dynamicHeight
        }
        
        
    }
    
    // Set Table Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if self.isShimmer {
            return self.shimmerCellCount
        }
        else {
           return allMembers.count
        }
    }
    
    @objc func redirecttolist(_ sender: UIButton)
    {
        let presentedVC = AddtolistViewController()
        let id = self.allMembers[sender.tag]
        presentedVC.friend_id = id.user_id
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if self.isShimmer {
             tableView.register(MemberShimmeringTableCell.self, forCellReuseIdentifier: "cell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MemberShimmeringTableCell
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MemberListViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            let memberInfo = allMembers[(indexPath as NSIndexPath).row]
            cell.tag = (indexPath as NSIndexPath).row
            if let url = URL(string: memberInfo.image_profile!){
                
                cell.profileImage.kf.setImage(with: url, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
            }
            cell.msgButton.isHidden = true
            cell.optionMenu.isHidden = true
            cell.userName.isHidden = true
            cell.locationLabel.isHidden = true
            cell.mutualFriendsLabel.isHidden = true
            cell.friendName.text = memberInfo.displayname
            if contentType == "AdvVideo" {
                cell.msgButton.isHidden = true
                cell.optionMenu.isHidden = true
                cell.friendName.isHidden = true
                cell.userName.isHidden = false
                cell.userName.text = memberInfo.displayname
                cell.locationLabel.isHidden = false
                cell.locationLabel.text = memberInfo.location
            }
            if let menu = memberInfo.menus
            {
                if menu.count > 0
                {
                    if contentType == "user"
                    {
                        if(logoutUser == false){
                            if memberInfo.user_id != nil {
                                if userId != currentUserId{
                                    
                                    cell.msgButton.isHidden = true
                                    cell.optionMenu.isHidden = true
                                    let nameString = menu["name"]as! String
                                    if nameString == "add_friend" || nameString == "member_follow"{
                                        cell.friendRequestButton.isHidden = false
                                        let originalImage = UIImage(named: "FriendOutlinedIcon_Add")
                                        let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
                                        cell.friendRequestButton.setImage(tintedImage, for: .normal)
                                        cell.friendRequestButton.tintColor = buttonColor
                                        cell.friendRequestButton.addTarget(self, action: #selector(FriendListViewController.menuAction(_:)), for: .touchUpInside)
                                        cell.friendRequestButton.tag = (indexPath as NSIndexPath).row
                                        
                                    }
                                        
                                    else if (nameString == "cancel_request") ||  (nameString == "cancel_follow"){
                                        cell.friendRequestButton.isHidden = false
                                        let originalImage = UIImage(named: "FriendFilledIcon_Cancel")
                                        let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
                                        cell.friendRequestButton.setImage(tintedImage, for: .normal)
                                        cell.friendRequestButton.tintColor = buttonColor
                                        cell.friendRequestButton.addTarget(self, action: #selector(FriendListViewController.menuAction(_:)), for: .touchUpInside)
                                        
                                        cell.friendRequestButton.tag = (indexPath as NSIndexPath).row
                                    }
                                    else if (nameString == "remove_friend") ||  (nameString == "member_unfollow"){
                                        cell.friendRequestButton.isHidden = false
                                        let originalImage = UIImage(named: "FriendFilledIcon_Tick")
                                        let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
                                        cell.friendRequestButton.setImage(tintedImage, for: .normal)
                                        cell.friendRequestButton.tintColor = buttonColor
                                        cell.friendRequestButton.addTarget(self, action: #selector(FriendListViewController.menuAction(_:)), for: .touchUpInside)
                                        
                                        cell.friendRequestButton.tag = (indexPath as NSIndexPath).row
                                        
                                    }
                                    
                                }
                                else{
                                    let nameString = menu["name"]as! String
                                    
                                    if (nameString == "remove_friend")  ||  (nameString == "member_unfollow")
                                    {
                                        cell.msgButton.isHidden = false
                                        cell.optionMenu.isHidden = false
                                        cell.optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome5FreeSolid", size: 18.0)
                                        cell.optionMenu.setTitle(moreIcon, for: .normal)
                                        cell.optionMenu.setTitleColor(textColorMedium, for: .normal)
                                        cell.containerView.addSubview(cell.msgButton)
                                        cell.containerView.addSubview(cell.optionMenu)
                                        cell.optionMenu.tag = (indexPath as NSIndexPath).row
                                        cell.msgButton.tag = (indexPath as NSIndexPath).row
                                        cell.optionMenu.addTarget(self, action: #selector(FriendListViewController.showMainGutterMenu(_:)), for: .touchUpInside)
                                        cell.msgButton.addTarget(self, action: #selector(FriendListViewController.clickOnFloatyMsgButton(_:)), for: .touchUpInside)
                                        
                                    }
                                    if nameString == "add_friend" || nameString == "member_follow"{
                                        cell.msgButton.isHidden = true
                                        cell.optionMenu.isHidden = false
                                        
                                    }
                                        
                                    else if (nameString == "cancel_request") ||  (nameString == "cancel_follow"){
                                        cell.msgButton.isHidden = true
                                        cell.optionMenu.isHidden = false
                                    }
                                    else
                                    {
                                        //  cell.msgButton.isHidden = true
                                        //                                    cell.optionMenu.isHidden = true
                                        
                                    }
                                    
                                }
                            }
                            
                        }
                        
                    }
                    if contentType == "userFollow"  || contentType == "userFollower" {
                        cell.msgButton.isHidden = true
                        //                    cell.optionMenu.isHidden = true
                        let nameString = menu["name"]as! String
                        if nameString == "add_friend" || nameString == "member_follow"{
                            cell.friendRequestButton.isHidden = false
                            let originalImage = UIImage(named: "FriendOutlinedIcon_Add")
                            let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
                            cell.friendRequestButton.setImage(tintedImage, for: .normal)
                            cell.friendRequestButton.tintColor = buttonColor
                            cell.friendRequestButton.addTarget(self, action: #selector(FriendListViewController.menuAction(_:)), for: .touchUpInside)
                            cell.friendRequestButton.tag = (indexPath as NSIndexPath).row
                            
                        }
                            
                        else if (nameString == "cancel_request") ||  (nameString == "cancel_follow"){
                            cell.friendRequestButton.isHidden = false
                            let originalImage = UIImage(named: "FriendFilledIcon_Cancel")
                            let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
                            cell.friendRequestButton.setImage(tintedImage, for: .normal)
                            cell.friendRequestButton.tintColor = buttonColor
                            cell.friendRequestButton.addTarget(self, action: #selector(FriendListViewController.menuAction(_:)), for: .touchUpInside)
                            
                            cell.friendRequestButton.tag = (indexPath as NSIndexPath).row
                        }
                        else if (nameString == "remove_friend") ||  (nameString == "member_unfollow"){
                            cell.friendRequestButton.isHidden = false
                            let originalImage = UIImage(named: "FriendFilledIcon_Tick")
                            let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
                            cell.friendRequestButton.setImage(tintedImage, for: .normal)
                            cell.friendRequestButton.tintColor = buttonColor
                            cell.friendRequestButton.addTarget(self, action: #selector(FriendListViewController.menuAction(_:)), for: .touchUpInside)
                            
                            cell.friendRequestButton.tag = (indexPath as NSIndexPath).row
                            
                        }
                        
                    }
                }
            }
            
            return cell
        }
        
    }
    
    // Handle Classified Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !isShimmer {
        if allMembers.count > (indexPath as NSIndexPath).row {
            let  memberInfo = allMembers[(indexPath as NSIndexPath).row]
            
            if let menuItem = memberInfo.menus{
                
                if let urlParam = menuItem["urlParams"] as? NSDictionary{
                    var user_id : Int = 0
                    if let id = urlParam["user_id"] as? Int
                    {
                        
                        user_id = id
                    }
                    else if let id = urlParam["resource_id"] as? Int
                    {
                        user_id = id
                    }
                    
                    let presentedVC = ContentActivityFeedViewController()
                    presentedVC.subjectType = "user"
                    presentedVC.subjectId = "\(user_id)"
                    searchDic.removeAll(keepingCapacity: false)
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                    
                }
                
            } else{
                if let user_id = memberInfo.user_id{
                    let presentedVC = ContentActivityFeedViewController()
                    presentedVC.subjectType = "user"
                    presentedVC.subjectId = "\(userid)"
                    searchDic.removeAll(keepingCapacity: false)
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                    
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
                if (!isPageRefresing  && customLimit*pageNumber < totalItems){
                    
                    if reachability.connection != .none {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        membersTableView.tableFooterView?.isHidden = false
                        findAllMembers()
                    }
                }
                else
                {
                    membersTableView.tableFooterView?.isHidden = true
                }
            }
            
        }
        
    }
    
    @objc func addNewMember(){
        let presentedVC = MemberViewController()
        presentedVC.contentType = "members"
        presentedVC.navLeftIcon = true
        presentedVC.fromTab = true
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

