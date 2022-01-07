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

//  MessageCreateController.swift

import UIKit
import Photos
var addfrndTags = false
class MessageCreateController: UIViewController, UITableViewDataSource,UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate,ELCImagePickerControllerDelegate{
    var suggestedFrnd = [AnyObject]()
    var searchResultTableView : UITableView!
    var dynamicHeight:CGFloat = 50              // Dynamic Height fort for Cell
    var subjectLabelText : UITextField!
    var contentLabelText : UITextView!
    var submitButton : UIButton!
    var toLabelText : UITextField!
    var sendMsg : UIButton!
    var friendListView : UIScrollView!
    var border = CALayer()
    var userID : String!
    var fromProfile = false
    var profileName: String!
    var iscoming:String = ""
    var displayNameLabel = ""
    var url : String = ""
    var leftBarButtonItem : UIBarButtonItem!
    // message related work
    var optionButton : UIButton!
    var rightNavView : UIView!
    var countLabel: UILabel!
    let attachmentCount = 1
    var attachmentCreateMessageFlag = false   // Check image,video,link attached with Message or not
    var transparentView :UIView!              // View to show Attached Image
    var transparentView1 :UIView!             // View to Show Attached Link or Attach Video
    var subView : UIView!
    var subView1 : UIView!
    var titleofLink : String = ""
    var descriptionofLink : String = ""
    var imageofLink: String = ""
    var transparentViewVideo :UIView!
    var subViewVideo : UIView!
    var linkField: UITextField!
    var linkTextField : UITextField!
    var attachFile : UIButton!
    var attachMessageLink : Bool = false
    var videoAttachmentKey = ""
    var cancelAttachFile : UIButton!
    var attachImage = [UIImage]()
    var attachmentsLink : Bool = false
    var linkUrl1 : String! = ""
    var videoUrl1 : String!
    var videoId1 : String!
    var placeHolderText = ""
    var param = NSDictionary()
    var checkfrom = ""
    override func viewDidLoad()
    {
        super.viewDidLoad()
        addfrndTags = false
        conversationVar = false
         frndTag.removeAll(keepingCapacity: true)
        // Do any additional setup after loading the view.
        view.backgroundColor = bgColor
       
//        if checkfrom != "" {
//            greetingsCheck = true
//        }
//        else{
//            greetingsCheck = false
//        }
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barTintColor = textColorPrime
        if iscoming == "sitegroup"{
            self.title = NSLocalizedString("Add People",  comment: "")
        }
        else if iscoming == "sitevideo" || iscoming == "sitevideoAvoid"{
            self.title = NSLocalizedString("Suggest to friends",  comment: "")
        }
        else {
            self.title = NSLocalizedString("New Message",  comment: "")
        }
        
        if iscoming == "sitegroup" || iscoming == "sitevideoAvoid" {
        toLabelText = createTextField(CGRect(x: PADING, y: TOPPADING, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: NSLocalizedString("Start typing the name of the member",  comment: ""), corner: true)
        toLabelText.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Start typing the name of the member",  comment: ""), attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        }
        else{
            toLabelText = createTextField(CGRect(x: PADING, y: TOPPADING, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText: NSLocalizedString("Send To",  comment: ""), corner: true)
            toLabelText.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Send To ",  comment: ""), attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        }
        toLabelText.becomeFirstResponder()
        // Event For Auto Suggest
        if fromProfile == false
        {
            
            toLabelText.addTarget(self, action: #selector(MessageCreateController.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)

        }
        else
        {
            let key = Int(userID)
            frndTag[key ?? 0] = profileName
            toLabelText.isUserInteractionEnabled = false
            
        }
        toLabelText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        toLabelText.backgroundColor = bgColor
        toLabelText.delegate = self
        toLabelText.layer.masksToBounds = true
        view.addSubview(toLabelText)
        

        
        searchResultTableView = UITableView(frame: CGRect(x: PADING, y: TOPPADING + 40, width: view.bounds.width - PADING, height: view.bounds.height-120), style: UITableView.Style.grouped)
        searchResultTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "Cell")
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        searchResultTableView.rowHeight = 50
        searchResultTableView.backgroundColor = tableViewBgColor
        view.addSubview(searchResultTableView)
        
        self.edgesForExtendedLayout = UIRectEdge.all;
        self.automaticallyAdjustsScrollViewInsets = false;
        
        subjectLabelText = createTextField(CGRect(x: PADING, y: TOPPADING+40, width: view.bounds.width - (2 * PADING ), height: 40), borderColor: borderColorClear , placeHolderText:  NSLocalizedString("Subject",  comment: ""), corner: true)
        subjectLabelText.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Subject",  comment: ""), attributes: [NSAttributedString.Key.foregroundColor: placeholderColor])
        subjectLabelText.font =  UIFont(name: fontName, size: FONTSIZELarge)
        subjectLabelText.delegate = self
        subjectLabelText.backgroundColor = bgColor
        
        
        let border1 = CALayer()
        let width1 = CGFloat(1.0)
        border1.borderColor = borderColorMedium.cgColor
        border1.frame = CGRect(x: 0, y: width1 + 2, width:  subjectLabelText.frame.size.width, height: 1.0)
        
        border1.borderWidth = width1
        subjectLabelText.layer.addSublayer(border1)
        subjectLabelText.layer.masksToBounds = true
        view.addSubview(subjectLabelText)
        placeHolderText = NSLocalizedString("Compose Message",  comment: "")

        contentLabelText = createTextView(CGRect(x: PADING, y: subjectLabelText.bounds.height + subjectLabelText.frame.origin.y + 5, width: view.bounds.width - (2*PADING) , height: 100), borderColor: borderColorClear, corner: false )
        contentLabelText.delegate = self
        contentLabelText.isHidden = false
        contentLabelText.text = NSLocalizedString("Compose Message",  comment: "")
        contentLabelText.font = UIFont(name: fontName, size: FONTSIZELarge)
        contentLabelText.textColor = placeholderColor
        contentLabelText.backgroundColor = bgColor
        
        contentLabelText.autocorrectionType = UITextAutocorrectionType.yes
        
        if iscoming == "sitegroup" || iscoming == "sitevideo" || iscoming == "sitevideoAvoid" {
            subjectLabelText.isHidden = true
            contentLabelText.isHidden = true
        }
        else {
            subjectLabelText.isHidden = false
            contentLabelText.isHidden = false
        }
        
        
        let border4 = CALayer()
        border4.borderColor = borderColorMedium.cgColor
        border4.frame = CGRect(x: 0, y: width1 + 2, width:  contentLabelText.frame.size.width, height: 1.0)
        border4.borderWidth = width1
        contentLabelText.layer.addSublayer(border4)
        view.addSubview(contentLabelText)
        
        rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 88, height: 44))
        rightNavView.backgroundColor = UIColor.clear
        
        if iscoming == "sitegroup" || iscoming == "sitevideo" || iscoming == "sitevideoAvoid" {
            
            sendMsg = createButton(CGRect(x: 44,y: 0,width: 44,height: 44), title: "\u{f1d8}", border: false, bgColor: false, textColor: textColorPrime)
            sendMsg.titleLabel!.font = UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
            sendMsg.addTarget(self, action: #selector(MessageCreateController.send), for: .touchUpInside)
            rightNavView.addSubview(sendMsg)
        }
        else{
        
        sendMsg = createButton(CGRect(x: 44,y: 0,width: 44,height: 44), title: "\u{f1d8}", border: false, bgColor: false, textColor: textColorPrime)
        sendMsg.titleLabel!.font = UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        sendMsg.addTarget(self, action: #selector(MessageCreateController.send), for: .touchUpInside)
        rightNavView.addSubview(sendMsg)
        
        optionButton = createButton(CGRect(x: 0,y: 0,width: 44,height: 44), title: "\u{f0c6}", border: false, bgColor: false, textColor: textColorPrime)
        optionButton.titleLabel!.font = UIFont(name: "FontAwesome", size:FONTSIZEExtraLarge)
        optionButton.addTarget(self, action: #selector(MessageCreateController.showOptions(_:)), for: .touchUpInside)
        optionButton.tag = 11
        rightNavView.addSubview(optionButton)
        }
       
        countLabel = createLabel(CGRect(x: 0,y: 0,width: 14,height: 14), text: "\(attachmentCount)", alignment: .center, textColor: textColorLight)
        countLabel.backgroundColor = UIColor.red
        countLabel.layer.cornerRadius = countLabel.frame.size.width / 2;
        countLabel.layer.masksToBounds = true
        
        countLabel.font = UIFont(name: "fontAwesome", size: FONTSIZENormal)
        countLabel.isHidden = true
        rightNavView.addSubview(countLabel)
        
        let barButtonItem = UIBarButtonItem(customView: rightNavView)
        self.navigationItem.rightBarButtonItem = barButtonItem
        
        let leftNavView = UIView(frame: CGRect(x:0,y:0,width:44,height:44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(MessageCreateController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let leftbarButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = leftbarButtonItem

        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MessageCreateController.resignKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false;
        view.addGestureRecognizer(tap)
        if #available(iOS 11.0, *) {
            self.searchResultTableView.estimatedSectionHeaderHeight = 0
        }
     
        
    }
    
    // MARK: Start Message Attachment Related work
    
    // Call when click on message attachment
    @objc func showOptions(_ sender:UIButton)
    {
        self.view.endEditing(true)
        if attachmentCreateMessageFlag == false
        {
            // Show Attachments Option like Link,Video,Image
            attachment()
        }
        else
        {
            let tagType = sender.tag
            switch(tagType){
            case 11:
                // Show Attachments Option like Link,Video,Image
                attachment()
            case 22:
                // Show the attachedImage
                showAttachedImage()
            case 33:
                // Show attached link
                showAttachedLink()
            default:
                print("Type Not Match")
            }
        }
    }
    
    //MARK: Start  Show Attachments Option like Link,Video,Image
    func attachment()
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Attach Image",comment: ""), style: .default, handler:{ (UIAlertAction) -> Void in
            // In case of Image Attachment
            let imagePicker = ELCImagePickerController(imagePicker: ())
            imagePicker?.maximumImagesCount = 1
            imagePicker?.returnsOriginalImage = true
            imagePicker?.returnsImage = true
            imagePicker?.onOrder = true
            imagePicker?.imagePickerDelegate = self
            
            let photoAuthorization = PHPhotoLibrary.authorizationStatus()
            switch photoAuthorization
            {
            case .authorized:
                self.present(imagePicker!, animated: false, completion: nil)
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
            
            //self.present(imagePicker!, animated: false, completion: nil)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Attach Link",comment: ""), style: .default, handler:{ (UIAlertAction) -> Void in
            // In Case of AttachLink
            self.attachmentLink()
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Attach Video",comment: ""), style: .default, handler:{ (UIAlertAction) -> Void in
            // In Case of AttachVideo
            self.attachmentVideo()
        }))
        if  (!isIpad()){
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
    //MARK: Finish  Show Attachments Option like Link,Video,Image
    
    // MARK: Start Work for Image Attachment
    func showAttachedImage(){
        if transparentView == nil
        {
            transparentView = UIView(frame: view.frame)
            transparentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            view.addSubview(transparentView)
        }
        for ob in transparentView.subviews{
            ob.removeFromSuperview()
        }
        subView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width * 0.8, height: view.bounds.height * 0.6))
        subView.backgroundColor = UIColor.white
        subView.center = transparentView.center
        subView.layer.borderWidth = 1;
        subView.layer.cornerRadius = 10.0
        transparentView.addSubview(subView)
        let imageAttach = createImageView(CGRect(x: 2 * contentPADING,y: 2 * contentPADING, width: subView.bounds.width -  (4*contentPADING) , height: subView.bounds.height  - (ButtonHeight + 4 * contentPADING)), border: true)
        if attachImage.count > 0{
            imageAttach.image = attachImage[0]
        }
        subView.addSubview(imageAttach)
        let originY:CGFloat = imageAttach.bounds.height
        let done = createButton(CGRect(x: 2 * contentPADING , y: originY + 3 * contentPADING, width: 110, height: ButtonHeight - 5), title: NSLocalizedString("Remove Attach", comment: ""), border: true,bgColor: true , textColor: textColorLight)
        done.addTarget(self , action:#selector(MessageCreateController.removeAttachedImage) , for: .touchUpInside)
        done.layer.cornerRadius = 5.0
        done.backgroundColor =  navColor
        done.layer.borderColor = navColor.cgColor
        done.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        done.setTitleColor(textColorLight, for: UIControl.State())
        subView.addSubview(done)
        let cancel = createButton(CGRect(x: (4 * contentPADING) + 110 , y: originY + 3 * contentPADING, width: 110, height: ButtonHeight - 5),  title: NSLocalizedString("Cancel",comment: ""), border: true,bgColor: false , textColor: navColor)
        cancel.addTarget(self , action:#selector(MessageCreateController.hideImageAttachedView) , for: .touchUpInside)
        cancel.layer.cornerRadius = 5.0
        cancel.layer.borderColor = navColor.cgColor
        cancel.backgroundColor = textColorLight
        cancel.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        subView.addSubview(cancel)
        subView.frame.size.height = originY + (4 * contentPADING) + ButtonHeight - 5
    }
    
  
    func elcImagePickerControllerDidCancel(_ picker: ELCImagePickerController!) {
        dismiss(animated: true, completion: nil)
    }
    
    func elcImagePickerController(_ picker: ELCImagePickerController!, didFinishPickingMediaWithInfo info: [Any]!) {
        dismiss(animated: true, completion: nil)
        attachImage.removeAll(keepingCapacity: false)
        linkUrl1 = ""
        
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
                        
                        self.attachImage.append(pickedImage!) // you can get image like this way
                        
                    })
                }
            }
        }
        
        for dic in info{
            if let photoDic = dic as? NSDictionary{
                if photoDic.object(forKey: UIImagePickerController.InfoKey.mediaType) as? String == ALAssetTypePhoto {
                    if (photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) != nil){
                        let image = photoDic.object(forKey: UIImagePickerController.InfoKey.originalImage) as! UIImage
                        attachImage.append(image)
                    }
                }
            }
        }
        
        if attachImage.count > 0 {
            attachmentCreateMessageFlag = true
            optionButton.tag = 22
            countLabel.isHidden = false
            attachmentsLink = true
        }
    }
    
