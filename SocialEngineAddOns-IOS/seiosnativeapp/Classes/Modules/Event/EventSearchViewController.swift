//
//  BlogSearchViewController.swift
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
import Foundation
import NVActivityIndicatorView

class EventSearchViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate, TTTAttributedLabelDelegate {
    
    var searchBar = UISearchBar()
    var eventTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                          // not show spinner at pull to refresh
    var eventResponse = [AnyObject]()
    var updateScrollFlag = false
    var refresher:UIRefreshControl!                 // Pull to refrresh
    var isPageRefresing = false                     // For Pagination
    var info:UILabel!
    var browseOrMyBlog = true
    var dynamicHeight:CGFloat = 50                  // Dynamic Height fort for Cell
    var search : String!
   // var imageCache = [String:UIImage]()
    var categ_id : Int!
    var leftBarButtonItem : UIBarButtonItem!
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    override func viewDidLoad() {
        
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        super.viewDidLoad()
        
//        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Events",  comment: ""))
//        searchBar.delegate = self

        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search Events",  comment: ""))
        searchBar.delegate = self
        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(EventSearchViewController.filter))
        
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        filter.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = filter
        
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        searchBar.setTextColor(textColorPrime)
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(EventSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        // Set tableview to show events
        eventTableView = UITableView(frame: CGRect(x: 0, y: 0,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        eventTableView.register(EventViewTableViewCell.self, forCellReuseIdentifier: "CellThree")
        eventTableView.rowHeight = 255.0
        eventTableView.dataSource = self
        eventTableView.delegate = self
        eventTableView.isOpaque = false
        // eventTableView.bounces = false
        eventTableView.backgroundColor = tableViewBgColor
        eventTableView.separatorColor = TVSeparatorColorClear
        view.addSubview(eventTableView)
        
        eventTableView.isHidden = true

        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        eventTableView.tableFooterView = footerView
        eventTableView.tableFooterView?.isHidden = true
        
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
            //        searchDic.removeAll(keepingCapacity: false)
            //        searchDic["search"] = searchBar.text
            pageNumber = 1
            showSpinner = true
            self.browseEntries()
        }
        
        
    }
    
    // Update Blog
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
    
    // MARK: - Server Connection For Event Updation
    // Update Events
    func browseEntries(){
        
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            for ob in view.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            //
            if (self.pageNumber == 1){
                self.eventResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true {
                    removeAlert()
                    self.eventTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
              //  spinner.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                   // activityIndicatorView.center = view.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                //activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            
            path = "events"
            parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future"]
            self.title = NSLocalizedString("Events",  comment: "")
            
            
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            //  path = "events/manage"
            
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    //self.tblAutoSearchSuggestions.isHidden = true
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    if msg{
                        
                        //print(succeeded)
                        
                        if self.pageNumber == 1{
                            self.eventResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let blog = response["response"] as? NSArray {
                                    self.eventResponse = self.eventResponse + (blog as [AnyObject])
                                }
                            }
                            
                            if response["getTotalItemCount"] != nil{
                                self.totalItems = response["getTotalItemCount"] as! Int
                            }
                        }
                        
                        
                        self.isPageRefresing = false
                        //                        //Reload Event Tabel
                        self.eventTableView.reloadData()
                        if self.tblAutoSearchSuggestions.isHidden == true
                        {
                           self.eventTableView.isHidden = false
                        }
                        
                        //    if succeeded["message"] != nil{
                        if self.eventResponse.count == 0{
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any event entries. Get started by writing a new entry.",  comment: "") , alignment: .center, textColor: textColorLight)
                            self.info.center = self.view.center
                            self.info.layer.cornerRadius = 25.0
                            self.info.layer.masksToBounds = true
                            self.info.backgroundColor = UIColor.black
                            self.info.tag = 1000
                            self.info.isHidden = true
                            self.view.addSubview(self.info)
                            showToast(message: "You do not have any event entries. Get started by writing a new entry.", controller: self)
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
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            self.searchBar.resignFirstResponder()
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
            return 255.0
        }
    }
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else
        {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return Int(ceil(Float(eventResponse.count)/2))
        }else{
            return eventResponse.count
        }
        }
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        if tableView.tag == 122{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = .none
            cell.backgroundColor = .white
            cell.contentView.backgroundColor = .white
            if let blogInfo = arrRecentSearchOptions[(indexPath as NSIndexPath).row] as String?
            {
                cell.imgSearch.isHidden = false
                cell.labTitle.frame = CGRect(x: cell.imgSearch.bounds.width + 24, y: 0,width: UIScreen.main.bounds.width - (cell.imgSearch.bounds.width + 24), height: 45)
                // cell.labTitle.center.y = cell.bounds.midY + 5
                cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
                cell.labTitle.text = blogInfo
                cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.labTitle.numberOfLines = 2
                //  cell.labTitle.sizeToFit()
            }
            cell.imgUser.isHidden = true
            return cell
        }
        else
        {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath) as! EventViewTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.lineView.isHidden = false
        cell.dateView.frame.size.height = 70
        cell.dateView.backgroundColor = navColor
        cell.titleView.frame.size.height = 70
        cell.titleView.backgroundColor = tableViewBgColor
        cell.backgroundColor = tableViewBgColor
        cell.layer.borderColor = UIColor.white.cgColor
        
        var eventInfo:NSDictionary!
        if(UIDevice.current.userInterfaceIdiom == .pad){
            if(eventResponse.count > ((indexPath as NSIndexPath).row)*2 ){
                eventInfo = eventResponse[((indexPath as NSIndexPath).row)*2] as! NSDictionary
                cell.contentSelection.tag = ((indexPath as NSIndexPath).row)*2
                cell.menu.tag = ((indexPath as NSIndexPath).row)*2
            }
        }else{
            eventInfo = eventResponse[(indexPath as NSIndexPath).row] as! NSDictionary
            cell.contentSelection.tag = (indexPath as NSIndexPath).row
            cell.menuButton.tag = (indexPath as NSIndexPath).row
        }
        
        //Select Event Action
        cell.contentSelection.addTarget(self, action: #selector(EventSearchViewController.showEvent(_:)), for: .touchUpInside)
        // Set MenuAction
        cell.menuButton.addTarget(self, action:Selector(("showEventMenu:")) , for: .touchUpInside)
        
        
        cell.contentImage.frame.size.height = 250
        cell.contentSelection.frame.size.height = 180
        
        // Set Event Image
        
        if let photoId = eventInfo["photo_id"] as? Int{
            
            if photoId != 0{
                
                cell.contentImage.backgroundColor = placeholderColor
                let url1 = URL(string: eventInfo["image"] as! NSString as String)
                cell.contentImage.kf.indicatorType = .activity
                (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.contentImage.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })
         
            }
            else{
                cell.contentImage.image = nil
                cell.contentImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                
            }
        }
        
        let name = eventInfo["title"] as? String
        var tempInfo = ""
        if let eventDate = eventInfo["starttime"] as? String{
            
            let dateMonth = dateDifferenceWithTime(eventDate)
            var dateArrayMonth = dateMonth.components(separatedBy: ", ")
            if dateArrayMonth.count > 1{
                cell.dateLabel1.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                
                cell.dateLabel1.numberOfLines = 0
                cell.dateLabel1.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                cell.dateLabel1.textColor = UIColor.white
                cell.dateLabel1.font = UIFont(name: "FontAwesome", size: 18)
            }
            
            let date = dateDifferenceWithEventTime(eventDate)
            var DateC = date.components(separatedBy: ", ")
            tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
            if DateC.count > 3{
                tempInfo += " at \(DateC[3])"
            }
        }
        
        cell.titleLabel.frame = CGRect(x: 10, y: 5, width: (cell.contentImage.bounds.width-70), height: 30)
        
        cell.titleLabel.text = "\(name!)"
        cell.titleLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        // cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
        cell.titleLabel.sizeToFit()
        
        let location = eventInfo["location"] as? String
        if location != "" && location != nil{
            
            cell.locLabel.isHidden = false
            
            cell.locLabel.frame = CGRect(x: 10, y: 25, width: (cell.contentImage.bounds.width-70), height: 20)
            cell.locLabel.text = "\u{f041}   \(location!)"
            // cell.locLabel.textColor = textColorLight
            cell.locLabel.font = UIFont(name: "FontAwesome", size: 14)
            
            cell.dateLabel.frame = CGRect(x: 10, y: 45, width: (cell.contentImage.bounds.width-70), height: 20)
            cell.dateLabel.text = "\u{f073}  \(tempInfo)"
            cell.dateLabel.textAlignment = NSTextAlignment.left
            // cell.dateLabel.textColor = textColorLight
            cell.dateLabel.font = UIFont(name: "FontAwesome", size: 14)
            
        }
        
        if location == "" || location == nil{
            
            cell.locLabel.isHidden = true
            
            cell.dateLabel.frame = CGRect(x: 10, y: 35, width: (cell.contentImage.bounds.width-70), height: 20)
            cell.dateLabel.text = "\u{f073}  \(tempInfo)"
            cell.dateLabel.textAlignment = NSTextAlignment.left
            //cell.dateLabel.textColor = textColorLight
            cell.dateLabel.font = UIFont(name: "FontAwesome", size: 14)
            
        }
        
        
        // Set Menu
        
        // RHS
        if(UIDevice.current.userInterfaceIdiom == .pad){
            
            cell.dateView2.isHidden = false
            cell.dateView2.frame.size.height = 70
            cell.dateView2.backgroundColor = navColor
            cell.titleView2.frame.size.height = 70
            cell.titleView2.backgroundColor = tableViewBgColor
            var eventInfo2:NSDictionary!
            if(eventResponse.count > (((indexPath as NSIndexPath).row)*2+1) ){
                eventInfo2 = eventResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
                cell.cellView2.isHidden = false
                cell.contentSelection2.isHidden = false
                cell.dateView2.isHidden = false
                cell.titleView2.isHidden = false
                cell.contentSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
                cell.menuButton2.tag = (((indexPath as NSIndexPath).row)*2+1)
            }else{
                cell.cellView2.isHidden = true
                cell.contentSelection2.isHidden = true
                cell.dateView2.isHidden = true
                cell.titleView2.isHidden = true
                return cell
            }
            
            // Select Event Action
            cell.contentSelection2.addTarget(self, action: #selector(EventSearchViewController.showEvent(_:)), for: .touchUpInside)
            // Set MenuAction
            cell.menuButton2.addTarget(self, action:Selector(("showEventMenu:")) , for: .touchUpInside)
            
            
            cell.contentImage2.frame.size.height = 250
            cell.contentSelection2.frame.size.height = 180
            
            
            // Set Event Image
            if let photoId = eventInfo2["photo_id"] as? Int{
                
                if photoId != 0{
                    cell.contentImage2.image = nil
                    let url = URL(string: eventInfo2["image"] as! NSString as String)
                    
                    if url != nil {
                        cell.contentImage2.kf.indicatorType = .activity
                        (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage2.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
 
                    }
                    
                }else{
                    cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                }
            }
            
            
            // Set Event Name
            
            let name = eventInfo2["title"] as? String
            var tempInfo = ""
            if let eventDate = eventInfo2["starttime"] as? String{
                
                let dateMonth = dateDifferenceWithTime(eventDate)
                var dateArrayMonth = dateMonth.components(separatedBy: ", ")
                if dateArrayMonth.count > 1{
                    cell.dateLabel3.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                    
                    cell.dateLabel3.numberOfLines = 0
                    cell.dateLabel3.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                    cell.dateLabel3.textColor = UIColor.white
                    cell.dateLabel3.font = UIFont(name: "FontAwesome", size: 18)
                }
                
                let date = dateDifferenceWithEventTime(eventDate)
                var DateC = date.components(separatedBy: ", ")
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
            }
            else{
                cell.dateView2.isHidden = true
            }
            
            cell.titleLabel2.frame = CGRect(x: 10, y: 5, width: (cell.contentImage2.bounds.width-70), height: 30)
            
            cell.titleLabel2.text = "\(name!)"
            cell.titleLabel2.lineBreakMode = NSLineBreakMode.byWordWrapping
            // cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
            cell.titleLabel2.sizeToFit()
            
            let location = eventInfo2["location"] as? String
            if location != "" && location != nil{
                
                cell.locLabel2.isHidden = false
                
                cell.locLabel2.frame = CGRect(x: 10, y: 25, width: (cell.contentImage2.bounds.width-70), height: 20)
                cell.locLabel2.text = "\u{f041}   \(location!)"
                // cell.locLabel.textColor = textColorLight
                cell.locLabel2.font = UIFont(name: "FontAwesome", size: 14)
                
                cell.dateLabel2.frame = CGRect(x: 10, y: 45, width: (cell.contentImage2.bounds.width-70), height: 20)
                cell.dateLabel2.text = "\u{f073}  \(tempInfo)"
                cell.dateLabel2.textAlignment = NSTextAlignment.left
                // cell.dateLabel.textColor = textColorLight
                cell.dateLabel2.font = UIFont(name: "FontAwesome", size: 14)
                
            }
            
            if location == "" || location == nil{
                
                cell.locLabel2.isHidden = true
                
                cell.dateLabel2.frame = CGRect(x: 10, y: 35, width: (cell.contentImage2.bounds.width-70), height: 20)
                cell.dateLabel2.text = "\u{f073}  \(tempInfo)"
                cell.dateLabel2.textAlignment = NSTextAlignment.left
                //cell.dateLabel.textColor = textColorLight
                cell.dateLabel2.font = UIFont(name: "FontAwesome", size: 14)
                
            }
            
        }
        
        // Set Menu
        
        return cell
        }
    }
    
    
    // Handle Blog Table Cell Selection
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
                self.eventTableView.isHidden = true
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
    
    
    // MARK:  TTTAttributedLabelDelegate
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        //UIApplication.shared.openURL(url!)
        let presentedVC = ExternalWebViewController()
        presentedVC.url = url.absoluteString
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let navigationController = UINavigationController(rootViewController: presentedVC)
        self.present(navigationController, animated: true, completion: nil)

    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        //print(components)
        
        
        let type = components["type"] as! String
        
        switch(type){
        case "category_id":
            blogUpdate = true
            searchDic.removeAll(keepingCapacity: false)
            let id = components["id"] as! Int
            searchDic["category"] = "\(id)"
            //print(searchDic, terminator: "")
            _ = self.navigationController?.popViewController(animated: true)
            
            
        case "less":
            
            print("less")
            
        case "user":
            print("user")
            
            
        default:
            print("default")
        }
        
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if updateScrollFlag{
//            // Check for Page Number for Browse Blog
//            if eventTableView.contentOffset.y >= eventTableView.contentSize.height - eventTableView.bounds.size.height{
//                if (!isPageRefresing  && limit*pageNumber < totalItems){
//                    if Reachabable.isConnectedToNetwork() {
//                        updateScrollFlag = false
//                        pageNumber += 1
//                        isPageRefresing = true
//                        if searchDic.count == 0{
//                            browseEntries()
//                        }
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
        if tblAutoSearchSuggestions.isHidden == true
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
                        eventTableView.tableFooterView?.isHidden = false
                       // if searchDic.count == 0{
                            browseEntries()
                       // }
                    }
                }
                else
                {
                    eventTableView.tableFooterView?.isHidden = true
                }
                
            }
            
        }
        }
    }
    
    @objc func cancel(){
        
        eventUpdate = false
        
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search_text"] = searchBar.text
        if categ_id != nil{
            searchDic["category_id"] = "\(categ_id)"
        }
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
                self.eventTableView.isHidden = true
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
        searchDic["search_text"] = searchBar.text
        if categ_id != nil{
            searchDic["category_id"] = "\(categ_id)"
        }
        pageNumber = 1
        showSpinner = true
      //  searchBar.resignFirstResponder()
        
        browseEntries()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    @objc func showEvent(_ sender:UIButton){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(view)
            return
        }
        var eventInfo:NSDictionary!
        eventInfo = eventResponse[sender.tag] as! NSDictionary
        
        if(eventInfo["allow_to_view"] as! Int == 1){
            if let name = eventInfo["title"] as? String
            {
                updateAutoSearchArray(str: name)
            }
            let presentedVC = ContentFeedViewController()
            presentedVC.subjectId = "\(eventInfo["event_id"]!)"
            presentedVC.subjectType = "event"
            navigationController?.pushViewController(presentedVC, animated: true)
        }else{
            showToast(message: "You do not have permission to view this private page.", controller: self)
        }
    }
    
    @objc func filter(){
        
        if filterSearchFormArray.count > 0{
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "event"
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else
        {
            let presentedVC = FilterSearchViewController()
            
            presentedVC.searchUrl = "events/search-form"
            presentedVC.serachFor = "event"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationImage(controller: self)
        if searchDic.count > 0 {
            if globFilterValue != ""{
                searchBar.text = globFilterValue
              //  searchBar.endEditing(true)
            }
            searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
        eventTableView.tableFooterView?.isHidden = true
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
