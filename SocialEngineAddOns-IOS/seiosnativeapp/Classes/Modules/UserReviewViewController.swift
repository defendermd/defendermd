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
//  UserReviewViewController.swift
//  seiosnativeapp
//

import UIKit

class UserReviewViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    var mytitle : String!
    var count:Int!
    var subjectId : Int!
    var ReviewTableview:UITableView!
    var viewcontener:UIView!
    var lblAvgrating:UILabel!
    var lblmyrating:UILabel!
    var viewAvgRating:UIView!
    var viewMyRating:UIView!
    var rated:Bool!
    
    var lblreviewcount:UILabel!
    var lblrecomendedcount:UILabel!
    
    var reviewarr:NSMutableArray!
    var actualreviewarr:NSArray!
    var dynamicHeight : CGFloat = 200
    var reviewid:Int!
    var ishelp:Int!
    var indextag:NSIndexPath!
    
    var refresher:UIRefreshControl!
    var showSpinner = true
    var listingTypeId: Int!
    var reviewGutterMenu = []

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        
        self.automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = bgColor
        navigationController?.navigationBar.hidden = false
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        if count > 0
        {
            
            self.title = NSLocalizedString("User Reviews (\(count)): \(mytitle)",  comment: "")
        }
        else
        {
            self.title = NSLocalizedString("User Reviews (0): \(mytitle)",  comment: "")
            
        }
        
        let leftNavView = UIView(frame: CGRectMake(0, 0, 44, 44))
        leftNavView.backgroundColor = UIColor.clearColor()
        
        let tapView = UITapGestureRecognizer(target: self, action: Selector("cancel"))
        leftNavView.addGestureRecognizer(tapView)
        
        
        let backIconImageView = createImageView(CGRectMake(0,12,22,22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")
        leftNavView.addSubview(backIconImageView)
        
        if footerDashboard == false {
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        
        
        viewcontener = createView(CGRectMake(0, 0,(CGRectGetWidth(UIScreen.mainScreen().bounds)) , 180), borderColor: borderColorMedium, shadow: false)
        viewcontener.layer.borderWidth = 0.0
        viewcontener.backgroundColor = UIColor.clearColor()
        viewcontener.hidden = true
        self.view.addSubview(viewcontener)
        
        
        lblAvgrating = createLabel(CGRectMake(10,70,CGRectGetWidth(view.bounds)/2-10, 20), text: "Average User Rating", alignment: .Left, textColor: textColorDark)
        lblAvgrating.font = UIFont(name: fontName, size: 16)
        lblAvgrating.textAlignment = NSTextAlignment.Center;
        viewcontener.addSubview(lblAvgrating)
        
        viewAvgRating = createView(CGRectMake(10,lblAvgrating.frame.origin.y+lblAvgrating.frame.size.height, CGRectGetWidth(view.bounds)/2-10, 30), borderColor: UIColor.clearColor(), shadow: true)
        viewAvgRating.backgroundColor = UIColor.clearColor()
        viewcontener.addSubview(viewAvgRating)
        self.rated = true
        self.updateAvgRating(0, ratingCount:0)
        
        
        lblmyrating = createLabel(CGRectMake(CGRectGetWidth(view.bounds)/2,70,CGRectGetWidth(view.bounds)/2-10, 20), text: "My Rating", alignment: .Left, textColor: textColorDark)
        lblmyrating.font = UIFont(name: fontName, size: 16)
        lblmyrating.textAlignment = NSTextAlignment.Center;
        viewcontener.addSubview(lblmyrating)
        
        viewMyRating = createView(CGRectMake(CGRectGetWidth(view.bounds)/2+10,lblAvgrating.frame.origin.y+lblAvgrating.frame.size.height, CGRectGetWidth(view.bounds)/2-10, 30), borderColor: UIColor.clearColor(), shadow: true)
        viewMyRating.backgroundColor = UIColor.clearColor()
        viewcontener.addSubview(viewMyRating)
        self.rated = true
        self.updatemyRating(0, ratingCount:0)
        
        lblreviewcount = createLabel(CGRectMake(10,viewAvgRating.frame.origin.y+viewAvgRating.frame.size.height+10,CGRectGetWidth(view.bounds)-20, 12), text: "Average User Rating", alignment: .Left, textColor: textColorMedium)
        lblreviewcount.font = UIFont(name: fontName, size: 12)
        lblreviewcount.textAlignment = NSTextAlignment.Left;
        viewcontener.addSubview(lblreviewcount)
        
        lblrecomendedcount = createLabel(CGRectMake(10,lblreviewcount.frame.origin.y+lblreviewcount.frame.size.height+3,CGRectGetWidth(view.bounds)-20, 12), text: "Average User Rating", alignment: .Left, textColor: textColorMedium)
        lblrecomendedcount.font = UIFont(name: fontName, size: 12)
        lblrecomendedcount.textAlignment = NSTextAlignment.Left;
        viewcontener.addSubview(lblrecomendedcount)
        
        
        // Set tableview to show events
        ReviewTableview = UITableView(frame: CGRectMake(0, ButtonHeight+ButtonHeight+64+30, CGRectGetWidth(view.bounds), CGRectGetHeight(view.bounds)-(ButtonHeight+ButtonHeight+64+30)), style: .Grouped)
        ReviewTableview.registerClass(UserReviewTableViewCell.self, forCellReuseIdentifier: "ReviewCell")
        ReviewTableview.estimatedRowHeight = 200.0
        ReviewTableview.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0)
        //        ReviewTableview.dataSource = self
        //        ReviewTableview.delegate = self
        ReviewTableview.opaque = false
        ReviewTableview.hidden = true
        ReviewTableview.backgroundColor = UIColor.redColor()
        ReviewTableview.backgroundColor = tableViewBgColor
        self.view.addSubview(ReviewTableview)
        
        
        // Initialize Pull to Refresh to ActivityFeed Table
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        ReviewTableview.addSubview(refresher)
        
        
    }
    
    
    override func viewWillAppear(animated: Bool)
    {
        exploreContent()
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        
        return 0.00001
        
    }
    
    // Set Tabel Header Height
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.00001
    }
    
    // Set TableView Section
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    // Set height for row at index path
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    
    // Set No. of Rows in Section
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return reviewarr.count
    }
    
    
    // Set Cell of TabelView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ReviewCell", forIndexPath: indexPath) as! UserReviewTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        let Reviewdic = reviewarr[indexPath.row] as! NSDictionary
        
        cell.ratingView.tag = indexPath.row
        cell.btncommentaction.tag = indexPath.row
        cell.btnhelpful.tag = indexPath.row
        cell.btnNothelpful.tag = indexPath.row
        
        cell.btncommentaction .addTarget(self, action: "openComment:", forControlEvents: .TouchUpInside)
        cell.btnhelpful .addTarget(self, action: "helpfulAction:", forControlEvents: .TouchUpInside)
        cell.btnhelpful.setTitle("\u{f164}", forState: .Normal)
        cell.btnNothelpful .addTarget(self, action: "nothelpfulAction:", forControlEvents: .TouchUpInside)
        
        print("below is revuiewd dictionary")
        print(Reviewdic)
        
        cell.reviewMoreOptions.tag = indexPath.row
        cell.reviewMoreOptions.addTarget(self, action: "showReviewMenu:", forControlEvents: .TouchUpInside)
        cell.reviewMoreOptions.hidden = false
        
        if let name = Reviewdic["title"] as? String
        {
            cell.titleLabel.text = "\(name)"
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
            cell.createdAt.text = "\(postedOn)"
        }
        
        if let pros = Reviewdic["pros"] as? String
        {
            
            cell.lblprostext.text = "\(pros)"
            cell.lblprostext.sizeToFit()
        }
        
        if let cons = Reviewdic["cons"] as? String
        {
            
            cell.lblconstext.text = "\(cons)"
            cell.lblconstext.sizeToFit()
        }
        
        if let summary = Reviewdic["body"] as? String
        {
            
            cell.lblsummarytext.text = "\(summary)"
            cell.lblsummarytext.sizeToFit()
        }
        
        cell.viewActivity.frame = CGRectMake(0,cell.lblsummarytext.frame.origin.y + cell.lblsummarytext.frame.size.height+10,cell.cellView.frame.size.width,50)
        
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
                cell.btnright.hidden = false
            }
            else
            {
                cell.btnright.hidden = true
            }
            
        }
        else
        {
            cell.btnright.hidden = true
        }
        
        
        let helpful = Reviewdic["is_helful"] as? Bool
        if helpful == false
        {
            
            cell.btnhelpful.selected = false
            cell.btnhelpful.userInteractionEnabled = true
            
            
        }
        else
        {
            cell.btnhelpful.selected = true
            cell.btnhelpful.userInteractionEnabled = false
            
        }
        
        let nothelpful = Reviewdic["is_not_helful"] as? Bool
        
        if nothelpful == false
        {
            cell.btnNothelpful.selected = false
            cell.btnNothelpful.userInteractionEnabled = true
        }
        else
        {
            
            cell.btnNothelpful.selected = true
            cell.btnNothelpful.userInteractionEnabled = false
            
        }
        
        
        dynamicHeight = 50
        
        if dynamicHeight < (cell.viewActivity.frame.origin.y + CGRectGetHeight(cell.viewActivity.bounds))
        {
            dynamicHeight = (cell.viewActivity.frame.origin.y + CGRectGetHeight(cell.viewActivity.bounds))
            cell.cellView.frame.size.height = dynamicHeight
        }
        
        
        return cell
        
    }
    
    
    // MARK:Rating Function
    func updateAvgRating(rating:Int, ratingCount:Int)
    {
        
        
        for ob in viewAvgRating.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 15 as CGFloat
        for(var i = 1 ; i <= 5; i++){
            let rate = createButton(CGRectMake(origin_x, 10, 20, 20), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clearColor()
            rate.setImage(UIImage(named: "graystar.png"), forState: .Normal )
            
            if rated == false
            {
                rate.tag = i
                rate.addTarget(self, action: "rateAction:", forControlEvents: .TouchUpInside)
            }
            else
            {
                if i <= rating
                {
                    //                    rate.backgroundColor = UIColor.greenColor()
                    rate.setImage(UIImage(named: "yellowStar.png"), forState: .Normal )
                }
                
            }
            origin_x += 22
            viewAvgRating.addSubview(rate)
        }
        
        
    }
    
    
    // MARK:Rating Function
    func updatemyRating(rating:Int, ratingCount:Int)
    {
        
        
        for ob in viewMyRating.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 15 as CGFloat
        for(var i = 1 ; i <= 5; i++){
            let rate = createButton(CGRectMake(origin_x, 10, 20, 20), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clearColor()
            rate.setImage(UIImage(named: "graystar.png"), forState: .Normal )
            
            if rated == false
            {
                rate.tag = i
                rate.addTarget(self, action: "rateAction:", forControlEvents: .TouchUpInside)
            }
            else
            {
                if i <= rating
                {
                    //                    rate.backgroundColor = UIColor.greenColor()
                    rate.setImage(UIImage(named: "yellowStar.png"), forState: .Normal )
                }
                
            }
            origin_x += 22
            viewMyRating.addSubview(rate)
        }
        
        
    }
    
    
    func openComment(sender:UIButton)
    {
        
        let Reviewdic = reviewarr[sender.tag] as! NSDictionary
        likeCommentContentType = "sitereview_review"
        let presentedVC = CommentsViewController()
        
        if let reviewid = Reviewdic["review_id"] as? Int
        {
            likeCommentContent_id = reviewid
        }
        
        
        presentedVC.openCommentTextView = 1
        presentedVC.activityfeedIndex = sender.tag
        presentedVC.activityFeedComment = true
        presentedVC.fromActivityFeed = true
        presentedVC.commentPermission = 1
        presentedVC.actionId = self.subjectId
        if footerDashboard == true {
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.presentViewController(nativationController, animated:true, completion: nil)
        }else{
            self.navigationController?.pushViewController(presentedVC, animated: true)
        }

        
    }
    
    
    func helpfulAction(sender:UIButton)
    {
        
        
        let index = sender.tag
        let indexPath = NSIndexPath(forRow:index, inSection: 0)
        indextag = indexPath
        if sender.selected
        {
            //sender.selected = false
            
        }
        else
        {
            
            sender.selected = true
            sender.userInteractionEnabled = false
            
            
            let dic = self.actualreviewarr[indexPath.row] as! NSDictionary
            let Reviewdic = dic.mutableCopy() as! NSMutableDictionary
            
            
            reviewid = Reviewdic["review_id"] as! Int
            ishelp = 1
            
            
            Reviewdic["is_helful"] = true
            Reviewdic["is_not_helful"] = false
            self.reviewarr[indexPath.row] = Reviewdic
            self.ReviewTableview.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            self.callIshelpful()
        }
        
    }
    
    
    func nothelpfulAction(sender:UIButton)
    {
        
        
        let index = sender.tag
        let indexPath = NSIndexPath(forRow:index, inSection: 0)
        indextag = indexPath
        if sender.selected
        {
            //sender.selected = false
            
        }
        else
        {
            
            sender.selected = true
            sender.userInteractionEnabled = false
            let dic = self.actualreviewarr[indexPath.row] as! NSDictionary
            let Reviewdic = dic.mutableCopy() as! NSMutableDictionary
            
            reviewid = Reviewdic["review_id"] as! Int
            ishelp = 2
            Reviewdic["is_not_helful"] = true
            Reviewdic["is_helful"] = false
            self.reviewarr[indexPath.row] = Reviewdic
            self.ReviewTableview.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            self.callIshelpful()
            
            
        }
        
    }
    
    
    func callIshelpful()
    {
        
        // Check Internet Connection
        if reachability.isReachable()
        {
            
            removeAlert()
            spinner.center = view.center
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(spinner)
            spinner.startAnimating()
            var url = ""
            let parameters = ["review_id": "\(reviewid)","helpful":"\(ishelp)", "listingtype_id": "\(listingTypeId)", "listing_id":"\(subjectId)"]
            
            url = "listings/review/helpful/\(self.subjectId)"
            post( parameters, url: url, method: "POST") { (succeeded, msg) -> () in
                
                dispatch_async(dispatch_get_main_queue(),
                    {
                        spinner.stopAnimating()
                        if msg
                        {
                            
                            if succeeded["body"] != nil
                            {
                                print(succeeded)
                                if let response = succeeded["body"] as? NSDictionary
                                {
                                    
                                    
                                    self.reviewarr[self.indextag.row] = response
                                    self.ReviewTableview.reloadRowsAtIndexPaths([self.indextag], withRowAnimation: UITableViewRowAnimation.None)
                                    
                                    
                                }
                                
                                
                            }
                        }
                        else
                        {
                            // Handle Server Side Error
                            if succeeded["message"] != nil
                            {
                                self.view.makeToast(succeeded["message"] as! String , duration: 5, position: "bottom")
                                
                                
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
    
    
    func cancel()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // Pull to Request Action
    func refresh(){
        // Check Internet Connectivity
        if reachability.isReachable()
        {
            // Pull to Refreh for Recent Feeds (Reset Variables)
            showSpinner = false
            exploreContent()
        }
        else
        {
            // No Internet Connection Message
            refresher.endRefreshing()
            self.view.makeToast(network_status_msg , duration: 5, position: "bottom")
            
        }
    }
    
    
    // Sevice Calling
    func exploreContent()
    {
        
        // Check Internet Connection
        if reachability.isReachable()
        {
            removeAlert()
            if self.showSpinner
                
            {
                spinner.center = view.center
                spinner.hidesWhenStopped = true
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                self.view.addSubview(spinner)
                spinner.startAnimating()
            }
            
            
            var url = ""
            
            var parameters = ["getRating": "1", "listing_id": "\(subjectId)", "listingtype_id": "\(listingTypeId)"]
            parameters["rsvp_form"] = "1"
            url = "listings/reviews"
            
            
            
            // Send Server Request to Explore listings Contents with listing_ID
            post( parameters, url: url, method: "GET") { (succeeded, msg) -> () in
                
                dispatch_async(dispatch_get_main_queue(),
                    {
                        
                        if self.showSpinner
                            
                        {
                            spinner.stopAnimating()
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
                                self.view.makeToast(succeeded["message"] as! String , duration: 5, position: "bottom")
                                
                            }
                            
                            if succeeded["body"] != nil
                            {
                                print(succeeded)
                                
                                // On Success Update Content Detail
                                if let response = succeeded["body"] as? NSDictionary
                                {
                                    
                                    // Update Content Gutter Menu
                                    if let menu = response["reviews"] as? NSArray
                                    {
                                        self.ReviewTableview.hidden = false
                                        self.ReviewTableview.dataSource = self
                                        self.ReviewTableview.delegate = self
                                        self.reviewarr = menu.mutableCopy() as! NSMutableArray
                                        self.actualreviewarr = menu
                                        self.ReviewTableview.reloadData()
                                    }
                                    
                                    if let rateingdic = response["ratings"] as? NSDictionary
                                    {
                                        self.viewcontener.hidden = false
                                        if let rating = rateingdic["rating_avg"] as? Int
                                        {
                                            self.rated = true
                                            self.updateAvgRating(rating, ratingCount: (rateingdic["rating_avg"] as? Int)!)
                                        }
                                        if let myrating = rateingdic["myRatings"] as? NSArray
                                        {
                                            
                                            if myrating.count>0
                                            {
                                                let dic = myrating[0]
                                                
                                                let myrating = dic["rating"] as! Int
                                                self.updatemyRating(myrating, ratingCount: (dic["rating"] as? Int)!)
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
                                        
                                        self.lblreviewcount.text = "Based on \(totalreview) Reviews"
                                    }
                                    
                                }
                            }
                        }
                        else
                        {
                            // Handle Server Side Error
                            if succeeded["message"] != nil{
                                self.view.makeToast(succeeded["message"] as! String , duration: 5, position: "bottom")
                                
                                
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
    func showAlertMessage( centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer
        {
            // Initialization of Timer
            createTimer(self)
        }
    }
    
    
    // Stop Timer for Check Updation
    func stopMyTimer(){
        if myTimer != nil{
            myTimer.invalidate()
        }
    }
    
    
    // SHOW GUTTER MENUS
    func showReviewMenu(sender:UIButton){
        
        var reviewInfo:NSDictionary
        reviewInfo = reviewarr[sender.tag] as! NSDictionary
        
        var confirmationTitle = ""
        
        var message = ""
        var url = ""
        var param = [:]
        let confirmationAlert = true
        
        let menuOption = reviewInfo["gutterMenus"] as! NSArray
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        for menu in menuOption{
            if let menuItem = menu as? NSDictionary{
                
                alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .Default, handler:{ (UIAlertAction) -> Void in
                    let condition = menuItem["name"] as! String
                    
                    switch(condition){
                        
                    case "delete":
                        
                        confirmationTitle = NSLocalizedString("Delete Review", comment: "")
                        message = NSLocalizedString("Are you sure you want to delete this review?", comment: "")
                        url = menuItem["url"] as! String
                        param = menuItem["urlParams"] as! NSDictionary
                        param.setValue(self.subjectId, forKey: "listing_id")
                        param.setValue(self.listingTypeId, forKey: "listingtype_id")
                        
//                    case "share":
//                        
//                        let presentedVC = ShareContentViewController()
//                        presentedVC.param = menuItem["urlParams"] as! NSDictionary
//                        presentedVC.url = menuItem["url"] as! String
//                        presentedVC.shareContentSubTitle = ""
//                        self.navigationController?.pushViewController(presentedVC, animated: false)
                        
                    case "report":
                        let presentedVC = ReportContentViewController()
                        presentedVC.param = menuItem["urlParams"] as! NSDictionary
                        presentedVC.url = menuItem["url"] as! String
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                        
                    case "update":


                        isCreateOrEdit = true
                        globFilterValue = ""
                        
                        let presentedVC = FormGenerationViewController()
                        presentedVC.formTitle = NSLocalizedString("Update Review", comment: "")
                        presentedVC.contentType = "Review"
                        let param = menuItem["urlParams"] as! NSDictionary
                        let reviewid = param["review_id"] as! Int
                        var tempDic = NSDictionary()
                        tempDic = ["listingtype_id" : "\(self.listingTypeId)","review_id":"\(reviewid)"]
                        presentedVC.param = tempDic
                        presentedVC.url = menuItem["url"] as! String
                        if footerDashboard == true {
                            presentedVC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                            let nativationController = UINavigationController(rootViewController: presentedVC)
                            self.presentViewController(nativationController, animated:false, completion: nil)
                        }else{
                            self.navigationController?.pushViewController(presentedVC, animated: false)
                        }
                        
                    default:
                        
                        print("error")
                    }
                    
                    
                    if confirmationAlert == true {

                        displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                            
                            if condition == "delete"{
                                self.updateReviewMenuAction(param, url: url)
                            }
                        }
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    
                }))
            }
        }
        
        if  (UIDevice.currentDevice().userInterfaceIdiom == .Phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler:nil))
        }else if (UIDevice.currentDevice().userInterfaceIdiom == .Pad){
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.Popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRectMake(view.bounds.width/2, view.bounds.height/2, 1, 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        
        self.presentViewController(alertController, animated:true, completion: nil)
        
    }
    
    // PERFORM ACTIONS PROVIDED IN GUTTER MENUS
    func updateReviewMenuAction(parameter:NSDictionary, url : String){
        
        // Check Internet Connection
        if reachability.isReachable() {
            removeAlert()
            spinner.center = view.center
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            view.addSubview(spinner)
            spinner.startAnimating()
            
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            // Send Server Request to Explore review Contents with review_id
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                dispatch_async(dispatch_get_main_queue(), {
                    spinner.stopAnimating()
                    
                    if msg{
                        // On Success Update listing Detail
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                            
                            if (self.reviewarr.count - 1) == 0{
                               listingDetailUpdate = true
                               self.navigationController?.popViewControllerAnimated(true) 
                            }
                            
                        }
                        
                        self.exploreContent()
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }
}
