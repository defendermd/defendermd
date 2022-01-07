///*
// * Copyright (c) 2016 BigStep Technologies Private Limited.
// *
// * You may not use this file except in compliance with the
// * SocialEngineAddOns License Agreement.
// * You may obtain a copy of the License at:
// * https://www.socialengineaddons.com/ios-app-license
// * The full copyright and license information is also mentioned
// * in the LICENSE file that was distributed with this
// * source code.
// */
//
//  AlbumProfileViewController.swift
import UIKit
import NVActivityIndicatorView
import SquareFlowLayout
var updateFromAlbum = false
var likeCommentFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
class AlbumProfileViewController: UIViewController , TTTAttributedLabelDelegate , UITabBarControllerDelegate, UIScrollViewDelegate{
    enum CellType {
        case normal
        case expanded
    }
    var gutterMenu: NSArray = []                          // Array for Gutter Menu
    var albumId :String!
    var selectedMoreLess:Bool = false
    var headerView : UIView!
    var headerImageView : UIImageView!
    var headerTitle : TTTAttributedLabel!
    var privacyButton : UIButton!
    var albumCreatedOn : UILabel!
    var topView : UIView!
    var profileImageUrlString : String!
    var headerImage1 : UIImageView!
    var albumName:String!
    var ownerTitle:String!
    var popAfterDelay:Bool!
    var mainView : UIScrollView!
    //var allPhotos = [AnyObject]()
    var dynamicHeight:CGFloat = 100
    var photos:[PhotoViewer] = []
    var descriptionResult: String!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var isPageRefresing = false
    var updateScrollFlag = true
    var refresher:UIRefreshControl!
    var showSpinner = true
    var deleteAlbum: Bool!
    var descView : TTTAttributedLabel!
   // var dividerLine : UIView!
    var like_comment : Like_CommentView!
    var height : CGFloat = 0
    //   var imageCache = [String:UIImage]()
    //   var imageCache1 = [String:UIImage]()
    var lastContentOffset: CGFloat = 0
    var showNavColor = false
    var photoId : Int!
    var contentType = ""
    var urlPath = ""
    var pageId : Int!
    let albumHeaderId = "albumHeaderId"
    var marqueeHeader : MarqueeLabel!
    var contentId: Int!
    var leftBarButtonItem : UIBarButtonItem!
    var groupId : Int!
    var contentDescription : String!
    var coverImageUrl : String!
    var rightBarButtonItem : UIBarButtonItem!
    var shareUrl : String!
    var dividerLine = UIView()
    var shareParam : NSDictionary!
    var subjectType : String!
    var plusIconButton = UIButton()
    var albumPhotoCollectionView: UICollectionView!
    var privacyResponse = [AnyObject]()
    private let patternValues: [CellType] = [
        .normal, .expanded, .normal, .normal, .normal, .normal, .normal, .normal, .normal, .expanded, .normal, .normal, .normal, .normal, .normal, .normal, .normal, .normal,
        ]
    var patternArray = [CellType]()
    var flag : Bool = false
    var deeplinkingPhotoId = ""
    var content_url = ""
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchDic.removeAll(keepingCapacity: false)
        view.backgroundColor = bgColor
        popAfterDelay = false
        deleteAlbum = false
        refreshPhotos = true
        albumUpdate = false
        subjectType = "album"
        self.tabBarController?.delegate = self
        mainView = UIScrollView()
        mainView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: view.bounds.height)
        mainView.delegate = self
        mainView.backgroundColor = .white
        view.addSubview(mainView)
        if #available(iOS 11.0, *) {
            mainView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        removeNavigationImage(controller: self)
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(AlbumProfileViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem

        if self.contentType == "sitegroup_photo" || self.contentType == "sitestore_photo" || self.contentType == "sitepage_photo"  {
            headerView = UIView(frame : CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 290))
            dividerLine = UIView(frame : CGRect(x: 0, y: getBottomEdgeY(inputView: headerView) - 2, width: self.view.frame.size.width, height: 1))
            dividerLine.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
            dividerLine.isHidden = true
            mainView.addSubview(headerView)
            headerView.addSubview(dividerLine)
            
        }
        else {
           headerView = UIView(frame : CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 360))
            mainView.addSubview(headerView)
        }
        
        headerView.backgroundColor = .white
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 200)
        headerImageView = CoverImageViewWithGradient(frame: frame)
        headerImageView.backgroundColor = placeholderColor
        headerImageView.isUserInteractionEnabled = true
        headerImageView.layer.masksToBounds = true
        headerImageView.contentMode = UIView.ContentMode.scaleAspectFill
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(AlbumProfileViewController.onImageViewTap))
        headerImageView.addGestureRecognizer(tap1)
        headerView.addSubview(headerImageView)
        headerTitle = TTTAttributedLabel(frame:CGRect(x: 10, y: getBottomEdgeY(inputView: headerImageView)+3, width: view.bounds.width - 20 , height: 40))
        headerTitle.font = UIFont(name: fontName, size: 30.0)
        headerTitle.center.x = self.view.center.x
        headerTitle.longPressLabel()
        headerTitle.textAlignment = .center
        headerTitle.numberOfLines = 2
        headerTitle.delegate = self
        headerView.addSubview(headerTitle)
        albumCreatedOn = createLabel(CGRect(x: 10, y: getBottomEdgeY(inputView: headerTitle), width: view.bounds.width - 20, height: 20), text: "", alignment: .center, textColor: textColorDark)
        albumCreatedOn.font = UIFont(name: fontName, size: FONTSIZESmall)
        //        albumCreatedOn.backgroundColor = UIColor.green
        headerView.addSubview(albumCreatedOn)
        
        privacyButton = createButton(CGRect(x: 0, y: getBottomEdgeY(inputView: albumCreatedOn), width: 200, height: 30), title: "", border: false, bgColor: false, textColor: textColorMedium)
        privacyButton.titleLabel?.font =  UIFont(name: "FontAwesome", size:13)
        privacyButton.contentVerticalAlignment = .fill
        privacyButton.contentMode = .center
        privacyButton.imageView?.contentMode = .scaleAspectFit
        privacyButton.center.x = headerView.center.x
        privacyButton.addTarget(self, action: #selector(AlbumProfileViewController.openPrivacyOptions), for: .touchUpInside)
        headerView.addSubview(privacyButton)
        
        descView = TTTAttributedLabel(frame: CGRect(x: 5,  y: getBottomEdgeY(inputView: privacyButton), width: view.bounds.width - 10, height: 0))
        descView.delegate = self
        descView.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
        //descView.backgroundColor = lightBgColor
        descView.numberOfLines = 0
        descView.longPressLabel()
        self.descView.font = UIFont(name: fontName, size: FONTSIZENormal)
        headerView.addSubview(descView)
        self.descView.textAlignment = .justified
       
        topView = createView(CGRect(x: 0, y: headerImageView.bounds.height, width: view.bounds.width, height: 70), borderColor: UIColor.clear, shadow: false)
        topView.backgroundColor = lightBgColor

        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(AlbumProfileViewController.refresh), for: UIControl.Event.valueChanged)
        mainView.addSubview(refresher)
        mainView.alwaysBounceVertical = true
        likeCommentContent_id = albumId
        if self.contentType == "sitepage_photo"{
            likeCommentContentType = "sitepage_photo"
        }
        else{
            likeCommentContentType = "album"
        }
        like_CommentStyle = 1
        if self.contentType == ""{
            likeCommentFrame = CGRect(x: 0, y: getBottomEdgeY(inputView: descView)+9,width: UIScreen.main.bounds.width,height: 50)
            like_comment = Like_CommentView()
            like_comment.isHidden = true
            headerView.addSubview(like_comment)
        }
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()

        let flowLayout = SquareFlowLayout()
        flowLayout.flowDelegate = self
        flowLayout.headerReferenceSize = CGSize(width: self.headerView.frame.size.width, height: 100)
        flowLayout.sectionHeadersPinToVisibleBounds = true
        self.albumPhotoCollectionView = UICollectionView(frame: CGRect(x: 0, y: Int(getBottomEdgeY(inputView: headerView)), width: Int(UIScreen.main.bounds.width), height: Int(UIScreen.main.bounds.height - tabBarHeight - headerView.frame.size.height)), collectionViewLayout: flowLayout)
        self.albumPhotoCollectionView.dataSource = self
        self.albumPhotoCollectionView.delegate = self
        self.albumPhotoCollectionView.register(UINib(nibName: "PhotoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCollectionViewCell")
        self.albumPhotoCollectionView.register(CollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: albumHeaderId)
        albumPhotoCollectionView.backgroundColor = .white
        albumPhotoCollectionView.isScrollEnabled = false
        mainView.addSubview(albumPhotoCollectionView)
        
        floatingPlusIconView()
        mainView.showsVerticalScrollIndicator = false
        
    }
    
        func floatingPlusIconView() {
            plusIconButton = UIButton()
            let iconHeight :CGFloat =  50
            plusIconButton = createButton(CGRect(x: view.frame.width - iconHeight - 20, y: view.frame.height - tabBarHeight  - 65, width: iconHeight , height: iconHeight), title: "", border: false, bgColor: false, textColor: textColorLight)
            let originalImage = UIImage(named: "plusIcon")
            let tintedImage =  originalImage?.withRenderingMode(.alwaysTemplate)
            plusIconButton.setImage(tintedImage, for: .normal)
            plusIconButton.tintColor = .white
            plusIconButton.isHidden = true
            plusIconButton.imageEdgeInsets = UIEdgeInsets(top: 7.5, left: 7.5, bottom: 7.5, right: 7.5)
            plusIconButton.layer.cornerRadius = iconHeight/2
            plusIconButton.backgroundColor = buttonColor
            plusIconButton.addTarget(self, action: #selector(AlbumProfileViewController.addPhotos), for: .touchUpInside)
            view.addSubview(plusIconButton)
            plusIconButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            plusIconButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            plusIconButton.layer.shadowOpacity = 1.0
            plusIconButton.layer.shadowRadius = 0.0
            plusIconButton.layer.masksToBounds = false
        }
    
        @objc func addPhotos() {
            for menu in gutterMenu{
              if let dic = menu as? NSDictionary{
                if dic["name"] as! String == "add" {
                    let presentedVC = UploadPhotosViewController()
                    presentedVC.directUpload = false
                    presentedVC.url = dic["url"] as! String
                    presentedVC.param = dic["urlParams"] as! NSDictionary
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                    self.navigationController?.pushViewController(presentedVC, animated: false)
                }
            }
        }
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
        @objc func openPrivacyOptions() {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
            for dic in self.privacyResponse {
                if let dictionary = dic as? NSDictionary {
                    if let options = dictionary["multiOptions"] as? NSDictionary {
                        for (key , value) in options {
                       
                alertController.addAction(UIAlertAction(title: "\(value)", style: .default) { action -> Void in
                   
                    if Reachabable.isConnectedToNetwork() {
                        removeAlert()
                        var params = [String : String]()
                        let albumId = String(describing: self.albumId!)
                        var urlPath = "albums/change-privacy/\(albumId)"
                        params["auth_view"] = "\(key)"
                        post(params, url: urlPath, method: "POST") { (succeeded, msg) -> () in
                            DispatchQueue.main.async(execute: {
                                if msg{
                                    
                                    if succeeded["message"] != nil{
                                        showToast(message: succeeded["message"] as! String, controller: self)
                                       // self.exploreAlbum()
                                        switch(self.contentType)
                                        {
                                        case "sitepage_photo":
                                            urlPath = "sitepage/photos/viewalbum/\(self.pageId!)/\(albumId)"
                                        case "sitestore_photo":
                                            urlPath = "sitestore/photos/view-album/" + String(self.contentId)
                                        case "sitegroup_photo":
                                            urlPath = "advancedgroups/photos/viewalbum/\(self.groupId!)/\(albumId)"
                                            
                                        default:
                                            urlPath = "albums/album/view"
                                            break
                                            
                                        }
                                        post(["gutter_menu": "1", "profile_tabs" : "1", "album_id" : String(albumId), "limit" :"\(limit)", "page" : "\(self.pageNumber)"], url: "\(urlPath)", method: "GET") { (succeeded, msg) -> ()  in
                                            //
                                            

                                            DispatchQueue.main.async(execute: {
                                             if msg{
                                                                                            if succeeded["body"] != nil{
                                                                                                if let body = succeeded["body"] as? NSDictionary{
                                                                                                    if let response = body["album"] as? NSDictionary{
                                                                
                                                           if let viewPrivacy = response["view_privacy"] as? String {
                                                                                         self.privacyButton.setTitle("\u{f0ac} \(viewPrivacy)", for: .normal)
                                                                                                        }                                         }
                                                                                                }
                                                }
                                                }
                                            })
                                                        
                                        }
                        
                                    }
                                  
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
                        self.showAlertMessage(self.view.center , msg: network_status_msg, timer: false)
                    }
    
                })
            }
                    }
                }
            }
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
             self.present(alertController, animated:true, completion: nil)
    
        }
    
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        //self.view.setNeedsDisplay()
        like_CommentStyle = 1
        if (showNavColor == true)
        {
            
            setNavigationImage(controller: self)
            
        }
        else
        {
            removeNavigationImage(controller: self)
        }
        if refreshPhotos == true || updateFromAlbum == true{
            refreshPhotos = false
            
            
            exploreAlbum()
        }
        else if refreshPhotos == false && updateFromAlbum == true{
            showSpinner = false
            updateFromAlbum = false
            exploreAlbum()
        }
        
        
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let newHeight : CGFloat = self.albumPhotoCollectionView.collectionViewLayout.collectionViewContentSize.height
        
        if newHeight > 0.0 {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            if self.contentType == "" {
            like_comment.isHidden = false
            
            if self.contentDescription != nil {
                if self.contentDescription.length < 100 {
               self.mainView.contentSize.height = self.headerView.frame.size.height + newHeight + tabBarHeight + 20
                }
                else {
                    self.mainView.contentSize.height = self.headerView.frame.size.height + newHeight + tabBarHeight
                }
            }
            else {
                self.mainView.contentSize.height = self.headerView.frame.size.height + newHeight + tabBarHeight
                }
            
            self.albumPhotoCollectionView.frame.size.height = newHeight - 10
            
         }
            else {
                self.dividerLine.isHidden = false
                self.mainView.contentSize.height = self.headerView.frame.size.height + newHeight + tabBarHeight
                self.albumPhotoCollectionView.frame.size.height = newHeight - 10
            }
        }
    }
   
    
    override func viewWillAppear(_ animated: Bool){
        self.albumPhotoCollectionView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.old, context: nil)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.alpha = 1
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 40, y: 0, width: navigationBar.frame.width - 80, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
            
        }
        if (showNavColor == true){
            setNavigationImage(controller: self)
        }else{
            removeNavigationImage(controller: self)
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
        if popAfterDelay == true{
            _ = navigationController?.popViewController(animated: true)
            
        }
    }
    
    // Pull to Request Action
    @objc func refresh(){
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            showSpinner = false
            pageNumber = 1
            exploreAlbum()
        }else{
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    
    func updateAlbum(_ url : String){
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
            var method = "POST"
            
            if url.range(of: "delete") != nil{
                method = "DELETE"
            }
            
            // Send Server Request to Explore Album Contents with Album_ID
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        // On Success Update Album Detail
                        // Update Album Detail
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        if self.deleteAlbum == true{
                            feedUpdate = true
                            albumUpdate = true
                            self.popAfterDelay = true
                            self.createTimer(self)
                            return
                        }
                        self.exploreAlbum()
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
            showAlertMessage(view.center , msg: network_status_msg, timer: false)
        }
        
    }
    
    // Present Feed Gutter Menus
    @objc func showGutterMenu(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                if (dic["name"] as! String != "share")
                {
                    let titleString = dic["name"] as! String
                    if titleString.range(of: "delete") != nil {
                        
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                            if  dic["name"] as! String ==  "delete"{
                                
                                // Confirmation Alert
                                displayAlertWithOtherButton(NSLocalizedString("Delete Album", comment: ""),message: NSLocalizedString("Are you sure you want to delete this album?",comment: "") , otherButton: NSLocalizedString("Delete Album", comment: "")) { () -> () in
                                    self.deleteAlbum = true
                                    self.updateAlbum(dic["url"] as! String)
                                }
                                DispatchQueue.main.async{
                                self.present(alert, animated: true, completion: nil)
                                }
                            }
                            
                        }))
                    }
                    else
                    {
                        
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                            // Write For Edit Album Entry
                            if dic["name"] as! String == "add" {
                                let presentedVC = UploadPhotosViewController()
                                presentedVC.directUpload = false
                                presentedVC.url = dic["url"] as! String
                                presentedVC.param = dic["urlParams"] as! NSDictionary
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                            }
                            
                            if dic["name"] as! String == "addphoto" {
                                let presentedVC = UploadPhotosViewController()
                                presentedVC.directUpload = false
                                presentedVC.url = dic["url"] as! String
                                presentedVC.param = [ : ]
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                            }
                            
                            if dic["name"] as! String == "albumofday" {
                                let presentedVC = FormGenerationViewController()
                                isCreateOrEdit = true
                                presentedVC.url = dic["url"] as! String
                                presentedVC.formTitle = NSLocalizedString(" Make Album of the Day", comment: "")
                                presentedVC.param = [ : ]
                                presentedVC.contentType = "Page"
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            }
                            
                            if dic["name"] as! String == "featured" ||  dic["name"] as! String == "unfeatured"{
                                
                                self.updateAlbum(dic["url"] as! String)
                                
                            }
                            
                            if  dic["name"] as! String == "edit"{
                                
                                isCreateOrEdit = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit Album Settings", comment: "")
                            
                                presentedVC.contentType = "album"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            }
                            if  dic["name"] as! String == "report"
                            {
                                //confirmationAlert = false
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                presentedVC.url = dic["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                            }
                            
                        }))
                        
                    }
                }
                
            }
        }
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = UIButton()
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    @objc func shareItem()
    {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title:  String(format: NSLocalizedString("Share on %@", comment: ""),app_title), style: .default) { action -> Void in
            let pv = AdvanceShareViewController()
            pv.url = self.shareUrl
            pv.param = self.shareParam as! [AnyHashable : Any] as NSDictionary
            pv.Sharetitle = self.albumName
            if (self.contentDescription != nil) {
                pv.ShareDescription = self.contentDescription
            }
            pv.imageString = self.profileImageUrlString
            pv.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: pv)
            self.present(nativationController, animated:true, completion: nil)
            
        })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share Outside",comment: ""), style: UIAlertAction.Style.default) { action -> Void in
            
             var sharingItems = [AnyObject]()
             sharingItems.append(self.content_url as AnyObject)
            
            let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            
            if  (UIDevice.current.userInterfaceIdiom == .phone){
                
                if(activityViewController.popoverPresentationController != nil) {
                    activityViewController.popoverPresentationController?.sourceView = self.view;
                    let frame = UIScreen.main.bounds
                    activityViewController.popoverPresentationController?.sourceRect = frame;
                }
                
            }
            else
            {
                
                let presentationController = activityViewController.popoverPresentationController
                presentationController?.sourceView = self.view
                presentationController?.sourceRect = CGRect(x: self.view.bounds.width/2 , y: self.view.bounds.width/2, width: 0, height: 0)
                presentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                
            }
            
            self.present(activityViewController, animated: true, completion: nil)
            
        })
        
        if  (UIDevice.current.userInterfaceIdiom == .phone){
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }else{
            // Present Alert as! Popover for iPad
            alertController.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover = alertController.popoverPresentationController
            popover?.sourceView = self.view
            popover?.sourceRect = CGRect(x: view.bounds.width/2, y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated:true, completion: nil)
        
    }
    // MARK: - Server Connection For Album Profile
    func exploreAlbum(){
        // Check Internet Connection
        
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            if (self.pageNumber == 1){
                allPhotos.removeAll(keepingCapacity: false)
            }
            
            if (showSpinner){
                //   spinner.center = view.center
                if updateScrollFlag == false
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1)
                {
                    activityIndicatorView.center = view.center
                    updateScrollFlag = false
                }
                //                spinner.hidesWhenStopped = true
                //                spinner.style = UIstyle.gray
                //                view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
                //   activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            
            switch(contentType)
            {
            case "sitepage_photo":
                urlPath = "sitepage/photos/viewalbum/\(pageId!)/\(albumId!)"
            case "sitestore_photo":
                urlPath = "sitestore/photos/view-album/" + String(contentId)
            case "sitegroup_photo":
                urlPath = "advancedgroups/photos/viewalbum/\(groupId!)/\(albumId!)"
                
            default:
                urlPath = "albums/album/view"
                break
                
            }
            
            // var param = [String:String]
            //param["auth_view"] = "everyone"
            
            // Send Server Request to Explore Group Contents with Group_ID
            post(["gutter_menu": "1", "profile_tabs" : "1", "album_id" : String(albumId), "limit" :"\(limit)", "page" : "\(pageNumber)"] , url: "\(urlPath)", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    if msg{
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                self.isPageRefresing = false
                                if let canEdit = body["canEdit"] {
                                    if canEdit as! Int == 1 {
                                    self.plusIconButton.isHidden = false
                                    self.privacyButton.isUserInteractionEnabled = true
                                    }
                                    else {
                                        self.plusIconButton.isHidden = true
                                        self.privacyButton.isUserInteractionEnabled = false
                                    }
                                }
                                if self.contentType != "" {
                                    self.plusIconButton.isHidden = true
                                }
                               
                                // Update Content Gutter Menu
                                if let response = body["album"] as? NSDictionary{
                                    
                                    self.albumName = response["title"] as? String
                                    self.headerTitle.textColor = textColorDark
                                    
                                    if self.albumName.length < 15{
                                       // self.headerTitle.frame.origin.y   = 210
                                    }
                                    if self.albumName.length > 18{
                                       // self.headerTitle.frame.origin.y   = 170
                                    }
                                    if self.albumName.length > 45{
                                       // self.headerTitle.frame.origin.y   = 130
                                    }
                                    if let url = response["content_url"] as? String {
                                        self.content_url = url
                                    }
                                    
                                    self.headerTitle.setText( self.albumName, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                        
                                        // TODO: Clean this up...
                                        return mutableAttributedString
                                    })

                                    self.descView.text = response["description"] as? String
                                    if (response["description"] as? String == "")
                                    {   self.headerView.frame.size.height =  self.headerView.frame.size.height  - self.descView.frame.size.height
                                        self.descView.frame.size.height = 0
                                        self.height = getBottomEdgeY(inputView: self.headerView)
                                        if self.contentType == "" {
                                            self.like_comment.frame.origin.y =  getBottomEdgeY(inputView: self.descView) + 17
                                            self.descView.textAlignment = .justified
                                        }
                                        self.albumPhotoCollectionView.frame.origin.y = getBottomEdgeY(inputView: self.headerView)
                                    }
                                    else if let description = response["description"] as? String
                                    {
                                        self.descView.textAlignment = .justified
                                        self.contentDescription = description
                                        if self.contentDescription.length < 100 {
                                           self.descView.frame.size.width = self.view.bounds.width - 10
                                        self.descView.setText(description, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in

                                            // TODO: Clean this up...
                                            return mutableAttributedString
                                        })
                                        self.descView.sizeToFit()
                                        self.headerView.frame.size.height = 360 + self.descView.frame.size.height - 20
                                        likeCommentFrame.origin.y = 40 + self.descView.frame.size.height
                                            if self.contentType != "sitegroup_photo" || self.contentType != "sitestore_photo"  || self.contentType != "sitepage_photo" {
                                            self.like_comment.frame.origin.y = getBottomEdgeY(inputView: self.descView) + 17
                                            }
                                        self.albumPhotoCollectionView.frame.origin.y = getBottomEdgeY(inputView: self.headerView) + 20
                                            self.albumPhotoCollectionView.frame.size.height = UIScreen.main.bounds.height - tabBarHeight - self.headerView.frame.size.height
                                        self.height = getBottomEdgeY(inputView: self.headerView)+15
                                    }
                                        else {
                                            self.descriptionResult = response["description"] as? String
                                            
                                            self.moreOrLess()
                                        }
                                    }
                                    
                                   
                                    if let postedDate = response["creation_date"] as? String
                                    {
                                        let postedOn = dateDifference(postedDate)
                                        if (postedOn.range(of: "ago") != nil) {
                                           self.albumCreatedOn.text = String(format: NSLocalizedString("Created %@", comment: ""), postedOn)
                                        }
                                        else {
                                           self.albumCreatedOn.text = String(format: NSLocalizedString("Created on %@", comment: ""), postedOn)
                                        }
                                    }
                                    if let viewPrivacy = response["view_privacy"] as? String {
                                        self.privacyButton.setTitle("\u{f0ac} \(viewPrivacy)", for: .normal)
                                    }
                                    
                                    self.ownerTitle = response["owner_title"] as? String
                                    self.profileImageUrlString = response["image"] as! String
                                    let profileImageUrl = URL(string: response["image"] as! String)
                                    if  profileImageUrl != nil {
                                        self.headerImageView.kf.indicatorType = .activity
                                        (self.headerImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                        self.headerImageView.kf.setImage(with: profileImageUrl as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                            
                                        })
                                        
                                    }
                                    
                                    
                                    let ownerImageUrl = URL(string: response["owner_image_normal"] as! String)
                                    self.coverImageUrl = response["owner_image_normal"] as! String
                                  if body["viewPrivacy"] != nil {
                                     if let categories = body["viewPrivacy"]  as? NSArray{
                                        self.privacyResponse = (categories as [AnyObject])
                                        //self.createCategoryView()
                                        }
                                   }
                                    var description = ""
                                    if let ownerName = response["owner_title"] as? String {
                                        description = "\(ownerName)\n"
                                        
                                        if let postedDate = response["creation_date"] as? String{
                                            let postedOn = dateDifference(postedDate)
                                            description += postedOn
                                            description += "\n"
                                            
                                            let viewCount = response["view_count"] as? Int
                                            var viewInfo = ""
                                            viewInfo =  singlePluralCheck( NSLocalizedString(" view", comment: ""),  plural: NSLocalizedString(" views", comment: ""), count: viewCount!)
                                            description += "\(viewInfo)"
                                        }
                                    }
                                }
                                
                                
                                if let menu = body["gutterMenu"] as? NSArray
                                {
                                    self.gutterMenu = menu
                                    let menu = UIBarButtonItem(title:optionIcon, style: UIBarButtonItem.Style.plain , target:self , action: #selector(AlbumProfileViewController.showGutterMenu))
                                    
                                    menu.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)!], for: UIControl.State())
                                    self.navigationItem.rightBarButtonItem = menu
                                }
                                
                                var isCancel = false
                                for tempMenu in self.gutterMenu{
                                    if let tempDic = tempMenu as? NSDictionary
                                    {
                                        if tempDic["name"] as! String == "share"
                                        {
                                            self.shareUrl = tempDic["url"] as! String
                                            self.shareParam = tempDic["urlParams"] as! NSDictionary
                                        }
                                        else
                                        {
                                            isCancel = true
                                        }
                                    }
                                }
                                
                                if let photosCount = body["totalPhotoCount"] as? Int
                                {
                                    if photosCount > 0
                                    {
                                        if updateFromAlbum {
                                            self.showSpinner = false
                                            updateFromAlbum = false
                                        }
                                        else {
                                            self.showSpinner = true
                                            
                                        }
                                        self.getPhotos()
                                        
                                    }
                                    else {
                                           self.navigationController?.setNavigationBarHidden(false, animated: true)
 
                                    }
                                }
                                
                                //                                if let images = body["albumPhotos"] as? NSArray{
                                //                                    allPhotos  = allPhotos + (images as! [NSDictionary])
                                //                                   // allPhotos = allPhotos + (images as [AnyObject])
                                //                                }
                                //                                self.totalItems = body["totalPhotoCount"] as! Int
                                //                                if self.totalItems < 3
                                //                                {
                                //                                    self.albumPhotoTableView.frame.size.height -= 35
                                //                                }
                                if logoutUser == false
                                {
                                    let rightNavView = UIView(frame: CGRect(x: 0, y: 0, width: 66, height: 44))
                                    rightNavView.backgroundColor = UIColor.clear
                                    let shareButton = createButton(CGRect(x: 0,y: 12,width: 22,height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    shareButton.setImage(UIImage(named: "upload")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    shareButton.addTarget(self, action: #selector(AlbumProfileViewController.shareItem), for: .touchUpInside)
                                    if (self.shareUrl != nil)
                                    {
                                        rightNavView.addSubview(shareButton)
                                    }
                                    let optionButton = createButton(CGRect(x: 22,y: 0,width: 45,height: 45), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                    optionButton.setImage(UIImage(named: "option")?.maskWithColor(color: textColorPrime), for: UIControl.State())
                                    optionButton.addTarget(self, action: #selector(AlbumProfileViewController.showGutterMenu), for: .touchUpInside)
                                    
                                    if isCancel == false
                                    {
                                        shareButton.frame.origin.x = 44
                                    }
                                    else
                                    {
                                        rightNavView.addSubview(optionButton)
                                    }
                                    
                                    self.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
                                    self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                                }
                                
                            }
                        }
                        self.albumPhotoCollectionView.reloadData()
                    let height = self.albumPhotoCollectionView.collectionViewLayout.collectionViewContentSize.height
                       
                        self.mainView.contentSize.height = self.headerView.frame.size.height + height
                        
                    }
                    else
                    {
                        // Handle Server Side Error
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                    }
                })
            }
        }else{
            // No Internet Connection Message
            showAlertMessage(view.center , msg: network_status_msg, timer: false)
        }
        
    }
    
    func getPhotos()
    {
        if reachability.connection != .none
        {
            removeAlert()
            if (self.pageNumber == 1)
            {
                allPhotos.removeAll(keepingCapacity: false)
            }
            
            if (showSpinner)
            {
                if updateScrollFlag == false
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
                if (self.pageNumber == 1)
                {
                    activityIndicatorView.center = view.center
                    updateScrollFlag = false
                }
                else
                {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
            }
            else
            {
                if (self.pageNumber == 1)
                {
                    activityIndicatorView.center = view.center
                    updateScrollFlag = false
                }
                else
                {
                    activityIndicatorView.center.x =  view.center.x
                    activityIndicatorView.frame.origin.y = self.view.frame.size.height - tabBarHeight - 40
                }
            }
            
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            
            var album_subject_type = ""
            switch(contentType)
            {
            case "sitepage_photo":
                album_subject_type = "sitepage_album"
            case "sitestore_photo":
                album_subject_type = "sitestore_album"
            case "sitegroup_photo":
                album_subject_type = "sitegroup_album"
            default:
                album_subject_type = "album"
                break
                
            }
            
            urlPath = "albums/view-content-album"
            post(["gutter_menu": "1", "profile_tabs" : "1", "subject_id" : String(albumId), "limit" :"\(limit)", "page" : "\(pageNumber)","subject_type" : album_subject_type] , url: "\(urlPath)", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    
                    activityIndicatorView.stopAnimating()
                    if self.flag == true {
                        self.mainView.frame.origin.y += 40
                        self.flag = false
                    }
                    self.refresher.endRefreshing()
                    self.showSpinner = false
                    self.updateScrollFlag = true
                    
                    if msg
                    {
                        self.isPageRefresing = false
                        if succeeded["body"] != nil
                        {
                            if let body = succeeded["body"] as? NSDictionary
                            {
                                if let images = body["albumPhotos"] as? NSArray
                                {
                                    allPhotos  = allPhotos + (images as! [NSDictionary])
                                    // allPhotos = allPhotos + (images as [AnyObject])
                                }
                                self.totalItems = body["totalPhotoCount"] as! Int
                                if self.deeplinkingPhotoId != "" {
                                    self.extractImageDetails(photoId: self.deeplinkingPhotoId)
                                }
                                if self.totalItems < 3
                                {
                                    //self.albumPhotoTableView.frame.size.height -= 35
                                }
                            }
                        }
                    }
                    if allPhotos.count == 0 {
                        print("no photos found ")
                    }
                    self.createPattern(count: allPhotos.count)
                    self.albumPhotoCollectionView.reloadData()
                    
                })
            }
            
        }
    }
    
    func extractImageDetails(photoId : String) {
        var imageIndex: Int?
        var imageUrl = ""
        for i in 0..<allPhotos.count {
            if let dic = allPhotos[i] as? NSDictionary {
                if let id = dic["photo_id"] as? Int, "\(id)" == photoId {
                    imageIndex = i
                    if let url = dic["image"] as? String {
                        imageUrl = url
                    }
                    break
                }
            }
        }
        let presentedVC = AdvancePhotoViewController()
        presentedVC.allphotos = allPhotos
        presentedVC.photoID = imageIndex ?? 0
        presentedVC.photoAlbumId = "\(self.albumId)"
        presentedVC.imageUrl = imageUrl
        presentedVC.photoType = "photo"
        presentedVC.param = ["subject_type":"album","subject_id":String(albumId)]
        presentedVC.photoLimit = limit
        presentedVC.photoForViewer = photos
        presentedVC.total_items = totalItems
        presentedVC.attachmentID = albumId!
        presentedVC.albumTitle = albumName
        presentedVC.ownerTitle = ownerTitle
        self.deeplinkingPhotoId = ""
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    
   
        @objc func openImage(_ sender:Int){
    
            let photoInfo = allPhotos[sender]
            let openingImage = photoInfo["image"] as! String
            let presentedVC = AdvancePhotoViewController()
            presentedVC.allphotos = allPhotos
            presentedVC.photoID = sender
            presentedVC.photoAlbumId = "\(self.albumId)"
            presentedVC.imageUrl = openingImage
            switch(contentType){
            case "sitepage_photo":
    
               // presentedVC.url = "sitepage/photos/viewalbum-data/" + String(pageId) + "/" + String(albumId)
                presentedVC.photoType = "sitepage_photo"
                presentedVC.param = ["subject_type":"sitepage_album","subject_id":String(albumId)]
            case "sitestore_photo":
               // presentedVC.url = "sitestore/photos/view-photo/" + String(contentId)
                presentedVC.param = ["subject_type":"sitestore_album","subject_id":String(albumId)]
                presentedVC.photoType = "sitestore_photo"
            case "sitegroup_photo":
                //presentedVC.url = "advancedgroups/photos/viewalbum/" + String(groupId) + "/" + String(albumId)
                presentedVC.photoType = "sitegroup_photo"
                presentedVC.param = ["subject_type":"sitegroup_album","subject_id":String(albumId)]
                presentedVC.groupId = groupId
    
            default:
                presentedVC.photoType = "photo"
                presentedVC.param = ["subject_type":"album","subject_id":String(albumId)]
                presentedVC.photoLimit = limit
                break
    
            }
            presentedVC.photoForViewer = photos
            presentedVC.total_items = totalItems
            presentedVC.attachmentID = albumId!
            presentedVC.albumTitle = albumName
            presentedVC.ownerTitle = ownerTitle
    
            self.navigationController?.pushViewController(presentedVC, animated: false)
    
        }
    
    // MARK:  UIScrollViewDelegate
    
    // Handle Scroll For Pagination
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
                    if flag == false
                    {
                        mainView.frame.origin.y -= 40
                        flag = true
                    }
                    
//                    let footerView = UIView(frame: frameActivityIndicator)
//                    footerView.tag = -11
//                    footerView.backgroundColor = UIColor.clear
//                    let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
//                    activityIndicatorView.frame = CGRect(x: 0, y: 160, width: 25, height: 25)
//                    activityIndicatorView.center.x = view.center.x
//                    view.bringSubviewToFront(activityIndicatorView)//addSubview(activityIndicatorView)
//                    activityIndicatorView.startAnimating()
//                    activityIndicatorView.backgroundColor = .green
//                    activityIndicatorView.animate(isHidden: false, duration: 3) { (_) in
//                        activityIndicatorView.stopAnimating()
//
//                    }
                    

                    getPhotos()
                    //exploreAlbum()
                }
            }
            else
            {
//                if flag == true {
//                    mainView.contentOffset.y += 50
//                    flag = false
//                }
//                albumPhotoCollectionView.frame.size.height += 50
            }
            
        }
        
    }
    var tempHeight : CGFloat = 0.0
    var lContentOffset: CGFloat = 0.0
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        arrowView.isHidden = true
        scrollViewEmoji.isHidden = true
        scrollviewEmojiLikeView.isHidden = true
        //if updateScrollFlag{
        // Check for Page Number for Browse Album
        //        if  albumPhotoTableView.contentOffset.y >= albumPhotoTableView.contentSize.height - albumPhotoTableView.bounds.size.height{
        //            if (!isPageRefresing  && limit*pageNumber < totalItems){
        //                if Reachabable.isConnectedToNetwork() {
        //                    updateScrollFlag = false
        //                    pageNumber += 1
        //                    isPageRefresing = true
        //                    exploreAlbum()
        //                }
        //            }
        //
        //        }
        let scrollOffset = scrollView.contentOffset.y

        let scrollViewHeight = scrollView.frame.size.height / 2
        
        if (scrollOffset > 60.0){
            showNavColor = true
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            setNavigationImage(controller: self)
            self.marqueeHeader.text = self.albumName
            self.marqueeHeader.alpha = barAlpha
            self.marqueeHeader.textColor = textColorPrime
            self.navigationController?.navigationBar.alpha = barAlpha
            self.headerTitle.alpha = 1-barAlpha
            if (self.lastContentOffset > scrollView.contentOffset.y) {
                // move up
              //  self.like_comment.fadeIn()
            }
            else if ((self.lastContentOffset < scrollView.contentOffset.y) && (scrollView.contentOffset.y < scrollViewHeight - 5 )){
                // move down
                //self.like_comment.fadeOut()
            }
            
            // update the new position acquired
            self.lastContentOffset = scrollView.contentOffset.y
            
        }else{
            showNavColor = false
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            
            removeNavigationImage(controller: self)
            self.marqueeHeader.alpha = barAlpha
            self.headerTitle.alpha = 1-barAlpha
            
            if (scrollOffset < 10.0){
                self.marqueeHeader.alpha = 0
                self.headerTitle.alpha = 1
                self.headerTitle.font = UIFont(name: fontName, size: 30.0)
            }
        }
    }
    
    func moreOrLess(){
        let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZENormal, nil)
        self.descView.numberOfLines = 0
        self.descView.delegate = self
        self.descView.font = UIFont(name: fontName, size: 14)
        self.descView.textAlignment = .justified
        self.descView.frame.size.width = self.view.bounds.width - 10
        if let description = descriptionResult{
            var tempInfo = ""
            if description != ""  {
                let tempTextLimit =  100
                if description.length > tempTextLimit{
                    if self.selectedMoreLess == false{
                        tempInfo += (description as NSString).substring(to: tempTextLimit-3)
                        tempInfo += NSLocalizedString(" More...",  comment: "")
                        //self.headerView.frame.size.height =  440
                       // self.albumPhotoCollectionView.frame.origin.y = getBottomEdgeY(inputView: headerView)
                        self.descView.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                            let range2 = (tempInfo as NSString).range(of: NSLocalizedString("More",  comment: ""))
                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTFontAttributeName as NSString) as String as String), value: boldFont, range: range2)
                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTForegroundColorAttributeName as NSString) as String as String), value:textColorDark , range: range2)
                           
                            return mutableAttributedString
                        })
                        let range = (tempInfo as NSString).range(of: tempInfo)//NSLocalizedString("More",  comment: ""))
                        self.descView.addLink(toTransitInformation: [ "type" : "moreContentInfo"], with:range)
                        self.descView.sizeToFit()
                        self.headerView.frame.size.height = 360 + self.descView.frame.size.height
                        likeCommentFrame.origin.y = 40 + self.descView.frame.size.height
                       // self.like_comment.myCustomSetup()
                        if self.contentType != "sitegroup_photo" || self.contentType != "sitestore_photo"  || self.contentType != "sitepage_photo" {
                        self.like_comment.frame.origin.y = getBottomEdgeY(inputView: self.descView) + 17
                        }
                        self.albumPhotoCollectionView.frame.origin.y = getBottomEdgeY(inputView: self.headerView)
                        self.albumPhotoCollectionView.frame.size.height = UIScreen.main.bounds.height - tabBarHeight - headerView.frame.size.height
                    }else{
                        tempInfo += description
                        tempInfo += NSLocalizedString(" Less ...",  comment: "")
                        //self.headerView.frame.size.height = 440 + descView.bounds.height
                        //self.like_comment.frame.origin.y = getBottomEdgeY(inputView: self.descView)
                        //self.albumPhotoCollectionView.frame.origin.y = getBottomEdgeY(inputView: headerView)
                        self.descView.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                            let range1 = (tempInfo as NSString).range(of: NSLocalizedString("Less",  comment: ""))
                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: (kCTFontAttributeName as NSString) as String as String), value: boldFont, range: range1)
                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range1)
                            return mutableAttributedString
                        })
                        let range1 = (tempInfo as NSString).range(of:tempInfo)//NSLocalizedString("Less",  comment: ""))
                        self.descView.addLink(toTransitInformation: ["type" : "lessContentInfo"], with:range1)
                        self.descView.sizeToFit()
                        self.headerView.frame.size.height = 360 + self.descView.frame.size.height
                       // likeCommentFrame.origin.y = 40 + self.descView.frame.size.height
                       // self.like_comment.myCustomSetup()
                        if self.contentType != "sitegroup_photo" || self.contentType != "sitestore_photo"  || self.contentType != "sitepage_photo" {
                        self.like_comment.frame.origin.y = getBottomEdgeY(inputView: self.descView) + 17
                        }
                        self.albumPhotoCollectionView.frame.origin.y = getBottomEdgeY(inputView: self.headerView)
                         self.albumPhotoCollectionView.frame.size.height = UIScreen.main.bounds.height - tabBarHeight - headerView.frame.size.height
                    }
                }
            }
          
          
            self.descView.lineBreakMode = NSLineBreakMode.byWordWrapping
        }
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithTransitInformation components: [AnyHashable: Any]!) {
        let type = components["type"] as! String
        switch(type){
        case "moreContentInfo":
            selectedMoreLess = true
            self.moreOrLess()
           // self.albumPhotoCollectionView.reloadData()
            
        case "lessContentInfo":
            selectedMoreLess = false
            self.moreOrLess()
           // self.albumPhotoCollectionView.reloadData()
        default:
            print("error")
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.albumPhotoCollectionView.removeObserver(self, forKeyPath: "contentSize")
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        setNavigationImage(controller: self)
        self.mainView.willRemoveSubview(self.albumPhotoCollectionView)
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }
    
    @objc func goBack(){
        
        if conditionalProfileForm == "BrowsePage"
        {
            albumUpdate = true
            _ = self.navigationController?.popToRootViewController(animated: true)
            
        }
        else
        {
            _ = self.navigationController?.popViewController(animated: false)
            
        }
        
    }

    @objc func onImageViewTap(){
        if self.profileImageUrlString != nil && self.profileImageUrlString != "" {
            let presentedVC = SinglePhotoLightBoxController()
            presentedVC.imageUrl = self.profileImageUrlString
            presentedVC.modalPresentationStyle = .fullScreen
            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.present(presentedVC, animated: true, completion: nil)
//            let nativationController = UINavigationController(rootViewController: presentedVC)
//            present(nativationController, animated:false, completion: nil)
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
// collectionview delegates
extension AlbumProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
//        if allPhotos.count > 0 {
//            if self.user_id == currentUserId {
//            plusIconButton.isHidden = false
//            }
//        }
        return allPhotos.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as? PhotoCollectionViewCell else {
            return UICollectionViewCell()
        }
        let photoInfo = allPhotos[indexPath.row]

        if let url1 = URL(string:photoInfo["image"] as! String){
            let imageUrl = photoInfo["image"] as! String
            cell.imageView?.backgroundColor = .randomColor()
           // cell.imageView?.kf.indicatorType = .activity
            //(cell.imageView?.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
            cell.imageView?.kf.setImage(with: url1, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in

            })
        }
        return cell
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

  

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openImage(indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header =  albumPhotoCollectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: albumHeaderId, for: indexPath) as! CollectionViewHeader
        header.view = headerView
        header.view.backgroundColor = .green
        return header
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let size = CGSize(width: view.frame.width, height: 100)
        return size
    }
    
    
}

extension AlbumProfileViewController: SquareFlowLayoutDelegate {
    func shouldExpandItem(at indexPath: IndexPath) -> Bool {

        if patternArray.count > 0 {
        if patternArray[indexPath.row] == .expanded {
            return true
        }
        else {
            return false
        }
    }
        else {
            return false
        }
    }

}



