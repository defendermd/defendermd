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
//  CategoryDetailGridViewController.swift
//  seiosnativeapp
//

import UIKit
import NVActivityIndicatorView

class CategoryDetailGridViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate
{
    var subjectId:Int!
    var subjectType:String!
    var subcatid:Int!
    var subsubcatid:Int!
    var totalItemCount:Int!
    var categoryTitle: String!
    let mainView = UIView()
    var listingTableView:UITableView!
    var refresher:UIRefreshControl!
    var refresher1:UIRefreshControl!
    var refreshButton : UIButton!
    var contentIcon : UILabel!
    var rootCategoryBar: UIButton!
    var childCategoryBar: UIButton!
    
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var updateScrollFlag = true
    var listingsResponse = [AnyObject]()        // For response come from Server
    var subCategoryArr = [AnyObject]()
    var subSubCategoryArr = [AnyObject]()
    var showSpinner = true
    var isPageRefresing = false
    var info:UILabel!
    
    var contentGutterMenu: NSArray = []
    var deleteContent : Bool!
    var contentTitle : String!
    var contentDescription : String!
    
    var shareUrl : String!
    var shareParam : NSDictionary!
    
    var subcategory: String!
    var subsubcategory: String!
    //  var imageCache = [String:UIImage]()
    var listingTypeId :  Int!
    var listingContentName : String!
    var dynamicHeight:CGFloat = 253.0
    var profileCurrencySymbol : String!
    var viewType : Int!
    var contentType = ""
    var pagesResponse = [AnyObject]()
    var pageTableView : UITableView!
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        subcategory = ""
        subsubcategory = ""
        
        view.backgroundColor = bgColor
        mainView.frame = view.frame
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        globFilterValue = ""
        openMenu = false
        updateAfterAlert = true
        listingUpdate = true
        pageUpdate = false
        advgroupUpdate = false
        
