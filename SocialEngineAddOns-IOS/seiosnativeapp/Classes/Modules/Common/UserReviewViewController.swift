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

//  UserReviewViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 16/02/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit

class UserReviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    var mytitle : String!
    var count:Int!
    var subjectId : String!
    var ReviewTableview:UITableView!
    var viewcontener:UIView!
    var lblAvgrating:UILabel!
    var lblmyrating:UILabel!
    var viewAvgRating:UIView!
    var viewMyRating:UIView!
    var rated:Bool!
    var productId : Int!
    var storeId : Int!
    var lblreviewcount:UILabel!
    var lblrecomendedcount:UILabel!
    
    var reviewarr:NSMutableArray!
    var actualreviewarr:NSArray!
    var dynamicHeight : CGFloat = 200
    var reviewid:Int!
    var ishelp:Int!
    var indextag:IndexPath!
    
    var refresher:UIRefreshControl!
    var showSpinner = true
    var listingTypeId: Int!
    var reviewGutterMenu: NSArray = []
    var contentType : String!
    var ownerid:Int!
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(UserReviewViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        viewcontener = createView(CGRect(x: 0, y: 0,width: (UIScreen.main.bounds.width) , height: 180), borderColor: borderColorMedium, shadow: false)
        viewcontener.layer.borderWidth = 0.0
        viewcontener.backgroundColor = UIColor.clear
        viewcontener.isHidden = false//true
        self.view.addSubview(viewcontener)
        
        
        lblAvgrating = createLabel(CGRect(x: 10,y: 70 + iphonXTopsafeArea,width: view.bounds.width/2-10, height: 20), text: "Average User Rating", alignment: .left, textColor: textColorDark)
        
        lblAvgrating.font = UIFont(name: fontName, size: FONTSIZELarge)
        
        lblAvgrating.textAlignment = NSTextAlignment.center;
        viewcontener.addSubview(lblAvgrating)
        
        viewAvgRating = createView(CGRect(x: 10,y: lblAvgrating.frame.origin.y+lblAvgrating.frame.size.height, width: view.bounds.width/2-10, height: 30), borderColor: UIColor.clear, shadow: true)
        viewAvgRating.backgroundColor = UIColor.clear
        viewcontener.addSubview(viewAvgRating)
        self.rated = true
        self.updateAvgRating(0, ratingCount:0)
        
        lblmyrating = createLabel(CGRect(x: view.bounds.width/2,y: 70 + iphonXTopsafeArea,width: view.bounds.width/2-10, height: 20), text: "My Rating", alignment: .left, textColor: textColorDark)
        lblmyrating.font = UIFont(name: fontName, size: FONTSIZELarge)
        
        lblmyrating.textAlignment = NSTextAlignment.center;
        viewcontener.addSubview(lblmyrating)
        
        viewMyRating = createView(CGRect(x: view.bounds.width/2+10,y: lblAvgrating.frame.origin.y+lblAvgrating.frame.size.height, width: view.bounds.width/2-10, height: 30), borderColor: UIColor.clear, shadow: true)
        viewMyRating.backgroundColor = UIColor.clear
        viewcontener.addSubview(viewMyRating)
        self.rated = true
        self.updatemyRating(0, ratingCount:0)
        
        lblreviewcount = createLabel(CGRect(x: 30,y: viewAvgRating.frame.origin.y+viewAvgRating.frame.size.height+10,width: view.bounds.width-20, height: 17), text: "Average User Rating", alignment: .left, textColor: textColorMedium)
        lblreviewcount.font = UIFont(name: fontName, size: FONTSIZENormal)
        lblreviewcount.textAlignment = NSTextAlignment.left;
        viewcontener.addSubview(lblreviewcount)
        
        lblrecomendedcount = createLabel(CGRect(x: 30,y: lblreviewcount.frame.origin.y+lblreviewcount.frame.size.height+3,width: view.bounds.width-20, height: 17), text: "Average User Rating", alignment: .left, textColor: textColorMedium)
        lblrecomendedcount.font = UIFont(name: fontName, size: FONTSIZENormal)
        lblrecomendedcount.textAlignment = NSTextAlignment.left;
        viewcontener.addSubview(lblrecomendedcount)
        
        // Set tableview to show events
        ReviewTableview = UITableView(frame: CGRect(x: 0, y: ButtonHeight+ButtonHeight+TOPPADING+30, width: view.bounds.width, height: view.bounds.height-(ButtonHeight+ButtonHeight+TOPPADING+30) - tabBarHeight), style: .grouped)
        ReviewTableview.register(UserReviewTableViewCell.self, forCellReuseIdentifier: "ReviewCell")
        ReviewTableview.estimatedRowHeight = 200.0
        ReviewTableview.contentInset = UIEdgeInsets(top: -35, left: 0, bottom: 0, right: 0)
        //        ReviewTableview.dataSource = self
        //        ReviewTableview.delegate = self
        ReviewTableview.isOpaque = false
        ReviewTableview.isHidden = true
        ReviewTableview.backgroundColor = UIColor.red
        ReviewTableview.backgroundColor = tableViewBgColor
        self.view.addSubview(ReviewTableview)
        
        
        // Initialize Pull to Refresh to ActivityFeed Table
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(UserReviewViewController.refresh), for: UIControl.Event.valueChanged)
        ReviewTableview.addSubview(refresher)
   
        
    }
    
    override func viewWillAppear(_ animated: Bool){

        
        exploreContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //self.title = NSLocalizedString("Info", comment: "")
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    @objc func cancel()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            // Pull to Refreh for Recent Feeds (Reset Variables)
            showSpinner = false
            exploreContent()
        }
        else
        {
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
            
        }
        
    }
    
    // Sevice Calling
    func exploreContent(){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
            removeAlert()
            if self.showSpinner
                
            {
//                spinner.center = view.center
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                self.view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            
            
            var url = ""
            var parameters = Dictionary<String, String>()
            
            switch(contentType){
            case "advancedevents":
                parameters = ["getRating": "1", "rsvp_form": "1"]
                url = "advancedevents/reviews/browse/event_id/\(self.subjectId)"
                
                break
                
            case "listings":
                parameters = ["getRating": "1", "listing_id": String(subjectId), "listingtype_id": String(listingTypeId)]
                url = "listings/reviews"
                break
                
            case "product":
                parameters = ["getRating": "1"]
                url = "sitestore/product/review/browse/\(storeId)/\(productId)"
                
                break
                
                
            default:
                break
            }
            
            
            // Send Server Request to Explore listings Contents with listing_ID
            post( parameters, url: url, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner
                        
                    {
                        activityIndicatorView.stopAnimating()
                    }
                    else
                    {
                        self.refresher.endRefreshing()
                        self.showSpinner = true
                    }
                    if msg
                    {
                        
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if succeeded["body"] != nil
                        {
                            //print(succeeded)
                            
                            // On Success Update Content Detail
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                
                                // Update Content Gutter Menu
                                if let menu = response["reviews"] as? NSArray
                                {
                                    self.ReviewTableview.isHidden = false
                                    self.ReviewTableview.dataSource = self
                                    self.ReviewTableview.delegate = self
                                    self.reviewarr = menu.mutableCopy() as! NSMutableArray
                                    self.actualreviewarr = menu
                                    self.ReviewTableview.reloadData()
                                }
                                
                                if let rateingdic = response["ratings"] as? NSDictionary
                                {
                                    self.viewcontener.isHidden = false
                                    if let rating = rateingdic["rating_avg"] as? Int
                                    {
                                        self.rated = true
                                        self.updateAvgRating(rating, ratingCount: (rateingdic["rating_avg"] as? Int)!)
                                    }
                                    if let myrating = rateingdic["myRatings"] as? NSArray
                                    {
                                        
                                        if myrating.count>0
                                        {
                                            let dic = myrating[0] as? NSDictionary
                                            
                                            let myrating = dic?["rating"] as! Int
                                            self.updatemyRating(myrating, ratingCount: (dic?["rating"] as? Int)!)
                                        }
                                        
                                    }
                                    if let Recomndedvalue = rateingdic["recomended"] as? Int
                                    {
                                        self.lblrecomendedcount.text = "Recommended by \(Recomndedvalue) users"
                                        
                                    }
                                    else
                                    {
                                        self.lblrecomendedcount.text = "Recommended by 0 users"
                                    }
                                    
                                    
                                }
                                
                                if let totalreview = response["total_reviews"] as? Int
                                {
                                    
                                    if totalreview == 1{
                                        self.lblreviewcount.text = NSLocalizedString("Based on \(totalreview) Review", comment:"")
                                    }else {
                                        self.lblreviewcount.text = NSLocalizedString("Based on \(totalreview) Reviews", comment: "")
                                    }
                                    
                                    //self.lblreviewcount.text = "Based on \(totalreview) Reviews"
                                    self.title = NSLocalizedString("User Reviews (\(totalreview)): " + self.mytitle,  comment: "")
                                    
                                }
                                
                            }
                        }
                        else
                        {
                            // Handle Server Side Error
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
                                
                            }
                        }
                    }
                    else
                    {
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                            
                        }
                    }
                })
            }
        }
        else
        {
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer
        {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer() {
        stop()
        _ = navigationController?.popViewController(animated: true)
    }
    // MARK:  UITableViewDelegate & UITableViewDataSource
    // Set Tabel Footer Height
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        
        return 0.00001
        
    }
    
    // Set Tabel Header Height
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        
        return 0.00001
    }
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    // Set height for row at index path
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return reviewarr.count
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! UserReviewTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let Reviewdic = reviewarr[(indexPath as NSIndexPath).row] as! NSDictionary
        let initalReviewDic = actualreviewarr[(indexPath as NSIndexPath).row] as! NSDictionary
        cell.lblhelpful.isHidden = false//true
        cell.lblhelpfulstar.isHidden  = false//true
        //cell.lblhelpfulcount.frame.origin.x = cell.lblhelpfulcount.frame.origin.x - 15
        cell.nothelpfulcommentstar.isHidden = true
        cell.ratingView.tag = (indexPath as NSIndexPath).row
        cell.btncommentaction.tag = (indexPath as NSIndexPath).row
        cell.btnhelpful.tag = (indexPath as NSIndexPath).row
        cell.btnNothelpful.tag = (indexPath as NSIndexPath).row
        cell.btnUser.tag = (indexPath as NSIndexPath).row
        cell.btncommentaction .addTarget(self, action: #selector(UserReviewViewController.openComment(_:)), for: .touchUpInside)
        cell.btnhelpful .addTarget(self, action: #selector(UserReviewViewController.helpfulAction(_:)), for: .touchUpInside)
        cell.btnhelpful.setTitle("\u{f164}", for: UIControl.State())
        cell.btnNothelpful .addTarget(self, action: #selector(UserReviewViewController.nothelpfulAction(_:)), for: .touchUpInside)
        
        if contentType == "listings"{
            cell.reviewMoreOptions.tag = (indexPath as NSIndexPath).row
            cell.reviewMoreOptions.addTarget(self, action: #selector(UserReviewViewController.showReviewMenu(_:)), for: .touchUpInside)
            cell.reviewMoreOptions.isHidden = false
        }
        
        if let name = Reviewdic["title"] as? String
        {
            
            cell.titleLabel.text = "\(name)"
            cell.titleLabel.numberOfLines = 1
            cell.titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        }
        
        if let rating = Reviewdic["overall_rating"] as? Int
        {
            cell.updateRating(rating, ratingCount: rating)
        }
        else
        {
            cell.updateRating(0, ratingCount: 0)
        }
        
        if let createdate = Reviewdic["creation_date"] as? String
        {
            let postedOn = dateDifference(createdate)
            
            if let ownerName = Reviewdic["owner_title"] as? String{
                let labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), ownerName, postedOn)
                cell.createdAt.text = labMsg
                cell.btnUser.addTarget(self, action: #selector(UserReviewViewController.userprofileAction(_:)), for: .touchUpInside)
            }else{
                cell.createdAt.text = "\(postedOn)"
            }
        }
        
        if let pros = Reviewdic["pros"] as? String
        {
            cell.lblprostext.numberOfLines = 0
            cell.lblprostext.text = "\(pros)"
            cell.lblprostext.sizeToFit()
        }
        
        if let cons = Reviewdic["cons"] as? String
        {
            cell.lblconstext.numberOfLines = 0
            cell.lblconstext.text = "\(cons)"
            cell.lblconstext.sizeToFit()
            cell.lblconstext.frame.origin.y = cell.lblprostext.frame.origin.y + cell.lblprostext.frame.size.height  + 20//+ 5
            cell.lblcons.frame.origin.y = cell.lblprostext.frame.origin.y + cell.lblprostext.frame.size.height  + 20//+ 5
        }
        
        if (Reviewdic["body"] as? String) != nil
            
        {
            cell.lblsummarytext.numberOfLines = 0
            
            cell.lblsummarytext.text = getReviewSummary(initalReviewDic)
            
            cell.lblsummarytext.sizeToFit()
            cell.lblsummarytext.frame.origin.x = cell.lblsummary.frame.origin.x  + cell.lblsummary.frame.size.width  + 20//+ 5
            cell.lblsummarytext.frame.origin.y = cell.lblconstext.frame.origin.y + cell.lblconstext.frame.size.height  + 20//+ 5
            cell.lblsummary.frame.origin.y = cell.lblconstext.frame.origin.y + cell.lblconstext.frame.size.height + 20//+ 5
        }
        
        // cell.reviewMoreOptions.frame = CGRect( x: cell.bounds.width - 40, y: cell.lblsummarytext.frame.origin.y + cell.lblsummarytext.frame.size.height + 10, width: 40, height: 15)
        
        cell.viewActivity.frame = CGRect(x: 0,y: cell.lblsummarytext.frame.origin.y + cell.lblsummarytext.frame.size.height + 10 + 15 + 10,width: cell.cellView.frame.size.width,height: 50)
        
        if let commentcount = Reviewdic["comment_count"] as? Int
        {
            
            cell.lblcomment.text = "\(commentcount) Comment"
        }
        
        if let helpfulcount = Reviewdic["helpful_count"] as? Int
        {
            cell.lblhelpfulcount.text = "\(helpfulcount)"
        }
        
        if let nothelpful = Reviewdic["nothelpful_count"] as? Int
        {
            cell.lblNothelpfulcount.text = "\(nothelpful)"
        }
        
        if let recomended = Reviewdic["recommend"] as? Int
        {
            if recomended == 1
            {
                cell.btnright.isHidden = false
            }
            else
            {
                cell.btnright.isHidden = true
            }
            
        }
        else
        {
            cell.btnright.isHidden = true
        }
        
        
        let helpful = Reviewdic["is_helpful"] as? Bool
        if helpful == false
        {
            
            cell.btnhelpful.isSelected = false
            cell.btnhelpful.isUserInteractionEnabled = true
            
            
        }
        else
        {
            cell.btnhelpful.isSelected = true
            cell.btnhelpful.isUserInteractionEnabled = false
            
        }
        
        let nothelpful = Reviewdic["is_not_helpful"] as? Bool
        
        if nothelpful == false
        {
            cell.btnNothelpful.isSelected = false
            cell.btnNothelpful.isUserInteractionEnabled = true
        }
        else
        {
            
            cell.btnNothelpful.isSelected = true
            cell.btnNothelpful.isUserInteractionEnabled = false
            
        }
        
        
        dynamicHeight = 50
        
        if dynamicHeight < (cell.viewActivity.frame.origin.y + cell.viewActivity.bounds.height)
        {
            dynamicHeight = (cell.viewActivity.frame.origin.y + cell.viewActivity.bounds.height)
            cell.cellView.frame.size.height = dynamicHeight
        }
        
        
        return cell
        
    }
    
    
    // MARK:Rating Function
    func updateAvgRating(_ rating:Int, ratingCount:Int)
    {
        
        
        
        for ob in viewAvgRating.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 15 as CGFloat
        
        for i in stride(from: 1, through: 5, by: 1){
            let rate = createButton(CGRect(x: origin_x + 20, y: 10, width: 20, height: 20), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clear
            rate.setImage(UIImage(named: "graystar.png"), for: UIControl.State() )
            
            if rated == false
            {
                rate.tag = i
                rate.addTarget(self, action: Selector(("rateAction:")), for: .touchUpInside)
            }
            else
            {
                if i <= rating
                {
                    rate.setImage(UIImage(named: "yellowStar.png"), for: UIControl.State() )
                }
                
            }
            origin_x += 22
            viewAvgRating.addSubview(rate)
        }
        
    }
    
    
    // MARK:Rating Function
    
    func updatemyRating(_ rating:Int, ratingCount:Int)
    {
        for ob in viewMyRating.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 15 as CGFloat
        
        for i in stride(from: 1, through: 5, by: 1){
            let rate = createButton(CGRect(x: origin_x + 20, y: 10, width: 20, height: 20), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clear
            rate.setImage(UIImage(named: "graystar.png"), for: UIControl.State() )
            
            if rated == false
            {
                rate.tag = i
                rate.addTarget(self, action: Selector(("rateAction:")), for: .touchUpInside)
            }
            else
            {
                if i <= rating
                {
                    rate.setImage(UIImage(named: "yellowStar.png"), for: UIControl.State() )
                }
                
            }
            origin_x += 22
            viewMyRating.addSubview(rate)
        }
        
    }
    
    @objc func openComment(_ sender:UIButton)
    {
        
        let Reviewdic = reviewarr[sender.tag] as! NSDictionary
        likeCommentContentType = "siteevent_review"
        likeCommentContentType = "sitereview_review"
        let presentedVC = CommentsViewController()
        
        if let reviewid = Reviewdic["review_id"] as? Int
        {
            likeCommentContent_id = "\(reviewid)"
        }
        presentedVC.openCommentTextView = 1
        presentedVC.activityfeedIndex = sender.tag
        presentedVC.activityFeedComment = false
        presentedVC.contentActivityFeedComment = false
        presentedVC.userActivityFeedComment = false
        presentedVC.fromActivityFeed = true
        presentedVC.commentPermission = 1
        presentedVC.actionId = "\(self.subjectId!)"
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:true, completion: nil)
    }
    
    @objc func helpfulAction(_ sender:UIButton)
    {
        
        let index = sender.tag
        let indexPath = IndexPath(row:index, section: 0)
        indextag = indexPath
        if sender.isSelected
        {
            //sender.selected = false
            
        }
        else
        {
            
            sender.isSelected = true
            sender.isUserInteractionEnabled = false
            
            
            let dic = self.actualreviewarr[(indexPath as NSIndexPath).row] as! NSDictionary
            let Reviewdic = dic.mutableCopy() as! NSMutableDictionary
            
            
            reviewid = Reviewdic["review_id"] as! Int
            ishelp = 1
            
            
            Reviewdic["is_helpful"] = true
            Reviewdic["is_not_helpful"] = false
            self.reviewarr[(indexPath as NSIndexPath).row] = Reviewdic
            self.ReviewTableview.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            self.callIshelpful()
        }
        
    }
    
    @objc func nothelpfulAction(_ sender:UIButton)
    {
        
        let index = sender.tag
        let indexPath = IndexPath(row:index, section: 0)
        indextag = indexPath
        if sender.isSelected
        {
            //sender.selected = false
            
        }
        else
        {
            
            sender.isSelected = true
            sender.isUserInteractionEnabled = false
            let dic = self.actualreviewarr[(indexPath as NSIndexPath).row] as! NSDictionary
            let Reviewdic = dic.mutableCopy() as! NSMutableDictionary
            
            reviewid = Reviewdic["review_id"] as! Int
            ishelp = 2
            Reviewdic["is_not_helpful"] = true
            Reviewdic["is_helpful"] = false
            self.reviewarr[(indexPath as NSIndexPath).row] = Reviewdic
            self.ReviewTableview.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            self.callIshelpful()
            
            
        }
        
    }
    
    @objc func userprofileAction(_ sender:UIButton)
    {
        let Reviewdic = reviewarr[sender.tag] as! NSDictionary
        ownerid = Reviewdic["owner_id"] as! Int
        if ownerid != nil
        {
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(ownerid)"
            presentedVC.fromActivity = false
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    func callIshelpful()
    {
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
            
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var url = ""
            var method = "GET"
            var parameters = Dictionary<String, String>()
            
            switch(contentType){
                
            case "advancedevents":
                
                parameters = ["review_id": String(reviewid),"helpful":String(ishelp)]
                url = "advancedevents/review/helpful/" + String(self.subjectId)
                method = "POST"
                break
                
            case "listings":
                
                parameters = ["review_id": String(reviewid),"helpful":String(ishelp), "listingtype_id": String(listingTypeId), "listing_id":String(subjectId)]
                url = "listings/review/helpful/" + String(self.subjectId)
                method = "POST"
                break
                
            default:
                break
            }
            
            
            post( parameters, url: url, method: "\(method)") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        
                        if succeeded["body"] != nil
                        {
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                
                                
                                self.reviewarr[self.indextag.row] = response
                                self.ReviewTableview.reloadRows(at: [self.indextag], with: UITableView.RowAnimation.none)
                                
                                
                            }
                            
                            
                        }
                    }
                    else
                    {
                        // Handle Server Side Error
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                            
                        }
                    }
                })
            }
        }
        else
        {
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    // SHOW GUTTER MENUS
    @objc func showReviewMenu(_ sender:UIButton){
        
        var reviewInfo:NSDictionary
        
        reviewInfo = actualreviewarr[sender.tag] as! NSDictionary
        
        var confirmationTitle = ""
        
        var message = ""
        var url = ""
        var param = [String:AnyObject]()
        var confirmationAlert = true
        
        if let menuOption = reviewInfo["gutterMenus"] as? NSArray {
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for menu in menuOption{
                if let menuItem = menu as? NSDictionary{
                    
                    alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                        let condition = menuItem["name"] as! String
                        
                        switch(condition){
                            
                        case "delete":
                            
                            confirmationTitle = NSLocalizedString("Delete Review", comment: "")
                            message = NSLocalizedString("Are you sure you want to delete this review?", comment: "")
                            url = menuItem["url"] as! String
                            param = ((menuItem["urlParams"] as! NSDictionary)) as! [String : AnyObject]
                            let dic = ["listing_id": "\(self.subjectId!)" , "listingtype_id" : "\(self.listingTypeId!)"]
                            param.update(dic as Dictionary<String, AnyObject>)
                            
                        case "share":
                            confirmationAlert = false
                            let presentedVC = AdvanceShareViewController()
                            presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.Sharetitle = reviewInfo["title"] as! String
                            presentedVC.ShareDescription = self.getReviewSummary(reviewInfo)
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:true, completion: nil)
                            
                            
                        case "report":
                            confirmationAlert = false
                            let presentedVC = ReportContentViewController()
                            presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                            presentedVC.url = menuItem["url"] as! String
                            self.navigationController?.pushViewController(presentedVC, animated: false)
                            
                        case "update":
                            
                            isCreateOrEdit = true
                            globFilterValue = ""
                            confirmationAlert = false
                            let presentedVC = FormGenerationViewController()
                            presentedVC.formTitle = NSLocalizedString("Update Review", comment: "")
                            presentedVC.contentType = "Review"
                            let param = menuItem["urlParams"] as! NSDictionary
                            let reviewid = param["review_id"] as! Int
                            var tempDic = NSDictionary()
                            tempDic = ["listingtype_id" : "\(self.listingTypeId!)","review_id":"\(reviewid)"]
                            presentedVC.param = tempDic as! [AnyHashable : Any] as NSDictionary
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.present(nativationController, animated:false, completion: nil)
                            
                            
                        default:
                            
                            print("error")
                        }
                        
                        
                        if confirmationAlert == true {
                            
                            displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                
                                if condition == "delete"{
                                    self.updateReviewMenuAction(param as NSDictionary, url: url)
                                }
                            }
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }))
                }
                
            }
            
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel", comment: ""), style: .cancel, handler:nil))
            }else if (UIDevice.current.userInterfaceIdiom == .pad){
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2, width: 1, height: 1)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            
            self.present(alertController, animated:true, completion: nil)
        }
        
    }
    
    // PERFORM ACTIONS PROVIDED IN GUTTER MENUS
    func updateReviewMenuAction(_ parameter:NSDictionary, url : String){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            // Send Server Request to Explore review Contents with review_id
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg{
                        // On Success Update listing Detail
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                            if (self.reviewarr.count - 1) == 0{
                                listingDetailUpdate = true
                                _ = self.navigationController?.popViewController(animated: true)
                            }
                            
                        }
                        
                        self.exploreContent()
                    }else{
                        // Handle Server Side Error
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
    
    //FUNCTION FOR GETTING UPDATED SUMMARY IF EXISTS AND IF NOT RETURNS AVAILABLE BODY
    func getReviewSummary(_ reviewDic: NSDictionary) -> String{
        
        if let summary = reviewDic["body"] as? String{
            if reviewDic.object(forKey: "updatedReviewArray") != nil{
                let updatedReviewArray = reviewDic["updatedReviewArray"] as! NSArray?
                let updatedReviewDic  = updatedReviewArray?[0] as! NSDictionary
                if let updatedSummary = updatedReviewDic["body"] as? String{
                    return "\(updatedSummary.html2String)"
                }
            }
            return summary.html2String
        }
        
        return ""
    }
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
        
    }
}