    // Hide Attached Image View
    @objc func hideImageAttachedView(){
        for ob in transparentView.subviews{
            ob.removeFromSuperview()
        }
        transparentView.removeFromSuperview()
        transparentView = nil
    }
    
    // Remove Attached Image
    @objc func removeAttachedImage(){
        attachImage.removeAll(keepingCapacity: false)
        countLabel.isHidden = true
        attachMessageLink = false
        for ob in transparentView.subviews{
            ob.removeFromSuperview()
        }
        transparentView.removeFromSuperview()
        transparentView = nil
        attachmentCreateMessageFlag = false
        optionButton.tag = 11
    }
    //MARK:  Finish Work for image attachment
    
    
    //MARK: Start Work for link attachment
    func attachmentLink(){
        let alert = UIAlertController(title: NSLocalizedString("Attach Link",comment: ""), message: NSLocalizedString("Enter url:",comment: ""), preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Done",comment: ""), style: UIAlertAction.Style.default, handler: showAlertToAddLink))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.default, handler: nil))
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.placeholder = NSLocalizedString("Enter Url",comment: "")
            textField.isSecureTextEntry = false
            self.linkField = textField
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    // When Press Done for Attach Link
    func showAlertToAddLink(_ alertView: UIAlertAction!){
        var error = ""
        if linkField.text!.range(of: "http://") != nil || linkField.text!.range(of: "https://") != nil{
            linkUrl1 = "\(self.linkField.text!)"
        }else{
            let tempUrl = "http://\(self.linkField.text!)"
            linkUrl1 = tempUrl
        }
        if self.linkField.text!  == "" {
            error = NSLocalizedString("Please enter url.",comment: "")
        }
        if error != ""{
            let alertController = UIAlertController(title: "Error", message:
                error, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            if Reachabable.isConnectedToNetwork() {
                var path = ""
                var parameters = [String:String]()
                path = "advancedactivity/feeds/attach-link"
                parameters = ["uri": linkUrl1]
                self.view.addSubview(activityIndicatorView)
                activityIndicatorView.center = self.view.center
                self.view.alpha = 1.0

                activityIndicatorView.startAnimating()
                view.isUserInteractionEnabled = false
                activityPost(parameters as Dictionary<String, AnyObject>, url: path, method: "POST") { (succeeded, msg) -> () in
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if(msg){
                            if let response = succeeded["body"] as? NSDictionary{
                                var title = ""
                                var description = ""
                                var imageString = ""
                                if let temp_title = response["title"] as? String{
                                    title = temp_title
                                }
                                if let temp_description = response["description"] as? String{
                                    description = temp_description
                                }
                                if let tempImageString = response["thumb"] as? String{
                                    imageString = tempImageString
                                }
                                if ((title != "" || description != "") && (imageString != "")){
                                    self.view.alpha = 1
                                    self.view.isUserInteractionEnabled = true
                                    self.titleofLink = title
                                    self.descriptionofLink = description
                                    self.imageofLink = imageString
                                    // If Link Correct then Show View to Attach Link
                                    self.showAttachedLink()
                                }else{
                                    self.view.alpha = 1
                                    self.linkUrl1 = ""
                                    self.view.isUserInteractionEnabled = true
                                    showToast(message: "Webpage not available.", controller: self)
                                }
                            }
                        }
                        else{
                            self.view.alpha = 1
                            self.view.isUserInteractionEnabled = true
                            showToast(message: "Webpage not available.", controller: self)
                        }
                    })
                }
            }
        }
        
    }
    
    // Show View so that we can Attach Link
    func showAttachedLink(){
        if transparentView1 == nil
        {
            transparentView1 = UIView(frame: view.frame)
            transparentView1.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            view.addSubview(transparentView1)
        }
        for ob in transparentView1.subviews{
            ob.removeFromSuperview()
        }
        subView1 = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width * 0.8, height: view.bounds.height * 0.4))
        subView1.backgroundColor = UIColor.white
        subView1.center = transparentView1.center
        subView1.layer.borderWidth = 1;
        subView1.layer.cornerRadius = 10.0
        subView1.tag = 1000
        subView1.isUserInteractionEnabled = true
        transparentView1.addSubview(subView1)
        var imageAttach = createImageView(CGRect(x: 2 * contentPADING,y: 2 * contentPADING, width: 80 , height: 80), border: true)
        let coverImageUrl = URL(string:  self.imageofLink)

