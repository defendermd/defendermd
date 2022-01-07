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
//  StoresProfileViewController.swift
//  seiosnativeapp
//

import UIKit
import NVActivityIndicatorView


var storeDetailUpdate: Bool!
var sitevideoPluginEnabled_store : Int = 0
class StoresProfileViewController: UIViewController, TTTAttributedLabelDelegate, UITableViewDelegate, UIScrollViewDelegate, UITextViewDelegate, UITableViewDataSource , UITabBarControllerDelegate{
    
    var productMoreOrLess : UIButton!
    var productMoreOrLessView :UIView!
    var RedirectText : String!
    var lastContentOffset: CGFloat = 0
    var storeId:String = ""
    var subjectId:Int!                         // For use Activity Feed updates in Other Modules
    var subjectType:String!                    // For use Activity Feed updates in Other Modules
    var showSpinner = true                      // show spinner flag for pull to refresh
    var refresher:UIRefreshControl!             // Refresher for Pull to Refresh
    var maxid:Int!                              // MaxID for Pagination
    var minid:Int!                              // MinID for New Feeds
    var myTimer:Timer!                        // Timer for Update feed after particular time repeation
    var updateScrollFlag = true                 // Flag for Pagination by ScrollView Delegate
    var contentUrl : String!
    var shareDescription : String!
    var coverImageUrl : String!
    var profileImageUrl : String!
    var mainSubView:UIView!
    var coverImage:UIImageView!
    var contentName:UILabel!
    var tabsContainerMenu:UIScrollView!
    var headerHeight:CGFloat = 0
    var detailWebView : UITextView!
    var contentTitle : String!
    var shareTitle:String!
    var user_id : Int!
    var ownerName : UILabel!
    var contentview : UIView!
    var deleteContent : Bool!
    var popAfterDelay:Bool!
    var showFulldescription = false
    var contentExtraInfo: NSDictionary!
    var CheckinDic: NSDictionary = [:]
    var gutterMenu: NSArray = []
    var topView: UIView!
    var imgUser: UIImageView!
    var shareUrl : String!
    var shareParam : NSDictionary!
    var info : UILabel!
    var UserId:Int!
  //  var imageCache = [String:UIImage]()
    var totalClassifiedImage : NSArray!
    var totalPic : TTTAttributedLabel!
    var totalPhoto: Int!
    var contentImage: String!
    @objc var count:Int = 0
    var profileView = UIView()
    var profileView2 = UIView()
    var addWishList : UIButton!
    var deleteStoreEntry:Bool!
    var reviewId:Int!
    var photos:[PhotoViewer] = []
    var noPost : Bool = true
    var marqueeHeader : MarqueeLabel!
    var webviewText : String!
    var rightBarButtonItem : UIBarButtonItem!
    var pageNumber:Int = 1
    var totalItems:Int = 0
    var storeProfileTabMenu: NSArray = []
    var productsTableView:UITableView!
    var storeProducts = [AnyObject]()
    var isPageRefresing = false
    var currency : String = ""
    var likeButton: UIButton!
    var isLike: Bool!
    var whiteBackView: UIView!
    var likeStat: UILabel!
    var cartButton = UIBarButtonItem()
    var label1 : TTTAttributedLabel!
    var label3 : TTTAttributedLabel!
    var label5 : TTTAttributedLabel!
    var label6 : TTTAttributedLabel!
    var isMyStore : Bool!
    
    /*** For cover and profile photo ***/
    
    
    var camIconOnCover: UILabel!
    var camIconOnProfile: UILabel!
    var memberProfilePhoto:UIImageView!
    
    let productAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        storeUpdate = false
        like_CommentStyle = 1
        storeDetailUpdate = true
        deleteStoreEntry = false
        storeProducts.removeAll(keepingCapacity: false)
        self.navigationItem.rightBarButtonItem = nil
        removeMarqueFroMNavigaTion(controller: self)
        
        self.tabBarController?.delegate = self
        

        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(StoresProfileViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
       
        
        if tabBarHeight > 0{
            productsTableView = UITableView(frame: CGRect(x:0,y: -TOPPADING, width: view.bounds.width, height: view.bounds.height - tabBarHeight+TOPPADING), style:.grouped)
        }else{
            productsTableView = UITableView(frame: CGRect(x:0,y: -TOPPADING, width: view.bounds.width, height: view.bounds.height+TOPPADING), style:.grouped)
            productsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        }
        
        productsTableView.register(ProductTableViewCell.self, forCellReuseIdentifier: "Cell")
        productsTableView.dataSource = self
        productsTableView.delegate = self
        productsTableView.backgroundColor = UIColor.clear
        productsTableView.separatorColor = UIColor.clear
        
        //mainSubView.addSubview(productsTableView)
        view.addSubview(productsTableView)
        
        
        
        
        if(UIDevice.current.userInterfaceIdiom == .pad){

            mainSubView = createView(CGRect(x:0, y: 0, width: view.bounds.width, height: 370), borderColor: borderColorLight, shadow: false)
            coverImage = CoverImageViewWithGradient(frame:CGRect(x:0,y: 0, width: mainSubView.bounds.width, height: 370))

        }else{
            mainSubView = createView(CGRect(x:0, y:0, width: view.bounds.width, height: 250), borderColor: borderColorLight, shadow: false)
            coverImage = CoverImageViewWithGradient(frame:CGRect(x:0, y: 0, width: mainSubView.bounds.width,  height:250))
        }
        
        mainSubView.layer.borderWidth = 0.0
        mainSubView.backgroundColor = aafBgColor //placeholderColor
        productsTableView.tableHeaderView = mainSubView
        //productsTableView.addSubview(mainSubView)
        //view.addSubview(mainSubView)
        
        
        coverImage.contentMode = UIView.ContentMode.scaleAspectFill
        coverImage.layer.masksToBounds = true
        coverImage.backgroundColor = placeholderColor
        coverImage.isUserInteractionEnabled = true
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(StoresProfileViewController.onImageViewTap))
        coverImage.addGestureRecognizer(tap1)
        mainSubView.addSubview(coverImage)
        
        totalPic = TTTAttributedLabel(frame:CGRect(x:view.bounds.width-45, y: 100, width: 45, height: 50) )
        totalPic.numberOfLines = 0
        totalPic.textColor = textColorLight
        totalPic.backgroundColor = UIColor.clear
        totalPic.delegate = self
        totalPic.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
        totalPic.layer.shadowColor = shadowColor.cgColor
        totalPic.layer.shadowOpacity = shadowOpacity
        totalPic.layer.shadowRadius = shadowRadius
        totalPic.layer.shadowOffset = shadowOffset
        totalPic.isHidden = true
        mainSubView.addSubview(totalPic)
        
        
        
        
        likeStat = createLabel(CGRect(x:coverImage.bounds.width - 55, y: coverImage.bounds.height - 30, width: 50, height: 30), text: "", alignment: .right, textColor: textColorLight)
        likeStat.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        mainSubView.addSubview(likeStat)
        
        topView = createView(CGRect(x:0, y: coverImage.bounds.height, width: view.bounds.width, height: 110), borderColor: UIColor.clear, shadow: false)
        topView.backgroundColor = lightBgColor
        mainSubView.addSubview(topView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(StoresProfileViewController.openProfile))
        topView.addGestureRecognizer(tap)
        
        
        
        /*imgUser = createImageView(CGRect(x:view.bounds.width/2-25, y: -25, width: 50, height: 50), border: true)
        imgUser.layer.borderWidth = 1
        imgUser.layer.masksToBounds = false
        imgUser.layer.borderColor = UIColor.clear.cgColor
        imgUser.layer.cornerRadius = imgUser.frame.height/2
        imgUser.image = UIImage(named: "user_profile_image.png")
        imgUser.clipsToBounds = true
        topView.addSubview(imgUser) */
        
        
        // Store Profile Photo at centet of top view
        
        if(UIDevice.current.userInterfaceIdiom == .pad){
            memberProfilePhoto = createImageView(CGRect(x: view.bounds.width/2-50, y: -50, width: 100, height: 100 ), border: true)
        }else{
            memberProfilePhoto = createImageView(CGRect(x: view.bounds.width/2-40, y: -40, width: 80, height: 80), border: true)
        }
        
