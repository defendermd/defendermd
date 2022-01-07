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
//  WishlistSearchViewController.swift
//  seiosnativeapp
//

import UIKit
import Foundation
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


var globWishlistFilterValue = ""
var globalWishlistOwnerSearch = ""

class WishlistSearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    var searchBar = UISearchBar()
    var wishlistTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var wishlistResponse = [WishListModel]()
    var updateScrollFlag = false
    var isPageRefresing = false                 // For Pagination
    var info:UILabel!
    var search : String!
  //  var imageCache = [String:UIImage]()
    let mainView = UIView()
    var showOnlyMyContent:Bool!
    let scrollView = UIScrollView()
    var imageArr:[UIImage]=[]
    var countListTitle : String!
    var contentGutterMenu: NSArray = []
    var subjectType:String!
    var productOrOthers:Bool!
    var leftBarButtonItem : UIBarButtonItem!
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    override func viewDidLoad() {
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        super.viewDidLoad()
        
//        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Wishlists",  comment: ""))
//        searchBar.delegate = self
//        searchBar.setTextColor(textColorPrime)

        
        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search Wishlists",  comment: ""))
        searchBar.delegate = self
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(WishlistSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(WishlistSearchViewController.filter))
        
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        filter.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = filter
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        // Initialize wishlist Table
        wishlistTableView = UITableView(frame: CGRect(x: 0, y: 0,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        wishlistTableView.register(WishlistTableViewCell.self, forCellReuseIdentifier: "WishlistCell")
        wishlistTableView.dataSource = self
        wishlistTableView.delegate = self
        wishlistTableView.estimatedRowHeight = 50.0
        wishlistTableView.rowHeight = UITableView.automaticDimension
        wishlistTableView.backgroundColor = tableViewBgColor
        wishlistTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            wishlistTableView.estimatedSectionHeaderHeight = 0
            wishlistTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(wishlistTableView)
        wishlistTableView.isHidden = true
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        wishlistTableView.tableFooterView = footerView
        wishlistTableView.tableFooterView?.isHidden = true

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
    

    // Check for wishlist Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        

       // self.navigationItem.titleView = searchBar
        
        if searchDic.count > 0 {
            if globWishlistFilterValue != ""{
                searchBar.text = globWishlistFilterValue
                
            }
           // searchBar.endEditing(true)
            tblAutoSearchSuggestions.isHidden = true
            showSpinner = true
            searchBar.endEditing(true)
            pageNumber = 1
            self.browseEntries()
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
        wishlistTableView.tableFooterView?.isHidden = true
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.navigationBar.isTranslucent = true
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
    
    /// Set Tabel Footer Height
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
    
    // Set TableView Section
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if tableView.tag == 122{
            return dynamicHeightAutoSearch
        }else{
        return 202.0
        }
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else
        {
        return wishlistResponse.count
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
        let cell = wishlistTableView.dequeueReusableCell(withIdentifier: "WishlistCell", for: indexPath) as! WishlistTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
      //  var listingInfo:NSDictionary!
      var listingInfo = wishlistResponse[(indexPath as NSIndexPath).row]
        
        cell.coverSelection.tag = (indexPath as NSIndexPath).row
        cell.coverImage.tag = (indexPath as NSIndexPath).row
        cell.moreOptions.isHidden = true
        cell.coverSelection.addTarget(self, action: #selector(WishlistSearchViewController.coverSelection(_:)), for: .touchUpInside)
        
        if let name = listingInfo.title{
            cell.titleLabel.text = "\(name)"
        }
        
        let count = listingInfo.total_item
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
                                    self.imageArr.append(image!)
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
        
    /*
        if count > 0
        {
            switch (count!){
            case 1 :
                
                cell.coverImage.isHidden = false
                cell.coverImage1.isHidden = true
                cell.coverImage2.isHidden = true
                cell.coverImage3.isHidden = true
                cell.coverImage4.isHidden = true
                cell.coverImage5.isHidden = true
                
                imageArr.removeAll()
                
                let imagedic = wishlistInfo["images_0"] as! NSDictionary
                let url = URL(string: imagedic["image"] as! NSString as String)
                
                if url != nil {
                    cell.coverImage.image = nil
                    cell.coverImage.kf.indicatorType = .activity
                    (cell.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.coverImage.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        self.imageArr.append(image!)
                    })
                }
                break
                
            case 2 :
                cell.coverImage.isHidden = true
                cell.coverImage1.isHidden = true
                cell.coverImage2.isHidden = true
                cell.coverImage3.isHidden = true
                cell.coverImage4.isHidden = false
                cell.coverImage5.isHidden = false
                
                imageArr.removeAll()
                
                let imagedic1 = wishlistInfo["images_0"] as! NSDictionary
                let imagedic2 = wishlistInfo["images_1"] as! NSDictionary
                
                
                let url1 = URL(string: imagedic1["image"] as! NSString as String)
                if url1 != nil {
                    cell.coverImage4.kf.setImage(with: url1, for: .normal)
                   // cell.coverImage4.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
//                    cell.coverImage4.kf.setImage(with: url1, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
//
//                    })
 
                }
                
                let url2 = URL(string: imagedic2["image"] as! NSString as String)
                if url2 != nil {
                     cell.coverImage5.kf.setImage(with: url2, for: .normal)
                   // cell.coverImage5.setImage(UIImage(named: "nophoto_diary_thumb_profile.png"), for: UIControl.State())
//                    cell.coverImage5.kf.setImage(with: url2, for: .normal, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
//
//                    })

                }
                
                break
            default:
                cell.coverImage.isHidden = true
                cell.coverImage4.isHidden = true
                cell.coverImage5.isHidden = true
                
                cell.coverImage1.isHidden = false
                cell.coverImage2.isHidden = false
                cell.coverImage3.isHidden = false
                imageArr.removeAll()
                let imagedic3 = wishlistInfo["images_0"] as! NSDictionary
                let imagedic4 = wishlistInfo["images_1"] as! NSDictionary
                let imagedic5 = wishlistInfo["images_2"] as! NSDictionary
                
                let url3 = URL(string: imagedic3["image"] as! NSString as String)
                if url3 != nil {
                 //   cell.coverImage1.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                    cell.coverImage1.kf.setImage(with: url3, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })


                }
                
                let url4 = URL(string: imagedic4["image"] as! NSString as String)
                if url4 != nil {
                   // cell.coverImage2.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                    cell.coverImage2.kf.setImage(with: url4 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })


                }
                
                let url5 = URL(string: imagedic5["image"] as! NSString as String)
                if url5 != nil {
                  //  cell.coverImage3.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                    cell.coverImage3.kf.setImage(with: url5 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler:{(image, error, cache, url) in
                        
                    })


                }
                
                break
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
                
                let imagedic = wishlistInfo["images_0"] as! NSDictionary
                let url = URL(string: imagedic["image"] as! NSString as String)
                if url != nil {
                  //  cell.coverImage.image = UIImage(named: "nophoto_diary_thumb_profile.png")
                    cell.coverImage.kf.indicatorType = .activity
                    (cell.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.coverImage.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    })
                }
            }
        }
    */
        return cell
        }
    }
    
    // Handle wishlist Table Cell Selection
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
                self.wishlistTableView.isHidden = true
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
            let listingInfo = wishlistResponse[(indexPath as NSIndexPath).row]
           
        if(listingInfo.allow_to_view  == 1){
            if let name = listingInfo.title{
                updateAutoSearchArray(str: name)
            }
            let presentedVC = WishlistDetailViewController()
            navigationController?.pushViewController(presentedVC, animated: false)
        }else{
            showToast(message: "You do not have permission to view this private page.", controller: self)
        }
        }
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if updateScrollFlag{
//            // Check for Page Number for Browse wishlist
//            if wishlistTableView.contentOffset.y >= wishlistTableView.contentSize.height - wishlistTableView.bounds.size.height{
//                if (!isPageRefresing  && limit*pageNumber < totalItems){
//                    if Reachabable.isConnectedToNetwork() {
//
//                        updateScrollFlag = false
//                        pageNumber += 1
//                        isPageRefresing = true
//                        browseEntries()
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
                if (!isPageRefresing  && limit*pageNumber < totalItems){
                    if Reachabable.isConnectedToNetwork() {
                        wishlistTableView.tableFooterView?.isHidden = false
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        browseEntries()
                    }
                }
                else
                {
                    wishlistTableView.tableFooterView?.isHidden = true
                }
                
            }
            
        }
        }
    }
    
    @objc func cancel(){
        wishlistUpdate = false
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    //MARK: - Search Bar Function
    
    //Called automatically when enter pressed on searchbar
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
                self.wishlistTableView.isHidden = true
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
    @objc func filter(){
        
        let presentedVC = FilterSearchViewController()
        presentedVC.serachFor = "wishlist"
        if filterSearchFormArray.count > 0 {
            
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else
        {
            
            if productOrOthers == true
            {
                presentedVC.searchUrl = "sitestore/product/wishlist/search-form"
                
            }
            else
            {
                presentedVC.searchUrl = "listings/wishlist/search-form"
            }
            
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        
    }
    
    // MARK: - Server Connection For wishlist Updation
    func browseEntries()
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

                self.wishlistResponse.removeAll(keepingCapacity: false)
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
                activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
               // activityIndicatorView.center = view.center
                
                if updateScrollFlag == false
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.center.y-85-(tabBarHeight/4))
                }
                
                if (self.pageNumber == 1)
                {
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
            if productOrOthers == true
            {
                path  = "sitestore/product/wishlist"
                
            }
            else
            {
                path = "listings/wishlist/browse"
            }
            
            parameters = ["page":"\(pageNumber)", "limit": "\(limit)"]
            self.title = NSLocalizedString("Wishlists",  comment: "")
            wishlistTableView.isHidden = false
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse wishlist Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    //self.tblAutoSearchSuggestions.isHidden = true
                        if self.showSpinner
                        {
                            activityIndicatorView.stopAnimating()
                        }
                        
                        self.showSpinner = false
                        self.updateScrollFlag = true
                        
                        if msg
                        {
                            if self.pageNumber == 1
                            {
                                self.wishlistResponse.removeAll(keepingCapacity: false)
                            }
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["response"] != nil
                                {
                                    if let wishlist = response["response"] as? NSArray
                                    {
                                         self.wishlistResponse += WishListModel.loadWishLists(wishlist, wishlistType: "self.wishlistType")
                                       // self.wishlistResponse = self.wishlistResponse + (wishlist as [AnyObject])
                                    }
                                }
                                
                            }
                            
                            if self.wishlistResponse.count != 0
                            {
                                if self.tblAutoSearchSuggestions.isHidden == true
                                {
                                     self.wishlistTableView.isHidden = false
                                }
                               
                            }
                            
                            if let response = succeeded["body"] as? NSDictionary
                            {
                                if response["totalItemCount"] != nil
                                {
                                    self.totalItems = response["totalItemCount"] as! Int
                                }
                            }
                            
                            
                            self.isPageRefresing = false
                            
                            //Reload wishlist Table
                            self.wishlistTableView.reloadData()
                            
                            if self.wishlistResponse.count == 0{
                                showToast(message: "No wishlist entries found. Get started by creating a new entry.", controller: self)
                                self.searchBar.resignFirstResponder()
                            }
                            
                        }
                        else
                        {
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
    func noRedirection(){
        showToast(message: "You do not have the permission to view this private page.", controller: self)
    }
    
    //Function
    @objc func coverSelection(_ sender:UIButton)
    {
        let listingInfo = wishlistResponse[sender.tag]
        if listingInfo.allow_to_view == 0
        {
            noRedirection()
        }
        else{
            
            
            
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
