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
//  StickersDetailsViewController.swift
//  seiosnativeapp
//

import UIKit
class StickersDetailsViewController: UIViewController,TTTAttributedLabelDelegate, UIScrollViewDelegate {
    
    var stickerImageView : UIImageView!
    var collectionId : Int!
    var scrollView : UIScrollView!
    var stictersValue :  NSArray = []
    var totalItems : Int = 0
    var stickerDescription : TTTAttributedLabel!
    var particularStickersView : UIView!
    var allStickers :  NSArray = []
    var sticterMenu :  NSArray = []
    var AddOrRemove : UIButton!
    var stickerIdToBeAdded:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = NSLocalizedString("Sticker Store",  comment: "")
        view.backgroundColor = bgColor
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(imagefromColor(navColor), for: .default)
        self.navigationController?.navigationBar.shadowImage = imagefromColor(navColor)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = textColorLight
        
        
        let leftNavView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        leftNavView.backgroundColor = UIColor.clear
        let tapView = UITapGestureRecognizer(target: self, action: #selector(InfoViewController.goBack))
        leftNavView.addGestureRecognizer(tapView)
        
        
        let backIconImageView = createImageView(CGRect(x: 0,y: 12,width: 22,height: 22), border: false)
        backIconImageView.image = UIImage(named: "back_icon")
        leftNavView.addSubview(backIconImageView)
        
        if footerDashboard == false {
            let barButtonItem = UIBarButtonItem(customView: leftNavView)
            self.navigationItem.leftBarButtonItem = barButtonItem
        }
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = bgColor
        scrollView.tag = 1000
        scrollView.delegate = self
        scrollView.bounces = false
        scrollView.contentSize = view.bounds.size
        scrollView.sizeToFit()
        view.addSubview(scrollView)
        getStickers()
    }
    
    
    
