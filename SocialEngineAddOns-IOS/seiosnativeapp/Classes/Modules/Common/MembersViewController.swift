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
//
//

import UIKit
import NVActivityIndicatorView

var membersUpdate:Bool!

class MembersViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate {
    
    let mainView = UIView()
    // Variables for Likes
    var allMembers = [AnyObject]()
    var membersTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    //  var activityFeedLikes:Bool!
    var isPageRefresing = false
    var dynamicHeight:CGFloat = 70              // Dynamic Height fort for Cell
    var contentType:String!
    var contentId:Int!
    var memberCount : Int!
    var commentsLike:Int!
    var showSpinner = true 
    var action_idd : String!
    // Reactions
    var reactions = [AnyObject]()
    var imagesReactions = [AnyObject]()
    var reactionsInfo : UIView!
    var selectedReaction : String = "all"
    var emojiMenu = [AnyObject]()
    var emojiCount = [AnyObject]()
    var productBrowseType : Int!
    let scrollView = UIScrollView()
    var pageOption:UIButton!
    var textReaction : UILabel!
    var callOne : Bool = false
    var leftBarButtonItem : UIBarButtonItem!
    var fromPhotoViewer = false
    var urlstring : String = ""
    
    // Initialize MembersViewController Class
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        membersUpdate = true
        searchDic.removeAll(keepingCapacity: false)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MembersViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        setNavigationImage(controller: self)
        
        membersTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height-TOPPADING ), style: .grouped)
        membersTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        membersTableView.rowHeight = 70
        membersTableView.dataSource = self
        membersTableView.delegate = self
        membersTableView.bounces = false
        membersTableView.backgroundColor = tableViewBgColor
        membersTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            membersTableView.estimatedSectionHeaderHeight = 0
            
        }
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        membersTableView.tableFooterView = footerView
        membersTableView.tableFooterView?.isHidden = true
        
        // Set Title for navigation Bar
        if(self.contentType == "user"){
            self.title = NSLocalizedString("Friends", comment: "")
            findAllMembers()
        }else{
            if ReactionPlugin == true  {
                self.title = NSLocalizedString("People who reacted on this", comment: "")
            }
            else{
                self.title = NSLocalizedString("People who like this", comment: "")
            }
            findAllMembers()
        }
        
        view.addSubview(membersTableView)
        self.automaticallyAdjustsScrollViewInsets = false;
   
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        membersTableView.tableFooterView?.isHidden = true
        filterSearchFormArray.removeAll(keepingCapacity: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        removeNavigationViews(controller: self)
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
    func filterSerach(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
//            searchBar.text = ""
//            searchBar.resignFirstResponder()
            searchDic.removeAll(keepingCapacity: false)
            membersUpdate = false
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "members/browse-search-form"
            presentedVC.serachFor = "members"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: true)
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
        var memberInfo:NSDictionary
        if (sender.tag > -1){
            memberInfo = allMembers[sender.tag] as! NSDictionary
            if let menuItem = memberInfo["menus"] as? NSDictionary{
                
                updateMembers(menuItem["urlParams"] as! NSDictionary, url: menuItem["url"] as! String)
            }
        }
        
    }
    
    func updateMembers(_ parameter: NSDictionary , url : String){
        
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
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        self.allMembers.removeAll(keepingCapacity: false)
                        self.findAllMembers()
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
    
    // Who Reacted Scroll View
    func createScrollPageMenu(){
        
        scrollView.frame = CGRect(x: 0, y: TOPPADING+10, width: view.bounds.width, height: 30)
        scrollView.delegate = self
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        var origin_x:CGFloat = 0
        
        for (_, element) in reactions.enumerated() {
            if let reaction = element["reaction"] as? String{
                emojiMenu.append(reaction as AnyObject)
            }
            if let reactionCount = element["reaction_count"] as? Int{
                emojiCount.append(reactionCount as AnyObject)
            }
            
            if let reactionIcon = element["reaction_icon"] as? NSDictionary{
                if let icon = reactionIcon[ "reaction_image_icon"] as? String{
                    imagesReactions.append(icon as AnyObject)
                }
            }
            
        }
        
        
        for i in 0 ..< reactions.count
        {
            menuWidth = 60
            if emojiMenu[i] as! String == selectedReaction
            {
                pageOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: 30), title: NSLocalizedString("", comment: ""), border: false, selected: true)
            }else{
                
                pageOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth , height: 30), title: NSLocalizedString("", comment: ""), border: false, selected: false)
                
            }
            
            pageOption.tag = i
            pageOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            pageOption.addTarget(self, action: #selector(MembersViewController.pageSelectOptions(_:)), for: .touchUpInside)
            pageOption.alpha = 1.0
            scrollView.addSubview(pageOption)
            
            let ImageView = createButton(CGRect(x: pageOption.frame.size.width/2 - 15,y: 0,width: 15,height: 20), title: "", border: false, bgColor: false, textColor: textColorDark)
            if i == 0{
                ImageView.setTitle(NSLocalizedString("All", comment: ""), for: UIControl.State())
                ImageView.titleLabel!.font =  UIFont(name: fontName, size: 13)
            }
            else{
                
                ImageView.imageEdgeInsets =  UIEdgeInsets(top: 2, left: 0, bottom: 3, right: 0)
                let imageUrl = imagesReactions[i] as? String
                let url = URL(string:imageUrl!)
                if url != nil
                {
                    ImageView.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })
                }
                
            }
            ImageView.tag = i
            ImageView.addTarget(self, action: #selector(MembersViewController.pageSelectOptions(_:)), for: .touchUpInside)
            pageOption.addSubview(ImageView)
            
            textReaction = createLabel(CGRect(x: ImageView.frame.size.width + ImageView.frame.origin.x + 5 ,y: 2,width: menuWidth - 20,height: 30), text: "\(emojiCount[(i)])", alignment: .left, textColor: textColorDark)
            textReaction.font = UIFont(name: fontName, size: FONTSIZEMedium)
            textReaction.sizeToFit()
            pageOption.addSubview(textReaction)
            
            origin_x += menuWidth
            
        }
        scrollView.contentSize = CGSize(width:origin_x + 10,height:ScrollframeY)
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.alwaysBounceHorizontal = true
        self.scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true;
        view.addSubview(scrollView)
        
    }
    
    @objc func pageSelectOptions(_ sender: UIButton){
        
        productBrowseType = sender.tag
        pageNumber = 1
        showSpinner = true
        scrollView.isUserInteractionEnabled = false
        selectedReaction = emojiMenu[sender.tag] as! String
        allMembers.removeAll(keepingCapacity: true)
        findAllMembers()
        
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        for ob in scrollView.subviews{
            if ob .isKind(of: UIButton.self){
                if ob.tag >= 0 && ob.tag < reactions.count
                {
                    
                    (ob as! UIButton).setUnSelectedButton()
                    if ob.tag == sender.tag
                    {
                        
                        (ob as! UIButton).setSelectedButton()
                        
                    }
                }
                
            }
        }
        
    }
    
    func findAllMembers(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            if (self.pageNumber == 1) && allMembers.count > 0{
                membersTableView.reloadData()
            }
            // Set Spinner
//            spinner.center = self.view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            if contentType == "members"{
//                mainView.addSubview(spinner)
//            }else{
//                view.addSubview(spinner)
//            }
            if showSpinner
            {
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()

            }
            var url = ""
            var parameter = ["limit":"\(limit)", "page":"\(pageNumber)"]
            switch(contentType){
            case "activityFeed":
                if  likeCommentContentType == "activity_action"{
                    if ReactionPlugin == true {
                        url = "reactions/reactions"
                        if selectedReaction != "" && selectedReaction != "all"{
                            parameter.merge(["reaction": "\(selectedReaction)"])
                        }
                    }
                    else{
                        url = "advancedactivity/feeds/likes-comments"
                    }
                }
                else{
                    if ReactionPlugin == true {
                        url = "reactions/reactions"
                        if selectedReaction != "" && selectedReaction != "all"{
                            parameter.merge(["reaction": "\(selectedReaction)"])
                        }
                    }
                    else{
                    url = "likes-comments"
                    }
                   
                }
                if action_idd != nil{
                    parameter.merge(["action_id": String(action_idd)])
                }
                if commentsLike != nil{
                    if ReactionPlugin == true{
                         parameter.merge(["subject_type": likeCommentContentType, "subject_id":String(commentsLike), "viewAllLikes":"1"])
                    }
                    else{
                    parameter.merge(["subject_type": likeCommentContentType, "subject_id":String(commentsLike), "viewAllLikes":"1"])
                    }
                }
                else{
                    if ReactionPlugin == true{
                         parameter.merge(["subject_id":String(likeCommentContent_id), "subject_type": likeCommentContentType, "viewAllLikes":"1"])
                    }
                    else{
                    parameter.merge(["content_id":String(likeCommentContent_id), "content_type": likeCommentContentType, "viewAllLikes":"1"])
                    }
                    
                }
            case "comments":
                if action_idd != nil{
                    url = "advancedactivity/feeds/likes-comments"
                    parameter.merge(["action_id": String(action_idd)])
                    if commentsLike != nil{
                        parameter.merge(["comment_id":String(commentsLike), "viewAllLikes":"1"])
                        
                    }
                }
                else
                {
                    url = "likes-comments"
                    parameter.merge(["subject_id":String(likeCommentContent_id), "subject_type": likeCommentContentType, "viewAllLikes":"1","comment_id":String(commentsLike)])
                }


            case "user":
                parameter.merge(["user_id":"\(contentId)"])
                url = "user/get-friend-list"
            case "members":
                url = "members"
            
            case "AdvVideo":
                url = urlstring
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
                    self.showSpinner = false
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                
                                if (self.contentType == "members") || (self.contentType == "user"){
                                    if let likes = body["response"] as? NSArray{
                                        self.allMembers = self.allMembers + (likes as [AnyObject])
                                    }
                                    
                                    if ((self.contentType == "user") ){
                                        if let likes = body["friends"] as? NSArray{
                                            self.allMembers = self.allMembers + (likes as [AnyObject])
                                        }
                                    }
                                    
                                    if let members = body["totalItemCount"] as? Int{
                                        self.memberCount = members
                                        
                                        if self.contentType == "user"{
                                            self.title = NSLocalizedString("Friends(\(self.memberCount))", comment: "")
                                        }
                                        else{
                                            self.title = NSLocalizedString("Members (\(self.memberCount))", comment: "")
                                        }
                                        self.totalItems = members
                                    }
                                }else{
                                    if let reaction =  body["reactionTabs"] as? NSArray{
                                        self.reactions = reaction as [AnyObject]
                                            if ReactionPlugin == true {
                                                self.createScrollPageMenu()
                                                self.membersTableView.frame =  CGRect(x: 0, y: 40 + TOPPADING, width: self.view.bounds.width, height: self.view.bounds.height-(TOPPADING + 40))
                                            }
                                    }
                                    if let likes = body["viewAllLikesBy"] as? NSArray{
                                        self.allMembers = self.allMembers + (likes as [AnyObject])
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
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
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
        return dynamicHeight
    }
    
    // Set Table Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return allMembers.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        var memberInfo:NSDictionary
        memberInfo = allMembers[(indexPath as NSIndexPath).row] as! NSDictionary
        
        cell.imgUser.frame = CGRect(x: 5, y: 5, width: 60, height: 60)
        
        // Set Name People who Likes Content
        cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 25,width: (UIScreen.main.bounds.width - 75) , height: 100)
        
        cell.labTitle.text = memberInfo["displayname"] as? String
        cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.labTitle.sizeToFit()
        cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
        
        
        // Set Owner Image
        let url = URL(string: memberInfo["image_profile"] as! String)
        
        if url != nil
        {
            cell.imgUser.kf.indicatorType = .activity
            (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.imgUser.kf.setImage(with: url as URL?, placeholder: UIImage(named : "user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        if ReactionPlugin == true && contentType != "comments"{
            let imageUrl = memberInfo["reaction_image_icon"] as! String
            let url = URL(string:imageUrl)
            if url != nil
            {
                cell.btnemoji.isHidden = false
                cell.btnemoji.kf.setImage(with: url as URL?, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in                        
                    })
            }
        }
        
        if let menu = memberInfo["menus"] as? NSDictionary{
            
            let nameString = menu["name"]as! String
            
            if (nameString == "remove_friend"){
                
                let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: unfriendIcon, border: false, bgColor: false, textColor: textColorDark)
                optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
                optionMenu.addTarget(self, action: #selector(MembersViewController.menuAction(_:)), for: .touchUpInside)
                optionMenu.tag = (indexPath as NSIndexPath).row
                cell.accessoryView = optionMenu
                
                
            }else if (nameString == "cancel_request"){
                
                let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: cancelFriendIcon, border: false, bgColor: false, textColor: textColorDark)
                optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
                optionMenu.addTarget(self, action: #selector(MembersViewController.menuAction(_:)), for: .touchUpInside)
                
                optionMenu.tag = (indexPath as NSIndexPath).row
                cell.accessoryView = optionMenu
                
                
            }else if (nameString == "add_friend"){
                
                let optionMenu = createButton(CGRect(x: view.bounds.width - 50, y: 0, width: 50, height: cell.bounds.height), title: friendReuestIcon, border: false, bgColor: false, textColor: textColorDark)
                optionMenu.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
                optionMenu.addTarget(self, action: #selector(MembersViewController.menuAction(_:)), for: .touchUpInside)
                optionMenu.tag = (indexPath as NSIndexPath).row
                cell.accessoryView = optionMenu
                
                
            }
        }
        
        return cell
    }
    
    
    // Handle Classified Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        var memberInfo:NSDictionary
        memberInfo = allMembers[(indexPath as NSIndexPath).row] as! NSDictionary
        
        if let menuItem = memberInfo["menus"] as? NSDictionary{
            
            if let urlParam = menuItem["urlParams"] as? NSDictionary{
                
               
               if let user_id = urlParam["user_id"] as? Int
               {
                    let presentedVC = ContentActivityFeedViewController()
                    presentedVC.subjectType = "user"
                    presentedVC.subjectId = "\(user_id)"
                    searchDic.removeAll(keepingCapacity: false)
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                }
                
            }
            
        } else{
            if let user_id = memberInfo["user_id"] as? Int{
                let presentedVC = ContentActivityFeedViewController()
                presentedVC.subjectType = "user"
                presentedVC.subjectId = "\(user_id)"
                searchDic.removeAll(keepingCapacity: false)
                self.navigationController?.pushViewController(presentedVC, animated: false)
                
            }
        }
        
    }
    
    func searchItem(){
        let presentedVC = MemberSearchViewController()
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        // if updateScrollFlag{
//        // Check for Page Number for Browse Blog
//        if membersTableView.contentOffset.y + 10 >= membersTableView.contentSize.height - membersTableView.bounds.size.height{
//            if (!isPageRefresing  && limit*pageNumber < totalItems){
//                if Reachabable.isConnectedToNetwork() {
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
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if (!isPageRefresing  && limit*pageNumber < totalItems){
                if Reachabable.isConnectedToNetwork() {
                    membersTableView.tableFooterView?.isHidden = false
                    pageNumber += 1
                    isPageRefresing = true
                    findAllMembers()
                }
            }
            else
            {
                membersTableView.tableFooterView?.isHidden = true
            }
            
        }
        
    }
    
    
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: true)
        
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
