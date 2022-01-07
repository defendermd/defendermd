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
//  MLTSearchMatrixViewController.swift
//  seiosnativeapp
//

import UIKit
import Foundation
import NVActivityIndicatorView

class MLTSearchMatrixViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var searchBar = UISearchBar()
    var listingsTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var blogResponse = [AnyObject]()
    var updateScrollFlag = false
    var refresher:UIRefreshControl!             // Pull to refrresh
    var isPageRefresing = false                 // For Pagination
    var info:UILabel!
    var browseOrMyBlog = true
    var dynamicHeight:CGFloat = 160              // Dynamic Height fort for Cell
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
    // var listingTableView:UITableView!           // TableView to show the listings Contents
   // var imageCache1 = [String:UIImage]()
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

        
        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search \(listingSearchName)",  comment: ""))
        searchBar.delegate = self
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MLTSearchMatrixViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        
        let backIconImageView = createImageView(CGRect(x: 0,y: 12,width: 22,height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(MLTSearchMatrixViewController.filter))
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        self.navigationItem.rightBarButtonItem = filter
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        mainView.frame = view.frame
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
        listingsTableView.register(ClassifiedTableViewCell.self, forCellReuseIdentifier: "Cell")
        listingsTableView.dataSource = self
        listingsTableView.delegate = self
        listingsTableView.estimatedRowHeight = 160.0
        listingsTableView.rowHeight = UITableView.automaticDimension
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
   
        // self.shyNavBarManager.scrollView = self.listingsTableView;
        
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
    
    
    // Update listings
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            //
            //            if showOnlyMyContent == true{
            //                browseOrMyListings = false
            //            }
            
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
              //  spinner.center = mainView.center
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
             //   activityIndicatorView.center = self.view.center
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
                   // self.tblAutoSearchSuggestions.isHidden = true
                    if self.tblAutoSearchSuggestions.isHidden == true
                    {
                        self.listingsTableView.isHidden = false
                    }
                 
                    
                    if self.showSpinner{
                        
                        activityIndicatorView.stopAnimating()
                    }
                    
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
                        
                        //Reload listings Table
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
                            self.refreshButton.addTarget(self, action: #selector(MLTSearchMatrixViewController.browseEntries), for: UIControl.Event.touchUpInside)

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
        return dynamicHeight
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
        return Int(ceil(Float(listingsResponse.count)/2))
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ClassifiedTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        var index:Int!
        index = (indexPath as NSIndexPath).row * 2
        
        if listingsResponse.count > index {
            cell.contentSelection.isHidden = false
            cell.classifiedImageView.isHidden = false
            cell.classifiedName.isHidden = false
            cell.classifiedImageView.image = nil
            
            
            if let photoInfo = listingsResponse[index] as? NSDictionary {
                // LHS
                if let url = URL(string: photoInfo["image"] as! NSString as String){
                    cell.classifiedImageView.kf.indicatorType = .activity
                    (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.classifiedImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                    
                }
                let name = photoInfo["title"] as? String
                
                let tempString = name! as NSString
                
                var value : String
                
                if tempString.length > 22{
                    
                    value = tempString.substring(to: 19)
                    value += NSLocalizedString("...",  comment: "")
                }else{
                    value = "\(tempString)"
                }
                
                cell.classifiedName.text = value
                let location = photoInfo["location"] as? String
                if location != "" && location != nil
                {
                    cell.classifiedName.frame.origin.y = 100
                    cell.lblLoc.frame.origin.y = 125
                    cell.lblLoc.isHidden = false
                    
                    cell.lblLoc.text = locationIcon + "  " + location!
                }
                else
                {
                    cell.classifiedName.frame.origin.y = 125
                    cell.lblLoc.isHidden = true
                }
                
                cell.contentSelection.accessibilityIdentifier = "\(index!)"
                cell.contentSelection.tag = photoInfo["listing_id"] as! Int
                
                if photoInfo["allow_to_view"] != nil && photoInfo["allow_to_view"] as! Int > 0 {
                    cell.contentSelection.addTarget(self, action: #selector(MLTSearchMatrixViewController.showListing(_:)), for: .touchUpInside)
                }
                else
                {
                    cell.contentSelection.addTarget(self, action: #selector(MLTSearchMatrixViewController.noRedirection(_:)), for: .touchUpInside)

                }
                
                if browseOrMyListings
                {
                    cell.menu.isHidden = true
                    cell.menu1.isHidden = true
                }
                else
                {
                    // Set MenuAction
                    cell.menu.addTarget(self, action:Selector(("showMenu:")) , for: .touchUpInside)
                    cell.menu.isHidden = false
                    cell.menu1.addTarget(self, action:Selector(("showMenu:")) , for: .touchUpInside)

                    cell.menu1.isHidden = false
                    
                }
                
                if(photoInfo["closed"] as! Int == 1){
                    cell.closeIconView.frame = CGRect(x: cell.classifiedImageView.bounds.width/2 - cell.classifiedImageView.bounds.width/4 , y: cell.classifiedImageView.bounds.height/2 - cell.classifiedImageView.bounds.height/4, width: cell.classifiedImageView.bounds.width/2, height: cell.classifiedImageView.bounds.height/2)
                    cell.closeIconView.isHidden = false
                    cell.closeIconView.text = "\(closedIcon)"
                    cell.closeIconView.font = UIFont(name: "FontAwesome", size: cell.classifiedImageView.bounds.width/4)
                }
                else{
                    cell.closeIconView.isHidden = true
                }
                
            }
            
        }
        else{
            cell.contentSelection.isHidden = true
            cell.classifiedImageView.isHidden = true
            cell.classifiedName.isHidden = true
            
            cell.contentSelection1.isHidden = true
            cell.classifiedImageView1.isHidden = true
            cell.classifiedName1.isHidden = true
        }
        
        
        if listingsResponse.count > (index + 1){
            cell.contentSelection1.isHidden = false
            cell.classifiedImageView1.isHidden = false
            cell.classifiedName1.isHidden = false
            
            
            cell.classifiedImageView1.image = nil
            if let photoInfo = listingsResponse[index + 1] as? NSDictionary {
                
                if let url = URL(string: photoInfo["image"] as! NSString as String){

                    cell.classifiedImageView1.kf.indicatorType = .activity
                    (cell.classifiedImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.classifiedImageView1.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                    
                }
                
                let name1 = photoInfo["title"] as? String
                
                let tempString1 = name1! as NSString
                
                var value1 : String
                
                if tempString1.length > 22{
                    
                    value1 = tempString1.substring(to: 19)
                    value1 += NSLocalizedString("...",  comment: "")
                }else{
                    value1 = "\(tempString1)"
                }
                
                cell.classifiedName1.text = value1
                
                let location = photoInfo["location"] as? String
                if location != "" && location != nil
                {
                    cell.classifiedName1.frame.origin.y = 100
                    cell.lblLoc1.frame.origin.y = 125
                    cell.lblLoc1.isHidden = false
                    
                    cell.lblLoc1.text = locationIcon + "  " + location!
                }
                else
                {
                    cell.classifiedName1.frame.origin.y = 125
                    cell.lblLoc1.isHidden = true
                }
                
                cell.contentSelection1.accessibilityIdentifier = "\(index! + 1)"
                cell.contentSelection1.tag = photoInfo["listing_id"] as! Int
                if photoInfo["allow_to_view"] != nil && photoInfo["allow_to_view"] as! Int > 0 {
                    cell.contentSelection1.addTarget(self, action: #selector(MLTSearchMatrixViewController.showListing(_:)), for: .touchUpInside)
                }
                else
                {
                    cell.contentSelection1.addTarget(self, action: #selector(MLTSearchMatrixViewController.noRedirection(_:)), for: .touchUpInside)
                }
                
                if browseOrMyListings
                {
                    cell.menu.isHidden = true
                    cell.menu1.isHidden = true
                }
                else
                {
                    // Set MenuAction
                    cell.menu.addTarget(self, action:Selector(("showMenu:")) , for: .touchUpInside)
                    cell.menu.isHidden = false
                    cell.menu1.addTarget(self, action:Selector(("showMenu:")) , for: .touchUpInside)

                    cell.menu1.isHidden = false
                    
                }
                
                if(photoInfo["closed"] as! Int == 1){
                    cell.closeIconView1.frame = CGRect(x: cell.classifiedImageView1.bounds.width/2 - cell.classifiedImageView1.bounds.width/4 , y: cell.classifiedImageView1.bounds.height/2 - cell.classifiedImageView1.bounds.height/4, width: cell.classifiedImageView1.bounds.width/2, height: cell.classifiedImageView1.bounds.height/2)
                    cell.closeIconView1.isHidden = false
                    cell.closeIconView1.text = "\(closedIcon)"
                    cell.closeIconView1.font = UIFont(name: "FontAwesome", size: cell.classifiedImageView1.bounds.width/4)
                }
                else{
                    cell.closeIconView1.isHidden = true
                }
                
            }
            
        }
            
        else{
            cell.contentSelection1.isHidden = true
            cell.classifiedImageView1.isHidden = true
            cell.classifiedName1.isHidden = true
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
            
        }
    }
    
    @objc func showListing(_ sender: UIButton)
    {
        if let strIndex = sender.accessibilityIdentifier, let index = Int(strIndex), let photoInfo = listingsResponse[index] as? NSDictionary {
            if let str = photoInfo["title"] as? String
            {
                updateAutoSearchArray(str: str)
            }
        }
        
        if viewSearchType == 2
        {
            let presentedVC = MLTClassifiedSimpleTypeViewController()
            
            presentedVC.listingId = "\(sender.tag)"
            presentedVC.listingTypeId = listingTypeId
            presentedVC.subjectType = "sitereview_listing"
            // presentedVC.listingName = listingContentName
            
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        if viewSearchType == 1{
            let presentedVC = MLTBlogTypeViewController()
            presentedVC.listingId = "\(sender.tag)"
            
            
            presentedVC.listingTypeId = listingTypeId
            presentedVC.subjectType = "sitereview_listing"
            //  presentedVC.listingName = listingContentName
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        if viewSearchType == 3{
            let presentedVC = MLTClassifiedAdvancedTypeViewController()
            presentedVC.listingId = "\(sender.tag)"
            
            
            presentedVC.listingTypeId = listingTypeId
            presentedVC.subjectType = "sitereview_listing"
            //   presentedVC.listingName = listingContentName
            
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    @objc func noRedirection(_ sender: UIButton){
        self.view.endEditing(true)
        showToast(message: "User not allowed to view this page", controller: self)
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if updateScrollFlag{
//            // Check for Page Number for Browse Blog
//            if listingsTableView.contentOffset.y >= listingsTableView.contentSize.height - listingsTableView.bounds.size.height{
//                if (limit*pageNumber < totalItems){
//
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
    //    searchBar.resignFirstResponder()
        
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
               // searchBar.endEditing(true)
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
