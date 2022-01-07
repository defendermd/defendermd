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
//  AdvancedGroupSearchViewController.swift
//  seiosnativeapp
//

import UIKit
import Foundation
import NVActivityIndicatorView


class AdvancedGroupSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var searchBar = UISearchBar()
    var advGroupTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var advGroupResponse = [AnyObject]()
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
        
        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Groups",  comment: ""))
        searchBar.delegate = self
        searchBar.setTextColor(textColorPrime)
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvancedGroupSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(AdvancedGroupSearchViewController.filter))
        
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        filter.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = filter
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        // Initialize Page Table
        advGroupTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING , width: view.bounds.width, height: view.bounds.height-(tabBarHeight + TOPPADING)), style: .grouped)
        
        advGroupTableView.register(GroupTableViewCell.self, forCellReuseIdentifier: "CellThree1")
        advGroupTableView.rowHeight = 253.0
        advGroupTableView.dataSource = self
        advGroupTableView.delegate = self
        advGroupTableView.isOpaque = false
        advGroupTableView.backgroundColor = bgColor
        advGroupTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            advGroupTableView.estimatedRowHeight = 0
            advGroupTableView.estimatedSectionHeaderHeight = 0
            advGroupTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(advGroupTableView)
        advGroupTableView.isHidden = true
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        advGroupTableView.tableFooterView = footerView
        advGroupTableView.tableFooterView?.isHidden = true
        
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
        setNavigationImage(controller: self)
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
                self.advGroupResponse.removeAll(keepingCapacity: false)
                
                if updateAfterAlert == true || searchDic.count > 0 {
                    removeAlert()
                    self.advGroupTableView.reloadData()
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
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                    //activityIndicatorView.center = view.center
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
            path = "advancedgroups/browse"
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
                        self.advGroupTableView.isHidden = false
                    }
                    
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.advGroupResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let page = response["response"] as? NSArray {
                                    self.advGroupResponse = self.advGroupResponse + (page as [AnyObject])
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                            
                        }
                        
                        self.isPageRefresing = false
                        //Reload Page Tabel
                        self.advGroupTableView.reloadData()
                        if self.advGroupResponse.count == 0{
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("There are no entries matching your criteria.",  comment: "") , alignment: .center, textColor: textColorLight)
                            self.info.center = self.view.center
                            self.info.layer.cornerRadius = 25.0
                            self.info.layer.masksToBounds = true
                            self.info.backgroundColor = UIColor.black
                            self.info.tag = 1000
                            self.info.isHidden = true
                            self.view.addSubview(self.info)
                            showToast(message:"There are no entries matching your criteria.", controller: self)
                            self.searchBar.resignFirstResponder()
                            
                        }
                    }else{
                        
                        // Handle Server Error
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
    
    // Set Page Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 122{
            return dynamicHeightAutoSearch
        }else{
            return 253.0
        }
        
    }
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else
        {
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return Int(ceil(Float(advGroupResponse.count)/2))
        }
        
        return advGroupResponse.count
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
            if let blogInfo = arrRecentSearchOptions[(indexPath as NSIndexPath).row] as String?
            {
                cell.imgSearch.isHidden = false
                cell.labTitle.frame = CGRect(x: cell.imgSearch.bounds.width + 24, y: 0,width: UIScreen.main.bounds.width - (cell.imgSearch.bounds.width + 24), height: 45)
                // cell.labTitle.center.y = cell.bounds.midY + 5
                cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
                cell.labTitle.text = blogInfo
                cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.labTitle.numberOfLines = 2
                //  cell.labTitle.sizeToFit()
            }
            cell.imgUser.isHidden = true
            return cell
        }
        else{
        let cell = advGroupTableView.dequeueReusableCell(withIdentifier: "CellThree1", for: indexPath) as! GroupTableViewCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = bgColor
        var pageInfo:NSDictionary!
        if(UIDevice.current.userInterfaceIdiom == .pad){
            if(advGroupResponse.count > ((indexPath as NSIndexPath).row)*2 ){
                pageInfo = advGroupResponse[((indexPath as NSIndexPath).row)*2] as! NSDictionary
                cell.contentSelection.tag = ((indexPath as NSIndexPath).row)*2
                cell.menu.tag = ((indexPath as NSIndexPath).row)*2
            }
        }else{
            pageInfo = advGroupResponse[(indexPath as NSIndexPath).row] as! NSDictionary
            cell.contentSelection.tag = (indexPath as NSIndexPath).row
            cell.menu.tag = (indexPath as NSIndexPath).row
        }
        cell.menu.isHidden = true
        
        
        //Select Group Action
        cell.contentSelection.addTarget(self, action: #selector(AdvancedGroupSearchViewController.showGroup(_:)), for: .touchUpInside)
        // Set MenuAction
        
        // Set Group Image
        if let photoId = pageInfo["photo_id"] as? Int{
            
            if photoId != 0{
                
                let url1 = NSURL(string: pageInfo["image"] as! NSString as String)
                cell.contentImage.backgroundColor = placeholderColor
                 cell.contentImage.kf.indicatorType = .activity
                (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.contentImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                
            } else {
                cell.contentImage.image = nil
                cell.contentImage.image = imageWithImage(UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                
            }
        }
        
        
        // Set Group Name
        let name = pageInfo["title"] as? String
        let tempString = name! as NSString
        var value : String
        if tempString.length > 60{
            value = tempString.substring(to: 57)
            value += NSLocalizedString("...",  comment: "")
        }else{
            value = "\(tempString)"
        }
        let owner = pageInfo["like_count"] as? Int
        
        let members = pageInfo["follow_count"] as? Int
        
        
//        let ownerName : String = (pageInfo["owner_title"] as? String)!
        var ownerName : String = ""
            
        if let location = pageInfo["location"] as? String
        {
            ownerName = location
        }
        
        var OwnerTitle : String
        let tempStringOwner = ownerName as NSString
        if tempStringOwner.length > 30{
            OwnerTitle = tempStringOwner.substring(to: 27)
            OwnerTitle += NSLocalizedString("...",  comment: "")
        }else{
            OwnerTitle = "\(tempStringOwner)"
        }
        
        
        let follower = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
        cell.contentName.frame = CGRect(x: 8, y: cell.contentImage.bounds.height - 55, width: (cell.contentImage.bounds.width-20), height: 27)
        cell.contentName.text = " \(value)"
        cell.contentName.font = UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)//UIFont(name: fontName, size: FONTSIZENormal)
        
        
        cell.ownerLabel.frame =  CGRect(x: 11, y: cell.contentImage.bounds.height - 30, width: (cell.contentImage.bounds.width-140), height: 20)
        cell.ownerLabel.text = "Created by \(OwnerTitle)"
        if ownerName != ""{
            cell.ownerLabel.text = "\(locationIcon) \(OwnerTitle)"
        }
        cell.ownerLabel.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZENormal)
        
        
        let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
        cell.totalMembers.frame = CGRect(x: (cell.contentImage.bounds.width-140), y: cell.contentImage.bounds.height - 30, width: 130, height: 20)
        cell.totalMembers.text = "\(likeCount)  \(follower)"
        cell.totalMembers.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZESmall)
        cell.totalMembers.textAlignment = NSTextAlignment.right
        cell.totalMembers.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.totalMembers.layer.shadowOpacity = 0.0
        
        
        // Set Menu
        
        // RHS
        if(UIDevice.current.userInterfaceIdiom == .pad){
            
            var pageInfo2:NSDictionary!
            if(advGroupResponse.count > (((indexPath as NSIndexPath).row)*2+1) ){
                pageInfo2 = advGroupResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
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
            cell.contentSelection2.addTarget(self, action: #selector(AdvancedGroupSearchViewController.showGroup(_:)), for: .touchUpInside)
            // Set MenuAction
            cell.menu2.addTarget(self, action:Selector(("groupMenu:")) , for: .touchUpInside)
            cell.menu2.isHidden = true
            // Set Group Image
            
            
            if let photoId = pageInfo2["photo_id"] as? Int{
                
                if photoId != 0{
                    
                    let url1 = NSURL(string: pageInfo2["image"] as! NSString as String)
                    cell.contentImage2.backgroundColor = placeholderColor
                     cell.contentImage2.kf.indicatorType = .activity
                    (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImage2.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                    
                } else {
                    cell.contentImage2.image = nil
                    cell.contentImage2.image = imageWithImage(UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                    
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
            
            let owner = pageInfo2["like_count"] as? Int
            
            let members = pageInfo2["follow_count"] as? Int
            
//            let ownerName : String = (pageInfo2["owner_title"] as? String)!
            var ownerName : String = ""
            
            if let location = pageInfo2["location"] as? String
            {
                ownerName = location
            }
            
            var OwnerTitle : String
            let tempStringOwner = ownerName as NSString
            if tempStringOwner.length > 30{
                OwnerTitle = tempStringOwner.substring(to: 27)
                OwnerTitle += NSLocalizedString("...",  comment: "")
            }else{
                OwnerTitle = "\(tempStringOwner)"
            }
            
            
            
            cell.contentName2.frame = CGRect(x: 8, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 22)
            cell.contentName2.text = " \(value2)"
            cell.contentName2.font = UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)//UIFont(name: fontName, size: FONTSIZENormal)
            
            cell.ownerLabel2.frame =  CGRect(x: 11, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage2.bounds.width-140), height: 20)
            if ownerName != ""{
                cell.ownerLabel2.text = "\(locationIcon) \(OwnerTitle)"
            }
            cell.ownerLabel2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZENormal)
            
            let member = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
            
            
            let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
            cell.totalMembers2.frame = CGRect(x: (cell.contentImage2.bounds.width-112), y: cell.contentImage2.bounds.height - 30, width: 100, height: 20)
            cell.totalMembers2.text = "\(likeCount)  \(member)"
            cell.totalMembers2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)//UIFont(name: fontName, size: FONTSIZESmall)
            cell.totalMembers2.textAlignment = NSTextAlignment.right
            
            
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
                self.advGroupTableView.isHidden = true
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
//                if advGroupTableView.contentOffset.y >= advGroupTableView.contentSize.height - advGroupTableView.bounds.size.height{
                    if (limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            advGroupTableView.tableFooterView?.isHidden = false
                            browseEntries()
                        }
                    }
                    else
                    {
                        advGroupTableView.tableFooterView?.isHidden = true
                }
                    
              //  }
                
            }
            
        }
        }
    }
    
    @objc func showGroup(_ sender:UIButton){
        
        var groupInfo:NSDictionary!
        groupInfo = advGroupResponse[sender.tag] as! NSDictionary
        
        if(groupInfo["allow_to_view"] as! Int == 1){
            if let name = groupInfo["title"] as? String
            {
                updateAutoSearchArray(str: name)
            }
            let presentedVC = AdvancedGroupDetailViewController()
            presentedVC.subjectId = "\(groupInfo["group_id"]!)"
            presentedVC.subjectType = "sitegroup_group"
            navigationController?.pushViewController(presentedVC, animated: true)
        }else{
            showToast(message:NSLocalizedString("You do not have permission to view this private group.", comment: ""), controller: self)
            
        }
    }
    
    @objc func cancel(){
        advgroupUpdate = false
        
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
                self.advGroupTableView.isHidden = true
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
        if categ_id != nil{
            searchDic["category"] = "\(categ_id)"
        }
        filterSearchString = searchBar.text!
        pageNumber = 1
        showSpinner = true
      //  searchBar.resignFirstResponder()
        browseEntries()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    
    @objc func filter(){
        if filterSearchFormArray.count > 0 {
            let presentedVC = FilterSearchViewController()
            presentedVC.serachFor = "sitegroup"
            presentedVC.stringFilter = searchBar.text!
            presentedVC.contentType = "sitegroup"
            
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "advancedgroups/search-form"
            presentedVC.serachFor = "sitegroup"
            presentedVC.contentType = "sitegroup"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
        advGroupTableView.tableFooterView?.isHidden = true
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.navigationBar.isTranslucent = true
        
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
