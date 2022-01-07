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

//  ProductProfilePage.swift
//  seiosnativeapp
//
//  Created by BigStep Tech on 03/02/16.
//  Copyright © 2016 bigstep. All rights reserved.


import UIKit
import CoreData
import AudioToolbox
var productDetailUpdate :Bool!
var priceValue : CGFloat!
var configurations = [String:AnyObject]()
var configurationsFields = [AnyObject]()//Dictionary<String, AnyObject>()
var indexValue : Int = 0
var AddToWishlistIcon = false

class ProductProfilePage: UIViewController, UIScrollViewDelegate, TTTAttributedLabelDelegate,UITabBarControllerDelegate{
    var dic = Dictionary<String, AnyObject>()
    var dicToBeAdded = Dictionary<String, AnyObject>()
    var withConfigDicToBeAdded = Dictionary<String, AnyObject>()
    var scrollView : UIScrollView!
    var imageScrollView: UIScrollView!
    var totalProductImage : NSArray!
    var totalPhoto : Int!
    var product_id : String!
    var owner_id : Int!
    var store_id : Int!
    var config : NSDictionary!
    var productName : TTTAttributedLabel!
    var tabsContainerMenu:UIScrollView!
    var contentImage: String!
    @objc var count:Int = 0
    var configView : UIView!
    var configOnClick : UIButton!
    var priceView : UIView!
    var Inoutstockstring : UILabel!
    var originalPriceValue : UILabel!
    var discountedAmount : UILabel!
    var discountValue : UILabel!
    var currency : String = ""
    var productReview : UIView!
    var productProfileFields : UIView!
    var review : UIView!
    var likeView : UIView!
    var reviewLabel : UILabel!
    var reviewCount : UILabel!
    var likeIcon : UILabel!
    var likeCount : UILabel!
    var label1 : TTTAttributedLabel!
    var label3 : TTTAttributedLabel!
    var label2 : UIButton!
    var shippingDetailString : UIButton!
    var moreShippingMethodDetails : UIButton!
    var shippingDetails : UIView!
    var relatedProducts : UIView!
    var storeSlideshow: ContentSlideshowScrollView!
    var requiredStoresResponse = [AnyObject]()
    var descriptionView : UIView!
    var RedirectText : String! = ""
    var overviewText = ""
    var shareUrl : String!
    var shareParam : NSDictionary!
    var gutterMenu :NSArray = [] as NSArray
    var coverImageUrl : String!
    var shareTitle:String!
    var contentUrl : String!
    var contentTitle : String! = ""
    let mainView = UIView()
    var productProfileTabMenu:NSArray = [] as NSArray
    var photos:[PhotoViewer] = []
    var bottomBorder2 = UIView()
    var bottomBorder3 = UIView()
    var add : UIButton!
    var buy : UIButton!
    var btnMsg = UIButton()
    var lastContentOffset: CGFloat = 0
    var marqueeHeader : MarqueeLabel!
    var relatedProductsTitle : UILabel!
    var rightBarButtonItem : UIBarButtonItem!
    var priceThatChange : CGFloat!
    var shippingMethodsDetails : NSDictionary!
    var statusofResponse : Bool = false
    var groupedProducts : UIView!
    var productsTitle : UILabel!
    var requiredProductResponse = [AnyObject]()
    var productSlideshow: ContentSlideshowScrollView!
    var downloadableProducts : UIView!
    var sampleProductTitle : UILabel!
    var productProfileTitle : UILabel!
    var downloadableProductResponse = [AnyObject]()
    var productProfileType = ""
    var dicGroup = [AnyObject]()
    var addInCoreData : Bool = false
    var Description : TTTAttributedLabel!
    var descriptionMoreOrLess : UIButton!
    var descriptionDetailString : UIButton!
    var Buynow = false
    var profileView = UIView()
    var label5 : TTTAttributedLabel!
    var label6 : TTTAttributedLabel!
    var productReviewCount: Int = 0
    var deleteProductEntry : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Messag_Owner = false
        AddToWishlistIcon = false
        configurations.removeAll(keepingCapacity: false)
        dic.removeAll(keepingCapacity: false)
        dicToBeAdded.removeAll(keepingCapacity: false)
        //setNavigationImage(controller: self)
        self.tabBarController?.delegate = self
        view.backgroundColor = bgColor
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(ProductProfilePage.goBack))
        leftNavView.addGestureRecognizer(tapView)
        let backIconImageView = createImageView(CGRect(x: 0, y: 12, width: 22, height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")!.maskWithColor(color: textColorPrime)
        leftNavView.addSubview(backIconImageView)
        
        let barButtonItem = UIBarButtonItem(customView: leftNavView)
        self.navigationItem.leftBarButtonItem = barButtonItem
        
        
        priceValue = 0.0
        productDetailUpdate = false
        productUpdate = false
        Buynow = false
        
        mainView.frame = view.frame
        mainView.backgroundColor = bgColor
        view.addSubview(mainView)
        
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.white//bgColor
        scrollView.tag = 1000
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.contentSize = view.bounds.size
        scrollView.sizeToFit()
        mainView.addSubview(scrollView)
        
        
        imageScrollView = UIScrollView(frame: CGRect(x:0, y:-TOPPADING, width:view.bounds.width, height:300))
        imageScrollView.delegate = self
        imageScrollView.backgroundColor = UIColor.white //placeholderColor
        
        imageScrollView.showsHorizontalScrollIndicator = false
        scrollView.addSubview(imageScrollView)
        
        productName = TTTAttributedLabel(frame: CGRect(x:contentPADING , y:imageScrollView.frame.origin.y + imageScrollView.bounds.height + 15, width:view.bounds.width - (2 * contentPADING), height:50))
        productName.numberOfLines = 0
        productName.font = UIFont(name: fontName , size: FONTSIZEMedium)
        productName.textColor = textColorMedium
        productName.longPressLabel()
        productName.isHidden = true
        productName.delegate = self
        scrollView.addSubview(productName)
        
        groupedProducts = createView(CGRect(x:0, y:productName.frame.origin.y + productName.bounds.height + 15, width:view.bounds.width, height:200), borderColor: UIColor.clear, shadow: false)
        groupedProducts.backgroundColor = UIColor.white//UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        groupedProducts.isHidden = true
        scrollView.addSubview(groupedProducts)
        
        
        productsTitle = createLabel(CGRect(x:5, y:0 , width:groupedProducts.bounds.width, height:30), text: "", alignment: .left, textColor: textColorDark)
        productsTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        productsTitle.textAlignment = NSTextAlignment.center
        productsTitle.longPressLabel()
        groupedProducts.addSubview(productsTitle)
        
        
        productSlideshow = ContentSlideshowScrollView(frame: CGRect(x:0, y:30, width:view.bounds.width, height:200))
        productSlideshow.backgroundColor = UIColor.white
        productSlideshow.delegate = self
        productSlideshow.showsHorizontalScrollIndicator = false
        groupedProducts.addSubview(productSlideshow)
        
        
        
        downloadableProducts = createView(CGRect(x:0, y:productName.frame.origin.y + productName.bounds.height + 15, width:view.bounds.width, height:200), borderColor: UIColor.clear, shadow: false)
        downloadableProducts.backgroundColor = UIColor.white//UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        downloadableProducts.isHidden = true
        scrollView.addSubview(downloadableProducts)
        
        
        
        sampleProductTitle = createLabel(CGRect(x:5, y:0 , width:downloadableProducts.bounds.width, height:30), text: "", alignment: .left, textColor: textColorDark)
        sampleProductTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        sampleProductTitle.textAlignment = NSTextAlignment.center
        sampleProductTitle.longPressLabel()
        downloadableProducts.addSubview(sampleProductTitle)
        
        
        
        tabsContainerMenu = UIScrollView(frame: CGRect(x:0, y:groupedProducts.frame.origin.y + groupedProducts.bounds.height + 5,width:view.bounds.width ,height:ButtonHeight ))
        tabsContainerMenu.delegate = self
        tabsContainerMenu.backgroundColor = tableViewBgColor
        tabsContainerMenu.isHidden = true
        tabsContainerMenu.showsHorizontalScrollIndicator = false
        tabsContainerMenu.showsVerticalScrollIndicator = false
        tabsContainerMenu.tag = 222
        scrollView.addSubview(tabsContainerMenu)
        
        
        configView = createView(CGRect(x:0, y:tabsContainerMenu.frame.origin.y + tabsContainerMenu.bounds.height + 5 , width:view.bounds.width, height:30), borderColor: UIColor.clear, shadow: false)
        configView.backgroundColor = UIColor.white//UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        configView.isHidden = true
        scrollView.addSubview(configView)
        
        
        priceView = createView(CGRect(x:0, y:tabsContainerMenu.frame.origin.y + tabsContainerMenu.bounds.height + 5 , width:view.bounds.width, height:30), borderColor: UIColor.clear, shadow: false)
        priceView.backgroundColor = UIColor.white//UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        priceView.isHidden = true
        scrollView.addSubview(priceView)
        
        
        configView = createView(CGRect(x:0, y:priceView.frame.origin.y + priceView.bounds.height + 5 , width:view.bounds.width, height:30), borderColor: UIColor.clear, shadow: false)
        configView.backgroundColor = UIColor.white//UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        configView.isHidden = true
        scrollView.addSubview(configView)
        
        
        configOnClick = createButton(CGRect(x:0,y:0, width:configView.bounds.width,  height:configView.bounds.height), title: "", border: false,bgColor: false, textColor: textColorDark)
        configOnClick.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        configView.addSubview(configOnClick)
        
        
        
        Inoutstockstring = createLabel(CGRect(x:contentPADING,  y:contentPADING, width:80, height:priceView.bounds.height - (2 * contentPADING)), text: "", alignment: .left, textColor: textColorDark)
        Inoutstockstring.font = UIFont(name: fontName, size: FONTSIZENormal)
        Inoutstockstring.longPressLabel()
        priceView.addSubview(Inoutstockstring)
        
        originalPriceValue = createLabel(CGRect(x:Inoutstockstring.frame.size.width + Inoutstockstring.frame.origin.x + 10,  y:contentPADING, width:100, height:priceView.bounds.height - (2 * contentPADING)), text: "", alignment: .left, textColor: textColorDark)
        originalPriceValue.font = UIFont(name: fontName, size: FONTSIZENormal)
        originalPriceValue.longPressLabel()
        originalPriceValue.isHidden = true
        priceView.addSubview(originalPriceValue)
        
        discountedAmount = createLabel(CGRect(x:originalPriceValue.frame.size.width + originalPriceValue.frame.origin.x + 10, y:contentPADING, width:100, height:priceView.bounds.height - (2 * contentPADING)), text: "", alignment: .left, textColor: textColorDark)
        discountedAmount.font = UIFont(name: fontName, size: FONTSIZENormal)
        discountedAmount.longPressLabel()
        discountedAmount.isHidden = true
        priceView.addSubview(discountedAmount)
        
        discountValue = createLabel(CGRect(x: 0 , y:contentPADING, width:view.bounds.width, height:priceView.bounds.height - (2 * contentPADING)), text: "", alignment: .left, textColor: UIColor.red)
        discountValue.font = UIFont(name: fontName, size: FONTSIZENormal)
        discountValue.longPressLabel()
        discountValue.isHidden = true
        priceView.addSubview(discountValue)
        
        
        productReview = createView(CGRect(x:0, y:priceView.frame.origin.y + priceView.bounds.height + 5, width:view.bounds.width, height:75), borderColor: UIColor.clear, shadow: false)
        productReview.backgroundColor = UIColor.white// UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        productReview.isHidden = true
        scrollView.addSubview(productReview)
        
        
        review = createView(CGRect(x:0, y:0, width:productReview.bounds.width/2, height:productReview.bounds.height ), borderColor: UIColor.clear, shadow: false)
        review.backgroundColor =  UIColor.white//UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        review.isHidden = false
        productReview.addSubview(review)
        
        
        likeView = createView(CGRect(x:review.bounds.width + review.frame.origin.y,y: 0, width:productReview.bounds.width/2, height:productReview.bounds.height ), borderColor: UIColor.clear, shadow: false)
        likeView.backgroundColor = UIColor.white//UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        likeView.isHidden = true
        productReview.addSubview(likeView)
        
        reviewLabel = createLabel(CGRect(x: 10 , y:contentPADING, width:review.bounds.width, height:40), text: "", alignment: .left, textColor: textColorDark)
        reviewLabel.font = UIFont(name: fontName, size: FONTSIZENormal)
        reviewLabel.isHidden = true
        reviewLabel.textAlignment = NSTextAlignment.center
        reviewLabel.longPressLabel()
        review.addSubview(reviewLabel)
        
        
        reviewCount = createLabel(CGRect(x:5, y:50 , width:review.bounds.width, height:20  ), text: "", alignment: .left, textColor: textColorDark)
        reviewCount.font = UIFont(name: fontName, size: FONTSIZENormal)
        reviewCount.isHidden = true
        reviewCount.textAlignment = NSTextAlignment.center
        reviewCount.longPressLabel()
        review.addSubview(reviewCount)
        
        
        likeIcon = createLabel(CGRect(x:5, y:contentPADING, width:likeView.bounds.width, height:40), text: "", alignment: .left, textColor: textColorMedium)
        likeIcon.font = UIFont(name: "FontAwesome", size: FONTSIZEExtraLarge)
        likeIcon.isHidden = true
        likeIcon.textAlignment = NSTextAlignment.center
        likeIcon.longPressLabel()
        likeView.addSubview(likeIcon)
        
        likeCount = createLabel(CGRect(x:5, y:50 , width:likeView.bounds.width, height:20  ), text: "", alignment: .left, textColor: textColorDark)
        likeCount.font = UIFont(name: fontName, size: FONTSIZENormal)
        likeCount.isHidden = true
        likeCount.textAlignment = NSTextAlignment.center
        likeCount.longPressLabel()
        likeView.addSubview(likeCount)
        
        
        profileView = createView(CGRect(x:0,  y:productReview.frame.origin.y + productReview.bounds.height + 5, width:view.bounds.width, height:100), borderColor: borderColorDark, shadow: false)
        profileView.layer.borderWidth = 0.0
        scrollView.addSubview(profileView)
        profileView.isHidden = true
        
        
        productProfileTitle = createLabel(CGRect(x:5, y:0 , width:profileView.bounds.width - 10, height:30), text: "", alignment: .left, textColor: textColorDark)
        productProfileTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        productProfileTitle.textAlignment = NSTextAlignment.center
        productProfileTitle.longPressLabel()
        profileView.addSubview(productProfileTitle)
        
        shippingDetails = createView(CGRect(x:0, y:profileView.frame.origin.y + profileView.bounds.height + 5, width:view.bounds.width, height:60), borderColor: UIColor.clear, shadow: false)
        shippingDetails.backgroundColor = UIColor.white//UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        shippingDetails.isHidden = true
        scrollView.addSubview(shippingDetails)
        
        
        descriptionView = createView(CGRect(x:0, y:shippingDetails.frame.origin.y + shippingDetails.bounds.height + 5 , width:view.bounds.width, height:150), borderColor: UIColor.clear, shadow: false)
        descriptionView.backgroundColor = UIColor.white//UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        descriptionView.isHidden = true
        scrollView.addSubview(descriptionView)
        
        
        Description = TTTAttributedLabel(frame: CGRect(x:2 * PADING , y:5 , width:view.bounds.width - (4 * PADING), height:120))
        Description.numberOfLines = 4
        Description.longPressLabel()
        Description.delegate = self
        descriptionView.addSubview(Description)
        descriptionMoreOrLess = createButton(CGRect(x:view.bounds.width - 50, y:Description.frame.size.height + Description.bounds.height + (2 * contentPADING) ,  width:40, height:30), title: "More", border: false,bgColor: false, textColor: navColor)
        descriptionMoreOrLess.isHidden = true
        descriptionMoreOrLess.sizeToFit()
        descriptionView.addSubview(descriptionMoreOrLess)
        descriptionMoreOrLess.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        
        relatedProducts = createView(CGRect(x:0, y:descriptionView.frame.origin.y + descriptionView.bounds.height + 10, width:view.bounds.width, height:200), borderColor: UIColor.clear, shadow: false)
        relatedProducts.backgroundColor = UIColor.white//UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
        relatedProducts.isHidden = true
        scrollView.addSubview(relatedProducts)
        
        relatedProductsTitle = createLabel(CGRect(x:5, y:0 , width:relatedProducts.bounds.width, height:30), text: "", alignment: .left, textColor: textColorDark)
        relatedProductsTitle.font = UIFont(name: fontBold, size: FONTSIZEMedium)
        relatedProductsTitle.textAlignment = NSTextAlignment.center
        relatedProductsTitle.longPressLabel()
        relatedProducts.addSubview(relatedProductsTitle)
        
        storeSlideshow = ContentSlideshowScrollView(frame: CGRect(x:0, y:30, width:view.bounds.width, height:180))
        storeSlideshow.backgroundColor = UIColor.white
        storeSlideshow.delegate = self
        storeSlideshow.showsHorizontalScrollIndicator = false
        relatedProducts.addSubview(storeSlideshow)
        
        
        // Add to cart
        add = createButton(CGRect(x:0,y:view.bounds.height-(tabBarHeight + ButtonHeight)-7, width:view.bounds.width/3, height:ButtonHeight), title: NSLocalizedString("\(addToCartIcon)  Add to Cart",  comment: ""), border: false, bgColor: false, textColor: textColorLight)
        add.tag = 11
        add.setTitleColor(textColorDark, for: .highlighted)
        add.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        add.addTarget(self, action: #selector(ProductProfilePage.addToCart), for: .touchUpInside)
        add.backgroundColor = navColor
        add.isHidden = true
        mainView.addSubview(add)
        
        bottomBorder2 = UIView(frame: CGRect(x:view.bounds.width/3 - 1, y:0, width:1 , height:add.frame.size.height ))
        bottomBorder2.backgroundColor = textColorLight
        add.addSubview(bottomBorder2)
        
        // Buy Now
        buy = createButton(CGRect(x:view.bounds.width/3,y:view.bounds.height-(tabBarHeight + ButtonHeight)-7, width:view.bounds.width/3, height:ButtonHeight), title: NSLocalizedString("\(buyNowIcon)  Buy Now",  comment: ""), border: false, bgColor: false, textColor: textColorLight)
        buy.tag = 12
        buy.setTitleColor(textColorDark, for: .highlighted)
        buy.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZEMedium)
        buy.addTarget(self, action: #selector(ProductProfilePage.showCart), for: .touchUpInside)
        buy.backgroundColor = navColor
        buy.isHidden = true
        mainView.addSubview(buy)
 
        bottomBorder3 = UIView(frame: CGRect(x:view.bounds.width/3 - 1, y:0, width:1 , height:buy.frame.size.height))
        bottomBorder3.backgroundColor = textColorLight
        buy.addSubview(bottomBorder3)
        
        // Message
        btnMsg = createButton(CGRect(x: 2*view.bounds.width/3,y: view.bounds.height-(tabBarHeight + ButtonHeight)-7,width: view.bounds.width/3, height: add.frame.size.height), title: String(format: NSLocalizedString("Message", comment: "")), border: false, bgColor: true, textColor: textColorLight)
        btnMsg.backgroundColor = navColor
        btnMsg.titleLabel?.font = UIFont(name: fontName, size: FONTSIZEMedium)
        btnMsg.isHidden = true
        btnMsg.contentEdgeInsets = UIEdgeInsets(top: 0, left: 27, bottom: 0, right: 0)
        btnMsg.addTarget(self, action: #selector(ProductProfilePage.clickOnFloatyMsgButton), for: .touchUpInside)
        mainView.addSubview(btnMsg)
        
        let img = UIImageView(frame: CGRect(x:25, y:14, width:15, height:15))
        img.image = UIImage(named:"messageIcon")?.maskWithColor(color: textColorLight)
        img.contentMode = .scaleAspectFit
        btnMsg.addSubview(img)
        
        exploreProduct()
    }
    
    // Floating Message Button Action
    @objc func clickOnFloatyMsgButton()
    {
        if isChannelizeAvailable{
            if self.owner_id != nil{
                let data : [AnyHashable:Any] = [AnyHashable("userId"):self.owner_id]
                if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                    let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                    if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                        channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: data)
                    }
                }
            }
        }else{
            let presentedVC = MessageOwnerViewController();
            presentedVC.url = Messag_Url
            self.navigationController?.pushViewController(presentedVC, animated: false)
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {

        if productDetailUpdate == true{
            productDetailUpdate = false
            exploreProduct()
            
        }
        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
        removeNavigationImage(controller: self)
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x:68, y: 0, width: navigationBar.frame.width - 148, height: navigationBar.frame.height)
            marqueeHeader = MarqueeLabel(frame: firstFrame)
            marqueeHeader.tag = 101
            marqueeHeader.setDefault()
            navigationBar.addSubview(marqueeHeader)
        }
        
    }
    override func viewWillDisappear(_ animated: Bool)
    {
        getCartCount()
        priceValue = 0.0
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
    
    func exploreProduct(){
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
            // Send Server Request to Explore PRODUCT Contents with product_ID and store_ID
            post([
                "gutter_menu": "1"], url: "sitestore/product/view/\(product_id!)", method: "GET") { (succeeded, msg) -> () in
                    
                    DispatchQueue.main.async(execute: {
                        activityIndicatorView.stopAnimating()
                        if msg{
                            // On Success Update product Detail
                            
                            if let productsProfile = succeeded["body"] as? NSDictionary {
                                
                                
                                if let menu = productsProfile["menu"] as? NSArray{
                                    self.gutterMenu  = menu as NSArray
                                    
                                    var isCancel = false
                                    for tempMenu in self.gutterMenu{
                                        if let tempDic = tempMenu as? NSDictionary{
                                            
                                            if tempDic["name"] as! String == "messageowner" {
                                                Messag_Owner = true
                                                if let url = tempDic["url"] as? String {
                                                    Messag_Url = url
                                                }
                                            }
                                            
                                            if tempDic["name"] as! String == "share" {
                                                self.shareUrl = tempDic["url"] as! String
                                                self.shareParam = tempDic["urlParams"] as! NSDictionary
                                            }
                                            else
                                            {
                                                isCancel = true
                                            }
                                        }
                                    }
                                    
                                    if logoutUser == false{
                                        
                                        let rightNavView = UIView(frame: CGRect(x:0, y:0, width:66, height:44))
                                        rightNavView.backgroundColor = UIColor.clear
                                        let optionButton = createButton(CGRect(x:22,y:0,width:45,height:45), title: "", border: false, bgColor: false, textColor: UIColor.clear)
                                        optionButton.setImage(UIImage(named: "option")!.maskWithColor(color: textColorPrime), for: .normal)
                                        optionButton.addTarget(self, action: #selector(ProductProfilePage.showGutterMenu), for: .touchUpInside)
                                     //   rightNavView.addSubview(optionButton)
                                        if isCancel == false
                                        {
                                           // shareButton.frame.origin.x = 44
                                        }
                                        else
                                        {
                                            rightNavView.addSubview(optionButton)
                                        }
                                        self.rightBarButtonItem = UIBarButtonItem(customView: rightNavView)
                                        self.navigationItem.rightBarButtonItem = self.rightBarButtonItem
                                    }
                                    
                                }
                                
                                self.contentUrl =  productsProfile["content_url"] as! String
                                
                                if let _ = productsProfile["photo_id"] as? Int{
                                    
                                    self.coverImageUrl = productsProfile["image"] as! String
                                }
                                
                                if let productImages = productsProfile["images"] as? NSArray
                                {
                                    self.totalProductImage = productImages
                                    self.totalPhoto = productImages.count
                                    if productImages.count > 1
                                    {
                                        let  totalPic = TTTAttributedLabel(frame:CGRect(x:self.view.bounds.width-45, y:100 ,width:45, height:50) )
                                        totalPic.numberOfLines = 0
                                        totalPic.textColor = textColorMedium
                                        totalPic.backgroundColor = UIColor.clear
                                        totalPic.delegate = self
                                        totalPic.font = UIFont(name: "FontAwesome", size:FONTSIZEMedium)
                                        totalPic.longPressLabel()
                                        self.scrollView.addSubview(totalPic)
                                        totalPic.isHidden = true
                                        
                                        
                                        let message = String(format: NSLocalizedString(" \(forwordIcon) \n\n \(productImages.count) \(cameraIcon)", comment: ""), productImages.count)
                                        totalPic.isHidden = false
                                        totalPic.setText(message, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                            
                                            // TODO: Clean this up..
                                            return mutableAttributedString!
                                        })
                                    }
                                    
                                    if productImages.count > 0
                                    {
                                        let productImagess = productImages[0] as! NSDictionary
                                        if let tempImageString = productImagess["image"] as? String {
                                            self.contentImage = tempImageString
                                        }
                                        self.imageScrollView.isHidden = false
                                        var originX = ImageViewPading
                                        self.imageScrollView.subviews.forEach({ $0.removeFromSuperview() })
                                        for images in productImages
                                        {
                                            if let dic = (images as AnyObject) as? NSDictionary
                                            {
                                                let frame = CGRect(x: originX , y:0, width:self.view.bounds.width, height:300)
                                                var welcomeImageView = ProductCoverImageViewWithGradient(frame: frame)
                                                welcomeImageView.tag = self.count
                                                welcomeImageView.contentMode = .scaleAspectFill
                                                self.count += 1
                                                welcomeImageView.isUserInteractionEnabled = true
                                                
                                                if let url = NSURL(string: dic["image"] as! String){
                                                    welcomeImageView.contentMode =  UIView.ContentMode.scaleAspectFit
                                                    welcomeImageView.kf.indicatorType = .activity
                                                    (welcomeImageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = buttonColor
                                                    welcomeImageView.kf.setImage(with: url as URL?, placeholder: nil, options: [.transition(.fade(1.0))], completionHandler: { (image, error, cache, url) in
                                                        
                                                    })
                                                    
                                                }
                                                
                                                welcomeImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProductProfilePage.onImageViewTap)))
                                                self.imageScrollView.addSubview(welcomeImageView)
                                                
                                            
                                                
                                                if logoutUser == false{
                                                
                                                    let frame1 = CGRect(x: self.view.bounds.width - 80 , y:200-(TOPPADING-64), width:30, height:30)
                                                    let shareButton = createButton(frame1, title: "", border: false, bgColor: false, textColor: textColorLight)
                                                    let image = UIImage(named: "upload") as UIImage?
                                                    shareButton.setImage(image, for: UIControl.State.normal)
                                                    shareButton.setTitleColor(textColorDark, for: .highlighted)
                                                    shareButton.titleLabel?.font =  UIFont(name: fontName, size:10.0)
                                                    shareButton.addTarget(self, action: #selector(ProductProfilePage.shareItem), for: .touchUpInside)
                                                    self.scrollView.addSubview(shareButton)
                                                    
                                                    let frame2 = CGRect(x: self.view.bounds.width - 40 , y:200-(TOPPADING-64), width:30, height:30)
                                                    let wishlistButton = createButton(frame2, title: "\u{f004}", border: false, bgColor: false, textColor: textColorLight)
                                                    wishlistButton.titleLabel?.font =  UIFont(name: "FontAwesome", size:20.0)
                                                    if let alreadyInWishlist = productsProfile["wishlistPresent"] as? Int{
                                                        if alreadyInWishlist == 1
                                                        {
                                                            wishlistButton.setTitleColor(UIColor.red, for: .normal)

                                                        }
                                                        else
                                                        {
                                                            wishlistButton.setTitleColor(textColorLight, for: .normal)

                                                        }
                                                    }
                                                    
                                                    wishlistButton.addTarget(self, action: #selector(ProductProfilePage.addToWishlist), for: .touchUpInside)
                                                    self.scrollView.addSubview(wishlistButton)
                                                }
                                                
                                                
                                                
                                            }
                                            originX += self.view.bounds.width
                                        }
                                        
                                        self.imageScrollView.contentSize = CGSize(width:originX , height:270)
                                        self.imageScrollView.isPagingEnabled = true
                                        self.imageScrollView.bounces = true
                                        self.imageScrollView.isUserInteractionEnabled = true
                                        
                                    }
                                }
                                
                                if let storeId = productsProfile["store_id"] as? Int{
                                    self.store_id = storeId
                                }
                                
                                if let ownerId = productsProfile["owner_id"] as? Int{
                                    self.owner_id = ownerId
                                    Message_OwnerId = ownerId
                                }
                                
                                if let productTitle = productsProfile["title"] as? String{
                                    self.shareTitle = productsProfile["title"] as? String
                                    self.contentTitle = productsProfile["title"] as? String
                                    
                                    self.productName.isHidden = false
                                    self.productName.setText(productTitle, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                        let boldFont = CTFontCreateWithName( (fontBold as CFString?)!, FONTSIZELarge, nil)
                                        let range = (productTitle as NSString).range(of: productTitle)
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont, range: range)
                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorDark , range: range)
                                        return mutableAttributedString!
                                        
                                        
                                        
                                    })
                                    self.productName.sizeToFit()
                                    
                                    
                                }
                                
                                if let productType = productsProfile["product_type"] as? String{
                                    self.productProfileType = productType
                                    
                                    if productType == "grouped" || productType == "bundled"{
                                        
                                        
                                        if let relatedProduct = productsProfile["groupedProducts"] as?  NSArray{
                                            if relatedProduct.count > 0{
                                                self.groupedProducts.frame.origin.y = getBottomEdgeY(inputView:self.productName) + 15
                                                self.groupedProducts.isHidden = false
                                                self.productsTitle.text = NSLocalizedString("Grouped Products",  comment: "")
                                                
                                                
                                                self.requiredProductResponse = relatedProduct as [AnyObject]
                                                self.productSlideshow.browseProducts(contentItems: self.requiredProductResponse)
                                                
                                                
                                            }
                                            else{
                                                self.groupedProducts.isHidden = true
                                                self.groupedProducts.frame.size.height = 0.0
                                                self.groupedProducts.frame.origin.y = getBottomEdgeY(inputView:self.productName)
                                            }
                                            
                                            
                                        }
                                        else  if let relatedProduct = productsProfile["bundledProducts"] as?  NSArray{
                                            if relatedProduct.count > 0{
                                                self.groupedProducts.frame.origin.y = getBottomEdgeY(inputView:self.productName) + 15
                                                self.groupedProducts.isHidden = false
                                                self.productsTitle.text = NSLocalizedString("Bundled Products",  comment: "")
                                                
                                                
                                                self.requiredProductResponse = relatedProduct as [AnyObject]
                                                self.productSlideshow.browseProducts(contentItems: self.requiredProductResponse)
                                                
                                                
                                            }
                                            else{
                                                self.groupedProducts.isHidden = true
                                                self.groupedProducts.frame.size.height = 0.0
                                                self.groupedProducts.frame.origin.y = getBottomEdgeY(inputView:self.productName)
                                            }
                                            
                                            
                                        }
                                        else{
                                            self.groupedProducts.isHidden = true
                                            self.groupedProducts.frame.size.height = 0.0
                                            self.groupedProducts.frame.origin.y = getBottomEdgeY(inputView:self.productName)
                                        }
                                        
                                    }
                                    else{
                                        self.groupedProducts.isHidden = true
                                        self.groupedProducts.frame.size.height = 0.0
                                        self.groupedProducts.frame.origin.y = getBottomEdgeY(inputView:self.productName)
                                        
                                    }
                                    
                                    
                                }
                                
                                if let productType = productsProfile["product_type"] as? String{
                                    
                                    if productType == "downloadable"{
                                        self.downloadableProducts.frame.origin.y = getBottomEdgeY(inputView:self.productName) + 15
                                        self.downloadableProducts.isHidden = false
                                        
                                        if let sampleProduct = productsProfile["sampleFiles"] as?  NSArray{
                                            self.downloadableProductResponse = sampleProduct as [AnyObject]
                                            self.sampleProductTitle.text = NSLocalizedString("Sample Products",  comment: "")
                                            var labelDesc : String!
                                            
                                            var profileFieldString = ""
                                            var profileFieldString2 = ""
                                            var origin_labelheight_y2 : CGFloat = 0
                                            var origin_labelheight_y : CGFloat = 0
                                            
                                            origin_labelheight_y  = getBottomEdgeY(inputView:self.sampleProductTitle)
                                            origin_labelheight_y2  = getBottomEdgeY(inputView:self.sampleProductTitle)
                                            var i = 0
                                            for shampleproducts in sampleProduct {
                                                if let dic = shampleproducts as? NSDictionary {
                                                    
                                                    if  let title = dic["title"] as? String{
                                                        
                                                        
                                                        if origin_labelheight_y2 > origin_labelheight_y{
                                                            origin_labelheight_y = origin_labelheight_y2
                                                        }
                                                        
                                                        
                                                        self.label1 = TTTAttributedLabel(frame:CGRect(x:2 * PADING,y:origin_labelheight_y + 5,width:self.view.bounds.width/2 - 2 * PADING , height:30) )
                                                        self.label1.textColor = textColorDark
                                                        self.label1.isHidden = false
                                                        
                                                        self.label1.backgroundColor = UIColor.white
                                                        self.label1.font = UIFont(name: fontNormal, size: FONTSIZESmall)
                                                        self.label1.numberOfLines = 0
                                                        self.label1.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                        labelDesc = title
                                                        profileFieldString = labelDesc + "\n" + "\n"
                                                        self.label1.text = profileFieldString
                                                        self.label1.setText(profileFieldString , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                            
                                                            let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZESmall, nil)
                                                            
                                                            let range1 = (profileFieldString as NSString).range(of: labelDesc as String)
                                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                                                            
                                                            
                                                            return mutableAttributedString!
                                                        })
                                                        self.label1.sizeToFit()
                                                        
                                                        
                                                        origin_labelheight_y  = origin_labelheight_y + self.label1.bounds.height
                                                        
                                                        self.downloadableProducts.addSubview(self.label1)
                                                        self.label2 = createButton(CGRect(x:self.view.bounds.width - 100 ,y:origin_labelheight_y2 ,width:90, height:20), title: "", border: false,bgColor: false, textColor: textColorLight)
                                                        self.label2.isHidden = false
                                                        self.label2.layer.cornerRadius = 2.0
                                                        self.label2.titleLabel?.font = UIFont(name: "FontAwesome", size: FONTSIZESmall)
                                                        self.label2.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.center
                                                        self.label2.backgroundColor = navColor
                                                        self.label2.tag = i
                                                        profileFieldString2 = NSLocalizedString("Download"  , comment: "")
                                                        self.label2.setTitle("\(profileFieldString2)", for: UIControl.State.normal)
                                                        self.label2.setTitleColor(textColorDark, for: .highlighted)
                                                        self.label2.addTarget(self, action: #selector(ProductProfilePage.openDownloadableProduct), for: UIControl.Event.touchUpInside)
                                                        origin_labelheight_y2  = origin_labelheight_y2 + self.label2.bounds.height + 5
                                                        self.downloadableProducts.addSubview(self.label2)
                                                        if origin_labelheight_y2 > origin_labelheight_y{
                                                            self.downloadableProducts.frame.size.height = origin_labelheight_y2  + 5
                                                        }
                                                        else{
                                                            self.downloadableProducts.frame.size.height = origin_labelheight_y  + 5
                                                        }
                                                        i = i + 1
                                                        
                                                    }
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        else{
                                            self.downloadableProducts.isHidden = true
                                            self.downloadableProducts.frame.size.height = 0.0
                                            self.downloadableProducts.frame.origin.y = getBottomEdgeY(inputView:self.productName)
                                        }
                                        
                                        
                                    }
                                    else{
                                        self.downloadableProducts.isHidden = true
                                        self.downloadableProducts.frame.size.height = 0.0
                                        self.downloadableProducts.frame.origin.y = getBottomEdgeY(inputView:self.productName)
                                    }
                                    
                                    
                                    
                                }
                                
                                if let addToCart = productsProfile["canAddtoCart"] as? Int{
                                    if addToCart == 1{
                                        self.add.isHidden = false
                                        self.buy.isHidden = false
                                        
                                        if Messag_Owner == true {
                                            self.btnMsg.isHidden = false
                                        }
                                        else
                                        {
                                            self.bottomBorder2.isHidden = true
                                            self.bottomBorder3.isHidden = true
                                            self.add.frame.size.width = self.view.bounds.width/2
                                            
                                            let bottomBorder4 = UIView(frame: CGRect(x:self.view.bounds.width/2 - 1, y:0, width:1 , height:self.add.frame.size.height ))
                                            bottomBorder4.backgroundColor = textColorLight
                                            self.add.addSubview(bottomBorder4)
                                            self.mainView.addSubview(self.add)
                                            
                                            self.buy.frame.origin.x = self.view.bounds.width/2
                                            self.buy.frame.size.width = self.view.bounds.width/2
                                            self.mainView.addSubview(self.buy)
                                        }
                                    }
                                    
                                }
                                
                                if let menu = productsProfile["tabs"] as? NSArray{
                                    self.productProfileTabMenu = menu as NSArray
                                    if let productType = productsProfile["product_type"] as? String{
                                        if productType == "downloadable"{
                                            self.tabsContainerMenu.frame.origin.y = getBottomEdgeY(inputView:self.downloadableProducts) + 5
                                        }
                                        else  if productType == "grouped" || productType == "bundled"{
                                            self.tabsContainerMenu.frame.origin.y = getBottomEdgeY(inputView:self.groupedProducts) + 5
                                        }
                                        else{
                                            self.tabsContainerMenu.frame.origin.y = getBottomEdgeY(inputView:self.productName)  + 15
                                        }
                                    }
                                    self.tabsContainerMenu.isHidden = false
                                    for ob in self.tabsContainerMenu.subviews{
                                        if ob.tag == 101{
                                            ob.removeFromSuperview()
                                        }
                                    }
                                    var tempLabelCount = 0
                                    tempLabelCount = self.productProfileTabMenu.count
                                    var origin_x:CGFloat = 0
                                    for menu in self.productProfileTabMenu{
                                        if let menuItem = menu as? NSDictionary{
                                            var button_title : String! = ""
                                            if menuItem["name"] as! String == "overview"{
                                                button_title = NSLocalizedString("Info", comment: "")
                                            }
                                            else{
                                                button_title = menuItem["label"] as! String
                                            }
                                            
                                            if let totalItem = menuItem["totalItemCount"] as? Int{
                                                if totalItem > 0{
                                                    button_title = button_title + " (\(totalItem))"
                                                }
                                            }
                                            var width = findWidthByText(button_title as String) + 10
                                            if tempLabelCount < 3 {
                                                
                                                width = UIScreen.main.bounds.width / CGFloat(tempLabelCount)
                                            }
                                            else
                                            {
                                                width = UIScreen.main.bounds.width / CGFloat(tempLabelCount)
                                            }
                                            let menu = createNavigationButton(CGRect(x:origin_x,y:0 - contentPADING ,width:width , height:self.tabsContainerMenu.bounds.height + contentPADING) , title: button_title, border: true, selected: false)
                                            
                                            if menuItem["name"] as! String == "overview"{
                                                menu.setSelectedButton()
                                            }
                                            else{
                                                menu.setUnSelectedButton()
                                            }
                                            
                                            menu.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZENormal)
                                            menu.tag = 101
                                            menu.addTarget(self, action: #selector(ProductProfilePage.tabMenuAction), for: .touchUpInside)
                                            self.tabsContainerMenu.addSubview(menu)
                                            origin_x += width
                                            
                                        }
                                    }
                                    
                                    self.tabsContainerMenu.contentSize = CGSize(width:origin_x, height:self.tabsContainerMenu.bounds.height)
                                    
                                }
                                else{
                                    self.tabsContainerMenu.isHidden = true
                                    self.tabsContainerMenu.frame.size.height = 0.0
                                    if let productType = productsProfile["product_type"] as? String{
                                        if productType == "downloadable"{
                                            self.tabsContainerMenu.frame.origin.y = getBottomEdgeY(inputView:self.downloadableProducts) + 5
                                        }
                                        else  if productType == "grouped" || productType == "bundled"{
                                            self.tabsContainerMenu.frame.origin.y = getBottomEdgeY(inputView:self.groupedProducts) + 5
                                        }
                                        else{
                                            self.tabsContainerMenu.frame.origin.y = getBottomEdgeY(inputView:self.productName) + 15
                                        }
                                    }
                                    
                                }
                                
                                if let information = productsProfile["information"] as? NSDictionary{
                                    var signTextHeight : CGFloat = 0.0
                                    if let price = information["price"] as? NSDictionary{
                                        self.priceView.frame.origin.y = getBottomEdgeY(inputView:self.tabsContainerMenu) + 5
                                        self.priceView.isHidden = false
                                        if let inStock =  productsProfile["in_stock_product"] as? Bool{
                                            if inStock == true{
                                                self.Inoutstockstring.text = NSLocalizedString("In Stock", comment: "")
                                                self.Inoutstockstring.textColor = UIColor(red:0.31, green:0.57, blue:0.43, alpha:1.0)
                                                
                                            }
                                            else{
                                                self.Inoutstockstring.text = NSLocalizedString("Out Of Stock", comment: "")
                                                self.Inoutstockstring.textColor = UIColor.red
                                                
                                            }
                                            self.Inoutstockstring.sizeToFit()
                                        }
                                        if let  currencyValue = productsProfile["currency"] as? String{
                                            self.currency = currencyValue
                                        }
                                        if let discount = price["discount"] as? CGFloat{
                                            
                                            if discount == 1{
                                                if let productType = productsProfile["product_type"] as? String{
                                                    if productType == "grouped"{
                                                        self.discountedAmount.isHidden = false
                                                        self.discountedAmount.frame.origin.x = self.Inoutstockstring.frame.origin.x + self.Inoutstockstring.frame.size.width + 10
                                                        self.discountedAmount.text = NSLocalizedString("Starting at:", comment: "")
                                                        
                                                        self.discountedAmount.sizeToFit()
                                                    }
                                                    else{

                                                if let discountedPrice = price["discounted_amount"] as? CGFloat{
                                                    var discountedPrice = discountedPrice as NSNumber
                                                    self.discountedAmount.isHidden = false
                                                    if priceValue != 0.0{
                                                        discountedPrice = priceValue as NSNumber
                                                    }
                                                    self.priceThatChange = discountedPrice as! CGFloat
                                                    self.discountedAmount.frame.origin.x = self.Inoutstockstring.frame.origin.x + self.Inoutstockstring.frame.size.width + 10
                                                    var priceValueOfProduct = ""
                                                    let formatter = NumberFormatter()
                                                    formatter.numberStyle = .currency
                                                    formatter.locale = NSLocale.current // This is the default
                                                    formatter.currencyCode = "\(self.currency)"
                                                    
                                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                                        let defaults = UserDefaults.standard
                                                        if let name = defaults.object(forKey: "Currency")
                                                        {
                                                            let price = gettwoFractionDigits(FractionDigit: "\(discountedPrice)")
                                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price)!
                                                            let showPrice = (String(format:"%.2f", changePrice))
                                                            
                                                            priceValueOfProduct =  "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                                            
                                                        }
                                                    }
                                                    else{
                                                        priceValueOfProduct = formatter.string(from: discountedPrice)!
                                                    }
                                                    
                                                  //  priceValueOfProduct = formatter.string(from: discountedPrice)! // $123"
                                                    if let signValue = price["sign"] as? Int{
                                                        if signValue == 1{
                                                            
                                                            
                                                            self.discountedAmount.text = "\(priceValueOfProduct)*"
                                                            
                                                            
                                                        }
                                                        else{
                                                            self.discountedAmount.text = "\(priceValueOfProduct)"
                                                        }
                                                    }
                                                    else{
                                                        self.discountedAmount.text = "\(priceValueOfProduct)"
                                                    }
                                                    
                                                    self.discountedAmount.sizeToFit()
                                                    
                                                }
                                                    }
                                                }
                                                if let actualPrice = price["price"] as? CGFloat{
                                                    let actualPrice = actualPrice as NSNumber
                                                    self.originalPriceValue.isHidden = false
                                                    self.originalPriceValue.frame.origin.x = self.discountedAmount.frame.origin.x + self.discountedAmount.frame.size.width + 10
                                                    var price = ""
                                                    let formatter = NumberFormatter()
                                                    formatter.numberStyle = .currency
                                                    formatter.locale = NSLocale.current // This is the default
                                                    formatter.currencyCode = "\(self.currency)"
                                                    
                                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                                        let defaults = UserDefaults.standard
                                                        if let name = defaults.object(forKey: "Currency")
                                                        {
                                                            let price1 = gettwoFractionDigits(FractionDigit: "\(actualPrice)")
                                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price1)!
                                                            let showPrice = (String(format:"%.2f", changePrice))
                                                            
                                                            price = "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                                            
                                                        }
                                                    }
                                                    else{
                                                        price = formatter.string(from: actualPrice)!
                                                    }
                                                    
                                                   // price = formatter.string(from: actualPrice)! // $123"
                                                    self.originalPriceValue.text = "\(price)"
                                                    self.originalPriceValue.sizeToFit()
                                                    let viewBorder = UIView(frame:CGRect(x:0, y:6, width:self.originalPriceValue.frame.size.width, height:1))
                                                    viewBorder.backgroundColor = UIColor.black
                                                    viewBorder.tag = 1002
                                                    self.originalPriceValue.addSubview(viewBorder)
                                                    
                                                    
                                                    
                                                }
                                                
                                                if let discountValue = price["discount_percentage"] as? CGFloat{
                                                    let discountValue = discountValue as NSNumber
                                                    self.discountValue.isHidden = false
                                                    self.discountValue.frame.origin.x = self.originalPriceValue.frame.origin.x + self.originalPriceValue.frame.size.width + 10
                                                    let formatter = NumberFormatter()
                                                    formatter.numberStyle = .decimal
                                                    formatter.locale = NSLocale.current // This is the default
                                                    var  discountPriceValue = ""
                                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                                        let defaults = UserDefaults.standard
                                                        if let name = defaults.object(forKey: "Currency")
                                                        {
                                                            let price1 = gettwoFractionDigits(FractionDigit: "\(discountValue)")
                                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price1)!
                                                            let showPrice = (String(format:"%.2f", changePrice))
                                                            
                                                            discountPriceValue = "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                                            
                                                        }
                                                    }
                                                    else{
                                                       discountPriceValue = formatter.string(from: discountValue)!
                                                    }
                                                    
                                                   // discountPriceValue = formatter.string(from: discountValue)!
                                                    discountPriceValue = "\(discountPriceValue)% off"
                                                    self.discountValue.text = "\(discountPriceValue)"
                                                    self.discountValue.sizeToFit()
                                                    
                                                }
                                            }
                                            else{
                                                
                                                
                                                if let actualPrice = price["price"] as? CGFloat{
                                                    var actualPrice = actualPrice as NSNumber
                                                    if priceValue != 0.0{
                                                        actualPrice = priceValue as NSNumber
                                                    }
                                                    self.priceThatChange = actualPrice as! CGFloat
                                                    self.originalPriceValue.isHidden = false
                                                    self.originalPriceValue.frame.origin.x = self.Inoutstockstring.frame.origin.x + self.Inoutstockstring.frame.size.width + 10
                                                    var priceValueOfProduct = ""
                                                    let formatter = NumberFormatter()
                                                    formatter.numberStyle = .currency
                                                    formatter.locale = NSLocale.current // This is the default
                                                    formatter.currencyCode = "\(self.currency)"
                                                    
                                                    if  UserDefaults.standard.object(forKey: "Currency") != nil && UserDefaults.standard.object(forKey: "PriceRate") != nil {
                                                        let defaults = UserDefaults.standard
                                                        if let name = defaults.object(forKey: "Currency")
                                                        {
                                                            let price1 = gettwoFractionDigits(FractionDigit: "\(actualPrice)")
                                                            let changePrice = (defaults.object(forKey: "PriceRate") as! Float) * Float(price1)!
                                                            let showPrice = (String(format:"%.2f", changePrice))
                                                            
                                                            priceValueOfProduct = "\(getCurrencySymbol(name as! String)) \(showPrice)"
                                                            
                                                        }
                                                    }
                                                    else{
                                                        priceValueOfProduct = formatter.string(from: actualPrice)!
                                                    }
                                                    
                                                   // priceValueOfProduct = formatter.string(from: actualPrice)! // $123"
                                                    if let signValue = price["sign"] as? Int{
                                                        if signValue == 1{
                                                            self.originalPriceValue.text = String(format: NSLocalizedString("Starting at: %@*", comment: ""),"\(priceValueOfProduct)")
                                                            
                                                        }
                                                        else{
                                                           self.originalPriceValue.text = String(format: NSLocalizedString("Starting at: %@", comment: ""),"\(priceValueOfProduct)")
                                                        }
                                                    }
                                                    else{
                                                        self.originalPriceValue.text = String(format: NSLocalizedString("Starting at: %@", comment: ""),"\(priceValueOfProduct)")
                                                    }
                                                    self.originalPriceValue.sizeToFit()
                                                    
                                                    
                                                }
                                                
                                            }
                                            
                                            
                                            if let signValue = price["sign"] as? Int{
                                                if signValue == 1{
                                                    let  sign = createLabel(CGRect(x:contentPADING, y:self.discountedAmount.frame.origin.y + self.discountedAmount.frame.size.height + 5, width:self.priceView.bounds.height - (2 * contentPADING), height:50), text: "", alignment: .left, textColor: textColorDark)
                                                    sign.font = UIFont(name: fontName, size: FONTSIZENormal)
                                                    sign.longPressLabel()
                                                    sign.text = NSLocalizedString("Prices incl. VAT plus shipping costs", comment: "")
                                                    
                                                    self.priceView.addSubview(sign)
                                                    sign.sizeToFit()
                                                    signTextHeight = sign.frame.size.height
                                                    self.priceView.frame.size.height =   self.priceView.frame.size.height + signTextHeight
                                                }
                                            }
                                        }
                                    }
                                    
                                    // for config
                                    if let configArray = productsProfile["config"] as? NSDictionary{
                                        self.configView.frame.origin.y = getBottomEdgeY(inputView:self.priceView) + 5
                                        self.configView.isHidden = false
                                        
                                        self.configOnClick.setTitle(NSLocalizedString("Select Configurations ", comment: ""), for: UIControl.State.normal)
                                        self.configView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProductProfilePage.selectConfigAction)))
                                        self.configOnClick.titleLabel?.textAlignment = NSTextAlignment.center
                                        self.config = configArray
                                        self.configOnClick.addTarget(self, action: #selector(ProductProfilePage.selectConfigAction), for: UIControl.Event.touchUpInside)
                                        var arrayForShowFields = [NSDictionary]()
                                        if let configDependentArray = configArray["dependentFields"] as? NSArray{
                                            if configDependentArray.count > 0
                                            {
                                                for i in 0 ..< configDependentArray.count where i < configDependentArray.count
                                                {
                                                    if let dic = configDependentArray[i] as? NSDictionary
                                                    {
                                                        arrayForShowFields.append(dic)
                                                    }
                                                    
                                                }
                                            }
                                        }
                                        if let configInDependentArray = configArray["independentFields"] as? NSArray
                                        {
                                            if configInDependentArray.count > 0
                                            {
                                                for i in 0 ..< configInDependentArray.count where i < configInDependentArray.count
                                                {
                                                    if let dic = configInDependentArray[i] as? NSDictionary
                                                    {
                                                        arrayForShowFields.append(dic)
                                                    }
                                                    
                                                }
                                            }
                                        }
                                        if arrayForShowFields.count == 0
                                        {
                                            self.configOnClick.isHidden = true
                                            self.configView.frame.origin.y = getBottomEdgeY(inputView:self.priceView)
                                            self.configView.frame.size.height = 0
                                        }
                                        
                                        if arrayForShowFields.count == 1{
                                            let arrayForShowFields = arrayForShowFields[0] as! NSDictionary
                                            var nameOfDependentField : String = ""
                                            if arrayForShowFields["label"] as? String != nil{
                                                if let name = arrayForShowFields["label"] as? String{
                                                    nameOfDependentField = name
                                                }
                                            }
                                            var heightForMore = self.configOnClick.bounds.height
                                            let configField = createButton(CGRect(x:2 * PADING, y:heightForMore,width:self.view.bounds.width/2  , height:30),title: "", border: false,bgColor: false, textColor: navColor )
                                            configField.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
                                            configField.setTitle(NSLocalizedString("\(nameOfDependentField)", comment: ""), for: UIControl.State.normal)
                                            configField.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                                            configField.addTarget(self, action: #selector(ProductProfilePage.selectConfigAction), for: UIControl.Event.touchUpInside)
                                            self.configView.addSubview(configField)
                                            heightForMore = heightForMore + configField.bounds.height
                                            self.configView.frame.size.height = heightForMore + 5
                                            
                                            
                                        }
                                        else{
                                            var nameOfDependentField : String = ""
                                            var heightForMore2 = self.configOnClick.bounds.height
                                            let heightForMore = self.configOnClick.bounds.height
                                            if arrayForShowFields.count > 0
                                            {
                                                for i in 0 ..< arrayForShowFields.count where i < arrayForShowFields.count
                                                {
                                                    let arrayForShowField = arrayForShowFields[i] as! NSDictionary
                                                    if let name = arrayForShowField["label"] as? String
                                                    {
                                                            nameOfDependentField = name
                                                    }
                                                    else
                                                    {
                                                        let name = arrayForShowField["label"]
                                                        nameOfDependentField = String(describing: name!)
                                                    }
                                                    let configField = createButton(CGRect(x:2 * PADING, y:heightForMore2,width:self.view.bounds.width/2 , height:30),title: "", border: false,bgColor: false, textColor: navColor )
//                                                    if i == 0
//                                                    {
//                                                        configField.frame.origin.x = 2*PADING
//                                                    }
                                                    if (i+1) % 2 != 0
                                                    {
                                                        configField.frame.origin.x = 2*PADING
                                                    }
                                                    else if (i+1) % 2 == 0
                                                    {
                                                        configField.frame.origin.x = self.view.bounds.width/2
                                                        heightForMore2 = heightForMore2+30
                                                    }
                                                    configField.setTitle(NSLocalizedString("\(nameOfDependentField)", comment: ""), for: UIControl.State.normal)
                                                    configField.addTarget(self, action: #selector(ProductProfilePage.selectConfigAction), for: UIControl.Event.touchUpInside)
                                                    configField.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                                                    
                                                    self.configView.addSubview(configField)
                                                    
                                                }

                                                self.configView.frame.size.height = heightForMore + heightForMore2
                                            }
                                            else{
                                                self.configOnClick.isHidden = true
                                                self.configView.frame.origin.y = getBottomEdgeY(inputView:self.priceView)
                                                self.configView.frame.size.height = 0
                                            }
                                            
                                            
                                            
                                        }
                                        
                                    }
                                    else
                                    {
                                        
                                        self.configView.frame.origin.y = getBottomEdgeY(inputView:self.priceView)
                                        self.configView.frame.size.height = 0
                                    }
                                    
                                    if let rating = productsProfile["rating_avg"] as? Int{
                                        self.productReview.frame.origin.y = getBottomEdgeY(inputView:self.configView) + 5
                                        self.productReview.isHidden = false
                                        self.reviewLabel.isHidden = false
                                        self.updateRating(rating: rating, ratingCount: rating)
                                        
                                    }
                                    
                                    if let reviewCount = information[ "review_count"] as? Int{
                                        
                                        self.productReviewCount = reviewCount
                                        self.reviewCount.isHidden = false
                                        self.reviewCount.text = "Reviews: \(reviewCount)"
                                        
                                        if reviewCount != 0{
                                            self.review.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProductProfilePage.ProductReview)))
                                        }
                                        
                                        
                                        
                                    }
                                    
                                    
                                    if let likes = information[ "like_count"] as? Int{
                                        self.likeView.isHidden = false
                                        self.likeIcon.isHidden = false
                                        self.likeCount.isHidden = false
                                        self.productReview.frame.origin.y = getBottomEdgeY(inputView:self.configView) + 5
                                        self.likeIcon.text =   "\u{f164}"
                                        
                                        self.likeCount.text =   String(format: NSLocalizedString("Likes: %d ", comment: ""),likes)
                                        
                                    }
                                    
                                    
                                }
                                
                                
                                if let information = productsProfile["information"] as? NSDictionary{
                                    if  let profileFields = information["profileFields"] as? NSDictionary{
                                        self.profileView.isHidden = false
                                        self.profileView.frame.origin.y = getBottomEdgeY(inputView:self.productReview) + 5
                                        self.productProfileTitle.text = NSLocalizedString(" Product Information",  comment: "")
                                        
                                        //Work for showing profile fields
                                        var profileFieldString = ""
                                        var profileFieldString2 = ""
                                        
                                        
                                        var labelKey : String!
                                        var labelDesc : String!
                                        
                                        var labelKey2 : String!
                                        var labelDesc2 : String!
                                        
                                        var origin_labelheight_y2 : CGFloat = 0
                                        var origin_labelheight_y : CGFloat = 0
                                        origin_labelheight_y  = getBottomEdgeY(inputView:self.productProfileTitle)
                                        origin_labelheight_y2  = getBottomEdgeY(inputView:self.productProfileTitle)
                                        
                                        for(key,profileField) in profileFields{
                                            
                                            if profileField is NSDictionary{
                                                let    titleField = TTTAttributedLabel(frame:CGRect(x:2 * PADING,y:origin_labelheight_y + 5,width:self.view.bounds.width/2 - 2 * PADING , height:30) )
                                                titleField.textColor = textColorDark
                                                titleField.delegate = self
                                                titleField.isHidden = false
                                                titleField.backgroundColor = UIColor.white
                                                titleField.font = UIFont(name: fontBold, size: FONTSIZENormal)
                                                titleField.numberOfLines = 0
                                                titleField.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                titleField.isUserInteractionEnabled = true
                                                titleField.setText(key , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                    
                                                    return mutableAttributedString!
                                                })
                                                
                                                titleField.sizeToFit()
                                                self.profileView.addSubview(titleField)
                                                origin_labelheight_y  = origin_labelheight_y + titleField.bounds.height
                                                origin_labelheight_y2  = origin_labelheight_y + titleField.bounds.height
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
                                                            
                                                            
                                                            self.label5 = TTTAttributedLabel(frame:CGRect(x:2 * PADING,y:origin_labelheight_y + 5,width:self.view.bounds.width/2 - 2 * PADING , height:30) )
                                                            self.label5.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
                                                            self.label5.textColor = textColorDark
                                                            self.label5.delegate = self
                                                            self.label5.isHidden = false
                                                            labelKey = ((k as? String)! + ": ")
                                                            if v is NSInteger {
                                                                labelDesc = "\(v)"
                                                                profileFieldString = labelKey + "\(labelDesc!)" + "\n" + "\n"
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
                                                            self.label5.setText(profileFieldString , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                                
                                                                let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                                                                
                                                                let range1 = (profileFieldString as NSString).range(of: labelDesc as String)
                                                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                                                                
                                                                
                                                                return mutableAttributedString!
                                                            })
                                                            
                                                            self.label5.sizeToFit()
                                                            
                                                            
                                                            origin_labelheight_y  = origin_labelheight_y + self.label5.bounds.height
                                                            
                                                            loop = loop + 1
                                                            
                                                            
                                                            self.profileView.addSubview(self.label5)
                                                        }
                                                        else{
                                                            
                                                            loop = loop + 1
                                                            
                                                            self.label6 = TTTAttributedLabel(frame:CGRect(x:self.view.bounds.width/2 + 2 * PADING,y:origin_labelheight_y2 + 5,width:self.profileView.bounds.width/2 - 3 * PADING, height:30) )
                                                            
                                                            self.label6.textColor = textColorDark
                                                            self.label6.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
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
                                                            
                                                            
                                                            
                                                            self.label6.backgroundColor =  UIColor.white//aafBgColor //UIColor.red
                                                            
                                                            self.label6.font = UIFont(name: fontName, size: FONTSIZESmall)
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
                                                            self.label6.setText(profileFieldString2 , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                                
                                                                let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                                                                
                                                                let range1 = (profileFieldString2 as NSString).range(of: labelDesc2 as String)
                                                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                                mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                                                                
                                                                
                                                                return mutableAttributedString!
                                                            })
                                                            
                                                            self.label6.sizeToFit()
                                                            
                                                            origin_labelheight_y2  = origin_labelheight_y2 + self.label6.bounds.height
                                                            
                                                            self.profileView.addSubview(self.label6)
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                }
                                                
                                            }
                                            
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
                                                        
                                                        self.label5 = TTTAttributedLabel(frame:CGRect(x:2 * PADING,y:origin_labelheight_y + 5,width:self.view.bounds.width/2 - 2 * PADING , height:30) )
                                                        self.label5.linkAttributes = [kCTForegroundColorAttributeName:textColorDark]
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
                                                            
                                                            
                                                            return mutableAttributedString!
                                                        })
                                                        
                                                        self.label5.sizeToFit()
                                                        
                                                        
                                                        origin_labelheight_y  = origin_labelheight_y + self.label5.bounds.height
                                                        
                                                        loop = loop + 1
                                                        
                                                        
                                                        self.profileView.addSubview(self.label5)
                                                    }
                                                    else{
                                                        
                                                        loop = loop + 1
                                                        
                                                        self.label6 = TTTAttributedLabel(frame:CGRect(x:self.view.bounds.width/2 + 2 * PADING,y:origin_labelheight_y2 + 5,width:self.profileView.bounds.width/2 - 3 * PADING, height:30) )
                                                        
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
                                                        self.label6.setText(profileFieldString2 , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                            
                                                            let boldFont1 = CTFontCreateWithName((fontName as CFString?)!, FONTSIZENormal, nil)
                                                            
                                                            let range1 = (profileFieldString2 as NSString).range(of: labelDesc2 as String)
                                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                            mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                                                            
                                                            
                                                            return mutableAttributedString!
                                                        })
                                                        
                                                        self.label6.sizeToFit()
                                                        
                                                        origin_labelheight_y2  = origin_labelheight_y2 + self.label6.bounds.height
                                                        
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
                                    else{
                                        
                                        self.profileView.isHidden  = true
                                        self.profileView.frame.origin.y = getBottomEdgeY(inputView:self.productReview)
                                        self.profileView.frame.size.height = 0
                                    }
                                    
                                    if let productType = productsProfile["product_type"] as? String{
                                        
                                        if productType == "downloadable" || productType == "virtual"{
                                            
                                            self.shippingDetails.isHidden  = true
                                            self.shippingDetails.frame.origin.y = getBottomEdgeY(inputView:self.profileView)
                                            self.shippingDetails.frame.size.height = 0
                                            
                                        }
                                        else{
                                            if let shippingMethods = information["shippingMethods"] as? NSDictionary{
                                                self.shippingMethodsDetails = shippingMethods
                                                if let shippingMethodsCount = shippingMethods["totalItemCount"] as? Int{
                                                    if shippingMethodsCount > 0{
                                                        
                                                        self.shippingDetails.isHidden = false
                                                        self.shippingDetails.frame.origin.y = getBottomEdgeY(inputView:self.profileView) + 5
                                                        
                                                        var profileFieldString = ""
                                                        var origin_labelheight_y : CGFloat = 0
                                                        var heightForMore : CGFloat = 0
                                                        
                                                        
                                                        self.shippingDetailString = createButton(CGRect(x:2 * PADING, y:5,width:self.view.bounds.width - 4 * PADING , height:30),title: "", border: false,bgColor: false, textColor: textColorDark )
                                                        self.shippingDetailString.isHidden = false
                                                        
                                                        self.shippingDetailString.backgroundColor = UIColor.white//aafBgColor
                                                        self.shippingDetailString.setTitle(NSLocalizedString("Shipping Methods ", comment: ""), for: UIControl.State.normal)
                                                        self.shippingDetailString.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                                                        
                                                        self.shippingDetailString.addTarget(self, action: #selector(ProductProfilePage.methodsDetails), for: UIControl.Event.touchUpInside)
                                                        origin_labelheight_y  = origin_labelheight_y + self.shippingDetailString.bounds.height + 10
                                                        self.shippingDetails.addSubview(self.shippingDetailString)
                                                        
                                                        
                                                        
                                                        
                                                        if let shippingMethods = shippingMethods["methods"] as? NSArray{
                                                            
                                                            for shippingMethod in shippingMethods {
                                                                if let dic = shippingMethod as? NSDictionary {
                                                                    
                                                                    if  let title = dic["title"] as? String{
                                                                        profileFieldString =  "\(title)  " + ":"
                                                                        
                                                                    }
                                                                    if  let deliveryTime = dic["delivery_time"] as? String{
                                                                        profileFieldString = "\(profileFieldString)" + "   \(deliveryTime)"
                                                                        profileFieldString = profileFieldString +  NSLocalizedString(" (Delivery Time)", comment: "")
                                                                    }
                                                                    
                                                                    self.label1 = TTTAttributedLabel(frame:CGRect(x:2 * PADING,y:origin_labelheight_y + 5,width:self.view.bounds.width - 4 * PADING , height:30) )
                                                                    self.label1.textColor = textColorDark
                                                                    self.label1.isHidden = false
                                                                    self.label1.backgroundColor = UIColor.white//aafBgColor
                                                                    
                                                                    self.label1.font = UIFont(name: fontNormal, size: FONTSIZENormal)
                                                                    self.label1.numberOfLines = 0
                                                                    self.label1.lineBreakMode = NSLineBreakMode.byWordWrapping
                                                                    
                                                                    self.label1.text = profileFieldString
                                                                    self.label1.setText(profileFieldString , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                                                        
                                                                        let boldFont1 = CTFontCreateWithName((fontNormal as CFString?)!, FONTSIZESmall, nil)
                                                                        
                                                                        let range1 = (profileFieldString as NSString).range(of: profileFieldString as String)
                                                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTFontAttributeName as String as String), value: boldFont1, range: range1)
                                                                        mutableAttributedString?.addAttribute(NSAttributedString.Key(rawValue: kCTForegroundColorAttributeName as String as String), value:textColorMedium , range: range1)
                                                                        
                                                                        
                                                                        return mutableAttributedString!
                                                                    })
                                                                    
                                                                    self.label1.sizeToFit()
                                                                    
                                                                    
                                                                    origin_labelheight_y  = origin_labelheight_y + self.label1.bounds.height + 5
                                                                    
                                                                    self.shippingDetails.addSubview(self.label1)
                                                                }
                                                                
                                                                self.shippingDetails.frame.size.height = origin_labelheight_y  + 5
                                                            }
                                                            
                                                        }
                                                        heightForMore = origin_labelheight_y
                                                        
                                                        self.moreShippingMethodDetails = createButton(CGRect(x:2 * PADING, y:heightForMore,width:self.view.bounds.width - 30 , height:25),title: "", border: false,bgColor: false, textColor: navColor )
                                                        self.moreShippingMethodDetails.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.right
                                                        self.moreShippingMethodDetails.setTitle(NSLocalizedString("More", comment: ""), for: UIControl.State.normal)
                                                        self.moreShippingMethodDetails.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                                                        self.moreShippingMethodDetails.addTarget(self, action: #selector(ProductProfilePage.methodsDetails), for: UIControl.Event.touchUpInside)
                                                        self.shippingDetails.addSubview(self.moreShippingMethodDetails)
                                                        heightForMore = heightForMore + self.moreShippingMethodDetails.bounds.height
                                                        self.shippingDetails.frame.size.height = heightForMore + 5
                                                        
                                                        
                                                    }
                                                    else{
                                                        self.shippingDetails.isHidden  = true
                                                        self.shippingDetails.frame.origin.y = getBottomEdgeY(inputView:self.productReview)
                                                        self.shippingDetails.frame.size.height = 0
                                                    }
                                                }
                                                
                                            }
                                            else{
                                                
                                                self.shippingDetails.isHidden  = true
                                                self.shippingDetails.frame.origin.y = getBottomEdgeY(inputView:self.productReview)
                                                self.shippingDetails.frame.size.height = 0
                                                
                                            }
                                        }
                                        
                                    }
                                    
                                    var descriptionProduct = ""
                                    if let description = information["description"] as? String{
                                        descriptionProduct = description
                                    }
                                    else {
                                        if  let description =  productsProfile["body"] as? String{
                                            descriptionProduct = description
                                        }
                                    }
                                    
                                    if  descriptionProduct != ""{
                                        self.descriptionDetailString = createButton(CGRect(x:2 * PADING, y:5,width:self.view.bounds.width - 4 * PADING , height:30),title: "", border: false,bgColor: false, textColor: textColorDark )
                                        self.descriptionDetailString.isHidden = false
                                        
                                        self.descriptionDetailString.backgroundColor = UIColor.white//aafBgColor
                                        self.descriptionDetailString.setTitle(NSLocalizedString("Overview", comment: ""), for: UIControl.State.normal)
                                        self.descriptionDetailString.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZEMedium)
                                        self.descriptionView.addSubview(self.descriptionDetailString)
                                        
                                        
                                        self.descriptionView.isHidden = false
                                        self.descriptionView.frame.origin.y = getBottomEdgeY(inputView:self.shippingDetails) + 5
                                        if information["description"] != nil{
                                        self.RedirectText = String(describing: information["description"]!)
                                            self.overviewText = self.RedirectText
                                        self.RedirectText = self.RedirectText.html2String as String
                                        }
                                        
                                        
                                        let tempTextLimit =  100
                                        
                                        
                                        var tempInfo = ""
                                        if self.RedirectText != ""  {
                                            
                                            if self.RedirectText.length > tempTextLimit{
                                                tempInfo += (self.RedirectText as NSString).substring(to: tempTextLimit-3)
                                                tempInfo += NSLocalizedString("... ",  comment: "")
                                            }else{
                                                tempInfo += self.RedirectText
                                            }
                                        }
                                        
                                        
                                        self.Description.numberOfLines = 4
                                        self.Description.textColor = textColorDark
                                        self.Description.delegate = self
                                        self.Description.font = UIFont(name: fontName, size: FONTSIZESmall)
                                        self.Description.frame.origin.y = self.descriptionDetailString.bounds.height + 5
                                        self.Description.setText(tempInfo, afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
                                            
                                            // TODO: Clean this up...
                                            return mutableAttributedString!
                                        })
                                        
                                        self.Description.lineBreakMode = NSLineBreakMode.byWordWrapping
                                        self.Description.sizeToFit()
                                        
                                        if self.RedirectText.length > tempTextLimit{
                                            self.descriptionMoreOrLess.frame =  CGRect(x:self.view.bounds.width - 50, y:self.Description.frame.size.height + self.Description.frame.origin.y ,  width:40, height:30)
                                            self.descriptionMoreOrLess.addTarget(self, action: #selector(ProductProfilePage.descriptionOpen), for: UIControl.Event.touchUpInside)
                                            
                                            self.descriptionMoreOrLess.isHidden = false
                                            
                                            self.descriptionMoreOrLess.setTitle(NSLocalizedString("More", comment: ""), for: UIControl.State.normal)
                                        }else{
                                            self.descriptionMoreOrLess.frame =  CGRect(x:self.view.bounds.width - 50, y:self.Description.frame.size.height + self.Description.frame.origin.y ,  width:40, height:30)
                                            self.descriptionMoreOrLess.isHidden = true
                                            self.descriptionMoreOrLess.frame.size.height = 0.0
                                        }
                                        
                                        
                                        self.descriptionView.frame.size.height = self.descriptionMoreOrLess.frame.origin.y + self.descriptionMoreOrLess.bounds.height + 5
                                        
                                        
                                    }
                                    else{
                                        
                                        self.descriptionView.isHidden = true
                                        self.descriptionView.frame.origin.y = getBottomEdgeY(inputView:self.shippingDetails)
                                        self.descriptionView.frame.size.height = 0
                                        
                                    }
                                    
                                    
                                    
                                    
                                    if let relatedProduct = information["relatedProducts"] as? NSDictionary{
                                        if let relatedProductCount = relatedProduct["totalItemCount"] as? Int{
                                            if relatedProductCount > 0{
                                                self.relatedProducts.isHidden = false
                                                self.relatedProductsTitle.text = NSLocalizedString("Related Products",  comment: "")
                                                self.relatedProducts.frame.origin.y = self.descriptionView.frame.origin.y + self.descriptionView.bounds.height + 5
                                                if let products =  relatedProduct["products"] as? NSArray{
                                                    self.requiredStoresResponse = products as [AnyObject]
                                                    self.storeSlideshow.browseProducts(contentItems: self.requiredStoresResponse)
                                                }
                                                
                                                
                                            }
                                            else{
                                                self.relatedProducts.isHidden = true
                                                self.relatedProducts.frame.origin.y = getBottomEdgeY(inputView:self.descriptionView)
                                                self.relatedProducts.frame.size.height = 0
                                            }
                                            
                                            
                                        }
                                    }
                                    
                                }
                                
                                
                                self.scrollView.contentSize.height = getBottomEdgeY(inputView:self.relatedProducts) + 40
                                self.scrollView.sizeToFit()
                                
                                
                                
                            }
                            if succeeded["message"] != nil{
                                showToast(message: succeeded["message"] as! String, controller: self)
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
    
    
    // Add To Cart
    @objc func addToCart(){
        
        dic["product_id"] = "\(product_id)" as AnyObject?
        dic["quantity"] = 1 as AnyObject?
        if configurations.count > 0{
            if let _ = configurations["configFields"] as? NSDictionary{
                dic["configFields"] =  configurations["configFields"] as! NSDictionary
            }
        }
        else{
            dic["configFields"] = [:] as NSDictionary
        }
        if logoutUser == false{
            var parameters = [String:String]()
            if dic.count > 0{
                let dicc = (dic["configFields"])!
                parameters["product_config"] = GetjsonObject(data:dicc)
                callAddToCartApi(dictionary: dic){
                    (status : Bool) in
                    
                    if status == true{
                        if self.Buynow == true{
                            self.Buynow = false
                            let presentedVC = ManageCartViewController()
                            self.navigationController?.pushViewController(presentedVC, animated: true)
                        }
                    }
                    
                }
                
            }
            
        }
        else{
            if productProfileType == "downloadable"{
                showToast(message:NSLocalizedString("Please login to add this product.", comment: ""), controller: self)
                
            }
                
            else{
                if productProfileType != "grouped"{
                    updateCoreData(dictionary: dic)
                }
                else{
                    
                    for (_, element) in requiredProductResponse.enumerated()  {
                        var tempDict = Dictionary<String, AnyObject>()
                        tempDict["product_id"] = (element as! NSDictionary)["product_id"] as! NSString
                        tempDict["quantity"] = 1 as AnyObject?
                        tempDict["configFields"] =  [:] as NSDictionary
                        dicGroup.append(tempDict as AnyObject)
                        updateCoreData(dictionary: tempDict)
                    }
                    
                    showToast(message:"Added In Cart Successfully ", controller: self)
                    
                }
            }
        }
        
    }
    
    // call Api for addinfo product in cart
    func callAddToCartApi(dictionary : Dictionary<String, AnyObject>, completion: @escaping (_ status: Bool) -> Void){
        var statusofResponse : Bool = false
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
//            spinner.center = view.center
//            spinner.hidesWhenStopped = true
//            spinner.style = UIstyle.gray
//            view.addSubview(spinner)
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            var parameters = [String:String]()
            if dictionary.count > 0{
                if dictionary["configFields"] != nil{
                    let dicc = (dictionary["configFields"])!
                    parameters["product_config"] = GetjsonObject(data:dicc)
                }
            }
            // Send Server Request to Explore classified Contents with classified_ID
            post(parameters, url: "sitestore/product/add-to-cart/\(store_id!)/\(product_id!)", method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    activityIndicatorView.stopAnimating()
                    if msg{
                        if succeeded["message"] != nil{
                            statusofResponse = true
                            showToast(message: succeeded["message"] as! String, controller: self)
                            completion(statusofResponse)
                            getCartCount()
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            
                            
                        }
                    }
                    else
                    {
                        // Handle Server Side Error
                        
                        if succeeded["message"] != nil
                        {
                            showToast(message: succeeded["message"] as! String, controller: self)
                            completion(statusofResponse)
                            
                            
                        }
                    }
                })
            }
        }
        else{
            // No Internet Connection Message
           showToast(message: network_status_msg, controller: self)
        }
    }
    
    
    
    // Update core data Value
    func updateCoreData(dictionary : Dictionary<String, AnyObject>)
    {
        let results = GetallRecord()
        if(results.count>0){
            
            var i = 0
            for result: Any in results{
                let data = (result as AnyObject).value(forKey: "added_products")
                let output = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
                if let dict = output as? NSDictionary {
                    if (dict["product_id"] != nil && dictionary["product_id"] != nil && dict["configFields"] != nil && dictionary["configFields"] != nil){
                        if (dict["product_id"] as? Int  == dictionary["product_id"] as? Int) && (dict["configFields"] as? NSDictionary ==  dictionary["configFields"] as? NSDictionary){
                            dicToBeAdded.removeAll(keepingCapacity: true)
                            withConfigDicToBeAdded.removeAll(keepingCapacity: true)
                            withConfigDicToBeAdded["product_id"] =  dictionary["product_id"]
                            if let strquantity = dict["quantity"] as? String
                            {
                                let quantity = Int(strquantity)
                                if quantity != nil
                                {
                                    withConfigDicToBeAdded["quantity"] =  quantity! + 1 as  AnyObject?
                                }
                            }
                            else
                            {
                                withConfigDicToBeAdded["quantity"] = dict["quantity"] as! Int + 1  as  AnyObject?
                            }
                            withConfigDicToBeAdded["configFields"] = dictionary["configFields"]
                            indexValue = i
                            
                            break
                            
                        }
                        else if (dict["product_id"] as! Int  == dictionary["product_id"] as! Int){
                            // config diff
                            dicToBeAdded.removeAll(keepingCapacity: true)
                            dicToBeAdded.removeAll(keepingCapacity: true)
                            dicToBeAdded["product_id"] =  dictionary["product_id"]
                            dicToBeAdded["quantity"] =  dictionary["quantity"]
                            dicToBeAdded["configFields"] = dictionary["configFields"]
                            indexValue = i
                            
                        }
                        else{
                            dicToBeAdded.removeAll(keepingCapacity: true)
                            dicToBeAdded.removeAll(keepingCapacity: true)
                            dicToBeAdded["product_id"] =  dictionary["product_id"]
                            dicToBeAdded["quantity"] =  dictionary["quantity"]
                            dicToBeAdded["configFields"] = dictionary["configFields"]
                            indexValue = i
                            
                        }
                    }
                    
                }
                i = i + 1
                
            }
            
            
        }
        else{
            var parameters = [String:String]()
            if dictionary.count > 0{
                if productProfileType != "grouped"{
                    if dictionary["configFields"] != nil {
                        let dicc = (dictionary["configFields"])!
                        parameters["product_config"] = GetjsonObject(data:dicc)
                        callAddToCartApi(dictionary: dictionary){
                            (status : Bool) in
                            
                            
                            if status == true{
                                let newUser = NSEntityDescription.insertNewObject(forEntityName: "CartData", into: context) as NSManagedObject
                                newUser.setValue( NSKeyedArchiver.archivedData(withRootObject: dictionary) , forKey: "added_products")

                                do {
                                    try context.save()
                                } catch _ {
                                }
                                getCartCount()
                                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            }
                            
                        }
                    }
                }
                else{
                    let newUser = NSEntityDescription.insertNewObject(forEntityName: "CartData", into: context) as NSManagedObject
                    
                    newUser.setValue( NSKeyedArchiver.archivedData(withRootObject: dictionary) , forKey: "added_products")
                    
                    
                    do {
                        try context.save()
                    } catch _ {
                    }
                    getCartCount()
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
                
                
            }
        }
        if withConfigDicToBeAdded.count > 0{
            var parameters = [String:String]()
            if withConfigDicToBeAdded.count > 0{
                if productProfileType != "grouped"{
                    let dic = (withConfigDicToBeAdded["configFields"])!
                    parameters["product_config"] = GetjsonObject(data:dic)
                    callAddToCartApi(dictionary: withConfigDicToBeAdded){
                        (status : Bool) in
                        if status == true{
                            let result = results[indexValue] as! NSManagedObject
                            result.setValue( NSKeyedArchiver.archivedData(withRootObject: self.withConfigDicToBeAdded) , forKey: "added_products")
                            
                            do {
                                try context.save()
                            } catch _ {
                            }
                            getCartCount()
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        }
                        
                    }}
                    
                else{
                    let result = results[indexValue] as! NSManagedObject
                    result.setValue( NSKeyedArchiver.archivedData(withRootObject: self.withConfigDicToBeAdded) , forKey: "added_products")
                    
                    do {
                        try context.save()
                    } catch _ {
                    }
                    getCartCount()
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
            }
        }
        else if dicToBeAdded.count > 0{
            var parameters = [String:String]()
            if dicToBeAdded.count > 0{
                if productProfileType != "grouped"{
                    let dic = (dicToBeAdded["configFields"])!
                    parameters["product_config"] = GetjsonObject(data:dic)
                    callAddToCartApi(dictionary: dicToBeAdded){
                        (status : Bool) in
                        if status == true{
                            let newUser = NSEntityDescription.insertNewObject(forEntityName: "CartData", into: context) as NSManagedObject
                            
                            newUser.setValue( NSKeyedArchiver.archivedData(withRootObject: self.dicToBeAdded) , forKey: "added_products")
                            
                            
                            do {
                                try context.save()
                            } catch _ {
                            }
                            getCartCount()
                            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                            
                        }
                    }
                }
                else{
                    let newUser = NSEntityDescription.insertNewObject(forEntityName: "CartData", into: context) as NSManagedObject
                    
                    newUser.setValue( NSKeyedArchiver.archivedData(withRootObject: self.dicToBeAdded) , forKey: "added_products")
                    
                    
                    do {
                        try context.save()
                    } catch _ {
                    }
                    getCartCount()
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
            }
            
            
        }
        
        
        
        
    }
    
    
    // Open Downloadable Sample Products
    @objc func openDownloadableProduct(sender : UIButton){
        if  let response = downloadableProductResponse[sender.tag] as? NSDictionary{
            
            let string = response["filepath"]! as! String
            UIApplication.shared.openURL(NSURL(string: "\(string)")! as URL)
        }
        
        
    }
    
    func updateRating(rating:Int, ratingCount:Int)
    {
        
        
        for ob in reviewLabel.subviews
        {
            ob.removeFromSuperview()
        }
        
        var origin_x = 0 as CGFloat
       
        for i in 0 ..< 5
        {
            let rate = createButton(CGRect(x:origin_x, y:10 , width:FONTSIZEExtraLarge, height:FONTSIZEExtraLarge), title: "", border: false, bgColor: false, textColor: textColorLight)
            rate.backgroundColor = UIColor.clear
            rate.setImage(UIImage(named: "graystar.png"), for: .normal )

            if i < rating
            {
                rate.setImage(UIImage(named: "yellowStar.png"), for: .normal )
            }
            
            origin_x += 25
            reviewLabel.addSubview(rate)
        }
        
    }
    
    // Configuration selection
    @objc func  selectConfigAction(){
        SiteStoreObject().redirectToConfigFormViewPage(viewController: self, showOnlyMyContent: false, configArray : config,productId : product_id, priceValue : priceThatChange)
        
    }
    
    // For Share
    @objc func shareItem(){
        let alertController = UIAlertController(title: "", message:
            nil,preferredStyle: UIAlertController.Style.actionSheet)
        
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
                presentationController?.sourceRect = CGRect(x:self.view.bounds.width/2 , y:self.view.bounds.width/2, width:0, height:0)
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
            popover?.sourceRect = CGRect(x:view.bounds.width/2, y:view.bounds.height/2 , width:1, height:1)
            popover?.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // For Description
    @objc func descriptionOpen(){
        let presentedVC = OverViewViewController()//MLTInfoViewController()
        presentedVC.label1 = self.overviewText
       // presentedVC.contentType = "product"
        navigationController?.pushViewController(presentedVC, animated: true)
        
        
    }
    
    // Show Shipping details
    @objc func methodsDetails(){
        let presentedVC = ShippingMethodDetailsViewController()
        presentedVC.shippingMethodDetailss = shippingMethodsDetails
        presentedVC.currency = currency
        navigationController?.pushViewController(presentedVC, animated: true)
    }
    
    // Gutter Menu Option
    @objc func showGutterMenu(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        searchDic.removeAll(keepingCapacity: false)
        
        var url = ""
        
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary
            {
                
                if dic["name"] as! String == "videoCreate"
                {
                    continue
                }
                
                if dic["name"] as! String != "share"
                {
                        let condition = dic["name"] as! String
                        var actionUrl = ""
                        if let url = dic["url"] as? String
                        {
                            actionUrl = url
                        }
                        if (condition.range(of: "delete") != nil)
                        {
                            alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: UIAlertAction.Style.destructive, handler:{ (UIAlertAction) -> Void in
                                
                                let condition = dic["name"] as! String
                                switch(condition)
                                {
                                    
                                case "delete_product":
                                    
                                    displayAlertWithOtherButton(NSLocalizedString("Delete Product", comment: ""),message: NSLocalizedString("Are you sure you want to delete this Product?",comment: "") , otherButton: NSLocalizedString("Delete Product", comment: "")) { () -> () in
                                        self.deleteProductEntry = true
                                        self.performProductAction(url: actionUrl )
                                        
                                    }
                                    
                                    self.present(alert, animated: true, completion: nil)
                                    
                                default:
                                    
                                    showToast(message:unconditionalMessage, controller: self)
                                    
                                }
                            })) 
                        }
                        else
                        {
                            alertController.addAction(UIAlertAction(title: (dic["label"] as! String), style: .default, handler:{ (UIAlertAction) -> Void in
                                
                            switch(condition)
                            {
                                
                            case "tellafriend":
                                let presentedVC = TellAFriendViewController();
                                url = dic["url"] as! String
                                presentedVC.url = url
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                            case "askopinion":
                                let presentedVC = TellAFriendViewController();
                                presentedVC.opinion = true
                                url = dic["url"] as! String
                                presentedVC.url = url
                                self.navigationController?.pushViewController(presentedVC, animated: true)
                                
                                
                                
                            case "report":
                                let presentedVC = ReportContentViewController()
                                presentedVC.param = dic["urlParams"] as! NSDictionary
                                presentedVC.url = dic["url"] as! String
                                self.navigationController?.pushViewController(presentedVC, animated: false)
                                
                                
                            case "wishlist":
                                
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Add To Wishlist", comment: "")
                                presentedVC.contentType = "product wishlist"
                                presentedVC.url = dic["url"] as! String
                                var tempDic = NSDictionary()
                                tempDic = ["product_id" : String(self.product_id)]
                                presentedVC.param = tempDic
                                
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:false, completion: nil)
                                
                            case "create_review":
                                
                                isCreateOrEdit = true
                                globFilterValue = ""
                                
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Write a Review", comment: "")
                                presentedVC.contentType = "Review"
                                // var tempDic = NSDictionary()
                                // tempDic = ["listingtype_id" : "\(self.listingTypeId)"]
                                presentedVC.param = [ : ]
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                            case "update_review":
                                
                                
                                isCreateOrEdit = false
                                globFilterValue = ""
                                let presentedVC = FormGenerationViewController()
                                presentedVC.formTitle = NSLocalizedString("Update Review", comment: "")
                                presentedVC.contentType = "Review"
                                presentedVC.param = [ : ]
                                presentedVC.url = dic["url"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                            case "messageowner":
                                
                                if isChannelizeAvailable{
                                    if self.owner_id != nil{
                                        let data : [AnyHashable:Any] = [AnyHashable("userId"):self.owner_id]
                                        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController{
                                            let moduleName = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
                                            if let channelizeClass = NSClassFromString(moduleName + "." + "ChannelizeHelper") as? ChannelizeHelperDelegates.Type{
                                                channelizeClass.performChannelizeLaunch(navigationController: navigationController, data: data)
                                            }
                                        }
                                    }
                                } else{
                                    let presentedVC = MessageOwnerViewController();
                                    presentedVC.url = dic["url"] as! String
                                    self.navigationController?.pushViewController(presentedVC, animated: false)
                                }
                            case "edit_product":
                                
                                let presentedVC = AddProductToStoreViewController()
                                presentedVC.url = dic["url"] as! String
                                presentedVC.contentType = "editProduct"
                                isCreateOrEdit = false
                                /*let presentedVC = FormGenerationViewController()
                                presentedVC.url = dic["url"] as! String
                                presentedVC.contentType = "editProduct"
                                isCreateOrEdit = false
                                //presentedVC.storeId = String(self.store_id)
                                //presentedVC.productType = "" */
                                //presentedVC.formTitle = NSLocalizedString("Edit Product", comment: "")
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let nativationController = UINavigationController(rootViewController: presentedVC)
                                self.present(nativationController, animated:true, completion: nil)
                                
                            case "configure_product":
                                let presentedVC = ExternalWebViewController()
                                presentedVC.url = dic["webUrl"] as! String
                                presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                                let navigationController = UINavigationController(rootViewController: presentedVC)
                                self.present(navigationController, animated: true, completion: nil)
                                
                            default:
                                print("hello")
                                
                            }
                        }))
                    }
                
                }
            }
        }
        
        if  (UIDevice.current.userInterfaceIdiom == .phone)
        {
            alertController.addAction(UIAlertAction(title:  NSLocalizedString("Cancel",comment: ""), style: .cancel, handler:nil))
        }
        else
        {
            // Present Alert as! Popover for iPad
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = CGRect(x:view.bounds.width/2 , y:view.bounds.height/2, width:0, height:0)
            alertController.popoverPresentationController!.permittedArrowDirections = UIPopoverArrowDirection()
        }
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    // Add to Wishlist
    @objc func addToWishlist(){
        for menu in gutterMenu{
            if let dic = menu as? NSDictionary{
                if dic["name"] as! String == "wishlist"{
                    
                    let presentedVC = FormGenerationViewController()
                    presentedVC.formTitle = NSLocalizedString("Add To Wishlist", comment: "")
                    presentedVC.contentType = "product wishlist"
                    presentedVC.url = dic["url"] as! String
                    var tempDic = NSDictionary()
                    tempDic = ["product_id" : String(self.product_id)]
                    presentedVC.param = tempDic
                    
                    presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                    let nativationController = UINavigationController(rootViewController: presentedVC)
                    self.present(nativationController, animated:false, completion: nil)

                }
            }
        }
        
        
        
    }
    
    // Action after click on tabBar
    @objc func tabMenuAction(sender:UIButton){
        for menu in productProfileTabMenu{
            if let menuItem = menu as? NSDictionary{
                
                var button_title = menuItem["label"] as! String
                
                
                if let totalItem = menuItem["totalItemCount"] as? Int{
                    if totalItem > 0{
                        button_title += " (\(totalItem))"
                    }
                }
                
                if sender.titleLabel?.text == button_title{
                    
                    if menuItem["name"] as! String == "review"
                    {
                        let presentedVC = PageReviewViewController()
                        presentedVC.mytitle = contentTitle
                        presentedVC.subjectId = "\(product_id!)"
                        presentedVC.storeId = store_id
                        presentedVC.contentType = "product"
                        
                        if let totalItem = menuItem["count"] as? Int
                        {
                            if totalItem > 0
                            {
                                presentedVC.currentReviewcount = totalItem
                                
                            }
                        }
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                    }
                    
                    if menuItem["name"] as! String == "photos"
                    {
                        let presentedVC = PhotoListViewController()
                        presentedVC.contentType = "product_photo"
                        let tempUrl = menuItem["url"] as! String
                        presentedVC.mytitle = self.contentTitle
                        presentedVC.url = tempUrl
                        presentedVC.param = ["subject_type" : "sitestoreproduct_album"]
                        self.navigationController?.pushViewController(presentedVC, animated: false)
                        
                    }
                    
                    if menuItem["name"] as! String == "main_file"
                    {
                        let presentedVC = FileListViewController()
                        presentedVC.url = menuItem["url"] as! String
                        presentedVC.urlParams = menuItem["urlParams"] as! NSDictionary
                        presentedVC.contentType = "mainFile"
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let nativationController = UINavigationController(rootViewController: presentedVC)
                        self.present(nativationController, animated:false, completion: nil)
                        
                        /*let presentedVC = FormGenerationViewController()
                        presentedVC.url = "sitestore/product/file/upload-file/"+String(product_id)
                        presentedVC.formTitle = "Upload Main File"
                        presentedVC.contentType = "mainFile"
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let nativationController = UINavigationController(rootViewController: presentedVC)
                        self.present(nativationController, animated:false, completion: nil) */
                    }
                    
                    if menuItem["name"] as! String == "sample_file"
                    {
                        let presentedVC = FileListViewController()
                        presentedVC.url = menuItem["url"] as! String
                        presentedVC.urlParams = menuItem["urlParams"] as! NSDictionary
                        presentedVC.contentType = "sampleFile"
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let nativationController = UINavigationController(rootViewController: presentedVC)
                        self.present(nativationController, animated:false, completion: nil)
                        
                        /*let presentedVC = FormGenerationViewController()
                        presentedVC.url = "sitestore/product/file/upload-file/"+String(product_id)
                        presentedVC.formTitle = "Upload sample file"
                        presentedVC.contentType = "sampleFile"
                        presentedVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        let nativationController = UINavigationController(rootViewController: presentedVC)
                        self.present(nativationController, animated:false, completion: nil)*/
                    }
                    
                    
                }
            }
        }
    }
    
    // Page REview Redirection
    @objc func ProductReview(){
        let presentedVC = PageReviewViewController()
        presentedVC.mytitle = contentTitle
        presentedVC.subjectId = "\(product_id!)"
        presentedVC.storeId = store_id
        presentedVC.contentType = "product"
        if productReviewCount > 0
        {
            presentedVC.currentReviewcount = productReviewCount
            
        }
        self.navigationController?.pushViewController(presentedVC, animated: false)
        
    }
    
    //After Click on Image
    @objc func onImageViewTap(sender:UITapGestureRecognizer)
    {
        let pv = ActivityFeedPhotoViewController()
        pv.photoAttachmentArray = self.totalProductImage
        pv.photoIndex = sender.view!.tag
        pv.photoType = "product_photo"
        let nativationController = UINavigationController(rootViewController: pv)
        present(nativationController, animated:true, completion: nil)
        
    }
    
    // Show cart when click on buy now
    @objc func showCart(){
        iscomingfrom = ""
        Buynow = true
        addToCart()
    }
    
    // Handle Scroll For Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if scrollView.tag == 1000{
            let scrollOffset = scrollView.contentOffset.y
            
            let scrollViewHeight = scrollView.frame.size.height / 2
            if (scrollOffset > 30.0){
                let barAlpha = max(0, min(1, (scrollOffset/155)))
                setNavigationImage(controller: self)
                self.marqueeHeader.text = self.contentTitle
                self.navigationController?.navigationBar.alpha = barAlpha
                self.marqueeHeader.textColor = textColorPrime
                self.marqueeHeader.alpha = barAlpha
                self.marqueeHeader.textColor = textColorPrime
                
                if (self.lastContentOffset > scrollView.contentOffset.y) {
                    // move up
                    self.add.fadeIn()
                    self.buy.fadeIn()
                    self.btnMsg.fadeIn()
                }
                else if ((self.lastContentOffset < scrollView.contentOffset.y) && (scrollView.contentOffset.y < scrollViewHeight - 5 )){
                    // move down
                    self.add.fadeOut()
                    self.buy.fadeOut()
                    self.btnMsg.fadeOut()
                }
                
                // update the new position acquired
                self.lastContentOffset = scrollView.contentOffset.y
                
                
            }
            else{
                if self.marqueeHeader != nil{
                    self.marqueeHeader.text = ""
                }
                removeNavigationImage(controller: self)
                if self.marqueeHeader != nil{
                    self.marqueeHeader.alpha = 1
                }
                
                
                
            }
        }
    }

    func performProductAction(url: String)
    {
        if Reachabable.isConnectedToNetwork() {
            removeAlert()
            self.view.addSubview(activityIndicatorView)
            activityIndicatorView.center = self.view.center
            activityIndicatorView.startAnimating()
            
            var dic = Dictionary<String, String>()
            
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
                        
                        if self.deleteProductEntry == true {
                            storeUpdate = true
                            storeDetailUpdate = true
                            productDetailUpdate = true
                            productUpdate = true
                            
                            //_ = self.dismiss(animated: false, completion: nil)
                            _ = self.navigationController?.popViewController(animated: false)
                            //return
                        }
                        else
                        {
                            storeUpdate = true
                            storeDetailUpdate = true
                            productUpdate = true
                            productDetailUpdate = true
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
            showAlertMessage(view.center , msg: network_status_msg , timer: false)
        }
        
    }
    
    func showAlertMessage( _ centerPoint: CGPoint, msg: String, timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
            createTimer(self)
        }
    }
    func createTimer(_ target: AnyObject){
        timer = Timer.scheduledTimer(timeInterval: 2, target: target, selector:  #selector(stopTimer), userInfo: nil, repeats: false)
    }
    @objc func stopTimer() {
        stop()
    }
    @objc func goBack()
    {
        configurations.removeAll(keepingCapacity: false)
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
