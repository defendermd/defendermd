//
//  AdvancvideoCategoryDetailViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 18/06/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import NVActivityIndicatorView
import WebKit

class AdvancvideoCategoryDetailViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,WKNavigationDelegate {

    var contentType : String = ""
    var tittle: String!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var updateScrollFlag = true
    var subjectId:Int!
    var subjectType:String!
    var subcatid:Int!
    var subsubcatid:Int!
    var totalItemCount:Int!
    var videoTypeCheck = ""
    
    var advVideoTableView:UITableView!
    var videosResponse = [AnyObject]()
    var refresher:UIRefreshControl!
    var refreshButton : UIButton!
    var contentIcon : UILabel!
    var feedFilter: UIButton!
    var feedFilter2: UIButton!
    var subcategory: String!
    var subsubcategory: String!
   // var imageCache = [String:UIImage]()
    var popAfterDelay : Bool!
    var leftBarButtonItem : UIBarButtonItem!
    


    var Subcategoryarr = [AnyObject]()
    var SubSubcategoryarr = [AnyObject]()
    var showSpinner = true
    var isPageRefresing = false
    var info:UILabel!
    
    var categoryType : String = ""
    
    var contentGutterMenu: NSArray = []
    var deleteContent : Bool!
    var contentTitle : String!
    var contentDescription : String!
    
    var shareUrl : String!
    var shareParam : NSDictionary!
    var canInviteEventOrGroup = false
    var viewSubview = UIView()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        productUpdate = false
        subcategory = ""
        subsubcategory = ""
        globFilterValue = ""
        openMenu = false
        updateAfterAlert = true
        evetUpdate = true
        pageNumber = 1
        updateScrollFlag = false
        self.view.backgroundColor = textColorLight
        // UI Implementaion
        designUI()
     
        // Server calling
        browseEntries()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        self.title = NSLocalizedString(tittle!,comment: "")
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvancvideoCategoryDetailViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        advVideoTableView.tableFooterView?.isHidden = true
        categoryType = ""
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    // MARK:Back Action
    @objc func goBack()
    {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        _ = self.navigationController?.popViewController(animated: false)
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        return true
    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true
        {
            _ = self.navigationController?.popViewController(animated: false)
            
        }
        
    }
    // MARK:UI Implementaion
    func designUI()
    {
        // Set tableview to show events
        advVideoTableView = UITableView(frame: CGRect(x: 0, y: 3, width: view.bounds.width,height: view.bounds.height - 3 - tabBarHeight), style: .grouped)
        advVideoTableView.register(CustomTableViewCellThree.self, forCellReuseIdentifier: "Cell")
        advVideoTableView.dataSource = self
        advVideoTableView.delegate = self
        advVideoTableView.isOpaque = false
        advVideoTableView.backgroundColor = tableViewBgColor
        advVideoTableView.separatorColor = TVSeparatorColorClear
        self.automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            advVideoTableView.sectionHeaderHeight = 0
        }
        self.view.addSubview(advVideoTableView)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        advVideoTableView.tableFooterView = footerView
        advVideoTableView.tableFooterView?.isHidden = true
        
