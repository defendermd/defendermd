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
//  UploadChoosenPhotosViewController.swift
//  seiosnativeapp
//
//

import UIKit
import MobileCoreServices

class UploadChoosenPhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var selectedPhotostableView:UITableView!
    var dynamicHeight:CGFloat = 100
    var allPhotos = [UIImage]()
    var popAfterDelay:Bool!
    var url: String!
    var param: NSDictionary!
    var directUpload = true
    var showGallery = true
    var listingId : Int!
    var listingTypeId : Int!
    var contentType = ""
    var photoId: Int!
    var profileOrCoverChange: Bool! //true => profile photo, false => cover photo
    var leftBarButtonItem : UIBarButtonItem!
    var contentId  = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        view.backgroundColor = bgColor
        popAfterDelay = false
        mediaType = "image"
        
        if directUpload == false{
            let uploadImg = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style:.plain , target:self , action: #selector(UploadChoosenPhotosViewController.setChosenImage))
            self.navigationItem.rightBarButtonItem = uploadImg
            uploadImg.tintColor = textColorPrime
        }else{
            let uploadImg = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style:.plain , target:self , action: #selector(UploadChoosenPhotosViewController.uploadImages))
            self.navigationItem.rightBarButtonItem = uploadImg
            uploadImg.tintColor = textColorPrime
            
        }
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(UploadChoosenPhotosViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        
        self.edgesForExtendedLayout = UIRectEdge.all;
        self.automaticallyAdjustsScrollViewInsets = false;
        
        selectedPhotostableView = UITableView(frame: CGRect(x: 0, y: TOPPADING, width: view.bounds.width, height: view.bounds.height-TOPPADING - tabBarHeight), style: UITableView.Style.grouped)
        selectedPhotostableView.register(PhotosTableViewCell.self, forCellReuseIdentifier: "Cell")
        selectedPhotostableView.rowHeight = 120.0
        selectedPhotostableView.dataSource = self
        selectedPhotostableView.delegate = self
        selectedPhotostableView.backgroundColor = tableViewBgColor
        selectedPhotostableView.separatorColor = TVSeparatorColor
        if #available(iOS 11.0, *) {
            selectedPhotostableView.estimatedRowHeight = 0
            selectedPhotostableView.estimatedSectionHeaderHeight = 0
            selectedPhotostableView.estimatedSectionFooterHeight = 0
        }
        view.addSubview(selectedPhotostableView)

        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        self.title = ""
        setNavigationImage(controller: self)
        
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
        if popAfterDelay == true{
            
            let count = self.navigationController!.viewControllers.count
            let viewControllersStack = self.navigationController!.viewControllers
            
            if count >= 4{
                if (self.contentType == "siteevent_event") || (self.contentType == "sitereview_listing"){
                    _ = self.navigationController?.popToViewController(viewControllersStack[count-3], animated: true)
                }
                else{
                _ = self.navigationController?.popToViewController(viewControllersStack[count-4], animated: true)
                }
            }else{
                _ = self.navigationController?.popViewController(animated: true)

            }
        }
    }
    
    
    func selectedImages(){
        if allPhotos.count == 0 {
            return
        }else{
            
            filePathArray.removeAll(keepingCapacity: false)
            filePathArray = saveFileInDocumentDirectory(allPhotos)
            
            _ = navigationController?.popViewController(animated: true)

        }
    }
    
    @objc func uploadImages(){
        removeAlert()
        if allPhotos.count == 0 {
            return
        }
        
        // Check Internet Connection

        if Reachabable.isConnectedToNetwork() {

            self.navigationItem.rightBarButtonItem?.isEnabled = false
            view.isUserInteractionEnabled = false
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            filePathArray.removeAll(keepingCapacity: false)
            filePathArray = saveFileInDocumentDirectory(allPhotos)
            
            isCreateOrEdit = true
            
            var dic = Dictionary<String, String>()
            for (key, value) in param{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            //dic["listingtype_id"] = "\(listingTypeId)"
            // Send Server Request to Create/Edit Group Entries
            
            
            
            var isSinglePhoto = false
            if dic.index(forKey: "listingtype_id") != nil {
                isSinglePhoto = true
            }
            
            postForm(dic, url: url, filePath: filePathArray, filePathKey: "photo", SinglePhoto: isSinglePhoto ) { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.view.alpha = 1.0
                    self.view.isUserInteractionEnabled = true
                    if msg{
                        
                        for path in filePathArray{
                            removeFileFromDocumentDirectoryAtPath(path)
                        }
                        filePathArray.removeAll(keepingCapacity: false)
                        self.view.alpha = 1.0
                        self.view.isUserInteractionEnabled = true
                        // On Sucess Update Blog
                        if self.allPhotos.count == 1{
                            showToast(message: NSLocalizedString("Photo uploaded successfully", comment: ""), controller: self)
                        }
                        else{
                            showToast(message: NSLocalizedString("Photos uploaded successfully", comment: ""), controller: self)
                        }
                        
                        self.popAfterDelay = true
                        self.createTimer(self)
                        
                        contentFeedUpdate = true
                        listingDetailUpdate = true
                        refreshPhotos = true
                        update = true
                        updateFromAlbum = true
                        membersUpdate1 = true
                        
                    }else{
                        // Handle server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
        }else{
            
            //print("Internet problem")
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
        
    }
    
    //Function for setting chosen image
    @objc func setChosenImage(){
        
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
            
            var dic = Dictionary<String, String>()
            
            for (key, value) in param{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            var url = ""
            if contentType != ""{
                 url = "coverphoto/upload-cover-photo"
                dic["photo_id"] = String(photoId)
                dic["subject_id"] = String(contentId)
                dic["subject_type"] = contentType
                
                if profileOrCoverChange != nil && profileOrCoverChange == true{
                      dic["special"] = "profile"
                }
            }
            else{
            
            if profileOrCoverChange != nil && profileOrCoverChange == true{
             url = "user/profilepage/upload-cover-photo/user_id/" + String(currentUserId) + "/photo_id/" + String(photoId) + "/special/profile"
            }else{
             url = "user/profilepage/upload-cover-photo/user_id/" + String(currentUserId) + "/photo_id/" + String(photoId) + "/special/cover"
            }
            }
            
            // Send Server Request to Explore Blog Contents with Blog_ID
            post(dic, url: "\(url)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Blog Detail
                        // Update Blog Detail
                        
                        if succeeded["message"] != nil{
                            showToast(message: NSLocalizedString("Photo changed successfully", comment: ""), controller: self)
                        }
                        else{
                            showToast(message: NSLocalizedString("Photo changed successfully", comment: ""), controller: self)
                        }
                        
                        updateUserData()
                        contentFeedUpdate = true
                        pageUpdate = true
                        advgroupUpdate = true
                        pageDetailUpdate = true
                        advGroupDetailUpdate = true
                        listingDetailUpdate = true
                        refreshPhotos = true
                        update = true
                        updateFromAlbum = true
                        feedUpdate = true
                        self.popAfterDelay = true
                        self.createTimer(self)
                        
                    }
                        
                    else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
            
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    //set Height for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    // Set Table Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    // Set Table Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if(UIDevice.current.userInterfaceIdiom == .pad){
            return Int(ceil(Float(allPhotos.count)/4))
        }else{
            return Int(ceil(Float(allPhotos.count)/2))
        }
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PhotosTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = tableViewBgColor
        
        var index:Int!
        if(UIDevice.current.userInterfaceIdiom == .pad){
            index = (indexPath as NSIndexPath).row * 4
        }else{
            index = (indexPath as NSIndexPath).row * 2
        }
        
        if allPhotos.count > index {
            cell.image1.isHidden = false
            cell.image1.setImage((allPhotos[index]), for: UIControl.State())
        }
        dynamicHeight = cell.image1.bounds.width
        
        if allPhotos.count > index + 1{
            cell.image2.isHidden = false
            cell.image2.setImage((allPhotos[index+1]), for: UIControl.State())
        }
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            
            if allPhotos.count > index + 2{
                cell.image3.isHidden = false
                cell.image3.setImage((allPhotos[index+2]), for: UIControl.State())
            }
            
            if allPhotos.count > index + 3{
                cell.image4.isHidden = false
                cell.image4.setImage((allPhotos[index+3]), for: UIControl.State())
            }
            
        }
        
        return cell
    }
    
    @objc func goBack()
    {
        _ = self.navigationController?.popViewController(animated: false)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if profileOrCoverChange != nil && profileOrCoverChange == true{
            self.title = NSLocalizedString("Make Profile Photo", comment: "")
        }else{
            self.title = NSLocalizedString("Make Cover Photo", comment: "")
        }
        
        
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