        imageAttach.kf.indicatorType = .activity
        (imageAttach.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
        imageAttach.kf.setImage(with: coverImageUrl, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
            
        })

        subView1.addSubview(imageAttach)
        let titleLabel = createLabel(CGRect(x: 3 * contentPADING + 80, y: 2 * contentPADING, width: subView1.bounds.width -  (6*contentPADING + 80), height: 20) , text: "", alignment: .left, textColor: textColorDark)
        titleLabel.text = "\(self.titleofLink)"
        titleLabel.font = UIFont(name: fontBold, size: FONTSIZESmall)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        subView1.addSubview(titleLabel)
        let descriptionLabel = createLabel(CGRect(x: 3 * contentPADING + 80,y: 2 * contentPADING + 20 , width: subView1.bounds.width -  (6*contentPADING + 80), height: 50), text: "\(self.descriptionofLink)", alignment: .left, textColor: textColorDark)
        descriptionLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        descriptionLabel.numberOfLines = 0
        subView1.addSubview(descriptionLabel)
        let originY:CGFloat = imageAttach.bounds.height
        let done = createButton(CGRect(x: 2 * contentPADING , y: originY + 3 * contentPADING, width: 110, height: ButtonHeight - 5), title: NSLocalizedString("Attach Link", comment: ""), border: true,bgColor: true , textColor: textColorLight)
        done.layer.cornerRadius = 5.0
        done.addTarget(self , action:#selector(MessageCreateController.attachLinkUrl) , for: .touchUpInside)
        done.isUserInteractionEnabled = true
        done.backgroundColor =  navColor
        done.layer.borderColor = navColor.cgColor
        done.setTitleColor(textColorLight, for: UIControl.State())
        subView1.addSubview(done)
        let cancel = createButton(CGRect(x: (4 * contentPADING) + 110 , y: originY + 3 * contentPADING, width: 110, height: ButtonHeight - 5),  title: NSLocalizedString("Cancel",comment: ""), border: true,bgColor: false , textColor: navColor)
        cancel.addTarget(self , action:#selector(MessageCreateController.hideViewForAttachLink) , for: .touchUpInside)
        cancel.layer.cornerRadius = 5.0
        cancel.layer.borderColor = navColor.cgColor
        cancel.backgroundColor = textColorLight
        subView1.addSubview(cancel)
        subView1.frame.size.height = originY + (4 * contentPADING) + ButtonHeight - 5
    }
    
    // Attach Link After Click on Attach Link
    @objc func attachLinkUrl(){
        countLabel.isHidden = false
        optionButton.tag = 33
        attachmentsLink = true
        attachmentCreateMessageFlag = true
        attachImage.removeAll(keepingCapacity: false)
        hideViewForAttachLink()
    }
    
    @objc func hideViewForAttachLink(){
        for ob in transparentView1.subviews{
            ob.removeFromSuperview()
        }
        attachmentCreateMessageFlag = true
        transparentView1.removeFromSuperview()
        transparentView1 = nil
    }
    //MARK:  Finish Work for link attachment
    
    
    //MARK: Start Work for video attachment
    
    // After Click On Attach Video
    func attachmentVideo(){
        if transparentViewVideo == nil
        {
            transparentViewVideo = UIView(frame: view.frame)
            transparentViewVideo.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            view.addSubview(transparentViewVideo)
        }
        for ob in transparentViewVideo.subviews{
            ob.removeFromSuperview()
        }
        subViewVideo = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 110))
        subViewVideo.backgroundColor = UIColor.white
        subViewVideo.center = transparentViewVideo.center
        subViewVideo.layer.borderWidth = 1;
        subViewVideo.layer.cornerRadius = 10.0
        transparentViewVideo.addSubview(subViewVideo)
        let cancel = createButton(CGRect(x: subViewVideo.bounds.width-20, y: 2,width: 20, height: 30), title: "\(cancelFriendIcon)", border: false,bgColor: false, textColor: textColorDark)
        cancel.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
        cancel.addTarget(self, action: #selector(MessageCreateController.hideViewOfVideoOrLink(_:)), for: .touchUpInside)
        subViewVideo.addSubview(cancel)
        let videoOption = createButton(CGRect(x: 5, y: 35, width: subViewVideo.bounds.width - 10, height: 40),title: NSLocalizedString("Choose Source",  comment: "") , border: true,bgColor: false, textColor: textColorDark)
        videoOption.titleLabel?.font = UIFont(name: fontName , size: FONTSIZESmall)
        videoOption.contentHorizontalAlignment = .left
        videoOption.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        videoOption.addTarget(self, action: #selector(MessageCreateController.videoOptionList(_:)), for: .touchUpInside)
        subViewVideo.addSubview(videoOption)
        self.linkTextField =  createTextField(CGRect(x: 5, y: 80, width: subViewVideo.bounds.width - 10, height: 40), borderColor: borderColorDark, placeHolderText: NSLocalizedString("Link",  comment: "" ),corner: false )
        self.linkTextField.isHidden = true
        self.linkTextField.delegate = self
        subViewVideo.addSubview(linkTextField)
        self.linkTextField.returnKeyType = UIReturnKeyType.done
        self.linkTextField.autocorrectionType = UITextAutocorrectionType.no
        self.linkTextField.autocapitalizationType = .none
        self.linkTextField.keyboardType = UIKeyboardType.URL
        self.view.isUserInteractionEnabled = true
        self.attachFile = createButton(CGRect(x: 2 * contentPADING, y: 125, width: 110, height: ButtonHeight - 5),  title: NSLocalizedString("Attach",  comment: ""), border: true,bgColor: false, textColor: textColorLight)
        self.attachFile.isHidden = true
        self.attachFile.layer.cornerRadius = 5.0
        self.attachFile.tag = 5
        self.attachFile.backgroundColor = navColor
        self.attachFile.layer.borderColor = navColor.cgColor
        self.attachFile.addTarget(self, action: #selector(MessageCreateController.attachVideoAction(_:)), for: .touchUpInside)
        subViewVideo.addSubview(self.attachFile)
        cancelAttachFile = createButton(CGRect(x: (4 * contentPADING) + 110, y: 125, width: 110, height: ButtonHeight - 5),  title: NSLocalizedString("Cancel",  comment: ""), border: true,bgColor: false, textColor: navColor)
        cancelAttachFile.isHidden = true
        cancelAttachFile.layer.cornerRadius = 5.0
        cancelAttachFile.tag = 5
        cancelAttachFile.layer.borderColor = navColor.cgColor
        cancelAttachFile.backgroundColor = textColorLight
        cancelAttachFile.addTarget(self, action: #selector(MessageCreateController.hideViewOfVideoOrLink(_:)), for: .touchUpInside)
        subViewVideo.addSubview(cancelAttachFile)
    }
    
    // To Show Video Options
    @objc func videoOptionList(_ sender:UIButton){
        var videoDictionary = Dictionary<String, String>()
        videoDictionary["0"] = "Choose Source"
        videoDictionary["1"] = "YouTube"
        videoDictionary["2"] = "Vimeo"
        if videoDictionary.count > 0 {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for (key,value) in videoDictionary {
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("\(value)",comment: ""), style: .default) { action -> Void in
                    sender.setTitle(videoDictionary["\(key)"], for: UIControl.State())
                    if key != "0"{
                        self.subViewVideo.frame.size.height = self.cancelAttachFile.frame.origin.y + self.cancelAttachFile.frame.size.height + 10
                        self.subViewVideo.center = self.transparentViewVideo.center
                        self.videoAttachmentKey = key
                        self.attachFile.isHidden = false
                        self.linkTextField.isHidden = false
                        self.cancelAttachFile.isHidden = false
                    }
                })
            }
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
            }else{
                // Present Alert as! Popover for iPad
                alertController.modalPresentationStyle = UIModalPresentationStyle.popover
                let popover = alertController.popoverPresentationController
                popover?.sourceView = UIButton()
                popover?.sourceRect = CGRect(x: view.bounds.height/2, y: view.bounds.width/2, width: 0, height: 0)
                popover?.permittedArrowDirections = UIPopoverArrowDirection()
            }
            self.present(alertController, animated:true, completion: nil)
        }
    }
    
