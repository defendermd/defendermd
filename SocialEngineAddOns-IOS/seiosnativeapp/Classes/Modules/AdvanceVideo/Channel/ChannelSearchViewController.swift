//
//  ChannelSearchViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 24/06/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import NVActivityIndicatorView
import WebKit

class ChannelSearchViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate, TTTAttributedLabelDelegate,WKNavigationDelegate {
    var searchBar = UISearchBar()
    var channelTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var channelResponse = [AnyObject]()
    var updateScrollFlag = false
    var refresher:UIRefreshControl!             // Pull to refrresh
    var isPageRefresing = false                 // For Pagination
    var info:UILabel!
    var search : String!
    var browseOrMyVideo = true
    var searchPath = ""
   // var imageCache = [String:UIImage]()
    var leftBarButtonItem : UIBarButtonItem!
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    var viewSubview = UIView()
    
    override func viewDidLoad() {
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        super.viewDidLoad()
        
//        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Channels",  comment: ""))
//        searchBar.delegate = self
//        searchBar.backgroundColor = textColorclear
//        searchBar.setTextColor(textColorPrime)

        _ = SearchBarContainerView(self, customSearchBar:searchBar)

        searchBar.setPlaceholderWithColor(NSLocalizedString("Search Channels",  comment: ""))
        searchBar.delegate = self
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ChannelSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(ChannelSearchViewController.filter))
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        filter.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = filter
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        // Initialize Video Search Table
        channelTableView = UITableView(frame: CGRect(x: 0, y: 5,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        channelTableView.register(CustomTableViewCellThree.self, forCellReuseIdentifier: "CellThree")
        channelTableView.rowHeight = 235.0
        channelTableView.dataSource = self
        channelTableView.delegate = self
        channelTableView.isOpaque = false
        channelTableView.backgroundColor = tableViewBgColor
        channelTableView.separatorColor = TVSeparatorColorClear
        view.addSubview(channelTableView)
        channelTableView.isHidden = true
  
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        channelTableView.tableFooterView = footerView
        channelTableView.tableFooterView?.isHidden = true
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
    // Check for Video Search Update Every Time when View Appears
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
        channelTableView.tableFooterView?.isHidden = true
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
    

    @objc func cancel(){
        videosUpdate = false
        
        _ = self.navigationController?.popViewController(animated: false)
        
        
    }
    // Update Video Search
    func browseEntries()
    {
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            for ob in view.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            if (self.pageNumber == 1){
                self.channelResponse.removeAll(keepingCapacity: false)
                
                if updateAfterAlert == true || searchDic.count > 0 {
                    removeAlert()
                    self.channelTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
           //     spinner.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                   // activityIndicatorView.center = view.center
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
          //      activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            var parameters = [String:String]()

            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            // Send Server Request to Browse Blog Entries
            post(parameters, url: searchPath, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                   // self.tblAutoSearchSuggestions.isHidden = true
                    if self.tblAutoSearchSuggestions.isHidden == true
                    {
                        self.channelTableView.isHidden = false
                    }
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    if msg{
                        self.isPageRefresing = false
                        if succeeded["body"] != nil{
                            if let response = succeeded["body"] as? NSDictionary{
                                if let group = response["response"] as? NSArray {
                                    self.channelResponse = self.channelResponse + (group as [AnyObject])
                                }
                                if response["totalItemCount"] != nil{
                                    self.totalItems = response["totalItemCount"] as! Int
                                }
                            }
                        }
                        //Reload Video Search Tabel
                        self.channelTableView.reloadData()
                        
                        if self.channelResponse.count == 0{
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any channels. Get started by creating a new entry.", comment: ""), alignment: .center, textColor: textColorLight)
                            self.info.center = self.view.center
                            self.info.layer.cornerRadius = 25.0
                            self.info.layer.masksToBounds = true
                            self.info.backgroundColor = UIColor.black
                            self.info.tag = 1000
                            self.info.isHidden = true
                            self.view.addSubview(self.info)
                            showToast(message:NSLocalizedString("You do not have any channels. Get started by creating a new entry.", comment: ""), controller: self)
                            self.searchBar.resignFirstResponder()
                        }
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
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
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    // Stop Timer
    @objc func stopTimer()
    {
        stop()
    }
    // MARK: - Table View Delegates
    
    // Set Video Search Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Video Search Tabel Header Height
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
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 122{
            return dynamicHeightAutoSearch
        }else{
            return 235.0
        }
    }
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else
        {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return Int(ceil(Float(channelResponse.count)/2))
        }else{
            return channelResponse.count
        }
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
            //{
                cell.imgSearch.isHidden = false
                cell.labTitle.frame = CGRect(x: cell.imgSearch.bounds.width + 24, y: 0,width: UIScreen.main.bounds.width - (cell.imgSearch.bounds.width + 24), height: 45)
                // cell.labTitle.center.y = cell.bounds.midY + 5
                cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
                cell.labTitle.text = blogInfo
                cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.labTitle.numberOfLines = 2
                //  cell.labTitle.sizeToFit()
            //}
            cell.imgUser.isHidden = true
            return cell
        }
        else
        {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath) as! CustomTableViewCellThree
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = tableViewBgColor
        
        var videosInfo:NSDictionary!
        if(UIDevice.current.userInterfaceIdiom == .pad){
            if(channelResponse.count > ((indexPath as NSIndexPath).row)*2 ){
                videosInfo = channelResponse[((indexPath as NSIndexPath).row)*2] as! NSDictionary
                cell.contentSelection.tag = ((indexPath as NSIndexPath).row)*2
                
            }
        }else{
            videosInfo = channelResponse[(indexPath as NSIndexPath).row] as! NSDictionary
            cell.contentSelection.tag = (indexPath as NSIndexPath).row
            
        }
        
        //Select Video Action
        cell.contentSelection.addTarget(self, action: #selector(ChannelSearchViewController.showVideo(_:)), for: .touchUpInside)
        cell.imgVideo.addTarget(self, action: #selector(ChannelSearchViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
        cell.imgVideo.tag = cell.contentSelection.tag
        cell.contentImage.frame.size.height = 180
        cell.contentSelection.frame.size.height = 180
        // Set Video Image
        // Set Video Image
            if let imgeMain = videosInfo["video_overlay_image"] as? [String : AnyObject], let url = URL(string: imgeMain["url"] as? String ?? "")
            {
                cell.imgViewOverLay.kf.indicatorType = .activity
                (cell.imgViewOverLay.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgViewOverLay.kf.setImage(with: url, placeholder: UIImage(named : ""), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
            }
            else
            {
                cell.imgViewOverLay.image = UIImage(named: "")
            }
            
        if (videosInfo["image"] as? String) != nil
        {
            let url  = URL(string: videosInfo["image"] as! NSString as String)
             cell.contentImage.kf.indicatorType = .activity
            (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.contentImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
            
        }
        else
        {
            cell.contentImage.image = UIImage(named: "nophoto_group_thumb_profile.png")!
        }

        // Set Video Name
        let videoscount = videosInfo["videos_count"] as? Int

        cell.videoDuration.isHidden = false
        if videoscount == 1
        {
            cell.videoDuration.text = "\(videoscount!) Video"
        }
        else
        {
            cell.videoDuration.text = "\(videoscount!) Videos"
        }
        cell.contentName.frame = CGRect(x: (cell.contentImage.bounds.width - 50), y: 110, width: (cell.contentImage.bounds.width-100), height: 10)
        cell.contentName.font = UIFont(name: fontName, size: FONTSIZESmall)
        cell.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.contentName.sizeToFit()
        cell.contentName.frame.origin.y = (cell.contentImage.bounds.height - (cell.contentName.bounds.height+10))
        
        // Set Video Info
        
        cell.createdBy.frame = CGRect(x: contentPADING , y: cell.contentImage.bounds.height, width: cell.cellView.bounds.width - (cell.cellView.bounds.height - cell.contentImage.bounds.height), height: cell.cellView.bounds.height - cell.contentImage.bounds.height)
        
        var tempInfo = ""
        
        var value = ""
        if let videoTitle = videosInfo["title"] as? NSString {
            if videoTitle.length > 32{
                value = videoTitle.substring(to: 32-3)
                value += NSLocalizedString("...",  comment: "")
            }else{
                value = "\(videoTitle)"
            }
        }
        
        tempInfo = "\(value)\n"
        tempInfo = "\(tempInfo)"
        let postedDate = videosInfo["creation_date"] as? String
        let postedOn = dateDifference(postedDate!)
        tempInfo += String(format: NSLocalizedString("%@", comment:""),postedOn)
        cell.createdBy.delegate = self
        cell.createdBy.textAlignment = .left
        cell.createdBy.textColor = textColorMedium
        cell.createdBy.numberOfLines = 0
        
        cell.createdBy.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
            let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
            
            let range = (tempInfo as NSString).range(of: value)
            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
            
            // TODO: Clean this up...
            
            return mutableAttributedString
        })
        // Set Like , Comment & ViewCount
        
        var totalView = ""
        if let ratingCount = videosInfo["rating_count"] as? Int{
            totalView = "\(ratingCount) \(starIcon)"
        }
        if let likes = videosInfo["like_count"] as? Int{
            totalView += " \(likes) \(likeIcon)"
        }
        if let comment = videosInfo["comment_count"] as? Int{
            totalView += " \(comment) \(commentIcon)"
        }
        cell.totalMembers.textColor = textColorMedium
        cell.totalMembers.text = "\(totalView)"
        cell.totalMembers.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
        
        // Set Menu
        if(isIpad()){
            
            if browseOrMyVideo {
                cell.menu.isHidden = true
                cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 95)
                cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage.bounds.height, width: 95
                    , height: 40)
                
            }else{
                cell.menu.isHidden = false
                cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 95)
                //            cell.totalMembers.frame = CGRect(x:(CGRectGetWidth(cell.createdBy.bounds) + cell.createdBy.frame.origin.x + 5 - 10), CGRectGetHeight(cell.contentImage.bounds) + 5 , 110, 40)
                cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage.bounds.height , width: 95, height: 30)
            }
            
        }
        else{
            if browseOrMyVideo {
                cell.menu.isHidden = true
                cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 90)
                cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 90,y: cell.contentImage.bounds.height, width: 90
                    , height: 40)
                
            }else{
                cell.menu.isHidden = false
                cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 90)
                cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 90,y: cell.contentImage.bounds.height , width: 90, height: 30)
            }
            
        }
        
