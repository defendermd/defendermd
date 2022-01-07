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
//  MLTSearchGridViewController.swift
//  seiosnativeapp
//

import UIKit
import Foundation
import NVActivityIndicatorView

class MLTSearchGridViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var searchBar = UISearchBar()
    var listingsTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var updateScrollFlag = false
    var refresher:UIRefreshControl!             // Pull to refrresh
    var isPageRefresing = false                 // For Pagination
    var info:UILabel!
    var dynamicHeight:CGFloat = 253              // Dynamic Height fort for Cell
    var search : String!
 //   var imageCache = [String:UIImage]()
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
    // var listingTableView:UITableView!           // TableView to show the listings Contents
 //   var imageCache1 = [String:UIImage]()
    var ownerLabel : UILabel!
    var size:CGFloat = 0;
    var listingTypeId:Int!
    var scrollView = UIScrollView()
    var listingOption:UIButton!
    var listingBrowseType:Int!
    var fromSearch: Bool!
    var viewSearchType : Int!
    var profileCurrencySymbol : String!
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
//        searchBar.setTextColor(textColorPrime)

        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search \(listingSearchName)",  comment: ""))
        searchBar.delegate = self
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MLTSearchGridViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(MLTSearchGridViewController.filter))
        
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        filter.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = filter
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        mainView.frame = view.frame
        // mainView.backgroundColor = bgColor
        mainView.backgroundColor = UIColor.white
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        info = createLabel(CGRect(x: 0, y: 0,width: 0, height: 0), text: NSLocalizedString("",  comment: "") , alignment: .center, textColor: textColorMedium)
        mainView.addSubview(info)
        info.isHidden = true

        
        // Initialize Blog Table
        listingsTableView = UITableView(frame: CGRect(x: 0, y: 0,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        listingsTableView.register(MLTGridTableViewCell.self, forCellReuseIdentifier: "CellThree")
        listingsTableView.rowHeight = 253
        listingsTableView.dataSource = self
        listingsTableView.delegate = self
        listingsTableView.rowHeight = UITableView.automaticDimension
        listingsTableView.backgroundColor = tableViewBgColor
        listingsTableView.separatorColor = TVSeparatorColor
        listingsTableView.isHidden = true
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            listingsTableView.estimatedRowHeight = 0
            listingsTableView.estimatedSectionHeaderHeight = 0
            listingsTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(listingsTableView)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        listingsTableView.tableFooterView = footerView
        listingsTableView.tableFooterView?.isHidden = true
 
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
    
    // Check for listing Update Every Time when View Appears
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
    
    // Update listings
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            
            if (self.pageNumber == 1){
                self.listingsResponse.removeAll(keepingCapacity: false)
                
                if updateAfterAlert == true {
                    removeAlert()
                    self.listingsTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            contentIcon.isHidden = true
            refreshButton.isHidden = true
            info.isHidden = true
            
            if (showSpinner){
            //    spinner.center = mainView.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                  //  activityIndicatorView.center = mainView.center
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
            
            
            path = "listings"
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)", "listingtype_id": String(listingTypeId)]
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Classified Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    
                    if self.tblAutoSearchSuggestions.isHidden == true
                    {
                        self.listingsTableView.isHidden = false
                    }
                   // self.tblAutoSearchSuggestions.isHidden = true
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    
                    //  self.refresher.endRefreshing()
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
                            if self.browseOrMyListings{
                                if response["response"] != nil {
                                    if let listing = response["response"] as? NSArray {
                                        self.listingsResponse = self.listingsResponse + (listing as [AnyObject])
                                    }
                                }
                            }else{
                                if response["listings"] != nil {
                                    if let listing = response["listings"] as? NSArray {
                                        self.listingsResponse = self.listingsResponse + (listing as [AnyObject])
                                    }
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                        }
                        
                        
                        self.isPageRefresing = false
                        self.listingsTableView.reloadData()
                        
                        if self.listingsResponse.count == 0{
                            
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(listingDefaultIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.view.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any listing entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
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
                            self.refreshButton.addTarget(self, action: #selector(MLTSearchGridViewController.browseEntries), for: UIControl.Event.touchUpInside)

                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.view.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            self.info.isHidden = false
                            self.searchBar.resignFirstResponder()
                        }
                        
                    }else{
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
    
    // Set listing Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set listing Tabel Header Height
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
        return dynamicHeight
        }
    }
    
    // Set listing Section
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
        //MARK: CELL LAYOUT LIKE EVENT VIEW
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath) as! MLTGridTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        //SET CONTENT IMAGE BOUNDS
        cell.contentImage.frame = CGRect(x: 0, y: 0, width: cell.cellView.bounds.width, height: cell.cellView.bounds.height - cell.cellView.bounds.height/4)
        
        //SET TITLE VIEW BOUNDS
        // TITLE VIEW IS BEING USED TO SHOW THE INFO ABOUT THE CONTENT
        cell.titleView.frame = CGRect(x: 0, y: cell.contentImage.bounds.height, width: cell.cellView.bounds.width, height: cell.cellView.bounds.height/4 - 5)
        cell.titleView.backgroundColor = UIColor.white
        
        // SHOWS THE LINE GAP BETWEEN TWO ITEMS
        cell.lineView.isHidden = false
        
        // HIDE THE DATE VIEW
        cell.dateView.isHidden = true
        
        //Hide price tag
        cell.contentName.isHidden = true
        
        
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
        }
        
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
                cell.contentImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
            }
        }
        
        let name = listingInfo["title"] as? String
        let tempInfo = ""
        
        cell.titleLabel.frame = CGRect(x: 10, y: 0, width: cell.titleView.bounds.width - 10, height: 30)
        cell.titleLabel.text = "\(name ?? "")"
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
        
        cell.contentSelection.addTarget(self, action: #selector(MLTSearchGridViewController.showListing(_:)), for: .touchUpInside)
        

        if listingInfo.object(forKey: "price") != nil && (listingInfo["price"] as! Double > 0 ){

            
            if listingInfo["currency"] != nil{
                
                let currencySymbol = getCurrencySymbol(listingInfo["currency"] as! String)
                profileCurrencySymbol = currencySymbol
                if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "Currency")
                    {
                        let price = Float(truncating: (listingInfo["price"] as AnyObject) as! NSNumber)
                        let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)
                        let showPrice = (String(format:"%.2f", changePrice))
                        
                        cell.contentName.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                        
                    }
                }
                else{
                cell.contentName.text = "\(currencySymbol) \(listingInfo["price"]!)"
                }
                cell.contentName.isHidden = false
            }
        }
        
        cell.contentName.layer.shadowOpacity = 1
        
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
                let date = dateDifferenceWithEventTime(postedDate)
                var DateC = date.components(separatedBy: ", ")
                var tempInfo = ""
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
                
                
                if browseOrMyListings {
                    labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), listingOwnerTitle!, tempInfo)
                    cell.listingDetailsLabel.isHidden = true
                    cell.titleView.frame.size.height = cell.listingDetailsLabel.frame.origin.y + 5
                    
                }else{
                    labMsg = String(format: NSLocalizedString("%@", comment: ""), tempInfo)
                    
                    let view_count = listingInfo["view_count"]
                    let review_count = listingInfo["review_count"]
                    let comment_count = listingInfo["comment_count"]
                    let like_count = listingInfo["like_count"]
                    
                    cell.listingDetailsLabel.text = labMsg
                    cell.listingDetailsLabel.text = "\(viewIcon) \(view_count!)  \(starIcon) \(review_count!)  \(commentIcon) \(comment_count!)  \(likeIcon) \(like_count!)"
                    cell.listingDetailsLabel.isHidden = false
                    
                    cell.titleView.frame.size.height = cell.listingDetailsLabel.frame.origin.y + cell.listingDetailsLabel.bounds.height
                }
            }
            
            cell.dateLabel.text = labMsg
            
            if(listingInfo["closed"] as! Int == 1){
                cell.closeIconView.frame = CGRect(x: cell.contentImage.bounds.width/2 - cell.contentImage.bounds.width/6 , y: cell.contentImage.bounds.height/2 - cell.contentImage.bounds.height/6, width: cell.contentImage.bounds.width/3, height: cell.contentImage.bounds.height/3)
                cell.closeIconView.isHidden = false
                cell.closeIconView.text = "\(closedIcon)"
                cell.closeIconView.font = UIFont(name: "FontAwesome", size: cell.contentImage.bounds.width/6)
            }
            else{
                cell.closeIconView.isHidden = true
            }
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
            }else{
                cell.cellView2.isHidden = true
                cell.contentSelection2.isHidden = true
                cell.dateView2.isHidden = true
                cell.titleView2.isHidden = true
                return cell
            }
            
            // Select Event Action
            cell.contentSelection2.addTarget(self, action: #selector(MLTSearchGridViewController.showListing(_:)), for: .touchUpInside)
            
            
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
            var tempInfo = ""
            if let eventDate = listingInfo2["starttime"] as? String{
                
                let dateMonth = dateDifferenceWithTime(eventDate)
                var dateArrayMonth = dateMonth.components(separatedBy: ", ")
                if dateArrayMonth.count > 1{
                    cell.dateLabel3.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                    
                    cell.dateLabel3.numberOfLines = 0
                    cell.dateLabel3.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                    cell.dateLabel3.textColor = UIColor.white
                    cell.dateLabel3.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                }
                
                let date = dateDifferenceWithEventTime(eventDate)
                var DateC = date.components(separatedBy: ", ")
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
            }
            else{
                cell.dateView2.isHidden = true
            }
            
            cell.titleLabel2.frame = CGRect(x: 10, y: 0, width: (cell.contentImage2.bounds.width-125), height: 30)
            cell.titleLabel2.text = "\(name ?? "")"
            cell.titleLabel2.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            let location = listingInfo2["location"] as? String
            
            if location != "" && location != nil{
                
                cell.dateLabel2.frame = CGRect(x: 10, y: 25, width: (cell.contentImage2.bounds.width-70), height: 20)
                cell.dateLabel2.text = "\(tempInfo)"
                cell.dateLabel2.textAlignment = NSTextAlignment.left
                // cell.dateLabel.textColor = textColorLight
                cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                
                cell.locLabel2.isHidden = false
                cell.locLabel2.frame = CGRect(x: 10, y: 45, width: (cell.contentImage2.bounds.width-70), height: 20)
                cell.locLabel2.text = "\(locationIcon) \(location!)"
                // cell.locLabel.textColor = textColorLight
                cell.locLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                
            }
            
            if location == "" || location == nil{
                
                cell.locLabel2.isHidden = true
                cell.dateLabel2.frame = CGRect(x: 10, y: 35, width: (cell.contentImage2.bounds.width-70), height: 20)
                cell.dateLabel2.text = "\(tempInfo)"
                cell.dateLabel2.textAlignment = NSTextAlignment.left
                //cell.dateLabel.textColor = textColorLight
                cell.dateLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                
            }
            
            let listingOwnerTitle = listingInfo2["owner_title"] as? String
            
            if listingOwnerTitle != "" && listingOwnerTitle != nil{
                var labMsg = ""
                if let postedDate = listingInfo2["creation_date"] as? String{
                    let date = dateDifferenceWithEventTime(postedDate)
                    var DateC = date.components(separatedBy: ", ")
                    var tempInfo = ""
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
                    
                    
                    if browseOrMyListings {
                        labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), listingOwnerTitle!, tempInfo)
                        cell.listingDetailsLabel2.isHidden = true
                        
                    }else{
                        labMsg = String(format: NSLocalizedString("%@", comment: ""), tempInfo)
                        
                        let view_count = listingInfo2["view_count"]
                        let review_count = listingInfo2["review_count"]
                        let comment_count = listingInfo2["comment_count"]
                        let like_count = listingInfo2["like_count"]
                        
                        
                        cell.lineView2.frame.origin.y = 280
                        cell.titleView2.frame.size.height = 100
                        cell.listingDetailsLabel2.text = labMsg
                        cell.listingDetailsLabel2.text = "\(viewIcon) \(view_count!) \(reviewIcon) \(review_count!) \(commentIcon) \(comment_count!) \(likeIcon) \(like_count!)"
                        
                        cell.listingDetailsLabel2.isHidden = false
                    }
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
        if !browseOrMyListings{
            cell.titleView.frame.size.height = cell.listingDetailsLabel.frame.origin.y + cell.listingDetailsLabel.bounds.height
            dynamicHeight = cell.titleView.frame.origin.y + cell.titleView.bounds.height + 5
        }
        cell.cellView.frame.size.height = dynamicHeight
        cell.lineView.frame.origin.y = dynamicHeight-5
        
        return cell
        }
    }
    
    
    // Handle listing Table Cell Selection
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
            
            if let name = listingInfo["title"] as? String
            {
                updateAutoSearchArray(str: name)
            }
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
                presentedVC.subjectType = "sitereview_listtype_\(tempListingTypeId)"
            }
            
            presentedVC.listingName = listingInfo["title"] as! String
            
            navigationController?.pushViewController(presentedVC, animated: true)
        }else{
            showToast(message: NSLocalizedString("You do not have permission to view this private page.",  comment: ""), controller: self)
        }
        }
        
    }
    
    
    // MARK:  UIScrollViewDelegate
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if updateScrollFlag{
//            // Check for Page Number for Browse listing
//            if listingsTableView.contentOffset.y >= listingsTableView.contentSize.height - listingsTableView.bounds.size.height{
//                if (limit*pageNumber < totalItems){
//                    if Reachabable.isConnectedToNetwork() {
//                        updateScrollFlag = false
//                        pageNumber += 1
//                        isPageRefresing = true
//                        browseEntries()
//                    }
//                }
//            }
//        }
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
                // Check for Page Number for Browse listing
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
             //   }
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
        showSpinner = true
        filterSearchString = searchBar.text!
        pageNumber = 1
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
        showSpinner = true
        filterSearchString = searchBar.text!
        pageNumber = 1
     //   searchBar.resignFirstResponder()
        browseEntries()
    }
    @objc func showListing(_ sender: UIButton){
        
        var listingInfo:NSDictionary!
        listingInfo = listingsResponse[sender.tag] as! NSDictionary
        
        if(listingInfo["allow_to_view"] as! Int == 1){
            // let presentedVC = MLTBlogTypeViewController()
            
            var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingTypeId]!
            let viewType = tempBrowseViewTypeDic["viewType"]!

            if let name = listingInfo["title"] as? String
            {
                updateAutoSearchArray(str: name)
            }
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
            
            // isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        } else {
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
