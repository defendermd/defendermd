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
//  CategoryBrowseViewController.swift
//  seiosnativeapp
//

import UIKit

class CategoryBrowseViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {
    
    let mainView = UIView()
    var showOnlyMyContent:Bool! = false
    
    let scrollView = UIScrollView()
    var feedFilter: UIButton!
    var CategoryTableView:UITableView!
    var refresher:UIRefreshControl!
    var showSpinner = true
    var isPageRefresing = false
    
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var categoriesResponse = [AnyObject]()
    var refreshButton : UIButton!
    var contentIcon : UILabel!
    var updateScrollFlag = true
    var user_id : Int!
    var fromTab = false
    var countListTitle : String!
    var subjectType:String!
   // var imageCache = [String:UIImage]()
    
    var listingOption:UIButton!
    var listingBrowseType:Int!
    var browseOrMyListings = true
    var listingName:String!
    var listingTypeId:Int!
    var browseType:Int!
    var dashboardMenuDic = NSDictionary()
    var viewType : Int = 0
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if fromTab == false {
            if (self.tabBarController?.selectedIndex == 1 ) ||  (self.tabBarController?.selectedIndex == 2) || ( self.tabBarController?.selectedIndex == 3 ) {
                setDynamicTabValue()
            }
            self.navigationItem.hidesBackButton = true
            
        }
        
        view.backgroundColor = bgColor
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        subjectType = ""
        listingUpdate = true
        
        globFilterValue = ""
        openMenu = false
        updateAfterAlert = true
        listingUpdate = true
        
        if showOnlyMyContent == false
        {
            self.navigationItem.setHidesBackButton(true, animated: false)
            createScrollableListingMenu()
        }
        
        
        
        // Create a Feed Filter to perform Feed Filtering
        let filter = createButton(CGRect(x: PADING, y: TOPPADING + contentPADING + ButtonHeight, width: ButtonHeight - PADING, height: 0), title: fiterIcon, border: true,bgColor: false, textColor: textColorDark)
        filter.addTarget(self, action: Selector(("filterSerach")), for: .touchUpInside)

        filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        mainView.addSubview(filter)
        filter.isHidden = true
        

        
        if logoutUser == true || showOnlyMyContent == true
        {
            filter.frame.origin.y = TOPPADING
            self.title = NSLocalizedString("\(countListTitle)",  comment: "")

            if countListTitle == nil{
                self.title = NSLocalizedString("Categories",  comment: "")

            }
            
        }
        
        contentIcon = createLabel(CGRect(x: 0, y: 0, width: 0, height: 0), text: "", alignment: .center, textColor: textColorMedium )

        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0, y: 0, width: 0, height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        // Initialize Classified Table
        CategoryTableView = UITableView(frame: CGRect(x: 0, y: ButtonHeight+TOPPADING, width: view.bounds.width, height: view.bounds.height-(ButtonHeight+TOPPADING) - tabBarHeight), style: .grouped)
        CategoryTableView.register(CategoryBrowseTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
        CategoryTableView.dataSource = self
        CategoryTableView.delegate = self
        CategoryTableView.estimatedRowHeight = 110.0
        CategoryTableView.rowHeight = UITableView.automaticDimension
        CategoryTableView.backgroundColor = UIColor.white
        CategoryTableView.separatorColor = UIColor.clear
        CategoryTableView.isHidden = true
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            CategoryTableView.estimatedRowHeight = 0
            CategoryTableView.estimatedSectionHeaderHeight = 0
            CategoryTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(CategoryTableView)
        
        self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30, y: self.view.bounds.height/2-80,width: 60, height: 60), text: NSLocalizedString("\(listingDefaultIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
        self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
        self.contentIcon.isHidden = true
        self.mainView.addSubview(self.contentIcon)
        
        self.info = createLabel(CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.8, height: 60), text: NSLocalizedString("You do not have any listings matching this criteria.",  comment: "") , alignment: .center, textColor: textColorMedium)
        self.info.numberOfLines = 0
        self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.info.center = self.view.center
        self.info.backgroundColor = bgColor
        self.info.tag = 1000
        self.info.isHidden = true
        self.mainView.addSubview(self.info)
        
