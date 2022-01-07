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
//  PhotoListViewController.swift
//  seiosnativeapp


import UIKit
import NVActivityIndicatorView
var refreshPhotos:Bool!
import SquareFlowLayout
class PhotoListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate {
    enum CellType {
        case normal
        case expanded
    }
    var mytitle:String!
    var url: String = ""
    var param: NSMutableDictionary!
  //  var allPhotos = [AnyObject]()
    var gpPhotostableView:UITableView!
    var photoCollectionView : UICollectionView!
    var dynamicHeight:CGFloat = 100
    var photos:[PhotoViewer] = []
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var isPageRefresing = false
    var updateScrollFlag = true
    var refresher:UIRefreshControl!
    var showSpinner = true
    var contentType : String = ""
//    var imageCache = [String:UIImage]()
//    var imageCache1 = [String:UIImage]()
    var listingId : String!
    var listingTypeId : Int!
    var leftBarButtonItem : UIBarButtonItem!
    var marqueeHeader : MarqueeLabel!
    private let patternValues: [CellType] = [
        .normal, .expanded, .normal, .normal, .normal, .normal, .normal, .normal, .normal, .expanded, .normal, .normal, .normal, .normal, .normal, .normal, .normal, .normal,
        ]
    var patternArray = [CellType]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = UIColor.white
        view.backgroundColor = bgColor
        refreshPhotos = true
        self.tabBarController?.delegate = self
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(PhotoListViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        var size:CGFloat = 0;
        
        gpPhotostableView = UITableView(frame: CGRect(x: 0,y: 0 , width: view.bounds.width, height: view.bounds.height - tabBarHeight), style:.grouped)
        gpPhotostableView.register(PhotoViewCell.self, forCellReuseIdentifier: "Cell")
        gpPhotostableView.rowHeight = 120.0
        gpPhotostableView.dataSource = self
        gpPhotostableView.delegate = self
        gpPhotostableView.backgroundColor = tableViewBgColor
        gpPhotostableView.separatorColor = UIColor.clear
        // For ios 11 spacing issue below the navigation controller
        if #available(iOS 11.0, *) {
            gpPhotostableView.estimatedRowHeight = 0
            gpPhotostableView.estimatedSectionHeaderHeight = 0
            gpPhotostableView.estimatedSectionFooterHeight = 0
        }
       // view.addSubview(gpPhotostableView)
        let flowLayout = SquareFlowLayout()
        flowLayout.flowDelegate = self
        self.photoCollectionView = UICollectionView(frame: CGRect(x: 0,y: 0 , width: view.bounds.width, height: view.bounds.height - tabBarHeight), collectionViewLayout: flowLayout)
        self.photoCollectionView.collectionViewLayout = flowLayout
        self.photoCollectionView.dataSource = self
        self.photoCollectionView.delegate = self
        self.photoCollectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        self.photoCollectionView.backgroundColor = .white
        view.addSubview(photoCollectionView)
        if(UIDevice.current.userInterfaceIdiom == .pad){
            size = (UIScreen.main.bounds.width-30)/4
        }else{
            size = (UIScreen.main.bounds.width-15)/2
        }
        
