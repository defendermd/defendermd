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
//  CategoryDetailListViewController.swift
//  seiosnativeapp
//

import UIKit
import NVActivityIndicatorView

class CategoryDetailListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate
{
    var subjectId:Int!
    var subjectType:String!
    var subcatid:Int!
    var subsubcatid:Int!
    var totalItemCount:Int!
    var categoryTitle: String!
    let mainView = UIView()
    var listingTableView:UITableView!
    var refresher:UIRefreshControl!
    var refreshButton : UIButton!
    var contentIcon : UILabel!
    var rootCategoryBar: UIButton!
    var childCategoryBar: UIButton!
    
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var updateScrollFlag = true
    var listingsResponse = [AnyObject]()
    var Subcategoryarr = [AnyObject]()
    var SubSubcategoryarr = [AnyObject]()
    var showSpinner = true
    var isPageRefresing = false
    var info:UILabel!
    
    var contentGutterMenu: NSArray = []
    var deleteContent : Bool!
    var contentTitle : String!
    var contentDescription : String!
    
    var shareUrl : String!
    var shareParam : NSDictionary!
    
    var subcategory: String!
    var subsubcategory: String!
   // var imageCache = [String:UIImage]()
    var listingTypeId :  Int!
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        subcategory = ""
        subsubcategory = ""
        
        view.backgroundColor = bgColor
        mainView.frame = view.frame
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        globFilterValue = ""
        openMenu = false
        updateAfterAlert = true
        listingUpdate = true
        
