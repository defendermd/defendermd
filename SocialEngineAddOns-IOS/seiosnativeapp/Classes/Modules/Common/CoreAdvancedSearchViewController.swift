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
import Foundation
import NVActivityIndicatorView
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
    
}


class CoreAdvancedSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var conversation_id = 1
    var converstationTableView:UITableView!
    var query:String!
    var searchBar = UISearchBar()
    var isPageRefresing = false
    var showSpinner = true
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var conversation = [AnyObject]()            // For response come from Server
    var dynamicHeight:CGFloat = 70              // Dynamic Height fort for Cell
    var refresher:UIRefreshControl!             // Pull to refrresh
    var updateScrollFlag = true                 // Paginatjion Flag
    var conversationTitle : UILabel!
    var msgBodyText : UITextField!
    var sendButton: UIButton!
    var imaged : UIImage!
    var keyboard_height: CGFloat!
    var fromInapp = false
    var textLimit : Int = 50
  //  var imageCache = [String:UIImage]()
    var hashtagSearch : Bool = false
    
    var contentType : String!
    var tblAutoSearchSuggestions : UITableView!
    var searchResultTableView : UITableView!
    var suggestedHashTags = [AnyObject]()
    var dynamicHeight1:CGFloat = 50
    var dynamicHeightAutoSearch:CGFloat = 50
    var leftBarButtonItem : UIBarButtonItem!
    var keyBoardHeight1 :  CGFloat = 0
    override func viewDidLoad() {
        
        super.viewDidLoad()
  
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.delegate = self
        if forumSearchCheck == "ForumSearch"{
            searchBar.setPlaceholderWithColor(NSLocalizedString("Search Forum",  comment: ""))
        }else{
            searchBar.setPlaceholderWithColor(NSLocalizedString("Search",  comment: ""))
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CoreAdvancedSearchViewController.keyboardWasShown),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CoreAdvancedSearchViewController.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
    
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(CoreAdvancedSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        let url : String = "search"
        loadFilter(url)
        
        converstationTableView = UITableView(frame: CGRect(x: 0, y: 0,width: view.bounds.width, height: view.bounds.height - tabBarHeight), style: .grouped)
        converstationTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        
        converstationTableView.dataSource = self
        converstationTableView.delegate = self
        converstationTableView.estimatedRowHeight = 50.0
        converstationTableView.rowHeight = UITableView.automaticDimension
        converstationTableView.backgroundColor = tableViewBgColor
        converstationTableView.separatorColor = TVSeparatorColor
        converstationTableView.tag = 22
        converstationTableView.isHidden = true
        if #available(iOS 11.0, *) {
            converstationTableView.estimatedRowHeight = 0
            converstationTableView.estimatedSectionHeaderHeight = 0
            converstationTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(converstationTableView)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        converstationTableView.tableFooterView = footerView
        converstationTableView.tableFooterView?.isHidden = true
        
        
        let button = createButton(CGRect(x: self.view.bounds.size.width-100,y: 0,width: 30,height: 30), title: fiterIcon, border: false, bgColor: false, textColor: textColorPrime)
        button.backgroundColor = UIColor.clear
        button.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
        button.addTarget(self, action: #selector(CoreAdvancedSearchViewController.filter), for: UIControl.Event.touchUpInside)
        let locButton = UIBarButtonItem()
        locButton.customView = button
        self.navigationItem.setRightBarButtonItems([locButton], animated: true)

        searchResultTableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height-120), style: UITableView.Style.grouped)
        searchResultTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        searchResultTableView.rowHeight = 50
        searchResultTableView.backgroundColor = tableViewBgColor
        searchResultTableView.separatorColor = TVSeparatorColor
        searchResultTableView.tag = 11
        searchResultTableView.isHidden = true
        view.addSubview(searchResultTableView)
        searchResultTableView.keyboardDismissMode = .onDrag
        
        tblAutoSearchSuggestions = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 440), style: UITableView.Style.plain)
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
            tblAutoSearchSuggestions.isHidden = false
        }
        else
        {
            tblAutoSearchSuggestions.isHidden = true
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
   //     searchBar.becomeFirstResponder()
        setNavigationImage(controller: self)
        loadFilter("search")
        if searchDic.count > 0 {
            searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {

        if searchDic.count > 0{
            if globFilterValue != ""{
                searchBar.text = globFilterValue
            }
            searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
            showSpinner = true
            self.browseConversations()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
        converstationTableView.tableFooterView?.isHidden = true
//        searchBar.text = ""
//        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search",  comment: ""))
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.navigationBar.isTranslucent = true
        if (self.isMovingFromParent){
            filterSearchString = ""
            globCoreSearchType = "0"
        }
    }
    @objc func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyBoardHeight1 = keyboardFrame.size.height
        //print(keyBoardHeight1)
        if #available(iOS 9.0, *) {
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                UIView.animate(withDuration: 0.2, animations: {
                    self.converstationTableView.frame.size.height = self.converstationTableView.frame.size.height + tabBarHeight - self.keyBoardHeight1
                    
                })
                
            }
        }
        
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        if #available(iOS 9.0, *) {
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                UIView.animate(withDuration: 0.2, animations: {
                    self.converstationTableView.frame.size.height = self.view.bounds.height - tabBarHeight
                    
                })
                
            }
        }
        
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vw = UIView()
        if tableView.tag == 122{
            let labTitle = createLabel(CGRect( x: 14, y: 0,width: view.bounds.width, height: 40), text: NSLocalizedString("RECENT SEARCHES", comment: ""), alignment: .left, textColor: textColorDark)
            labTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium - 2)
            vw.addSubview(labTitle)
            return vw
        }
        else
        {
            return vw
        }

    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView.tag == 22{
            if (limit*pageNumber < totalItems){
                return 0
                
            }else{
                return 0.00001
            }
        }
        else{
            return 0.00001
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 22{
            return dynamicHeight
        }
        else if tableView.tag == 122{
            return dynamicHeightAutoSearch
        }else{
            return dynamicHeight1
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if tableView.tag == 22{
            return self.conversation.count
        }else if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else{
            return  suggestedHashTags.count
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        if tableView.tag == 22{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            var blogInfo:NSDictionary
            blogInfo = conversation[(indexPath as NSIndexPath).row] as! NSDictionary
            
            cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10,width: (UIScreen.main.bounds.width - cell.imgUser.bounds.width-90) , height: 20)
            let desc = blogInfo["description"] as? String
            let title2 = blogInfo["title"] as? String
            var disname = blogInfo["displayname"] as? String
            let contentType = blogInfo["type"] as? String
            
            if title2 != "" || title2 != nil {
                cell.labTitle.text = title2
            }
            
            if disname == nil && contentType == "User"{
                disname = "Deleted member"
            }
            
            if ( title2 == nil || title2 == "") {
                if (desc == nil || desc == ""){
                    cell.labTitle.text = disname
                }
                else{
                    cell.labTitle.text = desc
                }
                
            }
            
            cell.postCount.frame = CGRect(x:(UIScreen.main.bounds.width - 85), y:10, width:85 , height:15)
            
            
            
            if let module_title = blogInfo["module_title"] as? String{
                cell.postCount.text = module_title
            }
            
            cell.postCount.numberOfLines = 2
            cell.postCount.sizeToFit()
            
            cell.postCount.textColor = UIColor.gray
            cell.postCount.textAlignment = NSTextAlignment.center
            
            
            if let bodyHtml = blogInfo["body"] as? String{
                var tempInfo = ""
                let content = bodyHtml.html2String;
                if content != ""  {
                    
                    if content.length > textLimit{
                        
                        tempInfo = tempInfo + (content as NSString).substring(to: textLimit-3)
                        
                        
                    }else{
                        tempInfo += content
                    }
                }
                
                
                
                if (title2 == nil || title2 == "") && (desc == nil || desc == "") && (disname == nil || disname == ""){
                    cell.labTitle.text = tempInfo
                }
                
            }
            
            
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            cell.labTitle.numberOfLines = 2
            cell.labTitle.sizeToFit()
            cell.imgUser.layer.borderWidth = 0.0
            if (blogInfo["image_profile"] != nil){
                
                if let url = URL(string: blogInfo["image_profile"] as! String){
                    cell.imgUser.kf.indicatorType = .activity
                    (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
            }
            
            return cell
        }
        else if tableView.tag == 122{
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
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            
            
            if let response = suggestedHashTags[(indexPath as NSIndexPath).row] as? NSDictionary {
                cell.labTitle.frame.size.width = (UIScreen.main.bounds.width - (cell.imgUser.bounds.width + 15))
                // Set Name People who Likes Content
                cell.labTitle.text = response["label"] as? String
                cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.labTitle.sizeToFit()
                
                dynamicHeight = cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5
                
                if dynamicHeight < (cell.imgUser.bounds.height + 10){
                    dynamicHeight = (cell.imgUser.bounds.height + 10)
                }
                
                // Set Frnd Image
                // Set Feed Owner Image
                if let imgUrl = response["image_icon"] as? String{
                    let url = URL(string:imgUrl)
                    if url != nil
                    {
                        cell.imgUser.image = nil
                        cell.imgUser.kf.indicatorType = .activity
                        (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.imgUser.kf.setImage(with: url as URL?, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                    }
                    
                }
                
                if let id = response["id"] as? Int{
                    if frndTag[id] != nil{
                        cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                    }else{
                        cell.accessoryType = UITableViewCell.AccessoryType.none
                    }
                }
                
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        if tableView.tag == 22{
            
            tableView.deselectRow(at: indexPath, animated: true)
            var blogInfo:NSDictionary
            
            blogInfo = conversation[(indexPath as NSIndexPath).row] as! NSDictionary
    
            let desc = blogInfo["description"] as? String ?? ""
            let title = blogInfo["title"] as? String ?? ""
            let disname = blogInfo["displayname"] as? String ?? ""
            var strName = ""
            if title.length != 0 {
                strName = title
            }
            else if desc.length != 0
            {
                strName = desc
            }
            else if disname.length != 0 {
                
                if (blogInfo["type"] != nil && blogInfo["type"] as! String == "User" )
                {
                    if blogInfo["user_id"] != nil
                    {
                        strName = disname
                    }
                }
                else
                {
                    strName = disname
                }
                
            }
            else if let bodyHtml = blogInfo["body"] as? String{
                var tempInfo = ""
                let content = bodyHtml.html2String;
                if content != ""  {
                    if content.length > textLimit{
                        tempInfo = tempInfo + (content as NSString).substring(to: textLimit-3)
                        
                        
                    }else{
                        tempInfo += content
                    }
                }
                    strName = tempInfo
                
            }
            if strName.length != 0, let strType = blogInfo["type"] as? String
            {
                if strType != "Sitefaq" && strType != "Sitenews"
                {
                  updateAutoSearchArray(str: strName)
                }
               
            }
            
            if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Blog"){
                BlogObject().redirectToBlogDetailPage(self, blogId: blogInfo["blog_id"] as! Int,title: "")
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Classified"){
                ClassifiedObject().redirectToProfilePage(self, id: blogInfo["classified_id"] as! Int)
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Sitealbum"){
                
                let presentedVC = AlbumProfileViewController()
                presentedVC.albumId = "\(blogInfo["album_id"]!)"
                presentedVC.albumName = ""
                navigationController?.pushViewController(presentedVC, animated: false)
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Album"){
                
                let presentedVC = AlbumProfileViewController()
                presentedVC.albumId = "\(blogInfo["album_id"]!)"
                presentedVC.albumName = ""
                navigationController?.pushViewController(presentedVC, animated: false)
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Group"){
                
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectId = "\(blogInfo["group_id"]!)"
                presentedVC.subjectType = "group"
                navigationController?.pushViewController(presentedVC, animated: false)
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Event"){
                
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectId = "\(blogInfo["event_id"]!)"
                presentedVC.subjectType = "event"
                navigationController?.pushViewController(presentedVC, animated: false)
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Music"){
                
                MusicObject().redirectToPlaylistPage(self,id: blogInfo["playlist_id"] as! Int)
                
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "User" ){
                
                if blogInfo["user_id"] != nil{
                    let presentedVC = ContentActivityFeedViewController()
                    presentedVC.subjectType = "user"
                    presentedVC.subjectId = "\(blogInfo["user_id"]!)"
                    navigationController?.pushViewController(presentedVC, animated: false)
                    
                }
                
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Forum")
            {

                let presentedVC = ForumsViewPageController()
                presentedVC.forumId = "\(blogInfo["forum_id"]!)"
                if blogInfo["title"] != nil {
                presentedVC.forumName = "\(blogInfo["title"]!)"
                }
                if blogInfo["slug"] != nil
                {
                    presentedVC.forumSlug = blogInfo["slug"] as! String
                }else{
                    presentedVC.forumSlug = ""
                }
                navigationController?.pushViewController(presentedVC, animated: false)
                
                
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "forum_topic"){
            
            let presentedVC = ForumTopicViewController()
           // let dic = blogInfo["object"] as? NSDictionary
            let url =  blogInfo["url"] as! String
            let arr = url.components(separatedBy: "/")
            let count = arr.count - 1
            presentedVC.slug = arr[count]
            presentedVC.topicId = blogInfo["topic_id"] as! Int
            presentedVC.topicName = blogInfo["title"] as! String
            navigationController?.pushViewController(presentedVC, animated: true)
        }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Siteevent"){
                let presentedVC = ContentFeedViewController()
                presentedVC.subjectType = "advancedevents"
                if( blogInfo["event_id"] is String ){
                    presentedVC.subjectId =  "\(blogInfo["event_id"]!)"
                }
                else  if( blogInfo["event_id"] is NSNumber ){
                    presentedVC.subjectId = "\(blogInfo["event_id"]!)"
                }
                navigationController?.pushViewController(presentedVC, animated: false)
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Sitereview"){
                
                if (blogInfo["item_type"] != nil && blogInfo["item_type"] as! String == "sitereview_listing"){
                    let listingId = "\(blogInfo["listing_id"]!)"
                    
                    if let listingtype_id = blogInfo["listingtype_id"] as? Int{
                        if listingtype_id != 0{
                            
                            var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingtype_id]!
                            let viewType = tempBrowseViewTypeDic["viewType"]!
                            
                            SiteMltObject().redirectToMltProfilePage(self, subjectType : "sitereview_listing" , listingTypeIdValue : listingtype_id, listingIdValue : listingId, viewTypeValue : viewType)
                            
                        }
                        
                    }
                }
                else if (blogInfo["item_type"] != nil && blogInfo["item_type"] as! String == "sitereview_review"){
                    
                    if let listingtype_id = blogInfo["listingtype_id"] as? Int{
                        let listingTypeId = listingtype_id
                        
                        if listingTypeId != 0{
                            
                            if (blogInfo["resource_id"] as? Int) != nil{
                                if let listingId = blogInfo["resource_id"] as? Int{
                                    let presentedVC = UserReviewViewController()
                                    presentedVC.mytitle = blogInfo["title"] as! String
                                    presentedVC.subjectId = "\(listingId)"
                                    presentedVC.listingTypeId = listingTypeId
                                    presentedVC.contentType = "listings"
                                    navigationController?.pushViewController(presentedVC, animated: false)
                                }
                            }
                            
                        }
                    }
                    
                }
                
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Sitefaq"){
                //TODO: Need to receive correct response from Api.
            }
                
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Sitepage"){
                
                SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id:"\(blogInfo["page_id"]!)")
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Sitegroup"){
                
                SiteAdvGroupObject().redirectToAdvGroupProfilePage(self, subject_type: "sitegroup_group", subject_id: "\(blogInfo["group_id"]!)")
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Sitestoreoffer"){
                let pv = CouponsBrowseViewController()
                pv.showOnlyMyContent = false
                pv.fromStore = false
                pv.isFromSearchPage = true
                pv.resultInfo = blogInfo
                navigationController?.pushViewController(pv, animated: false)
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Sitestoreproduct"){
                SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false, product_id: "\(blogInfo["product_id"]!)")
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Sitestore"){
                SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: "\(blogInfo["store_id"]!)")
            }
            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Video")
            {
                VideoObject().redirectToVideoProfilePage(self, videoId: blogInfo["video_id"] as! Int, videoType: blogInfo["video_type"] as! Int, videoUrl: blogInfo["content_url"] as! String)
            }
//            else if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Sitenews")
//            {
//
//            }
            else
            {
                let presentedVC = ExternalWebViewController()
                
                if (blogInfo["type"] != nil && blogInfo["type"] as! String == "Sitenews"){
                    presentedVC.url = blogInfo["original_link"]! as! String
                }else if blogInfo["content_url"] != nil{
                    presentedVC.url = blogInfo["content_url"]! as! String
                }
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let navigationController = UINavigationController(rootViewController: presentedVC)
                self.present(navigationController, animated: true, completion: nil)
                
            }
            
        }
            
        else if tableView.tag == 122{
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
                self.searchResultTableView.isHidden = true
                self.converstationTableView.isHidden = true
                
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
            var hashTagString : String!
            let singleString : String!
            
            if let response = suggestedHashTags[(indexPath as NSIndexPath).row] as? NSDictionary {
                
                hashTagString = response["label"] as? String
            }
            
            searchDic.removeAll(keepingCapacity: false)
            
            if hashTagString.range(of: "#") != nil{
                let original = hashTagString
                singleString = String(original!.dropFirst())
                
            }
            else{
                singleString = hashTagString
            }
            updateAutoSearchArray(str: hashTagString)
            searchBar.resignFirstResponder()
            searchDic.removeAll(keepingCapacity: false)
            self.searchResultTableView.isHidden = true
            self.converstationTableView.isHidden = false
            
            let presentedVC = HashTagFeedViewController()
            presentedVC.completionHandler = { 
             
                self.searchBar.text = nil
                self.searchBar.becomeFirstResponder()
                self.tblAutoSearchSuggestions.reloadData()
            }
            presentedVC.hashtagString = singleString
            navigationController?.pushViewController(presentedVC, animated: false)
            
        }
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.length > 0 && searchBar.text![searchBar.text!.startIndex] == "#"{
            tblAutoSearchSuggestions.isHidden = true
            self.searchResultTableView.isHidden = false
            self.converstationTableView.isHidden = true
            hashTagSearch(searchBar.text!)
        }
        else
        {
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
                    tblAutoSearchSuggestions.isHidden = false
                    self.searchResultTableView.isHidden = true
                    self.converstationTableView.isHidden = true
                }
                else
                {
                    tblAutoSearchSuggestions.isHidden = true
                }
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
 
    
    func hashTagSearch(_ searchText:String){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = CGPoint(x: view.center.x, y: 140)
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
            activityIndicatorView.startAnimating()
            
            userInteractionOff = false
            // Send Server Request to Share Content
            post(["hashtag":"\(searchText)", "limit": "10"], url: "sitehashtag/browse", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            
                            if let response = succeeded["body"] as? NSArray{
                                self.suggestedHashTags = response as [AnyObject]
                                
                            }
                            
                            self.searchResultTableView.reloadData()
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
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//
//        if updateScrollFlag{
//            // Check for Page Number for Browse Blog
//            if converstationTableView.contentOffset.y >= converstationTableView.contentSize.height - converstationTableView.bounds.size.height{
//                if (!isPageRefresing  && limit*pageNumber < totalItems){
//                    if Reachabable.isConnectedToNetwork() {
//                        updateScrollFlag = false
//                        pageNumber += 1
//                        isPageRefresing = true
//                        browseConversations()
//                    }
//                }
//
//            }
//
//        }
//
//    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {

        if tblAutoSearchSuggestions.isHidden == true
        {
            let currentOffset = scrollView.contentOffset.y
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
            
            if maximumOffset - currentOffset <= 10
            {
                if updateScrollFlag{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            converstationTableView.tableFooterView?.isHidden = false
                            browseConversations()
                        }
                    }
                    else
                    {
                        converstationTableView.tableFooterView?.isHidden = true
                    }
                    
                }
            }
            }
    }
    func browseConversations(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            
            
            if (showSpinner){
                if updateScrollFlag == false {
                    //activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                }
                if (self.pageNumber == 1){
                   // activityIndicatorView.center = view.center
                    updateScrollFlag = false
                }
                activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
            }
            
            let path = "search"
            var parameters = [String:String]()
            
            
            if forumSearchCheck == "ForumSearch"
            {
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "query":"\(self.query)","forumSearch" : "1"]
            }
            else
            {
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "query":"\(self.query)"]
            }
            
            
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            postAutoSearch(parameters, url: path, method: "POST") {
                (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
//                    self.tblAutoSearchSuggestions.isHidden = true
                    
                    if self.pageNumber == 1
                    {
                        self.conversation.removeAll(keepingCapacity: false)
                    }
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.converstationTableView.tableFooterView?.isHidden = true
                    if msg{
                        if succeeded["body"] != nil{
                            if let response1 = succeeded["body"] as? NSDictionary{
                                
                                if let responseResult = response1["result"] as? NSArray{
                                    self.conversation = self.conversation + (responseResult as [AnyObject])
                                   // self.converstationTableView.reloadData()
                                    if self.tblAutoSearchSuggestions.isHidden == true
                                    {
                                      self.converstationTableView.isHidden = false
                                    }
                                }
                                
                                if response1["totalItemCount"] != nil{
                                    self.totalItems = response1["totalItemCount"] as! Int
                                }
                               
                            }
                            if self.conversation.count == 0{
                                showToast(message: NSLocalizedString("You do not have any entries. Get started by writing a new entry.",  comment: ""), controller: self)
                                self.searchBar.resignFirstResponder()
                            }
                            self.converstationTableView.isHidden = false
                            self.isPageRefresing = false
                            self.converstationTableView.reloadData()
                        }
                        
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
             self.converstationTableView.tableFooterView?.isHidden = true
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
             searchBar.resignFirstResponder()
        }
        
    }
    
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
    
    func refresh(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            browseConversations()
            self.converstationTableView.reloadData()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    @objc func filter(){
        
        if filterSearchFormArray.count > 0{
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "coreSearch"
            presentedVC.contentType = "SearchHome"
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            
            presentedVC.searchUrl = "search"
            presentedVC.serachFor = "coreSearch"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    @objc func cancel(){
     //   searchBar.delegate = nil
        searchBar.resignFirstResponder()
        searchBar.text = ""
        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search",  comment: ""))
        openSideMenu = false
        if forumSearchCheck == "ForumSearch"
        {
            forumSearchCheck = ""
            _ = self.navigationController?.popViewController(animated: false)
        }
        else
        {
            if fromInapp
            {
                _ = self.navigationController?.popViewController(animated: false)
                
            }
            else
            {
//                let presentedVC = AdvanceActivityFeedViewController()
//                _ = self.navigationController?.pushViewController(presentedVC, animated: false)
                 _ = self.navigationController?.popViewController(animated: false)
            }
        }
        globCoreSearchType = "0"
        globSearchString = ""
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        tblAutoSearchSuggestions.isHidden = true
        searchDic.removeAll(keepingCapacity: false)
        searchDic["query"] = searchBar.text
        
        if globalTypeSearch != ""{
            searchDic["type"] = globalTypeSearch
            searchDic["type"] = globCoreSearchType
        }
        
        if forumSearchCheck == "ForumSearch"{
            searchDic["type"] = "forum_topic"
        }
        showSpinner = true
        pageNumber = 1
        searchBar.resignFirstResponder()
        let textValue = searchBar.text
        if textValue!.range(of: "#") != nil{
            let original = textValue
            let singleString = String(original!.dropFirst())
            let presentedVC = HashTagFeedViewController()
            presentedVC.hashtagString = singleString
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            browseConversations()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField!) -> Bool {
        self.msgBodyText.resignFirstResponder()
        return true
  
    }
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
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
        
        self.suggestedHashTags.removeAll(keepingCapacity: false)
        self.searchResultTableView.isHidden = true
        self.converstationTableView.isHidden = false
        searchDic.removeAll(keepingCapacity: false)
        searchDic["query"] = searchBar.text
        if globalTypeSearch != ""{
            searchDic["type"] = globalTypeSearch
            searchDic["type"] = globCoreSearchType
        }
        if forumSearchCheck == "ForumSearch"{
            searchDic["type"] = "forum_topic"
        }
        showSpinner = true
        pageNumber = 1
        browseConversations()
    }
    
}
