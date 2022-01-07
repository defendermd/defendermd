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

//  ChooseFromAlbumsViewController.swift

import UIKit
import NVActivityIndicatorView

var chooseFromAlbumsUpdate :Bool!

class ChooseFromAlbumsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate{
    
    let mainView = UIView()
    var showSpinner = true                       // not show spinner at pull to refresh
    var albumResponse = [AnyObject]()            // For response come from Server
    var isPageRefresing = false                  // For Pagination
    var albumTableView:UITableView!              // TAbleView to show the Album Contents
    var refresher:UIRefreshControl!              // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var info:UILabel!
    var updateScrollFlag = true                  // Pagination Flag
    var showOnlyMyContent:Bool!
  //  var imageCache = [String:UIImage]()
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    
    var imgUser:UIImageView!
    var labTitle:UILabel!
    var imageview:UILabel!
    var profileOrCoverChange: Bool! //true => profile photo, false => cover photo
    var leftBarButtonItem : UIBarButtonItem!
    var contentType = ""
    var contentId  = ""
    var contentUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel",  comment: ""), style:.plain , target:self , action: #selector(ChooseFromAlbumsViewController.goBack))
        self.navigationItem.rightBarButtonItem = cancelButton
        cancelButton.tintColor = textColorPrime
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        openMenu = false
        updateAfterAlert = true
        
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        
        albumTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height - TOPPADING), style: .grouped)
        
        
        albumTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height - tabBarHeight - TOPPADING), style: .grouped)
        albumTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "albumCell")
        albumTableView.rowHeight = 250
        albumTableView.dataSource = self
        albumTableView.delegate = self
        albumTableView.isOpaque = false
        self.automaticallyAdjustsScrollViewInsets = false
        albumTableView.backgroundColor = tableViewBgColor
        mainView.addSubview(albumTableView)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        albumTableView.tableFooterView = footerView
        albumTableView.tableFooterView?.isHidden = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = NSLocalizedString("Select an Album",  comment: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        browseEntries()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        albumTableView.tableFooterView?.isHidden = true
        globFilterValue = ""
    }
    
    
    // Cancle Search Result for Logout User
    func cancelUpload(){
        browseEntries()
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer:Bool){
        self.view.addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer{
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer() {
        stop()
       // if popAfterDelay == true{
            _ = self.navigationController?.popViewController(animated: true)
            
       // }
    }
    // Update Album
    func browseEntries(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
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
//                self.mainView.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
               // activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            var path = ""
            var parameters = [String:String]()
            
            // Set Parameters for Browse/MyAlbum
            if contentType == "sitepage_page"{
              path = "sitepage/photos/index/\(self.contentId)"
            }
                else if contentType == "sitegroup_group"{
                
                path = "advancedgroups/photos/index/\(self.contentId)"
            }
            else{
            path = "albums/manage"
            }
            parameters = ["page":"\(pageNumber)" , "limit": "\(limit)"]
            
            // Send Server Request to Browse Album Entries
            post(parameters, url: path, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    
                    self.showSpinner = false
                    self.updateScrollFlag = true
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
                        self.albumTableView.reloadData()
                        
                        if self.albumResponse.count == 0{
                            
                            self.info = createLabel(CGRect(x: 0, y: 0,width: self.view.bounds.width * 0.8 , height: 50), text: NSLocalizedString("You do not have any Album entries.",  comment: "") , alignment: .center, textColor: textColorMedium)
                            self.info.sizeToFit()
                            self.info.numberOfLines = 0
                            self.info.center = self.view.center
                            self.info.backgroundColor = bgColor
                            self.info.tag = 1000
                            self.mainView.addSubview(self.info)
                            
                        }
                    }else{
                        
                        // Handle Server Side Error
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
    
    // Set Album Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        if (limit*pageNumber < totalItems){
            return 0
            
        }else{
            return 0.00001
        }
        
    }
    
    // Set Album Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    // Set Album Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return albumResponse.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "albumCell", for: indexPath) as! CustomTableViewCell
        
        let albumInfo = albumResponse[(indexPath as NSIndexPath).row]
        
        let albumTitle = albumInfo["title"] as! String
        let photoCount = albumInfo["photo_count"] as! Int
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.lineView.isHidden = false
        
        cell.imgUser.frame = CGRect(x: 5, y: 7, width: 60, height: 60)
        
        
        // Set Blog Title
        cell.labTitle.frame = CGRect(x: cell.imgUser.bounds.width + 10, y: 10, width: cell.bounds.width - (cell.imgUser.bounds.width + 15), height: 20)
        cell.labTitle.text = String(format: NSLocalizedString("%@ (%@)", comment: ""), albumTitle, "\(photoCount)")
        cell.labTitle.numberOfLines = 2
        cell.labTitle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        
        cell.labTitle.font = UIFont(name: fontName, size: FONTSIZELarge)
        cell.labTitle.sizeToFit()
        
        

        
        if let url = URL(string: albumInfo["image"] as! String){
            cell.imgUser.kf.indicatorType = .activity
            (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.imgUser.kf.setImage(with: url, placeholder: UIImage(named : "default_blog_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        cell.lineView.frame = CGRect(x: 0, y: cell.bounds.height, width: (UIScreen.main.bounds).width, height: 2)
        cell.lineView.isHidden = false
        
        return cell;
        
        // Set Listing Owner Image
        
    }
    

        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Apply condition for tableViews
        
        let albumInfo:NSDictionary!
        albumInfo = albumResponse[(indexPath as NSIndexPath).row] as! NSDictionary
        let presentedVC = ChoosePhotoViewController()
        presentedVC.albumId = albumInfo["album_id"] as! Int
        if let _ : Int = albumInfo["page_id"] as? Int{
        presentedVC.pageId = albumInfo["page_id"] as! Int
        }
        if let _ : Int = albumInfo["group_id"] as? Int{
         presentedVC.pageId = albumInfo["group_id"] as! Int
        }
        presentedVC.profileOrCoverChange = self.profileOrCoverChange
        presentedVC.contentType = contentType
        presentedVC.contentId = "\(contentId)"
        self.navigationController?.pushViewController(presentedVC, animated: false)
 
    }
    
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if updateScrollFlag{
//            // Check for Page Number for Browse Album
//            if albumTableView.contentOffset.y >= albumTableView.contentSize.height - albumTableView.bounds.size.height{
//                if (!isPageRefresing  && limit*pageNumber < totalItems){
//                    if Reachabable.isConnectedToNetwork() {
//                        updateScrollFlag = false
//                        pageNumber += 1
//                        isPageRefresing = true
//                        browseEntries()
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
                if (!isPageRefresing  && limit*pageNumber < totalItems){
                    if Reachabable.isConnectedToNetwork() {
                        updateScrollFlag = false
                        pageNumber += 1
                        isPageRefresing = true
                        albumTableView.tableFooterView?.isHidden = false
                        browseEntries()
                    }
                }
                else
                {
                    albumTableView.tableFooterView?.isHidden = true
                }
                
            }
            
        }
        
    }
    @objc func goBack(){
        _ = self.navigationController?.popViewController(animated: false)
    }
    
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