        let subViews = mainView.subviews
        for subview in subViews
        {
            subview.removeFromSuperview()
        }
        
        
        // Set tableview to show events
        listingTableView = UITableView(frame: CGRect(x: 0, y: 0,width: view.bounds.width, height: view.bounds.height - tabBarHeight), style: .grouped)
        listingTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "MLTGridTypeCell")
        listingTableView.rowHeight = 250
        listingTableView.dataSource = self
        listingTableView.delegate = self
        listingTableView.isOpaque = false
        listingTableView.backgroundColor = tableViewBgColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            listingTableView.estimatedSectionHeaderHeight = 0
        }
        mainView.addSubview(listingTableView)
        
        // Set pull to referseh for eventtableview
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(CategoryDetailListViewController.refresh), for: UIControl.Event.valueChanged)
        listingTableView.addSubview(refresher)
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        pageNumber = 1
        updateScrollFlag = false
   
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        listingTableView.tableFooterView = footerView
        listingTableView.tableFooterView?.isHidden = true
        
        browseEntries()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        self.title = NSLocalizedString("\(self.title!)",  comment: "")
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(CategoryDetailListViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        listingTableView.tableFooterView?.isHidden = true
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }
    
    
    // MARK:Back Action
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)

    }
    
    // Stop Timer
    @objc func stopTimer()
    {
        stop()
    }
    
    
    // MARK:Pull to refreash
    // MARK: -  Pull to Request Action
    @objc func refresh()
    {
        
        if Reachabable.isConnectedToNetwork()
        {
            searchDic.removeAll(keepingCapacity: false)
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            browseEntries()
        }
        else
        {
            // No Internet Connection Message
            refresher.endRefreshing()
           showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Table Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (limit*pageNumber < totalItems)
        {
            return 0
        }
        else
        {
            return 0.00001
        }
    }
    
    // Set Table Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.00001
    }
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return Int(ceil(Float(listingsResponse.count)/2))
        }
        else
        {
            return listingsResponse.count
        }
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        
        let cell = listingTableView.dequeueReusableCell(withIdentifier: "MLTGridTypeCell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.lineView.isHidden = false
        
        var listingInfo:NSDictionary
        listingInfo = listingsResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        
        cell.imgUser.frame = CGRect(x: 5, y: 7, width: 60, height: 60)
        
        
        // Set Blog Title
        cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10, width: cell.bounds.width - (cell.imgUser.bounds.width + 15), height: 20)
        cell.labTitle.text = listingInfo["title"] as? String
        cell.labTitle.numberOfLines = 2
        cell.labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
        cell.labTitle.sizeToFit()
        
        if let ownerName = listingInfo["owner_title"] as? String {
            if let postedDate = listingInfo["creation_date"] as? String{
                var tempInfo = ""
                let date = dateDifferenceWithEventTime(postedDate)
                var DateC = date.components(separatedBy: ", ")
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
                
                cell.labMessage.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5,width: (UIScreen.main.bounds.width - 75) , height: 20)
                cell.labMessage.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                
                var labMsg = ""
                
                labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), ownerName, tempInfo)
                cell.postCount.isHidden = true
                
                cell.labMessage.setText(labMsg, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in

                    return mutableAttributedString
                })
                
                
            }
        }
        
        
        cell.labMessage.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.labMessage.sizeToFit()
        cell.labMessage.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        
        if listingInfo.object(forKey: "closed") != nil && (listingInfo["closed"] as! Int == 1){
            cell.imageview.isHidden = false
            cell.imageview.text = "\(closedIcon)"
        }
        else{
            cell.imageview.isHidden = true
        }
        
        // Set Listing Owner Image
        
        if let url = URL(string: listingInfo["image"] as! String){

            cell.imgUser.kf.indicatorType = .activity
            (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
              
            })
        }
        cell.accessoryView = nil
        cell.lineView.frame = CGRect(x: 0, y: cell.bounds.height, width: (UIScreen.main.bounds).width, height: 2)
        cell.lineView.isHidden = false
        return cell
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        tableView.deselectRow(at: indexPath, animated: true)
        var listingInfo:NSDictionary
        listingInfo = listingsResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        var viewType : Int = 0
        
        if self.tabBarController?.selectedIndex == 1 || self.tabBarController?.selectedIndex == 2 || self.tabBarController?.selectedIndex == 3{
            if self.tabBarController?.selectedIndex == 1 {
                listingTypeId = globalListingTypeId
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }
                
                
            }
            if self.tabBarController?.selectedIndex == 2 {
                listingTypeId = globalListingTypeId1
                
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType1")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType1") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }
                
            }
            if self.tabBarController?.selectedIndex == 3 {
                listingTypeId = globalListingTypeId2
                
                
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType2")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType2") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }
                
                
            }
        }
        else
        {
            
            
            var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingInfo["listingtype_id"] as! Int]!
            viewType = tempBrowseViewTypeDic["viewType"]!
        }

        
        
        if(listingInfo["allow_to_view"] as! Int == 1){
            
            switch viewType{
            case 2:
                let presentedVC = MLTClassifiedSimpleTypeViewController()
                
                if (listingInfo["listing_id"] is String){
                    let tempValue = listingInfo["listing_id"] as! String
                    presentedVC.listingId = tempValue
                }else{
                    presentedVC.listingId = "\(listingInfo["listing_id"]!)"
                }
                
                if listingInfo["listingtype_id"] is Int{
                    
                    presentedVC.listingTypeId = listingInfo["listingtype_id"] as! Int
                    presentedVC.subjectType = "sitereview_listing"
                }
                
                navigationController?.pushViewController(presentedVC, animated: true)
                break
                
            case 3:
                let presentedVC = MLTClassifiedAdvancedTypeViewController()
                if (listingInfo["listing_id"] is String){
                    let tempValue = listingInfo["listing_id"] as! String
                    
                    presentedVC.listingId = tempValue
                    
                }else{
                    presentedVC.listingId = "\(listingInfo["listing_id"]!)"
                    
                }
                
                if listingInfo["listingtype_id"] is Int{
                    presentedVC.listingTypeId = listingInfo["listingtype_id"] as! Int
                    presentedVC.subjectType = "sitereview_listing"
                }
                
                navigationController?.pushViewController(presentedVC, animated: true)
                break
                
            default:
                let presentedVC = MLTBlogTypeViewController()
                if (listingInfo["listing_id"] is String){
                    let tempValue = listingInfo["listing_id"] as! String
                    
                    presentedVC.listingId = tempValue
                    
                }else{
                    presentedVC.listingId = "\(listingInfo["listing_id"]!)"
                }
                
                if listingInfo["listingtype_id"] is Int{
                    
                    let tempListingTypeId = listingInfo["listingtype_id"] as! Int
                    presentedVC.listingTypeId = listingInfo["listingtype_id"] as! Int
                    presentedVC.subjectType = "sitereview_listing"
                    presentedVC.listingTypeId = tempListingTypeId
                }
                
                navigationController?.pushViewController(presentedVC, animated: true)
                break
            }
            
            
        }else{
            showToast(message: NSLocalizedString("You do not have permission to view this private page.",  comment: ""), controller: self)
        }
    }
    
    //MARK: Category filter
    @objc func showRootCategoryOptions(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        let alertController = UIActionSheet(title:"Choose sub category", delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), destructiveButtonTitle: nil)
        alertController.tag = 0
        for menu in Subcategoryarr
        {
            
            if let menuItem = menu as? NSDictionary
            {
                
                let titleString = menuItem["sub_cat_name"] as! String
                alertController.addButton(withTitle: titleString)
            }
        }
        
        alertController.show(in: self.view)
        searchDic.removeAll(keepingCapacity: false)
        
        
    }
    
    @objc func showChildCategoryOptions1(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        
        
        let alertController = UIActionSheet(title:"Choose Subsub category", delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), destructiveButtonTitle: nil)
        alertController.tag = 1
        for menu in SubSubcategoryarr
        {
            if let menuItem = menu as? NSDictionary
            {
                
                let titleString = menuItem["tree_sub_cat_name"] as! String
                
                alertController.addButton(withTitle: titleString)
            }
        }
        
        alertController.show(in: self.view)
        searchDic.removeAll(keepingCapacity: false)
        
        
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int)
    {
        if actionSheet.tag==0
        {
            
            if buttonIndex != 0
            {
                
                let subcat = Subcategoryarr[buttonIndex-1] as! NSDictionary
                subcatid = subcat["sub_cat_id"] as! Int
                rootCategoryBar.setTitle(subcat["sub_cat_name"] as? String, for: UIControl.State())
                subcategory = subcat["sub_cat_name"] as? String
                subsubcategory = ""
                self.showSpinner = true
                browseEntries()
                
            }
            
        }
        else
        {
            if buttonIndex != 0
            {
                let subcat = SubSubcategoryarr[buttonIndex-1] as! NSDictionary
                subsubcatid = subcat["tree_sub_cat_id"] as! Int
                childCategoryBar.setTitle(subcat["tree_sub_cat_name"] as? String, for: UIControl.State())
                subsubcategory = subcat["tree_sub_cat_name"] as? String
                self.showSpinner = true
                browseEntries()
                
            }
            
        }
        
    }
    
    @objc func browseEntries()
    {
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            //info.removeFromSuperview()
            let subViews = mainView.subviews
            for ob in subViews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            if (self.pageNumber == 1)
            {
                //self.listingsResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true
                {
                    removeAlert()
                    self.listingTableView.reloadData()
                }
                else
                {
                    updateAfterAlert = true
                }
            }
            
            refreshButton.isHidden = true
            contentIcon.isHidden = true
            
            if (showSpinner)
            {
              //  spinner.center = view.center
                if updateScrollFlag == false
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                
                if (self.pageNumber == 1)
                {
                    activityIndicatorView.center = mainView.center
                    updateScrollFlag = false
                }
                
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
             //   activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            var path = ""
            var parameters = [String:String]()
            path = "listings/categories"
            
            if subcatid != nil && subsubcatid != nil
            {
                parameters = ["page":"\(pageNumber)","limit": "\(limit)","showListings":"1", "category_id":String(subjectId), "subCategory_id": String(subcatid), "subsubcategory_id":String(subsubcatid), "listingtype_id": String(listingTypeId),"restapilocation":defaultlocation]
            }
            else if subcatid != nil
            {
                parameters = ["page":"\(pageNumber)","limit": "\(limit)","showListings":"1","category_id":String(subjectId), "subCategory_id":String(subcatid), "listingtype_id": String(listingTypeId),"restapilocation":defaultlocation]
                
            }
            else
            {
                parameters = ["page":"\(pageNumber)","limit": "\(limit)","showListings":"1","category_id":String(subjectId), "listingtype_id": String(listingTypeId),"restapilocation":defaultlocation]
            }
            
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner
                    {
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                     self.listingTableView.tableFooterView?.isHidden = true
                    if msg
                    {
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                   
                    self.updateScrollFlag = true
                    
                    let subviews : NSArray = self.mainView.subviews as NSArray
                    for filterview : Any in subviews
                    {
                        if filterview is UIButton{
                            if (filterview as AnyObject).tag == 240
                            {
                                self.childCategoryBar.removeFromSuperview()
                                self.listingTableView.frame = CGRect(x: 0, y: ButtonHeight, width: self.view.bounds.width,height: self.view.bounds.height-(ButtonHeight + tabBarHeight))
                            }
                            
                        }
                        
                    }
                    
                    if msg
                    {
                        
                        if self.pageNumber == 1
                        {
                            self.listingsResponse.removeAll(keepingCapacity: false)
                            self.Subcategoryarr.removeAll(keepingCapacity: false)
                            self.SubSubcategoryarr.removeAll(keepingCapacity: false)
                            
                        }
                        
                        if self.pageNumber == 1
                        {
                            self.listingsResponse.removeAll(keepingCapacity: false)
                            self.Subcategoryarr.removeAll(keepingCapacity: false)
                            self.SubSubcategoryarr.removeAll(keepingCapacity: false)
                            
                        }

                        
                        if succeeded["message"] != nil
                        {

                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if response["listings"] != nil
                            {
                                if let listings = response["listings"]as? NSArray
                                {
                                    self.listingsResponse = self.listingsResponse + (listings as [AnyObject])

                                }
                            }
                            if response["totalListingCount"] != nil{
                                self.totalItems = response["totalListingCount"] as! Int
                            }
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if response["subCategories"] != nil
                            {
                                if let subCategories = response["subCategories"]as? NSArray
                                {
                                    if subCategories.count > 0
                                    {

                                        self.Subcategoryarr = self.Subcategoryarr + (subCategories as [AnyObject])
                                        if self.subcategory == ""
                                        {
                                            self.rootCategoryBar = createButton(CGRect(x: 0,y: TOPPADING , width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString("Choose sub category",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )

                                        }
                                        else
                                        {
                                            self.rootCategoryBar = createButton(CGRect(x: 0,y: TOPPADING , width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString(self.subcategory,  comment: "") , border: false, bgColor: false,textColor: textColorMedium )

                                        }
                                        
                                        self.rootCategoryBar.isEnabled = true
                                        self.rootCategoryBar.backgroundColor = lightBgColor
                                        self.rootCategoryBar.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.rootCategoryBar.addTarget(self, action: #selector(CategoryDetailListViewController.showRootCategoryOptions(_:)), for: .touchUpInside)
                                        self.mainView.addSubview(self.rootCategoryBar)
                                        
                                        // Filter Icon on Left site
                                        let filterIcon = createLabel(CGRect(x: self.rootCategoryBar.bounds.width - self.rootCategoryBar.bounds.height, y: 0 ,width: self.rootCategoryBar.bounds.height ,height: self.rootCategoryBar.bounds.height), text: "\(searchFilterIcon)", alignment: .center, textColor: textColorMedium)
                                        filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                                        self.rootCategoryBar.addSubview(filterIcon)
                                        
                                        if self.listingsResponse.count > 0{
                                            self.listingTableView.frame = CGRect(x: 0, y: ButtonHeight + TOPPADING, width: self.view.bounds.width,height: self.view.bounds.height-(ButtonHeight + tabBarHeight + TOPPADING))
                                        }
                                        else{
                                            self.listingTableView.frame = CGRect(x: 0,y: 0 , width: self.view.bounds.width,height: self.view.bounds.height-(ButtonHeight + tabBarHeight))
                                            
                                        }

                                    }
                                }
                            }
                        }
                        
                        
                        if let response1 = succeeded["body"] as? NSDictionary
                        {
                            if response1["subsubCategories"] != nil
                            {
                                if let subsubCategories = response1["subsubCategories"]as? NSArray
                                {
                                    if subsubCategories.count > 0
                                    {
                                        self.SubSubcategoryarr = self.SubSubcategoryarr + (subsubCategories as [AnyObject])
                                        
                                        if self.subsubcategory == ""
                                        {
                                            self.childCategoryBar = createButton(CGRect(x: 0,y: ButtonHeight + TOPPADING, width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString("Choose sub sub category",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )

                                        }
                                        else
                                        {

                                            self.childCategoryBar = createButton(CGRect(x: 0,y: ButtonHeight + TOPPADING, width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString(self.subsubcategory,  comment: "") , border: false, bgColor: false,textColor: textColorMedium )

                                        }
                                        
                                        self.childCategoryBar.isEnabled = true
                                        self.childCategoryBar.tag = 240
                                        self.childCategoryBar.backgroundColor = lightBgColor
                                        self.childCategoryBar.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.childCategoryBar.addTarget(self, action: #selector(CategoryDetailListViewController.showChildCategoryOptions1(_:)), for: .touchUpInside)
                                        self.mainView.addSubview(self.childCategoryBar)
                                        
                                        // Filter Icon on Left site
                                        let filterIcon1 = createLabel(CGRect(x: self.childCategoryBar.bounds.width - self.childCategoryBar.bounds.height, y: 0 ,width: self.childCategoryBar.bounds.height ,height: self.childCategoryBar.bounds.height), text: "\(searchFilterIcon)", alignment: .center, textColor: textColorMedium)
                                        filterIcon1.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                                        self.childCategoryBar.addSubview(filterIcon1)
                                        
                                       self.listingTableView.frame = CGRect(x: 0, y: 2*ButtonHeight  + TOPPADING, width: self.view.bounds.width, height: self.view.bounds.height-(2*ButtonHeight + TOPPADING + tabBarHeight))
                                        
                                    }
                                }
                            }
                        }
                        
                        self.isPageRefresing = false
                        
                        // Reload listings Table
                        self.listingTableView.reloadData()
                        
                        
                        if self.listingsResponse.count == 0
                        {
                            
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(listingDefaultIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.mainView.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any listings matching this criteria.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.numberOfLines = 0
                            self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.mainView.addSubview(self.info)
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(CategoryDetailListViewController.browseEntries), for: UIControl.Event.touchUpInside)
                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.mainView.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            

                        }
                    }
                    else
                    {
                        // Handle Server Error
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
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    // Handle Scroll For Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        
        
//        var index:Int!
//        index = listingsResponse.count
//        
//        let someFloat: CGFloat = CGFloat(index)
//        listingTableView.contentSize.height = 75 * someFloat
        
        
//        if updateScrollFlag{
//            // Check for Page Number for Browse Classified
//            if listingTableView.contentOffset.y >= listingTableView.contentSize.height - listingTableView.bounds.size.height{
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
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                // Check for Page Number for Browse Classified
//                if listingTableView.contentOffset.y >= listingTableView.contentSize.height - listingTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            listingTableView.tableFooterView?.isHidden = false
                         //   if searchDic.count == 0{
                                browseEntries()
                           // }
                        }
                    }
                    else
                    {
                        listingTableView.tableFooterView?.isHidden = true
                }
                    
              //  }
                
            }
            
        }
        
    }
}
