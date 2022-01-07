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
//  MLTSearchListViewController.swift
//  seiosnativeapp
//

import UIKit
import Foundation
import NVActivityIndicatorView

class MLTSearchListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    var searchBar = UISearchBar()
    var listingsTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var updateScrollFlag = false
    var refresher:UIRefreshControl!             // Pull to refrresh
    var isPageRefresing = false                 // For Pagination
    var info:UILabel!
    var dynamicHeight:CGFloat = 75              // Dynamic Height fort for Cell
    var search : String!
    // var imageCache = [String:UIImage]()
    var categ_id : Int!
    var listingId : Int!
    let mainView = UIView()
    var showOnlyMyContent:Bool!
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    var countListTitle : String!
    var listingsResponse = [AnyObject]()        // For response come from Server
    var browseOrMyListings = true               // True for Browse Listings & False for My Listings
    var fromTab : Bool!
    var user_id : Int!
    var editListingID:Int = 0
    var listingTableView:UITableView!           // TableView to show the listings Contents
    //  var imageCache1 = [String:UIImage]()
    var ownerLabel : UILabel!
    var size:CGFloat = 0;
    var listingTypeId:Int!
    var scrollView = UIScrollView()
    
    var listingOption:UIButton!
    var listingBrowseType:Int!
    var fromSearch: Bool!
    var viewSearchType : Int!
    var listingSearchName = ""
    var leftBarButtonItem : UIBarButtonItem!
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    override func viewDidLoad() {
        
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        super.viewDidLoad()
        
        //        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search \(listingSearchName)",  comment: ""))
        //        searchBar.delegate = self
        //
        //        searchBar.setTextColor(textColorPrime)
        
        
        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search \(listingSearchName)",  comment: ""))
        searchBar.delegate = self
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MLTSearchListViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(MLTSearchListViewController.filter))
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        
        self.navigationItem.rightBarButtonItem = filter
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        mainView.frame = view.frame 
        mainView.backgroundColor = UIColor.white
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        contentIcon = createLabel(CGRect(x: 0, y: 0, width: 0, height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0, y: 0, width: 0, height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        info = createLabel(CGRect(x: 0, y: 0, width: 0, height: 0), text: NSLocalizedString("",  comment: "") , alignment: .center, textColor: textColorMedium)
        mainView.addSubview(info)
        info.isHidden = true
        
        // Initialize Blog Table
        listingsTableView = UITableView(frame: CGRect(x: 0, y: 0,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        listingsTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        listingsTableView.dataSource = self
        listingsTableView.delegate = self
        listingsTableView.backgroundColor = tableViewBgColor
        listingsTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            listingsTableView.estimatedRowHeight = 0
            listingsTableView.estimatedSectionHeaderHeight = 0
            listingsTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(listingsTableView)
        listingsTableView.isHidden = true
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        listingsTableView.tableFooterView = footerView
        listingsTableView.tableFooterView?.isHidden = true
        
        tblAutoSearchSuggestions = UITableView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 420), style:UITableView.Style.plain)
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
    // Check for Blog Update Every Time when View Appears
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
    // Update Blog
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            self.refreshButton.isHidden = true
            self.contentIcon.isHidden = true
            self.info.isHidden = true
            
            if (self.pageNumber == 1){
                
                if updateAfterAlert == true || searchDic.count > 0 {
                    self.listingsResponse.removeAll(keepingCapacity: false)
                    removeAlert()
                    self.listingsTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
                //  spinner.center = mainView.center
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
            
            
            // Set Parameters for Search
            path = "listings"
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "listingtype_id": String(listingTypeId)]
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                   // self.tblAutoSearchSuggestions.isHidden = true
                    if self.tblAutoSearchSuggestions.isHidden == true
                    {
                         self.listingsTableView.isHidden = false
                    }
                   
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    
                    //self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.listingsResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            
                            if response["response"] != nil {
                                if let listing = response["response"] as? NSArray {
                                    self.listingsResponse = self.listingsResponse + (listing as [AnyObject])
                                }
                            }
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                        }
                        
                        self.isPageRefresing = false
                        
                        //Reload Listing Table
                        self.listingsTableView.reloadData()
                        if self.listingsResponse.count == 0{
                            
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(listingDefaultIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.view.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any listings entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.sizeToFit()
                            self.info.numberOfLines = 0
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.view.addSubview(self.info)
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(MLTSearchListViewController.browseEntries), for: UIControl.Event.touchUpInside)
                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.view.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            self.info.isHidden = false
                            
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
    
    // Set Blog Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Blog Tabel Header Height
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
            return 75
        }
    }
    
    // Set Blog Section
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
            return listingsResponse.count
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
        else
        {
            //LAYOUT LIKE BLOG VIEW
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            
            var listingInfo:NSDictionary
            listingInfo = listingsResponse[(indexPath as NSIndexPath).row] as! NSDictionary
            
            cell.imgUser.frame = CGRect(x: 5, y: 7, width: 60, height: 60)
            
            // Set Blog Title
            cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10, width: cell.bounds.width - (cell.imgUser.bounds.width + 15) , height: 20)
            cell.labTitle.text = listingInfo["title"] as? String
            cell.labTitle.numberOfLines = 2
            cell.labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
            
            cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
            cell.labTitle.sizeToFit()
            
            if let ownerName = listingInfo["owner_title"] as? String {
                if let postedDate = listingInfo["creation_date"] as? String{
                    let postedOn = dateDifference(postedDate)
                    
                    cell.labMessage.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5,width: (UIScreen.main.bounds.width - 75) , height: 20)
                    cell.labMessage.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                    
                    var labMsg = ""
                    
                    if browseOrMyListings {
                        labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), ownerName, postedOn)
                        cell.postCount.isHidden = true
                    }else{
                        
                        labMsg = String(format: NSLocalizedString("%@", comment: ""), postedOn)
                        
                        var listingStats = ""
                        let view_count = listingInfo["view_count"]
                        let review_count = listingInfo["review_count"]
                        let comment_count = listingInfo["comment_count"]
                        let like_count = listingInfo["like_count"]
                        
                        listingStats = String(format: NSLocalizedString("\(viewIcon) \(view_count!)  \(starIcon) \(review_count!)  \(commentIcon) \(comment_count!)  \(likeIcon) \(like_count!)", comment: ""))
                        
                        // postCount is being used to show the listing stats
                        cell.postCount.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labMessage.frame.origin.y + cell.labMessage.bounds.height, width: (UIScreen.main.bounds.width - 75), height: 20)
                        cell.postCount.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                        cell.postCount.textColor = UIColor.gray
                        
                        cell.postCount.text = listingStats
                        cell.postCount.sizeToFit()
                        cell.postCount.isHidden = false
                        
                    }
                    
                    cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                        return mutableAttributedString
                    })
                    
                    
                }
            }
            
            cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labMessage.sizeToFit()
            cell.labMessage.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            
            if(listingInfo["closed"] as! Int == 1){
                cell.imageview.isHidden = false
                cell.imageview.text = "\(closedIcon)"
            }
            else{
                cell.imageview.isHidden = true
            }
            
            // Set Listing Owner Image
            
            if let url = URL(string: listingInfo["image"] as! String){
     
                cell.imgUser.kf.indicatorType = .activity
                (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    if let imgT = image
                    {
                        cell.imgUser.image = CustomSquareImage(imgT, size: CGSize(width: cell.imgUser.frame.width, height: cell.imgUser.frame.height))
                    }
                })
            }
            return cell
        }
        
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
                self.listingsTableView.isHidden = true
                
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
            var listingInfo:NSDictionary
            listingInfo = listingsResponse[(indexPath as NSIndexPath).row] as! NSDictionary
            
            if(listingInfo["allow_to_view"] as! Int == 1){
                // let presentedVC = MLTBlogTypeViewController()
                if let str = listingInfo["title"] as? String
                {
                    updateAutoSearchArray(str: str)
                }
                var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingTypeId]!
                let viewType = tempBrowseViewTypeDic["viewType"]!
                switch viewType{
                case 2:
                    
                    let presentedVC = MLTClassifiedSimpleTypeViewController()
                    if (listingInfo["listing_id"] is String){
                        let tempValue = listingInfo["listing_id"] as! String
                        
                        presentedVC.listingId = tempValue
                        
                    }else{
                        presentedVC.listingId = "\(listingInfo["listing_id"]!)"
                    }
                    
                    if listingInfo["listingtype_id"] is Int{
                        
                        let tempListingTypeId = listingInfo["listingtype_id"] as! Int
                        presentedVC.listingTypeId = listingInfo["listingtype_id"] as! Int
                        presentedVC.subjectType = "sitereview_listing"
                        presentedVC.listingTypeId = tempListingTypeId
                    }
                    
                    navigationController?.pushViewController(presentedVC, animated: true)
                    break
                    
                case 3:
                    
                    let presentedVC = MLTClassifiedAdvancedTypeViewController()
                    if (listingInfo["listing_id"] is String){
                        let tempValue = listingInfo["listing_id"] as! String
                        
                        presentedVC.listingId = tempValue
                        
                    }else{
                        presentedVC.listingId = "\(listingInfo["listing_id"]!)"
                    }
                    
                    if listingInfo["listingtype_id"] is Int{
                        
                        let tempListingTypeId = listingInfo["listingtype_id"] as! Int
                        presentedVC.listingTypeId = listingInfo["listingtype_id"] as! Int
                        presentedVC.subjectType = "sitereview_listing"
                        presentedVC.listingTypeId = tempListingTypeId
                    }
                    
                    
                    navigationController?.pushViewController(presentedVC, animated: true)
                    break
                    
                default:
                    
                    let presentedVC = MLTBlogTypeViewController()
                    if (listingInfo["listing_id"] is String){
                        let tempValue = listingInfo["listing_id"] as! String
                        
                        presentedVC.listingId = tempValue
                        
                    }else{
                        presentedVC.listingId = "\(listingInfo["listing_id"]!)"
                    }
                    
                    if listingInfo["listingtype_id"] is Int{
                        
                        let tempListingTypeId = listingInfo["listingtype_id"] as! Int
                        presentedVC.listingTypeId = listingInfo["listingtype_id"] as! Int
                        presentedVC.subjectType = "sitereview_listing"
                        presentedVC.listingTypeId = tempListingTypeId
                    }
                    
                    
                    
                    navigationController?.pushViewController(presentedVC, animated: true)
                    break
                }
                
                
            }
                
            else
            {
                showToast(message: NSLocalizedString("You do not have permission to view this private page.",  comment: ""), controller: self)
            }
        }
        
    }
    
    
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
    //    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    //
    //        if updateScrollFlag{
    //            // Check for Page Number for Browse Blog
    //            if listingsTableView.contentOffset.y >= listingsTableView.contentSize.height - listingsTableView.bounds.size.height{
    //                if (limit*pageNumber < totalItems){
    //                    if Reachabable.isConnectedToNetwork() {
    //                        updateScrollFlag = false
    //                        pageNumber += 1
    //                        isPageRefresing = true
    //                        browseEntries()
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
        if tblAutoSearchSuggestions.isHidden == true
        {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                // Check for Page Number for Browse Blog
                //                if listingsTableView.contentOffset.y >= listingsTableView.contentSize.height - listingsTableView.bounds.size.height{
                if (limit*pageNumber < totalItems){
                    if Reachabable.isConnectedToNetwork() {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        listingsTableView.tableFooterView?.isHidden = false
                        browseEntries()
                    }
                }
                else
                {
                    listingsTableView.tableFooterView?.isHidden = true
                }
                
                //     }
                
            }
            
        }
        }
    }
    
    
    
    @objc func cancel(){
        listingUpdate = false
        
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
                self.listingsTableView.isHidden = true
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
    @objc func filter(){
        if filterSearchFormArray.count > 0 {
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "listing"
            presentedVC.url = "listings/search-form"
            presentedVC.contentType = "listings"
            presentedVC.listingTypeId = listingTypeId
            presentedVC.stringFilter = searchBar.text!
            
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            
            presentedVC.searchUrl = "listings/search-form"
            presentedVC.serachFor = "listing"
            presentedVC.url = "listings/search-form"
            presentedVC.contentType = "listings"
            presentedVC.listingTypeId = listingTypeId
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
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
                //searchBar.endEditing(true)
            }
            searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
        listingsTableView.tableFooterView?.isHidden = true
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