        memberProfilePhoto.layer.borderColor = UIColor.white.cgColor
        memberProfilePhoto.layer.borderWidth = 2.5
        memberProfilePhoto.layer.cornerRadius = memberProfilePhoto.frame.size.width / 2
        memberProfilePhoto.backgroundColor = placeholderColor
        memberProfilePhoto.contentMode = UIView.ContentMode.scaleAspectFill
        memberProfilePhoto.layer.masksToBounds = true
        memberProfilePhoto.image = UIImage(named: "user_profile_image.png")
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(StoresProfileViewController.onImageViewTap2))
        memberProfilePhoto.addGestureRecognizer(tap2)
        memberProfilePhoto.tag = 321
        memberProfilePhoto.isUserInteractionEnabled = true
        topView.addSubview(memberProfilePhoto)
        memberProfilePhoto.isHidden = false
        
        
        
        /*contentName = createLabel(CGRect(x:contentPADING, y: 200, width: mainSubView.bounds.width - (2 * contentPADING), height: 40), text: "", alignment: .left, textColor: textColorLight)
        contentName.font = UIFont(name: fontBold, size: 30)
        contentName.numberOfLines = 1
        contentName.longPressLabel()
        mainSubView.addSubview(contentName) */
        
        contentName = createLabel(CGRect(x:30, y: 40, width: view.bounds.width-60, height: 30), text: "", alignment: .center, textColor: textColorDark)
        contentName.font = UIFont(name: fontName, size: FONTSIZELarge)
        contentName.lineBreakMode =  NSLineBreakMode.byTruncatingTail
        //contentName.numberOfLines = 1
        contentName.textAlignment = .center
        contentName.longPressLabel()
        topView.addSubview(contentName)
        
        ownerName = createLabel(CGRect(x:view.bounds.width/2-100, y: 70, width: 200, height: 30), text: "", alignment: .left, textColor: textColorDark)
        ownerName.lineBreakMode =  NSLineBreakMode.byTruncatingTail
        ownerName.font = UIFont(name: fontName, size: FONTSIZESmall)
        ownerName.textAlignment = .center
        topView.addSubview(ownerName)
        
        detailWebView = createTextView(CGRect(x:PADING, y: mainSubView.bounds.height + 70, width: view.bounds.width - 2 * PADING, height: 10), borderColor: borderColorMedium, corner: false )
        detailWebView.backgroundColor =  UIColor.black//bgColor
        detailWebView.isUserInteractionEnabled = true
        detailWebView.isEditable = false
        detailWebView.delegate = self
        detailWebView.text = NSLocalizedString("",  comment: "")
        detailWebView.font = UIFont(name: fontName, size: FONTSIZENormal)
        detailWebView.textColor = textColorDark
        detailWebView.layer.borderWidth = 0.0
        detailWebView.isHidden = true
        detailWebView.showsVerticalScrollIndicator = false
        mainSubView.addSubview(detailWebView)
        
        productMoreOrLessView = createView(CGRect(x:PADING, y: getBottomEdgeY(inputView:detailWebView), width:  view.bounds.width - 2 * PADING, height: 40), borderColor: UIColor.white, shadow: false)
        productMoreOrLessView.isHidden = true
        productMoreOrLessView.backgroundColor = UIColor.white
        mainSubView.addSubview(productMoreOrLessView)
        
        productMoreOrLess = createButton(CGRect(x:self.view.bounds.width - 50, y: 0, width:  40, height: 30), title: "More", border: false, bgColor: false, textColor: navColor)
        productMoreOrLess.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        productMoreOrLess.isHidden = true
        productMoreOrLess.addTarget(self, action: #selector(StoresProfileViewController.showFullDescription), for: .touchUpInside)
        productMoreOrLessView.addSubview(productMoreOrLess)
        
        whiteBackView = createView(CGRect(x:PADING, y: getBottomEdgeY(inputView:self.productMoreOrLessView), width: view.bounds.width - 2 * PADING, height: 2 * ButtonHeight - PADING), borderColor: UIColor.clear, shadow: false)
        whiteBackView.backgroundColor = UIColor.clear
        mainSubView.addSubview(whiteBackView)
        
        likeButton = createButton(CGRect(x:10,y: PADING, width: self.whiteBackView.bounds.width - 20, height: ButtonHeight - 2 * PADING), title: "", border: false, bgColor: false, textColor: textColorPrime)
        likeButton.addTarget(self, action: #selector(StoresProfileViewController.like_unLikeAction), for: UIControl.Event.touchUpInside)
        likeButton.titleLabel?.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        likeButton.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
        whiteBackView.addSubview(likeButton)
        
        label1 = TTTAttributedLabel(frame:CGRect(x:PADING, y: 10, width: self.mainSubView.bounds.width/2 - PADING , height: 30) )
        label3 = TTTAttributedLabel(frame:CGRect(x:PADING, y: 10, width: self.mainSubView.bounds.width/2 - PADING , height: 30) )
        label1.isHidden = true
        label3.isHidden = true
        
        profileView.addSubview(label1)
        profileView.addSubview(label3)
        
        tabsContainerMenu = UIScrollView(frame: CGRect(x:0, y: getBottomEdgeY(inputView:mainSubView) + 5, width: view.bounds.width, height: ButtonHeight))
        tabsContainerMenu.backgroundColor = TabMenubgColor
        tabsContainerMenu.isHidden = true
        tabsContainerMenu.showsHorizontalScrollIndicator = false
        mainSubView.addSubview(tabsContainerMenu)
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: NSLocalizedString("Pull to Refresh",  comment: ""))
        refresher.addTarget(self, action: #selector(StoresProfileViewController.refresh), for: UIControl.Event.valueChanged)
        productsTableView.addSubview(refresher)
        self.automaticallyAdjustsScrollViewInsets = false
        //view.addSubview(refresher)
        
        
        
        
        /* Edited for Setting Profile image of store and updation */
        
        
        camIconOnCover = createLabel(CGRect(x: coverImage.bounds.width - 70, y: coverImage.bounds.height - 25, width: 20, height: 20), text: "\(cameraIcon)", alignment: .center, textColor: textColorLight)
        camIconOnCover.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        camIconOnCover.isHidden = false
        
        
        
       /*
        if(UIDevice.current.userInterfaceIdiom == .pad){
            memberProfilePhoto = createImageView(CGRect(x: 20, y: coverImage.bounds.height - (5 * contentPADING) - 100, width: 100, height: 100 ), border: true)
        }else{
            memberProfilePhoto = createImageView(CGRect(x: 10, y: coverImage.bounds.height - (5 * contentPADING) - 80, width: 80, height: 80), border: true)
        }
        
        memberProfilePhoto.layer.borderColor = UIColor.white.cgColor
        memberProfilePhoto.layer.borderWidth = 2.5
        memberProfilePhoto.layer.cornerRadius = memberProfilePhoto.frame.size.width / 2
        memberProfilePhoto.backgroundColor = placeholderColor
        memberProfilePhoto.contentMode = UIView.ContentMode.scaleAspectFill
        memberProfilePhoto.layer.masksToBounds = true
        memberProfilePhoto.image = UIImage(named: "user_profile_image.png")
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(StoresProfileViewController.onImageViewTap2))
        memberProfilePhoto.addGestureRecognizer(tap2)
        memberProfilePhoto.tag = 321
        memberProfilePhoto.isUserInteractionEnabled = true
        mainSubView.addSubview(memberProfilePhoto)
        memberProfilePhoto.isHidden = false 
 
        */
        
        camIconOnProfile = createLabel(CGRect(x: (memberProfilePhoto.bounds.width/2) - 15, y: memberProfilePhoto.bounds.height - 30, width: 30, height: 30), text: "\(cameraIcon)", alignment: .center, textColor: textColorLight)
        camIconOnProfile.font = UIFont(name: "fontAwesome", size: FONTSIZELarge)
        camIconOnProfile.layer.shadowColor = shadowColor.cgColor
        camIconOnProfile.layer.shadowOpacity = shadowOpacity
        camIconOnProfile.layer.shadowRadius = shadowRadius
        camIconOnProfile.layer.shadowOffset = shadowOffset
        camIconOnProfile.isHidden = false
   
        let footerView = UIView(frame: frameActivityIndicator)
        footerView.backgroundColor = UIColor.clear
        let activityIndicatorView = NVActivityIndicatorView(frame: frameActivityIndicator, type: .circleStrokeSpin, color: buttonColor, padding: nil)
        activityIndicatorView.center = CGPoint(x:(self.view.bounds.width)/2, y:2.0)
        footerView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        productsTableView.tableFooterView = footerView
        productsTableView.tableFooterView?.isHidden = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.cartButton.customView = cartButtonView(functionOf: self)
        self.navigationItem.setRightBarButtonItems([self.cartButton], animated: false)
        
        if conditionalProfileForm == "browseProduct"
        {
            navigationController?.navigationBar.isHidden = false
            self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
            self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = textColorPrime
        
            if openMenu
            {
                openMenu = false
            }
            IsRedirectToProduct()
        }
        
        if logoutUser == false
        {
            
            let rightNavView = UIView(frame: CGRect(x:0, y: 0, width: 66, height: 44))
            rightNavView.backgroundColor = UIColor.clear
            
            let shareButton = createButton(CGRect(x:0, y: 12, width: 22, height: 22), title: "", border: false, bgColor: false, textColor: UIColor.clear)
            shareButton.setImage(UIImage(named: "upload")!.maskWithColor(color: textColorPrime), for: .normal)
            shareButton.addTarget(self, action: #selector(StoresProfileViewController.shareItem), for: .touchUpInside)
            rightNavView.addSubview(shareButton)
            
            let optionButton = createButton(CGRect(x:27, y: 0, width: 45, height: 45), title: "", border: false, bgColor: false, textColor: UIColor.clear)
            optionButton.setImage(UIImage(named: "option")!.maskWithColor(color: textColorPrime), for: .normal)
            optionButton.addTarget(self, action: #selector(StoresProfileViewController.showGutterMenu), for: .touchUpInside)
            rightNavView.addSubview(optionButton)
            
            self.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
            self.navigationItem.setRightBarButtonItems([self.rightBarButtonItem, self.cartButton], animated: false)
        }
        removeNavigationImage(controller: self)
        
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 40, y: 0, width: navigationBar.frame.width - 180, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.textAlignment = NSTextAlignment.left
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
        }
        
        if storeDetailUpdate == true{
            IsRedirctToVideoProfile(videoTypeCheck : "stores",navigationController:navigationController!, vc: self)
            // Set Default & request to hard Refresh
            storeDetailUpdate = false
            feedUpdate = false
            maxid = 0
            profileView = createView(CGRect(x:PADING,y: getBottomEdgeY(inputView:self.productMoreOrLessView), width: view.bounds.width - 2 * PADING, height: 100), borderColor: borderColorDark, shadow: false)
            profileView.layer.borderWidth = 0.0
            profileView.isHidden = true
            mainSubView.addSubview(profileView)
            
            label1.isHidden = true
            label3.isHidden = true
            showSpinner = true
            
            exploreContent()

        } else {
            if productUpdate == true{
                getStoreProducts()
            }else{
                productsTableView.reloadData()
            }

        }
     
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool)
    {
        productsTableView.tableFooterView?.isHidden = true
        tableViewFrameType = ""
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        self.navigationItem.rightBarButtonItem = nil
        setNavigationImage(controller: self)
    }
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        self.marqueeHeader.text = ""
        removeMarqueFroMNavigaTion(controller: self)
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func IsRedirectToProduct()
    {
        if conditionalProfileForm == "browseProduct"
        {
            conditionalProfileForm = ""
            let presentedVC = ProductProfilePage()
            presentedVC.product_id = "\(productIdReturned!)"
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    @objc func shareItem(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        alertController.addAction(UIAlertAction(title:  String(format: NSLocalizedString("Share on %@", comment: ""),app_title), style: .default) { action -> Void in
            let presentedVC = AdvanceShareViewController()
            presentedVC.param = self.shareParam
            presentedVC.url = self.shareUrl
            presentedVC.Sharetitle = self.shareTitle
            
            if (self.RedirectText != nil) {
                presentedVC.ShareDescription = self.RedirectText
            }
            
            if self.coverImageUrl != nil && self.coverImageUrl != ""{
                presentedVC.imageString = self.coverImageUrl
            }

            presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            let nativationController = UINavigationController(rootViewController: presentedVC)
            self.present(nativationController, animated:true, completion: nil)
            
            })
        
        alertController.addAction(UIAlertAction(title:  NSLocalizedString("Share Outside",comment: ""), style: UIAlertAction.Style.default) { action -> Void in
            
            var sharingItems = [AnyObject]()
            
            if let text = self.contentTitle {
                sharingItems.append(text as AnyObject)
            }
            
            
            if let url = self.contentUrl {
                let finalUrl = NSURL(string: url)!
                sharingItems.append(finalUrl)
            }
            
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
                presentationController?.sourceRect = CGRect(x:self.view.bounds.width/2, y: self.view.bounds.width/2, width: 0, height: 0)
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
            popover?.sourceRect = CGRect(x:view.bounds.width/2,y: view.bounds.height/2 , width: 1, height: 1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func showFullDescription(){
        if self.detailWebView != nil{
            let presentedVC = MLTInfoViewController()
            presentedVC.label1 = self.RedirectText
            navigationController?.pushViewController(presentedVC, animated: true)
        }
    }
    
    // Open Owner's Profile
    @objc func openProfile(){
        if (self.user_id != nil){
            let presentedVC = ContentActivityFeedViewController()
            presentedVC.subjectType = "user"
            presentedVC.subjectId = "\(user_id!)"
            searchDic.removeAll(keepingCapacity: false)
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }
    
    @objc func onImageViewTap(sender:UITapGestureRecognizer){
        
        if isMyStore == true {
            
            let alert1 = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let action1 = UIAlertAction(title: "Upload Cover Image", style: .default, handler: { (action) -> Void in
                
                let presentedVC = EditProfilePhotoViewController()
                presentedVC.currentImageUrl = self.coverImageUrl
                presentedVC.url = "coverphoto/upload-cover-photo/"
                presentedVC.pageTitle = NSLocalizedString("Edit Cover Photo", comment: "")
                presentedVC.contentType = "sitestore_store"
                presentedVC.contentId = "\(self.storeId)"
                presentedVC.showCameraButton = false
                self.navigationController?.pushViewController(presentedVC, animated: false)
                
                
            })
            let action2 = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            let action3 = UIAlertAction(title: "View Image", style: .default, handler: { (action) -> Void in
                
                if self.coverImageUrl != nil && self.coverImageUrl != "" {
                    let presentedVC = SinglePhotoLightBoxController()
                    presentedVC.imageUrl = self.coverImageUrl
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    self.present(nativationController, animated:false, completion: nil)
                }
                
            })
            let action4 = UIAlertAction(title: "Remove Cover Image", style: .destructive, handler: { (action) -> Void in
                
                let alertController = UIAlertController(title: "Remove Cover Image", message: "Are you sure to remove cover image?", preferredStyle: .alert)
                let action11 = UIAlertAction(title: "Remove", style: .destructive, handler: { (action) -> Void in
                    
                    let url = "coverphoto/remove-cover-photo"
                    let subjectId = String(self.storeId)
                    let subjectType = "sitestore_store"
                    self.performPhotoActions(subject_type : subjectType as! String, subject_id : subjectId as! String, url: url as! String, special: "")
                    
                })
                let action22 = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                alertController.addAction(action11)
                alertController.addAction(action22)
                self.present(alertController, animated: true, completion: nil)
            })
            
            alert1.addAction(action1)
            alert1.addAction(action2)
            alert1.addAction(action3)
            alert1.addAction(action4)
            self.present(alert1, animated: false, completion: nil)
            
        }
        
        else
        {
            if self.coverImageUrl != nil
            {
                let presentedVC = SinglePhotoLightBoxController()
                presentedVC.imageUrl = self.coverImageUrl
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)
            }
            
        }
        
        
        
    }
    
    
    @objc func onImageViewTap2(sender:UITapGestureRecognizer){
        
        if isMyStore == true {
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let action1 = UIAlertAction(title: "Upload Profile Image", style: .default, handler: { (action) -> Void in
                
                let presentedVC = EditProfilePhotoViewController()
                presentedVC.currentImageUrl = self.profileImageUrl
                presentedVC.url = "coverphoto/upload-cover-photo/"
                presentedVC.pageTitle = NSLocalizedString("Edit Profile Photo", comment: "")
                presentedVC.contentType = "sitestore_store"
                presentedVC.contentId = "\(self.storeId)"
                presentedVC.special = "profile"
                presentedVC.showCameraButton = true
                self.navigationController?.pushViewController(presentedVC, animated: false)
                
                
            })
            let action2 = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            let action3 = UIAlertAction(title: "View Image", style: .default, handler: { (action) -> Void in
                
                if self.coverImageUrl != nil && self.coverImageUrl != "" {
                    let presentedVC = SinglePhotoLightBoxController()
                    presentedVC.imageUrl = self.profileImageUrl
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    self.present(nativationController, animated:false, completion: nil)
                }
                
            })
            
            let action4 = UIAlertAction(title: "Remove Profile Image", style: .destructive, handler: { (action) -> Void in
                
                
                let alertController = UIAlertController(title: "Remove Profile Image", message: "Are you sure to remove profile image?", preferredStyle: .alert)
                let action11 = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                    
                    let url = "coverphoto/remove-cover-photo"
                    let subjectId = String(self.storeId)
                    let subjectType = "sitestore_store"
                    let special = "profile"
                    self.performPhotoActions(subject_type : subjectType as! String, subject_id : subjectId as! String, url: url as! String, special : special as! String)
                
                })
                let action22 = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                alertController.addAction(action11)
                alertController.addAction(action22)
                self.present(alertController, animated: true, completion: nil)
                
                
            })
            
            alert.addAction(action1)
            alert.addAction(action2)
            alert.addAction(action3)
            alert.addAction(action4)
            self.present(alert, animated: false, completion: nil)
        }
        else
        {
            if self.profileImageUrl != nil
            {
                let presentedVC = SinglePhotoLightBoxController()
                presentedVC.imageUrl = self.profileImageUrl
                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                let nativationController = UINavigationController(rootViewController: presentedVC)
                self.present(nativationController, animated:false, completion: nil)
            }
            
        }

    }
    
    
    // Stop Timer
    @objc func stopTimer()
    {   sitevideoPluginEnabled_store = 0
        stop()
        if popAfterDelay == true
        {
             _ = self.navigationController?.popViewController(animated: false)
        }
        
    }
    
    // FUNCTION TO GET STORE PROFILE DETAILS
    func exploreContent()
    {
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            // Checkin calling
            removeAlert()

//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()

            
            post(["gutter_menu": "1"], url: "/sitestore/view/\(storeId)", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    
                    if msg
                    {
                        // On Success Update Store Detail
                        
                        if let storeDetails = succeeded["body"] as? NSDictionary {
                            if let sitevideoPluginEnabled = storeDetails["sitevideoPluginEnabled"] as? Int
                            {
                                sitevideoPluginEnabled_store = sitevideoPluginEnabled
                            }
                            self.likeButton.setTitleColor(textColorPrime, for: .normal)
                            if storeDetails["is_liked"] as! Int == 1{
                                self.isLike = true
                                self.likeButton.setTitle("Unlike", for: .normal)
                            }else{
                                self.isLike = false
                                self.likeButton.setTitle("Like", for: .normal)
                                
                            }
                            
                            if let like_count = storeDetails["like_count"] as? Int{
                                total_Likes = like_count
                                self.likeStat.text = "\(like_count) \(likeIcon)"
                                
                            }
                        
                            
                            if let menu = storeDetails["gutterMenu"] as? NSArray{
                                self.gutterMenu  = menu
                                print(self.gutterMenu.count)
                                if self.gutterMenu.count < 5
                                {
                                    self.isMyStore = false
                                } else {
                                    self.isMyStore = true
                                }
                                
                                if self.isMyStore == true {
                                    self.coverImage.addSubview(self.camIconOnCover)
                                    self.memberProfilePhoto.addSubview(self.camIconOnProfile)
                                }
                                
                                
                                if let owner_id = storeDetails["owner_id"] as? Int{
                                    self.user_id = owner_id
                                }
                                
                                for tempMenu in self.gutterMenu{
                                    if let tempDic = tempMenu as? NSDictionary{
                                        
                                        if tempDic["name"] as! String == "share" {
                                            self.shareUrl = tempDic["url"] as! String
                                            self.shareParam = tempDic["urlParams"] as! NSDictionary
                                        }
                                    }
                                }
                                
                                
                                
                            }
                            
                            // Update tabContainer Menu
                            if let tabsContainerMenuItems = storeDetails["profileTabs"] as? NSArray
                            {
                                self.storeProfileTabMenu = tabsContainerMenuItems
                                self.tabsContainerMenu.isHidden = false
                            }
                            
                            self.contentUrl =  storeDetails["content_url"] as! String
                            
                            if let response = storeDetails as NSDictionary?
                            {
                                self.shareTitle = response["title"] as? String
                                self.storeId = "\(response["store_id"]!)"
                                self.contentName.font = UIFont(name: fontName, size: FONTSIZEExtraLarge)
                                self.contentName.text = (response["title"] as? String)!
                                //self.contentName.sizeToFit()
                                self.contentTitle = (response["title"] as? String)!
                                
                                
                                self.contentName.lineBreakMode = NSLineBreakMode.byWordWrapping
                                let ownername = response["owner_title"] as? String
                                self.ownerName.text = "By "+ownername!
                                
//                                if let url = NSURL(string: response["owner_image_normal"] as! String){
//
//                                    self.imgUser.kf.indicatorType = .activity
//                                     (self.imgUser.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
//                                    self.imgUser.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
//                                        if let img = image
//                                        {
//                                            self.imgUser.image = imageWithImage(img, scaletoWidth: self.coverImage.bounds.width)
//                                        }
//                                    })
//                                }
                                
                                if let url = NSURL(string: response["image"] as! String){
                                    
                                    self.memberProfilePhoto.kf.indicatorType = .activity
                                    (self.memberProfilePhoto.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                    self.memberProfilePhoto.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                        if let img = image
                                        {
                                            self.memberProfilePhoto.image = imageWithImage(img, scaletoWidth: self.coverImage.bounds.width)
                                        }
                                    })
                                }
                                
                                if let defaultCover = response["default_cover"] as? Int{
                                    
                                    if let profileImage = response["image"] as? String
                                    {
                                        self.profileImageUrl = profileImage
                                    }
                                    //self.profileImageUrl = response["image"] as! String
                                    
                                    if defaultCover == 0
                                    {
                                        if let url1 = response["cover_image"] as? String
                                        {
                                            self.coverImage.contentMode = .scaleAspectFill
                                            self.coverImage.layer.masksToBounds = true
                                            self.coverImageUrl = response["cover_image"] as! String
                                            let url = NSURL(string: url1)
                                            self.coverImage.kf.indicatorType = .activity
                                            (self.coverImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                            self.coverImage.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                
                                                //let ratio = (image?.size.width)!/(image?.size.height)!
                                                //let newHeight = self.coverImage.frame.size.width/ratio
                                                //self.coverImage.frame.size.height = newHeight
                                            })
                                        }
                                        else
                                        {
                                            self.coverImage.image =  imageWithImage( UIImage(named: "nophoto_store_thumb_profile_main.png")!, scaletoWidth: self.coverImage.bounds.width)
                                        }
                                        
                                    }
                                    else
                                    {
                                        self.coverImage.image =  imageWithImage( UIImage(named: "nophoto_store_thumb_profile_main.png")!, scaletoWidth: self.coverImage.bounds.width)
                                        
                                    }
                                    
                                }
                                
                                
                                if let classifiedImages = response["images"] as? NSArray{
                                    self.totalClassifiedImage = classifiedImages
                                    self.totalPhoto = classifiedImages.count
                                    if classifiedImages.count > 1{
                                        
                                        let message = String(format: NSLocalizedString(" \(forwordIcon) \n\n \(classifiedImages.count) \(cameraIcon)", comment: ""), classifiedImages.count)
                                        self.totalPic.isHidden = false
                                        self.totalPic.setText(message, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                            
                                            return mutableAttributedString
                                        })
                                    }else{
                                        self.totalPic.isHidden = true
                                    }
                                    
                                    if classifiedImages.count > 0 {
                                        
                                        
                                        let tempContentImagesDic = classifiedImages[0] as! NSDictionary
                                        if let tempImageString = tempContentImagesDic["image"] as? String {
                                            self.contentImage = tempImageString
                                        }
                                        
                                        var originX = ImageViewPading
                                        for images in classifiedImages {
                                            if let dic = images as? NSDictionary {
                                                let frame = CGRect(x: originX , y: 0, width: self.view.bounds.width, height:270  )
                                                
                                                var welcomeImageView = ClassifiedCoverImageViewWithGradient(frame: frame)
                                                welcomeImageView.tag = self.count
                                                welcomeImageView.isUserInteractionEnabled = true
                                                
                                                let url = NSURL(string:dic["image"] as! String)!
                                                welcomeImageView.kf.indicatorType = .activity
                                                 (welcomeImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                                welcomeImageView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                    
                                                })
                                                welcomeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(StoresProfileViewController.onImageViewTap)))
                                                self.count += 1
                                                
                                            }
                                            originX += self.view.bounds.width
                                        }
                                        
                                    }
                                    
                                }
                                else
                                {
                                    let originX = ImageViewPading
                                    let frame = CGRect(x: originX ,y: 0, width: self.view.bounds.width, height: 270)
                                    
                                    let welcomeImageView = ClassifiedCoverImageViewWithGradient(frame: frame)
                                    welcomeImageView.isUserInteractionEnabled = false
                                    
                                    welcomeImageView.image =  imageWithImage( UIImage(named: "nophoto_store_thumb_profile_main.png")!, scaletoWidth: self.coverImage.bounds.width)
                                    
                                }
                                
                                
                                //MARK: Work for Store description
                                let topicDescription = "\(response["body"] as! String)"
                                self.RedirectText = response["body"] as! String
                                
                                if response["overview"] != nil {
                                    self.webviewText = response["overview"] as! String
                                }
                                
                                self.detailWebView.frame.origin.y = getBottomEdgeY(inputView:self.topView) + 5
                                let lineCount = findHeightByText(topicDescription)
                                
                                self.detailWebView.text = topicDescription.html2String
                                self.detailWebView.font = UIFont(name: fontName, size: FONTSIZENormal)
                                self.detailWebView.textContainer.maximumNumberOfLines = 4
                                self.detailWebView.textContainer.lineBreakMode = NSLineBreakMode.byTruncatingTail
                                self.detailWebView.backgroundColor = textColorLight//aafBgColor
                                self.detailWebView.isHidden = false
                                self.detailWebView.sizeToFit()
                                
                                if lineCount > 4{
                                    self.productMoreOrLess.isHidden = false
                                    self.productMoreOrLessView.isHidden = false
                                    self.productMoreOrLessView.frame.origin.y = getBottomEdgeY(inputView:self.detailWebView)
                                    
                                }
                                else
                                {
                                    self.productMoreOrLessView.frame.size.height = 0.0
                                }
                                
                                //After sizetofit width is again set to cover to view bounds
                                self.detailWebView.frame.size.width = self.view.bounds.width - 2 * PADING
                                // For Showing Check-in Button and count
                                let Pading : CGFloat = getBottomEdgeY(inputView: self.detailWebView) + self.productMoreOrLessView.frame.size.height+10
                                self.mainSubView.isHidden = false
                                self.mainSubView.frame.size.height = Pading
                                
                                
                                
                                self.whiteBackView.frame = CGRect(x:PADING, y: self.mainSubView.frame.size.height + 5, width: self.view.bounds.width - 2 * PADING, height: ButtonHeight)
                                self.likeButton.frame = CGRect(x:10,y: PADING,width: self.whiteBackView.bounds.width - 20, height:ButtonHeight -  2 * PADING)
                                self.likeButton.isHidden = false
                                self.likeButton.backgroundColor = navColor
                                self.likeButton.tag = 62
                                
                                if logoutUser == true{
                                    self.whiteBackView.isHidden = true
                                    self.whiteBackView.frame.size.height = 0
                                }
                                
                                
                                //MARK: Work for showing profile fields
                                
                                if storeDetails["profile_information"] != nil {
                                    
                                    if  let profileFields = storeDetails["profile_information"] as? NSDictionary{
                                        
                                        self.profileView.isHidden = false
                                        self.profileView.frame.origin.y = getBottomEdgeY(inputView:self.whiteBackView) + 10
                                        
                                        var profileFieldString = ""
                                        var profileFieldString2 = ""
                                        var labelKey : String!
                                        var labelDesc : String!
                                        var labelKey2 : String!
                                        var labelDesc2 : String!
                                        var origin_labelheight_y2 : CGFloat = 0
                                        var origin_labelheight_y : CGFloat = 0
                                        
                                        for(key,profileField) in profileFields{
                                            
                                            //MARK: when profile fields is a dictionary
                                            if profileField is NSDictionary{
                                                let titleField = TTTAttributedLabel(frame:CGRect(x:2 * PADING, y: origin_labelheight_y + 5, width: self.view.bounds.width/2 - 2 * PADING, height: 30) )
                                                
                                                titleField.textColor = textColorDark
                                                titleField.delegate = self
                                                titleField.isHidden = false
                                                titleField.backgroundColor = UIColor.white
                                                titleField.font = UIFont(name: fontBold, size: FONTSIZENormal)
                                                titleField.numberOfLines = 0
                                                titleField.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                titleField.isUserInteractionEnabled = true
                                                titleField.setText(key, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                    return mutableAttributedString!
                                                })
                                                
                                                titleField.sizeToFit()
                                                self.profileView.addSubview(titleField)
                                                origin_labelheight_y = origin_labelheight_y + titleField.bounds.height
                                                origin_labelheight_y2 = origin_labelheight_y
                                                
                                                if (profileField as AnyObject).count > 0{
                                                    var loop : Int = 0
                                                    for(k,v) in profileField as! NSDictionary{
                                                        
                                                        if origin_labelheight_y2 > origin_labelheight_y{
                                                            origin_labelheight_y = origin_labelheight_y2
                                                        }
                                                        if v is NSInteger{
                                                            if v as! NSInteger == 0{
                                                                continue
                                                            }
                                                        }else{
                                                            
                                                            if (v as? String) == nil || (v as? String) == ""{
                                                                continue
                                                            }
                                                            
                                                        }
                                                        
                                                        if loop % 2 == 0{
                                                            
                                                            self.label5 = TTTAttributedLabel(frame:CGRect(x:2 * PADING, y:origin_labelheight_y + 5, width: self.view.bounds.width/2 - 2 * PADING, height: 30) )
                                                            self.label5.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
                                                            self.label5.textColor = textColorDark
                                                            self.label5.delegate = self
                                                            self.label5.isHidden = false
                                                            
                                                            labelKey = ((k as? String)! + ": ")
                                                            
                                                            if v is NSInteger {
                                                                labelDesc = "\(v)"
                                                                profileFieldString = labelKey + "\(labelDesc)" + "\n" + "\n"
                                                            }else{
                                                                labelDesc = (v as? String)
                                                                profileFieldString = ((labelKey as String) + (labelDesc as String)) + "\n" + "\n"
                                                            }
                                                            
                                                            self.label5.backgroundColor = UIColor.white
                                                            self.label5.font = UIFont(name: fontName, size: FONTSIZESmall)
                                                            self.label5.numberOfLines = 0
                                                            self.label5.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                            
                                                            let linkColor = UIColor.blue
                                                            let linkActiveColor = UIColor.green
                                                            
                                                            self.label5.linkAttributes = [kCTForegroundColorAttributeName as AnyHashable : linkColor.cgColor,kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: true)]
                                                            self.label5.activeLinkAttributes = [NSAttributedString.Key.foregroundColor : linkActiveColor]
                                                            self.label5.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                                                            self.label5.enabledTextCheckingTypes = NSTextCheckingAllTypes
                                                            self.label5.isUserInteractionEnabled = true
                                                            self.label5.text = profileFieldString
                                                            self.label5.setText(profileFieldString, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                                
                                                                let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                                                                
                                                                let range1 = (profileFieldString as NSString).range(of: labelDesc as String)
                                                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium, range: range1)
                                                                
                                                                
                                                                return mutableAttributedString
                                                            })
                                                            
                                                            self.label5.sizeToFit()
                                                            
                                                            origin_labelheight_y = origin_labelheight_y + self.label5.bounds.height
                                                            
                                                            loop = loop + 1
                                                            self.profileView.addSubview(self.label5)
                                                        }
                                                        else{
                                                            
                                                            loop = loop + 1
                                                            
                                                            self.label6 = TTTAttributedLabel(frame:CGRect(x:self.view.bounds.width/2 + 2 * PADING,y: origin_labelheight_y2 + 5, width: self.profileView.bounds.width/2 - 3 * PADING, height: 30) )
                                                            self.label6.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
                                                            self.label6.textColor = textColorDark
                                                            self.label6.delegate = self
                                                            self.label6.isHidden = false
                                                            
                                                            labelKey2 = ((k as? String)! + ": ") as AnyObject as! String
                                                            
                                                            if v is NSInteger{
                                                                labelDesc2 = "\(v)"
                                                                profileFieldString2 = ((labelKey2 as String) + (labelDesc2 as String)) + "\n" + "\n"
                                                            }
                                                            else{
                                                                labelDesc2 = (v as? String)
                                                                profileFieldString2 = ((labelKey2 as String) + (labelDesc2 as String)) + "\n" + "\n"
                                                            }
                                                            
                                                            self.label6.backgroundColor =  UIColor.white
                                                            self.label6.font = UIFont(name: fontName, size: FONTSIZESmall)
                                                            self.label6.numberOfLines = 0
                                                            self.label6.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                            
                                                            let linkColor = UIColor.blue
                                                            let linkActiveColor = UIColor.green
                                                            
                                                            self.label6.linkAttributes = [kCTForegroundColorAttributeName as AnyHashable : linkColor.cgColor, kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: true)]
                                                            self.label6.activeLinkAttributes = [NSAttributedString.Key.foregroundColor : linkActiveColor]
                                                            self.label6.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                                                            self.label6.enabledTextCheckingTypes = NSTextCheckingAllTypes
                                                            self.label6.isUserInteractionEnabled = true
                                                            self.label6.text = profileFieldString2
                                                            self.label6.setText(profileFieldString2, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                                
                                                                let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                                                                
                                                                let range1 = (profileFieldString2 as NSString).range(of: labelDesc2 as String)
                                                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium, range: range1)
                                                                
                                                                return mutableAttributedString
                                                            })
                                                            
                                                            self.label6.sizeToFit()
                                                            
                                                            origin_labelheight_y2 = origin_labelheight_y2 + self.label6.bounds.height
                                                            
                                                            self.profileView.addSubview(self.label6)
                                                        }
                                                    }
                                                }
                                            }
                                            
                                            //MARK: when profile fields is a string
                                            if profileField is String{
                                                if profileFields.count > 0{
                                                    var loop : Int = 0
                                                    
                                                    if origin_labelheight_y2 > origin_labelheight_y{
                                                        origin_labelheight_y = origin_labelheight_y2
                                                    }
                                                    
                                                    if profileField is NSInteger{
                                                        if profileField as! NSInteger == 0{
                                                            continue
                                                        }
                                                    }else{
                                                        if (profileField as? String) == nil || (profileField as? String) == ""{
                                                            continue
                                                        }
                                                        
                                                    }
                                                    if loop % 2 == 0{
                                                        
                                                        self.label5 = TTTAttributedLabel(frame:CGRect(x:2 * PADING, y: origin_labelheight_y + 5, width: self.view.bounds.width/2 - 2 * PADING, height: 30) )
                                                        
                                                        self.label5.textColor = textColorDark
                                                        self.label5.delegate = self
                                                        self.label5.isHidden = false
                                                        
                                                        labelKey = ((key as? String)! + ": ")
                                                        
                                                        if profileField is NSInteger {
                                                            labelDesc = "\(profileField)"
                                                            profileFieldString = labelKey + "\(labelDesc)" + "\n" + "\n"
                                                        }else{
                                                            labelDesc = (profileField as? String)
                                                            profileFieldString = ((labelKey as String) + (labelDesc as String)) + "\n" + "\n"
                                                        }
                                                        
                                                        
                                                        self.label5.backgroundColor = UIColor.white
                                                        self.label5.font = UIFont(name: fontName, size: FONTSIZENormal)
                                                        self.label5.numberOfLines = 0
                                                        self.label5.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                        
                                                        let linkColor = UIColor.blue
                                                        let linkActiveColor = UIColor.green
                                                        
                                                        self.label5.linkAttributes = [kCTForegroundColorAttributeName as AnyHashable : linkColor.cgColor,kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: true)]
                                                        self.label5.activeLinkAttributes = [NSAttributedString.Key.foregroundColor : linkActiveColor]
                                                        self.label5.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                                                        self.label5.enabledTextCheckingTypes = NSTextCheckingAllTypes
                                                        self.label5.isUserInteractionEnabled = true
                                                        self.label5.text = profileFieldString
                                                        self.label5.setText(profileFieldString , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                            
                                                            let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                                                            
                                                            let range1 = (profileFieldString as NSString).range(of: labelDesc as String)
                                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                                                            
                                                            
                                                            return mutableAttributedString
                                                        })
                                                        
                                                        self.label5.sizeToFit()
                                                        origin_labelheight_y  = origin_labelheight_y + self.label5.bounds.height
                                                        loop = loop + 1
                                                        self.profileView.addSubview(self.label5)
                                                    }
                                                    else{
                                                        
                                                        loop = loop + 1
                                                        
                                                        self.label6 = TTTAttributedLabel(frame:CGRect(x:self.view.bounds.width/2 + 2 * PADING, y: origin_labelheight_y2 + 5, width: self.profileView.bounds.width/2 - 3 * PADING, height: 30) )
                                                        self.label6.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
                                                        self.label6.textColor = textColorDark
                                                        self.label6.delegate = self
                                                        self.label6.isHidden = false
                                                        
                                                        labelKey2 = ((key as? String)! + ": ") as AnyObject as! String
                                                        
                                                        if profileField is NSInteger{
                                                            labelDesc2 = "\(profileField)"
                                                            profileFieldString2 = ((labelKey2 as String) + (labelDesc2 as String)) + "\n" + "\n"
                                                        }
                                                        else{
                                                            labelDesc2 = (profileField as? String)
                                                            profileFieldString2 = ((labelKey2 as String) + (labelDesc2 as String)) + "\n" + "\n"
                                                        }
                                                        
                                                        self.label6.backgroundColor =  UIColor.white
                                                        self.label6.font = UIFont(name: fontName, size: FONTSIZENormal)
                                                        self.label6.numberOfLines = 0
                                                        self.label6.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                        
                                                        let linkColor = UIColor.blue
                                                        let linkActiveColor = UIColor.green
                                                        
                                                        
                                                        self.label6.linkAttributes = [kCTForegroundColorAttributeName as AnyHashable : linkColor.cgColor,kCTUnderlineStyleAttributeName as AnyHashable : NSNumber(value: true)]
                                                        self.label6.activeLinkAttributes = [NSAttributedString.Key.foregroundColor : linkActiveColor]
                                                        self.label6.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                                                        self.label6.enabledTextCheckingTypes = NSTextCheckingAllTypes
                                                        self.label6.isUserInteractionEnabled = true
                                                        
                                                        
                                                        self.label6.text = profileFieldString2
                                                        self.label6.setText(profileFieldString2, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                            
                                                            let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                                                            
                                                            let range1 = (profileFieldString2 as NSString).range(of: labelDesc2 as String)
                                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium, range: range1)
                                                            
                                                            
                                                            return mutableAttributedString
                                                        })
                                                        
                                                        self.label6.sizeToFit()
                                                        origin_labelheight_y2 = origin_labelheight_y2 + self.label6.bounds.height
                                                        self.profileView.addSubview(self.label6)
                                                    }
                                                }
                                            }
                                        }
                                        
                                        if origin_labelheight_y2 > origin_labelheight_y{
                                            
                                            self.profileView.frame.size.height = origin_labelheight_y2 + 5
                                            
                                        }
                                        else{
                                            self.profileView.frame.size.height = origin_labelheight_y + 5
                                            
                                        }
                                    }
                                }
                                else
                                {
                                    
                                    self.profileView.isHidden  = true
                                    self.profileView.frame.origin.y = getBottomEdgeY(inputView:self.whiteBackView) + 5
                                    self.profileView.frame.size.height = 0
                                }
                                
                                self.likeButton.frame = CGRect(x:5, y: PADING, width: self.whiteBackView.bounds.width - 2 * 5, height: ButtonHeight-PADING)
                                self.likeButton.isHidden = false
                                self.likeButton.backgroundColor = navColor
                                self.likeButton.tag = 62

                                self.mainSubView.frame.size.height = self.whiteBackView.frame.origin.y + self.whiteBackView.bounds.height + 5
                                
                                self.showtabMenu()
                                self.tabsContainerMenu.isHidden = false
                                self.tabsContainerMenu.frame.origin.y = getBottomEdgeY(inputView:self.profileView) + 5
                                self.mainSubView.frame.size.height = getBottomEdgeY(inputView:self.tabsContainerMenu) + 5
                                self.headerHeight = self.mainSubView.frame.size.height + 5
                                
                                self.getStoreProducts()
                                //self.productsTableView.tableHeaderView = self.mainSubView
                                self.productsTableView.reloadData()
                            }
                            
                        }
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                    }else{
                        // Handle Server Error
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            let message = succeeded["message"] as? String
                            if message == "You do not have the access of this page."
                            {
                                self.popAfterDelay = true
                                self.createTimer(self)
                                
                            }
                        }
                    }
                })
                
            }
        }else{
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
        }
        
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    // MARK: - Activity Feed functions
    
    func getStoreProducts(){
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork()
        {
            
            removeAlert()
            
            for ob in self.productsTableView.subviews{
                if ob.tag == 1000{
                    ob.removeFromSuperview()
                }
            }
            
            for ob in view.subviews{
                if ob.tag == 2000{
                    ob.removeFromSuperview()
                }
            }
            
            self.storeProducts.removeAll(keepingCapacity: false)
            
            // Check for Show Spinner Position for Request
            if (showSpinner){
                activityIndicatorView.center = view.center
                if updateScrollFlag == false {
                    activityIndicatorView.center = CGPoint(x: view.center.x, y: view.bounds.height-85 - (tabBarHeight / 4))
                }
//                spinner.hidesWhenStopped = true
//                spinner.style = UIstyle.gray
//                self.view.addSubview(spinner)
                self.view.addSubview(activityIndicatorView)
            //    activityIndicatorView.center = self.view.center
                activityIndicatorView.startAnimating()
            }
            
            // Set Parameters & Path for Activity Feed Request
            var parameters = [String:String]()
            parameters = ["limit": "\(limit)"]
            
            // Set userinteractionflag for request
            userInteractionOff = false
            
            // Send Server Request for Activity Feed
            post(parameters, url: "sitestore/product/index/\(storeId)", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    
                    // Reset Object after Response from server
                    userInteractionOff = true
                    if self.showSpinner{
                        activityIndicatorView.stopAnimating()
                    }else{
                        self.refresher.endRefreshing()

                    }
                    self.showSpinner = false
                    
                    // On Success Show Store Products
                    if msg{
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        if let response = succeeded["body"] as? NSDictionary{
                            
                            if response["response"] != nil {
                                if let product = response["response"] as? NSArray {
                                    self.storeProducts = self.storeProducts + (product as [AnyObject])
                                    if response["currency"] != nil{
                                        self.currency = response["currency"] as! String
                                    }
                                }
                                
                                self.productsTableView.layoutIfNeeded()
                                self.productsTableView.reloadData()
                            }
                            
                            if self.storeProducts.count == 0
                            {
                                self.info  = createLabel(CGRect(x:0, y: self.tabsContainerMenu.frame.origin.y + ButtonHeight + 10, width: self.view.bounds.width, height: 50), text: NSLocalizedString("No updates at this moment . Check again any \nother time.",  comment: "") , alignment: .center, textColor: textColorMedium)
                                self.info.backgroundColor = .white
                                self.info.tag = 1000
                                self.info.textAlignment = .center
                                self.info.numberOfLines = 2
                                self.productsTableView.addSubview(self.info)
                                self.info.isHidden = false
                                self.info.font = UIFont(name: fontName, size: FONTSIZENormal)
                            }
                        }
                    }else{
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        
                        self.updateScrollFlag = true
                    }
                })
            }
        }else{
            
            // No Internet Connection Message
            showToast(message: network_status_msg, controller: self)
            
        }
    }
    
    func showtabMenu(){
        
        for ob in tabsContainerMenu.subviews{
            if ob.tag == 1001{
                ob.removeFromSuperview()
            }
        }
        
        var origin_x:CGFloat = 0
        for menu in storeProfileTabMenu{
            if let menuItem = menu as? NSDictionary{
                
                if menuItem["name"] as! String != "update"{
                    
                    var button_title = menuItem["label"] as! String
                    if let totalItem = menuItem["totalItemCount"] as? Int{
                        if totalItem > 0{
                            button_title += " (\(totalItem))"
                        }
                    }
                    let button_name = menuItem["name"] as! String
                    
                    let width = findWidthByText(button_title) + 10
                    
                    let menu = createButton(CGRect(x:origin_x, y: 0, width: width, height: tabsContainerMenu.bounds.height), title: button_title, border: false, bgColor: false, textColor: textColorDark)
                    menu.titleLabel?.font = UIFont(name: fontName, size: FONTSIZENormal)
                    menu.tag = 1001
                    menu.addTarget(self, action: #selector(StoresProfileViewController.tabMenuAction), for: .touchUpInside)
                    tabsContainerMenu.addSubview(menu)
                    origin_x += width
                    
                    if button_name == "products"{
                        menu.setTitleColor(textColorDark, for: .normal)
                    }
                    else{
                        menu.setTitleColor(textColorMedium, for: .normal)
                    }
                    
                }
                
            }
        }
        
        tabsContainerMenu.contentSize = CGSize(width: origin_x, height: tabsContainerMenu.bounds.height)
        
    }
    
    @objc func tabMenuAction(sender:UIButton){
        
        for menu in storeProfileTabMenu{
            if let menuItem = menu as? NSDictionary{
                
                var button_title = menuItem["label"] as! String
                
                // if button_title != "Fourms Posts" {
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                
                if sender.titleLabel?.text == button_title{
                    if menuItem["name"] as! String == "information"{
                        
                        let presentedVC = UserInfoViewController()
                        presentedVC.contentId = "\(storeId)"
                        presentedVC.user_id = "\(user_id!)"
                        presentedVC.contentUrl = menuItem["url"] as! String
                        navigationController?.pushViewController(presentedVC,animated:true)
                    }
                    
                    if menuItem["name"] as! String == "overview"{
                        
                        if self.detailWebView != nil{
                            let presentedVC = OverViewViewController()
                            presentedVC.label1 = self.webviewText
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                    }
                    
                    if menuItem["name"] as! String == "video"{
                        
                        if sitevideoPluginEnabled_store == 1
                        {
                            let presentedVC = AdvanceVideoViewController()
                            presentedVC.user_id = "\(storeId)"
                            presentedVC.fromTab = true
                            presentedVC.showOnlyMyContent = false
                            presentedVC.countListTitle = button_title
                            presentedVC.other_module = true
                            presentedVC.videoTypeCheck = "stores"
                            presentedVC.url = menuItem["url"] as! String//"advancedvideos/index/\(self.storeId)"
                            presentedVC.subject_type = menuItem["subject_type"] as! String
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }
                        else
                        {
                            let presentedVC = VideoBrowseViewController()
                            presentedVC.showOnlyMyContent = true
                            presentedVC.url = menuItem["url"] as! String
                            presentedVC.videoTypeCheck = "stores"
                            presentedVC.listingId = "\(storeId)"
                            presentedVC.fromTab = true
                            presentedVC.countListTitle =  button_title
                            
                            navigationController?.pushViewController(presentedVC, animated: true)
                        }

                    }
                    
                    if menuItem["name"] as! String == "advevents"{
                        let presentedVC = AdvancedEventViewController()
                        presentedVC.showOnlyMyContent = true
                        presentedVC.sitegroupCheck = "sitestore"
                        if menuItem["totalItemCount"] as? Int != nil {
                            presentedVC.eventCount = menuItem["totalItemCount"] as! Int
                        }
                        if let dic1 = menuItem["urlParams"] as? NSDictionary{
                            presentedVC.user_id = "\(dic1["subject_id"]!)"
                        }
                        presentedVC.fromTab = true
                        
                        
                        navigationController?.pushViewController(presentedVC, animated: false)
                    }
                    
                    if menuItem["name"] as! String == "reviews"
                    {
                        let presentedVC = PageReviewViewController()
                        presentedVC.mytitle = String(contentTitle!)
                        presentedVC.subjectId = "\(storeId)"
                        presentedVC.contentType = "sitestore_store"
                        
                        if let totalItem = menuItem["count"] as? Int
                        {
                            if totalItem > 0
                            {
                                presentedVC.currentReviewcount = totalItem
                            }
                            
                        }
                        
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                    }
                    
                    if menuItem["name"] as! String == "photos"{
                        let presentedVC = AlbumViewController()
                        presentedVC.contentType = "sitestore_photo"
                        presentedVC.countListTitle = button_title
                        presentedVC.showOnlyMyContent = true
                        let tempUrl = menuItem["url"] as! String
                        presentedVC.path = tempUrl
                        presentedVC.user_id = "\(user_id!)"
                        presentedVC.fromTab = true
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                        
                    }
                    
                    if menuItem["name"] as! String == "coupons"{
                        let presentedVC = CouponsBrowseViewController()
                        presentedVC.showOnlyMyContent = true
                        presentedVC.content_id = "\(self.storeId)"
                        presentedVC.countListTitle = "Coupons"
                        presentedVC.fromStore = false
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                        
                    }
                }
            }
        }
    }
    
    @objc func goBack(){
        sitevideoPluginEnabled_store = 0
        if conditionalProfileForm == "BrowsePage"
        {
            storeUpdate = true
            storeDetailUpdate = true
            _ = self.navigationController?.popToRootViewController(animated: false)
        }
        else if conditionalProfileForm == "BrowseMyStore"
        {
            
            let pv = StoresBrowseViewController()
            pv.showOnlyMyContent = false
            self.navigationController?.pushViewController(pv, animated: true)
            
            /*storeUpdate = true
            self.dismiss(animated: false, completion: nil)
            //self.navigationController?.popToViewController(StoresBrowseViewController, animated: false)
            //_ =  self.navigationController?.popToRootViewController(animated: false) */
        }
        else
        {
            storeUpdate = true
            storeDetailUpdate = true
             _ = self.navigationController?.popViewController(animated: false)
        }
    }
    
    @objc func refresh(){
        
        DispatchQueue.main.async(execute:  {
            soundEffect("Activity")
        })
        
        // Check Internet Connectivity
        if Reachabable.isConnectedToNetwork() {
            
            searchDic.removeAll(keepingCapacity: false)
            showSpinner = false
            updateAfterAlert = false
            exploreContent()
            
        }else{
            
            // No Internet Connection Message
            refresher.endRefreshing()
            showToast(message: network_status_msg, controller: self)
        }
    }
    
    @objc func showGutterMenu(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        deleteContent = false
        let confirmationTitle = ""
        let message = ""
        var url = ""
        var confirmationAlert = true
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                
                var params = Dictionary<String, AnyObject>()
//                if dic["name"] as! String == "videoCreate"{
//                    continue
//                }
                
                if dic["name"] as! String != "share"{
                    
                    let titleString = dic["name"] as! String
                    
                    if titleString.range(of: "delete") != nil{
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                            
                            let condition = dic["name"] as! String
                            switch(condition){
                                
                            case "delete":
                                
                                displayAlertWithOtherButton(NSLocalizedString("Delete Entry", comment: ""),message: NSLocalizedString("Are you sure you want to delete this store?",comment: "") , otherButton: NSLocalizedString("Delete Store", comment: "")) { () -> () in
                                    self.deleteStoreEntry = true
                                    self.performStoreMenuAction(params: params as NSDictionary, url: dic["url"] as! String)
                                }
                                
                                self.present(alert, animated: true, completion: nil)
                                
                            default:
                                
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                        }))
                    }else{
                        
                        alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.default, handler:{ (action) -> Void in
                            // Write For Edit Album Entry
                            let condition = dic["name"] as! String
                            switch(condition){
                                
                            case "videoCreate" :
                                isCreateOrEdit = true
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Add New Video", comment: "")
                                presentedVC.contentType = "Advanced Video"
                                if sitevideoPluginEnabled_store == 1
                                {
                                    let subject_type = dic["subject_type"] as! String
                                    let subject_id =   dic["subject_id"] as! Int
                                    presentedVC.param = ["subject_id":"\(subject_id)","subject_type" :"\(subject_type)" ]
                                }
                                url = dic["url"] as! String
                                presentedVC.url = url
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                            case "create" :
                                
                                if dynamicEventPackageEnabled == 1
                                {
                                    isCreateOrEdit = true
                                    let presentedVC = PackageViewController()
                                    presentedVC.contentType = "advancedevents"
                                    presentedVC.url = "advancedevents/packages"
                                    presentedVC.extensionParam = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                    url = dic["url"] as! String
                                    presentedVC.extensionUrl = url
                                    presentedVC.eventExtensionCheck = true
                                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                    let nativationController = UINavigationController(rootViewController: presentedVC)
                                    self.present(nativationController, animated:false, completion: nil)
                                    
                                }
                                else{
                                
                                isCreateOrEdit = true
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = dic["label"] as! String
                                presentedVC.contentType = "advancedevents"
                                presentedVC.eventExtensionCheck = true
                                presentedVC.param = (dic["urlParams"] as! NSDictionary) as! [AnyHashable : Any] as NSDictionary
                                url = dic["url"] as! String
                                presentedVC.url = url
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                }
                                
                            case "tellafriend":
                                
                                confirmationAlert = false
                                let presentedVC = TellAFriendViewController();
                                url = dic["url"] as! String
                                presentedVC.url = url
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                                
                            case "report":
                                confirmationAlert = false
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = dic["urlParams"] as! NSDictionary
                                presentedVC.url = dic["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                                
                            case "create_review":
                                
                                confirmationAlert = false
                                isCreateOrEdit = true
                                globFilterValue = ""
                                
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Write a Review", comment: "")
                                presentedVC.contentType = "Review"
                                presentedVC.param = [:]
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                                
                            case "update_review":
                                
                                isCreateOrEdit = false
                                globFilterValue = ""
                                confirmationAlert = false
                                
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Update Review", comment: "")
                                presentedVC.contentType = "Review"
                                
                                let tempDic = NSDictionary()
                                presentedVC.param = tempDic
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                                
                            case "close":
                                
                                confirmationAlert = false
                                Reload = "Not Refresh"
                                let params = ["close": 1]
                                self.performStoreMenuAction(params: params as NSDictionary, url: dic["url"] as! String)
                                
                                
                                
                            case "open":
                                
                                confirmationAlert = false
                                Reload = "Not Refresh"
                                let params = ["close": 0]
                                self.performStoreMenuAction(params: params as NSDictionary, url: dic["url"] as! String)
                                
                            case "subscribe":
                                
                                Reload = "Not Refresh"
                                confirmationAlert = false
                                var message = ""
                                let title = dic["label"] as! String
                                message = String(format: NSLocalizedString("You have successfully subscribed to %@!", comment: ""), title)
                                params["message"] = message as AnyObject?
                                self.performStoreMenuAction(params: params as NSDictionary, url: dic["url"] as! String)
                                
                            case "unsubscribe":
                                
                                Reload = "Not Refresh"
                                confirmationAlert = false
                                var message = ""
                                let title = dic["label"] as! String
                                message = String(format: NSLocalizedString("You have successfully unsubscribed to %@!", comment: ""), title)
                                params["message"] = message as AnyObject?
                                self.performStoreMenuAction(params: params as NSDictionary, url: dic["url"] as! String)
                                
                            case "claim":
                                
                                confirmationAlert = false
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Claim Store", comment: "")
                                presentedVC.contentType = "Listings claim"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)

                                
                            case "share":
                                
                                let presentedVC = AdvanceShareViewController()
                                presentedVC.param = dic["urlParams"] as! NSDictionary
                                presentedVC.url = dic["url"] as! String
                                presentedVC.Sharetitle = self.shareTitle
                                presentedVC.ShareDescription = self.detailWebView.text
                                presentedVC.imageString = self.coverImageUrl
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                                
                            case "invite":
                                confirmationAlert = false
                                let presentedVC = InviteMemberViewController()
                                presentedVC.contentType = "\(self.subjectType)"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.param = Dictionary<String, String>() as NSDictionary? //menuItem["urlParams"] as! NSDictionary
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                            case "payment_method":
                                
                                let alert = UIAlertController(title: "Password", message: "Please Enter your login Password", preferredStyle: .alert)
                                alert.addTextField { (textField : UITextField!) -> Void in
                                    textField.placeholder = "Enter Login Password"
                                }
                                let action1 = UIAlertAction(title: "OK", style:UIAlertAction.Style.default, handler: { (action) -> Void in
                                    
                                    let firstTextField = alert.textFields![0] as UITextField
                                    let firstValue = firstTextField.text
                                    
                                    let presentedVC = AddPaymentMethodViewController()
                                     presentedVC.password = firstValue!
                                     presentedVC.storeId = String(self.storeId)
                                     let nativationController = UINavigationController(rootViewController: presentedVC)
                                     self.present(nativationController, animated: false, completion: nil)
                                    
                                    
                                })
                                let action2 = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: nil)
                                
                                alert.addAction(action1)
                                alert.addAction(action2)
                                
                                self.present(alert, animated: false, completion: nil)
                                    
                            case "shipping_method":
                                
                                
                                 let presentedVC = PackageViewController()
                                 presentedVC.contentType = "shippingMethod"
                                 presentedVC.storeID = String(self.storeId)
                                 presentedVC.url = dic["url"] as! String
                                 presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                 let nativationController = UINavigationController(rootViewController: presentedVC)
                                 self.present(nativationController, animated:false, completion: nil)

 
                                
                            case "edit_store":
                                
                                
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Edit Store", comment: "")
                                presentedVC.contentType = "editStore"
                                isCreateOrEdit = false
                                presentedVC.url = dic["url"] as! String
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated: false, completion: nil)
                            
                            case "add_product":
                                
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Select Product Type ", comment: "")
                                presentedVC.contentType = "productType"
                                isCreateOrEdit = true
                                presentedVC.url = "sitestore/product/create"
                                presentedVC.storeId = String(self.storeId)
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated: false, completion: nil)
                                
                                /*let alert = UIAlertController(title: "Message", message: "Sorry this feature has not been setup for Now", preferredStyle: .alert)
                                alert.addAction(self.productAction)
                                self.present(alert, animated: false, completion: nil) */
                                
                            case "package_payment":
                                
                                let presentedVC = ExternalWebViewController()
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let navigationController = UINavigationController(rootViewController: presentedVC)
                                self.present(navigationController, animated: true, completion: nil)
                                
                            case "upgrade_package":
                                let presentedVC = PackageViewController()
                                presentedVC.contentType = "listings"
                                presentedVC.url = dic["url"] as! String
                                presentedVC.urlParams = dic["urlParams"] as! NSDictionary
                                presentedVC.isUpgradePackageScreen = true
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            default:
                                showToast(message: unconditionalMessage, controller: self)
                                
                            }
                            
                            if confirmationAlert == true {
                                displayAlertWithOtherButton(confirmationTitle, message: message, otherButton: confirmationTitle) { () -> () in
                                }
                                self.present(alert, animated: true, completion: nil)
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
            popover?.sourceRect = CGRect(x:view.bounds.width/2,y: view.bounds.height/2 , width: 1, height:1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func performStoreMenuAction(params: NSDictionary, url: String){
        
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
            
            for (key, value) in params{
                
                if let id = value as? NSNumber {
                    dic["\(key)"] = String(id as! Int)
                }
                
                if let receiver = value as? NSString {
                    dic["\(key)"] = receiver as String
                }
            }
            
            var method:String
            
            if url.range(of:"delete") != nil{
                method = "DELETE"
            }else{
                method = "POST"
            }
            
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute:  {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                            
                        }
                        
                        if self.deleteStoreEntry == true{
                            sitevideoPluginEnabled_store = 0
                            storeUpdate = true
                             _ = self.navigationController?.popViewController(animated: false)
                            
                            return
                        }
                        self.exploreContent()
                        
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
            showAlertMessage(centerPoint: view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    // Stop Detail or Overview Editing
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    // Generate Custom Alert Messages
    func showAlertMessage( centerPoint: CGPoint, msg: String , timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
           self.createTimer(self)
        }
    }
    
    // MARK:  UITableViewDelegate & UITableViewDataSource
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        
        if (limit*pageNumber < totalItems)
        {
            
            return 0
            
        }
        else
        {
            return 0.00001
        }
    }
    
    // Change Height for header section
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.001
        //return getBottomEdgeY(inputView: mainSubView)
    }
    
    // Change height of row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 240
    }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return Int(ceil(Float(storeProducts.count)/2))
    }
    
    // Set Cell of TabelView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let row = indexPath.row as Int
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! ProductTableViewCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.backgroundColor = bgColor
        var index:Int!
        
        index = row * 2
        
        if storeProducts.count > index {
            
            cell.contentSelection.isHidden = false
            cell.classifiedImageView.isHidden = false
            cell.classifiedName.isHidden = false
            cell.ratings.isHidden = false
            cell.classifiedImageView.image = nil
            
            if let productInfo = storeProducts[index] as? NSDictionary {
                // LHS
                if let url = NSURL(string: productInfo["image"] as! String){
                    cell.classifiedImageView.kf.indicatorType = .activity
                     (cell.classifiedImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.classifiedImageView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                    
                }
                if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                    cell.featuredLabel.isHidden = false
                }else{
                    cell.featuredLabel.isHidden = true
                }
                
                if productInfo["sponsored"] != nil && productInfo["sponsored"] as! Int == 1{
                    
                    cell.sponsoredLabel.frame = CGRect(x:0,y: 0,width: 70,height: 20)
                    if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                        cell.sponsoredLabel.frame = CGRect(x:0,y: 25, width:70, height: 20)
                    }
                    cell.sponsoredLabel.isHidden = false
                }else{
                    cell.sponsoredLabel.isHidden = true
                }
                
                var title = productInfo["title"] as! String
                if title.length > 30{
                    title = (title as NSString).substring(to: 30-3)
                    title  = title + "..."
                }
                
                cell.classifiedName.text = title
                
                cell.classifiedName.sizeToFit()
                cell.classifiedName.frame.size.width =  cell.descriptionView1.bounds.width-10
                cell.ratings.frame.origin.y = cell.classifiedName.frame.size.height + cell.classifiedName.frame.origin.y + 5
                
                if let rating = productInfo["rating_avg"] as? Int
                {
                    cell.updateRating(rating: rating, ratingCount: rating)
                } else {
                    cell.updateRating(rating: 0, ratingCount: 0)
                }
                
                cell.actualPrice.frame.origin.y = getBottomEdgeY(inputView:cell.ratings)
                cell.discountedPrice.frame.origin.y = getBottomEdgeY(inputView:cell.ratings)
                
                
                cell.contentSelection.tag = index as Int
                cell.contentSelection.addTarget(self, action: #selector(StoresProfileViewController.showProduct), for: .touchUpInside)
                
                if logoutUser == false{
                    
                    
                    if let menu = productInfo["menu"] as? NSArray{
                        for menuitem in menu{
                            
                            let menuitem = menuitem as! NSDictionary
                            
                            if menuitem["name"] as! String == "wishlist"{
                                
                                cell.menu.isHidden = false
                                cell.menu.tag = index as Int
                                cell.menu.addTarget(self, action:#selector(StoresProfileViewController.addToWishlist) , for: .touchUpInside)
                                if let _ = productInfo["wishlist"] as? NSArray{
                                    cell.menu.setTitleColor(UIColor.red, for: .normal)
                                }
                                else{
                                    cell.menu.setTitleColor(textColorLight, for: .normal)
                                }
                                
                            }
                        }
                    }
                }
                var totalView = ""
                if let information = productInfo["information"] as? NSDictionary{
                    if let price = information["price"] as? NSDictionary{
                        if let discount = price["discount"] as? CGFloat{
                            if discount == 1{
                                
                                if let productType = productInfo["product_type"] as? String{
                                    if productType == "grouped"{
                                        
                                        cell.actualPrice.text = NSLocalizedString("Start at:", comment: "")
                                        cell.actualPrice.sizeToFit()
                                    }
                                    else{
                                        if let views = price["discounted_amount"] as? Double{
                                            cell.discountedPrice.isHidden = false
                                            cell.discountedPrice.frame.origin.x = 5
                                            let formatter = NumberFormatter()
                                            formatter.numberStyle = .currency
                                            formatter.locale = NSLocale.current // This is the default
                                            formatter.currencyCode = "\(currency)"
                                            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                                let defaults = UserDefaults.standard
                                                if let name = defaults.object(forKey: "Currency")
                                                {
                                                    let price = gettwoFractionDigits(FractionDigit: "\(views)")
                                                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                                    let showPrice = (String(format:"%.2f", changePrice))
                                                    
                                                    totalView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                                    
                                                }
                                            }
                                            else{
                                                totalView += formatter.string(from: NSNumber(value: views))!
                                            }
                                           // totalView += formatter.string(from: NSNumber(value: views))! // $123"
                                            if let signValue = price["sign"] as? Int{
                                                if signValue == 1{
                                                    cell.discountedPrice.text = "\(totalView)*"
                                                }
                                                else{
                                                    cell.discountedPrice.text = "\(totalView)"
                                                }
                                            }
                                            else{
                                                cell.discountedPrice.text = "\(totalView)"
                                            }
                                            cell.discountedPrice.sizeToFit()
                                        }
                                    }
                                }
                                if let ratingAvg = price["price"] as? Double{
                                    
                                    cell.actualPrice.isHidden = false
                                    cell.actualPrice.frame.origin.x =  getRightEdgeX(inputView: cell.discountedPrice) + 5
                                    var ratingView = ""
                                    let formatter = NumberFormatter()
                                    formatter.numberStyle = .currency
                                    formatter.locale = NSLocale.current // This is the default
                                    formatter.currencyCode = "\(currency)"
                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                        let defaults = UserDefaults.standard
                                        if let name = defaults.object(forKey: "Currency")
                                        {
                                            let price = gettwoFractionDigits(FractionDigit: "\(ratingAvg)")
                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                            let showPrice = (String(format:"%.2f", changePrice))
                                            
                                            ratingView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                            
                                        }
                                    }
                                    else{
                                        ratingView += formatter.string(from: NSNumber(value: ratingAvg))!
                                    }
                                   // ratingView += formatter.string(from: NSNumber(value: ratingAvg))! // $123"
                                    cell.actualPrice.text = "\(ratingView)"
                                    cell.actualPrice.sizeToFit()
                                    cell.actualPrice.frame.size.width = cell.actualPrice.bounds.width
                                    let viewBorder = UIView(frame:CGRect(x:0, y: 6, width: cell.actualPrice.frame.size.width, height: 1))
                                    viewBorder.backgroundColor = UIColor.black
                                    viewBorder.tag = 1002
                                    cell.actualPrice.addSubview(viewBorder)
                                    
                                }
                                
                            }
                            else{
                                cell.discountedPrice.isHidden = true
                                for ob in cell.actualPrice.subviews{
                                    if ob.tag == 1002 {
                                        ob.removeFromSuperview()
                                    }
                                    
                                    
                                }
                                if let views = price["price"] as? Double{
                                    cell.actualPrice.frame.origin.x = 5
                                    cell.actualPrice.isHidden = false
                                    let formatter = NumberFormatter()
                                    formatter.numberStyle = .currency
                                    formatter.locale = NSLocale.current // This is the default
                                    formatter.currencyCode = "\(currency)"
                                    
                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                        let defaults = UserDefaults.standard
                                        if let name = defaults.object(forKey: "Currency")
                                        {
                                            let price = gettwoFractionDigits(FractionDigit: "\(views)")
                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                            let showPrice = (String(format:"%.2f", changePrice))
                                            
                                            totalView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                            
                                        }
                                    }
                                    else{
                                        totalView += formatter.string(from: NSNumber(value: views))!
                                    }
                                    
                                   // totalView += formatter.string( from: NSNumber(value: views))! // $123"
                                    if let productType = productInfo["product_type"] as? String{
                                        if productType == "grouped"{
                                            if let signValue = price["sign"] as? Int{
                                                if signValue == 1{
                                                    cell.actualPrice.text = String(format: NSLocalizedString("Start at: %@*", comment: ""),"\(totalView)")
                                                    
                                                }
                                                else{
                                                    cell.actualPrice.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                }
                                            }
                                            else{
                                                cell.actualPrice.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                
                                            }
                                        }
                                        else{
                                            
                                            if let signValue = price["sign"] as? Int{
                                                if signValue == 1{
                                                    cell.actualPrice.text = "\(totalView)*"
                                                }
                                                else{
                                                    cell.actualPrice.text = "\(totalView)"
                                                }
                                            }
                                            else{
                                                cell.actualPrice.text = "\(totalView)"
                                            }
                                            
                                        }
                                    }
                                    cell.actualPrice.sizeToFit()
                                }
                                
                            }
                            
                            
                        }
                    }
                }
                
                
            }
        } else {
            cell.contentSelection.isHidden = true
            cell.classifiedImageView.isHidden = true
            cell.classifiedName.isHidden = true
            cell.ratings.isHidden = true
            cell.discountedPrice.isHidden = true
            cell.actualPrice.isHidden = true
            cell.descriptionView.isHidden = true
            
            cell.contentSelection1.isHidden = true
            cell.productImageView1.isHidden = true
            cell.classifiedName1.isHidden = true
            cell.ratings1.isHidden = true
            cell.descriptionView1.isHidden = true
            cell.discountedPrice1.isHidden = true
            cell.actualPrice1.isHidden = true
        }
        
        if storeProducts.count > (index + 1){
            
            cell.contentSelection1.isHidden = false
            cell.productImageView1.isHidden = false
            cell.classifiedName1.isHidden = false
            cell.ratings1.isHidden = false
            cell.descriptionView1.isHidden = false
            cell.discountedPrice1.isHidden = false
            cell.actualPrice1.isHidden = false
            cell.productImageView1.image = nil
            
            if let productInfo = storeProducts[index + 1] as? NSDictionary {
                
                if let url = NSURL(string: productInfo["image"] as! String){
                    cell.productImageView1.kf.indicatorType = .activity
                    (cell.productImageView1.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                    cell.productImageView1.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                        
                    })
                }
                if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                    cell.featuredLabel1.isHidden = false
                }else{
                    cell.featuredLabel1.isHidden = true
                }
                
                if productInfo["sponsored"] != nil && productInfo["sponsored"] as! Int == 1{
                    
                    cell.sponsoredLabel1.frame = CGRect(x:0,y: 0, width: 70, height: 20)
                    if productInfo["featured"] != nil && productInfo["featured"] as! Int == 1{
                        cell.sponsoredLabel1.frame = CGRect(x:0,y: 25,width: 70, height: 20)
                    }
                    cell.sponsoredLabel1.isHidden = false
                }else{
                    cell.sponsoredLabel1.isHidden = true
                }
                
                var title = productInfo["title"] as! String
                if title.length > 30{
                    title = (title as NSString).substring(to: 30-3)
                    title  = title + "..."
                }
                cell.classifiedName1.text = title
                cell.classifiedName1.sizeToFit()
                cell.classifiedName1.frame.size.width =  cell.descriptionView1.bounds.width-5
                
                cell.ratings1.frame.origin.y = getBottomEdgeY(inputView:cell.classifiedName1) + 5
                
                
                if let rating = productInfo["rating_avg"] as? Int
                {
                    cell.updateRating1(rating: rating, ratingCount: rating)
                } else {
                    cell.updateRating1(rating: 0, ratingCount: 0)
                }
                
                cell.actualPrice1.frame.origin.y = getBottomEdgeY(inputView:cell.ratings1)
                cell.discountedPrice1.frame.origin.y = getBottomEdgeY(inputView:cell.ratings1)
                
                
                cell.contentSelection1.tag = (index + 1) as Int
                cell.contentSelection1.addTarget(self, action: #selector(StoresProfileViewController.showProduct), for: .touchUpInside)
                
                if logoutUser == false{
                    
                    if let menu = productInfo["menu"] as? NSArray{
                        for menuitem in menu{
                            
                            let menuitem = menuitem as! NSDictionary
                            
                            if menuitem["name"] as! String == "wishlist"{
                                
                                cell.menu1.isHidden = false
                                cell.menu1.tag = (index + 1) as Int
                                cell.menu1.addTarget(self, action:#selector(StoresProfileViewController.addToWishlist) , for: .touchUpInside)
                                if let _ = productInfo["wishlist"] as? NSArray{
                                    cell.menu1.setTitleColor(UIColor.red, for: .normal)
                                }
                                else{
                                    cell.menu1.setTitleColor(textColorLight, for: .normal)
                                }
                                
                            }
                        }
                    }
                }
                var totalView = ""
                
                if let information = productInfo["information"] as? NSDictionary{
                    if let price = information["price"] as? NSDictionary{
                        if let discount = price["discount"] as? CGFloat{
                            if discount == 1{
                                
                                if let productType = productInfo["product_type"] as? String{
                                    if productType == "grouped"{
                                        
                                        cell.actualPrice1.text = NSLocalizedString("Start at:", comment: "")
                                        cell.actualPrice1.sizeToFit()
                                    }
                                    else{
                                        if let views = price["discounted_amount"] as? Double{
                                            cell.discountedPrice1.isHidden = false
                                            cell.discountedPrice1.frame.origin.x = 5
                                            let formatter = NumberFormatter()
                                            formatter.numberStyle = .currency
                                            formatter.locale = NSLocale.current // This is the default
                                            formatter.currencyCode = "\(currency)"
                                            
                                            if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                                let defaults = UserDefaults.standard
                                                if let name = defaults.object(forKey: "Currency")
                                                {
                                                    let price = gettwoFractionDigits(FractionDigit: "\(views)")
                                                    let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                                    let showPrice = (String(format:"%.2f", changePrice))
                                                    
                                                    totalView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                                    
                                                }
                                            }
                                            else{
                                                totalView += formatter.string(from: NSNumber(value: views))!
                                            }
                                           // totalView += formatter.string(from: NSNumber(value: views))! // $123"
                                            if let signValue = price["sign"] as? Int{
                                                if signValue == 1{
                                                    cell.discountedPrice1.text = "\(totalView)*"
                                                }
                                                else{
                                                    cell.discountedPrice1.text = "\(totalView)"
                                                }
                                            }
                                            else{
                                                cell.discountedPrice1.text = "\(totalView)"
                                            }
                                            cell.discountedPrice1.sizeToFit()
                                        }
                                    }
                                }
                                if let ratingAvg = price["price"] as? Double{
                                    
                                    cell.actualPrice1.isHidden = false
                                    cell.actualPrice1.frame.origin.x =  getRightEdgeX(inputView: cell.discountedPrice1) + 5
                                    var ratingView = ""
                                    let formatter = NumberFormatter()
                                    formatter.numberStyle = .currency
                                    formatter.locale = NSLocale.current // This is the default
                                    formatter.currencyCode = "\(currency)"
                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                        let defaults = UserDefaults.standard
                                        if let name = defaults.object(forKey: "Currency")
                                        {
                                            let price = gettwoFractionDigits(FractionDigit: "\(ratingAvg)")
                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                            let showPrice = (String(format:"%.2f", changePrice))
                                            
                                            ratingView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                            
                                        }
                                    }
                                    else{
                                        ratingView += formatter.string(from: NSNumber(value: ratingAvg))!
                                    }
                                  //  ratingView += formatter.string(from: NSNumber(value: ratingAvg))! // $123"
                                    cell.actualPrice1.text = "\(ratingView)"
                                    cell.actualPrice1.sizeToFit()
                                    cell.actualPrice1.frame.size.width = cell.actualPrice1.bounds.width
                                    let viewBorder1 = UIView(frame:CGRect(x:0, y: 6, width: cell.actualPrice1.frame.size.width, height: 1))
                                    viewBorder1.backgroundColor = UIColor.black
                                    viewBorder1.tag = 1003
                                    cell.actualPrice1.addSubview(viewBorder1)
                                    
                                }
                                
                            }
                            else{
                                cell.discountedPrice1.isHidden = true
                                for ob in cell.actualPrice1.subviews{
                                    if ob.tag == 1003 {
                                        ob.removeFromSuperview()
                                    }
                                    
                                    
                                }
                                if let views = price["price"] as? Double{
                                    cell.actualPrice1.frame.origin.x = 5
                                    let formatter = NumberFormatter()
                                    formatter.numberStyle = .currency
                                    formatter.locale = NSLocale.current // This is the default
                                    formatter.currencyCode = "\(currency)"
                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                        let defaults = UserDefaults.standard
                                        if let name = defaults.object(forKey: "Currency")
                                        {
                                            let price = gettwoFractionDigits(FractionDigit: "\(views)")
                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                            let showPrice = (String(format:"%.2f", changePrice))
                                            
                                            totalView =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                            
                                        }
                                    }
                                    else{
                                        totalView += formatter.string(from: NSNumber(value: views))!
                                    }
                                  //  totalView += formatter.string( from: NSNumber(value: views))! // $123"
                                    if let productType = productInfo["product_type"] as? String{
                                        if productType == "grouped"{
                                            if let signValue = price["sign"] as? Int{
                                                if signValue == 1{
                                                    cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@*", comment: ""),"\(totalView)")
                                                    
                                                }
                                                else{
                                                    cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                }
                                            }
                                            else{
                                                cell.actualPrice1.text = String(format: NSLocalizedString("Start at: %@", comment: ""),"\(totalView)")
                                                
                                            }
                                        }
                                        else{
                                            
                                            if let signValue = price["sign"] as? Int{
                                                if signValue == 1{
                                                    cell.actualPrice1.text = "\(totalView)*"
                                                }
                                                else{
                                                    cell.actualPrice1.text = "\(totalView)"
                                                }
                                            }
                                            else{
                                                cell.actualPrice1.text = "\(totalView)"
                                            }
                                            
                                        }
                                    }
                                    cell.actualPrice1.sizeToFit()
                                }
                                
                            }
                            
                            
                        }
                    }
                }
            }
        } else {
            cell.contentSelection1.isHidden = true
            cell.productImageView1.isHidden = true
            cell.classifiedName1.isHidden = true
            cell.ratings1.isHidden = true
            cell.discountedPrice1.isHidden = true
            cell.actualPrice1.isHidden = true
            cell.descriptionView1.isHidden = true
        }
        
        return cell
        
    }
    
    // MARK:  UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
