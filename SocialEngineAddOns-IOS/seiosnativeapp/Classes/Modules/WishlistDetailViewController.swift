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
//  WishlistDetailViewController.swift
//  seiosnativeapp
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


class WishlistDetailViewController
    : UIViewController, UITableViewDataSource, UITableViewDelegate , UITabBarControllerDelegate
{
    var subjectId:Int! = 0
    var subjectType:String!
    var descriptionWishlist:String!
    var totalItemCount:Int!
    var wishlistName: String!
    let mainView = UIView()
    var wishlistTableView:UITableView!
    var refresher:UIRefreshControl!
    var refreshButton : UIButton!
    var contentIcon : UILabel!
    
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var updateScrollFlag = true
    var wishlistResponse = [AnyObject]()
    var showSpinner = true
    var isPageRefresing = false
    var info:UILabel!
    
    var contentGutterMenu: NSArray = []
    var deleteContent : Bool!
    var contentTitle : String!
    var contentDescription : String!
    
    var shareUrl : String!
    var shareParam : NSDictionary!
  //  var imageCache = [String:UIImage]()
    var descriptionTextview:UITextView!
    var listingContentName : String!
    var dynamicHeight:CGFloat = 253.0
    var contentUrl : String!
    var contentImageUrls : String!
    var profileCurrencySymbol : String!
    var wishlistDescriptionView : UIView!
    var wishlistDescriptionLabel: UILabel!
    var productOrOthers:Bool! = false
    var marqueeHeader : MarqueeLabel!
    var leftBarButtonItem : UIBarButtonItem!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = bgColor
        mainView.frame = view.frame
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        wishlistUpdate = false//true
        self.tabBarController?.delegate = self
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = textColorPrime
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(WishlistDetailViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        globWishlistFilterValue = ""
        openMenu = false
        updateAfterAlert = true
        //wishlistUpdate = true
        
        wishlistTableView = UITableView(frame: CGRect(x: 0, y: 0,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)        
        wishlistTableView.register(MLTGridTableViewCell.self, forCellReuseIdentifier: "wishlistProfileCell")

        wishlistTableView.estimatedRowHeight = 250
        wishlistTableView.dataSource = self
        wishlistTableView.delegate = self
        wishlistTableView.isOpaque = false
        wishlistTableView.backgroundColor = tableViewBgColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            wishlistTableView.estimatedSectionHeaderHeight = 0
            wishlistTableView.estimatedSectionFooterHeight = 0
        }
        mainView.addSubview(wishlistTableView)
        
        // Set pull to referseh for wishlistTableView
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(WishlistDetailViewController.refresh), for: UIControl.Event.valueChanged)
        wishlistTableView.addSubview(refresher)
        
        contentIcon = createLabel(CGRect(x: 0, y: 0, width: 0, height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0, y: 0, width: 0, height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        wishlistDescriptionView = createView(CGRect(x: 0, y: 5, width: view.bounds.width, height: 100), borderColor: UIColor.clear, shadow: false)
        wishlistDescriptionView.backgroundColor = tableViewBgColor
        
        wishlistDescriptionLabel = createLabel(CGRect(x: PADING, y: 0, width: view.bounds.width - (2 * PADING), height: 100), text: "", alignment: .left, textColor:UIColor.black)
        wishlistDescriptionLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        wishlistDescriptionLabel.backgroundColor = tableViewBgColor
        wishlistDescriptionLabel.textAlignment = NSTextAlignment.center
        wishlistDescriptionView.addSubview(wishlistDescriptionLabel)
        wishlistDescriptionView.isHidden = true
        mainView.addSubview(wishlistDescriptionView)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        wishlistTableView.tableFooterView = footerView
        wishlistTableView.tableFooterView?.isHidden = true
   
         browseEntries()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = textColorPrime
        
        
        let pageTitle = wishlistName

        if let navigationBar = self.navigationController?.navigationBar {
            if marqueeHeader != nil{
                marqueeHeader.text = ""
                removeMarqueFroMNavigaTion(controller: self)
            }
            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            marqueeHeader.text = pageTitle
            marqueeHeader.textColor = textColorPrime
            navigationBar.addSubview(marqueeHeader)
        }
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(WishlistDetailViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        
     //   if (wishlistUpdate == true){
            wishlistDescriptionView.isHidden = true
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            browseEntries()
     //   }
        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        wishlistTableView.tableFooterView?.isHidden = true
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = textColorPrime
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
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
        
        var wishlistInfo:NSDictionary!
        wishlistInfo = wishlistResponse[sender.tag] as! NSDictionary
        
        var viewType = 1
        if let listingTypeId = wishlistInfo["listingtype_id"] as? Int{
            
            var tempBrowseViewTypeDic = listingBrowseViewTypeArr[listingTypeId]!
            
            viewType = tempBrowseViewTypeDic["viewType"]!
            
//            viewType = 1 //listingBrowseViewTypeArr[listingTypeId]!
        }
        
        
        if(wishlistInfo["allow_to_view"] as! Int == 1){
            
            if viewType == 1{
                let presentedVC = MLTBlogTypeViewController()
                if (wishlistInfo["listing_id"] is String){
                    let tempValue = wishlistInfo["listing_id"] as! String
                    
                    presentedVC.listingId = tempValue
                    
                }else{
                    presentedVC.listingId = "\(wishlistInfo["listing_id"]!)"
                    
                }
                
                if wishlistInfo["listingtype_id"] is Int{
                    
                    presentedVC.listingTypeId = wishlistInfo["listingtype_id"] as! Int
                    presentedVC.subjectType = "sitereview_listing"
                    
                }
                
                presentedVC.listingName = "\(wishlistInfo["title"]!)"
                
                navigationController?.pushViewController(presentedVC, animated: true)
            }
            if viewType == 2{
                let presentedVC = MLTClassifiedSimpleTypeViewController()
                if (wishlistInfo["listing_id"] is String){
                    let tempValue = wishlistInfo["listing_id"] as! String
                    
                    presentedVC.listingId = tempValue
                    
                }else{
                    presentedVC.listingId = "\(wishlistInfo["listing_id"]!)"
                    
                }
                
                if wishlistInfo["listingtype_id"] is Int{

                    presentedVC.listingTypeId = wishlistInfo["listingtype_id"] as! Int
                    presentedVC.subjectType = "sitereview_listing"
                    
                }
                
                navigationController?.pushViewController(presentedVC, animated: true)
            }
            if viewType == 3{
                let presentedVC = MLTClassifiedAdvancedTypeViewController()
                if (wishlistInfo["listing_id"] is String){
                    let tempValue = wishlistInfo["listing_id"] as! String
                    
                    presentedVC.listingId = tempValue
                    //presentedVC.subjectId = Int(tempValue)
                }else{
                    presentedVC.listingId = "\(wishlistInfo["listing_id"]!)"
                    //presentedVC.subjectId = listingInfo["listing_id"] as! Int
                }
                
                if wishlistInfo["listingtype_id"] is Int{

                    presentedVC.listingTypeId = wishlistInfo["listingtype_id"] as! Int
                    presentedVC.subjectType = "sitereview_listing"
                    //presentedVC.listingTypeId = tempListingTypeId
                }
                
                //presentedVC.listingName = wishlistInfo["title"] as! String
                
                navigationController?.pushViewController(presentedVC, animated: true)
            }
            
        }else{
            showToast(message:  NSLocalizedString("You do not have permission to view this private page.",  comment: ""), controller: self)
        }
        
    }
    
    @objc func showProduct(_ sender:UIButton)
    {
        if let productInfo = wishlistResponse[sender.tag] as? NSDictionary {
            let product_id =  "\(productInfo["product_id"]!)"
            if(productInfo["allow_to_view"] as! Int == 1){
                SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id:product_id)
            }else{
                showToast(message: NSLocalizedString("You do not have permission to view this private page.", comment: ""), controller: self)
            }
        }
    }
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
    
    
    // Set Blog Table Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return dynamicHeight
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        self.totalItemCount = wishlistResponse.count
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            return Int(ceil(Float(wishlistResponse.count)/2))
        }
        else
        {
            return wishlistResponse.count
        }
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        //MARK: CELL LAYOUT LIKE EVENT VIEW
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "wishlistProfileCell", for: indexPath) as! MLTGridTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        //SET CONTENT IMAGE BOUNDS
        cell.contentImage.frame = CGRect(x: 0, y: 0, width: cell.cellView.bounds.width, height: cell.cellView.bounds.height - cell.cellView.bounds.height/4)
        
        //SET TITLE VIEW BOUNDS
        // TITLE VIEW IS BEING USED TO SHOW THE INFO ABOUT THE CONTENT
        cell.titleView.frame = CGRect(x: 0, y: cell.contentImage.bounds.height, width: cell.cellView.bounds.width, height: cell.cellView.bounds.height/4 - 5)
        cell.titleView.backgroundColor = UIColor.white
        
        // SHOWS THE LINE GAP BETWEEN TWO ITEMS
        cell.lineView.isHidden = false
        
        // HIDE THE DATE VIEW
        cell.dateView.isHidden = true
        
        //Hide price tag
        cell.contentName.isHidden = true
        
        cell.backgroundColor = tableViewBgColor
        cell.layer.borderColor = UIColor.white.cgColor
        
        var listingInfo:NSDictionary!
        if(UIDevice.current.userInterfaceIdiom == .pad){
            if(wishlistResponse.count > ((indexPath as NSIndexPath).row)*2 ){
                listingInfo = wishlistResponse[((indexPath as NSIndexPath).row)*2] as! NSDictionary
                cell.contentSelection.tag = ((indexPath as NSIndexPath).row)*2
                cell.menu.tag = ((indexPath as NSIndexPath).row)*2
            }
        }else{
            listingInfo = wishlistResponse[(indexPath as NSIndexPath).row] as! NSDictionary
            cell.contentSelection.tag = (indexPath as NSIndexPath).row
        }
        
        listingContentName = "\(listingInfo["title"]!)"
        self.contentUrl =  listingInfo["content_url"] as! String

        if productOrOthers == true{
            
            cell.contentSelection.addTarget(self, action: #selector(WishlistDetailViewController.showProduct(_:)), for: .touchUpInside)

        }
        else
        {
           cell.contentSelection.addTarget(self, action: #selector(WishlistDetailViewController.showListing(_:)), for: .touchUpInside)
        }

        cell.contentSelection.frame.size.height = 180
        
        // Set Content Image
        
        if let photoId = listingInfo["photo_id"] as? Int{
            
            if photoId != 0{
                
                cell.contentImage.backgroundColor = placeholderColor
                let url1 = URL(string: listingInfo["image"] as! NSString as String)
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
        
        let name = listingInfo["title"] as? String
        let tempInfo = ""
        
        cell.titleLabel.frame = CGRect(x: 10, y: 0, width: cell.titleView.bounds.width - 10, height: 30)
        cell.titleLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        cell.titleLabel.text = "\(name!)"
        cell.titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        cell.listingPriceTagLabel.frame = CGRect(x: cell.contentName.frame.origin.x - 5 , y: cell.titleView.frame.origin.y - 30, width: 5, height: 20)
        cell.listingPriceTagLabel.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        cell.listingPriceTagLabel.text = "\(priceTagIcon)"
        cell.listingPriceTagLabel.textColor = textColorDark
        cell.listingPriceTagLabel.isHidden = false
        
        
        
        cell.contentName.frame = CGRect(x: cell.titleView.frame.origin.x, y: cell.titleView.frame.origin.y - 30, width: cell.titleView.bounds.width - 10, height: 20)
        cell.contentName.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        cell.contentName.backgroundColor = UIColor.clear
        cell.contentName.textAlignment = NSTextAlignment.right
        
        if listingInfo.object(forKey: "price") != nil && (listingInfo["price"]  as? Double > 0.0 ){
            
            if listingInfo["currency"] != nil{
                
                let currencySymbol = getCurrencySymbol(listingInfo["currency"] as! String)
                profileCurrencySymbol = currencySymbol
                if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                    let defaults = UserDefaults.standard
                    if let name = defaults.object(forKey: "Currency")
                    {
                        let price = Float(truncating: (listingInfo["price"] as AnyObject) as! NSNumber)
                        let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)
                        let showPrice = (String(format:"%.2f", changePrice))
                        
                        cell.contentName.text =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                        
                    }
                }
                else{
                cell.contentName.text = "\(currencySymbol) \(listingInfo["price"]!)"
                }
                cell.contentName.isHidden = false
            }
        }
        
        cell.contentName.layer.shadowOpacity = 1
        
        cell.menuButton.isHidden = true
        
        
        //SHOWING CONTENT IN TITLE VIEW
        
        //SHOWING LOCATION
        let location = listingInfo["location"] as? String
        
        //IF LOCATION EXISTS
        if location != "" && location != nil{
            
            cell.dateLabel.frame = CGRect(x: 10, y: 25, width: (cell.contentImage.bounds.width-70), height: 20)
            cell.dateLabel.text = "\(tempInfo)"
            cell.dateLabel.textAlignment = NSTextAlignment.left
            cell.dateLabel.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            
            cell.locLabel.isHidden = false
            cell.locLabel.frame = CGRect(x: 10, y: 45, width: (cell.contentImage.bounds.width-70), height: 20)
            cell.locLabel.text = "\(locationIcon) \(location!)"
            cell.locLabel.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
            
            cell.listingDetailsLabel.frame = CGRect(x: 10, y: cell.locLabel.frame.origin.y + cell.locLabel.frame.height, width: (cell.contentImage.bounds.width-70), height: 20)
            
        }
        cell.dateLabel.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
        //IF LOCATION DOES NOT EXISTS
        if location == "" || location == nil{
            
            cell.locLabel.isHidden = true
            cell.dateLabel.frame = CGRect(x: 10, y: 25, width: (cell.contentImage.bounds.width-70), height: 20)
            cell.dateLabel.text = "\(locationIcon)  \(tempInfo)"
            cell.dateLabel.textAlignment = NSTextAlignment.left
            cell.dateLabel.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
            cell.listingDetailsLabel.frame = CGRect(x: 10, y: cell.dateLabel.frame.origin.y + cell.dateLabel.frame.height, width: (cell.contentImage.bounds.width-70), height: 20)
            
            
        }
        
        //SHOWING OWNERTITLE
        let listingOwnerTitle = listingInfo["owner_title"] as? String
        
        //IF OWNER TITLE EXISTS
        if listingOwnerTitle != "" && listingOwnerTitle != nil{
            
            var labMsg = ""
            if let postedDate = listingInfo["creation_date"] as? String{
                let postedOn = dateDifference(postedDate)
                
                labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), listingOwnerTitle!, postedOn)
                cell.listingDetailsLabel.isHidden = true
                cell.titleView.frame.size.height = cell.listingDetailsLabel.frame.origin.y + 5
                
            }
            
            cell.dateLabel.text = labMsg
            
        }
        
        // RHS
        if(UIDevice.current.userInterfaceIdiom == .pad){
            
            cell.dateView2.isHidden = true
            cell.dateView2.frame.size.height = 70
            cell.dateView2.backgroundColor = navColor
            
            cell.titleView2.frame.origin.x = cell.cellView.bounds.width
            cell.titleView2.frame.size.width = cell.cellView.bounds.width
            cell.titleView2.frame.size.height = 70
            cell.titleView2.backgroundColor = UIColor.white
            
            var listingInfo2:NSDictionary!
            if(wishlistResponse.count > (((indexPath as NSIndexPath).row)*2+1) ){
                listingInfo2 = wishlistResponse[(((indexPath as NSIndexPath).row)*2+1)] as! NSDictionary
                cell.cellView2.isHidden = false
                cell.contentSelection2.isHidden = false
                cell.dateView2.isHidden = false
                cell.titleView2.isHidden = false
                cell.contentSelection2.tag = (((indexPath as NSIndexPath).row)*2+1)
            }else{
                cell.cellView2.isHidden = true
                cell.contentSelection2.isHidden = true
                cell.dateView2.isHidden = true
                cell.titleView2.isHidden = true
                return cell
            }
            
            // Set Action to be performed on selection of any content
            
            if productOrOthers == true
            {
                
                cell.contentSelection2.addTarget(self, action: #selector(WishlistDetailViewController.showProduct(_:)), for: .touchUpInside)
            }
            else
            {
                cell.contentSelection2.addTarget(self, action: #selector(WishlistDetailViewController.showListing(_:)), for: .touchUpInside)
            }

            cell.contentImage2.frame.size.height = 250
            cell.contentSelection2.frame.size.height = 180
            
            // Set listing Image
            if let photoId = listingInfo2["photo_id"] as? Int{
                
                if photoId != 0{
                    cell.contentImage2.backgroundColor = placeholderColor
                    cell.contentImage2.image = nil
                    let url = URL(string: listingInfo2["image"] as! NSString as String)
                    
                    if url != nil
                    {
                        cell.contentImage2.kf.indicatorType = .activity
                        (cell.contentImage2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.contentImage2.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })

                    }
                    
                }else{
                    cell.contentImage2.backgroundColor = placeholderColor
                    cell.contentImage2.image =  imageWithImage( UIImage(named: "nophoto_group_thumb_profile.png")!, scaletoWidth: cell.contentImage.bounds.width)
                }
            }
            
            
            // Set listing Name
            
            let name = listingInfo2["title"] as? String
            var tempInfo = ""
            if let listingDate = listingInfo2["starttime"] as? String{
                
                let dateMonth = dateDifferenceWithTime(listingDate)
                var dateArrayMonth = dateMonth.components(separatedBy: ", ")
                
                if dateArrayMonth.count > 1{
                    cell.dateLabel3.frame = CGRect(x: 10, y: 5, width: 50, height: 60)
                    
                    cell.dateLabel3.numberOfLines = 0
                    cell.dateLabel3.text = "\(dateArrayMonth[1])\n\(dateArrayMonth[0])"
                    cell.dateLabel3.textColor = UIColor.white
                    cell.dateLabel3.font = UIFont(name: "FontAwesome", size: 18)
                }
                
                let date = dateDifferenceWithEventTime(listingDate)
                var DateC = date.components(separatedBy: ", ")
                tempInfo += "\(DateC[1]) \(DateC[0]) \(DateC[2])"
                
                if DateC.count > 3{
                    tempInfo += " at \(DateC[3])"
                }
            }
            else{
                cell.dateView2.isHidden = true
            }
            
            cell.titleLabel2.frame = CGRect(x: 10, y: 0, width: (cell.contentImage2.bounds.width-125), height: 30)
            cell.titleLabel2.text = "\(name!)"
            cell.titleLabel2.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            let location = listingInfo2["location"] as? String
            if location != "" && location != nil{
                
                cell.dateLabel2.frame = CGRect(x: 10, y: 25, width: (cell.contentImage2.bounds.width-70), height: 20)
                cell.dateLabel2.text = "\(tempInfo)"
                cell.dateLabel2.textAlignment = NSTextAlignment.left
                cell.dateLabel2.font = UIFont(name: "FontAwesome", size: 14)
                
                cell.locLabel2.isHidden = false
                cell.locLabel2.frame = CGRect(x: 10, y: 45, width: (cell.contentImage2.bounds.width-70), height: 20)
                cell.locLabel2.text = "\(locationIcon) \(location!)"
                cell.locLabel2.font = UIFont(name: "FontAwesome", size: 14)
                
            }
            
            if location == "" || location == nil{
                
                cell.locLabel2.isHidden = true
                cell.dateLabel2.frame = CGRect(x: 10, y: 35, width: (cell.contentImage2.bounds.width-70), height: 20)
                cell.dateLabel2.text = "\(tempInfo)"
                cell.dateLabel2.textAlignment = NSTextAlignment.left
                cell.dateLabel2.font = UIFont(name: "FontAwesome", size: 14)
                
            }
            
            cell.menuButton2.isHidden = true
            
            
            let listingOwnerTitle = listingInfo2["owner_title"] as? String
            
            if listingOwnerTitle != "" && listingOwnerTitle != nil{
                var labMsg = ""
                if let postedDate = listingInfo2["creation_date"] as? String{
                    let postedOn = dateDifference(postedDate)
                    
                    labMsg = String(format: NSLocalizedString("by %@ - %@", comment: ""), listingOwnerTitle!, postedOn)
                    cell.listingDetailsLabel2.isHidden = true
                    
                }
                
                cell.dateLabel2.text = labMsg
            }
            
            return cell
        }
        
        dynamicHeight = cell.titleView.frame.origin.y + cell.titleView.bounds.height
        cell.cellView.frame.size.height = dynamicHeight
        cell.lineView.frame.origin.y = dynamicHeight-5
        
        return cell
        
    }
    
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView)
//    {
//        if updateScrollFlag
//        {
//            // Check for Page Number for Browse Blog
//
//            if wishlistTableView.contentOffset.y >= wishlistTableView.contentSize.height - wishlistTableView.bounds.size.height{
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
//
//            }
//        }
//
//    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                // Check for Page Number for Browse Blog
                
