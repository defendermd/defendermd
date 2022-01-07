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
//  WishlistBrowseViewController.swift
//  seiosnativeapp
//

import UIKit
import NVActivityIndicatorView
import Instructions

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

var wishlistUpdate = false // To maintain if content should be reloaded or not.
class WishlistBrowseViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, CoachMarksControllerDataSource, CoachMarksControllerDelegate
{
    
    let mainView = UIView()
    var showOnlyMyContent:Bool!
    let scrollView = UIScrollView()
    var WishlistTableView:UITableView!
    var refresher:UIRefreshControl!
    var showSpinner = true
    var isPageRefresing = false
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var listingResponse:[WishListModel] = []
    var noContentView = NoContentView()
    var updateScrollFlag = true
    var imageArr:[UIImage]=[]
    var countListTitle : String!
    var contentGutterMenu: NSArray = []
    var deleteContent : Bool!
    var subjectType:String!
  //  var imageCache = [String:UIImage]()
    var fromWithinClass : Bool!
    var menuOption:UIButton!
    var productOrOthers:Bool!
    var btnHight:CGFloat = 0
    var wishlistType : String = ""
    var leftBarButtonItem : UIBarButtonItem!
    var coachMarksController = CoachMarksController()
    var targetCheckValue : Int = 1
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //print(wishlistType)
        view.backgroundColor = bgColor
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        subjectType = "wishlists"
        wishlistUpdate = true
        
        globWishlistFilterValue = ""
        openMenu = false                                    // true: opens the menu, false: doesn't opens the dashboard menu
        updateAfterAlert = true
        

        self.navigationItem.hidesBackButton = true
        self.title = NSLocalizedString("Wishlist", comment: "")
        
        // Create a Feed Filter to perform Feed Filtering
        let filter = createButton(CGRect(x: PADING, y: TOPPADING + contentPADING + ButtonHeight, width: ButtonHeight - PADING , height: 0), title: fiterIcon, border: true,bgColor: false, textColor: textColorDark)
        filter.addTarget(self, action: #selector(WishlistBrowseViewController.filterSearch), for: .touchUpInside)
        filter.titleLabel?.font =  UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        mainView.addSubview(filter)
        filter.isHidden = true

        
        // Set pull to referseh for wishlisttableview
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(WishlistBrowseViewController.refresh), for: UIControl.Event.valueChanged)
        
        
        if logoutUser == true || showOnlyMyContent == true
        {
            filter.frame.origin.y = TOPPADING
            self.title = NSLocalizedString("\(countListTitle)",  comment: "")
            
            let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            leftNavView.backgroundColor = UIColor.clear
            let tapView = UITapGestureRecognizer(target: self, action: #selector(WishlistBrowseViewController.goBack))
            leftNavView.addGestureRecognizer(tapView)
            let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
            backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
            leftNavView.addSubview(backIconImageView)
            
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
            
            
        }
        noContentView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        noContentView.isHidden = true
        mainView.addSubview(noContentView)

        
        // Get wishlist type for show
        switch(wishlistType)
        {
          case "both":
            createScrollableStoreMenu()
            productOrOthers = true
         case "product":
            productOrOthers = true
         case "other":
            productOrOthers = false
        case "diary":
            productOrOthers = false
            
         default:
            productOrOthers = false
            
        }

        
        
        if tabBarHeight > 0{

            WishlistTableView = UITableView(frame: CGRect(x:0, y:TOPPADING+btnHight, width:view.bounds.width, height:view.bounds.height-(TOPPADING - 12+btnHight) - tabBarHeight ), style: .grouped)
        }else{
            WishlistTableView = UITableView(frame: CGRect(x:0, y:TOPPADING+btnHight ,width: view.bounds.width, height:view.bounds.height-(TOPPADING+btnHight) - tabBarHeight ), style: .grouped)

        }
        
        WishlistTableView.register(WishlistTableViewCell.self, forCellReuseIdentifier: "WishlistCell")
        WishlistTableView.rowHeight = 200
        WishlistTableView.dataSource = self
        WishlistTableView.delegate = self
        WishlistTableView.isOpaque = false
        WishlistTableView.isHidden = true
        WishlistTableView.backgroundColor = tableViewBgColor
        WishlistTableView.showsVerticalScrollIndicator = false
        WishlistTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            WishlistTableView.estimatedSectionHeaderHeight = 0
            WishlistTableView.estimatedSectionFooterHeight = 0
        }

