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
//  BlogSearchViewController.swift
//  seiosnativeapp
//

import UIKit
import Foundation
import NVActivityIndicatorView

class ShowMemberSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, TTTAttributedLabelDelegate{
    
    var searchBar = UISearchBar()
    var blogTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                          // not show spinner at pull to refresh
    var allMembers = [AnyObject]()
    var updateScrollFlag = false
    var refresher:UIRefreshControl!                 // Pull to refrresh
    var isPageRefresing = false                     // For Pagination
    var info:UILabel!
    var browseOrMyBlog = true
    var dynamicHeight:CGFloat = 75                  // Dynamic Height fort for Cell
    var search : String!
  //  var imageCache = [String:UIImage]()
    var categ_id : Int!
    var url = ""
    var memberInfo:NSDictionary!
    var contentType = ""
    var param: NSDictionary = [ : ]
    var leftBarButtonItem : UIBarButtonItem!
    var resourceId : Int = 0
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    override func viewDidLoad() {
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        super.viewDidLoad()
        if (self.contentType == "group") || (self.contentType == "sitegroup"){
            
            searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Members",  comment: ""))
        }
          else if (self.contentType == "userFollow"){
            searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Followers",  comment: ""))
        }
        else{
            
            searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Guests",  comment: ""))
        }
        
        // searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search \(contentType)",  comment: ""))
        searchBar.delegate = self
        searchBar.setTextColor(textColorPrime)
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ShowMemberSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        // Initialize Blog Table
        blogTableView = UITableView(frame: CGRect(x: 0, y: 0,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        blogTableView.register(CommentTableViewCell.self, forCellReuseIdentifier: "Cell")
        blogTableView.dataSource = self
        blogTableView.delegate = self
        blogTableView.estimatedRowHeight = 75.0
        blogTableView.rowHeight = UITableView.automaticDimension
        blogTableView.backgroundColor = tableViewBgColor
        blogTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            blogTableView.estimatedRowHeight = 0
            blogTableView.estimatedSectionHeaderHeight = 0
            blogTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(blogTableView)
        blogTableView.isHidden = true
        
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        blogTableView.tableFooterView = footerView
        blogTableView.tableFooterView?.isHidden = true
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
    
    // Check for Blog Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        if searchDic.count > 0 {
            if globFilterValue != ""{
                searchBar.text = globFilterValue
            }
            searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
            showSpinner = true
            pageNumber = 1
            showMembers(url, parameter: param as NSDictionary)
        }
    }

    func showMembers(_ url:String, parameter: NSDictionary){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            
            for ob in view.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            if (self.pageNumber == 1){
                self.allMembers.removeAll(keepingCapacity: false)
                
                if searchDic.count > 0 {
                   
                    self.blogTableView.reloadData()
                }
            }
            
            removeAlert()
            // Set Spinner
//            spinner.center = self.view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            self.view.addSubview(spinner)
            if showSpinner
            {
            self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
           // activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            }
            
            
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            dic["limit"] = "\(limit)"
            dic["page"] = "\(pageNumber)"
            dic["menu"] = "1"
            
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                dic.merge(searchDic)
            }
            if (self.contentType == "userFollow"){
                dic["resource_type"] = "user"
                dic["resource_id"] = "\(resourceId)"
            }

            
            // Send Server Request to Share Content
            post(dic, url: url, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    //self.tblAutoSearchSuggestions.isHidden = true
                    self.blogTableView.tableFooterView?.isHidden = true
                    if self.tblAutoSearchSuggestions.isHidden == true
                    {
                        self.blogTableView.isHidden = false
                    }
                    
                    self.showSpinner = false
                    if msg{
                        
                        
                        if self.pageNumber == 1{
                            self.allMembers.removeAll(keepingCapacity: false)
                        }
                        
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            
                            
                            if let body = succeeded["body"] as? NSDictionary{
                                
                                if let members = body["members"] as? NSArray{
                                    self.allMembers = self.allMembers + (members as [AnyObject])
                                }
                                if let members = body["response"] as? NSArray{
                                    self.allMembers = self.allMembers + (members as [AnyObject])
                                }
                                if body["getTotalItemCount"] != nil{
                                    self.totalItems = body["getTotalItemCount"] as! Int
                                }
                                
                                //self.totalItem = body["getTotalItemCount"] as! Int
                                
                                for ob in self.view.subviews{
                                    if (ob.tag == 11) || (ob.tag == 22) {
                                        ob.removeFromSuperview()
                                    }
                                }
                                
                                // Reload Table on Getting Data from Server
                                self.isPageRefresing = false
                                self.blogTableView.reloadData()
                                
                                if self.allMembers.count == 0{
                                    showToast(message: "No members found.", controller: self)
                                    self.searchBar.resignFirstResponder()
                                }
                                
                            }
                        }
                        
                    }else{
                        // Handle Server Side Error
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
    
    // Set Blog Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Blog Tabel Header Height
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
    
    // Set Blog Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else
        {
        return allMembers.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        //print(cell)
        
        
        memberInfo = allMembers[(indexPath as NSIndexPath).row] as! NSDictionary
        cell.author_photo.frame = CGRect(x: 5,y: 5,width: 60,height: 60)
        
        // Set Name People who Likes Content
        if (self.contentType == "group") || (self.contentType == "sitegroup") || (self.contentType == "userFollow"){
            cell.author_title.frame = CGRect(x: cell.author_photo.bounds.width+10, y: 25, width: self.view.bounds.width-(cell.author_photo.bounds.width+15), height: 100)
        }
        else{
            cell.author_title.frame = CGRect(x: cell.author_photo.bounds.width+10, y: 9, width: self.view.bounds.width-(cell.author_photo.bounds.width+15), height: 100)
        }
        cell.author_title.delegate = self
        cell.author_title.text = memberInfo["displayname"] as? String
        cell.author_title.sizeToFit()
        cell.author_title.font = UIFont(name: fontName, size: FONTSIZELarge)
        let userId = memberInfo["user_id"] as! Int
            if let strLength = cell.author_title.text
        {
            let length:Int =  (strLength as AnyObject).length
            
            cell.author_title.addLink(toTransitInformation: [ "type" : "user", "user_id" : userId  ], with:NSMakeRange(0,length));
        }

        cell.author_title.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.author_title.sizeToFit()
        cell.imageButton.addTarget(self, action: #selector(ShowMemberSearchViewController.showProfile(_:)), for: UIControl.Event.touchUpInside)
        cell.imageButton.tag = userId
        cell.imageButton.accessibilityIdentifier = "\((indexPath as NSIndexPath).row)"
        
        cell.staff.isHidden = true
        if contentType == "group"{
            if let staff = memberInfo["staff"] as? String{
                
                if staff != "" {
                    
                    cell.staff.setTitle("(\(staff))", for: UIControl.State())
                    
                    cell.staff.tag = (memberInfo["user_id"] as? Int)!
                    
                    cell.staff.isHidden = false
                    
                    cell.staff.frame.origin.x = cell.author_title.frame.size.width + cell.author_title.frame.origin.x + 10
                    cell.staff.frame.origin.y = cell.author_title.frame.origin.y - 4
                    cell.staff.frame.size.width = (findWidthByText("(\(staff))")+22)
                    cell.staff.setTitleColor(textColorMedium, for: UIControl.State())

                    
                }
                
            }
        }
        
        
        cell.status.isHidden = true
        
        // In Case of Event Check for RSVP
        cell.comment_date.isHidden = true
        if contentType == "event"{
            
            if let rsvp = memberInfo["rsvp"] as? Int{
                switch(rsvp){
                case 0:
                    cell.comment_date.text = NSLocalizedString("Not Attending", comment: "")
                case 1:
                    cell.comment_date.text = NSLocalizedString("May be Attending", comment: "")
                case 2:
                    cell.comment_date.text = NSLocalizedString("Attending", comment: "")
                case 3:
                    cell.comment_date.text = NSLocalizedString("Awaiting Reply", comment: "")
                default:
                    print("error")
                }
                cell.comment_date.frame.origin.x = cell.author_title.frame.origin.x
                cell.comment_date.frame.size.width = 110
                cell.comment_date.frame.origin.y = cell.status.frame.origin.y + cell.status.bounds.height + 2
                cell.comment_date.isHidden = false
                cell.comment_date.textColor = textColorMedium
            }
        }
        
        if contentType == "advancedevents"{
            
            
            
            if let rsvp = memberInfo["rsvp"] as? Int{
                switch(rsvp){
                case 0:
                    cell.comment_date.text = NSLocalizedString("Not Attending", comment: "")
                case 1:
                    cell.comment_date.text = NSLocalizedString("May be Attending", comment: "")
                case 2:
                    cell.comment_date.text = NSLocalizedString("Attending", comment: "")
                case 3:
                    cell.comment_date.text = NSLocalizedString("Awaiting Reply", comment: "")
                default:
                    print("error")
                }
                cell.comment_date.frame.origin.x = cell.author_title.frame.origin.x
                cell.comment_date.frame.size.width = 110
                cell.comment_date.frame.origin.y = cell.status.frame.origin.y + cell.status.bounds.height + 2
                cell.comment_date.isHidden = false
                cell.comment_date.textColor = textColorMedium
            }
        }
        cell.option1.isHidden = true
        cell.option2.isHidden = true
        // Set Owner Image
        let url = URL(string: memberInfo["image"] as! String)
        if url != nil
        {
            cell.author_photo.kf.indicatorType = .activity
            (cell.author_photo.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.author_photo.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
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
                self.blogTableView.isHidden = true
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
        memberInfo = allMembers[(indexPath as NSIndexPath).row] as! NSDictionary
        if let str = memberInfo["displayname"] as? String
        {
            updateAutoSearchArray(str: str)
        }
        let user_id = memberInfo["user_id"] as? Int        
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(user_id!)"
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    // Handle Blog Table Cell Selection
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if updateScrollFlag{
//            // Check for Page Number for Browse Blog
//            if blogTableView.contentOffset.y >= blogTableView.contentSize.height - blogTableView.bounds.size.height{
//                if (limit*pageNumber < totalItems){
//                    if Reachabable.isConnectedToNetwork() {
//                        updateScrollFlag = false
//                        pageNumber += 1
//                        isPageRefresing = true
//                        showMembers(url, parameter: param as NSDictionary)
//
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
                if (limit*pageNumber < totalItems){
                    if Reachabable.isConnectedToNetwork() {
                        updateScrollFlag = false
                        pageNumber += 1
                        blogTableView.tableFooterView?.isHidden = false
                        isPageRefresing = true
                        showMembers(url, parameter: param as NSDictionary)
                        
                    }
                }
                else
                {
                    blogTableView.tableFooterView?.isHidden = true
                }
                
            }
            
        }
        }
    }
    
    
    @objc func cancel(){
        _ = self.navigationController?.popViewController(animated: false)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Add search text to searchDic
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
        pageNumber = 1
        showSpinner = true
        searchBar.resignFirstResponder()
        // Update Blog for Search Text
        if url != "" {
            showMembers(url, parameter: param as NSDictionary)
        }
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
                self.blogTableView.isHidden = true
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
        pageNumber = 1
        showSpinner = true
      //  searchBar.resignFirstResponder()
        // Update Blog for Search Text
        if url != "" {
            showMembers(url, parameter: param as NSDictionary)
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    @objc func showProfile(_ sender: UIButton){
        
        if let strIndex = sender.accessibilityIdentifier, let index = Int(strIndex), let photoInfo = allMembers[index] as? NSDictionary {
            if let str = photoInfo["displayname"] as? String
            {
                updateAutoSearchArray(str: str)
            }
        }
     
        let presentedVC = ContentActivityFeedViewController()
        presentedVC.subjectType = "user"
        presentedVC.subjectId = "\(sender.tag)"
        presentedVC.fromActivity = false
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
        searchDic.removeAll(keepingCapacity: false)
        blogTableView.tableFooterView?.isHidden = true
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
}
