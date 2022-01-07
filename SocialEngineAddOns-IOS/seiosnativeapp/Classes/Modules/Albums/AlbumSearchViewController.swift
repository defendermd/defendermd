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
//  AlbumSearchViewController.swift
//  seiosnativeapp

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


class AlbumSearchViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate {
    
    
    var searchBar = UISearchBar()
    var albumCollectionView: UICollectionView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var albumResponse = [AnyObject]()
    var updateScrollFlag = false
    var refresher:UIRefreshControl!             // Pull to refrresh
    var isPageRefresing = false                 // For Pagination
    var info:UILabel!
    var search : String!
    var albumFooterView = UICollectionReusableView()
  //  var imageCache = [String:UIImage]()
    var popAfterDelay:Bool!
    var leftBarButtonItem : UIBarButtonItem!
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    var cellWidth = 0
    var cellHeight = 0
    let albumFooter = "footerId"
    override func viewDidLoad() {
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = false
        super.viewDidLoad()
        popAfterDelay = false
        cellWidth = Int(self.view.frame.size.width/2-35)
        cellHeight = cellWidth + 50
//        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Albums",  comment: ""))
//        searchBar.delegate = self
//        searchBar.backgroundColor = UIColor.clear
//        searchBar.setTextColor(textColorPrime)
        
        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search Albums",  comment: ""))
        searchBar.delegate = self

        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AlbumSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

//        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(AlbumSearchViewController.filter))
//        
//        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
//        filter.tintColor = textColorPrime
//        self.navigationItem.rightBarButtonItem = filter
        
        
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        
        
        let frame = CGRect(x: 0, y: TOPPADING + 15,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING - 15)
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        albumCollectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        albumCollectionView.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        albumCollectionView.register(UICollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: albumFooter)
        albumCollectionView.dataSource = self
        albumCollectionView.delegate = self
        albumCollectionView.bounces = false
        albumCollectionView.showsVerticalScrollIndicator = false
        albumCollectionView.backgroundColor = .white
       
        view.addSubview(albumCollectionView)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
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
    override func viewDidAppear(_ animated: Bool) {

        if searchDic.count > 0 {
            if globFilterValue != ""{
                searchBar.text = globFilterValue
            }
            //tblAutoSearchSuggestions.isHidden = true
            showSpinner = true
            pageNumber = 1
            self.browseEntries()
        }
        
        
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer:Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        
        if timer{
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
        if popAfterDelay == true {
             _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    // Update Album
    func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            // Reset Objects
            for ob in view.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            
            if (self.pageNumber == 1){
                self.albumResponse.removeAll(keepingCapacity: false)
                if updateAfterAlert == true || searchDic.count > 0 {
                    removeAlert()
                    self.albumCollectionView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
                activityIndicatorView.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-50 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                  //  activityIndicatorView.center = view.center
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                self.view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
            //    activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            // Set Parameters for Browse/MyAlbum
            path = "albums"
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
            
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Album Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                   // self.tblAutoSearchSuggestions.isHidden = true
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    //                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    //})
                    
                  //  //print(succeeded, msg)
                    
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.albumResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let album = response["response"] as? NSArray {
                                    self.albumResponse = self.albumResponse + (album as [AnyObject])
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                        }
                        
                        self.isPageRefresing = false
                       
                        self.albumCollectionView.reloadData()
                        if self.albumResponse.count == 0{
                            showToast(message:  NSLocalizedString("You do not have any Album entries. Get started by writing a new entry.",  comment: ""), controller: self)
                          // self.createTimer(self)
                            self.popAfterDelay = true
                            self.searchBar.resignFirstResponder()
                        }
                    }else{
                        
                        // Handle Server Side Error
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
    
    // Set Album Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Album Tabel Header Height
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
        return 253
        }
    }
    
    // Set Album Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else
        {
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return Int(ceil(Float(albumResponse.count)/3))
        }else{
            return albumResponse.count
        }
        }
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        if tableView.tag == 122{
            
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
           
        }
         return cell
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
    // Handle Scroll For Pagination

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        if tblAutoSearchSuggestions.isHidden == true
        {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                // Check for Page Number for Browse Album
//                if albumTableView.contentOffset.y >= albumTableView.contentSize.height - albumTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                         //   if searchDic.count == 0{
                                browseEntries()
                           // }
                        }
                    }
                
                    
              //  }
                
            }
            
        }
        }
    }
    
    @objc func cancel(){
        albumUpdate = false
        
        _ = self.navigationController?.popViewController(animated: false)
        
        
    }
    func checkAlbumPassword(row: Int) {
        let albumInfo:NSDictionary!
        albumInfo = albumResponse[row] as! NSDictionary
        if let isPassword = albumInfo["isPassword"] as? Bool, isPassword {
            if let password = albumInfo["password"] as? String {
                self.passwordAlert(pass: password, row: row)
            }
        }
        else {
            self.showAlbum(index: row)
        }
    }
    
    func passwordAlert(pass : String, row: Int)
    {
        let alertController = UIAlertController(title: NSLocalizedString("Enter Password",  comment: ""), message: "", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {(_ textField: UITextField) -> Void in
            textField.placeholder = NSLocalizedString("Enter Password",  comment: "")
            textField.isSecureTextEntry = true
        })
        
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            let enterpass = alertController.textFields?[0].text
            if enterpass == String(pass)
            {
                self.showAlbum(index: row)
            }
            else
            {
                showToast(message: "Password invalid", controller: self)
                self.passwordAlert(pass : pass, row: row)
            }
        })
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: {  })
    }
    
    @objc func showAlbum(index: Int){
       if let photoInfo = albumResponse[index] as? NSDictionary {

            if let str = photoInfo["title"] as? String
            {
               updateAutoSearchArray(str: str)
            }
        if let id = photoInfo["album_id"] as? Int {
            let presentedVC = AlbumProfileViewController()
            presentedVC.albumId = "\(id)"
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
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
       // searchBar.resignFirstResponder()
        browseEntries()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    @objc func filter(){
        
        if filterSearchFormArray.count > 0 {
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "album"
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = false
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else{
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "albums/search-form"
            presentedVC.serachFor = "album"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
    
    
    
    
    
    //    override func viewWillDisappear(animated: Bool) {
    //        view.removeGestureRecognizer(tapGesture)
    //        // searchDic.removeAll(keepingCapacity: false)
    //    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// CollectionView Delegates

extension AlbumSearchViewController : UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.size.width/2-20
        return CGSize(width: cellWidth + 18, height: cellHeight + 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
}

extension AlbumSearchViewController : UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return albumResponse.count
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        albumFooterView = albumCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: albumFooter, for: indexPath)
        for ob in albumFooterView.subviews {
            if ob.tag == 2000 {
                ob.removeFromSuperview()
            }
        }

        if (!isPageRefresing  && limit*pageNumber < totalItems){
                let footerView = UIView(frame: frameActivityIndicator)
                footerView.backgroundColor = UIColor.clear
                footerView.tag = 2000
                let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
                activityIndicatorView.frame = CGRect(x: 0, y: 0, width:30 , height: 30)
                activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:15.0)
                footerView.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
                albumFooterView.addSubview(footerView)
                albumFooterView.isHidden = false
                return albumFooterView
         
        }
        else
        {
            albumFooterView.isHidden = true
            return albumFooterView
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 50)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumCollectionViewCell
                cell.albumCoverView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
                cell.plusIcon.isHidden = true
                cell.albumCoverView.layer.borderColor = UIColor.clear.cgColor
                cell.albumPhotoCount.isHidden = false
                cell.menu.isHidden = true

                if let photoInfo = albumResponse[indexPath.row] as? NSDictionary
                {
                    if let imageUrl = photoInfo["image"] as? String
                    {
                        if (imageUrl.range(of: ".gif") != nil){
                            cell.gifImageView.isHidden = false
                        }else{
                            cell.gifImageView.isHidden = true
                        }
                        let url1 = URL( string:imageUrl)
                        //cell.albumCoverView.kf.indicatorType = .activity
                        //(cell.albumCoverView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                        cell.albumCoverView.kf.setImage(with: url1 as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                            
                        })
                    }
                    if let photoCount = photoInfo["photo_count"] as? String{
                        if Int(photoCount) > 1 {
                            
                            cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photos ", comment: ""),photoCount) //"\(photoCount) photos"
                        }else{
                            cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photo ", comment: ""),photoCount) //"\(photoCount) photo"
                        }
                    }else if let photoCount = photoInfo["photo_count"] as? Int{
                        if photoCount > 1 {
                            cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photos ", comment: ""),photoCount) //"\(photoCount) photos"
                        }else{
                            cell.albumPhotoCount.text = String(format: NSLocalizedString("%d Photo ", comment: ""),photoCount) //"\(photoCount) photo"
                        }
                    }
                    let name = photoInfo["title"] as? String
                    let tempString = name! as NSString
                    var value : String
                    if tempString.length > 30{
                        value = tempString.substring(to: 25)
                        value += NSLocalizedString("...",  comment: "")
                    }else{
                        value = "\(tempString)"
                    }
                    cell.albumTitleLabel.text = " \(value)"
                    
                }
            return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        checkAlbumPassword(row: indexPath.row)
    }
    
}