//        if updateScrollFlag{
//
//            // Check for PAGINATION
//            if productsTableView.contentSize.height > productsTableView.bounds.size.height{
//
//                if productsTableView.contentOffset.y >= (productsTableView.contentSize.height - productsTableView.bounds.size.height){
//
//                    if Reachabable.isConnectedToNetwork() {
//
//                        if storeProducts.count > 0{
//                            if maxid == 0{
//
//                                if noPost == true{
//                                    self.view.makeToast("There are no more products to show." , duration: 5, position: "bottom")
//                                    noPost = false
//                                }
//
//                            }else{
//
//                                // Request for Pagination
//                                updateScrollFlag = false
//
//                               // showSpinner = true
//                                getStoreProducts()
//                            }
//                        }
//                    }
//                }
//            }
//        }
        
        let scrollOffset = scrollView.contentOffset.y
        
        if (scrollOffset > 60.0){
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            setNavigationImage(controller: self)
            self.navigationController?.navigationBar.alpha = barAlpha
            self.marqueeHeader.text = self.contentTitle
            self.marqueeHeader.textColor = textColorPrime
            self.marqueeHeader.alpha = barAlpha
            self.contentName.alpha = 1-barAlpha
            
            // update the new position acquired
            self.lastContentOffset = scrollView.contentOffset.y
        }else{
            let barAlpha = max(0, min(1, (scrollOffset/155)))
            if self.marqueeHeader != nil{
                self.marqueeHeader.text = ""
            }
            
            removeNavigationImage(controller: self)
            self.contentName.alpha = 1-barAlpha
            
            if self.marqueeHeader != nil{
                self.marqueeHeader.alpha = 1
            }
            
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if maximumOffset - currentOffset <= 10
        {
            if updateScrollFlag{
                
                // Check for PAGINATION
//                if productsTableView.contentSize.height > productsTableView.bounds.size.height{
                
//                    if productsTableView.contentOffset.y >= (productsTableView.contentSize.height - productsTableView.bounds.size.height){
//                        
                        if Reachabable.isConnectedToNetwork() {
                            
                            if storeProducts.count > 0{
                                if maxid == 0{
                                    productsTableView.tableFooterView?.isHidden = true
                                    if noPost == true{
                                        showToast(message: "There are no more products to show.", controller: self)
                                        noPost = false
                                    }
                                    
                                }else{
                                    
                                    productsTableView.tableFooterView?.isHidden = false
                                    
                                    // Request for Pagination
                                    updateScrollFlag = false
                                    
                                    // showSpinner = true
                                    getStoreProducts()
                                }
                            }
                            else
                            {
                                productsTableView.tableFooterView?.isHidden = true
                            }
                        }
                //    }
               // }
            }
            
        }
        
    }
    
    @objc func like_unLikeAction(sender:UIButton){
        DispatchQueue.main.async(execute:  {
            soundEffect("like_sound")
        })
        
        if self.isLike != nil {
            
            //animationEffectOnButton(sender)
            if self.isLike == true{
                self.likeButton.setTitle("Like", for: .normal)
            }
            else{
                self.likeButton.setTitle("Unlike", for: .normal)
            }
            self.likeButton.isEnabled = false
            
            // Check Internet Connection
            if Reachabable.isConnectedToNetwork() {
                
                removeAlert()
                var path = ""
                
                // Set path for Like & UnLike
                if self.isLike == true{
                    path = "unlike"
                }else{
                    path = "like"
                }
                activityIndicatorView.startAnimating()
                // Send Server Request to Like/Unlike Content
                post(["subject_id":String(storeId), "subject_type": "sitestore_store", "sendNotification": "0"], url: path, method: "POST") {
                    (succeeded, msg) -> () in
                    
                    self.likeButton.isEnabled = true
                    DispatchQueue.main.async(execute:  {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            
                            // On Success Update
                            if succeeded["message"] != nil{
                                
                                if(self.isLike == true){
                                    
                                    self.isLike = false
                                    total_Likes = total_Likes - 1
                                    self.likeButton.setTitle("Like", for: .normal)
                                    self.likeStat.text = "\(total_Likes) \(likeIcon)"
                                    self.likeButton.isEnabled = true
                                    
                                }else{
                                    
                                    self.isLike = true
                                    total_Likes = total_Likes + 1
                                    self.likeButton.setTitle("Unlike", for: .normal)
                                    self.likeStat.text = "\(total_Likes) \(likeIcon)"
                                    
                                    self.likeButton.isEnabled = true
                                    
                                }
                            }
                            
                        }else{
                            // Handle Server Side Error
                            if succeeded["message"] != nil{
                                displayAlert("Info", error: (succeeded["message"] as! String))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }else{
                // No Internet Connection Message
                displayAlert("Info", error: network_status_msg)
                showCustomAlert(self.view.center, msg: network_status_msg)
            }
        }
        
    }
    
    // Add products in  Wishlist
    @objc func addToWishlist(sender : UIButton){
        var productInfo:NSDictionary!
        productInfo = storeProducts[sender.tag] as! NSDictionary
        let product_id =   productInfo["product_id"] as! Int
        if let menu = productInfo["menu"] as? NSArray{
            for menuitem in menu{
                
                let menuitem = menuitem as! NSDictionary
                
                if menuitem["name"] as! String == "wishlist"{
                    
                    let presentedVC = FormGenerationViewController()
                    presentedVC.formTitle = NSLocalizedString("Add To Wishlist", comment: "")
                    presentedVC.contentType = "product wishlist"
                    presentedVC.url = menuitem["url"] as! String
                    var tempDic = NSDictionary()
                    tempDic = ["product_id" : "\(product_id)"]
                    presentedVC.param = tempDic
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    self.present(nativationController, animated:false, completion: nil)
                    
                }
            }
            
            
        }
        
        
        
        
    }
    
    @objc func showProduct(sender: UIButton){
        if let productInfo = storeProducts[sender.tag] as? NSDictionary
        {
            let product_id = "\(productInfo["product_id"]!)"
            SiteStoreObject().redirectToProductsProfilePage(viewController: self, showOnlyMyContent: false, product_id:product_id)
        }
        
    }
    
   @objc func showCart(){
        
        let presentedVC = ManageCartViewController()
        navigationController?.pushViewController(presentedVC, animated: true)
        
    }


    // MARK: - Checkin wideget server calling
    func ischekin()
    {
        
        if Reachabable.isConnectedToNetwork()
        {
            removeAlert()
            
            var parameters = [String:String]()
            parameters = ["subject_type": "sitestore_store" , "subject_id": String(storeId)]
            // Send Server Request to Explore classified Contents with classified_ID
            post(parameters, url: "/sitetagcheckin/checkin-count", method: "GET") { (succeeded, msg) -> () in
                
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg
                    {
                        if let response = succeeded["body"] as? NSDictionary
                        {

                            self.CheckinDic = response
                            
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
    
    func performPhotoActions(subject_type : String, subject_id : String , url : String, special : String){
        // Check Internet Connection
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var dic = Dictionary<String, String>()
            dic["subject_type"] = subject_type
            dic["subject_id"] = subject_id
            if special == "profile"
            {
                dic["special"] = "profile"
            }
            else
            {
                print("")
            }
            
            var method: String!
            method = "POST"
            userInteractionOff = false
            // Send Server Request to Update Feed Gutter Menu
            post(dic, url: "\(url)", method: method) { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    userInteractionOff = false
                    
                    if msg{
                        if succeeded["message"] != nil{
                            showToast(message: succeeded["message"] as! String, controller: self)
                        }
                        //updateUserData()
                        self.coverImageUrl = ""
                        self.exploreContent()
                        
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
            showAlertMessage(centerPoint: view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    func checkinAction(_ sender:UIButton)
    {
        let presentedVC = AdvancePostFeedViewController()
        presentedVC.isCheckIn = true
        presentedVC.openfeedStyle = 4
        presentedVC.subjectId = "\(storeId)"
        presentedVC.subjectType = "sitestore_store"
        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        let nativationController = UINavigationController(rootViewController: presentedVC)
        self.present(nativationController, animated:true, completion: nil)
        
    }


    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the isSelected object to the new view controller.
    }
    */
    
}
