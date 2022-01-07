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
//  EditProfilePhotoController.swift
//  seiosnativeapp

import UIKit

class EditProfilePhotoViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    var chhosePhotoButton:UIButton!
    var cameraButton:UIButton!
    var skipButton:UIButton!
    var base64String: String!
    var imageView : UIImageView!
    var imageurl : URL!
    var currentImageUrl : String!
    var popAfterDelay:Bool!
    var url: String!
    var pageTitle: String!
    var showCameraButton: Bool = true
    var leftBarButtonItem : UIBarButtonItem!
    var contentType = ""
    var contentId  = ""
    var special = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mediaType = "image"
        multiplePhotoSelection = false
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        
        
        popAfterDelay = false
        
        if pageTitle != nil{
            self.title = pageTitle
        }else{
            self.title = NSLocalizedString("Edit My Photo",comment: "")
        }
        
        imageView  = UIImageView(frame:CGRect(x: view.bounds.width/2.0 - 150 , y: TOPPADING + 20, width: 300, height: 300));
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(EditProfilePhotoViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        //        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2;
        //        self.imageView.clipsToBounds = true;
        self.imageView.layer.borderWidth = 3.0;
        self.imageView.layer.borderColor = UIColor.white.cgColor
        
        imageView.image = UIImage(named:"user_profile_image.png")
        view.addSubview(imageView)
        
        if self.currentImageUrl != nil {
            self.imageurl  = URL(string: self.currentImageUrl as NSString as String)
            self.imageView.contentMode = .scaleAspectFill
            self.imageView.layer.masksToBounds = true
            self.imageView.kf.indicatorType = .activity
            (self.imageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            self.imageView.kf.setImage(with: imageurl as URL?, placeholder: UIImage(named:"user_profile_image.png"), options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                
            })
        }
        else
        {
            self.imageView.image =  UIImage(named:"user_profile_image.png")
        }
        
        
        // Initialize Blog Types
        chhosePhotoButton = createButton(CGRect(x: PADING, y: TOPPADING + 350 ,width: view.bounds.width/2 - 2*PADING, height: ButtonHeight) , title: NSLocalizedString("Gallery",  comment: ""), border: true,bgColor: false, textColor: textColorDark)
        chhosePhotoButton.tag = 11
        chhosePhotoButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        chhosePhotoButton.addTarget(self, action: #selector(EditProfilePhotoViewController.choosePhoto(_:)), for: .touchUpInside)
        view.addSubview(chhosePhotoButton)
        
        cameraButton = createButton(CGRect(x: view.bounds.width/2.0, y: TOPPADING + 350 ,width: view.bounds.width/2 - PADING , height: ButtonHeight), title: NSLocalizedString("Camera",  comment: ""), border: true,bgColor: false, textColor: textColorDark)
        cameraButton.tag = 22
        cameraButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        cameraButton.addTarget(self, action: #selector(EditProfilePhotoViewController.chooseCamera(_:)), for: .touchUpInside)
        view.addSubview(cameraButton)
        
        if showCameraButton == false{
            chhosePhotoButton.frame = CGRect(x: PADING, y: TOPPADING + 350, width: view.bounds.width - 2*PADING, height: ButtonHeight)
            cameraButton.isHidden = true
        }
        
        
        // Initialize Blog Types
        skipButton = createButton(CGRect(x: PADING, y: TOPPADING + 360 + ButtonHeight ,width: view.bounds.width - 2*PADING , height: ButtonHeight) , title: NSLocalizedString("Save Photo",  comment: ""), border: true,bgColor: false, textColor: textColorDark)
        skipButton.tag = 11
        skipButton.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        skipButton.addTarget(self, action: #selector(EditProfilePhotoViewController.save(_:)), for: .touchUpInside)
        view.addSubview(skipButton)
  
    }

    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        setNavigationImage(controller: self)
    }

    
    @objc func choosePhoto(_ sender: UIButton){
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.photoLibrary
        if UIDevice.current.userInterfaceIdiom != .pad{
            image.allowsEditing = true
        }
        self.present(image, animated: true, completion: nil)
    }
    
    @objc func chooseCamera(_ sender: UIButton){
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerController.SourceType.camera
        if UIDevice.current.userInterfaceIdiom != .pad{
            image.allowsEditing = true
        }
        self.present(image, animated: true, completion: nil)
    }
    

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        self.dismiss(animated: true, completion: nil)
//        for dic in info{
//            if let photoDic = dic as? NSDictionary{
//                
//                if photoDic.object(forKey: UIImagePickerController.InfoKey.mediaType) as! String == ALAssetTypePhoto {
//                    
//                    if (photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) != nil){
//                        let image = photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) as! UIImage
//                        imageView.image = image
//                        //print(image as UIImage)
//                        let imageArray = [image as UIImage]
//                        filePathArray.removeAll(keepingCapacity: false)
//                        filePathArray = saveFileInDocumentDirectory(imageArray)
//                    }
//                }
//            }
//            
//        }
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        imageView.image = image
        //print(image as UIImage)
        let imageArray = [image as UIImage]
        filePathArray.removeAll(keepingCapacity: false)
        filePathArray = saveFileInDocumentDirectory(imageArray)
    }
    
    @objc func save(_ sender:UIButton) {
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            self.imageView.alpha = 0.4
            
            var dic = Dictionary<String, String>()
            dic["fields_validation"] = "1"
            dic["account_validation"] = "1"
            signupDictionary.update(dic)
            
            
            //Set Parameters (Token & Form Values) & path for Create/Edit Blog Form
            var parameter = [String:String]()
            var path = ""
            parameter = ["":""]
            
            if url != nil{
                path = url
            }else{
                path = "members/edit/photo"
            }
            
            if contentType != ""{
                
                if special != "" {
                    parameter = ["subject_type":"\(contentType)","subject_id": "\(contentId)","special": "profile"]
                }
                else{
                
                parameter = ["subject_type":"\(contentType)","subject_id": "\(contentId)"]
                }
                
            }
            postForm(parameter, url: path, filePath: filePathArray, filePathKey: "photo" , SinglePhoto: true) { (succeeded, msg) -> () in
                // Send Server Request to Create/Edit Blog Entries
                DispatchQueue.main.async(execute: {
                    
                    activityIndicatorView.stopAnimating()
                    self.imageView.alpha = 1.0
                    
                    if msg{
                            if self.contentType == "sitestore_store"
                            {
                                showToast(message: "Image Updated Successfully", controller: self)
                            }
                            else
                            {
                                showToast(message: "Your photo is successfully uploaded", controller: self)
                            }
                        filePathArray.removeAll(keepingCapacity: false)
                        updateUserData()
                        feedUpdate = true
                        contentFeedUpdate = true
                        pageUpdate = true
                        storeUpdate = true
                        storeDetailUpdate = true
                        advgroupUpdate = true
                        pageDetailUpdate = true
                        listingDetailUpdate = true
                        listingUpdate = true
                        advGroupDetailUpdate = true
                        self.popAfterDelay = true
                        self.createTimer(self)
                        
                    }
                        
                    else{
                        if  (UIDevice.current.userInterfaceIdiom == .phone){
                        }else{
                            let a = succeeded["message"] as! NSDictionary
                            signupValidation.removeAll(keepingCapacity: false)
                            for (_,value) in a{
                                signupValidation.append(value as AnyObject)
                            }
                            let secondViewController = SignUpValidationController()
                            
                            secondViewController.validationArray = signupValidation as NSArray?
                            
                            secondViewController.modalPresentationStyle = UIModalPresentationStyle.popover
                            
                            secondViewController.preferredContentSize = CGSize(width: self.view.bounds.width*0.8,height: self.view.bounds.height*0.35)
                            
                            let popoverpresentationviewcontroller = secondViewController.popoverPresentationController
                            
                            popoverpresentationviewcontroller?.delegate = self
                            
                            popoverpresentationviewcontroller?.permittedArrowDirections = UIPopoverArrowDirection()
                            
                            popoverpresentationviewcontroller?.sourceRect = CGRect( x: 0, y: self.view.bounds.height/3 , width: self.view.bounds.width , height: self.view.bounds.height/3)
                            popoverpresentationviewcontroller?.sourceView = self.view
                            
                            self.navigationController?.present(secondViewController, animated: false, completion: nil)
                        }
                    }
                    
                    
                })
            }
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // Stop Timer
    @objc func stopTimer() {
        stop()
        if popAfterDelay == true{
            filePathArray.removeAll(keepingCapacity: false)
            _ = self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    @objc func goBack(){
        filePathArray.removeAll(keepingCapacity: false)
        _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    
}
