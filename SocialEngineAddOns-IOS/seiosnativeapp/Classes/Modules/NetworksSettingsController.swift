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
//  NetworksSettingsController.swift
//  SocailEngineDemoForSwift


import UIKit
import Foundation
import NVActivityIndicatorView

// Global Variable Initialization Used in  Module
var networkUpdate: Bool!
class NetworksSettingsController: UIViewController , UITableViewDataSource, UITableViewDelegate  {
    let mainView = UIView()
    var networkOrMyNetwork = true                   // true for Available & false for My Networks
    var showSpinner = true                      // not show spinner at pull to refresh
    var networkResponse = [AnyObject]()            // For response come from Server
    var isPageRefresing = false                 // For Pagination
    var networkTableView:UITableView!              // TAbleView to show the network Contents
    var network:UIButton!                    // Network Types
    var myNetwork:UIButton!
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                 // Pagination Flag
    var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
    var fromActivityFeed = false
    var objectId:Int!
    var showOnlyMyContent = false
    var contentIcon : UILabel!
    var refreshButton : UIButton!
    var leftBarButtonItem : UIBarButtonItem!
    // Initialization of class Object
    override func viewDidLoad() {
        
        super.viewDidLoad()
        networkUpdate = true
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        openMenu = false
        updateAfterAlert = true
        
        let subViews = mainView.subviews
        for subview in subViews{
            subview.removeFromSuperview()
        }
        
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        contentIcon = createLabel(CGRect(x: 0,y: 0,width: 0,height: 0), text: "", alignment: .center, textColor: textColorMedium )
        mainView.addSubview(contentIcon)
        contentIcon.isHidden = true
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        
        self.title = NSLocalizedString("Available Networks",  comment: "")
        
        
        
        // Initialize Network Types
        network = createNavigationButton(CGRect(x: 0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) , title: NSLocalizedString("Available Networks",  comment: ""), border: true, selected: true)
        network.tag = 11
        network.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        network.addTarget(self, action: #selector(NetworksSettingsController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(network)
        
        
        myNetwork = createNavigationButton(CGRect(x: view.bounds.width/2.0, y: TOPPADING ,width: view.bounds.width/2.0  , height: ButtonHeight) , title: NSLocalizedString("My Networks",  comment: ""), border: true, selected: false)
        myNetwork.tag = 22
        myNetwork.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        myNetwork.addTarget(self, action: #selector(NetworksSettingsController.prebrowseEntries(_:)), for: .touchUpInside)
        mainView.addSubview(myNetwork)
        
        
        // Create Filter Search Link
        let filter = createButton(CGRect(x: PADING, y: TOPPADING + contentPADING + ButtonHeight, width: ButtonHeight - PADING , height: ButtonHeight - PADING), title: "F", border: true,bgColor: false, textColor: textColorDark)

        filter.addTarget(self, action: #selector(NetworksSettingsController.filterSerach), for: .touchUpInside)
        mainView.addSubview(filter)
        
    
        // Initialize Network Table
        networkTableView = UITableView(frame: CGRect(x: 0, y: ButtonHeight+TOPPADING , width: view.bounds.width, height: view.bounds.height-(filter.bounds.height + 2 * contentPADING + filter.frame.origin.y)), style: .grouped)
        networkTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        networkTableView.dataSource = self
        networkTableView.delegate = self
        networkTableView.backgroundColor = tableViewBgColor
        networkTableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            networkTableView.estimatedSectionHeaderHeight = 0
        }
        mainView.addSubview(networkTableView)
        
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(NetworksSettingsController.refresh), for: UIControl.Event.valueChanged)
        networkTableView.addSubview(refresher)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        networkTableView.tableFooterView = footerView
        networkTableView.tableFooterView?.isHidden = true
        
        if logoutUser == true || showOnlyMyContent == true{
            network.isHidden = true
            myNetwork.isHidden = true
            filter.frame.origin.y = TOPPADING
            networkTableView.frame.origin.y = filter.bounds.height + 2 * contentPADING + filter.frame.origin.y
            networkTableView.frame.size.height = view.bounds.height - (filter.bounds.height + 2 * contentPADING + filter.frame.origin.y)
            let addCancel = UIBarButtonItem(title: NSLocalizedString("",  comment: ""), style:.plain , target:self , action: #selector(NetworksSettingsController.cancleSearch))
            self.navigationItem.rightBarButtonItem = addCancel
            
            
        }
        //        network.layer.borderColor = navColor.cgColor
        //        network.backgroundColor = navColor
        //        myNetwork.backgroundColor = textColorLight
        //        network.setTitleColor(textColorLight, forState: .normal)
        //        myNetwork.setTitleColor(navColor, forState: .normal)
        //        myNetwork.layer.borderColor = navColor.cgColor
        //
        
        myNetwork.setUnSelectedButton()
        network.setSelectedButton()
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(NetworksSettingsController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
    

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        networkTableView.tableFooterView?.isHidden = true
    }
    
    // Check for Network Update Every Time when View Appears
    override func viewDidAppear(_ animated: Bool) {
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }
        networkTableView.reloadData()
        if (networkUpdate == true){
            pageNumber = 1
            showSpinner = true
            updateScrollFlag = false
            browseEntries()
        }
        
    }
  
    // Handle TapGesture On Open Slide Menu
    func handleTap(_ recognizer: UITapGestureRecognizer) {
        openMenu = false
        openMenuSlideOnView(mainView)
        mainView.removeGestureRecognizer(tapGesture)
    }

    
    // Cancle Search Result for Logout User
    @objc func cancleSearch(){
        searchDic.removeAll(keepingCapacity: false)
        searchDic["search"] = ""
        pageNumber = 1
        showSpinner = true
        self.navigationItem.rightBarButtonItem?.title = ""
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        browseEntries()
    }
    
    
    // Open Filter Search Form
    @objc func filterSerach(){
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
        }else{
            searchDic.removeAll(keepingCapacity: false)
            networkUpdate = false
            let presentedVC = FilterSearchViewController()
            presentedVC.searchUrl = "blogs/browse-search-form"
            presentedVC.serachFor = "blog"
            isCreateOrEdit = true
            navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    
    
    // Handle Browse Network or My Network PreAction
    @objc func prebrowseEntries(_ sender: UIButton){
        // true for Network & false for My Network
        if openMenu{
            openMenu = false
            openMenuSlideOnView(mainView)
            return
        }
        
        if sender.tag == 22 {
            networkOrMyNetwork = false
        }else if sender.tag == 11 {
            networkOrMyNetwork = true
        }
        networkTableView.tableFooterView?.isHidden = true
        self.networkResponse.removeAll(keepingCapacity: false)
        searchDic.removeAll(keepingCapacity: false)
        updateScrollFlag = false
        pageNumber = 1
        showSpinner = true
        // Update for Network
        browseEntries()
    }
    
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        //  if networkResponse.count != 0{
        if Reachabable.isConnectedToNetwork() {
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
        //   }
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
    
    // Update Network
    @objc func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            if showOnlyMyContent == true{
                networkOrMyNetwork = false
            }
            
            // Reset Objects
            for ob in mainView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            contentIcon.isHidden = true
            refreshButton.isHidden = true
            
            if (self.pageNumber == 1){
                self.networkResponse.removeAll(keepingCapacity: false)
                
                if updateAfterAlert == true || searchDic.count > 0 {
                    removeAlert()
                    self.networkTableView.reloadData()
                }else{
                    updateAfterAlert = true
                }
            }
            
            if (showSpinner){
             //   spinner.center = mainView.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
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
            // Set Parameters for Browse/myNetwork
            if networkOrMyNetwork {
                path = "members/settings/network"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                self.title = NSLocalizedString("Available Networks",  comment: "")
                myNetwork.setUnSelectedButton()
                network.setSelectedButton()
                
                
            }else{
                path = "members/settings/network"
                parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
                self.title = NSLocalizedString("My Networks",  comment: "")
                myNetwork.setSelectedButton()
                network.setUnSelectedButton()
            }
            // Set Parameters for Search
            if searchDic.count > 0 {
                parameters.merge(searchDic)
            }
            
            // Send Server Request to Browse Network Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    self.networkTableView.tableFooterView?.isHidden = true
                    if msg{
                        
                        if self.pageNumber == 1{
                            self.networkResponse.removeAll(keepingCapacity: false)
                        }
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            if(self.networkOrMyNetwork){
                                
                                if let blog = response["availableNetworks"] as? NSArray {
                                    self.networkResponse = self.networkResponse + (blog as [AnyObject])
                                }
                                
                            }else{
                                
                                if let blog = response["joinedNetworks"] as? NSArray {
                                    self.networkResponse = self.networkResponse + (blog as [AnyObject])
                                }
                                
                            }
                            
                            if response["totalItemCount"] != nil{
                                self.totalItems = response["totalItemCount"] as! Int
                            }
                            
                        }
                        
                        self.isPageRefresing = false
                        //Reload Network Tabel
                        self.networkTableView.reloadData()
                        //    if succeeded["message"] != nil{
                        if self.networkResponse.count == 0{
                            
                            self.contentIcon = createLabel(CGRect(x: self.view.bounds.width/2 - 30, y: self.view.bounds.height/2-80,width: 60 , height: 60), text: NSLocalizedString("\u{f013}",  comment: "") , alignment: .center, textColor: textColorMedium)
                            
                            self.contentIcon.font = UIFont(name: "FontAwesome", size: 40)
                            self.mainView.addSubview(self.contentIcon)
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any network.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.mainView.addSubview(self.info)
                            
                            self.refreshButton = createButton(CGRect(x: self.view.bounds.width/2-40, y: self.info.bounds.height + self.info.frame.origin.y + (2 * contentPADING ), width: 80, height: 40), title: NSLocalizedString("Try Again",  comment: ""), border: true, bgColor: true, textColor: navColor)
                            self.refreshButton.backgroundColor = bgColor
                            self.refreshButton.layer.borderColor = navColor.cgColor
                            self.refreshButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
                            self.refreshButton.addTarget(self, action: #selector(NetworksSettingsController.browseEntries), for: UIControl.Event.touchUpInside)

                            self.refreshButton.layer.cornerRadius = 5.0
                            self.refreshButton.layer.masksToBounds = true
                            self.mainView.addSubview(self.refreshButton)
                            
                            self.contentIcon.isHidden = false
                            self.refreshButton.isHidden = false
                            
                        }
                        
                    }else{
                        
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                    }
                    
                })
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Network Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
    }
    
    // Set Network Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set Network Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return networkResponse.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.blue
        var networkInfo:NSDictionary
        
        networkInfo = networkResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        
        cell.textLabel!.text = networkInfo["title"] as? String
        
        var buttonLabel : String
        
        if(self.networkOrMyNetwork){
            buttonLabel = NSLocalizedString("Join",  comment: "")
        }else{
            buttonLabel = NSLocalizedString("Leave",  comment: "")
        }
        
        let optionMenu = createButton(CGRect(x: view.bounds.width - 100, y: 0, width: 100, height: cell.bounds.height), title: buttonLabel , border: false, bgColor: false, textColor: textColorDark)
        
        //  optionMenu.setBackgroundImage(UIImage(named: "icon-option.png"), forState: .normal)
        optionMenu.addTarget(self, action: #selector(NetworksSettingsController.menuAction(_:)), for: .touchUpInside)

        
        optionMenu.tag = networkInfo["network_id"] as! Int
        
        cell.accessoryView = optionMenu
        return cell
        
    }
    
    
    // Handle Blog Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        //        var networkInfo = networkResponse[indexPath.row] as! NSDictionary

        
    }
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        if updateScrollFlag{
//            // Check for Page Number for Browse Network
//            if networkTableView.contentOffset.y >= networkTableView.contentSize.height - networkTableView.bounds.size.height{
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
//                // Check for Page Number for Browse Network
//                if networkTableView.contentOffset.y >= networkTableView.contentSize.height - networkTableView.bounds.size.height{
                    if (!isPageRefresing  && limit*pageNumber < totalItems){
                        if Reachabable.isConnectedToNetwork() {
                            updateScrollFlag = false
                            pageNumber += 1
                            isPageRefresing = true
                            networkTableView.tableFooterView?.isHidden = false
                          //  if searchDic.count == 0{
                                browseEntries()
                          //  }
                        }
                    }
                    else
                    {
                        networkTableView.tableFooterView?.isHidden = true
                }
                    
            //    }
                
            }
            
        }
        
    }
    
    @objc func menuAction(_ sender:UIButton){
        let networkId = sender.tag
        updateNetwork(networkId as Int)
        
    }
    
    func updateNetwork(_ networkId : Int){
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
            
            var path = ""
            var parameters = [String:String]()
            // Set Parameters for Browse/myNetwork
            if networkOrMyNetwork {
                path = "members/settings/network"
                parameters = ["join_id":"\(networkId)"]
            }else{
                path = "members/settings/network"
                parameters = ["leave_id":"\(networkId)"]
            }
            // Send Server Request to Browse Network Entries
            post(parameters, url: path, method: "POST") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    updateAfterAlert = false
                    self.browseEntries()
                    self.networkTableView.reloadData()
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    @objc func goBack(){

        _ = self.navigationController?.popViewController(animated: true)

        
    }
    
    
    
    //    override func viewWillDisappear(animated: Bool) {
    //
    //        mainView.removeGestureRecognizer(tapGesture)
    //       //  searchDic.removeAll(keepingCapacity: false)
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