        mainView.addSubview(WishlistTableView)
        
        let footerView = UIView(frame: CGRect(x: 0, y: -10, width: self.view.bounds.width, height: 25))
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = footerView.center//CGPoint(x:(footerView.bounds.width - 25)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        WishlistTableView.tableFooterView = footerView
        WishlistTableView.tableFooterView?.isHidden = true
        self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
        self.mainView.addSubview(self.noContentView)
        self.noContentView.isHidden = true
        self.noContentView.button.layer.borderWidth = 1
        self.noContentView.button.layer.borderColor = buttonColor.cgColor
        self.noContentView.button.setTitle(NSLocalizedString("Create", comment: ""), for: .normal) 
        self.noContentView.button.addTarget(self, action: #selector(WishlistBrowseViewController.addNewEvent), for: .touchUpInside)
        self.noContentView.label.text = NSLocalizedString("No Listings available at this moment, Create One", comment: "")

        browseEntries()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        removeNavigationViews(controller: self)
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        isredirectToViewpage()

        if wishlistUpdate == true
        {
            wishlistUpdate = false
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            browseEntries()
        }
        
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        fromWithinClass = false
        WishlistTableView.reloadData()
        
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        if self.wishlistType == "diary"{
            return 2
        }
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
            var origin_x : CGFloat = self.view.bounds.width - 15.0
            let radious : Int = 40
            if self.wishlistType == "diary"{
                origin_x = self.view.bounds.width - 75.0
            }
            
            
            coachMark2 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
            coachMark2.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark2
            
        case 1:
            // skipView.isHidden = true
            var  coachMark1 : CoachMark
            let showView = UIView()
            let origin_x : CGFloat = self.view.bounds.width - 15.0
            let radious : Int = 40
            
            
            coachMark1 = coachMarksController.helper.makeCoachMark(for: showView) { (frame: CGRect) -> UIBezierPath in
                // This will create a circular cutoutPath, perfect for the circular avatar!
                let circlePath = UIBezierPath(arcCenter: CGPoint(x: origin_x,y: 50), radius: CGFloat(radious), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
                
                return circlePath
                
            }
            coachMark1.gapBetweenCoachMarkAndCutoutPath = 6.0
            return coachMark1
            
            
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
        case 1:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        // coachViews.bodyView.isUserInteractionEnabled = false
        default:
            coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: false, withNextText: true, arrowOrientation: coachMark.arrowOrientation)
        }
        
