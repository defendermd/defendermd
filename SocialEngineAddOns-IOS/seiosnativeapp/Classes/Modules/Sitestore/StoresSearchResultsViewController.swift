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
//  StoresSearchResultsViewController.swift
//  seiosnativeapp
//

import UIKit
import Foundation
import NVActivityIndicatorView

class StoresSearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    var searchBar = UISearchBar()
    var storesTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var updateScrollFlag = false
    var refresher:UIRefreshControl!             // Pull to refrresh
    var isPageRefresing = false                 // For Pagination
    var info:UILabel!
    var dynamicHeight:CGFloat = 253              // Dynamic Height fort for Cell
    var search : String!
   // var imageCache = [String:UIImage]()
    var categ_id : Int!
    var storeId : Int!
    let mainView = UIView()
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    var searchResponse = [AnyObject]()        // For response come from Server
    var size:CGFloat = 0
    
    var scrollView = UIScrollView()
    var storesSearchName = ""
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    override func viewDidLoad() {
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        super.viewDidLoad()
        
//        searchBar.addSearchBarWithText(self, placeholderText: NSLocalizedString("Search \(storesSearchName)",  comment: ""))
//        searchBar.delegate = self
   
        _ = SearchBarContainerView(self, customSearchBar:searchBar)

        searchBar.setPlaceholderWithColor(NSLocalizedString("Search \(storesSearchName)",  comment: ""))
        searchBar.delegate = self
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(StoresSearchResultsViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
//        let leftButton = UIBarButtonItem(customView: leftNavView)
//        self.navigationItem.leftBarButtonItem = leftButton
        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(StoresSearchResultsViewController.filter))
        
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!], for: UIControl.State.normal)
        
        self.navigationItem.rightBarButtonItem = filter
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        mainView.frame = view.frame
        mainView.backgroundColor = UIColor.white
        mainView.removeGestureRecognizer(tapGesture)
        view.addSubview(mainView)
        
        contentIcon = createLabel(CGRect(x:0,y: 0,width: 0,height:0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x:0,y:0,width:0,height:0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        info = createLabel(CGRect(x:0,y: 0,width:0,height: 0), text: NSLocalizedString("",  comment: "") , alignment: .center, textColor: textColorMedium)
        info.isHidden = true
        mainView.addSubview(info)
        
        // Initialize Table
        storesTableView = UITableView(frame: CGRect(x:0, y:0,width: view.bounds.width,height: view.bounds.height - (tabBarHeight + TOPPADING - 12)), style:.grouped)
        storesTableView.register(MLTGridTableViewCell.self, forCellReuseIdentifier: "CellThree")
        storesTableView.rowHeight = 253
        storesTableView.dataSource = self
        storesTableView.delegate = self
        storesTableView.backgroundColor = tableViewBgColor
        storesTableView.separatorColor = TVSeparatorColor
        storesTableView.isHidden = true
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            self.storesTableView.estimatedRowHeight = 0
            self.storesTableView.estimatedSectionHeaderHeight = 0
            self.storesTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(storesTableView)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        storesTableView.tableFooterView = footerView
        storesTableView.tableFooterView?.isHidden = true
  
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
       // self.navigationItem.titleView = searchBar
        if searchDic.count > 0 {
            if globFilterValue != ""{
                searchBar.text = globFilterValue
                searchBar.endEditing(true)
            }
            searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
            showSpinner = true
            pageNumber = 1
            self.browseEntries()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
        storesTableView.tableFooterView?.isHidden = true
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
                self.searchResponse.removeAll(keepingCapacity: false)
                
                if updateAfterAlert == true {
                    removeAlert()
                    self.storesTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            contentIcon.isHidden = true
            refreshButton.isHidden = true
            info.isHidden = true
            
            if (showSpinner){
             //   spinner.center = mainView.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                   // activityIndicatorView.center = mainView.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
           //     activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            var parameters = [String:String]()
            
            let path = "sitestore/browse"
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Classified Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    //self.tblAutoSearchSuggestions.isHidden = true
                    if self.tblAutoSearchSuggestions.isHidden == true
                    {
                        self.storesTableView.isHidden = false
                    }
                    
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    
                    //  self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.searchResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if response["response"] != nil {
                                if let stores = response["response"] as? NSArray {
                                    self.searchResponse = self.searchResponse + (stores as [AnyObject])
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                        }
                        
                        
                        self.isPageRefresing = false
                        self.storesTableView.reloadData()
                        
                        if self.searchResponse.count == 0{
                            
                            self.contentIcon = createLabel(CGRect(x:self.view.bounds.width/2 - 30, y:self.view.bounds.height/2-80,width: 60,height: 60), text: NSLocalizedString("\(storeCartIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.view.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x:0,y: 0,width: self.view.bounds.width * 0.8,height: 50), text: NSLocalizedString("There are no stores matching this criteria.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.numberOfLines = 0
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.view.addSubview(self.info)
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40,y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING),width: 80,height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(StoresSearchResultsViewController.browseEntries), for: UIControl.Event.touchUpInside)
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
    
    func showAlertMessage(centerPoint: CGPoint, msg: String, timer: Bool){
        self.view.addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer() {
        stop()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }
        else
        {
        return searchResponse.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
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
        let row = indexPath.row as Int
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath as IndexPath) as! MLTGridTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        //SET CONTENT IMAGE BOUNDS
        //cell.contentImage.frame = CGRect(x:0, 0, cell.cellView.bounds.width, cell.cellView.bounds.height - cell.cellView.bounds.height/4)
        
        cell.ownerImage.frame = CGRect(x:cell.contentImage.bounds.width/2 - 30,y: -30,width: 60,height: 60)
        cell.ownerImage.layer.borderColor = UIColor.white.cgColor
        cell.ownerImage.layer.borderWidth = 2.5
        cell.ownerImage.layer.cornerRadius = cell.ownerImage.frame.size.width / 2
        cell.ownerImage.backgroundColor = placeholderColor
        cell.ownerImage.contentMode = UIView.ContentMode.scaleAspectFill
        cell.ownerImage.layer.masksToBounds = true
        cell.ownerImage.image = UIImage(named: "user_profile_image.png")
        cell.ownerImage.tag = 321
        cell.ownerImage.isUserInteractionEnabled = true
        cell.ownerImage.isHidden = false
        
        //SET TITLE VIEW BOUNDS
        
        // TITLE VIEW IS BEING USED TO SHOW THE INFO ABOUT THE CONTENT
        cell.titleView.frame = CGRect(x:0, y:cell.contentImage.bounds.height,width: cell.cellView.bounds.width, height: cell.cellView.bounds.height/4 - 5)
        cell.titleView.backgroundColor = UIColor.white
        
        // SHOWS THE LINE GAP BETWEEN TWO ITEMS
        cell.lineView.isHidden = false
        
        //Hide price tag
        cell.contentName.isHidden = true
        
        // HIDE THE DATE VIEW
        cell.dateView.isHidden = true
        cell.dateLabel.isHidden = true
        
        
        cell.backgroundColor = tableViewBgColor
        cell.layer.borderColor = UIColor.white.cgColor
        
        var storeInfo:NSDictionary!
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            
            if(searchResponse.count > (row)*2 )
            {
                storeInfo = searchResponse[(row)*2] as! NSDictionary
                cell.contentSelection.tag = (row)*2
                cell.menu.tag = (row)*2
            }
            
        }
        else
        {
            storeInfo = searchResponse[row] as! NSDictionary
            cell.contentSelection.tag = row
            cell.menuButton.tag = row
        }
        
        cell.contentSelection.addTarget(self, action: #selector(StoresSearchResultsViewController.showStoreProfile(sender:)), for: .touchUpInside)
        cell.menuButton.addTarget(self, action:Selector(("showMyStoreMenu:")) , for: .touchUpInside)
        cell.contentSelection.frame = CGRect(x:0,y: 40,width: cell.cellView.bounds.width,height: cell.cellView.bounds.height)
        cell.contentSelection.frame.size.height = 180
        
        if let photoId = storeInfo["photo_id"] as? Int{
            
            if photoId != 0{
                
                cell.contentImage.backgroundColor = placeholderColor
                let url1 = NSURL(string: storeInfo["image"] as! NSString as String)

                     cell.contentImage.kf.indicatorType = .activity
                    (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.contentImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                    cell.contentImage.backgroundColor = placeholderColor
             //   }
                
            }
            else{
                cell.contentImage.image = nil
                cell.contentImage.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                
            }
        }
        
        if storeInfo["featured"] != nil && storeInfo["featured"] as! Int == 1{
            cell.featuredLabel.frame = CGRect(x:0,y: 0,width: 66,height: 20)
            cell.featuredLabel.isHidden = false
        }else{
            cell.featuredLabel.isHidden = true
        }
        
        if storeInfo["sponsored"] != nil && storeInfo["sponsored"] as! Int == 1{
            
            cell.sponsoredLabel.frame = CGRect(x:cell.contentImage.bounds.width - 75,y: 0,width: 75,height: 20)
            cell.sponsoredLabel.isHidden = false
        }else{
            cell.sponsoredLabel.isHidden = true
        }
        
        if let ownerPhotoUrl = storeInfo["owner_image"] as? String{
            
            if ownerPhotoUrl != ""{
                
                cell.ownerImage.backgroundColor = placeholderColor
                let url1 = NSURL(string: storeInfo["owner_image"] as! NSString as String)
                cell.ownerImage.kf.indicatorType = .activity
                (cell.ownerImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.ownerImage.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    
                })
                cell.ownerImage.backgroundColor = placeholderColor
            }
            else{
                cell.ownerImage.image = nil
                cell.ownerImage.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.ownerImage.bounds.width)
                
            }
        }
        
        let name = storeInfo["title"] as? String
        
        cell.titleLabel.frame = CGRect(x:0,y: 30,width: cell.titleView.bounds.width,height: 25)
        cell.titleLabel.text = "\(name!)"
        cell.titleLabel.textAlignment = .center
        cell.titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        var likeCount = 0
        if let tempCount = storeInfo["like_count"] as? Int{
            likeCount = tempCount
        }
        
        
        let likeText = singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: likeCount)
        
        let finalText = likeText
        
        cell.statsLabel.frame = CGRect(x:0,y: cell.titleLabel.frame.origin.y + cell.titleLabel.bounds.height,width: cell.titleView.bounds.width,height: 20)
        cell.statsLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        cell.statsLabel.text = String(format: NSLocalizedString(finalText, comment: ""))
        cell.statsLabel.textAlignment = .center
        cell.statsLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        cell.statsLabel.isHidden = false
        
        let storeCategory = storeInfo["category_title"] as? String
        
        if storeCategory != "" && storeCategory != nil{
            
            cell.locLabel.isHidden = false
            cell.locLabel.frame = CGRect(x:0,y: cell.statsLabel.frame.origin.y + cell.statsLabel.bounds.height, width: cell.contentImage.bounds.width,height: 25)
            cell.locLabel.text = "in \(storeCategory!)"
            cell.locLabel.textAlignment = .center
            cell.locLabel.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            
        }
        
        if storeCategory == "" || storeCategory == nil{
            cell.locLabel.isHidden = true
        }
        
        if(storeInfo["closed"] as! Int == 1){
            cell.closeIconView.frame = CGRect(x:cell.contentImage.bounds.width/2 - cell.contentImage.bounds.width/6, y: cell.contentImage.bounds.height/2 - cell.contentImage.bounds.height/6, width: cell.contentImage.bounds.width/3, height: cell.contentImage.bounds.height/3)
            cell.closeIconView.isHidden = false
            cell.closeIconView.text = "\(closedIcon)"
            cell.closeIconView.font = UIFont(name: "FontAwesome", size: cell.contentImage.bounds.width/6)
        }
        else{
            cell.closeIconView.isHidden = true
        }
        
        cell.likesLabel.frame = CGRect(x:cell.contentImage.bounds.width - 55, y: cell.contentImage.bounds.height - 50, width: 50, height: 20)
        cell.likesLabel.textAlignment = .right
        cell.likesLabel.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        cell.likesLabel.text = String(format: NSLocalizedString("\(likeCount) \(likeIcon)", comment: ""))
        
        
        
        cell.menuButton.isHidden = true
        
        
        // For Ipad
        if(UIDevice.current.userInterfaceIdiom == .pad){
            
            // SHOWS THE LINE GAP BETWEEN TWO ITEMS
            cell.lineView2.isHidden = false
            
            // Hide price tag
            cell.contentName2.isHidden = true
            
            // HIDE THE DATE VIEW
            cell.dateView2.isHidden = true
            cell.dateLabel2.isHidden = true
            
            cell.ownerImage2.frame = CGRect(x:cell.contentImage2.bounds.width/2 - 30, y: -30, width: 60, height: 60)
            cell.ownerImage2.layer.borderColor = UIColor.white.cgColor
            cell.ownerImage2.layer.borderWidth = 2.5
            cell.ownerImage2.layer.cornerRadius = cell.ownerImage2.frame.size.width / 2
            cell.ownerImage2.backgroundColor = placeholderColor
            cell.ownerImage2.contentMode = UIView.ContentMode.scaleAspectFill
            cell.ownerImage2.layer.masksToBounds = true
            cell.ownerImage2.image = UIImage(named: "user_profile_image.png")
            cell.ownerImage2.tag = 321
            cell.ownerImage2.isUserInteractionEnabled = true
            cell.ownerImage2.isHidden = false
            
            cell.titleView2.frame = CGRect(x:cell.titleView.bounds.width, y: cell.contentImage2.bounds.height, width: cell.cellView2.bounds.width, height: cell.cellView2.bounds.height/4 - 5)
            cell.titleView2.backgroundColor = UIColor.white
            
            
            var storeInfo2:NSDictionary!
            
            //Related to ads ??
            var adcount = Int()
            adcount = 0
            
            if(searchResponse.count > ((row)*2+1+adcount) ){
                storeInfo2 = searchResponse[((row)*2+1+adcount)] as! NSDictionary
                cell.cellView2.isHidden = false
                cell.contentSelection2.isHidden = false
                cell.titleView2.isHidden = false
                cell.contentSelection2.tag = ((row)*2+1+adcount)
                cell.menuButton2.tag = ((row)*2+1+adcount)
            }else{
                cell.cellView2.isHidden = true
                cell.contentSelection2.isHidden = true
                cell.titleView2.isHidden = true
                return cell
            }
            
            // Set Menu Action
            cell.menuButton2.addTarget(self, action:Selector(("showMyStoreMenu:")) , for: .touchUpInside)
            
            // Select Action
            cell.contentSelection2.frame = CGRect(x:cell.cellView.bounds.width, y: 40, width: cell.cellView2.bounds.width, height: cell.cellView2.bounds.height)
            cell.contentSelection2.addTarget(self, action: #selector(StoresSearchResultsViewController.showStoreProfile(sender:)), for: .touchUpInside)
            cell.contentSelection2.frame.size.height = 180
            
            
            // Set Image
            if let photoId = storeInfo2["photo_id"] as? Int{
                
                if photoId != 0{
                    
                    cell.contentImage2.backgroundColor = placeholderColor
                    let url1 = NSURL(string: storeInfo2["image"] as! NSString as String)
                    
//                    if let img = imageCache[storeInfo2["image"] as! NSString as String] {
//                        cell.contentImage2?.image = img
//                    } else {
                  //      cell.contentImage2.image = nil
                         cell.contentImage2.kf.indicatorType = .activity
                    cell.contentImage2.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                    (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage2.backgroundColor = placeholderColor
              //      }
                    
                }
                else{
                    cell.contentImage2.image = nil
                    cell.contentImage2.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage2.bounds.width)
                    
                }
            }
            
            if storeInfo2["featured"] != nil && storeInfo2["featured"] as! Int == 1{
                cell.featuredLabel2.frame = CGRect(x:0, y: 0, width: 66, height: 20)
                cell.featuredLabel2.isHidden = false
            }else{
                cell.featuredLabel2.isHidden = true
            }
            
            if storeInfo2["sponsored"] != nil && storeInfo2["sponsored"] as! Int == 1{
                cell.sponsoredLabel2.frame = CGRect(x:cell.contentImage2.bounds.width - 75, y: 0, width: 75, height: 20)
                cell.sponsoredLabel2.isHidden = false
            }else{
                cell.sponsoredLabel2.isHidden = true
            }
            
            if let ownerPhotoUrl = storeInfo2["owner_image"] as? String{
                
                if ownerPhotoUrl != ""{
                    
                    cell.ownerImage2.backgroundColor = placeholderColor
                    let url1 = NSURL(string: storeInfo2["owner_image"] as! NSString as String)
                    cell.ownerImage2.kf.indicatorType = .activity
                    (cell.ownerImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.ownerImage2.kf.setImage(with: url1! as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                    cell.ownerImage2.backgroundColor = placeholderColor
                    
                }
                else{
                    cell.ownerImage2.image = nil
                    cell.ownerImage2.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.ownerImage2.bounds.width)
                    
                }
            }
            
            // Set Name
            let name = storeInfo2["title"] as? String
            cell.titleLabel2.frame = CGRect(x:0,y: 30, width: cell.titleView2.bounds.width,height: 25)
            cell.titleLabel2.text = "\(name!)"
            cell.titleLabel2.textAlignment = .center
            cell.titleLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
            
            var likeCount = 0
            if let tempCount = storeInfo2["like_count"] as? Int{
                likeCount = tempCount
            }
            
            
            let likeText = singlePluralCheck( NSLocalizedString(" Like", comment: ""),  plural: NSLocalizedString(" Likes", comment: ""), count: likeCount)
            
            let finalText = likeText
            
            cell.statsLabel2.frame = CGRect(x:0,y: cell.titleLabel2.frame.origin.y + cell.titleLabel2.bounds.height, width: cell.titleView2.bounds.width,height: 20)
            cell.statsLabel2.font = UIFont(name: fontName, size: FONTSIZENormal)
            cell.statsLabel2.text = String(format: NSLocalizedString(finalText, comment: ""))
            cell.statsLabel2.textAlignment = .center
            cell.statsLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
            cell.statsLabel2.isHidden = false
            
            //SHOWING CATEGORY
            let storeCategory = storeInfo2["category_title"] as? String
            
            //IF storeCategory EXISTS
            if storeCategory != "" && storeCategory != nil{
                
                cell.locLabel2.isHidden = false
                cell.locLabel2.frame = CGRect(x:0,y: cell.statsLabel2.frame.origin.y + cell.statsLabel2.bounds.height, width:cell.contentImage2.bounds.width,height: 25)
                cell.locLabel2.text = "in \(storeCategory!)"
                cell.locLabel2.textAlignment = .center
                cell.locLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                
            }
            
            //IF LOCATION DOES NOT EXISTS
            if storeCategory == "" || storeCategory == nil{
                cell.locLabel2.isHidden = true
            }
            
            if(storeInfo2["closed"] as! Int == 1){
                cell.closeIconView2.frame = CGRect(x: cell.contentImage2.bounds.width/2 - cell.contentImage2.bounds.width/6 ,y: cell.contentImage2.bounds.height/2 - cell.contentImage2.bounds.height/6,width: cell.contentImage2.bounds.width/3,height: cell.contentImage2.bounds.height/3)
                cell.closeIconView2.isHidden = false
                cell.closeIconView2.text = "\(closedIcon)"
                cell.closeIconView2.font = UIFont(name: "FontAwesome", size: cell.contentImage2.bounds.width/6)
            }
            else{
                cell.closeIconView2.isHidden = true
            }
            
            
            cell.likesLabel2.frame = CGRect(x: cell.contentImage2.bounds.width - 55, y:cell.contentImage2.bounds.height - 50, width: 50 , height: 20)
            cell.likesLabel2.textAlignment = .right
            cell.likesLabel2.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            cell.likesLabel2.text = String(format: NSLocalizedString("\(likeCount) \(likeIcon)", comment: ""))
            
            cell.menuButton2.isHidden = true
            
            
            cell.titleView2.frame.size.height = cell.locLabel2.frame.origin.y + cell.locLabel2.bounds.height
            dynamicHeight = cell.titleView2.frame.origin.y + cell.titleView2.bounds.height + 5
            cell.cellView2.frame.size.height = dynamicHeight
            cell.cellView.frame.size.height = dynamicHeight
            cell.lineView.frame.origin.y = dynamicHeight-5
            cell.lineView.frame.size.width = view.bounds.width/2
            cell.lineView2.frame.origin.y = dynamicHeight-5
            
            return cell
        }
        
        cell.titleView.frame.size.height = cell.locLabel.frame.origin.y + cell.locLabel.bounds.height
        dynamicHeight = cell.titleView.frame.origin.y + cell.titleView.bounds.height + 5
        cell.cellView.frame.size.height = dynamicHeight
        cell.lineView.frame.origin.y = dynamicHeight-5
        
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
                self.storesTableView.isHidden = true
                
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
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        var storeInfo:NSDictionary
        storeInfo = searchResponse[indexPath.row] as! NSDictionary
        
        if(storeInfo["allow_to_view"] as! Int == 1){
            if let name = storeInfo["title"] as? String
            {
                updateAutoSearchArray(str: name)
            }
            let presentedVC = StoresProfileViewController()
            presentedVC.storeId = "\(storeInfo["store_id"]!)"
            presentedVC.subjectType = "sitestore_store"
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        else
        {
            showToast(message: "You do not have permission to view this private page.", controller: self)
        }
        }
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if updateScrollFlag{
//            // Check for Page Number for Browse Stores
//            if storesTableView.contentOffset.y >= storesTableView.contentSize.height - storesTableView.bounds.size.height{
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
                // Check for Page Number for Browse Stores
//                if storesTableView.contentOffset.y >= storesTableView.contentSize.height - storesTableView.bounds.size.height{
                    if (limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            storesTableView.tableFooterView?.isHidden = false
                            browseEntries()
                        }
                    }
                    else
                    {
                        storesTableView.tableFooterView?.isHidden = true
                }
               // }
            }
            
        }
        }
    }
    
    @objc func cancel(){
        storeUpdate = false
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
                self.storesTableView.isHidden = true
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
    @objc func showStoreProfile(sender: UIButton){
        
        var storeInfo:NSDictionary!
        storeInfo = searchResponse[sender.tag] as! NSDictionary
        
        if(storeInfo["allow_to_view"] as! Int == 1){
            if let videoTitle = storeInfo["title"] as? String {
                updateAutoSearchArray(str: videoTitle)
            }
            let presentedVC = StoresProfileViewController()
            presentedVC.storeId = "\(storeInfo["store_id"]!)"
            presentedVC.subjectType = "sitestore_store"
            navigationController?.pushViewController(presentedVC, animated: true)
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
            presentedVC.serachFor = "Stores"
            presentedVC.url = "sitestore/search-form"
            presentedVC.contentType = "Stores"
            presentedVC.stringFilter = searchBar.text!
            navigationController?.pushViewController(presentedVC, animated: false)
            
        } else {
            let presentedVC = FilterSearchViewController()
            
            presentedVC.searchUrl = "sitestore/search-form"
            presentedVC.serachFor = "Stores"
            presentedVC.url = "sitestore/search-form"
            presentedVC.contentType = "Stores"
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
}