    //MARK: Get All Stickers and set In Table View
    func  getStickers(){
        // Check Internet Connection
        if reachability.isReachable {
            removeAlert()
            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
            dic["collection_id"] = String(collectionId)
            spinner.center = CGPoint(x: view.center.x , y: view.center.y)
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            self.view.addSubview(spinner)
            spinner.startAnimating()
            post(dic, url: "reactions/store", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    spinner.stopAnimating()
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                // Check for Stickers Array
                                if let stickerArray = body["response"] as? NSArray
                                {
                                    self.stictersValue = stickerArray
                                    self.totalItems = self.stictersValue.count
                                    if let stickerArrayDictionary = stickerArray[0] as? NSDictionary{
                                        if let allstickerArray = stickerArrayDictionary["stickers"] as? NSArray
                                        {
                                            self.allStickers = allstickerArray
                                        }
                                        if let menu = stickerArrayDictionary["menu"] as? NSArray
                                        {
                                            self.sticterMenu = menu
                                        }
                                    }
                                    self.stickersUI()
                                }
                            }
                        }
                    }
                })
            }
        }
        else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }
    
    //MARK: Show all Stickers
    func stickersUI(){
        let sticterDetails =  sticterArray[0] as! NSDictionary
        stickerImageView = createImageView(CGRect(x: 10, y: 10, width: 60, height: 60), border: true)
        if let icon = sticterDetails["image"] as? String {
            let url = URL(string:icon)
            downloadData(url!, downloadCompleted: { (downloadedData, msg) -> () in
                if msg{
                    let image: UIImage  = UIImage(data: downloadedData)!
                    self.stickerImageView.image = image
                }
            })
        }
        scrollView.addSubview(stickerImageView)
        
        
        
        self.stickerDescription = TTTAttributedLabel(frame:CGRect(x:stickerImageView.frame.size.width + stickerImageView.frame.origin.x + 10,y:10,width:self.view.bounds.width - (stickerImageView.frame.size.width + stickerImageView.frame.origin.x + 10) , height:60) )
        self.stickerDescription.textColor = textColorDark
        self.stickerDescription.isHidden = false
        self.stickerDescription.backgroundColor = bgColor
        self.stickerDescription.font = UIFont(name: fontNormal, size: FONTSIZESmall)
        self.stickerDescription.numberOfLines = 0
        self.stickerDescription.lineBreakMode = NSLineBreakMode.byWordWrapping
        var textWithTitleDescription = ""
        var titleOfSticker = ""
        if sticterDetails["title"] != nil{
            let title = String(describing: sticterDetails["title"]!)
            textWithTitleDescription = "\(title)"
            titleOfSticker = "\(title)"
        }
        if sticterDetails["body"] != nil{
            let description = String(describing: sticterDetails["body"]!)
            textWithTitleDescription +=  "\n"  + "\n" +  "\(description)"
        }
        self.stickerDescription.setText(textWithTitleDescription , afterInheritingLabelAttributesAndConfiguringWith: { (mutableAttributedString: NSMutableAttributedString?) -> NSMutableAttributedString? in
            let boldFont1 = CTFontCreateWithName(fontBold as CFString?, FONTSIZELarge, nil)
            let range1 = (textWithTitleDescription as NSString).range(of: titleOfSticker as String)
            mutableAttributedString?.addAttribute(kCTFontAttributeName as String, value: boldFont1, range: range1)
            mutableAttributedString?.addAttribute(kCTForegroundColorAttributeName as String, value:textColorDark , range: range1)
            return mutableAttributedString!
        })
        self.stickerDescription.sizeToFit()
        
        scrollView.addSubview(stickerDescription)
        var actualDistanceOfY =  CGFloat()
        if stickerDescription.frame.size.height > stickerImageView.frame.size.height{
            actualDistanceOfY = stickerDescription.frame.size.height + stickerDescription.frame.origin.y
        }
        else{
            actualDistanceOfY = stickerImageView.frame.size.height + stickerImageView.frame.origin.y
        }
        
        AddOrRemove =    createButton(CGRect(x: 5,y: actualDistanceOfY + 10 ,width: view.bounds.width - (10)  ,height: 40), title: "", border: false,bgColor: false, textColor: textColorLight)
        AddOrRemove.titleLabel?.textAlignment = NSTextAlignment.center
        AddOrRemove.layer.cornerRadius = 10.0
        AddOrRemove.titleLabel?.font = UIFont(name: fontBold, size: FONTSIZELarge)
        AddOrRemove.backgroundColor = UIColor.blue
        if sticterMenu.count > 0{
            for menu in sticterMenu {
                print(menu)
                if let dic = menu as? NSDictionary{
                    if dic["name"] as? String  == "remove"{
                        AddOrRemove.setTitle(dic["label"] as? String, for: .normal)
                    }
                    else if dic["name"] as? String == "add"{
                        AddOrRemove.setTitle(dic["label"] as? String, for: .normal)
                    }
                    
                }
            }
        }
        AddOrRemove.addTarget(self, action: #selector(StickersDetailsViewController.addOrRemoveSticker), for: UIControlEvents.touchUpInside)
        scrollView.addSubview(AddOrRemove)
        
        
        particularStickersView = createView(CGRect(x: 0, y: AddOrRemove.frame.size.height + AddOrRemove.frame.origin.y + 10 ,width: self.view.bounds.width  ,height: view.bounds.height - (stickerDescription.frame.size.height + stickerDescription.frame.origin.y + 10)), borderColor: borderColorLight, shadow: false)
        particularStickersView.backgroundColor =   bgColor
        particularStickersView.tag = 3;
        if allStickers.count > 0 {
            var origin_x1:CGFloat = PADING
            var origin_y1:CGFloat = PADING
            var menuWidth1 = CGFloat()
            var menuHeight1 = CGFloat()
            menuWidth1 = (self.view.bounds.width/4) - (2 * PADING)
            menuHeight1 = (self.view.bounds.width/4) - (2 * PADING)
            for i in 1...self.allStickers.count {
                let stickerView = createImageView(CGRect(x: origin_x1, y: origin_y1, width: (self.view.bounds.width/4) - (2 * PADING), height: (self.view.bounds.width/4) - (2 * PADING)), border: false)
                if let dic = allStickers[i - 1] as? NSDictionary{
                    if dic["image"] != nil{
                        let icon = dic["image"]
                        let url = URL(string:icon as! String)
                        downloadData(url!, downloadCompleted: { (downloadedData, msg) -> () in
                            if msg{
                                let image: UIImage  = UIImage(data: downloadedData)!
                                stickerView.image = image
                            }
                        })
                    }
                }
                particularStickersView.addSubview(stickerView)
                origin_x1 = menuWidth1 + origin_x1 + (2 * PADING)
                if i%4 == 0{
                    origin_x1 = PADING
                    origin_y1 = menuHeight1 + origin_y1 + PADING
                }
            }
            if self.allStickers.count  % 4 != 0{
                origin_y1 = menuHeight1 + origin_y1 + PADING
            }
            particularStickersView.frame.size.height = origin_y1
            scrollView.addSubview(particularStickersView)
        }
        let totalHeight = particularStickersView.frame.origin.y + particularStickersView.frame.size.height + 10
        scrollView.contentSize = CGSize(width: view.bounds.width,height: totalHeight)
    }
    
    //MARK: Add or Remove Stickers
    func addOrRemoveSticker(){
        var url = ""
        var blogInfo:NSDictionary
        var collectionId : Int!
        var order : Int = 0
        var dic1 = Dictionary<String, String>()
        blogInfo = stictersValue[0] as! NSDictionary
        order = (blogInfo["order"] as? Int)!
        collectionId = blogInfo["collection_id"] as? Int
        var addOrRemoveValue = false
        for menu in sticterMenu {
            if let dic = menu as? NSDictionary{
                if dic["name"] != nil{
                    if dic["name"] as? String  == "remove"{
                        addOrRemoveValue = true
                        url = (dic["url"] as? String)!
                        
                        let params = dic["urlParams"] as? NSDictionary
                        for(k,v) in params!{
                            dic1["\(k)"] = "\(v)"
                        }
                    }
                    else if dic["name"] as? String == "add"{
                        addOrRemoveValue = false
                        url = (dic["url"] as? String)!
                        let params = dic["urlParams"] as? NSDictionary
                        for(k,v) in params!{
                            dic1["\(k)"] = "\(v)"
                        }
                    }
                }
            }
        }
        
        // Check Internet Connection
        if reachability.isReachable {
            removeAlert()
            // Send Server Request for Comments
            spinner.center = CGPoint(x: view.center.x , y: view.center.y)
            spinner.hidesWhenStopped = true
            spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            self.view.addSubview(spinner)
            spinner.startAnimating()
            post(dic1, url: url, method: "POST") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    spinner.stopAnimating()
                    if msg
                    {
                        self.view.makeToast(succeeded["message"] as! String, duration: 5, position: "bottom")
                        // Remove Sticker from sticterArray Or Add Sticker in sticterArray
                        if addOrRemoveValue == true{
                            for (index, element) in sticterArray.enumerated() {
                                if let dic = element as? NSDictionary {
                                    if  let collection_id = dic["collection_id"] as? Int{
                                        if collection_id == collectionId{
                                            commentsUpdate = true
                                            sticterArray.removeObject(at: index)
                                        }
                                    }
                                }
                            }
                        }
                        else{
                            commentsUpdate = true
                            sticterArray.add(blogInfo)
                        }
                        // Remove Sticker from allStickersValueDic Or Add Sticker in allStickersValueDic
                        if addOrRemoveValue == true{
                            allStickersValueDic.removeValue(forKey: "\(order)")
                        }
                        else{
                            self.stickerIdToBeAdded = collectionId
                            self.StickersOfParticularSticker()
                        }
                        self.getStickers()
                    }
                })
            }
        }
        else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }
    
    //MARK: If added then fetch all stickers for Particular Stickers
    func  StickersOfParticularSticker(){
        var order : Int = 0
        // Check Internet Connection
        if reachability.isReachable {
            removeAlert()
            // Send Server Request for Comments
            var dic = Dictionary<String, String>()
            dic["collection_id"] = String(stickerIdToBeAdded)
            post(dic, url: "reactions/stickers", method: "GET") { (succeeded, msg) -> () in
                DispatchQueue.main.async(execute: {
                    spinner.stopAnimating()
                    if msg
                    {
                        if succeeded["body"] != nil{
                            if let body = succeeded["body"] as? NSDictionary{
                                
                                if let collectionArray = body["collection"] as? NSDictionary{
                                    if let orderOfSticker = collectionArray["order"] as? Int{
                                        order = orderOfSticker
                                    }
                                }
                                // Check for Stickers Array
                                if let stickerArray = body["stickers"] as? NSArray
                                {
                                    let value = stickerArray
                                    commentsUpdate = true
                                    allStickersValueDic["\(order)"] = value
                                }
                            }
                        }
                    }
                    
                })
            }
        }
        else{
            // No Internet Connection Message
            self.view.makeToast(network_status_msg, duration: 5, position: "bottom")
        }
    }
    
    // Generate Form On View Appear
    func showAlertMessage( _ centerPoint: CGPoint, msg: String , timer: Bool){
        self.view .addSubview(validationMsg)
        showCustomAlert(centerPoint, msg: msg)
        if timer {
            // Initialization of Timer
            createTimer(self)
        }
    }
    
    
    func goBack()
    {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