        // Set pull to referseh for advVideoTableView
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(AdvancvideoCategoryDetailViewController.refresh), for: UIControl.Event.valueChanged)
        advVideoTableView.addSubview(refresher)
        
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        self.view.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        self.view.addSubview(refreshButton)
        refreshButton.isHidden = true

    }
    
    // MARK: -  Pull to Request Action
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
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    // MARK: - Cover Image Selection
    @objc func showVideo(_ sender:UIButton)
    {
        
        var videoInfo:NSDictionary!
        videoInfo = videosResponse[sender.tag] as! NSDictionary
        if(videoInfo["allow_to_view"] as! Int == 1){
            let presentedVC = AdvanceVideoProfileViewController()//GroupDetailViewController()
            
            if self.videoTypeCheck == "AdvEventVideo"{
                presentedVC.videoProfileTypeCheck = "AdvEventProfile"
            }
            else if self.videoTypeCheck == "sitegroup"{
                presentedVC.videoProfileTypeCheck = "sitegroupvideo"
                presentedVC.event_id = videoInfo["group_id"] as! Int
            }
            else{
                presentedVC.videoProfileTypeCheck = ""
            }
            presentedVC.videoId = videoInfo["video_id"] as! Int
            presentedVC.videoType = videoInfo["type"] as? Int
            if  videoInfo["type"] as! Int == 3 || videoInfo["type"] as! Int == 2 || videoInfo["type"] as! Int == 1 || videoInfo["type"] as! Int == 4 ||  videoInfo["type"] as! Int == 5 || videoInfo["type"] as! Int == 6
            {
                if let url = videoInfo["video_url"] as? String
                {
                    presentedVC.videoUrl = url
                }
            }
            else
            {
                presentedVC.videoUrl = videoInfo["content_url"] as! String
            }
            
            if self.videoTypeCheck == "AdvEventVideo"{
                presentedVC.event_id = videoInfo["event_id"] as! Int
            }
            let navigationController = UINavigationController(rootViewController: presentedVC)
            self.present(navigationController, animated:true, completion: nil)
        }else{
            showToast(message: NSLocalizedString("You do not have permission to view this private page.",comment: ""), controller: self)
        }
        
    }
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

            if (limit*pageNumber < totalItems){
                return 0
            }else{
                return 0.00001
            }
        
    }
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return 0.00001
    }

    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {

            if(isIpad()){
                return Int(ceil(Float(videosResponse.count)/2))
            }else{
                return videosResponse.count
            }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 235
        
    }

    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let row = (indexPath as NSIndexPath).row as Int
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCellThree
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = tableViewBgColor
        var videosInfo:NSDictionary!
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
                if(videosResponse.count > (row)*2)
                {
                    videosInfo = videosResponse[(row)*2] as! NSDictionary
                    cell.contentSelection.tag = (row)*2
                    cell.menu.tag = (row)*2
                    
                }
        }
        else
        {
            videosInfo = videosResponse[row] as! NSDictionary
            cell.contentSelection.tag = row
            cell.menu.tag = row
        }
        
        //Select Video Action
        cell.contentSelection.addTarget(self, action: #selector(AdvancvideoCategoryDetailViewController.showVideo(_:)), for: .touchUpInside)
        cell.imgVideo.addTarget(self, action: #selector(AdvancvideoCategoryDetailViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
        cell.imgVideo.tag = cell.contentSelection.tag
        // Set MenuAction
        cell.contentImage.frame.size.height = 180
        //        cell.contentSelection.frame.size.height = 180
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
        if let photoId = videosInfo["photo_id"] as? Int{
            
            if photoId != 0{
                cell.contentImage.image = nil
                cell.contentImage.backgroundColor = placeholderColor
                let url = URL(string: videosInfo["image"] as! NSString as String)
                
                if  url != nil {

                    cell.contentImage.kf.indicatorType = .activity
                    (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.contentImage.kf.setImage(with: url, placeholder: UIImage(named : "nophoto_group_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        cell.contentImage.backgroundColor = UIColor.clear
                    })
                }
                
            }else{
                cell.contentImage.image = nil
                cell.contentImage.image = UIImage(named: "nophoto_group_thumb_profile.png")!
                
            }
        }

        
        // Set Video Name
        let duration = videosInfo["duration"] as? Int
        let durationString = timeFormatted(duration!) as String
        cell.videoDuration.isHidden = false
        cell.videoDuration.text = "\(durationString)"
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
        }else if videosInfo["title"] is NSNumber{
            let videoTitle = String(describing: videosInfo["title"]!) as NSString
            
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
        
        let date = dateDifferenceWithEventTime(postedDate!)
        var DateC = date.components(separatedBy: ", ")
        tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
        if DateC.count > 3{
            tempInfo += " at \(DateC[3])"
        }
        cell.createdBy.textAlignment = .left
        cell.createdBy.textColor = textColorMedium
        cell.createdBy.numberOfLines = 0
        cell.createdBy.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
            let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
            
            let range = (tempInfo as NSString).range(of: value)
            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
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
            totalView += " \(comment) \(viewIcon)"
        }
        cell.totalMembers.textColor = textColorMedium
        cell.totalMembers.text = "\(totalView)"
        cell.totalMembers.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
        
        // Set Menu
        if(isIpad()){
            
                cell.menu.isHidden = true
                cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 95)
                //
                cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage.bounds.height, width: 95
                    , height: 40)

            
        }
        else{

                cell.menu.isHidden = true
                cell.createdBy.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy.frame.origin.x + 90)
                cell.totalMembers.frame = CGRect(x: cell.cellView.bounds.width - 90,y: cell.contentImage.bounds.height, width: 90
                    , height: 40)

            
        }
        
        // RHS
        if(isIpad()){
            var videosInfo2:NSDictionary!
            var adcount = Int()
            adcount = 0
            if(videosResponse.count > ((row)*2+1+adcount))
            {
                
                videosInfo2 = videosResponse[((row)*2+1+adcount)] as! NSDictionary
                cell.cellView2.isHidden = false
                cell.contentSelection2.isHidden = false
                cell.contentSelection2.tag = ((row)*2+1+adcount)
                cell.menu2.tag = ((row)*2+1+adcount)
            }
            else
            {
                cell.cellView2.isHidden = true
                cell.contentSelection2.isHidden = true
                return cell
            }
            
            // Select Video Action
            cell.contentSelection2.addTarget(self, action: #selector(AdvancvideoCategoryDetailViewController.showVideo(_:)), for: .touchUpInside)
            cell.imgVideo2.addTarget(self, action: #selector(AdvancvideoCategoryDetailViewController.btnVideoIconClicked(_:)), for: .touchUpInside)
            cell.imgVideo2.tag = cell.contentSelection2.tag
            
            // Set MenuAction
            cell.contentImage2.frame.size.height = 180
            
            if let photoId = videosInfo2["photo_id"] as? Int{
                if photoId != 0{
                    cell.contentImage2.image = nil
                    let url = URL(string: videosInfo2["image"] as! NSString as String)
                    
                    if  url != nil {
                        cell.contentImage2.kf.indicatorType = .activity
                        (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage2.kf.setImage(with: url, placeholder: UIImage(named : "nophoto_group_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            cell.contentImage2.backgroundColor = UIColor.clear
                        })
                    }
                }else{
                    
                    cell.contentImage2.image = UIImage(named: "nophoto_group_thumb_profile.png")!
                }
            }
            
            // Set Video Duration
            let duration = videosInfo2["duration"] as? Int
            let durationString = timeFormatted(duration!) as String
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
            }else if videosInfo2["title"] is NSNumber{
                let videoTitle2 = String(describing: videosInfo2["title"]!) as NSString
                
                if videoTitle2.length > 25{
                    value2 = videoTitle2.substring(to: 25 - 3)
                    value2 += NSLocalizedString("...",  comment: "")
                }else{
                    value2 = "\(videoTitle2)"
                }
                
                
            }
            
            tempInfo = "\(value2)\n"
            tempInfo = "\(tempInfo)\n"
            let postedDate2 = videosInfo2["creation_date"] as? String
            
            let date = dateDifferenceWithEventTime(postedDate2!)
            var DateC = date.components(separatedBy: ", ")
            tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
            if DateC.count > 3{
                tempInfo += " at \(DateC[3])"
            }

            cell.createdBy2.textAlignment = .left
            cell.createdBy2.textColor = textColorMedium
            cell.createdBy2.numberOfLines = 0
            
            cell.createdBy2.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                let boldFont = CTFontCreateWithName((fontName as CFString?)!, FONTSIZELarge, nil)
                let range = (tempInfo as NSString).range(of: value2)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                
                
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
            cell.totalMembers2.sizeToFit()
            //   Set Menu
            
            cell.menu2.isHidden = true
            cell.createdBy2.frame.size.width = cell.cellView.bounds.width -  (cell.createdBy2.frame.origin.x + 95)
            cell.totalMembers2.frame = CGRect(x: cell.cellView.bounds.width - 95,y: cell.contentImage2.bounds.height, width: 95, height: 40)

        }
        return cell
        
        
        
        
        
    }
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView)
//    {
//
//        if updateScrollFlag{
//
//            // Check for Page Number for Browse Video
//
//                if advVideoTableView.contentOffset.y >= advVideoTableView.contentSize.height - advVideoTableView.bounds.size.height{
//                    if (!isPageRefresing  && limit*pageNumber < totalItems){
//                        if Reachabable.isConnectedToNetwork() {
//                            updateScrollFlag = false
//                            pageNumber += 1
//                            isPageRefresing = true
//                            browseEntries()
//
//                        }
//                    }
//
//                }
//
//        }
//
//    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
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
                        advVideoTableView.tableFooterView?.isHidden = false
                        browseEntries()
                        
                    }
                }
                else
                {
                    advVideoTableView.tableFooterView?.isHidden = true
                }
                
            }
            
        }
        
    }
    //MARK: Category filter
    @objc func showFeedFilterOptions(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        let alertController = UIActionSheet(title:"Choose sub category", delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), destructiveButtonTitle: nil)
        alertController.tag = 0
        for menu in Subcategoryarr
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
    
    @objc func showFeedFilterOptions1(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        
        
        let alertController = UIActionSheet(title:"Choose Subsub category", delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), destructiveButtonTitle: nil)
        alertController.tag = 1
        for menu in SubSubcategoryarr
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
                
                let subcat = Subcategoryarr[buttonIndex-1] as! NSDictionary
                subcatid = subcat["sub_cat_id"] as! Int
                feedFilter.setTitle(subcat["sub_cat_name"] as? String, for: UIControl.State())
                subcategory = subcat["sub_cat_name"] as? String
                subsubcategory = ""
                subsubcatid = nil
                self.showSpinner = true
                browseEntries()
                
            }
            
        }
        else
        {
            if buttonIndex != 0
            {
                let subcat = SubSubcategoryarr[buttonIndex-1] as! NSDictionary
                subsubcatid = subcat["tree_sub_cat_id"] as! Int
                feedFilter2.setTitle(subcat["tree_sub_cat_name"] as? String, for: UIControl.State())
                subsubcategory = subcat["tree_sub_cat_name"] as? String
                self.showSpinner = true
                browseEntries()
                
            }
            
        }
        
    }
    // MARK: - Server Connection For Event Updation
    @objc func browseEntries()
    {
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            //info.removeFromSuperview()
            let subViews = self.view.subviews
            for ob in subViews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            if (self.pageNumber == 1)
            {
                //self.videosResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true
                {
                    removeAlert()
                    self.advVideoTableView.reloadData()
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
                activityIndicatorView.center = view.center
                
                if (self.pageNumber == 1)
                {
                    //spinner.center = mainView.center
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.center.y-50)
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
            path = "advancedvideos/categories"
            
            
            if Locationdic != nil
            {
                let defaults = UserDefaults.standard
                if let loc = defaults.string(forKey: "Location")
                {
                    if subcatid != nil && subsubcatid != nil
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showVideos":"1","category_id":String(subjectId!),"subCategory_id":String(subcatid!),"subsubcategory_id":String(subsubcatid!),"restapilocation":"\(loc)"]
                    }
                    else if subcatid != nil
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showVideos":"1","category_id":String(subjectId!),"subCategory_id":String(subcatid!),"restapilocation":"\(loc)"]
                        
                    }
                    else
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showVideos":"1","category_id":String(subjectId!),"restapilocation":"\(loc)"]
                    }
                    
                }
                else
                {
                    if subcatid != nil && subsubcatid != nil
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showVideos":"1","category_id":String(subjectId!),"subCategory_id":String(subcatid!),"subsubcategory_id":String(subsubcatid!),"restapilocation":"\(defaultlocation)"]
                    }
                    else if subcatid != nil
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showVideos":"1","category_id":String(subjectId!),"subCategory_id":String(subcatid!),"restapilocation":"\(defaultlocation)"]
                        
                    }
                    else
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showVideos":"1","category_id":String(subjectId!),"restapilocation":"\(defaultlocation)"]
                    }
                    
                    
                }
            }
            else
            {
                if subcatid != nil && subsubcatid != nil
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","showVideos":"1","category_id":String(subjectId!),"subCategory_id":String(subcatid!),"subsubcategory_id":String(subsubcatid!)]
                }
                else if subcatid != nil
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","showVideos":"1","category_id":String(subjectId!),"subCategory_id":String(subcatid!)]
                    
                }
                else
                {
                    parameters = ["page":"1","limit": "20","showVideos":"1","category_id":String(subjectId!),"showCount":"1"]
                }
                
            }
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner
                    {
                        activityIndicatorView.stopAnimating()
                    }
                    self.advVideoTableView.tableFooterView?.isHidden = true
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    let subviews : NSArray = self.view.subviews as NSArray
                    for filterview : Any in subviews
                    {
                        if filterview is UIButton {
                            if (filterview as AnyObject).tag == 240
                            {
                                self.feedFilter2.removeFromSuperview()
                                self.advVideoTableView.frame = CGRect(x: 0, y: TOPPADING+ButtonHeight, width: self.view.bounds.width,height: self.view.bounds.height-ButtonHeight - TOPPADING - tabBarHeight)
                            }
                        }
                    }
                    
                    if msg
                    {
                        if self.pageNumber == 1
                        {
                            self.videosResponse.removeAll(keepingCapacity: false)
                            self.Subcategoryarr.removeAll(keepingCapacity: false)
                            self.SubSubcategoryarr.removeAll(keepingCapacity: false)
                            
                        }
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if let video = response["video"] as? NSDictionary
                            {
                                
                                if let blog = video["response"]as? NSArray
                                {
                                    self.videosResponse = self.videosResponse + (blog as [AnyObject])
                                    
                                }
                                if video["totalItemCount"] != nil{
                                    self.totalItems = video["totalItemCount"] as! Int
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
                                        
                                        if self.subcategory == ""
                                        {
                                            self.feedFilter = createButton(CGRect(x: 0,y: TOPPADING,width: self.view.bounds.width,height: ButtonHeight),title: NSLocalizedString("Choose sub category",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                        }
                                        else
                                        {
                                            self.feedFilter = createButton(CGRect(x: 0,y: TOPPADING ,width: self.view.bounds.width,height: ButtonHeight),title: NSLocalizedString(self.subcategory,  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                        }
                                        
                                        self.feedFilter.isEnabled = true
                                        self.feedFilter.backgroundColor = lightBgColor
                                        self.feedFilter.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.feedFilter.addTarget(self, action: #selector(AdvancvideoCategoryDetailViewController.showFeedFilterOptions(_:)), for: .touchUpInside)
                                        self.view.addSubview(self.feedFilter)
                                        
                                        // Filter Icon on Left site
                                        let filterIcon = createLabel(CGRect(x: self.feedFilter.bounds.width - self.feedFilter.bounds.height, y: 0 , width: self.feedFilter.bounds.height , height: self.feedFilter.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorMedium)
                                        filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                                        self.feedFilter.addSubview(filterIcon)
                                        
                                        self.advVideoTableView.frame = CGRect(x: 0,y: TOPPADING+3 + ButtonHeight, width: self.view.bounds.width, height: self.view.bounds.height - ButtonHeight - 3 - TOPPADING - tabBarHeight)
                                        self.Subcategoryarr  =  self.Subcategoryarr + (blog as [AnyObject])
                                        
                                        
                                    }
                                    else
                                    {
                                        self.advVideoTableView.frame = CGRect(x: 0, y: TOPPADING+3, width: self.view.bounds.width,height: self.view.bounds.height - 3-TOPPADING - tabBarHeight)
                                    }
                                    
                                }
                            }
                            
                        }
                        
                        
                        if let response1 = succeeded["body"] as? NSDictionary
                        {
                            if response1["subsubCategories"] != nil
                            {
                                
                                if let blog1 = response1["subsubCategories"]as? NSArray
                                {
                                    if blog1.count > 0
                                    {
                                        self.SubSubcategoryarr = self.SubSubcategoryarr + (blog1 as [AnyObject])
                                        
                                        if self.subsubcategory == ""
                                        {
                                            self.feedFilter2 = createButton(CGRect(x: 0,y: TOPPADING+ButtonHeight, width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString("Choose 3rd level category",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                            
                                        }
                                        else
                                        {
                                            self.feedFilter2 = createButton(CGRect(x: 0,y:  TOPPADING+ButtonHeight, width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString(self.subsubcategory,  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                        }
                                        
                                        self.feedFilter2.isEnabled = true
                                        self.feedFilter2.tag = 240
                                        self.feedFilter2.backgroundColor = lightBgColor
                                        self.feedFilter2.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.feedFilter2.addTarget(self, action: #selector(AdvancvideoCategoryDetailViewController.showFeedFilterOptions1(_:)), for: .touchUpInside)
                                        self.view.addSubview(self.feedFilter2)
                                        
                                        // Filter Icon on Left site
                                        let filterIcon1 = createLabel(CGRect(x: self.feedFilter2.bounds.width - self.feedFilter2.bounds.height, y: 0 ,width: self.feedFilter2.bounds.height ,height: self.feedFilter2.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorMedium)
                                        filterIcon1.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                                        self.feedFilter2.addSubview(filterIcon1)
                                        
                                        self.advVideoTableView.frame = CGRect(x: 0, y: ButtonHeight+ButtonHeight + 3 + TOPPADING, width: self.view.bounds.width,height: self.view.bounds.height-(2*ButtonHeight) - 3 - TOPPADING - tabBarHeight)
                                        
                                        
                                    }
                                }
                                
                            }
                            
                        }
                        
                        self.isPageRefresing = false
                        // Reload Event Tabel
                        self.advVideoTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.videosResponse.count == 0
                        {
                            
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(eventIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.view.addSubview(self.contentIcon)
                            self.info = createLabel(CGRect(x: self.view.bounds.width * 0.1, y: self.contentIcon.frame.origin.y+self.contentIcon.frame.size.height,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any events matching this criteria.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.numberOfLines = 0
                            self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                            //self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.view.addSubview(self.info)
                            
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y, width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(AdvancvideoCategoryDetailViewController.browseEntries), for: UIControl.Event.touchUpInside)
                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.view.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            
                        }
 
                    }
                    else
                    {//print("=====>>>>   Fail")
                        // Handle Server Error
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                            let message = succeeded["message"] as? String
                            if message == "You do not have the access of this page."
                            {
                                self.popAfterDelay = true
                                self.createTimer(self)
                                
                            }
                            
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
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // MARK: Video Icon Action
    @objc func btnVideoIconClicked(_ sender: UIButton)
    {
        var videoInfo:NSDictionary!
        videoInfo = videosResponse[sender.tag] as! NSDictionary
        if(videoInfo["allow_to_view"] as! Int == 1){
            
            let attachment_video_type = videoInfo["type"] as? Int ?? 0
            var attachment_video_url = videoInfo["video_url"] as? String ?? ""
            let attachment_video_code = videoInfo["code"] as? String ?? ""
            
            if  videoInfo["type"] as! Int == 3 || videoInfo["type"] as! Int == 2 || videoInfo["type"] as! Int == 1 || videoInfo["type"] as! Int == 4 ||  videoInfo["type"] as! Int == 5 || videoInfo["type"] as! Int == 6
            {
                if let url = videoInfo["video_url"] as? String
                {
                    attachment_video_url = url
                }
            }
            else
            {
                attachment_video_url = videoInfo["content_url"] as! String
            }
            
            implemnetPlayer(videoType: attachment_video_type, videoURL: attachment_video_url, videoCode: attachment_video_code, sender : sender)
        }
        else
        {
            showToast(message: NSLocalizedString("You do not have permission to view this private page.",comment: ""), controller: self)
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

