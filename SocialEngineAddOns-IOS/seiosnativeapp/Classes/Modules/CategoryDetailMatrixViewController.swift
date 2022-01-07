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
//  CategoryDetailMatrixViewController.swift
//  seiosnativeapp
//

import UIKit
import NVActivityIndicatorView

class CategoryDetailMatrixViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate
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
    var subCategoryArr = [AnyObject]()
    var subSubCategoryArr = [AnyObject]()
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
    var listingContentName : String!
   // var imageCache1 = [String:UIImage]()
    var dynamicHeight:CGFloat = 160              // Dynamic Height fort for Cell
    var viewType : Int!
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
        
        
        // Set tableview to show listings
        listingTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING+ButtonHeight+5,width: view.bounds.width, height: view.bounds.height - tabBarHeight - (TOPPADING + ButtonHeight + 5)), style: .grouped)// UITableView(frame: CGRect(x: 0, y: 0,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        listingTableView.register(ClassifiedTableViewCell.self, forCellReuseIdentifier: "MLTMatrixTypeCell")
      //  listingTableView.rowHeight = 160
        listingTableView.dataSource = self
        listingTableView.delegate = self
        listingTableView.isOpaque = false
        listingTableView.backgroundColor = tableViewBgColor
        listingTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            listingTableView.estimatedRowHeight = 0
            listingTableView.estimatedSectionHeaderHeight = 0
            listingTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(listingTableView)
        
        // Set pull to referseh for listingtableview
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(CategoryDetailMatrixViewController.refresh), for: UIControl.Event.valueChanged)
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
        let tapView = UITapGestureRecognizer(target: self, action: #selector(CategoryDetailMatrixViewController.goBack))
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
    
    // MARK: - Cover Image Selection
    @objc func showListing(_ sender:UIButton)
    {
        
        var listingInfo:NSDictionary!
        
        listingInfo = listingsResponse[sender.tag] as! NSDictionary
        
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
            let listingid = listingInfo["listingtype_id"] as! Int
            var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingid]!
            viewType = tempBrowseViewTypeDic["viewType"]!
        }
        if listingInfo["allow_to_view"] != nil && listingInfo["allow_to_view"] as! Int > 0 {
            
        switch viewType{
            
        case 2:
            
            let presentedVC = MLTClassifiedSimpleTypeViewController()
            presentedVC.listingId = "\(listingInfo["listing_id"]!)"
            presentedVC.listingTypeId = listingTypeId
            presentedVC.subjectType = "sitereview_listing"
            navigationController?.pushViewController(presentedVC, animated: true)
            
            break
            
        case 3:
            
            let presentedVC = MLTClassifiedAdvancedTypeViewController()
            presentedVC.listingId = "\(listingInfo["listing_id"]!)"
            presentedVC.listingTypeId = listingTypeId
            presentedVC.subjectType = "sitereview_listing"
            navigationController?.pushViewController(presentedVC, animated: true)
       
            break
            
        default:
            
            let presentedVC = MLTBlogTypeViewController()
            presentedVC.listingId = "\(listingInfo["listing_id"]!)"
            presentedVC.listingTypeId = listingTypeId
            presentedVC.subjectType = "sitereview_listing"
            navigationController?.pushViewController(presentedVC, animated: true)
   
           
            break
        }
        }
        else{
            showToast(message: "You do not have permission to view this private page.", controller: self)
        }
        
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
            
        }else{
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
        return 160
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
            return Int(ceil(Float(listingsResponse.count)/2))
        }
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MLTMatrixTypeCell", for: indexPath) as! ClassifiedTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        var index:Int!
        index = (indexPath as NSIndexPath).row * 2
        
        if listingsResponse.count > index {
            
            cell.contentSelection.isHidden = false
            cell.classifiedImageView.isHidden = false
            cell.classifiedName.isHidden = false
            cell.classifiedImageView.image = nil
            
            if let photoInfo = listingsResponse[index] as? NSDictionary {
                // LHS
                if let url = URL(string: photoInfo["image"] as! NSString as String){
                    cell.classifiedImageView.kf.indicatorType = .activity
                    (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.classifiedImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                
                let name = photoInfo["title"] as? String
                let tempString = name! as NSString
                var value : String
                
                if tempString.length > 22{
                    
                    value = tempString.substring(to: 19)
                    value += NSLocalizedString("...",  comment: "")
                }else{
                    value = "\(tempString)"
                }
                
                cell.classifiedName.text = value
                
                let location = photoInfo["location"] as? String
                if location != "" && location != nil
                {
                    cell.classifiedName.frame.origin.y = 100
                    cell.lblLoc.frame.origin.y = 125
                    cell.lblLoc.isHidden = false
                    
                    cell.lblLoc.text = locationIcon + "  " + location!
                }
                else
                {
                    cell.classifiedName.frame.origin.y = 125
                    cell.lblLoc.isHidden = true
                }
                
                cell.contentSelection.tag = index
                listingContentName = photoInfo["title"] as! String
                
                if photoInfo["allow_to_view"] != nil && photoInfo["allow_to_view"] as! Int > 0 {
                    cell.contentSelection.addTarget(self, action: #selector(CategoryDetailMatrixViewController.showListing(_:)), for: .touchUpInside)
                }
                
                cell.menu.isHidden = true
                cell.menu1.isHidden = true
                
                
                if photoInfo.object(forKey: "closed") != nil && (photoInfo["closed"] as! Int == 1){
                    cell.closeIconView.frame = CGRect(x: cell.classifiedImageView.bounds.width/2 - cell.classifiedImageView.bounds.width/4 , y: cell.classifiedImageView.bounds.height/2 - cell.classifiedImageView.bounds.height/4, width: cell.classifiedImageView.bounds.width/2, height: cell.classifiedImageView.bounds.height/2)
                    cell.closeIconView.isHidden = false
                    cell.closeIconView.text = "\(closedIcon)"
                    cell.closeIconView.font = UIFont(name: "FontAwesome", size: cell.classifiedImageView.bounds.width/4)
                }
                else{
                    cell.closeIconView.isHidden = true
                }
            }
            
        }else{
            cell.contentSelection.isHidden = true
            cell.classifiedImageView.isHidden = true
            cell.classifiedName.isHidden = true
            cell.contentSelection1.isHidden = true
            cell.classifiedImageView1.isHidden = true
            cell.classifiedName1.isHidden = true
        }
        
        
        if listingsResponse.count > (index + 1){
            cell.contentSelection1.isHidden = false
            cell.classifiedImageView1.isHidden = false
            cell.classifiedName1.isHidden = false
            
            
            cell.classifiedImageView1.image = nil
            if let photoInfo = listingsResponse[index + 1] as? NSDictionary {
                
                if let url = URL(string: photoInfo["image"] as! NSString as String){

                    cell.classifiedImageView1.kf.indicatorType = .activity
                    (cell.classifiedImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.classifiedImageView1.kf.setImage(with: url, placeholder: UIImage(named: "defaultcat.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                
                let name1 = photoInfo["title"] as? String
                let tempString1 = name1! as NSString
                var value1 : String
                
                if tempString1.length > 22{
                    value1 = tempString1.substring(to: 19)
                    value1 += NSLocalizedString("...",  comment: "")
                }else{
                    value1 = "\(tempString1)"
                }
                
                cell.classifiedName1.text = value1
                
                let location = photoInfo["location"] as? String
                if location != "" && location != nil
                {
                    cell.classifiedName1.frame.origin.y = 100
                    cell.lblLoc1.frame.origin.y = 125
                    cell.lblLoc1.isHidden = false
                    
                    cell.lblLoc1.text = locationIcon + "  " + location!
                }
                else
                {
                    cell.classifiedName1.frame.origin.y = 125
                    cell.lblLoc1.isHidden = true
                }
                
                listingContentName = photoInfo["title"] as! String
                cell.contentSelection1.tag = index + 1
                
                if photoInfo["allow_to_view"] != nil && photoInfo["allow_to_view"] as! Int > 0 {
                    cell.contentSelection1.addTarget(self, action: #selector(CategoryDetailMatrixViewController.showListing(_:)), for: .touchUpInside)
                }
                
                cell.menu.isHidden = true
                cell.menu1.isHidden = true
                
                if photoInfo.object(forKey: "closed") != nil && (photoInfo["closed"] as! Int == 1){
                    cell.closeIconView1.frame = CGRect(x: cell.classifiedImageView1.bounds.width/2 - cell.classifiedImageView1.bounds.width/4 , y: cell.classifiedImageView1.bounds.height/2 - cell.classifiedImageView1.bounds.height/4, width: cell.classifiedImageView1.bounds.width/2, height: cell.classifiedImageView1.bounds.height/2)
                    cell.closeIconView1.isHidden = false
                    cell.closeIconView1.text = "\(closedIcon)"
                    cell.closeIconView1.font = UIFont(name: "FontAwesome", size: cell.classifiedImageView1.bounds.width/4)
                }
                else{
                    cell.closeIconView1.isHidden = true
                }
            }
        }else{
            cell.contentSelection1.isHidden = true
            cell.classifiedImageView1.isHidden = true
            cell.classifiedName1.isHidden = true
        }
        
        return cell
    }
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
   
    
    //MARK: Category filter
    @objc func showRootCategoryOptions(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        let alertController = UIActionSheet(title:"Choose sub category", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        alertController.tag = 0
        for menu in subCategoryArr
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
    
    @objc func showChildCategoryOptions(_ sender: UIButton)
    {
        // Generate Feed Filter Options Gutter Menu from Server as! Alert Popover
        
        
        let alertController = UIActionSheet(title:"Choose Subsub category", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil)
        alertController.tag = 1
        for menu in subSubCategoryArr
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
                
                let subcat = subCategoryArr[buttonIndex-1] as! NSDictionary
                subcatid = subcat["sub_cat_id"] as! Int
                rootCategoryBar.setTitle(subcat["sub_cat_name"] as? String, for: UIControl.State())
                subcategory = subcat["sub_cat_name"] as? String
                subsubcategory = ""
                subsubcatid = 0
                self.showSpinner = true
                browseEntries()
                
            }
            
        }
        else
        {
            if buttonIndex != 0
            {
                let subcat = subSubCategoryArr[buttonIndex-1] as! NSDictionary
                subsubcatid = subcat["tree_sub_cat_id"] as! Int
                childCategoryBar.setTitle(subcat["tree_sub_cat_name"] as? String, for: UIControl.State())
                subsubcategory = subcat["tree_sub_cat_name"] as? String
                self.showSpinner = true
                browseEntries()
                
            }
            
        }
        
    }
    
    // MARK: - Server Connection For listing Updation
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
                    //self.listingTableView.reloadData()
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
             //   spinner.center = view.center
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
            //    activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            path = "listings/categories"
            
            
            if subcatid != nil && subsubcatid != nil
            {
                parameters = ["page":"\(pageNumber)","limit": "\(limit)","showListings":"1","category_id":String(subjectId), "subCategory_id":String(subcatid), "subsubcategory_id": String(subsubcatid), "listingtype_id": String(listingTypeId),"restapilocation":defaultlocation]
            }
            else if subcatid != nil
            {
                parameters = ["page":"\(pageNumber)","limit": "\(limit)","showListings":"1","category_id":String(subjectId),"subCategory_id": String(subcatid), "listingtype_id": String(listingTypeId),"restapilocation":defaultlocation]
                
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
                    self.listingTableView.tableFooterView?.isHidden = true
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    if msg
                    {
                        
                        if self.pageNumber == 1
                        {
                            self.listingsResponse.removeAll(keepingCapacity: false)
                            self.subCategoryArr.removeAll(keepingCapacity: false)
                            self.subSubCategoryArr.removeAll(keepingCapacity: false)
                            

                        }
                        
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }

                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if response["listings"] != nil
                            {

                                if let blog = response["listings"]as? NSArray
                                {
                                    self.listingsResponse = self.listingsResponse + (blog as [AnyObject])
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
                                
                                if let blog = response["subCategories"]as? NSArray
                                {
                                    if blog.count > 0
                                    {
                                        self.subCategoryArr = blog as [AnyObject]
                                        if self.subcategory == ""
                                        {
                                            self.rootCategoryBar = createButton(CGRect(x: 0,y: TOPPADING , width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString("Choose sub category",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )

                                        }
                                        else
                                        {
                                            self.rootCategoryBar = createButton(CGRect(x: 0,y: TOPPADING , width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString("\(self.subcategory!)",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )

                                        }
                                        
                                        
                                        self.rootCategoryBar.isEnabled = true
                                        self.rootCategoryBar.backgroundColor = lightBgColor
                                        self.rootCategoryBar.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.rootCategoryBar.addTarget(self, action: #selector(CategoryDetailMatrixViewController.showRootCategoryOptions(_:)), for: .touchUpInside)
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
//                                        self.listingTableView.frame = CGRect(x: 0, y: ButtonHeight, width: self.view.bounds.width, height: self.view.bounds.height - ButtonHeight)
                                        
                                                                                
                                    }
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                        
                        if let response1 = succeeded["body"] as? NSDictionary
                        {
                            if response1["subsubCategories"] != nil
                            {
                                
                                if let subSubCategories = response1["subsubCategories"]as? NSArray
                                {
                                    if subSubCategories.count > 0
                                    {
                                        self.subSubCategoryArr = self.subSubCategoryArr + (subSubCategories as [AnyObject])
                                        
                                        if self.subsubcategory == ""
                                        {
                                            self.childCategoryBar = createButton(CGRect(x: 0,y: ButtonHeight + TOPPADING, width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString("Choose sub sub category",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                        }
                                        else
                                        {
                                            self.childCategoryBar = createButton(CGRect(x: 0,y: ButtonHeight + TOPPADING, width: self.view.bounds.width, height: ButtonHeight),title: NSLocalizedString("\(self.subsubcategory)",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )

                                        }

                                        
                                        
                                        self.childCategoryBar.isEnabled = true
                                        self.childCategoryBar.backgroundColor = lightBgColor
                                        self.childCategoryBar.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                        self.childCategoryBar.addTarget(self, action: #selector(CategoryDetailMatrixViewController.showChildCategoryOptions(_:)), for: .touchUpInside)
                                        self.mainView.addSubview(self.childCategoryBar)
                                        
                                        // Filter Icon on Left site
                                        let filterIcon1 = createLabel(CGRect(x: self.childCategoryBar.bounds.width - self.childCategoryBar.bounds.height, y: 0 ,width: self.childCategoryBar.bounds.height ,height: self.childCategoryBar.bounds.height), text: "\(searchFilterIcon)", alignment: .center, textColor: textColorMedium)
                                        filterIcon1.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                                        self.childCategoryBar.addSubview(filterIcon1)
                                        self.listingTableView.frame = CGRect(x: 0, y: 2*ButtonHeight  + TOPPADING, width: self.view.bounds.width, height: self.view.bounds.height-(2*ButtonHeight + TOPPADING + tabBarHeight))
//                                        self.listingTableView.frame = CGRect(x: 0, y: 2*ButtonHeight, width: self.view.bounds.width, height: self.view.bounds.height - (2*ButtonHeight))
                                        
                                    }
                                }
                            }
                            
                        }
                        
                        self.isPageRefresing = false
                        
                        // Reload listing table
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
                            self.refreshButton.addTarget(self, action: #selector(CategoryDetailMatrixViewController.browseEntries), for: UIControl.Event.touchUpInside)
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
                            listingTableView.tableFooterView?.isHidden = false
                          //  if searchDic.count == 0{
                                browseEntries()
                           // }
                        }
                    }
                    else
                    {
                        listingTableView.tableFooterView?.isHidden = true
                }
                    
             //   }
                
            }
            
        }
        
    }
    
}

