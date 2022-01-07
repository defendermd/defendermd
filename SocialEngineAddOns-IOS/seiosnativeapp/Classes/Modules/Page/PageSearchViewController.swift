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
//  PageSearchViewController.swift
//  seiosnativeapp
//

import UIKit
import Foundation
import NVActivityIndicatorView

class PageSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var searchBar = UISearchBar()
    var pageTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var pageResponse = [AnyObject]()
    var updateScrollFlag = false
    var refresher:UIRefreshControl!             // Pull to refrresh
    var isPageRefresing = false                 // For Pagination
    var info:UILabel!
    var search : String!
    //    var imageCache = [String:UIImage]()
    //    var imageCache2 = [String:UIImage]()
    var categ_id : Int!
    var leftBarButtonItem : UIBarButtonItem!
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    
    override func viewDidLoad() {
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        super.viewDidLoad()
        
        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Pages",  comment: ""))
        searchBar.delegate = self
        searchBar.setTextColor(textColorPrime)
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(PageSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(PageSearchViewController.filter))
        
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        filter.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = filter
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        // Initialize Page Table
        pageTableView = UITableView(frame: CGRect(x: 0, y: 0 , width: view.bounds.width, height: view.bounds.height-(tabBarHeight + TOPPADING)), style: .grouped)
        
        pageTableView.register(GroupTableViewCell.self, forCellReuseIdentifier: "CellThree1")
        pageTableView.rowHeight = 253.0
        pageTableView.dataSource = self
        pageTableView.delegate = self
        pageTableView.isOpaque = false
        pageTableView.backgroundColor = bgColor
        pageTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            pageTableView.estimatedRowHeight = 0
            pageTableView.estimatedSectionHeaderHeight = 0
            pageTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(pageTableView)
        pageTableView.isHidden = true
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        pageTableView.tableFooterView = footerView
        pageTableView.tableFooterView?.isHidden = true
        
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
            tblAutoSearchSuggestions.isHidden = false
        }
        else
        {
            tblAutoSearchSuggestions.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = textColorPrime
        if searchDic.count > 0 {
            if globFilterValue != ""{
                searchBar.text = globFilterValue
                // searchBar.endEditing(true)
                
            }
            searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
        }
    }
    
    // Check for Page Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        if searchDic.count > 0 {
            if globFilterValue != ""{
                searchBar.text = globFilterValue
                searchBar.endEditing(false)
            }
            showSpinner = true
            pageNumber = 1
            self.browseEntries()
        }
    }
    
    // Update Page
    func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            for ob in view.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            if (self.pageNumber == 1){
                self.pageResponse.removeAll(keepingCapacity: false)
                
                if updateAfterAlert == true || searchDic.count > 0 {
                    removeAlert()
                    self.pageTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
                //    spinner.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    //  activityIndicatorView.center = view.center
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                    updateScrollFlag = false
                }
                //                spinner.hidesWhenStopped = true
                //                spinner.style = UIstyle.gray
                //                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                //     activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            // Set Parameters for Browse/MyPage
            path = "sitepages/browse"
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)" ]
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Page Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    // self.tblAutoSearchSuggestions.isHidden = true
                    if self.tblAutoSearchSuggestions.isHidden == true
                    {
                        self.pageTableView.isHidden = false
                    }
                    
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.pageResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let page = response["response"] as? NSArray {
                                    self.pageResponse = self.pageResponse + (page as [AnyObject])
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                            
                        }
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        self.isPageRefresing = false
                        //Reload Page Tabel
                        self.pageTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.pageResponse.count == 0{
                            //self.info.isHidden = false
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("There are no entries matching your criteria.",  comment: "") , alignment: .center, textColor: textColorLight)
                            self.info.center = self.view.center
                            self.info.layer.cornerRadius = 25.0
                            self.info.layer.masksToBounds = true
                            self.info.backgroundColor = UIColor.black
                            self.info.tag = 1000
                            self.info.isHidden = true
                            self.view.addSubview(self.info)
                            self.view.makeToast("There are no entries matching your criteria.", duration: 5, position: "bottom")
                            self.searchBar.resignFirstResponder()
                            
                        }
                    }else{
                        
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            self.searchBar.resignFirstResponder()
                        }
                        
                    }
                    
                })
            }
        }else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
            searchBar.resignFirstResponder()
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
    
    // Set Page Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Page Tabel Header Height
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 122{
            return dynamicHeightAutoSearch
        }else{
            return 253.0
        }
    }
    
    // Set Page Section
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else
        {
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return Int(ceil(Float(pageResponse.count)/2))
            }
            
            return pageResponse.count
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
        else{
            let cell = pageTableView.dequeueReusableCell(withIdentifier: "CellThree1", for: indexPath) as! GroupTableViewCell
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = bgColor
            
            // cell.contentSelection.frame.height = CGRectGetHeight(cell.contentImage.bounds) - 75
            
            var groupInfo:NSDictionary!
            
            if(UIDevice.current.userInterfaceIdiom == .pad){
                if(pageResponse.count > ((indexPath as NSIndexPath).row)*2 ){
                    groupInfo = pageResponse[((indexPath as NSIndexPath).row)*2] as! NSDictionary
                    cell.contentSelection.tag = ((indexPath as NSIndexPath).row)*2
                    cell.menu.tag = ((indexPath as NSIndexPath).row)*2
                }
            }else{
                groupInfo = pageResponse[(indexPath as NSIndexPath).row] as! NSDictionary
                cell.contentSelection.tag = (indexPath as NSIndexPath).row
                cell.menu.tag = (indexPath as NSIndexPath).row
            }
            
            cell.menu.isHidden = true
            
            
            //Select Group Action
            cell.contentSelection.addTarget(self, action: #selector(PageSearchViewController.showGroup(_:)), for: .touchUpInside)
            // Set MenuAction
            //print(groupInfo)
            
            // Set Group Image
            if let photoId = groupInfo["photo_id"] as? Int{
                if photoId != 0{
                    cell.contentImage.image = nil
                    cell.contentImage.backgroundColor = placeholderColor
                    if let url1 = URL(string: groupInfo["image"] as! NSString as String){
                        cell.contentImage.kf.indicatorType = .activity
                        (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        })
                    }
                    
                }
                else{
                    cell.contentImage.image = nil
                    cell.contentImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                }
            }
            
            // Set Group Name
            let name = groupInfo["title"] as? String
            let tempString = name! as NSString
            var value : String
            
            if tempString.length > 30{
                value = tempString.substring(to: 27)
                value += NSLocalizedString("...",  comment: "")
            }else{
                value = "\(tempString)"
            }
            
            let owner = groupInfo["like_count"] as? Int
            let members = groupInfo["follow_count"] as? Int
            let fontIcon1 = "\u{f007}"
            
            let a = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
            cell.contentName.frame = CGRect(x: 8, y: cell.contentImage.bounds.height - 55, width: (cell.contentImage.bounds.width-20), height: 20)
            cell.contentName.text = " \(value)"
            cell.contentName.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            
            let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
            cell.totalMembers.frame = CGRect(x: 10, y: cell.contentImage.bounds.height - 30, width: (cell.contentImage.bounds.width-100), height: 20)
            cell.totalMembers.text = "\(likeIcon) \(likeCount) "
            cell.totalMembers.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
            cell.totalMembers.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.totalMembers.layer.shadowOpacity = 0.0
            
            cell.eventTime.frame = CGRect(x: cell.contentImage.bounds.width - 100, y: cell.contentImage.bounds.height - 30, width: 100, height: 20)
            cell.eventTime.text = "\(fontIcon1)  \(a)"
            cell.eventTime.textAlignment = NSTextAlignment.left
            cell.eventTime.textColor = textColorLight
            cell.eventTime.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
            
            // Set Menu
            
            // RHS
            if(UIDevice.current.userInterfaceIdiom == .pad){
                
                var pageInfo2:NSDictionary!
                if(pageResponse.count > (((indexPath as NSIndexPath).row)*2+1) ){
                    pageInfo2 = pageResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
                    cell.cellView2.isHidden = false
                    cell.contentSelection2.isHidden = false
                    cell.contentSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
                    cell.menu2.tag = (((indexPath as NSIndexPath).row)*2+1)
                }else{
                    cell.cellView2.isHidden = true
                    cell.contentSelection2.isHidden = true
                    return cell
                }
                
                
                // Select Group Action
                cell.contentSelection2.addTarget(self, action: #selector(PageSearchViewController.showGroup(_:)), for: .touchUpInside)
                // Set MenuAction
                cell.menu2.addTarget(self, action:Selector(("groupMenu:")) , for: .touchUpInside)
                cell.menu2.isHidden = true
                // Set Group Image
                
                
                if let photoId = pageInfo2["photo_id"] as? Int{
                    
                    if photoId != 0{
                        cell.contentImage2.image = nil
                        cell.contentImage2.backgroundColor = placeholderColor
                        
                        if let url = URL(string: pageInfo2["image"] as! NSString as String){
                            
                            cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                        }
                        
                        
                    }else{
                        cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                        
                    }
                }
                
                // Set Group Name
                let name = pageInfo2["title"] as? String
                
                let tempString2 = "\(name!)" as NSString
                
                var value2 : String
                
                if tempString2.length > 30{
                    value2 = tempString2.substring(to: 27)
                    value2 += NSLocalizedString("...",  comment: "")
                }else{
                    value2 = "\(tempString2)"
                }
                
                let owner = pageInfo2["owner_title"] as? String
                let text = String(format: NSLocalizedString("led by %@", comment:""),owner!)
                
                let members = pageInfo2["member_count"] as? Int
                let fontIcon1 = "\u{f007}"
                
                _ = singlePluralCheck( NSLocalizedString(" member", comment: ""),  plural: NSLocalizedString(" members", comment: ""), count: members!)
                cell.contentName2.frame = CGRect(x: 8, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 20)
                cell.contentName2.text = " \(value2)"
                cell.contentName2.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                
                cell.totalMembers2.frame = CGRect(x: 10, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage.bounds.width-20), height: 20)
                cell.totalMembers2.text = "\u{f19d} \(text)"
                cell.totalMembers2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                
                
                let member = singlePluralCheck( NSLocalizedString(" member", comment: ""),  plural: NSLocalizedString(" members", comment: ""), count: members!)
                // CGRect(x:CGRectGetWidth(cell.contentImage.bounds) - 100, CGRectGetHeight(cell.contentImage.bounds) - 40, 100, 20)
                cell.eventTime2.frame = CGRect(x: cell.contentImage2.bounds.width - 100, y: cell.contentImage2.bounds.height - 30, width: 100, height: 20)
                cell.eventTime2.text = "\(fontIcon1)  \(member)"
                cell.eventTime2.textAlignment = NSTextAlignment.left
                cell.eventTime2.textColor = textColorLight
                cell.eventTime2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                
            }
            
            return cell
        }
    }
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
                self.pageTableView.isHidden = true
                //self.converstationTableView.isHidden = true
                
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
        else
        {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    // MARK:  UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        if tblAutoSearchSuggestions.isHidden == true
        {
            let currentOffset = scrollView.contentOffset.y
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
            
            if maximumOffset - currentOffset <= 10
            {
                if updateScrollFlag{
                    // Check for Page Number for Browse Page
                    //                if pageTableView.contentOffset.y >= pageTableView.contentSize.height - pageTableView.bounds.size.height{
                    if (limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            pageTableView.tableFooterView?.isHidden = false
                            browseEntries()
                        }
                    }
                    else
                    {
                        pageTableView.tableFooterView?.isHidden = true
                    }
                    
                    //  }
                    
                }
                
            }
        }
    }
    
    @objc func showGroup(_ sender:UIButton){
        
        var groupInfo:NSDictionary!
        groupInfo = pageResponse[sender.tag] as! NSDictionary
        
        if(groupInfo["allow_to_view"] as! Int == 1){
            if let videoTitle = groupInfo["title"] as? String {
                updateAutoSearchArray(str: videoTitle)
            }
            let presentedVC = PageDetailViewController()//GroupDetailViewController()
            presentedVC.subjectId = "\(groupInfo["page_id"]!)"
            presentedVC.isComingFromPage = true
            presentedVC.subjectType = "sitepage_page"
            if let title = groupInfo["title"] as? String {
                presentedVC.pageTitle = title
            }
            if let owner = groupInfo["owner_title"] as? String {
                presentedVC.ownerTitle = owner
            }
            if let categ = groupInfo["category_title"] as? String {
                presentedVC.categoryTitle = categ
            }
            if let like = groupInfo["like_count"] as? Int {
                presentedVC.likes = like
            }
            if let desc = groupInfo["body"] as? String {
                presentedVC.descriptionString = desc
            }
            if let location = groupInfo["location"] as? String {
                presentedVC.locationInfo = location
            }
            if let url = groupInfo["cover_image"] as? String {
                presentedVC.coverImageUrl1 = url
            }
            if let url = groupInfo["image_profile"] as? String {
                presentedVC.pageProfileUrl = url
            }
            navigationController?.pushViewController(presentedVC, animated: true)
        }else{
            self.view.makeToast(NSLocalizedString("You do not have permission to view this private page.", comment: ""), duration: 5, position: "bottom")
            
        }
    }
    
    @objc func cancel(){
        pageUpdate = false
        
        _ = self.navigationController?.popViewController(animated: false)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
        if categ_id != nil{
            searchDic["category"] = "\(categ_id)"
        }
        filterSearchString = searchBar.text!
        pageNumber = 1
        showSpinner = true
        searchBar.resignFirstResponder()
        browseEntries()
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
                tblAutoSearchSuggestions.isHidden = false
                self.pageTableView.isHidden = true
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
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
        showSpinner = true
        pageNumber = 1
        //  searchBar.resignFirstResponder()
        browseEntries()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    
    @objc func filter(){
        if filterSearchFormArray.count > 0 {
            let presentedVC = FilterSearchViewController()
            presentedVC.serachFor = "Pages"
            presentedVC.stringFilter = searchBar.text!
            presentedVC.contentType = "Page"
            
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "sitepages/search-form"
            presentedVC.serachFor = "Pages"
            presentedVC.contentType = "Page"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.navigationBar.isTranslucent = true
        pageTableView.tableFooterView?.isHidden = true
        if (self.isMovingFromParent){
            if fromGlobSearch{
                conditionalForm = ""
                loadFilter("search")
                globSearchString = searchBar.text!
                backToGlobalSearch(self)
            }
        }
    }
}
