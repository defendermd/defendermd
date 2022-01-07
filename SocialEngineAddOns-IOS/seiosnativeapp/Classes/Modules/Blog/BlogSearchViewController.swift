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

var globFilterValue = ""
class BlogSearchViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate {
    
     var searchBar = UISearchBar()
    var blogTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var blogResponse = [AnyObject]()
    var updateScrollFlag = false
    var refresher:UIRefreshControl!             // Pull to refrresh
    var isPageRefresing = false                 // For Pagination
     var info:UILabel!
    var browseOrMyBlog = true
    var dynamicHeight:CGFloat = 75              // Dynamic Height fort for Cell
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
    
        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Blogs",  comment: ""))
        searchBar.setTextColor(textColorPrime)
        searchBar.delegate = self
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(BlogSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(BlogSearchViewController.filter))
        
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        filter.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = filter
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        // Initialize Blog Table
        blogTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        blogTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        blogTableView.dataSource = self
        blogTableView.delegate = self
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
    
    // Check for Blog Update Every Time when View Appears
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
    // Update Blog
    func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            for ob in view.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            if (self.pageNumber == 1){
                self.blogResponse.removeAll(keepingCapacity: false)
                
                if updateAfterAlert == true || searchDic.count > 0 {
                    removeAlert()
                    self.blogTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
             //   spinner.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                  //  activityIndicatorView.center = view.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
               // activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            // Set Parameters for Browse/MyBlog
            path = "blogs/browse"
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)" ]
            
//            parameters["search"] = search
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    //self.tblAutoSearchSuggestions.isHidden = true
                    if self.tblAutoSearchSuggestions.isHidden == true
                    {
                        self.blogTableView.isHidden = false
                    }
                   
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.blogResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let blog = response["response"] as? NSArray {
                                    self.blogResponse = self.blogResponse + (blog as [AnyObject])
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                          
                        }
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        self.isPageRefresing = false
                        //Reload Blog Tabel
                        self.blogTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.blogResponse.count == 0{
                            //self.info.isHidden = false
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any blog entries. Get started by writing a new entry.",  comment: "") , alignment: .center, textColor: textColorLight)
                            self.info.center = self.view.center
                            self.info.layer.cornerRadius = 25.0
                            self.info.layer.masksToBounds = true
                            self.info.backgroundColor = UIColor.black
                            self.info.tag = 1000
                            self.info.isHidden = true
                            self.view.addSubview(self.info)
                            showToast(message: "You do not have any blog entries. Get started by writing a new entry.", controller: self)
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
             searchBar.resignFirstResponder()
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
        return blogResponse.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
        cell.backgroundColor = tableViewBgColor
        
        var blogInfo:NSDictionary
        blogInfo = blogResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        
        cell.imgUser.contentMode = .scaleAspectFill
        cell.imgUser.frame = CGRect(x: 5, y: 7, width: 60, height: 60)
        // Set Blog Title
        cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10,width: (UIScreen.main.bounds.width - 75) , height: 100)
        cell.labTitle.text = blogInfo["title"] as? String
        cell.labTitle.numberOfLines = 2
        cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        cell.labTitle.font = UIFont(name: fontName, size: FONTSIZENormal)
        cell.labTitle.sizeToFit()
        
        if let ownerName = blogInfo["owner_title"] as? String {
            if let postedDate = blogInfo["creation_date"] as? String{
                let postedOn = dateDifference(postedDate)
                cell.labMessage.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5,width: (UIScreen.main.bounds.width - 75) , height: 100)
                var labMsg = ""
                if browseOrMyBlog {
                    labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), ownerName, postedOn)
                }else{
                    labMsg = String(format: NSLocalizedString("%@", comment: ""), postedOn)
                }
                
                cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                    return mutableAttributedString
                })
                
            }
        }
        
        cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.labMessage.sizeToFit()
        cell.labMessage.font = UIFont(name: fontName, size: FONTSIZESmall)
        
        // Set Blog Owner Image
        
        if let url = URL(string: blogInfo["owner_image"] as! String){
            cell.imgUser.kf.indicatorType = .activity
            (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        
        cell.accessoryView = nil
        
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
        var blogInfo:NSDictionary
        blogInfo = blogResponse[(indexPath as NSIndexPath).row] as! NSDictionary
    
        if(blogInfo["allow_to_view"] as! Int == 1){
            
            if let str = blogInfo["title"] as? String
            {
                updateAutoSearchArray(str: str)
            }
            
            let presentedVC = BlogDetailViewController()
            
            if (blogInfo["blog_id"] is String){
                let tempValue = blogInfo["blog_id"] as! String
                presentedVC.blogId = Int(tempValue)
            }else{
              presentedVC.blogId = blogInfo["blog_id"] as! Int
            }
            presentedVC.blogName = blogInfo["title"] as! String
            //  presentedVC.url = blogInfo["url"] as! String
            navigationController?.pushViewController(presentedVC, animated: false)
        }else{
            showToast(message: "You do not have permission to view this private page.", controller: self)
        }
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
                // Check for Page Number for Browse Blog
//                if blogTableView.contentOffset.y >= blogTableView.contentSize.height - blogTableView.bounds.size.height{
                    if (limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            blogTableView.tableFooterView?.isHidden = false
                            browseEntries()
                         
                         }
                        }
                    else
                    {
                        blogTableView.tableFooterView?.isHidden = true
                }
                   // }
                    
               // }
                
            }
            
        }
        }
    }
    
    
    
    @objc func cancel(){
        blogUpdate = false
        
        _ = self.navigationController?.popViewController(animated: false)
        
    }
    
    
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
        if categ_id != nil{
            searchDic["category"] = "\(categ_id)"
        }
        filterSearchString = searchBar.text!
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
        if categ_id != nil{
            searchDic["category"] = "\(categ_id)"
        }
        filterSearchString = searchBar.text!
        pageNumber = 1
        showSpinner = true
   //     searchBar.resignFirstResponder()
        
        browseEntries()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    @objc func filter(){
        if filterSearchFormArray.count > 0 {
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "blog"
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "blogs/search-form"
            presentedVC.serachFor = "blog"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
        override func viewWillDisappear(_ animated: Bool) {
            searchBar.resignFirstResponder()
            blogTableView.tableFooterView?.isHidden = true
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
