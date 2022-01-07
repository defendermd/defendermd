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
//  UploadPhotosViewController.swift
//  seiosnativeapp
//
//

import UIKit
import MobileCoreServices
import Photos

class UploadPhotosViewController: UIViewController, ELCImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate  {
    
    //var groupID:Int!
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
    var leftBarButtonItem : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = bgColor
        popAfterDelay = false
        
        mediaType = "image"
        if directUpload == false{
            albumUpdate = false
            let uploadImg = UIBarButtonItem(title: NSLocalizedString("Upload", comment: ""), style:.plain , target:self , action: #selector(UploadPhotosViewController.uploadImages))
            self.navigationItem.rightBarButtonItem = uploadImg
            uploadImg.tintColor = textColorPrime
            
        }else{
            let uploadImg = UIBarButtonItem(title: NSLocalizedString("Done", comment: ""), style:.plain , target:self , action: #selector(UploadPhotosViewController.selectedImages))
            self.navigationItem.rightBarButtonItem = uploadImg
            uploadImg.tintColor = textColorPrime
        }
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(UploadPhotosViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        self.edgesForExtendedLayout = UIRectEdge.all;
        self.automaticallyAdjustsScrollViewInsets = false;
        
        
        
        selectedPhotostableView = UITableView(frame: CGRect(x: 0,y: TOPPADING , width: view.bounds.width, height: view.bounds.height-TOPPADING - tabBarHeight), style: UITableView.Style.grouped)
        selectedPhotostableView.register(PhotosTableViewCell.self, forCellReuseIdentifier: "Cell")
        selectedPhotostableView.rowHeight = 120.0
        selectedPhotostableView.dataSource = self
        selectedPhotostableView.delegate = self
        selectedPhotostableView.backgroundColor = tableViewBgColor
        selectedPhotostableView.separatorColor = TVSeparatorColor
        // For ios 11 spacing issue below the navigation controller
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
    
    override func viewDidAppear(_ animated: Bool) {
        if showGallery{
            showGallery = false
            openGallery()
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
        if popAfterDelay == true{
            _ = self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @objc func selectedImages(){
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
            
            var isSinglePhoto = false
         //   if dic.index(forKey: "listingtype_id") != nil {
                if allPhotos.count > 1{
                isSinglePhoto = false
                }
                else{
                    isSinglePhoto = true
                }
          //  }
            
            postForm(dic, url: url, filePath: filePathArray, filePathKey: "photo", SinglePhoto: isSinglePhoto ) { (succeeded, msg) -> () in
                
                //  post(parameter,path , "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    photoUpload = true
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
                        if succeeded["message"] != nil{
                            if self.allPhotos.count == 1{
                                showToast(message: NSLocalizedString("Photo uploaded successfully", comment: ""), controller: self)
                            }else{
                                showToast(message: NSLocalizedString("Photos uploaded successfully", comment: ""), controller: self)
                            }
                            self.popAfterDelay = true
                           self.createTimer(self)
                            listingDetailUpdate = true
                            pageDetailUpdate = true
                            contentFeedUpdate = true
                            refreshPhotos = true
                            update = true
                            updateFromAlbum = true
                        }
                        else{
                            if self.allPhotos.count == 1{
                                showToast(message: NSLocalizedString("Photo uploaded successfully", comment: ""), controller: self)
                            }else{
                                showToast(message: NSLocalizedString("Photos uploaded successfully", comment: ""), controller: self)
                            }
                            self.popAfterDelay = true
                            self.createTimer(self)
                            
                            //  groupView_Update = true
                            contentFeedUpdate = true
                            
                            listingDetailUpdate = true
                            pageDetailUpdate = true
                            //  eventView_Update = true
                            refreshPhotos = true
                            update = true
                            updateFromAlbum = true
                            
                        }
                        
                        
                    }else{
                        // Handle server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
            }
        }
        else
        {
            //print("Internet problem")
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    
    func openGallery() {
        
        let imagePicker = ELCImagePickerController(imagePicker: ())
        if self.contentType == "sitereview_photo"{
            
            imagePicker?.maximumImagesCount = 10
        }
        else
        {
            imagePicker?.maximumImagesCount = 10
            
        }
        imagePicker?.returnsOriginalImage = true
        imagePicker?.returnsImage = true
        imagePicker?.onOrder = true
        imagePicker?.mediaTypes = [kUTTypeImage]
        imagePicker?.imagePickerDelegate = self
        imagePicker?.modalPresentationStyle = .fullScreen
        let photoAuthorization = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorization
        {
        case .authorized:
            present(imagePicker!, animated: false, completion: nil)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if newStatus == PHAuthorizationStatus.authorized
                {
                    self.present(imagePicker!, animated: false, completion: nil)
                }
            })
            print("It is not determined until now")
        case .denied, .restricted:
            photoPermission(controller: self)
            print("User has denied the permission.")
        }
        
        //present(imagePicker!, animated: false, completion: nil)
        
    }
    
    // MARK: ELCImagePickerControllerDelegate Methods
    
    func elcImagePickerControllerDidCancel(_ picker: ELCImagePickerController!) {
        dismiss(animated: true, completion: nil)
        
        if allPhotos.count == 0{
            _ = self.navigationController?.popViewController(animated: false)
            
            allPhotos.removeAll(keepingCapacity: false)
        }
    }
    
    public func elcImagePickerController(_ picker: ELCImagePickerController!, didFinishPickingMediaWithInfo info: [Any]!) {
        
        
        dismiss(animated: true, completion: nil)
        
        allPhotos.removeAll(keepingCapacity: false)
        
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = PHImageRequestOptionsResizeMode.exact
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        requestOptions.isSynchronous = true
        for dic in info
        {
            if let photoDic = dic as? PHAsset
            {
                if photoDic.mediaType == PHAssetMediaType.image
                {
                    manager.requestImage(for: photoDic , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: requestOptions, resultHandler: { (pickedImage, info) in
                        
                        self.allPhotos.append(pickedImage!) // you can get image like this way
                        
                    })
                }
            }
        }
        
        for dic in info{
            if let photoDic = dic as? NSDictionary{
                
                if photoDic.object(forKey: UIImagePickerController.InfoKey.mediaType) as! String == ALAssetTypePhoto {
                    
                    if (photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) != nil){
                        let image = photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) as! UIImage
                        allPhotos.append(image)
                    }
                }
            }
            
        }
        if allPhotos.count == 0{
            
            _ = self.navigationController?.popViewController(animated: true)
            
            self.allPhotos.removeAll(keepingCapacity: false)
        }
        selectedPhotostableView.reloadData()
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    //set Height for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        /* if (limit*pageNumber < totalItems){
         return 80
         }else{*/
        return 0.001
        // }
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
        //2
        if allPhotos.count > index + 1{
            cell.image2.isHidden = false
            cell.image2.setImage((allPhotos[index+1]), for: UIControl.State())
        }
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            
            //3
            if allPhotos.count > index + 2{
                
                cell.image3.isHidden = false
                cell.image3.setImage((allPhotos[index+2]), for: UIControl.State())
                
            }
            
            
            //4
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
        self.title = NSLocalizedString("Upload Photo", comment: "")
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
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