        switch(index) {
            //        case 0:
            //            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: "")) \n\n  1/2  "
            //            coachViews.bodyView.nextLabel.text = "Next"
            
       
           
            
        case 0:
            if self.wishlistType == "diary"{
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 1/2", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Next ", comment: "")
            }
            else{
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(searchTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 1/1", comment: "")
            coachViews.bodyView.nextLabel.text = NSLocalizedString("Finish ", comment: "")
            }
            
        case 1:
            coachViews.bodyView.hintLabel.text = "\(NSLocalizedString("\(createTourText)", comment: ""))"
            coachViews.bodyView.countTourLabel.text = NSLocalizedString(" 2/2", comment: "")
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
    
    func showSearchAppTour(){
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


    
    
    func isredirectToViewpage()
    {
        if conditionalProfileForm == "BrowsePage"
        {
            conditionalProfileForm = ""
            let presentedVC = DiaryDetailViewController()
            presentedVC.subjectId = createResponse["diary_id"] as! Int
            presentedVC.totalItemCount = createResponse["total_events"] as! Int
            presentedVC.diaryName = "\(createResponse["title"]!)"
            presentedVC.IScomingfrom = "diary"
            presentedVC.descriptiondiary = "\(createResponse["body"]!)"
            navigationController?.pushViewController(presentedVC, animated: true)
            
        }
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        WishlistTableView.tableFooterView?.isHidden = true
        globalWishlistOwnerSearch = ""
        filterSearchFormArray.removeAll(keepingCapacity: false)
        
    }
    func createScrollableStoreMenu()
    {
        openMenu = false
        scrollView.frame = CGRect(x:0, y:TOPPADING, width:view.bounds.width, height:ButtonHeight)
        scrollView.delegate = self
        scrollView.tag = 2;
        var menuWidth = CGFloat()
        
        
        var listingMenu = [NSLocalizedString("Products", comment: ""), NSLocalizedString("Others", comment: "")]
        var origin_x:CGFloat = 0.0
        menuWidth = CGFloat((view.bounds.width)/2)
        for i in 100 ..< 102
        {
            menuOption =  createNavigationButton(CGRect(x:origin_x, y:ScrollframeY, width:menuWidth, height:ButtonHeight), title:String(format: NSLocalizedString("\(listingMenu[(i-100)])", comment: ""), "Stores"), border: true, selected: false)
            
            if i == 100
            {
                menuOption.setSelectedButton()
                
            }
            else
            {
                
                menuOption.setUnSelectedButton()
                
            }
            menuOption.tag = i
            menuOption.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
            menuOption.addTarget(self, action: #selector(WishlistBrowseViewController.menuSelectOptions(sender:)), for: .touchUpInside)
            menuOption.backgroundColor =  UIColor.clear//textColorLight
            menuOption.alpha = 1.0
            scrollView.addSubview(menuOption)
            origin_x += menuWidth
            
        }
        scrollView.contentSize = CGSize(width:menuWidth * 3 , height:-TOPPADING)
        scrollView.bounces = false
        scrollView.isUserInteractionEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.isDirectionalLockEnabled = true;
        scrollView.backgroundColor = UIColor.clear
        mainView.addSubview(scrollView)
        
        self.scrollView.alwaysBounceHorizontal = false
        self.scrollView.alwaysBounceVertical = false
        btnHight = ButtonHeight
        
    }
    @objc func menuSelectOptions(sender: UIButton)
    {
        let menuBrowseType = sender.tag - 100
        
        scrollView.isUserInteractionEnabled = false
        if menuBrowseType == 0
        {
            productOrOthers = true
            self.listingResponse.removeAll(keepingCapacity: false)
        }
        else if menuBrowseType == 1
        {
            productOrOthers = false
            self.listingResponse.removeAll(keepingCapacity: false)
        }
        showSpinner = true
        WishlistTableView.reloadData()
        
        for ob in scrollView.subviews{
            if ob.isKind(of: UIButton.self){
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
        pageNumber = 1
        browseEntries()
        
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Show Slide Menu
    @objc func openSlideMenu()
    {
        let dashObj = DashboardViewController()
        dashObj.getDynamicDashboard()
        dashObj.dashboardTableView.reloadData()
       //  
        openSideMenu = true
        
    }
    
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer)
    {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    func sideMenuWillOpen() {
        openSideMenu = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(WishlistBrowseViewController.openSlideMenu))
        mainView.addGestureRecognizer(tapGesture)
    }
    
    func sideMenuWillClose() {
        openSideMenu = false
        mainView.removeGestureRecognizer(tapGesture)
    }
    
    // MARK: -  Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
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
    
    @objc func filterSearch()
    {
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        else
        {

            searchDic.removeAll(keepingCapacity: false)
            wishlistUpdate = false
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "listings/wishlist/search-form"
            presentedVC.serachFor = "wishlists"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView)
//    {
//
//        if updateScrollFlag
//        {
//            // Check for Page Number for Browse wishlist
//            if WishlistTableView.contentOffset.y >= WishlistTableView.contentSize.height - WishlistTableView.bounds.size.height{
//                if (!isPageRefresing  && limit*pageNumber < totalItems)
//                {
//                    if Reachabable.isConnectedToNetwork()
//                    {
//                        updateScrollFlag = false
//                        pageNumber += 1
//                        isPageRefresing = true
//                        if searchDic.count == 0{
//                            browseEntries()
//                        }
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
                if (!isPageRefresing  && limit*pageNumber < totalItems)
                {
                    if Reachabable.isConnectedToNetwork()
                    {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        WishlistTableView.tableFooterView?.isHidden = false
                      //  if searchDic.count == 0{
                            browseEntries()
                      //  }
                    }
                }
                else
                {
                    WishlistTableView.tableFooterView?.isHidden = true
                }
            }
            
        }
        
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
        return 202.0
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return Int(ceil(Float(listingResponse.count)/2))
        }
        else
        {
            return listingResponse.count
        }
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = WishlistTableView.dequeueReusableCell(withIdentifier: "WishlistCell", for: indexPath) as! WishlistTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let listingInfo = listingResponse[(indexPath as NSIndexPath).row]
        cell.coverSelection.tag = (indexPath as NSIndexPath).row
        cell.coverImage.tag = (indexPath as NSIndexPath).row
        cell.moreOptions.tag = (indexPath as NSIndexPath).row
        
        cell.coverSelection.addTarget(self, action: #selector(WishlistBrowseViewController.coverSelection(_:)), for: .touchUpInside)
        
        cell.moreOptions.addTarget(self, action: #selector(WishlistBrowseViewController.moreOptions(_:)), for: .touchUpInside)
        if listingInfo.isLike  == 0 as Int{
            cell.moreOptions.setTitleColor(textColorLight, for: UIControl.State())
        }else{
            cell.moreOptions.setTitleColor(navColor, for: UIControl.State())
        }
        
        let name = listingInfo.title
        cell.titleLabel.text = "\(name!)"
        let count = listingInfo.total_item
        if count != nil
        {
            if productOrOthers == true
            {
                if count == 1
                {
                 cell.countLabel.text = String(format: NSLocalizedString("%@ Product", comment: ""),"\(count!)")
                
                }
                else
                {
                  cell.countLabel.text = String(format: NSLocalizedString("%@ Products", comment: ""),"\(count!)")
                }
            }
            else
            {
                if wishlistType == "diary"
                {
                    cell.moreOptions.isHidden = true
                    if count == 1
                    {
                        cell.countLabel.text = String(format: NSLocalizedString("%@ Event", comment: ""),"\(count!)")
                        
                    }
                    else
                    {
                        cell.countLabel.text = String(format: NSLocalizedString("%@ Events", comment: ""),"\(count!)")
                    }
                }
                else
                {
                    if count == 1
                    {
                        cell.countLabel.text = String(format: NSLocalizedString("%@ Listing", comment: ""),"\(count!)")
                        
                    }
                    else
                    {
                        cell.countLabel.text = String(format: NSLocalizedString("%@ Listings", comment: ""),"\(count!)")
                    }
                }

            }
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
                
                imageArr.removeAll()
                cell.coverImage.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                let imagedic = listingInfo.listing_images_1
                if imagedic != ""{
                    let url = URL(string: imagedic! as String)
                    if url != nil {
                        cell.coverImage.kf.indicatorType = .activity
                        (cell.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.coverImage.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            DispatchQueue.main.async {
                                if image != nil {
                                    self.imageArr.append(image!)
                                }
                            }
                        })
                    }
                    
                    
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
                
                
                imageArr.removeAll()
                let imagedic1 = listingInfo.listing_images_1
                let imagedic2 = listingInfo.listing_images_2
                
                if imagedic1 != ""{
                    let url1 = URL(string: imagedic1! as String)
                    if url1 != nil {
                        cell.coverImage4.kf.setImage(with: url1, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                            
                        })

                    }
                }else{
                    cell.coverImage4.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
                }
                if imagedic2 != ""{
                    let url2 = URL(string: imagedic2! as String)
                    if url2 != nil {
                        cell.coverImage5.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
                        cell.coverImage5.kf.setImage(with: url2, for: .normal, placeholder: UIImage(named: "nophoto_diary_thumb_profile.png"), options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                            
                        })

                    }
                }else{
                    cell.coverImage5.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
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
                
                imageArr.removeAll()
                let imagedic3 = listingInfo.listing_images_1
                let imagedic4 = listingInfo.listing_images_2
                let imagedic5 = listingInfo.listing_images_3
                
                if imagedic3 != ""{
                    let url3 = URL(string: imagedic3! as String)
                    if url3 != nil {
                        cell.coverImage1.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                        cell.coverImage1.kf.indicatorType = .activity
                        (cell.coverImage1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.coverImage1.kf.setImage(with: url3 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })

                    }
                }else{
                    cell.coverImage1.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                }
                
                if imagedic4 != ""{
                    let url4 = URL(string: imagedic4! as String)
                    if url4 != nil {
                        cell.coverImage2.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                        cell.coverImage2.kf.indicatorType = .activity
                        (cell.coverImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.coverImage2.kf.setImage(with: url4 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })


                    }
                }else{
                    cell.coverImage2.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                }
                
                if imagedic5 != ""{
                    let url5 = URL(string: imagedic5! as String)
                    if url5 != nil {
                        cell.coverImage3.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                        cell.coverImage3.kf.indicatorType = .activity
                        (cell.coverImage3.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.coverImage3.kf.setImage(with: url5 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })

                    }
                }else{
                    
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

            }
        }
        
        return cell
    }
    
    //Show msg for unauthorized user
    func noRedirection(){
        showToast(message: "You do not have the permission to view this private page.", controller: self)
    }
    
    // Handle wishlist Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // MARK: - searchItem Selection
    @objc func searchItem()
    {
        

        var url = String()
        let presentedVC = WishlistSearchViewController()
        
        if productOrOthers == true
        {
            url  = "sitestore/product/wishlist/search-form"
            presentedVC.productOrOthers = true
            loadFilter(url)
            self.navigationController?.pushViewController(presentedVC, animated: false)
            
        }
        else
        {
            if wishlistType == "diary"
            {
                globalCatg = ""
                let url : String = "advancedevents/diaries/search-form"
                loadFilter(url)
                let presentedVC = AdvancedEventSearchViewController()
                presentedVC.comingFrom = "diary"
                presentedVC.eventBrowseType = 10
                self.navigationController?.pushViewController(presentedVC, animated: false)
            }
            else
            {
                url = "listings/wishlist/search-form"
                presentedVC.productOrOthers = false
                loadFilter(url)
                self.navigationController?.pushViewController(presentedVC, animated: false)
                
            }

        }

    }
    
    //Function
    @objc func coverSelection(_ sender:UIButton)
    {
        let listingInfo = listingResponse[sender.tag]
        if listingInfo.allow_to_view == 0
        {
            noRedirection()
        }
        else{
            
            if openMenu
            {
                openMenu = false
                openMenuSlideOnView(mainView)
                return
            }
            
            if wishlistType == "diary"
            {
                let presentedVC = DiaryDetailViewController()
                presentedVC.subjectId = listingInfo.wishlist_id
                presentedVC.totalItemCount = listingInfo.total_item
                presentedVC.diaryName = listingInfo.title
                presentedVC.IScomingfrom = "diary"
                presentedVC.descriptiondiary = listingInfo.body
                navigationController?.pushViewController(presentedVC, animated: true)
            }
            else
            {
                let presentedVC = WishlistDetailViewController()
                presentedVC.subjectId = listingInfo.wishlist_id
                presentedVC.totalItemCount = listingInfo.total_item
                presentedVC.wishlistName = listingInfo.title
                presentedVC.descriptionWishlist = listingInfo.body
                presentedVC.productOrOthers = productOrOthers
                navigationController?.pushViewController(presentedVC, animated: true)
            }
        }
    }
    
    //Function for showing options like & follow for wishlist
    //TODO: work for menus as currently options are not coming from wishlist
    @objc func moreOptions(_ sender:UIButton)
    {
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        let currentWishList = listingResponse[sender.tag]
        
        if currentWishList.isLike! as Int == 1{
            sender.setTitleColor(textColorLight, for: UIControl.State())
            sender.tintColor = textColorLight
            animationEffectOnButton(sender)
            currentWishList.isLike = 0
            self.likeFollowWishList(sender.tag,likeOrUnlike : 0,sender : sender)
        }
        else{
            sender.setTitleColor(navColor, for: UIControl.State())
            sender.tintColor = navColor
            animationEffectOnButton(sender)
            currentWishList.isLike = 1
            self.likeFollowWishList(sender.tag,likeOrUnlike : 1,sender : sender)
        }
        
        searchDic.removeAll(keepingCapacity: false)
    }
    
    func likeFollowWishList(_ indexPath : Int, likeOrUnlike : Int,sender : UIButton){
        let currentWishList = listingResponse[indexPath]
        let tempLikeDictionary = currentWishList.likeDictionary
        
        var url = "like"
        
        if likeOrUnlike == 1 {
            tempLikeDictionary!.setObject( "/like", forKey: "url" as NSCopying)
            url = "/like"
        }else{
            tempLikeDictionary!.setObject( "/unlike", forKey: "url" as NSCopying)
            url = "/unlike"
        }
        
        let parameter = tempLikeDictionary!["urlParams"] as? NSDictionary
        
        var dic = Dictionary<String, String>()
        for (key, value) in parameter!{
            
            if let id = value as? NSNumber {
                dic["\(key)"] = String(id as! Int)
            }
            
            if let receiver = value as? NSString {
                dic["\(key)"] = receiver as String
            }
        }
        
        if Reachabable.isConnectedToNetwork() {
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        sender.isEnabled = true
                    } else {
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg, timer:false )
        }
        
    }
    
    //Go Back
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view.addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer for remove Alert
    @objc func stopTimer() {
        stop()
    }
    @objc func addNewEvent()
    {
        
        if openMenu
        {
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        else
        {
            if wishlistType == "diary"
            {
                isCreateOrEdit = true
                globFilterValue = ""
                let presentedVC = FormGenerationViewController()
                presentedVC.formTitle = NSLocalizedString("Create New Diary", comment: "")
                presentedVC.contentType = "Diary"
                presentedVC.param = [ : ]
                presentedVC.url = "advancedevents/diaries/create"
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)
            }
        }
    }
    // MARK: - Server Connection For Wishlist Updation
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
                self.listingResponse.removeAll(keepingCapacity: false)
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
              //  spinner.center = view.center
                if updateScrollFlag == false
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85-(tabBarHeight/4))
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
               // activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            var path = ""
            var parameters = [String:String]()
            self.title = NSLocalizedString("Wishlists",  comment: "")
            if productOrOthers == true
            {
                path = "sitestore/product/wishlist"
            }
            else
            {
                if wishlistType == "diary"
                {
                    path = "advancedevents/diaries"
                    self.title = NSLocalizedString("Diaries",  comment: "")
                }
                else
                {
                    path = "listings/wishlist/browse"
                }
                
            }
            
            parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
            WishlistTableView.isHidden = false
            // Send Server Request to Browse wishlist Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                        
                        if self.showSpinner
                        {
                            activityIndicatorView.stopAnimating()
                        }
                        self.WishlistTableView.tableFooterView?.isHidden = true
                        self.refresher.endRefreshing()
                        self.showSpinner = false
                        self.updateScrollFlag = true
                        self.scrollView.isUserInteractionEnabled = true
                        self.isPageRefresing = false
                        if msg
                        {
                            if self.pageNumber == 1
                            {
                                self.listingResponse.removeAll(keepingCapacity: false)
                            }
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["response"] != nil
                                {
                                    if let wishlist = response["response"] as? NSArray
                                    {
                                        self.listingResponse += WishListModel.loadWishLists(wishlist, wishlistType: self.wishlistType)
                                    }
                                }
                                
                            }
                            
                            if self.listingResponse.count == 0
                            {

                                self.noContentView.isHidden = false
                            }
                            else
                            {

                                self.noContentView.isHidden = true
                            }
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["totalItemCount"] != nil
                                {
                                    self.totalItems = response["totalItemCount"] as! Int
                                }
                                if response["canCreate"] != nil
                                {
                                    if (response["canCreate"] as! Int == 1)
                                    {
                                        if self.wishlistType == "diary"{
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(WishlistBrowseViewController.searchItem))
                                            searchItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                                        let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(WishlistBrowseViewController.addNewEvent))
                                        self.navigationItem.setRightBarButtonItems([addBlog,searchItem], animated: true)
                                            addBlog.imageInsets = UIEdgeInsets(top: 0,left: 0, bottom: 0, right: 0)
                                        searchItem.tintColor = textColorPrime
                                        addBlog.tintColor = textColorPrime
                                            self.showAppTour()
                                        }else{
                                            let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(WishlistBrowseViewController.searchItem))
                                            self.navigationItem.setRightBarButtonItems([searchItem], animated: true)
                                            searchItem.tintColor = textColorPrime
                                            self.showSearchAppTour()
                                        }

                                    }
                                    else
                                    {
                                        let searchItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.search, target: self, action: #selector(WishlistBrowseViewController.searchItem))
                                        self.navigationItem.setRightBarButtonItems([searchItem], animated: true)
                                        searchItem.tintColor = textColorPrime
                                        self.showSearchAppTour()
                                        
                            
                                    }
                                }

                            }
                            self.WishlistTableView.reloadData()
                            
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
    
}
