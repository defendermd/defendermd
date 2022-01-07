//
//  PlaylistSearchViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 26/06/17.
//  Copyright © 2017 bigstep. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class PlaylistSearchViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate {
    
    var searchBar = UISearchBar()
    var searchPath = ""
    var classifiedTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var playlistResponse = [AnyObject]()
    var updateScrollFlag = false
    var refresher:UIRefreshControl!             // Pull to refrresh
    var isPageRefresing = false                 // For Pagination
    var info:UILabel!
    var browseOrMyBlog = true
    var dynamicHeight:CGFloat = 160              // Dynamic Height fort for Cell
    var search : String!
    var contentIcon : UILabel!
    var refreshButton : UIButton!
//    var imageCache = [String:UIImage]()
//    var imageCache1 = [String:UIImage]()
    var categ_id : Int!
    var leftBarButtonItem : UIBarButtonItem!
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    
    override func viewDidLoad() {
        
        
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        super.viewDidLoad()
        
//        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Playlists",  comment: ""))
//        searchBar.delegate = self
//        searchBar.setTextColor(textColorPrime)
//        searchBar.backgroundColor = textColorclear


        _ = SearchBarContainerView(self, customSearchBar:searchBar)

        searchBar.setPlaceholderWithColor(NSLocalizedString("Search Playlists",  comment: ""))
        searchBar.delegate = self
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(PlaylistSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(PlaylistSearchViewController.filter))
        
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        filter.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = filter
        
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        view.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        view.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        
        
        // Initialize Blog Table
        classifiedTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        classifiedTableView.register(ClassifiedTableViewCell.self, forCellReuseIdentifier: "Cell")
        classifiedTableView.dataSource = self
        classifiedTableView.delegate = self
        classifiedTableView.estimatedRowHeight = 160.0
        classifiedTableView.rowHeight = UITableView.automaticDimension
        classifiedTableView.backgroundColor = UIColor.clear
        classifiedTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            classifiedTableView.estimatedRowHeight = 0
            classifiedTableView.estimatedSectionHeaderHeight = 0
            classifiedTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(classifiedTableView)
        
        classifiedTableView.isHidden = true
     

        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        classifiedTableView.tableFooterView = footerView
        classifiedTableView.tableFooterView?.isHidden = true
        
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
            showSpinner = true
            pageNumber = 1
            self.browseEntries()
        }
    }
    // Update Classified
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            for ob in view.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            if (self.pageNumber == 1){
                self.playlistResponse.removeAll(keepingCapacity: false)
                
                if updateAfterAlert == true {
                    removeAlert()
                    self.classifiedTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            contentIcon.isHidden = true
            refreshButton.isHidden = true
            if (showSpinner){
             //   spinner.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                  //  activityIndicatorView.center = view.center
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
             //   activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var parameters = [String:String]()
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Classified Entries
            post(parameters, url: searchPath, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    //self.tblAutoSearchSuggestions.isHidden = true
                    if self.tblAutoSearchSuggestions.isHidden == true
                    {
                        self.classifiedTableView.isHidden = false
                    }                   
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.playlistResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let Classified = response["response"] as? NSArray {
                                    self.playlistResponse = self.playlistResponse + (Classified as [AnyObject])
                                    
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                        }
                        //  dispatch_async(dispatch_get_main_queue(),{
                        
                        self.isPageRefresing = false
                        //Reload Classified Tabel
                        self.classifiedTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.playlistResponse.count == 0{
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(classifiedIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.view.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any Playlists.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.sizeToFit()
                            self.info.numberOfLines = 0
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.view.addSubview(self.info)
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(PlaylistSearchViewController.browseEntries), for: UIControl.Event.touchUpInside)
                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.view.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            
                        }

                    }else{
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
    // MARK:  UITableViewDelegate & UITableViewDataSource

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Classified Tabel Header Height
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
    // Set Classified Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else{
        return Int(ceil(Float(playlistResponse.count)/2))
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
        else{
        
        let row = (indexPath as NSIndexPath).row as Int
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ClassifiedTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.lblvideocount.isHidden = false
        var index:Int!
        index = row * 2
        
        
        if playlistResponse.count > index
        {
            cell.contentSelection.isHidden = false
            cell.classifiedImageView.isHidden = false
            cell.classifiedName.isHidden = false
            cell.classifiedImageView.image = nil
            
            if let playlistInfo = playlistResponse[index] as? NSDictionary {
                // LHS
                if let url = URL(string: playlistInfo["image"] as! NSString as String){
                    cell.classifiedImageView.kf.indicatorType = .activity
                    (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.classifiedImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
                let name = playlistInfo["title"] as? String
                
                let tempString = name! as NSString
                
                var value : String
                
                if tempString.length > 22{
                    
                    value = tempString.substring(to: 19)
                    value += NSLocalizedString("...",  comment: "")
                }else{
                    value = "\(tempString)"
                    
                }
                cell.classifiedName.frame = CGRect(x:cell.classifiedName.frame.origin.x, y:125, width :cell.classifiedName.frame.size.width, height:20)
                cell.classifiedName.font = UIFont(name: fontName, size: FONTSIZENormal)
                cell.classifiedName.text = value
                
                
                if let videocount = playlistInfo["video_count"] as? Int
                {
                    if videocount != 1
                    {
                        cell.lblvideocount.text = "\(videocount) Videos"
                    }
                    else
                    {
                        cell.lblvideocount.text = "\(videocount) Video"
                        
                    }
                    
                }
                cell.contentSelection.accessibilityIdentifier = "\(index!)"
                cell.contentSelection.tag = playlistInfo["playlist_id"] as! Int
                if playlistInfo["allow_to_view"] != nil  { //&& playlistInfo["allow_to_view"] as! Int > 0
                    cell.contentSelection.addTarget(self, action: #selector(PlaylistSearchViewController.showClassified(_:)), for: .touchUpInside)
                }else{
                    cell.contentSelection.addTarget(self, action: #selector(PlaylistSearchViewController.noRedirection(_:)), for: .touchUpInside)
                }
                
                
                
                cell.menu.isHidden = true
                cell.menu1.isHidden = true
                
                
            }
            
        }
        else
        {
            cell.contentSelection.isHidden = true
            cell.classifiedImageView.isHidden = true
            cell.classifiedName.isHidden = true
            cell.contentSelection1.isHidden = true
            cell.classifiedImageView1.isHidden = true
            cell.classifiedName1.isHidden = true
            cell.lblvideocount1.isHidden = true
        }
        if playlistResponse.count > (index + 1){
            cell.contentSelection1.isHidden = false
            cell.classifiedImageView1.isHidden = false
            cell.classifiedName1.isHidden = false
            cell.lblvideocount1.isHidden = false
            cell.classifiedImageView1.image = nil
            
            if let playlistInfo = playlistResponse[index + 1] as? NSDictionary {
                
                if let url = URL(string: playlistInfo["image"] as! NSString as String){
                    cell.classifiedImageView1.kf.indicatorType = .activity
                    (cell.classifiedImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.classifiedImageView1.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
                
                
                let name1 = playlistInfo["title"] as? String
                
                let tempString1 = name1! as NSString
                
                var value1 : String
                
                if tempString1.length > 22{
                    
                    value1 = tempString1.substring(to: 19)
                    value1 += NSLocalizedString("...",  comment: "")
                }else{
                    value1 = "\(tempString1)"
                }
                
                cell.classifiedName1.text = value1
                cell.classifiedName1.frame = CGRect(x:cell.classifiedName1.frame.origin.x, y:125, width :cell.classifiedName1.frame.size.width, height:20)
                
                if let videocount = playlistInfo["video_count"] as? Int
                {
                    if videocount != 1
                    {
                        cell.lblvideocount1.text = "\(videocount) Videos"
                    }
                    else
                    {
                        cell.lblvideocount1.text = "\(videocount) Video"
                        
                    }
                    
                    
                }
                
                cell.contentSelection1.accessibilityIdentifier = "\(index! + 1)"
                cell.contentSelection1.tag = playlistInfo["playlist_id"] as! Int
                if playlistInfo["allow_to_view"] != nil  { //&& playlistInfo["allow_to_view"] as! Int > 0
                    cell.contentSelection1.addTarget(self, action: #selector(PlaylistSearchViewController.showClassified(_:)), for: .touchUpInside)
                }else{
                    cell.contentSelection1.addTarget(self, action: #selector(PlaylistSearchViewController.noRedirection(_:)), for: .touchUpInside)
                    
                }
                
                
                
                cell.menu.isHidden = true
                cell.menu1.isHidden = true
                
                
            }
            
        }
        else
        {
            cell.contentSelection1.isHidden = true
            cell.classifiedImageView1.isHidden = true
            cell.classifiedName1.isHidden = true
        }
        return cell
        }
        
    }
    @objc func noRedirection(_ sender: UIButton){
        showToast(message: "User not allowed to view this page", controller: self)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
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
                self.classifiedTableView.isHidden = true
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
                // Check for Page Number for Browse Classified
//                if classifiedTableView.contentOffset.y >= classifiedTableView.contentSize.height - classifiedTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            classifiedTableView.tableFooterView?.isHidden = false
                         //   if searchDic.count == 0{
                                browseEntries()
                           // }
                        }
                    }
                    else
                    {
                        classifiedTableView.tableFooterView?.isHidden = true
                }
                    
             //   }
                
            }
            
        }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showClassified(_ sender: UIButton){
        if let strIndex = sender.accessibilityIdentifier, let index = Int(strIndex), let photoInfo = playlistResponse[index] as? NSDictionary {
            if let str = photoInfo["title"] as? String
            {
                updateAutoSearchArray(str: str)
            }
        }
        let presentedVC = PlaylistProfileViewController()
        presentedVC.playlistId = "\(sender.tag)"
        navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    @objc func cancel(){
        classifiedUpdate = false
        
        _ = self.navigationController?.popViewController(animated: false)
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
        if categ_id != nil{
            searchDic["category"] = "\(categ_id)"
        }
        showSpinner = true
        pageNumber = 1
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
                self.classifiedTableView.isHidden = true
                // self.converstationTableView.isHidden = true
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
        showSpinner = true
        pageNumber = 1
      //  searchBar.resignFirstResponder()
        browseEntries()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    @objc func filter(){
        if filterSearchFormArray.count > 0{
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.stringFilter = searchBar.text!
            
            // presentedVC.searchUrl = "classifieds/browse-search-form"
            presentedVC.serachFor = "classified"
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            
            presentedVC.searchUrl = "classifieds/search-form"
            presentedVC.serachFor = "classified"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationImage(controller: self)
        if searchDic.count > 0 {
            if globFilterValue != ""{
                searchBar.text = globFilterValue
               // searchBar.endEditing(true)
            }
            searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
        classifiedTableView.tableFooterView?.isHidden = true
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
