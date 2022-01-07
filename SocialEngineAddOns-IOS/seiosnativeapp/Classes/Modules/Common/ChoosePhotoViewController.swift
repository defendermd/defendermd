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
//  ChoosePhotoViewController.swift
//  seiosnativeapp

import UIKit
import NVActivityIndicatorView

class ChoosePhotoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate
{

    var param: NSDictionary!
    let mainView = UIView()
    var showSpinner = true                      // not show spinner at pull to refresh
    var isPageRefresing = false                 // For Pagination
    var refresher:UIRefreshControl!             // Pull to refrresh
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var updateScrollFlag = true                 // Paginatjion Flag
    var showOnlyMyContent:Bool!
    var photoAlbum : UIButton!
    var refreshButton : UIButton!
    var albumPhotoTableView:UITableView!
    var allPhotos = [AnyObject]()
 //   var imageCache = [String:UIImage]()
    
    fileprivate var popover: Popover!
    fileprivate var popoverOptions: [PopoverOption] = [
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
    ]
    var albumId: Int! = 0
    var choosenPhoto = [UIImage]()
    var profileOrCoverChange: Bool! //true => profile photo, false => cover photo
    var fetchPhotosLimit = 25
    var leftBarButtonItem : UIBarButtonItem!
    var contentType = ""
    var contentId  = ""
    var pageId = 0
    var listingTypeId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
        
        openMenu = false
        updateAfterAlert = true
        albumUpdate = true
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ChoosePhotoViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        mainView.removeGestureRecognizer(tapGesture)
        
        refreshButton = createButton(CGRect(x: 0,y: 0,width: 0,height: 0), title: "", border: true, bgColor: true, textColor: navColor)
        mainView.addSubview(refreshButton)
        refreshButton.isHidden = true
        
        albumPhotoTableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height - TOPPADING - tabBarHeight), style: .grouped)
        
        albumPhotoTableView.register(ChoosePhotoTableViewCell.self, forCellReuseIdentifier: "Cell")
        var size:CGFloat = 0;
        if(UIDevice.current.userInterfaceIdiom == .pad){
            size = (UIScreen.main.bounds.width-30)/4
        }else{
            size = (UIScreen.main.bounds.width-15)/2
        }
        albumPhotoTableView.rowHeight = size
        albumPhotoTableView.dataSource = self
        albumPhotoTableView.delegate = self
        albumPhotoTableView.backgroundColor = tableViewBgColor
        albumPhotoTableView.separatorColor = TVSeparatorColor
        mainView.addSubview(albumPhotoTableView)
        albumPhotoTableView.isHidden = false
        albumPhotoTableView.tag = 101
        if #available(iOS 11.0, *)
        {
            albumPhotoTableView.estimatedRowHeight = 0
            albumPhotoTableView.estimatedSectionFooterHeight = 0
            albumPhotoTableView.estimatedSectionHeaderHeight = 0
        }
        
        // Initialize Reresher for Table (Pull to Refresh)
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(ChoosePhotoViewController.refresh), for: UIControl.Event.valueChanged)
        albumPhotoTableView.addSubview(refresher)
 
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        albumPhotoTableView.tableFooterView = footerView
        albumPhotoTableView.tableFooterView?.isHidden = true
        
        
        
        explorePhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = NSLocalizedString("Pick photos",  comment: "")
    }
    override func viewWillDisappear(_ animated: Bool) {
        albumPhotoTableView.tableFooterView?.isHidden = true
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource

    // Set Album Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    // Set Height Of Row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var size:CGFloat = 0
        size = (UIScreen.main.bounds.width - (2 * PADING))/4
        return size + 10
    }
    
    // Set Number Of Section In Table
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return Int(ceil(Float(allPhotos.count)/4))
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChoosePhotoTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = tableViewBgColor
        
        var index:Int!
        index = (indexPath as NSIndexPath).row * 4
        if allPhotos.count > index {
            
            let photoInfo = allPhotos[index] as! NSDictionary
            
            cell.image1.isHidden = false
            cell.photo1.isHidden = false
            cell.photo1.backgroundColor = placeholderColor
            if let url1 = URL( string:photoInfo["image"] as! NSString as String){
                cell.photo1.kf.indicatorType = .activity
                (cell.photo1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.photo1.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    cell.image1.tag = index
                    cell.image1.addTarget(self, action: #selector(ChoosePhotoViewController.previewSelectedPhoto(_:)), for: .touchUpInside)
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
            
            cell.contentSelection1.tag = index
            cell.contentSelection1.addTarget(self, action: #selector(ChoosePhotoViewController.previewSelectedPhoto(_:)), for: .touchUpInside)
            
            
        }
        else{
            cell.image1.isHidden = true
            cell.image2.isHidden = true
            cell.image3.isHidden = true
            cell.image4.isHidden = true
            cell.photo1.isHidden = true
            cell.photo2.isHidden = true
            cell.photo3.isHidden = true
            cell.photo4.isHidden = true
            
            return cell
        }
        
        if allPhotos.count > (index + 1){
            
            let photoInfo = allPhotos[index + 1] as! NSDictionary
            
            cell.image2.isHidden = false
            cell.photo2.isHidden = false
            cell.photo2.backgroundColor = placeholderColor
            
            if let url1 = URL(string: photoInfo["image"] as! String){
                cell.photo2.kf.indicatorType = .activity
                (cell.photo2.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.photo2.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    cell.image2.tag = index+1
                    cell.image2.addTarget(self, action: #selector(ChoosePhotoViewController.previewSelectedPhoto(_:)), for: .touchUpInside)
                    cell.image2.contentMode = UIView.ContentMode.scaleAspectFill
                })
            }
            
            cell.likeCommentLabel1.isHidden = true
            cell.contentSelection2.tag = index+1
            cell.contentSelection2.addTarget(self, action: #selector(ChoosePhotoViewController.previewSelectedPhoto(_:)), for: .touchUpInside)
        }
        else{
            
            cell.image2.isHidden = true
            cell.image3.isHidden = true
            cell.image4.isHidden = true
            cell.photo2.isHidden = true
            cell.photo3.isHidden = true
            cell.photo4.isHidden = true
            
            return cell
        }
        
        if allPhotos.count > (index + 2){
            // cell.image2.imageView?.image = nil
            let photoInfo = allPhotos[index + 2] as! NSDictionary
            
            cell.image3.isHidden = false
            cell.photo3.isHidden = false
            cell.photo3.backgroundColor = placeholderColor
            //cell.photo3.image = nil
            if let url1 = URL(string: photoInfo["image"] as! String){
                cell.photo3.kf.indicatorType = .activity
                (cell.photo3.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.photo3.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    cell.image3.tag = index+2
                    cell.image3.addTarget(self, action: #selector(ChoosePhotoViewController.previewSelectedPhoto(_:)), for: .touchUpInside)
                    cell.image3.contentMode = UIView.ContentMode.scaleAspectFill
                })
                
            }
            
            cell.likeCommentLabel1.isHidden = true
            cell.contentSelection3.tag = index + 2
            cell.contentSelection3.addTarget(self, action: #selector(ChoosePhotoViewController.previewSelectedPhoto(_:)), for: .touchUpInside)
        }
        else{
            cell.image3.isHidden = true
            cell.image4.isHidden = true
            cell.photo3.isHidden = true
            cell.photo4.isHidden = true
            
            return cell
        }
        
        if allPhotos.count > (index + 3){
            
            let photoInfo = allPhotos[index + 3] as! NSDictionary
            
            cell.image4.isHidden = false
            cell.photo4.isHidden = false
            cell.photo4.backgroundColor = placeholderColor
            
            if let url1 = URL(string: photoInfo["image"] as! String){
                cell.photo4.kf.indicatorType = .activity
                (cell.photo4.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                cell.photo4.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                    cell.image4.tag = index+3
                    cell.image4.addTarget(self, action: #selector(ChoosePhotoViewController.previewSelectedPhoto(_:)), for: .touchUpInside)
                    cell.image4.contentMode = UIView.ContentMode.scaleAspectFill
                })
            }
            
            cell.likeCommentLabel1.isHidden = true
            cell.contentSelection4.tag = index + 3
            cell.contentSelection4.addTarget(self, action: #selector(ChoosePhotoViewController.previewSelectedPhoto(_:)), for: .touchUpInside)
        }
        else{
            cell.image4.isHidden = true
            cell.photo4.isHidden = true
            
            return cell
        }
        
        return cell
        
    }

    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if (fetchPhotosLimit*pageNumber < totalItems){
                if Reachabable.isConnectedToNetwork() {
                    updateScrollFlag = false
                    pageNumber += 1
                    albumPhotoTableView.tableFooterView?.isHidden = false
                    explorePhotos()
                }
            }
            else
            {
                albumPhotoTableView.tableFooterView?.isHidden = true
            }
        }
        
    }
    
    func explorePhotos(){
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            if (self.pageNumber == 1){
                self.allPhotos.removeAll(keepingCapacity: false)
            }
            if (showSpinner){
       //         spinner.center = view.center
                if updateScrollFlag == false {
               //     spinner.center = CGPoint(x: view.center.x, y: view.bounds.height-50)
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height - tabBarHeight - 50)

                }
                if (self.pageNumber == 1){
                    activityIndicatorView.center = view.center
                    updateScrollFlag = false
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
            //    activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            self.updateScrollFlag = true
            var path = ""
            if self.contentType == "sitepage_page"{
                path = "sitepage/photos/viewalbum/\(pageId)/\(albumId!)"
            }
                else if self.contentType == "sitegroup_group"{
                
                path = "advancedgroups/photos/viewalbum/\(pageId)/\(albumId!)"
            }
            else if self.contentType == "siteevent_event"{
                
                path = "advancedevents/photo/list/\(contentId)"
            }
            else if self.contentType == "sitereview_listing"{
                
                path = "listing/view/\(contentId)"
            }
            else{
               path = "albums/album/view"
            }
            
            if self.contentType == "sitereview_listing"{
                
               param = ["page" : "\(pageNumber)", "order" : "order DESC", "listingtype_id" : String(listingTypeId), "limit" :"\(fetchPhotosLimit)"]
            }
            else{

            param = ["page" : "\(pageNumber)", "order" : "order DESC", "album_id" : String(albumId), "limit" :"\(fetchPhotosLimit)"]
            }
            
            post( param as! Dictionary<String, String> , url: path, method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.showSpinner = false
                    self.refresher.endRefreshing()
                    if let body = succeeded["body"] as? NSDictionary{
                        
                        self.isPageRefresing = false
                        if let images = body["albumPhotos"] as? NSArray{
                            self.allPhotos = self.allPhotos + (images as [AnyObject])
                        }
                        if let images = body["images"] as? NSArray{
                            self.allPhotos = self.allPhotos + (images as [AnyObject])
                        }
                        
                        if self.allPhotos.count == 0{
                                showToast(message: "There are no any photos.", controller: self)
                                let triggerTime = (Int64(NSEC_PER_SEC) * 3)
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                    _ = self.navigationController?.popViewController(animated: true)
                                })
                         }
                        
                        if body["totalPhotoCount"] != nil{
                            self.totalItems = body["totalPhotoCount"] as! Int
                         }
                        
                        if body["totalItemCount"] != nil{
                            self.totalItems = body["totalItemCount"] as! Int
                         }
                        
                        self.albumPhotoTableView.reloadData()
                    }
                })
            }
         }
    }
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            showSpinner = false
            pageNumber = 1
            updateAfterAlert = false
            explorePhotos()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    
    @objc func previewSelectedPhoto(_ sender: UIButton){
        
        choosenPhoto.removeAll()
        
        let photoInfo = allPhotos[sender.tag] as! NSDictionary
        
        
        if let url = URL( string:photoInfo["image"] as! NSString as String){
            var imgView = UIImageView()
            imgView.kf.indicatorType = .activity
            (imgView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            imgView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                if let imgT = image
                {
                    self.choosenPhoto.append(imgT)
                }
            })
        }
        
        let presentedVC = UploadChoosenPhotosViewController()
        presentedVC.allPhotos = choosenPhoto
        presentedVC.directUpload = false
        presentedVC.param = [:]
        presentedVC.photoId = photoInfo["photo_id"] as! Int
        presentedVC.profileOrCoverChange = self.profileOrCoverChange
        presentedVC.contentType = contentType
        presentedVC.contentId = "\(contentId)"
        self.navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    @objc func goBack()
    {
        self.dismiss(animated: true, completion: nil)
        _ = self.navigationController?.popViewController(animated: true)
        
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