    // Call To Attach Video
    @objc func attachVideoAction(_ sender:UIButton){
        for ob in transparentViewVideo.subviews{
            ob.removeFromSuperview()
        }
        transparentViewVideo.removeFromSuperview()
        transparentViewVideo = nil
        linkTextField.resignFirstResponder()
        // Call To Attach Video
        attachVideo()
    }
    
    // Check Whether video link is correct or not
    func attachVideo(){
        if linkTextField.text!.range(of: "http://") != nil || linkTextField.text!.range(of: "https://") != nil{
            videoUrl1 = self.linkTextField.text!
        }else{
            let tempUrl = "http://\(self.linkTextField.text!)"
            videoUrl1 = tempUrl
        }
        if Reachabable.isConnectedToNetwork() {
            var path = ""
            var parameters = [String:String]()
            path = "videos/create"
            parameters = ["post_attach":"1","type":"\(videoAttachmentKey)", "url" : videoUrl1]
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            self.view.alpha = 1.0

            activityIndicatorView.startAnimating()
            view.isUserInteractionEnabled = false
            post(parameters, url: path, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if let response = succeeded["body"] as? NSDictionary{
                            if let result = response["response"] as? NSDictionary{
                                var title = ""
                                var video_id = ""
                                var imageString = ""
                                if let temp_title = result["title"] as? String{
                                    title = temp_title
                                }
                                if let temp_description = result["video_id"] as? Int{
                                    video_id = String(temp_description)
                                }
                                if let tempImageString = result["image"] as? String{
                                    imageString = tempImageString
                                }
                                if ((title != "" || video_id != "") && (imageString != "")){
                                    self.videoId1 = video_id
                                    self.view.alpha = 1
                                    self.titleofLink = title
                                    self.descriptionofLink = video_id
                                    self.imageofLink = imageString
                                    self.view.isUserInteractionEnabled = true
                                    // Show Attached Link
                                    self.showAttachedVideoLink()
                                }else{
                                    self.videoId1 = ""
                                    self.view.alpha = 1
                                    self.view.isUserInteractionEnabled = true
                                    showToast(message: "Video Not Available", controller: self)
                                }
                            }
                        }
                    }else{
                        activityIndicatorView.stopAnimating()
                        self.view.alpha = 1
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        self.view.isUserInteractionEnabled = true
                    }
                    
                })
            }
        }
    }
    
    // hide View of Link Or Video
    @objc func hideViewOfVideoOrLink(_ sender:UIButton){
        videoUrl1 = ""
        transparentViewVideo.removeFromSuperview()
        transparentViewVideo = nil
    }
    
    //If Video Link Url is Correct then Show Video View So that We can Attach Link
    func showAttachedVideoLink(){
        if transparentView1 == nil
        {
            transparentView1 = UIView(frame: view.frame)
            transparentView1.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            view.addSubview(transparentView1)
        }
        
        for ob in transparentView1.subviews{
            ob.removeFromSuperview()
        }
        subView1 = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width * 0.8, height: view.bounds.height * 0.4))
        subView1.backgroundColor = UIColor.white
        subView1.center = transparentView1.center
        subView1.layer.borderWidth = 1;
        subView1.layer.cornerRadius = 10.0
        subView1.tag = 1000
        subView1.isUserInteractionEnabled = true
        transparentView1.addSubview(subView1)
        var imageAttach = createImageView(CGRect(x: 2 * contentPADING,y: 2 * contentPADING, width: 80 , height: 80), border: true)
        let coverImageUrl = URL(string:  self.imageofLink)
        imageAttach.kf.indicatorType = .activity
        (imageAttach.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
        imageAttach.kf.setImage(with: coverImageUrl!, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
            
        })
        subView1.addSubview(imageAttach)
        let titleLabel = createLabel(CGRect(x: 3 * contentPADING + 80, y: 2 * contentPADING, width: subView1.bounds.width -  (4*contentPADING + 80), height: 20) , text: "", alignment: .left, textColor: textColorDark)
        titleLabel.text = "\(self.titleofLink)"
        titleLabel.font = UIFont(name: fontBold, size: FONTSIZENormal)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        subView1.addSubview(titleLabel)
        let descriptionLabel = createLabel(CGRect(x: 3 * contentPADING + 80,y: 2 * contentPADING + 20 , width: subView1.bounds.width -  (6*contentPADING + 80), height: 50), text: "\(self.descriptionofLink)", alignment: .left, textColor: textColorDark)
        descriptionLabel.font = UIFont(name: fontName, size: FONTSIZEMedium)
        descriptionLabel.numberOfLines = 2
        subView1.addSubview(descriptionLabel)
        let originY:CGFloat = imageAttach.bounds.height
        let done = createButton(CGRect(x: 2 * contentPADING , y: originY + 3 * contentPADING, width: 110, height: ButtonHeight - 5), title: NSLocalizedString("Attach Link", comment: ""), border: true,bgColor: true , textColor: textColorLight)
        done.addTarget(self , action:#selector(MessageCreateController.attachVideoUrl) , for: .touchUpInside)
        done.layer.cornerRadius = 5.0
        done.isUserInteractionEnabled = true
        done.backgroundColor =  navColor
        done.layer.borderColor = navColor.cgColor
        done.setTitleColor(textColorLight, for: UIControl.State())
        subView1.addSubview(done)
        let cancel = createButton(CGRect(x: (4 * contentPADING) + 110 , y: originY + 3 * contentPADING, width: 110, height: ButtonHeight - 5),  title: NSLocalizedString("Cancel",comment: ""), border: true,bgColor: false , textColor: navColor)
        cancel.layer.cornerRadius = 5.0
        cancel.addTarget(self , action:#selector(MessageCreateController.hideViewForAttachLink) , for: .touchUpInside)
        cancel.layer.borderColor = navColor.cgColor
        cancel.backgroundColor = textColorLight
        subView1.addSubview(cancel)
        subView1.frame.size.height = originY + (4 * contentPADING) + ButtonHeight - 5
    }
    
    // Attached Video Link
    @objc func attachVideoUrl(){
        countLabel.isHidden = false
        optionButton.tag = 33
        attachmentsLink = true
        attachmentCreateMessageFlag = true
        attachImage.removeAll(keepingCapacity: false)
        hideViewForAttachLink()
    }
    //MARK: Finish Work for video attachment
    
    
    //MARK: Finish Message Attachment Related work
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool{
        // test if our control subview is on-screen
        if (touch.view == self.sendMsg) {
            return false
        }
        return true // handle the touch
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        if(conversationVar == true){
            _ = self.navigationController?.popViewController(animated: false)
        }
        else{
            addFriendTag()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            let tableFrame = self.searchResultTableView.frame.origin.y
            let keyboardHeight = keyboardSize.height
            searchResultTableView.frame.size.height = view.bounds.height-(tableFrame+keyboardHeight)
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification)
    {
        UIView.animate(withDuration: 0.5, animations: {
            self.searchResultTableView.frame.size.height = self.view.bounds.height-120
        })
    }

    
    // MARK: Add Tag Of Contacts
    func addFriendTag(){
        if frndTag.count>0{
            for (key, _) in frndTag{
                for ob in view.subviews {
                    if ob.tag == key{
                        ob.removeFromSuperview()
                    }
                }
            }
            var origin_x:CGFloat = PADING
            var origin_y:CGFloat = TOPPADING+35
            searchResultTableView.frame = CGRect(x: 0, y: 170, width: view.bounds.width, height: (view.bounds.height-170))
            for (key, value) in frndTag{
                if origin_x + (findWidthByText(value) + 15)  > view.bounds.width{
                    origin_y += 25
                    origin_x = PADING
                    searchResultTableView.frame.origin.y += 50
                }
                let frndTags = createLabel(CGRect(x: origin_x , y: origin_y, width: (findWidthByText(value) + 5), height: 20), text: " \(value)", alignment: .left, textColor: textColorLight)
                frndTags.backgroundColor = navColor
                frndTags.font = UIFont(name: fontName, size: FONTSIZESmall)
                frndTags.tag = key
                view.addSubview(frndTags)
                origin_x += frndTags.bounds.width
                let cancel = createButton(CGRect( x: origin_x, y: origin_y, width: 20, height: 20), title: "\(cancelFriendIcon)", border: false,bgColor: false, textColor: textColorLight)
                cancel.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZENormal)
                cancel.tag = key
                cancel.addTarget(self, action: #selector(MessageCreateController.removeFriend(_:)), for: .touchUpInside)
                cancel.backgroundColor = buttonBgColor
                view.addSubview(cancel)
                origin_x += (cancel.bounds.width+5)
                self.subjectLabelText.frame = CGRect(x: PADING, y: origin_y + 20 , width: view.bounds.width - (2 * PADING ), height: 40)
                self.contentLabelText.frame = CGRect(x: PADING, y: subjectLabelText.bounds.height + subjectLabelText.frame.origin.y + 5, width: view.bounds.width - (2*PADING) , height: 100)
                if iscoming == "sitegroup" || iscoming == "sitevideo" || iscoming == "sitevideoAvoid" {
                    subjectLabelText.isHidden = true
                    contentLabelText.isHidden = true
                }
                else {
                    subjectLabelText.isHidden = false
                    contentLabelText.isHidden = false
                }
                
            }
        }
    }
    
    // MARK:  Make server Request for searching friends
    
    func friendSearch(_ searchText:String){
        
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            activityIndicatorView.center = CGPoint(x: view.center.x, y: view.center.y/3)
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
           // activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            userInteractionOff = false
            var parameters = [String:String]()
            var urlList = ""
            if iscoming == "Messageview"
            {
                parameters = ["search":"\(searchText)", "limit": "10","message":"1"]
                urlList = "user/suggest"
            }
            else if iscoming == "sitegroup" || iscoming == "sitevideoAvoid"
            {
                parameters = ["search":"\(searchText)", "limit": "5"]
                urlList = "advancedactivity/friends/suggest"
                
            }
            else if iscoming == "sitevideo"
            {
                for (key, value) in param{
                    
                    if let id = value as? NSNumber {
                        parameters["\(key)"] = String(id as! Int)
                    }
                    
                    if let receiver = value as? NSString {
                        parameters["\(key)"] = receiver as String
                    }
                }
                parameters["search"] = "\(searchText)"
                parameters["limit"] =  "5"
                urlList = url
                
            }
            else
            {
                parameters = ["search":"\(searchText)", "limit": "10"]
                urlList = "user/suggest"
            }
            
            
            // Send Server Request to Share Content
            post(parameters, url: urlList, method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = true
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            
                            if let response = succeeded["body"] as? NSArray{
                                self.suggestedFrnd = response as [AnyObject]
                                
                                if ( self.suggestedFrnd.count > 0){
                                    self.contentLabelText.isHidden = true
                                    self.subjectLabelText.isHidden = true
                                    self.searchResultTableView.isHidden = false
                                }
                                else
                                {
                                    if self.iscoming == "sitegroup" || self.iscoming == "sitevideo" || self.iscoming == "sitevideoAvoid" {
                                        self.subjectLabelText.isHidden = true
                                        self.contentLabelText.isHidden = true
                                    }
                                    else {
                                        self.subjectLabelText.isHidden = false
                                        self.contentLabelText.isHidden = false
                                    }
                                    
                                    self.searchResultTableView.isHidden = true
                                }
                            }
                            self.searchResultTableView.reloadData()
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
            showAlertMessage(view.center , msg: network_status_msg, timer:false )
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
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    // Set Message Recipients Tabel Footer Height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    // Set Message Recipients Tabel Header Height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dynamicHeight
    }
    
    // Set Message Recipients Section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Set No. of Rows in Section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return suggestedFrnd.count
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        
        if let response = suggestedFrnd[(indexPath as NSIndexPath).row] as? NSDictionary {
            cell.labTitle.frame.size.width = (UIScreen.main.bounds.width - (cell.imgUser.bounds.width + 15))
            // Set Name People who Likes Content
            cell.labTitle.text = response["label"] as? String
            cell.labTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.labTitle.sizeToFit()
            
            dynamicHeight = cell.labTitle.frame.origin.y + cell.labTitle.bounds.height + 5
            
            if dynamicHeight < (cell.imgUser.bounds.height + 10){
                dynamicHeight = (cell.imgUser.bounds.height + 10)
            }
            
            // Set Frnd Image
            // Set Message Owner Image
            if let imgUrl = response["image_icon"] as? String{
                let url = URL(string:imgUrl)
                if url != nil
                {
                    cell.imgUser.image = nil
                    cell.imgUser.kf.indicatorType = .activity
                    (cell.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.imgUser.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
            }
            
            if let id = response["id"] as? Int{
                if frndTag[id] != nil{
                    cell.accessoryType = UITableViewCell.AccessoryType.checkmark
                }else{
                    cell.accessoryType = UITableViewCell.AccessoryType.none
                }
            }
            
        }
        return cell
    }
    
    
    // Handle Message Recipients Table Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.toLabelText.resignFirstResponder()
        if let response = suggestedFrnd[(indexPath as NSIndexPath).row] as? NSDictionary {
            frndTag[(response["id"] as? Int)!] = response["label"] as? String
            displayNameLabel = (response["label"] as? String)!
        }
        addFriendTag()
        self.toLabelText.text = ""
        self.suggestedFrnd.removeAll(keepingCapacity: false)
        self.searchResultTableView.reloadData()
        
    }
    
    // MARK:  Remove Friends From Tags
    
    @objc func removeFriend(_ sender: UIButton){
        frndTag.removeValue(forKey: sender.tag)
        for ob in view.subviews{
            if ob.tag == sender.tag{
                ob.removeFromSuperview()
            }
        }
        if(frndTag.count == 0){
            subjectLabelText.frame.origin.y = TOPPADING+45
            contentLabelText.frame.origin.y =  subjectLabelText.bounds.height + subjectLabelText.frame.origin.y + 5
        }
    }
    
    
    func addTag(){
        addfrndTags = true
        _ = navigationController?.popViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:  Send Message
    
    @objc func send(){
        view.endEditing(true)
        var errorMsg = ""
        var parameters = [String:String]()
        if(contentLabelText.text == "") || (contentLabelText.text == placeHolderText){
            if iscoming != "sitegroup" && iscoming != "sitevideo" && iscoming != "sitevideoAvoid" {
            errorMsg = NSLocalizedString("Content can't be empty",  comment: "")
            }
        }else if frndTag.count == 0{
            errorMsg = NSLocalizedString("No Recipients",  comment: "")
        }
        
        if(errorMsg == ""){
            activityIndicatorView.center = CGPoint(x: view.center.x, y: view.center.y/3)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            let finalString = "\(loadingIcon)"
            sendMsg.titleLabel?.text = finalString
            var myDynamicArray:[Int] = []
            
            for (key, _) in frndTag{
                myDynamicArray.append(key)
            }
            
            var str : String = ""
            
            
            for i in stride(from: 0, through: (myDynamicArray.count - 1), by: 1){
                
                if i == (myDynamicArray.count - 1){
                    str += "\(myDynamicArray[i])"
                    
                }
                else {
                    str += "\(myDynamicArray[i]),"
                }
                
            }
            var urlPath = ""
            if iscoming == "sitegroup" || iscoming == "sitevideo" || iscoming == "sitevideoAvoid" {
                
                parameters = ["user_ids": "\(str)"]
                urlPath = url
            }
            else
            {
                parameters = ["title":"\(subjectLabelText.text!)","body":"\(contentLabelText.text!)","toValues": "\(str)"]
                urlPath = "messages/compose"
            }
            // In Case of Attachment
            if(attachmentsLink == true){
                mediaType = "image"
                // In case of Image Attachment
                if attachImage.count > 0 {
                    filePathArray.removeAll(keepingCapacity: false)
                    parameters["type"] = "photo"
                    parameters["post_attach"] = "1"
                    filePathArray = saveFileInDocumentDirectory(attachImage)
                    attachmentsLink = false
                    attachImage.removeAll(keepingCapacity: false)
                    postActivityForm(parameters as Dictionary<String, AnyObject>, url: "messages/compose", filePath: filePathArray , filePathKey: "photo", SinglePhoto: true){ (succeeded, msg) -> () in
                        DispatchQueue.main.async(execute: {
                            activityIndicatorView.stopAnimating()
                            if msg{
                                for path in filePathArray{
                                    removeFileFromDocumentDirectoryAtPath(path)
                                }
                                filePathArray.removeAll(keepingCapacity: false)
                                var convId:Int!
                                if let response = succeeded["body"] as? NSDictionary{
                                    if let conversations = response["conversation"] as? NSDictionary{
                                        convId = conversations["conversation_id"] as! Int
                                    }
                                }
                                let presentedVC = ConverstationViewController()
                                presentedVC.subject = self.displayNameLabel//subjectName
                                presentedVC.displaysendername = self.displayNameLabel//subjectName
                                presentedVC.conversation_id = convId
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                DispatchQueue.main.async(execute: {
                                    self.readMessage(convId as Int)
                                })
                            }
                        })
                    }
                }
                // In Case of Link
                else if linkUrl1 != ""{
                    parameters["type"] = "link"
                    parameters["uri"] = linkUrl1
                    parameters["post_attach"] = "1"
                    linkUrl1 = ""
                    attachmentsLink = false
                    activityPost(parameters as Dictionary<String, AnyObject>, url: "messages/compose", method: "POST") { (succeeded, msg) -> () in
                        DispatchQueue.main.async(execute: {
                            activityIndicatorView.stopAnimating()
                            //
                            var convId:Int!
                            if let response = succeeded["body"] as? NSDictionary{
                                if let conversations = response["conversation"] as? NSDictionary{
                                    convId = conversations["conversation_id"] as! Int
                                }
                            }
                            let presentedVC = ConverstationViewController()
                            presentedVC.subject = self.displayNameLabel//subjectName
                            presentedVC.displaysendername = self.displayNameLabel//subjectName
                            presentedVC.conversation_id = convId
                            self.navigationController?.pushViewController(presentedVC, animated: true)
                            DispatchQueue.main.async(execute: {
                                self.readMessage(convId as Int)
                            })
                        })
                    }
                }
                // In Case of Video Link
                else if videoUrl1 != ""{
                    parameters["video_id"] = videoId1
                    parameters["type"] = "video"
                    parameters["post_attach"] = "1"
                    videoUrl1 = ""
                    attachmentsLink = false
                    activityPost(parameters as Dictionary<String, AnyObject>, url: "messages/compose", method: "POST") { (succeeded, msg) -> () in
                        DispatchQueue.main.async(execute: {
                            activityIndicatorView.stopAnimating()
                            var convId:Int!
                            if let response = succeeded["body"] as? NSDictionary{
                                if let conversations = response["conversation"] as? NSDictionary{
                                    convId = conversations["conversation_id"] as! Int
                                }
                            }
                            let presentedVC = ConverstationViewController()
                            presentedVC.subject = self.displayNameLabel//subjectName
                            presentedVC.displaysendername = self.displayNameLabel//subjectName
                            presentedVC.conversation_id = convId
                            self.navigationController?.pushViewController(presentedVC, animated: true)
                            DispatchQueue.main.async(execute: {
                                self.readMessage(convId as Int)
                            })
                        })
                    }
                }
            }
            // In Vase of Without Attachment
            else{
            post(parameters, url: urlPath, method: "POST") {
                (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if self.iscoming == "sitegroup"{
                            showToast(message: "Selected Members have been successfully added.", controller: self)
                            advGroupDetailUpdate = true
                            let triggerTime = (Int64(NSEC_PER_SEC) * 3)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                self.goBack()
                            })
                        }
                        else if self.iscoming == "sitevideoAvoid"{
                            showToast(message: "Your suggestions have been sent.", controller: self)
                            advGroupDetailUpdate = true
                            let triggerTime = (Int64(NSEC_PER_SEC) * 3)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(triggerTime) / Double(NSEC_PER_SEC), execute: { () -> Void in
                                self.goBack()
                            })
                        }

                        var convId:Int!
                        let finalString = "\u{f1d8}"
                        self.sendMsg.titleLabel?.text = finalString
                        if succeeded["body"] != nil{
                            createMessage = true
                            if let message = succeeded["message"] as? String {
                                showToast(message: message, controller: self)
                            }
                            if let response = succeeded["body"] as? NSDictionary{
                                if let conversations = response["conversation"] as? NSDictionary{
                                    convId = conversations["conversation_id"] as! Int
                                }
                            }
                            let presentedVC = ConverstationViewController()
                            presentedVC.subject = self.displayNameLabel//subjectName
                            presentedVC.displaysendername = self.displayNameLabel//subjectName
                            presentedVC.conversation_id = convId
                            self.navigationController?.pushViewController(presentedVC, animated: true)
                            DispatchQueue.main.async(execute: {
                                self.readMessage(convId as Int)
                            })
                        }
                    }else{
                        // Handle Server Side Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                    }
                })
                
            }
            }
        }else{
            let alertController = UIAlertController(title: "Error", message:
                errorMsg, preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func getFriends() {
        if(self.toLabelText.text != ""){
            friendSearch(self.toLabelText.text!)
        }
        else{
            self.searchResultTableView.isHidden = true
            if iscoming != "sitegroup" || iscoming == "sitevideoAvoid"{
                self.contentLabelText.isHidden = false
                self.subjectLabelText.isHidden = false
            }
        }
    }
    
    
    func readMessage(_ msgId: Int){
        var parameters = [String:String]()
        parameters = ["message_id": "\(msgId)", "is_read" : "1"]
        post(parameters, url: "messages/mark-message-read-unread", method: "POST"){(succeeded, msg) -> () in
            DispatchQueue.main.async(execute: {
                activityIndicatorView.stopAnimating()
            })
        }
        
    }
    @objc private func textFieldDidChange(_ textField: UITextField) {
        
        if(self.toLabelText.text != ""){
            friendSearch(self.toLabelText.text!)
        }
        else{
            self.searchResultTableView.isHidden = true
//            self.contentLabelText.isHidden = false
//            self.subjectLabelText.isHidden = false
        }
    }
    @objc func goBack(){
        isPresented = false
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func cancel(){
        isPresented = false
        scrollingToBottom = false
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
        
    }
    
    @objc func resignKeyboard(){
        contentLabelText.resignFirstResponder()
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        if textView.textColor == placeholderColor {
            textView.text = nil
            textView.textColor = textColorDark
        }
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        if textView.text.isEmpty{
            self.contentLabelText.text = NSLocalizedString("Compose Message",  comment: "")
            self.contentLabelText.textColor = placeholderColor
        }
        return true
    }
    
}
