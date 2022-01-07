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

//  CouponsBrowseViewController.swift
//  SocailEngineDemoForSwift

import UIKit
import Foundation
import NVActivityIndicatorView

class CouponsBrowseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate , UITabBarControllerDelegate{
    
    let mainView = UIView()
    var showSpinner = true                      // not show spinner at pull to refresh
    var couponsResponse = [AnyObject]()         // For response come from Server
    var isPageRefresing = false                 // For Pagination
    var couponsTableView:UITableView!           // TAbleView to show the blog Contents
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var updateScrollFlag = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 75              // Dynamic Height fort for Cell
    var showOnlyMyContent:Bool = false
    var fromSearch: Bool!
    var scrollView: UIScrollView!
    var user_id : Int!
    var content_id : String!
    var fromTab : Bool! = false
    var noContentView = NoContentView()
    var countListTitle : String!
    //var imageCache = [String:UIImage]()
    var responseCache = [String:AnyObject]()
    
    var couponDetailView: CouponDetailView!
    var blackScreen: UIView!
    var fromStore = false
    var leftBarButtonItem : UIBarButtonItem!
    var contentType : String = ""
    var url: String = ""
    var isFromSearchPage = false
    var resultInfo: NSDictionary!
    var Events_home = Int()
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        if fromTab == false{
            setDynamicTabValue()
        }

        self.tabBarController?.delegate = self
        globFilterValue = ""
        category_filterId = nil
        openMenu = false
        updateAfterAlert = true
        
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        noContentView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        noContentView.isHidden = true
        mainView.addSubview(noContentView)
        
        if showOnlyMyContent == false
        {
            if Events_home != 1{
                self.title = NSLocalizedString("Coupons",  comment: "")
//                baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = ""
            }
        }
        else
        {
            self.title = String(format: NSLocalizedString(" %@ ", comment: ""), countListTitle)

        }
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(CouponsBrowseViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        couponsTableView = UITableView(frame: CGRect(x:0, y:0, width:view.bounds.width, height:view.bounds.height-(tabBarHeight + 120)), style:.grouped)
        couponsTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        couponsTableView.dataSource = self
        couponsTableView.delegate = self
        couponsTableView.backgroundColor = tableViewBgColor
        couponsTableView.separatorColor = TVSeparatorColor

        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            couponsTableView.estimatedRowHeight = 0
            couponsTableView.estimatedSectionHeaderHeight = 0
            couponsTableView.estimatedSectionFooterHeight = 0
        }
        else{
            if !fromStore{
                couponsTableView.contentInset = UIEdgeInsets.init(top: TOPPADING, left: 0, bottom: 0, right: 0)
            }
        }
        mainView.addSubview(couponsTableView)
        
