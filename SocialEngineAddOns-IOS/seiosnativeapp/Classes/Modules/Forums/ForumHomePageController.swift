//
//  ForumHomePageController.swift
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
var forumUpdate:Bool!
var forumSearchCheck = ""
import Instructions
class ForumHomePageController: UIViewController,UITableViewDataSource, UITableViewDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate{
    let mainView = UIView()
    var showSpinner = true                      // not show spinner at pull to refresh
    var forumsResponse = [AnyObject]()            // For response come from Server
    var isPageRefresing = false                 // For Pagination
    var forumTableView:UITableView!              // TAbleView to show the forum Contents
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var updateScrollFlag = true                 // Paginatjion Flag
    var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
   // var imageCache = [String:UIImage]()
    var leftBarButtonItem : UIBarButtonItem!
    
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        openMenu = false
        forumUpdate = true
        globFilterValue = ""
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        let subViews = mainView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        self.title = NSLocalizedString("Forums",  comment: "")
        baseController?.tabBar.items?[self.tabBarController!.selectedIndex].title = nil
        self.navigationItem.setHidesBackButton(true, animated: false)

       
        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(ForumHomePageController.searchItem))
        self.navigationItem.rightBarButtonItem = searchItem
        searchItem.tintColor = textColorPrime
        
        // Initialize Forum Table
        forumTableView = UITableView(frame: CGRect(x: 0, y: 0 , width: view.bounds.width, height: view.bounds.height - tabBarHeight ), style: .grouped)
        forumTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        forumTableView.dataSource = self
        forumTableView.delegate = self
        forumTableView.estimatedRowHeight = 70  //50.0
        forumTableView.rowHeight = UITableView.automaticDimension
        forumTableView.backgroundColor = tableViewBgColor
        forumTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            forumTableView.estimatedSectionHeaderHeight = 0
        }
        mainView.addSubview(forumTableView)
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(ForumHomePageController.refresh), for: UIControl.Event.valueChanged)
        forumTableView.addSubview(refresher)
    
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        forumTableView.tableFooterView = footerView
        forumTableView.tableFooterView?.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        removeNavigationViews(controller: self)
    }
    
    // Check for Forum Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        if (forumUpdate == true){
            forumUpdate = false
            showSpinner = true
            pageNumber = 1
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
            self.showAlertMessage(mainView.center , msg: network_status_msg , timer: false)
        }
    }
  
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
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
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 1/1", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
            
            
            
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
        if let name = defaults.object(forKey: "showSearchPluginAppTour")
        {
            if  UserDefaults.standard.object(forKey: "showSearchPluginAppTour") != nil {
                
                self.targetCheckValue = name as! Int
                
                
            }
            
        }
        
        if self.targetCheckValue == 1 {
            
            UserDefaults.standard.set(2, forKey: "showSearchPluginAppTour")
            self.coachMarksController.dataSource = self
            self.coachMarksController.delegate = self
            self.coachMarksController.overlay.allowTap = true
            self.coachMarksController.overlay.fadeAnimationDuration = 0.5
            self.coachMarksController.start(on: self)
        }
    }
    
    
    
    // MARK: - Server Connection For Forum Updation
    // Update Forum
    func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            self.showAppTour()
            if (self.pageNumber == 1){
                self.forumsResponse.removeAll(keepingCapacity: false)
                self.forumTableView.reloadData()
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
            //    activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            let parameters = ["page":"\(pageNumber)", "limit" :"\(limit)"]
            // Send Server Request to Browse Forum Entries
            post(parameters, url: "forums", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.forumTableView.tableFooterView?.isHidden = true
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    if msg{
                        
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.mainView.center , msg: succeeded["message"] as! String, timer: true)
                        }
                        if let response = succeeded["body"] as? NSArray{
                          
                            self.forumsResponse = self.forumsResponse + (response as [AnyObject])
                            self.isPageRefresing = false
                            self.forumTableView.reloadData()
                        }
                        
                    }else{
                        
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            self.showAlertMessage(self.mainView.center , msg: succeeded["message"] as! String, timer: false)
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            self.showAlertMessage(mainView.center , msg: network_status_msg , timer: false)
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
        return 30.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set  Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return forumsResponse.count
    }
    
    // Set Title of Header in Section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let forum = forumsResponse[section] as! NSDictionary
        return forum["title"] as? String
    }
    
    // Set no. of rows in Every section of TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        var count : Int!
        if let forumCategory = forumsResponse[section] as? NSDictionary{
            if let forums = forumCategory["forums"] as? NSArray {
                count = forums.count
            }
        }
        return count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        // dequeue a cell for the given indexPath
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        // set the cell's text with the new string formatting
        if let forumCategory = forumsResponse[(indexPath as NSIndexPath).section] as? NSDictionary{
            if let forums = forumCategory["forums"] as? NSArray {
                if let forum = forums[(indexPath as NSIndexPath).row] as? NSDictionary{
                    cell.labTitle.text = forum["title"] as? String
                    cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
                    cell.labTitle.sizeToFit()
                    cell.labTitle.frame.size.width = (UIScreen.main.bounds.width - 75)
                    cell.labMessage.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5,width: (UIScreen.main.bounds.width - 75) , height: 100)
                    cell.labMessage.font = UIFont(name: fontName, size:FONTSIZESmall)
                    var subTitle = ""
                    if let post = forum["post_count"] as? Int{
                    subTitle = singlePluralCheck(NSLocalizedString(" post - ", comment: ""), plural: NSLocalizedString(" posts - ", comment: ""), count: post)
                    }
                    
                    if let topic = forum["topic_count"] as? Int{
                    subTitle += singlePluralCheck(NSLocalizedString(" topic", comment: ""), plural: NSLocalizedString(" topics", comment: ""), count: topic)
                    }
                    cell.labMessage.text = subTitle
                    cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.labMessage.sizeToFit()
                    cell.labMessage.frame.size.width = (UIScreen.main.bounds.width - 75)
                    // let url = NSURL(string: forum["image"] as! NSString as String)
                    if  (UIDevice.current.userInterfaceIdiom == .phone){
                        cell.imgUser.frame =  CGRect(x: 5, y: 5, width: 50, height: 50)
                        cell.imgUser.layer.cornerRadius = 0.0
                        cell.imgUser.clipsToBounds = false
                        cell.imgUser.layer.borderWidth =  0.0
                        cell.imgUser.layer.masksToBounds = false
                        cell.imgUser.layer.cornerRadius = 0.0
                        
                    }else{
                        cell.imgUser.frame =  CGRect(x: 5, y: 5, width: 60, height: 60)
                        cell.imgUser.layer.cornerRadius = 0.0
                        cell.imgUser.clipsToBounds = false
                        cell.imgUser.layer.borderWidth =  0.0
                        cell.imgUser.layer.masksToBounds = false
                        cell.imgUser.layer.cornerRadius = 0.0
                    }
                    
                    if let url = URL(string: forum["image"] as! String){

                        cell.imgUser.kf.indicatorType = .activity
                        (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            if let imgT = image
                            {
                                cell.imgUser.image = CustomSquareImage(imgT, size: CGSize(width: cell.imgUser.frame.width, height: cell.imgUser.frame.height))
                            }
                        })
                    }
                    
                }
            }
        }
        dynamicHeight = cell.labMessage.frame.origin.y + cell.labMessage.bounds.height + 5
        if dynamicHeight < (cell.imgUser.bounds.height + 10){
            dynamicHeight = (cell.imgUser.bounds.height + 10)
        }
        
        return cell
    }
    
    // Handle Forum Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let forumCategory = forumsResponse[(indexPath as NSIndexPath).section] as? NSDictionary{
            if let forums = forumCategory["forums"] as? NSArray {
                if let forum = forums[(indexPath as NSIndexPath).row] as? NSDictionary{
                    if(forum["allow_to_view"] as! Int == 1){
                        let presentedVC = ForumsViewPageController()
                        presentedVC.forumId = "\(forum["forum_id"]!)"
                        presentedVC.forumName = forum["title"] as! String
                        presentedVC.forumSlug = forum["slug"] as! String
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }else{
                        showAlertMessage(mainView.center, msg: NSLocalizedString("You do not have permission to view this private page.", comment: ""), timer: true)
                    }
                }
            }
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
//
//                    }
//                }
//            }
//        }
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
    
    @objc func searchItem(){
        forumSearchCheck = "ForumSearch"
        DispatchQueue.main.async {
            let presentedVC = CoreAdvancedSearchViewController()
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }       
        conditionalForm = "ForumSearch"
       
        let url : String = "search"
        loadFilter(url)
    }
    override func viewWillDisappear(_ animated: Bool) {
         forumTableView.tableFooterView?.isHidden = true
        globFilterValue = ""
        textstoreValue = ""
        conditionForm = ""
        UserDefaults.standard.removeObject(forKey: "forumcheckkey")
        UserDefaults.standard.removeObject(forKey: "preferenceName")
        filterSearchFormArray.removeAll(keepingCapacity: false)
    }
    func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
        
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