        // RHS
        if(isIpad()){
            var videosInfo2:NSDictionary!
            if(channelResponse.count > (((indexPath as NSIndexPath).row)*2+1) ){
                videosInfo2 = channelResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
                cell.cellView2.isHidden = false
                cell.contentSelection2.isHidden = false
                cell.contentSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
            }else{
                cell.cellView2.isHidden = true
                cell.contentSelection2.isHidden = true
                return cell
            }
            
            // Select Video Action
            cell.contentSelection2.addTarget(self, action: #selector(ChannelSearchViewController.showVideo(_:)), for: .touchUpInside)
            
            cell.contentImage2.frame.size.height = 180
            cell.contentSelection2.frame.size.height = 180
            // Set Video Image
            if (videosInfo2["video_overlay_image"] as? String) != nil
            {
                let url  = URL(string: videosInfo["video_overlay_image"] as! NSString as String)
                cell.imgViewOverLay2.kf.indicatorType = .activity
                (cell.imgViewOverLay2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.imgViewOverLay2.kf.setImage(with: url, placeholder: UIImage(named : ""), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
            }
            else
            {
                cell.imgViewOverLay2.image = UIImage(named: "")!
            }
            if (videosInfo2["image"] as? String) != nil
            {
                let url  = URL(string: videosInfo2["image"] as! NSString as String)
                 cell.contentImage.kf.indicatorType = .activity
                (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.contentImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
                
            }
            else
            {
                cell.contentImage2.image = UIImage(named: "nophoto_group_thumb_profile.png")!
            }
  
            // Set Video Duration
            let videoscount = videosInfo2["videos_count"] as? Int
            let durationString = timeFormatted(videoscount!) as String
            cell.videoDuration2.isHidden = false
            cell.videoDuration2.text = "\(durationString)"
            cell.contentName2.frame = CGRect(x: (cell.contentImage2.bounds.width - 50), y: 110, width: (cell.contentImage2.bounds.width-100), height: 10)
            cell.contentName2.font = UIFont(name: fontName, size: FONTSIZESmall)
            //            cell.contentName2.text = timeFormatted(duration!)
            cell.contentName2.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.contentName2.sizeToFit()
            cell.contentName2.frame.origin.y = (cell.contentImage2.bounds.height - (cell.contentName2.bounds.height+10))
            // Set Video Info
            cell.createdBy2.frame = CGRect(x: contentPADING , y: cell.contentImage2.bounds.height, width: cell.cellView2.bounds.width - (cell.cellView2.bounds.height - cell.contentImage2.bounds.height), height: cell.cellView2.bounds.height - cell.contentImage2.bounds.height)
            var value2 = ""
            if let videoTitle2 = videosInfo2["title"] as? NSString {
                if videoTitle2.length > 25{
                    value2 = videoTitle2.substring(to: 25 - 3)
                    value2 += NSLocalizedString("...",  comment: "")
                }else{
                    value2 = "\(videoTitle2)"
                }
            }
            
            tempInfo = "\(value2)\n"
            let postedDate2 = videosInfo2["creation_date"] as? String
            let postedOn2 = dateDifference(postedDate2!)
            tempInfo += String(format: NSLocalizedString("%@", comment:""),postedOn2)
            cell.createdBy2.delegate = self
            cell.createdBy2.textAlignment = .left
            cell.createdBy2.textColor = textColorMedium
            cell.createdBy2.numberOfLines = 0
            
            cell.createdBy2.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                let range = (tempInfo as NSString).range(of: value2)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                let boldFont1 = CTFontCreateWithName( (fontName as CFString?)!, FONTSIZESmall, nil)
                let range1 = (tempInfo as NSString).range(of: postedOn2)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)
                
                // TODO: Clean this up...
                
                return mutableAttributedString
            })
            
            var totalView = ""
            
            if let ratingCount = videosInfo2["rating_count"] as? Int{
                totalView = "\(ratingCount) \(starIcon)"
            }
            if let likes = videosInfo2["like_count"] as? Int{
                totalView += " \(likes) \(likeIcon)"
            }
            if let comment = videosInfo2["comment_count"] as? Int{
                totalView += " \(comment) \(commentIcon)"
            }
            cell.totalMembers2.text = "\(totalView)"
            cell.totalMembers2.textColor = textColorMedium
            cell.totalMembers2.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
            
            //   Set Menu
            if browseOrMyVideo {
                cell.menu2.isHidden = true
                cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)
            }else{
                cell.menu2.isHidden = false
                cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
                cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height , width: 95, height: 40)
            }
        }
        return cell
        }
        
    }
    // Handle Video Search Table Cell Selection
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
                self.channelTableView.isHidden = true
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
                // Check for Page Number for Browse Video Search
