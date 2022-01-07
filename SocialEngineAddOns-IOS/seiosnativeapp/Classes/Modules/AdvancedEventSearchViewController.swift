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

//  AdvancedEventSearchViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 18/01/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {

    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }

}


class AdvancedEventSearchViewController: UIViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource, TTTAttributedLabelDelegate
{
    
    var searchBar = UISearchBar()
    var advancedeventTableView:UITableView!
    var pageNumber:Int = 1
    var advancedeventResponse = [AnyObject]()
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var updateScrollFlag = false
    var refresher:UIRefreshControl!             // Pull to refrresh
    var isPageRefresing = false                 // For Pagination
    var info:UILabel!
    var browseOrMyBlog = true
    var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
    var search : String!
    var eventBrowseType:Int!
    var DiaryTableView:UITableView!
   // var imageCache = [String:UIImage]()
    var imageArr:[UIImage]=[]
    var issearch : String = ""
    var leftBarButtonItem : UIBarButtonItem!
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    var comingFrom = ""
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        super.viewDidLoad()
        
        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.delegate = self
        if eventBrowseType == 10
        {

            searchBar.setPlaceholderWithColor(NSLocalizedString("Search Diaries",  comment: ""))
        }
        else
        {

            searchBar.setPlaceholderWithColor(NSLocalizedString("Search Events",  comment: ""))
        }

        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(AdvancedEventSearchViewController.filter))
        
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        filter.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = filter
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))

        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AdvancedEventSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        
        
        let backIconImageView = createImageView(CGRect(x: 0,y: 12,width: 22,height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        // Set tableview to show events
        advancedeventTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        advancedeventTableView.register(EventViewTableViewCell.self, forCellReuseIdentifier: "CellThree")
        advancedeventTableView.rowHeight = 255.0
        advancedeventTableView.dataSource = self
        advancedeventTableView.delegate = self
        advancedeventTableView.isOpaque = false
        advancedeventTableView.backgroundColor = tableViewBgColor
        advancedeventTableView.separatorColor = TVSeparatorColorClear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            advancedeventTableView.estimatedRowHeight = 0
            advancedeventTableView.estimatedSectionHeaderHeight = 0
            advancedeventTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(advancedeventTableView)
        advancedeventTableView.isHidden = true
        
        
        // Set tableview to show Diaries
        DiaryTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        DiaryTableView.register(DiaryTableViewCell.self, forCellReuseIdentifier: "Cell")
        DiaryTableView.rowHeight = 250
        DiaryTableView.dataSource = self
        DiaryTableView.delegate = self
        DiaryTableView.isOpaque = false
        DiaryTableView.isHidden = true
        DiaryTableView.backgroundColor = tableViewBgColor
        DiaryTableView.showsVerticalScrollIndicator = false
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            DiaryTableView.estimatedRowHeight = 0
            DiaryTableView.estimatedSectionHeaderHeight = 0
            DiaryTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(DiaryTableView)
        
 
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        advancedeventTableView.tableFooterView = footerView
        advancedeventTableView.tableFooterView?.isHidden = true

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
        
        self.automaticallyAdjustsScrollViewInsets = false

        setNavigationImage(controller: self)
        if issearch == "yes"
        {
            DiaryTableView.frame = CGRect(x: 0, y: 0 , width: view.bounds.width, height: view.bounds.height)

        }
        if searchDic.count > 0
        {
           // searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
            searchBar.text = globFilterValue
            searchBar.endEditing(true)
            pageNumber = 1
            showSpinner = true
            self.browseEntries()
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
        advancedeventTableView.tableFooterView?.isHidden = true
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
    @objc func stopTimer()
    {
        stop()
    }
    
    //MARK:Event for BACK
    @objc func cancel()
    {
        eventUpdate = false
        _ = self.navigationController?.popViewController(animated: false)

        
    }
    
    // MARK: - Host Profile Selection
    @objc func hostProfile(_ sender:UIButton)
    {
        var eventInfo:NSDictionary!
        var hostInfo:NSDictionary!
        eventInfo = advancedeventResponse[sender.tag] as! NSDictionary
        if let _ = eventInfo["hosted_by"]
        {
            hostInfo = eventInfo["hosted_by"]as! NSDictionary
            
            if let hostId = hostInfo["host_id"] as? Int
            {
                if hostId != 0
                {
                    let  hostType = hostInfo["host_type"] as? String
                    
                    if let eventInfo = eventInfo["title"] as? String {
                        updateAutoSearchArray(str: eventInfo)
                    }
                    if hostType == "user"{
                        
                        let presentedVC = ContentActivityFeedViewController()
                        
                        presentedVC.subjectType = "user"
                        eventUpdate = false
                        presentedVC.subjectId = "\(hostId)"
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    else{
                        let presentedVC = AdvHostMemberViewController()
                        presentedVC.hostId = hostId
                        navigationController?.pushViewController(presentedVC, animated: true)
                    }
                    
                }
                
            }
            else
            {
                showToast(message: "You do not have permission to view this private page.", controller: self)
            }
        }
    }
    
    //MARK:Diary section
    @objc func coverSelection(_ sender:UIButton)
    {
        
        var eventInfo:NSDictionary!
        eventInfo = advancedeventResponse[sender.tag] as! NSDictionary
        
        if let eventInfo = eventInfo["title"] as? String {
            updateAutoSearchArray(str: eventInfo)
        }
        let presentedVC = DiaryDetailViewController()
        presentedVC.subjectId = eventInfo["diary_id"] as! Int
        presentedVC.totalItemCount = eventInfo["total_item"] as! Int
        presentedVC.diaryName = eventInfo["title"] as! String
        presentedVC.IScomingfrom = "diary"
        
        presentedVC.descriptiondiary = eventInfo["body"] as! String
        issearch = "yes"
        
        
        navigationController?.pushViewController(presentedVC, animated: true)
        
        
    }
    
    //MARK:Event for SEARCH
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
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
                advancedeventTableView.isHidden = true
                DiaryTableView.isHidden = true
                //  self.channelTableView.isHidden = true
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
     //   searchBar.resignFirstResponder()
        
        browseEntries()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    @objc func showEvent(_ sender:UIButton)
    {
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(view)
            return
        }
        var eventInfo:NSDictionary!
        eventInfo = advancedeventResponse[sender.tag] as! NSDictionary
        
        if(eventInfo["allow_to_view"] as! Int == 1)
        {
            if let eventInfo = eventInfo["title"] as? String {
                updateAutoSearchArray(str: eventInfo)
            }
            let presentedVC = ContentFeedViewController()
            presentedVC.subjectId = "\(eventInfo["event_id"]!)"
            presentedVC.subjectType = "advancedevents"
            navigationController?.pushViewController(presentedVC, animated: true)
        }
        else
        {
            showToast(message: "You do not have permission to view this private page.", controller: self)
        }
    }
    
    @objc func filter()
    {
        
        if filterSearchFormArray.count > 0
        {
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "advancedevents"
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else
        {
            let presentedVC = FilterSearchViewController()
            if self.comingFrom == "diary" {
                presentedVC.searchUrl = "advancedevents/diaries/search-form"
            }
            else {
                presentedVC.searchUrl = "advancedevents/search-form"
                presentedVC.serachFor = "advancedevents"
            }
            
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        
        
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView)
//    {
//
//        if updateScrollFlag{
//            // Check for Page Number for Browse Blog
//            if advancedeventTableView.contentOffset.y >= advancedeventTableView.contentSize.height - advancedeventTableView.bounds.size.height{
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
                // Check for Page Number for Browse Blog
//                if advancedeventTableView.contentOffset.y >= advancedeventTableView.contentSize.height - advancedeventTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            advancedeventTableView.tableFooterView?.isHidden = false
                           // if searchDic.count == 0{
                                browseEntries()
                           // }
                        }
                    }
                    else
                    {
                        advancedeventTableView.tableFooterView?.isHidden = true
                }
                    
              //  }
                
            }
            
        }
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView.tag == 122{
            return dynamicHeightAutoSearch
        }
       else if eventBrowseType == 10
        {
            return 202.0
        }
        else
        {
            return 265.0
        }
        
    }
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else if(UIDevice.current.userInterfaceIdiom == .pad){
            return Int(ceil(Float(advancedeventResponse.count)/2))
        }else{
            return advancedeventResponse.count
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
        else if eventBrowseType == 10
        {
            let cell = DiaryTableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DiaryTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            var eventInfo:NSDictionary!
            
            
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                if(advancedeventResponse.count > ((indexPath as NSIndexPath).row)*2)
                {
                    eventInfo = advancedeventResponse[((indexPath as NSIndexPath).row)*2] as! NSDictionary
                    cell.coverSelection.tag = ((indexPath as NSIndexPath).row)*2
                    cell.coverImage.tag = ((indexPath as NSIndexPath).row)*2
                    
                }
            }
            else
            {
                eventInfo = advancedeventResponse[(indexPath as NSIndexPath).row] as! NSDictionary
                cell.coverSelection.tag = (indexPath as NSIndexPath).row
                cell.coverImage.tag = (indexPath as NSIndexPath).row
                
            }
            
            cell.coverSelection.addTarget(self, action: #selector(AdvancedEventSearchViewController.coverSelection(_:)), for: .touchUpInside)
            let name = eventInfo["title"] as? String
            cell.titleLabel.text = "\(name!)"
            
            
            let count = eventInfo["total_item"] as? Int
            if count != nil
            {
                cell.countLabel.text = "\(count!)"
            }
            
            
            if count>0
            {
                if count==1
                {
                    cell.coverImage.isHidden = false
                    cell.coverImage1.isHidden = true
                    cell.coverImage2.isHidden = true
                    cell.coverImage3.isHidden = true
                    cell.coverImage4.isHidden = true
                    cell.coverImage5.isHidden = true
                    cell.coverImage.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                    imageArr.removeAll()
                    let imagedic = eventInfo["images_1"] as! NSDictionary
                    let url = URL(string: imagedic["image"] as! NSString as String)
                    if url != nil {
                        cell.coverImage.kf.indicatorType = .activity
                        (cell.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.coverImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                        
                    }
                    
                }
                else if count==2
                {
                    cell.coverImage.isHidden = true
                    cell.coverImage1.isHidden = true
                    cell.coverImage2.isHidden = true
                    cell.coverImage3.isHidden = true
                    cell.coverImage4.isHidden = false
                    cell.coverImage5.isHidden = false
                    
                    cell.coverImage4.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
                    cell.coverImage5.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
                    
                    let imagedic1 = eventInfo["images_1"] as! NSDictionary
                    let imagedic2 = eventInfo["images_2"] as! NSDictionary
                    
                    let url1 = URL(string: imagedic1["image"] as! NSString as String)
                    if url1 != nil {

                      cell.coverImage4.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
                        cell.coverImage4.kf.setImage(with: url1, for: .normal, placeholder: UIImage(named: "nophoto_diary_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                            
                        })

                    }
                    
                    let url2 = URL(string: imagedic2["image"] as! NSString as String)
                    if url2 != nil {

                        cell.coverImage5.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
                        cell.coverImage5.kf.setImage(with: url2, for: .normal, placeholder: UIImage(named: "nophoto_diary_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                            
                        })

                    }
                    
                    
                }
                else if count==3 || count > 3
                {
                    cell.coverImage.isHidden = true
                    cell.coverImage4.isHidden = true
                    cell.coverImage5.isHidden = true
                    
                    cell.coverImage1.isHidden = false
                    cell.coverImage2.isHidden = false
                    cell.coverImage3.isHidden = false
                    
                    cell.coverImage1.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                    cell.coverImage2.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                    cell.coverImage3.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                    let imagedic3 = eventInfo["images_1"] as! NSDictionary
                    let imagedic4 = eventInfo["images_2"] as! NSDictionary
                    let imagedic5 = eventInfo["images_3"] as! NSDictionary
                    
                    let url3 = URL(string: imagedic3["image"] as! NSString as String)

                    if url3 != nil {

                        cell.coverImage1.kf.indicatorType = .activity
                        (cell.coverImage1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.coverImage1.kf.setImage(with: url3 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                    }
                    
                    let url4 = URL(string: imagedic4["image"] as! NSString as String)
                    if url4 != nil {
                        cell.coverImage2.kf.indicatorType = .activity
                        (cell.coverImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.coverImage2.kf.setImage(with: url4 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })

                    }
                    let url5 = URL(string: imagedic5["image"] as! NSString as String)
                    if url5 != nil {
                        cell.coverImage3.kf.indicatorType = .activity
                        (cell.coverImage3.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.coverImage3.kf.setImage(with: url5 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
  
                    }
                    
                }
            }
            else
            {
                if count != nil
                {
                    imageArr.removeAll()
                    cell.coverImage.isHidden = false
                    cell.coverImage1.isHidden = true
                    cell.coverImage2.isHidden = true
                    cell.coverImage3.isHidden = true
                    cell.coverImage4.isHidden = true
                    cell.coverImage5.isHidden = true
                    cell.coverImage.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                    
                    let imagedic = eventInfo["images_0"] as! NSDictionary
                    let url = URL(string: imagedic["image"] as! NSString as String)
                    if url != nil {
                        cell.coverImage.kf.indicatorType = .activity
                        (cell.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.coverImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        })

                    }
                }
 
            }
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                
                
                cell.lineView2.isHidden = false
                var eventInfo2:NSDictionary!
                if(advancedeventResponse.count > (((indexPath as NSIndexPath).row)*2+1))
                {
                    eventInfo2 = advancedeventResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
                    
                    
                    cell.cellView2.isHidden = false
                    cell.lineView2.isHidden = false
                    cell.coverSelection2.isHidden = false
                    cell.coverSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
                }
                else
                {
                    cell.cellView2.isHidden = true
                    cell.lineView2.isHidden = true
                    
                }
                cell.coverSelection2.addTarget(self, action: #selector(AdvancedEventSearchViewController.coverSelection(_:)), for: .touchUpInside)
                let name = eventInfo2["title"] as? String
                cell.titleLabel2.text = "\(name!)"
                
                
                let count = eventInfo2["total_item"] as? Int
                if count != nil
                {
                    cell.countLabel2.text = "\(count!)"
                }
                
                
                if count>0
                {
                    if count==1
                    {
                        cell.coverImage6.isHidden = false
                        cell.coverImage7.isHidden = true
                        cell.coverImage8.isHidden = true
                        cell.coverImage9.isHidden = true
                        cell.coverImage10.isHidden = true
                        cell.coverImage11.isHidden = true
                        
                        
                        let imagedic6 = eventInfo2["event_images_1"] as! NSDictionary
                        let url6 = URL(string: imagedic6["image"] as! NSString as String)
                        if url6 != nil {
                            cell.coverImage6.image = nil
                            cell.coverImage6.kf.indicatorType = .activity
                            (cell.coverImage6.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.coverImage6.kf.setImage(with: url6 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })

                        }
                        
                    }
                    else if count==2
                    {
                        cell.coverImage6.isHidden = true
                        cell.coverImage7.isHidden = true
                        cell.coverImage8.isHidden = true
                        cell.coverImage9.isHidden = true
                        cell.coverImage10.isHidden = false
                        cell.coverImage11.isHidden = false
                        
                        
                        
                        let imagedic7 = eventInfo2["event_images_1"] as! NSDictionary
                        let imagedic8 = eventInfo2["event_images_2"] as! NSDictionary
                        let url7 = URL(string: imagedic7["image"] as! NSString as String)

                        if url7 != nil {
                            cell.coverImage10.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
                            cell.coverImage10.kf.setImage(with: url7, for: .normal, placeholder: UIImage(named: "nophoto_diary_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                
                            })

                        }
                        
                        let url8 = URL(string: imagedic8["image"] as! NSString as String)

                        if url8 != nil {

                            cell.coverImage11.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
                            cell.coverImage11.kf.setImage(with: url8, for: .normal, placeholder: UIImage(named: "nophoto_diary_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                                
                            })

                        }
                        
                    }
                    else if count==3 || count > 3
                    {
                        cell.coverImage6.isHidden = true
                        cell.coverImage10.isHidden = true
                        cell.coverImage11.isHidden = true
                        
                        cell.coverImage7.isHidden = false
                        cell.coverImage8.isHidden = false
                        cell.coverImage9.isHidden = false
                        
                        let imagedic9 = eventInfo2["event_images_1"] as! NSDictionary
                        let imagedic10 = eventInfo2["event_images_2"] as! NSDictionary
                        let imagedic11 = eventInfo2["event_images_3"] as! NSDictionary
                        
                        let url9 = URL(string: imagedic9["image"] as! NSString as String)

                        if url9 != nil {

                            cell.coverImage7.kf.indicatorType = .activity
                            (cell.coverImage7.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.coverImage7.kf.setImage(with: url9, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })

                        }
                        
                        let url10 = URL(string: imagedic10["image"] as! NSString as String)

                        if url10 != nil {

                            cell.coverImage8.kf.indicatorType = .activity
                            (cell.coverImage8.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.coverImage8.kf.setImage(with: url10, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })
                            
                        }
                        
                        let url11 = URL(string: imagedic11["image"] as! NSString as String)

                        if url11 != nil {

                            cell.coverImage9.kf.indicatorType = .activity
                            (cell.coverImage9.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.coverImage9.kf.setImage(with: url11, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                
                            })

                        }
 
                    }
                }
                else
                {
                    if count != nil
                    {
                        
                        cell.coverImage6.isHidden = false
                        cell.coverImage7.isHidden = true
                        cell.coverImage8.isHidden = true
                        cell.coverImage9.isHidden = true
                        cell.coverImage10.isHidden = true
                        cell.coverImage11.isHidden = true
                        
                        let imagedic = eventInfo2["event_images_0"] as! NSDictionary
                        let url = URL(string: imagedic["image"] as! NSString as String)

                        if url != nil {
                            cell.coverImage6.kf.indicatorType = .activity
                            (cell.coverImage6.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.coverImage6.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            })
                        }
                    }
 
                }
                return cell
            }
            
            return cell
        }
        else
        {
            let cell = advancedeventTableView.dequeueReusableCell(withIdentifier: "CellThree", for: indexPath) as! EventViewTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.lineView.isHidden = false
            cell.dateView.backgroundColor = navColor
            cell.btnDate.addTarget(self, action: Selector(("DateAction:")), for: .touchUpInside)

            cell.btnDate.tag = (indexPath as NSIndexPath).row
            cell.backgroundColor = tableViewBgColor
            
            cell.hostImage.isHidden = false
            cell.hostSelection.isHidden = false
            cell.hostSelection.isUserInteractionEnabled = true
            
            var eventInfo:NSDictionary!
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                if(advancedeventResponse.count > ((indexPath as NSIndexPath).row)*2)
                {
                    eventInfo = advancedeventResponse[((indexPath as NSIndexPath).row)*2] as! NSDictionary
                    cell.contentSelection.tag = ((indexPath as NSIndexPath).row)*2
                    cell.hostSelection.tag = ((indexPath as NSIndexPath).row)*2
                    cell.btnDate.tag = ((indexPath as NSIndexPath).row)*2
                    cell.menu.tag = ((indexPath as NSIndexPath).row)*2
                    
                    if eventBrowseType==3
                    {
                        cell.gutterMenu.tag = ((indexPath as NSIndexPath).row)*2
                        cell.gutterMenu.isHidden = false
                        cell.cellView.frame.size.height = 280
                        cell.titleView.frame.size.height = 100
                        cell.dateView.frame.size.height = cell.titleView.frame.size.height
                        cell.lineView.frame.origin.y = cell.cellView.frame.size.height
                        cell.gutterMenu.addTarget(self, action:Selector(("showGutterMenu:")) , for: .touchUpInside)

                        advancedeventTableView.rowHeight = 280
                        cell.btnMembercount.isHidden = false
                        cell.btnviewcount.isHidden = false
                        cell.btnlikecount.isHidden = false
                        cell.lblMembercount.isHidden = false
                        cell.lblviewcount.isHidden = false
                        cell.lbllikecount.isHidden = false
                        
                        
                        
                        cell.cellView2.frame.size.height = 280
                        cell.titleView2.frame.size.height = 100
                        cell.dateView2.frame.size.height = cell.titleView.frame.size.height
                        cell.lineView2.frame.origin.y = cell.cellView.frame.size.height

                        
                    }
                    else
                    {
                        cell.gutterMenu.isHidden = true
                        cell.cellView.frame.size.height = 260
                        cell.titleView.frame.size.height = 80
                        cell.dateView.frame.size.height = cell.titleView.frame.size.height
                        cell.lineView.frame.origin.y = cell.cellView.frame.size.height
                        
                        advancedeventTableView.rowHeight = 260
                        cell.btnMembercount.isHidden = true
                        cell.btnviewcount.isHidden = true
                        cell.btnlikecount.isHidden = true
                        cell.lblMembercount.isHidden = true
                        cell.lblviewcount.isHidden = true
                        cell.lbllikecount.isHidden = true
                        
                    }
                    
                }
                
                
                
            }
            else
            {
                eventInfo = advancedeventResponse[(indexPath as NSIndexPath).row] as! NSDictionary
                cell.contentSelection.tag = (indexPath as NSIndexPath).row
                cell.hostSelection.tag = (indexPath as NSIndexPath).row
                cell.btnDate.tag = (indexPath as NSIndexPath).row
                cell.menuButton.tag = (indexPath as NSIndexPath).row
                cell.gutterMenu.tag = (indexPath as NSIndexPath).row
                
                if eventBrowseType==3
                {
                    cell.gutterMenu.isHidden = false
                    cell.cellView.frame.size.height = 280
                    cell.titleView.frame.size.height = 100
                    cell.dateView.frame.size.height = cell.titleView.frame.size.height
                    cell.lineView.frame.origin.y = cell.cellView.frame.size.height
                    cell.gutterMenu.addTarget(self, action:Selector(("showGutterMenu:")) , for: .touchUpInside)

                    advancedeventTableView.rowHeight = 280
                    cell.btnMembercount.isHidden = false
                    cell.btnviewcount.isHidden = false
                    cell.btnlikecount.isHidden = false
                    cell.lblMembercount.isHidden = false
                    cell.lblviewcount.isHidden = false
                    cell.lbllikecount.isHidden = false
                    
                }
                else
                {
                    cell.cellView.frame.size.height = 260
                    cell.titleView.frame.size.height = 80
                    cell.dateView.frame.size.height = cell.titleView.frame.size.height
                    cell.lineView.frame.origin.y = cell.cellView.frame.size.height
                    cell.gutterMenu.isHidden = true
                    advancedeventTableView.rowHeight = 260
                    cell.btnMembercount.isHidden = true
                    cell.btnviewcount.isHidden = true
                    cell.btnlikecount.isHidden = true
                    cell.lblMembercount.isHidden = true
                    cell.lblviewcount.isHidden = true
                    cell.lbllikecount.isHidden = true
                    
                }
                
            }
            
            
            
            //Select Event Action
            cell.contentSelection.addTarget(self, action: #selector(AdvancedEventSearchViewController.showEvent(_:)), for: .touchUpInside)
            // Set MenuAction

            cell.menuButton.addTarget(self, action:Selector(("showEventMenu:")) , for: .touchUpInside)

            cell.hostSelection.addTarget(self, action:#selector(AdvancedEventSearchViewController.hostProfile(_:)), for: .touchUpInside)
            cell.btnTittle.addTarget(self, action:#selector(AdvancedEventSearchViewController.showEvent(_:)) , for: .touchUpInside)
            cell.contentImage.frame.size.height = 180
            cell.contentSelection.frame.size.height = 180
            //
            // Set Event Image
            
            if let photoId = eventInfo["photo_id"] as? Int
            {
                
                if photoId != 0
                {
                    cell.contentImage.image = nil
                    cell.contentImage.backgroundColor = placeholderColor
                    let url = URL(string: eventInfo["image"] as! NSString as String)
                    if url != nil {
                         cell.contentImage.kf.indicatorType = .activity
                        (cell.contentImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.contentImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                })

                    }
                    
                }
                else
                {
                    cell.contentImage.image = nil
                    cell.contentImage.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                    
                }
            }
            else
            {
                cell.contentImage.image = nil
            }
            
            
            
            //Set Profile Image
            if let hostId = eventInfo["host_id"] as? Int
            {
                
                if hostId != 0
                {
                    cell.hostImage.image = nil
                    cell.hostImage.backgroundColor = placeholderColor
                    var hostInfo:NSDictionary!
                    if let _ = eventInfo["hosted_by"]
                    {
                        hostInfo = eventInfo["hosted_by"] as! NSDictionary
                        let url = URL(string: hostInfo["image"] as! NSString as String)
                        if url != nil {
                            cell.hostImage.kf.indicatorType = .activity
                            (cell.hostImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                            cell.hostImage.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            })
                        }
                        
                    }

                }
                else
                {
                    cell.hostImage.image = nil
                    cell.hostImage.image =  imageWithImage( UIImage(named: "")!, scaletoWidth: cell.hostImage.bounds.width)
                    
                }
            }
            else
            {
                cell.hostImage.image = nil
            }
            
            let name = eventInfo["title"] as? String
            var tempInfo = ""
            
            
            if let eventDate = eventInfo["starttime"] as? String
            {
                
                let dateMonth = dateDifferenceWithTime(eventDate)

                var dateArrayMonth = dateMonth.components(separatedBy: ", ")
                if dateArrayMonth.count > 1{
                    cell.dateLabel1.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                    
                    cell.dateLabel1.numberOfLines = 0
                    cell.dateLabel1.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                    cell.dateLabel1.textColor = UIColor.white
                    cell.dateLabel1.font = UIFont(name: "FontAwesome", size: 22)
                }
                
                let date = dateDifferenceWithEventTime(eventDate)

                var DateC = date.components(separatedBy: ", ")
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
                if eventInfo["isRepeatEvent"] as? Int == 1
                {
                    tempInfo += "(Multiple Dates Available)"
                }
            }
            
            cell.titleLabel.frame = CGRect(x: 10, y: 0, width: (cell.contentImage.bounds.width-110), height: 30)
            
            cell.titleLabel.text = "\(name!)"
            cell.titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
            // cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
            
            
            
            if let membercount = eventInfo["member_count"] as? Int
            {
                cell.lblMembercount.text = "\(membercount)"
            }
            
            if let viewcount = eventInfo["view_count"] as? Int
            {
                cell.lblviewcount.text = "\(viewcount)"
            }
            
            if let likecount = eventInfo["like_count"] as? Int
            {
                cell.lbllikecount.text = "\(likecount)"
            }
            
            
            let location = eventInfo["location"] as? String
            if location != "" && location != nil
            {
                
                cell.locLabel.isHidden = false
                
                cell.locLabel.frame = CGRect(x: 10, y: 25, width: (cell.contentImage.bounds.width-110), height: 20)
                cell.locLabel.text = "\u{f041}   \(location!)"
                // cell.locLabel.textColor = textColorLight
                cell.locLabel.font = UIFont(name: "FontAwesome", size: 14)
                cell.locLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
                
                if eventInfo["isRepeatEvent"] as? Int == 1
                {
                    cell.dateLabel.frame = CGRect(x: 10, y: 40, width: (cell.contentImage.bounds.width-110), height: 40)
                    
                    cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                    cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                    
                    cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                    cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                    
                    cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                    cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y-5, width: 20, height: 20)
                }
                else
                {
                    cell.dateLabel.frame = CGRect(x: 10, y: 45, width: (cell.contentImage.bounds.width-110), height: 20)
                    
                    cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                    cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                    
                    cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                    cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                    
                    cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                    cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                }
                
                cell.dateLabel.text = "\u{f073}  \(tempInfo)"
                cell.dateLabel.textAlignment = NSTextAlignment.left
                cell.dateLabel.numberOfLines = 0
                
                // cell.dateLabel.textColor = textColorLight
                cell.dateLabel.font = UIFont(name: "FontAwesome", size: 14)
                
                cell.dateLabel1.frame = CGRect(x: 0, y: (cell.titleView.frame.size.height-60)/2, width: 70, height: 60)
                
                
            }
            
            if location == "" || location == nil{
                
                cell.locLabel.isHidden = true
                if eventInfo["isRepeatEvent"] as? Int == 1
                {
                    cell.dateLabel.frame = CGRect(x: 10, y: 30, width: (cell.contentImage.bounds.width-110), height: 40)
                    
                    cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                    cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                    
                    
                    cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                    cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                    
                    cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                    cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                    
                }
                else
                {
                    cell.dateLabel.frame = CGRect(x: 10, y: 35, width: (cell.contentImage.bounds.width-110), height: 20)
                    
                    cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                    cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                    
                    
                    cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                    cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                    
                    cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                    cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                    
                }
                
                
                cell.dateLabel.text = "\u{f073}  \(tempInfo)"
                cell.dateLabel.textAlignment = NSTextAlignment.left
                //cell.dateLabel.textColor = textColorLight
                cell.dateLabel.numberOfLines = 0
                cell.dateLabel.font = UIFont(name: "FontAwesome", size: 14)
                
                cell.dateLabel1.frame = CGRect(x: 0, y: (cell.titleView.frame.size.height-60)/2, width: 70, height: 60)
                
            }
            
            
            // RHS
            if(UIDevice.current.userInterfaceIdiom == .pad)
            {
                
                
                cell.lineView2.isHidden = false
                cell.dateView2.backgroundColor = navColor

                cell.btnDate1.addTarget(self, action: Selector(("DateAction:")), for: .touchUpInside)

                var eventInfo2:NSDictionary!
                if(advancedeventResponse.count > (((indexPath as NSIndexPath).row)*2+1))
                {
                    eventInfo2 = advancedeventResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
                    cell.dateView2.isHidden = false
                    cell.cellView2.isHidden = false
                    cell.titleView2.isHidden = false
                    cell.contentSelection2.isHidden = false
                    cell.contentSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
                    cell.hostSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
                    cell.menuButton2.tag = (((indexPath as NSIndexPath).row)*2+1)
                    cell.btnDate1.tag = (((indexPath as NSIndexPath).row)*2+1)
                    if eventBrowseType==3
                    {
                        
                        
                        cell.gutterMenu2.isHidden = false
                        cell.gutterMenu2.tag = (((indexPath as NSIndexPath).row)*2+1)
                        cell.cellView2.frame.size.height = 280
                        cell.titleView2.frame.size.height = 100
                        cell.dateView2.frame.size.height = cell.titleView2.frame.size.height
                        cell.lineView2.frame.origin.y = cell.cellView2.frame.size.height
                        cell.gutterMenu2.addTarget(self, action:Selector(("showGutterMenu:")) , for: .touchUpInside)

                        advancedeventTableView.rowHeight = 280
                        cell.btnMembercount2.isHidden = false
                        cell.btnviewcount2.isHidden = false
                        cell.btnlikecount2.isHidden = false
                        cell.lblMembercount2.isHidden = false
                        cell.lblviewcount2.isHidden = false
                        cell.lbllikecount2.isHidden = false
                        
                        cell.cellView2.frame.size.height = 280
                        cell.titleView2.frame.size.height = 100
                        cell.dateView2.frame.size.height = cell.titleView.frame.size.height
                        cell.lineView2.frame.origin.y = cell.cellView.frame.size.height
                        
                        
                    }
                    else
                    {
                        cell.cellView2.frame.size.height = 260
                        cell.titleView2.frame.size.height = 80
                        cell.dateView2.frame.size.height = cell.titleView2.frame.size.height
                        cell.lineView2.frame.origin.y = cell.cellView2.frame.size.height
                        cell.gutterMenu2.isHidden = true
                        advancedeventTableView.rowHeight = 260
                        cell.btnMembercount2.isHidden = true
                        cell.btnviewcount2.isHidden = true
                        cell.btnlikecount2.isHidden = true
                        cell.lblMembercount2.isHidden = true
                        cell.lblviewcount2.isHidden = true
                        cell.lbllikecount2.isHidden = true
                        
                        
                    }
                    
                }
                else
                {
                    cell.cellView2.isHidden = true
                    cell.dateView2.isHidden = true
                    cell.contentSelection2.isHidden = true
                    cell.titleView2.isHidden = true
                    return cell
                }
                
                
                
                cell.hostImage2.isHidden = false
                cell.hostSelection2.isHidden = false
                cell.hostSelection2.isUserInteractionEnabled = true
                
                // Select Event Action
                cell.contentSelection2.addTarget(self, action: #selector(AdvancedEventSearchViewController.showEvent(_:)), for: .touchUpInside)
                // Set MenuAction
                cell.btnTittle2.addTarget(self, action:#selector(AdvancedEventSearchViewController.showEvent(_:)) , for: .touchUpInside)
                cell.menuButton2.addTarget(self, action:Selector(("showEventMenu:")) , for: .touchUpInside)

                cell.hostSelection2.addTarget(self, action:#selector(AdvancedEventSearchViewController.hostProfile(_:)), for: .touchUpInside)
                
                
                
                cell.contentImage2.frame.size.height = 180
                cell.contentSelection2.frame.size.height = 180
                
                
                // Set Event Image
                if let photoId = eventInfo2["photo_id"] as? Int{
                    
                    if photoId != 0{
                        cell.contentImage2.image = nil
                        let url = URL(string: eventInfo2["image"] as! NSString as String)
                        
                        if url != nil {
                              cell.contentImage2.kf.indicatorType = .activity
                            (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                              cell.contentImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                             })

                        }
                        
                    }
                    else
                    {
                        cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                    }
                }
                
                
                //Set Profile Image
                if let hostId2 = eventInfo2["host_id"] as? Int
                {
                    
                    if hostId2 != 0
                    {
                        cell.hostImage2.image = nil
                        cell.hostImage2.backgroundColor = placeholderColor
                        var hostInfo2:NSDictionary!
                        if let _ = eventInfo2["hosted_by"]
                        {
                            hostInfo2 = eventInfo2["hosted_by"] as! NSDictionary
                            let url = URL(string: hostInfo2["image"] as! NSString as String)

                            if url != nil {
                                cell.hostImage2.kf.indicatorType = .activity
                                (cell.hostImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                cell.hostImage2.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                })

                            }
                            
                        }

                    }
                    else
                    {
                        cell.hostImage2.image = nil
                        cell.hostImage2.image =  imageWithImage( UIImage(named: "")!, scaletoWidth: cell.hostImage2.bounds.width)
                        
                    }
                }
                else
                {
                    cell.hostImage2.image = nil
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
                        cell.dateLabel3.font = UIFont(name: "FontAwesome", size: 22)
                    }
                    
                    let date = dateDifferenceWithEventTime(eventDate)
                    var DateC = date.components(separatedBy: ", ")
                    tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                    if DateC.count > 3{
                        tempInfo += " at \(DateC[3])"
                    }
                    if eventInfo2["isRepeatEvent"] as? Int == 1
                    {
                        tempInfo += "(Multiple Dates Available)"
                    }
                    
                }
                else{
                    cell.dateView2.isHidden = true
                }
                
                cell.titleLabel2.frame = CGRect(x: 10, y: 0, width: (cell.contentImage2.bounds.width-110), height: 30)
                
                cell.titleLabel2.text = "\(name!)"
                cell.titleLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                // cell.contentName.font = UIFont(name: "FontAwesome", size: 18)
                
                
                
                
                if let membercount2 = eventInfo2["member_count"] as? Int
                {
                    cell.lblMembercount2.text = "\(membercount2)"
                }
                
                if let viewcount2 = eventInfo2["view_count"] as? Int
                {
                    cell.lblviewcount2.text = "\(viewcount2)"
                }
                
                if let likecount2 = eventInfo2["like_count"] as? Int
                {
                    cell.lbllikecount2.text = "\(likecount2)"
                }
                
                
                
                let location = eventInfo2["location"] as? String
                if location != "" && location != nil{
                    
                    cell.locLabel2.isHidden = false
                    
                    cell.locLabel2.frame = CGRect(x: 10, y: 25, width: (cell.contentImage2.bounds.width-110), height: 20)
                    cell.locLabel2.text = "\u{f041}   \(location!)"
                    // cell.locLabel.textColor = textColorLight
                    cell.locLabel2.font = UIFont(name: "FontAwesome", size: 14)
                    cell.locLabel2.lineBreakMode = NSLineBreakMode.byTruncatingTail
                    
                    
                    if eventInfo2["isRepeatEvent"] as? Int == 1
                    {
                        cell.dateLabel2.frame = CGRect(x: 10, y: 40, width: (cell.contentImage2.bounds.width-110), height: 40)
                        cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                        cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                        
                        cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                        cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                        
                        cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                        cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y-5, width: 20, height: 20)
                    }
                    else
                    {
                        cell.dateLabel2.frame = CGRect(x: 10, y: 45, width: (cell.contentImage2.bounds.width-110), height: 20)
                        
                        cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                        cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                        
                        cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                        cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                        
                        cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                        cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                    }
                    
                    
                    cell.dateLabel2.text = "\u{f073}  \(tempInfo)"
                    cell.dateLabel2.textAlignment = NSTextAlignment.left
                    // cell.dateLabel.textColor = textColorLight
                    cell.dateLabel2.numberOfLines = 0
                    
                    cell.dateLabel2.font = UIFont(name: "FontAwesome", size: 14)
                    
                    
                    cell.dateLabel3.frame = CGRect(x: 0, y: (cell.titleView.frame.size.height-60)/2, width: 70, height: 60)
                    
                    
                    
                }
                
                if location == "" || location == nil{
                    
                    cell.locLabel2.isHidden = true
                    
                    
                    if eventInfo["isRepeatEvent"] as? Int == 1
                    {
                        cell.dateLabel.frame = CGRect(x: 10, y: 30, width: (cell.contentImage.bounds.width-110), height: 40)
                        
                        cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                        cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                        
                        
                        cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                        cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                        
                        cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                        cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y, width: 20, height: 20)
                        
                    }
                    else
                    {
                        cell.dateLabel.frame = CGRect(x: 10, y: 35, width: (cell.contentImage.bounds.width-110), height: 20)
                        
                        cell.btnMembercount.frame  = CGRect(x: 7,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                        cell.lblMembercount.frame = CGRect(x: cell.btnMembercount.frame.origin.x + cell.btnMembercount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                        
                        
                        cell.btnviewcount.frame  = CGRect(x: cell.lblMembercount.frame.origin.x + cell.lblMembercount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                        cell.lblviewcount.frame = CGRect(x: cell.btnviewcount.frame.origin.x + cell.btnviewcount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                        
                        cell.btnlikecount.frame  = CGRect(x: cell.lblviewcount.frame.origin.x + cell.lblviewcount.frame.size.width+20,y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                        cell.lbllikecount.frame = CGRect(x: cell.btnlikecount.frame.origin.x + cell.btnlikecount.frame.size.width+10, y: cell.dateLabel.frame.size.height+cell.dateLabel.frame.origin.y+10, width: 20, height: 20)
                        
                    }
                    
                    
                    
                    if eventInfo2["isRepeatEvent"] as? Int == 1
                    {
                        cell.dateLabel2.frame = CGRect(x: 10, y: 30, width: (cell.contentImage2.bounds.width-110), height: 40)
                        
                        cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                        cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                        
                        cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                        cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                        
                        cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                        cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y, width: 20, height: 20)
                        
                        
                    }
                    else
                    {
                        cell.dateLabel2.frame = CGRect(x: 10, y: 35, width: (cell.contentImage2.bounds.width-110), height: 20)
                        
                        cell.btnMembercount2.frame  = CGRect(x: 7,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                        cell.lblMembercount2.frame = CGRect(x: cell.btnMembercount2.frame.origin.x + cell.btnMembercount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                        
                        cell.btnviewcount2.frame  = CGRect(x: cell.lblMembercount2.frame.origin.x + cell.lblMembercount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                        cell.lblviewcount2.frame = CGRect(x: cell.btnviewcount2.frame.origin.x + cell.btnviewcount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                        
                        cell.btnlikecount2.frame  = CGRect(x: cell.lblviewcount2.frame.origin.x + cell.lblviewcount2.frame.size.width+20,y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                        cell.lbllikecount2.frame = CGRect(x: cell.btnlikecount2.frame.origin.x + cell.btnlikecount2.frame.size.width+10, y: cell.dateLabel2.frame.size.height+cell.dateLabel2.frame.origin.y+10, width: 20, height: 20)
                        
                        
                    }
                    
                    
                    cell.dateLabel2.text = "\u{f073}  \(tempInfo)"
                    cell.dateLabel2.textAlignment = NSTextAlignment.left
                    //cell.dateLabel.textColor = textColorLight
                    cell.dateLabel2.numberOfLines = 0
                    
                    cell.dateLabel2.font = UIFont(name: "FontAwesome", size: 14)
                    
                    
                    cell.dateLabel3.frame = CGRect(x: 0, y: (cell.titleView.frame.size.height-60)/2, width: 70, height: 60)
                    
                    
                    
                    
                }
                
                
                return cell
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
                advancedeventTableView.isHidden = true
                DiaryTableView.isHidden = true
              //  self.channelTableView.isHidden = true
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

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!)
    {
        
        
        
        let type = components["type"] as! String
        
        switch(type)
        {
        case "category_id":
            blogUpdate = true
            searchDic.removeAll(keepingCapacity: false)
            let id = components["id"] as! Int
            searchDic["category"] = "\(id)"

            _ = self.navigationController?.popViewController(animated: true)

//
//        case "less":
//            //print("less")
//
//        case "user":
//            //print("user")
            
        default:
            print("default")
        }
        
    }
    
    // MARK: - Server Connection For Event Updation
    // Update Events
    
    func browseEntries()
    {
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            
            for ob in view.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            //
            if (self.pageNumber == 1)
            {
                self.advancedeventResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true
                {
                    removeAlert()
                    self.advancedeventTableView.reloadData()
                }
                else
                {
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner)
            {
//                spinner.center = view.center
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
              //  activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            
            
            
            switch(eventBrowseType)
            {
            case 0:
                
                path = "advancedevents"
                //                parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future"]
                self.title = NSLocalizedString("Advanced Events",  comment: "")
                
                if Locationdic != nil
                {
                    let defaults = UserDefaults.standard
                    
                    if let loc = defaults.string(forKey: "Location")
                    {
                        
                        parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future","restapilocation": loc]
                    }
                    else
                    {
                        
                        
                        parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future","restapilocation": defaultlocation]
                    }
                    
                    
                    
                }
                else
                {
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future"]
                }
                
                
            case 1:
                path = "advancedevents"
                //parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future"]
                if Locationdic != nil
                {
                    let defaults = UserDefaults.standard
                    
                    if let loc = defaults.string(forKey: "Location")
                    {
                        
                        parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future","restapilocation": loc]
                    }
                    else
                    {
                        
                        
                        parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future","restapilocation": defaultlocation]
                    }
                    
                    
                    
                }
                else
                {
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future"]
                }
                self.title = NSLocalizedString("Advanced Events",  comment: "")
                
            case 10:
                
                path = "advancedevents/diaries"
                parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future"]
                self.title = NSLocalizedString("Diary",  comment: "")
                
            case 2:
                path = "advancedevents/manage"
                //parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
                self.title = NSLocalizedString("My Events",  comment: "")
                if Locationdic != nil
                {
                    let defaults = UserDefaults.standard
                    
                    if let loc = defaults.string(forKey: "Location")
                    {
                        
                        parameters = ["page":"\(pageNumber)", "limit": "\(limit)","restapilocation": loc]
                    }
                    else
                    {
                        
                        
                        parameters = ["page":"\(pageNumber)", "limit": "\(limit)","restapilocation": defaultlocation]
                    }
                    
                    
                    
                }
                else
                {
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
                }
                
                
            case 3:
                
                path = "advancedevents"
                self.title = NSLocalizedString("Advanced Events",  comment: "")
                //parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future"]
                if Locationdic != nil
                {
                    let defaults = UserDefaults.standard
                    
                    if let loc = defaults.string(forKey: "Location")
                    {
                        
                        parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future","restapilocation": loc]
                    }
                    else
                    {
                        
                        
                        parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future","restapilocation":defaultlocation]
                    }
                    
                    
                    
                }
                else
                {
                    parameters = ["page":"\(pageNumber)", "limit": "\(limit)","filter":"future"]
                }
            default:
                
                print("Error")
            }
            
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
                
            }
            //  path = "advancedevents/manage"
            
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                   // self.tblAutoSearchSuggestions.isHidden = true
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    
                    if msg
                    {
                        
                        if self.pageNumber == 1
                        {
                            self.advancedeventResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if response["response"] != nil
                            {
                                if let blog = response["response"] as? NSArray
                                {
                                    self.advancedeventResponse = self.advancedeventResponse + (blog as [AnyObject])
                                }
                            }
                            
                            if response["getTotalItemCount"] != nil
                            {
                                self.totalItems = response["getTotalItemCount"] as! Int
                            }
                        }
                        
                        
                        self.isPageRefresing = false
                        if self.tblAutoSearchSuggestions.isHidden == true
                        {
                            if self.eventBrowseType == 10
                            {
                                self.DiaryTableView.reloadData()
                                self.DiaryTableView.isHidden = false
                                self.advancedeventTableView.isHidden = true
                            }
                            else
                            {
                                self.advancedeventTableView.reloadData()
                                self.advancedeventTableView.isHidden = false
                                self.DiaryTableView.isHidden = true
                            }
                        }
              
                        
                        
                        if self.advancedeventResponse.count == 0
                        {
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any entries. Get started by writing a new entry.",  comment: "") , alignment: .center, textColor: textColorLight)
                            self.info.center = self.view.center
                            self.info.layer.cornerRadius = 25.0
                            self.info.layer.masksToBounds = true
                            self.info.backgroundColor = UIColor.black
                            self.info.tag = 1000
                            self.info.isHidden = true
                            self.view.addSubview(self.info)
                            showToast(message: NSLocalizedString("You do not have any entries. Get started by writing a new entry.",  comment: ""), controller: self)
                            self.searchBar.resignFirstResponder()
                        }
                        
                    }
                    else
                    {
                        // Handle Server Error
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            self.searchBar.resignFirstResponder()
                        }
                        
                    }
                    
                })
            }
        }
        else
        {
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
             searchBar.resignFirstResponder()
        }
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
}
