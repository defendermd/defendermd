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
//  MembersViewController.swift
//  seiosnativeapp

import UIKit
var friendRequest:Bool!
let keywindow = UIApplication.shared.keyWindow
class FriendRequestViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    let mainView = UIView()
    // Variables for Likes
    var allMembers :[FriendRequestModel] = []
    var membersTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    //  var activityFeedLikes:Bool!
    var isPageRefresing = false
    var dynamicHeight:CGFloat = 90          // Dynamic Height fort for Cell
    var contentType:String = ""
    var searchBar : UISearchBar!             // searchBar
    var contentId:Int!
    var noRequestLabel : UILabel!
    var refresher:UIRefreshControl!
    
    var leftBarButtonItem : UIBarButtonItem!
    var urlString: String!
    var param: NSDictionary!
    var friendRequestAcceptView : FriendConfirmationTip!
    
    
    // Initialize MembersViewController Class
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        setDynamicTabValue()
        friendRequest = true
        searchDic.removeAll(keepingCapacity: false)
        // self.navigationController!.interactivePopGestureRecognizer!.delegate = self
        
        setNavigationImage(controller: self)
        
        membersTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING  , width: view.bounds.width, height: view.bounds.height - TOPPADING - tabBarHeight), style: UITableView.Style.plain)
        membersTableView.register(FriendRequestTableViewCell.self, forCellReuseIdentifier: "Cell")
        membersTableView.rowHeight = 70
        membersTableView.bounces = true
        membersTableView.backgroundColor = tableViewBgColor
        membersTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.membersTableView.estimatedSectionHeaderHeight = 0
        }
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(FriendRequestViewController.refresh), for: UIControl.Event.valueChanged)
        membersTableView.addSubview(refresher)
        
        if contentType == "friendmembers" {
            // Set Title for navigation Bar
            self.navigationItem.title = NSLocalizedString("Requests", comment: "")
            baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
            openMenu = false
            view.backgroundColor = bgColor
            navigationController?.navigationBar.isHidden = false
            self.navigationItem.hidesBackButton = true
            
            mainView.frame = view.frame
            mainView.backgroundColor = bgColor
            view.addSubview(mainView)
            mainView.removeGestureRecognizer(tapGesture)
            mainView.addSubview(membersTableView)
            
            noRequestLabel = createLabel(CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: 50), text: "", alignment: .left, textColor: textColorDark)
            noRequestLabel.backgroundColor = UIColor.yellow
            noRequestLabel.isHidden = true
            mainView.addSubview(noRequestLabel)
            
            // Create Filter Search Link
            let filter = createButton(CGRect(x: PADING, y: TOPPADING , width: ButtonHeight - PADING , height: 0), title: fiterIcon, border: true,bgColor: false, textColor: textColorDark)
            filter.addTarget(self, action: #selector(FriendRequestViewController.filterSerach), for: .touchUpInside)
            
            filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
            filter.tintColor = textColorPrime
            mainView.addSubview(filter)
            filter.isHidden = true
            
            
            // Initialze Searcgh Bar
            searchBar = UISearchBar()
            searchBar.frame = CGRect( x: filter.bounds.width + 2*PADING, y: TOPPADING , width: view.bounds.width - (filter.bounds.width + 3*PADING), height: 0)
            searchBar.delegate = self
            searchBar.placeholder = NSLocalizedString("Search",  comment: "")
            
            mainView.addSubview(searchBar)
            searchBar.isHidden = true
            
            for subView in searchBar.subviews  {
                for subsubView in subView.subviews  {
                    if let textField = subsubView as? UITextField {
                        textField.textColor = textColorDark
                        textField.font = UIFont(name: fontBold, size: FONTSIZENormal)
                    }
                }
            }
            
            // Change Table Frame
            membersTableView.frame = CGRect(x: 0, y: TOPPADING  , width: view.bounds.width, height: view.bounds.height - TOPPADING - tabBarHeight)
            
        }
        
        
        //  self.edgesForExtendedLayout = UIRectEdge.All;
        self.automaticallyAdjustsScrollViewInsets = false;
        pageNumber = 1
        // findAllMembers()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UpdateNotifications()
        findAllMembers()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        if let view = friendRequestAcceptView {
        //            view.removeFromSuperview()
        //        }
    }
    
    
    // Update BadgeCount
    @objc func UpdateNotifications(){
        
        // Check Internet Connectivity
        if reachability.connection != .none {
            // Reset Objects
            
            var path = ""
            
            path = "notifications/mark-friend-request-read"
            
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
    
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showFriendContent")
        {
            if  UserDefaults.standard.object(forKey: "showFriendContent") != nil {
                
                contentType = name as! String
                
            }
            UserDefaults.standard.removeObject(forKey: "showFriendContent")
        }
        
    }
    
    // Check for Blog Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        
        
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    // Open Filter Search Form
    @objc func filterSerach(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            searchBar.text = ""
            searchBar.resignFirstResponder()
            searchDic.removeAll(keepingCapacity: false)
            friendRequest = false
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "members/browse-search-form"
            presentedVC.serachFor = "members"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    func setFriendConfirmationTip(subjectid: Int, image: UIImage, name: String) {
        if let view = self.friendRequestAcceptView {
            view.removeFromSuperview()
        }
        self.friendRequestAcceptView = FriendConfirmationTip(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: self.view.frame.size.width , height: 80))
        self.friendRequestAcceptView.isHidden = true
        self.friendRequestAcceptView.alpha = 0
        self.friendRequestAcceptView.isHidden = true
        self.friendRequestAcceptView.alpha = 0
        self.friendRequestAcceptView.confirmationLabel.text = "Congrats! You and \(name) are now friends"
        self.friendRequestAcceptView.userImage.setImage(image, for: .normal)
        self.friendRequestAcceptView.userImage.id = "\(subjectid)"
        self.friendRequestAcceptView.userImage.viewController = self
        self.friendRequestAcceptView.messageButton.name = displayName
        self.friendRequestAcceptView.messageButton.id = "\(subjectid)"
        self.friendRequestAcceptView.messageButton.viewController = self
        self.friendRequestAcceptView.setView(hidden: false)
        keywindow!.addSubview(friendRequestAcceptView)
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
    
    // MARK: - UISearchBar Delegates
    // Check Condition when Search is Enable
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return false
        }else{
            return true
        }
    }
    
    func findAllMembers(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            if (self.pageNumber == 1) && allMembers.count > 0{
                membersTableView.reloadData()
            }
            
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            // Set Spinner
            
            //            spinner.center = self.view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            if contentType == "friendmembers"{
            //                mainView.addSubview(spinner)
            //            }
            //            else
            //            {
            //                view.addSubview(spinner)
            //            }
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            var url = ""
            var parameter = ["limit":"5000", "page":"\(pageNumber)"]
            switch(contentType){
            case "activityFeed", "comments":
                url = "/likes-comments"
                parameter.merge(["content_id":String(likeCommentContent_id), "content_type": likeCommentContentType, "viewAllLikes":"1"])
            case "user":
                parameter.merge(["user_id":"\(contentId)"])
                url = "user/get-friend-list"
            case "friendmembers":
                url = "notifications/friend-request"
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
            
            // Send Server Request to Share Content
            post(parameter, url: url, method: "GET") { (succeeded, msg) -> () in
                // Remove Spinner
                DispatchQueue.main.async(execute: {
                    
                    activityIndicatorView.stopAnimating()
                    
                    self.refresher.endRefreshing()
                    self.membersTableView.dataSource = self
                    self.membersTableView.delegate = self
                    if (self.pageNumber == 1){
                        self.allMembers.removeAll(keepingCapacity: false)
                    }
                    
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                if let membersArray = body["response"] as? NSArray{
                                    self.allMembers += FriendRequestModel.loadFriendRequests(membersArray)
                                }
                                if let members = body["totalItemCount"] as? Int{
                                    self.totalItems = members
                                }
                            }
                            self.isPageRefresing = false
                            self.membersTableView.reloadData()
                            
                            let footerView = createView(CGRect(x: 0, y: 0, width: self.membersTableView.frame.size.width, height: ButtonHeight), borderColor: borderColorMedium, shadow: false)
                            let footerSeeAllBtn = createButton(CGRect(x: 0, y: 0.0, width: self.membersTableView.frame.size.width, height: ButtonHeight), title: NSLocalizedString("See All", comment: ""), border: false, bgColor: false, textColor: textColorMedium)
                            footerSeeAllBtn.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            footerSeeAllBtn.backgroundColor = tableViewBgColor
                            footerSeeAllBtn.addTarget(self, action: #selector(FriendRequestViewController.seeAllSuggestions(_:)), for: UIControl.Event.touchUpInside)
                            footerView.addSubview(footerSeeAllBtn)
                            self.membersTableView.tableFooterView = footerView
                        }
                        
                    }
                    else
                    {
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 && allMembers.count == 0{
            let customView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 135))
            let label = UILabel()
            let button = UIButton()
            customView.addSubview(label)
            customView.addSubview(button)
            label.frame = CGRect(x: 0, y: 10, width: customView.frame.width, height: 40)
            label.text = NSLocalizedString("You do not have any Friend Request, Start making \nsome new Friends.", comment: "")
            label.font = UIFont.systemFont(ofSize: 14)
            label.numberOfLines = 2
            label.textAlignment = .center
            button.frame = CGRect(x: customView.frame.width/2 - 43, y: getBottomEdgeY(inputView: label) + 10, width: 86, height: 30)
            button.layer.cornerRadius = button.frame.size.height/2
            button.setTitle(NSLocalizedString("Start", comment: ""), for: .normal)
            button.layer.borderColor = buttonColor.cgColor
            button.layer.borderWidth = 1
            button.setTitleColor(UIColor.white, for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.backgroundColor = buttonColor
            button.addTarget(self, action: #selector(FriendRequestViewController.gotoMember), for: .touchUpInside)
            return customView
        }
        return nil
        
    }
    @objc func gotoMember() {
        let presentedVC = MemberViewController()
        presentedVC.contentType = "members"
        presentedVC .mapormember = 1
        navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 && allMembers.count == 0{
            return 105
        }
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title = ""
        if section == 0{
            title = NSLocalizedString("FRIEND REQUESTS",  comment:"")
        }else{
            title = NSLocalizedString("PEOPLE YOU MAY KNOW",  comment:"")
        }
        
        
        let headerview = createView(CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: ButtonHeight), borderColor: borderColorMedium, shadow: false)
        let sectionHeaderLabel = createLabel(CGRect(x: 10, y: 0.0, width: tableView.frame.size.width-20, height: ButtonHeight), text: title, alignment: NSTextAlignment.left, textColor: textColorMedium)
        sectionHeaderLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        sectionHeaderLabel.backgroundColor = tableViewBgColor
        headerview.backgroundColor = tableViewBgColor
        headerview.addSubview(sectionHeaderLabel)
        return headerview
    }
    // Set Table Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return ButtonHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set Table Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if section == 0{
            return allMembers.count
        }else{
            return userSuggestions.count
        }
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FriendRequestTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            let memberInfo = allMembers[(indexPath as NSIndexPath).row]
            // Set Name People who Likes Content
            cell.title.text = memberInfo.displayname
            cell.title.font = UIFont(name: fontBold, size: FONTSIZENormal)
            cell.title.numberOfLines = 1
            // Set Owner Image
            cell.acceptButton.image = UIImage(named: "user_image.png")
            if memberInfo.profileImage == ""{
                cell.imgUser.image = UIImage(named: "user_image.png")
            }
            else
            {
                let url = URL(string: memberInfo.profileImage!)
                cell.imgUser.kf.indicatorType = .activity
                (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url as URL?, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    cell.acceptButton.image = image
                })
                
            }
            cell.acceptButton.tag = (indexPath as NSIndexPath).row
            cell.acceptButton.addTarget(self, action: #selector(FriendRequestViewController.acceptFriend(_:)), for: .touchUpInside)
            
            cell.rejectButton.tag = (indexPath as NSIndexPath).row
            cell.rejectButton.addTarget(self, action: #selector(FriendRequestViewController.rejectFriend(_:)), for: .touchUpInside)
            return cell
        }else{
            
            membersTableView.register(FriendRequestTableViewCell.self, forCellReuseIdentifier: "suggestionsCell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "suggestionsCell", for: indexPath) as! FriendRequestTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            let memberInfo = userSuggestions[indexPath.row] as! [String: AnyObject]
            
            // Set Name People who Likes Content
            cell.title.text = memberInfo["displayname"] as! String?
            cell.title.font = UIFont(name: fontBold, size: FONTSIZENormal)
            cell.title.numberOfLines = 1
            
            // Set Owner Image
            if let photoId = memberInfo["photo_id"] as? Int{
                
                if photoId != 0{
                    let url1 = NSURL(string: memberInfo["image"] as! NSString as String)
                    cell.imgUser.kf.indicatorType = .activity
                    (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgUser.kf.setImage(with: url1! as URL?, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
                else{
                    cell.imgUser.image = nil
                    cell.imgUser.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.imgUser.bounds.width)
                    
                }
            }
            
            cell.acceptButton.setTitle(NSLocalizedString("Add Friend",  comment: ""), for: UIControl.State.normal)
            if memberInfo["friendship_type"] != nil && memberInfo["friendship_type"] as! String == "cancel_request"{
                cell.acceptButton.setTitle(NSLocalizedString("Undo", comment: ""), for: UIControl.State.normal)
            }
            cell.acceptButton.tag =  120 + (indexPath as NSIndexPath).row
            cell.acceptButton.addTarget(self, action: #selector(FriendRequestViewController.acceptSuggestion(_:)), for: .touchUpInside)
            
            cell.rejectButton.setTitle(NSLocalizedString("Remove",  comment: ""), for: UIControl.State.normal)
            cell.rejectButton.tag = 130 + (indexPath as NSIndexPath).row
            cell.rejectButton.addTarget(self, action: #selector(FriendRequestViewController.removeSuggestionFromList(_:)), for: .touchUpInside)
            return cell
        }
        //  let cell = FriendRequestTableViewCell()
        //  return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let suggestionIndex = indexPath.row
        var subjectId: Int
        if indexPath.section == 0{
            let memberInfo = allMembers[(indexPath as NSIndexPath).row]
            subjectId = memberInfo.subject_id
        }else{
            let memberInfo = userSuggestions[suggestionIndex] as! NSDictionary
            subjectId = memberInfo["user_id"] as! Int
        }
        
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = "\(subjectId)"
        searchDic.removeAll(keepingCapacity: false)
        presentedVC.fromDashboard =  false
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    // MARK:  UIScrollViewDelegate
    
    @objc func acceptFriend(_ sender:CustomButton){
        
        let memberInfo = allMembers[sender.tag]
        let subjectId = memberInfo.subject_id!
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let friend = self.allMembers[sender.tag]
        let displayName = friend.displayname!
        let userImage = sender.image
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                //
                
            })
            self.setFriendConfirmationTip(subjectid: friend.subject_id, image: userImage!, name: displayName)
            if sender.tag == self.allMembers.count - 1 {
                self.allMembers.remove(at: sender.tag)
                self.membersTableView.reloadData()
            }
            else {
                self.allMembers.remove(at: sender.tag)
                self.membersTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                self.membersTableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            }
            CATransaction.commit()
            self.view.isUserInteractionEnabled = false
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["user_id":"\(subjectId)"], url: "/user/confirm", method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    self.view.isUserInteractionEnabled = true
                    if msg{
                        showToast(message: "Friend request accepted", controller: self)
                    }
                    // Handle Server Error
                    if succeeded["message"] != nil{
                        showToast(message: succeeded["message"] as! String, controller: self)
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    
    @objc func rejectFriend(_ sender:UIButton){
        
        let memberInfo = allMembers[sender.tag]
        let subjectId = memberInfo.subject_id as Int
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            //            removeAlert()
            //            spinner.center = view.center
            //            spinner.hidesWhenStopped = true
            //            spinner.style = UIstyle.gray
            //            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(["user_id": String(subjectId)], url: "/user/reject", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    self.view.isUserInteractionEnabled = true
                    activityIndicatorView.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    if msg{
                        let indexPath = IndexPath(row: sender.tag, section: 0)
                        self.membersTableView.beginUpdates()
                        self.allMembers.remove(at: sender.tag)
                        self.membersTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
                        self.membersTableView.endUpdates()
                        self.membersTableView.reloadData()
                        
                    }
                })
            }
        }
    }
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            pageNumber = 1
            findAllMembers()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    
    // See all suggetion
    @objc func seeAllSuggestions(_ sender: UIButton){
        let vc = SuggestionsBrowseViewController()
        vc.activeTableView = 1
        self.navigationController?.pushViewController(vc, animated: false)
    }
    //MARK: Accept Reject and Remove Suggestions or Requests Functions
    @objc func acceptSuggestion(_ sender:UIButton){
        
        let suggestionIndex = sender.tag-120
        if suggestionIndex < userSuggestions.count && userSuggestions[suggestionIndex] != nil {
            let memberInfo = userSuggestions[suggestionIndex] as! NSDictionary
            let subjectId = memberInfo["user_id"] as! Int
            
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
                sender.isEnabled = false
                let userAction = memberInfo["friendship_type"] as? String
                var url = "user/add"
                if userAction == "cancel_request"{
                    url = "user/cancel"
                }
                self.view.isUserInteractionEnabled = false
                // Send Server Request to Explore Blog Contents with Blog_ID
                post(["user_id":String(subjectId)], url: url, method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        sender.isEnabled = true
                        if msg{
                            _ = IndexPath(row: suggestionIndex, section: 0)
                            if userAction == "cancel_request"{
                                memberInfo.setValue("add_friend", forKey: "friendship_type")
                            }else{
                                memberInfo.setValue("cancel_request", forKey: "friendship_type")
                            }
                            self.membersTableView.reloadData()
                            
                        }
                        self.view.isUserInteractionEnabled = true
                    })
                }
                
            }else{
                // No Internet Connection Message
                showAlertMessage(view.center , msg: network_status_msg , timer: false)
            }
        }
    }
    
    @objc func removeSuggestionFromList(_ sender:UIButton){
        
        let suggestionIndex = sender.tag - 130
        if suggestionIndex < userSuggestions.count && userSuggestions[suggestionIndex] != nil {
            let memberInfo = userSuggestions[suggestionIndex] as! NSDictionary
            let subjectId = memberInfo["user_id"] as! Int
            
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
                self.view.isUserInteractionEnabled = false
                let url = "suggestions/remove"
                
                // Send Server Request to Explore Blog Contents with Blog_ID
                post(["user_id":String(subjectId)], url: url, method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            userSuggestions.remove(at: suggestionIndex)
                            self.membersTableView.reloadData()
                            
                        }
                        self.view.isUserInteractionEnabled = true
                    })
                }
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

