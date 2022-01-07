//
//  BlogSearchViewController.swift
//  seiosnativeapp
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


import UIKit
import Foundation
import NVActivityIndicatorView

class MusicSearchViewController: UIViewController , UITableViewDataSource, UITableViewDelegate , UISearchBarDelegate, TTTAttributedLabelDelegate {
    
    var editPlaylistID:Int = 0
    
    var searchBar = UISearchBar()
    var musicTableView:UITableView!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var showSpinner = true                      // not show spinner at pull to refresh
    var musicResponse = [AnyObject]()
    var updateScrollFlag = false
    var isPageRefresing = false                 // For Pagination
    var info:UILabel!
    var browseOrMyMusic = true
    var browseMusic:UIButton!                    // Music Types
    var myMusic:UIButton!
    var dynamicHeight:CGFloat = 165              // Dynamic Height fort for Cell
    var search : String!
    var showOnlyMyContent:Bool!
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    var user_id : Int!
    var fromTab : Bool!
//     var imageCache = [String:UIImage]()
//    var imageCache1 = [String:UIImage]()
    var leftBarButtonItem : UIBarButtonItem!
    var tblAutoSearchSuggestions : UITableView!
    var dynamicHeightAutoSearch:CGFloat = 50
    override func viewDidLoad() {
        
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
        
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = textColorPrime
        
        super.viewDidLoad()
        
//        searchBar.addSearchBarWithText(self,placeholderText: NSLocalizedString("Search Music",  comment: ""))
//        searchBar.delegate = self
//        searchBar.backgroundColor = UIColor.clear
//        searchBar.setTextColor(textColorPrime)
        
        _ = SearchBarContainerView(self, customSearchBar:searchBar)
        searchBar.setPlaceholderWithColor(NSLocalizedString("Search Music",  comment: ""))
        searchBar.delegate = self
        
        let filter = UIBarButtonItem( title: fiterIcon , style: UIBarButtonItem.Style.plain , target:self , action: #selector(MusicSearchViewController.filter))
        
        filter.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!],for: UIControl.State())
        filter.tintColor = textColorPrime
        self.navigationItem.rightBarButtonItem = filter
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
       
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MusicSearchViewController.cancel))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

       
        automaticallyAdjustsScrollViewInsets = false
        definesPresentationContext = true
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        view.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        view.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        // Initialize music Table
        musicTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING,width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        musicTableView.register(MusicTableViewCell.self, forCellReuseIdentifier: "Cell")
        musicTableView.dataSource = self
        musicTableView.delegate = self
        musicTableView.estimatedRowHeight = 165.0
        musicTableView.rowHeight = UITableView.automaticDimension
        musicTableView.backgroundColor = UIColor.clear
        musicTableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            musicTableView.estimatedRowHeight = 0
            musicTableView.estimatedSectionHeaderHeight = 0
            musicTableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(musicTableView)
        
        musicTableView.isHidden = true
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        musicTableView.tableFooterView = footerView
        musicTableView.tableFooterView?.isHidden = true
        
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
        
        setNavigationImage(controller: self)
        showInFilter = ""
     //   self.navigationItem.titleView = searchBar
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
        musicTableView.tableFooterView?.isHidden = true
        searchDic.removeAll(keepingCapacity: false)
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func updateMusicMenuAction(_ url : String){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            
            let dic = Dictionary<String, String>()
            // Send Server Request to Explore Music Contents with Music_ID
            post(dic, url: "\(url)", method: "DELETE") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Music Detail
                        // Update Music Detail
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
  
                        }
                        updateAfterAlert = false
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
            showToast(message: network_status_msg, controller: self)
            
            
        }
        
    }
    
    
    // Update Music
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            for ob in view.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            refreshButton.isHidden = true
            contentIcon.isHidden = true
            
            
            if (self.pageNumber == 1){
                self.musicResponse.removeAll(keepingCapacity: false)
                
                if updateAfterAlert == true || searchDic.count > 0 {
                    removeAlert()
                    self.musicTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            if (showSpinner){
              //  spinner.center = self.view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height/3)
                  //  activityIndicatorView.center = self.view.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
            //    activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            if((fromTab != nil) && (fromTab == true) && (user_id != nil)) {
                browseOrMyMusic = true
            }
            
            let path = "music"
            var parameters = [String:String]()
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Music Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    //self.tblAutoSearchSuggestions.isHidden = true
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.musicResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                            
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if response["response"] != nil{
                                if let music = response["response"] as? NSArray {
                                    self.musicResponse = self.musicResponse + (music as [AnyObject])
                                }
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                        }
                        
                        self.isPageRefresing = false
                        //Reload Music Tabel
                        self.musicTableView.reloadData()
                        if self.tblAutoSearchSuggestions.isHidden == true
                        {
                             self.musicTableView.isHidden = false
                        }
                       
                        if self.musicResponse.count == 0{
                            
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30,y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\(musicIcon)",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 50)
                            self.view.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any Music entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.sizeToFit()
                            self.info.numberOfLines = 0
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.view.addSubview(self.info)
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(MusicSearchViewController.browseEntries), for: UIControl.Event.touchUpInside)
                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.view.addSubview(self.refreshButton)
                            self.refreshButton.isHidden = false
                            self.contentIcon.isHidden = false
                            self.searchBar.resignFirstResponder()
                            
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
            self.searchBar.resignFirstResponder()
            
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
    // Stop Timer
    @objc func stopTimer() {
        stop()
    }
    
    // Set Music Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Music Tabel Header Height
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
        return dynamicHeight
        }
    }
    
    // Set Music Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if tableView.tag == 122{
            return arrRecentSearchOptions.count
        }else
        {
            return Int(ceil(Float(musicResponse.count)/2))
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MusicTableViewCell
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
        
        
        var index:Int!
        index = (indexPath as NSIndexPath).row * 2
        
        
        
        if musicResponse.count > index {
            cell.contentSelection.isHidden = false
            cell.classifiedImageView.isHidden = false
            cell.classifiedName.isHidden = false
            
            cell.MusicPlays.isHidden = false
            cell.classifiedImageView.image = nil
            
            if let musicInfo = musicResponse[index] as? NSDictionary {
                // LHS
                
                if let url = URL(string: musicInfo["image"] as! String){
                    cell.classifiedImageView.kf.indicatorType = .activity
                    (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.classifiedImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        cell.classifiedImageView?.image = image
                        let imageview = createImageView(CGRect(x: cell.classifiedImageView.bounds.width/2 - 5, y: cell.classifiedImageView.bounds.height/2 - 5, width: 20, height: 20), border: false)
                        
                        let lockedImage = UIImage(named:"CircularPlay1.png")
                        
                        imageview.image = lockedImage
                        
                        cell.classifiedImageView.addSubview(imageview)
                    })
                    
                }

                

                cell.classifiedName.text = musicInfo["title"] as? String
                cell.contentSelection.accessibilityIdentifier = "\(index!)"
                cell.contentSelection.tag = musicInfo["playlist_id"] as! Int
                cell.contentSelection.addTarget(self, action: #selector(MusicSearchViewController.showMusic(_:)), for: .touchUpInside)
                if browseOrMyMusic {
                    cell.menu.isHidden = true
                    cell.menu1.isHidden = true
                }else{
                    // Set MenuAction
                    cell.menu.addTarget(self, action:#selector(MusicSearchViewController.showMenu(_:)) , for: .touchUpInside)
                    cell.menu.isHidden = false
                    cell.menu1.addTarget(self, action:#selector(MusicSearchViewController.showMenu(_:)) , for: .touchUpInside)
                    cell.menu1.isHidden = false
                    
                }
                
                var totalView = ""
                if let views = musicInfo["play_count"] as? Int{
                    let a = singlePluralCheck( NSLocalizedString(" play", comment: ""),  plural: NSLocalizedString(" plays", comment: ""), count: views)
                    
                    totalView += " \(a)  "
                    
                }

                cell.MusicPlays.text = "\(totalView)  "
            }
            
        }else{
            cell.contentSelection.isHidden = true
            cell.classifiedImageView.isHidden = true
            cell.classifiedName.isHidden = true
            cell.MusicPlays.isHidden = true
            
            
            cell.contentSelection1.isHidden = true
            cell.classifiedImageView1.isHidden = true
            cell.classifiedName1.isHidden = true
            cell.MusicPlays1.isHidden = true
        }
        
        
        if musicResponse.count > (index + 1){
            cell.contentSelection1.isHidden = false
            cell.classifiedImageView1.isHidden = false
            cell.classifiedName1.isHidden = false
            cell.MusicPlays1.isHidden = false
            
            cell.classifiedImageView1.image = nil
            if let musicInfo = musicResponse[index + 1] as? NSDictionary {
                
                if let url = URL(string: musicInfo["image"] as! String){
                    cell.classifiedImageView1.kf.indicatorType = .activity
                    (cell.classifiedImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.classifiedImageView1.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        cell.classifiedImageView1?.image = image
                        let imageview = createImageView(CGRect(x: cell.classifiedImageView1.bounds.width/2 - 5, y: cell.classifiedImageView1.bounds.height/2 - 5, width: 20, height: 20), border: false)
                        
                        let lockedImage = UIImage(named:"CircularPlay1.png")
                        
                        imageview.image = lockedImage
                        
                        cell.classifiedImageView1.addSubview(imageview)
                    })
                    
                }

                
                
                cell.classifiedName1.text = musicInfo["title"] as? String
                cell.contentSelection1.accessibilityIdentifier = "\(index! + 1)"
                cell.contentSelection1.tag = musicInfo["playlist_id"] as! Int
                cell.contentSelection1.addTarget(self, action: #selector(MusicSearchViewController.showMusic(_:)), for: .touchUpInside)
                if browseOrMyMusic {
                    cell.menu.isHidden = true
                    cell.menu1.isHidden = true
                }else{
                    // Set MenuAction
                    cell.menu.addTarget(self, action:#selector(MusicSearchViewController.showMenu(_:)) , for: .touchUpInside)
                    cell.menu.isHidden = false
                    cell.menu1.addTarget(self, action:#selector(MusicSearchViewController.showMenu(_:)) , for: .touchUpInside)
                    cell.menu1.isHidden = false
                    
                }
                var totalView = ""
                if let views = musicInfo["play_count"] as? Int{
                    let a = singlePluralCheck( NSLocalizedString(" play", comment: ""),  plural: NSLocalizedString(" plays", comment: ""), count: views) as String
                    
                    totalView += " \(a)  "
                    
                }
     
                cell.MusicPlays1.text = "\(totalView)  "
        
            }
            
        }
        else{
            cell.contentSelection1.isHidden = true
            cell.classifiedImageView1.isHidden = true
            cell.classifiedName1.isHidden = true
            cell.MusicPlays1.isHidden = true
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
                self.musicTableView.isHidden = true
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
    @objc func showMenu(_ sender:UIButton){
        var musicInfo:NSDictionary
        musicInfo = musicResponse[sender.tag] as! NSDictionary
        editPlaylistID = musicInfo["playlist_id"] as! Int
        
        let menuOption = musicInfo["menu"] as! NSArray
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        for menu in menuOption{
            if let menuItem = menu as? NSDictionary{
                let titleString = menuItem["name"] as! String
                
                if titleString.range(of: "delete") != nil{
                    alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                        let condition = menuItem["name"] as! String
                        switch(condition){
                            
                        case "delete":
                            displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this playlist ?",comment: "") , otherButton: NSLocalizedString("Delete Playlist", comment: "")) { () -> () in
                                self.updateMusicMenuAction(menuItem["url"] as! String)
                                
                            }
                            self.present(alert, animated: true, completion: nil)
                            
                            
                        default:
                            showToast(message: unconditionalMessage, controller: self)
                            
                            
                        }
                        
                        
                    }))
                }else{
                    alertController.addAction(UIAlertAction(title: (menuItem["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                        let condition = menuItem["name"] as! String
                        switch(condition){
                            
                        case "play_on_profile":
                            
                            print("not working")
                        default:
                            showToast(message: unconditionalMessage, controller: self)
                        }
                        
                        
                    }))
                }
            }
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else if  (UIDevice.current.userInterfaceIdiom == .pad){
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
        
    }

    
    @objc func showMusic(_ sender:UIButton){
        
        if let strIndex = sender.accessibilityIdentifier, let index = Int(strIndex), let photoInfo = musicResponse[index] as? NSDictionary {
            if let str = photoInfo["title"] as? String
            {
                updateAutoSearchArray(str: str)
            }
        }
        let presentedVC = MusicPlayListViewController() //MusicPlayerViewController()
        presentedVC.playListId = sender.tag
        navigationController?.pushViewController(presentedVC, animated: true)
        
        
    }
    
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if updateScrollFlag{
//            // Check for Page Number for Browse Blog
//            if musicTableView.contentOffset.y >= musicTableView.contentSize.height - musicTableView.bounds.size.height{
//                if (limit*pageNumber < totalItems){
//                    if Reachabable.isConnectedToNetwork() {
//                        updateScrollFlag = false
//                        pageNumber += 1
//                        isPageRefresing = true
//                        browseEntries()
//
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
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        musicTableView.tableFooterView?.isHidden = false
                        browseEntries()                      
                    }
                }
                else
                {
                    musicTableView.tableFooterView?.isHidden = true
                }
                
            }
            }
        }
        
    }

    @objc func cancel(){
        musicUpdate = false
        if fromGlobSearch{
            conditionalForm = ""
            loadFilter("search")
            backToGlobalSearch(self)
        }else{
            _ = self.navigationController?.popViewController(animated: false)
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
                self.musicTableView.isHidden = true
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
      //  searchBar.resignFirstResponder()
        
        browseEntries()
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        searchBar.resignFirstResponder()
    }
    @objc func filter()
    {
        
        if filterSearchFormArray.count > 0
        {
            let presentedVC = FilterSearchViewController()
            presentedVC.formController.form = CreateNewForm()
            presentedVC.filterArray = filterSearchFormArray
            presentedVC.serachFor = "music"
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        else
        {
            let presentedVC = FilterSearchViewController()
            
            presentedVC.searchUrl = "music/search-form"
            presentedVC.serachFor = "music"
            presentedVC.stringFilter = searchBar.text!
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
        
        
    }
    
    
}
