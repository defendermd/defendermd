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

//  PageReviewViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 16/02/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
var reviewUpdate = true
class PageReviewViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate , UITabBarControllerDelegate
{
    var mytitle : String!
    var currentReviewcount:Int! = 0
    var subjectId : String!
    var reviewId : Int!
    var ReviewTableview:UITableView!
    var viewcontener:UIView!
    var lblAvgrating:UILabel!
    var lblmyrating:UILabel!
    var viewAvgRating:UIView!
    var rated:Bool!
    var lblreviewcount:UILabel!
    var lblrecomendedcount:UILabel!
    var reviewArray:[PageReviewModel] = []
    var actualreviewarr:NSArray!
    var dynamicHeight : CGFloat = 200
    var reviewid:Int!
    var ishelp:Int!
    var indextag:IndexPath!
    var refresher:UIRefreshControl!
    var showSpinner = true
    var listingTypeId: Int!
    var reviewGutterMenu:NSArray = []
    var contentType : String!
    var ownerid:Int!
    var like_unlikecount : Int!
    var hideMenuOption : Bool = false
    var recommendText : String!
    var storeId: Int!
    var marqueeHeader : MarqueeLabel!
    var leftBarButtonItem : UIBarButtonItem!
    var count:Int!


    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        reviewUpdate = true
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(PageReviewViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        self.tabBarController?.delegate = self

       
        ReviewTableview = UITableView(frame: CGRect(x:0, y:TOPPADING, width:view.bounds.width, height:view.bounds.height - (TOPPADING) - tabBarHeight), style: .grouped)
        
        if tabBarHeight > 0{
            ReviewTableview = UITableView(frame: CGRect(x:0, y:TOPPADING, width:view.bounds.width, height:view.bounds.height - (TOPPADING) - tabBarHeight), style: .grouped)
        }
        
        ReviewTableview.register(UserReviewTableViewCell.self, forCellReuseIdentifier: "ReviewCell")
        ReviewTableview.isOpaque = false
        ReviewTableview.isHidden = true
        ReviewTableview.backgroundColor = tableViewBgColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            ReviewTableview.estimatedRowHeight = 0
            ReviewTableview.estimatedSectionHeaderHeight = 0
            ReviewTableview.estimatedSectionFooterHeight = 0
        }
        self.view.addSubview(ReviewTableview)
        
        viewcontener = createView(CGRect(x:0, y:0, width:(UIScreen.main.bounds.width), height:180), borderColor: borderColorMedium, shadow: false)
        viewcontener.layer.borderWidth = 0.0
        viewcontener.backgroundColor = UIColor.clear
        viewcontener.isHidden = true
        ReviewTableview.addSubview(viewcontener)

        lblAvgrating = createLabel(CGRect(x:10, y:20, width:view.bounds.width/2-10, height:20), text: "Overall Rating", alignment: .left, textColor: textColorDark)
        lblAvgrating.font = UIFont(name: fontBold, size: FONTSIZELarge)

        viewcontener.addSubview(lblAvgrating)
        
        viewAvgRating = createView(CGRect(x:view.bounds.width/2, y:10, width:view.bounds.width/2-10, height:30), borderColor: UIColor.clear, shadow: true)
        viewAvgRating.backgroundColor = UIColor.clear

        viewcontener.addSubview(viewAvgRating)
        
        self.rated = true
        self.updateAvgRating(0, ratingCount:0)

        lblmyrating = createLabel(CGRect(x:view.bounds.width/2, y:10, width:view.bounds.width/2-10, height:20), text: "My Rating", alignment: .left, textColor: textColorDark)
        lblmyrating.font = UIFont(name: fontName, size: FONTSIZELarge)
        lblmyrating.textAlignment = NSTextAlignment.center

        viewcontener.addSubview(lblmyrating)
        lblmyrating.isHidden = true
        

        lblreviewcount = createLabel(CGRect(x:10, y:getBottomEdgeY(inputView: viewAvgRating) + 10, width:view.bounds.width-20, height:12), text: "Average User Rating", alignment: .left, textColor: textColorMedium)
        lblreviewcount.font = UIFont(name: fontName, size: FONTSIZENormal)
        lblreviewcount.textAlignment = NSTextAlignment.left;

