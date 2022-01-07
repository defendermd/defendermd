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

//  ProductCategoriesDetailViewController.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 03/02/16.
//  Copyright © 2016 bigstep. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ProductCategoriesDetailViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate , UITabBarControllerDelegate
{
    
    var subjectId:Int!
    var subjectType:String!
    var subcatid:Int!
    var subsubcatid:Int!
    var totalItemCount:Int!
    var tittle: String!
    let mainView = UIView()
    var productTableView:UITableView!
    var productResponse = [AnyObject]()
    var refresher:UIRefreshControl!
    var refreshButton : UIButton!
    var contentIcon : UILabel!
    var feedFilter: UIButton!
    var feedFilter2: UIButton!
    var currency : String = ""
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var updateScrollFlag = true
    var Subcategoryarr = [AnyObject]()
    var SubSubcategoryarr = [AnyObject]()
    var showSpinner = true
    var isPageRefresing = false
    var info:UILabel!
    var categoryType : String = ""
    var marqueeHeader : MarqueeLabel!
    var deleteContent : Bool!
    var contentTitle : String!
    var contentDescription : String!
    
    
    var shareUrl : String!
    var shareParam : NSDictionary!
    
    var subcategory: String!
    var subsubcategory: String!
   // var imageCache = [String:UIImage]()
    var popAfterDelay : Bool!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        productUpdate = false
        subcategory = ""
        subsubcategory = ""
        self.tabBarController?.delegate = self
        
        view.backgroundColor = bgColor
        mainView.frame = view.frame
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        openMenu = false
        updateAfterAlert = true
        evetUpdate = true
        
        
        let subViews = mainView.subviews
        for subview in subViews
        {
            subview.removeFromSuperview()
        }
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ProductCategoriesDetailViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        // Product Table View to Show Products
        productTableView = UITableView(frame: CGRect(x:0, y:0, width:view.bounds.width, height:view.bounds.height-(tabBarHeight)), style:.grouped)
        productTableView.register(ProductTableViewCell.self, forCellReuseIdentifier: "Cell")
        productTableView.rowHeight = 253.0
        productTableView.dataSource = self
        productTableView.delegate = self
        productTableView.isOpaque = false
        productTableView.backgroundColor = tableViewBgColor//bgColor
        productTableView.separatorColor = UIColor.clear
        mainView.addSubview(productTableView)
        
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        productTableView.tableFooterView = footerView
        productTableView.tableFooterView?.isHidden = true
        
        // Set pull to referseh for eventtableview
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh", comment: ""))
        refresher.addTarget(self, action: #selector(ProductCategoriesDetailViewController.refresh), for: UIControl.Event.valueChanged)
        productTableView.addSubview(refresher)
        
        
        
        
        contentIcon = createLabel(CGRect(x:0,y:0,width:0,height:0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x:0,y:0,width:0,height:0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        pageNumber = 1
        updateScrollFlag = false
   
        browseEntries()
        
    }
    override func viewWillAppear(_ animated: Bool)
    {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame:firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            marqueeHeader.text = "\(tittle!)"
            navigationBar.addSubview(marqueeHeader)
        }
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ProductCategoriesDetailViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        
        
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        //_ = UIBarButtonItem(customView: leftNavView)

        
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
         productTableView.tableFooterView?.isHidden = true
        //categoryType = ""
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
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
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true
        {
            _ = self.navigationController?.popViewController(animated: false)
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
    
    // Set Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 230
    }
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        return Int(ceil(Float(productResponse.count)/2))
        
    }
    
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
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
                
                cell.actualPrice.frame.origin.y = getBottomEdgeY(inputView:cell.ratings)
                cell.discountedPrice.frame.origin.y = getBottomEdgeY(inputView:cell.ratings)
                
                cell.contentSelection.tag = index as Int
                cell.contentSelection.addTarget(self, action: #selector(ProductCategoriesDetailViewController.showProduct(sender:)), for: .touchUpInside)
                
                if logoutUser == false{
                    if let menu = productInfo["menu"] as? NSArray{
                        for menuitem in menu
                        {
                            let menuitem = menuitem as! NSDictionary
                            if menuitem["name"] as! String == "wishlist"{
                                cell.menu.isHidden = false
                                cell.menu.tag = index as Int
                                cell.menu.addTarget(self, action:Selector(("addToWishlist:")) , for: .touchUpInside)
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
                                            
                                         //   totalView += formatter.string(from: NSNumber(value: views))! // $123"
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
                                    
                                   // ratingView += formatter.string(from: NSNumber(value: ratingAvg))! // $123"
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
                                        totalView += formatter.string( from: NSNumber(value: views))!
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
        else{
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
                cell.contentSelection1.addTarget(self, action: #selector(ProductCategoriesDetailViewController.showProduct(sender:)), for: .touchUpInside)
                
                if logoutUser == false{
                    if let menu = productInfo["menu"] as? NSArray{
                        for menuitem in menu{
                            let menuitem = menuitem as! NSDictionary
                            if menuitem["name"] as! String == "wishlist"{
                                cell.menu1.isHidden = false
                                cell.menu1.tag = (index + 1) as Int
                                cell.menu1.addTarget(self, action:Selector(("addToWishlist:")) , for: .touchUpInside)
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
                                                totalView += formatter.string( from: NSNumber(value: views))!
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
                                    
                                 //   ratingView += formatter.string(from: NSNumber(value: ratingAvg))! // $123"
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
                                    
                                   // totalView += formatter.string( from: NSNumber(value: views))! // $123"
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
    
    
    
    //MARK: Category filter
    @objc func showFeedFilterOptions(_ sender: UIButton)
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
    @objc func showFeedFilterOptions1(_ sender: UIButton)
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
                feedFilter.setTitle(subcat["sub_cat_name"] as? String, for: UIControl.State.normal)
                subcategory = subcat["sub_cat_name"] as? String
                subsubcategory = ""
                subsubcatid = nil
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
                feedFilter2.setTitle(subcat["tree_sub_cat_name"] as? String, for: UIControl.State.normal)
                subsubcategory = subcat["tree_sub_cat_name"] as? String
                self.showSpinner = true
                browseEntries()
                
            }
            
        }
        
    }
    
    // MARK: - Server Connection For Products Updation
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
                self.productResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true
                {
                    removeAlert()
                    self.productTableView.reloadData()
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
                activityIndicatorView.center = view.center
                
                if (self.pageNumber == 1)
                {
                    //spinner.center = mainView.center
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.center.y-50)
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
         //       activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            if categoryType == "products"{
                path = "sitestore/product/category"
            }
            else if categoryType == "stores"
            {
                path = "sitestore/category"
                parameters["category_id"] = "\(subjectId)"
            }
            else{
                path = "advancedevents/categories"
            }
            
            if Locationdic != nil
            {
                let defaults = UserDefaults.standard
                if let loc = defaults.string(forKey: "Location")
                {
                    if subcatid != nil && subsubcatid != nil
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showProducts":"1","category_id":"\(subjectId!)","subcategory_id":"\(subcatid!)","subsubcategory_id":"\(subsubcatid!)","restapilocation":"\(loc)"]
                    }
                    else if subcatid != nil
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showProducts":"1","category_id":"\(subjectId!)","subcategory_id":"\(subcatid!)","restapilocation":"\(loc)"]
                        
                    }
                    else
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showProducts":"1","category_id":"\(subjectId!)","restapilocation":"\(loc)"]
                    }
                    
                }
                else
                {
                    if subcatid != nil && subsubcatid != nil
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showProducts":"1","category_id":"\(subjectId!)","subcategory_id":"\(subcatid!)","subsubcategory_id":"\(subsubcatid!)","restapilocation":"\(defaultlocation)"]
                    }
                    else if subcatid != nil
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showProducts":"1","category_id":"\(subjectId!)","subcategory_id":"\(subcatid!)","restapilocation":"\(defaultlocation)"]
                        
                    }
                    else
                    {
                        parameters = ["page":"\(pageNumber)","limit": "\(limit)","showProducts":"1","category_id":"\(subjectId!)","restapilocation":"\(defaultlocation)"]
                    }
                    
                    
                }
            }
            else
            {
                if subcatid != nil && subsubcatid != nil
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","showEvents":"1","category_id":"\(subjectId!)","subCategory_id":"\(subcatid!)","subsubcategory_id":"\(subsubcatid!)"]
                }
                else if subcatid != nil
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","showEvents":"1","category_id":"\(subjectId!)","subCategory_id":"\(subcatid!)"]
                    
                }
                else
                {
                    parameters = ["page":"\(pageNumber)","limit": "\(limit)","showEvents":"1","category_id":"\(subjectId!)"]
                }
                
            }
            
            // Send Server Request to Browse Products Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute:
                    {
                        
                        if self.showSpinner
                        {
                            activityIndicatorView.stopAnimating()
                        }
                        self.refresher.endRefreshing()
                        self.showSpinner = false
                        self.updateScrollFlag = true
                        let subviews : NSArray = self.mainView.subviews as NSArray
                        for  filterview in subviews
                        {
                            
                            if((filterview as AnyObject) .isKind(of:UIButton.self))
                            {
                                if (filterview as AnyObject).tag == 240
                                {
                                    self.feedFilter2.removeFromSuperview()
                                    self.productTableView.frame = CGRect(x:0, y:ButtonHeight, width:self.view.bounds.width,height:self.view.bounds.height-ButtonHeight)
                                }
                            }
                        }
                        
                        if msg
                        {
                            
                            
                            
                            if self.pageNumber == 1
                            {
                                self.productResponse.removeAll(keepingCapacity: false)
                                self.Subcategoryarr.removeAll(keepingCapacity: false)
                                self.SubSubcategoryarr.removeAll(keepingCapacity: false)
                                
                            }
                            
                            if succeeded["message"] != nil
                            {
                                showToast(message: succeeded["message"] as! String, controller: self)
                            }
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if let mainResponse = response["stores"] as? NSDictionary
                                {
                                    if let products = mainResponse["response"] as? NSArray
                                    {
                                       self.productResponse = self.productResponse + (products as [AnyObject])
                                    }
                                }
                            }
                            
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["response"] != nil
                                {
                                    self.totalItems = response["totalItemCount"] as! Int
                                    if let Products = response["response"]as? NSArray
                                    {
                                        self.productResponse = self.productResponse + (Products as [AnyObject])
                                    }
                                    
                                    
                                }
                                
                                if response["currency"] != nil{
                                    self.currency = response["currency"] as! String
                                }
                                
                            }
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["subCategories"] != nil
                                {
                                    
                                    if let Products = response["subCategories"]as? NSArray
                                    {
                                        if Products.count > 0
                                        {
                                            
                                            if self.subcategory == ""
                                            {
                                                self.feedFilter = createButton(CGRect(x:0,y:TOPPADING , width:self.view.bounds.width, height:ButtonHeight),title: NSLocalizedString("Choose sub category",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                            }
                                            else
                                            {
                                                self.feedFilter = createButton(CGRect(x:0,y:TOPPADING, width:self.view.bounds.width, height:ButtonHeight),title: NSLocalizedString("\(self.subcategory!)",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                            }
                                            
                                            self.feedFilter.isEnabled = true
                                            self.feedFilter.backgroundColor = lightBgColor
                                            self.feedFilter.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                            self.feedFilter.addTarget(self, action: #selector(ProductCategoriesDetailViewController.showFeedFilterOptions(_:)), for: .touchUpInside)
                                            self.mainView.addSubview(self.feedFilter)
                                            
                                            // Filter Icon on Left site
                                            let filterIcon = createLabel(CGRect(x:self.feedFilter.bounds.width - self.feedFilter.bounds.height, y:0 ,width:self.feedFilter.bounds.height ,height:self.feedFilter.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorMedium)
                                            filterIcon.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                                            self.feedFilter.addSubview(filterIcon)
                                            
                                            
                                            self.productTableView.frame = CGRect(x:0, y:ButtonHeight, width:self.view.bounds.width,height:self.view.bounds.height-ButtonHeight)
                                            self.Subcategoryarr = self.Subcategoryarr + (Products as [AnyObject])
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                                
                            }
                            
                            
                            if let response1 = succeeded["body"] as? NSDictionary
                            {
                                if response1["subsubCategories"] != nil
                                {
                                    
                                    if let Products1 = response1["subsubCategories"]as? NSArray
                                    {
                                        if Products1.count > 0
                                        {
                                            
                                            self.SubSubcategoryarr = self.SubSubcategoryarr + (Products1 as [AnyObject])
                                            
                                            if self.subsubcategory == ""
                                            {
                                                self.feedFilter2 = createButton(CGRect(x:0,y:ButtonHeight + TOPPADING, width:self.view.bounds.width, height:ButtonHeight),title: NSLocalizedString("Choose 3rd level category",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                            }
                                            else
                                            {
                                                self.feedFilter2 = createButton(CGRect(x:0,y:ButtonHeight + TOPPADING, width:self.view.bounds.width, height:ButtonHeight),title: NSLocalizedString("\(self.subsubcategory!)",  comment: "") , border: false, bgColor: false,textColor: textColorMedium )
                                            }
                                            
                                            self.feedFilter2.isEnabled = true
                                            self.feedFilter2.tag = 240
                                            self.feedFilter2.backgroundColor = lightBgColor
                                            self.feedFilter2.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                            self.feedFilter2.addTarget(self, action: #selector(ProductCategoriesDetailViewController.showFeedFilterOptions1(_:)), for: .touchUpInside)
                                            self.mainView.addSubview(self.feedFilter2)
                                            
                                            // Filter Icon on Left site
                                            let filterIcon1 = createLabel(CGRect(x:self.feedFilter2.bounds.width - self.feedFilter2.bounds.height, y:0 ,width:self.feedFilter2.bounds.height ,height:self.feedFilter2.bounds.height), text: "\u{f107}", alignment: .center, textColor: textColorMedium)
                                            filterIcon1.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
                                            self.feedFilter2.addSubview(filterIcon1)
                                            
                                            self.productTableView.frame = CGRect(x:0, y:ButtonHeight+ButtonHeight, width:self.view.bounds.width,height:self.view.bounds.height-(2*ButtonHeight))
                                            
                                            
                                        }
                                    }
                                    
                                    
                                }
                                
                            }
                            
                            self.isPageRefresing = false
                            // Reload Event Tabel
                            self.productTableView.reloadData()
                            //    if succeeded["message"] != nil{
                            if self.productResponse.count == 0
                            {
                                
                                self.contentIcon = createLabel(CGRect(x:self.view.bounds.width/2 - 30,y:self.view.bounds.height/2-80,width:60 , height:60), text: NSLocalizedString("\(eventIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                                self.mainView.addSubview(self.contentIcon)
                                self.info = createLabel(CGRect(x:self.view.bounds.width * 0.1, y:self.contentIcon.frame.origin.y+self.contentIcon.frame.size.height,width:self.view.bounds.width * 0.8 , height:50), text: NSLocalizedString("You do not have any products matching this criteria.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.info.numberOfLines = 0
                                self.info.lineBreakMode = NSLineBreakMode.byWordWrapping
                                //self.info.center = self.view.center
                                self.info.backgroundColor = bgColor
                                self.info.tag = 1000
                                self.mainView.addSubview(self.info)
                                
                                self.refreshButton = createButton(CGRect(x:self.view.bounds.width/2-40, y:self.info.bounds.height + self.info.frame.origin.y, width:80, height:40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                                self.refreshButton.backgroundColor = bgColor
                                self.refreshButton.layer.borderColor = navColor.cgColor
                                self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                                self.refreshButton.addTarget(self, action: #selector(ProductCategoriesDetailViewController.browseEntries), for: UIControl.Event.touchUpInside)
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
                                
                                let message = succeeded["message"] as? String
                                if message == "You do not have the access of this page."
                                {
                                    self.popAfterDelay = true
                                    self.createTimer(self)
                                    
                                }
                                
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
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // After click on particular products redirect to Product Profile
    @objc func showProduct(sender: UIButton){
        if let productInfo = productResponse[sender.tag] as? NSDictionary {
            _ =   productInfo["store_id"] as? Int
            var product_id = 0
            var store_id = 0
            if let pid = productInfo["product_id"] as? Int
            {
                product_id = pid
            }
            if categoryType == "stores"
            {
                if let sid = productInfo["store_id"] as? Int
                {
                    store_id = sid
                }
            }
            if productInfo["allow_to_view"] != nil && productInfo["allow_to_view"] as! Int == 1 {
            if product_id != 0
            {
                SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false,product_id:"\(product_id)")
            }
            else if store_id != 0
            {
                SiteStoreObject().redirectToStoreProfile(viewController: self, subject_type: "sitestore_store", subject_id: "\(store_id)")
            }
            }
            else{
                showToast(message:NSLocalizedString("You do not have permission to view this private page.", comment: ""), controller: self)
            }
            
        }
        
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView)
//    {
//        if updateScrollFlag{
//            // Check for Page Number for Browse Classified
//            if productTableView.contentOffset.y >= productTableView.contentSize.height - productTableView.bounds.size.height{
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
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                if (!isPageRefresing  && limit*pageNumber < totalItems){
                    if Reachabable.isConnectedToNetwork() {
                        updateScrollFlag = false
                        pageNumber += 1
                        productTableView.tableFooterView?.isHidden = false
                        isPageRefresing = true
                    //    if searchDic.count == 0{
                            browseEntries()
                      //  }
                    }
                }
                else
                {
                    productTableView.tableFooterView?.isHidden = true
                }
                
            }
            
        }
        
    }
    
    
    
    // Add products in  Wishlist
    func addToWishlist(sender : UIButton){
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
    
    
}