        self.dynamicHeight = size + 5
        
        
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(PhotoListViewController.refresh), for: UIControl.Event.valueChanged)
        gpPhotostableView.addSubview(refresher)
        
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        gpPhotostableView.tableFooterView = footerView
        gpPhotostableView.tableFooterView?.isHidden = true
     
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)

        if let navigationBar = self.navigationController?.navigationBar
        {
            let firstFrame = CGRect(x: 68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            self.marqueeHeader.textColor = textColorPrime
            navigationBar.addSubview(marqueeHeader)
        }
        
        gpPhotostableView.reloadData()
        photoCollectionView.reloadData()
    }
    
    func createPattern(count : Int) {
        if patternArray.count > 0 {
            patternArray.removeAll()
        }
        patternArray = [CellType](repeating: .normal, count: count)
        var i = 0
        var j = 0
        while i < count {
            patternArray[i] = patternValues[j]
            j += 1
            if j == patternValues.count {
                j = 0
            }
            i += 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        
        setNavigationImage(controller: self)
        if refreshPhotos == true{
            refreshPhotos = false
            
            if self.contentType == "product_photo"{
               // param = [ : ]
                exploreAllPhotos(url, parameter: param)
            }
            else
            {
                if url != "" 
                {
                    exploreAllPhotos(url, parameter: param)
                }
            }
        }else{
            self.marqueeHeader.text = self.mytitle
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        gpPhotostableView.tableFooterView?.isHidden = true
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        navigationController?.navigationBar.isHidden = false
//        setNavigationImage(controller: self)
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
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        //    if allPhotos.count != 0{
        if Reachabable.isConnectedToNetwork() {

            showSpinner = false
            pageNumber = 1
            if self.contentType == "siteevent_photo" || self.contentType == "product_photo"{
                //param = [ : ]
                exploreAllPhotos(url, parameter: param)
            }
            else{
                
                if url != "" && param.count > 0{
                    exploreAllPhotos(url, parameter: param)
                }
            }
            
        }
        else
        {
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
        //  }
    }
    
    func exploreAllPhotos(_ url:String, parameter: NSDictionary){
        
        // Check Internet Connection
        self.view.isUserInteractionEnabled = false
        if Reachabable.isConnectedToNetwork() {
            
            removeAlert()
            if (self.pageNumber == 1){
                allPhotos.removeAll(keepingCapacity: false)
            }
            
            
            if (showSpinner){
                activityIndicatorView.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1){
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
              //  activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            var dic = Dictionary<String, String>()
            for (key, value) in parameter{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            dic["page"] = "\(pageNumber)"
            dic["limit"] = "\(limit)"
            dic["menu"] = "1"
            
            // Send Server Request to Explore Group Contents with Group_ID
            post(dic , url: url, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    activityIndicatorView.stopAnimating()
                    self.view.isUserInteractionEnabled = true
                    self.refresher.endRefreshing()
                    self.updateScrollFlag = true
                    self.showSpinner = false
                    if msg{
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        //print(succeeded)
                        if succeeded["body"] != nil{
                            
                            if let body = succeeded["body"] as? NSDictionary{
                                self.isPageRefresing = false
                                
                                if let canUpload = body["canUpload"] as? Bool{
                                    if canUpload{
                                        let upload = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(PhotoListViewController.uploadPhotos))
                                        self.navigationItem.rightBarButtonItem = upload
                                        upload.tintColor = textColorPrime
                                        
                                        let addBlog = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(PhotoListViewController.addphotos))
                                        addBlog.tintColor = textColorPrime
                                        self.navigationItem.setRightBarButtonItems([addBlog], animated: true)
                                        
                                    }
                                }
                                
                                if let images = body["albumPhotos"] as? NSArray{
                               
                                    allPhotos  = allPhotos + (images as! [NSDictionary])
                                    
                                }
                                if let images = body["images"] as? NSArray{
                                
                                    allPhotos  = allPhotos + (images as! [NSDictionary])
                                    
                                }
                                if let count  = body["totalItemCount"] as? Int
                                {
                                    self.totalItems = count
                                }
                                self.photos.removeAll(keepingCapacity: false)
                                self.photos = PhotoViewer.loadPhotosInfo(allPhotos as NSArray)
                                
                            }
                        }
                        self.createPattern(count: allPhotos.count)
                        self.marqueeHeader.text = "Photos (" + String(self.totalItems) + "): " + self.mytitle
                        self.gpPhotostableView.reloadData()
                        self.photoCollectionView.reloadData()
                        
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
    
    func cancel()
    {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        allPhotos.removeAll(keepingCapacity: false)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func uploadPhotos()
    {
        let presentedVC = UploadPhotosViewController()
        presentedVC.directUpload = false
        if self.contentType == "sitereview_photo"{
            presentedVC.contentType = "sitereview_photo"
        }
        presentedVC.url = url
        presentedVC.param = param
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        navigationController?.pushViewController(presentedVC, animated: true)
    }
    @objc func addphotos()
    {
        let presentedVC = UploadPhotosViewController()
        presentedVC.directUpload = false
        if url != ""
        {
            presentedVC.url = url
            if param.count>0{
                presentedVC.param = param
            }
        }
        else
        {
            
            presentedVC.url = "advancedvideo/channel/photo/\(param["subject_id"]!)"//dic["url"] as! String
            presentedVC.param = [ : ]
        }
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.navigationController?.pushViewController(presentedVC, animated: false)
    }
    @objc func openImage(_ sender:Int)
    {
        
        let presentedVC = AdvancePhotoViewController()//PhotoViewController()
        presentedVC.allphotos = allPhotos
        let photoInfo = allPhotos[sender]
       if let album_id = photoInfo["album_id"] as? Int
       {
          param["subject_id"] = String(album_id)
       }
        let openingImage = photoInfo["image"] as! String
        presentedVC.listingPhotoId = photoInfo["photo_id"] as! Int
        presentedVC.listingTypeId = listingTypeId
        presentedVC.photoID = sender
        presentedVC.photoType = contentType
        presentedVC.photoForViewer = photos
        presentedVC.total_items = totalItems
        presentedVC.contentType = contentType
        presentedVC.imageUrl = openingImage
        presentedVC.attachmentID = ""
        
        presentedVC.param = param
        presentedVC.url = url
        self.navigationController?.pushViewController(presentedVC, animated: false)

        
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if (limit*pageNumber < totalItems){
            return 0
        }else{
            return 0.00001
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var size:CGFloat = 0
        
        size = (UIScreen.main.bounds.width-15)/2
        return size + 10
        
    }
    
    // Set Album Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return Int(ceil(Float(allPhotos.count)/2))
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PhotoViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = tableViewBgColor
        
        var index:Int!
        index = (indexPath as NSIndexPath).row * 2
        if allPhotos.count > index {
            // cell.image1.imageView?.image = nil
            // cell.photo1.image = nil
            let photoInfo = allPhotos[index] 
            
            cell.image1.isHidden = false
            cell.photo1.isHidden = false
            cell.photo1.backgroundColor = placeholderColor
            if let url1 = URL( string:photoInfo["image"] as! NSString as String){
                cell.photo1.kf.indicatorType = .activity
                (cell.photo1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.photo1.kf.setImage(with: url1 , placeholder: UIImage(named : "album-default.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    cell.image1.tag = index
                   // cell.image1.addTarget(self, action: #selector(PhotoListViewController.openImage(_:)), for: .touchUpInside)
                    cell.image1.contentMode = UIView.ContentMode.scaleAspectFill
                })
                
            }
            
            var totalView = ""
            if let likes = photoInfo["like_count"] as? Int{
                totalView = "\(likes) \(likeIcon)"
            }
            if let comment = photoInfo["comment_count"] as? Int{
                totalView += " \(comment) \(commentIcon)"
            }
            
            cell.likeCommentLabel.text = "\(totalView)"
            cell.likeCommentLabel.font = UIFont(name: "FontAwesome", size:FONTSIZENormal )
            
            
        }
        else{
            cell.image1.isHidden = true
            cell.image2.isHidden = true
            cell.photo1.isHidden = true
            cell.photo2.isHidden = true
            return cell
        }
        
        if allPhotos.count > (index + 1){
            // cell.image2.imageView?.image = nil
            let photoInfo = allPhotos[index + 1] 
            
            cell.image2.isHidden = false
            cell.photo2.isHidden = false
            cell.photo2.backgroundColor = placeholderColor
            //cell.photo2.image = nil
            if let url1 = URL(string: photoInfo["image"] as! String){
                cell.photo2.kf.indicatorType = .activity
                (cell.photo2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.photo2.kf.setImage(with: url1 , placeholder: UIImage(named : "album-default.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    cell.image2.tag = index+1
                    //cell.image2.addTarget(self, action: #selector(PhotoListViewController.openImage(_:)), for: .touchUpInside)
                    cell.image2.contentMode = UIView.ContentMode.scaleAspectFill
                })
            }
            
            var totalView = ""
            if let likes = photoInfo["like_count"] as? Int{
                totalView = "\(likes) \(likeIcon)"
            }
            if let comment = photoInfo["comment_count"] as? Int{
                totalView += " \(comment) \(commentIcon)"
            }
            
            cell.likeCommentLabel1.text = "\(totalView)"
            cell.likeCommentLabel1.font = UIFont(name: "FontAwesome", size:FONTSIZENormal )
        }
        else{
            cell.image2.isHidden = true
            cell.photo2.isHidden = true
            
            return cell
        }
        return cell
    }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        //if updateScrollFlag{
//        // Check for Page Number for Browse Blog
//        if  gpPhotostableView.contentOffset.y >= gpPhotostableView.contentSize.height - gpPhotostableView.bounds.size.height{
//            if (!isPageRefresing  && limit*pageNumber < totalItems){
//                if Reachabable.isConnectedToNetwork() {
//                    updateScrollFlag = false
//                    pageNumber += 1
//                    isPageRefresing = true
//                    if self.contentType == "siteevent_photo"{
//                        param = [ : ]
//                        exploreAllPhotos(url, parameter: param)
//                    }
//                    else{
//
//                        if url != "" && param.count > 0{
//                            exploreAllPhotos(url, parameter: param)
//                        }
//                    }
//                }
//            }
//
//        }
//
//        // }
//
//    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if (!isPageRefresing  && limit*pageNumber < totalItems){
                if Reachabable.isConnectedToNetwork() {
                    updateScrollFlag = false
                    pageNumber += 1
                    isPageRefresing = true
                    gpPhotostableView.tableFooterView?.isHidden = false
                    if self.contentType == "siteevent_photo"{
                        param = [ : ]
                        exploreAllPhotos(url, parameter: param)
                    }
                    else{
                        
                        if url != "" && param.count > 0{
                            exploreAllPhotos(url, parameter: param)
                        }
                    }
                }
            }
            else
            {
                gpPhotostableView.tableFooterView?.isHidden = true
            }

        }
        
    }
  
    
    @objc func goBack()
    {
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



extension PhotoListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        print("count--\(allPhotos.count)")
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        let photoInfo = allPhotos[indexPath.row]
        if let url1 = URL( string:photoInfo["image"] as! NSString as String){
            cell.imageView.kf.indicatorType = .activity
            (cell.imageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.imageView.kf.setImage(with: url1 , placeholder: UIImage(named : "album-default.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                cell.imageView.tag = indexPath.row
                // cell.image1.addTarget(self, action: #selector(PhotoListViewController.openImage(_:)), for: .touchUpInside)
                cell.imageView.contentMode = UIView.ContentMode.scaleAspectFill
            })
            
        }
        return cell
    }
    
  
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openImage(indexPath.row)
    }
}

extension PhotoListViewController: SquareFlowLayoutDelegate {
    func shouldExpandItem(at indexPath: IndexPath) -> Bool {
        if patternArray[indexPath.row] == .expanded {
            return true
        }
        else {
            return false
        }
    }
}