        viewcontener.addSubview(lblreviewcount)
        lblreviewcount.isHidden = true
        
        
        lblrecomendedcount = createLabel(CGRect(x:10,y:lblreviewcount.frame.origin.y + lblreviewcount.frame.size.height + 3,width:view.bounds.width-20, height:12), text: "Average User Rating", alignment: .left, textColor: textColorMedium)
        lblrecomendedcount.font = UIFont(name: fontName, size: FONTSIZENormal)
        lblrecomendedcount.textAlignment = NSTextAlignment.left;
        viewcontener.addSubview(lblrecomendedcount)

        // Initialize Pull to Refresh to ActivityFeed Table
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(PageReviewViewController.refresh), for: UIControl.Event.valueChanged)
        ReviewTableview.addSubview(refresher)
 

    }
    
    override func viewDidAppear(_ animated: Bool) {

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

    override func viewWillAppear(_ animated: Bool)

    {
        if let navigationBar = self.navigationController?.navigationBar {
            if self.marqueeHeader != nil{
                self.marqueeHeader.text = ""
                removeMarqueFroMNavigaTion(controller: self)
            }
            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            self.marqueeHeader = MarqueeLabel(frame: firstFrame)
            self.marqueeHeader.tag = 101
            self.marqueeHeader.setDefault()
            if self.mytitle != nil && self.mytitle != "" {
            self.marqueeHeader.text = "User Reviews (" + String(currentReviewcount) + "): " + self.mytitle + ")"
            }
            else{
                self.marqueeHeader.text = "User Reviews (" + String(currentReviewcount) + ")"
            }
            navigationBar.addSubview(self.marqueeHeader)
        }
        
        if reviewUpdate == true{

            exploreContent()
        }
        
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
    func exploreContent()
    {
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
            removeAlert()
            if self.showSpinner
            {
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            var url = ""
            var parameters = Dictionary<String, String>()
            
            switch(contentType){
            case "advancedevents":
                parameters = ["getRating": "1", "rsvp_form": "1"]
                url = "advancedevents/reviews/browse/event_id/\(self.subjectId!)"
                break
                
            case "Pages":
                parameters = ["getRating": "1", "rsvp_form": "1"]
                url = "sitepage/reviews/browse/\(self.subjectId!)"
                
            case "listings":
                parameters = ["getRating": "1", "listing_id": String(subjectId), "listingtype_id": String(listingTypeId)]
                url = "listings/reviews"
                break
                
                
            case "product":
                parameters = ["getRating": "1"]
                url = "sitestore/product/review/browse/\(subjectId!)"
                break
                
            case "sitestore_store":
                parameters = ["getRating": "1"]
                url = "sitestore/reviews/browse/\(self.subjectId!)"
                
                break
            case "siteproduct_review":
                parameters = ["getRating": "1"]
                url = "sitestore/product/review/view/\(self.subjectId!)/\(self.reviewId!)"
                
                break
                
            case "sitegroup":
                
                parameters = ["getRating": "1", "rsvp_form": "1"]
                url = "advancedgroups/reviews/browse/\(self.subjectId!)"
    

                
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
                                // On Success Update Content Detail
                                if let response = succeeded["body"] as? NSDictionary
                                {
                                    // Update Content Gutter Menu
                                    
                                    if let totalreview = response["total_reviews"] as? Int{
                                        self.lblreviewcount.isHidden = false
                                        if totalreview == 1{
                                            self.lblreviewcount.text = NSLocalizedString("Based on \(totalreview) Review", comment:"")
                                        }else {
                                            self.lblreviewcount.text = NSLocalizedString("Based on \(totalreview) Reviews", comment: "")
                                        }
                                        
                                        //self.lblreviewcount.text = "Based on \(totalreview) Reviews"
                                        if let navigationBar = self.navigationController?.navigationBar {
                                            if self.marqueeHeader != nil{
                                                self.marqueeHeader.text = ""
                                                removeMarqueFroMNavigaTion(controller: self)
                                            }
                                            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
                                            self.marqueeHeader = MarqueeLabel(frame: firstFrame)
                                            self.marqueeHeader.tag = 101
                                            self.marqueeHeader.setDefault()
                                            if self.mytitle != nil && self.mytitle != "" {
                                                self.marqueeHeader.text = "User Reviews (" + String(totalreview) + "): " + self.mytitle + ")"
                                            }
                                            else{
                                                self.marqueeHeader.text = "User Reviews (" + String(totalreview) + ")"
                                            }
                                           
                                            navigationBar.addSubview(self.marqueeHeader)
                                        }
                                        
                                        
                                    }

                                    if let rateingdic = response["ratings"] as? NSDictionary
                                    {
                                        self.viewcontener.isHidden = false
                                        if let rating = rateingdic["rating_avg"] as? Int
                                        {
                                            self.rated = true
                                            self.updateAvgRating(rating, ratingCount: (rateingdic["rating_avg"] as? Int)!)
                                        }
                                        
                                        self.lblrecomendedcount.frame.origin.y = self.lblreviewcount.frame.origin.y + self.lblreviewcount.frame.size.height + 3
                                        if let RecommendedValue = rateingdic["recomended"] as? String{
                                            self.lblrecomendedcount.text = "Recommended by \(RecommendedValue) members"
                                            
                                        } else {
                                            self.lblrecomendedcount.text = "Recommended by 0 members"
                                        }

                                        var origin_labelheight_y = getBottomEdgeY(inputView: self.lblrecomendedcount) + 10

                                        var origin_labelheight_y2 = origin_labelheight_y
                                        
                                        
                                        if (rateingdic["breakdown_ratings_params"]! as AnyObject).count > 0 {

                                            if  let   reviewResponse = rateingdic["breakdown_ratings_params"] as? NSArray  {
                                                
                                                var loop : Int = 0
                                                
                                                for tempMenu in reviewResponse{
                                                    let tempMenu = tempMenu as! NSDictionary
                                                    if loop % 2 == 0{
                                                        let label1 = UILabel()
                                                        let ratingView = UIView()
                                                        
                                                        label1 .frame = CGRect(x:10, y:origin_labelheight_y + 5, width:self.view.bounds.width/2 - 20, height:30)
                                                        label1.textColor = textColorDark
                                                        label1.isHidden = false
                                                        
                                                        if self.contentType == "product"{
                                                            label1.text = tempMenu["ratingparam_name"] as? String
                                                        }
                                                        else{
                                                            label1.text = tempMenu["reviewcat_name"] as? String
                                                        }
                                                        
                                                        label1.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                                                        label1.numberOfLines = 0
                                                        label1.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                        label1.sizeToFit()
                                                        self.viewcontener.addSubview(label1)
                                                        
                                                        ratingView.frame = CGRect(x: 10, y:label1.bounds.height + origin_labelheight_y, width:self.view.bounds.width/2 - 30, height:20)
                                                        ratingView.backgroundColor = UIColor.clear
                                                        self.viewcontener.addSubview(ratingView)
                                                        
                                                        if let rating = tempMenu["avg_rating"] as? Int
                                                        {
                                                            self.rated = true
                                                            // self.updateRating(rating, ratingCount: (subValue[indexPath.row] as? Int)!)
                                                            self.updateRating1(rating, ratingCount:rating, ratingView: ratingView)
                                                        }
                                                        
                                                        ratingView.sizeToFit()
                                                        
                                                        origin_labelheight_y = origin_labelheight_y + label1.bounds.height + ratingView.bounds.height + 5
                                                        loop = loop + 1
                                                        
                                                    }
                                                    else {
                                                        
                                                        loop = loop + 1
                                                        
                                                        let label3 = UILabel()
                                                        let ratingView = UIView()
                                                        
                                                        label3.frame = CGRect(x:self.view.bounds.width/2 + 20,y:origin_labelheight_y2 + 5, width:self.view.bounds.width/2 - 20, height:30)
                                                        label3.textColor = textColorDark
                                                        label3.isHidden = false
                                                        
                                                        
                                                        
                                                        if self.contentType == "product"{
                                                            label3.text = tempMenu["ratingparam_name"] as? String
                                                        }
                                                        else{
                                                            label3.text = tempMenu["reviewcat_name"] as? String
                                                        }
                                                        label3.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                                                        label3.numberOfLines = 0
                                                        label3.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                        self.viewcontener.addSubview(label3)
                                                        
                                                        label3.sizeToFit()
                                                        
                                                        
                                                        ratingView.frame = CGRect(x:self.view.bounds.width/2 + 20,y:origin_labelheight_y2 + label3.bounds.height, width:self.view.bounds.width/2 - 30, height:20)
                                                        ratingView.backgroundColor = UIColor.clear
                                                        self.viewcontener.addSubview(ratingView)
                                                        
                                                        if let rating = tempMenu["avg_rating"] as? Int
                                                        {
                                                            self.rated = true
                                                            self.updateRating1(rating, ratingCount:rating , ratingView: ratingView)
                                                        }
                                                        
                                                        ratingView.sizeToFit()
                                                        
                                                        origin_labelheight_y2  = origin_labelheight_y2 + ratingView.bounds.height + label3.bounds.height + 5
                                                    }
                                                }

                                            }
                                            
                                        } else {
                                            origin_labelheight_y = origin_labelheight_y - 5
                                            origin_labelheight_y2 = origin_labelheight_y2 - 5
                                        }
                                        
                                        if origin_labelheight_y2 > origin_labelheight_y{
                                            self.viewcontener.frame.size.height = origin_labelheight_y2
                                        } else {
                                            self.viewcontener.frame.size.height = origin_labelheight_y
                                        }

                                    }
                                    
                                    if let menu = response["reviews"] as? NSArray{
                                        self.reviewArray.removeAll()
                                        self.ReviewTableview.isHidden = false
                                        self.ReviewTableview.dataSource = self
                                        self.ReviewTableview.delegate = self
                                        self.reviewArray +=  PageReviewModel.loadReview(menu)
                                        self.actualreviewarr = menu
                                        
                                    }

                                    
                                    self.ReviewTableview.reloadData()
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
    
    func updateRating1(_ rating:Int, ratingCount:Int , ratingView:UIView)
    {
        for ob in ratingView.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 0 as CGFloat

        for i in stride(from: 1, through: 5, by: 1){

            let rate = createButton(CGRect(x: origin_x, y: 10, width: 15, height: 15), title: "", border: false, bgColor: false, textColor: textColorLight)
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
            origin_x += 15
            ratingView.addSubview(rate)
        }

        }

    func updateRating(_ rating:Int, ratingCount:Int,ratingView:UIView)
    {
        for ob in ratingView.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 0 as CGFloat
        for i in stride(from: 1, through: 5, by: 1){

            let rate = createButton(CGRect(x: origin_x, y: 10, width: 13, height: 13), title: "", border: false, bgColor: false, textColor: textColorLight)
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
            origin_x += 13
            ratingView.addSubview(rate)
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
        if (viewcontener != nil){
            return getBottomEdgeY(inputView: viewcontener)
        }
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {

        return dynamicHeight
    }
    
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return reviewArray.count
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! UserReviewTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        for ob in cell.subviews{
            if ob .isKind(of: UILabel.self){
                
                if ob.tag == 1010{
                    ob.removeFromSuperview()
                }
                
            }
        }
        
        let Reviewdic = reviewArray[(indexPath as NSIndexPath).row]
        let initalReviewDic = actualreviewarr[(indexPath as NSIndexPath).row] as! NSDictionary

        if let abcd = initalReviewDic["guttermenu"] as? NSArray{
            if abcd.count > 0{
                self.hideMenuOption = false
            }
            else{
                self.hideMenuOption = true
            }
        }

        cell.cellView.isUserInteractionEnabled = true
        cell.lblhelpful.isHidden = true
        cell.lblhelpfulstar.isHidden = true
        cell.createdAttbLabel.isHidden = false
        
        cell.createdAt.isHidden = true
        cell.btnhelpful.frame.origin.x = cell.lblhelpful.frame.origin.x - 10


        cell.btnhelpful.titleLabel?.font = UIFont(name: fontBold, size:FONTSIZELarge)
        cell.ratingView.tag = indexPath.row
        cell.btncommentaction.tag = indexPath.row
        cell.btnhelpful.tag = indexPath.row
        cell.btnNothelpful.tag = indexPath.row
        cell.btnNothelpful.isHidden = true
        //cell.btnhelpful.isHidden = true
        
        cell.btncommentaction.addTarget(self, action: #selector(PageReviewViewController.openComment(_:)), for: .touchUpInside)
        cell.btnhelpful.addTarget(self, action: #selector(PageReviewViewController.helpfulAction(sender:)), for: .touchUpInside)
        cell.btnNothelpful.addTarget(self, action: #selector(PageReviewViewController.helpfulAction(sender:)), for: .touchUpInside)
        cell.nothelpfulcommentstar.isHidden = true
        
        cell.reviewMoreOptions.tag = indexPath.row
        cell.reviewMoreOptions.addTarget(self, action: #selector(PageReviewViewController.showReviewMenu(_:)), for: .touchUpInside)
        if logoutUser == false{
            
            if hideMenuOption == false{
                cell.reviewMoreOptions.isHidden = false
            }
            else{
                cell.reviewMoreOptions.isHidden = true


            }
        }
        
        
        if let name = Reviewdic.title
        {

           cell.titleLabel.frame = CGRect(x: 8, y: 2, width: cell.cellView.bounds.width - 120, height: 30)
           cell.titleLabel.text = "\(name)"
           cell.titleLabel.numberOfLines = 1
           cell.titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail

        }
        
        ownerid = Reviewdic.owner_id
        
        if let rating = Reviewdic.overall_rating
        {
            cell.updateRating(rating, ratingCount: rating)
        }
        else
        {
            cell.updateRating(0, ratingCount: 0)
        }
        
        if let createdate = Reviewdic.creation_date
        {
            let postedOn = dateDifference(createdate)
            
            if let ownerName = Reviewdic.owner_title {
                
                cell.btnUser.isHidden = true
                
                let labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), ownerName, postedOn)
                cell.createdAttbLabel.text = labMsg


                cell.createdAttbLabel.textColor = textColorMedium
                cell.createdAttbLabel.font = UIFont(name: fontName, size: FONTSIZESmall)
                cell.createdAttbLabel.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                    var boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZESmall, nil)
                    boldFont =  CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZESmall, nil)
                    
                    let range1 = (labMsg as NSString).range(of: ownerName)
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range1)
                    mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)
                    
                    return mutableAttributedString!
                })


                
                let range1 = (labMsg as NSString).range(of: ownerName)
                cell.createdAttbLabel.addLink(toTransitInformation: [ "id" : Reviewdic.owner_id!,"type" : "user"], with:range1)

                
                let activeLinkAttributes = NSMutableDictionary(dictionary: cell.createdAttbLabel.activeLinkAttributes)
                activeLinkAttributes[NSAttributedString.Key.foregroundColor] = UIColor.black
                
                let linkAttributes = NSMutableDictionary(dictionary: cell.createdAttbLabel.linkAttributes)
                linkAttributes[NSAttributedString.Key.foregroundColor] = UIColor.black
                linkAttributes[NSAttributedString.Key.underlineStyle] = .none
                
                cell.createdAttbLabel.linkAttributes = [kCTForegroundColorAttributeName:UIColor.black]
                
                cell.createdAttbLabel.activeLinkAttributes = activeLinkAttributes as NSDictionary as! [AnyHashable: Any]
                
                cell.createdAttbLabel.delegate = self
                cell.createdAttbLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.createdAttbLabel.sizeToFit()


            } else {

                cell.createdAt.text = "\(postedOn)"
            }
        }
        
        var origin_labelheight_y:CGFloat =  50
        var origin_labelheight_y2:CGFloat = 50
        
        if Reviewdic.breakdown_ratings_params!.count > 0
        {

            if let reviewResponse = Reviewdic.breakdown_ratings_params
            {
                
                var loop : Int = 0
                for tempMenu in reviewResponse{
                let tempMenu = tempMenu as! NSDictionary
                    if loop % 2 == 0
                    {
                        let label1 = UILabel()

                        let ratingCellView = UIView()

                        label1.frame = CGRect(x: 10,y: origin_labelheight_y+5,width: cell.cellView.bounds.width/2 - 20 , height: 30)
                        label1.tag = 1010
                        label1.isHidden = false
                        label1.textColor = textColorDark

                        if self.contentType == "product"{
                            label1.text = tempMenu["ratingparam_name"] as? String
                        }
                        else{
                            label1.text = tempMenu["reviewcat_name"] as? String
                        }
                        label1.font = UIFont(name: fontNormal, size: FONTSIZEMedium)

                        label1.numberOfLines = 0
                        label1.lineBreakMode = NSLineBreakMode.byWordWrapping
                        label1.sizeToFit()
                        
                        ratingCellView.frame = (CGRect(x: 10,y:label1.bounds.height + origin_labelheight_y ,width:cell.cellView.bounds.width/2 - 30, height:20))
                        ratingCellView.backgroundColor = UIColor.clear
                        ratingCellView.tag = 1010

                        if let rating = tempMenu["rating"] as? Int

                        {
                            self.rated = true
                            self.updateRating(rating, ratingCount:rating,ratingView: ratingCellView)
                        }

                        origin_labelheight_y  = origin_labelheight_y + label1.bounds.height + cell.ratingView.bounds.height + 10

                        ratingCellView.sizeToFit()
                        cell.addSubview(label1)
                        cell.addSubview(ratingCellView)
                        
                        loop = loop + 1
                        
                    }
                    else
                    {
                        
                        loop = loop + 1
                        
                        let label3 = UILabel()
                        let ratingCellView = UIView()
                        
                        label3.frame = CGRect(x: cell.cellView.bounds.width/2 + 20,y: origin_labelheight_y2 + 5 ,width: cell.cellView.bounds.width/2 - 20 , height: 30)
                        label3 .isHidden = false
                        label3 .textColor = textColorDark

                        label3 .isHidden = false
                        label3.tag = 1010

                        if self.contentType == "product"{
                            label3.text = tempMenu["ratingparam_name"] as? String
                        }
                        else{
                            label3 .text = tempMenu["reviewcat_name"] as? String
                        }
                        label3 .font = UIFont(name: fontNormal, size: FONTSIZEMedium)

                        label3 .numberOfLines = 0
                        label3 .lineBreakMode = NSLineBreakMode.byWordWrapping
                        
                        label3 .sizeToFit()
                        
                        ratingCellView.frame = CGRect(x: cell.cellView.bounds.width/2 + 20,y: origin_labelheight_y2  + label3.bounds.height,width: cell.cellView.bounds.width/2 - 30, height: 20)
                        ratingCellView.backgroundColor = UIColor.clear

                        ratingCellView.tag = 1010

                        if let rating = tempMenu["rating"] as? Int
                        {
                            self.rated = true
                            self.updateRating(rating, ratingCount:rating,ratingView:ratingCellView)
                        }
                        
                        ratingCellView.sizeToFit()
                        cell.addSubview(ratingCellView)
                        cell.addSubview(label3)
                        
                        origin_labelheight_y2  = origin_labelheight_y2 + cell.ratingView.bounds.height + label3.bounds.height + 10

                    }
                }
            }
        }
        else
        {
            origin_labelheight_y = origin_labelheight_y - 5
            origin_labelheight_y2 = origin_labelheight_y2 - 5
        }
        
        
        if origin_labelheight_y2 > origin_labelheight_y{

            cell.lblprostext.frame.origin.y  = origin_labelheight_y2 + 15
        } else {
            cell.lblprostext.frame.origin.y  =  origin_labelheight_y + 15
        }

        cell.lblRecomnded.isHidden = true

        
        if let pros = Reviewdic.pros
        {
            cell.lblpros.frame.origin.y = cell.lblprostext.frame.origin.y

            cell.lblprostext.numberOfLines = 0
            cell.lblprostext.text = "\(pros)"
            cell.lblprostext.lineBreakMode = NSLineBreakMode.byWordWrapping
            if cell.lblprostext.text != ""
            {
               cell.lblprostext.sizeToFit()
            }
            cell.lblprostext.frame.size.width = cell.cellView.bounds.width - 50
        }
        
        if let cons = Reviewdic.cons
        {
            cell.lblconstext.numberOfLines = 0
            cell.lblconstext.text = "\(cons)"
            cell.lblconstext.lineBreakMode = NSLineBreakMode.byWordWrapping
            if cell.lblconstext.text != ""
            {
              cell.lblconstext.sizeToFit()
            }
            cell.lblconstext.frame.size.width = cell.cellView.bounds.width - 50
            cell.lblconstext.frame.origin.y = cell.lblprostext.frame.origin.y + cell.lblprostext.frame.size.height
            cell.lblcons.frame.origin.y = cell.lblprostext.frame.origin.y + cell.lblprostext.frame.size.height
        }
        
        if let body = Reviewdic.body
        {
            cell.lblsummary.frame.origin.y = getBottomEdgeY(inputView: cell.lblconstext) + 5
            cell.lblsummarytext.numberOfLines = 0
            
            cell.lblsummarytext.text = "\(body.html2String)"
            cell.lblsummarytext.lineBreakMode = NSLineBreakMode.byWordWrapping

            cell.lblsummarytext.sizeToFit()

            cell.lblsummarytext.frame.size.width = cell.cellView.bounds.width - cell.titleLabel.frame.origin.x - 10
            cell.lblsummarytext.frame.origin.y = getBottomEdgeY(inputView: cell.lblsummary)
            
        }
        if contentType != "product"{
            cell.lblrecommend.isHidden = false
            cell.lblrecommendtext.isHidden = false
            cell.lblrecommend.frame.origin.y = getBottomEdgeY(inputView: cell.lblsummarytext) + 10
            cell.lblrecommendtext.text = Reviewdic.recommendText
            cell.lblrecommendtext.frame.origin.y = getBottomEdgeY(inputView: cell.lblsummarytext) + 2
        }
        
//        cell.reviewMoreOptions.frame = CGRect(x: cell.bounds.width - 40, y:getBottomEdgeY(inputView: cell.lblsummarytext) + 10, width:40, height:15)
        
        cell.viewActivity.frame = CGRect(x:0, y:getBottomEdgeY(inputView: cell.lblsummarytext)+50,width:cell.cellView.frame.size.width,height:50)

        
        if let commentcount = Reviewdic.comment_count
        {

        
            if commentcount == 1
            {
                cell.lblcomment.text = "\(commentcount) Comment"
            }
            else
            {
                cell.lblcomment.text = "\(commentcount) Comments"
            }
        }
        
        cell.lblhelpfulcount.isHidden = true

        cell.lblNothelpfulcount.isHidden = true
        
        if let recomended = Reviewdic.recommend
        {
            if recomended == 1
            {

                cell.btnright.isHidden = false
                cell.lblRecomnded.isHidden = false
            }
            else
            {
                cell.btnright.isHidden = true
                cell.lblRecomnded.isHidden = true

            }
            
        }
        else
        {
            cell.btnright.isHidden = true
        }
        
        
        let helpful = Reviewdic.is_liked
        if helpful == false
        {
            if let helpfulcount = Reviewdic.like_count
            {
                like_unlikecount = helpfulcount
                
                cell.btnhelpful.setTitleColor(textColorMedium, for: UIControl.State())
                if helpfulcount == 1
                {
                 cell.btnhelpful.setTitle("\(helpfulcount) Like", for: UIControl.State())
                }
                else
                {
                 cell.btnhelpful.setTitle("\(helpfulcount) Likes", for: UIControl.State())
                }
                

            }
            
        }
        else
        {
            if let helpfulcount = Reviewdic.like_count
            {
                like_unlikecount = helpfulcount
                
                cell.btnhelpful.setTitleColor(navColor, for: UIControl.State())
                if helpfulcount == 1
                {
                    cell.btnhelpful.setTitle("\(helpfulcount) Like", for: UIControl.State())
                }
                else
                {
                    cell.btnhelpful.setTitle("\(helpfulcount) Likes", for: UIControl.State())
                }
                


            }
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

            let rate = createButton(CGRect(x: origin_x, y: 10, width: 20, height: 20), title: "", border: false, bgColor: false, textColor: textColorLight)
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
    
    @objc func openComment(_ sender:UIButton)
    {
        if logoutUser == false{
            
            
            let Reviewdic = reviewArray[sender.tag]
            
            switch(contentType){
            case "product":
                likeCommentContentType = "sitestoreproduct_review"
            case "sitestore_store":
                likeCommentContentType = "sitestorereview_review"
             case "sitegroup":
                likeCommentContentType = "sitegroupreview_review"
            default:
                likeCommentContentType = "sitepagereview_review"
            }
            
            let presentedVC = CommentsViewController()
            
            if let reviewid = Reviewdic.review_id
            {
                likeCommentContent_id = "\(reviewid)"
            }
            
            
            presentedVC.openCommentTextView = 1
            presentedVC.activityfeedIndex = sender.tag
            presentedVC.activityFeedComment = false
            //presentedVC.fromActivityFeed = true
            presentedVC.commentPermission = 1
            //presentedVC.actionId = self.subjectId
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:true, completion: nil)
        }
        
    }
    
    @objc func helpfulAction(sender:UIButton)
    {
        if logoutUser == false{
            
            let currentWishList = reviewArray[sender.tag]
            
            if currentWishList.is_liked!  == true {
                sender.setTitle("Like", for: .normal)
                sender.setTitleColor(textColorMedium, for: .normal)
                //sender.tintColor = textColorLight
                animationEffectOnButton(sender)
                currentWishList.is_liked = false
                currentWishList.like_count = currentWishList.like_count! - 1
                
                self.callIshelpful(sender.tag,sender : sender)
            }
            else{
                sender.setTitle("Unlike", for: .normal)
                sender.setTitleColor(navColor, for: .normal)
                animationEffectOnButton(sender)
                currentWishList.is_liked = true
                currentWishList.like_count = currentWishList.like_count! + 1
                self.callIshelpful(sender.tag,sender : sender)
            }


        }

    }
    
    func userprofileAction()
    {
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

    func callIshelpful(_ indexPath : Int, sender : UIButton)
    {
        let currentWishList = reviewArray[indexPath]
        
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
            
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var url = ""
            var method = "GET"
            var parameters = Dictionary<String, String>()
            
            switch(contentType){
                
                
            case "Pages":
                
                parameters = [:]
                url = "sitepage/review/like/" + String(self.subjectId) + "/" + String(currentWishList.review_id)
                method = "POST"
                
            case "sitestore_store":
                parameters = [:]
                url = "sitestore/review/like/" + String(self.subjectId) + "/" + String(currentWishList.review_id)
                method = "POST"
                
            case "product":
                
                parameters = [:]
                url = "sitestore/product/review/like/" + String(self.subjectId) + "/" + String(currentWishList.review_id)
                method = "POST"
             
            case "sitegroup":
                parameters = [:]
                method = "POST"
                url = "advancedgroups/review/like/\(self.subjectId!)/\(currentWishList.review_id!)"
                
   

                
            default:
                break
            }

            sender.isUserInteractionEnabled = false

            post( parameters, url: url, method: "\(method)") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        //print("hello")
                        sender.isUserInteractionEnabled = true
                        self.ReviewTableview.reloadData()
                        
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
        var param: NSDictionary = [:]
        var confirmationAlert = true
        
        if let menuOption = reviewInfo["guttermenu"] as? NSArray {
            
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
                            param = [ : ]
                            
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
                            
                        case "edit_review":
                            
                            isCreateOrEdit = false
                            globFilterValue = ""
                            confirmationAlert = false
                            let presentedVC = FormGenerationViewController()
                            presentedVC.formTitle = NSLocalizedString("Edit Review", comment: "")
                            presentedVC.contentType = "Review"
                            presentedVC.param = [ : ]
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

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {

        
        let type = components["type"] as! String
        
        switch(type){
        case "user":
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(components["id"]!)"
            self.navigationController?.pushViewController(presentedVC, animated: true)
        default:
            print("default")
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
                            pageDetailUpdate = true
                            if (self.reviewArray.count - 1) == 0{
                                listingDetailUpdate = true
                                pageDetailUpdate = true
                                productDetailUpdate = true
                                advGroupDetailUpdate = true
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
                    return "\(updatedSummary)"
                }
            }
            return summary
        }
        
        return ""
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        //setNavigationImage(controller: self)
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
}