        blackScreen = UIView(frame: view.frame)
        blackScreen.backgroundColor = UIColor.black
        blackScreen.alpha = 0.0
        view.addSubview(blackScreen)
        
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(CouponsBrowseViewController.refresh), for: UIControl.Event.valueChanged)
        couponsTableView.addSubview(refresher)
        
        
        if logoutUser == true || showOnlyMyContent == true{
            couponsTableView.frame.size.height = view.bounds.height - tabBarHeight
        }
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizer.Direction.down
        view.addGestureRecognizer(swipeDown)
        
        if isFromSearchPage && resultInfo.count > 0{
            showCouponDetails(couponInfo: resultInfo)
        }
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        couponsTableView.tableFooterView = footerView
        couponsTableView.tableFooterView?.isHidden = true
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeNavigationViews(controller: self)
    }
    
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showOfferContent")
        {
            if  UserDefaults.standard.object(forKey: "showOfferContent") != nil {
                
                showOnlyMyContent = name as! Bool
                
            }
            UserDefaults.standard.removeObject(forKey: "showOfferContent")
        }
        
    }


    override func viewDidAppear(_ animated: Bool)
    {
        setNavigationImage(controller: self)
        removeMarqueFroMNavigaTion(controller: self)
        pageNumber = 1
        showSpinner = true
        updateScrollFlag = false
        browseEntries()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        globFilterValue = ""
        globalCatg = ""
        url = ""
        couponsTableView.tableFooterView?.isHidden = true
    }

    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            searchDic.removeAll(keepingCapacity: false)
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            browseEntries()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    
    // Update Blog
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            var parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
            var path = "sitestore/offers/index"
            if contentType == "sitegroup"{
                path = "advancedgroups/offers/\(content_id!)"
                parameters.updateValue("\(content_id!)", forKey: "group_id")
                
            }
            else{

            if fromStore
            {
                path = "sitestore/offers/browse/\(content_id)"
                parameters.updateValue("\(content_id)", forKey: "store_id")
            }
            else if url != ""
            {
                if Events_home == 1 {
                    self.title = NSLocalizedString("",  comment: "")
                    couponsTableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
                    path = url
                }
                else {
                    path = url
                    parameters.updateValue("\(content_id!)", forKey: "event_id")
                }
            }
            }

            if (showSpinner){
             //   spinner.center = mainView.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = mainView.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
             //   activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            if (self.pageNumber == 1){
                if updateAfterAlert == true || searchDic.count > 0 {
                    self.couponsResponse.removeAll(keepingCapacity: false)
                    removeAlert()
                    if let responseCacheArray = self.responseCache["\(path)"]{
                   //     showSpinner = false
                        self.couponsResponse = responseCacheArray as! [AnyObject]
                    }
                    self.couponsTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }

              self.noContentView.isHidden = true
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.couponsResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if response["offers"] != nil
                            {
                                if let blog = response["offers"] as? NSMutableArray
                                {
                                    self.couponsResponse = self.couponsResponse + (blog as [AnyObject])
                                    if (self.pageNumber == 1)
                                    {
                                        self.responseCache["\(path)"] = blog
                                    }
                                }
                            }
                            else if response["response"] != nil
                            {
                                if let blog = response["response"] as? NSMutableArray
                                {
                                    self.couponsResponse = self.couponsResponse + (blog as [AnyObject])
                                    if (self.pageNumber == 1)
                                    {
                                        self.responseCache["\(path)"] = blog
                                    }
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                        }
                        
                        self.isPageRefresing = false
                        self.couponsTableView.reloadData()
                        
                        if self.couponsResponse.count == 0{
                            self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                            self.mainView.addSubview(self.noContentView)
                            self.noContentView.isHidden = false
                            self.noContentView.button.layer.borderWidth = 1
                            self.noContentView.button.layer.borderColor = buttonColor.cgColor
                            self.noContentView.button.setTitle("Try Again", for: .normal)
                            self.noContentView.button.isHidden = true
                            self.noContentView.button.addTarget(self, action: #selector(CouponsBrowseViewController.browseEntries), for: .touchUpInside)
                            self.noContentView.label.text = "There are no coupons available here"
                        }
                        
                    }
                    else
                    {
                        
                        // Handle Server Error
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
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        return couponsResponse.count
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let row = indexPath.row as Int
        
        var couponInfo:NSDictionary
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = tableViewBgColor
        
        couponInfo = couponsResponse[row] as! NSDictionary
        cell.imgUser.contentMode = .scaleAspectFill
        cell.imgUser.frame = CGRect(x:5, y:7, width:60, height:60)
        // Set Blog Title
        cell.labTitle.frame = CGRect(x:cell.imgUser.bounds.width + 10, y:10,width:(UIScreen.main.bounds.width - 75) , height:100)
        cell.labTitle.text = couponInfo["title"] as? String
        cell.labTitle.numberOfLines = 2
        cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
        cell.labTitle.sizeToFit()
        
        if contentType != "sitegroup"{
        
        if let postedDate = couponInfo["start_time"] as? String{
            let date = dateDifferenceWithEventTime(postedDate)
            var DateC = date.components(separatedBy: ",")
            var tempInfo = ""
            
            tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
            if DateC.count > 3{
                tempInfo += " at \(DateC[3])"
            }
            
            cell.labMessage.frame = CGRect(x:cell.imgUser.bounds.width + 10, y:cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5,width:(UIScreen.main.bounds.width - 75) , height:100)
            let labMsg = String(format: NSLocalizedString("Start date: %@", comment: ""), tempInfo)
            
            
            cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                // TODO: Clean this up..
                return mutableAttributedString!
            })
        }
        
        cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.labMessage.sizeToFit()
        cell.labMessage.font = UIFont(name: fontName, size: FONTSIZENormal)
        }
        
        if let postedDate = couponInfo["end_time"] as? String{
            let date = dateDifferenceWithEndTime(orignalDate: postedDate)
            var DateC = date.components(separatedBy: ",")
            var tempInfo = ""
            if DateC.count > 1{
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
            }else{
                tempInfo = date
            }
            if contentType == "sitegroup"{
                cell.endDateLabel.frame = CGRect(x:cell.imgUser.bounds.width + 10, y:cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5,width:(UIScreen.main.bounds.width - 75) , height:100)
            }
            else{
            cell.endDateLabel.frame = CGRect(x:cell.imgUser.bounds.width + 10, y:cell.labMessage.frame.origin.y + cell.labMessage.bounds.height+5,width:(UIScreen.main.bounds.width - 75) , height:100)
            }
            let endDateMsg = String(format: NSLocalizedString("End date: %@", comment: ""), tempInfo)
            
            
            cell.endDateLabel.setText(endDateMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                // TODO: Clean this up..
                return mutableAttributedString!
            })
        }
        
        cell.endDateLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.endDateLabel.sizeToFit()
        cell.endDateLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        
        if contentType == "sitegroup"{
            
            if let claimedCount = (couponInfo["claimed"] as? Int){
            cell.labMessage.frame.origin.y = getBottomEdgeY(inputView: cell.endDateLabel) + 5
                cell.labMessage.frame.origin.x = cell.imgUser.bounds.width + 10
                let labMsg = String(format: NSLocalizedString("%d Claimed", comment: ""), claimedCount)
            cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                    // TODO: Clean this up..
                    return mutableAttributedString!
                })
                cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.labMessage.sizeToFit()
                cell.labMessage.font = UIFont(name: fontName, size: FONTSIZENormal)

                
            }
            
        }
        
        // Set Blog Owner Image
        
        if let url = NSURL(string: couponInfo["image"] as! String){

            cell.imgUser.kf.indicatorType = .activity
            (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.imgUser.kf.setImage(with: url as URL?, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
        var index = Int()
        index = indexPath.row
        
        
        var couponInfo:NSDictionary
        couponInfo = couponsResponse[index] as! NSDictionary
        
        showCouponDetails(couponInfo: couponInfo)
}

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                // Check for Page Number for Browse Blog
//                if couponsTableView.contentOffset.y >= couponsTableView.contentSize.height - couponsTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            couponsTableView.tableFooterView?.isHidden = false
                          //  if searchDic.count == 0{
                                browseEntries()
                           // }
                        }
                    }
                    else
                    {
                        couponsTableView.tableFooterView?.isHidden = true
                }
                    
              //  }
                
            }
            
        }
        
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .left) {
            openMenu = false
            openMenuSlideOnView(mainView)
            mainView.removeGestureRecognizer(tapGesture)
        }
        
    }
    
    @objc func goBack(){
         _ = self.navigationController?.popViewController(animated: false)
    }
    
    @objc func hideCouponDetail(){

        UIView.animate(withDuration:0.5) { () -> Void in
            self.couponDetailView.frame.origin.y = self.view.bounds.height
            self.blackScreen.alpha = 0.0
            self.couponDetailView.removeFromSuperview()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            switch swipeGesture.direction {
//            case UISwipeGestureRecognizer.Direction.right:
//                //print("Swiped right")
//            case UISwipeGestureRecognizer.Direction.down:
//                //print("Swiped down")
//                hideCouponDetail()
//            case UISwipeGestureRecognizer.Direction.left:
//                //print("Swiped left")
//            case UISwipeGestureRecognizer.Direction.up:
//                //print("Swiped up")
//            default:
//                break
//            }
//        }
    }
    
    func showCouponDetails(couponInfo: NSDictionary){
        
        couponDetailView = CouponDetailView(frame:CGRect(x:10, y:view.bounds.height, width:view.bounds.width - 20, height:view.bounds.height/2))
        
        couponDetailView.couponImage.image = nil
        couponDetailView.couponImage.image = imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: couponDetailView.couponImage.bounds.width)
        
        if let url1 = NSURL(string: couponInfo["image"] as! NSString as String){

            couponDetailView.couponImage.kf.indicatorType = .activity
            (couponDetailView.couponImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            couponDetailView.couponImage.kf.setImage(with: url1 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
              
            })
            couponDetailView.couponImage.backgroundColor = placeholderColor
        }
        
        couponDetailView.couponLabel.text = "\(couponInfo["title"]!)"
        couponDetailView.couponDescription.numberOfLines = 10
        couponDetailView.couponDescription.text = "\(couponInfo["description"]!)"
        couponDetailView.couponDescription.sizeToFit()
        
        couponDetailView.frame.size.height = getBottomEdgeY(inputView:couponDetailView.couponDescription) + couponDetailView.couponDescription.frame.size.height
        
        couponDetailView.couponCode.text = "\(couponInfo["coupon_code"]!)"
        
        
        
        if contentType != "sitegroup"{
            
            if couponInfo["discount_type"] as! Int  == 0{
                couponDetailView.couponDiscount.text = "\(couponInfo["discount_amount"]!)%"
            }
            else
            {
                couponDetailView.couponDiscount.text = "\(couponInfo["discount_amount"]!)"
            }
        }
        else {
            couponDetailView.couponEndDate.frame.origin.y = getBottomEdgeY(inputView: couponDetailView.couponLabel) + 10
            couponDetailView.couponEndDateLabel.frame.origin.y = getBottomEdgeY(inputView: couponDetailView.couponLabel) + 10
            couponDetailView.couponUsageLimit.frame.origin.y = getBottomEdgeY(inputView: couponDetailView.couponEndDateLabel) + 5
        }
        
        if url == ""
        {
            if couponInfo["claim_count"] as! Int == -1
            {
                couponDetailView.couponUsageLimit.text = "Unlimited Use"
            }
            else
            {
                if let couponClaimedCount = couponInfo["claimed"] as? Int{
                    if couponClaimedCount > 0{
                        let remainingClaimCount = couponInfo["claim_count"] as! Int - couponClaimedCount
                        if remainingClaimCount == 1{
                            couponDetailView.couponUsageLimit.text = "\(couponClaimedCount) Claimed - \(remainingClaimCount) coupon Left"
                        }else{
                            couponDetailView.couponUsageLimit.text = "\(couponClaimedCount) Claimed - \(remainingClaimCount) coupons Left"
                        }
                        
                    }
                    else
                    {
                        couponDetailView.couponUsageLimit.text = "\(couponInfo["claim_count"]!) coupons Left"
                    }
                }
                
            }
        }
        if contentType != "sitegroup"{
            if let postedDate = couponInfo["start_time"] as? String{
                let date = dateDifferenceWithEventTime(postedDate)
                var DateC = date.components(separatedBy: ",")
                var tempInfo = ""
                
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
                
                let labMsg = String(format: NSLocalizedString("%@", comment: ""), tempInfo)
                
                couponDetailView.couponStartDate.text = labMsg
            }
        }
        
        if let postedDate = couponInfo["end_time"] as? String{
            let date = dateDifferenceWithEndTime(orignalDate: postedDate)
            var DateC = date.components(separatedBy: ",")
            var tempInfo = ""
            if DateC.count > 1{
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
            }else{
                tempInfo = date
            }
            
            
            let endDateMsg = String(format: NSLocalizedString("%@", comment: ""), tempInfo)
            
            couponDetailView.couponEndDate.text = endDateMsg
            
        }
        if self.contentType == "sitegroup"{
            couponDetailView.couponStartDateLabel.isHidden = true
            couponDetailView.couponStartDate.isHidden = true
        }
        
        couponDetailView.doneButton.addTarget(self, action: #selector(CouponsBrowseViewController.hideCouponDetail), for: UIControl.Event.touchUpInside)
        
        view.addSubview(couponDetailView)
        
        UIView.animate(withDuration: 0.5) { () -> Void in
            self.couponDetailView.frame.origin.y = self.view.bounds.height/2 - self.couponDetailView.frame.height/2
            self.blackScreen.alpha = 0.5
        }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the isSelected object to the new view controller.
    }
    */
    
}