//                if channelTableView.contentOffset.y >= channelTableView.contentSize.height - channelTableView.bounds.size.height{
                    if (limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            channelTableView.tableFooterView?.isHidden = false
                            browseEntries()
                        }
                    }
                    else
                    {
                        channelTableView.tableFooterView?.isHidden = true
                }
              //  }
            }
            
        }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
        showSpinner = true
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
                self.channelTableView.isHidden = true
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
    // MARK: - Filter Search
    @objc func filter(){
        if filterSearchFormArray.count > 0{
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "video"
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else
        {
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "advancedvideos/search-form"
            presentedVC.serachFor = "video"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    // MARK: - Show Video
    @objc func showVideo(_ sender:UIButton){
        var videoInfo:NSDictionary!
        videoInfo = channelResponse[sender.tag] as! NSDictionary

        if(videoInfo["allow_to_view"] as! Int == 1){
            if let videoTitle = videoInfo["title"] as? String {
                updateAutoSearchArray(str: videoTitle)
            }
            let presentedVC = ChannelProfileViewController()
            presentedVC.subjectId = "\(videoInfo["channel_id"]!)"
            presentedVC.subjectType = "sitevideo_channel"
            navigationController?.pushViewController(presentedVC, animated: true)
        }else{
            showToast(message:NSLocalizedString("You do not have permission to view this private page.", comment: ""), controller: self)
        }
    }
    // MARK: Video Icon Action
    @objc func btnVideoIconClicked(_ sender: UIButton)
    {
        var videoInfo:NSDictionary!
        videoInfo = channelResponse[sender.tag] as! NSDictionary
        
        let attachment_video_type = videoInfo["type"] as? Int ?? 0
        let attachment_video_url = videoInfo["video_url"] as? String ?? ""
        let attachment_video_code = videoInfo["code"] as? String ?? ""
        
        if(videoInfo["allow_to_view"] as! Int == 1){
            
            implemnetPlayer(videoType: attachment_video_type, videoURL: attachment_video_url, videoCode: attachment_video_code, sender : sender)
        }else{
             showToast(message:NSLocalizedString("You do not have permission to view this private page.", comment: ""), controller: self)
        }
        
        
    }
    @objc func btnVideoIconClosedAction()
    {
        let window = UIApplication.shared.keyWindow!
        if let view = window.viewWithTag(200123)
        {
            view.alpha = 0.0
            window.viewWithTag(200123)?.removeFromSuperview()
            //            UIView.animate(withDuration: 0.5, animations: {
            //                view.alpha = 0.0
            //            }) { (isComplete) in
            //                window.viewWithTag(200123)?.removeFromSuperview()
            //            }
        }
        player?.pause()
        player?.replaceCurrentItem(with: nil)
    }
    var originalPosition = CGPoint(x: 0, y: 0)
    var player : AVPlayer?
    // MARK: - Player & Webview Implimentation
    func implemnetPlayer(videoType : Int, videoURL : String, videoCode : String, sender : UIButton)
    {
        if videoType == 3
        {
            if let url = URL(string:videoURL)
            {
                player = AVPlayer(url: url)
                let vc = AVPlayerViewController()
                vc.player = player
                
                present(vc, animated: true) {
                    vc.player?.play()
                }
            }
            
        }
        else
        {
            let window = UIApplication.shared.keyWindow!
            viewSubview = UIView(frame:CGRect(x: 0 , y: 0, width: self.view.bounds.width, height: self.view.bounds.height + tabBarHeight + TOPPADING))
            viewSubview.backgroundColor = .black
            viewSubview.tag = 200123
            viewSubview.alpha = 0
            let imageButton = createButton(CGRect(x: -10,y: 10 ,width: 100 , height:100) , title: "Close", border: false, bgColor: false, textColor: textColorLight)
            imageButton.addTarget(self, action: #selector(self.btnVideoIconClosedAction), for: .touchUpInside)
            //  viewSubview.addSubview(imageButton)
            
            var playerHeight: CGFloat = 800
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                playerHeight = 500
            }
            self.navigationItem.rightBarButtonItem = nil
            playerHeight += TOPPADING - contentPADING
            
            var videoWebView = WKWebView()
            videoWebView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height )
            
            
            let configuration = WKWebViewConfiguration()
            if #available(iOS 10.0, *) {
                configuration.mediaTypesRequiringUserActionForPlayback = []
            }
            configuration.allowsInlineMediaPlayback = true
            videoWebView = WKWebView(frame: videoWebView.frame, configuration: configuration)
            //videoWebView.center = viewSubview.convert(viewSubview.center, from:viewSubview.superview)
            videoWebView.isOpaque = false
            //WKAudiovisualMediaTypeNone = 0
            videoWebView.backgroundColor = UIColor.black
            videoWebView.scrollView.bounces = false
            videoWebView.allowsLinkPreview = false
            videoWebView.navigationDelegate = self
            let jeremyGif = UIImage.gifWithName("progress bar")
            // Use the UIImage in your UIImageView
            let imageView = UIImageView(image: jeremyGif)
            imageView.tag = 2002134
            imageView.frame = CGRect(x: view.bounds.width/2 - 60,y: self.view.bounds.height/2 ,width: 120, height: 7)
            
            var url = ""
            if videoURL.length != 0
            {
                let videoUrl1 : String = videoURL
                let find = videoUrl1.contains("http")
                if videoType == 1 || videoType == 2 || videoType == 4 || videoType == 5 && find == false{
                    
                    url = "https://" + videoURL
                }
                else
                {
                    url = videoURL
                }
            }
            
            if let videoURL =  URL(string:url){
                var request = URLRequest(url: videoURL)
                if videoType == 1 {
                    request.setValue("http://www.youtube.com", forHTTPHeaderField: "Referer")
                }
                videoWebView.load(request)
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch _ as NSError {
                    //print(error)
                }
                
            }
            else
            {
                if videoType == 6
                {
                    if videoUrl != nil {
                        videoWebView.loadHTMLString(videoUrl, baseURL: nil)
                    }
                }
            }
            
//            if let videoURL =  URL(string:url)
//            {
//                var request = URLRequest(url: videoURL)
//                if videoType == 1 {
//                    request.setValue("http://www.youtube.com", forHTTPHeaderField: "Referer")
//                    let embededHTML = "<html><body style='margin:0px;padding:0px;'><script type='text/javascript' src='http://www.youtube.com/iframe_api'></script><script type='text/javascript'>function onYouTubeIframeAPIReady(){ytplayer=new YT.Player('playerId',{events:{onReady:onPlayerReady}})}function onPlayerReady(a){a.target.playVideo();}</script><iframe id='playerId' type='text/html' width='\(view.frame.size.width)' height='\(view.frame.size.height - TOPPADING - 30)' src='http://www.youtube.com/embed/\(videoCode)?enablejsapi=1&rel=0&playsinline=1&autoplay=1' frameborder='0'></body></html>"
//                    let videoURLYouTube =  URL(string:"http://www.youtube.com")
//                    videoWebView.loadHTMLString(embededHTML, baseURL: videoURLYouTube)
//                }
//                else
//                {
//                    // videoWebView.frame.origin.y = viewSubview.bounds.height/8
//                    // videoWebView.center = window.convert(window.center, from:window.superview)
//                    // videoWebView.center = CGPoint(x: viewSubview.bounds.midX,                                                  y: viewSubview.bounds.midY - (playerHeight/6))
//                    videoWebView.center = view.convert(view.center, from:view.superview)
//                    videoWebView.loadRequest(request)
//                }
//
//                do {
//                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
//                    try AVAudioSession.sharedInstance().setActive(true)
//                } catch _ as NSError {
//                    //print(error)
//                }
//
//            }
//            else
//            {
//                if videoType == 6
//                {
//                    videoWebView.loadHTMLString(videoURL, baseURL: nil)
//                }
//            }
            viewSubview.addSubview(videoWebView)
            videoWebView.addSubview(imageView)
            
            
            window.addSubview(viewSubview)
            originalPosition = self.viewSubview.center
            
            viewSubview.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(onDrage(_:))))
            
            UIView.animate(withDuration: 0.5, animations: {
                self.viewSubview.alpha = 1.0
            }, completion: nil)
            
        }
        
        
    }
    
    @objc func onDrage(_ panGesture: UIPanGestureRecognizer) {
        let translation = panGesture.translation(in: viewSubview)
        
        if panGesture.state == .changed {
            viewSubview.frame.origin = CGPoint(
                x:  viewSubview.frame.origin.x,
                y:  viewSubview.frame.origin.y + translation.y
            )
            panGesture.setTranslation(CGPoint.zero, in: self.viewSubview)
        } else if panGesture.state == .ended {
            let velocity = panGesture.velocity(in: viewSubview)
            if velocity.y >= 150 {
                UIView.animate(withDuration: 0.2
                    , animations: {
                        self.viewSubview.frame.origin = CGPoint(
                            x: self.viewSubview.frame.origin.x,
                            y: self.viewSubview.frame.size.height
                        )
                }, completion: { (isCompleted) in
                    if isCompleted {
                        self.btnVideoIconClosedAction()
                        // self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.viewSubview.center = self.originalPosition
                })
            }
        }
    }
    
    // MARK: - WebView delegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("didStartProvisionalNavigation - webView.url: \(String(describing: webView.url?.description))")
        if let imgView = webView.viewWithTag(2002134)
        {
            imgView.isHidden = false
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish - webView.url: \(String(describing: webView.url?.description))")
        if let imgView = webView.viewWithTag(2002134)
        {
            imgView.isHidden = true
        }
    }
}

