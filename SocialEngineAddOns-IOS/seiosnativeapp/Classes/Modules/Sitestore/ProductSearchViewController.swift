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

//  ProductSearchViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 03/02/16.
//  Copyright © 2016 bigstep. All rights reserved.

import UIKit
import Foundation
import NVActivityIndicatorView

class ProductSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    var currency : String = ""
    var searchBar = UISearchBar()
    var productTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                     // not show spinner at pull to refresh
    var updateScrollFlag = false
    var refresher:UIRefreshControl!             // Pull to refrresh
    var isPageRefresing = false                 // For Pagination
    var dynamicHeight:CGFloat = 75              // Dynamic Height fort for Cell
    var search : String!
   // var imageCache = [String:UIImage]()
    var categ_id : Int!
    var listingId : Int!
    let mainView = UIView()
    var showOnlyMyContent:Bool!
    var noContentView = NoContentView()
    var countListTitle : String!
    var productResponse = [AnyObject]()        // For response come from Server
    var browseOrMyListings = true               // True for Browse Listings & False for My Listings
    var fromTab : Bool!
    var user_id : Int!
    var editListingID:Int = 0
  //  var imageCache1 = [String:UIImage]()
    var ownerLabel : UILabel!
    var size:CGFloat = 0;
    var listingTypeId:Int!
    var scrollView = UIScrollView()
    
    var listingOption:UIButton!
    var listingBrowseType:Int!
    var fromSearch: Bool!
    var viewSearchType : Int!
    var listingSearchName = ""
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    override func viewDidLoad() {
        
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        super.viewDidLoad()
        
//        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search \(listingSearchName)",  comment: ""))
//        searchBar.delegate = self

        _ = SearchBarContainerView(self, customSearchBar:searchBar)

        searchBar.setPlaceholderWithColor(NSLocalizedString("Search \(listingSearchName)",  comment: ""))
        searchBar.delegate = self
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ProductSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        
        
        
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(ProductSearchViewController.filter))
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State.normal)
        
        self.navigationItem.rightBarButtonItem = filter
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        mainView.frame = view.frame
        mainView.backgroundColor = UIColor.white
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        noContentView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        mainView.addSubview(noContentView)
        noContentView.isHidden = true
        
        
        productTableView = UITableView(frame: CGRect(x:0,y:0, width:view.bounds.width, height:view.bounds.height - tabBarHeight - TOPPADING), style:.grouped)
        
        productTableView.register(ProductTableViewCell.self, forCellReuseIdentifier: "Cell")
        productTableView.rowHeight = 253.0
        productTableView.dataSource = self
        productTableView.delegate = self
        productTableView.isOpaque = false
        productTableView.backgroundColor = bgColor
        productTableView.backgroundColor = bgColor
        productTableView.separatorColor = UIColor.clear
        productTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            productTableView.estimatedRowHeight = 0
            productTableView.estimatedSectionHeaderHeight = 0
            productTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(productTableView)
        productTableView.isHidden = true
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        productTableView.tableFooterView = footerView
        productTableView.tableFooterView?.isHidden = true
      
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
    // Check for Products Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {

        if searchDic.count > 0 {
            if globFilterValue != ""{
                searchBar.text = globFilterValue
            }
            showSpinner = true
            pageNumber = 1
            searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
            self.browseEntries()
        }
        
        
    }
    // Update Products
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }

            noContentView.isHidden = true
            
            if (self.pageNumber == 1){
                
                if updateAfterAlert == true || searchDic.count > 0 {
                    self.productResponse.removeAll(keepingCapacity: false)
                    removeAlert()
                    self.productTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
              //  spinner.center = mainView.center
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
            
            
            // Set Parameters for Search
            path = "sitestore/product/browse"
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Products Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                  // self.tblAutoSearchSuggestions.isHidden = true
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    
                    //self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.productResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            
                            if response["response"] != nil {
                                if let listing = response["response"] as? NSArray {
                                    self.productResponse = self.productResponse + (listing as [AnyObject])
                                }
                            }
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            if response["currency"] != nil{
                                self.currency = response["currency"] as! String
                            }
                        }
                        
                        self.isPageRefresing = false
                        
                        //Reload Listing Table
                        self.productTableView.reloadData()
                        if self.productResponse.count == 0{
                            self.noContentView.frame = CGRect(x: self.view.bounds.width/2 - 150,y: self.view.bounds.height/2-170,width: 300 , height: 300)
                            self.mainView.addSubview(self.noContentView)
                            self.noContentView.isHidden = false
                            self.noContentView.button.layer.borderWidth = 1
                            self.noContentView.button.layer.borderColor = buttonColor.cgColor
                            self.noContentView.button.setTitle("Try Again", for: .normal)
                            self.noContentView.button.isHidden = true
                            self.noContentView.button.setTitleColor(UIColor.white, for: .normal)
                            self.noContentView.button.backgroundColor = buttonColor
                            self.noContentView.button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                            self.noContentView.button.addTarget(self, action: #selector(ProductSearchViewController.browseEntries), for: .touchUpInside)
                            self.noContentView.label.text = "You do not have any product entries"
                            
                            self.searchBar.resignFirstResponder()
                            
                        }
                        else
                        {
                            if self.tblAutoSearchSuggestions.isHidden == true
                            {
                                self.productTableView.isHidden = false
                            }
                            
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
    func showAlertMessage( centerPoint: CGPoint, msg: String, timer: Bool){
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
    
    // Set Products Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView.tag == 11{
            return 0.00001
        }
        else{
            
            if (limit*pageNumber < totalItems){
                return 0
            }else{
                return 0.00001
            }
        }
    }
    
    // Set Products Tabel Header Height
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
        return 230
        }
    }
    
    // Set Products Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else
        {
        return Int(ceil(Float(productResponse.count)/2))
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
           // {
                cell.imgSearch.isHidden = false
                cell.labTitle.frame = CGRect(x: cell.imgSearch.bounds.width + 24, y: 0,width: UIScreen.main.bounds.width - (cell.imgSearch.bounds.width + 24), height: 45)
                // cell.labTitle.center.y = cell.bounds.midY + 5
                cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
                cell.labTitle.text = blogInfo
                cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.labTitle.numberOfLines = 2
                //  cell.labTitle.sizeToFit()
           // }
            cell.imgUser.isHidden = true
            return cell
        }
        else
        {
        let row = indexPath.row as Int
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! ProductTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = bgColor
        
        var index:Int!
        if(UIDevice.current.userInterfaceIdiom == .pad)
        {
            index = row * 2
            
        }
        else
        {
            index = row * 2
        }
        
        
        if productResponse.count > index {
            cell.contentSelection.isHidden = false
            cell.classifiedImageView.isHidden = false
            cell.classifiedName.isHidden = false
            cell.ratings.isHidden = false
            cell.classifiedImageView.image = nil
            cell.descriptionView.isHidden = false
            cell.actualPrice.isHidden = false
            
            if let productInfo = productResponse[index] as? NSDictionary {
                // LHS
                if let url = NSURL(string: productInfo["image"] as! String){
                    cell.classifiedImageView.kf.indicatorType = .activity
                    (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.classifiedImageView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                    
                }
                if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                    cell.featuredLabel.isHidden = false
                }else{
                    cell.featuredLabel.isHidden = true
                }
                
                if productInfo["sponsored"] != nil && productInfo["sponsored"] as! Int == 1{
                    
                    cell.sponsoredLabel.frame = CGRect(x:0, y:0, width:70, height:20)
                    if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                        cell.sponsoredLabel.frame = CGRect(x:0, y:25, width:70, height:20)
                    }
                    cell.sponsoredLabel.isHidden = false
                }else{
                    cell.sponsoredLabel.isHidden = true
                }
                
                var title = productInfo["title"] as! String
                if title.length > 30{
                    title = (title as NSString).substring(to: 30-3)
                    title  = title + "..."
                }
                
                cell.classifiedName.text = title
                cell.classifiedName.sizeToFit()
                cell.classifiedName.frame.size.width =  cell.descriptionView1.bounds.width-5
                cell.ratings.frame.origin.y = cell.classifiedName.frame.size.height + cell.classifiedName.frame.origin.y + 5
                
                if let rating = productInfo["rating_avg"] as? Int
                {
                    cell.updateRating(rating: rating, ratingCount: rating)
                }
                else
                {
                    cell.updateRating(rating: 0, ratingCount: 0)
                }
                
                cell.actualPrice.frame.origin.y = cell.ratings.frame.origin.y + cell.ratings.bounds.height
                cell.discountedPrice.frame.origin.y = cell.ratings.frame.origin.y + cell.ratings.bounds.height
                
                
                
                cell.contentSelection.tag = index as Int
                cell.contentSelection.addTarget(self, action:  #selector(ProductSearchViewController.showProduct), for: .touchUpInside)
                
                if logoutUser == false{
                    
                    
                    if let menu = productInfo["menu"] as? NSArray{
                        for menuitem in menu{
                            
                            let menuitem = menuitem as! NSDictionary
                            if menuitem["name"] as! String == "wishlist"{
                                
                                cell.menu.isHidden = false
                                cell.menu.tag = index as Int
                                cell.menu.addTarget(self, action:#selector(ProductSearchViewController.addToWishlist) , for: .touchUpInside)
                                if let _ = productInfo["wishlist"] as? NSArray{
                                    cell.menu.setTitleColor(UIColor.red, for: .normal)
                                }
                                else{
                                    cell.menu.setTitleColor(textColorLight, for: .normal)
                                }
                                
                            }
                        }
                        
                        
                    }
                }
                var totalView = ""
                if let information = productInfo["information"] as? NSDictionary{
                    if let price = information["price"] as? NSDictionary{
                        if let discount = price["discount"] as? CGFloat{
                            if discount == 1{
                                
                                if let productType = productInfo["product_type"] as? String{
                                    if productType == "grouped"{
                                        
                                        cell.actualPrice.text = NSLocalizedString("Start at:", comment: "")
                                        cell.actualPrice.sizeToFit()
                                    }
                                    else{
                                        if let views = price["discounted_amount"] as? Double{
                                            cell.discountedPrice.isHidden = false
                                            cell.discountedPrice.frame.origin.x = 5
                                            let formatter = NumberFormatter()
                                            formatter.numberStyle = .currency
                                            formatter.locale = NSLocale.current // This is the default
                                            formatter.currencyCode = "\(currency)"
                                            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                                let defaults = UserDefaults.standard
                                                if let name = defaults.object(forKey: "Currency")
                                                {
                                                    let price = gettwoFractionDigits(FractionDigit: "\(views)")
                                                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                                    let showPrice = (String(format:"%.2f", changePrice))
                                                    
                                                    totalView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                                    
                                                }
                                            }
                                            else{
                                                totalView += formatter.string(from: NSNumber(value: views))!
                                            }
                                           // totalView += formatter.string(from: NSNumber(value: views))! // $123"
                                            if let signValue = price["sign"] as? Int{
                                                if signValue == 1{
                                                    cell.discountedPrice.text = "\(totalView)*"
                                                }
                                                else{
                                                    cell.discountedPrice.text = "\(totalView)"
                                                }
                                            }
                                            else{
                                                cell.discountedPrice.text = "\(totalView)"
                                            }
                                            cell.discountedPrice.sizeToFit()
                                        }
                                    }
                                }
                                if let ratingAvg = price["price"] as? Double{
                                    
                                    cell.actualPrice.isHidden = false
                                    cell.actualPrice.frame.origin.x =  getRightEdgeX(inputView: cell.discountedPrice) + 5
                                    var ratingView = ""
                                    let formatter = NumberFormatter()
                                    formatter.numberStyle = .currency
                                    formatter.locale = NSLocale.current // This is the default
                                    formatter.currencyCode = "\(currency)"
                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                        let defaults = UserDefaults.standard
                                        if let name = defaults.object(forKey: "Currency")
                                        {
                                            let price = gettwoFractionDigits(FractionDigit: "\(ratingAvg)")
                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                            let showPrice = (String(format:"%.2f", changePrice))
                                            
                                            ratingView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                            
                                        }
                                    }
                                    else{
                                        ratingView += formatter.string(from: NSNumber(value: ratingAvg))!
                                    }
                                  //  ratingView += formatter.string(from: NSNumber(value: ratingAvg))! // $123"
                                    cell.actualPrice.text = "\(ratingView)"
                                    cell.actualPrice.sizeToFit()
                                    cell.actualPrice.frame.size.width = cell.actualPrice.bounds.width
                                    let viewBorder = UIView(frame:CGRect(x:0, y: 6, width: cell.actualPrice.frame.size.width, height: 1))
                                    viewBorder.backgroundColor = UIColor.black
                                    viewBorder.tag = 1002
                                    cell.actualPrice.addSubview(viewBorder)
                                    
                                }
                                
                            }
                            else{
                                cell.discountedPrice.isHidden = true
                                for ob in cell.actualPrice.subviews{
                                    if ob.tag == 1002 {
                                        ob.removeFromSuperview()
                                    }
                                    
                                    
                                }
                                if let views = price["price"] as? Double{
                                    cell.actualPrice.frame.origin.x = 5
                                    let formatter = NumberFormatter()
                                    formatter.numberStyle = .currency
                                    formatter.locale = NSLocale.current // This is the default
                                    formatter.currencyCode = "\(currency)"
                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                        let defaults = UserDefaults.standard
                                        if let name = defaults.object(forKey: "Currency")
                                        {
                                            let price = gettwoFractionDigits(FractionDigit: "\(views)")
                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                            let showPrice = (String(format:"%.2f", changePrice))
                                            
                                            totalView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                            
                                        }
                                    }
                                    else{
                                        totalView += formatter.string(from: NSNumber(value: views))!
                                    }
                                   // totalView += formatter.string( from: NSNumber(value: views))! // $123"
                                    if let productType = productInfo["product_type"] as? String{
                                        if productType == "grouped"{
                                            if let signValue = price["sign"] as? Int{
                                                if signValue == 1{
                                                    cell.actualPrice.text = String(format: NSLocalizedString("Start at: %@*", comment: ""),"\(totalView)")
                                                    
                                                }
                                                else{
                                                    cell.actualPrice.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                }
                                            }
                                            else{
                                                cell.actualPrice.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                
                                            }
                                        }
                                        else{
                                            
                                            if let signValue = price["sign"] as? Int{
                                                if signValue == 1{
                                                    cell.actualPrice.text = "\(totalView)*"
                                                }
                                                else{
                                                    cell.actualPrice.text = "\(totalView)"
                                                }
                                            }
                                            else{
                                                cell.actualPrice.text = "\(totalView)"
                                            }
                                            
                                        }
                                    }
                                    cell.actualPrice.sizeToFit()
                                }
                                
                            }
                            
                            
                        }
                    }
                }
            }
            
            
        }
        else
        {
            cell.contentSelection.isHidden = true
            cell.classifiedImageView.isHidden = true
            cell.classifiedName.isHidden = true
            cell.ratings.isHidden = true
            cell.discountedPrice.isHidden = true
            cell.actualPrice.isHidden = true
            cell.descriptionView.isHidden = true
            
            cell.contentSelection1.isHidden = true
            cell.productImageView1.isHidden = true
            cell.classifiedName1.isHidden = true
            cell.ratings1.isHidden = true
            cell.descriptionView1.isHidden = true
            cell.discountedPrice1.isHidden = true
            cell.actualPrice1.isHidden = true
        }
        
        
        if productResponse.count > (index + 1){
            cell.contentSelection1.isHidden = false
            cell.productImageView1.isHidden = false
            cell.classifiedName1.isHidden = false
            cell.ratings1.isHidden = false
            cell.descriptionView1.isHidden = false
            cell.discountedPrice1.isHidden = false
            cell.actualPrice1.isHidden = false
            cell.productImageView1.image = nil
            if let productInfo = productResponse[index + 1] as? NSDictionary {
                
                if let url = NSURL(string: productInfo["image"] as! String){
                    cell.productImageView1.kf.indicatorType = .activity
                    (cell.productImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.productImageView1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                    cell.featuredLabel1.isHidden = false
                }else{
                    cell.featuredLabel1.isHidden = true
                }
                
                if productInfo["sponsored"] != nil && productInfo["sponsored"] as! Int == 1{
                    
                    cell.sponsoredLabel1.frame = CGRect(x:0, y:0, width:70, height:20)
                    if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                        cell.sponsoredLabel1.frame = CGRect(x:0, y:25, width:70, height:20)
                    }
                    cell.sponsoredLabel1.isHidden = false
                }else{
                    cell.sponsoredLabel1.isHidden = true
                }
                
                var title = productInfo["title"] as! String
                if title.length > 30{
                    title = (title as NSString).substring(to: 30-3)
                    title  = title + "..."
                }
                cell.classifiedName1.text = title
                cell.classifiedName1.sizeToFit()
                cell.classifiedName1.frame.size.width =  cell.descriptionView1.bounds.width-5
                cell.ratings1.frame.origin.y = cell.classifiedName1.frame.size.height + cell.classifiedName1.frame.origin.y + 5
                
                if let rating = productInfo["rating_avg"] as? Int
                {
                    cell.updateRating1(rating: rating, ratingCount: rating)
                }
                else
                {
                    cell.updateRating1(rating: 0, ratingCount: 0)
                }
                
                
                cell.actualPrice1.frame.origin.y = cell.ratings1.frame.origin.y + cell.ratings1.bounds.height
                cell.discountedPrice1.frame.origin.y = cell.ratings1.frame.origin.y + cell.ratings1.bounds.height
                
                
                
                cell.contentSelection1.tag = (index + 1) as Int
                cell.contentSelection1.addTarget(self, action: #selector(ProductSearchViewController.showProduct), for: .touchUpInside)
                
                
                if logoutUser == false{
                    
                    
                    if let menu = productInfo["menu"] as? NSArray{
                        for menuitem in menu{
                            
                            let menuitem = menuitem as! NSDictionary
                            if menuitem["name"] as! String == "wishlist"{
                                
                                cell.menu1.isHidden = false
                                cell.menu1.tag = (index + 1) as Int
                                cell.menu1.addTarget(self, action:#selector(ProductSearchViewController.addToWishlist) , for: .touchUpInside)
                                if let _ = productInfo["wishlist"] as? NSArray{
                                    cell.menu1.setTitleColor(UIColor.red, for: .normal)
                                }
                                else{
                                    cell.menu1.setTitleColor(textColorLight, for: .normal)
                                }
                                
                            }
                        }
                        
                        
                    }
                    
                }
                var totalView = ""
                
                if let information = productInfo["information"] as? NSDictionary{
                    if let price = information["price"] as? NSDictionary{
                        if let discount = price["discount"] as? CGFloat{
                            if discount == 1{
                                
                                if let productType = productInfo["product_type"] as? String{
                                    if productType == "grouped"{
                                        
                                        cell.actualPrice1.text = NSLocalizedString("Start at:", comment: "")
                                        cell.actualPrice1.sizeToFit()
                                    }
                                    else{
                                        if let views = price["discounted_amount"] as? Double{
                                            cell.discountedPrice1.isHidden = false
                                            cell.discountedPrice1.frame.origin.x = 5
                                            let formatter = NumberFormatter()
                                            formatter.numberStyle = .currency
                                            formatter.locale = NSLocale.current // This is the default
                                            formatter.currencyCode = "\(currency)"
                                            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                                let defaults = UserDefaults.standard
                                                if let name = defaults.object(forKey: "Currency")
                                                {
                                                    let price = gettwoFractionDigits(FractionDigit: "\(views)")
                                                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                                    let showPrice = (String(format:"%.2f", changePrice))
                                                    
                                                    totalView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                                    
                                                }
                                            }
                                            else{
                                                totalView += formatter.string(from: NSNumber(value: views))!
                                            }
                                          //  totalView += formatter.string(from: NSNumber(value: views))! // $123"
                                            if let signValue = price["sign"] as? Int{
                                                if signValue == 1{
                                                    cell.discountedPrice1.text = "\(totalView)*"
                                                }
                                                else{
                                                    cell.discountedPrice1.text = "\(totalView)"
                                                }
                                            }
                                            else{
                                                cell.discountedPrice1.text = "\(totalView)"
                                            }
                                            cell.discountedPrice1.sizeToFit()
                                        }
                                    }
                                }
                                if let ratingAvg = price["price"] as? Double{
                                    
                                    cell.actualPrice1.isHidden = false
                                    cell.actualPrice1.frame.origin.x =  getRightEdgeX(inputView: cell.discountedPrice1) + 5
                                    var ratingView = ""
                                    let formatter = NumberFormatter()
                                    formatter.numberStyle = .currency
                                    formatter.locale = NSLocale.current // This is the default
                                    formatter.currencyCode = "\(currency)"
                                    
                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                        let defaults = UserDefaults.standard
                                        if let name = defaults.object(forKey: "Currency")
                                        {
                                            let price = gettwoFractionDigits(FractionDigit: "\(ratingAvg)")
                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                            let showPrice = (String(format:"%.2f", changePrice))
                                            
                                            ratingView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                            
                                        }
                                    }
                                    else{
                                        ratingView += formatter.string(from: NSNumber(value: ratingAvg))!
                                    }
                                    
                                   // ratingView += formatter.string(from: NSNumber(value: ratingAvg))! // $123"
                                    cell.actualPrice1.text = "\(ratingView)"
                                    cell.actualPrice1.sizeToFit()
                                    cell.actualPrice1.frame.size.width = cell.actualPrice1.bounds.width
                                    let viewBorder1 = UIView(frame:CGRect(x:0, y: 6, width: cell.actualPrice1.frame.size.width, height: 1))
                                    viewBorder1.backgroundColor = UIColor.black
                                    viewBorder1.tag = 1003
                                    cell.actualPrice1.addSubview(viewBorder1)
                                    
                                }
                                
                            }
                            else{
                                cell.discountedPrice1.isHidden = true
                                for ob in cell.actualPrice1.subviews{
                                    if ob.tag == 1003 {
                                        ob.removeFromSuperview()
                                    }
                                    
                                    
                                }
                                if let views = price["price"] as? Double{
                                    cell.actualPrice1.frame.origin.x = 5
                                    let formatter = NumberFormatter()
                                    formatter.numberStyle = .currency
                                    formatter.locale = NSLocale.current // This is the default
                                    formatter.currencyCode = "\(currency)"
                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                        let defaults = UserDefaults.standard
                                        if let name = defaults.object(forKey: "Currency")
                                        {
                                            let price = gettwoFractionDigits(FractionDigit: "\(views)")
                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                            let showPrice = (String(format:"%.2f", changePrice))
                                            
                                            totalView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                            
                                        }
                                    }
                                    else{
                                        totalView += formatter.string(from: NSNumber(value: views))!
                                    }
                                  //  totalView += formatter.string( from: NSNumber(value: views))! // $123"
                                    if let productType = productInfo["product_type"] as? String{
                                        if productType == "grouped"{
                                            if let signValue = price["sign"] as? Int{
                                                if signValue == 1{
                                                    cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@*", comment: ""),"\(totalView)")
                                                    
                                                }
                                                else{
                                                    cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                }
                                            }
                                            else{
                                                cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                
                                            }
                                        }
                                        else{
                                            
                                            if let signValue = price["sign"] as? Int{
                                                if signValue == 1{
                                                    cell.actualPrice1.text = "\(totalView)*"
                                                }
                                                else{
                                                    cell.actualPrice1.text = "\(totalView)"
                                                }
                                            }
                                            else{
                                                cell.actualPrice1.text = "\(totalView)"
                                            }
                                            
                                        }
                                    }
                                    cell.actualPrice1.sizeToFit()
                                }
                                
                            }
                            
                            
                        }
                    }
                }
                
                
            }
            
        }
        else{
            cell.contentSelection1.isHidden = true
            cell.productImageView1.isHidden = true
            cell.classifiedName1.isHidden = true
            cell.ratings1.isHidden = true
            cell.discountedPrice1.isHidden = true
            cell.actualPrice1.isHidden = true
            cell.descriptionView1.isHidden = true
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
                self.productTableView.isHidden = true
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
                // Check for Page Number for Browse Products
//                if productTableView.contentOffset.y >= productTableView.contentSize.height - productTableView.bounds.size.height{
                    if (limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                             productTableView.tableFooterView?.isHidden = false
                            browseEntries()
                        }
                    }
                    else
                    {
                        productTableView.tableFooterView?.isHidden = true
                }
                    
              //  }
                
            }
            
        }
        }
    }
    
    @objc func cancel(){
        listingUpdate = false
         _ = self.navigationController?.popViewController(animated: false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = searchBar.text
        
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
                self.productTableView.isHidden = true
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
        
        filterSearchString = searchBar.text!
        pageNumber = 1
        showSpinner = true
     //   searchBar.resignFirstResponder()
        
        browseEntries()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    
    // Filter Search of Products
    @objc func filter(){
        if filterSearchFormArray.count > 0 {
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "products"
            presentedVC.url = "sitestore/product/product-search-form"
            presentedVC.contentType = "products"
            presentedVC.stringFilter = searchBar.text!
            
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            
            presentedVC.searchUrl = "sitestore/product/product-search-form"
            presentedVC.serachFor = "products"
            presentedVC.url = "sitestore/product/product-search-form"
            presentedVC.contentType = "products"
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    
    // Add products in  Wishlist
    @objc func addToWishlist(sender : UIButton){
        var productInfo:NSDictionary!
        productInfo = productResponse[sender.tag] as! NSDictionary
        let product_id =   productInfo["product_id"] as! Int
        if let menu = productInfo["menu"] as? NSArray{
            for menuitem in menu{
                let menuitem = menuitem as! NSDictionary
                if menuitem["name"] as! String == "wishlist"{
                    let presentedVC = FormGenerationViewController()
                    presentedVC.formTitle = NSLocalizedString("Add To Wishlist", comment: "")
                    presentedVC.contentType = "product wishlist"
                    presentedVC.url = menuitem["url"] as! String
                    var tempDic = NSDictionary()
                    tempDic = ["product_id" : "\(product_id)"]
                    presentedVC.param = tempDic
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    self.present(nativationController, animated:false, completion: nil)

                }
            }
        }
    }
    
    // Show product Profile After Click on Products
    @objc func showProduct(sender: UIButton){
        if let productInfo = productResponse[sender.tag] as? NSDictionary {
            if let videoTitle = productInfo["title"] as? String {
                updateAutoSearchArray(str: videoTitle)
            }
            _ =   productInfo["store_id"] as? Int
            let product_id =  "\(productInfo["product_id"]!)"
            
            SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id:product_id)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = textColorPrime
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        searchBar.resignFirstResponder()
        productTableView.tableFooterView?.isHidden = true
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    
    
    
    
}