//                if wishlistTableView.contentOffset.y >= wishlistTableView.contentSize.height - wishlistTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems)
                    {
                        if Reachabable.isConnectedToNetwork()
                        {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            wishlistTableView.tableFooterView?.isHidden = false
                         //   if searchDic.count == 0{
                                browseEntries()
                          //  }
                        }
                    }
                    else
                    {
                        wishlistTableView.tableFooterView?.isHidden = true
                }
                    
               // }
            }
            
        }
        
    }
    
    
    //MARK:Gutter Menu
    @objc func showMainGutterMenu()
    {
        
        // Generate wishlist Menu Come From Server as! Alert Popover
        
        deleteContent = false
        var confirmationTitle = ""
        var message = ""
        var url = ""
        var param: NSDictionary = [:]
        var confirmationAlert = true
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        for menu in contentGutterMenu
        {
            if let menuItem = menu as? NSDictionary
            {
                
                if (menuItem["name"] as! String != "share")
                {
                    let titleString = menuItem["name"] as! String
                    
                    if ((titleString.range(of: "delete") != nil))
                    {
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .destructive , handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            switch(condition){
                                
                            case "delete":
                                
                                self.deleteContent = true
                                confirmationTitle = NSLocalizedString("Delete Wishlist", comment: "")
                                message = NSLocalizedString("Are you sure you want to delete this Wishlist?", comment: "")
                                url = menuItem["url"] as! String
                                param = Dictionary<String, String>() as NSDictionary //menuItem["urlParams"] as! NSDictionary
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                            
                            if confirmationAlert == true
                            {
                                displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                    self.updateContentAction(param as NSDictionary, url: url)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        }))
                    }
                    else
                    {
                        alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            let condition = menuItem["name"] as! String
                            switch(condition){
                                
                            case "edit":
                                
                                confirmationAlert = false
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit Wishlist", comment: "")
                                if self.productOrOthers == true{
                                    presentedVC.contentType = "product wishlist"
                                }
                                else{
                                presentedVC.contentType = "wishlist"
                                }
                                presentedVC.url = menuItem["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                               
                            case "tellafriend":
                                
                                confirmationAlert = false
                                let presentedVC = TellAFriendViewController();
                                url = menuItem["url"] as! String
                                presentedVC.url = url
                                presentedVC.param = menuItem["urlParams"] as! NSDictionary
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                break
                                
                            case "report":
                                
                                confirmationAlert = false
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = menuItem["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "memberWishlist":
                                
                                confirmationAlert = false
                               // wishlistUpdate = true
                                searchDic.removeAll(keepingCapacity: false)
                                let presentedVC = WishlistSearchViewController()
                                let menuParams = menuItem["urlParams"] as! NSDictionary

                                presentedVC.productOrOthers = self.productOrOthers
                                if let text = menuParams["text"] as? String
                                {
                                  searchDic["text"] = "\(text)"
                                }

                                globalWishlistOwnerSearch = menuParams["text"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                                break
                            case "messageOwner":
                                
                                confirmationAlert = false
                                let presentedVC = MessageOwnerViewController();
                                url = menuItem["url"] as! String
                                presentedVC.url = url
                                presentedVC.param = (menuItem["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                break
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                            }
                            
                            if confirmationAlert == true
                            {
                                displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                    self.updateContentAction(param as NSDictionary,url: url)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        }))
                    }
                }}
        }
        
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel", comment: ""), style: .cancel, handler:nil))
        }
        else
        {
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        
        self.present(alertController, animated:true, completion: nil)
        
    }
    
    
    func updateContentAction(_ parameter: NSDictionary , url : String)
    {
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork()
        {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            var method = "POST"
            
            if (url.range(of: "delete") != nil)
            {
                method = "DELETE"
            }
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        
                        if msg
                        {
                            if succeeded["message"] != nil
                            {
                                showToast(message: succeeded["message"] as! String, controller: self)
                            }
                            
                            if self.deleteContent == true
                            {
                               //self.createTimer(self)
                                wishlistUpdate = true
                                _ = self.navigationController?.popViewController(animated: false)
                            }
                            
                            self.browseEntries()
                            
                        }
                            
                        else
                        {
                            // Handle Server Side Error
                            if succeeded["message"] != nil{
                               showToast(message: succeeded["message"] as! String, controller: self)
                                
                            }
                        }
                })
            }
            
        }
        else
        {
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
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
    // MARK: - Server Connection For wishlist Updation
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

                if updateAfterAlert == true
                {
                    removeAlert()
                    self.wishlistTableView.reloadData()
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
          //      spinner.center = view.center
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
            
            if productOrOthers == true
            {
              path = "sitestore/product/wishlist/" + String(self.subjectId)
            }
            else
            {
               path = "listings/wishlist/" + String(self.subjectId)
            }
            
            parameters = ["page":"\(pageNumber)","limit": "\(limit)"]
            
            // Send Server Request to Browse listing Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                        
                        if self.showSpinner
                        {
                            activityIndicatorView.stopAnimating()
                        }
                        self.refresher.endRefreshing()
                        self.showSpinner = false
                        self.updateScrollFlag = true
                        
                        
                        if msg
                        {
                            
                            if self.pageNumber == 1
                            {
                                self.wishlistResponse.removeAll(keepingCapacity: false)
                            }
                            
                            if succeeded["message"] != nil
                            {
                                showToast(message: succeeded["message"] as! String, controller: self)
                            }
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["response"] != nil
                                {
                                    if let wishlist = response["response"] as? NSDictionary
                                    {
                                        
                                        if let wishlistDescriptionBody = wishlist["body"] as? String{
                                            self.wishlistDescriptionLabel.text = wishlistDescriptionBody
                                            self.wishlistDescriptionLabel.numberOfLines = 0
                                            self.wishlistDescriptionLabel.sizeToFit()

                                            self.wishlistDescriptionView.frame.size.height = self.wishlistDescriptionLabel.bounds.height + 5
                                            self.wishlistTableView.frame.origin.y = self.wishlistDescriptionView.frame.origin.y + self.wishlistDescriptionView.bounds.height + 10
                                            self.wishlistTableView.frame.size.height = self.view.bounds.height - tabBarHeight - (self.wishlistTableView.frame.origin.y)

                                            
                                            if self.wishlistDescriptionLabel.text == "" || self.wishlistDescriptionLabel.text == nil{
                                                    self.wishlistDescriptionView.isHidden = true
                                                    self.wishlistTableView.frame.origin.y = 0
                                            }else{
                                                self.wishlistDescriptionView.isHidden = false
                                            }
                                            
                                        }
                                        
                                        self.contentImageUrls = wishlist["owner_image"] as! String
                                        self.contentTitle = "\(wishlist["title"]!)"
                                        if self.productOrOthers == true
                                        {

                                            if let listing = wishlist["products"]as? NSArray
                                            {
                                                self.wishlistResponse = self.wishlistResponse + (listing as [AnyObject])
                                            }

                                        }
                                        else
                                        {
                                            if let listing = wishlist["listing"]as? NSArray
                                            {
                                                self.wishlistResponse = self.wishlistResponse + (listing as [AnyObject])
                                            }

                                        }
                                       


                                        //MARK: - check it this code is required
                                        var pageTitle = self.wishlistName
                                        self.totalItemCount = self.wishlistResponse.count
                                        if self.totalItemCount != nil{
                                            pageTitle = self.wishlistName + ": " + String(self.totalItemCount)
                                        }
//                                        self.title = NSLocalizedString("\(pageTitle)",  comment: "")
                                        
                                        if let navigationBar = self.navigationController?.navigationBar {
                                            if self.marqueeHeader != nil{
                                            self.marqueeHeader.text = ""
                                            removeMarqueFroMNavigaTion(controller: self)
                                            }
                                            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
                                            self.marqueeHeader = MarqueeLabel(frame: firstFrame)
                                            self.marqueeHeader.tag = 101
                                            self.marqueeHeader.setDefault()
                                            self.marqueeHeader.text = pageTitle
                                            self.marqueeHeader.textColor = textColorPrime
                                            navigationBar.addSubview(self.marqueeHeader)
                                        }
                                        
                                    }
                                }
                                
                                
                                if logoutUser == false{
                                    
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")!.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    shareButton.addTarget(self, action: #selector(WishlistDetailViewController.shareItem), for: .touchUpInside)
                                    rightNavView.addSubview(shareButton)
                                    
                                    let optionButton = createButton(CGRect(x: 44,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")!.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    optionButton.addTarget(self, action: #selector(WishlistDetailViewController.showMainGutterMenu), for: .touchUpInside)
                                    rightNavView.addSubview(optionButton)
                                    
                                    let barButtonItem = UIBarButtonItem(customView: rightNavView)
                                    
                                    self.navigationItem.rightBarButtonItem = barButtonItem
                                }
                            }
                            
                            // Update Content Gutter Menu
                            if let contentInfo = succeeded["body"] as? NSDictionary
                            {
                                if let menu = contentInfo["gutterMenus"] as? NSArray
                                {
                                    self.contentGutterMenu = menu
                                    
                                    for tempMenu in self.contentGutterMenu
                                    {
                                        if let tempDic = tempMenu as? NSDictionary
                                        {
                                            
                                            if tempDic["name"] as! String == "share"
                                            {
                                                self.shareUrl = tempDic["url"] as! String
                                                self.shareParam = tempDic["urlParams"] as! NSDictionary
                                            }
                                        }
                                    }
                                    
                                }
                            }
                            
                            var pageTitle = self.wishlistName
                            if self.totalItemCount != nil{
                                pageTitle = self.wishlistName + ": \(self.totalItemCount!)"
                            }
                            self.marqueeHeader.text = "\(pageTitle!)"
                            self.isPageRefresing = false
                            self.wishlistTableView.reloadData()
                            if self.wishlistResponse.count == 0
                            {
                                
                                self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(listingDefaultIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                                self.mainView.addSubview(self.contentIcon)
                                
                                if self.productOrOthers == true
                                {
                                    self.info = createLabel(CGRect(x:0, y:0, width:self.mainView.bounds.width * 0.8, height:50), text: NSLocalizedString("There are currently no products in this wishlist.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                }
                                else
                                {
                                    self.info = createLabel(CGRect(x:0, y:0, width:self.mainView.bounds.width * 0.8, height:50), text: NSLocalizedString("There are currently no listings in this wishlist.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                }

                                self.info.numberOfLines = 0
                                self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                                self.info.center = self.mainView.center
                                self.info.backgroundColor = bgColor
                                self.info.tag = 1000
                                self.mainView.addSubview(self.info)
                                
                                self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                                self.refreshButton.backgroundColor = bgColor
                                self.refreshButton.layer.borderColor = navColor.cgColor
                                self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)

                                self.refreshButton.addTarget(self, action: #selector(WishlistDetailViewController.browseEntries), for: UIControl.Event.touchUpInside)

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
    
    @objc func shareItem(){
        
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title:  String(format: NSLocalizedString("Share on %@", comment: ""),app_title), style: .default) { action -> Void in
            let pv = AdvanceShareViewController()
            pv.url = self.shareUrl
            pv.param = self.shareParam as! [AnyHashable : Any] as NSDictionary
            pv.Sharetitle = self.contentTitle
            pv.imageString = self.contentImageUrls
            pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: pv)
            self.present(nativationController, animated:true, completion: nil)
            
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share Outside", comment: ""), style: UIAlertAction.Style.default) { action -> Void in
            
            var sharingItems = [AnyObject]()
            
            if let text = self.contentTitle {
                sharingItems.append(text as AnyObject)
            }
            
            if let url = self.contentUrl {
                let finalUrl = URL(string: url)!
                sharingItems.append(finalUrl as AnyObject)
            }
            
            let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                
                if(activityViewController.popoverPresentationController != nil) {
                    activityViewController.popoverPresentationController?.sourceView = self.view;
                    let frame = UIScreen.main.bounds
                    activityViewController.popoverPresentationController?.sourceRect = frame;
                }
            } else {
                let presentationController = activityViewController.popoverPresentationController
                presentationController?.sourceView = self.view
                presentationController?.sourceRect = CGRect(x: self.view.bounds.width/2 , y: self.view.bounds.width/2, width: 0, height: 0)
                presentationController?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            
            self.present(activityViewController, animated: true, completion: nil)
            
            })
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel", comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = self.view
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        
        self.present(alertController, animated:true, completion: nil)
    }
}