        self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
        self.refreshButton.backgroundColor = bgColor
        self.refreshButton.layer.borderColor = navColor.cgColor
        self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        self.refreshButton.addTarget(self, action: #selector(CategoryBrowseViewController.browseEntries), for: UIControl.Event.touchUpInside)
        self.refreshButton.layer.cornerRadius = 5.0
        self.refreshButton.layer.masksToBounds = true
        self.mainView.addSubview(self.refreshButton)
        self.refreshButton.isHidden = true
        scrollView.isUserInteractionEnabled = false
  
        browseEntries()
    }
    
    func setDynamicTabValue(){
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "showMyListingContent") != nil {
            if let name = defaults.object(forKey: "showMyListingContent")
            {
                if  UserDefaults.standard.object(forKey: "showMyListingContent") != nil {
                    
                    showOnlyMyContent = name as! Bool
                    
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingName")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingName") != nil {
                        
                        listingName = name as! String
                        
                    }
                }
                if let name = UserDefaults.standard.object(forKey: "showlistingId")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingId") != nil {
                        
                        listingTypeId = name as! Int
                        
                    }
                }
                
            }
        }
        if defaults.object(forKey: "showMyListingContent1") != nil {
            if let name = defaults.object(forKey: "showMyListingContent1")
            {
                if  UserDefaults.standard.object(forKey: "showMyListingContent1") != nil {
                    
                    showOnlyMyContent = name as! Bool
                    
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingName1")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingName1") != nil {
                        
                        listingName = name as! String
                        
                    }
                }
                if let name = UserDefaults.standard.object(forKey: "showlistingId1")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingId1") != nil {
                        
                        listingTypeId = name as! Int
                        
                    }
                }
            }
        }
        if defaults.object(forKey: "showMyListingContent2") != nil {
            if let name = defaults.object(forKey: "showMyListingContent2")
            {
                if  UserDefaults.standard.object(forKey: "showMyListingContent2") != nil {
                    
                    showOnlyMyContent = name as! Bool
                    
                }
                
                if let name = UserDefaults.standard.object(forKey: "showlistingName2")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingName2") != nil {
                        
                        listingName = name as! String
                        
                    }
                }
                if let name = UserDefaults.standard.object(forKey: "showlistingId2")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingId2") != nil {
                        
                        listingTypeId = name as! Int
                        
                    }
                }
                
                
            }
        }
        
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.title = listingName
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = textColorLight
        self.title = NSLocalizedString(listingName, comment: "")
        self.navigationItem.hidesBackButton = true

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = textColorPrime
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Tabel Footer Height
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
    
    // Set Tabel Header Height
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
        return 105.0
    }
    
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return Int(ceil(Float(categoriesResponse.count)/4))
        }
        else
        {
            return Int(ceil(Float(categoriesResponse.count)/3))
        }
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = CategoryTableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryBrowseTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.blue
        cell.categoryName.isHidden = false
        cell.categoryName1.isHidden = false
        cell.categoryName2.isHidden = false
        cell.cellView.frame.size.height = 100
        cell.cellView1.frame.size.height = 100
        cell.cellView2.frame.size.height = 100
        
        var index:Int!
        index = (indexPath as NSIndexPath).row * 3
        
        
        if categoriesResponse.count > index
        {
            cell.cellView.isHidden = false
            cell.contentSelection.isHidden = false
            cell.categoryImageView.isHidden = false
            cell.categoryName.isHidden = false
            //cell.classifiedImageView.image = nil
            cell.categoryImageView.image = UIImage(named: "defaultcat.png")
            if let imageInfo = categoriesResponse[index] as? NSDictionary
            {
                if imageInfo["image_icon"] != nil
                {
                    if imageInfo["image_icon"]  != nil , let url = URL(string: imageInfo["image_icon"] as! String)
                    {
                        cell.categoryImageView.kf.indicatorType = .activity
                        (cell.categoryImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.categoryImageView.kf.setImage(with: url as URL?, placeholder: UIImage(named: "defaultcat.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                    }
                }
        
                // LHS
                cell.categoryName.text = imageInfo["category_name"] as? String
                cell.contentSelection.tag = index//imageInfo["category_id"] as! Int
                cell.contentSelection.addTarget(self, action: #selector(CategoryBrowseViewController.showSubCategory(_:)), for: .touchUpInside)
                
            }
            
        }
        else
        {
            cell.cellView.isHidden = true
            cell.contentSelection.isHidden = true
            cell.categoryImageView.isHidden = true
            cell.categoryName.isHidden = true
            
            cell.cellView1.isHidden = true
            cell.contentSelection1.isHidden = true
            cell.categoryImageView1.isHidden = true
            cell.categoryName1.isHidden = true
            
            cell.cellView2.isHidden = true
            cell.contentSelection2.isHidden = true
            cell.categoryImageView2.isHidden = true
            cell.categoryName2.isHidden = true
            
        }
        
        if categoriesResponse.count > (index + 1)
        {
            cell.cellView1.isHidden = false
            cell.contentSelection1.isHidden = false
            cell.categoryImageView1.isHidden = false
            cell.categoryName1.isHidden = false
            cell.categoryImageView1.image = UIImage(named: "defaultcat.png")
            //cell.classifiedImageView1.image = nil
            if let imageInfo = categoriesResponse[index + 1] as? NSDictionary
            {
                if imageInfo["image_icon"] != nil
                {
                    if imageInfo["image_icon"]  != nil , let url = URL(string: imageInfo["image_icon"] as! String)
                    {
                        cell.categoryImageView1.kf.indicatorType = .activity
                        (cell.categoryImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.categoryImageView1.kf.setImage(with: url as URL?, placeholder: UIImage(named: "defaultcat.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                        
                    }
                }
                
                cell.categoryName1.text = imageInfo["category_name"] as? String
                cell.contentSelection1.tag = index+1 //imageInfo["category_id"] as! Int
                cell.contentSelection1.addTarget(self, action: #selector(CategoryBrowseViewController.showSubCategory(_:)), for: .touchUpInside)
            }
            
        }
        else
        {
            cell.contentSelection1.isHidden = true
            cell.categoryImageView1.isHidden = true
            cell.categoryName1.isHidden = true
            
            cell.contentSelection2.isHidden = true
            cell.categoryImageView2.isHidden = true
            cell.categoryName2.isHidden = true
            
        }
        
        if categoriesResponse.count > (index + 2)
        {
            cell.cellView2.isHidden = false
            cell.contentSelection2.isHidden = false
            cell.categoryImageView2.isHidden = false
            cell.categoryName2.isHidden = false
            cell.categoryImageView2.image = UIImage(named: "defaultcat.png")
            //cell.classifiedImageView1.image = nil
            if let imageInfo = categoriesResponse[index + 2] as? NSDictionary
            {
                if imageInfo["image_icon"] != nil
                {
                    if imageInfo["image_icon"]  != nil , let url = URL(string: imageInfo["image_icon"] as! String)
                    {
                        cell.categoryImageView2.kf.indicatorType = .activity
                        (cell.categoryImageView2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.categoryImageView2.kf.setImage(with: url as URL?, placeholder: UIImage(named: "defaultcat.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
   
                    }
                }
                
                cell.categoryName2.text = imageInfo["category_name"] as? String
                cell.contentSelection2.tag = index+2 //imageInfo["category_id"] as! Int
                cell.contentSelection2.addTarget(self, action: #selector(CategoryBrowseViewController.showSubCategory(_:)), for: .touchUpInside)
            }
            
        }
        else
        {
            cell.contentSelection2.isHidden = true
            cell.categoryImageView2.isHidden = true
            cell.categoryName2.isHidden = true
            
        }
        
        return cell
        
    }
    
    
    // Handle Listing Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: Create Category Browse scrollable Menu
    func createScrollableListingMenu()
    {
        openMenu = false
        scrollView.frame = CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: ButtonHeight)
        scrollView.delegate = self
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        if self.tabBarController?.selectedIndex == 1 {
            listingTypeId = globalListingTypeId
            listingName = globalListingName
            
        }
        if self.tabBarController?.selectedIndex == 2 {
            listingTypeId = globalListingTypeId1
            listingName = globalListingName1
        }
        if self.tabBarController?.selectedIndex == 3 {
            listingTypeId = globalListingTypeId2
            listingName = globalListingName2
            
        }
        if logoutUser == false
        {
            var listingMenu = ["Categories","%@"]
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/2)
            for i in 100 ..< 102
            {

                listingOption =  createNavigationButton(CGRect(x: origin_x, y: ScrollframeY, width: menuWidth, height: ButtonHeight), title:String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), listingName), border: false, selected: false)
                listingOption.tag = i
                listingOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                listingOption.addTarget(self, action: #selector(CategoryBrowseViewController.listingSelectOptions(_:)), for: .touchUpInside)
                listingOption.backgroundColor =  UIColor.clear//textColorLight
                listingOption.alpha = 1.0
                if i == 100
                {
                    listingOption.setSelectedButton()
                }else{
                    listingOption.setUnSelectedButton()
                }
                scrollView.addSubview(listingOption)
                origin_x += menuWidth
                
            }
        }
        else
        {
            var listingMenu = ["Browse %@", "Categories"]
            var origin_x:CGFloat = 0.0
            menuWidth = CGFloat((view.bounds.width)/2)

            for i in 100 ..< 102

            {
                
                listingOption =  createNavigationButton(CGRect(x: origin_x, y: -ScrollframeY, width: menuWidth, height: ButtonHeight), title:String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), listingName), border: false, selected: false)
                
                listingOption.tag = i
                listingOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                listingOption.addTarget(self, action: #selector(CategoryBrowseViewController.listingSelectOptions(_:)), for: .touchUpInside)
                listingOption.backgroundColor =  UIColor.clear//textColorLight
                listingOption.alpha = 1.0

                
                if i == 100
                {
                    listingOption.setSelectedButton()
                }
                scrollView.addSubview(listingOption)
                origin_x += menuWidth
                
            }
            
        }
        scrollView.contentSize = CGSize(width:menuWidth * 2,height:ScrollframeY)

        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        mainView.addSubview(scrollView)
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.alwaysBounceVertical = false
        scrollView.isDirectionalLockEnabled = true;
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    
    // MARK: - Category Selection Action
    @objc func listingSelectOptions(_ sender: UIButton)
    {
        
        listingBrowseType = sender.tag - 100
        browseOrMyListings = true
        
        for ob in scrollView.subviews{
            if ob .isKind(of: UIButton.self){
                if ob.tag >= 100 && ob.tag <= 104
                {
                    (ob as! UIButton).setUnSelectedButton()
                    
                    if ob.tag == sender.tag
                    {
                        (ob as! UIButton).setSelectedButton()
                    }
                }
                
            }
        }

        searchDic.removeAll(keepingCapacity: false)
        pageNumber = 1
        showSpinner = true
        
        
        if listingBrowseType == 0 {
            browseOrMyListings = false
            showOnlyMyContent = false
            let presentedVC = CategoryBrowseViewController()
            presentedVC.listingName = listingName
            presentedVC.listingTypeId = self.listingTypeId
            navigationController?.pushViewController(presentedVC, animated: false)
            
        }else{
            var viewType : Int = 0
            var tempListingBrowseType : Int = 0
            var anotherTempListingBrowseType : Int = 0
            if self.tabBarController?.selectedIndex == 1 || self.tabBarController?.selectedIndex == 2 || self.tabBarController?.selectedIndex == 3{
            if self.tabBarController?.selectedIndex == 1 {
                listingTypeId = globalListingTypeId
                listingName = globalListingName
                if let name = UserDefaults.standard.object(forKey: "showlistingBrowseType")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingBrowseType") != nil {
                        
                        tempListingBrowseType = name as! Int
                        
                    }
                }
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }

                
            }
            if self.tabBarController?.selectedIndex == 2 {
                listingTypeId = globalListingTypeId1
                listingName = globalListingName1
                if let name = UserDefaults.standard.object(forKey: "showlistingBrowseType1")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingBrowseType1") != nil {
                        
                        tempListingBrowseType = name as! Int
                        
                    }
                }

                if let name = UserDefaults.standard.object(forKey: "showlistingviewType1")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType1") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }

            }
            if self.tabBarController?.selectedIndex == 3 {
                listingTypeId = globalListingTypeId2
                listingName = globalListingName2
                
                if let name = UserDefaults.standard.object(forKey: "showlistingBrowseType2")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingBrowseType2") != nil {
                        
                        tempListingBrowseType = name as! Int
                        
                    }
                }

                
                if let name = UserDefaults.standard.object(forKey: "showlistingviewType2")
                {
                    if  UserDefaults.standard.object(forKey: "showlistingviewType2") != nil {
                        
                        viewType = name as! Int
                        
                    }
                }

                
            }
            }
            else {

             var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingTypeId]!
             viewType = tempBrowseViewTypeDic["viewType"]!
             tempListingBrowseType = tempBrowseViewTypeDic["browseType"]!
             anotherTempListingBrowseType = tempBrowseViewTypeDic["anotherViewBrowseType"]!
            }
            
//            if mltToggleView == true
//            {
//                tempListingBrowseType = anotherTempListingBrowseType
//            }
            //mltToggleView
            if showGoogleMapView == true && listingBrowseType == 0
            {
                tempListingBrowseType = 4
            }
            switch(tempListingBrowseType){
            case 1:
                let presentedVC = MLTBrowseListViewController()
                presentedVC.title = listingName
                presentedVC.showOnlyMyContent = false
                presentedVC.listingTypeId = self.listingTypeId
                presentedVC.viewType = viewType
                presentedVC.listingName = listingName
                presentedVC.browseOrMyListings = browseOrMyListings
                presentedVC.dashboardMenuDic = dashboardMenuDic
                navigationController?.pushViewController(presentedVC, animated: false)
                
                break
            case 2:
                
                let presentedVC = MLTBrowseGridViewController()
                presentedVC.title = listingName
                presentedVC.showOnlyMyContent = false
                presentedVC.listingTypeId = self.listingTypeId
                presentedVC.viewType = viewType
                presentedVC.listingName = listingName
                presentedVC.browseOrMyListings = browseOrMyListings
                presentedVC.dashboardMenuDic = dashboardMenuDic
                navigationController?.pushViewController(presentedVC, animated: false)
                
                break
            case 3:
                
                let presentedVC = MLTBrowseMatrixViewController()
                presentedVC.title = listingName
                presentedVC.showOnlyMyContent = false
                presentedVC.listingTypeId = self.listingTypeId
                presentedVC.viewType = viewType //sitereviewMenuDictionary["viewType"] as! Int
                presentedVC.listingName = listingName
                presentedVC.browseOrMyListings = browseOrMyListings
                presentedVC.dashboardMenuDic = dashboardMenuDic
                navigationController?.pushViewController(presentedVC, animated: false)
                
                break
            default:
                showGoogleMapView = false
                let presentedVC = GoogleMapViewController()
                presentedVC.title = listingName
                presentedVC.showOnlyMyContent = false
                presentedVC.listingTypeId = self.listingTypeId
                presentedVC.viewType = viewType
                presentedVC.listingName = listingName
                presentedVC.browseOrMyListings = browseOrMyListings
                presentedVC.dashboardMenuDic = dashboardMenuDic
                navigationController?.pushViewController(presentedVC, animated: false)
                
                break
            }
        }
    }
    
    
    // MARK: - Browse entries
    @objc func browseEntries()
    {
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            
            let subViews = mainView.subviews
            for ob in subViews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            if (self.pageNumber == 1)
            {
                self.categoriesResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true
                {
                    removeAlert()
                }
                else
                {
                    updateAfterAlert = true
                }
            }
            
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
            
            if self.tabBarController?.selectedIndex == 1 {
                listingTypeId = globalListingTypeId
                listingName = globalListingName
                
                // baseController?.tabBar.items?[self.tabBarController!.selectedIndex]
                //baseController?.tabBar.userInteractionEnabled = false
            }
            if self.tabBarController?.selectedIndex == 2 {
                listingTypeId = globalListingTypeId1
                listingName = globalListingName1
                
                
            }
            if self.tabBarController?.selectedIndex == 3 {
                listingTypeId = globalListingTypeId2
                listingName = globalListingName2
                
            }
            var path = ""
            var parameters = [String:String]()
            
            path = "listings/categories"
            parameters = ["page":"\(pageNumber)","limit": "\(limit)", "listingtype_id": String(listingTypeId)]
            
            CategoryTableView.isHidden = false
            
            // Send Server Request to Browse Blog Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner
                    {
                        activityIndicatorView.stopAnimating()
                    }
                    
                    self.showSpinner = true
                    self.updateScrollFlag = true
                    self.scrollView.isUserInteractionEnabled = true
                    if msg
                    {

                        
                        if self.pageNumber == 1
                        {
                            self.categoriesResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary
                        {
                            if response["categories"] != nil

                            {
                                if let categories = response["categories"] as? NSArray
                                {
                                    self.categoriesResponse = self.categoriesResponse + (categories as [AnyObject])

                                }
                            }
                            
                            if response["totalItemCount"] != nil
                            {
                                self.totalItems = response["totalItemCount"] as! Int

                            }
                            
                        }
                        
                        self.CategoryTableView.reloadData()
                        self.isPageRefresing = false
                        if self.categoriesResponse.count == 0
                        {
                            
                            self.info = createLabel(CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.8, height: 60), text: NSLocalizedString("You do not have any listings matching this criteria.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.numberOfLines = 0
                            self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.info.isHidden = false
                            self.mainView.addSubview(self.info)
                            
                            self.info.isHidden = false
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false

                            
                        }
                        else
                        {
                            self.info.isHidden = true
                            self.refreshButton.isHidden = true
                            self.contentIcon.isHidden = true
                            
                        }
                        
                    }
                    else
                    {
                        

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
            self.scrollView.isUserInteractionEnabled = true
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    
    //MARK: Category Selection
    @objc func showSubCategory(_ sender:UIButton)
    {
        
        var listingInfo:NSDictionary!
        
        listingInfo = categoriesResponse[sender.tag] as! NSDictionary
        
        var presentedVC : UIViewController!

//        if showGoogleMapView == true
//        {
//            browseType = 4
//        }
        
        var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingTypeId]!
//        viewType = tempBrowseViewTypeDic["viewType"]!
        browseType = tempBrowseViewTypeDic["browseType"]!
        
        switch(browseType){
        case 1:
            presentedVC = CategoryDetailListViewController()
            (presentedVC as! CategoryDetailListViewController).subjectId = listingInfo["category_id"] as! Int
            (presentedVC as! CategoryDetailListViewController).title = listingInfo["category_name"] as? String
            (presentedVC as! CategoryDetailListViewController).listingTypeId = self.listingTypeId
            
            break
            
        case 2:
            presentedVC = CategoryDetailGridViewController()
            (presentedVC as! CategoryDetailGridViewController).subjectId = listingInfo["category_id"] as! Int
            (presentedVC as! CategoryDetailGridViewController).title = listingInfo["category_name"] as? String
            (presentedVC as! CategoryDetailGridViewController).listingTypeId = self.listingTypeId
            
            break
        case 3:
            presentedVC = CategoryDetailMatrixViewController()
            (presentedVC as! CategoryDetailMatrixViewController).subjectId = listingInfo["category_id"] as! Int
            (presentedVC as! CategoryDetailMatrixViewController).title = listingInfo["category_name"] as? String
            (presentedVC as! CategoryDetailMatrixViewController).listingTypeId = self.listingTypeId
            
            break
       
        default:
            
            presentedVC = CategoryDetailListViewController()
            (presentedVC as! CategoryDetailListViewController).subjectId = listingInfo["category_id"] as! Int
            (presentedVC as! CategoryDetailListViewController).title = listingInfo["category_name"] as? String
            (presentedVC as! CategoryDetailListViewController).listingTypeId = self.listingTypeId
            
            
//            presentedVC = GoogleMapViewController()
//            (presentedVC as! GoogleMapViewController).title = listingInfo["category_name"] as? String
//            (presentedVC as! GoogleMapViewController).listingTypeId = self.listingTypeId
//            (presentedVC as! GoogleMapViewController).listingName = sitereviewMenuDictionary["headerLabel"] as! String
//            (presentedVC as! GoogleMapViewController).categoryId = listingInfo["category_id"] as! Int
//            (presentedVC as! GoogleMapViewController).fromCategory = true
//            (presentedVC as! GoogleMapViewController).viewType = viewType
            break
        }
        
        navigationController?.pushViewController(presentedVC, animated: true)
    }

    func goBack()
    {
        
        _ = self.navigationController?.popViewController(animated: false)
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