        // Set tableview to show listings
        listingTableView = UITableView(frame: CGRect(x: 0, y: 0,width: view.bounds.width, height: view.bounds.height - tabBarHeight - 10), style: .grouped)
        listingTableView.register(MLTGridTableViewCell.self, forCellReuseIdentifier: "MLTGridTypeCell")
        listingTableView.rowHeight = 250
        listingTableView.dataSource = self
        listingTableView.delegate = self
        listingTableView.isOpaque = false
        listingTableView.isHidden = true
        listingTableView.backgroundColor = tableViewBgColor
        listingTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            listingTableView.estimatedSectionHeaderHeight = 0
        }
        mainView.addSubview(listingTableView)
        
        pageTableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width,height: view.bounds.height - tabBarHeight), style: .grouped)
        pageTableView.register(GroupTableViewCell.self, forCellReuseIdentifier: "CellThree")
        pageTableView.rowHeight = 253.0
        pageTableView.dataSource = self
        pageTableView.delegate = self
        pageTableView.isOpaque = false
        pageTableView.isHidden = true
        pageTableView.backgroundColor = bgColor
        pageTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            pageTableView.estimatedSectionHeaderHeight = 0
        }
        mainView.addSubview(pageTableView)
        
        
        
        // Set pull to referseh for listingtableview
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(CategoryDetailGridViewController.refresh), for: UIControl.Event.valueChanged)
        listingTableView.addSubview(refresher)
        
        refresher1 = UIRefreshControl()
        refresher1.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher1.addTarget(self, action: #selector(CategoryDetailGridViewController.refresh), for: UIControl.Event.valueChanged)
        pageTableView.addSubview(refresher1)
        
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        pageNumber = 1
        updateScrollFlag = false
        showSpinner = true
        browseEntries()
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        pageTableView.tableFooterView = footerView
        pageTableView.tableFooterView?.isHidden = true
        
        let footerView2 = UIView(frame: frameActivityIndicator)
        footerView2.backgroundColor = UIColor.clear
        let activityIndicatorView2 = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView2.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView2.addSubview(activityIndicatorView2)
        activityIndicatorView2.startAnimating()
        listingTableView.tableFooterView = footerView2
        listingTableView.tableFooterView?.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        self.title = NSLocalizedString("\(self.title!)",  comment: "")
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(CategoryDetailGridViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        pageTableView.tableFooterView?.isHidden = true
        listingTableView.tableFooterView?.isHidden = true
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
    }
    
    
    // MARK:Back Action
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)
        
    }
    
    // Stop Timer
    @objc func stopTimer()
    {
        stop()
    }
    
    // MARK: - Cover Image Selection
    @objc func showListing(_ sender:UIButton)
    {
        
        var listingInfo:NSDictionary!
        listingInfo = listingsResponse[sender.tag] as! NSDictionary
        
        var viewType : Int = 0
        
        if self.tabBarController?.selectedIndex == 1 || self.tabBarController?.selectedIndex == 2 || self.tabBarController?.selectedIndex == 3{
            if self.tabBarController?.selectedIndex == 1 {
                listingTypeId = globalListingTypeId
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }
                
                
            }
            if self.tabBarController?.selectedIndex == 2 {
                listingTypeId = globalListingTypeId1
                
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType1")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType1") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }
                
            }
            if self.tabBarController?.selectedIndex == 3 {
                listingTypeId = globalListingTypeId2
                
                
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType2")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType2") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }
                
                
            }
        }
        else
        {
            
            var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingInfo["listingtype_id"] as! Int]!
            viewType = tempBrowseViewTypeDic["viewType"]!
        }
        
        if listingInfo["allow_to_view"] != nil && listingInfo["allow_to_view"] as! Int > 0 {
            
            switch viewType{
            case 2:
                
                let presentedVC = MLTClassifiedSimpleTypeViewController()
                presentedVC.listingId = "\(listingInfo["listing_id"] as! Int)"
                presentedVC.listingTypeId = listingTypeId
                presentedVC.subjectType = "sitereview_listing"
                navigationController?.pushViewController(presentedVC, animated: true)
                break
                
            case 3:
                
                let presentedVC = MLTClassifiedAdvancedTypeViewController()
                presentedVC.listingId = "\(listingInfo["listing_id"] as! Int)"
                presentedVC.listingTypeId = listingTypeId
                presentedVC.subjectType = "sitereview_listing"
                navigationController?.pushViewController(presentedVC, animated: true)
                break
                
            default:
                
                let presentedVC = MLTBlogTypeViewController()
                presentedVC.listingId = "\(listingInfo["listing_id"] as! Int)"
                presentedVC.listingTypeId = listingTypeId
                presentedVC.subjectType = "sitereview_listing"
                navigationController?.pushViewController(presentedVC, animated: true)
                break
            }
        }
        else{
            self.view.makeToast( NSLocalizedString("You do not have permission to view this private page.",  comment: ""), duration: 5, position: "bottom")
        }
    }
    
    @objc func showPage(_ sender:UIButton){
        
        var groupInfo:NSDictionary!
        groupInfo = pagesResponse[sender.tag] as! NSDictionary
        
        if self.contentType == "sitegroup"{
            
            SiteAdvGroupObject().redirectToAdvGroupProfilePage(self, subject_type: "sitegroup_group", subject_id: "\(groupInfo["group_id"] as! Int)")
        }
        else {
            
            
            SitePageObject().redirectToPageProfilePage(self, subject_type: "sitepage_page", subject_id: "\(groupInfo["page_id"] as! Int)")
            
        }
    }
    
    
    // MARK: Pull to refresh
    @objc func refresh()
    {
        
        if Reachabable.isConnectedToNetwork()
        {
            searchDic.removeAll(keepingCapacity: false)
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            browseEntries()
        }
        else
        {
            // No Internet Connection Message
            refresher.endRefreshing()
            refresher1.endRefreshing()
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Table Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (limit*pageNumber < totalItems)
        {
            return 0
        }
        else
        {
            return 0.00001
        }
    }
    
    // Set Table Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.00001
    }
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return dynamicHeight
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if self.contentType == "Pages" || self.contentType == "sitegroup"{
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return Int(ceil(Float(pagesResponse.count)/2))
            }
            else
            {
                return pagesResponse.count
            }
            
        }
        else{
            
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                return Int(ceil(Float(listingsResponse.count)/2))
            }
            else
            {
                return listingsResponse.count
            }
            
        }
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if self.contentType == "Pages" || self.contentType == "sitegroup" {
            pageTableView.isHidden = false
            
            let cell = pageTableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath) as! GroupTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = bgColor
            
            
            // cell.contentSelection.frame.height = CGRectGetHeight(cell.contentImage.bounds) - 75
            
            var groupInfo:NSDictionary!
            
            if(UIDevice.current.userInterfaceIdiom == .pad){
                if(pagesResponse.count > ((indexPath as NSIndexPath).row)*2 ){
                    groupInfo = pagesResponse[((indexPath as NSIndexPath).row)*2] as! NSDictionary
                    cell.contentSelection.tag = ((indexPath as NSIndexPath).row)*2
                    cell.menu.tag = ((indexPath as NSIndexPath).row)*2
                }
            }else{
                groupInfo = pagesResponse[(indexPath as NSIndexPath).row] as! NSDictionary
                cell.contentSelection.tag = (indexPath as NSIndexPath).row
                cell.menu.tag = (indexPath as NSIndexPath).row
            }
            
            
            cell.menu.isHidden = true
            //Select Group Action
            cell.contentSelection.addTarget(self, action: #selector(CategoryDetailGridViewController.showPage(_:)), for: .touchUpInside)
            
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
            
            var ownerName : String = ""//(groupInfo["owner_title"] as? String)!
            
            if let location : String = groupInfo["location"] as? String
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
            
            
            
            let a = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
            cell.contentName.frame = CGRect(x: 8, y: cell.contentImage.bounds.height - 55, width: (cell.contentImage.bounds.width-20), height: 20)
            cell.contentName.text = " \(value)"
            cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
            
            if self.contentType == "sitegroup"{
                
                cell.ownerLabel.frame =  CGRect(x: 11, y: cell.contentImage.bounds.height - 30, width: (cell.contentImage.bounds.width-140), height: 20)
                if ownerName != ""{
                    cell.ownerLabel.text = "\(locationIcon) \(OwnerTitle)"
                }
                cell.ownerLabel.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                
                let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                cell.totalMembers.frame = CGRect(x: (cell.contentImage.bounds.width-112), y: cell.contentImage.bounds.height - 30, width: 100, height: 20)
                cell.totalMembers.text = "\(likeCount)  \(a)"
                cell.totalMembers.font = UIFont(name: fontName, size: FONTSIZESmall)
                cell.totalMembers.textAlignment = NSTextAlignment.right
                cell.totalMembers.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.totalMembers.layer.shadowOpacity = 0.0
                
            }
            else {
                
                
                let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                cell.totalMembers.frame = CGRect(x: 12, y: cell.contentImage.bounds.height - 30, width: (cell.contentImage.bounds.width-100), height: 20)
                cell.totalMembers.text = "\(likeCount) "
                cell.totalMembers.font = UIFont(name: "FontAwesome", size: 14)
                cell.totalMembers.layer.shadowOffset = CGSize(width: 0, height: 0)
                cell.totalMembers.layer.shadowOpacity = 0.0
                
                cell.eventTime.frame = CGRect(x: cell.contentImage.bounds.width - 100, y: cell.contentImage.bounds.height - 30, width: 100, height: 20)
                cell.eventTime.text = "\(a)"
                cell.eventTime.textAlignment = NSTextAlignment.center
                cell.eventTime.textColor = textColorLight
                cell.eventTime.font = UIFont(name: "FontAwesome", size: 14)
            }
            
            // Set Menu
            
            // RHS
            if(UIDevice.current.userInterfaceIdiom == .pad){
                
                var pageInfo2:NSDictionary!
                if(pagesResponse.count > (((indexPath as NSIndexPath).row)*2+1) ){
                    pageInfo2 = pagesResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
                    cell.cellView2.isHidden = false
                    cell.contentSelection2.isHidden = false
                    cell.contentSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
                    cell.menu2.tag = (((indexPath as NSIndexPath).row)*2+1)
                }else{
                    cell.cellView2.isHidden = true
                    cell.contentSelection2.isHidden = true
                    return cell
                }
                
                cell.menu2.isHidden = true
                // Select Group Action
                cell.contentSelection2.addTarget(self, action: #selector(CategoryDetailGridViewController.showPage(_:)), for: .touchUpInside)
                // Set MenuAction
                
                
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
                
                //                let ownerName : String = (pageInfo2["owner_title"] as? String)!
                var ownerName : String = ""
                
                if let location : String = pageInfo2["location"] as? String
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
                
                
                var value2 : String
                
                if tempString2.length > 30{
                    value2 = tempString2.substring(to: 27)
                    value2 += NSLocalizedString("...",  comment: "")
                }else{
                    value2 = "\(tempString2)"
                }
                
                let owner = pageInfo2["like_count"] as? Int
                
                let members = pageInfo2["follow_count"] as? Int
                
                
                cell.contentName2.frame = CGRect(x: 8, y: cell.contentImage2.bounds.height - 55, width: (cell.contentImage2.bounds.width-20), height: 20)
                cell.contentName2.text = " \(value2)"
                cell.contentName2.font = UIFont(name: "FontAwesome", size: 18)
                
                let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                let member = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                
                if self.contentType == "sitegroup"{
                    
                    cell.ownerLabel2.frame =  CGRect(x: 11, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage2.bounds.width-140), height: 20)
                    if ownerName != ""{
                        cell.ownerLabel2.text = "\(locationIcon) \(OwnerTitle)"
                    }
                    cell.ownerLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                    
                    let likeCount = singlePluralCheck( NSLocalizedString(" like", comment: ""),  plural: NSLocalizedString(" likes", comment: ""), count: owner!)
                    cell.totalMembers2.frame = CGRect(x: (cell.contentImage2.bounds.width-112), y: cell.contentImage2.bounds.height - 30, width: 100, height: 20)
                    cell.totalMembers2.text = "\(likeCount)  \(member)"
                    cell.totalMembers2.font = UIFont(name: fontName, size: FONTSIZESmall)
                    cell.totalMembers2.textAlignment = NSTextAlignment.right
                    cell.totalMembers2.layer.shadowOffset = CGSize(width: 0, height: 0)
                    cell.totalMembers2.layer.shadowOpacity = 0.0
                    
                }
                else {
                    
                    
                    
                    cell.totalMembers2.frame = CGRect(x: 10, y: cell.contentImage2.bounds.height - 30, width: (cell.contentImage.bounds.width-20), height: 20)
                    cell.totalMembers2.text = " \(likeCount)"
                    cell.totalMembers2.font = UIFont(name: "FontAwesome", size: 14)
                    
                    
                    let member = singlePluralCheck( NSLocalizedString(" follower", comment: ""),  plural: NSLocalizedString(" followers", comment: ""), count: members!)
                    // CGRect(x:CGRectGetWidth(cell.contentImage.bounds) - 100, CGRectGetHeight(cell.contentImage.bounds) - 40, 100, 20)
                    cell.eventTime2.frame = CGRect(x: cell.contentImage2.bounds.width - 100, y: cell.contentImage2.bounds.height - 30, width: 100, height: 20)
                    cell.eventTime2.text = "\(member)"
                    cell.eventTime2.textAlignment = NSTextAlignment.left
                    cell.eventTime2.textColor = textColorLight
                    cell.eventTime2.font = UIFont(name: "FontAwesome", size: 14)
                    
                }
            }
            
            return cell
        }
        else{
            listingTableView.isHidden = false
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MLTGridTypeCell", for: indexPath) as! MLTGridTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            //SET CONTENT IMAGE BOUNDS
            cell.contentImage.frame = CGRect(x: 0, y: 0, width: cell.cellView.bounds.width, height: cell.cellView.bounds.height - cell.cellView.bounds.height/4)
            
            //SET TITLE VIEW BOUNDS
            // TITLE VIEW IS BEING USED TO SHOW THE INFO ABOUT THE CONTENT
            cell.titleView.frame = CGRect(x: 0, y: cell.contentImage.bounds.height, width: cell.cellView.bounds.width, height: cell.cellView.bounds.height/4 - 5)
            cell.titleView.backgroundColor = UIColor.white
            
            // SHOWS THE LINE GAP BETWEEN TWO ITEMS
            cell.lineView.isHidden = false
            
            //Hide price tag
            cell.contentName.isHidden = true
            
            // HIDE THE DATE VIEW
            cell.dateView.isHidden = true
            cell.backgroundColor = tableViewBgColor
            cell.layer.borderColor = UIColor.white.cgColor
            
            var listingInfo:NSDictionary!
            
            if(UIDevice.current.userInterfaceIdiom == .pad){
                if(listingsResponse.count > ((indexPath as NSIndexPath).row)*2 ){
                    listingInfo = listingsResponse[((indexPath as NSIndexPath).row)*2] as! NSDictionary
                    cell.contentSelection.tag = ((indexPath as NSIndexPath).row)*2
                    cell.menu.tag = ((indexPath as NSIndexPath).row)*2
                    
                }
            }else{
                listingInfo = listingsResponse[(indexPath as NSIndexPath).row] as! NSDictionary
                cell.contentSelection.tag = (indexPath as NSIndexPath).row
                cell.menuButton.tag = (indexPath as NSIndexPath).row
            }
            
            
            listingContentName = listingInfo["title"] as! String
            cell.contentSelection.addTarget(self, action: #selector(CategoryDetailGridViewController.showListing(_:)), for: .touchUpInside)
            
            // Set MenuAction
            cell.menuButton.addTarget(self, action:Selector(("showListingMenu:")) , for: .touchUpInside)
            cell.contentSelection.frame.size.height = 180
            
            // Set Content Image
            if let photoId = listingInfo["photo_id"] as? Int{
                if photoId != 0{
                    
                    cell.contentImage.backgroundColor = placeholderColor
                    let url1 = URL(string: listingInfo["image"] as! NSString as String)
                    cell.contentImage.kf.indicatorType = .activity
                    (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImage.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
                else {
                    cell.contentImage.image = nil
                    cell.contentImage.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                    
                }
            }
            
            let name = listingInfo["title"] as? String
            let tempInfo = ""
            cell.titleLabel.frame = CGRect(x: 10, y: 0, width: cell.titleView.bounds.width - 30, height: 30)
            cell.titleLabel.text = "\(name!)"
            cell.titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
            //cell.titleLabel.sizeToFit()
            cell.listingPriceTagLabel.frame = CGRect(x: cell.contentName.frame.origin.x - 5 , y: cell.titleView.frame.origin.y - 30, width: 5, height: 20)
            cell.listingPriceTagLabel.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            cell.listingPriceTagLabel.text = "\(priceTagIcon)"
            cell.listingPriceTagLabel.textColor = textColorDark
            cell.listingPriceTagLabel.isHidden = false
            
            cell.contentName.frame = CGRect(x: cell.titleView.frame.origin.x, y: cell.titleView.frame.origin.y - 30, width: cell.titleView.bounds.width - 10, height: 20)
            cell.contentName.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            cell.contentName.backgroundColor = UIColor.clear
            cell.contentName.textAlignment = NSTextAlignment.right
            
            if listingInfo.object(forKey: "price") != nil && (listingInfo["price"] as! Double > 0 ){
                
                if listingInfo["currency"] != nil{
                    
                    let currencySymbol = getCurrencySymbol(listingInfo["currency"] as! String)
                    profileCurrencySymbol = currencySymbol
                    cell.contentName.text = "\(currencySymbol) \(listingInfo["price"]!)"
                    cell.contentName.isHidden = false
                }
            }
            
            cell.contentName.layer.shadowOpacity = 1
            
            
            cell.menuButton.isHidden = true
            
            
            //SHOWING CONTENT IN TITLE VIEW
            
            //SHOWING LOCATION
            let location = listingInfo["location"] as? String
            
            //IF LOCATION EXISTS
            if location != "" && location != nil{
                
                cell.dateLabel.frame = CGRect(x: 10, y: 25, width: (cell.contentImage.bounds.width-70), height: 20)
                cell.dateLabel.text = "\(tempInfo)"
                cell.dateLabel.textAlignment = NSTextAlignment.left
                cell.dateLabel.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                
                cell.locLabel.isHidden = false
                cell.locLabel.frame = CGRect(x: 10, y: 45, width: (cell.contentImage.bounds.width-70), height: 20)
                cell.locLabel.text = "\(locationIcon) \(location!)"
                cell.locLabel.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                
                cell.listingDetailsLabel.frame = CGRect(x: 10, y: cell.locLabel.frame.origin.y + cell.locLabel.frame.height, width: (cell.contentImage.bounds.width-70), height: 20)
                
                
            }
            
            //IF LOCATION DOES NOT EXISTS
            if location == "" || location == nil{
                
                cell.locLabel.isHidden = true
                cell.dateLabel.frame = CGRect(x: 10, y: 25, width: (cell.contentImage.bounds.width-70), height: 20)
                cell.dateLabel.text = "\(locationIcon)  \(tempInfo)"
                cell.dateLabel.textAlignment = NSTextAlignment.left
                cell.dateLabel.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                cell.listingDetailsLabel.frame = CGRect(x: 10, y: cell.dateLabel.frame.origin.y + cell.dateLabel.frame.height, width: (cell.contentImage.bounds.width-70), height: 20)
            }
            
            //SHOWING OWNERTITLE
            let listingOwnerTitle = listingInfo["owner_title"] as? String
            
            
            //IF OWNER TITLE EXISTS
            if listingOwnerTitle != "" && listingOwnerTitle != nil{
                
                var labMsg = ""
                if let postedDate = listingInfo["creation_date"] as? String{
                    
                    var tempInfo = ""
                    let date = dateDifferenceWithEventTime(postedDate)
                    var DateC = date.components(separatedBy: ", ")
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
                    
                    labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), listingOwnerTitle!, tempInfo)
                    cell.listingDetailsLabel.isHidden = true
                    cell.titleView.frame.size.height = cell.listingDetailsLabel.frame.origin.y + 5
                    
                }
                
                cell.dateLabel.text = labMsg
                
            }
            
            if listingInfo.object(forKey: "closed") != nil && (listingInfo["closed"] as! Int == 1){
                cell.closeIconView.frame = CGRect(x: cell.contentImage.bounds.width/2 - cell.contentImage.bounds.width/6 , y: cell.contentImage.bounds.height/2 - cell.contentImage.bounds.height/6, width: cell.contentImage.bounds.width/3, height: cell.contentImage.bounds.height/3)
                cell.closeIconView.isHidden = false
                cell.closeIconView.text = "\(closedIcon)"
                cell.closeIconView.font = UIFont(name: "FontAwesome", size: cell.contentImage.bounds.width/6)
            }
            else{
                cell.closeIconView.isHidden = true
                
            }
            
            // RHS
            if(UIDevice.current.userInterfaceIdiom == .pad){
                
                cell.dateView2.isHidden = true
                cell.dateView2.frame.size.height = 70
                cell.dateView2.backgroundColor = navColor
                
                cell.titleView2.frame.origin.x = cell.cellView.bounds.width
                cell.titleView2.frame.size.width = cell.cellView.bounds.width
                cell.titleView2.frame.size.height = 70
                cell.titleView2.backgroundColor = UIColor.white
                
                var listingInfo2:NSDictionary!
                if(listingsResponse.count > (((indexPath as NSIndexPath).row)*2+1) ){
                    listingInfo2 = listingsResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
                    cell.cellView2.isHidden = false
                    cell.contentSelection2.isHidden = false
                    cell.dateView2.isHidden = false
                    cell.titleView2.isHidden = false
                    cell.contentSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
                    cell.menuButton2.tag = (((indexPath as NSIndexPath).row)*2+1)
                }else{
                    cell.cellView2.isHidden = true
                    cell.contentSelection2.isHidden = true
                    cell.dateView2.isHidden = true
                    cell.titleView2.isHidden = true
                    return cell
                }
                
                // Select Event Action
                cell.contentSelection2.addTarget(self, action: #selector(CategoryDetailGridViewController.showListing(_:)), for: .touchUpInside)
                
                // Set MenuAction
                cell.menuButton2.addTarget(self, action:Selector(("showListingMenu:")) , for: .touchUpInside)
                
                cell.contentImage2.frame.size.height = 250
                cell.contentSelection2.frame.size.height = 180
                
                // Set Event Image
                if let photoId = listingInfo2["photo_id"] as? Int{
                    
                    if photoId != 0{
                        cell.contentImage2.backgroundColor = placeholderColor
                        cell.contentImage2.image = nil
                        let url = URL(string: listingInfo2["image"] as! NSString as String)
                        
                        if url != nil {
                            cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.contentImage2.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                            
                        }
                        
                    }else{
                        cell.contentImage2.backgroundColor = placeholderColor
                        cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                    }
                }
                
                
                // Set Event Name
                
                let name = listingInfo2["title"] as? String
                
                if let listingDate = listingInfo2["starttime"] as? String{
                    var tempInfo = ""
                    let date = dateDifferenceWithEventTime(listingDate)
                    var DateC = date.components(separatedBy: ", ")
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
                    if DateC.count > 1{
                        cell.dateLabel3.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                        
                        cell.dateLabel3.numberOfLines = 0
                        cell.dateLabel3.text = "\(tempInfo)"
                        cell.dateLabel3.textColor = UIColor.white
                        cell.dateLabel3.font = UIFont(name: "FontAwesome", size: 18)
                    }
                    
                    
                }
                else{
                    cell.dateView2.isHidden = true
                }
                
                cell.titleLabel2.frame = CGRect(x: 10, y: 0, width: (cell.contentImage2.bounds.width-125), height: 30)
                cell.titleLabel2.text = "\(name!)"
                cell.titleLabel2.lineBreakMode = NSLineBreakMode.byWordWrapping
                let location = listingInfo2["location"] as? String
                
                if location != "" && location != nil{
                    
                    cell.dateLabel2.frame = CGRect(x: 10, y: 25, width: (cell.contentImage2.bounds.width-70), height: 20)
                    cell.dateLabel2.text = "\(tempInfo)"
                    cell.dateLabel2.textAlignment = NSTextAlignment.left
                    cell.dateLabel2.font = UIFont(name: "FontAwesome", size: 14)
                    
                    cell.locLabel2.isHidden = false
                    cell.locLabel2.frame = CGRect(x: 10, y: 45, width: (cell.contentImage2.bounds.width-70), height: 20)
                    cell.locLabel2.text = "\(locationIcon) \(location!)"
                    cell.locLabel2.font = UIFont(name: "FontAwesome", size: 14)
                    
                }
                
                if location == "" || location == nil{
                    
                    cell.locLabel2.isHidden = true
                    cell.dateLabel2.frame = CGRect(x: 10, y: 35, width: (cell.contentImage2.bounds.width-70), height: 20)
                    cell.dateLabel2.text = "\(tempInfo)"
                    cell.dateLabel2.textAlignment = NSTextAlignment.left
                    cell.dateLabel2.font = UIFont(name: "FontAwesome", size: 14)
                    
                }
                
                cell.menuButton2.isHidden = false
                let listingOwnerTitle = listingInfo2["owner_title"] as? String
                
                if listingOwnerTitle != "" && listingOwnerTitle != nil{
                    var labMsg = ""
                    
                    if let postedDate = listingInfo2["creation_date"] as? String{
                        var tempInfo = ""
                        let date = dateDifferenceWithEventTime(postedDate)
                        var DateC = date.components(separatedBy: ", ")
                        tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                        if DateC.count > 3{
                            tempInfo += " at \(DateC[3])"
                        }
                        
                        labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), listingOwnerTitle!, tempInfo)
                        cell.listingDetailsLabel2.isHidden = true
                    }
                    
                    cell.dateLabel2.text = labMsg
                }
                
                if(listingInfo2["closed"] as! Int == 1){
                    cell.closeIconView2.frame = CGRect(x: cell.contentImage2.bounds.width/2 - cell.contentImage2.bounds.width/6 , y: cell.contentImage2.bounds.height/2 - cell.contentImage2.bounds.height/6, width: cell.contentImage2.bounds.width/3, height: cell.contentImage.bounds.height/3)
                    cell.closeIconView2.isHidden = false
                    cell.closeIconView2.text = "\(closedIcon)"
                    cell.closeIconView2.font = UIFont(name: "FontAwesome", size: cell.contentImage2.bounds.width/6)
                }
                else{
                    cell.closeIconView2.isHidden = true
                }
                
                return cell
            }
            
            
            
            dynamicHeight = cell.titleView.frame.origin.y + cell.titleView.bounds.height
            
            cell.titleView.frame.size.height = cell.listingDetailsLabel.frame.origin.y + cell.listingDetailsLabel.bounds.height
            dynamicHeight = cell.titleView.frame.origin.y + cell.titleView.bounds.height + 5
            cell.menuButton.frame.size.height = cell.titleView.bounds.height - 10
            cell.cellView.frame.size.height = dynamicHeight
            cell.lineView.frame.origin.y = dynamicHeight-5
            
            return cell
        }
        
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: Category filter
    @objc func showRootCategoryOptions(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        let alertController = UIActionSheet(title:"Choose sub category", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        alertController.tag = 0
        for menu in subCategoryArr
        {
            
            if let menuItem = menu as? NSDictionary
            {
                
                let titleString = menuItem["sub_cat_name"] as! String
                alertController.addButton(withTitle: titleString)
            }
        }
        
        alertController.show(in: self.view)
        searchDic.removeAll(keepingCapacity: false)
        
    }
    
    @objc func showChildCategoryOptions(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        
        
        let alertController = UIActionSheet(title:"Choose Subsub category", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        alertController.tag = 1
        for menu in subSubCategoryArr
        {
            if let menuItem = menu as? NSDictionary
            {
                let titleString = menuItem["tree_sub_cat_name"] as! String
                alertController.addButton(withTitle: titleString)
            }
        }
        
        alertController.show(in: self.view)
        searchDic.removeAll(keepingCapacity: false)
        
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        if actionSheet.tag==0
        {
            if buttonIndex != 0
            {
                let subcat = subCategoryArr[buttonIndex-1] as! NSDictionary
                subcatid = subcat["sub_cat_id"] as! Int
                rootCategoryBar.setTitle("", for: .normal)
                rootCategoryBar.setTitle(subcat["sub_cat_name"] as? String, for: UIControl.State())
                subcategory = subcat["sub_cat_name"] as? String
                subsubcatid = nil
                subsubcategory = ""
                self.showSpinner = true
                browseEntries()
            }
        } else {
            if buttonIndex != 0
            {
                let subcat = subSubCategoryArr[buttonIndex-1] as! NSDictionary
                subsubcatid = subcat["tree_sub_cat_id"] as! Int
                childCategoryBar.setTitle(subcat["tree_sub_cat_name"] as? String, for: UIControl.State())
                subsubcategory = subcat["tree_sub_cat_name"] as? String
                self.showSpinner = true
                browseEntries()
                
            }
        }
    }
    
    @objc func browseEntries()
    {
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            
            //info.removeFromSuperview()
            let subViews = mainView.subviews
            for ob in subViews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            if (self.pageNumber == 1)
            {
                //self.listingsResponse.removeAll(keepingCapacity: false)
                //self.pagesResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true
                {
                    removeAlert()
                    if self.contentType == "Pages" || self.contentType == "sitegroup"{
                        self.pageTableView.reloadData()
                    }
                    else{
                        self.listingTableView.reloadData()
                    }
                }
                else
                {
                    updateAfterAlert = true
                }
            }
            refreshButton.isHidden = true
            contentIcon.isHidden = true
            
            if (showSpinner)
            {
                //  spinner.center = view.center
                if updateScrollFlag == false
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1)
                {
                    activityIndicatorView.center = mainView.center
                    updateScrollFlag = false
                }
                //                spinner.hidesWhenStopped = true
                //                spinner.style = UIstyle.gray
                //                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                //  activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            var path = ""
            var parameters = [String:String]()
            
            if contentType == "Pages" || contentType == "sitegroup"{
                
                if contentType == "Pages"{
                    path = "sitepages/category"
                }
                else {
                    path = "advancedgroups/category"
                }
                
                
                if subcatid != nil && subsubcatid != nil
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","category_id": String(subjectId),"subcategory_id":String(subcatid),"subsubcategory_id": String(subsubcatid),"restapilocation":defaultlocation]
                }
                else if subcatid != nil
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","category_id": String(subjectId),"subcategory_id":String(subcatid),"restapilocation":defaultlocation]
                    
                }
                else
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","category_id": String(subjectId),"restapilocation":defaultlocation]
                }
                
                
            }
            else{
                path = "listings/categories"
                
                if subcatid != nil && subsubcatid != nil
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","showListings":"1","category_id":String(subjectId),"subCategory_id":String(subcatid),"subsubcategory_id":String(subsubcatid), "listingtype_id": String(listingTypeId),"restapilocation":defaultlocation]
                }
                else if subcatid != nil
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","showListings":"1","category_id":String(subjectId),"subCategory_id":String(subcatid), "listingtype_id": String(listingTypeId),"restapilocation":defaultlocation]
                    
                }
                else
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","showListings":"1","category_id":String(subjectId), "listingtype_id": String(listingTypeId),"restapilocation":defaultlocation]
                    
                }
            }
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner
                    {
                        activityIndicatorView.stopAnimating()
                    }
                    self.pageTableView.tableFooterView?.isHidden = true
                    self.listingTableView.tableFooterView?.isHidden = true
                    self.refresher.endRefreshing()
                    self.refresher1.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    let subviews : NSArray = self.mainView.subviews as NSArray
                    for filterview : Any in subviews
                    {
                        if filterview is UIButton{
                            if (filterview as AnyObject).tag == 240
                            {
                                self.childCategoryBar.removeFromSuperview()
                                self.pageTableView.frame = CGRect(x: 0, y: ButtonHeight, width: self.view.bounds.width,height: self.view.bounds.height-(ButtonHeight + tabBarHeight))
                                self.listingTableView.frame = CGRect(x: 0, y: ButtonHeight, width: self.view.bounds.width,height: self.view.bounds.height-(ButtonHeight + tabBarHeight))
                            }
                            
                        }
                        
                    }
                    
                    
                    
                    if msg
                    {
                        if self.pageNumber == 1
                        {
                            self.listingsResponse.removeAll(keepingCapacity: false)
                            self.pagesResponse.removeAll(keepingCapacity: false)
                            self.subCategoryArr.removeAll(keepingCapacity: false)
                            self.subSubCategoryArr.removeAll(keepingCapacity: false)
                            
                            
                        }
                        
                        if succeeded["message"] != nil
                        {
                            
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                        
                        if self.contentType == "Pages"{
                            
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["pages"] != nil
                                {
                                    if let blog = response["pages"]as? NSArray
                                    {
                                        self.pagesResponse = self.pagesResponse + (blog as [AnyObject])
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        else if self.contentType == "sitegroup"{
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["groups"] != nil
                                {
                                    if let blog1 = response["groups"]as? NSDictionary
                                    {
                                        if let blog = blog1["response"] as? NSArray {
                                            self.pagesResponse = self.pagesResponse + (blog as [AnyObject])
                                        }
                                    }
                                }
                                if response["totalItemCount"] != nil{
                                    self.totalItems = response["totalItemCount"] as! Int
                                }
                            }
                            
                        }
                            
                        else{
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["listings"] != nil
                                {
                                    if let blog = response["listings"]as? NSArray
                                    {
                                        self.listingsResponse = self.listingsResponse + (blog as [AnyObject])
                                        
                                    }
                                }
                                if response["totalListingCount"] != nil{
                                    self.totalItems = response["totalListingCount"] as! Int
                                }
                                
                            }
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if response["subCategories"] != nil
                            {
                                if let blog = response["subCategories"]as? NSArray
                                {
                                    if blog.count > 0
                                    {
                                        self.subCategoryArr = self.subCategoryArr + (blog as [AnyObject])
                                        if self.subcategory == ""
                                        {
                                            
                                            self.rootCategoryBar = createButton(CGRect(x: 0,y: TOPPADING , width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString("Choose sub category",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                            //self.rootCategoryBar.isHidden = false
                                        }
                                        else
                                        {
                                            
                                            self.rootCategoryBar = createButton(CGRect(x: 0, y: TOPPADING, width: self.view.bounds.width, height: ButtonHeight), title: NSLocalizedString(self.subcategory, comment: ""), border: false, bgColor: false, textColor: textColorMedium )
                                            
                                            
                                            //self.rootCategoryBar.isHidden = false
                                        }
                                        
                                        self.rootCategoryBar.isEnabled = true
                                        self.rootCategoryBar.backgroundColor = lightBgColor
                                        self.rootCategoryBar.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.rootCategoryBar.addTarget(self, action: #selector(CategoryDetailGridViewController.showRootCategoryOptions(_:)), for: .touchUpInside)
                                        self.mainView.addSubview(self.rootCategoryBar)
                                        
                                        // Filter Icon on Left site
                                        let filterIcon = createLabel(CGRect(x: self.rootCategoryBar.bounds.width - self.rootCategoryBar.bounds.height, y: 0 ,width: self.rootCategoryBar.bounds.height ,height: self.rootCategoryBar.bounds.height), text: "\(searchFilterIcon)", alignment: .center, textColor: textColorMedium)
                                        filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                                        self.rootCategoryBar.addSubview(filterIcon)
                                        
                                        if self.listingsResponse.count > 0{
                                            self.listingTableView.frame = CGRect(x: 0, y: ButtonHeight + TOPPADING, width: self.view.bounds.width,height: self.view.bounds.height-(ButtonHeight + tabBarHeight + TOPPADING))
                                        }
                                        else{
                                            self.listingTableView.frame = CGRect(x: 0,y: 0 , width: self.view.bounds.width,height: self.view.bounds.height-(ButtonHeight + tabBarHeight))
                                            
                                        }
                                        
                                        if self.pagesResponse.count > 0{
                                            // self.rootCategoryBar.isHidden = false
                                            self.pageTableView.frame = CGRect(x: 0, y: ButtonHeight + TOPPADING, width: self.view.bounds.width,height: self.view.bounds.height-(ButtonHeight + tabBarHeight + TOPPADING))
                                        }
                                        else{
                                            // self.rootCategoryBar.isHidden = true
                                            self.pageTableView.frame = CGRect(x: 0,y: 0 , width: self.view.bounds.width,height: self.view.bounds.height-(ButtonHeight + tabBarHeight))
                                            
                                        }
                                        
                                        
                                        
                                    }
                                }
                            }
                        }
                        
                        if let response1 = succeeded["body"] as? NSDictionary
                        {
                            if response1["subsubCategories"] != nil
                            {
                                if let subSubCategories = response1["subsubCategories"]as? NSArray
                                {
                                    if subSubCategories.count > 0
                                    {
                                        self.subSubCategoryArr = self.subSubCategoryArr + (subSubCategories as [AnyObject])
                                        
                                        if self.subsubcategory == ""
                                        {
                                            self.childCategoryBar = createButton(CGRect(x: 0,y: ButtonHeight + TOPPADING, width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString("Choose sub sub category",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                            
                                        }
                                        else
                                        {
                                            self.childCategoryBar = createButton(CGRect(x: 0,y: ButtonHeight + TOPPADING, width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString(self.subsubcategory,  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                        }
                                        
                                        
                                        
                                        self.childCategoryBar.isEnabled = true
                                        self.childCategoryBar.tag = 240
                                        self.childCategoryBar.backgroundColor = lightBgColor
                                        self.childCategoryBar.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.childCategoryBar.addTarget(self, action: #selector(CategoryDetailGridViewController.showChildCategoryOptions(_:)), for: .touchUpInside)
                                        self.mainView.addSubview(self.childCategoryBar)
                                        
                                        // Filter Icon on Left site
                                        let filterIcon1 = createLabel(CGRect(x: self.childCategoryBar.bounds.width - self.childCategoryBar.bounds.height, y: 0 ,width: self.childCategoryBar.bounds.height ,height: self.childCategoryBar.bounds.height), text: "\(searchFilterIcon)", alignment: .center, textColor: textColorMedium)
                                        filterIcon1.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                                        self.childCategoryBar.addSubview(filterIcon1)
                                        
                                        self.listingTableView.frame = CGRect(x: 0, y: 2*ButtonHeight  + TOPPADING, width: self.view.bounds.width, height: self.view.bounds.height-(2*ButtonHeight + TOPPADING + tabBarHeight))
                                        self.pageTableView.frame = CGRect(x: 0, y: 2*ButtonHeight + TOPPADING, width: self.view.bounds.width, height: self.view.bounds.height-(2*ButtonHeight + tabBarHeight + TOPPADING))
                                        
                                        
                                    }
                                }
                            }
                        }
                        
                        self.isPageRefresing = false
                        
                        // Reload listing Table
                        if self.contentType == "Pages" || self.contentType == "sitegroup"{
                            self.pageTableView.reloadData()
                        }
                        else{
                            self.listingTableView.reloadData()
                        }
                        
                        //    if succeeded["message"] != nil{
                        
                        
                        if self.listingsResponse.count == 0 && self.pagesResponse.count == 0
                        {
                            if self.contentType == "Pages" {
                                self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(pageIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            }
                            else if self.contentType == "sitegroup" {
                                self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(groupIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            }
                                
                            else{
                                self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(listingDefaultIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            }
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.mainView.addSubview(self.contentIcon)
                            
                            if self.contentType == "Pages" {
                                
                                self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any pages matching this criteria.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            }
                            else if self.contentType == "sitegroup" {
                                
                                self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any group matching this criteria.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            }
                                
                            else{
                                self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any listings matching this criteria.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            }
                            
                            self.info.numberOfLines = 0
                            self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.mainView.addSubview(self.info)
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(CategoryDetailGridViewController.browseEntries), for: UIControl.Event.touchUpInside)
                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.mainView.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            
                        }
                    }
                    else
                    {
                        // Handle Server Error
                        if succeeded["message"] != nil
                        {
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                    }
                })
            }
        }
        else
        {
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
        
    }
    
    // Handle Scroll For Pagination
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            //   var index:Int!
            if self.contentType == "Pages" || self.contentType == "sitegroup"{
                
                
                if updateScrollFlag{
                    // Check for Page Number for Browse Classified
                    //                    if pageTableView.contentOffset.y >= pageTableView.contentSize.height - pageTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            pageTableView.tableFooterView?.isHidden = false
                            //   if searchDic.count == 0{
                            browseEntries()
                            // }
                        }
                    }
                    else
                    {
                        pageTableView.tableFooterView?.isHidden = true
                    }
                    
                    //   }
                    
                }
                
                
            }
            else{
                //                index = listingsResponse.count
                //                let someFloat: CGFloat = CGFloat(index)
                //                listingTableView.contentSize.height = dynamicHeight * someFloat
                
                if updateScrollFlag{
                    // Check for Page Number for Browse Classified
                    //                    if listingTableView.contentOffset.y >= listingTableView.contentSize.height - listingTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            listingTableView.tableFooterView?.isHidden = false
                            //  if searchDic.count == 0{
                            browseEntries()
                            // }
                        }
                    }
                    else
                    {
                        listingTableView.tableFooterView?.isHidden = true
                    }
                    
                    //     }
                    
                }
                
                
            }
            
        }
        
    }
    //    func scrollViewDidScroll(_ scrollView: UIScrollView)
    //    {
    //        var index:Int!
    //       if self.contentType == "Pages" || self.contentType == "sitegroup"{
    //
    //            if(UIDevice.current.userInterfaceIdiom == .pad)
    //            {
    //                index =  Int(ceil(Float(pagesResponse.count)/2))
    //            }
    //            else{
    //
    //                index = pagesResponse.count
    //            }
    //            let someFloat: CGFloat = CGFloat(index)
    //            pageTableView.contentSize.height = dynamicHeight * someFloat
    //
    //            if updateScrollFlag{
    //                // Check for Page Number for Browse Classified
    //                if pageTableView.contentOffset.y >= pageTableView.contentSize.height - pageTableView.bounds.size.height{
    //                    if (!isPageRefresing  && limit*pageNumber < totalItems){
    //                        if Reachabable.isConnectedToNetwork() {
    //                            updateScrollFlag = false
    //                            pageNumber += 1
    //                            isPageRefresing = true
    //                            if searchDic.count == 0{
    //                                browseEntries()
    //                            }
    //                        }
    //                    }
    //
    //                }
    //
    //            }
    //
    //
    //        }
    //        else{
    //            index = listingsResponse.count
    //            let someFloat: CGFloat = CGFloat(index)
    //            listingTableView.contentSize.height = dynamicHeight * someFloat
    //
    //            if updateScrollFlag{
    //                // Check for Page Number for Browse Classified
    //                if listingTableView.contentOffset.y >= listingTableView.contentSize.height - listingTableView.bounds.size.height{
    //                    if (!isPageRefresing  && limit*pageNumber < totalItems){
    //                        if Reachabable.isConnectedToNetwork() {
    //                            updateScrollFlag = false
    //                            pageNumber += 1
    //                            isPageRefresing = true
    //                            if searchDic.count == 0{
    //                                browseEntries()
    //                            }
    //                        }
    //                    }
    //
    //                }
    //
    //            }
    //
    //
    //        }
    //
    //
    //
    //
    //    }
    
}
