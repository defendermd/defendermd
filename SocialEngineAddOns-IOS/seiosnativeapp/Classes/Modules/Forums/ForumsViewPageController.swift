//
//  ForumsViewPageController.swift
//  seiosnativeapp
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


import UIKit
import NVActivityIndicatorView
import Instructions
var forumViewUpdate:Bool!

class ForumsViewPageController: UIViewController, UITableViewDataSource, UITableViewDelegate, TTTAttributedLabelDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    
    var forumId:String!
    var forumName:String! = ""
    var showSpinner = true                      // not show spinner at pull to refresh
    var forumsResponse = [AnyObject]()            // For response come from Server
    var isPageRefresing = false                 // For Pagination
    var forumTableView:UITableView!              // TAbleView to show the Forum Contents
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var updateScrollFlag = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 70             // Dynamic Height fort for Cell
    var forumSlug : String!
    var type : String!
    var id : Int!
    var dynamicReturnHeight : CGFloat!
    var profile : UIButton!
  //  var imageCache = [String:UIImage]()
    var leftBarButtonItem : UIBarButtonItem!
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        forumViewUpdate = true
        self.title = String(format: NSLocalizedString(" %@ ", comment: ""), forumName)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ForumsViewPageController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        // Initialize Forum Table
        forumTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING , width: view.bounds.width, height: view.bounds.height - TOPPADING - tabBarHeight ), style: .grouped)
        forumTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        forumTableView.dataSource = self
        forumTableView.delegate = self
        forumTableView.estimatedRowHeight = 70 //50.0
        forumTableView.rowHeight = UITableView.automaticDimension
        forumTableView.backgroundColor = tableViewBgColor
        forumTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            forumTableView.estimatedSectionHeaderHeight = 0
        }
        view.addSubview(forumTableView)
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(ForumsViewPageController.refresh), for: UIControl.Event.valueChanged)
        forumTableView.addSubview(refresher)
        self.automaticallyAdjustsScrollViewInsets = false;

        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        forumTableView.tableFooterView = footerView
        forumTableView.tableFooterView?.isHidden = true
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        forumTableView.tableFooterView?.isHidden = true
    }
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        let flatCutoutPathMaker = { (frame: CGRect) -> UIBezierPath in
            return UIBezierPath(rect: frame)
        }
        //  self.blackScreen.alpha = 0.5
        var coachMark : CoachMark
        switch(index) {
            
       
            
            
        case 0:
            // skipView.isHidden = true
            var  coachMark2 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 15.0
            let radious : Int = 40
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
            coachMark2.disableOverlayTap = true
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
            
        default:
            coachMark = coachMarksController.helper.makeCoachMark()
            coachMark.gapBetweenCoachMarkAndCutoutPath = 6.0
        }
        
        
        return coachMark
    }
    
    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController, at index: Int) -> Bool{
        
       coachMarksController.stop(immediately: true)
        return false
        
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        
        var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        //  var coachViews: (bodyView: CoachMarkBodyDefaultView, arrowView: CoachMarkArrowDefaultView?)
        
        // For the coach mark at index 2, we disable the ability to tap on the
        // coach mark to get to the next one, forcing the user to perform
        // the appropriate action.
        switch(index) {
        case 0:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        // coachViews.bodyView.isUserInteractionEnabled = false
        default:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
//        case 0:
//            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: "")) \n\n  1/2  "
//            coachViews.bodyView.nextLabel.text = "Next"
            
        case 0:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(createTourText)", comment: ""))"
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Got It", comment: "")
            
            
            
        default: break
        }
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
        
        
    }
    func coachMarksController(_ coachMarksController: CoachMarksController, didEndShowingBySkipping skipped: Bool)
    {
        print("End Skip")
        //  self.blackScreen.alpha = 0.0
        
    }
    
    func showAppTour(){
        let defaults = UserDefaults.standard
        if let name = defaults.object(forKey: "showPluginAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showPluginAppTour") != nil {
                
                self.targetCheckValue = name as! Int
                
                
            }
            
        }
        
        if self.targetCheckValue == 1 {
            
            UserDefaults.standard.set(2, forKey: "showPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
    }
    
    
    // Check for Forum Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        
        if (forumViewUpdate == true) {
            forumViewUpdate = false
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            browseEntries()
        }
    }
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            browseEntries()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            self.showAlertMessage(view.center , msg: network_status_msg , timer: false)
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
    
    @objc func addNewTopic(){
        conditionForm = "topicCreation"
        isCreateOrEdit = true
        textstoreValue = ""
        
        let defaults = UserDefaults.standard
        defaults.set("Coding Explorer", forKey: "forumcheckkey")
        if defaults.value(forKey: "imagePicked") != nil {
            defaults.removeObject(forKey: "imagePicked")
        }
        let presentedVC = FormGenerationViewController()
        presentedVC.formTitle = NSLocalizedString("Post New Topic", comment: "")
        presentedVC.contentType = "forum"
        presentedVC.param = ["forum_id" : "\(forumId!)"]
        presentedVC.url = "forums/\(forumId!)/\(forumSlug!)/topic-create"
        
        UserDefaults.standard.removeObject(forKey: "preferenceName")

        let nativationController = UINavigationController(rootViewController: presentedVC)
        nativationController.modalPresentationStyle = .fullScreen
        self.present(nativationController, animated:false, completion: nil)

        
    }
    
    // MARK: - Server Connection For Forum Updation
    // Update Forum
    func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            if (self.pageNumber == 1){
                self.forumsResponse.removeAll(keepingCapacity: false)
                self.forumTableView.reloadData()
            }
            if (showSpinner){
            //    spinner.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = view.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
              //  activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            // Send Server Request to Browse Forum Entries

            post(["page":"\(pageNumber)", "limit" :"\(limit)"], url: "forums/" + String(forumId) + "/" + String(forumSlug), method: "GET") { (succeeded, msg) -> () in

                DispatchQueue.main.async(execute: {
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    if msg{
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center , msg: succeeded["message"] as! String, timer: true)
                        }
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let forumsTopic = response["response"] as? NSArray {
                                    self.forumsResponse = self.forumsResponse + (forumsTopic as [AnyObject])
                                }
                            }
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                            if (response["can_post"] as! Bool == true){
                                
                                let addTopic = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ForumsViewPageController.addNewTopic))
                                
                                self.navigationItem.rightBarButtonItem = addTopic
                                addTopic.tintColor = textColorPrime
                                self.showAppTour()
                                
                            }
                            self.isPageRefresing = false
                            self.forumTableView.reloadData()
                        }
                    }else{
                        
                        // Handle Server Error
                        if succeeded["body"] != nil{
                            if let response = succeeded["body"] as? NSDictionary{
                                if response["message"] != nil{
                                    //self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                                    self.showAlertMessage(self.view.center , msg: response["message"] as! String, timer: false)
                                }
                                if (response["can_post"] as! Bool == true){
                                    
                                    let addTopic = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(ForumsViewPageController.addNewTopic))
                                    
                                    self.navigationItem.rightBarButtonItem = addTopic
                                    self.showAppTour()
                                    
                                }
                                
                            }
                        }
                        
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.view.center , msg: succeeded["message"] as! String, timer: false)
                        }
                        
                    }
                    
                })
            }
        }else{
            // No Internet Connection Message
            self.showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set  Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set  Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001//30.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set Forum Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set no. of rows in Every section of TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return forumsResponse.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // dequeue a cell for the given indexPath
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        // set the cell's text with the new string formatting
        if let forum = forumsResponse[(indexPath as NSIndexPath).row] as? NSDictionary{
            cell.labTitle.frame = CGRect( x: 5, y: 5 , width: (UIScreen.main.bounds.width - 85) , height: 100)
            cell.labTitle.text = forum["title"] as? String
            cell.labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labTitle.sizeToFit()
            if let postCount = forum["post_count"] as? Int{
                cell.postCount.frame = CGRect(x: (UIScreen.main.bounds.width - 75), y: 5, width: 75, height: 15)
                //cell.postCount.text = singlePluralCheck(NSLocalizedString(" reply", comment: ""), plural: NSLocalizedString(" replies", comment: ""), count: postCount)
                
                if postCount > 1{
                    cell.postCount.text =  String(format: NSLocalizedString("%d replies ", comment: ""),postCount)
                }else if postCount == 1{
                    cell.postCount.text =  String(format: NSLocalizedString("%d reply ", comment: ""),postCount)
                } else if postCount == 0{
                    cell.postCount.text =  String(format: NSLocalizedString("%d replies ", comment: ""),postCount)
                }
                
                cell.postCount.textAlignment = NSTextAlignment.center
                cell.postCount.textColor = UIColor.gray
                cell.postCount.font = UIFont(name: fontName, size: FONTSIZESmall)
            }
            
            cell.labMessage.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 6 ,width: (UIScreen.main.bounds.width - (cell.imgUser.bounds.width)) , height: 100)
            cell.labMessage.font = UIFont(name: fontName, size:13)
            cell.imgUser.frame.origin.y = cell.labMessage.frame.origin.y + 4
            var subTitle = ""
            var postedBy = ""
            if let last_posted_by = forum["last_posted_by"] as? NSDictionary{
                if let displayName = last_posted_by["displayname"] as? String {
                    postedBy = displayName
                }else{
                    postedBy = ""
                }
                subTitle = "Last post by \(postedBy)"
                // Set Owner Image
                
                if let url = URL(string: last_posted_by["image"] as! String){
                    cell.imgUser.kf.indicatorType = .activity
                    (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                
            }
            
            if let modifiedDate = forum["modified_date"] as? String{
                let postedOn = dateDifference(modifiedDate)
                subTitle = "\n\(subTitle)" + "\n\(postedOn)"
            }

            cell.labMessage.setText(subTitle, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZESmall , nil)
                let range = (subTitle as NSString).range(of: postedBy)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value: textColorDark, range: range)
                
                // TODO: Clean this up..
                return mutableAttributedString
            })
            
            let range = (subTitle as NSString).range(of: NSLocalizedString(postedBy,  comment: ""))
            cell.labMessage.addLink(toTransitInformation: [ "id" : (forum["user_id"] as? Int)!,"type" : "user"], with:range)
            cell.labMessage.delegate = self
            cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labMessage.sizeToFit()
            
        }
        dynamicHeight = cell.labMessage.frame.origin.y + cell.labMessage.bounds.height + 15
        if dynamicHeight < (cell.imgUser.bounds.height + 10 + cell.imgUser.frame.origin.y){

            dynamicHeight = (cell.imgUser.bounds.height + 20 + cell.imgUser.frame.origin.y)
            // forumViewUpdate = true
        }
        
        return cell
    }
    
    // Handle  Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var forumInfo:NSDictionary
        forumInfo = forumsResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        
        if(forumInfo["allow_to_view"] as! Int == 1){
            
            let presentedVC = ForumTopicViewController()
            presentedVC.topicId = forumInfo["topic_id"] as! Int
            if let title = forumInfo["title"] as? String{
                presentedVC.topicName = title
            }else{
                presentedVC.topicName = String(forumInfo["title"] as! Int)
            }

            presentedVC.slug = forumInfo["slug"] as! String
            navigationController?.pushViewController(presentedVC, animated: true)
        }else{
            showAlertMessage(view.center, msg: NSLocalizedString("You do not have permission to view this private page.", comment: ""), timer: true)
        }
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if updateScrollFlag{
//            // Check for Page Number for Browse Forum
//            if forumTableView.contentOffset.y >= forumTableView.contentSize.height - forumTableView.bounds.size.height{
//                if (!isPageRefresing  && limit*pageNumber < totalItems){
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
                        forumTableView.tableFooterView?.isHidden = false
                        // if searchDic.count == 0{
                        browseEntries()
                        // }
                    }
                }
                else
                {
                    forumTableView.tableFooterView?.isHidden = true
                }
                
            }
            
        }
        
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
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
            print("Type Not Match")
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
